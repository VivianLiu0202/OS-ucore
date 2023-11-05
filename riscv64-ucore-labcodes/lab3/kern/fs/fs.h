#ifndef __KERN_FS_FS_H__
#define __KERN_FS_FS_H__

#include <mmu.h>

#define SECTSIZE            512 //扇区大小 512B
#define PAGE_NSECT          (PGSIZE / SECTSIZE) //一页需要的磁盘扇区数，等于页面大小除以磁盘扇区大小 也就是4096/512=8

#define SWAP_DEV_NO         1  //交换分区所在的磁盘编号

#endif /* !__KERN_FS_FS_H__ */
