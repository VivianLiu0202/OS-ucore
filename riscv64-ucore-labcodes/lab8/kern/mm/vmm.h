#ifndef __KERN_MM_VMM_H__
#define __KERN_MM_VMM_H__

#include <defs.h>
#include <list.h>
#include <memlayout.h>
#include <sync.h>
#include <sem.h>
#include <proc.h>
//pre define
struct mm_struct;

// the virtual continuous memory area(vma), [vm_start, vm_end), 
// addr belong to a vma means  vma.vm_start<= addr <vma.vm_end 
struct vma_struct {//虚拟内存空间
    struct mm_struct *vm_mm; // the set of vma using the same PDT  虚拟内存空间属于的进程
    uintptr_t vm_start;      // start addr of vma 连续地址的虚拟内存空间的起始位置和结束位置
    uintptr_t vm_end;        // end addr of vma, not include the vm_end itself
    uint32_t vm_flags;       // flags of vma 虚拟内存空间的属性（读/写/执行/栈）
    list_entry_t list_link;  // linear list link which sorted by start addr of vma 双向链表，从小到大将虚拟内存空间链接起来
};

/**
 * le2vma 宏定义的作用是将一个 list_entry_t 类型的指针转换为一个 vma_struct 类型的指针。
 * 这个宏定义通常用于遍历双向链表中的元素，将链表节点的指针转换为节点所属的结构体的指针，从而方便对节点所属的结构体进行操作。
*/
#define le2vma(le, member)                  \
    to_struct((le), struct vma_struct, member)

//注意vm_flags表示虚拟内存空间属性，一共四种：读、写、执行、栈
#define VM_READ                 0x00000001 
#define VM_WRITE                0x00000002
#define VM_EXEC                 0x00000004
#define VM_STACK                0x00000008

// the control struct for a set of vma using the same PDI
struct mm_struct {//描述一个进程的虚拟地址空间，每个进程的pcb中会有一个指针指向本结构体
    list_entry_t mmap_list;        // linear list link which sorted by start addr of vma 链接同一页目录表的虚拟内存空间的双向链表的头节点画
    struct vma_struct *mmap_cache; // current accessed vma, used for speed purpose 当前正在使用的虚拟内存空间
    pde_t *pgdir;                  // the PDT of these vma mm_struct 所维护的页表地址(拿来找 PTE)
    int map_count;                 // the count of these vma 虚拟内存块的数目
    void *sm_priv;                 // the private data for swap manager 记录访问情况链表头地址(用于置换算法)
    int mm_count;                  // the number ofprocess which shared the mm 共享该虚拟地址空间的进程数目
    semaphore_t mm_sem; // mutex for using dup_mmap fun to duplicat the mm 信号量，用于保护dup_mmap 函数的互斥访问。
    int locked_by; //表示当前进程对这个mm_struct的锁定状态
};
//mmap_cache变量可以使程序更好地利用操作系统执行的“局部性”原理，现阶段使用地虚拟内存空间接下来很可能还用到，所以如果直接用到地话直接调用mmap_cache将很好地提高效率。
//访问pgdir可以查找某虚拟地址对应的页表项是否存在以及页表项的属性


struct vma_struct *find_vma(struct mm_struct *mm, uintptr_t addr);
struct vma_struct *vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags);
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma);

struct mm_struct *mm_create(void);
void mm_destroy(struct mm_struct *mm);

void vmm_init(void);
int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store);
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr);

int mm_unmap(struct mm_struct *mm, uintptr_t addr, size_t len);
int dup_mmap(struct mm_struct *to, struct mm_struct *from);
void exit_mmap(struct mm_struct *mm);
uintptr_t get_unmapped_area(struct mm_struct *mm, size_t len);
int mm_brk(struct mm_struct *mm, uintptr_t addr, size_t len);

extern volatile unsigned int pgfault_num;
extern struct mm_struct *check_mm_struct;

bool user_mem_check(struct mm_struct *mm, uintptr_t start, size_t len, bool write);
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable);
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len);
bool copy_string(struct mm_struct *mm, char *dst, const char *src, size_t maxn);

static inline int
mm_count(struct mm_struct *mm) {
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
    return mm->mm_count;
}

static inline int
mm_count_dec(struct mm_struct *mm) {
    mm->mm_count -= 1;
    return mm->mm_count;
}

/**
 * 这两个函数的作用是对 mm_struct 结构体进行加锁和解锁操作
 * 用于保护进程的内存映射信息，避免多个进程同时修改同一个 mm_struct 结构体导致数据不一致。
*/
//对结构体进行加锁
static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        down(&(mm->mm_sem));//进行P操作，将进程加入等待队列并进入睡眠状态
        if (current != NULL) {
            mm->locked_by = current->pid;//锁定进程
        }
    }
}

//对结构体进行解锁
static inline void
unlock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        up(&(mm->mm_sem));//进行V操作，将信号量+1并唤醒等待队列中的一个进程
        mm->locked_by = 0;
    }
}

#endif /* !__KERN_MM_VMM_H__ */

