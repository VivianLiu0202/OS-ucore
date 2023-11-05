#include <default_pmm.h>
#include <defs.h>
#include <error.h>
#include <memlayout.h>
#include <mmu.h>
#include <pmm.h>
#include <sbi.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <sync.h>
#include <vmm.h>
#include <riscv.h>

// virtual address of physical page array
struct Page *pages; //指向物理页面数组的指针，用于跟踪物理页面的分配和释放。
// amount of physical memory (in pages)
size_t npage = 0; //表示物理内存中页面的数量
// The kernel image is mapped at VA=KERNBASE and PA=info.base
uint_t va_pa_offset; //表示内核镜像在虚拟地址空间中的偏移量，用于将虚拟地址转换为物理地址。
// memory starts at 0x80000000 in RISC-V
const size_t nbase = DRAM_BASE / PGSIZE; //物理内存的起始地址，用于计算物理地址。

// virtual address of boot-time page directory 启动时页目录表的虚拟地址，用于跟踪虚拟地址到物理地址的映射关系。
pde_t *boot_pgdir = NULL;
// physical address of boot-time page directory
uintptr_t boot_cr3; //表示启动时页目录表的物理地址，用于在处理器中加载页目录表。

// physical memory management
const struct pmm_manager *pmm_manager;

static void check_alloc_page(void);
static void check_pgdir(void);
static void check_boot_pgdir(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void)
{
    pmm_manager = &default_pmm_manager;
    cprintf("memory management: %s\n", pmm_manager->name);
    pmm_manager->init();
}

// init_memmap - call pmm->init_memmap to build Page struct for free memory
static void init_memmap(struct Page *base, size_t n)
{
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
//在alloc_pages()里面，如果此时试图得到空闲页且没有空闲的物理页时，我们才尝试换出页面到硬盘上。
struct Page *alloc_pages(size_t n)
{
    struct Page *page = NULL;
    bool intr_flag;

    while (1)
    {
        local_intr_save(intr_flag);
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        // pmm_init的时候swap_init_ok为0，所以不会执行下面的代码
        // 进行到swap_init的时候，swap_init_ok为1，所以会执行下面的代码
        //如果有足够的物理页面，就不必换出其他页面
        //如果n>1, 说明希望分配多个连续的页面，但是我们换出页面的时候并不能换出连续的页面
 		//swap_init_ok标志是否成功初始化了
        if (page != NULL || n > 1 || swap_init_ok == 0)
            break;

        extern struct mm_struct *check_mm_struct;
        cprintf("page %x, call swap_out in alloc_pages %d\n", page, n);
        swap_out(check_mm_struct, n, 0); //调用页面置换的”换出页面“接口。这里必有n=1
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;

    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
    }
    local_intr_restore(intr_flag);
}

// nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
// of current free memory
size_t nr_free_pages(void)
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
    }
    local_intr_restore(intr_flag);
    return ret;
}

/* page_init - initialize the physical memory management */
static void page_init(void)
{
    extern char kern_entry[];

    va_pa_offset = KERNBASE - 0x80200000;
    uint64_t mem_begin = KERNEL_BEGIN_PADDR;
    uint64_t mem_size = PHYSICAL_MEMORY_END - KERNEL_BEGIN_PADDR;
    uint64_t mem_end = PHYSICAL_MEMORY_END; // 硬编码取代 sbi_query_memory()接口
    cprintf("membegin %llx memend %llx mem_size %llx\n", mem_begin, mem_end, mem_size);
    cprintf("physcial memory map:\n");
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
            mem_end - 1);
    uint64_t maxpa = mem_end;

    if (maxpa > KERNTOP)
    {
        maxpa = KERNTOP;
    }

    extern char end[];

    npage = maxpa / PGSIZE;
    // BBL has put the initial page table at the first available page after the
    // kernel
    // so stay away from it by adding extra offset to end
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
    for (size_t i = 0; i < npage - nbase; i++)
    {
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
    mem_begin = ROUNDUP(freemem, PGSIZE);
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
    if (freemem < mem_end)
    {
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

static void enable_paging(void)
{
    write_csr(satp, (0x8000000000000000) | (boot_cr3 >> RISCV_PGSHIFT));
}

/**
 * @brief      setup and enable the paging mechanism
 *
 * @param      pgdir  The page dir
 * @param[in]  la     Linear address of this memory need to map
 * @param[in]  size   Memory size
 * @param[in]  pa     Physical address of this memory
 * @param[in]  perm   The permission of this memory
 */
static void boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size,
                             uintptr_t pa, uint32_t perm)
{
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n--, la += PGSIZE, pa += PGSIZE)
    {
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pte_create(pa >> PGSHIFT, PTE_V | perm);
    }
}

// boot_alloc_page - allocate one page using pmm->alloc_pages(1)
// return value: the kernel virtual address of this allocated page
// note: this function is used to get the memory for PDT(Page Directory
// Table)&PT(Page Table)
static void *boot_alloc_page(void)
{
    struct Page *p = alloc_page();
    if (p == NULL)
    {
        panic("boot_alloc_page failed.\n");
    }
    return page2kva(p);
}

// pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup
// paging mechanism
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void pmm_init(void)
{
    // We need to alloc/free the physical memory (granularity is 4KB or other
    // size).
    // So a framework of physical memory manager (struct pmm_manager)is defined
    // in pmm.h
    // First we should init a physical memory manager(pmm) based on the
    // framework.
    // Then pmm can alloc/free the physical memory.
    // Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();

    // use pmm->check to verify the correctness of the alloc/free function in a
    // pmm
    check_alloc_page();
    // create boot_pgdir, an initial page directory(Page Directory Table, PDT)
    extern char boot_page_table_sv39[];         // entry.S中定义的页表
    boot_pgdir = (pte_t *)boot_page_table_sv39; // 页目录表的虚拟地址
    boot_cr3 = PADDR(boot_pgdir);
    check_pgdir();
    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE~KERNBASE+KMEMSIZE = phy_addr 0~KMEMSIZE
    // But shouldn't use this map until enable_paging() & gdt_init() finished.
    // boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, PADDR(KERNBASE),
    //                READ_WRITE_EXEC);

    // temporary map:
    // virtual_addr 3G~3G+4M = linear_addr 0~4M = linear_addr 3G~3G+4M =
    // phy_addr 0~4M
    // boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)];

    //    enable_paging();

    // now the basic virtual memory map(see memalyout.h) is established.
    // check the correctness of the basic virtual memory map.
    check_boot_pgdir();
}

// get_pte - 获取PTE并返回此PTE的内核虚拟地址，用于映射la
//        - 如果PT中不存在此PTE，则为PT分配一个Page
// 参数：
//  pgdir：PDT的内核虚拟基地址
//  la：需要映射的线性地址
//  create：一个逻辑值，用于决定是否为PT分配一个Page
// 返回值：此PTE的内核虚拟地址
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) // 根据虚拟地址找到最下一层页表的页表项（返回个指针）
{
    // pgdir是页目录表的虚拟地址（数组首地址）
    // la是线性地址
    // create是一个逻辑值，决定是否为页表分配一个页
    /*
     *
     * If you need to visit a physical address, please use KADDR()
     * please read pmm.h for useful macros
     *
     * Maybe you want help comment, BELOW comments can help you finish the code
     *
     * Some Useful MACROs and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   PDX(la) = the index of page directory entry of VIRTUAL ADDRESS la.
     *   PDX(la) = 虚拟地址la的页目录项索引。
     *   KADDR(pa) : takes a physical address and returns the corresponding
     * kernel virtual address.
     *   set_page_ref(page,1) : means the page be referenced by one time
     *   page2pa(page): get the physical address of memory which this (struct
     * Page *) page  manages
     *   struct Page * alloc_page() : allocation a page
     *   memset(void *s, char c, size_t n) : sets the first n bytes of the
     * memory area pointed by s
     *                                       to the specified value c.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry
     * flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)]; // 找到线性地址la对应的页目录项的地址，用pdep1指针存着
    //找到对应的Giga Page
    // 先解析线性地址（虚拟地址各个位）找到页目录表中的索引
    // &pgdir[PDX1(la)] 表示页目录表中索引为 PDX1(la) 的条目的地址

    if (!(*pdep1 & PTE_V)) // 如果该条目不存在（PTE_Valid信号为1 如果下一级页表不存在，那就给它分配一页，创造新页表
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) // 函数create参数为0表示不创建新的页目录项，或者不能再分配新的页
        {
            return NULL;
        }
        set_page_ref(page, 1);                              // 设置页面引用次数为1
        uintptr_t pa = page2pa(page);                       // 获取页面的物理地址
        memset(KADDR(pa), 0, PGSIZE);                       // 将页面清零
        //我们现在在虚拟地址空间中，所以要转化为KADDR再memset.
        //不管页表怎么构造，我们确保物理地址和虚拟地址的偏移量始终相同，那么就可以用这种方式完成对物理内存的访问
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V); // 设置页目录项为新的页的物理地址//注意这里R,W,X全零
    }
    // 接下来处理下一级页表项
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
    // PDE_ADDR用来获取页表项pdep1中的物理地址部分（*是取内容符号）
    // KADDR用来将物理地址转换为虚拟地址
    // PDX0用来获取中间页表的索引【页表项里从高到低三级页表的页码分别称作PDX1, PDX0和PTX(Page Table Index)】

    // pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) // 如果该条目不存在（PTE_Valid信号为0），*是取内容符号
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) // 函数create参数为0表示不创建新的页目录项，或者不能再分配新的页
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
        //   	memset(pa, 0, PGSIZE);
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    //找到输入的虚拟地址la对应的页表项的地址(可能是刚刚分配的)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
    // 和上面一样，不过对虚拟地址la用的宏是PTX，找最低一级页表的索引
}

// get_page - get related Page struct for linear address la using PDT pgdir
// 根据线性地址 la 和页目录表 pgdir 获取相应的 Page 结构体
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
    pte_t *ptep = get_pte(pgdir, la, 0);
    if (ptep_store != NULL)
    {
        *ptep_store = ptep;
    }
    if (ptep != NULL && *ptep & PTE_V)
    {
        return pte2page(*ptep);
    }
    return NULL;
}

//删除一个页表项以及它的映射，删除虚拟地址 la 对应的页表项，并释放相应的物理页面。
// page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
// note: PT is changed, so the TLB need to be invalidate
static inline void page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep)
{
    /*
     *
     * Please check if ptep is valid, and tlb must be manually updated if
     * mapping is updated
     *
     * Maybe you want help comment, BELOW comments can help you finish the code
     *
     * Some Useful MACROs and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   struct Page *page pte2page(*ptep): get the according page from the
     * value of a ptep
     *   free_page : free a page
     *   page_ref_dec(page) : decrease page->ref. NOTICE: ff page->ref == 0 ,
     * then this page should be free.
     *   tlb_invalidate(pde_t *pgdir, uintptr_t la) : Invalidate a TLB entry,
     * but only if the page tables being
     *                        edited are the ones currently in use by the
     * processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry
     * flags bit : Present
     */
    if (*ptep & PTE_V) //函数首先检查页表项是否有效，如果无效则直接返回。
    { //(1) check if this page table entry is
        struct Page *page =
            pte2page(*ptep); //(2) find corresponding page to pte 函数使用 pte2page 函数将页表项转换为对应的物理页面
        page_ref_dec(page);  //(3) decrease page reference 用 page_ref_dec 函数将物理页面的引用计数减1。
        if (page_ref(page) ==
            0)
        { //(4) and free this page when page reference reachs 0
            free_page(page);//如果引用计数为0，则调用 free_page 函数释放物理页面。
        }
        *ptep = 0;                 //(5) clear second page table entry 将页表项清零
        tlb_invalidate(pgdir, la); //(6) flush tlb
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la)
{
    //pgdir是页表基址(satp)。la是虚拟地址
    pte_t *ptep = get_pte(pgdir, la, 0);//找到页表项所在位置
    if (ptep != NULL)
    {
        page_remove_pte(pgdir, la, ptep);//删除这个页表项的映射
    }
}

// page_insert - 建立一个Page的物理地址和线性地址la之间的映射
// 参数：
//  pgdir：PDT的内核虚拟基地址
//  page：需要映射的Page
//  la：需要映射的线性地址
//  perm：在相关的pte中设置的此Page的权限
// 返回值：始终为0
// 注意：PT已更改，因此需要使TLB失效
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm)
{
    //pgdir是页表基址(satp)，page对应物理页面，la是虚拟地址，权限 perm
    pte_t *ptep = get_pte(pgdir, la, 1); ////先找到对应页表项的位置，如果原先不存在，get_pte()会分配页表项的内存
    if (ptep == NULL)
    {
        return -E_NO_MEM;
    }
    page_ref_inc(page); //指向这个物理页面的虚拟地址增加了一个
    if (*ptep & PTE_V) //原先存在映射
    {
        struct Page *p = pte2page(*ptep);
        if (p == page)//如果这个映射原先就有
        {
            page_ref_dec(page);
        }
        else //如果原先这个虚拟地址映射到其他物理页面，那么需要删除映射
        {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm); //构造页表项
    tlb_invalidate(pgdir, la);//页表改变之后要刷新TLB
    return 0;
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }

// pgdir_alloc_page - call alloc_page & page_insert functions to
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm)
{
    struct Page *page = alloc_page();
    if (page != NULL)
    {
        if (page_insert(pgdir, page, la, perm) != 0)
        {
            free_page(page);
            return NULL;
        }
        if (swap_init_ok)
        {
            swap_map_swappable(check_mm_struct, la, page, 0);
            page->pra_vaddr = la;
            assert(page_ref(page) == 1);
            // cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x,
            // pra_link_next %x in pgdir_alloc_page\n", (page-pages),
            // page->pra_vaddr,page->pra_page_link.prev,
            // page->pra_page_link.next);
        }
    }

    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
    cprintf("check_alloc_page() succeeded!\n");
}

/**
 * 验证页目录和页表的正确性
 * 验证了页表管理的各种基本功能，包括页面分配、插入、移除以及引用计数等。
*/
static void check_pgdir(void)
{
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    //这部分的断言用于进行一些基本验证：确保总的页数不超过内核顶部地址除以每页的大小。确保 boot_pgdir（引导页目录）非空且是页对齐的。确保虚拟地址 0x0 没有映射到任何页面。
    assert(npage <= KERNTOP / PGSIZE); //确保内核不会超出其可用的虚拟地址空间。
    //boot_pgdir是页表的虚拟地址
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
    //get_page()尝试找到虚拟内存0x0对应的页，现在当然是没有的，返回NULL
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);

    //分配了一个新的页面p1，将此页面插入到虚拟地址0x0
    struct Page *p1, *p2;
    p1 = alloc_page();//拿过来一个物理页面
    //page_insert 函数使用多级页表来实现虚拟地址到物理地址的映射。这个函数返回0表示映射成功。
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0); //把这个物理页面通过多级页表映射到0x0

    //检查插入操作的正确性，验证获取虚拟地址 0x0 的页表项。确保页表项指向正确的页面。页面的引用计数是否正确（应为1）
    pte_t *ptep;
    //get_pte查找某个虚拟地址对应的页表项，如果不存在这个页表项，会为它分配各级的页表
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
    assert(pte2page(*ptep) == p1); //pte2page 函数将页表项转换为对应的物理页面，并将其与 p1 进行比较。如果它们相等，assert 宏将不会发生错误。
    assert(page_ref(p1) == 1);

    //用于测试 get_pte 函数是否能够正确地获取虚拟地址对应的页表项。
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);

    //分配和插入另一个页面，函数分配了另一个页面 p2，并将其插入到虚拟地址 PGSIZE，这个页面是用户可访问的，并且可写。
    p2 = alloc_page();
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
    //再次进行一系列的验证，检查新插入的页表项的权限和引用计数。
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
    assert(*ptep & PTE_U);
    assert(*ptep & PTE_W);
    assert(boot_pgdir[0] & PTE_U);
    assert(page_ref(p2) == 1);

    //将之前分配的页面 p1 再次插入到新的虚拟地址 PGSIZE。同时验证了页面 p1 的引用计数是否正确增加，同时页面 p2 的引用计数是否已经减少。
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
    assert(page_ref(p1) == 2);
    assert(page_ref(p2) == 0);

    //检查页表项的权限和对应的物理页面是否正确。
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
    assert((*ptep & PTE_U) == 0);

    //移除了之前插入的两个页面，并验证了这两个页面的引用计数是否已经正确更新。
    page_remove(boot_pgdir, 0x0);
    assert(page_ref(p1) == 1);
    assert(page_ref(p2) == 0);

    page_remove(boot_pgdir, PGSIZE);
    assert(page_ref(p1) == 0);
    assert(page_ref(p2) == 0);

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);

    pde_t *pd1 = boot_pgdir, *pd0 = page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;

    //使用 assert 宏检查空闲页面的数量是否正确，并输出测试结果。
    assert(nr_free_store == nr_free_pages());

    cprintf("check_pgdir() succeeded!\n");
}

static void check_boot_pgdir(void)
{
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
    {
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(boot_pgdir[0] == 0);

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
    assert(page_ref(p) == 1);
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
    assert(page_ref(p) == 2);

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);

    *(char *)(page2kva(p) + 0x100) = '\0';
    assert(strlen((const char *)0x100) == 0);

    pde_t *pd1 = boot_pgdir, *pd0 = page2kva(pde2page(boot_pgdir[0]));
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;

    assert(nr_free_store == nr_free_pages());

    cprintf("check_boot_pgdir() succeeded!\n");
}

void *kmalloc(size_t n)//分配至少n个连续的字节，这里实现得不精细，占用的只能是整数个页。
{
    /**
     * kmalloc:类似于用户空间中的malloc函数，但是它是在内核空间中进行内存分配，因此用于内核代码中
     * 它会在内存池中查找一个足够大的空闲内存块，将其标记为已使用，并返回其首地址
     * 如果内存池中没有足够大的空闲内存块，则会进行内存压缩或者内存回收操作，以获得足够的连续内存空间。
     */
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124); //124M内存
    int num_pages = (n + PGSIZE - 1) / PGSIZE; //向上取整到整数个页
    base = alloc_pages(num_pages);
    assert(base != NULL); //如果分配失败就直接panic
    ptr = page2kva(base);//分配的内存的起始位置（虚拟地址），
    //page2kva, 就是page_to_kernel_virtual_address
    return ptr;
}

void kfree(void *ptr, size_t n) //从某个位置开始释放n个字节
{
    assert(n > 0 && n < 1024 * 0124);
    assert(ptr != NULL);
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
    /*计算num_pages和kmalloc里一样，
    但是如果程序员写错了呢？调用kfree的时候传入的n和调用kmalloc传入的n不一样？
    就像你平时在windows/linux写C语言一样，会出各种奇奇怪怪的bug。
    */
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
