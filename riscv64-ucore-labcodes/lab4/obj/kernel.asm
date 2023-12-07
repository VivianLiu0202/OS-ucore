
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020a2b7          	lui	t0,0xc020a
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c020a137          	lui	sp,0xc020a

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);

int kern_init(void)
{
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000b517          	auipc	a0,0xb
ffffffffc020003a:	02a50513          	addi	a0,a0,42 # ffffffffc020b060 <edata>
ffffffffc020003e:	00016617          	auipc	a2,0x16
ffffffffc0200042:	5c260613          	addi	a2,a2,1474 # ffffffffc0216600 <end>
{
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
{
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	693040ef          	jal	ra,ffffffffc0204ee0 <memset>

    cons_init(); // init the console
ffffffffc0200052:	4b4000ef          	jal	ra,ffffffffc0200506 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00005597          	auipc	a1,0x5
ffffffffc020005a:	eea58593          	addi	a1,a1,-278 # ffffffffc0204f40 <etext+0x6>
ffffffffc020005e:	00005517          	auipc	a0,0x5
ffffffffc0200062:	f0250513          	addi	a0,a0,-254 # ffffffffc0204f60 <etext+0x26>
ffffffffc0200066:	128000ef          	jal	ra,ffffffffc020018e <cprintf>

    print_kerninfo();
ffffffffc020006a:	16c000ef          	jal	ra,ffffffffc02001d6 <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc020006e:	7c9010ef          	jal	ra,ffffffffc0202036 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc0200072:	56c000ef          	jal	ra,ffffffffc02005de <pic_init>
    // 加入多级页表的接口和测试
    idt_init(); // init interrupt descriptor table
ffffffffc0200076:	5dc000ef          	jal	ra,ffffffffc0200652 <idt_init>

    vmm_init();  // init virtual memory management 初始化虚拟内存管理
ffffffffc020007a:	1c1030ef          	jal	ra,ffffffffc0203a3a <vmm_init>
    proc_init(); // init process table
ffffffffc020007e:	66e040ef          	jal	ra,ffffffffc02046ec <proc_init>

    ide_init();  // init ide devices 初始化“硬盘”
ffffffffc0200082:	4f8000ef          	jal	ra,ffffffffc020057a <ide_init>
    swap_init(); // init swap 初始化页面置换机制并进行测试
ffffffffc0200086:	2d3020ef          	jal	ra,ffffffffc0202b58 <swap_init>

    clock_init();  // init clock interrupt
ffffffffc020008a:	426000ef          	jal	ra,ffffffffc02004b0 <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020008e:	544000ef          	jal	ra,ffffffffc02005d2 <intr_enable>

    cpu_idle(); // run idle process
ffffffffc0200092:	04f040ef          	jal	ra,ffffffffc02048e0 <cpu_idle>

ffffffffc0200096 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200096:	715d                	addi	sp,sp,-80
ffffffffc0200098:	e486                	sd	ra,72(sp)
ffffffffc020009a:	e0a2                	sd	s0,64(sp)
ffffffffc020009c:	fc26                	sd	s1,56(sp)
ffffffffc020009e:	f84a                	sd	s2,48(sp)
ffffffffc02000a0:	f44e                	sd	s3,40(sp)
ffffffffc02000a2:	f052                	sd	s4,32(sp)
ffffffffc02000a4:	ec56                	sd	s5,24(sp)
ffffffffc02000a6:	e85a                	sd	s6,16(sp)
ffffffffc02000a8:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02000aa:	c901                	beqz	a0,ffffffffc02000ba <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02000ac:	85aa                	mv	a1,a0
ffffffffc02000ae:	00005517          	auipc	a0,0x5
ffffffffc02000b2:	eba50513          	addi	a0,a0,-326 # ffffffffc0204f68 <etext+0x2e>
ffffffffc02000b6:	0d8000ef          	jal	ra,ffffffffc020018e <cprintf>
readline(const char *prompt) {
ffffffffc02000ba:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000bc:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000be:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000c0:	4aa9                	li	s5,10
ffffffffc02000c2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000c4:	0000bb97          	auipc	s7,0xb
ffffffffc02000c8:	f9cb8b93          	addi	s7,s7,-100 # ffffffffc020b060 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000cc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d0:	0f6000ef          	jal	ra,ffffffffc02001c6 <getchar>
ffffffffc02000d4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000d6:	00054b63          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	00a95b63          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc02000de:	029a5463          	ble	s1,s4,ffffffffc0200106 <readline+0x70>
        c = getchar();
ffffffffc02000e2:	0e4000ef          	jal	ra,ffffffffc02001c6 <getchar>
ffffffffc02000e6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000e8:	fe0559e3          	bgez	a0,ffffffffc02000da <readline+0x44>
            return NULL;
ffffffffc02000ec:	4501                	li	a0,0
ffffffffc02000ee:	a099                	j	ffffffffc0200134 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02000f0:	03341463          	bne	s0,s3,ffffffffc0200118 <readline+0x82>
ffffffffc02000f4:	e8b9                	bnez	s1,ffffffffc020014a <readline+0xb4>
        c = getchar();
ffffffffc02000f6:	0d0000ef          	jal	ra,ffffffffc02001c6 <getchar>
ffffffffc02000fa:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000fc:	fe0548e3          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200100:	fea958e3          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc0200104:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200106:	8522                	mv	a0,s0
ffffffffc0200108:	0ba000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i ++] = c;
ffffffffc020010c:	009b87b3          	add	a5,s7,s1
ffffffffc0200110:	00878023          	sb	s0,0(a5)
ffffffffc0200114:	2485                	addiw	s1,s1,1
ffffffffc0200116:	bf6d                	j	ffffffffc02000d0 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0200118:	01540463          	beq	s0,s5,ffffffffc0200120 <readline+0x8a>
ffffffffc020011c:	fb641ae3          	bne	s0,s6,ffffffffc02000d0 <readline+0x3a>
            cputchar(c);
ffffffffc0200120:	8522                	mv	a0,s0
ffffffffc0200122:	0a0000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i] = '\0';
ffffffffc0200126:	0000b517          	auipc	a0,0xb
ffffffffc020012a:	f3a50513          	addi	a0,a0,-198 # ffffffffc020b060 <edata>
ffffffffc020012e:	94aa                	add	s1,s1,a0
ffffffffc0200130:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200134:	60a6                	ld	ra,72(sp)
ffffffffc0200136:	6406                	ld	s0,64(sp)
ffffffffc0200138:	74e2                	ld	s1,56(sp)
ffffffffc020013a:	7942                	ld	s2,48(sp)
ffffffffc020013c:	79a2                	ld	s3,40(sp)
ffffffffc020013e:	7a02                	ld	s4,32(sp)
ffffffffc0200140:	6ae2                	ld	s5,24(sp)
ffffffffc0200142:	6b42                	ld	s6,16(sp)
ffffffffc0200144:	6ba2                	ld	s7,8(sp)
ffffffffc0200146:	6161                	addi	sp,sp,80
ffffffffc0200148:	8082                	ret
            cputchar(c);
ffffffffc020014a:	4521                	li	a0,8
ffffffffc020014c:	076000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            i --;
ffffffffc0200150:	34fd                	addiw	s1,s1,-1
ffffffffc0200152:	bfbd                	j	ffffffffc02000d0 <readline+0x3a>

ffffffffc0200154 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200154:	1141                	addi	sp,sp,-16
ffffffffc0200156:	e022                	sd	s0,0(sp)
ffffffffc0200158:	e406                	sd	ra,8(sp)
ffffffffc020015a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020015c:	3ac000ef          	jal	ra,ffffffffc0200508 <cons_putc>
    (*cnt) ++;
ffffffffc0200160:	401c                	lw	a5,0(s0)
}
ffffffffc0200162:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200164:	2785                	addiw	a5,a5,1
ffffffffc0200166:	c01c                	sw	a5,0(s0)
}
ffffffffc0200168:	6402                	ld	s0,0(sp)
ffffffffc020016a:	0141                	addi	sp,sp,16
ffffffffc020016c:	8082                	ret

ffffffffc020016e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020016e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200170:	86ae                	mv	a3,a1
ffffffffc0200172:	862a                	mv	a2,a0
ffffffffc0200174:	006c                	addi	a1,sp,12
ffffffffc0200176:	00000517          	auipc	a0,0x0
ffffffffc020017a:	fde50513          	addi	a0,a0,-34 # ffffffffc0200154 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc020017e:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200180:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200182:	135040ef          	jal	ra,ffffffffc0204ab6 <vprintfmt>
    return cnt;
}
ffffffffc0200186:	60e2                	ld	ra,24(sp)
ffffffffc0200188:	4532                	lw	a0,12(sp)
ffffffffc020018a:	6105                	addi	sp,sp,32
ffffffffc020018c:	8082                	ret

ffffffffc020018e <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020018e:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200190:	02810313          	addi	t1,sp,40 # ffffffffc020a028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200194:	f42e                	sd	a1,40(sp)
ffffffffc0200196:	f832                	sd	a2,48(sp)
ffffffffc0200198:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020019a:	862a                	mv	a2,a0
ffffffffc020019c:	004c                	addi	a1,sp,4
ffffffffc020019e:	00000517          	auipc	a0,0x0
ffffffffc02001a2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200154 <cputch>
ffffffffc02001a6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02001a8:	ec06                	sd	ra,24(sp)
ffffffffc02001aa:	e0ba                	sd	a4,64(sp)
ffffffffc02001ac:	e4be                	sd	a5,72(sp)
ffffffffc02001ae:	e8c2                	sd	a6,80(sp)
ffffffffc02001b0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001b2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001b4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001b6:	101040ef          	jal	ra,ffffffffc0204ab6 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ba:	60e2                	ld	ra,24(sp)
ffffffffc02001bc:	4512                	lw	a0,4(sp)
ffffffffc02001be:	6125                	addi	sp,sp,96
ffffffffc02001c0:	8082                	ret

ffffffffc02001c2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001c2:	3460006f          	j	ffffffffc0200508 <cons_putc>

ffffffffc02001c6 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001c6:	1141                	addi	sp,sp,-16
ffffffffc02001c8:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001ca:	374000ef          	jal	ra,ffffffffc020053e <cons_getc>
ffffffffc02001ce:	dd75                	beqz	a0,ffffffffc02001ca <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02001d0:	60a2                	ld	ra,8(sp)
ffffffffc02001d2:	0141                	addi	sp,sp,16
ffffffffc02001d4:	8082                	ret

ffffffffc02001d6 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02001d6:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001d8:	00005517          	auipc	a0,0x5
ffffffffc02001dc:	dc850513          	addi	a0,a0,-568 # ffffffffc0204fa0 <etext+0x66>
void print_kerninfo(void) {
ffffffffc02001e0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001e2:	fadff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02001e6:	00000597          	auipc	a1,0x0
ffffffffc02001ea:	e5058593          	addi	a1,a1,-432 # ffffffffc0200036 <kern_init>
ffffffffc02001ee:	00005517          	auipc	a0,0x5
ffffffffc02001f2:	dd250513          	addi	a0,a0,-558 # ffffffffc0204fc0 <etext+0x86>
ffffffffc02001f6:	f99ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02001fa:	00005597          	auipc	a1,0x5
ffffffffc02001fe:	d4058593          	addi	a1,a1,-704 # ffffffffc0204f3a <etext>
ffffffffc0200202:	00005517          	auipc	a0,0x5
ffffffffc0200206:	dde50513          	addi	a0,a0,-546 # ffffffffc0204fe0 <etext+0xa6>
ffffffffc020020a:	f85ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020020e:	0000b597          	auipc	a1,0xb
ffffffffc0200212:	e5258593          	addi	a1,a1,-430 # ffffffffc020b060 <edata>
ffffffffc0200216:	00005517          	auipc	a0,0x5
ffffffffc020021a:	dea50513          	addi	a0,a0,-534 # ffffffffc0205000 <etext+0xc6>
ffffffffc020021e:	f71ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200222:	00016597          	auipc	a1,0x16
ffffffffc0200226:	3de58593          	addi	a1,a1,990 # ffffffffc0216600 <end>
ffffffffc020022a:	00005517          	auipc	a0,0x5
ffffffffc020022e:	df650513          	addi	a0,a0,-522 # ffffffffc0205020 <etext+0xe6>
ffffffffc0200232:	f5dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200236:	00016597          	auipc	a1,0x16
ffffffffc020023a:	7c958593          	addi	a1,a1,1993 # ffffffffc02169ff <end+0x3ff>
ffffffffc020023e:	00000797          	auipc	a5,0x0
ffffffffc0200242:	df878793          	addi	a5,a5,-520 # ffffffffc0200036 <kern_init>
ffffffffc0200246:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020024a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020024e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200250:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200254:	95be                	add	a1,a1,a5
ffffffffc0200256:	85a9                	srai	a1,a1,0xa
ffffffffc0200258:	00005517          	auipc	a0,0x5
ffffffffc020025c:	de850513          	addi	a0,a0,-536 # ffffffffc0205040 <etext+0x106>
}
ffffffffc0200260:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200262:	f2dff06f          	j	ffffffffc020018e <cprintf>

ffffffffc0200266 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200266:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200268:	00005617          	auipc	a2,0x5
ffffffffc020026c:	d0860613          	addi	a2,a2,-760 # ffffffffc0204f70 <etext+0x36>
ffffffffc0200270:	04d00593          	li	a1,77
ffffffffc0200274:	00005517          	auipc	a0,0x5
ffffffffc0200278:	d1450513          	addi	a0,a0,-748 # ffffffffc0204f88 <etext+0x4e>
void print_stackframe(void) {
ffffffffc020027c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020027e:	1d2000ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0200282 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200282:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200284:	00005617          	auipc	a2,0x5
ffffffffc0200288:	ecc60613          	addi	a2,a2,-308 # ffffffffc0205150 <commands+0xe0>
ffffffffc020028c:	00005597          	auipc	a1,0x5
ffffffffc0200290:	ee458593          	addi	a1,a1,-284 # ffffffffc0205170 <commands+0x100>
ffffffffc0200294:	00005517          	auipc	a0,0x5
ffffffffc0200298:	ee450513          	addi	a0,a0,-284 # ffffffffc0205178 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020029c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020029e:	ef1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002a2:	00005617          	auipc	a2,0x5
ffffffffc02002a6:	ee660613          	addi	a2,a2,-282 # ffffffffc0205188 <commands+0x118>
ffffffffc02002aa:	00005597          	auipc	a1,0x5
ffffffffc02002ae:	f0658593          	addi	a1,a1,-250 # ffffffffc02051b0 <commands+0x140>
ffffffffc02002b2:	00005517          	auipc	a0,0x5
ffffffffc02002b6:	ec650513          	addi	a0,a0,-314 # ffffffffc0205178 <commands+0x108>
ffffffffc02002ba:	ed5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002be:	00005617          	auipc	a2,0x5
ffffffffc02002c2:	f0260613          	addi	a2,a2,-254 # ffffffffc02051c0 <commands+0x150>
ffffffffc02002c6:	00005597          	auipc	a1,0x5
ffffffffc02002ca:	f1a58593          	addi	a1,a1,-230 # ffffffffc02051e0 <commands+0x170>
ffffffffc02002ce:	00005517          	auipc	a0,0x5
ffffffffc02002d2:	eaa50513          	addi	a0,a0,-342 # ffffffffc0205178 <commands+0x108>
ffffffffc02002d6:	eb9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    }
    return 0;
}
ffffffffc02002da:	60a2                	ld	ra,8(sp)
ffffffffc02002dc:	4501                	li	a0,0
ffffffffc02002de:	0141                	addi	sp,sp,16
ffffffffc02002e0:	8082                	ret

ffffffffc02002e2 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e2:	1141                	addi	sp,sp,-16
ffffffffc02002e4:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002e6:	ef1ff0ef          	jal	ra,ffffffffc02001d6 <print_kerninfo>
    return 0;
}
ffffffffc02002ea:	60a2                	ld	ra,8(sp)
ffffffffc02002ec:	4501                	li	a0,0
ffffffffc02002ee:	0141                	addi	sp,sp,16
ffffffffc02002f0:	8082                	ret

ffffffffc02002f2 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002f2:	1141                	addi	sp,sp,-16
ffffffffc02002f4:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002f6:	f71ff0ef          	jal	ra,ffffffffc0200266 <print_stackframe>
    return 0;
}
ffffffffc02002fa:	60a2                	ld	ra,8(sp)
ffffffffc02002fc:	4501                	li	a0,0
ffffffffc02002fe:	0141                	addi	sp,sp,16
ffffffffc0200300:	8082                	ret

ffffffffc0200302 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200302:	7115                	addi	sp,sp,-224
ffffffffc0200304:	e962                	sd	s8,144(sp)
ffffffffc0200306:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200308:	00005517          	auipc	a0,0x5
ffffffffc020030c:	db050513          	addi	a0,a0,-592 # ffffffffc02050b8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200310:	ed86                	sd	ra,216(sp)
ffffffffc0200312:	e9a2                	sd	s0,208(sp)
ffffffffc0200314:	e5a6                	sd	s1,200(sp)
ffffffffc0200316:	e1ca                	sd	s2,192(sp)
ffffffffc0200318:	fd4e                	sd	s3,184(sp)
ffffffffc020031a:	f952                	sd	s4,176(sp)
ffffffffc020031c:	f556                	sd	s5,168(sp)
ffffffffc020031e:	f15a                	sd	s6,160(sp)
ffffffffc0200320:	ed5e                	sd	s7,152(sp)
ffffffffc0200322:	e566                	sd	s9,136(sp)
ffffffffc0200324:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200326:	e69ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020032a:	00005517          	auipc	a0,0x5
ffffffffc020032e:	db650513          	addi	a0,a0,-586 # ffffffffc02050e0 <commands+0x70>
ffffffffc0200332:	e5dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    if (tf != NULL) {
ffffffffc0200336:	000c0563          	beqz	s8,ffffffffc0200340 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020033a:	8562                	mv	a0,s8
ffffffffc020033c:	4fe000ef          	jal	ra,ffffffffc020083a <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200340:	4501                	li	a0,0
ffffffffc0200342:	4581                	li	a1,0
ffffffffc0200344:	4601                	li	a2,0
ffffffffc0200346:	48a1                	li	a7,8
ffffffffc0200348:	00000073          	ecall
ffffffffc020034c:	00005c97          	auipc	s9,0x5
ffffffffc0200350:	d24c8c93          	addi	s9,s9,-732 # ffffffffc0205070 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200354:	00005997          	auipc	s3,0x5
ffffffffc0200358:	db498993          	addi	s3,s3,-588 # ffffffffc0205108 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020035c:	00005917          	auipc	s2,0x5
ffffffffc0200360:	db490913          	addi	s2,s2,-588 # ffffffffc0205110 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200364:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200366:	00005b17          	auipc	s6,0x5
ffffffffc020036a:	db2b0b13          	addi	s6,s6,-590 # ffffffffc0205118 <commands+0xa8>
    if (argc == 0) {
ffffffffc020036e:	00005a97          	auipc	s5,0x5
ffffffffc0200372:	e02a8a93          	addi	s5,s5,-510 # ffffffffc0205170 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200376:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200378:	854e                	mv	a0,s3
ffffffffc020037a:	d1dff0ef          	jal	ra,ffffffffc0200096 <readline>
ffffffffc020037e:	842a                	mv	s0,a0
ffffffffc0200380:	dd65                	beqz	a0,ffffffffc0200378 <kmonitor+0x76>
ffffffffc0200382:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200386:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200388:	c999                	beqz	a1,ffffffffc020039e <kmonitor+0x9c>
ffffffffc020038a:	854a                	mv	a0,s2
ffffffffc020038c:	337040ef          	jal	ra,ffffffffc0204ec2 <strchr>
ffffffffc0200390:	c925                	beqz	a0,ffffffffc0200400 <kmonitor+0xfe>
            *buf ++ = '\0';
ffffffffc0200392:	00144583          	lbu	a1,1(s0)
ffffffffc0200396:	00040023          	sb	zero,0(s0)
ffffffffc020039a:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020039c:	f5fd                	bnez	a1,ffffffffc020038a <kmonitor+0x88>
    if (argc == 0) {
ffffffffc020039e:	dce9                	beqz	s1,ffffffffc0200378 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003a0:	6582                	ld	a1,0(sp)
ffffffffc02003a2:	00005d17          	auipc	s10,0x5
ffffffffc02003a6:	cced0d13          	addi	s10,s10,-818 # ffffffffc0205070 <commands>
    if (argc == 0) {
ffffffffc02003aa:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ac:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ae:	0d61                	addi	s10,s10,24
ffffffffc02003b0:	2e9040ef          	jal	ra,ffffffffc0204e98 <strcmp>
ffffffffc02003b4:	c919                	beqz	a0,ffffffffc02003ca <kmonitor+0xc8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003b6:	2405                	addiw	s0,s0,1
ffffffffc02003b8:	09740463          	beq	s0,s7,ffffffffc0200440 <kmonitor+0x13e>
ffffffffc02003bc:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003c0:	6582                	ld	a1,0(sp)
ffffffffc02003c2:	0d61                	addi	s10,s10,24
ffffffffc02003c4:	2d5040ef          	jal	ra,ffffffffc0204e98 <strcmp>
ffffffffc02003c8:	f57d                	bnez	a0,ffffffffc02003b6 <kmonitor+0xb4>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003ca:	00141793          	slli	a5,s0,0x1
ffffffffc02003ce:	97a2                	add	a5,a5,s0
ffffffffc02003d0:	078e                	slli	a5,a5,0x3
ffffffffc02003d2:	97e6                	add	a5,a5,s9
ffffffffc02003d4:	6b9c                	ld	a5,16(a5)
ffffffffc02003d6:	8662                	mv	a2,s8
ffffffffc02003d8:	002c                	addi	a1,sp,8
ffffffffc02003da:	fff4851b          	addiw	a0,s1,-1
ffffffffc02003de:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003e0:	f8055ce3          	bgez	a0,ffffffffc0200378 <kmonitor+0x76>
}
ffffffffc02003e4:	60ee                	ld	ra,216(sp)
ffffffffc02003e6:	644e                	ld	s0,208(sp)
ffffffffc02003e8:	64ae                	ld	s1,200(sp)
ffffffffc02003ea:	690e                	ld	s2,192(sp)
ffffffffc02003ec:	79ea                	ld	s3,184(sp)
ffffffffc02003ee:	7a4a                	ld	s4,176(sp)
ffffffffc02003f0:	7aaa                	ld	s5,168(sp)
ffffffffc02003f2:	7b0a                	ld	s6,160(sp)
ffffffffc02003f4:	6bea                	ld	s7,152(sp)
ffffffffc02003f6:	6c4a                	ld	s8,144(sp)
ffffffffc02003f8:	6caa                	ld	s9,136(sp)
ffffffffc02003fa:	6d0a                	ld	s10,128(sp)
ffffffffc02003fc:	612d                	addi	sp,sp,224
ffffffffc02003fe:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200400:	00044783          	lbu	a5,0(s0)
ffffffffc0200404:	dfc9                	beqz	a5,ffffffffc020039e <kmonitor+0x9c>
        if (argc == MAXARGS - 1) {
ffffffffc0200406:	03448863          	beq	s1,s4,ffffffffc0200436 <kmonitor+0x134>
        argv[argc ++] = buf;
ffffffffc020040a:	00349793          	slli	a5,s1,0x3
ffffffffc020040e:	0118                	addi	a4,sp,128
ffffffffc0200410:	97ba                	add	a5,a5,a4
ffffffffc0200412:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200416:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020041a:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020041c:	e591                	bnez	a1,ffffffffc0200428 <kmonitor+0x126>
ffffffffc020041e:	b749                	j	ffffffffc02003a0 <kmonitor+0x9e>
            buf ++;
ffffffffc0200420:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200422:	00044583          	lbu	a1,0(s0)
ffffffffc0200426:	ddad                	beqz	a1,ffffffffc02003a0 <kmonitor+0x9e>
ffffffffc0200428:	854a                	mv	a0,s2
ffffffffc020042a:	299040ef          	jal	ra,ffffffffc0204ec2 <strchr>
ffffffffc020042e:	d96d                	beqz	a0,ffffffffc0200420 <kmonitor+0x11e>
ffffffffc0200430:	00044583          	lbu	a1,0(s0)
ffffffffc0200434:	bf91                	j	ffffffffc0200388 <kmonitor+0x86>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200436:	45c1                	li	a1,16
ffffffffc0200438:	855a                	mv	a0,s6
ffffffffc020043a:	d55ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc020043e:	b7f1                	j	ffffffffc020040a <kmonitor+0x108>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200440:	6582                	ld	a1,0(sp)
ffffffffc0200442:	00005517          	auipc	a0,0x5
ffffffffc0200446:	cf650513          	addi	a0,a0,-778 # ffffffffc0205138 <commands+0xc8>
ffffffffc020044a:	d45ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
ffffffffc020044e:	b72d                	j	ffffffffc0200378 <kmonitor+0x76>

ffffffffc0200450 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200450:	00016317          	auipc	t1,0x16
ffffffffc0200454:	02030313          	addi	t1,t1,32 # ffffffffc0216470 <is_panic>
ffffffffc0200458:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020045c:	715d                	addi	sp,sp,-80
ffffffffc020045e:	ec06                	sd	ra,24(sp)
ffffffffc0200460:	e822                	sd	s0,16(sp)
ffffffffc0200462:	f436                	sd	a3,40(sp)
ffffffffc0200464:	f83a                	sd	a4,48(sp)
ffffffffc0200466:	fc3e                	sd	a5,56(sp)
ffffffffc0200468:	e0c2                	sd	a6,64(sp)
ffffffffc020046a:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020046c:	02031c63          	bnez	t1,ffffffffc02004a4 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200470:	4785                	li	a5,1
ffffffffc0200472:	8432                	mv	s0,a2
ffffffffc0200474:	00016717          	auipc	a4,0x16
ffffffffc0200478:	fef72e23          	sw	a5,-4(a4) # ffffffffc0216470 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020047c:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc020047e:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200480:	85aa                	mv	a1,a0
ffffffffc0200482:	00005517          	auipc	a0,0x5
ffffffffc0200486:	d6e50513          	addi	a0,a0,-658 # ffffffffc02051f0 <commands+0x180>
    va_start(ap, fmt);
ffffffffc020048a:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020048c:	d03ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200490:	65a2                	ld	a1,8(sp)
ffffffffc0200492:	8522                	mv	a0,s0
ffffffffc0200494:	cdbff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc0200498:	00006517          	auipc	a0,0x6
ffffffffc020049c:	ce050513          	addi	a0,a0,-800 # ffffffffc0206178 <default_pmm_manager+0x500>
ffffffffc02004a0:	cefff0ef          	jal	ra,ffffffffc020018e <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02004a4:	134000ef          	jal	ra,ffffffffc02005d8 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004a8:	4501                	li	a0,0
ffffffffc02004aa:	e59ff0ef          	jal	ra,ffffffffc0200302 <kmonitor>
ffffffffc02004ae:	bfed                	j	ffffffffc02004a8 <__panic+0x58>

ffffffffc02004b0 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004b0:	67e1                	lui	a5,0x18
ffffffffc02004b2:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02004b6:	00016717          	auipc	a4,0x16
ffffffffc02004ba:	fcf73123          	sd	a5,-62(a4) # ffffffffc0216478 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004be:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02004c2:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004c4:	953e                	add	a0,a0,a5
ffffffffc02004c6:	4601                	li	a2,0
ffffffffc02004c8:	4881                	li	a7,0
ffffffffc02004ca:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02004ce:	02000793          	li	a5,32
ffffffffc02004d2:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02004d6:	00005517          	auipc	a0,0x5
ffffffffc02004da:	d3a50513          	addi	a0,a0,-710 # ffffffffc0205210 <commands+0x1a0>
    ticks = 0;
ffffffffc02004de:	00016797          	auipc	a5,0x16
ffffffffc02004e2:	fe07b923          	sd	zero,-14(a5) # ffffffffc02164d0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02004e6:	ca9ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02004ea <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004ea:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004ee:	00016797          	auipc	a5,0x16
ffffffffc02004f2:	f8a78793          	addi	a5,a5,-118 # ffffffffc0216478 <timebase>
ffffffffc02004f6:	639c                	ld	a5,0(a5)
ffffffffc02004f8:	4581                	li	a1,0
ffffffffc02004fa:	4601                	li	a2,0
ffffffffc02004fc:	953e                	add	a0,a0,a5
ffffffffc02004fe:	4881                	li	a7,0
ffffffffc0200500:	00000073          	ecall
ffffffffc0200504:	8082                	ret

ffffffffc0200506 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200506:	8082                	ret

ffffffffc0200508 <cons_putc>:
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void)
{
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0200508:	100027f3          	csrr	a5,sstatus
ffffffffc020050c:	8b89                	andi	a5,a5,2
ffffffffc020050e:	0ff57513          	andi	a0,a0,255
ffffffffc0200512:	e799                	bnez	a5,ffffffffc0200520 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200514:	4581                	li	a1,0
ffffffffc0200516:	4601                	li	a2,0
ffffffffc0200518:	4885                	li	a7,1
ffffffffc020051a:	00000073          	ecall

// 123

static inline void __intr_restore(bool flag)
{
    if (flag)
ffffffffc020051e:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200520:	1101                	addi	sp,sp,-32
ffffffffc0200522:	ec06                	sd	ra,24(sp)
ffffffffc0200524:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200526:	0b2000ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc020052a:	6522                	ld	a0,8(sp)
ffffffffc020052c:	4581                	li	a1,0
ffffffffc020052e:	4601                	li	a2,0
ffffffffc0200530:	4885                	li	a7,1
ffffffffc0200532:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200536:	60e2                	ld	ra,24(sp)
ffffffffc0200538:	6105                	addi	sp,sp,32
    {
        intr_enable();
ffffffffc020053a:	0980006f          	j	ffffffffc02005d2 <intr_enable>

ffffffffc020053e <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020053e:	100027f3          	csrr	a5,sstatus
ffffffffc0200542:	8b89                	andi	a5,a5,2
ffffffffc0200544:	eb89                	bnez	a5,ffffffffc0200556 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200546:	4501                	li	a0,0
ffffffffc0200548:	4581                	li	a1,0
ffffffffc020054a:	4601                	li	a2,0
ffffffffc020054c:	4889                	li	a7,2
ffffffffc020054e:	00000073          	ecall
ffffffffc0200552:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200554:	8082                	ret
int cons_getc(void) {
ffffffffc0200556:	1101                	addi	sp,sp,-32
ffffffffc0200558:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020055a:	07e000ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc020055e:	4501                	li	a0,0
ffffffffc0200560:	4581                	li	a1,0
ffffffffc0200562:	4601                	li	a2,0
ffffffffc0200564:	4889                	li	a7,2
ffffffffc0200566:	00000073          	ecall
ffffffffc020056a:	2501                	sext.w	a0,a0
ffffffffc020056c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020056e:	064000ef          	jal	ra,ffffffffc02005d2 <intr_enable>
}
ffffffffc0200572:	60e2                	ld	ra,24(sp)
ffffffffc0200574:	6522                	ld	a0,8(sp)
ffffffffc0200576:	6105                	addi	sp,sp,32
ffffffffc0200578:	8082                	ret

ffffffffc020057a <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc020057a:	8082                	ret

ffffffffc020057c <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc020057c:	00253513          	sltiu	a0,a0,2
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc0200582:	03800513          	li	a0,56
ffffffffc0200586:	8082                	ret

ffffffffc0200588 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200588:	0000b797          	auipc	a5,0xb
ffffffffc020058c:	ed878793          	addi	a5,a5,-296 # ffffffffc020b460 <ide>
ffffffffc0200590:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200594:	1141                	addi	sp,sp,-16
ffffffffc0200596:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200598:	95be                	add	a1,a1,a5
ffffffffc020059a:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc020059e:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02005a0:	153040ef          	jal	ra,ffffffffc0204ef2 <memcpy>
    return 0;
}
ffffffffc02005a4:	60a2                	ld	ra,8(sp)
ffffffffc02005a6:	4501                	li	a0,0
ffffffffc02005a8:	0141                	addi	sp,sp,16
ffffffffc02005aa:	8082                	ret

ffffffffc02005ac <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02005ac:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005ae:	0095979b          	slliw	a5,a1,0x9
ffffffffc02005b2:	0000b517          	auipc	a0,0xb
ffffffffc02005b6:	eae50513          	addi	a0,a0,-338 # ffffffffc020b460 <ide>
                   size_t nsecs) {
ffffffffc02005ba:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005bc:	00969613          	slli	a2,a3,0x9
ffffffffc02005c0:	85ba                	mv	a1,a4
ffffffffc02005c2:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02005c4:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005c6:	12d040ef          	jal	ra,ffffffffc0204ef2 <memcpy>
    return 0;
}
ffffffffc02005ca:	60a2                	ld	ra,8(sp)
ffffffffc02005cc:	4501                	li	a0,0
ffffffffc02005ce:	0141                	addi	sp,sp,16
ffffffffc02005d0:	8082                	ret

ffffffffc02005d2 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005d2:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005d6:	8082                	ret

ffffffffc02005d8 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005d8:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005dc:	8082                	ret

ffffffffc02005de <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005de:	8082                	ret

ffffffffc02005e0 <pgfault_handler>:
//用于判断当前的异常是否发生在内核态。
bool trap_in_kernel(struct trapframe *tf)
{
    //使用 tf->status 获取当前 CPU 的状态寄存器的值，该寄存器包含了当前 CPU 的特权级别信息。
    //使用 SSTATUS_SPP 宏获取状态寄存器中的 SPP（Supervisor Previous Privilege）位，该位表示上一次的特权级别。
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005e0:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005e4:	1141                	addi	sp,sp,-16
ffffffffc02005e6:	e022                	sd	s0,0(sp)
ffffffffc02005e8:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005ea:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005ee:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005f0:	11053583          	ld	a1,272(a0)
ffffffffc02005f4:	05500613          	li	a2,85
ffffffffc02005f8:	c399                	beqz	a5,ffffffffc02005fe <pgfault_handler+0x1e>
ffffffffc02005fa:	04b00613          	li	a2,75
ffffffffc02005fe:	11843703          	ld	a4,280(s0)
ffffffffc0200602:	47bd                	li	a5,15
ffffffffc0200604:	05700693          	li	a3,87
ffffffffc0200608:	00f70463          	beq	a4,a5,ffffffffc0200610 <pgfault_handler+0x30>
ffffffffc020060c:	05200693          	li	a3,82
ffffffffc0200610:	00005517          	auipc	a0,0x5
ffffffffc0200614:	ef850513          	addi	a0,a0,-264 # ffffffffc0205508 <commands+0x498>
ffffffffc0200618:	b77ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    /**
     * check_mm_struct 变量是一个指向 mm_struct 结构体的指针，用于指向当前正在运行的进程的内存管理结构。
     * 如果该变量不为 NULL，则说明当前正在运行的是用户进程，需要调用 do_pgfault 函数处理页故障。
     * 否则，说明当前正在运行的是内核代码，不需要处理页故障。
    */
    if (check_mm_struct != NULL) {
ffffffffc020061c:	00016797          	auipc	a5,0x16
ffffffffc0200620:	fcc78793          	addi	a5,a5,-52 # ffffffffc02165e8 <check_mm_struct>
ffffffffc0200624:	6388                	ld	a0,0(a5)
ffffffffc0200626:	c911                	beqz	a0,ffffffffc020063a <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200628:	11043603          	ld	a2,272(s0)
ffffffffc020062c:	11842583          	lw	a1,280(s0)
    }
    //我们的trapFrame传递了badvaddr给do_pgfault()函数，而这实际上是stval这个寄存器的数值（在旧版的RISCV标准里叫做sbadvaddr)
    //这个寄存器存储一些关于异常的数据，对于PageFault它存储的是访问出错的虚拟地址。
    panic("unhandled page fault.\n");
}
ffffffffc0200630:	6402                	ld	s0,0(sp)
ffffffffc0200632:	60a2                	ld	ra,8(sp)
ffffffffc0200634:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200636:	14b0306f          	j	ffffffffc0203f80 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020063a:	00005617          	auipc	a2,0x5
ffffffffc020063e:	eee60613          	addi	a2,a2,-274 # ffffffffc0205528 <commands+0x4b8>
ffffffffc0200642:	07300593          	li	a1,115
ffffffffc0200646:	00005517          	auipc	a0,0x5
ffffffffc020064a:	efa50513          	addi	a0,a0,-262 # ffffffffc0205540 <commands+0x4d0>
ffffffffc020064e:	e03ff0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0200652 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200652:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200656:	00000797          	auipc	a5,0x0
ffffffffc020065a:	4ba78793          	addi	a5,a5,1210 # ffffffffc0200b10 <__alltraps>
ffffffffc020065e:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200662:	000407b7          	lui	a5,0x40
ffffffffc0200666:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020066a:	8082                	ret

ffffffffc020066c <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020066c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020066e:	1141                	addi	sp,sp,-16
ffffffffc0200670:	e022                	sd	s0,0(sp)
ffffffffc0200672:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200674:	00005517          	auipc	a0,0x5
ffffffffc0200678:	ee450513          	addi	a0,a0,-284 # ffffffffc0205558 <commands+0x4e8>
void print_regs(struct pushregs *gpr) {
ffffffffc020067c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067e:	b11ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200682:	640c                	ld	a1,8(s0)
ffffffffc0200684:	00005517          	auipc	a0,0x5
ffffffffc0200688:	eec50513          	addi	a0,a0,-276 # ffffffffc0205570 <commands+0x500>
ffffffffc020068c:	b03ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200690:	680c                	ld	a1,16(s0)
ffffffffc0200692:	00005517          	auipc	a0,0x5
ffffffffc0200696:	ef650513          	addi	a0,a0,-266 # ffffffffc0205588 <commands+0x518>
ffffffffc020069a:	af5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020069e:	6c0c                	ld	a1,24(s0)
ffffffffc02006a0:	00005517          	auipc	a0,0x5
ffffffffc02006a4:	f0050513          	addi	a0,a0,-256 # ffffffffc02055a0 <commands+0x530>
ffffffffc02006a8:	ae7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006ac:	700c                	ld	a1,32(s0)
ffffffffc02006ae:	00005517          	auipc	a0,0x5
ffffffffc02006b2:	f0a50513          	addi	a0,a0,-246 # ffffffffc02055b8 <commands+0x548>
ffffffffc02006b6:	ad9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006ba:	740c                	ld	a1,40(s0)
ffffffffc02006bc:	00005517          	auipc	a0,0x5
ffffffffc02006c0:	f1450513          	addi	a0,a0,-236 # ffffffffc02055d0 <commands+0x560>
ffffffffc02006c4:	acbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c8:	780c                	ld	a1,48(s0)
ffffffffc02006ca:	00005517          	auipc	a0,0x5
ffffffffc02006ce:	f1e50513          	addi	a0,a0,-226 # ffffffffc02055e8 <commands+0x578>
ffffffffc02006d2:	abdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006d6:	7c0c                	ld	a1,56(s0)
ffffffffc02006d8:	00005517          	auipc	a0,0x5
ffffffffc02006dc:	f2850513          	addi	a0,a0,-216 # ffffffffc0205600 <commands+0x590>
ffffffffc02006e0:	aafff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006e4:	602c                	ld	a1,64(s0)
ffffffffc02006e6:	00005517          	auipc	a0,0x5
ffffffffc02006ea:	f3250513          	addi	a0,a0,-206 # ffffffffc0205618 <commands+0x5a8>
ffffffffc02006ee:	aa1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006f2:	642c                	ld	a1,72(s0)
ffffffffc02006f4:	00005517          	auipc	a0,0x5
ffffffffc02006f8:	f3c50513          	addi	a0,a0,-196 # ffffffffc0205630 <commands+0x5c0>
ffffffffc02006fc:	a93ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200700:	682c                	ld	a1,80(s0)
ffffffffc0200702:	00005517          	auipc	a0,0x5
ffffffffc0200706:	f4650513          	addi	a0,a0,-186 # ffffffffc0205648 <commands+0x5d8>
ffffffffc020070a:	a85ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020070e:	6c2c                	ld	a1,88(s0)
ffffffffc0200710:	00005517          	auipc	a0,0x5
ffffffffc0200714:	f5050513          	addi	a0,a0,-176 # ffffffffc0205660 <commands+0x5f0>
ffffffffc0200718:	a77ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020071c:	702c                	ld	a1,96(s0)
ffffffffc020071e:	00005517          	auipc	a0,0x5
ffffffffc0200722:	f5a50513          	addi	a0,a0,-166 # ffffffffc0205678 <commands+0x608>
ffffffffc0200726:	a69ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020072a:	742c                	ld	a1,104(s0)
ffffffffc020072c:	00005517          	auipc	a0,0x5
ffffffffc0200730:	f6450513          	addi	a0,a0,-156 # ffffffffc0205690 <commands+0x620>
ffffffffc0200734:	a5bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200738:	782c                	ld	a1,112(s0)
ffffffffc020073a:	00005517          	auipc	a0,0x5
ffffffffc020073e:	f6e50513          	addi	a0,a0,-146 # ffffffffc02056a8 <commands+0x638>
ffffffffc0200742:	a4dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200746:	7c2c                	ld	a1,120(s0)
ffffffffc0200748:	00005517          	auipc	a0,0x5
ffffffffc020074c:	f7850513          	addi	a0,a0,-136 # ffffffffc02056c0 <commands+0x650>
ffffffffc0200750:	a3fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200754:	604c                	ld	a1,128(s0)
ffffffffc0200756:	00005517          	auipc	a0,0x5
ffffffffc020075a:	f8250513          	addi	a0,a0,-126 # ffffffffc02056d8 <commands+0x668>
ffffffffc020075e:	a31ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200762:	644c                	ld	a1,136(s0)
ffffffffc0200764:	00005517          	auipc	a0,0x5
ffffffffc0200768:	f8c50513          	addi	a0,a0,-116 # ffffffffc02056f0 <commands+0x680>
ffffffffc020076c:	a23ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200770:	684c                	ld	a1,144(s0)
ffffffffc0200772:	00005517          	auipc	a0,0x5
ffffffffc0200776:	f9650513          	addi	a0,a0,-106 # ffffffffc0205708 <commands+0x698>
ffffffffc020077a:	a15ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020077e:	6c4c                	ld	a1,152(s0)
ffffffffc0200780:	00005517          	auipc	a0,0x5
ffffffffc0200784:	fa050513          	addi	a0,a0,-96 # ffffffffc0205720 <commands+0x6b0>
ffffffffc0200788:	a07ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020078c:	704c                	ld	a1,160(s0)
ffffffffc020078e:	00005517          	auipc	a0,0x5
ffffffffc0200792:	faa50513          	addi	a0,a0,-86 # ffffffffc0205738 <commands+0x6c8>
ffffffffc0200796:	9f9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020079a:	744c                	ld	a1,168(s0)
ffffffffc020079c:	00005517          	auipc	a0,0x5
ffffffffc02007a0:	fb450513          	addi	a0,a0,-76 # ffffffffc0205750 <commands+0x6e0>
ffffffffc02007a4:	9ebff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a8:	784c                	ld	a1,176(s0)
ffffffffc02007aa:	00005517          	auipc	a0,0x5
ffffffffc02007ae:	fbe50513          	addi	a0,a0,-66 # ffffffffc0205768 <commands+0x6f8>
ffffffffc02007b2:	9ddff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007b6:	7c4c                	ld	a1,184(s0)
ffffffffc02007b8:	00005517          	auipc	a0,0x5
ffffffffc02007bc:	fc850513          	addi	a0,a0,-56 # ffffffffc0205780 <commands+0x710>
ffffffffc02007c0:	9cfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007c4:	606c                	ld	a1,192(s0)
ffffffffc02007c6:	00005517          	auipc	a0,0x5
ffffffffc02007ca:	fd250513          	addi	a0,a0,-46 # ffffffffc0205798 <commands+0x728>
ffffffffc02007ce:	9c1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007d2:	646c                	ld	a1,200(s0)
ffffffffc02007d4:	00005517          	auipc	a0,0x5
ffffffffc02007d8:	fdc50513          	addi	a0,a0,-36 # ffffffffc02057b0 <commands+0x740>
ffffffffc02007dc:	9b3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007e0:	686c                	ld	a1,208(s0)
ffffffffc02007e2:	00005517          	auipc	a0,0x5
ffffffffc02007e6:	fe650513          	addi	a0,a0,-26 # ffffffffc02057c8 <commands+0x758>
ffffffffc02007ea:	9a5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ee:	6c6c                	ld	a1,216(s0)
ffffffffc02007f0:	00005517          	auipc	a0,0x5
ffffffffc02007f4:	ff050513          	addi	a0,a0,-16 # ffffffffc02057e0 <commands+0x770>
ffffffffc02007f8:	997ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007fc:	706c                	ld	a1,224(s0)
ffffffffc02007fe:	00005517          	auipc	a0,0x5
ffffffffc0200802:	ffa50513          	addi	a0,a0,-6 # ffffffffc02057f8 <commands+0x788>
ffffffffc0200806:	989ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020080a:	746c                	ld	a1,232(s0)
ffffffffc020080c:	00005517          	auipc	a0,0x5
ffffffffc0200810:	00450513          	addi	a0,a0,4 # ffffffffc0205810 <commands+0x7a0>
ffffffffc0200814:	97bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200818:	786c                	ld	a1,240(s0)
ffffffffc020081a:	00005517          	auipc	a0,0x5
ffffffffc020081e:	00e50513          	addi	a0,a0,14 # ffffffffc0205828 <commands+0x7b8>
ffffffffc0200822:	96dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200826:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200828:	6402                	ld	s0,0(sp)
ffffffffc020082a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082c:	00005517          	auipc	a0,0x5
ffffffffc0200830:	01450513          	addi	a0,a0,20 # ffffffffc0205840 <commands+0x7d0>
}
ffffffffc0200834:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200836:	959ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020083a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020083a:	1141                	addi	sp,sp,-16
ffffffffc020083c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020083e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200840:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200842:	00005517          	auipc	a0,0x5
ffffffffc0200846:	01650513          	addi	a0,a0,22 # ffffffffc0205858 <commands+0x7e8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020084a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020084c:	943ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200850:	8522                	mv	a0,s0
ffffffffc0200852:	e1bff0ef          	jal	ra,ffffffffc020066c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200856:	10043583          	ld	a1,256(s0)
ffffffffc020085a:	00005517          	auipc	a0,0x5
ffffffffc020085e:	01650513          	addi	a0,a0,22 # ffffffffc0205870 <commands+0x800>
ffffffffc0200862:	92dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200866:	10843583          	ld	a1,264(s0)
ffffffffc020086a:	00005517          	auipc	a0,0x5
ffffffffc020086e:	01e50513          	addi	a0,a0,30 # ffffffffc0205888 <commands+0x818>
ffffffffc0200872:	91dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200876:	11043583          	ld	a1,272(s0)
ffffffffc020087a:	00005517          	auipc	a0,0x5
ffffffffc020087e:	02650513          	addi	a0,a0,38 # ffffffffc02058a0 <commands+0x830>
ffffffffc0200882:	90dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200886:	11843583          	ld	a1,280(s0)
}
ffffffffc020088a:	6402                	ld	s0,0(sp)
ffffffffc020088c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088e:	00005517          	auipc	a0,0x5
ffffffffc0200892:	02a50513          	addi	a0,a0,42 # ffffffffc02058b8 <commands+0x848>
}
ffffffffc0200896:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200898:	8f7ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020089c <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020089c:	11853783          	ld	a5,280(a0)
ffffffffc02008a0:	577d                	li	a4,-1
ffffffffc02008a2:	8305                	srli	a4,a4,0x1
ffffffffc02008a4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02008a6:	472d                	li	a4,11
ffffffffc02008a8:	06f76f63          	bltu	a4,a5,ffffffffc0200926 <interrupt_handler+0x8a>
ffffffffc02008ac:	00005717          	auipc	a4,0x5
ffffffffc02008b0:	98070713          	addi	a4,a4,-1664 # ffffffffc020522c <commands+0x1bc>
ffffffffc02008b4:	078a                	slli	a5,a5,0x2
ffffffffc02008b6:	97ba                	add	a5,a5,a4
ffffffffc02008b8:	439c                	lw	a5,0(a5)
ffffffffc02008ba:	97ba                	add	a5,a5,a4
ffffffffc02008bc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02008be:	00005517          	auipc	a0,0x5
ffffffffc02008c2:	bfa50513          	addi	a0,a0,-1030 # ffffffffc02054b8 <commands+0x448>
ffffffffc02008c6:	8c9ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008ca:	00005517          	auipc	a0,0x5
ffffffffc02008ce:	bce50513          	addi	a0,a0,-1074 # ffffffffc0205498 <commands+0x428>
ffffffffc02008d2:	8bdff06f          	j	ffffffffc020018e <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008d6:	00005517          	auipc	a0,0x5
ffffffffc02008da:	b8250513          	addi	a0,a0,-1150 # ffffffffc0205458 <commands+0x3e8>
ffffffffc02008de:	8b1ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008e2:	00005517          	auipc	a0,0x5
ffffffffc02008e6:	b9650513          	addi	a0,a0,-1130 # ffffffffc0205478 <commands+0x408>
ffffffffc02008ea:	8a5ff06f          	j	ffffffffc020018e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02008ee:	00005517          	auipc	a0,0x5
ffffffffc02008f2:	bfa50513          	addi	a0,a0,-1030 # ffffffffc02054e8 <commands+0x478>
ffffffffc02008f6:	899ff06f          	j	ffffffffc020018e <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008fa:	1141                	addi	sp,sp,-16
ffffffffc02008fc:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc02008fe:	bedff0ef          	jal	ra,ffffffffc02004ea <clock_set_next_event>
            ticks++;
ffffffffc0200902:	00016717          	auipc	a4,0x16
ffffffffc0200906:	bce70713          	addi	a4,a4,-1074 # ffffffffc02164d0 <ticks>
ffffffffc020090a:	631c                	ld	a5,0(a4)
            if (ticks == 100)
ffffffffc020090c:	06400693          	li	a3,100
            ticks++;
ffffffffc0200910:	0785                	addi	a5,a5,1
ffffffffc0200912:	00016617          	auipc	a2,0x16
ffffffffc0200916:	baf63f23          	sd	a5,-1090(a2) # ffffffffc02164d0 <ticks>
            if (ticks == 100)
ffffffffc020091a:	631c                	ld	a5,0(a4)
ffffffffc020091c:	00d78763          	beq	a5,a3,ffffffffc020092a <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200920:	60a2                	ld	ra,8(sp)
ffffffffc0200922:	0141                	addi	sp,sp,16
ffffffffc0200924:	8082                	ret
            print_trapframe(tf);
ffffffffc0200926:	f15ff06f          	j	ffffffffc020083a <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020092a:	06400593          	li	a1,100
ffffffffc020092e:	00005517          	auipc	a0,0x5
ffffffffc0200932:	baa50513          	addi	a0,a0,-1110 # ffffffffc02054d8 <commands+0x468>
                ticks = 0;
ffffffffc0200936:	00016797          	auipc	a5,0x16
ffffffffc020093a:	b807bd23          	sd	zero,-1126(a5) # ffffffffc02164d0 <ticks>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020093e:	851ff0ef          	jal	ra,ffffffffc020018e <cprintf>
                if (num == 10)
ffffffffc0200942:	00016797          	auipc	a5,0x16
ffffffffc0200946:	b3e78793          	addi	a5,a5,-1218 # ffffffffc0216480 <num>
ffffffffc020094a:	6394                	ld	a3,0(a5)
ffffffffc020094c:	4729                	li	a4,10
ffffffffc020094e:	00e69863          	bne	a3,a4,ffffffffc020095e <interrupt_handler+0xc2>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200952:	4501                	li	a0,0
ffffffffc0200954:	4581                	li	a1,0
ffffffffc0200956:	4601                	li	a2,0
ffffffffc0200958:	48a1                	li	a7,8
ffffffffc020095a:	00000073          	ecall
                num++;
ffffffffc020095e:	639c                	ld	a5,0(a5)
ffffffffc0200960:	0785                	addi	a5,a5,1
ffffffffc0200962:	00016717          	auipc	a4,0x16
ffffffffc0200966:	b0f73f23          	sd	a5,-1250(a4) # ffffffffc0216480 <num>
ffffffffc020096a:	bf5d                	j	ffffffffc0200920 <interrupt_handler+0x84>

ffffffffc020096c <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020096c:	11853783          	ld	a5,280(a0)
ffffffffc0200970:	473d                	li	a4,15
ffffffffc0200972:	16f76563          	bltu	a4,a5,ffffffffc0200adc <exception_handler+0x170>
ffffffffc0200976:	00005717          	auipc	a4,0x5
ffffffffc020097a:	8e670713          	addi	a4,a4,-1818 # ffffffffc020525c <commands+0x1ec>
ffffffffc020097e:	078a                	slli	a5,a5,0x2
ffffffffc0200980:	97ba                	add	a5,a5,a4
ffffffffc0200982:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200984:	1101                	addi	sp,sp,-32
ffffffffc0200986:	e822                	sd	s0,16(sp)
ffffffffc0200988:	ec06                	sd	ra,24(sp)
ffffffffc020098a:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc020098c:	97ba                	add	a5,a5,a4
ffffffffc020098e:	842a                	mv	s0,a0
ffffffffc0200990:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:  // 存储页面错误。当一个程序尝试将数据存储到一个它没有权限访问的地址时，这种异常被触发。
            cprintf("Store/AMO page fault\n");  // 存储/原子存储-修改-写入页面错误。
ffffffffc0200992:	00005517          	auipc	a0,0x5
ffffffffc0200996:	aae50513          	addi	a0,a0,-1362 # ffffffffc0205440 <commands+0x3d0>
ffffffffc020099a:	ff4ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020099e:	8522                	mv	a0,s0
ffffffffc02009a0:	c41ff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc02009a4:	84aa                	mv	s1,a0
ffffffffc02009a6:	12051d63          	bnez	a0,ffffffffc0200ae0 <exception_handler+0x174>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02009aa:	60e2                	ld	ra,24(sp)
ffffffffc02009ac:	6442                	ld	s0,16(sp)
ffffffffc02009ae:	64a2                	ld	s1,8(sp)
ffffffffc02009b0:	6105                	addi	sp,sp,32
ffffffffc02009b2:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02009b4:	00005517          	auipc	a0,0x5
ffffffffc02009b8:	8ec50513          	addi	a0,a0,-1812 # ffffffffc02052a0 <commands+0x230>
}
ffffffffc02009bc:	6442                	ld	s0,16(sp)
ffffffffc02009be:	60e2                	ld	ra,24(sp)
ffffffffc02009c0:	64a2                	ld	s1,8(sp)
ffffffffc02009c2:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02009c4:	fcaff06f          	j	ffffffffc020018e <cprintf>
ffffffffc02009c8:	00005517          	auipc	a0,0x5
ffffffffc02009cc:	8f850513          	addi	a0,a0,-1800 # ffffffffc02052c0 <commands+0x250>
ffffffffc02009d0:	b7f5                	j	ffffffffc02009bc <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02009d2:	00005517          	auipc	a0,0x5
ffffffffc02009d6:	90e50513          	addi	a0,a0,-1778 # ffffffffc02052e0 <commands+0x270>
ffffffffc02009da:	b7cd                	j	ffffffffc02009bc <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02009dc:	00005517          	auipc	a0,0x5
ffffffffc02009e0:	91c50513          	addi	a0,a0,-1764 # ffffffffc02052f8 <commands+0x288>
ffffffffc02009e4:	bfe1                	j	ffffffffc02009bc <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02009e6:	00005517          	auipc	a0,0x5
ffffffffc02009ea:	92250513          	addi	a0,a0,-1758 # ffffffffc0205308 <commands+0x298>
ffffffffc02009ee:	b7f9                	j	ffffffffc02009bc <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02009f0:	00005517          	auipc	a0,0x5
ffffffffc02009f4:	93850513          	addi	a0,a0,-1736 # ffffffffc0205328 <commands+0x2b8>
ffffffffc02009f8:	f96ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) { //do_pgfault()页面置换成功时返回0
ffffffffc02009fc:	8522                	mv	a0,s0
ffffffffc02009fe:	be3ff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc0200a02:	84aa                	mv	s1,a0
ffffffffc0200a04:	d15d                	beqz	a0,ffffffffc02009aa <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a06:	8522                	mv	a0,s0
ffffffffc0200a08:	e33ff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a0c:	86a6                	mv	a3,s1
ffffffffc0200a0e:	00005617          	auipc	a2,0x5
ffffffffc0200a12:	93260613          	addi	a2,a2,-1742 # ffffffffc0205340 <commands+0x2d0>
ffffffffc0200a16:	0d000593          	li	a1,208
ffffffffc0200a1a:	00005517          	auipc	a0,0x5
ffffffffc0200a1e:	b2650513          	addi	a0,a0,-1242 # ffffffffc0205540 <commands+0x4d0>
ffffffffc0200a22:	a2fff0ef          	jal	ra,ffffffffc0200450 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200a26:	00005517          	auipc	a0,0x5
ffffffffc0200a2a:	93a50513          	addi	a0,a0,-1734 # ffffffffc0205360 <commands+0x2f0>
ffffffffc0200a2e:	b779                	j	ffffffffc02009bc <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200a30:	00005517          	auipc	a0,0x5
ffffffffc0200a34:	94850513          	addi	a0,a0,-1720 # ffffffffc0205378 <commands+0x308>
ffffffffc0200a38:	f56ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a3c:	8522                	mv	a0,s0
ffffffffc0200a3e:	ba3ff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc0200a42:	84aa                	mv	s1,a0
ffffffffc0200a44:	d13d                	beqz	a0,ffffffffc02009aa <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a46:	8522                	mv	a0,s0
ffffffffc0200a48:	df3ff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a4c:	86a6                	mv	a3,s1
ffffffffc0200a4e:	00005617          	auipc	a2,0x5
ffffffffc0200a52:	8f260613          	addi	a2,a2,-1806 # ffffffffc0205340 <commands+0x2d0>
ffffffffc0200a56:	0da00593          	li	a1,218
ffffffffc0200a5a:	00005517          	auipc	a0,0x5
ffffffffc0200a5e:	ae650513          	addi	a0,a0,-1306 # ffffffffc0205540 <commands+0x4d0>
ffffffffc0200a62:	9efff0ef          	jal	ra,ffffffffc0200450 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a66:	00005517          	auipc	a0,0x5
ffffffffc0200a6a:	92a50513          	addi	a0,a0,-1750 # ffffffffc0205390 <commands+0x320>
ffffffffc0200a6e:	b7b9                	j	ffffffffc02009bc <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a70:	00005517          	auipc	a0,0x5
ffffffffc0200a74:	94050513          	addi	a0,a0,-1728 # ffffffffc02053b0 <commands+0x340>
ffffffffc0200a78:	b791                	j	ffffffffc02009bc <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a7a:	00005517          	auipc	a0,0x5
ffffffffc0200a7e:	95650513          	addi	a0,a0,-1706 # ffffffffc02053d0 <commands+0x360>
ffffffffc0200a82:	bf2d                	j	ffffffffc02009bc <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a84:	00005517          	auipc	a0,0x5
ffffffffc0200a88:	96c50513          	addi	a0,a0,-1684 # ffffffffc02053f0 <commands+0x380>
ffffffffc0200a8c:	bf05                	j	ffffffffc02009bc <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a8e:	00005517          	auipc	a0,0x5
ffffffffc0200a92:	98250513          	addi	a0,a0,-1662 # ffffffffc0205410 <commands+0x3a0>
ffffffffc0200a96:	b71d                	j	ffffffffc02009bc <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a98:	00005517          	auipc	a0,0x5
ffffffffc0200a9c:	99050513          	addi	a0,a0,-1648 # ffffffffc0205428 <commands+0x3b8>
ffffffffc0200aa0:	eeeff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200aa4:	8522                	mv	a0,s0
ffffffffc0200aa6:	b3bff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc0200aaa:	84aa                	mv	s1,a0
ffffffffc0200aac:	ee050fe3          	beqz	a0,ffffffffc02009aa <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200ab0:	8522                	mv	a0,s0
ffffffffc0200ab2:	d89ff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ab6:	86a6                	mv	a3,s1
ffffffffc0200ab8:	00005617          	auipc	a2,0x5
ffffffffc0200abc:	88860613          	addi	a2,a2,-1912 # ffffffffc0205340 <commands+0x2d0>
ffffffffc0200ac0:	0f000593          	li	a1,240
ffffffffc0200ac4:	00005517          	auipc	a0,0x5
ffffffffc0200ac8:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0205540 <commands+0x4d0>
ffffffffc0200acc:	985ff0ef          	jal	ra,ffffffffc0200450 <__panic>
}
ffffffffc0200ad0:	6442                	ld	s0,16(sp)
ffffffffc0200ad2:	60e2                	ld	ra,24(sp)
ffffffffc0200ad4:	64a2                	ld	s1,8(sp)
ffffffffc0200ad6:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200ad8:	d63ff06f          	j	ffffffffc020083a <print_trapframe>
ffffffffc0200adc:	d5fff06f          	j	ffffffffc020083a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200ae0:	8522                	mv	a0,s0
ffffffffc0200ae2:	d59ff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ae6:	86a6                	mv	a3,s1
ffffffffc0200ae8:	00005617          	auipc	a2,0x5
ffffffffc0200aec:	85860613          	addi	a2,a2,-1960 # ffffffffc0205340 <commands+0x2d0>
ffffffffc0200af0:	0f700593          	li	a1,247
ffffffffc0200af4:	00005517          	auipc	a0,0x5
ffffffffc0200af8:	a4c50513          	addi	a0,a0,-1460 # ffffffffc0205540 <commands+0x4d0>
ffffffffc0200afc:	955ff0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0200b00 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200b00:	11853783          	ld	a5,280(a0)
ffffffffc0200b04:	0007c463          	bltz	a5,ffffffffc0200b0c <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200b08:	e65ff06f          	j	ffffffffc020096c <exception_handler>
        interrupt_handler(tf);
ffffffffc0200b0c:	d91ff06f          	j	ffffffffc020089c <interrupt_handler>

ffffffffc0200b10 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200b10:	14011073          	csrw	sscratch,sp
ffffffffc0200b14:	712d                	addi	sp,sp,-288
ffffffffc0200b16:	e406                	sd	ra,8(sp)
ffffffffc0200b18:	ec0e                	sd	gp,24(sp)
ffffffffc0200b1a:	f012                	sd	tp,32(sp)
ffffffffc0200b1c:	f416                	sd	t0,40(sp)
ffffffffc0200b1e:	f81a                	sd	t1,48(sp)
ffffffffc0200b20:	fc1e                	sd	t2,56(sp)
ffffffffc0200b22:	e0a2                	sd	s0,64(sp)
ffffffffc0200b24:	e4a6                	sd	s1,72(sp)
ffffffffc0200b26:	e8aa                	sd	a0,80(sp)
ffffffffc0200b28:	ecae                	sd	a1,88(sp)
ffffffffc0200b2a:	f0b2                	sd	a2,96(sp)
ffffffffc0200b2c:	f4b6                	sd	a3,104(sp)
ffffffffc0200b2e:	f8ba                	sd	a4,112(sp)
ffffffffc0200b30:	fcbe                	sd	a5,120(sp)
ffffffffc0200b32:	e142                	sd	a6,128(sp)
ffffffffc0200b34:	e546                	sd	a7,136(sp)
ffffffffc0200b36:	e94a                	sd	s2,144(sp)
ffffffffc0200b38:	ed4e                	sd	s3,152(sp)
ffffffffc0200b3a:	f152                	sd	s4,160(sp)
ffffffffc0200b3c:	f556                	sd	s5,168(sp)
ffffffffc0200b3e:	f95a                	sd	s6,176(sp)
ffffffffc0200b40:	fd5e                	sd	s7,184(sp)
ffffffffc0200b42:	e1e2                	sd	s8,192(sp)
ffffffffc0200b44:	e5e6                	sd	s9,200(sp)
ffffffffc0200b46:	e9ea                	sd	s10,208(sp)
ffffffffc0200b48:	edee                	sd	s11,216(sp)
ffffffffc0200b4a:	f1f2                	sd	t3,224(sp)
ffffffffc0200b4c:	f5f6                	sd	t4,232(sp)
ffffffffc0200b4e:	f9fa                	sd	t5,240(sp)
ffffffffc0200b50:	fdfe                	sd	t6,248(sp)
ffffffffc0200b52:	14002473          	csrr	s0,sscratch
ffffffffc0200b56:	100024f3          	csrr	s1,sstatus
ffffffffc0200b5a:	14102973          	csrr	s2,sepc
ffffffffc0200b5e:	143029f3          	csrr	s3,stval
ffffffffc0200b62:	14202a73          	csrr	s4,scause
ffffffffc0200b66:	e822                	sd	s0,16(sp)
ffffffffc0200b68:	e226                	sd	s1,256(sp)
ffffffffc0200b6a:	e64a                	sd	s2,264(sp)
ffffffffc0200b6c:	ea4e                	sd	s3,272(sp)
ffffffffc0200b6e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b70:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b72:	f8fff0ef          	jal	ra,ffffffffc0200b00 <trap>

ffffffffc0200b76 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b76:	6492                	ld	s1,256(sp)
ffffffffc0200b78:	6932                	ld	s2,264(sp)
ffffffffc0200b7a:	10049073          	csrw	sstatus,s1
ffffffffc0200b7e:	14191073          	csrw	sepc,s2
ffffffffc0200b82:	60a2                	ld	ra,8(sp)
ffffffffc0200b84:	61e2                	ld	gp,24(sp)
ffffffffc0200b86:	7202                	ld	tp,32(sp)
ffffffffc0200b88:	72a2                	ld	t0,40(sp)
ffffffffc0200b8a:	7342                	ld	t1,48(sp)
ffffffffc0200b8c:	73e2                	ld	t2,56(sp)
ffffffffc0200b8e:	6406                	ld	s0,64(sp)
ffffffffc0200b90:	64a6                	ld	s1,72(sp)
ffffffffc0200b92:	6546                	ld	a0,80(sp)
ffffffffc0200b94:	65e6                	ld	a1,88(sp)
ffffffffc0200b96:	7606                	ld	a2,96(sp)
ffffffffc0200b98:	76a6                	ld	a3,104(sp)
ffffffffc0200b9a:	7746                	ld	a4,112(sp)
ffffffffc0200b9c:	77e6                	ld	a5,120(sp)
ffffffffc0200b9e:	680a                	ld	a6,128(sp)
ffffffffc0200ba0:	68aa                	ld	a7,136(sp)
ffffffffc0200ba2:	694a                	ld	s2,144(sp)
ffffffffc0200ba4:	69ea                	ld	s3,152(sp)
ffffffffc0200ba6:	7a0a                	ld	s4,160(sp)
ffffffffc0200ba8:	7aaa                	ld	s5,168(sp)
ffffffffc0200baa:	7b4a                	ld	s6,176(sp)
ffffffffc0200bac:	7bea                	ld	s7,184(sp)
ffffffffc0200bae:	6c0e                	ld	s8,192(sp)
ffffffffc0200bb0:	6cae                	ld	s9,200(sp)
ffffffffc0200bb2:	6d4e                	ld	s10,208(sp)
ffffffffc0200bb4:	6dee                	ld	s11,216(sp)
ffffffffc0200bb6:	7e0e                	ld	t3,224(sp)
ffffffffc0200bb8:	7eae                	ld	t4,232(sp)
ffffffffc0200bba:	7f4e                	ld	t5,240(sp)
ffffffffc0200bbc:	7fee                	ld	t6,248(sp)
ffffffffc0200bbe:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret # sret命令，从监督者模式返回，会把sstatus寄存器的SIE位清零，这样就禁止了中断，同时把sstatus寄存器的SPIE位设置为SIE位的值，这样就恢复了中断的开关状态。
ffffffffc0200bc0:	10200073          	sret

ffffffffc0200bc4 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0 #把传进来的参数，也就是进程的中断帧放在了sp，后面根据sp的值逐个执行RESTORE操作，将中断程序的上下文恢复
ffffffffc0200bc4:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200bc6:	bf45                	j	ffffffffc0200b76 <__trapret>
	...

ffffffffc0200bca <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200bca:	00016797          	auipc	a5,0x16
ffffffffc0200bce:	90e78793          	addi	a5,a5,-1778 # ffffffffc02164d8 <free_area>
ffffffffc0200bd2:	e79c                	sd	a5,8(a5)
ffffffffc0200bd4:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200bd6:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200bda:	8082                	ret

ffffffffc0200bdc <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200bdc:	00016517          	auipc	a0,0x16
ffffffffc0200be0:	90c56503          	lwu	a0,-1780(a0) # ffffffffc02164e8 <free_area+0x10>
ffffffffc0200be4:	8082                	ret

ffffffffc0200be6 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200be6:	715d                	addi	sp,sp,-80
ffffffffc0200be8:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200bea:	00016917          	auipc	s2,0x16
ffffffffc0200bee:	8ee90913          	addi	s2,s2,-1810 # ffffffffc02164d8 <free_area>
ffffffffc0200bf2:	00893783          	ld	a5,8(s2)
ffffffffc0200bf6:	e486                	sd	ra,72(sp)
ffffffffc0200bf8:	e0a2                	sd	s0,64(sp)
ffffffffc0200bfa:	fc26                	sd	s1,56(sp)
ffffffffc0200bfc:	f44e                	sd	s3,40(sp)
ffffffffc0200bfe:	f052                	sd	s4,32(sp)
ffffffffc0200c00:	ec56                	sd	s5,24(sp)
ffffffffc0200c02:	e85a                	sd	s6,16(sp)
ffffffffc0200c04:	e45e                	sd	s7,8(sp)
ffffffffc0200c06:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c08:	31278463          	beq	a5,s2,ffffffffc0200f10 <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200c0c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200c10:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200c12:	8b05                	andi	a4,a4,1
ffffffffc0200c14:	30070263          	beqz	a4,ffffffffc0200f18 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200c18:	4401                	li	s0,0
ffffffffc0200c1a:	4481                	li	s1,0
ffffffffc0200c1c:	a031                	j	ffffffffc0200c28 <default_check+0x42>
ffffffffc0200c1e:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200c22:	8b09                	andi	a4,a4,2
ffffffffc0200c24:	2e070a63          	beqz	a4,ffffffffc0200f18 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200c28:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200c2c:	679c                	ld	a5,8(a5)
ffffffffc0200c2e:	2485                	addiw	s1,s1,1
ffffffffc0200c30:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c32:	ff2796e3          	bne	a5,s2,ffffffffc0200c1e <default_check+0x38>
ffffffffc0200c36:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200c38:	058010ef          	jal	ra,ffffffffc0201c90 <nr_free_pages>
ffffffffc0200c3c:	73351e63          	bne	a0,s3,ffffffffc0201378 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c40:	4505                	li	a0,1
ffffffffc0200c42:	781000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0200c46:	8a2a                	mv	s4,a0
ffffffffc0200c48:	46050863          	beqz	a0,ffffffffc02010b8 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c4c:	4505                	li	a0,1
ffffffffc0200c4e:	775000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0200c52:	89aa                	mv	s3,a0
ffffffffc0200c54:	74050263          	beqz	a0,ffffffffc0201398 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c58:	4505                	li	a0,1
ffffffffc0200c5a:	769000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0200c5e:	8aaa                	mv	s5,a0
ffffffffc0200c60:	4c050c63          	beqz	a0,ffffffffc0201138 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c64:	2d3a0a63          	beq	s4,s3,ffffffffc0200f38 <default_check+0x352>
ffffffffc0200c68:	2caa0863          	beq	s4,a0,ffffffffc0200f38 <default_check+0x352>
ffffffffc0200c6c:	2ca98663          	beq	s3,a0,ffffffffc0200f38 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c70:	000a2783          	lw	a5,0(s4)
ffffffffc0200c74:	2e079263          	bnez	a5,ffffffffc0200f58 <default_check+0x372>
ffffffffc0200c78:	0009a783          	lw	a5,0(s3)
ffffffffc0200c7c:	2c079e63          	bnez	a5,ffffffffc0200f58 <default_check+0x372>
ffffffffc0200c80:	411c                	lw	a5,0(a0)
ffffffffc0200c82:	2c079b63          	bnez	a5,ffffffffc0200f58 <default_check+0x372>
 * page2ppn 函数用于将一个物理页面转换为对应的页帧号。
 * 。它首先将页面指针减去 pages 指针，得到页面在数组中的偏移量。然后，它将偏移量加上 nbase 得到页帧号。
*/
static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200c86:	00016797          	auipc	a5,0x16
ffffffffc0200c8a:	88278793          	addi	a5,a5,-1918 # ffffffffc0216508 <pages>
ffffffffc0200c8e:	639c                	ld	a5,0(a5)
ffffffffc0200c90:	00006717          	auipc	a4,0x6
ffffffffc0200c94:	3d870713          	addi	a4,a4,984 # ffffffffc0207068 <nbase>
ffffffffc0200c98:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c9a:	00015717          	auipc	a4,0x15
ffffffffc0200c9e:	7fe70713          	addi	a4,a4,2046 # ffffffffc0216498 <npage>
ffffffffc0200ca2:	6314                	ld	a3,0(a4)
ffffffffc0200ca4:	40fa0733          	sub	a4,s4,a5
ffffffffc0200ca8:	8719                	srai	a4,a4,0x6
ffffffffc0200caa:	9732                	add	a4,a4,a2
ffffffffc0200cac:	06b2                	slli	a3,a3,0xc
 * page2pa 函数用于将一个物理页面转换为对应的物理地址。
 * 它首先调用 page2ppn 函数将页面转换为页帧号，然后将页帧号左移 PGSHIFT 位得到物理地址。
*/
static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cae:	0732                	slli	a4,a4,0xc
ffffffffc0200cb0:	2cd77463          	bleu	a3,a4,ffffffffc0200f78 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200cb4:	40f98733          	sub	a4,s3,a5
ffffffffc0200cb8:	8719                	srai	a4,a4,0x6
ffffffffc0200cba:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cbc:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200cbe:	4ed77d63          	bleu	a3,a4,ffffffffc02011b8 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200cc2:	40f507b3          	sub	a5,a0,a5
ffffffffc0200cc6:	8799                	srai	a5,a5,0x6
ffffffffc0200cc8:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cca:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ccc:	34d7f663          	bleu	a3,a5,ffffffffc0201018 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200cd0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200cd2:	00093c03          	ld	s8,0(s2)
ffffffffc0200cd6:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200cda:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200cde:	00016797          	auipc	a5,0x16
ffffffffc0200ce2:	8127b123          	sd	s2,-2046(a5) # ffffffffc02164e0 <free_area+0x8>
ffffffffc0200ce6:	00015797          	auipc	a5,0x15
ffffffffc0200cea:	7f27b923          	sd	s2,2034(a5) # ffffffffc02164d8 <free_area>
    nr_free = 0;
ffffffffc0200cee:	00015797          	auipc	a5,0x15
ffffffffc0200cf2:	7e07ad23          	sw	zero,2042(a5) # ffffffffc02164e8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200cf6:	6cd000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0200cfa:	2e051f63          	bnez	a0,ffffffffc0200ff8 <default_check+0x412>
    free_page(p0);
ffffffffc0200cfe:	4585                	li	a1,1
ffffffffc0200d00:	8552                	mv	a0,s4
ffffffffc0200d02:	749000ef          	jal	ra,ffffffffc0201c4a <free_pages>
    free_page(p1);
ffffffffc0200d06:	4585                	li	a1,1
ffffffffc0200d08:	854e                	mv	a0,s3
ffffffffc0200d0a:	741000ef          	jal	ra,ffffffffc0201c4a <free_pages>
    free_page(p2);
ffffffffc0200d0e:	4585                	li	a1,1
ffffffffc0200d10:	8556                	mv	a0,s5
ffffffffc0200d12:	739000ef          	jal	ra,ffffffffc0201c4a <free_pages>
    assert(nr_free == 3);
ffffffffc0200d16:	01092703          	lw	a4,16(s2)
ffffffffc0200d1a:	478d                	li	a5,3
ffffffffc0200d1c:	2af71e63          	bne	a4,a5,ffffffffc0200fd8 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d20:	4505                	li	a0,1
ffffffffc0200d22:	6a1000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0200d26:	89aa                	mv	s3,a0
ffffffffc0200d28:	28050863          	beqz	a0,ffffffffc0200fb8 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d2c:	4505                	li	a0,1
ffffffffc0200d2e:	695000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0200d32:	8aaa                	mv	s5,a0
ffffffffc0200d34:	3e050263          	beqz	a0,ffffffffc0201118 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d38:	4505                	li	a0,1
ffffffffc0200d3a:	689000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0200d3e:	8a2a                	mv	s4,a0
ffffffffc0200d40:	3a050c63          	beqz	a0,ffffffffc02010f8 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200d44:	4505                	li	a0,1
ffffffffc0200d46:	67d000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0200d4a:	38051763          	bnez	a0,ffffffffc02010d8 <default_check+0x4f2>
    free_page(p0);
ffffffffc0200d4e:	4585                	li	a1,1
ffffffffc0200d50:	854e                	mv	a0,s3
ffffffffc0200d52:	6f9000ef          	jal	ra,ffffffffc0201c4a <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200d56:	00893783          	ld	a5,8(s2)
ffffffffc0200d5a:	23278f63          	beq	a5,s2,ffffffffc0200f98 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200d5e:	4505                	li	a0,1
ffffffffc0200d60:	663000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0200d64:	32a99a63          	bne	s3,a0,ffffffffc0201098 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0200d68:	4505                	li	a0,1
ffffffffc0200d6a:	659000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0200d6e:	30051563          	bnez	a0,ffffffffc0201078 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0200d72:	01092783          	lw	a5,16(s2)
ffffffffc0200d76:	2e079163          	bnez	a5,ffffffffc0201058 <default_check+0x472>
    free_page(p);
ffffffffc0200d7a:	854e                	mv	a0,s3
ffffffffc0200d7c:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200d7e:	00015797          	auipc	a5,0x15
ffffffffc0200d82:	7587bd23          	sd	s8,1882(a5) # ffffffffc02164d8 <free_area>
ffffffffc0200d86:	00015797          	auipc	a5,0x15
ffffffffc0200d8a:	7577bd23          	sd	s7,1882(a5) # ffffffffc02164e0 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200d8e:	00015797          	auipc	a5,0x15
ffffffffc0200d92:	7567ad23          	sw	s6,1882(a5) # ffffffffc02164e8 <free_area+0x10>
    free_page(p);
ffffffffc0200d96:	6b5000ef          	jal	ra,ffffffffc0201c4a <free_pages>
    free_page(p1);
ffffffffc0200d9a:	4585                	li	a1,1
ffffffffc0200d9c:	8556                	mv	a0,s5
ffffffffc0200d9e:	6ad000ef          	jal	ra,ffffffffc0201c4a <free_pages>
    free_page(p2);
ffffffffc0200da2:	4585                	li	a1,1
ffffffffc0200da4:	8552                	mv	a0,s4
ffffffffc0200da6:	6a5000ef          	jal	ra,ffffffffc0201c4a <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200daa:	4515                	li	a0,5
ffffffffc0200dac:	617000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0200db0:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200db2:	28050363          	beqz	a0,ffffffffc0201038 <default_check+0x452>
ffffffffc0200db6:	651c                	ld	a5,8(a0)
ffffffffc0200db8:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200dba:	8b85                	andi	a5,a5,1
ffffffffc0200dbc:	54079e63          	bnez	a5,ffffffffc0201318 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200dc0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200dc2:	00093b03          	ld	s6,0(s2)
ffffffffc0200dc6:	00893a83          	ld	s5,8(s2)
ffffffffc0200dca:	00015797          	auipc	a5,0x15
ffffffffc0200dce:	7127b723          	sd	s2,1806(a5) # ffffffffc02164d8 <free_area>
ffffffffc0200dd2:	00015797          	auipc	a5,0x15
ffffffffc0200dd6:	7127b723          	sd	s2,1806(a5) # ffffffffc02164e0 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200dda:	5e9000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0200dde:	50051d63          	bnez	a0,ffffffffc02012f8 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200de2:	08098a13          	addi	s4,s3,128
ffffffffc0200de6:	8552                	mv	a0,s4
ffffffffc0200de8:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200dea:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200dee:	00015797          	auipc	a5,0x15
ffffffffc0200df2:	6e07ad23          	sw	zero,1786(a5) # ffffffffc02164e8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200df6:	655000ef          	jal	ra,ffffffffc0201c4a <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200dfa:	4511                	li	a0,4
ffffffffc0200dfc:	5c7000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0200e00:	4c051c63          	bnez	a0,ffffffffc02012d8 <default_check+0x6f2>
ffffffffc0200e04:	0889b783          	ld	a5,136(s3)
ffffffffc0200e08:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200e0a:	8b85                	andi	a5,a5,1
ffffffffc0200e0c:	4a078663          	beqz	a5,ffffffffc02012b8 <default_check+0x6d2>
ffffffffc0200e10:	0909a703          	lw	a4,144(s3)
ffffffffc0200e14:	478d                	li	a5,3
ffffffffc0200e16:	4af71163          	bne	a4,a5,ffffffffc02012b8 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200e1a:	450d                	li	a0,3
ffffffffc0200e1c:	5a7000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0200e20:	8c2a                	mv	s8,a0
ffffffffc0200e22:	46050b63          	beqz	a0,ffffffffc0201298 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0200e26:	4505                	li	a0,1
ffffffffc0200e28:	59b000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0200e2c:	44051663          	bnez	a0,ffffffffc0201278 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0200e30:	438a1463          	bne	s4,s8,ffffffffc0201258 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200e34:	4585                	li	a1,1
ffffffffc0200e36:	854e                	mv	a0,s3
ffffffffc0200e38:	613000ef          	jal	ra,ffffffffc0201c4a <free_pages>
    free_pages(p1, 3);
ffffffffc0200e3c:	458d                	li	a1,3
ffffffffc0200e3e:	8552                	mv	a0,s4
ffffffffc0200e40:	60b000ef          	jal	ra,ffffffffc0201c4a <free_pages>
ffffffffc0200e44:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200e48:	04098c13          	addi	s8,s3,64
ffffffffc0200e4c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200e4e:	8b85                	andi	a5,a5,1
ffffffffc0200e50:	3e078463          	beqz	a5,ffffffffc0201238 <default_check+0x652>
ffffffffc0200e54:	0109a703          	lw	a4,16(s3)
ffffffffc0200e58:	4785                	li	a5,1
ffffffffc0200e5a:	3cf71f63          	bne	a4,a5,ffffffffc0201238 <default_check+0x652>
ffffffffc0200e5e:	008a3783          	ld	a5,8(s4)
ffffffffc0200e62:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200e64:	8b85                	andi	a5,a5,1
ffffffffc0200e66:	3a078963          	beqz	a5,ffffffffc0201218 <default_check+0x632>
ffffffffc0200e6a:	010a2703          	lw	a4,16(s4)
ffffffffc0200e6e:	478d                	li	a5,3
ffffffffc0200e70:	3af71463          	bne	a4,a5,ffffffffc0201218 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200e74:	4505                	li	a0,1
ffffffffc0200e76:	54d000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0200e7a:	36a99f63          	bne	s3,a0,ffffffffc02011f8 <default_check+0x612>
    free_page(p0);
ffffffffc0200e7e:	4585                	li	a1,1
ffffffffc0200e80:	5cb000ef          	jal	ra,ffffffffc0201c4a <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200e84:	4509                	li	a0,2
ffffffffc0200e86:	53d000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0200e8a:	34aa1763          	bne	s4,a0,ffffffffc02011d8 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc0200e8e:	4589                	li	a1,2
ffffffffc0200e90:	5bb000ef          	jal	ra,ffffffffc0201c4a <free_pages>
    free_page(p2);
ffffffffc0200e94:	4585                	li	a1,1
ffffffffc0200e96:	8562                	mv	a0,s8
ffffffffc0200e98:	5b3000ef          	jal	ra,ffffffffc0201c4a <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e9c:	4515                	li	a0,5
ffffffffc0200e9e:	525000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0200ea2:	89aa                	mv	s3,a0
ffffffffc0200ea4:	48050a63          	beqz	a0,ffffffffc0201338 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0200ea8:	4505                	li	a0,1
ffffffffc0200eaa:	519000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0200eae:	2e051563          	bnez	a0,ffffffffc0201198 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0200eb2:	01092783          	lw	a5,16(s2)
ffffffffc0200eb6:	2c079163          	bnez	a5,ffffffffc0201178 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200eba:	4595                	li	a1,5
ffffffffc0200ebc:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200ebe:	00015797          	auipc	a5,0x15
ffffffffc0200ec2:	6377a523          	sw	s7,1578(a5) # ffffffffc02164e8 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200ec6:	00015797          	auipc	a5,0x15
ffffffffc0200eca:	6167b923          	sd	s6,1554(a5) # ffffffffc02164d8 <free_area>
ffffffffc0200ece:	00015797          	auipc	a5,0x15
ffffffffc0200ed2:	6157b923          	sd	s5,1554(a5) # ffffffffc02164e0 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200ed6:	575000ef          	jal	ra,ffffffffc0201c4a <free_pages>
    return listelm->next;
ffffffffc0200eda:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ede:	01278963          	beq	a5,s2,ffffffffc0200ef0 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200ee2:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ee6:	679c                	ld	a5,8(a5)
ffffffffc0200ee8:	34fd                	addiw	s1,s1,-1
ffffffffc0200eea:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200eec:	ff279be3          	bne	a5,s2,ffffffffc0200ee2 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0200ef0:	26049463          	bnez	s1,ffffffffc0201158 <default_check+0x572>
    assert(total == 0);
ffffffffc0200ef4:	46041263          	bnez	s0,ffffffffc0201358 <default_check+0x772>
}
ffffffffc0200ef8:	60a6                	ld	ra,72(sp)
ffffffffc0200efa:	6406                	ld	s0,64(sp)
ffffffffc0200efc:	74e2                	ld	s1,56(sp)
ffffffffc0200efe:	7942                	ld	s2,48(sp)
ffffffffc0200f00:	79a2                	ld	s3,40(sp)
ffffffffc0200f02:	7a02                	ld	s4,32(sp)
ffffffffc0200f04:	6ae2                	ld	s5,24(sp)
ffffffffc0200f06:	6b42                	ld	s6,16(sp)
ffffffffc0200f08:	6ba2                	ld	s7,8(sp)
ffffffffc0200f0a:	6c02                	ld	s8,0(sp)
ffffffffc0200f0c:	6161                	addi	sp,sp,80
ffffffffc0200f0e:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200f10:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200f12:	4401                	li	s0,0
ffffffffc0200f14:	4481                	li	s1,0
ffffffffc0200f16:	b30d                	j	ffffffffc0200c38 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200f18:	00005697          	auipc	a3,0x5
ffffffffc0200f1c:	9b868693          	addi	a3,a3,-1608 # ffffffffc02058d0 <commands+0x860>
ffffffffc0200f20:	00005617          	auipc	a2,0x5
ffffffffc0200f24:	9c060613          	addi	a2,a2,-1600 # ffffffffc02058e0 <commands+0x870>
ffffffffc0200f28:	0f000593          	li	a1,240
ffffffffc0200f2c:	00005517          	auipc	a0,0x5
ffffffffc0200f30:	9cc50513          	addi	a0,a0,-1588 # ffffffffc02058f8 <commands+0x888>
ffffffffc0200f34:	d1cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200f38:	00005697          	auipc	a3,0x5
ffffffffc0200f3c:	a5868693          	addi	a3,a3,-1448 # ffffffffc0205990 <commands+0x920>
ffffffffc0200f40:	00005617          	auipc	a2,0x5
ffffffffc0200f44:	9a060613          	addi	a2,a2,-1632 # ffffffffc02058e0 <commands+0x870>
ffffffffc0200f48:	0bd00593          	li	a1,189
ffffffffc0200f4c:	00005517          	auipc	a0,0x5
ffffffffc0200f50:	9ac50513          	addi	a0,a0,-1620 # ffffffffc02058f8 <commands+0x888>
ffffffffc0200f54:	cfcff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200f58:	00005697          	auipc	a3,0x5
ffffffffc0200f5c:	a6068693          	addi	a3,a3,-1440 # ffffffffc02059b8 <commands+0x948>
ffffffffc0200f60:	00005617          	auipc	a2,0x5
ffffffffc0200f64:	98060613          	addi	a2,a2,-1664 # ffffffffc02058e0 <commands+0x870>
ffffffffc0200f68:	0be00593          	li	a1,190
ffffffffc0200f6c:	00005517          	auipc	a0,0x5
ffffffffc0200f70:	98c50513          	addi	a0,a0,-1652 # ffffffffc02058f8 <commands+0x888>
ffffffffc0200f74:	cdcff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f78:	00005697          	auipc	a3,0x5
ffffffffc0200f7c:	a8068693          	addi	a3,a3,-1408 # ffffffffc02059f8 <commands+0x988>
ffffffffc0200f80:	00005617          	auipc	a2,0x5
ffffffffc0200f84:	96060613          	addi	a2,a2,-1696 # ffffffffc02058e0 <commands+0x870>
ffffffffc0200f88:	0c000593          	li	a1,192
ffffffffc0200f8c:	00005517          	auipc	a0,0x5
ffffffffc0200f90:	96c50513          	addi	a0,a0,-1684 # ffffffffc02058f8 <commands+0x888>
ffffffffc0200f94:	cbcff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200f98:	00005697          	auipc	a3,0x5
ffffffffc0200f9c:	ae868693          	addi	a3,a3,-1304 # ffffffffc0205a80 <commands+0xa10>
ffffffffc0200fa0:	00005617          	auipc	a2,0x5
ffffffffc0200fa4:	94060613          	addi	a2,a2,-1728 # ffffffffc02058e0 <commands+0x870>
ffffffffc0200fa8:	0d900593          	li	a1,217
ffffffffc0200fac:	00005517          	auipc	a0,0x5
ffffffffc0200fb0:	94c50513          	addi	a0,a0,-1716 # ffffffffc02058f8 <commands+0x888>
ffffffffc0200fb4:	c9cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fb8:	00005697          	auipc	a3,0x5
ffffffffc0200fbc:	97868693          	addi	a3,a3,-1672 # ffffffffc0205930 <commands+0x8c0>
ffffffffc0200fc0:	00005617          	auipc	a2,0x5
ffffffffc0200fc4:	92060613          	addi	a2,a2,-1760 # ffffffffc02058e0 <commands+0x870>
ffffffffc0200fc8:	0d200593          	li	a1,210
ffffffffc0200fcc:	00005517          	auipc	a0,0x5
ffffffffc0200fd0:	92c50513          	addi	a0,a0,-1748 # ffffffffc02058f8 <commands+0x888>
ffffffffc0200fd4:	c7cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free == 3);
ffffffffc0200fd8:	00005697          	auipc	a3,0x5
ffffffffc0200fdc:	a9868693          	addi	a3,a3,-1384 # ffffffffc0205a70 <commands+0xa00>
ffffffffc0200fe0:	00005617          	auipc	a2,0x5
ffffffffc0200fe4:	90060613          	addi	a2,a2,-1792 # ffffffffc02058e0 <commands+0x870>
ffffffffc0200fe8:	0d000593          	li	a1,208
ffffffffc0200fec:	00005517          	auipc	a0,0x5
ffffffffc0200ff0:	90c50513          	addi	a0,a0,-1780 # ffffffffc02058f8 <commands+0x888>
ffffffffc0200ff4:	c5cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ff8:	00005697          	auipc	a3,0x5
ffffffffc0200ffc:	a6068693          	addi	a3,a3,-1440 # ffffffffc0205a58 <commands+0x9e8>
ffffffffc0201000:	00005617          	auipc	a2,0x5
ffffffffc0201004:	8e060613          	addi	a2,a2,-1824 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201008:	0cb00593          	li	a1,203
ffffffffc020100c:	00005517          	auipc	a0,0x5
ffffffffc0201010:	8ec50513          	addi	a0,a0,-1812 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201014:	c3cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201018:	00005697          	auipc	a3,0x5
ffffffffc020101c:	a2068693          	addi	a3,a3,-1504 # ffffffffc0205a38 <commands+0x9c8>
ffffffffc0201020:	00005617          	auipc	a2,0x5
ffffffffc0201024:	8c060613          	addi	a2,a2,-1856 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201028:	0c200593          	li	a1,194
ffffffffc020102c:	00005517          	auipc	a0,0x5
ffffffffc0201030:	8cc50513          	addi	a0,a0,-1844 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201034:	c1cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(p0 != NULL);
ffffffffc0201038:	00005697          	auipc	a3,0x5
ffffffffc020103c:	a9068693          	addi	a3,a3,-1392 # ffffffffc0205ac8 <commands+0xa58>
ffffffffc0201040:	00005617          	auipc	a2,0x5
ffffffffc0201044:	8a060613          	addi	a2,a2,-1888 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201048:	0f800593          	li	a1,248
ffffffffc020104c:	00005517          	auipc	a0,0x5
ffffffffc0201050:	8ac50513          	addi	a0,a0,-1876 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201054:	bfcff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free == 0);
ffffffffc0201058:	00005697          	auipc	a3,0x5
ffffffffc020105c:	a6068693          	addi	a3,a3,-1440 # ffffffffc0205ab8 <commands+0xa48>
ffffffffc0201060:	00005617          	auipc	a2,0x5
ffffffffc0201064:	88060613          	addi	a2,a2,-1920 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201068:	0df00593          	li	a1,223
ffffffffc020106c:	00005517          	auipc	a0,0x5
ffffffffc0201070:	88c50513          	addi	a0,a0,-1908 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201074:	bdcff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201078:	00005697          	auipc	a3,0x5
ffffffffc020107c:	9e068693          	addi	a3,a3,-1568 # ffffffffc0205a58 <commands+0x9e8>
ffffffffc0201080:	00005617          	auipc	a2,0x5
ffffffffc0201084:	86060613          	addi	a2,a2,-1952 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201088:	0dd00593          	li	a1,221
ffffffffc020108c:	00005517          	auipc	a0,0x5
ffffffffc0201090:	86c50513          	addi	a0,a0,-1940 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201094:	bbcff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201098:	00005697          	auipc	a3,0x5
ffffffffc020109c:	a0068693          	addi	a3,a3,-1536 # ffffffffc0205a98 <commands+0xa28>
ffffffffc02010a0:	00005617          	auipc	a2,0x5
ffffffffc02010a4:	84060613          	addi	a2,a2,-1984 # ffffffffc02058e0 <commands+0x870>
ffffffffc02010a8:	0dc00593          	li	a1,220
ffffffffc02010ac:	00005517          	auipc	a0,0x5
ffffffffc02010b0:	84c50513          	addi	a0,a0,-1972 # ffffffffc02058f8 <commands+0x888>
ffffffffc02010b4:	b9cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02010b8:	00005697          	auipc	a3,0x5
ffffffffc02010bc:	87868693          	addi	a3,a3,-1928 # ffffffffc0205930 <commands+0x8c0>
ffffffffc02010c0:	00005617          	auipc	a2,0x5
ffffffffc02010c4:	82060613          	addi	a2,a2,-2016 # ffffffffc02058e0 <commands+0x870>
ffffffffc02010c8:	0b900593          	li	a1,185
ffffffffc02010cc:	00005517          	auipc	a0,0x5
ffffffffc02010d0:	82c50513          	addi	a0,a0,-2004 # ffffffffc02058f8 <commands+0x888>
ffffffffc02010d4:	b7cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010d8:	00005697          	auipc	a3,0x5
ffffffffc02010dc:	98068693          	addi	a3,a3,-1664 # ffffffffc0205a58 <commands+0x9e8>
ffffffffc02010e0:	00005617          	auipc	a2,0x5
ffffffffc02010e4:	80060613          	addi	a2,a2,-2048 # ffffffffc02058e0 <commands+0x870>
ffffffffc02010e8:	0d600593          	li	a1,214
ffffffffc02010ec:	00005517          	auipc	a0,0x5
ffffffffc02010f0:	80c50513          	addi	a0,a0,-2036 # ffffffffc02058f8 <commands+0x888>
ffffffffc02010f4:	b5cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010f8:	00005697          	auipc	a3,0x5
ffffffffc02010fc:	87868693          	addi	a3,a3,-1928 # ffffffffc0205970 <commands+0x900>
ffffffffc0201100:	00004617          	auipc	a2,0x4
ffffffffc0201104:	7e060613          	addi	a2,a2,2016 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201108:	0d400593          	li	a1,212
ffffffffc020110c:	00004517          	auipc	a0,0x4
ffffffffc0201110:	7ec50513          	addi	a0,a0,2028 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201114:	b3cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201118:	00005697          	auipc	a3,0x5
ffffffffc020111c:	83868693          	addi	a3,a3,-1992 # ffffffffc0205950 <commands+0x8e0>
ffffffffc0201120:	00004617          	auipc	a2,0x4
ffffffffc0201124:	7c060613          	addi	a2,a2,1984 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201128:	0d300593          	li	a1,211
ffffffffc020112c:	00004517          	auipc	a0,0x4
ffffffffc0201130:	7cc50513          	addi	a0,a0,1996 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201134:	b1cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201138:	00005697          	auipc	a3,0x5
ffffffffc020113c:	83868693          	addi	a3,a3,-1992 # ffffffffc0205970 <commands+0x900>
ffffffffc0201140:	00004617          	auipc	a2,0x4
ffffffffc0201144:	7a060613          	addi	a2,a2,1952 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201148:	0bb00593          	li	a1,187
ffffffffc020114c:	00004517          	auipc	a0,0x4
ffffffffc0201150:	7ac50513          	addi	a0,a0,1964 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201154:	afcff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(count == 0);
ffffffffc0201158:	00005697          	auipc	a3,0x5
ffffffffc020115c:	ac068693          	addi	a3,a3,-1344 # ffffffffc0205c18 <commands+0xba8>
ffffffffc0201160:	00004617          	auipc	a2,0x4
ffffffffc0201164:	78060613          	addi	a2,a2,1920 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201168:	12500593          	li	a1,293
ffffffffc020116c:	00004517          	auipc	a0,0x4
ffffffffc0201170:	78c50513          	addi	a0,a0,1932 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201174:	adcff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free == 0);
ffffffffc0201178:	00005697          	auipc	a3,0x5
ffffffffc020117c:	94068693          	addi	a3,a3,-1728 # ffffffffc0205ab8 <commands+0xa48>
ffffffffc0201180:	00004617          	auipc	a2,0x4
ffffffffc0201184:	76060613          	addi	a2,a2,1888 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201188:	11a00593          	li	a1,282
ffffffffc020118c:	00004517          	auipc	a0,0x4
ffffffffc0201190:	76c50513          	addi	a0,a0,1900 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201194:	abcff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201198:	00005697          	auipc	a3,0x5
ffffffffc020119c:	8c068693          	addi	a3,a3,-1856 # ffffffffc0205a58 <commands+0x9e8>
ffffffffc02011a0:	00004617          	auipc	a2,0x4
ffffffffc02011a4:	74060613          	addi	a2,a2,1856 # ffffffffc02058e0 <commands+0x870>
ffffffffc02011a8:	11800593          	li	a1,280
ffffffffc02011ac:	00004517          	auipc	a0,0x4
ffffffffc02011b0:	74c50513          	addi	a0,a0,1868 # ffffffffc02058f8 <commands+0x888>
ffffffffc02011b4:	a9cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02011b8:	00005697          	auipc	a3,0x5
ffffffffc02011bc:	86068693          	addi	a3,a3,-1952 # ffffffffc0205a18 <commands+0x9a8>
ffffffffc02011c0:	00004617          	auipc	a2,0x4
ffffffffc02011c4:	72060613          	addi	a2,a2,1824 # ffffffffc02058e0 <commands+0x870>
ffffffffc02011c8:	0c100593          	li	a1,193
ffffffffc02011cc:	00004517          	auipc	a0,0x4
ffffffffc02011d0:	72c50513          	addi	a0,a0,1836 # ffffffffc02058f8 <commands+0x888>
ffffffffc02011d4:	a7cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02011d8:	00005697          	auipc	a3,0x5
ffffffffc02011dc:	a0068693          	addi	a3,a3,-1536 # ffffffffc0205bd8 <commands+0xb68>
ffffffffc02011e0:	00004617          	auipc	a2,0x4
ffffffffc02011e4:	70060613          	addi	a2,a2,1792 # ffffffffc02058e0 <commands+0x870>
ffffffffc02011e8:	11200593          	li	a1,274
ffffffffc02011ec:	00004517          	auipc	a0,0x4
ffffffffc02011f0:	70c50513          	addi	a0,a0,1804 # ffffffffc02058f8 <commands+0x888>
ffffffffc02011f4:	a5cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02011f8:	00005697          	auipc	a3,0x5
ffffffffc02011fc:	9c068693          	addi	a3,a3,-1600 # ffffffffc0205bb8 <commands+0xb48>
ffffffffc0201200:	00004617          	auipc	a2,0x4
ffffffffc0201204:	6e060613          	addi	a2,a2,1760 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201208:	11000593          	li	a1,272
ffffffffc020120c:	00004517          	auipc	a0,0x4
ffffffffc0201210:	6ec50513          	addi	a0,a0,1772 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201214:	a3cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201218:	00005697          	auipc	a3,0x5
ffffffffc020121c:	97868693          	addi	a3,a3,-1672 # ffffffffc0205b90 <commands+0xb20>
ffffffffc0201220:	00004617          	auipc	a2,0x4
ffffffffc0201224:	6c060613          	addi	a2,a2,1728 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201228:	10e00593          	li	a1,270
ffffffffc020122c:	00004517          	auipc	a0,0x4
ffffffffc0201230:	6cc50513          	addi	a0,a0,1740 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201234:	a1cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201238:	00005697          	auipc	a3,0x5
ffffffffc020123c:	93068693          	addi	a3,a3,-1744 # ffffffffc0205b68 <commands+0xaf8>
ffffffffc0201240:	00004617          	auipc	a2,0x4
ffffffffc0201244:	6a060613          	addi	a2,a2,1696 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201248:	10d00593          	li	a1,269
ffffffffc020124c:	00004517          	auipc	a0,0x4
ffffffffc0201250:	6ac50513          	addi	a0,a0,1708 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201254:	9fcff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201258:	00005697          	auipc	a3,0x5
ffffffffc020125c:	90068693          	addi	a3,a3,-1792 # ffffffffc0205b58 <commands+0xae8>
ffffffffc0201260:	00004617          	auipc	a2,0x4
ffffffffc0201264:	68060613          	addi	a2,a2,1664 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201268:	10800593          	li	a1,264
ffffffffc020126c:	00004517          	auipc	a0,0x4
ffffffffc0201270:	68c50513          	addi	a0,a0,1676 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201274:	9dcff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201278:	00004697          	auipc	a3,0x4
ffffffffc020127c:	7e068693          	addi	a3,a3,2016 # ffffffffc0205a58 <commands+0x9e8>
ffffffffc0201280:	00004617          	auipc	a2,0x4
ffffffffc0201284:	66060613          	addi	a2,a2,1632 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201288:	10700593          	li	a1,263
ffffffffc020128c:	00004517          	auipc	a0,0x4
ffffffffc0201290:	66c50513          	addi	a0,a0,1644 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201294:	9bcff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201298:	00005697          	auipc	a3,0x5
ffffffffc020129c:	8a068693          	addi	a3,a3,-1888 # ffffffffc0205b38 <commands+0xac8>
ffffffffc02012a0:	00004617          	auipc	a2,0x4
ffffffffc02012a4:	64060613          	addi	a2,a2,1600 # ffffffffc02058e0 <commands+0x870>
ffffffffc02012a8:	10600593          	li	a1,262
ffffffffc02012ac:	00004517          	auipc	a0,0x4
ffffffffc02012b0:	64c50513          	addi	a0,a0,1612 # ffffffffc02058f8 <commands+0x888>
ffffffffc02012b4:	99cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02012b8:	00005697          	auipc	a3,0x5
ffffffffc02012bc:	85068693          	addi	a3,a3,-1968 # ffffffffc0205b08 <commands+0xa98>
ffffffffc02012c0:	00004617          	auipc	a2,0x4
ffffffffc02012c4:	62060613          	addi	a2,a2,1568 # ffffffffc02058e0 <commands+0x870>
ffffffffc02012c8:	10500593          	li	a1,261
ffffffffc02012cc:	00004517          	auipc	a0,0x4
ffffffffc02012d0:	62c50513          	addi	a0,a0,1580 # ffffffffc02058f8 <commands+0x888>
ffffffffc02012d4:	97cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02012d8:	00005697          	auipc	a3,0x5
ffffffffc02012dc:	81868693          	addi	a3,a3,-2024 # ffffffffc0205af0 <commands+0xa80>
ffffffffc02012e0:	00004617          	auipc	a2,0x4
ffffffffc02012e4:	60060613          	addi	a2,a2,1536 # ffffffffc02058e0 <commands+0x870>
ffffffffc02012e8:	10400593          	li	a1,260
ffffffffc02012ec:	00004517          	auipc	a0,0x4
ffffffffc02012f0:	60c50513          	addi	a0,a0,1548 # ffffffffc02058f8 <commands+0x888>
ffffffffc02012f4:	95cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012f8:	00004697          	auipc	a3,0x4
ffffffffc02012fc:	76068693          	addi	a3,a3,1888 # ffffffffc0205a58 <commands+0x9e8>
ffffffffc0201300:	00004617          	auipc	a2,0x4
ffffffffc0201304:	5e060613          	addi	a2,a2,1504 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201308:	0fe00593          	li	a1,254
ffffffffc020130c:	00004517          	auipc	a0,0x4
ffffffffc0201310:	5ec50513          	addi	a0,a0,1516 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201314:	93cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201318:	00004697          	auipc	a3,0x4
ffffffffc020131c:	7c068693          	addi	a3,a3,1984 # ffffffffc0205ad8 <commands+0xa68>
ffffffffc0201320:	00004617          	auipc	a2,0x4
ffffffffc0201324:	5c060613          	addi	a2,a2,1472 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201328:	0f900593          	li	a1,249
ffffffffc020132c:	00004517          	auipc	a0,0x4
ffffffffc0201330:	5cc50513          	addi	a0,a0,1484 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201334:	91cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201338:	00005697          	auipc	a3,0x5
ffffffffc020133c:	8c068693          	addi	a3,a3,-1856 # ffffffffc0205bf8 <commands+0xb88>
ffffffffc0201340:	00004617          	auipc	a2,0x4
ffffffffc0201344:	5a060613          	addi	a2,a2,1440 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201348:	11700593          	li	a1,279
ffffffffc020134c:	00004517          	auipc	a0,0x4
ffffffffc0201350:	5ac50513          	addi	a0,a0,1452 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201354:	8fcff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(total == 0);
ffffffffc0201358:	00005697          	auipc	a3,0x5
ffffffffc020135c:	8d068693          	addi	a3,a3,-1840 # ffffffffc0205c28 <commands+0xbb8>
ffffffffc0201360:	00004617          	auipc	a2,0x4
ffffffffc0201364:	58060613          	addi	a2,a2,1408 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201368:	12600593          	li	a1,294
ffffffffc020136c:	00004517          	auipc	a0,0x4
ffffffffc0201370:	58c50513          	addi	a0,a0,1420 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201374:	8dcff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201378:	00004697          	auipc	a3,0x4
ffffffffc020137c:	59868693          	addi	a3,a3,1432 # ffffffffc0205910 <commands+0x8a0>
ffffffffc0201380:	00004617          	auipc	a2,0x4
ffffffffc0201384:	56060613          	addi	a2,a2,1376 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201388:	0f300593          	li	a1,243
ffffffffc020138c:	00004517          	auipc	a0,0x4
ffffffffc0201390:	56c50513          	addi	a0,a0,1388 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201394:	8bcff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201398:	00004697          	auipc	a3,0x4
ffffffffc020139c:	5b868693          	addi	a3,a3,1464 # ffffffffc0205950 <commands+0x8e0>
ffffffffc02013a0:	00004617          	auipc	a2,0x4
ffffffffc02013a4:	54060613          	addi	a2,a2,1344 # ffffffffc02058e0 <commands+0x870>
ffffffffc02013a8:	0ba00593          	li	a1,186
ffffffffc02013ac:	00004517          	auipc	a0,0x4
ffffffffc02013b0:	54c50513          	addi	a0,a0,1356 # ffffffffc02058f8 <commands+0x888>
ffffffffc02013b4:	89cff0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02013b8 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02013b8:	1141                	addi	sp,sp,-16
ffffffffc02013ba:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02013bc:	16058e63          	beqz	a1,ffffffffc0201538 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc02013c0:	00659693          	slli	a3,a1,0x6
ffffffffc02013c4:	96aa                	add	a3,a3,a0
ffffffffc02013c6:	02d50d63          	beq	a0,a3,ffffffffc0201400 <default_free_pages+0x48>
ffffffffc02013ca:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02013cc:	8b85                	andi	a5,a5,1
ffffffffc02013ce:	14079563          	bnez	a5,ffffffffc0201518 <default_free_pages+0x160>
ffffffffc02013d2:	651c                	ld	a5,8(a0)
ffffffffc02013d4:	8385                	srli	a5,a5,0x1
ffffffffc02013d6:	8b85                	andi	a5,a5,1
ffffffffc02013d8:	14079063          	bnez	a5,ffffffffc0201518 <default_free_pages+0x160>
ffffffffc02013dc:	87aa                	mv	a5,a0
ffffffffc02013de:	a809                	j	ffffffffc02013f0 <default_free_pages+0x38>
ffffffffc02013e0:	6798                	ld	a4,8(a5)
ffffffffc02013e2:	8b05                	andi	a4,a4,1
ffffffffc02013e4:	12071a63          	bnez	a4,ffffffffc0201518 <default_free_pages+0x160>
ffffffffc02013e8:	6798                	ld	a4,8(a5)
ffffffffc02013ea:	8b09                	andi	a4,a4,2
ffffffffc02013ec:	12071663          	bnez	a4,ffffffffc0201518 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc02013f0:	0007b423          	sd	zero,8(a5)
}

//set_page_ref 函数用于设置页面的引用计数。
static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc02013f4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02013f8:	04078793          	addi	a5,a5,64
ffffffffc02013fc:	fed792e3          	bne	a5,a3,ffffffffc02013e0 <default_free_pages+0x28>
    base->property = n;
ffffffffc0201400:	2581                	sext.w	a1,a1
ffffffffc0201402:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201404:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201408:	4789                	li	a5,2
ffffffffc020140a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020140e:	00015697          	auipc	a3,0x15
ffffffffc0201412:	0ca68693          	addi	a3,a3,202 # ffffffffc02164d8 <free_area>
ffffffffc0201416:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201418:	669c                	ld	a5,8(a3)
ffffffffc020141a:	9db9                	addw	a1,a1,a4
ffffffffc020141c:	00015717          	auipc	a4,0x15
ffffffffc0201420:	0cb72623          	sw	a1,204(a4) # ffffffffc02164e8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201424:	0cd78163          	beq	a5,a3,ffffffffc02014e6 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201428:	fe878713          	addi	a4,a5,-24
ffffffffc020142c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020142e:	4801                	li	a6,0
ffffffffc0201430:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201434:	00e56a63          	bltu	a0,a4,ffffffffc0201448 <default_free_pages+0x90>
    return listelm->next;
ffffffffc0201438:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020143a:	04d70f63          	beq	a4,a3,ffffffffc0201498 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020143e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201440:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201444:	fee57ae3          	bleu	a4,a0,ffffffffc0201438 <default_free_pages+0x80>
ffffffffc0201448:	00080663          	beqz	a6,ffffffffc0201454 <default_free_pages+0x9c>
ffffffffc020144c:	00015817          	auipc	a6,0x15
ffffffffc0201450:	08b83623          	sd	a1,140(a6) # ffffffffc02164d8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201454:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201456:	e390                	sd	a2,0(a5)
ffffffffc0201458:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020145a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020145c:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc020145e:	06d58a63          	beq	a1,a3,ffffffffc02014d2 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc0201462:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201466:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc020146a:	02061793          	slli	a5,a2,0x20
ffffffffc020146e:	83e9                	srli	a5,a5,0x1a
ffffffffc0201470:	97ba                	add	a5,a5,a4
ffffffffc0201472:	04f51b63          	bne	a0,a5,ffffffffc02014c8 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc0201476:	491c                	lw	a5,16(a0)
ffffffffc0201478:	9e3d                	addw	a2,a2,a5
ffffffffc020147a:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020147e:	57f5                	li	a5,-3
ffffffffc0201480:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201484:	01853803          	ld	a6,24(a0)
ffffffffc0201488:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc020148a:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020148c:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0201490:	659c                	ld	a5,8(a1)
ffffffffc0201492:	01063023          	sd	a6,0(a2)
ffffffffc0201496:	a815                	j	ffffffffc02014ca <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0201498:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020149a:	f114                	sd	a3,32(a0)
ffffffffc020149c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020149e:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02014a0:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02014a2:	00d70563          	beq	a4,a3,ffffffffc02014ac <default_free_pages+0xf4>
ffffffffc02014a6:	4805                	li	a6,1
ffffffffc02014a8:	87ba                	mv	a5,a4
ffffffffc02014aa:	bf59                	j	ffffffffc0201440 <default_free_pages+0x88>
ffffffffc02014ac:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02014ae:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02014b0:	00d78d63          	beq	a5,a3,ffffffffc02014ca <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc02014b4:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02014b8:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02014bc:	02061793          	slli	a5,a2,0x20
ffffffffc02014c0:	83e9                	srli	a5,a5,0x1a
ffffffffc02014c2:	97ba                	add	a5,a5,a4
ffffffffc02014c4:	faf509e3          	beq	a0,a5,ffffffffc0201476 <default_free_pages+0xbe>
ffffffffc02014c8:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02014ca:	fe878713          	addi	a4,a5,-24
ffffffffc02014ce:	00d78963          	beq	a5,a3,ffffffffc02014e0 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc02014d2:	4910                	lw	a2,16(a0)
ffffffffc02014d4:	02061693          	slli	a3,a2,0x20
ffffffffc02014d8:	82e9                	srli	a3,a3,0x1a
ffffffffc02014da:	96aa                	add	a3,a3,a0
ffffffffc02014dc:	00d70e63          	beq	a4,a3,ffffffffc02014f8 <default_free_pages+0x140>
}
ffffffffc02014e0:	60a2                	ld	ra,8(sp)
ffffffffc02014e2:	0141                	addi	sp,sp,16
ffffffffc02014e4:	8082                	ret
ffffffffc02014e6:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02014e8:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02014ec:	e398                	sd	a4,0(a5)
ffffffffc02014ee:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02014f0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02014f2:	ed1c                	sd	a5,24(a0)
}
ffffffffc02014f4:	0141                	addi	sp,sp,16
ffffffffc02014f6:	8082                	ret
            base->property += p->property;
ffffffffc02014f8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02014fc:	ff078693          	addi	a3,a5,-16
ffffffffc0201500:	9e39                	addw	a2,a2,a4
ffffffffc0201502:	c910                	sw	a2,16(a0)
ffffffffc0201504:	5775                	li	a4,-3
ffffffffc0201506:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020150a:	6398                	ld	a4,0(a5)
ffffffffc020150c:	679c                	ld	a5,8(a5)
}
ffffffffc020150e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201510:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201512:	e398                	sd	a4,0(a5)
ffffffffc0201514:	0141                	addi	sp,sp,16
ffffffffc0201516:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201518:	00004697          	auipc	a3,0x4
ffffffffc020151c:	72068693          	addi	a3,a3,1824 # ffffffffc0205c38 <commands+0xbc8>
ffffffffc0201520:	00004617          	auipc	a2,0x4
ffffffffc0201524:	3c060613          	addi	a2,a2,960 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201528:	08300593          	li	a1,131
ffffffffc020152c:	00004517          	auipc	a0,0x4
ffffffffc0201530:	3cc50513          	addi	a0,a0,972 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201534:	f1dfe0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(n > 0);
ffffffffc0201538:	00004697          	auipc	a3,0x4
ffffffffc020153c:	72868693          	addi	a3,a3,1832 # ffffffffc0205c60 <commands+0xbf0>
ffffffffc0201540:	00004617          	auipc	a2,0x4
ffffffffc0201544:	3a060613          	addi	a2,a2,928 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201548:	08000593          	li	a1,128
ffffffffc020154c:	00004517          	auipc	a0,0x4
ffffffffc0201550:	3ac50513          	addi	a0,a0,940 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201554:	efdfe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201558 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201558:	c959                	beqz	a0,ffffffffc02015ee <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020155a:	00015597          	auipc	a1,0x15
ffffffffc020155e:	f7e58593          	addi	a1,a1,-130 # ffffffffc02164d8 <free_area>
ffffffffc0201562:	0105a803          	lw	a6,16(a1)
ffffffffc0201566:	862a                	mv	a2,a0
ffffffffc0201568:	02081793          	slli	a5,a6,0x20
ffffffffc020156c:	9381                	srli	a5,a5,0x20
ffffffffc020156e:	00a7ee63          	bltu	a5,a0,ffffffffc020158a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201572:	87ae                	mv	a5,a1
ffffffffc0201574:	a801                	j	ffffffffc0201584 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201576:	ff87a703          	lw	a4,-8(a5)
ffffffffc020157a:	02071693          	slli	a3,a4,0x20
ffffffffc020157e:	9281                	srli	a3,a3,0x20
ffffffffc0201580:	00c6f763          	bleu	a2,a3,ffffffffc020158e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201584:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201586:	feb798e3          	bne	a5,a1,ffffffffc0201576 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020158a:	4501                	li	a0,0
}
ffffffffc020158c:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020158e:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0201592:	dd6d                	beqz	a0,ffffffffc020158c <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201594:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201598:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc020159c:	00060e1b          	sext.w	t3,a2
ffffffffc02015a0:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02015a4:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02015a8:	02d67863          	bleu	a3,a2,ffffffffc02015d8 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc02015ac:	061a                	slli	a2,a2,0x6
ffffffffc02015ae:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc02015b0:	41c7073b          	subw	a4,a4,t3
ffffffffc02015b4:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015b6:	00860693          	addi	a3,a2,8
ffffffffc02015ba:	4709                	li	a4,2
ffffffffc02015bc:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc02015c0:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02015c4:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc02015c8:	0105a803          	lw	a6,16(a1)
ffffffffc02015cc:	e314                	sd	a3,0(a4)
ffffffffc02015ce:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc02015d2:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc02015d4:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc02015d8:	41c8083b          	subw	a6,a6,t3
ffffffffc02015dc:	00015717          	auipc	a4,0x15
ffffffffc02015e0:	f1072623          	sw	a6,-244(a4) # ffffffffc02164e8 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02015e4:	5775                	li	a4,-3
ffffffffc02015e6:	17c1                	addi	a5,a5,-16
ffffffffc02015e8:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc02015ec:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02015ee:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02015f0:	00004697          	auipc	a3,0x4
ffffffffc02015f4:	67068693          	addi	a3,a3,1648 # ffffffffc0205c60 <commands+0xbf0>
ffffffffc02015f8:	00004617          	auipc	a2,0x4
ffffffffc02015fc:	2e860613          	addi	a2,a2,744 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201600:	06200593          	li	a1,98
ffffffffc0201604:	00004517          	auipc	a0,0x4
ffffffffc0201608:	2f450513          	addi	a0,a0,756 # ffffffffc02058f8 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc020160c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020160e:	e43fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201612 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201612:	1141                	addi	sp,sp,-16
ffffffffc0201614:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201616:	c1ed                	beqz	a1,ffffffffc02016f8 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0201618:	00659693          	slli	a3,a1,0x6
ffffffffc020161c:	96aa                	add	a3,a3,a0
ffffffffc020161e:	02d50463          	beq	a0,a3,ffffffffc0201646 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201622:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0201624:	87aa                	mv	a5,a0
ffffffffc0201626:	8b05                	andi	a4,a4,1
ffffffffc0201628:	e709                	bnez	a4,ffffffffc0201632 <default_init_memmap+0x20>
ffffffffc020162a:	a07d                	j	ffffffffc02016d8 <default_init_memmap+0xc6>
ffffffffc020162c:	6798                	ld	a4,8(a5)
ffffffffc020162e:	8b05                	andi	a4,a4,1
ffffffffc0201630:	c745                	beqz	a4,ffffffffc02016d8 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc0201632:	0007a823          	sw	zero,16(a5)
ffffffffc0201636:	0007b423          	sd	zero,8(a5)
ffffffffc020163a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020163e:	04078793          	addi	a5,a5,64
ffffffffc0201642:	fed795e3          	bne	a5,a3,ffffffffc020162c <default_init_memmap+0x1a>
    base->property = n;
ffffffffc0201646:	2581                	sext.w	a1,a1
ffffffffc0201648:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020164a:	4789                	li	a5,2
ffffffffc020164c:	00850713          	addi	a4,a0,8
ffffffffc0201650:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201654:	00015697          	auipc	a3,0x15
ffffffffc0201658:	e8468693          	addi	a3,a3,-380 # ffffffffc02164d8 <free_area>
ffffffffc020165c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020165e:	669c                	ld	a5,8(a3)
ffffffffc0201660:	9db9                	addw	a1,a1,a4
ffffffffc0201662:	00015717          	auipc	a4,0x15
ffffffffc0201666:	e8b72323          	sw	a1,-378(a4) # ffffffffc02164e8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020166a:	04d78a63          	beq	a5,a3,ffffffffc02016be <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc020166e:	fe878713          	addi	a4,a5,-24
ffffffffc0201672:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201674:	4801                	li	a6,0
ffffffffc0201676:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020167a:	00e56a63          	bltu	a0,a4,ffffffffc020168e <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc020167e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201680:	02d70563          	beq	a4,a3,ffffffffc02016aa <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201684:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201686:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020168a:	fee57ae3          	bleu	a4,a0,ffffffffc020167e <default_init_memmap+0x6c>
ffffffffc020168e:	00080663          	beqz	a6,ffffffffc020169a <default_init_memmap+0x88>
ffffffffc0201692:	00015717          	auipc	a4,0x15
ffffffffc0201696:	e4b73323          	sd	a1,-442(a4) # ffffffffc02164d8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020169a:	6398                	ld	a4,0(a5)
}
ffffffffc020169c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020169e:	e390                	sd	a2,0(a5)
ffffffffc02016a0:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02016a2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016a4:	ed18                	sd	a4,24(a0)
ffffffffc02016a6:	0141                	addi	sp,sp,16
ffffffffc02016a8:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02016aa:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02016ac:	f114                	sd	a3,32(a0)
ffffffffc02016ae:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02016b0:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02016b2:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016b4:	00d70e63          	beq	a4,a3,ffffffffc02016d0 <default_init_memmap+0xbe>
ffffffffc02016b8:	4805                	li	a6,1
ffffffffc02016ba:	87ba                	mv	a5,a4
ffffffffc02016bc:	b7e9                	j	ffffffffc0201686 <default_init_memmap+0x74>
}
ffffffffc02016be:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02016c0:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02016c4:	e398                	sd	a4,0(a5)
ffffffffc02016c6:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02016c8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016ca:	ed1c                	sd	a5,24(a0)
}
ffffffffc02016cc:	0141                	addi	sp,sp,16
ffffffffc02016ce:	8082                	ret
ffffffffc02016d0:	60a2                	ld	ra,8(sp)
ffffffffc02016d2:	e290                	sd	a2,0(a3)
ffffffffc02016d4:	0141                	addi	sp,sp,16
ffffffffc02016d6:	8082                	ret
        assert(PageReserved(p));
ffffffffc02016d8:	00004697          	auipc	a3,0x4
ffffffffc02016dc:	59068693          	addi	a3,a3,1424 # ffffffffc0205c68 <commands+0xbf8>
ffffffffc02016e0:	00004617          	auipc	a2,0x4
ffffffffc02016e4:	20060613          	addi	a2,a2,512 # ffffffffc02058e0 <commands+0x870>
ffffffffc02016e8:	04900593          	li	a1,73
ffffffffc02016ec:	00004517          	auipc	a0,0x4
ffffffffc02016f0:	20c50513          	addi	a0,a0,524 # ffffffffc02058f8 <commands+0x888>
ffffffffc02016f4:	d5dfe0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(n > 0);
ffffffffc02016f8:	00004697          	auipc	a3,0x4
ffffffffc02016fc:	56868693          	addi	a3,a3,1384 # ffffffffc0205c60 <commands+0xbf0>
ffffffffc0201700:	00004617          	auipc	a2,0x4
ffffffffc0201704:	1e060613          	addi	a2,a2,480 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201708:	04600593          	li	a1,70
ffffffffc020170c:	00004517          	auipc	a0,0x4
ffffffffc0201710:	1ec50513          	addi	a0,a0,492 # ffffffffc02058f8 <commands+0x888>
ffffffffc0201714:	d3dfe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201718 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201718:	c125                	beqz	a0,ffffffffc0201778 <slob_free+0x60>
		return;

	if (size)
ffffffffc020171a:	e1a5                	bnez	a1,ffffffffc020177a <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020171c:	100027f3          	csrr	a5,sstatus
ffffffffc0201720:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201722:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201724:	e3bd                	bnez	a5,ffffffffc020178a <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201726:	0000a797          	auipc	a5,0xa
ffffffffc020172a:	92a78793          	addi	a5,a5,-1750 # ffffffffc020b050 <slobfree>
ffffffffc020172e:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201730:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201732:	00a7fa63          	bleu	a0,a5,ffffffffc0201746 <slob_free+0x2e>
ffffffffc0201736:	00e56c63          	bltu	a0,a4,ffffffffc020174e <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020173a:	00e7fa63          	bleu	a4,a5,ffffffffc020174e <slob_free+0x36>
    return 0;
ffffffffc020173e:	87ba                	mv	a5,a4
ffffffffc0201740:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201742:	fea7eae3          	bltu	a5,a0,ffffffffc0201736 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201746:	fee7ece3          	bltu	a5,a4,ffffffffc020173e <slob_free+0x26>
ffffffffc020174a:	fee57ae3          	bleu	a4,a0,ffffffffc020173e <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc020174e:	4110                	lw	a2,0(a0)
ffffffffc0201750:	00461693          	slli	a3,a2,0x4
ffffffffc0201754:	96aa                	add	a3,a3,a0
ffffffffc0201756:	08d70b63          	beq	a4,a3,ffffffffc02017ec <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc020175a:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc020175c:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc020175e:	00469713          	slli	a4,a3,0x4
ffffffffc0201762:	973e                	add	a4,a4,a5
ffffffffc0201764:	08e50f63          	beq	a0,a4,ffffffffc0201802 <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201768:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc020176a:	0000a717          	auipc	a4,0xa
ffffffffc020176e:	8ef73323          	sd	a5,-1818(a4) # ffffffffc020b050 <slobfree>
    if (flag)
ffffffffc0201772:	c199                	beqz	a1,ffffffffc0201778 <slob_free+0x60>
        intr_enable();
ffffffffc0201774:	e5ffe06f          	j	ffffffffc02005d2 <intr_enable>
ffffffffc0201778:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc020177a:	05bd                	addi	a1,a1,15
ffffffffc020177c:	8191                	srli	a1,a1,0x4
ffffffffc020177e:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201780:	100027f3          	csrr	a5,sstatus
ffffffffc0201784:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201786:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201788:	dfd9                	beqz	a5,ffffffffc0201726 <slob_free+0xe>
{
ffffffffc020178a:	1101                	addi	sp,sp,-32
ffffffffc020178c:	e42a                	sd	a0,8(sp)
ffffffffc020178e:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201790:	e49fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201794:	0000a797          	auipc	a5,0xa
ffffffffc0201798:	8bc78793          	addi	a5,a5,-1860 # ffffffffc020b050 <slobfree>
ffffffffc020179c:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc020179e:	6522                	ld	a0,8(sp)
ffffffffc02017a0:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02017a2:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02017a4:	00a7fa63          	bleu	a0,a5,ffffffffc02017b8 <slob_free+0xa0>
ffffffffc02017a8:	00e56c63          	bltu	a0,a4,ffffffffc02017c0 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02017ac:	00e7fa63          	bleu	a4,a5,ffffffffc02017c0 <slob_free+0xa8>
    return 0;
ffffffffc02017b0:	87ba                	mv	a5,a4
ffffffffc02017b2:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02017b4:	fea7eae3          	bltu	a5,a0,ffffffffc02017a8 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02017b8:	fee7ece3          	bltu	a5,a4,ffffffffc02017b0 <slob_free+0x98>
ffffffffc02017bc:	fee57ae3          	bleu	a4,a0,ffffffffc02017b0 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc02017c0:	4110                	lw	a2,0(a0)
ffffffffc02017c2:	00461693          	slli	a3,a2,0x4
ffffffffc02017c6:	96aa                	add	a3,a3,a0
ffffffffc02017c8:	04d70763          	beq	a4,a3,ffffffffc0201816 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc02017cc:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02017ce:	4394                	lw	a3,0(a5)
ffffffffc02017d0:	00469713          	slli	a4,a3,0x4
ffffffffc02017d4:	973e                	add	a4,a4,a5
ffffffffc02017d6:	04e50663          	beq	a0,a4,ffffffffc0201822 <slob_free+0x10a>
		cur->next = b;
ffffffffc02017da:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc02017dc:	0000a717          	auipc	a4,0xa
ffffffffc02017e0:	86f73a23          	sd	a5,-1932(a4) # ffffffffc020b050 <slobfree>
    if (flag)
ffffffffc02017e4:	e58d                	bnez	a1,ffffffffc020180e <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02017e6:	60e2                	ld	ra,24(sp)
ffffffffc02017e8:	6105                	addi	sp,sp,32
ffffffffc02017ea:	8082                	ret
		b->units += cur->next->units;
ffffffffc02017ec:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02017ee:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc02017f0:	9e35                	addw	a2,a2,a3
ffffffffc02017f2:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc02017f4:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc02017f6:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02017f8:	00469713          	slli	a4,a3,0x4
ffffffffc02017fc:	973e                	add	a4,a4,a5
ffffffffc02017fe:	f6e515e3          	bne	a0,a4,ffffffffc0201768 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201802:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201804:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201806:	9eb9                	addw	a3,a3,a4
ffffffffc0201808:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc020180a:	e790                	sd	a2,8(a5)
ffffffffc020180c:	bfb9                	j	ffffffffc020176a <slob_free+0x52>
}
ffffffffc020180e:	60e2                	ld	ra,24(sp)
ffffffffc0201810:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201812:	dc1fe06f          	j	ffffffffc02005d2 <intr_enable>
		b->units += cur->next->units;
ffffffffc0201816:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201818:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc020181a:	9e35                	addw	a2,a2,a3
ffffffffc020181c:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc020181e:	e518                	sd	a4,8(a0)
ffffffffc0201820:	b77d                	j	ffffffffc02017ce <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0201822:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201824:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201826:	9eb9                	addw	a3,a3,a4
ffffffffc0201828:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc020182a:	e790                	sd	a2,8(a5)
ffffffffc020182c:	bf45                	j	ffffffffc02017dc <slob_free+0xc4>

ffffffffc020182e <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc020182e:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201830:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201832:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201836:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201838:	38a000ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
  if(!page)
ffffffffc020183c:	c139                	beqz	a0,ffffffffc0201882 <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc020183e:	00015797          	auipc	a5,0x15
ffffffffc0201842:	cca78793          	addi	a5,a5,-822 # ffffffffc0216508 <pages>
ffffffffc0201846:	6394                	ld	a3,0(a5)
ffffffffc0201848:	00006797          	auipc	a5,0x6
ffffffffc020184c:	82078793          	addi	a5,a5,-2016 # ffffffffc0207068 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201850:	00015717          	auipc	a4,0x15
ffffffffc0201854:	c4870713          	addi	a4,a4,-952 # ffffffffc0216498 <npage>
    return page - pages + nbase;
ffffffffc0201858:	40d506b3          	sub	a3,a0,a3
ffffffffc020185c:	6388                	ld	a0,0(a5)
ffffffffc020185e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201860:	57fd                	li	a5,-1
ffffffffc0201862:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0201864:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0201866:	83b1                	srli	a5,a5,0xc
ffffffffc0201868:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020186a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020186c:	00e7ff63          	bleu	a4,a5,ffffffffc020188a <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0201870:	00015797          	auipc	a5,0x15
ffffffffc0201874:	c8878793          	addi	a5,a5,-888 # ffffffffc02164f8 <va_pa_offset>
ffffffffc0201878:	6388                	ld	a0,0(a5)
}
ffffffffc020187a:	60a2                	ld	ra,8(sp)
ffffffffc020187c:	9536                	add	a0,a0,a3
ffffffffc020187e:	0141                	addi	sp,sp,16
ffffffffc0201880:	8082                	ret
ffffffffc0201882:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0201884:	4501                	li	a0,0
}
ffffffffc0201886:	0141                	addi	sp,sp,16
ffffffffc0201888:	8082                	ret
ffffffffc020188a:	00004617          	auipc	a2,0x4
ffffffffc020188e:	43e60613          	addi	a2,a2,1086 # ffffffffc0205cc8 <default_pmm_manager+0x50>
ffffffffc0201892:	08b00593          	li	a1,139
ffffffffc0201896:	00004517          	auipc	a0,0x4
ffffffffc020189a:	45a50513          	addi	a0,a0,1114 # ffffffffc0205cf0 <default_pmm_manager+0x78>
ffffffffc020189e:	bb3fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02018a2 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02018a2:	7179                	addi	sp,sp,-48
ffffffffc02018a4:	f406                	sd	ra,40(sp)
ffffffffc02018a6:	f022                	sd	s0,32(sp)
ffffffffc02018a8:	ec26                	sd	s1,24(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02018aa:	01050713          	addi	a4,a0,16
ffffffffc02018ae:	6785                	lui	a5,0x1
ffffffffc02018b0:	0cf77b63          	bleu	a5,a4,ffffffffc0201986 <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02018b4:	00f50413          	addi	s0,a0,15
ffffffffc02018b8:	8011                	srli	s0,s0,0x4
ffffffffc02018ba:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02018bc:	10002673          	csrr	a2,sstatus
ffffffffc02018c0:	8a09                	andi	a2,a2,2
ffffffffc02018c2:	ea5d                	bnez	a2,ffffffffc0201978 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc02018c4:	00009497          	auipc	s1,0x9
ffffffffc02018c8:	78c48493          	addi	s1,s1,1932 # ffffffffc020b050 <slobfree>
ffffffffc02018cc:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02018ce:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02018d0:	4398                	lw	a4,0(a5)
ffffffffc02018d2:	0a875763          	ble	s0,a4,ffffffffc0201980 <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc02018d6:	00f68a63          	beq	a3,a5,ffffffffc02018ea <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02018da:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02018dc:	4118                	lw	a4,0(a0)
ffffffffc02018de:	02875763          	ble	s0,a4,ffffffffc020190c <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc02018e2:	6094                	ld	a3,0(s1)
ffffffffc02018e4:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc02018e6:	fef69ae3          	bne	a3,a5,ffffffffc02018da <slob_alloc.isra.1.constprop.3+0x38>
    if (flag)
ffffffffc02018ea:	ea39                	bnez	a2,ffffffffc0201940 <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02018ec:	4501                	li	a0,0
ffffffffc02018ee:	f41ff0ef          	jal	ra,ffffffffc020182e <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc02018f2:	cd29                	beqz	a0,ffffffffc020194c <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc02018f4:	6585                	lui	a1,0x1
ffffffffc02018f6:	e23ff0ef          	jal	ra,ffffffffc0201718 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02018fa:	10002673          	csrr	a2,sstatus
ffffffffc02018fe:	8a09                	andi	a2,a2,2
ffffffffc0201900:	ea1d                	bnez	a2,ffffffffc0201936 <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc0201902:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201904:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201906:	4118                	lw	a4,0(a0)
ffffffffc0201908:	fc874de3          	blt	a4,s0,ffffffffc02018e2 <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc020190c:	04e40663          	beq	s0,a4,ffffffffc0201958 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0201910:	00441693          	slli	a3,s0,0x4
ffffffffc0201914:	96aa                	add	a3,a3,a0
ffffffffc0201916:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201918:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc020191a:	9f01                	subw	a4,a4,s0
ffffffffc020191c:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc020191e:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201920:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc0201922:	00009717          	auipc	a4,0x9
ffffffffc0201926:	72f73723          	sd	a5,1838(a4) # ffffffffc020b050 <slobfree>
    if (flag)
ffffffffc020192a:	ee15                	bnez	a2,ffffffffc0201966 <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc020192c:	70a2                	ld	ra,40(sp)
ffffffffc020192e:	7402                	ld	s0,32(sp)
ffffffffc0201930:	64e2                	ld	s1,24(sp)
ffffffffc0201932:	6145                	addi	sp,sp,48
ffffffffc0201934:	8082                	ret
        intr_disable();
ffffffffc0201936:	ca3fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc020193a:	4605                	li	a2,1
			cur = slobfree;
ffffffffc020193c:	609c                	ld	a5,0(s1)
ffffffffc020193e:	b7d9                	j	ffffffffc0201904 <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0201940:	c93fe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201944:	4501                	li	a0,0
ffffffffc0201946:	ee9ff0ef          	jal	ra,ffffffffc020182e <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc020194a:	f54d                	bnez	a0,ffffffffc02018f4 <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc020194c:	70a2                	ld	ra,40(sp)
ffffffffc020194e:	7402                	ld	s0,32(sp)
ffffffffc0201950:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0201952:	4501                	li	a0,0
}
ffffffffc0201954:	6145                	addi	sp,sp,48
ffffffffc0201956:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201958:	6518                	ld	a4,8(a0)
ffffffffc020195a:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc020195c:	00009717          	auipc	a4,0x9
ffffffffc0201960:	6ef73a23          	sd	a5,1780(a4) # ffffffffc020b050 <slobfree>
    if (flag)
ffffffffc0201964:	d661                	beqz	a2,ffffffffc020192c <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0201966:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201968:	c6bfe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
}
ffffffffc020196c:	70a2                	ld	ra,40(sp)
ffffffffc020196e:	7402                	ld	s0,32(sp)
ffffffffc0201970:	6522                	ld	a0,8(sp)
ffffffffc0201972:	64e2                	ld	s1,24(sp)
ffffffffc0201974:	6145                	addi	sp,sp,48
ffffffffc0201976:	8082                	ret
        intr_disable();
ffffffffc0201978:	c61fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc020197c:	4605                	li	a2,1
ffffffffc020197e:	b799                	j	ffffffffc02018c4 <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201980:	853e                	mv	a0,a5
ffffffffc0201982:	87b6                	mv	a5,a3
ffffffffc0201984:	b761                	j	ffffffffc020190c <slob_alloc.isra.1.constprop.3+0x6a>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201986:	00004697          	auipc	a3,0x4
ffffffffc020198a:	3e268693          	addi	a3,a3,994 # ffffffffc0205d68 <default_pmm_manager+0xf0>
ffffffffc020198e:	00004617          	auipc	a2,0x4
ffffffffc0201992:	f5260613          	addi	a2,a2,-174 # ffffffffc02058e0 <commands+0x870>
ffffffffc0201996:	06300593          	li	a1,99
ffffffffc020199a:	00004517          	auipc	a0,0x4
ffffffffc020199e:	3ee50513          	addi	a0,a0,1006 # ffffffffc0205d88 <default_pmm_manager+0x110>
ffffffffc02019a2:	aaffe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02019a6 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc02019a6:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc02019a8:	00004517          	auipc	a0,0x4
ffffffffc02019ac:	3f850513          	addi	a0,a0,1016 # ffffffffc0205da0 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc02019b0:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc02019b2:	fdcfe0ef          	jal	ra,ffffffffc020018e <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02019b6:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02019b8:	00004517          	auipc	a0,0x4
ffffffffc02019bc:	39050513          	addi	a0,a0,912 # ffffffffc0205d48 <default_pmm_manager+0xd0>
}
ffffffffc02019c0:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02019c2:	fccfe06f          	j	ffffffffc020018e <cprintf>

ffffffffc02019c6 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc02019c6:	1101                	addi	sp,sp,-32
ffffffffc02019c8:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02019ca:	6905                	lui	s2,0x1
{
ffffffffc02019cc:	e822                	sd	s0,16(sp)
ffffffffc02019ce:	ec06                	sd	ra,24(sp)
ffffffffc02019d0:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02019d2:	fef90793          	addi	a5,s2,-17 # fef <BASE_ADDRESS-0xffffffffc01ff011>
{
ffffffffc02019d6:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02019d8:	04a7fc63          	bleu	a0,a5,ffffffffc0201a30 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02019dc:	4561                	li	a0,24
ffffffffc02019de:	ec5ff0ef          	jal	ra,ffffffffc02018a2 <slob_alloc.isra.1.constprop.3>
ffffffffc02019e2:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02019e4:	cd21                	beqz	a0,ffffffffc0201a3c <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc02019e6:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02019ea:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc02019ec:	00f95763          	ble	a5,s2,ffffffffc02019fa <kmalloc+0x34>
ffffffffc02019f0:	6705                	lui	a4,0x1
ffffffffc02019f2:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02019f4:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc02019f6:	fef74ee3          	blt	a4,a5,ffffffffc02019f2 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc02019fa:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc02019fc:	e33ff0ef          	jal	ra,ffffffffc020182e <__slob_get_free_pages.isra.0>
ffffffffc0201a00:	e488                	sd	a0,8(s1)
ffffffffc0201a02:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201a04:	c935                	beqz	a0,ffffffffc0201a78 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201a06:	100027f3          	csrr	a5,sstatus
ffffffffc0201a0a:	8b89                	andi	a5,a5,2
ffffffffc0201a0c:	e3a1                	bnez	a5,ffffffffc0201a4c <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201a0e:	00015797          	auipc	a5,0x15
ffffffffc0201a12:	a7a78793          	addi	a5,a5,-1414 # ffffffffc0216488 <bigblocks>
ffffffffc0201a16:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201a18:	00015717          	auipc	a4,0x15
ffffffffc0201a1c:	a6973823          	sd	s1,-1424(a4) # ffffffffc0216488 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201a20:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201a22:	8522                	mv	a0,s0
ffffffffc0201a24:	60e2                	ld	ra,24(sp)
ffffffffc0201a26:	6442                	ld	s0,16(sp)
ffffffffc0201a28:	64a2                	ld	s1,8(sp)
ffffffffc0201a2a:	6902                	ld	s2,0(sp)
ffffffffc0201a2c:	6105                	addi	sp,sp,32
ffffffffc0201a2e:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201a30:	0541                	addi	a0,a0,16
ffffffffc0201a32:	e71ff0ef          	jal	ra,ffffffffc02018a2 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201a36:	01050413          	addi	s0,a0,16
ffffffffc0201a3a:	f565                	bnez	a0,ffffffffc0201a22 <kmalloc+0x5c>
ffffffffc0201a3c:	4401                	li	s0,0
}
ffffffffc0201a3e:	8522                	mv	a0,s0
ffffffffc0201a40:	60e2                	ld	ra,24(sp)
ffffffffc0201a42:	6442                	ld	s0,16(sp)
ffffffffc0201a44:	64a2                	ld	s1,8(sp)
ffffffffc0201a46:	6902                	ld	s2,0(sp)
ffffffffc0201a48:	6105                	addi	sp,sp,32
ffffffffc0201a4a:	8082                	ret
        intr_disable();
ffffffffc0201a4c:	b8dfe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201a50:	00015797          	auipc	a5,0x15
ffffffffc0201a54:	a3878793          	addi	a5,a5,-1480 # ffffffffc0216488 <bigblocks>
ffffffffc0201a58:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201a5a:	00015717          	auipc	a4,0x15
ffffffffc0201a5e:	a2973723          	sd	s1,-1490(a4) # ffffffffc0216488 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201a62:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201a64:	b6ffe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
ffffffffc0201a68:	6480                	ld	s0,8(s1)
}
ffffffffc0201a6a:	60e2                	ld	ra,24(sp)
ffffffffc0201a6c:	64a2                	ld	s1,8(sp)
ffffffffc0201a6e:	8522                	mv	a0,s0
ffffffffc0201a70:	6442                	ld	s0,16(sp)
ffffffffc0201a72:	6902                	ld	s2,0(sp)
ffffffffc0201a74:	6105                	addi	sp,sp,32
ffffffffc0201a76:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201a78:	45e1                	li	a1,24
ffffffffc0201a7a:	8526                	mv	a0,s1
ffffffffc0201a7c:	c9dff0ef          	jal	ra,ffffffffc0201718 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201a80:	b74d                	j	ffffffffc0201a22 <kmalloc+0x5c>

ffffffffc0201a82 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201a82:	c175                	beqz	a0,ffffffffc0201b66 <kfree+0xe4>
{
ffffffffc0201a84:	1101                	addi	sp,sp,-32
ffffffffc0201a86:	e426                	sd	s1,8(sp)
ffffffffc0201a88:	ec06                	sd	ra,24(sp)
ffffffffc0201a8a:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201a8c:	03451793          	slli	a5,a0,0x34
ffffffffc0201a90:	84aa                	mv	s1,a0
ffffffffc0201a92:	eb8d                	bnez	a5,ffffffffc0201ac4 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201a94:	100027f3          	csrr	a5,sstatus
ffffffffc0201a98:	8b89                	andi	a5,a5,2
ffffffffc0201a9a:	efc9                	bnez	a5,ffffffffc0201b34 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201a9c:	00015797          	auipc	a5,0x15
ffffffffc0201aa0:	9ec78793          	addi	a5,a5,-1556 # ffffffffc0216488 <bigblocks>
ffffffffc0201aa4:	6394                	ld	a3,0(a5)
ffffffffc0201aa6:	ce99                	beqz	a3,ffffffffc0201ac4 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201aa8:	669c                	ld	a5,8(a3)
ffffffffc0201aaa:	6a80                	ld	s0,16(a3)
ffffffffc0201aac:	0af50e63          	beq	a0,a5,ffffffffc0201b68 <kfree+0xe6>
    return 0;
ffffffffc0201ab0:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201ab2:	c801                	beqz	s0,ffffffffc0201ac2 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201ab4:	6418                	ld	a4,8(s0)
ffffffffc0201ab6:	681c                	ld	a5,16(s0)
ffffffffc0201ab8:	00970f63          	beq	a4,s1,ffffffffc0201ad6 <kfree+0x54>
ffffffffc0201abc:	86a2                	mv	a3,s0
ffffffffc0201abe:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201ac0:	f875                	bnez	s0,ffffffffc0201ab4 <kfree+0x32>
    if (flag)
ffffffffc0201ac2:	e659                	bnez	a2,ffffffffc0201b50 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201ac4:	6442                	ld	s0,16(sp)
ffffffffc0201ac6:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201ac8:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201acc:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201ace:	4581                	li	a1,0
}
ffffffffc0201ad0:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201ad2:	c47ff06f          	j	ffffffffc0201718 <slob_free>
				*last = bb->next;
ffffffffc0201ad6:	ea9c                	sd	a5,16(a3)
ffffffffc0201ad8:	e641                	bnez	a2,ffffffffc0201b60 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0201ada:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201ade:	4018                	lw	a4,0(s0)
ffffffffc0201ae0:	08f4ea63          	bltu	s1,a5,ffffffffc0201b74 <kfree+0xf2>
ffffffffc0201ae4:	00015797          	auipc	a5,0x15
ffffffffc0201ae8:	a1478793          	addi	a5,a5,-1516 # ffffffffc02164f8 <va_pa_offset>
ffffffffc0201aec:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201aee:	00015797          	auipc	a5,0x15
ffffffffc0201af2:	9aa78793          	addi	a5,a5,-1622 # ffffffffc0216498 <npage>
ffffffffc0201af6:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201af8:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201afa:	80b1                	srli	s1,s1,0xc
ffffffffc0201afc:	08f4f963          	bleu	a5,s1,ffffffffc0201b8e <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b00:	00005797          	auipc	a5,0x5
ffffffffc0201b04:	56878793          	addi	a5,a5,1384 # ffffffffc0207068 <nbase>
ffffffffc0201b08:	639c                	ld	a5,0(a5)
ffffffffc0201b0a:	00015697          	auipc	a3,0x15
ffffffffc0201b0e:	9fe68693          	addi	a3,a3,-1538 # ffffffffc0216508 <pages>
ffffffffc0201b12:	6288                	ld	a0,0(a3)
ffffffffc0201b14:	8c9d                	sub	s1,s1,a5
ffffffffc0201b16:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201b18:	4585                	li	a1,1
ffffffffc0201b1a:	9526                	add	a0,a0,s1
ffffffffc0201b1c:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201b20:	12a000ef          	jal	ra,ffffffffc0201c4a <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b24:	8522                	mv	a0,s0
}
ffffffffc0201b26:	6442                	ld	s0,16(sp)
ffffffffc0201b28:	60e2                	ld	ra,24(sp)
ffffffffc0201b2a:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b2c:	45e1                	li	a1,24
}
ffffffffc0201b2e:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b30:	be9ff06f          	j	ffffffffc0201718 <slob_free>
        intr_disable();
ffffffffc0201b34:	aa5fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201b38:	00015797          	auipc	a5,0x15
ffffffffc0201b3c:	95078793          	addi	a5,a5,-1712 # ffffffffc0216488 <bigblocks>
ffffffffc0201b40:	6394                	ld	a3,0(a5)
ffffffffc0201b42:	c699                	beqz	a3,ffffffffc0201b50 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0201b44:	669c                	ld	a5,8(a3)
ffffffffc0201b46:	6a80                	ld	s0,16(a3)
ffffffffc0201b48:	00f48763          	beq	s1,a5,ffffffffc0201b56 <kfree+0xd4>
        return 1;
ffffffffc0201b4c:	4605                	li	a2,1
ffffffffc0201b4e:	b795                	j	ffffffffc0201ab2 <kfree+0x30>
        intr_enable();
ffffffffc0201b50:	a83fe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
ffffffffc0201b54:	bf85                	j	ffffffffc0201ac4 <kfree+0x42>
				*last = bb->next;
ffffffffc0201b56:	00015797          	auipc	a5,0x15
ffffffffc0201b5a:	9287b923          	sd	s0,-1742(a5) # ffffffffc0216488 <bigblocks>
ffffffffc0201b5e:	8436                	mv	s0,a3
ffffffffc0201b60:	a73fe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
ffffffffc0201b64:	bf9d                	j	ffffffffc0201ada <kfree+0x58>
ffffffffc0201b66:	8082                	ret
ffffffffc0201b68:	00015797          	auipc	a5,0x15
ffffffffc0201b6c:	9287b023          	sd	s0,-1760(a5) # ffffffffc0216488 <bigblocks>
ffffffffc0201b70:	8436                	mv	s0,a3
ffffffffc0201b72:	b7a5                	j	ffffffffc0201ada <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0201b74:	86a6                	mv	a3,s1
ffffffffc0201b76:	00004617          	auipc	a2,0x4
ffffffffc0201b7a:	18a60613          	addi	a2,a2,394 # ffffffffc0205d00 <default_pmm_manager+0x88>
ffffffffc0201b7e:	09400593          	li	a1,148
ffffffffc0201b82:	00004517          	auipc	a0,0x4
ffffffffc0201b86:	16e50513          	addi	a0,a0,366 # ffffffffc0205cf0 <default_pmm_manager+0x78>
ffffffffc0201b8a:	8c7fe0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201b8e:	00004617          	auipc	a2,0x4
ffffffffc0201b92:	19a60613          	addi	a2,a2,410 # ffffffffc0205d28 <default_pmm_manager+0xb0>
ffffffffc0201b96:	08000593          	li	a1,128
ffffffffc0201b9a:	00004517          	auipc	a0,0x4
ffffffffc0201b9e:	15650513          	addi	a0,a0,342 # ffffffffc0205cf0 <default_pmm_manager+0x78>
ffffffffc0201ba2:	8affe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201ba6 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201ba6:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201ba8:	00004617          	auipc	a2,0x4
ffffffffc0201bac:	18060613          	addi	a2,a2,384 # ffffffffc0205d28 <default_pmm_manager+0xb0>
ffffffffc0201bb0:	08000593          	li	a1,128
ffffffffc0201bb4:	00004517          	auipc	a0,0x4
ffffffffc0201bb8:	13c50513          	addi	a0,a0,316 # ffffffffc0205cf0 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201bbc:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201bbe:	893fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201bc2 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201bc2:	715d                	addi	sp,sp,-80
ffffffffc0201bc4:	e0a2                	sd	s0,64(sp)
ffffffffc0201bc6:	fc26                	sd	s1,56(sp)
ffffffffc0201bc8:	f84a                	sd	s2,48(sp)
ffffffffc0201bca:	f44e                	sd	s3,40(sp)
ffffffffc0201bcc:	f052                	sd	s4,32(sp)
ffffffffc0201bce:	ec56                	sd	s5,24(sp)
ffffffffc0201bd0:	e486                	sd	ra,72(sp)
ffffffffc0201bd2:	842a                	mv	s0,a0
ffffffffc0201bd4:	00015497          	auipc	s1,0x15
ffffffffc0201bd8:	91c48493          	addi	s1,s1,-1764 # ffffffffc02164f0 <pmm_manager>
        // pmm_init的时候swap_init_ok为0，所以不会执行下面的代码
        // 进行到swap_init的时候，swap_init_ok为1，所以会执行下面的代码
        //如果有足够的物理页面，就不必换出其他页面
        //如果n>1, 说明希望分配多个连续的页面，但是我们换出页面的时候并不能换出连续的页面
 		//swap_init_ok标志是否成功初始化了
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201bdc:	4985                	li	s3,1
ffffffffc0201bde:	00015a17          	auipc	s4,0x15
ffffffffc0201be2:	8caa0a13          	addi	s4,s4,-1846 # ffffffffc02164a8 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201be6:	0005091b          	sext.w	s2,a0
ffffffffc0201bea:	00015a97          	auipc	s5,0x15
ffffffffc0201bee:	9fea8a93          	addi	s5,s5,-1538 # ffffffffc02165e8 <check_mm_struct>
ffffffffc0201bf2:	a00d                	j	ffffffffc0201c14 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201bf4:	609c                	ld	a5,0(s1)
ffffffffc0201bf6:	6f9c                	ld	a5,24(a5)
ffffffffc0201bf8:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201bfa:	4601                	li	a2,0
ffffffffc0201bfc:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201bfe:	ed0d                	bnez	a0,ffffffffc0201c38 <alloc_pages+0x76>
ffffffffc0201c00:	0289ec63          	bltu	s3,s0,ffffffffc0201c38 <alloc_pages+0x76>
ffffffffc0201c04:	000a2783          	lw	a5,0(s4)
ffffffffc0201c08:	2781                	sext.w	a5,a5
ffffffffc0201c0a:	c79d                	beqz	a5,ffffffffc0201c38 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201c0c:	000ab503          	ld	a0,0(s5)
ffffffffc0201c10:	6dc010ef          	jal	ra,ffffffffc02032ec <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c14:	100027f3          	csrr	a5,sstatus
ffffffffc0201c18:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201c1a:	8522                	mv	a0,s0
ffffffffc0201c1c:	dfe1                	beqz	a5,ffffffffc0201bf4 <alloc_pages+0x32>
        intr_disable();
ffffffffc0201c1e:	9bbfe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc0201c22:	609c                	ld	a5,0(s1)
ffffffffc0201c24:	8522                	mv	a0,s0
ffffffffc0201c26:	6f9c                	ld	a5,24(a5)
ffffffffc0201c28:	9782                	jalr	a5
ffffffffc0201c2a:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201c2c:	9a7fe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
ffffffffc0201c30:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201c32:	4601                	li	a2,0
ffffffffc0201c34:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201c36:	d569                	beqz	a0,ffffffffc0201c00 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201c38:	60a6                	ld	ra,72(sp)
ffffffffc0201c3a:	6406                	ld	s0,64(sp)
ffffffffc0201c3c:	74e2                	ld	s1,56(sp)
ffffffffc0201c3e:	7942                	ld	s2,48(sp)
ffffffffc0201c40:	79a2                	ld	s3,40(sp)
ffffffffc0201c42:	7a02                	ld	s4,32(sp)
ffffffffc0201c44:	6ae2                	ld	s5,24(sp)
ffffffffc0201c46:	6161                	addi	sp,sp,80
ffffffffc0201c48:	8082                	ret

ffffffffc0201c4a <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c4a:	100027f3          	csrr	a5,sstatus
ffffffffc0201c4e:	8b89                	andi	a5,a5,2
ffffffffc0201c50:	eb89                	bnez	a5,ffffffffc0201c62 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201c52:	00015797          	auipc	a5,0x15
ffffffffc0201c56:	89e78793          	addi	a5,a5,-1890 # ffffffffc02164f0 <pmm_manager>
ffffffffc0201c5a:	639c                	ld	a5,0(a5)
ffffffffc0201c5c:	0207b303          	ld	t1,32(a5)
ffffffffc0201c60:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201c62:	1101                	addi	sp,sp,-32
ffffffffc0201c64:	ec06                	sd	ra,24(sp)
ffffffffc0201c66:	e822                	sd	s0,16(sp)
ffffffffc0201c68:	e426                	sd	s1,8(sp)
ffffffffc0201c6a:	842a                	mv	s0,a0
ffffffffc0201c6c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201c6e:	96bfe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201c72:	00015797          	auipc	a5,0x15
ffffffffc0201c76:	87e78793          	addi	a5,a5,-1922 # ffffffffc02164f0 <pmm_manager>
ffffffffc0201c7a:	639c                	ld	a5,0(a5)
ffffffffc0201c7c:	85a6                	mv	a1,s1
ffffffffc0201c7e:	8522                	mv	a0,s0
ffffffffc0201c80:	739c                	ld	a5,32(a5)
ffffffffc0201c82:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201c84:	6442                	ld	s0,16(sp)
ffffffffc0201c86:	60e2                	ld	ra,24(sp)
ffffffffc0201c88:	64a2                	ld	s1,8(sp)
ffffffffc0201c8a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201c8c:	947fe06f          	j	ffffffffc02005d2 <intr_enable>

ffffffffc0201c90 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c90:	100027f3          	csrr	a5,sstatus
ffffffffc0201c94:	8b89                	andi	a5,a5,2
ffffffffc0201c96:	eb89                	bnez	a5,ffffffffc0201ca8 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201c98:	00015797          	auipc	a5,0x15
ffffffffc0201c9c:	85878793          	addi	a5,a5,-1960 # ffffffffc02164f0 <pmm_manager>
ffffffffc0201ca0:	639c                	ld	a5,0(a5)
ffffffffc0201ca2:	0287b303          	ld	t1,40(a5)
ffffffffc0201ca6:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201ca8:	1141                	addi	sp,sp,-16
ffffffffc0201caa:	e406                	sd	ra,8(sp)
ffffffffc0201cac:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201cae:	92bfe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201cb2:	00015797          	auipc	a5,0x15
ffffffffc0201cb6:	83e78793          	addi	a5,a5,-1986 # ffffffffc02164f0 <pmm_manager>
ffffffffc0201cba:	639c                	ld	a5,0(a5)
ffffffffc0201cbc:	779c                	ld	a5,40(a5)
ffffffffc0201cbe:	9782                	jalr	a5
ffffffffc0201cc0:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201cc2:	911fe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201cc6:	8522                	mv	a0,s0
ffffffffc0201cc8:	60a2                	ld	ra,8(sp)
ffffffffc0201cca:	6402                	ld	s0,0(sp)
ffffffffc0201ccc:	0141                	addi	sp,sp,16
ffffffffc0201cce:	8082                	ret

ffffffffc0201cd0 <get_pte>:
// 参数：
//  pgdir：PDT的内核虚拟基地址
//  la：需要映射的线性地址
//  create：一个逻辑值，用于决定是否为PT分配一个Page
//  返回值：此PTE的内核虚拟地址
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201cd0:	7139                	addi	sp,sp,-64
ffffffffc0201cd2:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201cd4:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201cd8:	1ff4f493          	andi	s1,s1,511
ffffffffc0201cdc:	048e                	slli	s1,s1,0x3
ffffffffc0201cde:	94aa                	add	s1,s1,a0
    //找到对应的Giga Page
    // 先解析线性地址（虚拟地址各个位）找到页目录表中的索引
    // &pgdir[PDX1(la)] 表示页目录表中索引为 PDX1(la) 的条目的地址
    if (!(*pdep1 & PTE_V)) { // 如果该条目不存在（PTE_Valid信号为0 如果下一级页表不存在，那就给它分配一页，创造新页表
ffffffffc0201ce0:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201ce2:	f04a                	sd	s2,32(sp)
ffffffffc0201ce4:	ec4e                	sd	s3,24(sp)
ffffffffc0201ce6:	e852                	sd	s4,16(sp)
ffffffffc0201ce8:	fc06                	sd	ra,56(sp)
ffffffffc0201cea:	f822                	sd	s0,48(sp)
ffffffffc0201cec:	e456                	sd	s5,8(sp)
ffffffffc0201cee:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) { // 如果该条目不存在（PTE_Valid信号为0 如果下一级页表不存在，那就给它分配一页，创造新页表
ffffffffc0201cf0:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201cf4:	892e                	mv	s2,a1
ffffffffc0201cf6:	8a32                	mv	s4,a2
ffffffffc0201cf8:	00014997          	auipc	s3,0x14
ffffffffc0201cfc:	7a098993          	addi	s3,s3,1952 # ffffffffc0216498 <npage>
    if (!(*pdep1 & PTE_V)) { // 如果该条目不存在（PTE_Valid信号为0 如果下一级页表不存在，那就给它分配一页，创造新页表
ffffffffc0201d00:	e7bd                	bnez	a5,ffffffffc0201d6e <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) { // 函数create参数为0表示不创建新的页目录项，或者不能再分配新的页
ffffffffc0201d02:	12060c63          	beqz	a2,ffffffffc0201e3a <get_pte+0x16a>
ffffffffc0201d06:	4505                	li	a0,1
ffffffffc0201d08:	ebbff0ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0201d0c:	842a                	mv	s0,a0
ffffffffc0201d0e:	12050663          	beqz	a0,ffffffffc0201e3a <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201d12:	00014b17          	auipc	s6,0x14
ffffffffc0201d16:	7f6b0b13          	addi	s6,s6,2038 # ffffffffc0216508 <pages>
ffffffffc0201d1a:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201d1e:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);                              // 设置页面引用次数为1
        uintptr_t pa = page2pa(page);                       // 获取页面的物理地址
        memset(KADDR(pa), 0, PGSIZE);                       // 将页面清零
ffffffffc0201d20:	00014997          	auipc	s3,0x14
ffffffffc0201d24:	77898993          	addi	s3,s3,1912 # ffffffffc0216498 <npage>
    return page - pages + nbase;
ffffffffc0201d28:	40a40533          	sub	a0,s0,a0
ffffffffc0201d2c:	00080ab7          	lui	s5,0x80
ffffffffc0201d30:	8519                	srai	a0,a0,0x6
ffffffffc0201d32:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201d36:	c01c                	sw	a5,0(s0)
ffffffffc0201d38:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201d3a:	9556                	add	a0,a0,s5
ffffffffc0201d3c:	83b1                	srli	a5,a5,0xc
ffffffffc0201d3e:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201d40:	0532                	slli	a0,a0,0xc
ffffffffc0201d42:	14e7f363          	bleu	a4,a5,ffffffffc0201e88 <get_pte+0x1b8>
ffffffffc0201d46:	00014797          	auipc	a5,0x14
ffffffffc0201d4a:	7b278793          	addi	a5,a5,1970 # ffffffffc02164f8 <va_pa_offset>
ffffffffc0201d4e:	639c                	ld	a5,0(a5)
ffffffffc0201d50:	6605                	lui	a2,0x1
ffffffffc0201d52:	4581                	li	a1,0
ffffffffc0201d54:	953e                	add	a0,a0,a5
ffffffffc0201d56:	18a030ef          	jal	ra,ffffffffc0204ee0 <memset>
    return page - pages + nbase;
ffffffffc0201d5a:	000b3683          	ld	a3,0(s6)
ffffffffc0201d5e:	40d406b3          	sub	a3,s0,a3
ffffffffc0201d62:	8699                	srai	a3,a3,0x6
ffffffffc0201d64:	96d6                	add	a3,a3,s5
 * PTE_V: 一个标志位，表示这个页表项是有效的。
 * type: 通过按位或操作，将权限类型添加到页表项中
 * // 根据页帧号和权限位构造页表项
*/
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201d66:	06aa                	slli	a3,a3,0xa
ffffffffc0201d68:	0116e693          	ori	a3,a3,17
        //我们现在在虚拟地址空间中，所以要转化为KADDR再memset.
        //不管页表怎么构造，我们确保物理地址和虚拟地址的偏移量始终相同，那么就可以用这种方式完成对物理内存的访问

        // 设置页目录项为新的页的物理地址//注意这里R,W,X全零
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201d6c:	e094                	sd	a3,0(s1)
    }
    // 接下来处理下一级页表项
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201d6e:	77fd                	lui	a5,0xfffff
ffffffffc0201d70:	068a                	slli	a3,a3,0x2
ffffffffc0201d72:	0009b703          	ld	a4,0(s3)
ffffffffc0201d76:	8efd                	and	a3,a3,a5
ffffffffc0201d78:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201d7c:	0ce7f163          	bleu	a4,a5,ffffffffc0201e3e <get_pte+0x16e>
ffffffffc0201d80:	00014a97          	auipc	s5,0x14
ffffffffc0201d84:	778a8a93          	addi	s5,s5,1912 # ffffffffc02164f8 <va_pa_offset>
ffffffffc0201d88:	000ab403          	ld	s0,0(s5)
ffffffffc0201d8c:	01595793          	srli	a5,s2,0x15
ffffffffc0201d90:	1ff7f793          	andi	a5,a5,511
ffffffffc0201d94:	96a2                	add	a3,a3,s0
ffffffffc0201d96:	00379413          	slli	s0,a5,0x3
ffffffffc0201d9a:	9436                	add	s0,s0,a3
    // PDE_ADDR用来获取页表项pdep1中的物理地址部分（*是取内容符号）
    // KADDR用来将物理地址转换为虚拟地址
    // PDX0用来获取中间页表的索引【页表项里从高到低三级页表的页码分别称作PDX1, PDX0和PTX(Page Table Index)】

    if (!(*pdep0 & PTE_V)) {
ffffffffc0201d9c:	6014                	ld	a3,0(s0)
ffffffffc0201d9e:	0016f793          	andi	a5,a3,1
ffffffffc0201da2:	e3ad                	bnez	a5,ffffffffc0201e04 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201da4:	080a0b63          	beqz	s4,ffffffffc0201e3a <get_pte+0x16a>
ffffffffc0201da8:	4505                	li	a0,1
ffffffffc0201daa:	e19ff0ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0201dae:	84aa                	mv	s1,a0
ffffffffc0201db0:	c549                	beqz	a0,ffffffffc0201e3a <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201db2:	00014b17          	auipc	s6,0x14
ffffffffc0201db6:	756b0b13          	addi	s6,s6,1878 # ffffffffc0216508 <pages>
ffffffffc0201dba:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201dbe:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0201dc0:	00080a37          	lui	s4,0x80
ffffffffc0201dc4:	40a48533          	sub	a0,s1,a0
ffffffffc0201dc8:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201dca:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201dce:	c09c                	sw	a5,0(s1)
ffffffffc0201dd0:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201dd2:	9552                	add	a0,a0,s4
ffffffffc0201dd4:	83b1                	srli	a5,a5,0xc
ffffffffc0201dd6:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201dd8:	0532                	slli	a0,a0,0xc
ffffffffc0201dda:	08e7fa63          	bleu	a4,a5,ffffffffc0201e6e <get_pte+0x19e>
ffffffffc0201dde:	000ab783          	ld	a5,0(s5)
ffffffffc0201de2:	6605                	lui	a2,0x1
ffffffffc0201de4:	4581                	li	a1,0
ffffffffc0201de6:	953e                	add	a0,a0,a5
ffffffffc0201de8:	0f8030ef          	jal	ra,ffffffffc0204ee0 <memset>
    return page - pages + nbase;
ffffffffc0201dec:	000b3683          	ld	a3,0(s6)
ffffffffc0201df0:	40d486b3          	sub	a3,s1,a3
ffffffffc0201df4:	8699                	srai	a3,a3,0x6
ffffffffc0201df6:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201df8:	06aa                	slli	a3,a3,0xa
ffffffffc0201dfa:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201dfe:	e014                	sd	a3,0(s0)
ffffffffc0201e00:	0009b703          	ld	a4,0(s3)
    }
    //找到输入的虚拟地址la对应的页表项的地址(可能是刚刚分配的)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201e04:	068a                	slli	a3,a3,0x2
ffffffffc0201e06:	757d                	lui	a0,0xfffff
ffffffffc0201e08:	8ee9                	and	a3,a3,a0
ffffffffc0201e0a:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201e0e:	04e7f463          	bleu	a4,a5,ffffffffc0201e56 <get_pte+0x186>
ffffffffc0201e12:	000ab503          	ld	a0,0(s5)
ffffffffc0201e16:	00c95793          	srli	a5,s2,0xc
ffffffffc0201e1a:	1ff7f793          	andi	a5,a5,511
ffffffffc0201e1e:	96aa                	add	a3,a3,a0
ffffffffc0201e20:	00379513          	slli	a0,a5,0x3
ffffffffc0201e24:	9536                	add	a0,a0,a3
    // 和上面一样，不过对虚拟地址la用的宏是PTX，找最低一级页表的索引
}
ffffffffc0201e26:	70e2                	ld	ra,56(sp)
ffffffffc0201e28:	7442                	ld	s0,48(sp)
ffffffffc0201e2a:	74a2                	ld	s1,40(sp)
ffffffffc0201e2c:	7902                	ld	s2,32(sp)
ffffffffc0201e2e:	69e2                	ld	s3,24(sp)
ffffffffc0201e30:	6a42                	ld	s4,16(sp)
ffffffffc0201e32:	6aa2                	ld	s5,8(sp)
ffffffffc0201e34:	6b02                	ld	s6,0(sp)
ffffffffc0201e36:	6121                	addi	sp,sp,64
ffffffffc0201e38:	8082                	ret
            return NULL;
ffffffffc0201e3a:	4501                	li	a0,0
ffffffffc0201e3c:	b7ed                	j	ffffffffc0201e26 <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201e3e:	00004617          	auipc	a2,0x4
ffffffffc0201e42:	e8a60613          	addi	a2,a2,-374 # ffffffffc0205cc8 <default_pmm_manager+0x50>
ffffffffc0201e46:	0f900593          	li	a1,249
ffffffffc0201e4a:	00004517          	auipc	a0,0x4
ffffffffc0201e4e:	f6e50513          	addi	a0,a0,-146 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0201e52:	dfefe0ef          	jal	ra,ffffffffc0200450 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201e56:	00004617          	auipc	a2,0x4
ffffffffc0201e5a:	e7260613          	addi	a2,a2,-398 # ffffffffc0205cc8 <default_pmm_manager+0x50>
ffffffffc0201e5e:	10900593          	li	a1,265
ffffffffc0201e62:	00004517          	auipc	a0,0x4
ffffffffc0201e66:	f5650513          	addi	a0,a0,-170 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0201e6a:	de6fe0ef          	jal	ra,ffffffffc0200450 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e6e:	86aa                	mv	a3,a0
ffffffffc0201e70:	00004617          	auipc	a2,0x4
ffffffffc0201e74:	e5860613          	addi	a2,a2,-424 # ffffffffc0205cc8 <default_pmm_manager+0x50>
ffffffffc0201e78:	10500593          	li	a1,261
ffffffffc0201e7c:	00004517          	auipc	a0,0x4
ffffffffc0201e80:	f3c50513          	addi	a0,a0,-196 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0201e84:	dccfe0ef          	jal	ra,ffffffffc0200450 <__panic>
        memset(KADDR(pa), 0, PGSIZE);                       // 将页面清零
ffffffffc0201e88:	86aa                	mv	a3,a0
ffffffffc0201e8a:	00004617          	auipc	a2,0x4
ffffffffc0201e8e:	e3e60613          	addi	a2,a2,-450 # ffffffffc0205cc8 <default_pmm_manager+0x50>
ffffffffc0201e92:	0f100593          	li	a1,241
ffffffffc0201e96:	00004517          	auipc	a0,0x4
ffffffffc0201e9a:	f2250513          	addi	a0,a0,-222 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0201e9e:	db2fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201ea2 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
// 根据线性地址 la 和页目录表 pgdir 获取相应的 Page 结构体
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201ea2:	1141                	addi	sp,sp,-16
ffffffffc0201ea4:	e022                	sd	s0,0(sp)
ffffffffc0201ea6:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201ea8:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201eaa:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201eac:	e25ff0ef          	jal	ra,ffffffffc0201cd0 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201eb0:	c011                	beqz	s0,ffffffffc0201eb4 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201eb2:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201eb4:	c129                	beqz	a0,ffffffffc0201ef6 <get_page+0x54>
ffffffffc0201eb6:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201eb8:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201eba:	0017f713          	andi	a4,a5,1
ffffffffc0201ebe:	e709                	bnez	a4,ffffffffc0201ec8 <get_page+0x26>
}
ffffffffc0201ec0:	60a2                	ld	ra,8(sp)
ffffffffc0201ec2:	6402                	ld	s0,0(sp)
ffffffffc0201ec4:	0141                	addi	sp,sp,16
ffffffffc0201ec6:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201ec8:	00014717          	auipc	a4,0x14
ffffffffc0201ecc:	5d070713          	addi	a4,a4,1488 # ffffffffc0216498 <npage>
ffffffffc0201ed0:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ed2:	078a                	slli	a5,a5,0x2
ffffffffc0201ed4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ed6:	02e7f563          	bleu	a4,a5,ffffffffc0201f00 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201eda:	00014717          	auipc	a4,0x14
ffffffffc0201ede:	62e70713          	addi	a4,a4,1582 # ffffffffc0216508 <pages>
ffffffffc0201ee2:	6308                	ld	a0,0(a4)
ffffffffc0201ee4:	60a2                	ld	ra,8(sp)
ffffffffc0201ee6:	6402                	ld	s0,0(sp)
ffffffffc0201ee8:	fff80737          	lui	a4,0xfff80
ffffffffc0201eec:	97ba                	add	a5,a5,a4
ffffffffc0201eee:	079a                	slli	a5,a5,0x6
ffffffffc0201ef0:	953e                	add	a0,a0,a5
ffffffffc0201ef2:	0141                	addi	sp,sp,16
ffffffffc0201ef4:	8082                	ret
ffffffffc0201ef6:	60a2                	ld	ra,8(sp)
ffffffffc0201ef8:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0201efa:	4501                	li	a0,0
}
ffffffffc0201efc:	0141                	addi	sp,sp,16
ffffffffc0201efe:	8082                	ret
ffffffffc0201f00:	ca7ff0ef          	jal	ra,ffffffffc0201ba6 <pa2page.part.4>

ffffffffc0201f04 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201f04:	1101                	addi	sp,sp,-32
    //pgdir是页表基址(satp)。la是虚拟地址
    pte_t *ptep = get_pte(pgdir, la, 0); //找到页表项所在位置
ffffffffc0201f06:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201f08:	e426                	sd	s1,8(sp)
ffffffffc0201f0a:	ec06                	sd	ra,24(sp)
ffffffffc0201f0c:	e822                	sd	s0,16(sp)
ffffffffc0201f0e:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0); //找到页表项所在位置
ffffffffc0201f10:	dc1ff0ef          	jal	ra,ffffffffc0201cd0 <get_pte>
    if (ptep != NULL) {
ffffffffc0201f14:	c511                	beqz	a0,ffffffffc0201f20 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201f16:	611c                	ld	a5,0(a0)
ffffffffc0201f18:	842a                	mv	s0,a0
ffffffffc0201f1a:	0017f713          	andi	a4,a5,1
ffffffffc0201f1e:	e711                	bnez	a4,ffffffffc0201f2a <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep); //删除这个页表项的映射
    }
}
ffffffffc0201f20:	60e2                	ld	ra,24(sp)
ffffffffc0201f22:	6442                	ld	s0,16(sp)
ffffffffc0201f24:	64a2                	ld	s1,8(sp)
ffffffffc0201f26:	6105                	addi	sp,sp,32
ffffffffc0201f28:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201f2a:	00014717          	auipc	a4,0x14
ffffffffc0201f2e:	56e70713          	addi	a4,a4,1390 # ffffffffc0216498 <npage>
ffffffffc0201f32:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201f34:	078a                	slli	a5,a5,0x2
ffffffffc0201f36:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f38:	02e7fe63          	bleu	a4,a5,ffffffffc0201f74 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f3c:	00014717          	auipc	a4,0x14
ffffffffc0201f40:	5cc70713          	addi	a4,a4,1484 # ffffffffc0216508 <pages>
ffffffffc0201f44:	6308                	ld	a0,0(a4)
ffffffffc0201f46:	fff80737          	lui	a4,0xfff80
ffffffffc0201f4a:	97ba                	add	a5,a5,a4
ffffffffc0201f4c:	079a                	slli	a5,a5,0x6
ffffffffc0201f4e:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201f50:	411c                	lw	a5,0(a0)
ffffffffc0201f52:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201f56:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201f58:	cb11                	beqz	a4,ffffffffc0201f6c <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201f5a:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201f5e:	12048073          	sfence.vma	s1
}
ffffffffc0201f62:	60e2                	ld	ra,24(sp)
ffffffffc0201f64:	6442                	ld	s0,16(sp)
ffffffffc0201f66:	64a2                	ld	s1,8(sp)
ffffffffc0201f68:	6105                	addi	sp,sp,32
ffffffffc0201f6a:	8082                	ret
            free_page(page); //如果引用计数为0，则调用 free_page 函数释放物理页面。
ffffffffc0201f6c:	4585                	li	a1,1
ffffffffc0201f6e:	cddff0ef          	jal	ra,ffffffffc0201c4a <free_pages>
ffffffffc0201f72:	b7e5                	j	ffffffffc0201f5a <page_remove+0x56>
ffffffffc0201f74:	c33ff0ef          	jal	ra,ffffffffc0201ba6 <pa2page.part.4>

ffffffffc0201f78 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f78:	7179                	addi	sp,sp,-48
ffffffffc0201f7a:	e44e                	sd	s3,8(sp)
ffffffffc0201f7c:	89b2                	mv	s3,a2
ffffffffc0201f7e:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1); //先找到对应页表项的位置，如果原先不存在，get_pte()会分配页表项的内存
ffffffffc0201f80:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f82:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1); //先找到对应页表项的位置，如果原先不存在，get_pte()会分配页表项的内存
ffffffffc0201f84:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f86:	ec26                	sd	s1,24(sp)
ffffffffc0201f88:	f406                	sd	ra,40(sp)
ffffffffc0201f8a:	e84a                	sd	s2,16(sp)
ffffffffc0201f8c:	e052                	sd	s4,0(sp)
ffffffffc0201f8e:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1); //先找到对应页表项的位置，如果原先不存在，get_pte()会分配页表项的内存
ffffffffc0201f90:	d41ff0ef          	jal	ra,ffffffffc0201cd0 <get_pte>
    if (ptep == NULL) {
ffffffffc0201f94:	cd49                	beqz	a0,ffffffffc020202e <page_insert+0xb6>
    page->ref += 1;
ffffffffc0201f96:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) { //原先存在映射
ffffffffc0201f98:	611c                	ld	a5,0(a0)
ffffffffc0201f9a:	892a                	mv	s2,a0
ffffffffc0201f9c:	0016871b          	addiw	a4,a3,1
ffffffffc0201fa0:	c018                	sw	a4,0(s0)
ffffffffc0201fa2:	0017f713          	andi	a4,a5,1
ffffffffc0201fa6:	ef05                	bnez	a4,ffffffffc0201fde <page_insert+0x66>
ffffffffc0201fa8:	00014797          	auipc	a5,0x14
ffffffffc0201fac:	56078793          	addi	a5,a5,1376 # ffffffffc0216508 <pages>
ffffffffc0201fb0:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0201fb2:	8c19                	sub	s0,s0,a4
ffffffffc0201fb4:	000806b7          	lui	a3,0x80
ffffffffc0201fb8:	8419                	srai	s0,s0,0x6
ffffffffc0201fba:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201fbc:	042a                	slli	s0,s0,0xa
ffffffffc0201fbe:	8c45                	or	s0,s0,s1
ffffffffc0201fc0:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);  //构造页表项
ffffffffc0201fc4:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201fc8:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0201fcc:	4501                	li	a0,0
}
ffffffffc0201fce:	70a2                	ld	ra,40(sp)
ffffffffc0201fd0:	7402                	ld	s0,32(sp)
ffffffffc0201fd2:	64e2                	ld	s1,24(sp)
ffffffffc0201fd4:	6942                	ld	s2,16(sp)
ffffffffc0201fd6:	69a2                	ld	s3,8(sp)
ffffffffc0201fd8:	6a02                	ld	s4,0(sp)
ffffffffc0201fda:	6145                	addi	sp,sp,48
ffffffffc0201fdc:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201fde:	00014717          	auipc	a4,0x14
ffffffffc0201fe2:	4ba70713          	addi	a4,a4,1210 # ffffffffc0216498 <npage>
ffffffffc0201fe6:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201fe8:	078a                	slli	a5,a5,0x2
ffffffffc0201fea:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fec:	04e7f363          	bleu	a4,a5,ffffffffc0202032 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ff0:	00014a17          	auipc	s4,0x14
ffffffffc0201ff4:	518a0a13          	addi	s4,s4,1304 # ffffffffc0216508 <pages>
ffffffffc0201ff8:	000a3703          	ld	a4,0(s4)
ffffffffc0201ffc:	fff80537          	lui	a0,0xfff80
ffffffffc0202000:	953e                	add	a0,a0,a5
ffffffffc0202002:	051a                	slli	a0,a0,0x6
ffffffffc0202004:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0202006:	00a40a63          	beq	s0,a0,ffffffffc020201a <page_insert+0xa2>
    page->ref -= 1;
ffffffffc020200a:	411c                	lw	a5,0(a0)
ffffffffc020200c:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202010:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0202012:	c691                	beqz	a3,ffffffffc020201e <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202014:	12098073          	sfence.vma	s3
ffffffffc0202018:	bf69                	j	ffffffffc0201fb2 <page_insert+0x3a>
ffffffffc020201a:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc020201c:	bf59                	j	ffffffffc0201fb2 <page_insert+0x3a>
            free_page(page); //如果引用计数为0，则调用 free_page 函数释放物理页面。
ffffffffc020201e:	4585                	li	a1,1
ffffffffc0202020:	c2bff0ef          	jal	ra,ffffffffc0201c4a <free_pages>
ffffffffc0202024:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202028:	12098073          	sfence.vma	s3
ffffffffc020202c:	b759                	j	ffffffffc0201fb2 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020202e:	5571                	li	a0,-4
ffffffffc0202030:	bf79                	j	ffffffffc0201fce <page_insert+0x56>
ffffffffc0202032:	b75ff0ef          	jal	ra,ffffffffc0201ba6 <pa2page.part.4>

ffffffffc0202036 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202036:	00004797          	auipc	a5,0x4
ffffffffc020203a:	c4278793          	addi	a5,a5,-958 # ffffffffc0205c78 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020203e:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202040:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202042:	00004517          	auipc	a0,0x4
ffffffffc0202046:	d9e50513          	addi	a0,a0,-610 # ffffffffc0205de0 <default_pmm_manager+0x168>
void pmm_init(void) {
ffffffffc020204a:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020204c:	00014717          	auipc	a4,0x14
ffffffffc0202050:	4af73223          	sd	a5,1188(a4) # ffffffffc02164f0 <pmm_manager>
void pmm_init(void) {
ffffffffc0202054:	e0a2                	sd	s0,64(sp)
ffffffffc0202056:	fc26                	sd	s1,56(sp)
ffffffffc0202058:	f84a                	sd	s2,48(sp)
ffffffffc020205a:	f44e                	sd	s3,40(sp)
ffffffffc020205c:	f052                	sd	s4,32(sp)
ffffffffc020205e:	ec56                	sd	s5,24(sp)
ffffffffc0202060:	e85a                	sd	s6,16(sp)
ffffffffc0202062:	e45e                	sd	s7,8(sp)
ffffffffc0202064:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202066:	00014417          	auipc	s0,0x14
ffffffffc020206a:	48a40413          	addi	s0,s0,1162 # ffffffffc02164f0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020206e:	920fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    pmm_manager->init();
ffffffffc0202072:	601c                	ld	a5,0(s0)
ffffffffc0202074:	00014497          	auipc	s1,0x14
ffffffffc0202078:	42448493          	addi	s1,s1,1060 # ffffffffc0216498 <npage>
ffffffffc020207c:	00014917          	auipc	s2,0x14
ffffffffc0202080:	48c90913          	addi	s2,s2,1164 # ffffffffc0216508 <pages>
ffffffffc0202084:	679c                	ld	a5,8(a5)
ffffffffc0202086:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202088:	57f5                	li	a5,-3
ffffffffc020208a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020208c:	00004517          	auipc	a0,0x4
ffffffffc0202090:	d6c50513          	addi	a0,a0,-660 # ffffffffc0205df8 <default_pmm_manager+0x180>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202094:	00014717          	auipc	a4,0x14
ffffffffc0202098:	46f73223          	sd	a5,1124(a4) # ffffffffc02164f8 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020209c:	8f2fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02020a0:	46c5                	li	a3,17
ffffffffc02020a2:	06ee                	slli	a3,a3,0x1b
ffffffffc02020a4:	40100613          	li	a2,1025
ffffffffc02020a8:	16fd                	addi	a3,a3,-1
ffffffffc02020aa:	0656                	slli	a2,a2,0x15
ffffffffc02020ac:	07e005b7          	lui	a1,0x7e00
ffffffffc02020b0:	00004517          	auipc	a0,0x4
ffffffffc02020b4:	d6050513          	addi	a0,a0,-672 # ffffffffc0205e10 <default_pmm_manager+0x198>
ffffffffc02020b8:	8d6fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02020bc:	777d                	lui	a4,0xfffff
ffffffffc02020be:	00015797          	auipc	a5,0x15
ffffffffc02020c2:	54178793          	addi	a5,a5,1345 # ffffffffc02175ff <end+0xfff>
ffffffffc02020c6:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02020c8:	00088737          	lui	a4,0x88
ffffffffc02020cc:	00014697          	auipc	a3,0x14
ffffffffc02020d0:	3ce6b623          	sd	a4,972(a3) # ffffffffc0216498 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02020d4:	00014717          	auipc	a4,0x14
ffffffffc02020d8:	42f73a23          	sd	a5,1076(a4) # ffffffffc0216508 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02020dc:	4701                	li	a4,0
ffffffffc02020de:	4685                	li	a3,1
ffffffffc02020e0:	fff80837          	lui	a6,0xfff80
ffffffffc02020e4:	a019                	j	ffffffffc02020ea <pmm_init+0xb4>
ffffffffc02020e6:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02020ea:	00671613          	slli	a2,a4,0x6
ffffffffc02020ee:	97b2                	add	a5,a5,a2
ffffffffc02020f0:	07a1                	addi	a5,a5,8
ffffffffc02020f2:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02020f6:	6090                	ld	a2,0(s1)
ffffffffc02020f8:	0705                	addi	a4,a4,1
ffffffffc02020fa:	010607b3          	add	a5,a2,a6
ffffffffc02020fe:	fef764e3          	bltu	a4,a5,ffffffffc02020e6 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202102:	00093503          	ld	a0,0(s2)
ffffffffc0202106:	fe0007b7          	lui	a5,0xfe000
ffffffffc020210a:	00661693          	slli	a3,a2,0x6
ffffffffc020210e:	97aa                	add	a5,a5,a0
ffffffffc0202110:	96be                	add	a3,a3,a5
ffffffffc0202112:	c02007b7          	lui	a5,0xc0200
ffffffffc0202116:	7af6ed63          	bltu	a3,a5,ffffffffc02028d0 <pmm_init+0x89a>
ffffffffc020211a:	00014997          	auipc	s3,0x14
ffffffffc020211e:	3de98993          	addi	s3,s3,990 # ffffffffc02164f8 <va_pa_offset>
ffffffffc0202122:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0202126:	47c5                	li	a5,17
ffffffffc0202128:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020212a:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc020212c:	02f6f763          	bleu	a5,a3,ffffffffc020215a <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202130:	6585                	lui	a1,0x1
ffffffffc0202132:	15fd                	addi	a1,a1,-1
ffffffffc0202134:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0202136:	00c6d713          	srli	a4,a3,0xc
ffffffffc020213a:	48c77a63          	bleu	a2,a4,ffffffffc02025ce <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc020213e:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202140:	75fd                	lui	a1,0xfffff
ffffffffc0202142:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc0202144:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0202146:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202148:	40d786b3          	sub	a3,a5,a3
ffffffffc020214c:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc020214e:	00c6d593          	srli	a1,a3,0xc
ffffffffc0202152:	953a                	add	a0,a0,a4
ffffffffc0202154:	9602                	jalr	a2
ffffffffc0202156:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc020215a:	00004517          	auipc	a0,0x4
ffffffffc020215e:	cde50513          	addi	a0,a0,-802 # ffffffffc0205e38 <default_pmm_manager+0x1c0>
ffffffffc0202162:	82cfe0ef          	jal	ra,ffffffffc020018e <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202166:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;  // 页目录表的虚拟地址
ffffffffc0202168:	00014417          	auipc	s0,0x14
ffffffffc020216c:	32840413          	addi	s0,s0,808 # ffffffffc0216490 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202170:	7b9c                	ld	a5,48(a5)
ffffffffc0202172:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202174:	00004517          	auipc	a0,0x4
ffffffffc0202178:	cdc50513          	addi	a0,a0,-804 # ffffffffc0205e50 <default_pmm_manager+0x1d8>
ffffffffc020217c:	812fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;  // 页目录表的虚拟地址
ffffffffc0202180:	00008697          	auipc	a3,0x8
ffffffffc0202184:	e8068693          	addi	a3,a3,-384 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc0202188:	00014797          	auipc	a5,0x14
ffffffffc020218c:	30d7b423          	sd	a3,776(a5) # ffffffffc0216490 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202190:	c02007b7          	lui	a5,0xc0200
ffffffffc0202194:	10f6eae3          	bltu	a3,a5,ffffffffc0202aa8 <pmm_init+0xa72>
ffffffffc0202198:	0009b783          	ld	a5,0(s3)
ffffffffc020219c:	8e9d                	sub	a3,a3,a5
ffffffffc020219e:	00014797          	auipc	a5,0x14
ffffffffc02021a2:	36d7b123          	sd	a3,866(a5) # ffffffffc0216500 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc02021a6:	aebff0ef          	jal	ra,ffffffffc0201c90 <nr_free_pages>

    //这部分的断言用于进行一些基本验证：确保总的页数不超过内核顶部地址除以每页的大小。确保 boot_pgdir（引导页目录）非空且是页对齐的。确保虚拟地址 0x0 没有映射到任何页面。
    assert(npage <= KERNTOP / PGSIZE); //确保内核不会超出其可用的虚拟地址空间。
ffffffffc02021aa:	6098                	ld	a4,0(s1)
ffffffffc02021ac:	c80007b7          	lui	a5,0xc8000
ffffffffc02021b0:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc02021b2:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE); //确保内核不会超出其可用的虚拟地址空间。
ffffffffc02021b4:	0ce7eae3          	bltu	a5,a4,ffffffffc0202a88 <pmm_init+0xa52>
    //boot_pgdir是页表的虚拟地址
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02021b8:	6008                	ld	a0,0(s0)
ffffffffc02021ba:	44050463          	beqz	a0,ffffffffc0202602 <pmm_init+0x5cc>
ffffffffc02021be:	6785                	lui	a5,0x1
ffffffffc02021c0:	17fd                	addi	a5,a5,-1
ffffffffc02021c2:	8fe9                	and	a5,a5,a0
ffffffffc02021c4:	2781                	sext.w	a5,a5
ffffffffc02021c6:	42079e63          	bnez	a5,ffffffffc0202602 <pmm_init+0x5cc>
    //get_page()尝试找到虚拟内存0x0对应的页，现在当然是没有的，返回NULL
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02021ca:	4601                	li	a2,0
ffffffffc02021cc:	4581                	li	a1,0
ffffffffc02021ce:	cd5ff0ef          	jal	ra,ffffffffc0201ea2 <get_page>
ffffffffc02021d2:	78051b63          	bnez	a0,ffffffffc0202968 <pmm_init+0x932>

    //分配了一个新的页面p1，将此页面插入到虚拟地址0x0
    struct Page *p1, *p2;
    p1 = alloc_page(); //拿过来一个物理页面
ffffffffc02021d6:	4505                	li	a0,1
ffffffffc02021d8:	9ebff0ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc02021dc:	8aaa                	mv	s5,a0
    //page_insert 函数使用多级页表来实现虚拟地址到物理地址的映射。这个函数返回0表示映射成功。
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0); //把这个物理页面通过多级页表映射到0x0
ffffffffc02021de:	6008                	ld	a0,0(s0)
ffffffffc02021e0:	4681                	li	a3,0
ffffffffc02021e2:	4601                	li	a2,0
ffffffffc02021e4:	85d6                	mv	a1,s5
ffffffffc02021e6:	d93ff0ef          	jal	ra,ffffffffc0201f78 <page_insert>
ffffffffc02021ea:	7a051f63          	bnez	a0,ffffffffc02029a8 <pmm_init+0x972>

    //检查插入操作的正确性，验证获取虚拟地址 0x0 的页表项。确保页表项指向正确的页面。页面的引用计数是否正确（应为1）
    pte_t *ptep;
    //get_pte查找某个虚拟地址对应的页表项，如果不存在这个页表项，会为它分配各级的页表
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02021ee:	6008                	ld	a0,0(s0)
ffffffffc02021f0:	4601                	li	a2,0
ffffffffc02021f2:	4581                	li	a1,0
ffffffffc02021f4:	addff0ef          	jal	ra,ffffffffc0201cd0 <get_pte>
ffffffffc02021f8:	78050863          	beqz	a0,ffffffffc0202988 <pmm_init+0x952>
    assert(pte2page(*ptep) == p1); //pte2page 函数将页表项转换为对应的物理页面，并将其与 p1 进行比较。如果它们相等，assert 宏将不会发生错误。
ffffffffc02021fc:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02021fe:	0017f713          	andi	a4,a5,1
ffffffffc0202202:	3e070463          	beqz	a4,ffffffffc02025ea <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0202206:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202208:	078a                	slli	a5,a5,0x2
ffffffffc020220a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020220c:	3ce7f163          	bleu	a4,a5,ffffffffc02025ce <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202210:	00093683          	ld	a3,0(s2)
ffffffffc0202214:	fff80637          	lui	a2,0xfff80
ffffffffc0202218:	97b2                	add	a5,a5,a2
ffffffffc020221a:	079a                	slli	a5,a5,0x6
ffffffffc020221c:	97b6                	add	a5,a5,a3
ffffffffc020221e:	72fa9563          	bne	s5,a5,ffffffffc0202948 <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc0202222:	000aab83          	lw	s7,0(s5)
ffffffffc0202226:	4785                	li	a5,1
ffffffffc0202228:	70fb9063          	bne	s7,a5,ffffffffc0202928 <pmm_init+0x8f2>

    //用于测试 get_pte 函数是否能够正确地获取虚拟地址对应的页表项。
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020222c:	6008                	ld	a0,0(s0)
ffffffffc020222e:	76fd                	lui	a3,0xfffff
ffffffffc0202230:	611c                	ld	a5,0(a0)
ffffffffc0202232:	078a                	slli	a5,a5,0x2
ffffffffc0202234:	8ff5                	and	a5,a5,a3
ffffffffc0202236:	00c7d613          	srli	a2,a5,0xc
ffffffffc020223a:	66e67e63          	bleu	a4,a2,ffffffffc02028b6 <pmm_init+0x880>
ffffffffc020223e:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202242:	97e2                	add	a5,a5,s8
ffffffffc0202244:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0202248:	0b0a                	slli	s6,s6,0x2
ffffffffc020224a:	00db7b33          	and	s6,s6,a3
ffffffffc020224e:	00cb5793          	srli	a5,s6,0xc
ffffffffc0202252:	56e7f863          	bleu	a4,a5,ffffffffc02027c2 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202256:	4601                	li	a2,0
ffffffffc0202258:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020225a:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020225c:	a75ff0ef          	jal	ra,ffffffffc0201cd0 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202260:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202262:	55651063          	bne	a0,s6,ffffffffc02027a2 <pmm_init+0x76c>

    //分配和插入另一个页面，函数分配了另一个页面 p2，并将其插入到虚拟地址 PGSIZE，这个页面是用户可访问的，并且可写。
    p2 = alloc_page();
ffffffffc0202266:	4505                	li	a0,1
ffffffffc0202268:	95bff0ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc020226c:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020226e:	6008                	ld	a0,0(s0)
ffffffffc0202270:	46d1                	li	a3,20
ffffffffc0202272:	6605                	lui	a2,0x1
ffffffffc0202274:	85da                	mv	a1,s6
ffffffffc0202276:	d03ff0ef          	jal	ra,ffffffffc0201f78 <page_insert>
ffffffffc020227a:	50051463          	bnez	a0,ffffffffc0202782 <pmm_init+0x74c>
    //再次进行一系列的验证，检查新插入的页表项的权限和引用计数。
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020227e:	6008                	ld	a0,0(s0)
ffffffffc0202280:	4601                	li	a2,0
ffffffffc0202282:	6585                	lui	a1,0x1
ffffffffc0202284:	a4dff0ef          	jal	ra,ffffffffc0201cd0 <get_pte>
ffffffffc0202288:	4c050d63          	beqz	a0,ffffffffc0202762 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc020228c:	611c                	ld	a5,0(a0)
ffffffffc020228e:	0107f713          	andi	a4,a5,16
ffffffffc0202292:	4a070863          	beqz	a4,ffffffffc0202742 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc0202296:	8b91                	andi	a5,a5,4
ffffffffc0202298:	48078563          	beqz	a5,ffffffffc0202722 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020229c:	6008                	ld	a0,0(s0)
ffffffffc020229e:	611c                	ld	a5,0(a0)
ffffffffc02022a0:	8bc1                	andi	a5,a5,16
ffffffffc02022a2:	46078063          	beqz	a5,ffffffffc0202702 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc02022a6:	000b2783          	lw	a5,0(s6)
ffffffffc02022aa:	43779c63          	bne	a5,s7,ffffffffc02026e2 <pmm_init+0x6ac>

    //将之前分配的页面 p1 再次插入到新的虚拟地址 PGSIZE。同时验证了页面 p1 的引用计数是否正确增加，同时页面 p2 的引用计数是否已经减少。
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02022ae:	4681                	li	a3,0
ffffffffc02022b0:	6605                	lui	a2,0x1
ffffffffc02022b2:	85d6                	mv	a1,s5
ffffffffc02022b4:	cc5ff0ef          	jal	ra,ffffffffc0201f78 <page_insert>
ffffffffc02022b8:	40051563          	bnez	a0,ffffffffc02026c2 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc02022bc:	000aa703          	lw	a4,0(s5)
ffffffffc02022c0:	4789                	li	a5,2
ffffffffc02022c2:	3ef71063          	bne	a4,a5,ffffffffc02026a2 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc02022c6:	000b2783          	lw	a5,0(s6)
ffffffffc02022ca:	3a079c63          	bnez	a5,ffffffffc0202682 <pmm_init+0x64c>

    //检查页表项的权限和对应的物理页面是否正确。
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02022ce:	6008                	ld	a0,0(s0)
ffffffffc02022d0:	4601                	li	a2,0
ffffffffc02022d2:	6585                	lui	a1,0x1
ffffffffc02022d4:	9fdff0ef          	jal	ra,ffffffffc0201cd0 <get_pte>
ffffffffc02022d8:	38050563          	beqz	a0,ffffffffc0202662 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc02022dc:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02022de:	00177793          	andi	a5,a4,1
ffffffffc02022e2:	30078463          	beqz	a5,ffffffffc02025ea <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02022e6:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02022e8:	00271793          	slli	a5,a4,0x2
ffffffffc02022ec:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02022ee:	2ed7f063          	bleu	a3,a5,ffffffffc02025ce <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02022f2:	00093683          	ld	a3,0(s2)
ffffffffc02022f6:	fff80637          	lui	a2,0xfff80
ffffffffc02022fa:	97b2                	add	a5,a5,a2
ffffffffc02022fc:	079a                	slli	a5,a5,0x6
ffffffffc02022fe:	97b6                	add	a5,a5,a3
ffffffffc0202300:	32fa9163          	bne	s5,a5,ffffffffc0202622 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202304:	8b41                	andi	a4,a4,16
ffffffffc0202306:	70071163          	bnez	a4,ffffffffc0202a08 <pmm_init+0x9d2>

    //移除了之前插入的两个页面，并验证了这两个页面的引用计数是否已经正确更新。
    page_remove(boot_pgdir, 0x0);
ffffffffc020230a:	6008                	ld	a0,0(s0)
ffffffffc020230c:	4581                	li	a1,0
ffffffffc020230e:	bf7ff0ef          	jal	ra,ffffffffc0201f04 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202312:	000aa703          	lw	a4,0(s5)
ffffffffc0202316:	4785                	li	a5,1
ffffffffc0202318:	6cf71863          	bne	a4,a5,ffffffffc02029e8 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc020231c:	000b2783          	lw	a5,0(s6)
ffffffffc0202320:	6a079463          	bnez	a5,ffffffffc02029c8 <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202324:	6008                	ld	a0,0(s0)
ffffffffc0202326:	6585                	lui	a1,0x1
ffffffffc0202328:	bddff0ef          	jal	ra,ffffffffc0201f04 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020232c:	000aa783          	lw	a5,0(s5)
ffffffffc0202330:	50079363          	bnez	a5,ffffffffc0202836 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc0202334:	000b2783          	lw	a5,0(s6)
ffffffffc0202338:	4c079f63          	bnez	a5,ffffffffc0202816 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020233c:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202340:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202342:	000ab783          	ld	a5,0(s5)
ffffffffc0202346:	078a                	slli	a5,a5,0x2
ffffffffc0202348:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020234a:	28c7f263          	bleu	a2,a5,ffffffffc02025ce <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020234e:	fff80737          	lui	a4,0xfff80
ffffffffc0202352:	00093503          	ld	a0,0(s2)
ffffffffc0202356:	97ba                	add	a5,a5,a4
ffffffffc0202358:	079a                	slli	a5,a5,0x6
ffffffffc020235a:	00f50733          	add	a4,a0,a5
ffffffffc020235e:	4314                	lw	a3,0(a4)
ffffffffc0202360:	4705                	li	a4,1
ffffffffc0202362:	48e69a63          	bne	a3,a4,ffffffffc02027f6 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc0202366:	8799                	srai	a5,a5,0x6
ffffffffc0202368:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020236c:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc020236e:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc0202370:	8331                	srli	a4,a4,0xc
ffffffffc0202372:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202374:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202376:	46c77363          	bleu	a2,a4,ffffffffc02027dc <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020237a:	0009b683          	ld	a3,0(s3)
ffffffffc020237e:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0202380:	639c                	ld	a5,0(a5)
ffffffffc0202382:	078a                	slli	a5,a5,0x2
ffffffffc0202384:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202386:	24c7f463          	bleu	a2,a5,ffffffffc02025ce <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020238a:	416787b3          	sub	a5,a5,s6
ffffffffc020238e:	079a                	slli	a5,a5,0x6
ffffffffc0202390:	953e                	add	a0,a0,a5
ffffffffc0202392:	4585                	li	a1,1
ffffffffc0202394:	8b7ff0ef          	jal	ra,ffffffffc0201c4a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202398:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc020239c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020239e:	078a                	slli	a5,a5,0x2
ffffffffc02023a0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023a2:	22e7f663          	bleu	a4,a5,ffffffffc02025ce <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02023a6:	00093503          	ld	a0,0(s2)
ffffffffc02023aa:	416787b3          	sub	a5,a5,s6
ffffffffc02023ae:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02023b0:	953e                	add	a0,a0,a5
ffffffffc02023b2:	4585                	li	a1,1
ffffffffc02023b4:	897ff0ef          	jal	ra,ffffffffc0201c4a <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02023b8:	601c                	ld	a5,0(s0)
ffffffffc02023ba:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02023be:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02023c2:	8cfff0ef          	jal	ra,ffffffffc0201c90 <nr_free_pages>
ffffffffc02023c6:	68aa1163          	bne	s4,a0,ffffffffc0202a48 <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02023ca:	00004517          	auipc	a0,0x4
ffffffffc02023ce:	d9650513          	addi	a0,a0,-618 # ffffffffc0206160 <default_pmm_manager+0x4e8>
ffffffffc02023d2:	dbdfd0ef          	jal	ra,ffffffffc020018e <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02023d6:	8bbff0ef          	jal	ra,ffffffffc0201c90 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02023da:	6098                	ld	a4,0(s1)
ffffffffc02023dc:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02023e0:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02023e2:	00c71693          	slli	a3,a4,0xc
ffffffffc02023e6:	18d7f563          	bleu	a3,a5,ffffffffc0202570 <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02023ea:	83b1                	srli	a5,a5,0xc
ffffffffc02023ec:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02023ee:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02023f2:	1ae7f163          	bleu	a4,a5,ffffffffc0202594 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02023f6:	7bfd                	lui	s7,0xfffff
ffffffffc02023f8:	6b05                	lui	s6,0x1
ffffffffc02023fa:	a029                	j	ffffffffc0202404 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02023fc:	00cad713          	srli	a4,s5,0xc
ffffffffc0202400:	18f77a63          	bleu	a5,a4,ffffffffc0202594 <pmm_init+0x55e>
ffffffffc0202404:	0009b583          	ld	a1,0(s3)
ffffffffc0202408:	4601                	li	a2,0
ffffffffc020240a:	95d6                	add	a1,a1,s5
ffffffffc020240c:	8c5ff0ef          	jal	ra,ffffffffc0201cd0 <get_pte>
ffffffffc0202410:	16050263          	beqz	a0,ffffffffc0202574 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202414:	611c                	ld	a5,0(a0)
ffffffffc0202416:	078a                	slli	a5,a5,0x2
ffffffffc0202418:	0177f7b3          	and	a5,a5,s7
ffffffffc020241c:	19579963          	bne	a5,s5,ffffffffc02025ae <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202420:	609c                	ld	a5,0(s1)
ffffffffc0202422:	9ada                	add	s5,s5,s6
ffffffffc0202424:	6008                	ld	a0,0(s0)
ffffffffc0202426:	00c79713          	slli	a4,a5,0xc
ffffffffc020242a:	fceae9e3          	bltu	s5,a4,ffffffffc02023fc <pmm_init+0x3c6>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc020242e:	611c                	ld	a5,0(a0)
ffffffffc0202430:	62079c63          	bnez	a5,ffffffffc0202a68 <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc0202434:	4505                	li	a0,1
ffffffffc0202436:	f8cff0ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc020243a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020243c:	6008                	ld	a0,0(s0)
ffffffffc020243e:	4699                	li	a3,6
ffffffffc0202440:	10000613          	li	a2,256
ffffffffc0202444:	85d6                	mv	a1,s5
ffffffffc0202446:	b33ff0ef          	jal	ra,ffffffffc0201f78 <page_insert>
ffffffffc020244a:	1e051c63          	bnez	a0,ffffffffc0202642 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc020244e:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0202452:	4785                	li	a5,1
ffffffffc0202454:	44f71163          	bne	a4,a5,ffffffffc0202896 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202458:	6008                	ld	a0,0(s0)
ffffffffc020245a:	6b05                	lui	s6,0x1
ffffffffc020245c:	4699                	li	a3,6
ffffffffc020245e:	100b0613          	addi	a2,s6,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0202462:	85d6                	mv	a1,s5
ffffffffc0202464:	b15ff0ef          	jal	ra,ffffffffc0201f78 <page_insert>
ffffffffc0202468:	40051763          	bnez	a0,ffffffffc0202876 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc020246c:	000aa703          	lw	a4,0(s5)
ffffffffc0202470:	4789                	li	a5,2
ffffffffc0202472:	3ef71263          	bne	a4,a5,ffffffffc0202856 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202476:	00004597          	auipc	a1,0x4
ffffffffc020247a:	e2258593          	addi	a1,a1,-478 # ffffffffc0206298 <default_pmm_manager+0x620>
ffffffffc020247e:	10000513          	li	a0,256
ffffffffc0202482:	205020ef          	jal	ra,ffffffffc0204e86 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202486:	100b0593          	addi	a1,s6,256
ffffffffc020248a:	10000513          	li	a0,256
ffffffffc020248e:	20b020ef          	jal	ra,ffffffffc0204e98 <strcmp>
ffffffffc0202492:	44051b63          	bnez	a0,ffffffffc02028e8 <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0202496:	00093683          	ld	a3,0(s2)
ffffffffc020249a:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc020249e:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc02024a0:	40da86b3          	sub	a3,s5,a3
ffffffffc02024a4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02024a6:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc02024a8:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02024aa:	00cb5b13          	srli	s6,s6,0xc
ffffffffc02024ae:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02024b2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02024b4:	10f77f63          	bleu	a5,a4,ffffffffc02025d2 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02024b8:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02024bc:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02024c0:	96be                	add	a3,a3,a5
ffffffffc02024c2:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fde8b00>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02024c6:	17d020ef          	jal	ra,ffffffffc0204e42 <strlen>
ffffffffc02024ca:	54051f63          	bnez	a0,ffffffffc0202a28 <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02024ce:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02024d2:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024d4:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fde8a00>
ffffffffc02024d8:	068a                	slli	a3,a3,0x2
ffffffffc02024da:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024dc:	0ef6f963          	bleu	a5,a3,ffffffffc02025ce <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc02024e0:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02024e4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02024e6:	0efb7663          	bleu	a5,s6,ffffffffc02025d2 <pmm_init+0x59c>
ffffffffc02024ea:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc02024ee:	4585                	li	a1,1
ffffffffc02024f0:	8556                	mv	a0,s5
ffffffffc02024f2:	99b6                	add	s3,s3,a3
ffffffffc02024f4:	f56ff0ef          	jal	ra,ffffffffc0201c4a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02024f8:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02024fc:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024fe:	078a                	slli	a5,a5,0x2
ffffffffc0202500:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202502:	0ce7f663          	bleu	a4,a5,ffffffffc02025ce <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202506:	00093503          	ld	a0,0(s2)
ffffffffc020250a:	fff809b7          	lui	s3,0xfff80
ffffffffc020250e:	97ce                	add	a5,a5,s3
ffffffffc0202510:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202512:	953e                	add	a0,a0,a5
ffffffffc0202514:	4585                	li	a1,1
ffffffffc0202516:	f34ff0ef          	jal	ra,ffffffffc0201c4a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020251a:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc020251e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202520:	078a                	slli	a5,a5,0x2
ffffffffc0202522:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202524:	0ae7f563          	bleu	a4,a5,ffffffffc02025ce <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202528:	00093503          	ld	a0,0(s2)
ffffffffc020252c:	97ce                	add	a5,a5,s3
ffffffffc020252e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202530:	953e                	add	a0,a0,a5
ffffffffc0202532:	4585                	li	a1,1
ffffffffc0202534:	f16ff0ef          	jal	ra,ffffffffc0201c4a <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202538:	601c                	ld	a5,0(s0)
ffffffffc020253a:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc020253e:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202542:	f4eff0ef          	jal	ra,ffffffffc0201c90 <nr_free_pages>
ffffffffc0202546:	3caa1163          	bne	s4,a0,ffffffffc0202908 <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020254a:	00004517          	auipc	a0,0x4
ffffffffc020254e:	dc650513          	addi	a0,a0,-570 # ffffffffc0206310 <default_pmm_manager+0x698>
ffffffffc0202552:	c3dfd0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0202556:	6406                	ld	s0,64(sp)
ffffffffc0202558:	60a6                	ld	ra,72(sp)
ffffffffc020255a:	74e2                	ld	s1,56(sp)
ffffffffc020255c:	7942                	ld	s2,48(sp)
ffffffffc020255e:	79a2                	ld	s3,40(sp)
ffffffffc0202560:	7a02                	ld	s4,32(sp)
ffffffffc0202562:	6ae2                	ld	s5,24(sp)
ffffffffc0202564:	6b42                	ld	s6,16(sp)
ffffffffc0202566:	6ba2                	ld	s7,8(sp)
ffffffffc0202568:	6c02                	ld	s8,0(sp)
ffffffffc020256a:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc020256c:	c3aff06f          	j	ffffffffc02019a6 <kmalloc_init>
ffffffffc0202570:	6008                	ld	a0,0(s0)
ffffffffc0202572:	bd75                	j	ffffffffc020242e <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202574:	00004697          	auipc	a3,0x4
ffffffffc0202578:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0206180 <default_pmm_manager+0x508>
ffffffffc020257c:	00003617          	auipc	a2,0x3
ffffffffc0202580:	36460613          	addi	a2,a2,868 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202584:	1cf00593          	li	a1,463
ffffffffc0202588:	00004517          	auipc	a0,0x4
ffffffffc020258c:	83050513          	addi	a0,a0,-2000 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0202590:	ec1fd0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0202594:	86d6                	mv	a3,s5
ffffffffc0202596:	00003617          	auipc	a2,0x3
ffffffffc020259a:	73260613          	addi	a2,a2,1842 # ffffffffc0205cc8 <default_pmm_manager+0x50>
ffffffffc020259e:	1cf00593          	li	a1,463
ffffffffc02025a2:	00004517          	auipc	a0,0x4
ffffffffc02025a6:	81650513          	addi	a0,a0,-2026 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc02025aa:	ea7fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02025ae:	00004697          	auipc	a3,0x4
ffffffffc02025b2:	c1268693          	addi	a3,a3,-1006 # ffffffffc02061c0 <default_pmm_manager+0x548>
ffffffffc02025b6:	00003617          	auipc	a2,0x3
ffffffffc02025ba:	32a60613          	addi	a2,a2,810 # ffffffffc02058e0 <commands+0x870>
ffffffffc02025be:	1d000593          	li	a1,464
ffffffffc02025c2:	00003517          	auipc	a0,0x3
ffffffffc02025c6:	7f650513          	addi	a0,a0,2038 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc02025ca:	e87fd0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc02025ce:	dd8ff0ef          	jal	ra,ffffffffc0201ba6 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc02025d2:	00003617          	auipc	a2,0x3
ffffffffc02025d6:	6f660613          	addi	a2,a2,1782 # ffffffffc0205cc8 <default_pmm_manager+0x50>
ffffffffc02025da:	08b00593          	li	a1,139
ffffffffc02025de:	00003517          	auipc	a0,0x3
ffffffffc02025e2:	71250513          	addi	a0,a0,1810 # ffffffffc0205cf0 <default_pmm_manager+0x78>
ffffffffc02025e6:	e6bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02025ea:	00004617          	auipc	a2,0x4
ffffffffc02025ee:	96660613          	addi	a2,a2,-1690 # ffffffffc0205f50 <default_pmm_manager+0x2d8>
ffffffffc02025f2:	09f00593          	li	a1,159
ffffffffc02025f6:	00003517          	auipc	a0,0x3
ffffffffc02025fa:	6fa50513          	addi	a0,a0,1786 # ffffffffc0205cf0 <default_pmm_manager+0x78>
ffffffffc02025fe:	e53fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202602:	00004697          	auipc	a3,0x4
ffffffffc0202606:	88e68693          	addi	a3,a3,-1906 # ffffffffc0205e90 <default_pmm_manager+0x218>
ffffffffc020260a:	00003617          	auipc	a2,0x3
ffffffffc020260e:	2d660613          	addi	a2,a2,726 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202612:	18700593          	li	a1,391
ffffffffc0202616:	00003517          	auipc	a0,0x3
ffffffffc020261a:	7a250513          	addi	a0,a0,1954 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc020261e:	e33fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202622:	00004697          	auipc	a3,0x4
ffffffffc0202626:	95668693          	addi	a3,a3,-1706 # ffffffffc0205f78 <default_pmm_manager+0x300>
ffffffffc020262a:	00003617          	auipc	a2,0x3
ffffffffc020262e:	2b660613          	addi	a2,a2,694 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202632:	1ae00593          	li	a1,430
ffffffffc0202636:	00003517          	auipc	a0,0x3
ffffffffc020263a:	78250513          	addi	a0,a0,1922 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc020263e:	e13fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202642:	00004697          	auipc	a3,0x4
ffffffffc0202646:	bae68693          	addi	a3,a3,-1106 # ffffffffc02061f0 <default_pmm_manager+0x578>
ffffffffc020264a:	00003617          	auipc	a2,0x3
ffffffffc020264e:	29660613          	addi	a2,a2,662 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202652:	1d700593          	li	a1,471
ffffffffc0202656:	00003517          	auipc	a0,0x3
ffffffffc020265a:	76250513          	addi	a0,a0,1890 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc020265e:	df3fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202662:	00004697          	auipc	a3,0x4
ffffffffc0202666:	9a668693          	addi	a3,a3,-1626 # ffffffffc0206008 <default_pmm_manager+0x390>
ffffffffc020266a:	00003617          	auipc	a2,0x3
ffffffffc020266e:	27660613          	addi	a2,a2,630 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202672:	1ad00593          	li	a1,429
ffffffffc0202676:	00003517          	auipc	a0,0x3
ffffffffc020267a:	74250513          	addi	a0,a0,1858 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc020267e:	dd3fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202682:	00004697          	auipc	a3,0x4
ffffffffc0202686:	a4e68693          	addi	a3,a3,-1458 # ffffffffc02060d0 <default_pmm_manager+0x458>
ffffffffc020268a:	00003617          	auipc	a2,0x3
ffffffffc020268e:	25660613          	addi	a2,a2,598 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202692:	1aa00593          	li	a1,426
ffffffffc0202696:	00003517          	auipc	a0,0x3
ffffffffc020269a:	72250513          	addi	a0,a0,1826 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc020269e:	db3fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02026a2:	00004697          	auipc	a3,0x4
ffffffffc02026a6:	a1668693          	addi	a3,a3,-1514 # ffffffffc02060b8 <default_pmm_manager+0x440>
ffffffffc02026aa:	00003617          	auipc	a2,0x3
ffffffffc02026ae:	23660613          	addi	a2,a2,566 # ffffffffc02058e0 <commands+0x870>
ffffffffc02026b2:	1a900593          	li	a1,425
ffffffffc02026b6:	00003517          	auipc	a0,0x3
ffffffffc02026ba:	70250513          	addi	a0,a0,1794 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc02026be:	d93fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02026c2:	00004697          	auipc	a3,0x4
ffffffffc02026c6:	9c668693          	addi	a3,a3,-1594 # ffffffffc0206088 <default_pmm_manager+0x410>
ffffffffc02026ca:	00003617          	auipc	a2,0x3
ffffffffc02026ce:	21660613          	addi	a2,a2,534 # ffffffffc02058e0 <commands+0x870>
ffffffffc02026d2:	1a800593          	li	a1,424
ffffffffc02026d6:	00003517          	auipc	a0,0x3
ffffffffc02026da:	6e250513          	addi	a0,a0,1762 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc02026de:	d73fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02026e2:	00004697          	auipc	a3,0x4
ffffffffc02026e6:	98e68693          	addi	a3,a3,-1650 # ffffffffc0206070 <default_pmm_manager+0x3f8>
ffffffffc02026ea:	00003617          	auipc	a2,0x3
ffffffffc02026ee:	1f660613          	addi	a2,a2,502 # ffffffffc02058e0 <commands+0x870>
ffffffffc02026f2:	1a500593          	li	a1,421
ffffffffc02026f6:	00003517          	auipc	a0,0x3
ffffffffc02026fa:	6c250513          	addi	a0,a0,1730 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc02026fe:	d53fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202702:	00004697          	auipc	a3,0x4
ffffffffc0202706:	95668693          	addi	a3,a3,-1706 # ffffffffc0206058 <default_pmm_manager+0x3e0>
ffffffffc020270a:	00003617          	auipc	a2,0x3
ffffffffc020270e:	1d660613          	addi	a2,a2,470 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202712:	1a400593          	li	a1,420
ffffffffc0202716:	00003517          	auipc	a0,0x3
ffffffffc020271a:	6a250513          	addi	a0,a0,1698 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc020271e:	d33fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202722:	00004697          	auipc	a3,0x4
ffffffffc0202726:	92668693          	addi	a3,a3,-1754 # ffffffffc0206048 <default_pmm_manager+0x3d0>
ffffffffc020272a:	00003617          	auipc	a2,0x3
ffffffffc020272e:	1b660613          	addi	a2,a2,438 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202732:	1a300593          	li	a1,419
ffffffffc0202736:	00003517          	auipc	a0,0x3
ffffffffc020273a:	68250513          	addi	a0,a0,1666 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc020273e:	d13fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202742:	00004697          	auipc	a3,0x4
ffffffffc0202746:	8f668693          	addi	a3,a3,-1802 # ffffffffc0206038 <default_pmm_manager+0x3c0>
ffffffffc020274a:	00003617          	auipc	a2,0x3
ffffffffc020274e:	19660613          	addi	a2,a2,406 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202752:	1a200593          	li	a1,418
ffffffffc0202756:	00003517          	auipc	a0,0x3
ffffffffc020275a:	66250513          	addi	a0,a0,1634 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc020275e:	cf3fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202762:	00004697          	auipc	a3,0x4
ffffffffc0202766:	8a668693          	addi	a3,a3,-1882 # ffffffffc0206008 <default_pmm_manager+0x390>
ffffffffc020276a:	00003617          	auipc	a2,0x3
ffffffffc020276e:	17660613          	addi	a2,a2,374 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202772:	1a100593          	li	a1,417
ffffffffc0202776:	00003517          	auipc	a0,0x3
ffffffffc020277a:	64250513          	addi	a0,a0,1602 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc020277e:	cd3fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202782:	00004697          	auipc	a3,0x4
ffffffffc0202786:	84e68693          	addi	a3,a3,-1970 # ffffffffc0205fd0 <default_pmm_manager+0x358>
ffffffffc020278a:	00003617          	auipc	a2,0x3
ffffffffc020278e:	15660613          	addi	a2,a2,342 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202792:	19f00593          	li	a1,415
ffffffffc0202796:	00003517          	auipc	a0,0x3
ffffffffc020279a:	62250513          	addi	a0,a0,1570 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc020279e:	cb3fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02027a2:	00004697          	auipc	a3,0x4
ffffffffc02027a6:	80668693          	addi	a3,a3,-2042 # ffffffffc0205fa8 <default_pmm_manager+0x330>
ffffffffc02027aa:	00003617          	auipc	a2,0x3
ffffffffc02027ae:	13660613          	addi	a2,a2,310 # ffffffffc02058e0 <commands+0x870>
ffffffffc02027b2:	19b00593          	li	a1,411
ffffffffc02027b6:	00003517          	auipc	a0,0x3
ffffffffc02027ba:	60250513          	addi	a0,a0,1538 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc02027be:	c93fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02027c2:	86da                	mv	a3,s6
ffffffffc02027c4:	00003617          	auipc	a2,0x3
ffffffffc02027c8:	50460613          	addi	a2,a2,1284 # ffffffffc0205cc8 <default_pmm_manager+0x50>
ffffffffc02027cc:	19a00593          	li	a1,410
ffffffffc02027d0:	00003517          	auipc	a0,0x3
ffffffffc02027d4:	5e850513          	addi	a0,a0,1512 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc02027d8:	c79fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    return KADDR(page2pa(page));
ffffffffc02027dc:	86be                	mv	a3,a5
ffffffffc02027de:	00003617          	auipc	a2,0x3
ffffffffc02027e2:	4ea60613          	addi	a2,a2,1258 # ffffffffc0205cc8 <default_pmm_manager+0x50>
ffffffffc02027e6:	08b00593          	li	a1,139
ffffffffc02027ea:	00003517          	auipc	a0,0x3
ffffffffc02027ee:	50650513          	addi	a0,a0,1286 # ffffffffc0205cf0 <default_pmm_manager+0x78>
ffffffffc02027f2:	c5ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02027f6:	00004697          	auipc	a3,0x4
ffffffffc02027fa:	92268693          	addi	a3,a3,-1758 # ffffffffc0206118 <default_pmm_manager+0x4a0>
ffffffffc02027fe:	00003617          	auipc	a2,0x3
ffffffffc0202802:	0e260613          	addi	a2,a2,226 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202806:	1ba00593          	li	a1,442
ffffffffc020280a:	00003517          	auipc	a0,0x3
ffffffffc020280e:	5ae50513          	addi	a0,a0,1454 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0202812:	c3ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202816:	00004697          	auipc	a3,0x4
ffffffffc020281a:	8ba68693          	addi	a3,a3,-1862 # ffffffffc02060d0 <default_pmm_manager+0x458>
ffffffffc020281e:	00003617          	auipc	a2,0x3
ffffffffc0202822:	0c260613          	addi	a2,a2,194 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202826:	1b800593          	li	a1,440
ffffffffc020282a:	00003517          	auipc	a0,0x3
ffffffffc020282e:	58e50513          	addi	a0,a0,1422 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0202832:	c1ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202836:	00004697          	auipc	a3,0x4
ffffffffc020283a:	8ca68693          	addi	a3,a3,-1846 # ffffffffc0206100 <default_pmm_manager+0x488>
ffffffffc020283e:	00003617          	auipc	a2,0x3
ffffffffc0202842:	0a260613          	addi	a2,a2,162 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202846:	1b700593          	li	a1,439
ffffffffc020284a:	00003517          	auipc	a0,0x3
ffffffffc020284e:	56e50513          	addi	a0,a0,1390 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0202852:	bfffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202856:	00004697          	auipc	a3,0x4
ffffffffc020285a:	a2a68693          	addi	a3,a3,-1494 # ffffffffc0206280 <default_pmm_manager+0x608>
ffffffffc020285e:	00003617          	auipc	a2,0x3
ffffffffc0202862:	08260613          	addi	a2,a2,130 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202866:	1da00593          	li	a1,474
ffffffffc020286a:	00003517          	auipc	a0,0x3
ffffffffc020286e:	54e50513          	addi	a0,a0,1358 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0202872:	bdffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202876:	00004697          	auipc	a3,0x4
ffffffffc020287a:	9ca68693          	addi	a3,a3,-1590 # ffffffffc0206240 <default_pmm_manager+0x5c8>
ffffffffc020287e:	00003617          	auipc	a2,0x3
ffffffffc0202882:	06260613          	addi	a2,a2,98 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202886:	1d900593          	li	a1,473
ffffffffc020288a:	00003517          	auipc	a0,0x3
ffffffffc020288e:	52e50513          	addi	a0,a0,1326 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0202892:	bbffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202896:	00004697          	auipc	a3,0x4
ffffffffc020289a:	99268693          	addi	a3,a3,-1646 # ffffffffc0206228 <default_pmm_manager+0x5b0>
ffffffffc020289e:	00003617          	auipc	a2,0x3
ffffffffc02028a2:	04260613          	addi	a2,a2,66 # ffffffffc02058e0 <commands+0x870>
ffffffffc02028a6:	1d800593          	li	a1,472
ffffffffc02028aa:	00003517          	auipc	a0,0x3
ffffffffc02028ae:	50e50513          	addi	a0,a0,1294 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc02028b2:	b9ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02028b6:	86be                	mv	a3,a5
ffffffffc02028b8:	00003617          	auipc	a2,0x3
ffffffffc02028bc:	41060613          	addi	a2,a2,1040 # ffffffffc0205cc8 <default_pmm_manager+0x50>
ffffffffc02028c0:	19900593          	li	a1,409
ffffffffc02028c4:	00003517          	auipc	a0,0x3
ffffffffc02028c8:	4f450513          	addi	a0,a0,1268 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc02028cc:	b85fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02028d0:	00003617          	auipc	a2,0x3
ffffffffc02028d4:	43060613          	addi	a2,a2,1072 # ffffffffc0205d00 <default_pmm_manager+0x88>
ffffffffc02028d8:	08500593          	li	a1,133
ffffffffc02028dc:	00003517          	auipc	a0,0x3
ffffffffc02028e0:	4dc50513          	addi	a0,a0,1244 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc02028e4:	b6dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02028e8:	00004697          	auipc	a3,0x4
ffffffffc02028ec:	9c868693          	addi	a3,a3,-1592 # ffffffffc02062b0 <default_pmm_manager+0x638>
ffffffffc02028f0:	00003617          	auipc	a2,0x3
ffffffffc02028f4:	ff060613          	addi	a2,a2,-16 # ffffffffc02058e0 <commands+0x870>
ffffffffc02028f8:	1de00593          	li	a1,478
ffffffffc02028fc:	00003517          	auipc	a0,0x3
ffffffffc0202900:	4bc50513          	addi	a0,a0,1212 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0202904:	b4dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202908:	00004697          	auipc	a3,0x4
ffffffffc020290c:	83868693          	addi	a3,a3,-1992 # ffffffffc0206140 <default_pmm_manager+0x4c8>
ffffffffc0202910:	00003617          	auipc	a2,0x3
ffffffffc0202914:	fd060613          	addi	a2,a2,-48 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202918:	1ea00593          	li	a1,490
ffffffffc020291c:	00003517          	auipc	a0,0x3
ffffffffc0202920:	49c50513          	addi	a0,a0,1180 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0202924:	b2dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202928:	00003697          	auipc	a3,0x3
ffffffffc020292c:	66868693          	addi	a3,a3,1640 # ffffffffc0205f90 <default_pmm_manager+0x318>
ffffffffc0202930:	00003617          	auipc	a2,0x3
ffffffffc0202934:	fb060613          	addi	a2,a2,-80 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202938:	19600593          	li	a1,406
ffffffffc020293c:	00003517          	auipc	a0,0x3
ffffffffc0202940:	47c50513          	addi	a0,a0,1148 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0202944:	b0dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pte2page(*ptep) == p1); //pte2page 函数将页表项转换为对应的物理页面，并将其与 p1 进行比较。如果它们相等，assert 宏将不会发生错误。
ffffffffc0202948:	00003697          	auipc	a3,0x3
ffffffffc020294c:	63068693          	addi	a3,a3,1584 # ffffffffc0205f78 <default_pmm_manager+0x300>
ffffffffc0202950:	00003617          	auipc	a2,0x3
ffffffffc0202954:	f9060613          	addi	a2,a2,-112 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202958:	19500593          	li	a1,405
ffffffffc020295c:	00003517          	auipc	a0,0x3
ffffffffc0202960:	45c50513          	addi	a0,a0,1116 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0202964:	aedfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202968:	00003697          	auipc	a3,0x3
ffffffffc020296c:	56068693          	addi	a3,a3,1376 # ffffffffc0205ec8 <default_pmm_manager+0x250>
ffffffffc0202970:	00003617          	auipc	a2,0x3
ffffffffc0202974:	f7060613          	addi	a2,a2,-144 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202978:	18900593          	li	a1,393
ffffffffc020297c:	00003517          	auipc	a0,0x3
ffffffffc0202980:	43c50513          	addi	a0,a0,1084 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0202984:	acdfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202988:	00003697          	auipc	a3,0x3
ffffffffc020298c:	59868693          	addi	a3,a3,1432 # ffffffffc0205f20 <default_pmm_manager+0x2a8>
ffffffffc0202990:	00003617          	auipc	a2,0x3
ffffffffc0202994:	f5060613          	addi	a2,a2,-176 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202998:	19400593          	li	a1,404
ffffffffc020299c:	00003517          	auipc	a0,0x3
ffffffffc02029a0:	41c50513          	addi	a0,a0,1052 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc02029a4:	aadfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0); //把这个物理页面通过多级页表映射到0x0
ffffffffc02029a8:	00003697          	auipc	a3,0x3
ffffffffc02029ac:	54868693          	addi	a3,a3,1352 # ffffffffc0205ef0 <default_pmm_manager+0x278>
ffffffffc02029b0:	00003617          	auipc	a2,0x3
ffffffffc02029b4:	f3060613          	addi	a2,a2,-208 # ffffffffc02058e0 <commands+0x870>
ffffffffc02029b8:	18f00593          	li	a1,399
ffffffffc02029bc:	00003517          	auipc	a0,0x3
ffffffffc02029c0:	3fc50513          	addi	a0,a0,1020 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc02029c4:	a8dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02029c8:	00003697          	auipc	a3,0x3
ffffffffc02029cc:	70868693          	addi	a3,a3,1800 # ffffffffc02060d0 <default_pmm_manager+0x458>
ffffffffc02029d0:	00003617          	auipc	a2,0x3
ffffffffc02029d4:	f1060613          	addi	a2,a2,-240 # ffffffffc02058e0 <commands+0x870>
ffffffffc02029d8:	1b400593          	li	a1,436
ffffffffc02029dc:	00003517          	auipc	a0,0x3
ffffffffc02029e0:	3dc50513          	addi	a0,a0,988 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc02029e4:	a6dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02029e8:	00003697          	auipc	a3,0x3
ffffffffc02029ec:	5a868693          	addi	a3,a3,1448 # ffffffffc0205f90 <default_pmm_manager+0x318>
ffffffffc02029f0:	00003617          	auipc	a2,0x3
ffffffffc02029f4:	ef060613          	addi	a2,a2,-272 # ffffffffc02058e0 <commands+0x870>
ffffffffc02029f8:	1b300593          	li	a1,435
ffffffffc02029fc:	00003517          	auipc	a0,0x3
ffffffffc0202a00:	3bc50513          	addi	a0,a0,956 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0202a04:	a4dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202a08:	00003697          	auipc	a3,0x3
ffffffffc0202a0c:	6e068693          	addi	a3,a3,1760 # ffffffffc02060e8 <default_pmm_manager+0x470>
ffffffffc0202a10:	00003617          	auipc	a2,0x3
ffffffffc0202a14:	ed060613          	addi	a2,a2,-304 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202a18:	1af00593          	li	a1,431
ffffffffc0202a1c:	00003517          	auipc	a0,0x3
ffffffffc0202a20:	39c50513          	addi	a0,a0,924 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0202a24:	a2dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a28:	00004697          	auipc	a3,0x4
ffffffffc0202a2c:	8c068693          	addi	a3,a3,-1856 # ffffffffc02062e8 <default_pmm_manager+0x670>
ffffffffc0202a30:	00003617          	auipc	a2,0x3
ffffffffc0202a34:	eb060613          	addi	a2,a2,-336 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202a38:	1e100593          	li	a1,481
ffffffffc0202a3c:	00003517          	auipc	a0,0x3
ffffffffc0202a40:	37c50513          	addi	a0,a0,892 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0202a44:	a0dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202a48:	00003697          	auipc	a3,0x3
ffffffffc0202a4c:	6f868693          	addi	a3,a3,1784 # ffffffffc0206140 <default_pmm_manager+0x4c8>
ffffffffc0202a50:	00003617          	auipc	a2,0x3
ffffffffc0202a54:	e9060613          	addi	a2,a2,-368 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202a58:	1c200593          	li	a1,450
ffffffffc0202a5c:	00003517          	auipc	a0,0x3
ffffffffc0202a60:	35c50513          	addi	a0,a0,860 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0202a64:	9edfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202a68:	00003697          	auipc	a3,0x3
ffffffffc0202a6c:	77068693          	addi	a3,a3,1904 # ffffffffc02061d8 <default_pmm_manager+0x560>
ffffffffc0202a70:	00003617          	auipc	a2,0x3
ffffffffc0202a74:	e7060613          	addi	a2,a2,-400 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202a78:	1d300593          	li	a1,467
ffffffffc0202a7c:	00003517          	auipc	a0,0x3
ffffffffc0202a80:	33c50513          	addi	a0,a0,828 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0202a84:	9cdfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(npage <= KERNTOP / PGSIZE); //确保内核不会超出其可用的虚拟地址空间。
ffffffffc0202a88:	00003697          	auipc	a3,0x3
ffffffffc0202a8c:	3e868693          	addi	a3,a3,1000 # ffffffffc0205e70 <default_pmm_manager+0x1f8>
ffffffffc0202a90:	00003617          	auipc	a2,0x3
ffffffffc0202a94:	e5060613          	addi	a2,a2,-432 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202a98:	18500593          	li	a1,389
ffffffffc0202a9c:	00003517          	auipc	a0,0x3
ffffffffc0202aa0:	31c50513          	addi	a0,a0,796 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0202aa4:	9adfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202aa8:	00003617          	auipc	a2,0x3
ffffffffc0202aac:	25860613          	addi	a2,a2,600 # ffffffffc0205d00 <default_pmm_manager+0x88>
ffffffffc0202ab0:	0c900593          	li	a1,201
ffffffffc0202ab4:	00003517          	auipc	a0,0x3
ffffffffc0202ab8:	30450513          	addi	a0,a0,772 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0202abc:	995fd0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0202ac0 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202ac0:	12058073          	sfence.vma	a1
}
ffffffffc0202ac4:	8082                	ret

ffffffffc0202ac6 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202ac6:	7179                	addi	sp,sp,-48
ffffffffc0202ac8:	e84a                	sd	s2,16(sp)
ffffffffc0202aca:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202acc:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202ace:	f022                	sd	s0,32(sp)
ffffffffc0202ad0:	ec26                	sd	s1,24(sp)
ffffffffc0202ad2:	e44e                	sd	s3,8(sp)
ffffffffc0202ad4:	f406                	sd	ra,40(sp)
ffffffffc0202ad6:	84ae                	mv	s1,a1
ffffffffc0202ad8:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202ada:	8e8ff0ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0202ade:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202ae0:	cd19                	beqz	a0,ffffffffc0202afe <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202ae2:	85aa                	mv	a1,a0
ffffffffc0202ae4:	86ce                	mv	a3,s3
ffffffffc0202ae6:	8626                	mv	a2,s1
ffffffffc0202ae8:	854a                	mv	a0,s2
ffffffffc0202aea:	c8eff0ef          	jal	ra,ffffffffc0201f78 <page_insert>
ffffffffc0202aee:	ed39                	bnez	a0,ffffffffc0202b4c <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0202af0:	00014797          	auipc	a5,0x14
ffffffffc0202af4:	9b878793          	addi	a5,a5,-1608 # ffffffffc02164a8 <swap_init_ok>
ffffffffc0202af8:	439c                	lw	a5,0(a5)
ffffffffc0202afa:	2781                	sext.w	a5,a5
ffffffffc0202afc:	eb89                	bnez	a5,ffffffffc0202b0e <pgdir_alloc_page+0x48>
}
ffffffffc0202afe:	8522                	mv	a0,s0
ffffffffc0202b00:	70a2                	ld	ra,40(sp)
ffffffffc0202b02:	7402                	ld	s0,32(sp)
ffffffffc0202b04:	64e2                	ld	s1,24(sp)
ffffffffc0202b06:	6942                	ld	s2,16(sp)
ffffffffc0202b08:	69a2                	ld	s3,8(sp)
ffffffffc0202b0a:	6145                	addi	sp,sp,48
ffffffffc0202b0c:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202b0e:	00014797          	auipc	a5,0x14
ffffffffc0202b12:	ada78793          	addi	a5,a5,-1318 # ffffffffc02165e8 <check_mm_struct>
ffffffffc0202b16:	6388                	ld	a0,0(a5)
ffffffffc0202b18:	4681                	li	a3,0
ffffffffc0202b1a:	8622                	mv	a2,s0
ffffffffc0202b1c:	85a6                	mv	a1,s1
ffffffffc0202b1e:	7be000ef          	jal	ra,ffffffffc02032dc <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202b22:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202b24:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0202b26:	4785                	li	a5,1
ffffffffc0202b28:	fcf70be3          	beq	a4,a5,ffffffffc0202afe <pgdir_alloc_page+0x38>
ffffffffc0202b2c:	00003697          	auipc	a3,0x3
ffffffffc0202b30:	29c68693          	addi	a3,a3,668 # ffffffffc0205dc8 <default_pmm_manager+0x150>
ffffffffc0202b34:	00003617          	auipc	a2,0x3
ffffffffc0202b38:	dac60613          	addi	a2,a2,-596 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202b3c:	16800593          	li	a1,360
ffffffffc0202b40:	00003517          	auipc	a0,0x3
ffffffffc0202b44:	27850513          	addi	a0,a0,632 # ffffffffc0205db8 <default_pmm_manager+0x140>
ffffffffc0202b48:	909fd0ef          	jal	ra,ffffffffc0200450 <__panic>
            free_page(page);
ffffffffc0202b4c:	8522                	mv	a0,s0
ffffffffc0202b4e:	4585                	li	a1,1
ffffffffc0202b50:	8faff0ef          	jal	ra,ffffffffc0201c4a <free_pages>
            return NULL;
ffffffffc0202b54:	4401                	li	s0,0
ffffffffc0202b56:	b765                	j	ffffffffc0202afe <pgdir_alloc_page+0x38>

ffffffffc0202b58 <swap_init>:
static void check_swap(void);

//用于初始化页面交换系统
int
swap_init(void)
{
ffffffffc0202b58:	7135                	addi	sp,sp,-160
ffffffffc0202b5a:	ed06                	sd	ra,152(sp)
ffffffffc0202b5c:	e922                	sd	s0,144(sp)
ffffffffc0202b5e:	e526                	sd	s1,136(sp)
ffffffffc0202b60:	e14a                	sd	s2,128(sp)
ffffffffc0202b62:	fcce                	sd	s3,120(sp)
ffffffffc0202b64:	f8d2                	sd	s4,112(sp)
ffffffffc0202b66:	f4d6                	sd	s5,104(sp)
ffffffffc0202b68:	f0da                	sd	s6,96(sp)
ffffffffc0202b6a:	ecde                	sd	s7,88(sp)
ffffffffc0202b6c:	e8e2                	sd	s8,80(sp)
ffffffffc0202b6e:	e4e6                	sd	s9,72(sp)
ffffffffc0202b70:	e0ea                	sd	s10,64(sp)
ffffffffc0202b72:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202b74:	528010ef          	jal	ra,ffffffffc020409c <swapfs_init>
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     // 检查最大交换偏移量是否在某个范围内
     if (!(7 <= max_swap_offset &&
ffffffffc0202b78:	00014797          	auipc	a5,0x14
ffffffffc0202b7c:	a2078793          	addi	a5,a5,-1504 # ffffffffc0216598 <max_swap_offset>
ffffffffc0202b80:	6394                	ld	a3,0(a5)
ffffffffc0202b82:	010007b7          	lui	a5,0x1000
ffffffffc0202b86:	17e1                	addi	a5,a5,-8
ffffffffc0202b88:	ff968713          	addi	a4,a3,-7
ffffffffc0202b8c:	4ae7e863          	bltu	a5,a4,ffffffffc020303c <swap_init+0x4e4>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0202b90:	00008797          	auipc	a5,0x8
ffffffffc0202b94:	48078793          	addi	a5,a5,1152 # ffffffffc020b010 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202b98:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202b9a:	00014697          	auipc	a3,0x14
ffffffffc0202b9e:	90f6b323          	sd	a5,-1786(a3) # ffffffffc02164a0 <sm>
     int r = sm->init();
ffffffffc0202ba2:	9702                	jalr	a4
ffffffffc0202ba4:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc0202ba6:	c10d                	beqz	a0,ffffffffc0202bc8 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202ba8:	60ea                	ld	ra,152(sp)
ffffffffc0202baa:	644a                	ld	s0,144(sp)
ffffffffc0202bac:	8556                	mv	a0,s5
ffffffffc0202bae:	64aa                	ld	s1,136(sp)
ffffffffc0202bb0:	690a                	ld	s2,128(sp)
ffffffffc0202bb2:	79e6                	ld	s3,120(sp)
ffffffffc0202bb4:	7a46                	ld	s4,112(sp)
ffffffffc0202bb6:	7aa6                	ld	s5,104(sp)
ffffffffc0202bb8:	7b06                	ld	s6,96(sp)
ffffffffc0202bba:	6be6                	ld	s7,88(sp)
ffffffffc0202bbc:	6c46                	ld	s8,80(sp)
ffffffffc0202bbe:	6ca6                	ld	s9,72(sp)
ffffffffc0202bc0:	6d06                	ld	s10,64(sp)
ffffffffc0202bc2:	7de2                	ld	s11,56(sp)
ffffffffc0202bc4:	610d                	addi	sp,sp,160
ffffffffc0202bc6:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202bc8:	00014797          	auipc	a5,0x14
ffffffffc0202bcc:	8d878793          	addi	a5,a5,-1832 # ffffffffc02164a0 <sm>
ffffffffc0202bd0:	639c                	ld	a5,0(a5)
ffffffffc0202bd2:	00003517          	auipc	a0,0x3
ffffffffc0202bd6:	7de50513          	addi	a0,a0,2014 # ffffffffc02063b0 <default_pmm_manager+0x738>
    return listelm->next;
ffffffffc0202bda:	00014417          	auipc	s0,0x14
ffffffffc0202bde:	8fe40413          	addi	s0,s0,-1794 # ffffffffc02164d8 <free_area>
ffffffffc0202be2:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202be4:	4785                	li	a5,1
ffffffffc0202be6:	00014717          	auipc	a4,0x14
ffffffffc0202bea:	8cf72123          	sw	a5,-1854(a4) # ffffffffc02164a8 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202bee:	da0fd0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0202bf2:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bf4:	36878863          	beq	a5,s0,ffffffffc0202f64 <swap_init+0x40c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202bf8:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202bfc:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202bfe:	8b05                	andi	a4,a4,1
ffffffffc0202c00:	36070663          	beqz	a4,ffffffffc0202f6c <swap_init+0x414>
     int ret, count = 0, total = 0, i;
ffffffffc0202c04:	4481                	li	s1,0
ffffffffc0202c06:	4901                	li	s2,0
ffffffffc0202c08:	a031                	j	ffffffffc0202c14 <swap_init+0xbc>
ffffffffc0202c0a:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0202c0e:	8b09                	andi	a4,a4,2
ffffffffc0202c10:	34070e63          	beqz	a4,ffffffffc0202f6c <swap_init+0x414>
        count ++, total += p->property;
ffffffffc0202c14:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202c18:	679c                	ld	a5,8(a5)
ffffffffc0202c1a:	2905                	addiw	s2,s2,1
ffffffffc0202c1c:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c1e:	fe8796e3          	bne	a5,s0,ffffffffc0202c0a <swap_init+0xb2>
ffffffffc0202c22:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202c24:	86cff0ef          	jal	ra,ffffffffc0201c90 <nr_free_pages>
ffffffffc0202c28:	69351263          	bne	a0,s3,ffffffffc02032ac <swap_init+0x754>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202c2c:	8626                	mv	a2,s1
ffffffffc0202c2e:	85ca                	mv	a1,s2
ffffffffc0202c30:	00003517          	auipc	a0,0x3
ffffffffc0202c34:	79850513          	addi	a0,a0,1944 # ffffffffc02063c8 <default_pmm_manager+0x750>
ffffffffc0202c38:	d56fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202c3c:	44b000ef          	jal	ra,ffffffffc0203886 <mm_create>
ffffffffc0202c40:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202c42:	60050563          	beqz	a0,ffffffffc020324c <swap_init+0x6f4>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202c46:	00014797          	auipc	a5,0x14
ffffffffc0202c4a:	9a278793          	addi	a5,a5,-1630 # ffffffffc02165e8 <check_mm_struct>
ffffffffc0202c4e:	639c                	ld	a5,0(a5)
ffffffffc0202c50:	60079e63          	bnez	a5,ffffffffc020326c <swap_init+0x714>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c54:	00014797          	auipc	a5,0x14
ffffffffc0202c58:	83c78793          	addi	a5,a5,-1988 # ffffffffc0216490 <boot_pgdir>
ffffffffc0202c5c:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0202c60:	00014797          	auipc	a5,0x14
ffffffffc0202c64:	98a7b423          	sd	a0,-1656(a5) # ffffffffc02165e8 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0202c68:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c6c:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202c70:	4e079263          	bnez	a5,ffffffffc0203154 <swap_init+0x5fc>

     // 创建一个虚拟内存区域，其起始地址为0x1000，大小为0x6000，属性为可读可写
     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202c74:	6599                	lui	a1,0x6
ffffffffc0202c76:	460d                	li	a2,3
ffffffffc0202c78:	6505                	lui	a0,0x1
ffffffffc0202c7a:	459000ef          	jal	ra,ffffffffc02038d2 <vma_create>
ffffffffc0202c7e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202c80:	4e050a63          	beqz	a0,ffffffffc0203174 <swap_init+0x61c>

     insert_vma_struct(mm, vma); // 将虚拟内存区域插入到mm_struct结构体中
ffffffffc0202c84:	855e                	mv	a0,s7
ffffffffc0202c86:	4b9000ef          	jal	ra,ffffffffc020393e <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202c8a:	00003517          	auipc	a0,0x3
ffffffffc0202c8e:	7ae50513          	addi	a0,a0,1966 # ffffffffc0206438 <default_pmm_manager+0x7c0>
ffffffffc0202c92:	cfcfd0ef          	jal	ra,ffffffffc020018e <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202c96:	018bb503          	ld	a0,24(s7)
ffffffffc0202c9a:	4605                	li	a2,1
ffffffffc0202c9c:	6585                	lui	a1,0x1
ffffffffc0202c9e:	832ff0ef          	jal	ra,ffffffffc0201cd0 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202ca2:	4e050963          	beqz	a0,ffffffffc0203194 <swap_init+0x63c>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202ca6:	00003517          	auipc	a0,0x3
ffffffffc0202caa:	7e250513          	addi	a0,a0,2018 # ffffffffc0206488 <default_pmm_manager+0x810>
ffffffffc0202cae:	00014997          	auipc	s3,0x14
ffffffffc0202cb2:	86298993          	addi	s3,s3,-1950 # ffffffffc0216510 <check_rp>
ffffffffc0202cb6:	cd8fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     // 分配4个物理页面
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cba:	00014a17          	auipc	s4,0x14
ffffffffc0202cbe:	876a0a13          	addi	s4,s4,-1930 # ffffffffc0216530 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202cc2:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0202cc4:	4505                	li	a0,1
ffffffffc0202cc6:	efdfe0ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
ffffffffc0202cca:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202cce:	32050763          	beqz	a0,ffffffffc0202ffc <swap_init+0x4a4>
ffffffffc0202cd2:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202cd4:	8b89                	andi	a5,a5,2
ffffffffc0202cd6:	30079363          	bnez	a5,ffffffffc0202fdc <swap_init+0x484>
ffffffffc0202cda:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cdc:	ff4c14e3          	bne	s8,s4,ffffffffc0202cc4 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list; // 备份
ffffffffc0202ce0:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202ce2:	00014c17          	auipc	s8,0x14
ffffffffc0202ce6:	82ec0c13          	addi	s8,s8,-2002 # ffffffffc0216510 <check_rp>
     list_entry_t free_list_store = free_list; // 备份
ffffffffc0202cea:	ec3e                	sd	a5,24(sp)
ffffffffc0202cec:	641c                	ld	a5,8(s0)
ffffffffc0202cee:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202cf0:	481c                	lw	a5,16(s0)
ffffffffc0202cf2:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202cf4:	00013797          	auipc	a5,0x13
ffffffffc0202cf8:	7e87b623          	sd	s0,2028(a5) # ffffffffc02164e0 <free_area+0x8>
ffffffffc0202cfc:	00013797          	auipc	a5,0x13
ffffffffc0202d00:	7c87be23          	sd	s0,2012(a5) # ffffffffc02164d8 <free_area>
     nr_free = 0;
ffffffffc0202d04:	00013797          	auipc	a5,0x13
ffffffffc0202d08:	7e07a223          	sw	zero,2020(a5) # ffffffffc02164e8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202d0c:	000c3503          	ld	a0,0(s8)
ffffffffc0202d10:	4585                	li	a1,1
ffffffffc0202d12:	0c21                	addi	s8,s8,8
ffffffffc0202d14:	f37fe0ef          	jal	ra,ffffffffc0201c4a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202d18:	ff4c1ae3          	bne	s8,s4,ffffffffc0202d0c <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202d1c:	01042c03          	lw	s8,16(s0)
ffffffffc0202d20:	4791                	li	a5,4
ffffffffc0202d22:	50fc1563          	bne	s8,a5,ffffffffc020322c <swap_init+0x6d4>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202d26:	00003517          	auipc	a0,0x3
ffffffffc0202d2a:	7ea50513          	addi	a0,a0,2026 # ffffffffc0206510 <default_pmm_manager+0x898>
ffffffffc0202d2e:	c60fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202d32:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202d34:	00013797          	auipc	a5,0x13
ffffffffc0202d38:	7607ac23          	sw	zero,1912(a5) # ffffffffc02164ac <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202d3c:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202d3e:	00013797          	auipc	a5,0x13
ffffffffc0202d42:	76e78793          	addi	a5,a5,1902 # ffffffffc02164ac <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202d46:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202d4a:	4398                	lw	a4,0(a5)
ffffffffc0202d4c:	4585                	li	a1,1
ffffffffc0202d4e:	2701                	sext.w	a4,a4
ffffffffc0202d50:	38b71263          	bne	a4,a1,ffffffffc02030d4 <swap_init+0x57c>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202d54:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202d58:	4394                	lw	a3,0(a5)
ffffffffc0202d5a:	2681                	sext.w	a3,a3
ffffffffc0202d5c:	38e69c63          	bne	a3,a4,ffffffffc02030f4 <swap_init+0x59c>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202d60:	6689                	lui	a3,0x2
ffffffffc0202d62:	462d                	li	a2,11
ffffffffc0202d64:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202d68:	4398                	lw	a4,0(a5)
ffffffffc0202d6a:	4589                	li	a1,2
ffffffffc0202d6c:	2701                	sext.w	a4,a4
ffffffffc0202d6e:	2eb71363          	bne	a4,a1,ffffffffc0203054 <swap_init+0x4fc>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202d72:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202d76:	4394                	lw	a3,0(a5)
ffffffffc0202d78:	2681                	sext.w	a3,a3
ffffffffc0202d7a:	2ee69d63          	bne	a3,a4,ffffffffc0203074 <swap_init+0x51c>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202d7e:	668d                	lui	a3,0x3
ffffffffc0202d80:	4631                	li	a2,12
ffffffffc0202d82:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202d86:	4398                	lw	a4,0(a5)
ffffffffc0202d88:	458d                	li	a1,3
ffffffffc0202d8a:	2701                	sext.w	a4,a4
ffffffffc0202d8c:	30b71463          	bne	a4,a1,ffffffffc0203094 <swap_init+0x53c>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202d90:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202d94:	4394                	lw	a3,0(a5)
ffffffffc0202d96:	2681                	sext.w	a3,a3
ffffffffc0202d98:	30e69e63          	bne	a3,a4,ffffffffc02030b4 <swap_init+0x55c>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202d9c:	6691                	lui	a3,0x4
ffffffffc0202d9e:	4635                	li	a2,13
ffffffffc0202da0:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202da4:	4398                	lw	a4,0(a5)
ffffffffc0202da6:	2701                	sext.w	a4,a4
ffffffffc0202da8:	37871663          	bne	a4,s8,ffffffffc0203114 <swap_init+0x5bc>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202dac:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202db0:	439c                	lw	a5,0(a5)
ffffffffc0202db2:	2781                	sext.w	a5,a5
ffffffffc0202db4:	38e79063          	bne	a5,a4,ffffffffc0203134 <swap_init+0x5dc>
     
     check_content_set(); // 初步检查页面交换函数
     assert( nr_free == 0);         
ffffffffc0202db8:	481c                	lw	a5,16(s0)
ffffffffc0202dba:	3e079d63          	bnez	a5,ffffffffc02031b4 <swap_init+0x65c>
ffffffffc0202dbe:	00013797          	auipc	a5,0x13
ffffffffc0202dc2:	77278793          	addi	a5,a5,1906 # ffffffffc0216530 <swap_in_seq_no>
ffffffffc0202dc6:	00013717          	auipc	a4,0x13
ffffffffc0202dca:	79270713          	addi	a4,a4,1938 # ffffffffc0216558 <swap_out_seq_no>
ffffffffc0202dce:	00013617          	auipc	a2,0x13
ffffffffc0202dd2:	78a60613          	addi	a2,a2,1930 # ffffffffc0216558 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202dd6:	56fd                	li	a3,-1
ffffffffc0202dd8:	c394                	sw	a3,0(a5)
ffffffffc0202dda:	c314                	sw	a3,0(a4)
ffffffffc0202ddc:	0791                	addi	a5,a5,4
ffffffffc0202dde:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202de0:	fef61ce3          	bne	a2,a5,ffffffffc0202dd8 <swap_init+0x280>
ffffffffc0202de4:	00013697          	auipc	a3,0x13
ffffffffc0202de8:	7d468693          	addi	a3,a3,2004 # ffffffffc02165b8 <check_ptep>
ffffffffc0202dec:	00013817          	auipc	a6,0x13
ffffffffc0202df0:	72480813          	addi	a6,a6,1828 # ffffffffc0216510 <check_rp>
ffffffffc0202df4:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202df6:	00013c97          	auipc	s9,0x13
ffffffffc0202dfa:	6a2c8c93          	addi	s9,s9,1698 # ffffffffc0216498 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dfe:	00004d97          	auipc	s11,0x4
ffffffffc0202e02:	26ad8d93          	addi	s11,s11,618 # ffffffffc0207068 <nbase>
ffffffffc0202e06:	00013c17          	auipc	s8,0x13
ffffffffc0202e0a:	702c0c13          	addi	s8,s8,1794 # ffffffffc0216508 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202e0e:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202e12:	4601                	li	a2,0
ffffffffc0202e14:	85ea                	mv	a1,s10
ffffffffc0202e16:	855a                	mv	a0,s6
ffffffffc0202e18:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202e1a:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202e1c:	eb5fe0ef          	jal	ra,ffffffffc0201cd0 <get_pte>
ffffffffc0202e20:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202e22:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202e24:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202e26:	1e050b63          	beqz	a0,ffffffffc020301c <swap_init+0x4c4>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202e2a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202e2c:	0017f613          	andi	a2,a5,1
ffffffffc0202e30:	18060a63          	beqz	a2,ffffffffc0202fc4 <swap_init+0x46c>
    if (PPN(pa) >= npage) {
ffffffffc0202e34:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202e38:	078a                	slli	a5,a5,0x2
ffffffffc0202e3a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e3c:	14c7f863          	bleu	a2,a5,ffffffffc0202f8c <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e40:	000db703          	ld	a4,0(s11)
ffffffffc0202e44:	000c3603          	ld	a2,0(s8)
ffffffffc0202e48:	00083583          	ld	a1,0(a6)
ffffffffc0202e4c:	8f99                	sub	a5,a5,a4
ffffffffc0202e4e:	079a                	slli	a5,a5,0x6
ffffffffc0202e50:	e43a                	sd	a4,8(sp)
ffffffffc0202e52:	97b2                	add	a5,a5,a2
ffffffffc0202e54:	14f59863          	bne	a1,a5,ffffffffc0202fa4 <swap_init+0x44c>
ffffffffc0202e58:	6785                	lui	a5,0x1
ffffffffc0202e5a:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202e5c:	6795                	lui	a5,0x5
ffffffffc0202e5e:	06a1                	addi	a3,a3,8
ffffffffc0202e60:	0821                	addi	a6,a6,8
ffffffffc0202e62:	fafd16e3          	bne	s10,a5,ffffffffc0202e0e <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202e66:	00003517          	auipc	a0,0x3
ffffffffc0202e6a:	75250513          	addi	a0,a0,1874 # ffffffffc02065b8 <default_pmm_manager+0x940>
ffffffffc0202e6e:	b20fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = sm->check_swap();
ffffffffc0202e72:	00013797          	auipc	a5,0x13
ffffffffc0202e76:	62e78793          	addi	a5,a5,1582 # ffffffffc02164a0 <sm>
ffffffffc0202e7a:	639c                	ld	a5,0(a5)
ffffffffc0202e7c:	7f9c                	ld	a5,56(a5)
ffffffffc0202e7e:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();  // 调用不同页面置换算法的check函数检查算法
     assert(ret==0);
ffffffffc0202e80:	40051663          	bnez	a0,ffffffffc020328c <swap_init+0x734>

     nr_free = nr_free_store;
ffffffffc0202e84:	77a2                	ld	a5,40(sp)
ffffffffc0202e86:	00013717          	auipc	a4,0x13
ffffffffc0202e8a:	66f72123          	sw	a5,1634(a4) # ffffffffc02164e8 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202e8e:	67e2                	ld	a5,24(sp)
ffffffffc0202e90:	00013717          	auipc	a4,0x13
ffffffffc0202e94:	64f73423          	sd	a5,1608(a4) # ffffffffc02164d8 <free_area>
ffffffffc0202e98:	7782                	ld	a5,32(sp)
ffffffffc0202e9a:	00013717          	auipc	a4,0x13
ffffffffc0202e9e:	64f73323          	sd	a5,1606(a4) # ffffffffc02164e0 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202ea2:	0009b503          	ld	a0,0(s3)
ffffffffc0202ea6:	4585                	li	a1,1
ffffffffc0202ea8:	09a1                	addi	s3,s3,8
ffffffffc0202eaa:	da1fe0ef          	jal	ra,ffffffffc0201c4a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202eae:	ff499ae3          	bne	s3,s4,ffffffffc0202ea2 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202eb2:	855e                	mv	a0,s7
ffffffffc0202eb4:	359000ef          	jal	ra,ffffffffc0203a0c <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202eb8:	00013797          	auipc	a5,0x13
ffffffffc0202ebc:	5d878793          	addi	a5,a5,1496 # ffffffffc0216490 <boot_pgdir>
ffffffffc0202ec0:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202ec2:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ec6:	6394                	ld	a3,0(a5)
ffffffffc0202ec8:	068a                	slli	a3,a3,0x2
ffffffffc0202eca:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ecc:	0ce6f063          	bleu	a4,a3,ffffffffc0202f8c <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ed0:	67a2                	ld	a5,8(sp)
ffffffffc0202ed2:	000c3503          	ld	a0,0(s8)
ffffffffc0202ed6:	8e9d                	sub	a3,a3,a5
ffffffffc0202ed8:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0202eda:	8699                	srai	a3,a3,0x6
ffffffffc0202edc:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0202ede:	57fd                	li	a5,-1
ffffffffc0202ee0:	83b1                	srli	a5,a5,0xc
ffffffffc0202ee2:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ee4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202ee6:	2ee7f763          	bleu	a4,a5,ffffffffc02031d4 <swap_init+0x67c>
     free_page(pde2page(pd0[0]));
ffffffffc0202eea:	00013797          	auipc	a5,0x13
ffffffffc0202eee:	60e78793          	addi	a5,a5,1550 # ffffffffc02164f8 <va_pa_offset>
ffffffffc0202ef2:	639c                	ld	a5,0(a5)
ffffffffc0202ef4:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ef6:	629c                	ld	a5,0(a3)
ffffffffc0202ef8:	078a                	slli	a5,a5,0x2
ffffffffc0202efa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202efc:	08e7f863          	bleu	a4,a5,ffffffffc0202f8c <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f00:	69a2                	ld	s3,8(sp)
ffffffffc0202f02:	4585                	li	a1,1
ffffffffc0202f04:	413787b3          	sub	a5,a5,s3
ffffffffc0202f08:	079a                	slli	a5,a5,0x6
ffffffffc0202f0a:	953e                	add	a0,a0,a5
ffffffffc0202f0c:	d3ffe0ef          	jal	ra,ffffffffc0201c4a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f10:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202f14:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f18:	078a                	slli	a5,a5,0x2
ffffffffc0202f1a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202f1c:	06e7f863          	bleu	a4,a5,ffffffffc0202f8c <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f20:	000c3503          	ld	a0,0(s8)
ffffffffc0202f24:	413787b3          	sub	a5,a5,s3
ffffffffc0202f28:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0202f2a:	4585                	li	a1,1
ffffffffc0202f2c:	953e                	add	a0,a0,a5
ffffffffc0202f2e:	d1dfe0ef          	jal	ra,ffffffffc0201c4a <free_pages>
     pgdir[0] = 0;
ffffffffc0202f32:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0202f36:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202f3a:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f3c:	00878963          	beq	a5,s0,ffffffffc0202f4e <swap_init+0x3f6>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202f40:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202f44:	679c                	ld	a5,8(a5)
ffffffffc0202f46:	397d                	addiw	s2,s2,-1
ffffffffc0202f48:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f4a:	fe879be3          	bne	a5,s0,ffffffffc0202f40 <swap_init+0x3e8>
     }
     assert(count==0);
ffffffffc0202f4e:	28091f63          	bnez	s2,ffffffffc02031ec <swap_init+0x694>
     assert(total==0);
ffffffffc0202f52:	2a049d63          	bnez	s1,ffffffffc020320c <swap_init+0x6b4>

     cprintf("check_swap() succeeded!\n");
ffffffffc0202f56:	00003517          	auipc	a0,0x3
ffffffffc0202f5a:	6b250513          	addi	a0,a0,1714 # ffffffffc0206608 <default_pmm_manager+0x990>
ffffffffc0202f5e:	a30fd0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0202f62:	b199                	j	ffffffffc0202ba8 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202f64:	4481                	li	s1,0
ffffffffc0202f66:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f68:	4981                	li	s3,0
ffffffffc0202f6a:	b96d                	j	ffffffffc0202c24 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202f6c:	00003697          	auipc	a3,0x3
ffffffffc0202f70:	96468693          	addi	a3,a3,-1692 # ffffffffc02058d0 <commands+0x860>
ffffffffc0202f74:	00003617          	auipc	a2,0x3
ffffffffc0202f78:	96c60613          	addi	a2,a2,-1684 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202f7c:	0cf00593          	li	a1,207
ffffffffc0202f80:	00003517          	auipc	a0,0x3
ffffffffc0202f84:	42050513          	addi	a0,a0,1056 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc0202f88:	cc8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202f8c:	00003617          	auipc	a2,0x3
ffffffffc0202f90:	d9c60613          	addi	a2,a2,-612 # ffffffffc0205d28 <default_pmm_manager+0xb0>
ffffffffc0202f94:	08000593          	li	a1,128
ffffffffc0202f98:	00003517          	auipc	a0,0x3
ffffffffc0202f9c:	d5850513          	addi	a0,a0,-680 # ffffffffc0205cf0 <default_pmm_manager+0x78>
ffffffffc0202fa0:	cb0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202fa4:	00003697          	auipc	a3,0x3
ffffffffc0202fa8:	5ec68693          	addi	a3,a3,1516 # ffffffffc0206590 <default_pmm_manager+0x918>
ffffffffc0202fac:	00003617          	auipc	a2,0x3
ffffffffc0202fb0:	93460613          	addi	a2,a2,-1740 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202fb4:	11200593          	li	a1,274
ffffffffc0202fb8:	00003517          	auipc	a0,0x3
ffffffffc0202fbc:	3e850513          	addi	a0,a0,1000 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc0202fc0:	c90fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202fc4:	00003617          	auipc	a2,0x3
ffffffffc0202fc8:	f8c60613          	addi	a2,a2,-116 # ffffffffc0205f50 <default_pmm_manager+0x2d8>
ffffffffc0202fcc:	09f00593          	li	a1,159
ffffffffc0202fd0:	00003517          	auipc	a0,0x3
ffffffffc0202fd4:	d2050513          	addi	a0,a0,-736 # ffffffffc0205cf0 <default_pmm_manager+0x78>
ffffffffc0202fd8:	c78fd0ef          	jal	ra,ffffffffc0200450 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202fdc:	00003697          	auipc	a3,0x3
ffffffffc0202fe0:	4ec68693          	addi	a3,a3,1260 # ffffffffc02064c8 <default_pmm_manager+0x850>
ffffffffc0202fe4:	00003617          	auipc	a2,0x3
ffffffffc0202fe8:	8fc60613          	addi	a2,a2,-1796 # ffffffffc02058e0 <commands+0x870>
ffffffffc0202fec:	0f200593          	li	a1,242
ffffffffc0202ff0:	00003517          	auipc	a0,0x3
ffffffffc0202ff4:	3b050513          	addi	a0,a0,944 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc0202ff8:	c58fd0ef          	jal	ra,ffffffffc0200450 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202ffc:	00003697          	auipc	a3,0x3
ffffffffc0203000:	4b468693          	addi	a3,a3,1204 # ffffffffc02064b0 <default_pmm_manager+0x838>
ffffffffc0203004:	00003617          	auipc	a2,0x3
ffffffffc0203008:	8dc60613          	addi	a2,a2,-1828 # ffffffffc02058e0 <commands+0x870>
ffffffffc020300c:	0f100593          	li	a1,241
ffffffffc0203010:	00003517          	auipc	a0,0x3
ffffffffc0203014:	39050513          	addi	a0,a0,912 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc0203018:	c38fd0ef          	jal	ra,ffffffffc0200450 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc020301c:	00003697          	auipc	a3,0x3
ffffffffc0203020:	55c68693          	addi	a3,a3,1372 # ffffffffc0206578 <default_pmm_manager+0x900>
ffffffffc0203024:	00003617          	auipc	a2,0x3
ffffffffc0203028:	8bc60613          	addi	a2,a2,-1860 # ffffffffc02058e0 <commands+0x870>
ffffffffc020302c:	11100593          	li	a1,273
ffffffffc0203030:	00003517          	auipc	a0,0x3
ffffffffc0203034:	37050513          	addi	a0,a0,880 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc0203038:	c18fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020303c:	00003617          	auipc	a2,0x3
ffffffffc0203040:	34460613          	addi	a2,a2,836 # ffffffffc0206380 <default_pmm_manager+0x708>
ffffffffc0203044:	02c00593          	li	a1,44
ffffffffc0203048:	00003517          	auipc	a0,0x3
ffffffffc020304c:	35850513          	addi	a0,a0,856 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc0203050:	c00fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==2);
ffffffffc0203054:	00003697          	auipc	a3,0x3
ffffffffc0203058:	4f468693          	addi	a3,a3,1268 # ffffffffc0206548 <default_pmm_manager+0x8d0>
ffffffffc020305c:	00003617          	auipc	a2,0x3
ffffffffc0203060:	88460613          	addi	a2,a2,-1916 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203064:	0a500593          	li	a1,165
ffffffffc0203068:	00003517          	auipc	a0,0x3
ffffffffc020306c:	33850513          	addi	a0,a0,824 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc0203070:	be0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==2);
ffffffffc0203074:	00003697          	auipc	a3,0x3
ffffffffc0203078:	4d468693          	addi	a3,a3,1236 # ffffffffc0206548 <default_pmm_manager+0x8d0>
ffffffffc020307c:	00003617          	auipc	a2,0x3
ffffffffc0203080:	86460613          	addi	a2,a2,-1948 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203084:	0a700593          	li	a1,167
ffffffffc0203088:	00003517          	auipc	a0,0x3
ffffffffc020308c:	31850513          	addi	a0,a0,792 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc0203090:	bc0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==3);
ffffffffc0203094:	00003697          	auipc	a3,0x3
ffffffffc0203098:	4c468693          	addi	a3,a3,1220 # ffffffffc0206558 <default_pmm_manager+0x8e0>
ffffffffc020309c:	00003617          	auipc	a2,0x3
ffffffffc02030a0:	84460613          	addi	a2,a2,-1980 # ffffffffc02058e0 <commands+0x870>
ffffffffc02030a4:	0a900593          	li	a1,169
ffffffffc02030a8:	00003517          	auipc	a0,0x3
ffffffffc02030ac:	2f850513          	addi	a0,a0,760 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc02030b0:	ba0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==3);
ffffffffc02030b4:	00003697          	auipc	a3,0x3
ffffffffc02030b8:	4a468693          	addi	a3,a3,1188 # ffffffffc0206558 <default_pmm_manager+0x8e0>
ffffffffc02030bc:	00003617          	auipc	a2,0x3
ffffffffc02030c0:	82460613          	addi	a2,a2,-2012 # ffffffffc02058e0 <commands+0x870>
ffffffffc02030c4:	0ab00593          	li	a1,171
ffffffffc02030c8:	00003517          	auipc	a0,0x3
ffffffffc02030cc:	2d850513          	addi	a0,a0,728 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc02030d0:	b80fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==1);
ffffffffc02030d4:	00003697          	auipc	a3,0x3
ffffffffc02030d8:	46468693          	addi	a3,a3,1124 # ffffffffc0206538 <default_pmm_manager+0x8c0>
ffffffffc02030dc:	00003617          	auipc	a2,0x3
ffffffffc02030e0:	80460613          	addi	a2,a2,-2044 # ffffffffc02058e0 <commands+0x870>
ffffffffc02030e4:	0a100593          	li	a1,161
ffffffffc02030e8:	00003517          	auipc	a0,0x3
ffffffffc02030ec:	2b850513          	addi	a0,a0,696 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc02030f0:	b60fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==1);
ffffffffc02030f4:	00003697          	auipc	a3,0x3
ffffffffc02030f8:	44468693          	addi	a3,a3,1092 # ffffffffc0206538 <default_pmm_manager+0x8c0>
ffffffffc02030fc:	00002617          	auipc	a2,0x2
ffffffffc0203100:	7e460613          	addi	a2,a2,2020 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203104:	0a300593          	li	a1,163
ffffffffc0203108:	00003517          	auipc	a0,0x3
ffffffffc020310c:	29850513          	addi	a0,a0,664 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc0203110:	b40fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==4);
ffffffffc0203114:	00003697          	auipc	a3,0x3
ffffffffc0203118:	45468693          	addi	a3,a3,1108 # ffffffffc0206568 <default_pmm_manager+0x8f0>
ffffffffc020311c:	00002617          	auipc	a2,0x2
ffffffffc0203120:	7c460613          	addi	a2,a2,1988 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203124:	0ad00593          	li	a1,173
ffffffffc0203128:	00003517          	auipc	a0,0x3
ffffffffc020312c:	27850513          	addi	a0,a0,632 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc0203130:	b20fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==4);
ffffffffc0203134:	00003697          	auipc	a3,0x3
ffffffffc0203138:	43468693          	addi	a3,a3,1076 # ffffffffc0206568 <default_pmm_manager+0x8f0>
ffffffffc020313c:	00002617          	auipc	a2,0x2
ffffffffc0203140:	7a460613          	addi	a2,a2,1956 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203144:	0af00593          	li	a1,175
ffffffffc0203148:	00003517          	auipc	a0,0x3
ffffffffc020314c:	25850513          	addi	a0,a0,600 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc0203150:	b00fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203154:	00003697          	auipc	a3,0x3
ffffffffc0203158:	2c468693          	addi	a3,a3,708 # ffffffffc0206418 <default_pmm_manager+0x7a0>
ffffffffc020315c:	00002617          	auipc	a2,0x2
ffffffffc0203160:	78460613          	addi	a2,a2,1924 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203164:	0df00593          	li	a1,223
ffffffffc0203168:	00003517          	auipc	a0,0x3
ffffffffc020316c:	23850513          	addi	a0,a0,568 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc0203170:	ae0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(vma != NULL);
ffffffffc0203174:	00003697          	auipc	a3,0x3
ffffffffc0203178:	2b468693          	addi	a3,a3,692 # ffffffffc0206428 <default_pmm_manager+0x7b0>
ffffffffc020317c:	00002617          	auipc	a2,0x2
ffffffffc0203180:	76460613          	addi	a2,a2,1892 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203184:	0e300593          	li	a1,227
ffffffffc0203188:	00003517          	auipc	a0,0x3
ffffffffc020318c:	21850513          	addi	a0,a0,536 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc0203190:	ac0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203194:	00003697          	auipc	a3,0x3
ffffffffc0203198:	2dc68693          	addi	a3,a3,732 # ffffffffc0206470 <default_pmm_manager+0x7f8>
ffffffffc020319c:	00002617          	auipc	a2,0x2
ffffffffc02031a0:	74460613          	addi	a2,a2,1860 # ffffffffc02058e0 <commands+0x870>
ffffffffc02031a4:	0eb00593          	li	a1,235
ffffffffc02031a8:	00003517          	auipc	a0,0x3
ffffffffc02031ac:	1f850513          	addi	a0,a0,504 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc02031b0:	aa0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert( nr_free == 0);         
ffffffffc02031b4:	00003697          	auipc	a3,0x3
ffffffffc02031b8:	90468693          	addi	a3,a3,-1788 # ffffffffc0205ab8 <commands+0xa48>
ffffffffc02031bc:	00002617          	auipc	a2,0x2
ffffffffc02031c0:	72460613          	addi	a2,a2,1828 # ffffffffc02058e0 <commands+0x870>
ffffffffc02031c4:	10900593          	li	a1,265
ffffffffc02031c8:	00003517          	auipc	a0,0x3
ffffffffc02031cc:	1d850513          	addi	a0,a0,472 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc02031d0:	a80fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    return KADDR(page2pa(page));
ffffffffc02031d4:	00003617          	auipc	a2,0x3
ffffffffc02031d8:	af460613          	addi	a2,a2,-1292 # ffffffffc0205cc8 <default_pmm_manager+0x50>
ffffffffc02031dc:	08b00593          	li	a1,139
ffffffffc02031e0:	00003517          	auipc	a0,0x3
ffffffffc02031e4:	b1050513          	addi	a0,a0,-1264 # ffffffffc0205cf0 <default_pmm_manager+0x78>
ffffffffc02031e8:	a68fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(count==0);
ffffffffc02031ec:	00003697          	auipc	a3,0x3
ffffffffc02031f0:	3fc68693          	addi	a3,a3,1020 # ffffffffc02065e8 <default_pmm_manager+0x970>
ffffffffc02031f4:	00002617          	auipc	a2,0x2
ffffffffc02031f8:	6ec60613          	addi	a2,a2,1772 # ffffffffc02058e0 <commands+0x870>
ffffffffc02031fc:	13100593          	li	a1,305
ffffffffc0203200:	00003517          	auipc	a0,0x3
ffffffffc0203204:	1a050513          	addi	a0,a0,416 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc0203208:	a48fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(total==0);
ffffffffc020320c:	00003697          	auipc	a3,0x3
ffffffffc0203210:	3ec68693          	addi	a3,a3,1004 # ffffffffc02065f8 <default_pmm_manager+0x980>
ffffffffc0203214:	00002617          	auipc	a2,0x2
ffffffffc0203218:	6cc60613          	addi	a2,a2,1740 # ffffffffc02058e0 <commands+0x870>
ffffffffc020321c:	13200593          	li	a1,306
ffffffffc0203220:	00003517          	auipc	a0,0x3
ffffffffc0203224:	18050513          	addi	a0,a0,384 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc0203228:	a28fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020322c:	00003697          	auipc	a3,0x3
ffffffffc0203230:	2bc68693          	addi	a3,a3,700 # ffffffffc02064e8 <default_pmm_manager+0x870>
ffffffffc0203234:	00002617          	auipc	a2,0x2
ffffffffc0203238:	6ac60613          	addi	a2,a2,1708 # ffffffffc02058e0 <commands+0x870>
ffffffffc020323c:	10000593          	li	a1,256
ffffffffc0203240:	00003517          	auipc	a0,0x3
ffffffffc0203244:	16050513          	addi	a0,a0,352 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc0203248:	a08fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(mm != NULL);
ffffffffc020324c:	00003697          	auipc	a3,0x3
ffffffffc0203250:	1a468693          	addi	a3,a3,420 # ffffffffc02063f0 <default_pmm_manager+0x778>
ffffffffc0203254:	00002617          	auipc	a2,0x2
ffffffffc0203258:	68c60613          	addi	a2,a2,1676 # ffffffffc02058e0 <commands+0x870>
ffffffffc020325c:	0d700593          	li	a1,215
ffffffffc0203260:	00003517          	auipc	a0,0x3
ffffffffc0203264:	14050513          	addi	a0,a0,320 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc0203268:	9e8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc020326c:	00003697          	auipc	a3,0x3
ffffffffc0203270:	19468693          	addi	a3,a3,404 # ffffffffc0206400 <default_pmm_manager+0x788>
ffffffffc0203274:	00002617          	auipc	a2,0x2
ffffffffc0203278:	66c60613          	addi	a2,a2,1644 # ffffffffc02058e0 <commands+0x870>
ffffffffc020327c:	0da00593          	li	a1,218
ffffffffc0203280:	00003517          	auipc	a0,0x3
ffffffffc0203284:	12050513          	addi	a0,a0,288 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc0203288:	9c8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(ret==0);
ffffffffc020328c:	00003697          	auipc	a3,0x3
ffffffffc0203290:	35468693          	addi	a3,a3,852 # ffffffffc02065e0 <default_pmm_manager+0x968>
ffffffffc0203294:	00002617          	auipc	a2,0x2
ffffffffc0203298:	64c60613          	addi	a2,a2,1612 # ffffffffc02058e0 <commands+0x870>
ffffffffc020329c:	11800593          	li	a1,280
ffffffffc02032a0:	00003517          	auipc	a0,0x3
ffffffffc02032a4:	10050513          	addi	a0,a0,256 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc02032a8:	9a8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(total == nr_free_pages());
ffffffffc02032ac:	00002697          	auipc	a3,0x2
ffffffffc02032b0:	66468693          	addi	a3,a3,1636 # ffffffffc0205910 <commands+0x8a0>
ffffffffc02032b4:	00002617          	auipc	a2,0x2
ffffffffc02032b8:	62c60613          	addi	a2,a2,1580 # ffffffffc02058e0 <commands+0x870>
ffffffffc02032bc:	0d200593          	li	a1,210
ffffffffc02032c0:	00003517          	auipc	a0,0x3
ffffffffc02032c4:	0e050513          	addi	a0,a0,224 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc02032c8:	988fd0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02032cc <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02032cc:	00013797          	auipc	a5,0x13
ffffffffc02032d0:	1d478793          	addi	a5,a5,468 # ffffffffc02164a0 <sm>
ffffffffc02032d4:	639c                	ld	a5,0(a5)
ffffffffc02032d6:	0107b303          	ld	t1,16(a5)
ffffffffc02032da:	8302                	jr	t1

ffffffffc02032dc <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02032dc:	00013797          	auipc	a5,0x13
ffffffffc02032e0:	1c478793          	addi	a5,a5,452 # ffffffffc02164a0 <sm>
ffffffffc02032e4:	639c                	ld	a5,0(a5)
ffffffffc02032e6:	0207b303          	ld	t1,32(a5)
ffffffffc02032ea:	8302                	jr	t1

ffffffffc02032ec <swap_out>:
{
ffffffffc02032ec:	711d                	addi	sp,sp,-96
ffffffffc02032ee:	ec86                	sd	ra,88(sp)
ffffffffc02032f0:	e8a2                	sd	s0,80(sp)
ffffffffc02032f2:	e4a6                	sd	s1,72(sp)
ffffffffc02032f4:	e0ca                	sd	s2,64(sp)
ffffffffc02032f6:	fc4e                	sd	s3,56(sp)
ffffffffc02032f8:	f852                	sd	s4,48(sp)
ffffffffc02032fa:	f456                	sd	s5,40(sp)
ffffffffc02032fc:	f05a                	sd	s6,32(sp)
ffffffffc02032fe:	ec5e                	sd	s7,24(sp)
ffffffffc0203300:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203302:	cde9                	beqz	a1,ffffffffc02033dc <swap_out+0xf0>
ffffffffc0203304:	8ab2                	mv	s5,a2
ffffffffc0203306:	892a                	mv	s2,a0
ffffffffc0203308:	8a2e                	mv	s4,a1
ffffffffc020330a:	4401                	li	s0,0
ffffffffc020330c:	00013997          	auipc	s3,0x13
ffffffffc0203310:	19498993          	addi	s3,s3,404 # ffffffffc02164a0 <sm>
               cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr / PGSIZE + 1);
ffffffffc0203314:	00003b17          	auipc	s6,0x3
ffffffffc0203318:	374b0b13          	addi	s6,s6,884 # ffffffffc0206688 <default_pmm_manager+0xa10>
               cprintf("SWAP: failed to save\n");
ffffffffc020331c:	00003b97          	auipc	s7,0x3
ffffffffc0203320:	354b8b93          	addi	s7,s7,852 # ffffffffc0206670 <default_pmm_manager+0x9f8>
ffffffffc0203324:	a825                	j	ffffffffc020335c <swap_out+0x70>
               cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr / PGSIZE + 1);
ffffffffc0203326:	67a2                	ld	a5,8(sp)
ffffffffc0203328:	8626                	mv	a2,s1
ffffffffc020332a:	85a2                	mv	a1,s0
ffffffffc020332c:	7f94                	ld	a3,56(a5)
ffffffffc020332e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203330:	2405                	addiw	s0,s0,1
               cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr / PGSIZE + 1);
ffffffffc0203332:	82b1                	srli	a3,a3,0xc
ffffffffc0203334:	0685                	addi	a3,a3,1
ffffffffc0203336:	e59fc0ef          	jal	ra,ffffffffc020018e <cprintf>
               *ptep = (page->pra_vaddr / PGSIZE + 1) << 8;
ffffffffc020333a:	6522                	ld	a0,8(sp)
               free_page(page);
ffffffffc020333c:	4585                	li	a1,1
               *ptep = (page->pra_vaddr / PGSIZE + 1) << 8;
ffffffffc020333e:	7d1c                	ld	a5,56(a0)
ffffffffc0203340:	83b1                	srli	a5,a5,0xc
ffffffffc0203342:	0785                	addi	a5,a5,1
ffffffffc0203344:	07a2                	slli	a5,a5,0x8
ffffffffc0203346:	00fc3023          	sd	a5,0(s8)
               free_page(page);
ffffffffc020334a:	901fe0ef          	jal	ra,ffffffffc0201c4a <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc020334e:	01893503          	ld	a0,24(s2)
ffffffffc0203352:	85a6                	mv	a1,s1
ffffffffc0203354:	f6cff0ef          	jal	ra,ffffffffc0202ac0 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203358:	048a0d63          	beq	s4,s0,ffffffffc02033b2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc020335c:	0009b783          	ld	a5,0(s3)
ffffffffc0203360:	8656                	mv	a2,s5
ffffffffc0203362:	002c                	addi	a1,sp,8
ffffffffc0203364:	7b9c                	ld	a5,48(a5)
ffffffffc0203366:	854a                	mv	a0,s2
ffffffffc0203368:	9782                	jalr	a5
          if (r != 0) {
ffffffffc020336a:	e12d                	bnez	a0,ffffffffc02033cc <swap_out+0xe0>
          v = page->pra_vaddr;                    // 要换出页面的虚拟地址
ffffffffc020336c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0); // 找到页表项指针
ffffffffc020336e:	01893503          	ld	a0,24(s2)
ffffffffc0203372:	4601                	li	a2,0
          v = page->pra_vaddr;                    // 要换出页面的虚拟地址
ffffffffc0203374:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0); // 找到页表项指针
ffffffffc0203376:	85a6                	mv	a1,s1
ffffffffc0203378:	959fe0ef          	jal	ra,ffffffffc0201cd0 <get_pte>
          assert((*ptep & PTE_V) != 0);           // 判断页表项是否有效
ffffffffc020337c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0); // 找到页表项指针
ffffffffc020337e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);           // 判断页表项是否有效
ffffffffc0203380:	8b85                	andi	a5,a5,1
ffffffffc0203382:	cfb9                	beqz	a5,ffffffffc02033e0 <swap_out+0xf4>
          if (swapfs_write((page->pra_vaddr / PGSIZE + 1) << 8, page) != 0)
ffffffffc0203384:	65a2                	ld	a1,8(sp)
ffffffffc0203386:	7d9c                	ld	a5,56(a1)
ffffffffc0203388:	83b1                	srli	a5,a5,0xc
ffffffffc020338a:	00178513          	addi	a0,a5,1
ffffffffc020338e:	0522                	slli	a0,a0,0x8
ffffffffc0203390:	5dd000ef          	jal	ra,ffffffffc020416c <swapfs_write>
ffffffffc0203394:	d949                	beqz	a0,ffffffffc0203326 <swap_out+0x3a>
               cprintf("SWAP: failed to save\n");
ffffffffc0203396:	855e                	mv	a0,s7
ffffffffc0203398:	df7fc0ef          	jal	ra,ffffffffc020018e <cprintf>
               sm->map_swappable(mm, v, page, 0);
ffffffffc020339c:	0009b783          	ld	a5,0(s3)
ffffffffc02033a0:	6622                	ld	a2,8(sp)
ffffffffc02033a2:	4681                	li	a3,0
ffffffffc02033a4:	739c                	ld	a5,32(a5)
ffffffffc02033a6:	85a6                	mv	a1,s1
ffffffffc02033a8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc02033aa:	2405                	addiw	s0,s0,1
               sm->map_swappable(mm, v, page, 0);
ffffffffc02033ac:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc02033ae:	fa8a17e3          	bne	s4,s0,ffffffffc020335c <swap_out+0x70>
}
ffffffffc02033b2:	8522                	mv	a0,s0
ffffffffc02033b4:	60e6                	ld	ra,88(sp)
ffffffffc02033b6:	6446                	ld	s0,80(sp)
ffffffffc02033b8:	64a6                	ld	s1,72(sp)
ffffffffc02033ba:	6906                	ld	s2,64(sp)
ffffffffc02033bc:	79e2                	ld	s3,56(sp)
ffffffffc02033be:	7a42                	ld	s4,48(sp)
ffffffffc02033c0:	7aa2                	ld	s5,40(sp)
ffffffffc02033c2:	7b02                	ld	s6,32(sp)
ffffffffc02033c4:	6be2                	ld	s7,24(sp)
ffffffffc02033c6:	6c42                	ld	s8,16(sp)
ffffffffc02033c8:	6125                	addi	sp,sp,96
ffffffffc02033ca:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02033cc:	85a2                	mv	a1,s0
ffffffffc02033ce:	00003517          	auipc	a0,0x3
ffffffffc02033d2:	25a50513          	addi	a0,a0,602 # ffffffffc0206628 <default_pmm_manager+0x9b0>
ffffffffc02033d6:	db9fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                  break;
ffffffffc02033da:	bfe1                	j	ffffffffc02033b2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02033dc:	4401                	li	s0,0
ffffffffc02033de:	bfd1                	j	ffffffffc02033b2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);           // 判断页表项是否有效
ffffffffc02033e0:	00003697          	auipc	a3,0x3
ffffffffc02033e4:	27868693          	addi	a3,a3,632 # ffffffffc0206658 <default_pmm_manager+0x9e0>
ffffffffc02033e8:	00002617          	auipc	a2,0x2
ffffffffc02033ec:	4f860613          	addi	a2,a2,1272 # ffffffffc02058e0 <commands+0x870>
ffffffffc02033f0:	06c00593          	li	a1,108
ffffffffc02033f4:	00003517          	auipc	a0,0x3
ffffffffc02033f8:	fac50513          	addi	a0,a0,-84 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc02033fc:	854fd0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203400 <swap_in>:
{
ffffffffc0203400:	7179                	addi	sp,sp,-48
ffffffffc0203402:	e84a                	sd	s2,16(sp)
ffffffffc0203404:	892a                	mv	s2,a0
     struct Page *result = alloc_page(); //这里alloc_page()内部可能调用swap_out()
ffffffffc0203406:	4505                	li	a0,1
{
ffffffffc0203408:	ec26                	sd	s1,24(sp)
ffffffffc020340a:	e44e                	sd	s3,8(sp)
ffffffffc020340c:	f406                	sd	ra,40(sp)
ffffffffc020340e:	f022                	sd	s0,32(sp)
ffffffffc0203410:	84ae                	mv	s1,a1
ffffffffc0203412:	89b2                	mv	s3,a2
     struct Page *result = alloc_page(); //这里alloc_page()内部可能调用swap_out()
ffffffffc0203414:	faefe0ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
     assert(result != NULL);
ffffffffc0203418:	c129                	beqz	a0,ffffffffc020345a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0); //找到/构建对应的页表项
ffffffffc020341a:	842a                	mv	s0,a0
ffffffffc020341c:	01893503          	ld	a0,24(s2)
ffffffffc0203420:	4601                	li	a2,0
ffffffffc0203422:	85a6                	mv	a1,s1
ffffffffc0203424:	8adfe0ef          	jal	ra,ffffffffc0201cd0 <get_pte>
ffffffffc0203428:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020342a:	6108                	ld	a0,0(a0)
ffffffffc020342c:	85a2                	mv	a1,s0
ffffffffc020342e:	4a7000ef          	jal	ra,ffffffffc02040d4 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203432:	00093583          	ld	a1,0(s2)
ffffffffc0203436:	8626                	mv	a2,s1
ffffffffc0203438:	00003517          	auipc	a0,0x3
ffffffffc020343c:	f0850513          	addi	a0,a0,-248 # ffffffffc0206340 <default_pmm_manager+0x6c8>
ffffffffc0203440:	81a1                	srli	a1,a1,0x8
ffffffffc0203442:	d4dfc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0203446:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203448:	0089b023          	sd	s0,0(s3)
}
ffffffffc020344c:	7402                	ld	s0,32(sp)
ffffffffc020344e:	64e2                	ld	s1,24(sp)
ffffffffc0203450:	6942                	ld	s2,16(sp)
ffffffffc0203452:	69a2                	ld	s3,8(sp)
ffffffffc0203454:	4501                	li	a0,0
ffffffffc0203456:	6145                	addi	sp,sp,48
ffffffffc0203458:	8082                	ret
     assert(result != NULL);
ffffffffc020345a:	00003697          	auipc	a3,0x3
ffffffffc020345e:	ed668693          	addi	a3,a3,-298 # ffffffffc0206330 <default_pmm_manager+0x6b8>
ffffffffc0203462:	00002617          	auipc	a2,0x2
ffffffffc0203466:	47e60613          	addi	a2,a2,1150 # ffffffffc02058e0 <commands+0x870>
ffffffffc020346a:	08900593          	li	a1,137
ffffffffc020346e:	00003517          	auipc	a0,0x3
ffffffffc0203472:	f3250513          	addi	a0,a0,-206 # ffffffffc02063a0 <default_pmm_manager+0x728>
ffffffffc0203476:	fdbfc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020347a <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020347a:	00013797          	auipc	a5,0x13
ffffffffc020347e:	15e78793          	addi	a5,a5,350 # ffffffffc02165d8 <pra_list_head>
//该函数初始化用于FIFO算法的页面队列。
static int
_fifo_init_mm(struct mm_struct *mm)
{
    list_init(&pra_list_head); //初始化一个全局的双向链表头，该链表将用于存储所有可交换（可替换）的页面。
    mm->sm_priv = &pra_list_head;
ffffffffc0203482:	f51c                	sd	a5,40(a0)
ffffffffc0203484:	e79c                	sd	a5,8(a5)
ffffffffc0203486:	e39c                	sd	a5,0(a5)
    // 上面这句这句将mm->sm_priv指针指向pra_list_head。这样，从内存管理结构mm_struct中，我们可以访问到FIFO页面置换算法的队列
    //  cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    return 0;
}
ffffffffc0203488:	4501                	li	a0,0
ffffffffc020348a:	8082                	ret

ffffffffc020348c <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc020348c:	4501                	li	a0,0
ffffffffc020348e:	8082                	ret

ffffffffc0203490 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203490:	4501                	li	a0,0
ffffffffc0203492:	8082                	ret

ffffffffc0203494 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203494:	4501                	li	a0,0
ffffffffc0203496:	8082                	ret

ffffffffc0203498 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203498:	711d                	addi	sp,sp,-96
ffffffffc020349a:	fc4e                	sd	s3,56(sp)
ffffffffc020349c:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020349e:	00003517          	auipc	a0,0x3
ffffffffc02034a2:	22a50513          	addi	a0,a0,554 # ffffffffc02066c8 <default_pmm_manager+0xa50>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02034a6:	698d                	lui	s3,0x3
ffffffffc02034a8:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc02034aa:	e8a2                	sd	s0,80(sp)
ffffffffc02034ac:	e4a6                	sd	s1,72(sp)
ffffffffc02034ae:	ec86                	sd	ra,88(sp)
ffffffffc02034b0:	e0ca                	sd	s2,64(sp)
ffffffffc02034b2:	f456                	sd	s5,40(sp)
ffffffffc02034b4:	f05a                	sd	s6,32(sp)
ffffffffc02034b6:	ec5e                	sd	s7,24(sp)
ffffffffc02034b8:	e862                	sd	s8,16(sp)
ffffffffc02034ba:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc02034bc:	00013417          	auipc	s0,0x13
ffffffffc02034c0:	ff040413          	addi	s0,s0,-16 # ffffffffc02164ac <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02034c4:	ccbfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02034c8:	01498023          	sb	s4,0(s3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02034cc:	4004                	lw	s1,0(s0)
ffffffffc02034ce:	4791                	li	a5,4
ffffffffc02034d0:	2481                	sext.w	s1,s1
ffffffffc02034d2:	14f49963          	bne	s1,a5,ffffffffc0203624 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02034d6:	00003517          	auipc	a0,0x3
ffffffffc02034da:	23250513          	addi	a0,a0,562 # ffffffffc0206708 <default_pmm_manager+0xa90>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02034de:	6a85                	lui	s5,0x1
ffffffffc02034e0:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02034e2:	cadfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02034e6:	016a8023          	sb	s6,0(s5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02034ea:	00042903          	lw	s2,0(s0)
ffffffffc02034ee:	2901                	sext.w	s2,s2
ffffffffc02034f0:	2a991a63          	bne	s2,s1,ffffffffc02037a4 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02034f4:	00003517          	auipc	a0,0x3
ffffffffc02034f8:	23c50513          	addi	a0,a0,572 # ffffffffc0206730 <default_pmm_manager+0xab8>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02034fc:	6b91                	lui	s7,0x4
ffffffffc02034fe:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203500:	c8ffc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203504:	018b8023          	sb	s8,0(s7) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0203508:	4004                	lw	s1,0(s0)
ffffffffc020350a:	2481                	sext.w	s1,s1
ffffffffc020350c:	27249c63          	bne	s1,s2,ffffffffc0203784 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203510:	00003517          	auipc	a0,0x3
ffffffffc0203514:	24850513          	addi	a0,a0,584 # ffffffffc0206758 <default_pmm_manager+0xae0>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203518:	6909                	lui	s2,0x2
ffffffffc020351a:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020351c:	c73fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203520:	01990023          	sb	s9,0(s2) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0203524:	401c                	lw	a5,0(s0)
ffffffffc0203526:	2781                	sext.w	a5,a5
ffffffffc0203528:	22979e63          	bne	a5,s1,ffffffffc0203764 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc020352c:	00003517          	auipc	a0,0x3
ffffffffc0203530:	25450513          	addi	a0,a0,596 # ffffffffc0206780 <default_pmm_manager+0xb08>
ffffffffc0203534:	c5bfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203538:	6795                	lui	a5,0x5
ffffffffc020353a:	4739                	li	a4,14
ffffffffc020353c:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203540:	4004                	lw	s1,0(s0)
ffffffffc0203542:	4795                	li	a5,5
ffffffffc0203544:	2481                	sext.w	s1,s1
ffffffffc0203546:	1ef49f63          	bne	s1,a5,ffffffffc0203744 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020354a:	00003517          	auipc	a0,0x3
ffffffffc020354e:	20e50513          	addi	a0,a0,526 # ffffffffc0206758 <default_pmm_manager+0xae0>
ffffffffc0203552:	c3dfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203556:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc020355a:	401c                	lw	a5,0(s0)
ffffffffc020355c:	2781                	sext.w	a5,a5
ffffffffc020355e:	1c979363          	bne	a5,s1,ffffffffc0203724 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203562:	00003517          	auipc	a0,0x3
ffffffffc0203566:	1a650513          	addi	a0,a0,422 # ffffffffc0206708 <default_pmm_manager+0xa90>
ffffffffc020356a:	c25fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020356e:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203572:	401c                	lw	a5,0(s0)
ffffffffc0203574:	4719                	li	a4,6
ffffffffc0203576:	2781                	sext.w	a5,a5
ffffffffc0203578:	18e79663          	bne	a5,a4,ffffffffc0203704 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020357c:	00003517          	auipc	a0,0x3
ffffffffc0203580:	1dc50513          	addi	a0,a0,476 # ffffffffc0206758 <default_pmm_manager+0xae0>
ffffffffc0203584:	c0bfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203588:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc020358c:	401c                	lw	a5,0(s0)
ffffffffc020358e:	471d                	li	a4,7
ffffffffc0203590:	2781                	sext.w	a5,a5
ffffffffc0203592:	14e79963          	bne	a5,a4,ffffffffc02036e4 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203596:	00003517          	auipc	a0,0x3
ffffffffc020359a:	13250513          	addi	a0,a0,306 # ffffffffc02066c8 <default_pmm_manager+0xa50>
ffffffffc020359e:	bf1fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02035a2:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc02035a6:	401c                	lw	a5,0(s0)
ffffffffc02035a8:	4721                	li	a4,8
ffffffffc02035aa:	2781                	sext.w	a5,a5
ffffffffc02035ac:	10e79c63          	bne	a5,a4,ffffffffc02036c4 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02035b0:	00003517          	auipc	a0,0x3
ffffffffc02035b4:	18050513          	addi	a0,a0,384 # ffffffffc0206730 <default_pmm_manager+0xab8>
ffffffffc02035b8:	bd7fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02035bc:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02035c0:	401c                	lw	a5,0(s0)
ffffffffc02035c2:	4725                	li	a4,9
ffffffffc02035c4:	2781                	sext.w	a5,a5
ffffffffc02035c6:	0ce79f63          	bne	a5,a4,ffffffffc02036a4 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02035ca:	00003517          	auipc	a0,0x3
ffffffffc02035ce:	1b650513          	addi	a0,a0,438 # ffffffffc0206780 <default_pmm_manager+0xb08>
ffffffffc02035d2:	bbdfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02035d6:	6795                	lui	a5,0x5
ffffffffc02035d8:	4739                	li	a4,14
ffffffffc02035da:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc02035de:	4004                	lw	s1,0(s0)
ffffffffc02035e0:	47a9                	li	a5,10
ffffffffc02035e2:	2481                	sext.w	s1,s1
ffffffffc02035e4:	0af49063          	bne	s1,a5,ffffffffc0203684 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02035e8:	00003517          	auipc	a0,0x3
ffffffffc02035ec:	12050513          	addi	a0,a0,288 # ffffffffc0206708 <default_pmm_manager+0xa90>
ffffffffc02035f0:	b9ffc0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02035f4:	6785                	lui	a5,0x1
ffffffffc02035f6:	0007c783          	lbu	a5,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc02035fa:	06979563          	bne	a5,s1,ffffffffc0203664 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc02035fe:	401c                	lw	a5,0(s0)
ffffffffc0203600:	472d                	li	a4,11
ffffffffc0203602:	2781                	sext.w	a5,a5
ffffffffc0203604:	04e79063          	bne	a5,a4,ffffffffc0203644 <_fifo_check_swap+0x1ac>
}
ffffffffc0203608:	60e6                	ld	ra,88(sp)
ffffffffc020360a:	6446                	ld	s0,80(sp)
ffffffffc020360c:	64a6                	ld	s1,72(sp)
ffffffffc020360e:	6906                	ld	s2,64(sp)
ffffffffc0203610:	79e2                	ld	s3,56(sp)
ffffffffc0203612:	7a42                	ld	s4,48(sp)
ffffffffc0203614:	7aa2                	ld	s5,40(sp)
ffffffffc0203616:	7b02                	ld	s6,32(sp)
ffffffffc0203618:	6be2                	ld	s7,24(sp)
ffffffffc020361a:	6c42                	ld	s8,16(sp)
ffffffffc020361c:	6ca2                	ld	s9,8(sp)
ffffffffc020361e:	4501                	li	a0,0
ffffffffc0203620:	6125                	addi	sp,sp,96
ffffffffc0203622:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203624:	00003697          	auipc	a3,0x3
ffffffffc0203628:	f4468693          	addi	a3,a3,-188 # ffffffffc0206568 <default_pmm_manager+0x8f0>
ffffffffc020362c:	00002617          	auipc	a2,0x2
ffffffffc0203630:	2b460613          	addi	a2,a2,692 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203634:	05b00593          	li	a1,91
ffffffffc0203638:	00003517          	auipc	a0,0x3
ffffffffc020363c:	0b850513          	addi	a0,a0,184 # ffffffffc02066f0 <default_pmm_manager+0xa78>
ffffffffc0203640:	e11fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==11);
ffffffffc0203644:	00003697          	auipc	a3,0x3
ffffffffc0203648:	1ec68693          	addi	a3,a3,492 # ffffffffc0206830 <default_pmm_manager+0xbb8>
ffffffffc020364c:	00002617          	auipc	a2,0x2
ffffffffc0203650:	29460613          	addi	a2,a2,660 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203654:	07d00593          	li	a1,125
ffffffffc0203658:	00003517          	auipc	a0,0x3
ffffffffc020365c:	09850513          	addi	a0,a0,152 # ffffffffc02066f0 <default_pmm_manager+0xa78>
ffffffffc0203660:	df1fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203664:	00003697          	auipc	a3,0x3
ffffffffc0203668:	1a468693          	addi	a3,a3,420 # ffffffffc0206808 <default_pmm_manager+0xb90>
ffffffffc020366c:	00002617          	auipc	a2,0x2
ffffffffc0203670:	27460613          	addi	a2,a2,628 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203674:	07b00593          	li	a1,123
ffffffffc0203678:	00003517          	auipc	a0,0x3
ffffffffc020367c:	07850513          	addi	a0,a0,120 # ffffffffc02066f0 <default_pmm_manager+0xa78>
ffffffffc0203680:	dd1fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==10);
ffffffffc0203684:	00003697          	auipc	a3,0x3
ffffffffc0203688:	17468693          	addi	a3,a3,372 # ffffffffc02067f8 <default_pmm_manager+0xb80>
ffffffffc020368c:	00002617          	auipc	a2,0x2
ffffffffc0203690:	25460613          	addi	a2,a2,596 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203694:	07900593          	li	a1,121
ffffffffc0203698:	00003517          	auipc	a0,0x3
ffffffffc020369c:	05850513          	addi	a0,a0,88 # ffffffffc02066f0 <default_pmm_manager+0xa78>
ffffffffc02036a0:	db1fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==9);
ffffffffc02036a4:	00003697          	auipc	a3,0x3
ffffffffc02036a8:	14468693          	addi	a3,a3,324 # ffffffffc02067e8 <default_pmm_manager+0xb70>
ffffffffc02036ac:	00002617          	auipc	a2,0x2
ffffffffc02036b0:	23460613          	addi	a2,a2,564 # ffffffffc02058e0 <commands+0x870>
ffffffffc02036b4:	07600593          	li	a1,118
ffffffffc02036b8:	00003517          	auipc	a0,0x3
ffffffffc02036bc:	03850513          	addi	a0,a0,56 # ffffffffc02066f0 <default_pmm_manager+0xa78>
ffffffffc02036c0:	d91fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==8);
ffffffffc02036c4:	00003697          	auipc	a3,0x3
ffffffffc02036c8:	11468693          	addi	a3,a3,276 # ffffffffc02067d8 <default_pmm_manager+0xb60>
ffffffffc02036cc:	00002617          	auipc	a2,0x2
ffffffffc02036d0:	21460613          	addi	a2,a2,532 # ffffffffc02058e0 <commands+0x870>
ffffffffc02036d4:	07300593          	li	a1,115
ffffffffc02036d8:	00003517          	auipc	a0,0x3
ffffffffc02036dc:	01850513          	addi	a0,a0,24 # ffffffffc02066f0 <default_pmm_manager+0xa78>
ffffffffc02036e0:	d71fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==7);
ffffffffc02036e4:	00003697          	auipc	a3,0x3
ffffffffc02036e8:	0e468693          	addi	a3,a3,228 # ffffffffc02067c8 <default_pmm_manager+0xb50>
ffffffffc02036ec:	00002617          	auipc	a2,0x2
ffffffffc02036f0:	1f460613          	addi	a2,a2,500 # ffffffffc02058e0 <commands+0x870>
ffffffffc02036f4:	07000593          	li	a1,112
ffffffffc02036f8:	00003517          	auipc	a0,0x3
ffffffffc02036fc:	ff850513          	addi	a0,a0,-8 # ffffffffc02066f0 <default_pmm_manager+0xa78>
ffffffffc0203700:	d51fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==6);
ffffffffc0203704:	00003697          	auipc	a3,0x3
ffffffffc0203708:	0b468693          	addi	a3,a3,180 # ffffffffc02067b8 <default_pmm_manager+0xb40>
ffffffffc020370c:	00002617          	auipc	a2,0x2
ffffffffc0203710:	1d460613          	addi	a2,a2,468 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203714:	06d00593          	li	a1,109
ffffffffc0203718:	00003517          	auipc	a0,0x3
ffffffffc020371c:	fd850513          	addi	a0,a0,-40 # ffffffffc02066f0 <default_pmm_manager+0xa78>
ffffffffc0203720:	d31fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==5);
ffffffffc0203724:	00003697          	auipc	a3,0x3
ffffffffc0203728:	08468693          	addi	a3,a3,132 # ffffffffc02067a8 <default_pmm_manager+0xb30>
ffffffffc020372c:	00002617          	auipc	a2,0x2
ffffffffc0203730:	1b460613          	addi	a2,a2,436 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203734:	06a00593          	li	a1,106
ffffffffc0203738:	00003517          	auipc	a0,0x3
ffffffffc020373c:	fb850513          	addi	a0,a0,-72 # ffffffffc02066f0 <default_pmm_manager+0xa78>
ffffffffc0203740:	d11fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==5);
ffffffffc0203744:	00003697          	auipc	a3,0x3
ffffffffc0203748:	06468693          	addi	a3,a3,100 # ffffffffc02067a8 <default_pmm_manager+0xb30>
ffffffffc020374c:	00002617          	auipc	a2,0x2
ffffffffc0203750:	19460613          	addi	a2,a2,404 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203754:	06700593          	li	a1,103
ffffffffc0203758:	00003517          	auipc	a0,0x3
ffffffffc020375c:	f9850513          	addi	a0,a0,-104 # ffffffffc02066f0 <default_pmm_manager+0xa78>
ffffffffc0203760:	cf1fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==4);
ffffffffc0203764:	00003697          	auipc	a3,0x3
ffffffffc0203768:	e0468693          	addi	a3,a3,-508 # ffffffffc0206568 <default_pmm_manager+0x8f0>
ffffffffc020376c:	00002617          	auipc	a2,0x2
ffffffffc0203770:	17460613          	addi	a2,a2,372 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203774:	06400593          	li	a1,100
ffffffffc0203778:	00003517          	auipc	a0,0x3
ffffffffc020377c:	f7850513          	addi	a0,a0,-136 # ffffffffc02066f0 <default_pmm_manager+0xa78>
ffffffffc0203780:	cd1fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==4);
ffffffffc0203784:	00003697          	auipc	a3,0x3
ffffffffc0203788:	de468693          	addi	a3,a3,-540 # ffffffffc0206568 <default_pmm_manager+0x8f0>
ffffffffc020378c:	00002617          	auipc	a2,0x2
ffffffffc0203790:	15460613          	addi	a2,a2,340 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203794:	06100593          	li	a1,97
ffffffffc0203798:	00003517          	auipc	a0,0x3
ffffffffc020379c:	f5850513          	addi	a0,a0,-168 # ffffffffc02066f0 <default_pmm_manager+0xa78>
ffffffffc02037a0:	cb1fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==4);
ffffffffc02037a4:	00003697          	auipc	a3,0x3
ffffffffc02037a8:	dc468693          	addi	a3,a3,-572 # ffffffffc0206568 <default_pmm_manager+0x8f0>
ffffffffc02037ac:	00002617          	auipc	a2,0x2
ffffffffc02037b0:	13460613          	addi	a2,a2,308 # ffffffffc02058e0 <commands+0x870>
ffffffffc02037b4:	05e00593          	li	a1,94
ffffffffc02037b8:	00003517          	auipc	a0,0x3
ffffffffc02037bc:	f3850513          	addi	a0,a0,-200 # ffffffffc02066f0 <default_pmm_manager+0xa78>
ffffffffc02037c0:	c91fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02037c4 <_fifo_swap_out_victim>:
    list_entry_t *head = (list_entry_t *)mm->sm_priv; //这一行获取队列中最早到达的页面。
ffffffffc02037c4:	751c                	ld	a5,40(a0)
{
ffffffffc02037c6:	1141                	addi	sp,sp,-16
ffffffffc02037c8:	e406                	sd	ra,8(sp)
    assert(head != NULL);
ffffffffc02037ca:	cf91                	beqz	a5,ffffffffc02037e6 <_fifo_swap_out_victim+0x22>
    assert(in_tick==0);
ffffffffc02037cc:	ee0d                	bnez	a2,ffffffffc0203806 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc02037ce:	679c                	ld	a5,8(a5)
}
ffffffffc02037d0:	60a2                	ld	ra,8(sp)
ffffffffc02037d2:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc02037d4:	6394                	ld	a3,0(a5)
ffffffffc02037d6:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc02037d8:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc02037dc:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02037de:	e314                	sd	a3,0(a4)
ffffffffc02037e0:	e19c                	sd	a5,0(a1)
}
ffffffffc02037e2:	0141                	addi	sp,sp,16
ffffffffc02037e4:	8082                	ret
    assert(head != NULL);
ffffffffc02037e6:	00003697          	auipc	a3,0x3
ffffffffc02037ea:	07a68693          	addi	a3,a3,122 # ffffffffc0206860 <default_pmm_manager+0xbe8>
ffffffffc02037ee:	00002617          	auipc	a2,0x2
ffffffffc02037f2:	0f260613          	addi	a2,a2,242 # ffffffffc02058e0 <commands+0x870>
ffffffffc02037f6:	04b00593          	li	a1,75
ffffffffc02037fa:	00003517          	auipc	a0,0x3
ffffffffc02037fe:	ef650513          	addi	a0,a0,-266 # ffffffffc02066f0 <default_pmm_manager+0xa78>
ffffffffc0203802:	c4ffc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(in_tick==0);
ffffffffc0203806:	00003697          	auipc	a3,0x3
ffffffffc020380a:	06a68693          	addi	a3,a3,106 # ffffffffc0206870 <default_pmm_manager+0xbf8>
ffffffffc020380e:	00002617          	auipc	a2,0x2
ffffffffc0203812:	0d260613          	addi	a2,a2,210 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203816:	04c00593          	li	a1,76
ffffffffc020381a:	00003517          	auipc	a0,0x3
ffffffffc020381e:	ed650513          	addi	a0,a0,-298 # ffffffffc02066f0 <default_pmm_manager+0xa78>
ffffffffc0203822:	c2ffc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203826 <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203826:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020382a:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020382c:	cb09                	beqz	a4,ffffffffc020383e <_fifo_map_swappable+0x18>
ffffffffc020382e:	cb81                	beqz	a5,ffffffffc020383e <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203830:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203832:	e398                	sd	a4,0(a5)
}
ffffffffc0203834:	4501                	li	a0,0
ffffffffc0203836:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0203838:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020383a:	f614                	sd	a3,40(a2)
ffffffffc020383c:	8082                	ret
{
ffffffffc020383e:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203840:	00003697          	auipc	a3,0x3
ffffffffc0203844:	00068693          	mv	a3,a3
ffffffffc0203848:	00002617          	auipc	a2,0x2
ffffffffc020384c:	09860613          	addi	a2,a2,152 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203850:	03900593          	li	a1,57
ffffffffc0203854:	00003517          	auipc	a0,0x3
ffffffffc0203858:	e9c50513          	addi	a0,a0,-356 # ffffffffc02066f0 <default_pmm_manager+0xa78>
{
ffffffffc020385c:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc020385e:	bf3fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203862 <check_vma_overlap.isra.0.part.1>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
//在插入一个新的vma_struct之前，我们要保证它和原有的区间都不重合
static inline void // 检测两个vma是否重叠
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203862:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203864:	00003697          	auipc	a3,0x3
ffffffffc0203868:	03468693          	addi	a3,a3,52 # ffffffffc0206898 <default_pmm_manager+0xc20>
ffffffffc020386c:	00002617          	auipc	a2,0x2
ffffffffc0203870:	07460613          	addi	a2,a2,116 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203874:	09600593          	li	a1,150
ffffffffc0203878:	00003517          	auipc	a0,0x3
ffffffffc020387c:	04050513          	addi	a0,a0,64 # ffffffffc02068b8 <default_pmm_manager+0xc40>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203880:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203882:	bcffc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203886 <mm_create>:
mm_create(void) {
ffffffffc0203886:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203888:	03000513          	li	a0,48
mm_create(void) {
ffffffffc020388c:	e022                	sd	s0,0(sp)
ffffffffc020388e:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203890:	936fe0ef          	jal	ra,ffffffffc02019c6 <kmalloc>
ffffffffc0203894:	842a                	mv	s0,a0
    if (mm != NULL)
ffffffffc0203896:	c115                	beqz	a0,ffffffffc02038ba <mm_create+0x34>
        if (swap_init_ok) //我们接下来解释页面置换的初始化
ffffffffc0203898:	00013797          	auipc	a5,0x13
ffffffffc020389c:	c1078793          	addi	a5,a5,-1008 # ffffffffc02164a8 <swap_init_ok>
ffffffffc02038a0:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc02038a2:	e408                	sd	a0,8(s0)
ffffffffc02038a4:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL; // 当前没有正在使用的虚拟内存空间；
ffffffffc02038a6:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;      // 表示当前没有使用的页目录表；
ffffffffc02038aa:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;     // 表示当前没有虚拟内存空间；
ffffffffc02038ae:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) //我们接下来解释页面置换的初始化
ffffffffc02038b2:	2781                	sext.w	a5,a5
ffffffffc02038b4:	eb81                	bnez	a5,ffffffffc02038c4 <mm_create+0x3e>
            mm->sm_priv = NULL; // sm_priv 设置为 NULL。sm_priv 通常用于存储与特定交换空间实现相关的私有数据。
ffffffffc02038b6:	02053423          	sd	zero,40(a0)
}
ffffffffc02038ba:	8522                	mv	a0,s0
ffffffffc02038bc:	60a2                	ld	ra,8(sp)
ffffffffc02038be:	6402                	ld	s0,0(sp)
ffffffffc02038c0:	0141                	addi	sp,sp,16
ffffffffc02038c2:	8082                	ret
            swap_init_mm(mm); //初始化与交换空间（swap space）相关的数据结构
ffffffffc02038c4:	a09ff0ef          	jal	ra,ffffffffc02032cc <swap_init_mm>
}
ffffffffc02038c8:	8522                	mv	a0,s0
ffffffffc02038ca:	60a2                	ld	ra,8(sp)
ffffffffc02038cc:	6402                	ld	s0,0(sp)
ffffffffc02038ce:	0141                	addi	sp,sp,16
ffffffffc02038d0:	8082                	ret

ffffffffc02038d2 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02038d2:	1101                	addi	sp,sp,-32
ffffffffc02038d4:	e04a                	sd	s2,0(sp)
ffffffffc02038d6:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038d8:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02038dc:	e822                	sd	s0,16(sp)
ffffffffc02038de:	e426                	sd	s1,8(sp)
ffffffffc02038e0:	ec06                	sd	ra,24(sp)
ffffffffc02038e2:	84ae                	mv	s1,a1
ffffffffc02038e4:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038e6:	8e0fe0ef          	jal	ra,ffffffffc02019c6 <kmalloc>
    if (vma != NULL) {
ffffffffc02038ea:	c509                	beqz	a0,ffffffffc02038f4 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02038ec:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02038f0:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02038f2:	cd00                	sw	s0,24(a0)
}
ffffffffc02038f4:	60e2                	ld	ra,24(sp)
ffffffffc02038f6:	6442                	ld	s0,16(sp)
ffffffffc02038f8:	64a2                	ld	s1,8(sp)
ffffffffc02038fa:	6902                	ld	s2,0(sp)
ffffffffc02038fc:	6105                	addi	sp,sp,32
ffffffffc02038fe:	8082                	ret

ffffffffc0203900 <find_vma>:
    if (mm != NULL)
ffffffffc0203900:	c51d                	beqz	a0,ffffffffc020392e <find_vma+0x2e>
        vma = mm->mmap_cache; // 先查cache，当前正在使用的虚拟内存空间
ffffffffc0203902:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203904:	c781                	beqz	a5,ffffffffc020390c <find_vma+0xc>
ffffffffc0203906:	6798                	ld	a4,8(a5)
ffffffffc0203908:	02e5f663          	bleu	a4,a1,ffffffffc0203934 <find_vma+0x34>
            list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc020390c:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc020390e:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0203910:	00f50f63          	beq	a0,a5,ffffffffc020392e <find_vma+0x2e>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0203914:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203918:	fee5ebe3          	bltu	a1,a4,ffffffffc020390e <find_vma+0xe>
ffffffffc020391c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203920:	fee5f7e3          	bleu	a4,a1,ffffffffc020390e <find_vma+0xe>
                vma = le2vma(le, list_link);
ffffffffc0203924:	1781                	addi	a5,a5,-32
        if (vma != NULL)
ffffffffc0203926:	c781                	beqz	a5,ffffffffc020392e <find_vma+0x2e>
            mm->mmap_cache = vma; // 更新cache
ffffffffc0203928:	e91c                	sd	a5,16(a0)
}
ffffffffc020392a:	853e                	mv	a0,a5
ffffffffc020392c:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc020392e:	4781                	li	a5,0
}
ffffffffc0203930:	853e                	mv	a0,a5
ffffffffc0203932:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203934:	6b98                	ld	a4,16(a5)
ffffffffc0203936:	fce5fbe3          	bleu	a4,a1,ffffffffc020390c <find_vma+0xc>
            mm->mmap_cache = vma; // 更新cache
ffffffffc020393a:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc020393c:	b7fd                	j	ffffffffc020392a <find_vma+0x2a>

ffffffffc020393e <insert_vma_struct>:
// insert_vma_struct -insert vma in mm's list link
// 向mm的mmap_list的插入一个vma，按地址插入合适位置
// 我们可以插入一个新的vma_struct, 将一个 vma_struct 结构体插入到 mm_struct 结构体中。
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end); //函数首先检查 vma 是否为空，如果为空则直接返回。
ffffffffc020393e:	6590                	ld	a2,8(a1)
ffffffffc0203940:	0105b803          	ld	a6,16(a1) # 1010 <BASE_ADDRESS-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203944:	1141                	addi	sp,sp,-16
ffffffffc0203946:	e406                	sd	ra,8(sp)
ffffffffc0203948:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end); //函数首先检查 vma 是否为空，如果为空则直接返回。
ffffffffc020394a:	01066863          	bltu	a2,a6,ffffffffc020395a <insert_vma_struct+0x1c>
ffffffffc020394e:	a8b9                	j	ffffffffc02039ac <insert_vma_struct+0x6e>
    list_entry_t *le = list; // le用来遍历整个链表
    //使用 list_entry 宏遍历 mm 中的所有 vma，并找到第一个比 vma 的 vm_start 大的 vma。
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start) // 找到第一个比vma的vm_start大的vma
ffffffffc0203950:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203954:	04d66763          	bltu	a2,a3,ffffffffc02039a2 <insert_vma_struct+0x64>
ffffffffc0203958:	873e                	mv	a4,a5
ffffffffc020395a:	671c                	ld	a5,8(a4)
    while ((le = list_next(le)) != list)
ffffffffc020395c:	fef51ae3          	bne	a0,a5,ffffffffc0203950 <insert_vma_struct+0x12>

    le_next = list_next(le_prev);

    /* check overlap */
    //检查新插入的 vma_struct 结构体与相邻的 vma_struct 结构体是否重叠。
    if (le_prev != list)
ffffffffc0203960:	02a70463          	beq	a4,a0,ffffffffc0203988 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma); // 检查vma与前一个vma是否重叠
ffffffffc0203964:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203968:	fe873883          	ld	a7,-24(a4)
ffffffffc020396c:	08d8f063          	bleu	a3,a7,ffffffffc02039ec <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203970:	04d66e63          	bltu	a2,a3,ffffffffc02039cc <insert_vma_struct+0x8e>
    }
    if (le_next != list)
ffffffffc0203974:	00f50a63          	beq	a0,a5,ffffffffc0203988 <insert_vma_struct+0x4a>
ffffffffc0203978:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc020397c:	0506e863          	bltu	a3,a6,ffffffffc02039cc <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0203980:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203984:	02c6f263          	bleu	a2,a3,ffffffffc02039a8 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc0203988:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc020398a:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc020398c:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203990:	e390                	sd	a2,0(a5)
ffffffffc0203992:	e710                	sd	a2,8(a4)
    /**
     * 该函数假设 mm 中的 vma 已经按照起始地址排序，因此可以使用线性查找算法。
     * 该函数在实现虚拟内存管理时非常有用，可以方便地将 vma_struct 结构体插入到对应的 mm_struct 结构体中，从而管理进程的虚拟地址空间。
    */
}
ffffffffc0203994:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203996:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203998:	f198                	sd	a4,32(a1)
    mm->map_count++;
ffffffffc020399a:	2685                	addiw	a3,a3,1
ffffffffc020399c:	d114                	sw	a3,32(a0)
}
ffffffffc020399e:	0141                	addi	sp,sp,16
ffffffffc02039a0:	8082                	ret
    if (le_prev != list)
ffffffffc02039a2:	fca711e3          	bne	a4,a0,ffffffffc0203964 <insert_vma_struct+0x26>
ffffffffc02039a6:	bfd9                	j	ffffffffc020397c <insert_vma_struct+0x3e>
ffffffffc02039a8:	ebbff0ef          	jal	ra,ffffffffc0203862 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end); //函数首先检查 vma 是否为空，如果为空则直接返回。
ffffffffc02039ac:	00003697          	auipc	a3,0x3
ffffffffc02039b0:	00468693          	addi	a3,a3,4 # ffffffffc02069b0 <default_pmm_manager+0xd38>
ffffffffc02039b4:	00002617          	auipc	a2,0x2
ffffffffc02039b8:	f2c60613          	addi	a2,a2,-212 # ffffffffc02058e0 <commands+0x870>
ffffffffc02039bc:	09f00593          	li	a1,159
ffffffffc02039c0:	00003517          	auipc	a0,0x3
ffffffffc02039c4:	ef850513          	addi	a0,a0,-264 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc02039c8:	a89fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02039cc:	00003697          	auipc	a3,0x3
ffffffffc02039d0:	02468693          	addi	a3,a3,36 # ffffffffc02069f0 <default_pmm_manager+0xd78>
ffffffffc02039d4:	00002617          	auipc	a2,0x2
ffffffffc02039d8:	f0c60613          	addi	a2,a2,-244 # ffffffffc02058e0 <commands+0x870>
ffffffffc02039dc:	09500593          	li	a1,149
ffffffffc02039e0:	00003517          	auipc	a0,0x3
ffffffffc02039e4:	ed850513          	addi	a0,a0,-296 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc02039e8:	a69fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02039ec:	00003697          	auipc	a3,0x3
ffffffffc02039f0:	fe468693          	addi	a3,a3,-28 # ffffffffc02069d0 <default_pmm_manager+0xd58>
ffffffffc02039f4:	00002617          	auipc	a2,0x2
ffffffffc02039f8:	eec60613          	addi	a2,a2,-276 # ffffffffc02058e0 <commands+0x870>
ffffffffc02039fc:	09400593          	li	a1,148
ffffffffc0203a00:	00003517          	auipc	a0,0x3
ffffffffc0203a04:	eb850513          	addi	a0,a0,-328 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203a08:	a49fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203a0c <mm_destroy>:

// mm_destroy - free mm and mm internal fields
// 删除一个mm struct，kfree掉占用的空间
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0203a0c:	1141                	addi	sp,sp,-16
ffffffffc0203a0e:	e022                	sd	s0,0(sp)
ffffffffc0203a10:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203a12:	6508                	ld	a0,8(a0)
ffffffffc0203a14:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203a16:	00a40c63          	beq	s0,a0,ffffffffc0203a2e <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203a1a:	6118                	ld	a4,0(a0)
ffffffffc0203a1c:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203a1e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203a20:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203a22:	e398                	sd	a4,0(a5)
ffffffffc0203a24:	85efe0ef          	jal	ra,ffffffffc0201a82 <kfree>
    return listelm->next;
ffffffffc0203a28:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203a2a:	fea418e3          	bne	s0,a0,ffffffffc0203a1a <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0203a2e:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203a30:	6402                	ld	s0,0(sp)
ffffffffc0203a32:	60a2                	ld	ra,8(sp)
ffffffffc0203a34:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0203a36:	84cfe06f          	j	ffffffffc0201a82 <kfree>

ffffffffc0203a3a <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0203a3a:	7139                	addi	sp,sp,-64
ffffffffc0203a3c:	f822                	sd	s0,48(sp)
ffffffffc0203a3e:	f426                	sd	s1,40(sp)
ffffffffc0203a40:	fc06                	sd	ra,56(sp)
ffffffffc0203a42:	f04a                	sd	s2,32(sp)
ffffffffc0203a44:	ec4e                	sd	s3,24(sp)
ffffffffc0203a46:	e852                	sd	s4,16(sp)
ffffffffc0203a48:	e456                	sd	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    struct mm_struct *mm = mm_create();
ffffffffc0203a4a:	e3dff0ef          	jal	ra,ffffffffc0203886 <mm_create>
    assert(mm != NULL);
ffffffffc0203a4e:	842a                	mv	s0,a0
ffffffffc0203a50:	03200493          	li	s1,50
ffffffffc0203a54:	e919                	bnez	a0,ffffffffc0203a6a <vmm_init+0x30>
ffffffffc0203a56:	a989                	j	ffffffffc0203ea8 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0203a58:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203a5a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203a5c:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203a60:	14ed                	addi	s1,s1,-5
ffffffffc0203a62:	8522                	mv	a0,s0
ffffffffc0203a64:	edbff0ef          	jal	ra,ffffffffc020393e <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0203a68:	c88d                	beqz	s1,ffffffffc0203a9a <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a6a:	03000513          	li	a0,48
ffffffffc0203a6e:	f59fd0ef          	jal	ra,ffffffffc02019c6 <kmalloc>
ffffffffc0203a72:	85aa                	mv	a1,a0
ffffffffc0203a74:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203a78:	f165                	bnez	a0,ffffffffc0203a58 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0203a7a:	00003697          	auipc	a3,0x3
ffffffffc0203a7e:	9ae68693          	addi	a3,a3,-1618 # ffffffffc0206428 <default_pmm_manager+0x7b0>
ffffffffc0203a82:	00002617          	auipc	a2,0x2
ffffffffc0203a86:	e5e60613          	addi	a2,a2,-418 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203a8a:	0ef00593          	li	a1,239
ffffffffc0203a8e:	00003517          	auipc	a0,0x3
ffffffffc0203a92:	e2a50513          	addi	a0,a0,-470 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203a96:	9bbfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0203a9a:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203a9e:	1f900913          	li	s2,505
ffffffffc0203aa2:	a819                	j	ffffffffc0203ab8 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0203aa4:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203aa6:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203aa8:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203aac:	0495                	addi	s1,s1,5
ffffffffc0203aae:	8522                	mv	a0,s0
ffffffffc0203ab0:	e8fff0ef          	jal	ra,ffffffffc020393e <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203ab4:	03248a63          	beq	s1,s2,ffffffffc0203ae8 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203ab8:	03000513          	li	a0,48
ffffffffc0203abc:	f0bfd0ef          	jal	ra,ffffffffc02019c6 <kmalloc>
ffffffffc0203ac0:	85aa                	mv	a1,a0
ffffffffc0203ac2:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203ac6:	fd79                	bnez	a0,ffffffffc0203aa4 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0203ac8:	00003697          	auipc	a3,0x3
ffffffffc0203acc:	96068693          	addi	a3,a3,-1696 # ffffffffc0206428 <default_pmm_manager+0x7b0>
ffffffffc0203ad0:	00002617          	auipc	a2,0x2
ffffffffc0203ad4:	e1060613          	addi	a2,a2,-496 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203ad8:	0f500593          	li	a1,245
ffffffffc0203adc:	00003517          	auipc	a0,0x3
ffffffffc0203ae0:	ddc50513          	addi	a0,a0,-548 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203ae4:	96dfc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0203ae8:	6418                	ld	a4,8(s0)
ffffffffc0203aea:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203aec:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203af0:	2ee40063          	beq	s0,a4,ffffffffc0203dd0 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203af4:	fe873603          	ld	a2,-24(a4)
ffffffffc0203af8:	ffe78693          	addi	a3,a5,-2
ffffffffc0203afc:	24d61a63          	bne	a2,a3,ffffffffc0203d50 <vmm_init+0x316>
ffffffffc0203b00:	ff073683          	ld	a3,-16(a4)
ffffffffc0203b04:	24f69663          	bne	a3,a5,ffffffffc0203d50 <vmm_init+0x316>
ffffffffc0203b08:	0795                	addi	a5,a5,5
ffffffffc0203b0a:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0203b0c:	feb792e3          	bne	a5,a1,ffffffffc0203af0 <vmm_init+0xb6>
ffffffffc0203b10:	491d                	li	s2,7
ffffffffc0203b12:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203b14:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203b18:	85a6                	mv	a1,s1
ffffffffc0203b1a:	8522                	mv	a0,s0
ffffffffc0203b1c:	de5ff0ef          	jal	ra,ffffffffc0203900 <find_vma>
ffffffffc0203b20:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0203b22:	30050763          	beqz	a0,ffffffffc0203e30 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203b26:	00148593          	addi	a1,s1,1
ffffffffc0203b2a:	8522                	mv	a0,s0
ffffffffc0203b2c:	dd5ff0ef          	jal	ra,ffffffffc0203900 <find_vma>
ffffffffc0203b30:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203b32:	2c050f63          	beqz	a0,ffffffffc0203e10 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203b36:	85ca                	mv	a1,s2
ffffffffc0203b38:	8522                	mv	a0,s0
ffffffffc0203b3a:	dc7ff0ef          	jal	ra,ffffffffc0203900 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203b3e:	2a051963          	bnez	a0,ffffffffc0203df0 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203b42:	00348593          	addi	a1,s1,3
ffffffffc0203b46:	8522                	mv	a0,s0
ffffffffc0203b48:	db9ff0ef          	jal	ra,ffffffffc0203900 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203b4c:	32051263          	bnez	a0,ffffffffc0203e70 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203b50:	00448593          	addi	a1,s1,4
ffffffffc0203b54:	8522                	mv	a0,s0
ffffffffc0203b56:	dabff0ef          	jal	ra,ffffffffc0203900 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203b5a:	2e051b63          	bnez	a0,ffffffffc0203e50 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203b5e:	008a3783          	ld	a5,8(s4)
ffffffffc0203b62:	20979763          	bne	a5,s1,ffffffffc0203d70 <vmm_init+0x336>
ffffffffc0203b66:	010a3783          	ld	a5,16(s4)
ffffffffc0203b6a:	21279363          	bne	a5,s2,ffffffffc0203d70 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203b6e:	0089b783          	ld	a5,8(s3)
ffffffffc0203b72:	20979f63          	bne	a5,s1,ffffffffc0203d90 <vmm_init+0x356>
ffffffffc0203b76:	0109b783          	ld	a5,16(s3)
ffffffffc0203b7a:	21279b63          	bne	a5,s2,ffffffffc0203d90 <vmm_init+0x356>
ffffffffc0203b7e:	0495                	addi	s1,s1,5
ffffffffc0203b80:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203b82:	f9549be3          	bne	s1,s5,ffffffffc0203b18 <vmm_init+0xde>
ffffffffc0203b86:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203b88:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203b8a:	85a6                	mv	a1,s1
ffffffffc0203b8c:	8522                	mv	a0,s0
ffffffffc0203b8e:	d73ff0ef          	jal	ra,ffffffffc0203900 <find_vma>
ffffffffc0203b92:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0203b96:	c90d                	beqz	a0,ffffffffc0203bc8 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203b98:	6914                	ld	a3,16(a0)
ffffffffc0203b9a:	6510                	ld	a2,8(a0)
ffffffffc0203b9c:	00003517          	auipc	a0,0x3
ffffffffc0203ba0:	f7450513          	addi	a0,a0,-140 # ffffffffc0206b10 <default_pmm_manager+0xe98>
ffffffffc0203ba4:	deafc0ef          	jal	ra,ffffffffc020018e <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203ba8:	00003697          	auipc	a3,0x3
ffffffffc0203bac:	f9068693          	addi	a3,a3,-112 # ffffffffc0206b38 <default_pmm_manager+0xec0>
ffffffffc0203bb0:	00002617          	auipc	a2,0x2
ffffffffc0203bb4:	d3060613          	addi	a2,a2,-720 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203bb8:	11700593          	li	a1,279
ffffffffc0203bbc:	00003517          	auipc	a0,0x3
ffffffffc0203bc0:	cfc50513          	addi	a0,a0,-772 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203bc4:	88dfc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0203bc8:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0203bca:	fd2490e3          	bne	s1,s2,ffffffffc0203b8a <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0203bce:	8522                	mv	a0,s0
ffffffffc0203bd0:	e3dff0ef          	jal	ra,ffffffffc0203a0c <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203bd4:	00003517          	auipc	a0,0x3
ffffffffc0203bd8:	f7c50513          	addi	a0,a0,-132 # ffffffffc0206b50 <default_pmm_manager+0xed8>
ffffffffc0203bdc:	db2fc0ef          	jal	ra,ffffffffc020018e <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203be0:	8b0fe0ef          	jal	ra,ffffffffc0201c90 <nr_free_pages>
ffffffffc0203be4:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0203be6:	ca1ff0ef          	jal	ra,ffffffffc0203886 <mm_create>
ffffffffc0203bea:	00013797          	auipc	a5,0x13
ffffffffc0203bee:	9ea7bf23          	sd	a0,-1538(a5) # ffffffffc02165e8 <check_mm_struct>
ffffffffc0203bf2:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0203bf4:	36050663          	beqz	a0,ffffffffc0203f60 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203bf8:	00013797          	auipc	a5,0x13
ffffffffc0203bfc:	89878793          	addi	a5,a5,-1896 # ffffffffc0216490 <boot_pgdir>
ffffffffc0203c00:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0203c04:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203c08:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0203c0c:	2c079e63          	bnez	a5,ffffffffc0203ee8 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203c10:	03000513          	li	a0,48
ffffffffc0203c14:	db3fd0ef          	jal	ra,ffffffffc02019c6 <kmalloc>
ffffffffc0203c18:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0203c1a:	18050b63          	beqz	a0,ffffffffc0203db0 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0203c1e:	002007b7          	lui	a5,0x200
ffffffffc0203c22:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0203c24:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203c26:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203c28:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0203c2a:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0203c2c:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0203c30:	d0fff0ef          	jal	ra,ffffffffc020393e <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203c34:	10000593          	li	a1,256
ffffffffc0203c38:	8526                	mv	a0,s1
ffffffffc0203c3a:	cc7ff0ef          	jal	ra,ffffffffc0203900 <find_vma>
ffffffffc0203c3e:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203c42:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203c46:	2ca41163          	bne	s0,a0,ffffffffc0203f08 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0203c4a:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0203c4e:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0203c50:	fee79de3          	bne	a5,a4,ffffffffc0203c4a <vmm_init+0x210>
        sum += i;
ffffffffc0203c54:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0203c56:	10000793          	li	a5,256
        sum += i;
ffffffffc0203c5a:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203c5e:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203c62:	0007c683          	lbu	a3,0(a5)
ffffffffc0203c66:	0785                	addi	a5,a5,1
ffffffffc0203c68:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203c6a:	fec79ce3          	bne	a5,a2,ffffffffc0203c62 <vmm_init+0x228>
    }
    assert(sum == 0);
ffffffffc0203c6e:	2c071963          	bnez	a4,ffffffffc0203f40 <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c72:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203c76:	00013a97          	auipc	s5,0x13
ffffffffc0203c7a:	822a8a93          	addi	s5,s5,-2014 # ffffffffc0216498 <npage>
ffffffffc0203c7e:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c82:	078a                	slli	a5,a5,0x2
ffffffffc0203c84:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c86:	20e7f563          	bleu	a4,a5,ffffffffc0203e90 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c8a:	00003697          	auipc	a3,0x3
ffffffffc0203c8e:	3de68693          	addi	a3,a3,990 # ffffffffc0207068 <nbase>
ffffffffc0203c92:	0006ba03          	ld	s4,0(a3)
ffffffffc0203c96:	414786b3          	sub	a3,a5,s4
ffffffffc0203c9a:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203c9c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0203c9e:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0203ca0:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0203ca2:	83b1                	srli	a5,a5,0xc
ffffffffc0203ca4:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203ca6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203ca8:	28e7f063          	bleu	a4,a5,ffffffffc0203f28 <vmm_init+0x4ee>
ffffffffc0203cac:	00013797          	auipc	a5,0x13
ffffffffc0203cb0:	84c78793          	addi	a5,a5,-1972 # ffffffffc02164f8 <va_pa_offset>
ffffffffc0203cb4:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203cb6:	4581                	li	a1,0
ffffffffc0203cb8:	854a                	mv	a0,s2
ffffffffc0203cba:	9436                	add	s0,s0,a3
ffffffffc0203cbc:	a48fe0ef          	jal	ra,ffffffffc0201f04 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203cc0:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203cc2:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203cc6:	078a                	slli	a5,a5,0x2
ffffffffc0203cc8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203cca:	1ce7f363          	bleu	a4,a5,ffffffffc0203e90 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203cce:	00013417          	auipc	s0,0x13
ffffffffc0203cd2:	83a40413          	addi	s0,s0,-1990 # ffffffffc0216508 <pages>
ffffffffc0203cd6:	6008                	ld	a0,0(s0)
ffffffffc0203cd8:	414787b3          	sub	a5,a5,s4
ffffffffc0203cdc:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0203cde:	953e                	add	a0,a0,a5
ffffffffc0203ce0:	4585                	li	a1,1
ffffffffc0203ce2:	f69fd0ef          	jal	ra,ffffffffc0201c4a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203ce6:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203cea:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203cee:	078a                	slli	a5,a5,0x2
ffffffffc0203cf0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203cf2:	18e7ff63          	bleu	a4,a5,ffffffffc0203e90 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203cf6:	6008                	ld	a0,0(s0)
ffffffffc0203cf8:	414787b3          	sub	a5,a5,s4
ffffffffc0203cfc:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0203cfe:	4585                	li	a1,1
ffffffffc0203d00:	953e                	add	a0,a0,a5
ffffffffc0203d02:	f49fd0ef          	jal	ra,ffffffffc0201c4a <free_pages>
    pgdir[0] = 0;
ffffffffc0203d06:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0203d0a:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0203d0e:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0203d12:	8526                	mv	a0,s1
ffffffffc0203d14:	cf9ff0ef          	jal	ra,ffffffffc0203a0c <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0203d18:	00013797          	auipc	a5,0x13
ffffffffc0203d1c:	8c07b823          	sd	zero,-1840(a5) # ffffffffc02165e8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203d20:	f71fd0ef          	jal	ra,ffffffffc0201c90 <nr_free_pages>
ffffffffc0203d24:	1aa99263          	bne	s3,a0,ffffffffc0203ec8 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203d28:	00003517          	auipc	a0,0x3
ffffffffc0203d2c:	eb850513          	addi	a0,a0,-328 # ffffffffc0206be0 <default_pmm_manager+0xf68>
ffffffffc0203d30:	c5efc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0203d34:	7442                	ld	s0,48(sp)
ffffffffc0203d36:	70e2                	ld	ra,56(sp)
ffffffffc0203d38:	74a2                	ld	s1,40(sp)
ffffffffc0203d3a:	7902                	ld	s2,32(sp)
ffffffffc0203d3c:	69e2                	ld	s3,24(sp)
ffffffffc0203d3e:	6a42                	ld	s4,16(sp)
ffffffffc0203d40:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d42:	00003517          	auipc	a0,0x3
ffffffffc0203d46:	ebe50513          	addi	a0,a0,-322 # ffffffffc0206c00 <default_pmm_manager+0xf88>
}
ffffffffc0203d4a:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d4c:	c42fc06f          	j	ffffffffc020018e <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203d50:	00003697          	auipc	a3,0x3
ffffffffc0203d54:	cd868693          	addi	a3,a3,-808 # ffffffffc0206a28 <default_pmm_manager+0xdb0>
ffffffffc0203d58:	00002617          	auipc	a2,0x2
ffffffffc0203d5c:	b8860613          	addi	a2,a2,-1144 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203d60:	0fe00593          	li	a1,254
ffffffffc0203d64:	00003517          	auipc	a0,0x3
ffffffffc0203d68:	b5450513          	addi	a0,a0,-1196 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203d6c:	ee4fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203d70:	00003697          	auipc	a3,0x3
ffffffffc0203d74:	d4068693          	addi	a3,a3,-704 # ffffffffc0206ab0 <default_pmm_manager+0xe38>
ffffffffc0203d78:	00002617          	auipc	a2,0x2
ffffffffc0203d7c:	b6860613          	addi	a2,a2,-1176 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203d80:	10e00593          	li	a1,270
ffffffffc0203d84:	00003517          	auipc	a0,0x3
ffffffffc0203d88:	b3450513          	addi	a0,a0,-1228 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203d8c:	ec4fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203d90:	00003697          	auipc	a3,0x3
ffffffffc0203d94:	d5068693          	addi	a3,a3,-688 # ffffffffc0206ae0 <default_pmm_manager+0xe68>
ffffffffc0203d98:	00002617          	auipc	a2,0x2
ffffffffc0203d9c:	b4860613          	addi	a2,a2,-1208 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203da0:	10f00593          	li	a1,271
ffffffffc0203da4:	00003517          	auipc	a0,0x3
ffffffffc0203da8:	b1450513          	addi	a0,a0,-1260 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203dac:	ea4fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(vma != NULL);
ffffffffc0203db0:	00002697          	auipc	a3,0x2
ffffffffc0203db4:	67868693          	addi	a3,a3,1656 # ffffffffc0206428 <default_pmm_manager+0x7b0>
ffffffffc0203db8:	00002617          	auipc	a2,0x2
ffffffffc0203dbc:	b2860613          	addi	a2,a2,-1240 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203dc0:	12e00593          	li	a1,302
ffffffffc0203dc4:	00003517          	auipc	a0,0x3
ffffffffc0203dc8:	af450513          	addi	a0,a0,-1292 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203dcc:	e84fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203dd0:	00003697          	auipc	a3,0x3
ffffffffc0203dd4:	c4068693          	addi	a3,a3,-960 # ffffffffc0206a10 <default_pmm_manager+0xd98>
ffffffffc0203dd8:	00002617          	auipc	a2,0x2
ffffffffc0203ddc:	b0860613          	addi	a2,a2,-1272 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203de0:	0fc00593          	li	a1,252
ffffffffc0203de4:	00003517          	auipc	a0,0x3
ffffffffc0203de8:	ad450513          	addi	a0,a0,-1324 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203dec:	e64fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma3 == NULL);
ffffffffc0203df0:	00003697          	auipc	a3,0x3
ffffffffc0203df4:	c9068693          	addi	a3,a3,-880 # ffffffffc0206a80 <default_pmm_manager+0xe08>
ffffffffc0203df8:	00002617          	auipc	a2,0x2
ffffffffc0203dfc:	ae860613          	addi	a2,a2,-1304 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203e00:	10800593          	li	a1,264
ffffffffc0203e04:	00003517          	auipc	a0,0x3
ffffffffc0203e08:	ab450513          	addi	a0,a0,-1356 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203e0c:	e44fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma2 != NULL);
ffffffffc0203e10:	00003697          	auipc	a3,0x3
ffffffffc0203e14:	c6068693          	addi	a3,a3,-928 # ffffffffc0206a70 <default_pmm_manager+0xdf8>
ffffffffc0203e18:	00002617          	auipc	a2,0x2
ffffffffc0203e1c:	ac860613          	addi	a2,a2,-1336 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203e20:	10600593          	li	a1,262
ffffffffc0203e24:	00003517          	auipc	a0,0x3
ffffffffc0203e28:	a9450513          	addi	a0,a0,-1388 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203e2c:	e24fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma1 != NULL);
ffffffffc0203e30:	00003697          	auipc	a3,0x3
ffffffffc0203e34:	c3068693          	addi	a3,a3,-976 # ffffffffc0206a60 <default_pmm_manager+0xde8>
ffffffffc0203e38:	00002617          	auipc	a2,0x2
ffffffffc0203e3c:	aa860613          	addi	a2,a2,-1368 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203e40:	10400593          	li	a1,260
ffffffffc0203e44:	00003517          	auipc	a0,0x3
ffffffffc0203e48:	a7450513          	addi	a0,a0,-1420 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203e4c:	e04fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma5 == NULL);
ffffffffc0203e50:	00003697          	auipc	a3,0x3
ffffffffc0203e54:	c5068693          	addi	a3,a3,-944 # ffffffffc0206aa0 <default_pmm_manager+0xe28>
ffffffffc0203e58:	00002617          	auipc	a2,0x2
ffffffffc0203e5c:	a8860613          	addi	a2,a2,-1400 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203e60:	10c00593          	li	a1,268
ffffffffc0203e64:	00003517          	auipc	a0,0x3
ffffffffc0203e68:	a5450513          	addi	a0,a0,-1452 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203e6c:	de4fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma4 == NULL);
ffffffffc0203e70:	00003697          	auipc	a3,0x3
ffffffffc0203e74:	c2068693          	addi	a3,a3,-992 # ffffffffc0206a90 <default_pmm_manager+0xe18>
ffffffffc0203e78:	00002617          	auipc	a2,0x2
ffffffffc0203e7c:	a6860613          	addi	a2,a2,-1432 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203e80:	10a00593          	li	a1,266
ffffffffc0203e84:	00003517          	auipc	a0,0x3
ffffffffc0203e88:	a3450513          	addi	a0,a0,-1484 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203e8c:	dc4fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203e90:	00002617          	auipc	a2,0x2
ffffffffc0203e94:	e9860613          	addi	a2,a2,-360 # ffffffffc0205d28 <default_pmm_manager+0xb0>
ffffffffc0203e98:	08000593          	li	a1,128
ffffffffc0203e9c:	00002517          	auipc	a0,0x2
ffffffffc0203ea0:	e5450513          	addi	a0,a0,-428 # ffffffffc0205cf0 <default_pmm_manager+0x78>
ffffffffc0203ea4:	dacfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(mm != NULL);
ffffffffc0203ea8:	00002697          	auipc	a3,0x2
ffffffffc0203eac:	54868693          	addi	a3,a3,1352 # ffffffffc02063f0 <default_pmm_manager+0x778>
ffffffffc0203eb0:	00002617          	auipc	a2,0x2
ffffffffc0203eb4:	a3060613          	addi	a2,a2,-1488 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203eb8:	0e800593          	li	a1,232
ffffffffc0203ebc:	00003517          	auipc	a0,0x3
ffffffffc0203ec0:	9fc50513          	addi	a0,a0,-1540 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203ec4:	d8cfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203ec8:	00003697          	auipc	a3,0x3
ffffffffc0203ecc:	cf068693          	addi	a3,a3,-784 # ffffffffc0206bb8 <default_pmm_manager+0xf40>
ffffffffc0203ed0:	00002617          	auipc	a2,0x2
ffffffffc0203ed4:	a1060613          	addi	a2,a2,-1520 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203ed8:	14a00593          	li	a1,330
ffffffffc0203edc:	00003517          	auipc	a0,0x3
ffffffffc0203ee0:	9dc50513          	addi	a0,a0,-1572 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203ee4:	d6cfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203ee8:	00002697          	auipc	a3,0x2
ffffffffc0203eec:	53068693          	addi	a3,a3,1328 # ffffffffc0206418 <default_pmm_manager+0x7a0>
ffffffffc0203ef0:	00002617          	auipc	a2,0x2
ffffffffc0203ef4:	9f060613          	addi	a2,a2,-1552 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203ef8:	12b00593          	li	a1,299
ffffffffc0203efc:	00003517          	auipc	a0,0x3
ffffffffc0203f00:	9bc50513          	addi	a0,a0,-1604 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203f04:	d4cfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203f08:	00003697          	auipc	a3,0x3
ffffffffc0203f0c:	c8068693          	addi	a3,a3,-896 # ffffffffc0206b88 <default_pmm_manager+0xf10>
ffffffffc0203f10:	00002617          	auipc	a2,0x2
ffffffffc0203f14:	9d060613          	addi	a2,a2,-1584 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203f18:	13300593          	li	a1,307
ffffffffc0203f1c:	00003517          	auipc	a0,0x3
ffffffffc0203f20:	99c50513          	addi	a0,a0,-1636 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203f24:	d2cfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203f28:	00002617          	auipc	a2,0x2
ffffffffc0203f2c:	da060613          	addi	a2,a2,-608 # ffffffffc0205cc8 <default_pmm_manager+0x50>
ffffffffc0203f30:	08b00593          	li	a1,139
ffffffffc0203f34:	00002517          	auipc	a0,0x2
ffffffffc0203f38:	dbc50513          	addi	a0,a0,-580 # ffffffffc0205cf0 <default_pmm_manager+0x78>
ffffffffc0203f3c:	d14fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(sum == 0);
ffffffffc0203f40:	00003697          	auipc	a3,0x3
ffffffffc0203f44:	c6868693          	addi	a3,a3,-920 # ffffffffc0206ba8 <default_pmm_manager+0xf30>
ffffffffc0203f48:	00002617          	auipc	a2,0x2
ffffffffc0203f4c:	99860613          	addi	a2,a2,-1640 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203f50:	13d00593          	li	a1,317
ffffffffc0203f54:	00003517          	auipc	a0,0x3
ffffffffc0203f58:	96450513          	addi	a0,a0,-1692 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203f5c:	cf4fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203f60:	00003697          	auipc	a3,0x3
ffffffffc0203f64:	c1068693          	addi	a3,a3,-1008 # ffffffffc0206b70 <default_pmm_manager+0xef8>
ffffffffc0203f68:	00002617          	auipc	a2,0x2
ffffffffc0203f6c:	97860613          	addi	a2,a2,-1672 # ffffffffc02058e0 <commands+0x870>
ffffffffc0203f70:	12700593          	li	a1,295
ffffffffc0203f74:	00003517          	auipc	a0,0x3
ffffffffc0203f78:	94450513          	addi	a0,a0,-1724 # ffffffffc02068b8 <default_pmm_manager+0xc40>
ffffffffc0203f7c:	cd4fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203f80 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203f80:	7179                	addi	sp,sp,-48
    // mm mm_struct的结构体
    // error_code 错误码
    // addr 产生异常的地址
    int ret = -E_INVAL; // 返回值初始化为-E_INVAL，为无效值
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr); // 找到地址对应的vma_struct结构体
ffffffffc0203f82:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203f84:	f022                	sd	s0,32(sp)
ffffffffc0203f86:	ec26                	sd	s1,24(sp)
ffffffffc0203f88:	f406                	sd	ra,40(sp)
ffffffffc0203f8a:	e84a                	sd	s2,16(sp)
ffffffffc0203f8c:	8432                	mv	s0,a2
ffffffffc0203f8e:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr); // 找到地址对应的vma_struct结构体
ffffffffc0203f90:	971ff0ef          	jal	ra,ffffffffc0203900 <find_vma>
    //我们首先要做的就是在mm_struct里判断这个虚拟地址是否可用
    pgfault_num++;
ffffffffc0203f94:	00012797          	auipc	a5,0x12
ffffffffc0203f98:	51878793          	addi	a5,a5,1304 # ffffffffc02164ac <pgfault_num>
ffffffffc0203f9c:	439c                	lw	a5,0(a5)
ffffffffc0203f9e:	2785                	addiw	a5,a5,1
ffffffffc0203fa0:	00012717          	auipc	a4,0x12
ffffffffc0203fa4:	50f72623          	sw	a5,1292(a4) # ffffffffc02164ac <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203fa8:	c949                	beqz	a0,ffffffffc020403a <do_pgfault+0xba>
ffffffffc0203faa:	651c                	ld	a5,8(a0)
ffffffffc0203fac:	08f46763          	bltu	s0,a5,ffffffffc020403a <do_pgfault+0xba>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U; // 定义页权限并初始化为用户模式。
    if (vma->vm_flags & VM_WRITE) {  // 检查vma是否可写
ffffffffc0203fb0:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U; // 定义页权限并初始化为用户模式。
ffffffffc0203fb2:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {  // 检查vma是否可写
ffffffffc0203fb4:	8b89                	andi	a5,a5,2
ffffffffc0203fb6:	e3ad                	bnez	a5,ffffffffc0204018 <do_pgfault+0x98>
        perm |= READ_WRITE;
    }
    //按照页面大小把地址对齐
    addr = ROUNDDOWN(addr, PGSIZE); // 将addr向下对齐到页面大小的整数倍，找到发生缺页的addr所在的页面的首地址
ffffffffc0203fb8:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL; // 新建一个页表条目的指针
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203fba:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE); // 将addr向下对齐到页面大小的整数倍，找到发生缺页的addr所在的页面的首地址
ffffffffc0203fbc:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203fbe:	85a2                	mv	a1,s0
ffffffffc0203fc0:	4605                	li	a2,1
ffffffffc0203fc2:	d0ffd0ef          	jal	ra,ffffffffc0201cd0 <get_pte>
ffffffffc0203fc6:	c179                	beqz	a0,ffffffffc020408c <do_pgfault+0x10c>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0203fc8:	610c                	ld	a1,0(a0)
ffffffffc0203fca:	c9a9                	beqz	a1,ffffffffc020401c <do_pgfault+0x9c>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203fcc:	00012797          	auipc	a5,0x12
ffffffffc0203fd0:	4dc78793          	addi	a5,a5,1244 # ffffffffc02164a8 <swap_init_ok>
ffffffffc0203fd4:	439c                	lw	a5,0(a5)
ffffffffc0203fd6:	2781                	sext.w	a5,a5
ffffffffc0203fd8:	cbb5                	beqz	a5,ffffffffc020404c <do_pgfault+0xcc>
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.

            // (1) 尝试加载正确的磁盘页面的内容到内存中的页面
            int result = swap_in(mm, addr, &page); // ***在这里进swap_in函数
ffffffffc0203fda:	0030                	addi	a2,sp,8
ffffffffc0203fdc:	85a2                	mv	a1,s0
ffffffffc0203fde:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203fe0:	e402                	sd	zero,8(sp)
            int result = swap_in(mm, addr, &page); // ***在这里进swap_in函数
ffffffffc0203fe2:	c1eff0ef          	jal	ra,ffffffffc0203400 <swap_in>
            if (result != 0)
ffffffffc0203fe6:	e93d                	bnez	a0,ffffffffc020405c <do_pgfault+0xdc>
                cprintf("swap_in failed\n");
                goto failed;
            }

            // (2) 设置物理地址和逻辑地址的映射
            if (page_insert(mm->pgdir, page, addr, perm) != 0)
ffffffffc0203fe8:	65a2                	ld	a1,8(sp)
ffffffffc0203fea:	6c88                	ld	a0,24(s1)
ffffffffc0203fec:	86ca                	mv	a3,s2
ffffffffc0203fee:	8622                	mv	a2,s0
ffffffffc0203ff0:	f89fd0ef          	jal	ra,ffffffffc0201f78 <page_insert>
ffffffffc0203ff4:	ed25                	bnez	a0,ffffffffc020406c <do_pgfault+0xec>
                cprintf("page_insert failed\n");
                goto failed;
            }

            // (3) 设置页面为可交换的
            if (swap_map_swappable(mm, addr, page, 1) != 0)
ffffffffc0203ff6:	6622                	ld	a2,8(sp)
ffffffffc0203ff8:	4685                	li	a3,1
ffffffffc0203ffa:	85a2                	mv	a1,s0
ffffffffc0203ffc:	8526                	mv	a0,s1
ffffffffc0203ffe:	adeff0ef          	jal	ra,ffffffffc02032dc <swap_map_swappable>
ffffffffc0204002:	87aa                	mv	a5,a0
ffffffffc0204004:	ed25                	bnez	a0,ffffffffc020407c <do_pgfault+0xfc>
            {
                cprintf("swap_map_swappable failed\n");
                goto failed;
            }
            page->pra_vaddr = addr;
ffffffffc0204006:	6722                	ld	a4,8(sp)
ffffffffc0204008:	ff00                	sd	s0,56(a4)
   }

   ret = 0;
failed:
    return ret;
}
ffffffffc020400a:	70a2                	ld	ra,40(sp)
ffffffffc020400c:	7402                	ld	s0,32(sp)
ffffffffc020400e:	64e2                	ld	s1,24(sp)
ffffffffc0204010:	6942                	ld	s2,16(sp)
ffffffffc0204012:	853e                	mv	a0,a5
ffffffffc0204014:	6145                	addi	sp,sp,48
ffffffffc0204016:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204018:	495d                	li	s2,23
ffffffffc020401a:	bf79                	j	ffffffffc0203fb8 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020401c:	6c88                	ld	a0,24(s1)
ffffffffc020401e:	864a                	mv	a2,s2
ffffffffc0204020:	85a2                	mv	a1,s0
ffffffffc0204022:	aa5fe0ef          	jal	ra,ffffffffc0202ac6 <pgdir_alloc_page>
   ret = 0;
ffffffffc0204026:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204028:	f16d                	bnez	a0,ffffffffc020400a <do_pgfault+0x8a>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc020402a:	00003517          	auipc	a0,0x3
ffffffffc020402e:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0206918 <default_pmm_manager+0xca0>
ffffffffc0204032:	95cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;  // 表示没有可用内存
ffffffffc0204036:	57f1                	li	a5,-4
            goto failed;
ffffffffc0204038:	bfc9                	j	ffffffffc020400a <do_pgfault+0x8a>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc020403a:	85a2                	mv	a1,s0
ffffffffc020403c:	00003517          	auipc	a0,0x3
ffffffffc0204040:	88c50513          	addi	a0,a0,-1908 # ffffffffc02068c8 <default_pmm_manager+0xc50>
ffffffffc0204044:	94afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = -E_INVAL; // 返回值初始化为-E_INVAL，为无效值
ffffffffc0204048:	57f5                	li	a5,-3
        goto failed;
ffffffffc020404a:	b7c1                	j	ffffffffc020400a <do_pgfault+0x8a>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc020404c:	00003517          	auipc	a0,0x3
ffffffffc0204050:	93c50513          	addi	a0,a0,-1732 # ffffffffc0206988 <default_pmm_manager+0xd10>
ffffffffc0204054:	93afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;  // 表示没有可用内存
ffffffffc0204058:	57f1                	li	a5,-4
            goto failed;
ffffffffc020405a:	bf45                	j	ffffffffc020400a <do_pgfault+0x8a>
                cprintf("swap_in failed\n");
ffffffffc020405c:	00003517          	auipc	a0,0x3
ffffffffc0204060:	8e450513          	addi	a0,a0,-1820 # ffffffffc0206940 <default_pmm_manager+0xcc8>
ffffffffc0204064:	92afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;  // 表示没有可用内存
ffffffffc0204068:	57f1                	li	a5,-4
ffffffffc020406a:	b745                	j	ffffffffc020400a <do_pgfault+0x8a>
                cprintf("page_insert failed\n");
ffffffffc020406c:	00003517          	auipc	a0,0x3
ffffffffc0204070:	8e450513          	addi	a0,a0,-1820 # ffffffffc0206950 <default_pmm_manager+0xcd8>
ffffffffc0204074:	91afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;  // 表示没有可用内存
ffffffffc0204078:	57f1                	li	a5,-4
ffffffffc020407a:	bf41                	j	ffffffffc020400a <do_pgfault+0x8a>
                cprintf("swap_map_swappable failed\n");
ffffffffc020407c:	00003517          	auipc	a0,0x3
ffffffffc0204080:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0206968 <default_pmm_manager+0xcf0>
ffffffffc0204084:	90afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;  // 表示没有可用内存
ffffffffc0204088:	57f1                	li	a5,-4
ffffffffc020408a:	b741                	j	ffffffffc020400a <do_pgfault+0x8a>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc020408c:	00003517          	auipc	a0,0x3
ffffffffc0204090:	86c50513          	addi	a0,a0,-1940 # ffffffffc02068f8 <default_pmm_manager+0xc80>
ffffffffc0204094:	8fafc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;  // 表示没有可用内存
ffffffffc0204098:	57f1                	li	a5,-4
        goto failed;
ffffffffc020409a:	bf85                	j	ffffffffc020400a <do_pgfault+0x8a>

ffffffffc020409c <swapfs_init>:
#include <pmm.h>
#include <assert.h>

//初始化交换分区文件系统
void
swapfs_init(void) {//做一些检查
ffffffffc020409c:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);//检查每个页面的大小是否是扇区大小的整数倍;
    if (!ide_device_valid(SWAP_DEV_NO)) {//检查交换分区所在的磁盘是否存在
ffffffffc020409e:	4505                	li	a0,1
swapfs_init(void) {//做一些检查
ffffffffc02040a0:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {//检查交换分区所在的磁盘是否存在
ffffffffc02040a2:	cdafc0ef          	jal	ra,ffffffffc020057c <ide_device_valid>
ffffffffc02040a6:	cd01                	beqz	a0,ffffffffc02040be <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    //计算交换分区的最大偏移量
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE); //56/8=7
ffffffffc02040a8:	4505                	li	a0,1
ffffffffc02040aa:	cd8fc0ef          	jal	ra,ffffffffc0200582 <ide_device_size>
}
ffffffffc02040ae:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE); //56/8=7
ffffffffc02040b0:	810d                	srli	a0,a0,0x3
ffffffffc02040b2:	00012797          	auipc	a5,0x12
ffffffffc02040b6:	4ea7b323          	sd	a0,1254(a5) # ffffffffc0216598 <max_swap_offset>
}
ffffffffc02040ba:	0141                	addi	sp,sp,16
ffffffffc02040bc:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc02040be:	00003617          	auipc	a2,0x3
ffffffffc02040c2:	b5a60613          	addi	a2,a2,-1190 # ffffffffc0206c18 <default_pmm_manager+0xfa0>
ffffffffc02040c6:	45b9                	li	a1,14
ffffffffc02040c8:	00003517          	auipc	a0,0x3
ffffffffc02040cc:	b7050513          	addi	a0,a0,-1168 # ffffffffc0206c38 <default_pmm_manager+0xfc0>
ffffffffc02040d0:	b80fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02040d4 <swapfs_read>:

//从交换分区中读取指定的交换条目，病将其存储到指定的页面中
int swapfs_read(swap_entry_t entry, struct Page *page)
{   // 从磁盘交换分区读取页面
ffffffffc02040d4:	1141                	addi	sp,sp,-16
ffffffffc02040d6:	e406                	sd	ra,8(sp)
    // swap_entry_t（其实就是整数） entry：交换分区中的偏移量
    // struct Page *page：页面结构体指针
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02040d8:	00855793          	srli	a5,a0,0x8
ffffffffc02040dc:	cfb9                	beqz	a5,ffffffffc020413a <swapfs_read+0x66>
ffffffffc02040de:	00012717          	auipc	a4,0x12
ffffffffc02040e2:	4ba70713          	addi	a4,a4,1210 # ffffffffc0216598 <max_swap_offset>
ffffffffc02040e6:	6318                	ld	a4,0(a4)
ffffffffc02040e8:	04e7f963          	bleu	a4,a5,ffffffffc020413a <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc02040ec:	00012717          	auipc	a4,0x12
ffffffffc02040f0:	41c70713          	addi	a4,a4,1052 # ffffffffc0216508 <pages>
ffffffffc02040f4:	6310                	ld	a2,0(a4)
ffffffffc02040f6:	00003717          	auipc	a4,0x3
ffffffffc02040fa:	f7270713          	addi	a4,a4,-142 # ffffffffc0207068 <nbase>
    return KADDR(page2pa(page));
ffffffffc02040fe:	00012697          	auipc	a3,0x12
ffffffffc0204102:	39a68693          	addi	a3,a3,922 # ffffffffc0216498 <npage>
    return page - pages + nbase;
ffffffffc0204106:	40c58633          	sub	a2,a1,a2
ffffffffc020410a:	630c                	ld	a1,0(a4)
ffffffffc020410c:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc020410e:	577d                	li	a4,-1
ffffffffc0204110:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204112:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204114:	8331                	srli	a4,a4,0xc
ffffffffc0204116:	8f71                	and	a4,a4,a2
ffffffffc0204118:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc020411c:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc020411e:	02d77a63          	bleu	a3,a4,ffffffffc0204152 <swapfs_read+0x7e>
ffffffffc0204122:	00012797          	auipc	a5,0x12
ffffffffc0204126:	3d678793          	addi	a5,a5,982 # ffffffffc02164f8 <va_pa_offset>
ffffffffc020412a:	639c                	ld	a5,0(a5)
}
ffffffffc020412c:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020412e:	46a1                	li	a3,8
ffffffffc0204130:	963e                	add	a2,a2,a5
ffffffffc0204132:	4505                	li	a0,1
}
ffffffffc0204134:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204136:	c52fc06f          	j	ffffffffc0200588 <ide_read_secs>
ffffffffc020413a:	86aa                	mv	a3,a0
ffffffffc020413c:	00003617          	auipc	a2,0x3
ffffffffc0204140:	b1460613          	addi	a2,a2,-1260 # ffffffffc0206c50 <default_pmm_manager+0xfd8>
ffffffffc0204144:	45e5                	li	a1,25
ffffffffc0204146:	00003517          	auipc	a0,0x3
ffffffffc020414a:	af250513          	addi	a0,a0,-1294 # ffffffffc0206c38 <default_pmm_manager+0xfc0>
ffffffffc020414e:	b02fc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0204152:	86b2                	mv	a3,a2
ffffffffc0204154:	08b00593          	li	a1,139
ffffffffc0204158:	00002617          	auipc	a2,0x2
ffffffffc020415c:	b7060613          	addi	a2,a2,-1168 # ffffffffc0205cc8 <default_pmm_manager+0x50>
ffffffffc0204160:	00002517          	auipc	a0,0x2
ffffffffc0204164:	b9050513          	addi	a0,a0,-1136 # ffffffffc0205cf0 <default_pmm_manager+0x78>
ffffffffc0204168:	ae8fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020416c <swapfs_write>:

int swapfs_write(swap_entry_t entry, struct Page *page)
{ // 将页面写入交换磁盘分区
ffffffffc020416c:	1141                	addi	sp,sp,-16
ffffffffc020416e:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204170:	00855793          	srli	a5,a0,0x8
ffffffffc0204174:	cfb9                	beqz	a5,ffffffffc02041d2 <swapfs_write+0x66>
ffffffffc0204176:	00012717          	auipc	a4,0x12
ffffffffc020417a:	42270713          	addi	a4,a4,1058 # ffffffffc0216598 <max_swap_offset>
ffffffffc020417e:	6318                	ld	a4,0(a4)
ffffffffc0204180:	04e7f963          	bleu	a4,a5,ffffffffc02041d2 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204184:	00012717          	auipc	a4,0x12
ffffffffc0204188:	38470713          	addi	a4,a4,900 # ffffffffc0216508 <pages>
ffffffffc020418c:	6310                	ld	a2,0(a4)
ffffffffc020418e:	00003717          	auipc	a4,0x3
ffffffffc0204192:	eda70713          	addi	a4,a4,-294 # ffffffffc0207068 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204196:	00012697          	auipc	a3,0x12
ffffffffc020419a:	30268693          	addi	a3,a3,770 # ffffffffc0216498 <npage>
    return page - pages + nbase;
ffffffffc020419e:	40c58633          	sub	a2,a1,a2
ffffffffc02041a2:	630c                	ld	a1,0(a4)
ffffffffc02041a4:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc02041a6:	577d                	li	a4,-1
ffffffffc02041a8:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc02041aa:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc02041ac:	8331                	srli	a4,a4,0xc
ffffffffc02041ae:	8f71                	and	a4,a4,a2
ffffffffc02041b0:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc02041b4:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc02041b6:	02d77a63          	bleu	a3,a4,ffffffffc02041ea <swapfs_write+0x7e>
ffffffffc02041ba:	00012797          	auipc	a5,0x12
ffffffffc02041be:	33e78793          	addi	a5,a5,830 # ffffffffc02164f8 <va_pa_offset>
ffffffffc02041c2:	639c                	ld	a5,0(a5)
}
ffffffffc02041c4:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02041c6:	46a1                	li	a3,8
ffffffffc02041c8:	963e                	add	a2,a2,a5
ffffffffc02041ca:	4505                	li	a0,1
}
ffffffffc02041cc:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02041ce:	bdefc06f          	j	ffffffffc02005ac <ide_write_secs>
ffffffffc02041d2:	86aa                	mv	a3,a0
ffffffffc02041d4:	00003617          	auipc	a2,0x3
ffffffffc02041d8:	a7c60613          	addi	a2,a2,-1412 # ffffffffc0206c50 <default_pmm_manager+0xfd8>
ffffffffc02041dc:	45f9                	li	a1,30
ffffffffc02041de:	00003517          	auipc	a0,0x3
ffffffffc02041e2:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0206c38 <default_pmm_manager+0xfc0>
ffffffffc02041e6:	a6afc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc02041ea:	86b2                	mv	a3,a2
ffffffffc02041ec:	08b00593          	li	a1,139
ffffffffc02041f0:	00002617          	auipc	a2,0x2
ffffffffc02041f4:	ad860613          	addi	a2,a2,-1320 # ffffffffc0205cc8 <default_pmm_manager+0x50>
ffffffffc02041f8:	00002517          	auipc	a0,0x2
ffffffffc02041fc:	af850513          	addi	a0,a0,-1288 # ffffffffc0205cf0 <default_pmm_manager+0x78>
ffffffffc0204200:	a50fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0204204 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1 #放在了a0寄存器，并跳转到s0执行我们指定的函数，本实验中就是init_main函数，用来输出一些字符串，后续实验用这个进程做更多的事情
ffffffffc0204204:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204206:	9402                	jalr	s0

	jal do_exit
ffffffffc0204208:	4c8000ef          	jal	ra,ffffffffc02046d0 <do_exit>

ffffffffc020420c <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc020420c:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc020420e:	0e800513          	li	a0,232
{
ffffffffc0204212:	e022                	sd	s0,0(sp)
ffffffffc0204214:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204216:	fb0fd0ef          	jal	ra,ffffffffc02019c6 <kmalloc>
ffffffffc020421a:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc020421c:	c529                	beqz	a0,ffffffffc0204266 <alloc_proc+0x5a>
         *       struct trapframe *tf;                       // Trap frame for current interrupt
         *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
         *       uint32_t flags;                             // Process flag
         *       char name[PROC_NAME_LEN + 1];               // Process name
         */
        proc->state = PROC_UNINIT; // 设置进程为初始态
ffffffffc020421e:	57fd                	li	a5,-1
ffffffffc0204220:	1782                	slli	a5,a5,0x20
ffffffffc0204222:	e11c                	sd	a5,0(a0)
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204224:	07000613          	li	a2,112
ffffffffc0204228:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc020422a:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc020422e:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204232:	00052c23          	sw	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204236:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc020423a:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc020423e:	03050513          	addi	a0,a0,48
ffffffffc0204242:	49f000ef          	jal	ra,ffffffffc0204ee0 <memset>
        proc->tf = NULL;
        proc->cr3 = boot_cr3; // 使用内核页目录表的基址
ffffffffc0204246:	00012797          	auipc	a5,0x12
ffffffffc020424a:	2ba78793          	addi	a5,a5,698 # ffffffffc0216500 <boot_cr3>
ffffffffc020424e:	639c                	ld	a5,0(a5)
        proc->tf = NULL;
ffffffffc0204250:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc0204254:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3; // 使用内核页目录表的基址
ffffffffc0204258:	f45c                	sd	a5,168(s0)
        memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc020425a:	463d                	li	a2,15
ffffffffc020425c:	4581                	li	a1,0
ffffffffc020425e:	0b440513          	addi	a0,s0,180
ffffffffc0204262:	47f000ef          	jal	ra,ffffffffc0204ee0 <memset>
    }
    return proc;
}
ffffffffc0204266:	8522                	mv	a0,s0
ffffffffc0204268:	60a2                	ld	ra,8(sp)
ffffffffc020426a:	6402                	ld	s0,0(sp)
ffffffffc020426c:	0141                	addi	sp,sp,16
ffffffffc020426e:	8082                	ret

ffffffffc0204270 <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) // forkret函数调用了forkrets函数，参数是当前的tf，第一次启用新线程的时候执行的restore等操作。
{
    forkrets(current->tf);
ffffffffc0204270:	00012797          	auipc	a5,0x12
ffffffffc0204274:	24078793          	addi	a5,a5,576 # ffffffffc02164b0 <current>
ffffffffc0204278:	639c                	ld	a5,0(a5)
ffffffffc020427a:	73c8                	ld	a0,160(a5)
ffffffffc020427c:	949fc06f          	j	ffffffffc0200bc4 <forkrets>

ffffffffc0204280 <set_proc_name>:
{
ffffffffc0204280:	1101                	addi	sp,sp,-32
ffffffffc0204282:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204284:	0b450413          	addi	s0,a0,180
{
ffffffffc0204288:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020428a:	4641                	li	a2,16
{
ffffffffc020428c:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020428e:	8522                	mv	a0,s0
ffffffffc0204290:	4581                	li	a1,0
{
ffffffffc0204292:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204294:	44d000ef          	jal	ra,ffffffffc0204ee0 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204298:	8522                	mv	a0,s0
}
ffffffffc020429a:	6442                	ld	s0,16(sp)
ffffffffc020429c:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020429e:	85a6                	mv	a1,s1
}
ffffffffc02042a0:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02042a2:	463d                	li	a2,15
}
ffffffffc02042a4:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02042a6:	44d0006f          	j	ffffffffc0204ef2 <memcpy>

ffffffffc02042aa <get_proc_name>:
{
ffffffffc02042aa:	1101                	addi	sp,sp,-32
ffffffffc02042ac:	e822                	sd	s0,16(sp)
    memset(name, 0, sizeof(name));
ffffffffc02042ae:	00012417          	auipc	s0,0x12
ffffffffc02042b2:	1b240413          	addi	s0,s0,434 # ffffffffc0216460 <name.1565>
{
ffffffffc02042b6:	e426                	sd	s1,8(sp)
    memset(name, 0, sizeof(name));
ffffffffc02042b8:	4641                	li	a2,16
{
ffffffffc02042ba:	84aa                	mv	s1,a0
    memset(name, 0, sizeof(name));
ffffffffc02042bc:	4581                	li	a1,0
ffffffffc02042be:	8522                	mv	a0,s0
{
ffffffffc02042c0:	ec06                	sd	ra,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc02042c2:	41f000ef          	jal	ra,ffffffffc0204ee0 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02042c6:	8522                	mv	a0,s0
}
ffffffffc02042c8:	6442                	ld	s0,16(sp)
ffffffffc02042ca:	60e2                	ld	ra,24(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02042cc:	0b448593          	addi	a1,s1,180
}
ffffffffc02042d0:	64a2                	ld	s1,8(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02042d2:	463d                	li	a2,15
}
ffffffffc02042d4:	6105                	addi	sp,sp,32
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02042d6:	41d0006f          	j	ffffffffc0204ef2 <memcpy>

ffffffffc02042da <init_main>:

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02042da:	00012797          	auipc	a5,0x12
ffffffffc02042de:	1d678793          	addi	a5,a5,470 # ffffffffc02164b0 <current>
ffffffffc02042e2:	639c                	ld	a5,0(a5)
{
ffffffffc02042e4:	1101                	addi	sp,sp,-32
ffffffffc02042e6:	e426                	sd	s1,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02042e8:	43c4                	lw	s1,4(a5)
{
ffffffffc02042ea:	e822                	sd	s0,16(sp)
ffffffffc02042ec:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02042ee:	853e                	mv	a0,a5
{
ffffffffc02042f0:	ec06                	sd	ra,24(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02042f2:	fb9ff0ef          	jal	ra,ffffffffc02042aa <get_proc_name>
ffffffffc02042f6:	862a                	mv	a2,a0
ffffffffc02042f8:	85a6                	mv	a1,s1
ffffffffc02042fa:	00003517          	auipc	a0,0x3
ffffffffc02042fe:	9be50513          	addi	a0,a0,-1602 # ffffffffc0206cb8 <default_pmm_manager+0x1040>
ffffffffc0204302:	e8dfb0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc0204306:	85a2                	mv	a1,s0
ffffffffc0204308:	00003517          	auipc	a0,0x3
ffffffffc020430c:	9d850513          	addi	a0,a0,-1576 # ffffffffc0206ce0 <default_pmm_manager+0x1068>
ffffffffc0204310:	e7ffb0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc0204314:	00003517          	auipc	a0,0x3
ffffffffc0204318:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0206cf0 <default_pmm_manager+0x1078>
ffffffffc020431c:	e73fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
}
ffffffffc0204320:	60e2                	ld	ra,24(sp)
ffffffffc0204322:	6442                	ld	s0,16(sp)
ffffffffc0204324:	64a2                	ld	s1,8(sp)
ffffffffc0204326:	4501                	li	a0,0
ffffffffc0204328:	6105                	addi	sp,sp,32
ffffffffc020432a:	8082                	ret

ffffffffc020432c <proc_run>:
{
ffffffffc020432c:	1101                	addi	sp,sp,-32
    if (proc != current)
ffffffffc020432e:	00012797          	auipc	a5,0x12
ffffffffc0204332:	18278793          	addi	a5,a5,386 # ffffffffc02164b0 <current>
{
ffffffffc0204336:	e426                	sd	s1,8(sp)
    if (proc != current)
ffffffffc0204338:	6384                	ld	s1,0(a5)
{
ffffffffc020433a:	ec06                	sd	ra,24(sp)
ffffffffc020433c:	e822                	sd	s0,16(sp)
ffffffffc020433e:	e04a                	sd	s2,0(sp)
    if (proc != current)
ffffffffc0204340:	02a48c63          	beq	s1,a0,ffffffffc0204378 <proc_run+0x4c>
ffffffffc0204344:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204346:	100027f3          	csrr	a5,sstatus
ffffffffc020434a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020434c:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020434e:	e3b1                	bnez	a5,ffffffffc0204392 <proc_run+0x66>
            lcr3(next->cr3);
ffffffffc0204350:	745c                	ld	a5,168(s0)
            current = proc;
ffffffffc0204352:	00012717          	auipc	a4,0x12
ffffffffc0204356:	14873f23          	sd	s0,350(a4) # ffffffffc02164b0 <current>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc020435a:	80000737          	lui	a4,0x80000
ffffffffc020435e:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc0204362:	8fd9                	or	a5,a5,a4
ffffffffc0204364:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0204368:	03040593          	addi	a1,s0,48
ffffffffc020436c:	03048513          	addi	a0,s1,48
ffffffffc0204370:	58c000ef          	jal	ra,ffffffffc02048fc <switch_to>
    if (flag)
ffffffffc0204374:	00091863          	bnez	s2,ffffffffc0204384 <proc_run+0x58>
}
ffffffffc0204378:	60e2                	ld	ra,24(sp)
ffffffffc020437a:	6442                	ld	s0,16(sp)
ffffffffc020437c:	64a2                	ld	s1,8(sp)
ffffffffc020437e:	6902                	ld	s2,0(sp)
ffffffffc0204380:	6105                	addi	sp,sp,32
ffffffffc0204382:	8082                	ret
ffffffffc0204384:	6442                	ld	s0,16(sp)
ffffffffc0204386:	60e2                	ld	ra,24(sp)
ffffffffc0204388:	64a2                	ld	s1,8(sp)
ffffffffc020438a:	6902                	ld	s2,0(sp)
ffffffffc020438c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020438e:	a44fc06f          	j	ffffffffc02005d2 <intr_enable>
        intr_disable();
ffffffffc0204392:	a46fc0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
        return 1;
ffffffffc0204396:	4905                	li	s2,1
ffffffffc0204398:	bf65                	j	ffffffffc0204350 <proc_run+0x24>

ffffffffc020439a <find_proc>:
    if (0 < pid && pid < MAX_PID)
ffffffffc020439a:	0005071b          	sext.w	a4,a0
ffffffffc020439e:	6789                	lui	a5,0x2
ffffffffc02043a0:	fff7069b          	addiw	a3,a4,-1
ffffffffc02043a4:	17f9                	addi	a5,a5,-2
ffffffffc02043a6:	04d7e063          	bltu	a5,a3,ffffffffc02043e6 <find_proc+0x4c>
{
ffffffffc02043aa:	1141                	addi	sp,sp,-16
ffffffffc02043ac:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02043ae:	45a9                	li	a1,10
ffffffffc02043b0:	842a                	mv	s0,a0
ffffffffc02043b2:	853a                	mv	a0,a4
{
ffffffffc02043b4:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02043b6:	67c000ef          	jal	ra,ffffffffc0204a32 <hash32>
ffffffffc02043ba:	02051693          	slli	a3,a0,0x20
ffffffffc02043be:	82f1                	srli	a3,a3,0x1c
ffffffffc02043c0:	0000e517          	auipc	a0,0xe
ffffffffc02043c4:	0a050513          	addi	a0,a0,160 # ffffffffc0212460 <hash_list>
ffffffffc02043c8:	96aa                	add	a3,a3,a0
ffffffffc02043ca:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc02043cc:	a029                	j	ffffffffc02043d6 <find_proc+0x3c>
            if (proc->pid == pid)
ffffffffc02043ce:	f2c7a703          	lw	a4,-212(a5) # 1f2c <BASE_ADDRESS-0xffffffffc01fe0d4>
ffffffffc02043d2:	00870c63          	beq	a4,s0,ffffffffc02043ea <find_proc+0x50>
ffffffffc02043d6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02043d8:	fef69be3          	bne	a3,a5,ffffffffc02043ce <find_proc+0x34>
}
ffffffffc02043dc:	60a2                	ld	ra,8(sp)
ffffffffc02043de:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02043e0:	4501                	li	a0,0
}
ffffffffc02043e2:	0141                	addi	sp,sp,16
ffffffffc02043e4:	8082                	ret
    return NULL;
ffffffffc02043e6:	4501                	li	a0,0
}
ffffffffc02043e8:	8082                	ret
ffffffffc02043ea:	60a2                	ld	ra,8(sp)
ffffffffc02043ec:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02043ee:	f2878513          	addi	a0,a5,-216
}
ffffffffc02043f2:	0141                	addi	sp,sp,16
ffffffffc02043f4:	8082                	ret

ffffffffc02043f6 <do_fork>:
{
ffffffffc02043f6:	7179                	addi	sp,sp,-48
ffffffffc02043f8:	e44e                	sd	s3,8(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc02043fa:	00012997          	auipc	s3,0x12
ffffffffc02043fe:	0ce98993          	addi	s3,s3,206 # ffffffffc02164c8 <nr_process>
ffffffffc0204402:	0009a703          	lw	a4,0(s3)
{
ffffffffc0204406:	f406                	sd	ra,40(sp)
ffffffffc0204408:	f022                	sd	s0,32(sp)
ffffffffc020440a:	ec26                	sd	s1,24(sp)
ffffffffc020440c:	e84a                	sd	s2,16(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc020440e:	6785                	lui	a5,0x1
ffffffffc0204410:	22f75863          	ble	a5,a4,ffffffffc0204640 <do_fork+0x24a>
ffffffffc0204414:	892e                	mv	s2,a1
ffffffffc0204416:	84b2                	mv	s1,a2
    proc = alloc_proc(); // 本质上是用kmlloc函数分配了一块内存空间，然后将proc指向这块内存空间
ffffffffc0204418:	df5ff0ef          	jal	ra,ffffffffc020420c <alloc_proc>
ffffffffc020441c:	842a                	mv	s0,a0
    if (proc == NULL)
ffffffffc020441e:	22050363          	beqz	a0,ffffffffc0204644 <do_fork+0x24e>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204422:	4509                	li	a0,2
ffffffffc0204424:	f9efd0ef          	jal	ra,ffffffffc0201bc2 <alloc_pages>
    if (page != NULL)
ffffffffc0204428:	1e050c63          	beqz	a0,ffffffffc0204620 <do_fork+0x22a>
    return page - pages + nbase;
ffffffffc020442c:	00012797          	auipc	a5,0x12
ffffffffc0204430:	0dc78793          	addi	a5,a5,220 # ffffffffc0216508 <pages>
ffffffffc0204434:	6394                	ld	a3,0(a5)
ffffffffc0204436:	00003797          	auipc	a5,0x3
ffffffffc020443a:	c3278793          	addi	a5,a5,-974 # ffffffffc0207068 <nbase>
    return KADDR(page2pa(page));
ffffffffc020443e:	00012717          	auipc	a4,0x12
ffffffffc0204442:	05a70713          	addi	a4,a4,90 # ffffffffc0216498 <npage>
    return page - pages + nbase;
ffffffffc0204446:	40d506b3          	sub	a3,a0,a3
ffffffffc020444a:	6388                	ld	a0,0(a5)
ffffffffc020444c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020444e:	57fd                	li	a5,-1
ffffffffc0204450:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204452:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0204454:	83b1                	srli	a5,a5,0xc
ffffffffc0204456:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204458:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020445a:	1ee7f763          	bleu	a4,a5,ffffffffc0204648 <do_fork+0x252>
    assert(current->mm == NULL);
ffffffffc020445e:	00012797          	auipc	a5,0x12
ffffffffc0204462:	05278793          	addi	a5,a5,82 # ffffffffc02164b0 <current>
ffffffffc0204466:	639c                	ld	a5,0(a5)
ffffffffc0204468:	00012717          	auipc	a4,0x12
ffffffffc020446c:	09070713          	addi	a4,a4,144 # ffffffffc02164f8 <va_pa_offset>
ffffffffc0204470:	6318                	ld	a4,0(a4)
ffffffffc0204472:	779c                	ld	a5,40(a5)
ffffffffc0204474:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204476:	e814                	sd	a3,16(s0)
    assert(current->mm == NULL);
ffffffffc0204478:	1e079463          	bnez	a5,ffffffffc0204660 <do_fork+0x26a>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc020447c:	6789                	lui	a5,0x2
ffffffffc020447e:	ee078793          	addi	a5,a5,-288 # 1ee0 <BASE_ADDRESS-0xffffffffc01fe120>
ffffffffc0204482:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204484:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204486:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0204488:	87b6                	mv	a5,a3
ffffffffc020448a:	12048893          	addi	a7,s1,288
ffffffffc020448e:	00063803          	ld	a6,0(a2)
ffffffffc0204492:	6608                	ld	a0,8(a2)
ffffffffc0204494:	6a0c                	ld	a1,16(a2)
ffffffffc0204496:	6e18                	ld	a4,24(a2)
ffffffffc0204498:	0107b023          	sd	a6,0(a5)
ffffffffc020449c:	e788                	sd	a0,8(a5)
ffffffffc020449e:	eb8c                	sd	a1,16(a5)
ffffffffc02044a0:	ef98                	sd	a4,24(a5)
ffffffffc02044a2:	02060613          	addi	a2,a2,32
ffffffffc02044a6:	02078793          	addi	a5,a5,32
ffffffffc02044aa:	ff1612e3          	bne	a2,a7,ffffffffc020448e <do_fork+0x98>
    proc->tf->gpr.a0 = 0;
ffffffffc02044ae:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02044b2:	10090d63          	beqz	s2,ffffffffc02045cc <do_fork+0x1d6>
ffffffffc02044b6:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;    // 返回值地址为forkret函数的入口
ffffffffc02044ba:	00000797          	auipc	a5,0x0
ffffffffc02044be:	db678793          	addi	a5,a5,-586 # ffffffffc0204270 <forkret>
ffffffffc02044c2:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf); // 上下文的栈顶为trapframe的地址
ffffffffc02044c4:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02044c6:	100027f3          	csrr	a5,sstatus
ffffffffc02044ca:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02044cc:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02044ce:	10079e63          	bnez	a5,ffffffffc02045ea <do_fork+0x1f4>
    if (++last_pid >= MAX_PID)
ffffffffc02044d2:	00007797          	auipc	a5,0x7
ffffffffc02044d6:	b8678793          	addi	a5,a5,-1146 # ffffffffc020b058 <last_pid.1575>
ffffffffc02044da:	439c                	lw	a5,0(a5)
ffffffffc02044dc:	6709                	lui	a4,0x2
ffffffffc02044de:	0017851b          	addiw	a0,a5,1
ffffffffc02044e2:	00007697          	auipc	a3,0x7
ffffffffc02044e6:	b6a6ab23          	sw	a0,-1162(a3) # ffffffffc020b058 <last_pid.1575>
ffffffffc02044ea:	12e55163          	ble	a4,a0,ffffffffc020460c <do_fork+0x216>
    if (last_pid >= next_safe)
ffffffffc02044ee:	00007797          	auipc	a5,0x7
ffffffffc02044f2:	b6e78793          	addi	a5,a5,-1170 # ffffffffc020b05c <next_safe.1574>
ffffffffc02044f6:	439c                	lw	a5,0(a5)
ffffffffc02044f8:	00012497          	auipc	s1,0x12
ffffffffc02044fc:	0f848493          	addi	s1,s1,248 # ffffffffc02165f0 <proc_list>
ffffffffc0204500:	06f54063          	blt	a0,a5,ffffffffc0204560 <do_fork+0x16a>
        next_safe = MAX_PID;
ffffffffc0204504:	6789                	lui	a5,0x2
ffffffffc0204506:	00007717          	auipc	a4,0x7
ffffffffc020450a:	b4f72b23          	sw	a5,-1194(a4) # ffffffffc020b05c <next_safe.1574>
ffffffffc020450e:	4581                	li	a1,0
ffffffffc0204510:	87aa                	mv	a5,a0
ffffffffc0204512:	00012497          	auipc	s1,0x12
ffffffffc0204516:	0de48493          	addi	s1,s1,222 # ffffffffc02165f0 <proc_list>
    repeat:
ffffffffc020451a:	6889                	lui	a7,0x2
ffffffffc020451c:	882e                	mv	a6,a1
ffffffffc020451e:	6609                	lui	a2,0x2
        le = list; // le等于线程的链表头
ffffffffc0204520:	00012697          	auipc	a3,0x12
ffffffffc0204524:	0d068693          	addi	a3,a3,208 # ffffffffc02165f0 <proc_list>
ffffffffc0204528:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list)
ffffffffc020452a:	00968f63          	beq	a3,s1,ffffffffc0204548 <do_fork+0x152>
            if (proc->pid == last_pid)
ffffffffc020452e:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0204532:	08e78863          	beq	a5,a4,ffffffffc02045c2 <do_fork+0x1cc>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0204536:	fee7d9e3          	ble	a4,a5,ffffffffc0204528 <do_fork+0x132>
ffffffffc020453a:	fec757e3          	ble	a2,a4,ffffffffc0204528 <do_fork+0x132>
ffffffffc020453e:	6694                	ld	a3,8(a3)
ffffffffc0204540:	863a                	mv	a2,a4
ffffffffc0204542:	4805                	li	a6,1
        while ((le = list_next(le)) != list)
ffffffffc0204544:	fe9695e3          	bne	a3,s1,ffffffffc020452e <do_fork+0x138>
ffffffffc0204548:	c591                	beqz	a1,ffffffffc0204554 <do_fork+0x15e>
ffffffffc020454a:	00007717          	auipc	a4,0x7
ffffffffc020454e:	b0f72723          	sw	a5,-1266(a4) # ffffffffc020b058 <last_pid.1575>
ffffffffc0204552:	853e                	mv	a0,a5
ffffffffc0204554:	00080663          	beqz	a6,ffffffffc0204560 <do_fork+0x16a>
ffffffffc0204558:	00007797          	auipc	a5,0x7
ffffffffc020455c:	b0c7a223          	sw	a2,-1276(a5) # ffffffffc020b05c <next_safe.1574>
        proc->pid = get_pid(); // 分配一个新的不重复的pid
ffffffffc0204560:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204562:	45a9                	li	a1,10
ffffffffc0204564:	2501                	sext.w	a0,a0
ffffffffc0204566:	4cc000ef          	jal	ra,ffffffffc0204a32 <hash32>
ffffffffc020456a:	1502                	slli	a0,a0,0x20
ffffffffc020456c:	0000e797          	auipc	a5,0xe
ffffffffc0204570:	ef478793          	addi	a5,a5,-268 # ffffffffc0212460 <hash_list>
ffffffffc0204574:	8171                	srli	a0,a0,0x1c
ffffffffc0204576:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204578:	6510                	ld	a2,8(a0)
ffffffffc020457a:	0d840793          	addi	a5,s0,216
ffffffffc020457e:	6494                	ld	a3,8(s1)
        nr_process++;
ffffffffc0204580:	0009a703          	lw	a4,0(s3)
    prev->next = next->prev = elm;
ffffffffc0204584:	e21c                	sd	a5,0(a2)
ffffffffc0204586:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc0204588:	f070                	sd	a2,224(s0)
        list_add(&proc_list, &(proc->list_link));
ffffffffc020458a:	0c840793          	addi	a5,s0,200
    elm->prev = prev;
ffffffffc020458e:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0204590:	e29c                	sd	a5,0(a3)
        nr_process++;
ffffffffc0204592:	2705                	addiw	a4,a4,1
ffffffffc0204594:	00012617          	auipc	a2,0x12
ffffffffc0204598:	06f63223          	sd	a5,100(a2) # ffffffffc02165f8 <proc_list+0x8>
    elm->next = next;
ffffffffc020459c:	e874                	sd	a3,208(s0)
    elm->prev = prev;
ffffffffc020459e:	e464                	sd	s1,200(s0)
ffffffffc02045a0:	00012797          	auipc	a5,0x12
ffffffffc02045a4:	f2e7a423          	sw	a4,-216(a5) # ffffffffc02164c8 <nr_process>
    if (flag)
ffffffffc02045a8:	06091963          	bnez	s2,ffffffffc020461a <do_fork+0x224>
    wakeup_proc(proc); // 设置proc的state为PROC_RUNNABLE，使得进程可以被调度执行
ffffffffc02045ac:	8522                	mv	a0,s0
ffffffffc02045ae:	3b8000ef          	jal	ra,ffffffffc0204966 <wakeup_proc>
    ret = proc->pid;
ffffffffc02045b2:	4048                	lw	a0,4(s0)
}
ffffffffc02045b4:	70a2                	ld	ra,40(sp)
ffffffffc02045b6:	7402                	ld	s0,32(sp)
ffffffffc02045b8:	64e2                	ld	s1,24(sp)
ffffffffc02045ba:	6942                	ld	s2,16(sp)
ffffffffc02045bc:	69a2                	ld	s3,8(sp)
ffffffffc02045be:	6145                	addi	sp,sp,48
ffffffffc02045c0:	8082                	ret
                if (++last_pid >= next_safe)
ffffffffc02045c2:	2785                	addiw	a5,a5,1
ffffffffc02045c4:	06c7d963          	ble	a2,a5,ffffffffc0204636 <do_fork+0x240>
ffffffffc02045c8:	4585                	li	a1,1
ffffffffc02045ca:	bfb9                	j	ffffffffc0204528 <do_fork+0x132>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02045cc:	8936                	mv	s2,a3
ffffffffc02045ce:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;    // 返回值地址为forkret函数的入口
ffffffffc02045d2:	00000797          	auipc	a5,0x0
ffffffffc02045d6:	c9e78793          	addi	a5,a5,-866 # ffffffffc0204270 <forkret>
ffffffffc02045da:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf); // 上下文的栈顶为trapframe的地址
ffffffffc02045dc:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02045de:	100027f3          	csrr	a5,sstatus
ffffffffc02045e2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02045e4:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02045e6:	ee0786e3          	beqz	a5,ffffffffc02044d2 <do_fork+0xdc>
        intr_disable();
ffffffffc02045ea:	feffb0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
    if (++last_pid >= MAX_PID)
ffffffffc02045ee:	00007797          	auipc	a5,0x7
ffffffffc02045f2:	a6a78793          	addi	a5,a5,-1430 # ffffffffc020b058 <last_pid.1575>
ffffffffc02045f6:	439c                	lw	a5,0(a5)
ffffffffc02045f8:	6709                	lui	a4,0x2
        return 1;
ffffffffc02045fa:	4905                	li	s2,1
ffffffffc02045fc:	0017851b          	addiw	a0,a5,1
ffffffffc0204600:	00007697          	auipc	a3,0x7
ffffffffc0204604:	a4a6ac23          	sw	a0,-1448(a3) # ffffffffc020b058 <last_pid.1575>
ffffffffc0204608:	eee543e3          	blt	a0,a4,ffffffffc02044ee <do_fork+0xf8>
        last_pid = 1;
ffffffffc020460c:	4785                	li	a5,1
ffffffffc020460e:	00007717          	auipc	a4,0x7
ffffffffc0204612:	a4f72523          	sw	a5,-1462(a4) # ffffffffc020b058 <last_pid.1575>
ffffffffc0204616:	4505                	li	a0,1
ffffffffc0204618:	b5f5                	j	ffffffffc0204504 <do_fork+0x10e>
        intr_enable();
ffffffffc020461a:	fb9fb0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
ffffffffc020461e:	b779                	j	ffffffffc02045ac <do_fork+0x1b6>
    kfree(proc);
ffffffffc0204620:	8522                	mv	a0,s0
ffffffffc0204622:	c60fd0ef          	jal	ra,ffffffffc0201a82 <kfree>
}
ffffffffc0204626:	70a2                	ld	ra,40(sp)
ffffffffc0204628:	7402                	ld	s0,32(sp)
ffffffffc020462a:	64e2                	ld	s1,24(sp)
ffffffffc020462c:	6942                	ld	s2,16(sp)
ffffffffc020462e:	69a2                	ld	s3,8(sp)
    return -E_NO_MEM;
ffffffffc0204630:	5571                	li	a0,-4
}
ffffffffc0204632:	6145                	addi	sp,sp,48
ffffffffc0204634:	8082                	ret
                    if (last_pid >= MAX_PID)
ffffffffc0204636:	0117c363          	blt	a5,a7,ffffffffc020463c <do_fork+0x246>
                        last_pid = 1;
ffffffffc020463a:	4785                	li	a5,1
                    goto repeat;
ffffffffc020463c:	4585                	li	a1,1
ffffffffc020463e:	bdf9                	j	ffffffffc020451c <do_fork+0x126>
    int ret = -E_NO_FREE_PROC;
ffffffffc0204640:	556d                	li	a0,-5
ffffffffc0204642:	bf8d                	j	ffffffffc02045b4 <do_fork+0x1be>
    ret = -E_NO_MEM;
ffffffffc0204644:	5571                	li	a0,-4
ffffffffc0204646:	b7bd                	j	ffffffffc02045b4 <do_fork+0x1be>
ffffffffc0204648:	00001617          	auipc	a2,0x1
ffffffffc020464c:	68060613          	addi	a2,a2,1664 # ffffffffc0205cc8 <default_pmm_manager+0x50>
ffffffffc0204650:	08b00593          	li	a1,139
ffffffffc0204654:	00001517          	auipc	a0,0x1
ffffffffc0204658:	69c50513          	addi	a0,a0,1692 # ffffffffc0205cf0 <default_pmm_manager+0x78>
ffffffffc020465c:	df5fb0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(current->mm == NULL);
ffffffffc0204660:	00002697          	auipc	a3,0x2
ffffffffc0204664:	62868693          	addi	a3,a3,1576 # ffffffffc0206c88 <default_pmm_manager+0x1010>
ffffffffc0204668:	00001617          	auipc	a2,0x1
ffffffffc020466c:	27860613          	addi	a2,a2,632 # ffffffffc02058e0 <commands+0x870>
ffffffffc0204670:	14200593          	li	a1,322
ffffffffc0204674:	00002517          	auipc	a0,0x2
ffffffffc0204678:	62c50513          	addi	a0,a0,1580 # ffffffffc0206ca0 <default_pmm_manager+0x1028>
ffffffffc020467c:	dd5fb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0204680 <kernel_thread>:
{
ffffffffc0204680:	7129                	addi	sp,sp,-320
ffffffffc0204682:	fa22                	sd	s0,304(sp)
ffffffffc0204684:	f626                	sd	s1,296(sp)
ffffffffc0204686:	f24a                	sd	s2,288(sp)
ffffffffc0204688:	84ae                	mv	s1,a1
ffffffffc020468a:	892a                	mv	s2,a0
ffffffffc020468c:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020468e:	4581                	li	a1,0
ffffffffc0204690:	12000613          	li	a2,288
ffffffffc0204694:	850a                	mv	a0,sp
{
ffffffffc0204696:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204698:	049000ef          	jal	ra,ffffffffc0204ee0 <memset>
    tf.gpr.s0 = (uintptr_t)fn;  // s0 寄存器保存函数指针
ffffffffc020469c:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg; // s1 寄存器保存函数参数
ffffffffc020469e:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02046a0:	100027f3          	csrr	a5,sstatus
ffffffffc02046a4:	edd7f793          	andi	a5,a5,-291
ffffffffc02046a8:	1207e793          	ori	a5,a5,288
ffffffffc02046ac:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02046ae:	860a                	mv	a2,sp
ffffffffc02046b0:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02046b4:	00000797          	auipc	a5,0x0
ffffffffc02046b8:	b5078793          	addi	a5,a5,-1200 # ffffffffc0204204 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02046bc:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02046be:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02046c0:	d37ff0ef          	jal	ra,ffffffffc02043f6 <do_fork>
}
ffffffffc02046c4:	70f2                	ld	ra,312(sp)
ffffffffc02046c6:	7452                	ld	s0,304(sp)
ffffffffc02046c8:	74b2                	ld	s1,296(sp)
ffffffffc02046ca:	7912                	ld	s2,288(sp)
ffffffffc02046cc:	6131                	addi	sp,sp,320
ffffffffc02046ce:	8082                	ret

ffffffffc02046d0 <do_exit>:
{
ffffffffc02046d0:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc02046d2:	00002617          	auipc	a2,0x2
ffffffffc02046d6:	59e60613          	addi	a2,a2,1438 # ffffffffc0206c70 <default_pmm_manager+0xff8>
ffffffffc02046da:	1be00593          	li	a1,446
ffffffffc02046de:	00002517          	auipc	a0,0x2
ffffffffc02046e2:	5c250513          	addi	a0,a0,1474 # ffffffffc0206ca0 <default_pmm_manager+0x1028>
{
ffffffffc02046e6:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc02046e8:	d69fb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02046ec <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc02046ec:	00012797          	auipc	a5,0x12
ffffffffc02046f0:	f0478793          	addi	a5,a5,-252 # ffffffffc02165f0 <proc_list>
// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
// 意思是说，idleproc是第零个内核线程，它的pid是0，它的状态是“准备工作”，它的内核栈是bootstack，它的上下文是空的，它的页目录表是boot_cr3，它的线程控制块的名字是“idle”。
// idleproc就是内核当前正在执行的线程，且idleproc是第0个内核线程
void proc_init(void)
{
ffffffffc02046f4:	1101                	addi	sp,sp,-32
ffffffffc02046f6:	00012717          	auipc	a4,0x12
ffffffffc02046fa:	f0f73123          	sd	a5,-254(a4) # ffffffffc02165f8 <proc_list+0x8>
ffffffffc02046fe:	00012717          	auipc	a4,0x12
ffffffffc0204702:	eef73923          	sd	a5,-270(a4) # ffffffffc02165f0 <proc_list>
ffffffffc0204706:	ec06                	sd	ra,24(sp)
ffffffffc0204708:	e822                	sd	s0,16(sp)
ffffffffc020470a:	e426                	sd	s1,8(sp)
ffffffffc020470c:	e04a                	sd	s2,0(sp)
ffffffffc020470e:	0000e797          	auipc	a5,0xe
ffffffffc0204712:	d5278793          	addi	a5,a5,-686 # ffffffffc0212460 <hash_list>
ffffffffc0204716:	00012717          	auipc	a4,0x12
ffffffffc020471a:	d4a70713          	addi	a4,a4,-694 # ffffffffc0216460 <name.1565>
ffffffffc020471e:	e79c                	sd	a5,8(a5)
ffffffffc0204720:	e39c                	sd	a5,0(a5)
ffffffffc0204722:	07c1                	addi	a5,a5,16
    int i;
    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0204724:	fee79de3          	bne	a5,a4,ffffffffc020471e <proc_init+0x32>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc0204728:	ae5ff0ef          	jal	ra,ffffffffc020420c <alloc_proc>
ffffffffc020472c:	00012797          	auipc	a5,0x12
ffffffffc0204730:	d8a7b623          	sd	a0,-628(a5) # ffffffffc02164b8 <idleproc>
ffffffffc0204734:	00012417          	auipc	s0,0x12
ffffffffc0204738:	d8440413          	addi	s0,s0,-636 # ffffffffc02164b8 <idleproc>
ffffffffc020473c:	12050a63          	beqz	a0,ffffffffc0204870 <proc_init+0x184>
    {
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int *)kmalloc(sizeof(struct context));
ffffffffc0204740:	07000513          	li	a0,112
ffffffffc0204744:	a82fd0ef          	jal	ra,ffffffffc02019c6 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));                                            // 清空context_mem内存区域
ffffffffc0204748:	07000613          	li	a2,112
ffffffffc020474c:	4581                	li	a1,0
    int *context_mem = (int *)kmalloc(sizeof(struct context));
ffffffffc020474e:	84aa                	mv	s1,a0
    memset(context_mem, 0, sizeof(struct context));                                            // 清空context_mem内存区域
ffffffffc0204750:	790000ef          	jal	ra,ffffffffc0204ee0 <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context)); // 比较context_mem和idleproc->context的内容是否相同
ffffffffc0204754:	6008                	ld	a0,0(s0)
ffffffffc0204756:	85a6                	mv	a1,s1
ffffffffc0204758:	07000613          	li	a2,112
ffffffffc020475c:	03050513          	addi	a0,a0,48
ffffffffc0204760:	7aa000ef          	jal	ra,ffffffffc0204f0a <memcmp>
ffffffffc0204764:	892a                	mv	s2,a0

    int *proc_name_mem = (int *)kmalloc(PROC_NAME_LEN);
ffffffffc0204766:	453d                	li	a0,15
ffffffffc0204768:	a5efd0ef          	jal	ra,ffffffffc02019c6 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc020476c:	463d                	li	a2,15
ffffffffc020476e:	4581                	li	a1,0
    int *proc_name_mem = (int *)kmalloc(PROC_NAME_LEN);
ffffffffc0204770:	84aa                	mv	s1,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204772:	76e000ef          	jal	ra,ffffffffc0204ee0 <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc0204776:	6008                	ld	a0,0(s0)
ffffffffc0204778:	463d                	li	a2,15
ffffffffc020477a:	85a6                	mv	a1,s1
ffffffffc020477c:	0b450513          	addi	a0,a0,180
ffffffffc0204780:	78a000ef          	jal	ra,ffffffffc0204f0a <memcmp>

    if (idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0 && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag)
ffffffffc0204784:	601c                	ld	a5,0(s0)
ffffffffc0204786:	00012717          	auipc	a4,0x12
ffffffffc020478a:	d7a70713          	addi	a4,a4,-646 # ffffffffc0216500 <boot_cr3>
ffffffffc020478e:	6318                	ld	a4,0(a4)
ffffffffc0204790:	77d4                	ld	a3,168(a5)
ffffffffc0204792:	08e68e63          	beq	a3,a4,ffffffffc020482e <proc_init+0x142>
    {
        cprintf("alloc_proc() correct!\n");
    }

    idleproc->pid = 0;                       // 给了idleproc合法的身份证号–0，这名正言顺地表明了idleproc是第0个内核线程。通常可以通过pid的赋值来表示线程的创建和身份确定
    idleproc->state = PROC_RUNNABLE;         // 改变了idleproc的状态，使得它从“出生”转到了“准备工作”
ffffffffc0204796:	4709                	li	a4,2
ffffffffc0204798:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack; // idleproc所使用的内核栈的起始地址。需要注意以后的其他线程的内核栈都需要通过分配获得
ffffffffc020479a:	00004717          	auipc	a4,0x4
ffffffffc020479e:	86670713          	addi	a4,a4,-1946 # ffffffffc0208000 <bootstack>
ffffffffc02047a2:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;              // 如果此标志位为1，马上调用schedule函数切换给其他进程给CPU
ffffffffc02047a4:	4705                	li	a4,1
ffffffffc02047a6:	cf98                	sw	a4,24(a5)
    set_proc_name(idleproc, "idle");
ffffffffc02047a8:	00002597          	auipc	a1,0x2
ffffffffc02047ac:	59858593          	addi	a1,a1,1432 # ffffffffc0206d40 <default_pmm_manager+0x10c8>
ffffffffc02047b0:	853e                	mv	a0,a5
ffffffffc02047b2:	acfff0ef          	jal	ra,ffffffffc0204280 <set_proc_name>
    nr_process++;
ffffffffc02047b6:	00012797          	auipc	a5,0x12
ffffffffc02047ba:	d1278793          	addi	a5,a5,-750 # ffffffffc02164c8 <nr_process>
ffffffffc02047be:	439c                	lw	a5,0(a5)

    /* 设置当前运行的线程为idleproc */
    current = idleproc;
ffffffffc02047c0:	6018                	ld	a4,0(s0)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02047c2:	4601                	li	a2,0
    nr_process++;
ffffffffc02047c4:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02047c6:	00002597          	auipc	a1,0x2
ffffffffc02047ca:	58258593          	addi	a1,a1,1410 # ffffffffc0206d48 <default_pmm_manager+0x10d0>
ffffffffc02047ce:	00000517          	auipc	a0,0x0
ffffffffc02047d2:	b0c50513          	addi	a0,a0,-1268 # ffffffffc02042da <init_main>
    nr_process++;
ffffffffc02047d6:	00012697          	auipc	a3,0x12
ffffffffc02047da:	cef6a923          	sw	a5,-782(a3) # ffffffffc02164c8 <nr_process>
    current = idleproc;
ffffffffc02047de:	00012797          	auipc	a5,0x12
ffffffffc02047e2:	cce7b923          	sd	a4,-814(a5) # ffffffffc02164b0 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02047e6:	e9bff0ef          	jal	ra,ffffffffc0204680 <kernel_thread>
    if (pid <= 0)
ffffffffc02047ea:	0ca05f63          	blez	a0,ffffffffc02048c8 <proc_init+0x1dc>
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid); // 根据pid找到initproc
ffffffffc02047ee:	badff0ef          	jal	ra,ffffffffc020439a <find_proc>
    set_proc_name(initproc, "init");
ffffffffc02047f2:	00002597          	auipc	a1,0x2
ffffffffc02047f6:	58658593          	addi	a1,a1,1414 # ffffffffc0206d78 <default_pmm_manager+0x1100>
    initproc = find_proc(pid); // 根据pid找到initproc
ffffffffc02047fa:	00012797          	auipc	a5,0x12
ffffffffc02047fe:	cca7b323          	sd	a0,-826(a5) # ffffffffc02164c0 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0204802:	a7fff0ef          	jal	ra,ffffffffc0204280 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204806:	601c                	ld	a5,0(s0)
ffffffffc0204808:	c3c5                	beqz	a5,ffffffffc02048a8 <proc_init+0x1bc>
ffffffffc020480a:	43dc                	lw	a5,4(a5)
ffffffffc020480c:	efd1                	bnez	a5,ffffffffc02048a8 <proc_init+0x1bc>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020480e:	00012797          	auipc	a5,0x12
ffffffffc0204812:	cb278793          	addi	a5,a5,-846 # ffffffffc02164c0 <initproc>
ffffffffc0204816:	639c                	ld	a5,0(a5)
ffffffffc0204818:	cba5                	beqz	a5,ffffffffc0204888 <proc_init+0x19c>
ffffffffc020481a:	43d8                	lw	a4,4(a5)
ffffffffc020481c:	4785                	li	a5,1
ffffffffc020481e:	06f71563          	bne	a4,a5,ffffffffc0204888 <proc_init+0x19c>
}
ffffffffc0204822:	60e2                	ld	ra,24(sp)
ffffffffc0204824:	6442                	ld	s0,16(sp)
ffffffffc0204826:	64a2                	ld	s1,8(sp)
ffffffffc0204828:	6902                	ld	s2,0(sp)
ffffffffc020482a:	6105                	addi	sp,sp,32
ffffffffc020482c:	8082                	ret
    if (idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0 && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag)
ffffffffc020482e:	73d8                	ld	a4,160(a5)
ffffffffc0204830:	f33d                	bnez	a4,ffffffffc0204796 <proc_init+0xaa>
ffffffffc0204832:	f60912e3          	bnez	s2,ffffffffc0204796 <proc_init+0xaa>
ffffffffc0204836:	6394                	ld	a3,0(a5)
ffffffffc0204838:	577d                	li	a4,-1
ffffffffc020483a:	1702                	slli	a4,a4,0x20
ffffffffc020483c:	f4e69de3          	bne	a3,a4,ffffffffc0204796 <proc_init+0xaa>
ffffffffc0204840:	4798                	lw	a4,8(a5)
ffffffffc0204842:	fb31                	bnez	a4,ffffffffc0204796 <proc_init+0xaa>
ffffffffc0204844:	6b98                	ld	a4,16(a5)
ffffffffc0204846:	fb21                	bnez	a4,ffffffffc0204796 <proc_init+0xaa>
ffffffffc0204848:	4f98                	lw	a4,24(a5)
ffffffffc020484a:	2701                	sext.w	a4,a4
ffffffffc020484c:	f729                	bnez	a4,ffffffffc0204796 <proc_init+0xaa>
ffffffffc020484e:	7398                	ld	a4,32(a5)
ffffffffc0204850:	f339                	bnez	a4,ffffffffc0204796 <proc_init+0xaa>
ffffffffc0204852:	7798                	ld	a4,40(a5)
ffffffffc0204854:	f329                	bnez	a4,ffffffffc0204796 <proc_init+0xaa>
ffffffffc0204856:	0b07a703          	lw	a4,176(a5)
ffffffffc020485a:	8f49                	or	a4,a4,a0
ffffffffc020485c:	2701                	sext.w	a4,a4
ffffffffc020485e:	ff05                	bnez	a4,ffffffffc0204796 <proc_init+0xaa>
        cprintf("alloc_proc() correct!\n");
ffffffffc0204860:	00002517          	auipc	a0,0x2
ffffffffc0204864:	4c850513          	addi	a0,a0,1224 # ffffffffc0206d28 <default_pmm_manager+0x10b0>
ffffffffc0204868:	927fb0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc020486c:	601c                	ld	a5,0(s0)
ffffffffc020486e:	b725                	j	ffffffffc0204796 <proc_init+0xaa>
        panic("cannot alloc idleproc.\n");
ffffffffc0204870:	00002617          	auipc	a2,0x2
ffffffffc0204874:	4a060613          	addi	a2,a2,1184 # ffffffffc0206d10 <default_pmm_manager+0x1098>
ffffffffc0204878:	1da00593          	li	a1,474
ffffffffc020487c:	00002517          	auipc	a0,0x2
ffffffffc0204880:	42450513          	addi	a0,a0,1060 # ffffffffc0206ca0 <default_pmm_manager+0x1028>
ffffffffc0204884:	bcdfb0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204888:	00002697          	auipc	a3,0x2
ffffffffc020488c:	52068693          	addi	a3,a3,1312 # ffffffffc0206da8 <default_pmm_manager+0x1130>
ffffffffc0204890:	00001617          	auipc	a2,0x1
ffffffffc0204894:	05060613          	addi	a2,a2,80 # ffffffffc02058e0 <commands+0x870>
ffffffffc0204898:	1ff00593          	li	a1,511
ffffffffc020489c:	00002517          	auipc	a0,0x2
ffffffffc02048a0:	40450513          	addi	a0,a0,1028 # ffffffffc0206ca0 <default_pmm_manager+0x1028>
ffffffffc02048a4:	badfb0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02048a8:	00002697          	auipc	a3,0x2
ffffffffc02048ac:	4d868693          	addi	a3,a3,1240 # ffffffffc0206d80 <default_pmm_manager+0x1108>
ffffffffc02048b0:	00001617          	auipc	a2,0x1
ffffffffc02048b4:	03060613          	addi	a2,a2,48 # ffffffffc02058e0 <commands+0x870>
ffffffffc02048b8:	1fe00593          	li	a1,510
ffffffffc02048bc:	00002517          	auipc	a0,0x2
ffffffffc02048c0:	3e450513          	addi	a0,a0,996 # ffffffffc0206ca0 <default_pmm_manager+0x1028>
ffffffffc02048c4:	b8dfb0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("create init_main failed.\n");
ffffffffc02048c8:	00002617          	auipc	a2,0x2
ffffffffc02048cc:	49060613          	addi	a2,a2,1168 # ffffffffc0206d58 <default_pmm_manager+0x10e0>
ffffffffc02048d0:	1f800593          	li	a1,504
ffffffffc02048d4:	00002517          	auipc	a0,0x2
ffffffffc02048d8:	3cc50513          	addi	a0,a0,972 # ffffffffc0206ca0 <default_pmm_manager+0x1028>
ffffffffc02048dc:	b75fb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02048e0 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
// 执行cpu_idle函数让idleproc让出CPU资源
void cpu_idle(void)
{
ffffffffc02048e0:	1141                	addi	sp,sp,-16
ffffffffc02048e2:	e022                	sd	s0,0(sp)
ffffffffc02048e4:	e406                	sd	ra,8(sp)
ffffffffc02048e6:	00012417          	auipc	s0,0x12
ffffffffc02048ea:	bca40413          	addi	s0,s0,-1078 # ffffffffc02164b0 <current>
    while (1)
    {
        // 判断当前内核线程idleproc的need_resched是否不为0
        if (current->need_resched)
ffffffffc02048ee:	6018                	ld	a4,0(s0)
ffffffffc02048f0:	4f1c                	lw	a5,24(a4)
ffffffffc02048f2:	2781                	sext.w	a5,a5
ffffffffc02048f4:	dff5                	beqz	a5,ffffffffc02048f0 <cpu_idle+0x10>
        {
            // 调用schedule函数找其他处于“就绪”态的进程执行。
            schedule();
ffffffffc02048f6:	0a2000ef          	jal	ra,ffffffffc0204998 <schedule>
ffffffffc02048fa:	bfd5                	j	ffffffffc02048ee <cpu_idle+0xe>

ffffffffc02048fc <switch_to>:
# void switch_to(struct proc_struct* from, struct proc_struct* to)
# 将需要保存的寄存器进行保存和调换。其中的a0和a1是RISC-V 架构中通用寄存器，它们用于传递参数，也就是说a0指向原进程，a1指向目的进程。
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc02048fc:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204900:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204904:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204906:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204908:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc020490c:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204910:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204914:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204918:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc020491c:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204920:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204924:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204928:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc020492c:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204930:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204934:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204938:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc020493a:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc020493c:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204940:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204944:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204948:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc020494c:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204950:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204954:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204958:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc020495c:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204960:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204964:	8082                	ret

ffffffffc0204966 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204966:	411c                	lw	a5,0(a0)
ffffffffc0204968:	4705                	li	a4,1
ffffffffc020496a:	37f9                	addiw	a5,a5,-2
ffffffffc020496c:	00f77563          	bleu	a5,a4,ffffffffc0204976 <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc0204970:	4789                	li	a5,2
ffffffffc0204972:	c11c                	sw	a5,0(a0)
ffffffffc0204974:	8082                	ret
{
ffffffffc0204976:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204978:	00002697          	auipc	a3,0x2
ffffffffc020497c:	45868693          	addi	a3,a3,1112 # ffffffffc0206dd0 <default_pmm_manager+0x1158>
ffffffffc0204980:	00001617          	auipc	a2,0x1
ffffffffc0204984:	f6060613          	addi	a2,a2,-160 # ffffffffc02058e0 <commands+0x870>
ffffffffc0204988:	45a5                	li	a1,9
ffffffffc020498a:	00002517          	auipc	a0,0x2
ffffffffc020498e:	48650513          	addi	a0,a0,1158 # ffffffffc0206e10 <default_pmm_manager+0x1198>
{
ffffffffc0204992:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204994:	abdfb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0204998 <schedule>:
}

// uCore在实验四中只实现了一个最简单的FIFO调度器，其核心就是schedule函数。
void schedule(void)
{
ffffffffc0204998:	1141                	addi	sp,sp,-16
ffffffffc020499a:	e406                	sd	ra,8(sp)
ffffffffc020499c:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020499e:	100027f3          	csrr	a5,sstatus
ffffffffc02049a2:	8b89                	andi	a5,a5,2
ffffffffc02049a4:	4401                	li	s0,0
ffffffffc02049a6:	e3d1                	bnez	a5,ffffffffc0204a2a <schedule+0x92>
    struct proc_struct *next = NULL; // 下一进程
    // 关闭中断，避免操作共享数据的时候发生中断导致共享数据被修改
    local_intr_save(intr_flag);
    {
        // 设置当前内核线程current->need_resched为0
        current->need_resched = 0;
ffffffffc02049a8:	00012797          	auipc	a5,0x12
ffffffffc02049ac:	b0878793          	addi	a5,a5,-1272 # ffffffffc02164b0 <current>
ffffffffc02049b0:	0007b883          	ld	a7,0(a5)
        // 在proc_list队列中查找下一个处于“就绪”态的线程或进程next；
        // last是否是idle进程(第一个创建的进程),如果是，则从表头开始搜索  否则获取下一链表
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02049b4:	00012797          	auipc	a5,0x12
ffffffffc02049b8:	b0478793          	addi	a5,a5,-1276 # ffffffffc02164b8 <idleproc>
ffffffffc02049bc:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc02049be:	0008ac23          	sw	zero,24(a7) # 2018 <BASE_ADDRESS-0xffffffffc01fdfe8>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02049c2:	04a88e63          	beq	a7,a0,ffffffffc0204a1e <schedule+0x86>
ffffffffc02049c6:	0c888693          	addi	a3,a7,200
ffffffffc02049ca:	00012617          	auipc	a2,0x12
ffffffffc02049ce:	c2660613          	addi	a2,a2,-986 # ffffffffc02165f0 <proc_list>
        le = last;
ffffffffc02049d2:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL; // 下一进程
ffffffffc02049d4:	4581                	li	a1,0
            {
                // 获取下一进程
                next = le2proc(le, list_link);
                // 找到一个可以调度的进程，break
                // 只能找到一个处于“就绪”态的initproc内核线程
                if (next->state == PROC_RUNNABLE)
ffffffffc02049d6:	4809                	li	a6,2
    return listelm->next;
ffffffffc02049d8:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list)
ffffffffc02049da:	00c78863          	beq	a5,a2,ffffffffc02049ea <schedule+0x52>
                if (next->state == PROC_RUNNABLE)
ffffffffc02049de:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02049e2:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE)
ffffffffc02049e6:	01070463          	beq	a4,a6,ffffffffc02049ee <schedule+0x56>
                {
                    break;
                }
            }
        } while (le != last);
ffffffffc02049ea:	fef697e3          	bne	a3,a5,ffffffffc02049d8 <schedule+0x40>
        // 如果没有找到可调度的进程
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc02049ee:	c589                	beqz	a1,ffffffffc02049f8 <schedule+0x60>
ffffffffc02049f0:	4198                	lw	a4,0(a1)
ffffffffc02049f2:	4789                	li	a5,2
ffffffffc02049f4:	00f70e63          	beq	a4,a5,ffffffffc0204a10 <schedule+0x78>
        {
            next = idleproc;
        }
        next->runs++; // 运行次数加一
ffffffffc02049f8:	451c                	lw	a5,8(a0)
ffffffffc02049fa:	2785                	addiw	a5,a5,1
ffffffffc02049fc:	c51c                	sw	a5,8(a0)
        // 找到这样的进程后，就调用proc_run函数，保存当前进程current的执行现场（进程上下文），恢复新进程的执行现场，完成进程切换。
        if (next != current)
ffffffffc02049fe:	00a88463          	beq	a7,a0,ffffffffc0204a06 <schedule+0x6e>
        {
            proc_run(next);
ffffffffc0204a02:	92bff0ef          	jal	ra,ffffffffc020432c <proc_run>
    if (flag)
ffffffffc0204a06:	e419                	bnez	s0,ffffffffc0204a14 <schedule+0x7c>
        }
    }
    // 恢复中断
    local_intr_restore(intr_flag);
}
ffffffffc0204a08:	60a2                	ld	ra,8(sp)
ffffffffc0204a0a:	6402                	ld	s0,0(sp)
ffffffffc0204a0c:	0141                	addi	sp,sp,16
ffffffffc0204a0e:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc0204a10:	852e                	mv	a0,a1
ffffffffc0204a12:	b7dd                	j	ffffffffc02049f8 <schedule+0x60>
}
ffffffffc0204a14:	6402                	ld	s0,0(sp)
ffffffffc0204a16:	60a2                	ld	ra,8(sp)
ffffffffc0204a18:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0204a1a:	bb9fb06f          	j	ffffffffc02005d2 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204a1e:	00012617          	auipc	a2,0x12
ffffffffc0204a22:	bd260613          	addi	a2,a2,-1070 # ffffffffc02165f0 <proc_list>
ffffffffc0204a26:	86b2                	mv	a3,a2
ffffffffc0204a28:	b76d                	j	ffffffffc02049d2 <schedule+0x3a>
        intr_disable();
ffffffffc0204a2a:	baffb0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
        return 1;
ffffffffc0204a2e:	4405                	li	s0,1
ffffffffc0204a30:	bfa5                	j	ffffffffc02049a8 <schedule+0x10>

ffffffffc0204a32 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204a32:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204a36:	2785                	addiw	a5,a5,1
ffffffffc0204a38:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0204a3c:	02000793          	li	a5,32
ffffffffc0204a40:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0204a44:	00b5553b          	srlw	a0,a0,a1
ffffffffc0204a48:	8082                	ret

ffffffffc0204a4a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204a4a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204a4e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0204a50:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204a54:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204a56:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204a5a:	f022                	sd	s0,32(sp)
ffffffffc0204a5c:	ec26                	sd	s1,24(sp)
ffffffffc0204a5e:	e84a                	sd	s2,16(sp)
ffffffffc0204a60:	f406                	sd	ra,40(sp)
ffffffffc0204a62:	e44e                	sd	s3,8(sp)
ffffffffc0204a64:	84aa                	mv	s1,a0
ffffffffc0204a66:	892e                	mv	s2,a1
ffffffffc0204a68:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204a6c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0204a6e:	03067e63          	bleu	a6,a2,ffffffffc0204aaa <printnum+0x60>
ffffffffc0204a72:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204a74:	00805763          	blez	s0,ffffffffc0204a82 <printnum+0x38>
ffffffffc0204a78:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204a7a:	85ca                	mv	a1,s2
ffffffffc0204a7c:	854e                	mv	a0,s3
ffffffffc0204a7e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204a80:	fc65                	bnez	s0,ffffffffc0204a78 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204a82:	1a02                	slli	s4,s4,0x20
ffffffffc0204a84:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204a88:	00002797          	auipc	a5,0x2
ffffffffc0204a8c:	53078793          	addi	a5,a5,1328 # ffffffffc0206fb8 <error_string+0x38>
ffffffffc0204a90:	9a3e                	add	s4,s4,a5
}
ffffffffc0204a92:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204a94:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204a98:	70a2                	ld	ra,40(sp)
ffffffffc0204a9a:	69a2                	ld	s3,8(sp)
ffffffffc0204a9c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204a9e:	85ca                	mv	a1,s2
ffffffffc0204aa0:	8326                	mv	t1,s1
}
ffffffffc0204aa2:	6942                	ld	s2,16(sp)
ffffffffc0204aa4:	64e2                	ld	s1,24(sp)
ffffffffc0204aa6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204aa8:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204aaa:	03065633          	divu	a2,a2,a6
ffffffffc0204aae:	8722                	mv	a4,s0
ffffffffc0204ab0:	f9bff0ef          	jal	ra,ffffffffc0204a4a <printnum>
ffffffffc0204ab4:	b7f9                	j	ffffffffc0204a82 <printnum+0x38>

ffffffffc0204ab6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204ab6:	7119                	addi	sp,sp,-128
ffffffffc0204ab8:	f4a6                	sd	s1,104(sp)
ffffffffc0204aba:	f0ca                	sd	s2,96(sp)
ffffffffc0204abc:	e8d2                	sd	s4,80(sp)
ffffffffc0204abe:	e4d6                	sd	s5,72(sp)
ffffffffc0204ac0:	e0da                	sd	s6,64(sp)
ffffffffc0204ac2:	fc5e                	sd	s7,56(sp)
ffffffffc0204ac4:	f862                	sd	s8,48(sp)
ffffffffc0204ac6:	f06a                	sd	s10,32(sp)
ffffffffc0204ac8:	fc86                	sd	ra,120(sp)
ffffffffc0204aca:	f8a2                	sd	s0,112(sp)
ffffffffc0204acc:	ecce                	sd	s3,88(sp)
ffffffffc0204ace:	f466                	sd	s9,40(sp)
ffffffffc0204ad0:	ec6e                	sd	s11,24(sp)
ffffffffc0204ad2:	892a                	mv	s2,a0
ffffffffc0204ad4:	84ae                	mv	s1,a1
ffffffffc0204ad6:	8d32                	mv	s10,a2
ffffffffc0204ad8:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204ada:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204adc:	00002a17          	auipc	s4,0x2
ffffffffc0204ae0:	34ca0a13          	addi	s4,s4,844 # ffffffffc0206e28 <default_pmm_manager+0x11b0>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204ae4:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204ae8:	00002c17          	auipc	s8,0x2
ffffffffc0204aec:	498c0c13          	addi	s8,s8,1176 # ffffffffc0206f80 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204af0:	000d4503          	lbu	a0,0(s10) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0204af4:	02500793          	li	a5,37
ffffffffc0204af8:	001d0413          	addi	s0,s10,1
ffffffffc0204afc:	00f50e63          	beq	a0,a5,ffffffffc0204b18 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0204b00:	c521                	beqz	a0,ffffffffc0204b48 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b02:	02500993          	li	s3,37
ffffffffc0204b06:	a011                	j	ffffffffc0204b0a <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0204b08:	c121                	beqz	a0,ffffffffc0204b48 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0204b0a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b0c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204b0e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b10:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204b14:	ff351ae3          	bne	a0,s3,ffffffffc0204b08 <vprintfmt+0x52>
ffffffffc0204b18:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204b1c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204b20:	4981                	li	s3,0
ffffffffc0204b22:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0204b24:	5cfd                	li	s9,-1
ffffffffc0204b26:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b28:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0204b2c:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b2e:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0204b32:	0ff6f693          	andi	a3,a3,255
ffffffffc0204b36:	00140d13          	addi	s10,s0,1
ffffffffc0204b3a:	20d5e563          	bltu	a1,a3,ffffffffc0204d44 <vprintfmt+0x28e>
ffffffffc0204b3e:	068a                	slli	a3,a3,0x2
ffffffffc0204b40:	96d2                	add	a3,a3,s4
ffffffffc0204b42:	4294                	lw	a3,0(a3)
ffffffffc0204b44:	96d2                	add	a3,a3,s4
ffffffffc0204b46:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204b48:	70e6                	ld	ra,120(sp)
ffffffffc0204b4a:	7446                	ld	s0,112(sp)
ffffffffc0204b4c:	74a6                	ld	s1,104(sp)
ffffffffc0204b4e:	7906                	ld	s2,96(sp)
ffffffffc0204b50:	69e6                	ld	s3,88(sp)
ffffffffc0204b52:	6a46                	ld	s4,80(sp)
ffffffffc0204b54:	6aa6                	ld	s5,72(sp)
ffffffffc0204b56:	6b06                	ld	s6,64(sp)
ffffffffc0204b58:	7be2                	ld	s7,56(sp)
ffffffffc0204b5a:	7c42                	ld	s8,48(sp)
ffffffffc0204b5c:	7ca2                	ld	s9,40(sp)
ffffffffc0204b5e:	7d02                	ld	s10,32(sp)
ffffffffc0204b60:	6de2                	ld	s11,24(sp)
ffffffffc0204b62:	6109                	addi	sp,sp,128
ffffffffc0204b64:	8082                	ret
    if (lflag >= 2) {
ffffffffc0204b66:	4705                	li	a4,1
ffffffffc0204b68:	008a8593          	addi	a1,s5,8
ffffffffc0204b6c:	01074463          	blt	a4,a6,ffffffffc0204b74 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0204b70:	26080363          	beqz	a6,ffffffffc0204dd6 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0204b74:	000ab603          	ld	a2,0(s5)
ffffffffc0204b78:	46c1                	li	a3,16
ffffffffc0204b7a:	8aae                	mv	s5,a1
ffffffffc0204b7c:	a06d                	j	ffffffffc0204c26 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0204b7e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204b82:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b84:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204b86:	b765                	j	ffffffffc0204b2e <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0204b88:	000aa503          	lw	a0,0(s5)
ffffffffc0204b8c:	85a6                	mv	a1,s1
ffffffffc0204b8e:	0aa1                	addi	s5,s5,8
ffffffffc0204b90:	9902                	jalr	s2
            break;
ffffffffc0204b92:	bfb9                	j	ffffffffc0204af0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204b94:	4705                	li	a4,1
ffffffffc0204b96:	008a8993          	addi	s3,s5,8
ffffffffc0204b9a:	01074463          	blt	a4,a6,ffffffffc0204ba2 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0204b9e:	22080463          	beqz	a6,ffffffffc0204dc6 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0204ba2:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0204ba6:	24044463          	bltz	s0,ffffffffc0204dee <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0204baa:	8622                	mv	a2,s0
ffffffffc0204bac:	8ace                	mv	s5,s3
ffffffffc0204bae:	46a9                	li	a3,10
ffffffffc0204bb0:	a89d                	j	ffffffffc0204c26 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0204bb2:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204bb6:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204bb8:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0204bba:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204bbe:	8fb5                	xor	a5,a5,a3
ffffffffc0204bc0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204bc4:	1ad74363          	blt	a4,a3,ffffffffc0204d6a <vprintfmt+0x2b4>
ffffffffc0204bc8:	00369793          	slli	a5,a3,0x3
ffffffffc0204bcc:	97e2                	add	a5,a5,s8
ffffffffc0204bce:	639c                	ld	a5,0(a5)
ffffffffc0204bd0:	18078d63          	beqz	a5,ffffffffc0204d6a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204bd4:	86be                	mv	a3,a5
ffffffffc0204bd6:	00000617          	auipc	a2,0x0
ffffffffc0204bda:	39260613          	addi	a2,a2,914 # ffffffffc0204f68 <etext+0x2e>
ffffffffc0204bde:	85a6                	mv	a1,s1
ffffffffc0204be0:	854a                	mv	a0,s2
ffffffffc0204be2:	240000ef          	jal	ra,ffffffffc0204e22 <printfmt>
ffffffffc0204be6:	b729                	j	ffffffffc0204af0 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0204be8:	00144603          	lbu	a2,1(s0)
ffffffffc0204bec:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bee:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204bf0:	bf3d                	j	ffffffffc0204b2e <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0204bf2:	4705                	li	a4,1
ffffffffc0204bf4:	008a8593          	addi	a1,s5,8
ffffffffc0204bf8:	01074463          	blt	a4,a6,ffffffffc0204c00 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0204bfc:	1e080263          	beqz	a6,ffffffffc0204de0 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0204c00:	000ab603          	ld	a2,0(s5)
ffffffffc0204c04:	46a1                	li	a3,8
ffffffffc0204c06:	8aae                	mv	s5,a1
ffffffffc0204c08:	a839                	j	ffffffffc0204c26 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0204c0a:	03000513          	li	a0,48
ffffffffc0204c0e:	85a6                	mv	a1,s1
ffffffffc0204c10:	e03e                	sd	a5,0(sp)
ffffffffc0204c12:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204c14:	85a6                	mv	a1,s1
ffffffffc0204c16:	07800513          	li	a0,120
ffffffffc0204c1a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204c1c:	0aa1                	addi	s5,s5,8
ffffffffc0204c1e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0204c22:	6782                	ld	a5,0(sp)
ffffffffc0204c24:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204c26:	876e                	mv	a4,s11
ffffffffc0204c28:	85a6                	mv	a1,s1
ffffffffc0204c2a:	854a                	mv	a0,s2
ffffffffc0204c2c:	e1fff0ef          	jal	ra,ffffffffc0204a4a <printnum>
            break;
ffffffffc0204c30:	b5c1                	j	ffffffffc0204af0 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204c32:	000ab603          	ld	a2,0(s5)
ffffffffc0204c36:	0aa1                	addi	s5,s5,8
ffffffffc0204c38:	1c060663          	beqz	a2,ffffffffc0204e04 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0204c3c:	00160413          	addi	s0,a2,1
ffffffffc0204c40:	17b05c63          	blez	s11,ffffffffc0204db8 <vprintfmt+0x302>
ffffffffc0204c44:	02d00593          	li	a1,45
ffffffffc0204c48:	14b79263          	bne	a5,a1,ffffffffc0204d8c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204c4c:	00064783          	lbu	a5,0(a2)
ffffffffc0204c50:	0007851b          	sext.w	a0,a5
ffffffffc0204c54:	c905                	beqz	a0,ffffffffc0204c84 <vprintfmt+0x1ce>
ffffffffc0204c56:	000cc563          	bltz	s9,ffffffffc0204c60 <vprintfmt+0x1aa>
ffffffffc0204c5a:	3cfd                	addiw	s9,s9,-1
ffffffffc0204c5c:	036c8263          	beq	s9,s6,ffffffffc0204c80 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0204c60:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204c62:	18098463          	beqz	s3,ffffffffc0204dea <vprintfmt+0x334>
ffffffffc0204c66:	3781                	addiw	a5,a5,-32
ffffffffc0204c68:	18fbf163          	bleu	a5,s7,ffffffffc0204dea <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0204c6c:	03f00513          	li	a0,63
ffffffffc0204c70:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204c72:	0405                	addi	s0,s0,1
ffffffffc0204c74:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204c78:	3dfd                	addiw	s11,s11,-1
ffffffffc0204c7a:	0007851b          	sext.w	a0,a5
ffffffffc0204c7e:	fd61                	bnez	a0,ffffffffc0204c56 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0204c80:	e7b058e3          	blez	s11,ffffffffc0204af0 <vprintfmt+0x3a>
ffffffffc0204c84:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204c86:	85a6                	mv	a1,s1
ffffffffc0204c88:	02000513          	li	a0,32
ffffffffc0204c8c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204c8e:	e60d81e3          	beqz	s11,ffffffffc0204af0 <vprintfmt+0x3a>
ffffffffc0204c92:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204c94:	85a6                	mv	a1,s1
ffffffffc0204c96:	02000513          	li	a0,32
ffffffffc0204c9a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204c9c:	fe0d94e3          	bnez	s11,ffffffffc0204c84 <vprintfmt+0x1ce>
ffffffffc0204ca0:	bd81                	j	ffffffffc0204af0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204ca2:	4705                	li	a4,1
ffffffffc0204ca4:	008a8593          	addi	a1,s5,8
ffffffffc0204ca8:	01074463          	blt	a4,a6,ffffffffc0204cb0 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0204cac:	12080063          	beqz	a6,ffffffffc0204dcc <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0204cb0:	000ab603          	ld	a2,0(s5)
ffffffffc0204cb4:	46a9                	li	a3,10
ffffffffc0204cb6:	8aae                	mv	s5,a1
ffffffffc0204cb8:	b7bd                	j	ffffffffc0204c26 <vprintfmt+0x170>
ffffffffc0204cba:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0204cbe:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cc2:	846a                	mv	s0,s10
ffffffffc0204cc4:	b5ad                	j	ffffffffc0204b2e <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0204cc6:	85a6                	mv	a1,s1
ffffffffc0204cc8:	02500513          	li	a0,37
ffffffffc0204ccc:	9902                	jalr	s2
            break;
ffffffffc0204cce:	b50d                	j	ffffffffc0204af0 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0204cd0:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0204cd4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204cd8:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cda:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0204cdc:	e40dd9e3          	bgez	s11,ffffffffc0204b2e <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204ce0:	8de6                	mv	s11,s9
ffffffffc0204ce2:	5cfd                	li	s9,-1
ffffffffc0204ce4:	b5a9                	j	ffffffffc0204b2e <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204ce6:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0204cea:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cee:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204cf0:	bd3d                	j	ffffffffc0204b2e <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0204cf2:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0204cf6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cfa:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204cfc:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204d00:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204d04:	fcd56ce3          	bltu	a0,a3,ffffffffc0204cdc <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0204d08:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204d0a:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204d0e:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204d12:	0196873b          	addw	a4,a3,s9
ffffffffc0204d16:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204d1a:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204d1e:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204d22:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0204d26:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204d2a:	fcd57fe3          	bleu	a3,a0,ffffffffc0204d08 <vprintfmt+0x252>
ffffffffc0204d2e:	b77d                	j	ffffffffc0204cdc <vprintfmt+0x226>
            if (width < 0)
ffffffffc0204d30:	fffdc693          	not	a3,s11
ffffffffc0204d34:	96fd                	srai	a3,a3,0x3f
ffffffffc0204d36:	00ddfdb3          	and	s11,s11,a3
ffffffffc0204d3a:	00144603          	lbu	a2,1(s0)
ffffffffc0204d3e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d40:	846a                	mv	s0,s10
ffffffffc0204d42:	b3f5                	j	ffffffffc0204b2e <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0204d44:	85a6                	mv	a1,s1
ffffffffc0204d46:	02500513          	li	a0,37
ffffffffc0204d4a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204d4c:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204d50:	02500793          	li	a5,37
ffffffffc0204d54:	8d22                	mv	s10,s0
ffffffffc0204d56:	d8f70de3          	beq	a4,a5,ffffffffc0204af0 <vprintfmt+0x3a>
ffffffffc0204d5a:	02500713          	li	a4,37
ffffffffc0204d5e:	1d7d                	addi	s10,s10,-1
ffffffffc0204d60:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0204d64:	fee79de3          	bne	a5,a4,ffffffffc0204d5e <vprintfmt+0x2a8>
ffffffffc0204d68:	b361                	j	ffffffffc0204af0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204d6a:	00002617          	auipc	a2,0x2
ffffffffc0204d6e:	2ee60613          	addi	a2,a2,750 # ffffffffc0207058 <error_string+0xd8>
ffffffffc0204d72:	85a6                	mv	a1,s1
ffffffffc0204d74:	854a                	mv	a0,s2
ffffffffc0204d76:	0ac000ef          	jal	ra,ffffffffc0204e22 <printfmt>
ffffffffc0204d7a:	bb9d                	j	ffffffffc0204af0 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204d7c:	00002617          	auipc	a2,0x2
ffffffffc0204d80:	2d460613          	addi	a2,a2,724 # ffffffffc0207050 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0204d84:	00002417          	auipc	s0,0x2
ffffffffc0204d88:	2cd40413          	addi	s0,s0,717 # ffffffffc0207051 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204d8c:	8532                	mv	a0,a2
ffffffffc0204d8e:	85e6                	mv	a1,s9
ffffffffc0204d90:	e032                	sd	a2,0(sp)
ffffffffc0204d92:	e43e                	sd	a5,8(sp)
ffffffffc0204d94:	0cc000ef          	jal	ra,ffffffffc0204e60 <strnlen>
ffffffffc0204d98:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204d9c:	6602                	ld	a2,0(sp)
ffffffffc0204d9e:	01b05d63          	blez	s11,ffffffffc0204db8 <vprintfmt+0x302>
ffffffffc0204da2:	67a2                	ld	a5,8(sp)
ffffffffc0204da4:	2781                	sext.w	a5,a5
ffffffffc0204da6:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0204da8:	6522                	ld	a0,8(sp)
ffffffffc0204daa:	85a6                	mv	a1,s1
ffffffffc0204dac:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204dae:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204db0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204db2:	6602                	ld	a2,0(sp)
ffffffffc0204db4:	fe0d9ae3          	bnez	s11,ffffffffc0204da8 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204db8:	00064783          	lbu	a5,0(a2)
ffffffffc0204dbc:	0007851b          	sext.w	a0,a5
ffffffffc0204dc0:	e8051be3          	bnez	a0,ffffffffc0204c56 <vprintfmt+0x1a0>
ffffffffc0204dc4:	b335                	j	ffffffffc0204af0 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0204dc6:	000aa403          	lw	s0,0(s5)
ffffffffc0204dca:	bbf1                	j	ffffffffc0204ba6 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0204dcc:	000ae603          	lwu	a2,0(s5)
ffffffffc0204dd0:	46a9                	li	a3,10
ffffffffc0204dd2:	8aae                	mv	s5,a1
ffffffffc0204dd4:	bd89                	j	ffffffffc0204c26 <vprintfmt+0x170>
ffffffffc0204dd6:	000ae603          	lwu	a2,0(s5)
ffffffffc0204dda:	46c1                	li	a3,16
ffffffffc0204ddc:	8aae                	mv	s5,a1
ffffffffc0204dde:	b5a1                	j	ffffffffc0204c26 <vprintfmt+0x170>
ffffffffc0204de0:	000ae603          	lwu	a2,0(s5)
ffffffffc0204de4:	46a1                	li	a3,8
ffffffffc0204de6:	8aae                	mv	s5,a1
ffffffffc0204de8:	bd3d                	j	ffffffffc0204c26 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0204dea:	9902                	jalr	s2
ffffffffc0204dec:	b559                	j	ffffffffc0204c72 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0204dee:	85a6                	mv	a1,s1
ffffffffc0204df0:	02d00513          	li	a0,45
ffffffffc0204df4:	e03e                	sd	a5,0(sp)
ffffffffc0204df6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204df8:	8ace                	mv	s5,s3
ffffffffc0204dfa:	40800633          	neg	a2,s0
ffffffffc0204dfe:	46a9                	li	a3,10
ffffffffc0204e00:	6782                	ld	a5,0(sp)
ffffffffc0204e02:	b515                	j	ffffffffc0204c26 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0204e04:	01b05663          	blez	s11,ffffffffc0204e10 <vprintfmt+0x35a>
ffffffffc0204e08:	02d00693          	li	a3,45
ffffffffc0204e0c:	f6d798e3          	bne	a5,a3,ffffffffc0204d7c <vprintfmt+0x2c6>
ffffffffc0204e10:	00002417          	auipc	s0,0x2
ffffffffc0204e14:	24140413          	addi	s0,s0,577 # ffffffffc0207051 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204e18:	02800513          	li	a0,40
ffffffffc0204e1c:	02800793          	li	a5,40
ffffffffc0204e20:	bd1d                	j	ffffffffc0204c56 <vprintfmt+0x1a0>

ffffffffc0204e22 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e22:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204e24:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e28:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204e2a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e2c:	ec06                	sd	ra,24(sp)
ffffffffc0204e2e:	f83a                	sd	a4,48(sp)
ffffffffc0204e30:	fc3e                	sd	a5,56(sp)
ffffffffc0204e32:	e0c2                	sd	a6,64(sp)
ffffffffc0204e34:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204e36:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204e38:	c7fff0ef          	jal	ra,ffffffffc0204ab6 <vprintfmt>
}
ffffffffc0204e3c:	60e2                	ld	ra,24(sp)
ffffffffc0204e3e:	6161                	addi	sp,sp,80
ffffffffc0204e40:	8082                	ret

ffffffffc0204e42 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204e42:	00054783          	lbu	a5,0(a0)
ffffffffc0204e46:	cb91                	beqz	a5,ffffffffc0204e5a <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204e48:	4781                	li	a5,0
        cnt ++;
ffffffffc0204e4a:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0204e4c:	00f50733          	add	a4,a0,a5
ffffffffc0204e50:	00074703          	lbu	a4,0(a4)
ffffffffc0204e54:	fb7d                	bnez	a4,ffffffffc0204e4a <strlen+0x8>
    }
    return cnt;
}
ffffffffc0204e56:	853e                	mv	a0,a5
ffffffffc0204e58:	8082                	ret
    size_t cnt = 0;
ffffffffc0204e5a:	4781                	li	a5,0
}
ffffffffc0204e5c:	853e                	mv	a0,a5
ffffffffc0204e5e:	8082                	ret

ffffffffc0204e60 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204e60:	c185                	beqz	a1,ffffffffc0204e80 <strnlen+0x20>
ffffffffc0204e62:	00054783          	lbu	a5,0(a0)
ffffffffc0204e66:	cf89                	beqz	a5,ffffffffc0204e80 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0204e68:	4781                	li	a5,0
ffffffffc0204e6a:	a021                	j	ffffffffc0204e72 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204e6c:	00074703          	lbu	a4,0(a4)
ffffffffc0204e70:	c711                	beqz	a4,ffffffffc0204e7c <strnlen+0x1c>
        cnt ++;
ffffffffc0204e72:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204e74:	00f50733          	add	a4,a0,a5
ffffffffc0204e78:	fef59ae3          	bne	a1,a5,ffffffffc0204e6c <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0204e7c:	853e                	mv	a0,a5
ffffffffc0204e7e:	8082                	ret
    size_t cnt = 0;
ffffffffc0204e80:	4781                	li	a5,0
}
ffffffffc0204e82:	853e                	mv	a0,a5
ffffffffc0204e84:	8082                	ret

ffffffffc0204e86 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204e86:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204e88:	0585                	addi	a1,a1,1
ffffffffc0204e8a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204e8e:	0785                	addi	a5,a5,1
ffffffffc0204e90:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204e94:	fb75                	bnez	a4,ffffffffc0204e88 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204e96:	8082                	ret

ffffffffc0204e98 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204e98:	00054783          	lbu	a5,0(a0)
ffffffffc0204e9c:	0005c703          	lbu	a4,0(a1)
ffffffffc0204ea0:	cb91                	beqz	a5,ffffffffc0204eb4 <strcmp+0x1c>
ffffffffc0204ea2:	00e79c63          	bne	a5,a4,ffffffffc0204eba <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0204ea6:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204ea8:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0204eac:	0585                	addi	a1,a1,1
ffffffffc0204eae:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204eb2:	fbe5                	bnez	a5,ffffffffc0204ea2 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204eb4:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204eb6:	9d19                	subw	a0,a0,a4
ffffffffc0204eb8:	8082                	ret
ffffffffc0204eba:	0007851b          	sext.w	a0,a5
ffffffffc0204ebe:	9d19                	subw	a0,a0,a4
ffffffffc0204ec0:	8082                	ret

ffffffffc0204ec2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204ec2:	00054783          	lbu	a5,0(a0)
ffffffffc0204ec6:	cb91                	beqz	a5,ffffffffc0204eda <strchr+0x18>
        if (*s == c) {
ffffffffc0204ec8:	00b79563          	bne	a5,a1,ffffffffc0204ed2 <strchr+0x10>
ffffffffc0204ecc:	a809                	j	ffffffffc0204ede <strchr+0x1c>
ffffffffc0204ece:	00b78763          	beq	a5,a1,ffffffffc0204edc <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0204ed2:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204ed4:	00054783          	lbu	a5,0(a0)
ffffffffc0204ed8:	fbfd                	bnez	a5,ffffffffc0204ece <strchr+0xc>
    }
    return NULL;
ffffffffc0204eda:	4501                	li	a0,0
}
ffffffffc0204edc:	8082                	ret
ffffffffc0204ede:	8082                	ret

ffffffffc0204ee0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204ee0:	ca01                	beqz	a2,ffffffffc0204ef0 <memset+0x10>
ffffffffc0204ee2:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204ee4:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204ee6:	0785                	addi	a5,a5,1
ffffffffc0204ee8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204eec:	fec79de3          	bne	a5,a2,ffffffffc0204ee6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204ef0:	8082                	ret

ffffffffc0204ef2 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204ef2:	ca19                	beqz	a2,ffffffffc0204f08 <memcpy+0x16>
ffffffffc0204ef4:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204ef6:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204ef8:	0585                	addi	a1,a1,1
ffffffffc0204efa:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204efe:	0785                	addi	a5,a5,1
ffffffffc0204f00:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204f04:	fec59ae3          	bne	a1,a2,ffffffffc0204ef8 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204f08:	8082                	ret

ffffffffc0204f0a <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204f0a:	c21d                	beqz	a2,ffffffffc0204f30 <memcmp+0x26>
        if (*s1 != *s2) {
ffffffffc0204f0c:	00054783          	lbu	a5,0(a0)
ffffffffc0204f10:	0005c703          	lbu	a4,0(a1)
ffffffffc0204f14:	962a                	add	a2,a2,a0
ffffffffc0204f16:	00f70963          	beq	a4,a5,ffffffffc0204f28 <memcmp+0x1e>
ffffffffc0204f1a:	a829                	j	ffffffffc0204f34 <memcmp+0x2a>
ffffffffc0204f1c:	00054783          	lbu	a5,0(a0)
ffffffffc0204f20:	0005c703          	lbu	a4,0(a1)
ffffffffc0204f24:	00e79863          	bne	a5,a4,ffffffffc0204f34 <memcmp+0x2a>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204f28:	0505                	addi	a0,a0,1
ffffffffc0204f2a:	0585                	addi	a1,a1,1
    while (n -- > 0) {
ffffffffc0204f2c:	fea618e3          	bne	a2,a0,ffffffffc0204f1c <memcmp+0x12>
    }
    return 0;
ffffffffc0204f30:	4501                	li	a0,0
}
ffffffffc0204f32:	8082                	ret
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204f34:	40e7853b          	subw	a0,a5,a4
ffffffffc0204f38:	8082                	ret
