<h1><center>lab3实验报告</center></h1>
<h5><center>组员：杜鑫 胡博程 刘心源</center></h5>

# 一、基本练习

###  练习1：理解基于FIFO的页面替换算法（思考题）

描述FIFO页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？（为了方便同学们完成练习，所以实际上我们的项目代码和实验指导的还是略有不同，例如我们将FIFO页面置换算法头文件的大部分代码放在了`kern/mm/swap_fifo.c`文件中，这点请同学们注意）

- 至少正确指出10个不同的函数分别做了什么？如果少于10个将酌情给分。我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响,删去后会导致输出结果不同的函数（例如assert）而不是cprintf这样的函数。如果你选择的函数不能完整地体现”从换入到换出“的过程，比如10个函数都是页面换入的时候调用的，或者解释功能的时候只解释了这10个函数在页面换入时的功能，那么也会扣除一定的分数

<h4><center>本实验特有的数据结构</center></h4>

```c
// vma——virtual memory area，是一段连续的虚拟内存区域，[vm_start, vm_end)
struct vma_struct
{
    struct mm_struct *vm_mm; // the set of vma using the same PDT
    uintptr_t vm_start;      // start addr of vma
    uintptr_t vm_end;        // end addr of vma, not include the vm_end itself
    uint_t vm_flags;         // flags of vma
    list_entry_t list_link;  // linear list link which sorted by start addr of vma
};
```

```c
// the control struct for a set of vma using the same PDT
// mm_struct——memory management struct，是一组使用相同页目录表(PDT)的虚拟内存区域
// 里面有很多连续的内存区域小块，每个小块都是一个vma_struct，这些小块都含有list_entry_t结构
// 可以通过le2vm的宏由list_entry_t结构找到整个结构体vma_struct
struct mm_struct
{
    list_entry_t mmap_list;        // linear list link which sorted by start addr of vma
    struct vma_struct *mmap_cache; // current accessed vma, used for speed purpose
    pde_t *pgdir;                  // the PDT of these vma
    int map_count;                 // the count of these vma
    void *sm_priv;                 // the private data for swap manager
};
// mmap_list链表连接了使用相同页目录项的vma（对应的是vma中的list_link变量），使用le2vm宏由链表找到完整结构体
// ***这是一个设计的trick，page和vma_struct都有一个list_entry_t的变量，这样就可以通过le2page和le2vm宏找到完整的结构体
// mmap_cache是一个指针，指向当前正在访问的vma，这样可以加快访问速度
// pgdir是页目录表的地址
// map_count是vma的数量
// sm_priv是swap manager的私有数据,void *类型，意味着它是一个指向任意数据的通用指针
```

```c
struct Page
{
    int ref;      // page frame's reference counter
    uint_t flags; // array of flags that describe the status of the page frame
    uint_t visited;
    unsigned int property;      // the num of free block, used in first fit pm manager
    list_entry_t page_link;     // free list link
    //增添了两个变量：pra_page_link以及pra_vaddr，用于页替换算法
    list_entry_t pra_page_link; // used for pra (page replace algorithm)
    uintptr_t pra_vaddr;        // used for pra (page replace algorithm)
};
```



<h4><center>在swap_fifo.c中有以下三个函数</center></h4>

1. **_fifo_init_mm(struct mm_struct \*mm)**
   - 功能描述：初始化FIFO页面置换算法的队列，并将mm结构中的sm_priv指向该队列。
   - 处理内容：首先，初始化了一个名为`pra_list_head`的双向链表头部。接着，将`mm->sm_priv`指向这个队列头部，从而使得在内存管理结构mm_struct中可以访问到FIFO的队列。
2. **_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page \*page, int swap_in)**
   - 功能描述：当一个页面被换入时，这个函数将其加入到FIFO队列的尾部。
   - 处理内容：首先，它从`mm->sm_priv`获取FIFO队列头部的指针。接着，获取当前页面的指针。最后，将这个页面链接到队列的尾部，表示这个页面是最近进入内存的。
3. **_fifo_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick)**
   - 功能描述：当需要一个牺牲页面以换出时，这个函数选择并从FIFO队列的头部移除一个页面。
   - 处理内容：首先，从`mm->sm_priv`获取FIFO队列头部的指针。接着，选择队列中最旧的页面（即队列头部的上一个页面，因为这是一个环形队列）。然后，将这个页面从队列中删除，并将页面的地址设置给`ptr_page`。
   - 

<h4><center>理解代码的执行流</center></h4>

**主执行流：**init--->swap_init--->check_swap--->check_content_access--->sm->check_swap()--->发生缺页异常--->trap()--->exception_handler--->pgfault_handler--->do_pgfault--->swap_in、page_insert、swap_map_swappable

**swap_in分支**：swap_in->alloc_page--->alloc_pages--->swap_out--->sm->swap_out_victim

**page_insert分支**：page_insert--->tlb_validate



<h4><center>进行函数详解部分</center></h4>

#### 1、swap_init函数

用于初始化页面交换系统。具体来说，该函数首先调用`swapfs_init`函数初始化磁盘交换分区。然后，它检查最大交换偏移量是否在某个范围内，如果不在范围内，则输出错误信息并引发紧急情况。接着，该函数选择使用时钟页面置换算法，并调用该算法的`init`函数进行初始化。如果初始化成功，则将`swap_init_ok`标记为真，并输出当前使用的页面置换算法的名称。最后，该函数调用`check_swap`函数来检查页面置换算法的正确性和可靠性。

其中涉及`swapfs_init`、`sm->init`等函数

1. `swapfs_init`函数：使用`static_assert`宏检查页面大小是否是扇区大小的整数倍，如果不是，则会在编译时引发错误。接着，该函数调用`ide_device_valid`函数检查磁盘交换分区是否可用，如果不可用，则输出错误信息并引发紧急情况。最后，该函数计算最大交换偏移量，即磁盘交换分区的大小除以页面大小，以便在后续的页面置换算法中使用
2. `sm->init`函数：调用所选内存置换算法的init函数，现在选择的是上面提及的**_fifo_init_mm(struct mm_struct \*mm)**



#### 2、check_swap函数

检查页面交换函数。该函数首先备份内存环境，然后设置物理页面环境，并创建一个虚拟内存区域。接着，它分配4个物理页面，并重新初始化空闲页面链表。然后，它设置初始的虚拟页面和物理页面的映射关系，并调用不同页面置换算法的`check`函数来检查算法

其中涉及到`vma_create`，`insert_vma_struct`函数

1. `vma_create`函数：vma的创建并初始化，根据参数`vm_start`、`vm_end`、`vm_flags`完成初始化
2. `insert_vma_struct`函数：向mm的mmap_list的插入一个vma，按地址插入合适位置
3. `check_content_set`函数：初步检查页面交换函数，进行一些基本的访存和缺页处理

```c
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
```





#### 3、check_content_access函数

调用不同页面置换算法的check函数检查算法。当发生缺页异常的时候进入trap.c中的trap函数转到处理异常的函数`exception_handler`，随后进入`pgfault_handler`函数进行缺页的正常处理，并使用变量`ret`承接`pgfault_handler`函数的返回值，返回值为0表明处理成功，否则就使用`print_trapframe`函数打印寄存器状态，并输出一个错误消息。

```c
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
```

```c
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
    {
    // 其他代码
    case CAUSE_MISALIGNED_LOAD:
        cprintf("Load address misaligned\n");
        break;
    case CAUSE_LOAD_ACCESS:
        cprintf("Load access fault\n");
        if ((ret = pgfault_handler(tf)) != 0)
        {
            print_trapframe(tf);
            panic("handle pgfault failed. %e\n", ret);
        }
        break;
    case CAUSE_MISALIGNED_STORE:
        cprintf("AMO address misaligned\n");
        break;
    case CAUSE_STORE_ACCESS:
        cprintf("Store/AMO access fault\n");
        if ((ret = pgfault_handler(tf)) != 0)
        {
            print_trapframe(tf);
            panic("handle pgfault failed. %e\n", ret);
        }
        break;
    // 其他代码
    case CAUSE_LOAD_PAGE_FAULT:
        cprintf("Load page fault\n");
        if ((ret = pgfault_handler(tf)) != 0)
        {
            print_trapframe(tf);
            panic("handle pgfault failed. %e\n", ret);
        }
        break;
    case CAUSE_STORE_PAGE_FAULT:
        cprintf("Store/AMO page fault\n");
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
```

在`pgfault_handler`函数中首先调用`print_pgfault`打印异常发生的地址等信息，随后使用`do_pgfault`函数处理缺页异常。

#### 4、do_pgfault函数

接受一个指向`mm_struct`结构体的指针、一个错误码和一个地址作为参数。该函数首先使用函数`find_vma`尝试查找包含该地址的`vma`结构体，如果找不到或者该地址不在任何`vma`的范围内，则输出错误信息并返回无效值。接着，它检查该地址是否可写，并根据需要设置相应的页权限。然后，它将该地址向下对齐到页面大小的整数倍，找到发生缺页的地址所在的页面的首地址。接下来，它使用`get_pte`函数尝试获取该页面的页表条目，如果该条目为空，则使用`pgdir_alloc_page`函数尝试为该页面分配一个新页面并设置适当的权限。如果该条目不为空，则说明该页面已经被映射到物理页面上，此时需要根据该页表条目的交换条目信息，使用`swap_in`函数从磁盘中加载数据，再使用`page_insert`函数将其映射到物理页面上，然后使用`swap_map_swappable`函数设置页面为可交换的。最后，该函数返回0表示成功，或者返回错误码表示失败。

1. `find_vma`函数：用于查找包含给定地址的虚拟内存区域（VMA）。函数接受一个指向`mm_struct`结构体的指针和一个地址作为参数。它首先检查`mm`指针是否为空，如果为空则返回空指针。接着，它尝试从`mm`结构体中的`mmap_cache`字段中查找包含该地址的VMA，如果找到则直接返回该VMA。如果没有找到，则遍历`mm`结构体中的`mmap_list`链表，查找包含该地址的VMA。如果找到，则返回该VMA，否则返回空指针。最后，如果找到了VMA，则将其存储在`mmap_cache`字段中以备下次查找使用。该函数的目的是在给定的进程地址空间中查找包含给定地址的虚拟内存区域。
2. `insert_vma_struct`函数：用于将一个虚拟内存区域（VMA）插入到进程的地址空间中。函数接受一个指向`mm_struct`结构体的指针和一个指向`vma_struct`结构体的指针作为参数。该函数首先检查`vma`的起始地址是否小于结束地址，如果不是，则输出错误信息并终止程序。接着，它遍历`mm`结构体中的`mmap_list`链表，找到第一个起始地址大于`vma`的起始地址的VMA，并将`vma`插入到该VMA之前。如果找不到这样的VMA，则将`vma`插入到链表末尾。在插入之前，该函数还会检查`vma`与前后VMA是否重叠，如果重叠则输出错误信息并终止程序。最后，该函数将`vma`的`vm_mm`字段设置为`mm`，并将`mm`的`map_count`字段加1。该函数的目的是将一个VMA插入到进程的地址空间中，并保证VMA按地址顺序排列，不重叠。
3. `mm_destroy`函数：用于释放一个`mm_struct`结构体及其内部字段占用的空间。该函数接受一个指向`mm_struct`结构体的指针作为参数。该函数首先遍历`mm`结构体中的`mmap_list`链表，逐个删除其中的VMA，并释放其占用的空间。然后，它释放`mm`结构体本身占用的空间，并将`mm`指针设置为`NULL`。该函数的目的是在进程退出或被销毁时，释放其占用的内存空间，避免内存泄漏。
4. `get_pte`函数：用于获取给定线性地址对应的页表项指针，并在需要时为页表分配一个新页面。该函数接受一个指向页目录表（PDT）的指针、一个线性地址和一个逻辑值作为参数。如果该页表项不存在且`create`参数为真，则该函数会为页表分配一个新页面，并将该页表项设置为新页面的物理地址。如果分配失败，则返回空指针。如果该页表项已经存在，则直接返回该页表项指针。该函数的目的是获取给定线性地址对应的页表项指针，并在需要时为页表分配一个新页面。
5. `page_insert`函数：用于将一个物理页面映射到给定的线性地址上。该函数接受一个指向页目录表（PDT）的指针、一个指向`Page`结构体的指针、一个线性地址和一个权限参数作为参数。该函数首先调用`get_pte`函数获取给定线性地址对应的页表项指针，如果该页表项不存在，则返回错误码。接着，该函数增加该物理页面的引用计数，并检查该页表项是否已经被映射到其他物理页面上。如果是，则需要先将该页表项从原物理页面中删除。然后，该函数将该页表项设置为指向给定物理页面的物理地址，并设置相应的权限。最后，该函数调用`tlb_invalidate`函数使TLB失效，以确保新的映射关系能够生效。该函数的目的是将一个物理页面映射到给定的线性地址上，并更新页表项和TLB。
6. `swap_map_swappable`函数：用于将传入函数的页面标记为可交换的，接受三个参数——指向`mm_struct`结构体的指针、前页面在进程地址空间中的虚拟地址`addr`、指向 `struct Page` 结构体的指针、整数`swap_in`标识（表示当前页面是否需要从交换空间中调入内存，如果需要则为 1，否则为 0）这里将会调用**上面提到的sm->map_swappable**



#### 5、swap_in函数

`swap_in`函数：用于将一个页面从磁盘交换区读入到物理内存中。该函数接受一个指向`mm_struct`结构体的指针、一个线性地址和一个指向`Page`结构体指针的指针作为参数。该函数首先调用`alloc_page`函数分配一个新的物理页面，并将其存储在`result`指针中。接着，它调用`get_pte`函数获取给定线性地址对应的页表项指针，并将该页表项中的交换条目读入到`result`指向的物理页面中。如果读取失败，则输出错误信息并终止程序。最后，该函数将`result`指针存储在`ptr_result`指向的指针中，并返回0表示成功。



1. `alloc_page`宏拓展到`alloc_pages(1)`,用于分配指定数量的物理页面。该函数接受一个整数参数`n`，表示需要分配的页面数量。该函数首先定义一个指向`Page`结构体的指针`page`，并将其初始化为`NULL`。然后，该函数进入一个无限循环，每次循环中，它调用`pmm_manager`指向的物理内存管理器的`alloc_pages`函数来分配页面。如果分配成功，则直接返回该页面的指针。如果分配失败，则需要检查是否可以进行页面交换。如果`swap_init_ok`为真，且需要分配的页面数量为1，则调用`swap_out`函数将一个页面交换到磁盘上，并再次尝试分配页面。如果分配成功，则返回该页面的指针。如果分配失败，则继续循环。最后，该函数返回分配的页面的指针。而在`swap_out`函数中包含`swapfs_write`、`tlb_invalidate`等函数：
   - `swap_out`函数：用于将一个页面交换到磁盘上。该函数接受一个指向`mm_struct`结构体的指针、一个整数参数`n`和一个逻辑值`in_tick`作为参数。该函数首先进入一个循环，每次循环中，它调用**上面提到的sm->swap_out_victim**函数来选择一个页面作为交换页面。如果选择失败，则输出错误信息并终止程序。接着，该函数获取该页面对应的页表项指针，并将该页表项中的交换条目写入到磁盘交换区中。如果写入失败，则需要将该页面重新标记为可交换，并继续循环。如果写入成功，则将该页面的页表项设置为交换条目的值，并释放该页面占用的物理页面。最后，该调用`tlb_invalidate`函数使TLB失效，并返回成功交换的页面数量。
   - `swapfs_write`函数：接受一个交换条目号和一个指向`Page`结构体的指针作为参数，它使用`ide_write_secs`函数将`page`指向的物理页面中的数据写入到磁盘交换分区中对应的位置。该函数返回写入的扇区数，如果写入失败，则返回错误码。这两个函数的目的是在页面置换时，将物理页面与磁盘交换分区中的数据进行读写操作。
   - `tlb_invalidate`函数：内部执行一次`flush_tlb`函数，该函数内部执行代码`asm volatile("sfence.vma");`其中`sfence.vma`是RISC-V指令集中的一个特殊指令，用于刷新TLB缓存。
2. `swapfs_read`函数：接受一个交换条目号和一个指向`Page`结构体的指针作为参数，它使用`ide_read_secs`函数从磁盘交换分区中读取对应的页面数据，并将其存储到`page`指向的物理页面中。该函数返回读取的扇区数，如果读取失败，则返回错误码。
3. `tlb_invalidate`函数：内部执行一次`flush_tlb`函数，该函数内部执行代码`asm volatile("sfence.vma");`其中`sfence.vma`是RISC-V指令集中的一个特殊指令，用于刷新TLB缓存。



#### 6、附上用到的一些关于页表项和虚拟地址的宏

虚拟地址和页表项的结构如下：

```c
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
```

- **PDX1(la)** 和 **PDX0(la)**：这两个宏是为了从给定的线性地址`la`中提取页目录索引。它们通过右移适当的位数然后执行位与操作来获取目标索引。
- **PTX(la)**：此宏从线性地址`la`中提取页表索引。
- **PPN(la)**：从线性地址`la`中提取页号字段，这实质上是为了获取物理页号。
- **PGOFF(la)**：此宏用于获取线性地址`la`中的页内偏移量。
- **PGADDR(d1, d0, t, o)**：此宏使用页目录索引、页表索引和偏移量构建线性地址。
- **PTE_ADDR(pte)** 和 **PDE_ADDR(pde)**：这两个宏从页表或页目录条目中提取物理地址。它们首先通过位与操作清除条目的标志位，然后左移适当的位数。

**页目录和页表常数**：以下几个定义与页的大小、页表大小和页目录大小有关：

- **NPDEENTRY** 和 **NPTEENTRY**：它们定义了每个页目录和每个页表中的条目数。
- **PGSIZE**：定义了由一个页面映射的字节数。
- **PGSHIFT**、**PTSHIFT**：它们是对应大小的对数。
- **PTSIZE** 和 **PDSIZE**：它们分别表示由页目录条目和页目录映射的字节数。

**位移常量**：**PTXSHIFT**、**PDX0SHIFT**、**PDX1SHIFT** 和 **PTE_PPN_SHIFT** 代表在线性地址或物理地址中各部分的位偏移。

一些其他的辅助宏定义：

- **swap_offset(entry)**：将一个交换条目（swap_entry）转换为对应的偏移量（offset），将交换条目右移8位，得到的结果即为偏移量。

### 练习2：深入理解不同分页模式的工作原理（思考题

`get_pte()`函数（位于`kern/mm/pmm.c`）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。

- `get_pte()`函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。
- 目前`get_pte()`函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？



##### 第一问：

RISC-V的分页机制为多级页表，sv32、sv39和sv48三种分页模式分别是为了适配32位、39位和48位虚拟地址空间。每一种模式都有不同数量的页表层级。

- **sv32**：对于32位虚拟地址，使用两级页表：页目录（L1）和页表（L2）。
- **sv39**：对于39位虚拟地址，使用三级页表：页目录层级1（L1）、页目录层级2（L2）和页表（L3）。
- **sv48**：对于48位虚拟地址，使用四级页表：页目录层级1（L1）、页目录层级2（L2）、页目录层级3（L3）和页表（L4）。

在本实验中使用sv39分页机制，所以在`get_pte()`函数中，有两个层级的页目录项的处理。两段代码结构非常相似是因为其涉及**处理两级页表项的操作**

所以在这三种模式中，虽然页表层级的数量不同，但每一级的行为非常相似，只是它们对应于虚拟地址的不同部分。在每一级，以下步骤都会被执行：

1. 从虚拟地址中提取相应的索引。
2. 使用这个索引在当前层级的页表/页目录中查找。
3. 如果条目不存在（即没有映射），根据需要创建一个新的页表/页目录。
4. 如果已经存在条目，转到下一层级并重复这些步骤。

当扩展到sv32或sv48时，这种模式会持续。例如，在sv48中，应该有三段非常相似的代码，每段都对应于不同的页表层级。



##### 第二问：

我认为这种写法虽然有其合理性，但是相对于将页表项的查找和页表项的分配实现的思路，合在一起的思路还是不太好的。



将页表项的查找和分配合并在`get_pte()`函数中确实可以提供方便，因为它允许调用函数的代码更加简洁。但是，将这两个功能合并可能会对代码的可读性、模块化和重用性产生一些负面影响。以下是这种合并写法的优点和缺点：

**其合理性在于优点**：

1. **函数参数限制**：在`get_pte()`函数中， `create`参数决定是否为页表分配一个页，可以做到调用该函数的时候实现只查找不分配和查找分配都进行的操作，使得整个函数的功能是完整的。
2. **简化调用**：调用者不需要分别调用查找和分配函数，只需调用一个函数即可。
3. **减少错误**：由于查找和分配逻辑被封装在同一个函数中，调用者不太可能忘记执行其中的任何一步。

**其缺点在于**：（主要是第一个原因）

1. **需要额外的资源（可能是硬件资源）**：由于执行`get_pte()`函数时需要针对不同的应用场景传入`create`参数，即对于查找和分配同时做的操作【比如虚拟内存分配、虚拟内存分配等】需要标识create为1，对于查找和分配操作只做一个的操作【比如只读页表项查找、修改已有页表项、回收物理内存等操作】需要标识create为0，这个标示一定需要额外的资源，在可以通过**软件工程规范**函数功能分配的场景下，分开实现以规避冗余硬件资源是更合理的选择
2. **函数的单一职责原则**：通常，每个函数应该只有一个原因进行修改，这就是所谓的函数的单一职责原则。合并两个功能可能违反了这一原则。
3. **重用性**：如果在其他地方只需要其中的一个功能（例如，只查找不分配），则该函数可能不太适用。
4. **可读性和维护性**：合并两个功能可能使函数变得更长和更复杂，这可能会降低代码的可读性和维护性。
5. **不够直观**：当某人查看`get_pte()`函数时，他们可能不会立即意识到这个函数同时负责查找和分配。

在某些情况下，为了简化代码和减少错误，合并可能是合理的。但在其他情况下，为了提高代码的模块化、可读性和重用性，将它们分开可能是更好的选择。

### 练习3：给未被映射的地址映射上物理页（需要编程

补充完成do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限 的时候需要参考页面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制 结构所指定的页表，而不是内核的页表。 请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。

- 如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？

- 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

  

##### do_pgfault函数

1. **查找 VMA（Virtual Memory Area）**: 函数首先通过 `find_vma` 函数查找包含触发页错误的虚拟地址的 VMA。如果没有找到相应的 VMA，函数会返回错误。
2. **设置权限**: 函数根据 VMA 的标志设置页表项的权限。如果 VMA 允许写入，页表项将被标记为可读和可写。
3. **分配和映射页面**:
   - 如果虚拟地址尚未映射到物理内存（即页表项为空），函数会尝试分配一个新的物理页面，并更新页表以包含新的映射。
   - 如果虚拟地址已映射到物理内存，但页面当前不在内存中（可能已被换出），函数会尝试将页面换入，并更新页表。
4. **错误处理**: 如果在处理过程中出现错误（如没有足够的物理内存），函数会进行适当的错误处理，并返回一个错误代码。

我们补充的部分就是处理错误的时候，如果触发异常的虚拟地址已经在页表中有一个交换条目（swap entry），但是对应的物理页面当前不在内存中（可能被换出到磁盘），这段代码会被执行。

设计过程如下：

1. **检查交换初始化**:
   - 通过 `swap_init_ok` 变量检查交换是否已经初始化。如果没有初始化，函数会返回错误。
2. **页面换入**:
   - 调用 `swap_in(mm, addr, &page)` 函数。这个函数会根据页表中的交换条目找到磁盘上的页面，并将其内容加载到一个新分配的物理页面中。
   - 如果 `swap_in` 函数执行失败，函数会返回错误。
3. **插入新页面**:
   - 调用 `page_insert(mm->pgdir, page, addr, perm)` 函数。这个函数会在页表中设置新的物理页面和虚拟地址之间的映射关系。
   - 如果 `page_insert` 函数执行失败，函数会返回错误。
4. **设置页面为可交换**:
   - 调用 `swap_map_swappable(mm, addr, page, 1)` 函数。这个函数会标记页面为可交换，意味着在物理内存不足时，这个页面可以被换出到磁盘。
   - 如果 `swap_map_swappable` 函数执行失败，函数会返回错误。
5. **设置页面的虚拟地址**:
   - 最后，设置页面的虚拟地址属性 `page->pra_vaddr = addr`。这样，在将来如果需要换出页面，我们可以知道这个页面对应的虚拟地址。



##### 问题1:

页目录项（PDE）和页表项（PTE）在 ucore 实现页替换算法中有以下潜在用处：

- **访问位（Accessed Bit）和修改位（Dirty Bit）**：PDE 和 PTE 中通常会有表示页面是否被访问或修改的标志位。这些标志位可以用来实现某些页替换算法，例如 Clock 算法。当页面被访问或修改时，相应的标志位会被硬件自动设置，而页替换算法可以根据这些信息做出决策。

- **存在位（Present Bit）**：PDE 和 PTE 中的存在标志位可以表示相应的页或页表是否在物理内存中。如果一个页不在物理内存中（被换出），则可以清除此标志位，并在页表项中存储该页在磁盘上的位置信息。

- **权限位（Permission Bits）**：权限位（如读/写和用户/超级用户位）定义了对页面的访问权限。在进行页面替换时，这些信息可以帮助确定哪些页面可以被换出。

   



##### 问题2:

当ucore的缺页服务例程在执行过程中访问内存出现页访问异常时，硬件会执行以下步骤：

1. 保存当前的状态

   - 硬件会自动保存触发异常的当前状态，包括程序计数器、标志寄存器和其他相关寄存器的值。这样可以确保在异常处理完成后能够正确恢复到异常发生时的状态。
   - 在 [`trapentry.S`](https://github.com/VivianLiu0202/OS-ucore/blob/main/riscv64-ucore-labcodes/lab3/kern/trap/trapentry.S) 文件中，可以看到有一个 `SAVE_ALL` 宏，它保存了所有的寄存器状态。

2. 设置错误代码

   - 硬件会生成一个错误代码，该代码包含有关页访问异常的详细信息，例如引起异常的访问类型（读、写或执行）和引起异常的地址。
   - 在 [`trap.c`](https://github.com/VivianLiu0202/OS-ucore/blob/main/riscv64-ucore-labcodes/lab3/kern/trap/trap.c) 文件中的 `exception_handler` 函数处理各种异常，包括页错误。在这个函数中，根据 `tf->cause` 的值，可以确定是哪种类型的页错误（例如，加载、存储等）。

3. <硬件>跳转到异常处理程序

   - 硬件会将控制权转交给预先配置的页访问异常处理程序。这通常是通过修改程序计数器来实现的，使其指向异常处理程序的入口地址，也就是trap.c。

     ```c
     //kern/trap/trap.c
     void trap(struct trapframe *tf) {
         ...
         case IRQN_PAGE_FAULT:
             pgfault_handler(tf);
             break;
         ...
     }
     ```

4. <内核>执行异常处理程序

   - 异常处理程序（也称为中断服务例程）会执行，它会根据错误代码分析异常的原因，并采取相应的措施，例如加载缺失的页面或更改页表项的权限。

     ```c
     //kern/mm/swap.c
     int swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **pagep) {
         ...
     }
     
     //kern/mm/vmm.c
     int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
         ...
     }
     ```

5. <硬件>恢复状态并返回

   - 一旦异常处理程序完成，硬件会恢复之前保存的处理器状态，并将控制权返回给导致异常的指令的下一条指令，或者如果异常处理程序修改了程序计数器，则返回到一个新的地址。

     ```c
     //kern/trap/trap.c
     void trap(struct trapframe *tf) {
         ...
         if (tf->cause == IRQN_SYSCALL) {
             tf->epc += 4;
         }
         return;
     ```
     

##### 问题3:

`Page` 数据结构的全局变量数组中的每一项通常与物理页面相对应。而页目录项和页表项则是虚拟地址到物理地址的映射。`Page` 数据结构中的项通常会**包含与其对应的物理页面的管理和状态信息**。

- **对应关系**：每个 `Page` 结构通常会包含一个指向对应页表项的指针，或者包含足够的信息以便可以找到对应的页表项。这样，系统就可以根据 `Page` 结构快速找到和修改对应的页表项。
- **用途**：这种对应关系允许操作系统在管理物理内存时，可以方便地找到和修改虚拟地址到物理地址的映射，例如在页替换过程中。



### 练习4：补充完成Clock页替换算法（需要编程）

通过之前的练习，相信大家对FIFO的页面替换算法有了更深入的了解，现在请在我们给出的框架上，填写代码，实现 Clock页替换算法（mm/swap_clock.c）。 请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 比较Clock页替换算法和FIFO算法的不同。



##### clock算法的设计实现过程

时钟置换算法是FIFO页面置换算法的改进，也是LRU算法的简化。在时钟置换算法中，与每个页面关联的是一个“访问位”（

`Page`结构体中的`visited`属性），用于表示页面自上次检查以来是否被访问过。

其设计实现过程如下：

1. **初始化**:
   - 函数 `_clock_init_mm` 中初始化了双向链表 `pra_list_head`，该链表用于跟踪当前内存中的所有页面。
   - `curr_ptr` 初始化为指向 `pra_list_head` 的指针，表示当前页面置换的位置从链表头开始。
   - mm 结构的私有成员指针指向 `pra_list_head`，以方便后续的页面置换算法操作。
2. **映射可置换的页面**:
   - 在 `_clock_map_swappable` 函数中，当一个新页面被映射到内存时，该页面会被添加到 `pra_list_head` 链表的末尾，并将其 `visited` 标志设置为1，表示该页面已经被访问。
3. **选择置换的受害者**:
   - 在 `_clock_swap_out_victim` 函数中，算法遍历 `pra_list_head` 链表，从当前指针 `curr_ptr` 开始，查找第一个其 `visited` 标志为0的页面（即未被访问的页面）。
   - 如果找到这样的页面，该页面将从链表中删除，并选择为要被置换出去的页面。
   - 如果页面的 `visited` 标志为1，表示该页面最近被访问过，因此将 `visited` 标志重置为0，并继续搜索下一个页面。
   - 如果在整个链表中都没有找到 `visited` 为0的页面，那么算法会再次从链表的开头开始搜索。



##### 比较Clock页替换算法和FIFO算法的不同

1. **基本思想**：
   - **FIFO**：按照页面进入内存的时间顺序进行替换。先进入的页面会先被替换。
   - **Clock**：也称为二次机会算法。它维护一个循环队列（类似时钟的指针），并给每个页面一个访问位。当需要替换页面时，Clock算法检查当前指针所指的页面的访问位。如果为0，则替换该页面；如果为1，则清除该位并将指针移动到下一个页面。
2. **性能**：
   - **FIFO**：可能会导致“Belady's anomaly”（即物理内存增加时，页面错误率可能会增加）。
   - **Clock**：通常比FIFO性能更好，因为它考虑了页面的访问历史。被频繁访问的页面不太可能被快速替换。
3. **实现复杂性**：
   - **FIFO**：相对简单，只需维护一个队列即可。
   - **Clock**：需要维护一个循环队列并考虑访问位，实现稍微复杂些。
4. **对工作集的反应**：
   - **FIFO**：没有明确地考虑工作集（即一个进程在给定时间内频繁访问的页面集）。因此，一个进程的工作集中的页面可能被替换，导致不必要的页面错误。
   - **Clock**：通过检查和清除页面的访问位，更有可能保留工作集中的页面。
5. **页表需求**：
   - **FIFO**：不需要特殊的位在页表中。
   - **Clock**：需要一个访问位在每个页面的页表条目中。





### 练习5：阅读代码和实现手册，理解页表映射方式相关知识（思考题）

如果我们采用”一个大页“ 的页表映射方式，相比分级页表，有什么好处、优势，有什么坏处、风险？

##### 优势

1. **简化的地址转换**：对于一个大页，由于只需要一次查表操作，因此地址转换的过程相对简化。而分级页表则需要多次查表操作才能完成地址转换。
2. **减少的页表大小**：由于只使用一个大页来映射大部分的内存区域，因此所需的页表条目数量会减少，相应地，页表所占用的内存大小也会减少。
3. **减少TLB失效**：页大小增加意味着单个TLB条目能够映射更多的内存区域，这有可能降低TLB失效的次数。
4. **适用于大数据应用**：对于大数据或者高性能计算应用，它们经常需要访问大规模的连续内存空间，一个大页的策略更为高效。

##### 风险

1. **内存浪费**：大页的策略可能导致内存浪费，因为不是所有应用都能完全使用一个大页大小的内存。例如，如果一个应用只需要少量的内存，但是被分配了一个大页，那么大部分的内存资源都会被浪费。
2. **不适合小数据应用**：对于只需要少量内存的应用，使用大页可能会导致不必要的性能开销。
3. **内存碎片化**：随着时间的推移，可能会出现大量的未使用的大页内存，这会导致内存碎片化。
4. **页置换开销**：当需要进行页置换时，置换一个大页的开销远大于置换一个小页。
5. **限制了灵活性**：与分级页表相比，一个大页的策略限制了操作系统进行地址转换的灵活性。
6. **安全问题**：使用大页可能会影响到某些基于页面的内存保护机制，因此可能存在安全隐患。





# 三、本实验重要知识点

### 1、Belady's anomaly

Belady's anomaly，也称为Belady的异常，是指在某些页置换算法中，当增加可用的物理内存帧数量时，页面错误的次数却可能增加的现象。使用FIFO时可能会出现Belady的异常。在某些访问模式下，增加物理内存帧的数量可能会导致更多的页面错误，而不是减少。

在使用FIFO算法时可能会出现这个belady异常，比如下面一个简单的页面访问序列：`1, 2, 3, 4, 1, 2, 5, 1, 2, 3, 4, 5`。如果我们只有3个物理内存帧，那么在上述序列中会发生6次页面错误。但是，如果我们有4个帧，会发生8次页面错误！

这是因为在3帧的情况下，当我们访问页面5时，页面3和4已经被替换出去了。但是，在4帧的情况下，当我们访问页面5时，页面4还在内存中。这导致在后续的访问序列中，页面3和4都会导致页面错误。

这个异常显示了页替换策略的非直观性，并提醒我们，简单地增加资源（在这里是物理内存帧）并不总是提高性能。



### 2、页面置换与管理的逻辑

##### 为什么要进行页面置换？

因为发生了缺页异常，缺页异常是指CPU访问的虚拟地址时， MMU没有办法找到对应的物理地址映射关系，或者与该物理页的访问权不一致而发生的异常。

##### 为什么发生缺页异常？

操作系统给用户态的应用程序提供了一个虚拟的“大容量”内存空间，而实际的物理内存空间又没有那么大。所以操作系统就就“瞒着”应用程序，只把应用程序中“常用”的数据和代码放在物理内存中，而不常用的数据和代码放在了硬盘这样的存储介质上。如果应用程序访问的是“常用”的数据和代码，那么操作系统已经放置在内存中了，不会出现什么问题。但当应用程序访问它认为应该在内存中的的数据或代码时，如果这些数据或代码不在内存中，则根据上一小节的介绍，会产生页访问异常。

##### 哪些页面可以换出

只有映射到用户空间且被用户程序直接访问的页面才能被交换，而被内核直接使用的内核空间的页面不能被换出

##### 具体如何换出？

- 先进先出(First In First Out, FIFO)页替换算法：该算法总是淘汰最先进入内存的页，即选择在内存中驻留时间最久的页予以淘汰。只需把一个应用程序在执行过程中已调入内存的页按先后次序链接成一个队列，队列头指向内存中驻留时间最久的页，队列尾指向最近被调入内存的页。这样需要淘汰页时，从队列头很容易查找到需要淘汰的页。FIFO 算法只是在应用程序按线性顺序访问地址空间时效果才好，否则效率不高。因为那些常被访问的页，往往在内存中也停留得最久，结果它们因变“老”而不得不被置换出去。FIFO 算法的另一个缺点是，它有一种异常现象（Belady 现象），即在增加放置页的物理页帧的情况下，反而使页访问异常次数增多。
- 最久未使用(least recently used, LRU)算法：利用局部性，通过过去的访问情况预测未来的访问情况，我们可以认为最近还被访问过的页面将来被访问的可能性大，而很久没访问过的页面将来不太可能被访问。于是我们比较当前内存里的页面最近一次被访问的时间，把上一次访问时间离现在最久的页面置换出去。
- 时钟（Clock）页替换算法：是 LRU 算法的一种近似实现。时钟页替换算法把各个页面组织成环形链表的形式，类似于一个钟的表面。然后把一个指针（简称当前指针）指向最老的那个页面，即最先进来的那个页面。另外，时钟算法需要在页表项（PTE）中设置了一位访问位来表示此页表项对应的页当前是否被访问过。当该页被访问时，CPU 中的 MMU 硬件将把访问位置“1”。当操作系统需要淘汰页时，对当前指针指向的页所对应的页表项进行查询，如果访问位为“0”，则淘汰该页，如果该页被写过，则还要把它换出到硬盘上；如果访问位为“1”，则将该页表项的此位置“0”，继续访问下一个页。该算法近似地体现了 LRU 的思想，且易于实现，开销少，需要硬件支持来设置访问位。时钟页替换算法在本质上与 FIFO 算法是类似的，不同之处是在时钟页替换算法中跳过了访问位为 1 的页。
- 改进的时钟（Enhanced Clock）页替换算法：在时钟置换算法中，淘汰一个页面时只考虑了页面是否被访问过，但在实际情况中，还应考虑被淘汰的页面是否被修改过。因为淘汰修改过的页面还需要写回硬盘，使得其置换代价大于未修改过的页面，所以优先淘汰没有修改的页，减少磁盘操作次数。改进的时钟置换算法除了考虑页面的访问情况，还需考虑页面的修改情况。即该算法不但希望淘汰的页面是最近未使用的页，而且还希望被淘汰的页是在主存驻留期间其页面内容未被修改过的。这需要为每一页的对应页表项内容中增加一位引用位和一位修改位。当该页被访问时，CPU 中的 MMU 硬件将把访问位置“1”。当该页被“写”时，CPU 中的 MMU 硬件将把修改位置“1”。这样这两位就存在四种可能的组合情况：（0，0）表示最近未被引用也未被修改，首先选择此页淘汰；（0，1）最近未被使用，但被修改，其次选择；（1，0）最近使用而未修改，再次选择；（1，1）最近使用且修改，最后选择。该算法与时钟算法相比，可进一步减少磁盘的 I/O 操作次数，但为了查找到一个尽可能适合淘汰的页面，可能需要经过多次扫描，增加了算法本身的执行开销。



# 附录

整个lab3项目的代码执行流图、函数调用流图、头文件引用流图链接 [`html`](https://github.com/VivianLiu0202/OS-ucore/blob/main/riscv64-ucore-labcodes/lab3/html)(随变打开一个html文件就行)

> 使用的是doxygen + graphviz工具生成
