#ifndef __KERN_MM_SWAP_H__
#define __KERN_MM_SWAP_H__

#include <defs.h>
#include <memlayout.h>
#include <pmm.h>
#include <vmm.h>

/* *
 * swap_entry_t
 * --------------------------------------------
 * |         offset        |   reserved   | 0 |
 * --------------------------------------------
 *           24 bits            7 bits    1 bit
 * */

#define MAX_SWAP_OFFSET_LIMIT (1 << 24)

extern size_t max_swap_offset;

/* *
 * swap_offset - takes a swap_entry (saved in pte), and returns
 * the corresponding offset in swap mem_map.
 * */
// 交换条目右移8位，得到的结果即为偏移量
// 交换条目（swap_entry）是一个32位的整数，其中高24位表示交换分区中的偏移量，低8位表示交换标志（swap flag）
#define swap_offset(entry) ({                             \
     size_t __offset = (entry >> 8);                      \
     if (!(__offset > 0 && __offset < max_swap_offset))   \
     {                                                    \
          panic("invalid swap_entry_t = %08x.\n", entry); \
     }                                                    \
     __offset;                                            \
})

struct swap_manager
{
     const char *name; //交换空间管理器的名称，为一个指向字符常量的指针。
     /* Global initialization for the swap manager */
     int (*init)            (void); //交换空间管理器的全局初始化函数，返回一个整数值。
     /* Initialize the priv data inside mm_struct */
     int (*init_mm)         (struct mm_struct *mm); //初始化进程的交换空间管理器私有数据的函数，返回一个整数值。
     /* Called when tick interrupt occured */
     int (*tick_event)      (struct mm_struct *mm); //时钟中断处理函数，返回一个整数值。
     /* Called when map a swappable page into the mm_struct */
     //将一个可交换的页面映射到进程的地址空间的函数，返回一个整数值。
     int (*map_swappable)   (struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in);
     /* When a page is marked as shared, this routine is called to
      * delete the addr entry from the swap manager */
     //将一个页面标记为不可交换的函数，返回一个整数值。
     int (*set_unswappable) (struct mm_struct *mm, uintptr_t addr);
     /* Try to swap out a page, return then victim */
     //选择一个页面进行交换的函数，返回一个整数值。
     int (*swap_out_victim) (struct mm_struct *mm, struct Page **ptr_page, int in_tick);
     /* check the page relpacement algorithm */
     int (*check_swap)(void); //检查页面置换算法的函数，返回一个整数值。
};

extern volatile int swap_init_ok;
int swap_init(void);
int swap_init_mm(struct mm_struct *mm);
int swap_tick_event(struct mm_struct *mm);
int swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in);
int swap_set_unswappable(struct mm_struct *mm, uintptr_t addr);
int swap_out(struct mm_struct *mm, int n, int in_tick);
int swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result);

// #define MEMBER_OFFSET(m,t) ((int)(&((t *)0)->m))
// #define FROM_MEMBER(m,t,a) ((t *)((char *)(a) - MEMBER_OFFSET(m,t)))

#endif
