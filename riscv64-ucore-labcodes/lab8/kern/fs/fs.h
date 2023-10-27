#ifndef __KERN_FS_FS_H__
#define __KERN_FS_FS_H__

#include <defs.h>
#include <mmu.h>
#include <sem.h>
#include <atomic.h>

#define SECTSIZE            512
#define PAGE_NSECT          (PGSIZE / SECTSIZE) //一页需要的磁盘扇区数，等于页面大小除以磁盘扇区大小 也就是4096/512=8

#define SWAP_DEV_NO         1 //交换分区所在的磁盘编号
#define DISK0_DEV_NO        2 //磁盘0的编号
#define DISK1_DEV_NO        3 //磁盘1的编号

//文件系统的初始化与清理
void fs_init(void);
void fs_cleanup(void);

struct inode;
struct file;

/*
 * process's file related informaction
 * 表示进程打开的文件列表
 */
struct files_struct {
    struct inode *pwd;      // inode of present working directory 表示当前进程的工作目录
    struct file *fd_array;  // opened files array 指向file结构体数组的指针，表示进程打开的文件列表
    int files_count;        // the number of opened files 记录进程打开的文件数量
    semaphore_t files_sem;  // lock protect sem 保护进程打开的文件列表的信号量
};

#define FILES_STRUCT_BUFSIZE                       (PGSIZE - sizeof(struct files_struct))
#define FILES_STRUCT_NENTRY                        (FILES_STRUCT_BUFSIZE / sizeof(struct file))

void lock_files(struct files_struct *filesp);
void unlock_files(struct files_struct *filesp);

struct files_struct *files_create(void);
void files_destroy(struct files_struct *filesp);
void files_closeall(struct files_struct *filesp);
int dup_files(struct files_struct *to, struct files_struct *from);

static inline int
files_count(struct files_struct *filesp) {
    return filesp->files_count;
}

static inline int
files_count_inc(struct files_struct *filesp) {
    filesp->files_count += 1;
    return filesp->files_count;
}

static inline int
files_count_dec(struct files_struct *filesp) {
    filesp->files_count -= 1;
    return filesp->files_count;
}

#endif /* !__KERN_FS_FS_H__ */

