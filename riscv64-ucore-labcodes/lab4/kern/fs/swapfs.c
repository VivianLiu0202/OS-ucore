#include <swap.h>
#include <swapfs.h>
#include <mmu.h>
#include <fs.h>
#include <ide.h>
#include <pmm.h>
#include <assert.h>

//初始化交换分区文件系统
void
swapfs_init(void) {//做一些检查
    static_assert((PGSIZE % SECTSIZE) == 0);//检查每个页面的大小是否是扇区大小的整数倍;
    if (!ide_device_valid(SWAP_DEV_NO)) {//检查交换分区所在的磁盘是否存在
        panic("swap fs isn't available.\n");
    }
    //计算交换分区的最大偏移量
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE); //56/8=7
}

//从交换分区中读取指定的交换条目，病将其存储到指定的页面中
int swapfs_read(swap_entry_t entry, struct Page *page)
{   // 从磁盘交换分区读取页面
    // swap_entry_t（其实就是整数） entry：交换分区中的偏移量
    // struct Page *page：页面结构体指针
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int swapfs_write(swap_entry_t entry, struct Page *page)
{ // 将页面写入交换磁盘分区
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}
