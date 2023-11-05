#include <assert.h>
#include <clock.h>
#include <console.h>
#include <defs.h>
#include <kdebug.h>
#include <memlayout.h>
#include <mmu.h>
#include <stdio.h>
#include <swap.h>
#include <trap.h>
#include <vmm.h>
#include <riscv.h>
#include <sbi.h>

#define TICK_NUM 100
volatile size_t num = 0;

static void print_ticks()
{
    cprintf("%d ticks\n", TICK_NUM);
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S
 */
void idt_init(void)
{
    /* LAB1 YOUR CODE : STEP 2 */
    /* (1) Where are the entry addrs of each Interrupt Service Routine (ISR)?
     *     All ISR's entry addrs are stored in __vectors. where is uintptr_t
     * __vectors[] ?
     *     __vectors[] is in kern/trap/vector.S which is produced by
     * tools/vector.c
     *     (try "make" command in lab1, then you will find vector.S in kern/trap
     * DIR)
     *     You can use  "extern uintptr_t __vectors[];" to define this extern
     * variable which will be used later.
     * (2) Now you should setup the entries of ISR in Interrupt Description
     * Table (IDT).
     *     Can you see idt[256] in this file? Yes, it's IDT! you can use SETGATE
     * macro to setup each item of IDT
     * (3) After setup the contents of IDT, you will let CPU know where is the
     * IDT by using 'lidt' instruction.
     *     You don't know the meaning of this instruction? just google it! and
     * check the libs/x86.h to know more.
     *     Notice: the argument of lidt is idt_pd. try to find it!
     */
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    set_csr(sstatus, SSTATUS_SIE);
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
//用于判断当前的异常是否发生在内核态。
bool trap_in_kernel(struct trapframe *tf)
{
    //使用 tf->status 获取当前 CPU 的状态寄存器的值，该寄存器包含了当前 CPU 的特权级别信息。
    //使用 SSTATUS_SPP 宏获取状态寄存器中的 SPP（Supervisor Previous Privilege）位，该位表示上一次的特权级别。
    return (tf->status & SSTATUS_SPP) != 0;
    //如果 SPP 位为1，则上一次的特权级别为内核态，否则为用户态。
}

void print_trapframe(struct trapframe *tf)
{
    cprintf("trapframe at %p\n", tf);
    print_regs(&tf->gpr);
    cprintf("  status   0x%08x\n", tf->status);
    cprintf("  epc      0x%08x\n", tf->epc);
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
    cprintf("  ra       0x%08x\n", gpr->ra);
    cprintf("  sp       0x%08x\n", gpr->sp);
    cprintf("  gp       0x%08x\n", gpr->gp);
    cprintf("  tp       0x%08x\n", gpr->tp);
    cprintf("  t0       0x%08x\n", gpr->t0);
    cprintf("  t1       0x%08x\n", gpr->t1);
    cprintf("  t2       0x%08x\n", gpr->t2);
    cprintf("  s0       0x%08x\n", gpr->s0);
    cprintf("  s1       0x%08x\n", gpr->s1);
    cprintf("  a0       0x%08x\n", gpr->a0);
    cprintf("  a1       0x%08x\n", gpr->a1);
    cprintf("  a2       0x%08x\n", gpr->a2);
    cprintf("  a3       0x%08x\n", gpr->a3);
    cprintf("  a4       0x%08x\n", gpr->a4);
    cprintf("  a5       0x%08x\n", gpr->a5);
    cprintf("  a6       0x%08x\n", gpr->a6);
    cprintf("  a7       0x%08x\n", gpr->a7);
    cprintf("  s2       0x%08x\n", gpr->s2);
    cprintf("  s3       0x%08x\n", gpr->s3);
    cprintf("  s4       0x%08x\n", gpr->s4);
    cprintf("  s5       0x%08x\n", gpr->s5);
    cprintf("  s6       0x%08x\n", gpr->s6);
    cprintf("  s7       0x%08x\n", gpr->s7);
    cprintf("  s8       0x%08x\n", gpr->s8);
    cprintf("  s9       0x%08x\n", gpr->s9);
    cprintf("  s10      0x%08x\n", gpr->s10);
    cprintf("  s11      0x%08x\n", gpr->s11);
    cprintf("  t3       0x%08x\n", gpr->t3);
    cprintf("  t4       0x%08x\n", gpr->t4);
    cprintf("  t5       0x%08x\n", gpr->t5);
    cprintf("  t6       0x%08x\n", gpr->t6);
}

static inline void print_pgfault(struct trapframe *tf)
{
    //然后，函数根据 trap_in_kernel 函数的返回值判断页故障发生在用户态还是内核态，并将结果打印出来。
    //如果 trap_in_kernel 函数返回 true，则页故障发生在内核态，打印字符 K；
    //否则页故障发生在用户态，打印字符 U。
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',                   // U表示用户态，K表示内核态
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R'); // W表示写了不存在的页，R表示读了不存在的页
}

//处理页面故障异常
static int pgfault_handler(struct trapframe *tf)
{
    extern struct mm_struct *check_mm_struct; //当前使用的mm_struct的指针，在vmm.c定义
    print_pgfault(tf);
    /**
     * check_mm_struct 变量是一个指向 mm_struct 结构体的指针，用于指向当前正在运行的进程的内存管理结构。
     * 如果该变量不为 NULL，则说明当前正在运行的是用户进程，需要调用 do_pgfault 函数处理页故障。
     * 否则，说明当前正在运行的是内核代码，不需要处理页故障。
    */
    if (check_mm_struct != NULL)
    {
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);//调用do_pgfault函数处理页面故障
    }
    //我们的trapFrame传递了badvaddr给do_pgfault()函数，而这实际上是stval这个寄存器的数值（在旧版的RISCV标准里叫做sbadvaddr)
    //这个寄存器存储一些关于异常的数据，对于PageFault它存储的是访问出错的虚拟地址。
    panic("unhandled page fault.\n");
}

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf)
{
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause)
    {
    case IRQ_U_SOFT:
        cprintf("User software interrupt\n");
        break;
    case IRQ_S_SOFT:
        cprintf("Supervisor software interrupt\n");
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
        break;
    case IRQ_U_TIMER:
        cprintf("User software interrupt\n");
        break;
    case IRQ_S_TIMER:
        // "All bits besides SSIP and USIP in the sip register are
        // read-only." -- privileged spec1.9.1, 4.1.4, p59
        // In fact, Call sbi_set_timer will clear STIP, or you can clear it
        // directly.
        // clear_csr(sip, SIP_STIP);
        clock_set_next_event();
        // 修改成：
        ticks++;
        if (ticks == 100)
        {
            ticks = 0;
            print_ticks();
            if (num == 10)
            {
                sbi_shutdown();
            }
            num++;
        }
        break;

        // if (++ticks % TICK_NUM == 0) {
        //     print_ticks();
        // }
        // break;
    case IRQ_H_TIMER:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_TIMER:
        cprintf("Machine software interrupt\n");
        break;
    case IRQ_U_EXT:
        cprintf("User software interrupt\n");
        break;
    case IRQ_S_EXT:
        cprintf("Supervisor external interrupt\n");
        break;
    case IRQ_H_EXT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_EXT:
        cprintf("Machine software interrupt\n");
        break;
    default:
        print_trapframe(tf);
        break;
    }
}

void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
    {
    case CAUSE_MISALIGNED_FETCH: // 取指令时发生的Page Fault先不处理
        cprintf("Instruction address misaligned\n");
        break;
    case CAUSE_FETCH_ACCESS:
        cprintf("Instruction access fault\n");
        break;
    case CAUSE_ILLEGAL_INSTRUCTION:
        cprintf("Illegal instruction\n");
        break;
    case CAUSE_BREAKPOINT:
        cprintf("Breakpoint\n");
        break;
    case CAUSE_MISALIGNED_LOAD: // 加载地址未对齐。当尝试从一个非对齐的地址加载数据时，这种异常被触发。
        cprintf("Load address misaligned\n");
        break;
    case CAUSE_LOAD_ACCESS: // 加载访问错误。当一个程序尝试从一个它没有权限访问的地址加载数据时，这种异常被触发。
        cprintf("Load access fault\n");
        if ((ret = pgfault_handler(tf)) != 0) //do_pgfault()页面置换成功时返回0
        {
            print_trapframe(tf);
            panic("handle pgfault failed. %e\n", ret);
        }
        break;
    case CAUSE_MISALIGNED_STORE: // 存储地址未对齐。当尝试将数据存储到一个非对齐的地址时，这种异常被触发。
        cprintf("AMO address misaligned\n");
        break;
    case CAUSE_STORE_ACCESS: // 存储访问错误。当一个程序尝试将数据存储到一个它没有权限访问的地址时，这种异常被触发。
        cprintf("Store/AMO access fault\n");
        if ((ret = pgfault_handler(tf)) != 0)
        {
            print_trapframe(tf);
            panic("handle pgfault failed. %e\n", ret);
        }
        break;
    case CAUSE_USER_ECALL:
        cprintf("Environment call from U-mode\n");
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
        break;
    case CAUSE_HYPERVISOR_ECALL:
        cprintf("Environment call from H-mode\n");
        break;
    case CAUSE_MACHINE_ECALL:
        cprintf("Environment call from M-mode\n");
        break;
    case CAUSE_FETCH_PAGE_FAULT:
        cprintf("Instruction page fault\n");
        break;
    case CAUSE_LOAD_PAGE_FAULT: // 加载页面错误。当一个程序尝试从一个它没有权限访问的地址加载数据时，这种异常被触发。
        cprintf("Load page fault\n");
        if ((ret = pgfault_handler(tf)) != 0)
        {
            print_trapframe(tf);
            panic("handle pgfault failed. %e\n", ret);
        }
        break;
    case CAUSE_STORE_PAGE_FAULT:           // 存储页面错误。当一个程序尝试将数据存储到一个它没有权限访问的地址时，这种异常被触发。
        cprintf("Store/AMO page fault\n"); // 存储/原子存储-修改-写入页面错误。
        if ((ret = pgfault_handler(tf)) != 0)
        {
            print_trapframe(tf);
            panic("handle pgfault failed. %e\n", ret);
        }
        break;
    default:
        print_trapframe(tf);
        break;
    }
}

/* *
 * trap - handles or dispatches an exception/interrupt. if and when trap()
 * returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf)
{
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0)
    {
        // interrupts
        interrupt_handler(tf);
    }
    else
    {
        // exceptions
        exception_handler(tf);
    }
}
