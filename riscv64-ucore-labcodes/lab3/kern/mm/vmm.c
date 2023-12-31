#include <vmm.h>
#include <sync.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>
#include <error.h>
#include <pmm.h>
#include <riscv.h>
#include <swap.h>

/*
  vmm design include two parts: mm_struct (mm) & vma_struct (vma)
  mm is the memory manager for the set of continuous virtual memory
  area which have the same PDT. vma is a continuous virtual memory area.
  There a linear link list for vma & a redblack link list for vma in mm.
---------------
  mm related functions:
   golbal functions
     struct mm_struct * mm_create(void)
     void mm_destroy(struct mm_struct *mm)
     int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr)
--------------
  vma related functions:
   global functions
     struct vma_struct * vma_create (uintptr_t vm_start, uintptr_t vm_end,...)
     void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
     struct vma_struct * find_vma(struct mm_struct *mm, uintptr_t addr)
   local functions
     inline void check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
---------------
   check correctness functions
     void check_vmm(void);
     void check_vma_struct(void);
     void check_pgfault(void);
*/

// szx func : print_vma and print_mm
void print_vma(char *name, struct vma_struct *vma)
{
    cprintf("-- %s print_vma --\n", name);
    cprintf("   mm_struct: %p\n", vma->vm_mm);
    cprintf("   vm_start,vm_end: %x,%x\n", vma->vm_start, vma->vm_end);
    cprintf("   vm_flags: %x\n", vma->vm_flags);
    cprintf("   list_entry_t: %p\n", &vma->list_link);
}

void print_mm(char *name, struct mm_struct *mm)
{
    cprintf("-- %s print_mm --\n", name);
    cprintf("   mmap_list: %p\n", &mm->mmap_list);
    cprintf("   map_count: %d\n", mm->map_count);
    list_entry_t *list = &mm->mmap_list;
    for (int i = 0; i < mm->map_count; i++)
    {
        list = list_next(list);
        print_vma(name, le2vma(list, list_link));
    }
}

static void check_vmm(void);
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
// 创建一个mm_struct并初始化(创建时调用了kmalloc，一次create会创建一个新的，故删除前需要释放)
struct mm_struct *
mm_create(void)
{
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
    /**
     * kmalloc:类似于用户空间中的malloc函数，但是它是在内核空间中进行内存分配，因此用于内核代码中
     * 它会在内存池中查找一个足够大的空闲内存块，将其标记为已使用，并返回其首地址
     * 如果内存池中没有足够大的空闲内存块，则会进行内存压缩或者内存回收操作，以获得足够的连续内存空间。
     */

    if (mm != NULL)
    {
        list_init(&(mm->mmap_list)); //初始化 mm_struct 结构体中的 mmap_list。mmap_list 通常用于维护进程的内存映射列表。
        mm->mmap_cache = NULL; // 当前没有正在使用的虚拟内存空间；
        mm->pgdir = NULL;      // 表示当前没有使用的页目录表；
        mm->map_count = 0;     // 表示当前没有虚拟内存空间；

        if (swap_init_ok) //我们接下来解释页面置换的初始化
            swap_init_mm(mm); //初始化与交换空间（swap space）相关的数据结构
        else
            mm->sm_priv = NULL; // sm_priv 设置为 NULL。sm_priv 通常用于存储与特定交换空间实现相关的私有数据。
    }
    return mm;
}

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
// vma的创建并初始化，根据参数vm_start、vm_end、vm_flags完成初始化
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags)
{
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));

    if (vma != NULL)
    {
        vma->vm_start = vm_start;
        vma->vm_end = vm_end;
        vma->vm_flags = vm_flags;
    }
    return vma;
}

// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
// 根据mm以及addr找到vma ,查找这个地址对应的vma_struct结构体满足(vma->vm_start <= addr <= vma_vm_end)体
//find_vma 函数在给定进程的虚拟内存管理结构体中找到包含指定地址的虚拟内存区域，并返回包含其详细信息的 vma_struct。
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr)
{
    struct vma_struct *vma = NULL;
    if (mm != NULL)
    {
        //首先尝试从 mm->mmap_cache 中获取VMA。mmap_cache 存储了最近使用的VMA，以加快访问速度。
        vma = mm->mmap_cache; // 先查cache，当前正在使用的虚拟内存空间
        //检查找到的VMA是否包含传入的地址。如果 vma 不为 NULL 且地址在 vma->vm_start 和 vma->vm_end 之间，那么这个VMA就是我们要找的。
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
        // 传入的地址不在cache中，遍历整个 mm->mmap_list 链表，查找对应的vma（包含传入地址的 vma_struct 结构体）；
        {
            //如果没有在 mmap_cache 中找到VMA，则在 mm->mmap_list 链表中查找。定义了一个布尔变量 found 来标记是否找到了合适的VMA。
            bool found = 0;
            list_entry_t *list = &(mm->mmap_list), *le = list;
            // list标识vma链表的头部，le标识当前遍历到的vma
            while ((le = list_next(le)) != list)
            {
                //遍历 mm->mmap_list 链表。le2vma 是一个宏或函数，用于从链表条目获取对应的VMA。
                vma = le2vma(le, list_link);
                if (vma->vm_start <= addr && addr < vma->vm_end)
                {
                    //检查每个VMA是否包含传入的地址。如果找到，则设置 found 为 1 并退出循环。
                    found = 1;
                    break;
                }
            }
            //如果没有找到包含指定地址的VMA，则将 vma 设置为 NULL。
            if (!found)
            {
                vma = NULL;
            }
        }
        //如果找到了VMA，则更新 mm->mmap_cache 以加快后续的VMA查找。
        if (vma != NULL)
        {
            mm->mmap_cache = vma; // 更新cache
        }
    }
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?本质是检查vma1和vma2 start<end而且vma1.end<=vma2.start
//在插入一个新的vma_struct之前，我们要保证它和原有的区间都不重合
static inline void // 检测两个vma是否重叠
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end); //next 是我们想插入的区间，这里顺便检验了start < end
}

// insert_vma_struct -insert vma in mm's list link
// 向mm的mmap_list的插入一个vma，按地址插入合适位置
// 我们可以插入一个新的vma_struct, 将一个 vma_struct 结构体插入到 mm_struct 结构体中。
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end); //函数首先检查 vma 是否为空，如果为空则直接返回。
    list_entry_t *list = &(mm->mmap_list); // list标识vma链表头
    list_entry_t *le_prev = list, *le_next; // le_prev 和 le_next 分别表示该 vma 的前一个和后一个 vma，

    list_entry_t *le = list; // le用来遍历整个链表
    //使用 list_entry 宏遍历 mm 中的所有 vma，并找到第一个比 vma 的 vm_start 大的 vma。
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start) // 找到第一个比vma的vm_start大的vma
        {
            break;
        }
        le_prev = le;
        //保证插入后所有vma_struct按照区间左端点有序排列
    }

    le_next = list_next(le_prev);

    /* check overlap */
    //检查新插入的 vma_struct 结构体与相邻的 vma_struct 结构体是否重叠。
    if (le_prev != list)
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma); // 检查vma与前一个vma是否重叠
    }
    if (le_next != list)
    {
        check_vma_overlap(vma, le2vma(le_next, list_link));
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
    /**
     * 该函数假设 mm 中的 vma 已经按照起始地址排序，因此可以使用线性查找算法。
     * 该函数在实现虚拟内存管理时非常有用，可以方便地将 vma_struct 结构体插入到对应的 mm_struct 结构体中，从而管理进程的虚拟地址空间。
    */
}

// mm_destroy - free mm and mm internal fields
// 删除一个mm struct，kfree掉占用的空间
void mm_destroy(struct mm_struct *mm)
{

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
    {
        list_del(le);
        kfree(le2vma(le, list_link), sizeof(struct vma_struct)); // kfree vma
    }
    kfree(mm, sizeof(struct mm_struct)); // kfree mm
    mm = NULL;
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
    check_vmm();
}

// check_vmm - check correctness of vmm
static void
check_vmm(void)
{
    size_t nr_free_pages_store = nr_free_pages();
    check_vma_struct(); // 检查vma_struct结构体,检查vma_create、insert_vma_struct、find_vma函数
    check_pgfault();    // 检查页错误处理函数，

    nr_free_pages_store--; // szx : Sv39三级页表多占一个内存页，所以执行此操作
    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void)
{
    size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i++)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
    {
        assert(le != &(mm->mmap_list));
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
    {
        struct vma_struct *vma1 = find_vma(mm, i);
        assert(vma1 != NULL);
        struct vma_struct *vma2 = find_vma(mm, i + 1);
        assert(vma2 != NULL);
        struct vma_struct *vma3 = find_vma(mm, i + 2);
        assert(vma3 == NULL);
        struct vma_struct *vma4 = find_vma(mm, i + 3);
        assert(vma4 == NULL);
        struct vma_struct *vma5 = find_vma(mm, i + 4);
        assert(vma5 == NULL);

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
    }

    for (i = 4; i >= 0; i--)
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
        if (vma_below_5 != NULL)
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vma_struct() succeeded!\n");
}

struct mm_struct *check_mm_struct; // 用于check_pgfault函数

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void)
{
    // char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages(); // 备份当前系统的空闲页面数量

    check_mm_struct = mm_create(); // 创建一个新的内存管理结构mm。用来管理一系列的连续虚拟内存区域。

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir; // pgdir被设置为boot_pgdir，boot_pgdir在pmm.c中设置成boot_page_table_sv39
    assert(pgdir[0] == 0);

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE); // 创建一个新的虚拟内存区域（VMA）
    // 该VMA的起始地址为0，结束地址为PTSIZE（页目录项辐射的内存地址4096*512），权限为可写。

    assert(vma != NULL);

    insert_vma_struct(mm, vma); // 将新创建的虚拟内存区域插入到mm管理的VMA列表中

    // 在新创建的VMA范围内进行内存访问和修改
    /**
     * 定义了一个虚拟地址 addr，并使用 find_vma 函数查找包含该地址的 vma_struct 结构体。
     * 由于该地址在新创建的 vma_struct 范围内，因此 find_vma 函数应该返回该 vma_struct 结构体
    */
    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i++)
    {
        *(char *)(addr + i) = i; //每个地址对应的值设置为该地址的偏移量，并计算所有值的和
        sum += i;
    }
    for (i = 0; i < 100; i++)
    {
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);

    // 使用page_remove和free_page来释放前面访问和修改时分配的页面

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));

    free_page(pde2page(pgdir[0]));

    pgdir[0] = 0;

    // 清除mm的pgdir指针，并使用mm_destroy销毁mm结构。
    mm->pgdir = NULL;
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--; // szx : Sv39第二级页表多占了一个内存页，所以执行此操作

    // 比较当前系统的空闲页面数量与函数开始时的数量，以确保没有内存泄漏。
    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_pgfault() succeeded!\n");
}
// page fault number
volatile unsigned int pgfault_num = 0;

/* do_pgfault - interrupt handler to process the page fault execption
 * @mm         : the control struct for a set of vma using the same PDT
 * @error_code : the error code recorded in trapframe->tf_err which is setted by x86 hardware
 * @addr       : the addr which causes a memory access exception, (the contents of the CR2 register)
 *
 * CALL GRAPH: trap--> trap_dispatch-->pgfault_handler-->do_pgfault
 * The processor provides ucore's do_pgfault function with two items of information to aid in diagnosing
 * the exception and recovering from it.
 *   (1) The contents of the CR2 register. The processor loads the CR2 register with the
 *       32-bit linear address that generated the exception. The do_pgfault fun can
 *       use this address to locate the corresponding page directory and page-table
 *       entries.
 *   (2) An error code on the kernel stack. The error code for a page fault has a format different from
 *       that for other exceptions. The error code tells the exception handler three things:
 *         -- The P flag   (bit 0) indicates whether the exception was due to a not-present page (0)
 *            or to either an access rights violation or the use of a reserved bit (1).
 *         -- The W/R flag (bit 1) indicates whether the memory access that caused the exception
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr)
{
    //该函数的参数是一个指向 mm_struct 结构体的指针 mm、一个错误码 error_code 和一个地址 addr，分别表示当前进程的内存管理结构、页故障的错误码和引起页故障的地址。
    // mm mm_struct的结构体
    // error_code 错误码
    // addr 产生异常的地址
    int ret = -E_INVAL; // 返回值初始化为-E_INVAL，为无效值
    // try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr); // 找到地址对应的vma_struct结构体
    //我们首先要做的就是在mm_struct里判断这个虚拟地址是否可用
    pgfault_num++;
    // If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr)
    {
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }

    /* IF (write an existed addr ) OR
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U; // 定义页权限并初始化为用户模式。

    //检查 vma 是否可写，并根据检查结果设置页表项的权限标志。
    if (vma->vm_flags & VM_WRITE) // 检查vma是否可写
    {
        perm |= (PTE_R | PTE_W); //如果包含则表示 vma 可写。然后，代码将 PTE_R 和 PTE_W 标志分别按位或到 perm 变量中，表示页表项可读可写。
    }
    //按照页面大小把地址对齐
    addr = ROUNDDOWN(addr, PGSIZE); // 将addr向下对齐到页面大小的整数倍，找到发生缺页的addr所在的页面的首地址

    ret = -E_NO_MEM; // 表示没有可用内存

    pte_t *ptep = NULL; // 新建一个页表条目的指针
    /*
     * Maybe you want help comment, BELOW comments can help you finish the code
     *
     * Some Useful MACROs and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   get_pte : get an pte and return the kernel virtual address of this pte for la
     *             if the PT contians this pte didn't exist, alloc a page for PT (notice the 3th parameter '1')
     *   pgdir_alloc_page : call alloc_page & page_insert functions to allocate a page size memory & setup
     *             an addr map pa<--->la with linear address la and the PDT pgdir
     * DEFINES:
     *   VM_WRITE  : If vma->vm_flags & VM_WRITE == 1/0, then the vma is writable/non writable
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     * VARIABLES:
     *   mm->pgdir : the PDT of these vma
     *
     */

    ptep = get_pte(mm->pgdir, addr, 1);
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // 传入参数为mm->pgdir，addr，1————页目录表的虚拟地址，线性地址，是否创建标志位

    if (*ptep == 0) // 检查页表条目是否为空，即该虚拟地址是否已经映射到物理页面
    {
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) // 如果该地址未映射，则尝试为它分配一个新页面并设置适当的权限
        {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    }
    else
    {
        /*LAB3 EXERCISE 3: YOUR CODE
         * 请你根据以下信息提示，补充函数
         * 现在我们认为pte是一个交换条目，那我们应该从磁盘加载数据并放到带有phy addr的页面，
         * 并将phy addr与逻辑addr映射，触发交换管理器记录该页面的访问情况
         *
         *  一些有用的宏和定义，可能会对你接下来代码的编写产生帮助(显然是有帮助的)
         *  宏或函数:
         *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
         *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
         *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
         *    swap_map_swappable ： 设置页面可交换
         */
        if (swap_init_ok)
        {
            struct Page *page = NULL;
            /**
             * struct Page *page = NULL;
            //在swap_in()函数执行完之后，page保存换入的物理页面。
            //swap_in()函数里面可能把内存里原有的页面换出去
            swap_in(mm, addr, &page);  //(1）According to the mm AND addr, try
                                       //to load the content of right disk page
                                       //into the memory which page managed.
            page_insert(mm->pgdir, page, addr, perm); //更新页表，插入新的页表项
            //(2) According to the mm, addr AND page, 
            // setup the map of phy addr <---> virtual addr
            swap_map_swappable(mm, addr, page, 1);  //(3) make the page swappable.
            //标记这个页面将来是可以再换出的
            page->pra_vaddr = addr;
            */
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            // to load the content of right disk page
            // into the memory which page managed.
            //(2) According to the mm,
            // addr AND page, setup the
            // map of phy addr <--->
            // logical addr
            //(3) make the page swappable.

            // (1) 尝试加载正确的磁盘页面的内容到内存中的页面
            int result = swap_in(mm, addr, &page); // ***在这里进swap_in函数
            if (result != 0)
            {
                cprintf("swap_in failed\n");
                goto failed;
            }

            // (2) 设置物理地址和逻辑地址的映射
            if (page_insert(mm->pgdir, page, addr, perm) != 0)
            {
                cprintf("page_insert failed\n");
                goto failed;
            }

            // (3) 设置页面为可交换的
            if (swap_map_swappable(mm, addr, page, 1) != 0)
            {
                cprintf("swap_map_swappable failed\n");
                goto failed;
            }
            page->pra_vaddr = addr; //标记这个页面将来是可以再换出的
        }
        else
        {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
    }

    ret = 0;
failed:
    return ret;
}
