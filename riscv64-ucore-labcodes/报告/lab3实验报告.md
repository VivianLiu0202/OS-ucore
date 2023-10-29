<h1><center>lab3实验报告</center></h1>
<h5><center>组员：杜鑫 胡博程 刘心源</center></h5>

# 一、基本练习

###  练习1：理解基于FIFO的页面替换算法（思考题）

描述FIFO页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？（为了方便同学们完成练习，所以实际上我们的项目代码和实验指导的还是略有不同，例如我们将FIFO页面置换算法头文件的大部分代码放在了`kern/mm/swap_fifo.c`文件中，这点请同学们注意）

- 至少正确指出10个不同的函数分别做了什么？如果少于10个将酌情给分。我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响,删去后会导致输出结果不同的函数（例如assert）而不是cprintf这样的函数。如果你选择的函数不能完整地体现”从换入到换出“的过程，比如10个函数都是页面换入的时候调用的，或者解释功能的时候只解释了这10个函数在页面换入时的功能，那么也会扣除一定的分数

首先理解代码的执行流

init--->swap_init--->check_swap--->check_content_access--->sm->check_swap()--->发生缺页异常--->trap()--->exception_handler--->pgfault_handler--->do_pgfault--->swap_in、page_insert、swap_map_swappable



swap_in->alloc_page--->alloc_pages--->swap_out--->sm->swap_out_victim

page_insert--->tlb_validate

--->alloc_pages



数据结构

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

vmm_init--->check_vmm--->check_vma_struct && check_pgfault

### 练习2：深入理解不同分页模式的工作原理（思考题

get_pte()函数（位于`kern/mm/pmm.c`）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。

- get_pte()函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。
- 目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？

### 练习3：给未被映射的地址映射上物理页（需要编程

补充完成do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限 的时候需要参考页面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制 结构所指定的页表，而不是内核的页表。 请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。
- 如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？
- 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

### 练习4：补充完成Clock页替换算法（需要编程）

通过之前的练习，相信大家对FIFO的页面替换算法有了更深入的了解，现在请在我们给出的框架上，填写代码，实现 Clock页替换算法（mm/swap_clock.c）。 请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 比较Clock页替换算法和FIFO算法的不同。

### 练习5：阅读代码和实现手册，理解页表映射方式相关知识（思考题）

如果我们采用”一个大页“ 的页表映射方式，相比分级页表，有什么好处、优势，有什么坏处、风险？



# 二、扩展练习

### 扩展练习 Challenge：实现不考虑实现开销和效率的LRU页替换算法（需要编程）





# 三、本实验重要知识点


