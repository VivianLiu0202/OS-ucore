#include <defs.h>
#include <wait.h>
#include <atomic.h>
#include <kmalloc.h>
#include <sem.h>
#include <proc.h>
#include <sync.h>
#include <assert.h>


/**
 * sem_init 函数用于初始化一个信号量，将其值设置为 value，等待队列清空。
*/
void
sem_init(semaphore_t *sem, int value) {
    sem->value = value;
    wait_queue_init(&(sem->wait_queue));
}

/**
 * __up 函数是 up 函数的实现
 * 首先禁止中断，然后检查等待队列中是否有进程在等待资源，如果没有则将信号量的值加 1
 * 否则唤醒等待队列中的一个进程，并将其从等待队列中删除。
*/
static __noinline void __up(semaphore_t *sem, uint32_t wait_state) {
    bool intr_flag;
    local_intr_save(intr_flag); //禁止中断
    {
        wait_t *wait;
        if ((wait = wait_queue_first(&(sem->wait_queue))) == NULL) {
            sem->value ++;
        }
        else {
            assert(wait->proc->wait_state == wait_state);
            wakeup_wait(&(sem->wait_queue), wait, wait_state, 1);
        }
    }
    local_intr_restore(intr_flag);
}

/**
 * __down 函数是 down 函数的实现
 * 它首先禁止中断，然后检查当前信号量的值是否大于 0，如果是则将其值减 1，并返回 0
 * 否则将当前进程加入等待队列，并进入睡眠状态，直到有资源可用时被唤醒。
 * 进程被唤醒时，它会从等待队列中删除，并返回唤醒标志。
*/
static __noinline uint32_t __down(semaphore_t *sem, uint32_t wait_state) {
    bool intr_flag;
    local_intr_save(intr_flag); //禁止终端，保存状态
    if (sem->value > 0) {//检查信号量是否大于0
        sem->value --;
        local_intr_restore(intr_flag);
        return 0;
    }
    wait_t __wait, *wait = &__wait;//将当前的进程加入等待队列
    wait_current_set(&(sem->wait_queue), wait, wait_state);
    local_intr_restore(intr_flag);

    schedule();//将当前进程从运行队列中移除，并进入睡眠状态，直到有资源可用时被唤醒。

    local_intr_save(intr_flag);
    //当进程被唤醒的时候，将当前进程从信号量的等待队列中删除
    wait_current_del(&(sem->wait_queue), wait);
    local_intr_restore(intr_flag);

    //如果等待结构体的唤醒标志不等于 wait_state，则返回唤醒标志；否则返回 0。
    if (wait->wakeup_flags != wait_state) {
        return wait->wakeup_flags;
    }
    return 0;
}

/**
 * up 函数用于释放一个资源，将信号量的值加 1，并唤醒等待队列中的一个进程。
*/
void
up(semaphore_t *sem) {
    __up(sem, WT_KSEM);
}

/**
 * down 函数用于获取一个资源，如果当前信号量的值大于 0，则将其值减 1，并返回；
 * 否则将当前进程加入等待队列，并进入睡眠状态，直到有资源可用时被唤醒。
*/
void
down(semaphore_t *sem) {
    uint32_t flags = __down(sem, WT_KSEM);
    assert(flags == 0);
}

/**
 * try_down 函数用于尝试获取一个资源
 * 如果当前信号量的值大于 0，则将其值减 1，并返回 true；否则返回 false。
*/
bool
try_down(semaphore_t *sem) {
    bool intr_flag, ret = 0;
    local_intr_save(intr_flag);
    if (sem->value > 0) {
        sem->value --, ret = 1;
    }
    local_intr_restore(intr_flag);
    return ret;
}

