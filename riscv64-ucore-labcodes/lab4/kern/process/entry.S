.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1 #放在了a0寄存器，并跳转到s0执行我们指定的函数
	jalr s0

	jal do_exit
