#ifndef __KERN_SYNC_SEM_H__
#define __KERN_SYNC_SEM_H__

#include <defs.h>
#include <atomic.h>
#include <wait.h>

/**
 * 信号量是一种用于进程间同步和互斥的机制，它包含一个整数值和一个等待队列。
 * 整数值表示当前可用的资源数量，等待队列用于存储等待该资源的进程。
*/
typedef struct { //信号量
    int value; //当前可用的资源数量
    wait_queue_t wait_queue; //等待队列
} semaphore_t;

void sem_init(semaphore_t *sem, int value);
void up(semaphore_t *sem); 
void down(semaphore_t *sem);
bool try_down(semaphore_t *sem);

#endif /* !__KERN_SYNC_SEM_H__ */

