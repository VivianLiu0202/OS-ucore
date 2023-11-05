#ifndef __KERN_MM_PMM_H__
#define __KERN_MM_PMM_H__

#include <assert.h>
#include <atomic.h>
#include <defs.h>
#include <memlayout.h>
#include <mmu.h>

// pmm_manager is a physical memory management class. A special pmm manager -
// XXX_pmm_manager
// only needs to implement the methods in pmm_manager class, then
// XXX_pmm_manager can be used
// by ucore to manage the total physical memory space.
struct pmm_manager {
    const char *name;  // XXX_pmm_manager's name
    void (*init)(
        void);  // initialize internal description&management data structure
                // (free block list, number of free block) of XXX_pmm_manager
    void (*init_memmap)(
        struct Page *base,
        size_t n);  // setup description&management data structcure according to
                    // the initial free physical memory space
    struct Page *(*alloc_pages)(
        size_t n);  // allocate >=n pages, depend on the allocation algorithm
    void (*free_pages)(struct Page *base, size_t n);  // free >=n pages with
                                                      // "base" addr of Page
                                                      // descriptor
                                                      // structures(memlayout.h)
    size_t (*nr_free_pages)(void);  // return the number of free pages
    void (*check)(void);            // check the correctness of XXX_pmm_manager
};

extern const struct pmm_manager *pmm_manager;
extern pde_t *boot_pgdir;
extern const size_t nbase;
extern uintptr_t boot_cr3;

void pmm_init(void);

struct Page *alloc_pages(size_t n);
void free_pages(struct Page *base, size_t n);
size_t nr_free_pages(void);

#define alloc_page() alloc_pages(1)
#define free_page(page) free_pages(page, 1)

//用于获取虚拟地址对应的页表项，如果页表项不存在则可以选择创建它。
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create);
//get_page 函数用于获取虚拟地址对应的物理页面，并返回对应的页表项。
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store);
//page_remove 函数用于从页目录表和页表中删除虚拟地址对应的映射关系。
void page_remove(pde_t *pgdir, uintptr_t la);
//page_insert 函数用于将物理页面映射到虚拟地址，并设置相应的权限。
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm);

//tlb_invalidate 函数用于使处理器的 TLB 缓存失效，以便在虚拟地址空间发生更改时刷新缓存。
void tlb_invalidate(pde_t *pgdir, uintptr_t la);
//pgdir_alloc_page 函数用于分配一个物理页面，并将其映射到虚拟地址。
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm);


/* *
 * PADDR - takes a kernel virtual address (an address that points above
 * KERNBASE),
 * where the machine's maximum 256MB of physical memory is mapped and returns
 * the
 * corresponding physical address.  It panics if you pass it a non-kernel
 * virtual address.
 * PADDR 宏用于将一个内核虚拟地址转换为对应的物理地址。
 * 它首先检查传入的地址是否是内核虚拟地址，如果不是则会触发 panic。
 * 然后，它将虚拟地址减去 va_pa_offset 得到物理地址。
 * */
#define PADDR(kva)                                                 \
    ({                                                             \
        uintptr_t __m_kva = (uintptr_t)(kva);                      \
        if (__m_kva < KERNBASE) {                                  \
            panic("PADDR called with invalid kva %08lx", __m_kva); \
        }                                                          \
        __m_kva - va_pa_offset;                                    \
    })

/* *
 * KADDR - takes a physical address and returns the corresponding kernel virtual
 * address. It panics if you pass an invalid physical address.
 * KADDR 宏用于将一个物理地址转换为对应的内核虚拟地址。
 * 它首先检查传入的地址是否是有效的物理地址，如果不是则会触发 panic。
 * 然后，它将物理地址加上 va_pa_offset 得到内核虚拟地址。
 * */
#define KADDR(pa)                                                \
    ({                                                           \
        uintptr_t __m_pa = (pa);                                 \
        size_t __m_ppn = PPN(__m_pa);                            \
        if (__m_ppn >= npage) {                                  \
            panic("KADDR called with invalid pa %08lx", __m_pa); \
        }                                                        \
        (void *)(__m_pa + va_pa_offset);                         \
    })

extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

/**
 * page2ppn 函数用于将一个物理页面转换为对应的页帧号。
 * 。它首先将页面指针减去 pages 指针，得到页面在数组中的偏移量。然后，它将偏移量加上 nbase 得到页帧号。
*/
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }

/**
 * page2pa 函数用于将一个物理页面转换为对应的物理地址。
 * 它首先调用 page2ppn 函数将页面转换为页帧号，然后将页帧号左移 PGSHIFT 位得到物理地址。
*/
static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

/**
 * pa2page 函数用于将一个物理地址转换为对应的物理页面。
 * 它首先检查物理地址是否有效，如果无效则会触发 panic。
 * 然后，它将物理地址的页帧号减去 nbase 得到页面在数组中的偏移量，从而得到页面指针。
*/
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
}

/**
 * page2kva 函数用于将一个物理页面转换为对应的内核虚拟地址。
 * 它首先调用 page2pa 函数将页面转换为物理地址，然后调用 KADDR 宏将物理地址转换为内核虚拟地址。
*/
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }

/**
 * kva2page 函数用于将一个内核虚拟地址转换为对应的物理页面。
 * 它首先调用 PADDR 宏将虚拟地址转换为物理地址，然后调用 pa2page 函数将物理地址转换为物理页面。
*/
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }

/**
 * pte2page 函数用于将一个页表项转换为对应的物理页面。
 * 它首先检查页表项是否有效，如果无效则会触发 panic。
 * 然后，它调用 PTE_ADDR 宏将页表项转换为物理地址，再调用 pa2page 函数将物理地址转换为物理页面。
*/
static inline struct Page *pte2page(pte_t pte) {
    if (!(pte & PTE_V)) {
        panic("pte2page called with invalid pte");
    }
    return pa2page(PTE_ADDR(pte));
}

/**
 * pde2page 函数用于将一个页目录项转换为对应的物理页面。
 * 它调用 PDE_ADDR 宏将页目录项转换为物理地址，再调用 pa2page 函数将物理地址转换为物理页面。
*/
static inline struct Page *pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

//page_ref 函数用于获取页面的引用计数。
static inline int page_ref(struct Page *page) { return page->ref; }

//set_page_ref 函数用于设置页面的引用计数。
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }

static inline int page_ref_inc(struct Page *page) {
    page->ref += 1;
    return page->ref;
}

static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
/**
 * 构造一个页表项，参数 ppn 是物理页号，type 是权限类型。
 * ppn << PTE_PPN_SHIFT: 由于页表项不仅包含物理页号，还包含一些标志位和权限位，所以这里通过左移操作来为这些标志位和权限位留出空间。
 * PTE_V: 一个标志位，表示这个页表项是有效的。
 * type: 通过按位或操作，将权限类型添加到页表项中
*/
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
}

//创建一个指向页目录的页表项（页目录项）。
static inline pte_t ptd_create(uintptr_t ppn) { return pte_create(ppn, PTE_V); }

//bootstack 和 bootstacktop 代表内核的引导栈的底部和顶部
extern char bootstack[], bootstacktop[];

//是内核内存分配和释放函数的外部声明
extern void *kmalloc(size_t n);
extern void kfree(void *ptr, size_t n);

#endif /* !__KERN_MM_PMM_H__ */
