#ifndef __KERN_PROCESS_PROC_H__
#define __KERN_PROCESS_PROC_H__

#include <defs.h>
#include <list.h>
#include <trap.h>
#include <memlayout.h>


// process's state in his life cycle
enum proc_state {
    PROC_UNINIT = 0,  // uninitialized
    PROC_SLEEPING,    // sleeping
    PROC_RUNNABLE,    // runnable(maybe running)
    PROC_ZOMBIE,      // almost dead, and wait parent proc to reclaim his resource
};

//进程上下文使用结构体struct context保存，其中包含了ra，sp，s0~s11共14个寄存器。
/**
 * 为什么我们不需要保存所有的寄存器呢？利用了编译器对于函数的处理。
 * 寄存器可以分为调用者保存（caller-saved）寄存器和被调用者保存（callee-saved）寄存器。QAQ
 * 因为线程切换在一个函数当中，所以编译器会自动帮助我们生成保存和恢复调用者保存寄存器的代码，在实际的进程切换过程中我们只需要保存被调用者保存寄存器就好啦！
*/
struct context {
    uintptr_t ra;
    uintptr_t sp;
    uintptr_t s0;
    uintptr_t s1;
    uintptr_t s2;
    uintptr_t s3;
    uintptr_t s4;
    uintptr_t s5;
    uintptr_t s6;
    uintptr_t s7;
    uintptr_t s8;
    uintptr_t s9;
    uintptr_t s10;
    uintptr_t s11;
};

#define PROC_NAME_LEN               15
#define MAX_PROCESS                 4096
#define MAX_PID                     (MAX_PROCESS * 2)

extern list_entry_t proc_list;

struct proc_struct {
    //进程所处的状态。uCore中进程状态有四种：分别是PROC_UNINIT、PROC_SLEEPING、PROC_RUNNABLE、PROC_ZOMBIE。
    enum proc_state state;                      // Process state
    int pid;                                    // Process ID
    int runs;                                   // the running times of Proces
    /**
     * uCore在创建进程时分配了 2 个连续的物理页（参见memlayout.h中KSTACKSIZE的定义）作为内核栈的空间。
     * 这个栈很小，所以内核中的代码应该尽可能的紧凑，并且避免在栈上分配大的数据结构，以免栈溢出
     * kstack记录了分配给该进程/线程的内核栈的位置。
     * 首先，当内核准备从一个进程切换到另一个的时候，需要根据kstack 的值正确的设置好 tss,以便在进程切换以后再发生中断时能够使用正确的栈。
     * 其次，内核栈位于内核地址空间，并且是不共享的（每个线程都拥有自己的内核栈），因此不受到 mm 的管理，当进程退出的时候，内核能够根据 kstack 的值快速定位栈的位置并进行回收
    */
    uintptr_t kstack;                           // Process kernel stack
    volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
    /* 保存了进程的父进程的指针。
     * 在内核中，只有内核创建的idle进程没有父进程，其他进程都有父进程。
     * 进程的父子关系组成了一棵进程树，这种父子关系有利于维护父进程对于子进程的一些特殊操作。
     */
    struct proc_struct *parent;                 // the parent process
    /**这里面保存了内存管理的信息，包括内存映射，虚存管理等内容
     * 内核线程常驻内存，不需要考虑swap page问题，因此在lab4中mm对于内核线程就没有用了
     * 内核线程的proc_struct的成员变量mm=0是合理的，mm里有个很重要的项pgdir，记录的是该进程使用的一级页表的物理地址。
    */
    struct mm_struct *mm;                       // Process's memory management field
    /*
     * context中保存了进程执行的上下文，也就是几个关键的寄存器的值。
     这些寄存器的值用于在进程切换中还原之前进程的运行状态（进程切换的详细过程在后面会介绍）。切换过程的实现在kern/process/switch.S。
    */
    struct context context;                     // Switch here to run process
    /**
     * tf里保存了进程的中断帧。
     * 当进程从用户空间跳进内核空间的时候，进程的执行状态被保存在了中断帧中（注意这里需要保存的执行状态数量不同于上下文切换）。
     * 系统调用可能会改变用户寄存器的值，我们可以通过调整中断帧来使得系统调用返回特定的值。
    */
    struct trapframe *tf;                       // Trap frame for current interrupt
    /**
     * cr3寄存器是x86架构的特殊寄存器，用来保存页表所在的基址。
     * 出于legacy的原因，我们这里仍然保留了这个名字，但其值仍然是页表基址所在的位置。
     * 进程切换的时候方便直接使用 lcr3实现页表切换，避免每次都根据 mm 来计算 cr3。
     * 当某个进程是一个普通用户态进程的时候，PCB 中的 cr3 就是 mm 中页表（pgdir）的物理地址
     * 而当它是内核线程的时候，cr3 等于boot_cr3。boot_cr3指向了uCore启动时建立好的内核虚拟空间的页目录表首地址
    */
    uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
    uint32_t flags;                             // Process flag
    char name[PROC_NAME_LEN + 1];               // Process name
    list_entry_t list_link;                     // Process link list 
    list_entry_t hash_link;                     // Process hash list
};

#define le2proc(le, member)         \
    to_struct((le), struct proc_struct, member)

extern struct proc_struct *idleproc, *initproc, *current;

void proc_init(void);
void proc_run(struct proc_struct *proc);
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags);

char *set_proc_name(struct proc_struct *proc, const char *name);
char *get_proc_name(struct proc_struct *proc);
void cpu_idle(void) __attribute__((noreturn));

struct proc_struct *find_proc(int pid);
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf);
int do_exit(int error_code);

#endif /* !__KERN_PROCESS_PROC_H__ */

