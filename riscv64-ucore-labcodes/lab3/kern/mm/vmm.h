#ifndef __KERN_MM_VMM_H__
#define __KERN_MM_VMM_H__

#include <defs.h>
#include <list.h>
#include <memlayout.h>
#include <sync.h>

// pre define
struct mm_struct;

// the virtual continuous memory area(vma), [vm_start, vm_end),
// addr belong to a vma means  vma.vm_start<= addr <vma.vm_end
// vma——virtual memory area，是一段连续的虚拟内存区域，[vm_start, vm_end)
struct vma_struct
{
    struct mm_struct *vm_mm; // the set of vma using the same PDT表示使用同一个页目录表的一组 vma。
    uintptr_t vm_start;      // start addr of vma 表示虚拟内存区域的起始地址。
    uintptr_t vm_end;        // end addr of vma, not include the vm_end itself 表示虚拟内存区域的结束地址，不包括该地址本身。
    uint_t vm_flags;         // flags of vma，标识一段虚拟地址对应的权限（可读，可写，可执行等）
    list_entry_t list_link;  // linear list link which sorted by start addr of vma 该 vma 在 mm 中的位置，用于实现线性链表。
};
/**
 * vma_struct结构体描述一段连续的虚拟地址，从vm_start到vm_end。 通过包含一个list_entry_t成员，
 * 我们可以把同一个页表对应的多个vma_struct结构体串成一个链表，在链表里把它们按照区间的起始点进行排序。
vm_flags表示的是一段虚拟地址对应的权限（可读，可写，可执行等），这个权限在页表项里也要进行对应的设置。

*/
// 根据vma结构体中的list_link的地址得到整个结构体vma的头地址
//将 list_entry 结构体转换为 vma_struct 结构体。
#define le2vma(le, member) \
    to_struct((le), struct vma_struct, member)

#define VM_READ 0x00000001
#define VM_WRITE 0x00000002
#define VM_EXEC 0x00000004

// the control struct for a set of vma using the same PDT
// mm_struct——memory management struct，是一组使用相同页目录表(PDT)的虚拟内存区域
// 里面有很多连续的内存区域小块，每个小块都是一个vma_struct，这些小块都含有list_entry_t结构
// 可以通过le2vm的宏由list_entry_t结构找到整个结构体vma_struct
/**
 * 每个页表（每个虚拟地址空间）可能包含多个vma_struct, 也就是多个访问权限可能不同的，不相交的连续地址区间。
 * 我们用mm_struct结构体把一个页表对应的信息组合起来，包括vma_struct链表的首指针，对应的页表在内存里的指针，vma_struct链表的元素个数。
*/
struct mm_struct
{
    //链接和维护与该 mm_struct 关联的所有虚拟内存区域（VMA）的列表。链表中的 VMA 通常根据它们的开始地址进行排序。
    list_entry_t mmap_list;        // linear list link which sorted by start addr of vma 
    //这个缓存存储了最近访问的虚拟内存区域（VMA），可以加快对这块区域的访问速度。
    struct vma_struct *mmap_cache; // current accessed vma, used for speed purpose
    //一个指向页目录表（PDT）的指针。页目录表是虚拟内存到物理内存地址映射的一部分，用于在内存分页中查找和管理页表。
    pde_t *pgdir;                  // the PDT of these vma
    //与这个 mm_struct 结构体关联的虚拟内存区域（VMA）的数量。
    int map_count;                 // the count of these vma
    //指向私有数据的指针，这些私有数据通常被交换管理器（swap manager）使用。交换管理器负责管理和优化交换空间的使用，交换空间用于在物理内存不足时存储被换出的内存页面。
    void *sm_priv;                 // the private data for swap manager
};
// mmap_list链表连接了使用相同页目录项的vma（对应的是vma中的list_link变量），使用le2vm宏由链表找到完整结构体
// ***这是一个设计的trick，page和vma_struct都有一个list_entry_t的变量，这样就可以通过le2page和le2vm宏找到完整的结构体
// mmap_cache是一个指针，指向当前正在访问的vma，这样可以加快访问速度
// pgdir是页目录表的地址
// map_count是vma的数量
// sm_priv是swap manager的私有数据,void *类型，意味着它是一个指向任意数据的通用指针,经常存可换出页面的头指针

struct vma_struct *find_vma(struct mm_struct *mm, uintptr_t addr);                    // 找到一个进程内存管理器中某个地址对应的vma块
struct vma_struct *vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags); // vma创建和初始化
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma);                 // 向mm的mmap_list的插入一个vma，按地址插入合适位置

struct mm_struct *mm_create(void); // mm_struct创建和初始化

void mm_destroy(struct mm_struct *mm);

void vmm_init(void);

int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr);

extern volatile unsigned int pgfault_num;
extern struct mm_struct *check_mm_struct;

#endif /* !__KERN_MM_VMM_H__ */
