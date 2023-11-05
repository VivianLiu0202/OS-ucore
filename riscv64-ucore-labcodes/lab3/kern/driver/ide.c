#include <assert.h>
#include <defs.h>
#include <fs.h>
#include <ide.h>
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}

#define MAX_IDE 2
#define MAX_DISK_NSECS 56 // 56个扇区，每个扇区的大小为512字节
static char ide[MAX_DISK_NSECS * SECTSIZE];

// 检查指定的IDE硬盘设备是否可用，比较硬盘编号ideno和MAX_IDE的大小关系即可
bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }

// 获取指定IDE硬盘设备的代销，直接返回IDE硬盘的扇区数 也就是56个扇区
size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }


//定义 IDE 硬盘的读写函数，包括 ide_read_secs 和 ide_write_secs 两个函数。
/**
 * ide_read_secs 函数用于从 IDE 硬盘中读取指定扇区的数据。
 * 首先计算出目标扇区在 ide 数组中的偏移量 iobase
 * 然后调用 memcpy 函数将 ide 数组中的数据复制到目标缓冲区 dst 中
 */
int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs)
{
    // ideno: 假设挂载了多块磁盘，选择哪一块磁盘 这里我们其实只有一块“磁盘”，这个参数就没用到
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    // memcpy函数的参数：目标缓冲区、源缓冲区、复制的字节数
    return 0;
}

/**
 * ide_write_secs 函数用于向 IDE 硬盘中写入指定扇区的数据。
 * 在函数中，首先计算出目标扇区在 ide 数组中的偏移量 iobase
 * 然后调用 memcpy 函数将源缓冲区 src 中的数据复制到 ide 数组中
 */
int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs)
{
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
    return 0;
}

/**
 * 我们这里所谓的“硬盘IO”，只是在内存里用memcpy把数据复制来复制去。
 * 同时为了逼真地模仿磁盘，我们只允许以磁盘扇区为数据传输的基本单位
 * 也就是一次传输的数据必须是512字节的倍数，并且必须对齐
 */
