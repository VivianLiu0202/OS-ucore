#ifndef __KERN_MM_MMU_H__
#define __KERN_MM_MMU_H__

#ifndef __ASSEMBLER__
#include <defs.h>
#endif /* !__ASSEMBLER__ */

// A linear address 'la' has a four-part structure as follows:
// 虚拟地址的位含义：
// 页表项里从高到低三级页表的页码分别称作PDX1, PDX0和PTX(Page Table Index)
// +--------9-------+-------9--------+-------9--------+---------12----------+
// | Page Directory | Page Directory |   Page Table   | Offset within Page  |
// |     Index 1    |    Index 2     |                |                     |
// +----------------+----------------+----------------+---------------------+
//  \-- PDX1(la) --/ \-- PDX0(la) --/ \--- PTX(la) --/ \---- PGOFF(la) ----/
//  \-------------------PPN(la)----------------------/
//
// The PDX1, PDX0, PTX, PGOFF, and PPN macros decompose linear addresses as shown.
// To construct a linear address la from PDX(la), PTX(la), and PGOFF(la),
// use PGADDR(PDX(la), PTX(la), PGOFF(la)).

// RISC-V uses 39-bit virtual address to access 56-bit physical address!
// Sv39 virtual address:
// +----9----+----9---+----9---+---12--+
// |  VPN[2] | VPN[1] | VPN[0] | PGOFF |
// +---------+----+---+--------+-------+
//
// Sv39 physical address:物理地址的位含义
// +----26---+----9---+----9---+---12--+
// |  PPN[2] | PPN[1] | PPN[0] | PGOFF |
// +---------+----+---+--------+-------+
//
// Sv39 page table entry:页表项的位含义
// +----26---+----9---+----9---+---2----+-------8-------+
// |  PPN[2] | PPN[1] | PPN[0] |Reserved|D|A|G|U|X|W|R|V|
// +---------+----+---+--------+--------+---------------+

// page directory index
// 虚拟地址39位从高到低PDX1、PDX0、PTX
#define PDX1(la) ((((uintptr_t)(la)) >> PDX1SHIFT) & 0x1FF) // 虚拟地址右移30位并取低9位
#define PDX0(la) ((((uintptr_t)(la)) >> PDX0SHIFT) & 0x1FF) // 虚拟地址右移21位并取低9位

// page table index 这个宏用于获取线性地址的页表索引。
#define PTX(la) ((((uintptr_t)(la)) >> PTXSHIFT) & 0x1FF) // 虚拟地址右移12位并取低9位

// page number field of address
// 一个虚拟地址的高27位是页号，低12位是页内偏移
// 取高27位即可得到页号，是整体的页号，可以通过27位页号分成3部分，一部分9位的页号去查三级页表
#define PPN(la) (((uintptr_t)(la)) >> PTXSHIFT) // 虚拟地址右移12位，取所有位

// offset in page 提取页内偏移量。
#define PGOFF(la) (((uintptr_t)(la)) & 0xFFF) //0xFFF表示低12位

// construct linear address from indexes and offset
//从给定的页目录项索引、页表项索引和页内偏移量构造线性地址
//它将这些参数左移相应的位数，并将它们相加以构造线性地址。
#define PGADDR(d1, d0, t, o) ((uintptr_t)((d1) << PDX1SHIFT | (d0) << PDX0SHIFT | (t) << PTXSHIFT | (o)))

// address in page table or page directory entry
// 根据页表项或页目录项的地址找到页表或页目录项的地址
// 先将其最后 10 位清零，再左移 2 位（物理页号转换为物理地址），即可得到页表或页目录项的地址
// 物理页号与实际物理地址之间的差异在于低12位。其中，最低10位是页内偏移，再高的2位是页表项标志。左移2位后，最低10位变成页内偏移，而页表项的标志被推出，从而得到实际的物理地址。
#define PTE_ADDR(pte) (((uintptr_t)(pte) & ~0x3FF) << (PTXSHIFT - PTE_PPN_SHIFT))
#define PDE_ADDR(pde) PTE_ADDR(pde)  //从给定的页目录项中提取页表物理地址。

/* page directory and page table constants */
#define NPDEENTRY       512                    // page directory entries per page directory //512个页目录项
#define NPTEENTRY       512                    // page table entries per page table //512个页表项

#define PGSIZE          4096                    // bytes mapped by a page 一个页面的大小
#define PGSHIFT         12                      // log2(PGSIZE) 页面大小的对数
#define PTSIZE          (PGSIZE * NPTEENTRY)    // bytes mapped by a page directory entry 一个页目录项所映射的页表大小
#define PTSHIFT         21                      // log2(PTSIZE) 页表大小的对数

#define PTXSHIFT        12                      // offset of PTX in a linear address 页表项偏移量
#define PDX0SHIFT       21                      // offset of PDX0 in a linear address 第一级页目录项偏移量
#define PDX1SHIFT       30                      // offset of PDX0 in a linear address 第二级页目录项偏移量
#define PTE_PPN_SHIFT   10                      // offset of PPN in a physical address 物理地址中页帧号的偏移量

// page table entry (PTE) fields
#define PTE_V 0x001    // Valid
#define PTE_R 0x002    // Read
#define PTE_W 0x004    // Write
#define PTE_X 0x008    // Execute
#define PTE_U 0x010    // User
#define PTE_G 0x020    // Global
#define PTE_A 0x040    // Accessed
#define PTE_D 0x080    // Dirty
#define PTE_SOFT 0x300 // Reserved for Software

#define PAGE_TABLE_DIR (PTE_V)
#define READ_ONLY (PTE_R | PTE_V)
#define READ_WRITE (PTE_R | PTE_W | PTE_V)
#define EXEC_ONLY (PTE_X | PTE_V)
#define READ_EXEC (PTE_R | PTE_X | PTE_V)
#define READ_WRITE_EXEC (PTE_R | PTE_W | PTE_X | PTE_V)

#define PTE_USER (PTE_R | PTE_W | PTE_X | PTE_U | PTE_V)

#endif /* !__KERN_MM_MMU_H__ */
