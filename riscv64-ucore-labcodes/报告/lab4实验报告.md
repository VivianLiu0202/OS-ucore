<h1><center>lab4实验报告</center></h1>
<h5><center>组员:胡博程 刘心源</center></h5>

lab2和lab3完成了对内存的虚拟化，但整个控制流还是一条线串行执行。lab4将在此基础上进行CPU的虚拟化，即让ucore实现分时共享CPU，实现多条控制流能够并发执行。



# 一、基本练习

###  练习1：分配并初始化一个进程控制块（需要编码）

alloc_proc函数（位于kern/process/proc.c中）负责分配并返回一个新的struct proc_struct结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。

> 【提示】在alloc_proc函数的实现中，需要初始化的proc_struct结构中的成员变量至少包括：state/pid/runs/kstack/need_resched/parent/mm/context/tf/cr3/flags/name。

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 请说明proc_struct中`struct context context`和`struct trapframe *tf`成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）

#### 1.设计实现过程

```c
        proc->state = PROC_UNINIT; //设置进程为初始态
        proc->pid = -1; //设置进程pid的未初始化值
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
        proc->tf = NULL;
        proc->cr3 = boot_cr3; //使用内核页目录表的基址
        proc->flags = 0;
        memset(proc->name, 0, PROC_NAME_LEN);
```



#### 2.作用

根据定义找到相关函数

```c
/*
kernel_thread函数采用了局部变量tf来放置保存内核线程的临时中断帧，并把中断帧的指针传递给do_fork函数，而do_fork函数会调用copy_thread函数来在新创建的进程内核栈上专门给进程的中断帧分配一块空间
*/
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
    //kernel_cs和kernel_ds表示内核线程的代码段和数据段在内核中
    tf.tf_cs = KERNEL_CS;
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
    //fn指实际的线程入口地址
    tf.tf_regs.reg_ebx = (uint32_t)fn;
    tf.tf_regs.reg_edx = (uint32_t)arg;
    //kernel_thread_entry用于完成一些初始化工作
    tf.tf_eip = (uint32_t)kernel_thread_entry;
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) 
{
    //将tf进行初始化
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
    *(proc->tf) = *tf;
    proc->tf->tf_regs.reg_eax = 0;
    //设置tf的esp，表示中断栈的信息
    proc->tf->tf_esp = esp;
    proc->tf->tf_eflags |= FL_IF;
    //对context进行设置
    //forkret主要对返回的中断处理，基本可以认为是一个中断处理并恢复
    proc->context.eip = (uintptr_t)forkret;
    proc->context.esp = (uintptr_t)(proc->tf);
}
```

通过上述函数并结合switch.S中对context的操作，将各种寄存器的值保存到context中。我们可以知道context是与上下文切换相关的，而tf则与中断的处理相关。
的那部分寄存器的值，而tf保存了所有的寄存器值。具体结合gitbook上的介绍，具体回答：

proc_struct中的context：进程的上下文，用于进程切换。在 uCore中，所有的进程在内核中也是相对独立的（例如独立的内核堆栈以及上下文等）。使用 context 保存寄存器的目的就在于在内核态中能够进行上下文之间的切换。具体切换过程定义在switch.S中。

proc_struct中的tf：当前中断帧的指针。当进程从用户空间跳到内核空间时，中断帧记录了进程在被中断前的状态。当内核需要跳回用户空间时，需要调整中断帧以恢复让进程继续执行的各寄存器值。tf变量的作用在于在构造出了新的线程的时候，如果要将控制权交给这个线程，是使用中断返回的方式进行的，因此需要构造出一个伪造的中断返回现场，使得可以正确地将控制权转交给新的线程。

寄存器可以分为调用者保存
（caller-saved）寄存器和被调用者
保存（callee-saved）寄存器。前面说到的context和tf区别就在于：context只保存了被调用者保存的那部分寄存器，tf保存了所有的寄存器；context在进程切换中起作用，tf只在用户态与内核态切换起作用。


### 练习2：为新创建的内核线程分配资源（需要编码）

创建一个内核线程需要分配和设置好很多资源。kernel_thread函数通过调用**do_fork**函数完成具体内核线程的创建工作。do_kernel函数会调用alloc_proc函数来分配并初始化一个进程控制块，但alloc_proc只是找到了一小块内存用以记录进程的必要信息，并没有实际分配这些资源。ucore一般通过do_fork实际创建新的内核线程。do_fork的作用是，**创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。** 因此，我们**实际需要”fork”的东西就是stack和trapframe**。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。你需要完成在kern/process/proc.c中的do_fork函数中的处理过程。它的大致执行步骤包括：

- 调用alloc_proc，首先获得一块用户信息块。
- 为进程分配一个内核栈。
- 复制原进程的内存管理信息到新进程（但内核线程不必做此事）
- 复制原进程上下文到新进程
- 将新进程添加到进程列表
- 唤醒新进程
- 返回新进程号

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。

#### 1.设计实现过程

```c
    //    1. call alloc_proc to allocate a proc_struct
    proc = alloc_proc();
    if(proc == NULL){
        goto fork_out;
    }
    //    2. call setup_kstack to allocate a kernel stack for child process
    ret = setup_kstack(proc);
    if(ret != 0) {
        goto bad_fork_cleanup_proc;
    }
    //    3. call copy_mm to dup OR share mm according clone_flag
    ret = copy_mm(clone_flags,proc);
    if(ret != 0) {
        goto bad_fork_cleanup_kstack;
    }
    //    4. call copy_thread to setup tf & context in proc_struct
    copy_thread(proc,stack,tf);
    //    5. insert proc_struct into hash_list && proc_list
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        proc->pid = get_pid();
        hash_proc(proc);
        list_add(&proc_list,&(proc->list_link));
        nr_process++;
    }
    local_intr_restore(intr_flag);
    //    6. call wakeup_proc to make the new child process RUNNABLE
    wakeup_proc(proc);
    //    7. set ret vaule using child proc's pid
    ret = proc->pid;
```



#### 2.问题

查看函数`get_id`

```c
// get_pid - alloc a unique pid for process
static int
get_pid(void) {
    //实际上，之前定义了MAX_PID=2*MAX_PROCESS，意味着ID的总数目是大于PROCESS的总数目的
    //因此不会出现部分PROCESS无ID可分的情况
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    //next_safe和last_pid两个变量，这里需要注意！ 它们是static全局变量！！！
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    //++last_pid>-MAX_PID,说明pid以及分到尽头，需要从头再来
    if (++ last_pid >= MAX_PID) {
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list; //le等于线程的链表头
        //遍历一遍链表
        //循环扫描每一个当前进程：当一个现有的进程号和last_pid相等时，则将last_pid+1；
        //当现有的进程号大于last_pid时，这意味着在已经扫描的进程中
        //[last_pid,min(next_safe, proc->pid)] 这段进程号尚未被占用，继续扫描。
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {
                //如果proc的pid与last_pid相等，则将last_pid加1
                //当然，如果last_pid>=MAX_PID,then 将其变为1,确保了没有一个进程的pid与last_pid重合
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            //last_pid<pid<next_safe，确保最后能够找到这么一个满足条件的区间，获得合法的pid
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}
```

get_id( ) 的执行步骤：

- 首先声明两个`next_safe`和`last_pid`的静态全局变量，初始值都设置为MAX_PID。MAX_PID是进程ID的最大数量。**当last_pid达到MAX_PID时**，它将从头开始分配新的PID。

- 接着**检查last_pid是否大于等于next_safe**。如果是，那么说明没有足够的PID可供分配，就将**last_pid重置为1**，然后跳转到名为`inside`的标签。

- 在`inside`标签下，函数将**next_safe设置为MAX_PID，然后开始遍历进程链表**。对于链表中的每个进程，**检查进程的PID是否等于last_pid**。如果是，那么函数将`last_pid`增加1，并**检查是否超过了next_safe**。如果超过了，那么函数**将`last_pid`重置为1，next_safe设置为MAX_PID。**然后函数跳回标签`repeat`。

- 在标签`repeat`下，函数再次遍历进程链表。**检查进程的PID是否大于last_pid并且小于next_safe**。 如果是，那么函数**将next_safe设置为该进程的PID。**

- 最后，函数返回`last_pid`作为新的进程ID。

这样get_id就保证了为每个调用fock的线程返回不重复的id。

之所以按照这样的过程来找寻id，因为暴力搜索复杂度较高，我认为操作系统内部的算法应强调小而快。其次，维护一个合法的pid的区间，不仅优化了时间效率，而且不同的调用get_pid函数的时候可以利用到先前调用这个函数的中间结果去求解；







### 练习3：编写proc_run 函数（需要编码）

proc_run用于将指定的进程切换到CPU上运行。它的大致执行步骤包括：

- 检查要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换。
- 禁用中断。你可以使用`/kern/sync/sync.h`中定义好的宏`local_intr_save(x)`和`local_intr_restore(x)`来实现关、开中断。
- 切换当前进程为要运行的进程。
- 切换页表，以便使用新进程的地址空间。`/libs/riscv.h`中提供了`lcr3(unsigned int cr3)`函数，可实现修改CR3寄存器值的功能。
- 实现上下文切换。`/kern/process`中已经预先编写好了`switch.S`，其中定义了`switch_to()`函数。可实现两个进程的context切换。
- 允许中断。

请回答如下问题：

- 在本实验的执行过程中，创建且运行了几个内核线程？

通过kernel_thread函数、proc_init函数以及具体的实现结果可知，本次实验共建立了两个内核线程。首先是`idleproc`内核线程，该线程是最初的内核线程，完成内核中各个子线程的创建以及初始化。之后循环执行调度，执行其他进程。还有一个是`initproc`内核线程，该线程主要是为了显示实验的完成而打印出字符串"hello world"的内核线程。



# 二、扩展练习

### 扩展练习 Challenge：

##### 说明语句`local_intr_save(intr_flag);....local_intr_restore(intr_flag);`是如何实现开关中断的？

`local_intr_save(intr_flag);` 和 `local_intr_restore(intr_flag);` 是一对用于开关中断的函数。这两个函数通常在一段关键代码区域的开始和结束处使用，以防止该区域的代码在执行过程中被中断。

`local_intr_save(intr_flag);` 的作用是保存当前的中断状态并关闭中断。它首先将当前的中断状态保存到 `intr_flag` 变量中，然后关闭中断。

`local_intr_restore(intr_flag);` 的作用是恢复之前保存的中断状态。它将 `intr_flag` 变量中保存的中断状态恢复到当前的中断状态。

这两个函数的实现通常依赖于特定的硬件和操作系统，因此具体的实现代码可能会有所不同。在一些系统中，可能会使用特殊的硬件指令或系统调用来实现这两个函数。



# 三、本实验重要知识点

### 1、进程的状态

uCore中进程状态有四种：分别是PROC_UNINIT、PROC_SLEEPING、PROC_RUNNABLE、PROC_ZOMBIE。（分别是未初始化、睡眠、可运行、僵尸进程）

僵尸进程是指已经结束运行但是其父进程尚未读取其结束状态的进程。这种进程已经释放了大部分资源，如内存空间等，但是仍然在进程表中保留一个位置，以记录其结束状态和退出代码。如果父进程不读取其结束状态，这个位置就会一直保留，导致系统资源的浪费。



### 2、线程对应的内核栈

每个线程都有一个内核栈，并且位于内核地址空间的不同位置。对于内核线程，该栈就是运行时的程序使用的栈；而对于普通进程，该栈是发生特权级改变的时候使保存被打断的硬件信息用的栈





### 3、为什么我们不需要保存所有的寄存器呢？

这里我们巧妙地利用了编译器对于函数的处理。我们知道寄存器可以分为调用者保存（caller-saved）寄存器和被调用者保存（callee-saved）寄存器。因为线程切换在一个函数当中（我们下一小节就会看到），所以编译器会自动帮助我们生成保存和恢复调用者保存寄存器的代码，在实际的进程切换过程中我们只需要保存被调用者保存寄存器就好啦！



### 4、关于TSS

进程控制单元`proc_struct`中的变量`kstack`记录了分配给该进程/线程的内核栈的位置。主要作用有以下几点。首先，当内核准备从一个进程切换到另一个的时候，需要根据`kstack` 的值正确的设置好 `tss` 

- **特权级切换**：当CPU从用户模式（低特权级）切换到内核模式（高特权级）时，需要切换使用的堆栈。`TSS` 存储了内核堆栈的指针，当发生中断或系统调用时，CPU会使用 `TSS` 中的信息来加载正确的内核堆栈。
- **中断处理**：在处理中断时，尤其是当中断发生在用户模式下时，CPU 会使用 `TSS` 中的信息来确保中断处理程序在内核模式下的正确堆栈上运行。

5、区别**list_entry_t proc_list**和 **list_entry_t hash_list**

**list_entry_t proc_list**

- **用途**：这是一个双向线性链表，用来链接所有的进程控制块（PCB）。每个进程（或线程）的 `proc_struct` 结构中都有一个 `list_link` 成员，通过这个成员，每个进程被链接到这个链表中。
- **特点**：
  - **全面性**：链表包含了系统中所有的进程，不论其状态。
  - **顺序访问**：它支持对所有进程的顺序访问，这在某些情况下非常有用，比如需要遍历所有进程进行某些操作（如资源回收、信息统计）时。
  - **简单性**：双向链表结构相对简单，容易实现和维护。

**list_entry_t hash_list[HASH_LIST_SIZE]**

- **用途**：这是一个哈希表，用于更高效地根据进程标识符（PID）查找进程控制块。哈希表的每个槽位是一个链表，存储具有相同哈希值的 `proc_struct` 实例。
- **特点**：
  - **高效查找**：哈希表使得基于 PID 的查找操作更加高效，尤其是在存在大量进程时。
  - **哈希冲突处理**：通过链接列表来处理哈希冲突，即使多个进程的 PID 产生相同的哈希值，它们也可以被正确地管理。
  - **特定场景适用性**：主要用于快速的进程查找和管理，而不是遍历所有进程。

总的来说，`proc_list` 作为一个双向链表，适用于需要遍历所有进程的场景，而 `hash_list` 作为一个哈希表，更适合于需要快速定位特定进程的场景。这两种结构共同支持 uCore 中高效和灵活的进程管理。



### 6、内核线程与用户线程在内核栈方面的一些区别

**内核线程**：

- **共享内核栈**：内核线程通常直接运行在内核空间，它们可能共享同一个内核栈。因为内核线程不需要进行用户空间到内核空间的上下文切换，所以它们的内核栈使用可以是相对简单的。
- **无需用户栈**：由于内核线程不运行用户空间的代码，它们不需要用户栈。

**用户线程（进程）**：

- **独立的内核栈**：每个用户线程（进程）在内核空间中都有自己独立的内核栈。这是因为当用户线程执行系统调用或发生中断时，需要在内核模式下运行代码，而这时它们需要独立的栈来保存内核模式下的上下文信息。
- **用户栈和内核栈分离**：用户线程同时拥有用户栈（在用户空间）和内核栈（在内核空间）。用户栈用于执行用户空间代码，而内核栈用于执行内核空间代码（如处理系统调用和中断）。



### 7、区分“共享内核内存空间”与“为每个线程或进程分配独立资源（如内核栈）“

任何进程创建的时候，会在内核栈中分配两页大小的内核栈，所有进程（包括内核线程和用户线程）都有其对应的内核栈，他们共享同一个**内核内存空间**，所以内核栈用执行不同内核线程/切换使用用户线程的内核栈时候不需要上下文切换的开销。

但是，尽管内核线程共享内核内存空间，但每个线程仍然需要有自己的内核栈。这是因为栈用于存储局部变量、函数参数、返回地址等信息。不同线程在内核内存空间中有其独立的内核栈（两个页大小）



### 8、为什么在调度的时候要关闭中断

在进行进程调度时，通常需要关闭中断，主要有以下两个原因：

1. 避免数据竞争：进程调度涉及到许多共享数据的操作，如进程队列、进程状态等。如果在调度过程中发生中断，并且中断处理程序也试图操作这些共享数据，就可能导致数据竞争或者不一致的状态。
2. 避免调度混乱：如果在调度过程中发生中断，中断处理程序可能会导致另一个进程被调度运行。这样，当原来的调度过程恢复运行时，就可能出现混乱，因为它“认为”自己正在进行调度，但实际上CPU可能已经在运行另一个进程。



### 9、关于页表寄存器

idle 在启动的时候创建了一个页表，然后把它赋给了页表寄存器。 X86 的系统里边叫CR3，在RISCV里面它叫 SATP。**SATP 里边存的是整个page table 的树根的物理地址的页号**，TLB 里边放的就是虚拟地址到物理地址的一个翻译。


### 10、关于代码中的volatile关键字

作用是标记这个变量不需要被编译器优化读操作

举例：

变量a=xxx；

...一堆代码...

变量a=xxx

编译器优化可能直接删除了后面的a的赋值，但是当a这个变量可能被硬件或者其他东西在一堆代码中更改的时候，我们不希望编译器删除掉后面的哪个a的赋值语句。
