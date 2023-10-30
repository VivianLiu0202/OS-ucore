#include <swap.h>
#include <swapfs.h>
#include <swap_fifo.h>
#include <swap_clock.h>
#include <stdio.h>
#include <string.h>
#include <memlayout.h>
#include <pmm.h>
#include <mmu.h>

// the valid vaddr for check is between 0~CHECK_VALID_VADDR-1
#define CHECK_VALID_VIR_PAGE_NUM 5
#define BEING_CHECK_VALID_VADDR 0X1000
#define CHECK_VALID_VADDR (CHECK_VALID_VIR_PAGE_NUM + 1) * 0x1000
// the max number of valid physical page for check
#define CHECK_VALID_PHY_PAGE_NUM 4
// the max access seq number
#define MAX_SEQ_NO 10

static struct swap_manager *sm;
size_t max_swap_offset;

volatile int swap_init_ok = 0;

unsigned int swap_page[CHECK_VALID_VIR_PAGE_NUM];

unsigned int swap_in_seq_no[MAX_SEQ_NO], swap_out_seq_no[MAX_SEQ_NO];

static void check_swap(void);

int swap_init(void)
{
     swapfs_init(); // 初始化磁盘交换分区

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     // 检查最大交换偏移量是否在某个范围内
     if (!(7 <= max_swap_offset &&
           max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
          // 程序运行时发生严重错误时引发紧急情况。它会导致程序立即停止执行，并输出一条错误消息
     }

     sm = &swap_manager_clock; // use clock Page Replacement Algorithm
     // sm = &swap_manager_fifo; // use first in first out Page Replacement Algorithm
     int r = sm->init();

     if (r == 0)
     {
          swap_init_ok = 1;
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}

int swap_init_mm(struct mm_struct *mm)
{
     return sm->init_mm(mm);
}

int swap_tick_event(struct mm_struct *mm)
{
     return sm->tick_event(mm);
}

int swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
     return sm->map_swappable(mm, addr, page, swap_in);
}

int swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
     return sm->set_unswappable(mm, addr);
}

volatile unsigned int swap_out_num = 0;

int swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++i)
     {
          uintptr_t v;
          // struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick); // 调用swap_out_victim，把要换出的页放到page里
          if (r != 0)
          {
               cprintf("i %d, swap_out: call swap_out_victim failed\n", i);
               break;
          }
          // assert(!PageReserved(page));

          // cprintf("SWAP: choose victim page 0x%08x\n", page);

          v = page->pra_vaddr;                    // 要换出页面的虚拟地址
          pte_t *ptep = get_pte(mm->pgdir, v, 0); // 找到页表项指针
          assert((*ptep & PTE_V) != 0);           // 判断页表项是否有效

          // 将需要换出的页面的内容写入到磁盘交换分区中。其中，(page->pra_vaddr / PGSIZE + 1) << 8 表示磁盘交换分区中的页号，page 表示需要换出的页面的指针。
          if (swapfs_write((page->pra_vaddr / PGSIZE + 1) << 8, page) != 0)
          {
               cprintf("SWAP: failed to save\n");
               sm->map_swappable(mm, v, page, 0);
               continue;
          }
          else
          {
               cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr / PGSIZE + 1);
               // i 表示需要换出的页面在进程的页面数组中的索引，v 表示需要换出的页面的线性地址，page->pra_vaddr / PGSIZE + 1 表示需要换出的页面在磁盘交换分区中的页号
               *ptep = (page->pra_vaddr / PGSIZE + 1) << 8;
               free_page(page);
          }

          tlb_invalidate(mm->pgdir, v);
     }
     return i;
}

int swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
     struct Page *result = alloc_page();
     assert(result != NULL);

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));

     int r;
     if ((r = swapfs_read((*ptep), result)) != 0) // 调用swapfs_read函数，将磁盘交换分区中的页面读取到内存中
     {
          assert(r != 0);
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep) >> 8, addr);
     *ptr_result = result;
     return 0;
}

// 初步检查页面交换函数
static inline void
check_content_set(void)
{
     *(unsigned char *)0x1000 = 0x0a; // 冷启动，miss
     assert(pgfault_num == 1);
     *(unsigned char *)0x1010 = 0x0a; // hit
     assert(pgfault_num == 1);
     *(unsigned char *)0x2000 = 0x0b; // 冷启动，miss
     assert(pgfault_num == 2);
     *(unsigned char *)0x2010 = 0x0b; // 对齐，hit
     assert(pgfault_num == 2);
     *(unsigned char *)0x3000 = 0x0c; // 冷启动，miss
     assert(pgfault_num == 3);
     *(unsigned char *)0x3010 = 0x0c; // 对齐，hit
     assert(pgfault_num == 3);
     *(unsigned char *)0x4000 = 0x0d; // 冷启动，miss
     assert(pgfault_num == 4);
     *(unsigned char *)0x4010 = 0x0d; // 对齐，hit
     assert(pgfault_num == 4);
}

static inline int
check_content_access(void)
{
     int ret = sm->check_swap();
     return ret;
}

struct Page *check_rp[CHECK_VALID_PHY_PAGE_NUM];        // 用于存放物理页面的指针
pte_t *check_ptep[CHECK_VALID_PHY_PAGE_NUM];            // 用于存放页表项指针
unsigned int check_swap_addr[CHECK_VALID_VIR_PAGE_NUM]; // 用于存放虚拟地址

extern free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void) // 检查页面交换函数
{
     // backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list)
     {
          struct Page *p = le2page(le, page_link);
          assert(PageProperty(p));
          count++, total += p->property;
     }
     assert(total == nr_free_pages());
     cprintf("BEGIN check_swap: count %d, total %d\n", count, total);

     // now we set the phy pages env
     struct mm_struct *mm = mm_create();
     assert(mm != NULL);

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);

     check_mm_struct = mm; // 附上新的mm

     pde_t *pgdir = mm->pgdir = boot_pgdir;
     assert(pgdir[0] == 0);

     // 创建一个虚拟内存区域，其起始地址为0x1000，大小为0x6000，属性为可读可写
     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
     assert(vma != NULL);

     insert_vma_struct(mm, vma); // 将虚拟内存区域插入到mm_struct结构体中

     // setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
     pte_t *temp_ptep = NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep != NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");

     // 分配4个物理页面
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
     {
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL);
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list; // 备份
     // 重新初始化空闲页面链表
     list_init(&free_list);
     assert(list_empty(&free_list));

     // assert(alloc_page() == NULL);

     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
     {
          free_pages(check_rp[i], 1);
     }
     assert(nr_free == CHECK_VALID_PHY_PAGE_NUM);

     cprintf("set up init env for check_swap begin!\n");
     // setup initial vir_page<->phy_page environment for page relpacement algorithm

     pgfault_num = 0;

     check_content_set(); // 初步检查页面交换函数
     assert(nr_free == 0);
     for (i = 0; i < MAX_SEQ_NO; i++)
          swap_out_seq_no[i] = swap_in_seq_no[i] = -1;

     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
     {
          check_ptep[i] = 0;
          check_ptep[i] = get_pte(pgdir, (i + 1) * 0x1000, 0);
          // cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
          assert(check_ptep[i] != NULL);
          assert(pte2page(*check_ptep[i]) == check_rp[i]);
          assert((*check_ptep[i] & PTE_V));
     }
     cprintf("set up init env for check_swap over!\n");
     cprintf("当前缺页次数%d\n", pgfault_num);

     // now access the virt pages to test  page relpacement algorithm
     ret = check_content_access(); // 调用不同页面置换算法的check函数检查算法
     assert(ret == 0);

     // restore kernel mem env
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
     {
          free_pages(check_rp[i], 1);
     }

     // free_page(pte2page(*temp_ptep));

     mm_destroy(mm);

     nr_free = nr_free_store;
     free_list = free_list_store;

     le = &free_list;
     while ((le = list_next(le)) != &free_list)
     {
          struct Page *p = le2page(le, page_link);
          count--, total -= p->property;
     }
     cprintf("count is %d, total is %d\n", count, total);
     // assert(count == 0);

     cprintf("check_swap() succeeded!\n");
}
