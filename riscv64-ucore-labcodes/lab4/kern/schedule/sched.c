#include <list.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    proc->state = PROC_RUNNABLE;
}

//uCore在实验四中只实现了一个最简单的FIFO调度器，其核心就是schedule函数。
void
schedule(void) {
    bool intr_flag; //定义中断变量
    list_entry_t *le, *last; //当前list，下一list
    struct proc_struct *next = NULL; //下一进程
    //关闭中断
    local_intr_save(intr_flag);
    {
        //设置当前内核线程current->need_resched为0
        current->need_resched = 0;
        //在proc_list队列中查找下一个处于“就绪”态的线程或进程next；
        //last是否是idle进程(第一个创建的进程),如果是，则从表头开始搜索  否则获取下一链表
        last = (current == idleproc) ? &proc_list : &(current->list_link);
        le = last;
        //循环找到可调度的进程
        do {
            if ((le = list_next(le)) != &proc_list) {
               //获取下一进程
                next = le2proc(le, list_link);
                //找到一个可以调度的进程，break
                //只能找到一个处于“就绪”态的initproc内核线程
                if (next->state == PROC_RUNNABLE) {
                    break;
                }
            }
        } while (le != last);
        //如果没有找到可调度的进程
        if (next == NULL || next->state != PROC_RUNNABLE) {
            next = idleproc;
        }
        next->runs ++; //运行次数加一
        //找到这样的进程后，就调用proc_run函数，保存当前进程current的执行现场（进程上下文），恢复新进程的执行现场，完成进程切换。
        if (next != current) {
            proc_run(next);
        }
    }
    //恢复中断
    local_intr_restore(intr_flag);
}

