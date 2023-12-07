
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200028:	c020b137          	lui	sp,0xc020b

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

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	000a1517          	auipc	a0,0xa1
ffffffffc020003a:	12250513          	addi	a0,a0,290 # ffffffffc02a1158 <edata>
ffffffffc020003e:	000ac617          	auipc	a2,0xac
ffffffffc0200042:	6a260613          	addi	a2,a2,1698 # ffffffffc02ac6e0 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	5c6060ef          	jal	ra,ffffffffc0206614 <memset>
    cons_init();                // init the console
ffffffffc0200052:	536000ef          	jal	ra,ffffffffc0200588 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	5ea58593          	addi	a1,a1,1514 # ffffffffc0206640 <etext+0x2>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	60250513          	addi	a0,a0,1538 # ffffffffc0206660 <etext+0x22>
ffffffffc0200066:	128000ef          	jal	ra,ffffffffc020018e <cprintf>

    print_kerninfo();
ffffffffc020006a:	1ac000ef          	jal	ra,ffffffffc0200216 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	5c6020ef          	jal	ra,ffffffffc0202634 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5ee000ef          	jal	ra,ffffffffc0200660 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5ec000ef          	jal	ra,ffffffffc0200662 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	3e8040ef          	jal	ra,ffffffffc0204462 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	527050ef          	jal	ra,ffffffffc0205da4 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	57a000ef          	jal	ra,ffffffffc02005fc <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	306030ef          	jal	ra,ffffffffc020338c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	4a8000ef          	jal	ra,ffffffffc0200532 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5c6000ef          	jal	ra,ffffffffc0200654 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	65f050ef          	jal	ra,ffffffffc0205ef0 <cpu_idle>

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
ffffffffc02000ae:	00006517          	auipc	a0,0x6
ffffffffc02000b2:	5ba50513          	addi	a0,a0,1466 # ffffffffc0206668 <etext+0x2a>
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
ffffffffc02000c4:	000a1b97          	auipc	s7,0xa1
ffffffffc02000c8:	094b8b93          	addi	s7,s7,148 # ffffffffc02a1158 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000cc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d0:	136000ef          	jal	ra,ffffffffc0200206 <getchar>
ffffffffc02000d4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000d6:	00054b63          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	00a95b63          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc02000de:	029a5463          	ble	s1,s4,ffffffffc0200106 <readline+0x70>
        c = getchar();
ffffffffc02000e2:	124000ef          	jal	ra,ffffffffc0200206 <getchar>
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
ffffffffc02000f6:	110000ef          	jal	ra,ffffffffc0200206 <getchar>
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
ffffffffc0200126:	000a1517          	auipc	a0,0xa1
ffffffffc020012a:	03250513          	addi	a0,a0,50 # ffffffffc02a1158 <edata>
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
ffffffffc020015c:	42e000ef          	jal	ra,ffffffffc020058a <cons_putc>
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
ffffffffc0200182:	068060ef          	jal	ra,ffffffffc02061ea <vprintfmt>
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
ffffffffc0200190:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
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
ffffffffc02001b6:	034060ef          	jal	ra,ffffffffc02061ea <vprintfmt>
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
ffffffffc02001c2:	3c80006f          	j	ffffffffc020058a <cons_putc>

ffffffffc02001c6 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001c6:	1101                	addi	sp,sp,-32
ffffffffc02001c8:	e822                	sd	s0,16(sp)
ffffffffc02001ca:	ec06                	sd	ra,24(sp)
ffffffffc02001cc:	e426                	sd	s1,8(sp)
ffffffffc02001ce:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001d0:	00054503          	lbu	a0,0(a0)
ffffffffc02001d4:	c51d                	beqz	a0,ffffffffc0200202 <cputs+0x3c>
ffffffffc02001d6:	0405                	addi	s0,s0,1
ffffffffc02001d8:	4485                	li	s1,1
ffffffffc02001da:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001dc:	3ae000ef          	jal	ra,ffffffffc020058a <cons_putc>
    (*cnt) ++;
ffffffffc02001e0:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc02001e4:	0405                	addi	s0,s0,1
ffffffffc02001e6:	fff44503          	lbu	a0,-1(s0)
ffffffffc02001ea:	f96d                	bnez	a0,ffffffffc02001dc <cputs+0x16>
ffffffffc02001ec:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001f0:	4529                	li	a0,10
ffffffffc02001f2:	398000ef          	jal	ra,ffffffffc020058a <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001f6:	8522                	mv	a0,s0
ffffffffc02001f8:	60e2                	ld	ra,24(sp)
ffffffffc02001fa:	6442                	ld	s0,16(sp)
ffffffffc02001fc:	64a2                	ld	s1,8(sp)
ffffffffc02001fe:	6105                	addi	sp,sp,32
ffffffffc0200200:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200202:	4405                	li	s0,1
ffffffffc0200204:	b7f5                	j	ffffffffc02001f0 <cputs+0x2a>

ffffffffc0200206 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200206:	1141                	addi	sp,sp,-16
ffffffffc0200208:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020020a:	3b6000ef          	jal	ra,ffffffffc02005c0 <cons_getc>
ffffffffc020020e:	dd75                	beqz	a0,ffffffffc020020a <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200210:	60a2                	ld	ra,8(sp)
ffffffffc0200212:	0141                	addi	sp,sp,16
ffffffffc0200214:	8082                	ret

ffffffffc0200216 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200216:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200218:	00006517          	auipc	a0,0x6
ffffffffc020021c:	48850513          	addi	a0,a0,1160 # ffffffffc02066a0 <etext+0x62>
void print_kerninfo(void) {
ffffffffc0200220:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200222:	f6dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200226:	00000597          	auipc	a1,0x0
ffffffffc020022a:	e1058593          	addi	a1,a1,-496 # ffffffffc0200036 <kern_init>
ffffffffc020022e:	00006517          	auipc	a0,0x6
ffffffffc0200232:	49250513          	addi	a0,a0,1170 # ffffffffc02066c0 <etext+0x82>
ffffffffc0200236:	f59ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020023a:	00006597          	auipc	a1,0x6
ffffffffc020023e:	40458593          	addi	a1,a1,1028 # ffffffffc020663e <etext>
ffffffffc0200242:	00006517          	auipc	a0,0x6
ffffffffc0200246:	49e50513          	addi	a0,a0,1182 # ffffffffc02066e0 <etext+0xa2>
ffffffffc020024a:	f45ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020024e:	000a1597          	auipc	a1,0xa1
ffffffffc0200252:	f0a58593          	addi	a1,a1,-246 # ffffffffc02a1158 <edata>
ffffffffc0200256:	00006517          	auipc	a0,0x6
ffffffffc020025a:	4aa50513          	addi	a0,a0,1194 # ffffffffc0206700 <etext+0xc2>
ffffffffc020025e:	f31ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200262:	000ac597          	auipc	a1,0xac
ffffffffc0200266:	47e58593          	addi	a1,a1,1150 # ffffffffc02ac6e0 <end>
ffffffffc020026a:	00006517          	auipc	a0,0x6
ffffffffc020026e:	4b650513          	addi	a0,a0,1206 # ffffffffc0206720 <etext+0xe2>
ffffffffc0200272:	f1dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200276:	000ad597          	auipc	a1,0xad
ffffffffc020027a:	86958593          	addi	a1,a1,-1943 # ffffffffc02acadf <end+0x3ff>
ffffffffc020027e:	00000797          	auipc	a5,0x0
ffffffffc0200282:	db878793          	addi	a5,a5,-584 # ffffffffc0200036 <kern_init>
ffffffffc0200286:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020028a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020028e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200290:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200294:	95be                	add	a1,a1,a5
ffffffffc0200296:	85a9                	srai	a1,a1,0xa
ffffffffc0200298:	00006517          	auipc	a0,0x6
ffffffffc020029c:	4a850513          	addi	a0,a0,1192 # ffffffffc0206740 <etext+0x102>
}
ffffffffc02002a0:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002a2:	eedff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02002a6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002a6:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002a8:	00006617          	auipc	a2,0x6
ffffffffc02002ac:	3c860613          	addi	a2,a2,968 # ffffffffc0206670 <etext+0x32>
ffffffffc02002b0:	04d00593          	li	a1,77
ffffffffc02002b4:	00006517          	auipc	a0,0x6
ffffffffc02002b8:	3d450513          	addi	a0,a0,980 # ffffffffc0206688 <etext+0x4a>
void print_stackframe(void) {
ffffffffc02002bc:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002be:	1c6000ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02002c2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002c2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002c4:	00006617          	auipc	a2,0x6
ffffffffc02002c8:	58c60613          	addi	a2,a2,1420 # ffffffffc0206850 <commands+0xe0>
ffffffffc02002cc:	00006597          	auipc	a1,0x6
ffffffffc02002d0:	5a458593          	addi	a1,a1,1444 # ffffffffc0206870 <commands+0x100>
ffffffffc02002d4:	00006517          	auipc	a0,0x6
ffffffffc02002d8:	5a450513          	addi	a0,a0,1444 # ffffffffc0206878 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002dc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002de:	eb1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002e2:	00006617          	auipc	a2,0x6
ffffffffc02002e6:	5a660613          	addi	a2,a2,1446 # ffffffffc0206888 <commands+0x118>
ffffffffc02002ea:	00006597          	auipc	a1,0x6
ffffffffc02002ee:	5c658593          	addi	a1,a1,1478 # ffffffffc02068b0 <commands+0x140>
ffffffffc02002f2:	00006517          	auipc	a0,0x6
ffffffffc02002f6:	58650513          	addi	a0,a0,1414 # ffffffffc0206878 <commands+0x108>
ffffffffc02002fa:	e95ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002fe:	00006617          	auipc	a2,0x6
ffffffffc0200302:	5c260613          	addi	a2,a2,1474 # ffffffffc02068c0 <commands+0x150>
ffffffffc0200306:	00006597          	auipc	a1,0x6
ffffffffc020030a:	5da58593          	addi	a1,a1,1498 # ffffffffc02068e0 <commands+0x170>
ffffffffc020030e:	00006517          	auipc	a0,0x6
ffffffffc0200312:	56a50513          	addi	a0,a0,1386 # ffffffffc0206878 <commands+0x108>
ffffffffc0200316:	e79ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    }
    return 0;
}
ffffffffc020031a:	60a2                	ld	ra,8(sp)
ffffffffc020031c:	4501                	li	a0,0
ffffffffc020031e:	0141                	addi	sp,sp,16
ffffffffc0200320:	8082                	ret

ffffffffc0200322 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200322:	1141                	addi	sp,sp,-16
ffffffffc0200324:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200326:	ef1ff0ef          	jal	ra,ffffffffc0200216 <print_kerninfo>
    return 0;
}
ffffffffc020032a:	60a2                	ld	ra,8(sp)
ffffffffc020032c:	4501                	li	a0,0
ffffffffc020032e:	0141                	addi	sp,sp,16
ffffffffc0200330:	8082                	ret

ffffffffc0200332 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200332:	1141                	addi	sp,sp,-16
ffffffffc0200334:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200336:	f71ff0ef          	jal	ra,ffffffffc02002a6 <print_stackframe>
    return 0;
}
ffffffffc020033a:	60a2                	ld	ra,8(sp)
ffffffffc020033c:	4501                	li	a0,0
ffffffffc020033e:	0141                	addi	sp,sp,16
ffffffffc0200340:	8082                	ret

ffffffffc0200342 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200342:	7115                	addi	sp,sp,-224
ffffffffc0200344:	e962                	sd	s8,144(sp)
ffffffffc0200346:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200348:	00006517          	auipc	a0,0x6
ffffffffc020034c:	47050513          	addi	a0,a0,1136 # ffffffffc02067b8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200350:	ed86                	sd	ra,216(sp)
ffffffffc0200352:	e9a2                	sd	s0,208(sp)
ffffffffc0200354:	e5a6                	sd	s1,200(sp)
ffffffffc0200356:	e1ca                	sd	s2,192(sp)
ffffffffc0200358:	fd4e                	sd	s3,184(sp)
ffffffffc020035a:	f952                	sd	s4,176(sp)
ffffffffc020035c:	f556                	sd	s5,168(sp)
ffffffffc020035e:	f15a                	sd	s6,160(sp)
ffffffffc0200360:	ed5e                	sd	s7,152(sp)
ffffffffc0200362:	e566                	sd	s9,136(sp)
ffffffffc0200364:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200366:	e29ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020036a:	00006517          	auipc	a0,0x6
ffffffffc020036e:	47650513          	addi	a0,a0,1142 # ffffffffc02067e0 <commands+0x70>
ffffffffc0200372:	e1dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    if (tf != NULL) {
ffffffffc0200376:	000c0563          	beqz	s8,ffffffffc0200380 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020037a:	8562                	mv	a0,s8
ffffffffc020037c:	4ce000ef          	jal	ra,ffffffffc020084a <print_trapframe>
ffffffffc0200380:	00006c97          	auipc	s9,0x6
ffffffffc0200384:	3f0c8c93          	addi	s9,s9,1008 # ffffffffc0206770 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200388:	00006997          	auipc	s3,0x6
ffffffffc020038c:	48098993          	addi	s3,s3,1152 # ffffffffc0206808 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200390:	00006917          	auipc	s2,0x6
ffffffffc0200394:	48090913          	addi	s2,s2,1152 # ffffffffc0206810 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200398:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039a:	00006b17          	auipc	s6,0x6
ffffffffc020039e:	47eb0b13          	addi	s6,s6,1150 # ffffffffc0206818 <commands+0xa8>
    if (argc == 0) {
ffffffffc02003a2:	00006a97          	auipc	s5,0x6
ffffffffc02003a6:	4cea8a93          	addi	s5,s5,1230 # ffffffffc0206870 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003aa:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003ac:	854e                	mv	a0,s3
ffffffffc02003ae:	ce9ff0ef          	jal	ra,ffffffffc0200096 <readline>
ffffffffc02003b2:	842a                	mv	s0,a0
ffffffffc02003b4:	dd65                	beqz	a0,ffffffffc02003ac <kmonitor+0x6a>
ffffffffc02003b6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003ba:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003bc:	c999                	beqz	a1,ffffffffc02003d2 <kmonitor+0x90>
ffffffffc02003be:	854a                	mv	a0,s2
ffffffffc02003c0:	236060ef          	jal	ra,ffffffffc02065f6 <strchr>
ffffffffc02003c4:	c925                	beqz	a0,ffffffffc0200434 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02003c6:	00144583          	lbu	a1,1(s0)
ffffffffc02003ca:	00040023          	sb	zero,0(s0)
ffffffffc02003ce:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003d0:	f5fd                	bnez	a1,ffffffffc02003be <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02003d2:	dce9                	beqz	s1,ffffffffc02003ac <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d4:	6582                	ld	a1,0(sp)
ffffffffc02003d6:	00006d17          	auipc	s10,0x6
ffffffffc02003da:	39ad0d13          	addi	s10,s10,922 # ffffffffc0206770 <commands>
    if (argc == 0) {
ffffffffc02003de:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e0:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003e2:	0d61                	addi	s10,s10,24
ffffffffc02003e4:	1e8060ef          	jal	ra,ffffffffc02065cc <strcmp>
ffffffffc02003e8:	c919                	beqz	a0,ffffffffc02003fe <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ea:	2405                	addiw	s0,s0,1
ffffffffc02003ec:	09740463          	beq	s0,s7,ffffffffc0200474 <kmonitor+0x132>
ffffffffc02003f0:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f4:	6582                	ld	a1,0(sp)
ffffffffc02003f6:	0d61                	addi	s10,s10,24
ffffffffc02003f8:	1d4060ef          	jal	ra,ffffffffc02065cc <strcmp>
ffffffffc02003fc:	f57d                	bnez	a0,ffffffffc02003ea <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003fe:	00141793          	slli	a5,s0,0x1
ffffffffc0200402:	97a2                	add	a5,a5,s0
ffffffffc0200404:	078e                	slli	a5,a5,0x3
ffffffffc0200406:	97e6                	add	a5,a5,s9
ffffffffc0200408:	6b9c                	ld	a5,16(a5)
ffffffffc020040a:	8662                	mv	a2,s8
ffffffffc020040c:	002c                	addi	a1,sp,8
ffffffffc020040e:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200412:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200414:	f8055ce3          	bgez	a0,ffffffffc02003ac <kmonitor+0x6a>
}
ffffffffc0200418:	60ee                	ld	ra,216(sp)
ffffffffc020041a:	644e                	ld	s0,208(sp)
ffffffffc020041c:	64ae                	ld	s1,200(sp)
ffffffffc020041e:	690e                	ld	s2,192(sp)
ffffffffc0200420:	79ea                	ld	s3,184(sp)
ffffffffc0200422:	7a4a                	ld	s4,176(sp)
ffffffffc0200424:	7aaa                	ld	s5,168(sp)
ffffffffc0200426:	7b0a                	ld	s6,160(sp)
ffffffffc0200428:	6bea                	ld	s7,152(sp)
ffffffffc020042a:	6c4a                	ld	s8,144(sp)
ffffffffc020042c:	6caa                	ld	s9,136(sp)
ffffffffc020042e:	6d0a                	ld	s10,128(sp)
ffffffffc0200430:	612d                	addi	sp,sp,224
ffffffffc0200432:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200434:	00044783          	lbu	a5,0(s0)
ffffffffc0200438:	dfc9                	beqz	a5,ffffffffc02003d2 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020043a:	03448863          	beq	s1,s4,ffffffffc020046a <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020043e:	00349793          	slli	a5,s1,0x3
ffffffffc0200442:	0118                	addi	a4,sp,128
ffffffffc0200444:	97ba                	add	a5,a5,a4
ffffffffc0200446:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020044a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020044e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200450:	e591                	bnez	a1,ffffffffc020045c <kmonitor+0x11a>
ffffffffc0200452:	b749                	j	ffffffffc02003d4 <kmonitor+0x92>
            buf ++;
ffffffffc0200454:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200456:	00044583          	lbu	a1,0(s0)
ffffffffc020045a:	ddad                	beqz	a1,ffffffffc02003d4 <kmonitor+0x92>
ffffffffc020045c:	854a                	mv	a0,s2
ffffffffc020045e:	198060ef          	jal	ra,ffffffffc02065f6 <strchr>
ffffffffc0200462:	d96d                	beqz	a0,ffffffffc0200454 <kmonitor+0x112>
ffffffffc0200464:	00044583          	lbu	a1,0(s0)
ffffffffc0200468:	bf91                	j	ffffffffc02003bc <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020046a:	45c1                	li	a1,16
ffffffffc020046c:	855a                	mv	a0,s6
ffffffffc020046e:	d21ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0200472:	b7f1                	j	ffffffffc020043e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200474:	6582                	ld	a1,0(sp)
ffffffffc0200476:	00006517          	auipc	a0,0x6
ffffffffc020047a:	3c250513          	addi	a0,a0,962 # ffffffffc0206838 <commands+0xc8>
ffffffffc020047e:	d11ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
ffffffffc0200482:	b72d                	j	ffffffffc02003ac <kmonitor+0x6a>

ffffffffc0200484 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200484:	000ac317          	auipc	t1,0xac
ffffffffc0200488:	0d430313          	addi	t1,t1,212 # ffffffffc02ac558 <is_panic>
ffffffffc020048c:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200490:	715d                	addi	sp,sp,-80
ffffffffc0200492:	ec06                	sd	ra,24(sp)
ffffffffc0200494:	e822                	sd	s0,16(sp)
ffffffffc0200496:	f436                	sd	a3,40(sp)
ffffffffc0200498:	f83a                	sd	a4,48(sp)
ffffffffc020049a:	fc3e                	sd	a5,56(sp)
ffffffffc020049c:	e0c2                	sd	a6,64(sp)
ffffffffc020049e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02004a0:	02031c63          	bnez	t1,ffffffffc02004d8 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02004a4:	4785                	li	a5,1
ffffffffc02004a6:	8432                	mv	s0,a2
ffffffffc02004a8:	000ac717          	auipc	a4,0xac
ffffffffc02004ac:	0af73823          	sd	a5,176(a4) # ffffffffc02ac558 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b0:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02004b2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b4:	85aa                	mv	a1,a0
ffffffffc02004b6:	00006517          	auipc	a0,0x6
ffffffffc02004ba:	43a50513          	addi	a0,a0,1082 # ffffffffc02068f0 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02004be:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004c0:	ccfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004c4:	65a2                	ld	a1,8(sp)
ffffffffc02004c6:	8522                	mv	a0,s0
ffffffffc02004c8:	ca7ff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc02004cc:	00007517          	auipc	a0,0x7
ffffffffc02004d0:	3e450513          	addi	a0,a0,996 # ffffffffc02078b0 <default_pmm_manager+0x538>
ffffffffc02004d4:	cbbff0ef          	jal	ra,ffffffffc020018e <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004d8:	4501                	li	a0,0
ffffffffc02004da:	4581                	li	a1,0
ffffffffc02004dc:	4601                	li	a2,0
ffffffffc02004de:	48a1                	li	a7,8
ffffffffc02004e0:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004e4:	176000ef          	jal	ra,ffffffffc020065a <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004e8:	4501                	li	a0,0
ffffffffc02004ea:	e59ff0ef          	jal	ra,ffffffffc0200342 <kmonitor>
ffffffffc02004ee:	bfed                	j	ffffffffc02004e8 <__panic+0x64>

ffffffffc02004f0 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004f0:	715d                	addi	sp,sp,-80
ffffffffc02004f2:	e822                	sd	s0,16(sp)
ffffffffc02004f4:	fc3e                	sd	a5,56(sp)
ffffffffc02004f6:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004f8:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004fa:	862e                	mv	a2,a1
ffffffffc02004fc:	85aa                	mv	a1,a0
ffffffffc02004fe:	00006517          	auipc	a0,0x6
ffffffffc0200502:	41250513          	addi	a0,a0,1042 # ffffffffc0206910 <commands+0x1a0>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200506:	ec06                	sd	ra,24(sp)
ffffffffc0200508:	f436                	sd	a3,40(sp)
ffffffffc020050a:	f83a                	sd	a4,48(sp)
ffffffffc020050c:	e0c2                	sd	a6,64(sp)
ffffffffc020050e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200510:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200512:	c7dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200516:	65a2                	ld	a1,8(sp)
ffffffffc0200518:	8522                	mv	a0,s0
ffffffffc020051a:	c55ff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc020051e:	00007517          	auipc	a0,0x7
ffffffffc0200522:	39250513          	addi	a0,a0,914 # ffffffffc02078b0 <default_pmm_manager+0x538>
ffffffffc0200526:	c69ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    va_end(ap);
}
ffffffffc020052a:	60e2                	ld	ra,24(sp)
ffffffffc020052c:	6442                	ld	s0,16(sp)
ffffffffc020052e:	6161                	addi	sp,sp,80
ffffffffc0200530:	8082                	ret

ffffffffc0200532 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200532:	67e1                	lui	a5,0x18
ffffffffc0200534:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xdc10>
ffffffffc0200538:	000ac717          	auipc	a4,0xac
ffffffffc020053c:	02f73423          	sd	a5,40(a4) # ffffffffc02ac560 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200540:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200544:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200546:	953e                	add	a0,a0,a5
ffffffffc0200548:	4601                	li	a2,0
ffffffffc020054a:	4881                	li	a7,0
ffffffffc020054c:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200550:	02000793          	li	a5,32
ffffffffc0200554:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200558:	00006517          	auipc	a0,0x6
ffffffffc020055c:	3d850513          	addi	a0,a0,984 # ffffffffc0206930 <commands+0x1c0>
    ticks = 0;
ffffffffc0200560:	000ac797          	auipc	a5,0xac
ffffffffc0200564:	0407b823          	sd	zero,80(a5) # ffffffffc02ac5b0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200568:	c27ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020056c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020056c:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200570:	000ac797          	auipc	a5,0xac
ffffffffc0200574:	ff078793          	addi	a5,a5,-16 # ffffffffc02ac560 <timebase>
ffffffffc0200578:	639c                	ld	a5,0(a5)
ffffffffc020057a:	4581                	li	a1,0
ffffffffc020057c:	4601                	li	a2,0
ffffffffc020057e:	953e                	add	a0,a0,a5
ffffffffc0200580:	4881                	li	a7,0
ffffffffc0200582:	00000073          	ecall
ffffffffc0200586:	8082                	ret

ffffffffc0200588 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200588:	8082                	ret

ffffffffc020058a <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020058a:	100027f3          	csrr	a5,sstatus
ffffffffc020058e:	8b89                	andi	a5,a5,2
ffffffffc0200590:	0ff57513          	andi	a0,a0,255
ffffffffc0200594:	e799                	bnez	a5,ffffffffc02005a2 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200596:	4581                	li	a1,0
ffffffffc0200598:	4601                	li	a2,0
ffffffffc020059a:	4885                	li	a7,1
ffffffffc020059c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005a0:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005a2:	1101                	addi	sp,sp,-32
ffffffffc02005a4:	ec06                	sd	ra,24(sp)
ffffffffc02005a6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005a8:	0b2000ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc02005ac:	6522                	ld	a0,8(sp)
ffffffffc02005ae:	4581                	li	a1,0
ffffffffc02005b0:	4601                	li	a2,0
ffffffffc02005b2:	4885                	li	a7,1
ffffffffc02005b4:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005b8:	60e2                	ld	ra,24(sp)
ffffffffc02005ba:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005bc:	0980006f          	j	ffffffffc0200654 <intr_enable>

ffffffffc02005c0 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005c0:	100027f3          	csrr	a5,sstatus
ffffffffc02005c4:	8b89                	andi	a5,a5,2
ffffffffc02005c6:	eb89                	bnez	a5,ffffffffc02005d8 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005c8:	4501                	li	a0,0
ffffffffc02005ca:	4581                	li	a1,0
ffffffffc02005cc:	4601                	li	a2,0
ffffffffc02005ce:	4889                	li	a7,2
ffffffffc02005d0:	00000073          	ecall
ffffffffc02005d4:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005d6:	8082                	ret
int cons_getc(void) {
ffffffffc02005d8:	1101                	addi	sp,sp,-32
ffffffffc02005da:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005dc:	07e000ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc02005e0:	4501                	li	a0,0
ffffffffc02005e2:	4581                	li	a1,0
ffffffffc02005e4:	4601                	li	a2,0
ffffffffc02005e6:	4889                	li	a7,2
ffffffffc02005e8:	00000073          	ecall
ffffffffc02005ec:	2501                	sext.w	a0,a0
ffffffffc02005ee:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005f0:	064000ef          	jal	ra,ffffffffc0200654 <intr_enable>
}
ffffffffc02005f4:	60e2                	ld	ra,24(sp)
ffffffffc02005f6:	6522                	ld	a0,8(sp)
ffffffffc02005f8:	6105                	addi	sp,sp,32
ffffffffc02005fa:	8082                	ret

ffffffffc02005fc <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005fc:	8082                	ret

ffffffffc02005fe <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005fe:	00253513          	sltiu	a0,a0,2
ffffffffc0200602:	8082                	ret

ffffffffc0200604 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc0200604:	03800513          	li	a0,56
ffffffffc0200608:	8082                	ret

ffffffffc020060a <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020060a:	000a1797          	auipc	a5,0xa1
ffffffffc020060e:	f4e78793          	addi	a5,a5,-178 # ffffffffc02a1558 <ide>
ffffffffc0200612:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200616:	1141                	addi	sp,sp,-16
ffffffffc0200618:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020061a:	95be                	add	a1,a1,a5
ffffffffc020061c:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200620:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200622:	004060ef          	jal	ra,ffffffffc0206626 <memcpy>
    return 0;
}
ffffffffc0200626:	60a2                	ld	ra,8(sp)
ffffffffc0200628:	4501                	li	a0,0
ffffffffc020062a:	0141                	addi	sp,sp,16
ffffffffc020062c:	8082                	ret

ffffffffc020062e <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc020062e:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200630:	0095979b          	slliw	a5,a1,0x9
ffffffffc0200634:	000a1517          	auipc	a0,0xa1
ffffffffc0200638:	f2450513          	addi	a0,a0,-220 # ffffffffc02a1558 <ide>
                   size_t nsecs) {
ffffffffc020063c:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020063e:	00969613          	slli	a2,a3,0x9
ffffffffc0200642:	85ba                	mv	a1,a4
ffffffffc0200644:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc0200646:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200648:	7df050ef          	jal	ra,ffffffffc0206626 <memcpy>
    return 0;
}
ffffffffc020064c:	60a2                	ld	ra,8(sp)
ffffffffc020064e:	4501                	li	a0,0
ffffffffc0200650:	0141                	addi	sp,sp,16
ffffffffc0200652:	8082                	ret

ffffffffc0200654 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200654:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200658:	8082                	ret

ffffffffc020065a <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020065a:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020065e:	8082                	ret

ffffffffc0200660 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200660:	8082                	ret

ffffffffc0200662 <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200662:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200666:	00000797          	auipc	a5,0x0
ffffffffc020066a:	67a78793          	addi	a5,a5,1658 # ffffffffc0200ce0 <__alltraps>
ffffffffc020066e:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200672:	000407b7          	lui	a5,0x40
ffffffffc0200676:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020067a:	8082                	ret

ffffffffc020067c <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020067e:	1141                	addi	sp,sp,-16
ffffffffc0200680:	e022                	sd	s0,0(sp)
ffffffffc0200682:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200684:	00006517          	auipc	a0,0x6
ffffffffc0200688:	5f450513          	addi	a0,a0,1524 # ffffffffc0206c78 <commands+0x508>
void print_regs(struct pushregs* gpr) {
ffffffffc020068c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020068e:	b01ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200692:	640c                	ld	a1,8(s0)
ffffffffc0200694:	00006517          	auipc	a0,0x6
ffffffffc0200698:	5fc50513          	addi	a0,a0,1532 # ffffffffc0206c90 <commands+0x520>
ffffffffc020069c:	af3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02006a0:	680c                	ld	a1,16(s0)
ffffffffc02006a2:	00006517          	auipc	a0,0x6
ffffffffc02006a6:	60650513          	addi	a0,a0,1542 # ffffffffc0206ca8 <commands+0x538>
ffffffffc02006aa:	ae5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006ae:	6c0c                	ld	a1,24(s0)
ffffffffc02006b0:	00006517          	auipc	a0,0x6
ffffffffc02006b4:	61050513          	addi	a0,a0,1552 # ffffffffc0206cc0 <commands+0x550>
ffffffffc02006b8:	ad7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006bc:	700c                	ld	a1,32(s0)
ffffffffc02006be:	00006517          	auipc	a0,0x6
ffffffffc02006c2:	61a50513          	addi	a0,a0,1562 # ffffffffc0206cd8 <commands+0x568>
ffffffffc02006c6:	ac9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006ca:	740c                	ld	a1,40(s0)
ffffffffc02006cc:	00006517          	auipc	a0,0x6
ffffffffc02006d0:	62450513          	addi	a0,a0,1572 # ffffffffc0206cf0 <commands+0x580>
ffffffffc02006d4:	abbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d8:	780c                	ld	a1,48(s0)
ffffffffc02006da:	00006517          	auipc	a0,0x6
ffffffffc02006de:	62e50513          	addi	a0,a0,1582 # ffffffffc0206d08 <commands+0x598>
ffffffffc02006e2:	aadff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006e6:	7c0c                	ld	a1,56(s0)
ffffffffc02006e8:	00006517          	auipc	a0,0x6
ffffffffc02006ec:	63850513          	addi	a0,a0,1592 # ffffffffc0206d20 <commands+0x5b0>
ffffffffc02006f0:	a9fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006f4:	602c                	ld	a1,64(s0)
ffffffffc02006f6:	00006517          	auipc	a0,0x6
ffffffffc02006fa:	64250513          	addi	a0,a0,1602 # ffffffffc0206d38 <commands+0x5c8>
ffffffffc02006fe:	a91ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200702:	642c                	ld	a1,72(s0)
ffffffffc0200704:	00006517          	auipc	a0,0x6
ffffffffc0200708:	64c50513          	addi	a0,a0,1612 # ffffffffc0206d50 <commands+0x5e0>
ffffffffc020070c:	a83ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200710:	682c                	ld	a1,80(s0)
ffffffffc0200712:	00006517          	auipc	a0,0x6
ffffffffc0200716:	65650513          	addi	a0,a0,1622 # ffffffffc0206d68 <commands+0x5f8>
ffffffffc020071a:	a75ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020071e:	6c2c                	ld	a1,88(s0)
ffffffffc0200720:	00006517          	auipc	a0,0x6
ffffffffc0200724:	66050513          	addi	a0,a0,1632 # ffffffffc0206d80 <commands+0x610>
ffffffffc0200728:	a67ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020072c:	702c                	ld	a1,96(s0)
ffffffffc020072e:	00006517          	auipc	a0,0x6
ffffffffc0200732:	66a50513          	addi	a0,a0,1642 # ffffffffc0206d98 <commands+0x628>
ffffffffc0200736:	a59ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020073a:	742c                	ld	a1,104(s0)
ffffffffc020073c:	00006517          	auipc	a0,0x6
ffffffffc0200740:	67450513          	addi	a0,a0,1652 # ffffffffc0206db0 <commands+0x640>
ffffffffc0200744:	a4bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200748:	782c                	ld	a1,112(s0)
ffffffffc020074a:	00006517          	auipc	a0,0x6
ffffffffc020074e:	67e50513          	addi	a0,a0,1662 # ffffffffc0206dc8 <commands+0x658>
ffffffffc0200752:	a3dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200756:	7c2c                	ld	a1,120(s0)
ffffffffc0200758:	00006517          	auipc	a0,0x6
ffffffffc020075c:	68850513          	addi	a0,a0,1672 # ffffffffc0206de0 <commands+0x670>
ffffffffc0200760:	a2fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200764:	604c                	ld	a1,128(s0)
ffffffffc0200766:	00006517          	auipc	a0,0x6
ffffffffc020076a:	69250513          	addi	a0,a0,1682 # ffffffffc0206df8 <commands+0x688>
ffffffffc020076e:	a21ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200772:	644c                	ld	a1,136(s0)
ffffffffc0200774:	00006517          	auipc	a0,0x6
ffffffffc0200778:	69c50513          	addi	a0,a0,1692 # ffffffffc0206e10 <commands+0x6a0>
ffffffffc020077c:	a13ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200780:	684c                	ld	a1,144(s0)
ffffffffc0200782:	00006517          	auipc	a0,0x6
ffffffffc0200786:	6a650513          	addi	a0,a0,1702 # ffffffffc0206e28 <commands+0x6b8>
ffffffffc020078a:	a05ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020078e:	6c4c                	ld	a1,152(s0)
ffffffffc0200790:	00006517          	auipc	a0,0x6
ffffffffc0200794:	6b050513          	addi	a0,a0,1712 # ffffffffc0206e40 <commands+0x6d0>
ffffffffc0200798:	9f7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020079c:	704c                	ld	a1,160(s0)
ffffffffc020079e:	00006517          	auipc	a0,0x6
ffffffffc02007a2:	6ba50513          	addi	a0,a0,1722 # ffffffffc0206e58 <commands+0x6e8>
ffffffffc02007a6:	9e9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007aa:	744c                	ld	a1,168(s0)
ffffffffc02007ac:	00006517          	auipc	a0,0x6
ffffffffc02007b0:	6c450513          	addi	a0,a0,1732 # ffffffffc0206e70 <commands+0x700>
ffffffffc02007b4:	9dbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b8:	784c                	ld	a1,176(s0)
ffffffffc02007ba:	00006517          	auipc	a0,0x6
ffffffffc02007be:	6ce50513          	addi	a0,a0,1742 # ffffffffc0206e88 <commands+0x718>
ffffffffc02007c2:	9cdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007c6:	7c4c                	ld	a1,184(s0)
ffffffffc02007c8:	00006517          	auipc	a0,0x6
ffffffffc02007cc:	6d850513          	addi	a0,a0,1752 # ffffffffc0206ea0 <commands+0x730>
ffffffffc02007d0:	9bfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007d4:	606c                	ld	a1,192(s0)
ffffffffc02007d6:	00006517          	auipc	a0,0x6
ffffffffc02007da:	6e250513          	addi	a0,a0,1762 # ffffffffc0206eb8 <commands+0x748>
ffffffffc02007de:	9b1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007e2:	646c                	ld	a1,200(s0)
ffffffffc02007e4:	00006517          	auipc	a0,0x6
ffffffffc02007e8:	6ec50513          	addi	a0,a0,1772 # ffffffffc0206ed0 <commands+0x760>
ffffffffc02007ec:	9a3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007f0:	686c                	ld	a1,208(s0)
ffffffffc02007f2:	00006517          	auipc	a0,0x6
ffffffffc02007f6:	6f650513          	addi	a0,a0,1782 # ffffffffc0206ee8 <commands+0x778>
ffffffffc02007fa:	995ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200800:	00006517          	auipc	a0,0x6
ffffffffc0200804:	70050513          	addi	a0,a0,1792 # ffffffffc0206f00 <commands+0x790>
ffffffffc0200808:	987ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020080c:	706c                	ld	a1,224(s0)
ffffffffc020080e:	00006517          	auipc	a0,0x6
ffffffffc0200812:	70a50513          	addi	a0,a0,1802 # ffffffffc0206f18 <commands+0x7a8>
ffffffffc0200816:	979ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020081a:	746c                	ld	a1,232(s0)
ffffffffc020081c:	00006517          	auipc	a0,0x6
ffffffffc0200820:	71450513          	addi	a0,a0,1812 # ffffffffc0206f30 <commands+0x7c0>
ffffffffc0200824:	96bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200828:	786c                	ld	a1,240(s0)
ffffffffc020082a:	00006517          	auipc	a0,0x6
ffffffffc020082e:	71e50513          	addi	a0,a0,1822 # ffffffffc0206f48 <commands+0x7d8>
ffffffffc0200832:	95dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200836:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200838:	6402                	ld	s0,0(sp)
ffffffffc020083a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	72450513          	addi	a0,a0,1828 # ffffffffc0206f60 <commands+0x7f0>
}
ffffffffc0200844:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200846:	949ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020084a <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc020084a:	1141                	addi	sp,sp,-16
ffffffffc020084c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020084e:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200850:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200852:	00006517          	auipc	a0,0x6
ffffffffc0200856:	72650513          	addi	a0,a0,1830 # ffffffffc0206f78 <commands+0x808>
print_trapframe(struct trapframe *tf) {
ffffffffc020085a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020085c:	933ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200860:	8522                	mv	a0,s0
ffffffffc0200862:	e1bff0ef          	jal	ra,ffffffffc020067c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200866:	10043583          	ld	a1,256(s0)
ffffffffc020086a:	00006517          	auipc	a0,0x6
ffffffffc020086e:	72650513          	addi	a0,a0,1830 # ffffffffc0206f90 <commands+0x820>
ffffffffc0200872:	91dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200876:	10843583          	ld	a1,264(s0)
ffffffffc020087a:	00006517          	auipc	a0,0x6
ffffffffc020087e:	72e50513          	addi	a0,a0,1838 # ffffffffc0206fa8 <commands+0x838>
ffffffffc0200882:	90dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200886:	11043583          	ld	a1,272(s0)
ffffffffc020088a:	00006517          	auipc	a0,0x6
ffffffffc020088e:	73650513          	addi	a0,a0,1846 # ffffffffc0206fc0 <commands+0x850>
ffffffffc0200892:	8fdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	11843583          	ld	a1,280(s0)
}
ffffffffc020089a:	6402                	ld	s0,0(sp)
ffffffffc020089c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020089e:	00006517          	auipc	a0,0x6
ffffffffc02008a2:	73250513          	addi	a0,a0,1842 # ffffffffc0206fd0 <commands+0x860>
}
ffffffffc02008a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02008a8:	8e7ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02008ac <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ac:	1101                	addi	sp,sp,-32
ffffffffc02008ae:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008b0:	000ac497          	auipc	s1,0xac
ffffffffc02008b4:	e1848493          	addi	s1,s1,-488 # ffffffffc02ac6c8 <check_mm_struct>
ffffffffc02008b8:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ba:	e822                	sd	s0,16(sp)
ffffffffc02008bc:	ec06                	sd	ra,24(sp)
ffffffffc02008be:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008c0:	cbbd                	beqz	a5,ffffffffc0200936 <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008c2:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008c6:	11053583          	ld	a1,272(a0)
ffffffffc02008ca:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ce:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008d2:	cba1                	beqz	a5,ffffffffc0200922 <pgfault_handler+0x76>
ffffffffc02008d4:	11843703          	ld	a4,280(s0)
ffffffffc02008d8:	47bd                	li	a5,15
ffffffffc02008da:	05700693          	li	a3,87
ffffffffc02008de:	00f70463          	beq	a4,a5,ffffffffc02008e6 <pgfault_handler+0x3a>
ffffffffc02008e2:	05200693          	li	a3,82
ffffffffc02008e6:	00006517          	auipc	a0,0x6
ffffffffc02008ea:	31250513          	addi	a0,a0,786 # ffffffffc0206bf8 <commands+0x488>
ffffffffc02008ee:	8a1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008f2:	6088                	ld	a0,0(s1)
ffffffffc02008f4:	c129                	beqz	a0,ffffffffc0200936 <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008f6:	000ac797          	auipc	a5,0xac
ffffffffc02008fa:	c9a78793          	addi	a5,a5,-870 # ffffffffc02ac590 <current>
ffffffffc02008fe:	6398                	ld	a4,0(a5)
ffffffffc0200900:	000ac797          	auipc	a5,0xac
ffffffffc0200904:	c9878793          	addi	a5,a5,-872 # ffffffffc02ac598 <idleproc>
ffffffffc0200908:	639c                	ld	a5,0(a5)
ffffffffc020090a:	04f71763          	bne	a4,a5,ffffffffc0200958 <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020090e:	11043603          	ld	a2,272(s0)
ffffffffc0200912:	11843583          	ld	a1,280(s0)
}
ffffffffc0200916:	6442                	ld	s0,16(sp)
ffffffffc0200918:	60e2                	ld	ra,24(sp)
ffffffffc020091a:	64a2                	ld	s1,8(sp)
ffffffffc020091c:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020091e:	08a0406f          	j	ffffffffc02049a8 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200922:	11843703          	ld	a4,280(s0)
ffffffffc0200926:	47bd                	li	a5,15
ffffffffc0200928:	05500613          	li	a2,85
ffffffffc020092c:	05700693          	li	a3,87
ffffffffc0200930:	faf719e3          	bne	a4,a5,ffffffffc02008e2 <pgfault_handler+0x36>
ffffffffc0200934:	bf4d                	j	ffffffffc02008e6 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc0200936:	000ac797          	auipc	a5,0xac
ffffffffc020093a:	c5a78793          	addi	a5,a5,-934 # ffffffffc02ac590 <current>
ffffffffc020093e:	639c                	ld	a5,0(a5)
ffffffffc0200940:	cf85                	beqz	a5,ffffffffc0200978 <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200942:	11043603          	ld	a2,272(s0)
ffffffffc0200946:	11843583          	ld	a1,280(s0)
}
ffffffffc020094a:	6442                	ld	s0,16(sp)
ffffffffc020094c:	60e2                	ld	ra,24(sp)
ffffffffc020094e:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200950:	7788                	ld	a0,40(a5)
}
ffffffffc0200952:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200954:	0540406f          	j	ffffffffc02049a8 <do_pgfault>
        assert(current == idleproc);
ffffffffc0200958:	00006697          	auipc	a3,0x6
ffffffffc020095c:	2c068693          	addi	a3,a3,704 # ffffffffc0206c18 <commands+0x4a8>
ffffffffc0200960:	00006617          	auipc	a2,0x6
ffffffffc0200964:	2d060613          	addi	a2,a2,720 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0200968:	06b00593          	li	a1,107
ffffffffc020096c:	00006517          	auipc	a0,0x6
ffffffffc0200970:	2dc50513          	addi	a0,a0,732 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0200974:	b11ff0ef          	jal	ra,ffffffffc0200484 <__panic>
            print_trapframe(tf);
ffffffffc0200978:	8522                	mv	a0,s0
ffffffffc020097a:	ed1ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020097e:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200982:	11043583          	ld	a1,272(s0)
ffffffffc0200986:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020098a:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020098e:	e399                	bnez	a5,ffffffffc0200994 <pgfault_handler+0xe8>
ffffffffc0200990:	05500613          	li	a2,85
ffffffffc0200994:	11843703          	ld	a4,280(s0)
ffffffffc0200998:	47bd                	li	a5,15
ffffffffc020099a:	02f70663          	beq	a4,a5,ffffffffc02009c6 <pgfault_handler+0x11a>
ffffffffc020099e:	05200693          	li	a3,82
ffffffffc02009a2:	00006517          	auipc	a0,0x6
ffffffffc02009a6:	25650513          	addi	a0,a0,598 # ffffffffc0206bf8 <commands+0x488>
ffffffffc02009aa:	fe4ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009ae:	00006617          	auipc	a2,0x6
ffffffffc02009b2:	2b260613          	addi	a2,a2,690 # ffffffffc0206c60 <commands+0x4f0>
ffffffffc02009b6:	07200593          	li	a1,114
ffffffffc02009ba:	00006517          	auipc	a0,0x6
ffffffffc02009be:	28e50513          	addi	a0,a0,654 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc02009c2:	ac3ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009c6:	05700693          	li	a3,87
ffffffffc02009ca:	bfe1                	j	ffffffffc02009a2 <pgfault_handler+0xf6>

ffffffffc02009cc <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009cc:	11853783          	ld	a5,280(a0)
ffffffffc02009d0:	577d                	li	a4,-1
ffffffffc02009d2:	8305                	srli	a4,a4,0x1
ffffffffc02009d4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02009d6:	472d                	li	a4,11
ffffffffc02009d8:	08f76763          	bltu	a4,a5,ffffffffc0200a66 <interrupt_handler+0x9a>
ffffffffc02009dc:	00006717          	auipc	a4,0x6
ffffffffc02009e0:	f7070713          	addi	a4,a4,-144 # ffffffffc020694c <commands+0x1dc>
ffffffffc02009e4:	078a                	slli	a5,a5,0x2
ffffffffc02009e6:	97ba                	add	a5,a5,a4
ffffffffc02009e8:	439c                	lw	a5,0(a5)
ffffffffc02009ea:	97ba                	add	a5,a5,a4
ffffffffc02009ec:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009ee:	00006517          	auipc	a0,0x6
ffffffffc02009f2:	1ca50513          	addi	a0,a0,458 # ffffffffc0206bb8 <commands+0x448>
ffffffffc02009f6:	f98ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009fa:	00006517          	auipc	a0,0x6
ffffffffc02009fe:	19e50513          	addi	a0,a0,414 # ffffffffc0206b98 <commands+0x428>
ffffffffc0200a02:	f8cff06f          	j	ffffffffc020018e <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200a06:	00006517          	auipc	a0,0x6
ffffffffc0200a0a:	15250513          	addi	a0,a0,338 # ffffffffc0206b58 <commands+0x3e8>
ffffffffc0200a0e:	f80ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a12:	00006517          	auipc	a0,0x6
ffffffffc0200a16:	16650513          	addi	a0,a0,358 # ffffffffc0206b78 <commands+0x408>
ffffffffc0200a1a:	f74ff06f          	j	ffffffffc020018e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a1e:	00006517          	auipc	a0,0x6
ffffffffc0200a22:	1ba50513          	addi	a0,a0,442 # ffffffffc0206bd8 <commands+0x468>
ffffffffc0200a26:	f68ff06f          	j	ffffffffc020018e <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a2a:	1141                	addi	sp,sp,-16
ffffffffc0200a2c:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a2e:	b3fff0ef          	jal	ra,ffffffffc020056c <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a32:	000ac797          	auipc	a5,0xac
ffffffffc0200a36:	b7e78793          	addi	a5,a5,-1154 # ffffffffc02ac5b0 <ticks>
ffffffffc0200a3a:	639c                	ld	a5,0(a5)
ffffffffc0200a3c:	06400713          	li	a4,100
ffffffffc0200a40:	0785                	addi	a5,a5,1
ffffffffc0200a42:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a46:	000ac697          	auipc	a3,0xac
ffffffffc0200a4a:	b6f6b523          	sd	a5,-1174(a3) # ffffffffc02ac5b0 <ticks>
ffffffffc0200a4e:	eb09                	bnez	a4,ffffffffc0200a60 <interrupt_handler+0x94>
ffffffffc0200a50:	000ac797          	auipc	a5,0xac
ffffffffc0200a54:	b4078793          	addi	a5,a5,-1216 # ffffffffc02ac590 <current>
ffffffffc0200a58:	639c                	ld	a5,0(a5)
ffffffffc0200a5a:	c399                	beqz	a5,ffffffffc0200a60 <interrupt_handler+0x94>
                current->need_resched = 1;
ffffffffc0200a5c:	4705                	li	a4,1
ffffffffc0200a5e:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a60:	60a2                	ld	ra,8(sp)
ffffffffc0200a62:	0141                	addi	sp,sp,16
ffffffffc0200a64:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a66:	de5ff06f          	j	ffffffffc020084a <print_trapframe>

ffffffffc0200a6a <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a6a:	11853783          	ld	a5,280(a0)
ffffffffc0200a6e:	473d                	li	a4,15
ffffffffc0200a70:	1af76e63          	bltu	a4,a5,ffffffffc0200c2c <exception_handler+0x1c2>
ffffffffc0200a74:	00006717          	auipc	a4,0x6
ffffffffc0200a78:	f0870713          	addi	a4,a4,-248 # ffffffffc020697c <commands+0x20c>
ffffffffc0200a7c:	078a                	slli	a5,a5,0x2
ffffffffc0200a7e:	97ba                	add	a5,a5,a4
ffffffffc0200a80:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a82:	1101                	addi	sp,sp,-32
ffffffffc0200a84:	e822                	sd	s0,16(sp)
ffffffffc0200a86:	ec06                	sd	ra,24(sp)
ffffffffc0200a88:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a8a:	97ba                	add	a5,a5,a4
ffffffffc0200a8c:	842a                	mv	s0,a0
ffffffffc0200a8e:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a90:	00006517          	auipc	a0,0x6
ffffffffc0200a94:	02050513          	addi	a0,a0,32 # ffffffffc0206ab0 <commands+0x340>
ffffffffc0200a98:	ef6ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            tf->epc += 4;
ffffffffc0200a9c:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200aa0:	60e2                	ld	ra,24(sp)
ffffffffc0200aa2:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200aa4:	0791                	addi	a5,a5,4
ffffffffc0200aa6:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200aaa:	6442                	ld	s0,16(sp)
ffffffffc0200aac:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200aae:	6380506f          	j	ffffffffc02060e6 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	01e50513          	addi	a0,a0,30 # ffffffffc0206ad0 <commands+0x360>
}
ffffffffc0200aba:	6442                	ld	s0,16(sp)
ffffffffc0200abc:	60e2                	ld	ra,24(sp)
ffffffffc0200abe:	64a2                	ld	s1,8(sp)
ffffffffc0200ac0:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ac2:	eccff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ac6:	00006517          	auipc	a0,0x6
ffffffffc0200aca:	02a50513          	addi	a0,a0,42 # ffffffffc0206af0 <commands+0x380>
ffffffffc0200ace:	b7f5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ad0:	00006517          	auipc	a0,0x6
ffffffffc0200ad4:	04050513          	addi	a0,a0,64 # ffffffffc0206b10 <commands+0x3a0>
ffffffffc0200ad8:	b7cd                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ada:	00006517          	auipc	a0,0x6
ffffffffc0200ade:	04e50513          	addi	a0,a0,78 # ffffffffc0206b28 <commands+0x3b8>
ffffffffc0200ae2:	eacff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae6:	8522                	mv	a0,s0
ffffffffc0200ae8:	dc5ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200aec:	84aa                	mv	s1,a0
ffffffffc0200aee:	14051163          	bnez	a0,ffffffffc0200c30 <exception_handler+0x1c6>
}
ffffffffc0200af2:	60e2                	ld	ra,24(sp)
ffffffffc0200af4:	6442                	ld	s0,16(sp)
ffffffffc0200af6:	64a2                	ld	s1,8(sp)
ffffffffc0200af8:	6105                	addi	sp,sp,32
ffffffffc0200afa:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200afc:	00006517          	auipc	a0,0x6
ffffffffc0200b00:	04450513          	addi	a0,a0,68 # ffffffffc0206b40 <commands+0x3d0>
ffffffffc0200b04:	e8aff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b08:	8522                	mv	a0,s0
ffffffffc0200b0a:	da3ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200b0e:	84aa                	mv	s1,a0
ffffffffc0200b10:	d16d                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b12:	8522                	mv	a0,s0
ffffffffc0200b14:	d37ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b18:	86a6                	mv	a3,s1
ffffffffc0200b1a:	00006617          	auipc	a2,0x6
ffffffffc0200b1e:	f4660613          	addi	a2,a2,-186 # ffffffffc0206a60 <commands+0x2f0>
ffffffffc0200b22:	0f800593          	li	a1,248
ffffffffc0200b26:	00006517          	auipc	a0,0x6
ffffffffc0200b2a:	12250513          	addi	a0,a0,290 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0200b2e:	957ff0ef          	jal	ra,ffffffffc0200484 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b32:	00006517          	auipc	a0,0x6
ffffffffc0200b36:	e8e50513          	addi	a0,a0,-370 # ffffffffc02069c0 <commands+0x250>
ffffffffc0200b3a:	b741                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b3c:	00006517          	auipc	a0,0x6
ffffffffc0200b40:	ea450513          	addi	a0,a0,-348 # ffffffffc02069e0 <commands+0x270>
ffffffffc0200b44:	bf9d                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b46:	00006517          	auipc	a0,0x6
ffffffffc0200b4a:	eba50513          	addi	a0,a0,-326 # ffffffffc0206a00 <commands+0x290>
ffffffffc0200b4e:	b7b5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b50:	00006517          	auipc	a0,0x6
ffffffffc0200b54:	ec850513          	addi	a0,a0,-312 # ffffffffc0206a18 <commands+0x2a8>
ffffffffc0200b58:	e36ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b5c:	6458                	ld	a4,136(s0)
ffffffffc0200b5e:	47a9                	li	a5,10
ffffffffc0200b60:	f8f719e3          	bne	a4,a5,ffffffffc0200af2 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b64:	10843783          	ld	a5,264(s0)
ffffffffc0200b68:	0791                	addi	a5,a5,4
ffffffffc0200b6a:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b6e:	578050ef          	jal	ra,ffffffffc02060e6 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b72:	000ac797          	auipc	a5,0xac
ffffffffc0200b76:	a1e78793          	addi	a5,a5,-1506 # ffffffffc02ac590 <current>
ffffffffc0200b7a:	639c                	ld	a5,0(a5)
ffffffffc0200b7c:	8522                	mv	a0,s0
}
ffffffffc0200b7e:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b80:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b82:	60e2                	ld	ra,24(sp)
ffffffffc0200b84:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b86:	6589                	lui	a1,0x2
ffffffffc0200b88:	95be                	add	a1,a1,a5
}
ffffffffc0200b8a:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b8c:	2220006f          	j	ffffffffc0200dae <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b90:	00006517          	auipc	a0,0x6
ffffffffc0200b94:	e9850513          	addi	a0,a0,-360 # ffffffffc0206a28 <commands+0x2b8>
ffffffffc0200b98:	b70d                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b9a:	00006517          	auipc	a0,0x6
ffffffffc0200b9e:	eae50513          	addi	a0,a0,-338 # ffffffffc0206a48 <commands+0x2d8>
ffffffffc0200ba2:	decff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ba6:	8522                	mv	a0,s0
ffffffffc0200ba8:	d05ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200bac:	84aa                	mv	s1,a0
ffffffffc0200bae:	d131                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bb0:	8522                	mv	a0,s0
ffffffffc0200bb2:	c99ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bb6:	86a6                	mv	a3,s1
ffffffffc0200bb8:	00006617          	auipc	a2,0x6
ffffffffc0200bbc:	ea860613          	addi	a2,a2,-344 # ffffffffc0206a60 <commands+0x2f0>
ffffffffc0200bc0:	0cd00593          	li	a1,205
ffffffffc0200bc4:	00006517          	auipc	a0,0x6
ffffffffc0200bc8:	08450513          	addi	a0,a0,132 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0200bcc:	8b9ff0ef          	jal	ra,ffffffffc0200484 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bd0:	00006517          	auipc	a0,0x6
ffffffffc0200bd4:	ec850513          	addi	a0,a0,-312 # ffffffffc0206a98 <commands+0x328>
ffffffffc0200bd8:	db6ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bdc:	8522                	mv	a0,s0
ffffffffc0200bde:	ccfff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200be2:	84aa                	mv	s1,a0
ffffffffc0200be4:	f00507e3          	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200be8:	8522                	mv	a0,s0
ffffffffc0200bea:	c61ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bee:	86a6                	mv	a3,s1
ffffffffc0200bf0:	00006617          	auipc	a2,0x6
ffffffffc0200bf4:	e7060613          	addi	a2,a2,-400 # ffffffffc0206a60 <commands+0x2f0>
ffffffffc0200bf8:	0d700593          	li	a1,215
ffffffffc0200bfc:	00006517          	auipc	a0,0x6
ffffffffc0200c00:	04c50513          	addi	a0,a0,76 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0200c04:	881ff0ef          	jal	ra,ffffffffc0200484 <__panic>
}
ffffffffc0200c08:	6442                	ld	s0,16(sp)
ffffffffc0200c0a:	60e2                	ld	ra,24(sp)
ffffffffc0200c0c:	64a2                	ld	s1,8(sp)
ffffffffc0200c0e:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c10:	c3bff06f          	j	ffffffffc020084a <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c14:	00006617          	auipc	a2,0x6
ffffffffc0200c18:	e6c60613          	addi	a2,a2,-404 # ffffffffc0206a80 <commands+0x310>
ffffffffc0200c1c:	0d100593          	li	a1,209
ffffffffc0200c20:	00006517          	auipc	a0,0x6
ffffffffc0200c24:	02850513          	addi	a0,a0,40 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0200c28:	85dff0ef          	jal	ra,ffffffffc0200484 <__panic>
            print_trapframe(tf);
ffffffffc0200c2c:	c1fff06f          	j	ffffffffc020084a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c30:	8522                	mv	a0,s0
ffffffffc0200c32:	c19ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c36:	86a6                	mv	a3,s1
ffffffffc0200c38:	00006617          	auipc	a2,0x6
ffffffffc0200c3c:	e2860613          	addi	a2,a2,-472 # ffffffffc0206a60 <commands+0x2f0>
ffffffffc0200c40:	0f100593          	li	a1,241
ffffffffc0200c44:	00006517          	auipc	a0,0x6
ffffffffc0200c48:	00450513          	addi	a0,a0,4 # ffffffffc0206c48 <commands+0x4d8>
ffffffffc0200c4c:	839ff0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0200c50 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c50:	1101                	addi	sp,sp,-32
ffffffffc0200c52:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c54:	000ac417          	auipc	s0,0xac
ffffffffc0200c58:	93c40413          	addi	s0,s0,-1732 # ffffffffc02ac590 <current>
ffffffffc0200c5c:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c5e:	ec06                	sd	ra,24(sp)
ffffffffc0200c60:	e426                	sd	s1,8(sp)
ffffffffc0200c62:	e04a                	sd	s2,0(sp)
ffffffffc0200c64:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c68:	cf1d                	beqz	a4,ffffffffc0200ca6 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c6a:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c6e:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c72:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c74:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c78:	0206c463          	bltz	a3,ffffffffc0200ca0 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c7c:	defff0ef          	jal	ra,ffffffffc0200a6a <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c80:	601c                	ld	a5,0(s0)
ffffffffc0200c82:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c86:	e499                	bnez	s1,ffffffffc0200c94 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c88:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c8c:	8b05                	andi	a4,a4,1
ffffffffc0200c8e:	e339                	bnez	a4,ffffffffc0200cd4 <trap+0x84>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c90:	6f9c                	ld	a5,24(a5)
ffffffffc0200c92:	eb95                	bnez	a5,ffffffffc0200cc6 <trap+0x76>
                schedule();
            }
        }
    }
}
ffffffffc0200c94:	60e2                	ld	ra,24(sp)
ffffffffc0200c96:	6442                	ld	s0,16(sp)
ffffffffc0200c98:	64a2                	ld	s1,8(sp)
ffffffffc0200c9a:	6902                	ld	s2,0(sp)
ffffffffc0200c9c:	6105                	addi	sp,sp,32
ffffffffc0200c9e:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200ca0:	d2dff0ef          	jal	ra,ffffffffc02009cc <interrupt_handler>
ffffffffc0200ca4:	bff1                	j	ffffffffc0200c80 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200ca6:	0006c963          	bltz	a3,ffffffffc0200cb8 <trap+0x68>
}
ffffffffc0200caa:	6442                	ld	s0,16(sp)
ffffffffc0200cac:	60e2                	ld	ra,24(sp)
ffffffffc0200cae:	64a2                	ld	s1,8(sp)
ffffffffc0200cb0:	6902                	ld	s2,0(sp)
ffffffffc0200cb2:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200cb4:	db7ff06f          	j	ffffffffc0200a6a <exception_handler>
}
ffffffffc0200cb8:	6442                	ld	s0,16(sp)
ffffffffc0200cba:	60e2                	ld	ra,24(sp)
ffffffffc0200cbc:	64a2                	ld	s1,8(sp)
ffffffffc0200cbe:	6902                	ld	s2,0(sp)
ffffffffc0200cc0:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cc2:	d0bff06f          	j	ffffffffc02009cc <interrupt_handler>
}
ffffffffc0200cc6:	6442                	ld	s0,16(sp)
ffffffffc0200cc8:	60e2                	ld	ra,24(sp)
ffffffffc0200cca:	64a2                	ld	s1,8(sp)
ffffffffc0200ccc:	6902                	ld	s2,0(sp)
ffffffffc0200cce:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cd0:	3200506f          	j	ffffffffc0205ff0 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cd4:	555d                	li	a0,-9
ffffffffc0200cd6:	714040ef          	jal	ra,ffffffffc02053ea <do_exit>
ffffffffc0200cda:	601c                	ld	a5,0(s0)
ffffffffc0200cdc:	bf55                	j	ffffffffc0200c90 <trap+0x40>
	...

ffffffffc0200ce0 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ce0:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ce4:	00011463          	bnez	sp,ffffffffc0200cec <__alltraps+0xc>
ffffffffc0200ce8:	14002173          	csrr	sp,sscratch
ffffffffc0200cec:	712d                	addi	sp,sp,-288
ffffffffc0200cee:	e002                	sd	zero,0(sp)
ffffffffc0200cf0:	e406                	sd	ra,8(sp)
ffffffffc0200cf2:	ec0e                	sd	gp,24(sp)
ffffffffc0200cf4:	f012                	sd	tp,32(sp)
ffffffffc0200cf6:	f416                	sd	t0,40(sp)
ffffffffc0200cf8:	f81a                	sd	t1,48(sp)
ffffffffc0200cfa:	fc1e                	sd	t2,56(sp)
ffffffffc0200cfc:	e0a2                	sd	s0,64(sp)
ffffffffc0200cfe:	e4a6                	sd	s1,72(sp)
ffffffffc0200d00:	e8aa                	sd	a0,80(sp)
ffffffffc0200d02:	ecae                	sd	a1,88(sp)
ffffffffc0200d04:	f0b2                	sd	a2,96(sp)
ffffffffc0200d06:	f4b6                	sd	a3,104(sp)
ffffffffc0200d08:	f8ba                	sd	a4,112(sp)
ffffffffc0200d0a:	fcbe                	sd	a5,120(sp)
ffffffffc0200d0c:	e142                	sd	a6,128(sp)
ffffffffc0200d0e:	e546                	sd	a7,136(sp)
ffffffffc0200d10:	e94a                	sd	s2,144(sp)
ffffffffc0200d12:	ed4e                	sd	s3,152(sp)
ffffffffc0200d14:	f152                	sd	s4,160(sp)
ffffffffc0200d16:	f556                	sd	s5,168(sp)
ffffffffc0200d18:	f95a                	sd	s6,176(sp)
ffffffffc0200d1a:	fd5e                	sd	s7,184(sp)
ffffffffc0200d1c:	e1e2                	sd	s8,192(sp)
ffffffffc0200d1e:	e5e6                	sd	s9,200(sp)
ffffffffc0200d20:	e9ea                	sd	s10,208(sp)
ffffffffc0200d22:	edee                	sd	s11,216(sp)
ffffffffc0200d24:	f1f2                	sd	t3,224(sp)
ffffffffc0200d26:	f5f6                	sd	t4,232(sp)
ffffffffc0200d28:	f9fa                	sd	t5,240(sp)
ffffffffc0200d2a:	fdfe                	sd	t6,248(sp)
ffffffffc0200d2c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d30:	100024f3          	csrr	s1,sstatus
ffffffffc0200d34:	14102973          	csrr	s2,sepc
ffffffffc0200d38:	143029f3          	csrr	s3,stval
ffffffffc0200d3c:	14202a73          	csrr	s4,scause
ffffffffc0200d40:	e822                	sd	s0,16(sp)
ffffffffc0200d42:	e226                	sd	s1,256(sp)
ffffffffc0200d44:	e64a                	sd	s2,264(sp)
ffffffffc0200d46:	ea4e                	sd	s3,272(sp)
ffffffffc0200d48:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d4a:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d4c:	f05ff0ef          	jal	ra,ffffffffc0200c50 <trap>

ffffffffc0200d50 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d50:	6492                	ld	s1,256(sp)
ffffffffc0200d52:	6932                	ld	s2,264(sp)
ffffffffc0200d54:	1004f413          	andi	s0,s1,256
ffffffffc0200d58:	e401                	bnez	s0,ffffffffc0200d60 <__trapret+0x10>
ffffffffc0200d5a:	1200                	addi	s0,sp,288
ffffffffc0200d5c:	14041073          	csrw	sscratch,s0
ffffffffc0200d60:	10049073          	csrw	sstatus,s1
ffffffffc0200d64:	14191073          	csrw	sepc,s2
ffffffffc0200d68:	60a2                	ld	ra,8(sp)
ffffffffc0200d6a:	61e2                	ld	gp,24(sp)
ffffffffc0200d6c:	7202                	ld	tp,32(sp)
ffffffffc0200d6e:	72a2                	ld	t0,40(sp)
ffffffffc0200d70:	7342                	ld	t1,48(sp)
ffffffffc0200d72:	73e2                	ld	t2,56(sp)
ffffffffc0200d74:	6406                	ld	s0,64(sp)
ffffffffc0200d76:	64a6                	ld	s1,72(sp)
ffffffffc0200d78:	6546                	ld	a0,80(sp)
ffffffffc0200d7a:	65e6                	ld	a1,88(sp)
ffffffffc0200d7c:	7606                	ld	a2,96(sp)
ffffffffc0200d7e:	76a6                	ld	a3,104(sp)
ffffffffc0200d80:	7746                	ld	a4,112(sp)
ffffffffc0200d82:	77e6                	ld	a5,120(sp)
ffffffffc0200d84:	680a                	ld	a6,128(sp)
ffffffffc0200d86:	68aa                	ld	a7,136(sp)
ffffffffc0200d88:	694a                	ld	s2,144(sp)
ffffffffc0200d8a:	69ea                	ld	s3,152(sp)
ffffffffc0200d8c:	7a0a                	ld	s4,160(sp)
ffffffffc0200d8e:	7aaa                	ld	s5,168(sp)
ffffffffc0200d90:	7b4a                	ld	s6,176(sp)
ffffffffc0200d92:	7bea                	ld	s7,184(sp)
ffffffffc0200d94:	6c0e                	ld	s8,192(sp)
ffffffffc0200d96:	6cae                	ld	s9,200(sp)
ffffffffc0200d98:	6d4e                	ld	s10,208(sp)
ffffffffc0200d9a:	6dee                	ld	s11,216(sp)
ffffffffc0200d9c:	7e0e                	ld	t3,224(sp)
ffffffffc0200d9e:	7eae                	ld	t4,232(sp)
ffffffffc0200da0:	7f4e                	ld	t5,240(sp)
ffffffffc0200da2:	7fee                	ld	t6,248(sp)
ffffffffc0200da4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200da6:	10200073          	sret

ffffffffc0200daa <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200daa:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200dac:	b755                	j	ffffffffc0200d50 <__trapret>

ffffffffc0200dae <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200dae:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76a0>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200db2:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200db6:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200dba:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200dbe:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200dc2:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200dc6:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200dca:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200dce:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200dd2:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200dd4:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200dd6:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200dd8:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200dda:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200ddc:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dde:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200de0:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200de2:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200de4:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200de6:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200de8:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dea:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200dec:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dee:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200df0:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200df2:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200df4:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200df6:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200df8:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dfa:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dfc:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dfe:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200e00:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200e02:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200e04:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200e06:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200e08:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200e0a:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200e0c:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200e0e:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200e10:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200e12:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200e14:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200e16:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e18:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e1a:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e1c:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e1e:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e20:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e22:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e24:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e26:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e28:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e2a:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e2c:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e2e:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e30:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e32:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e34:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e36:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e38:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e3a:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e3c:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e3e:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e40:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e42:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e44:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e46:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e48:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e4a:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e4c:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e4e:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e50:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e52:	812e                	mv	sp,a1
ffffffffc0200e54:	bdf5                	j	ffffffffc0200d50 <__trapret>

ffffffffc0200e56 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e56:	000ab797          	auipc	a5,0xab
ffffffffc0200e5a:	76278793          	addi	a5,a5,1890 # ffffffffc02ac5b8 <free_area>
ffffffffc0200e5e:	e79c                	sd	a5,8(a5)
ffffffffc0200e60:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e62:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e66:	8082                	ret

ffffffffc0200e68 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e68:	000ab517          	auipc	a0,0xab
ffffffffc0200e6c:	76056503          	lwu	a0,1888(a0) # ffffffffc02ac5c8 <free_area+0x10>
ffffffffc0200e70:	8082                	ret

ffffffffc0200e72 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e72:	715d                	addi	sp,sp,-80
ffffffffc0200e74:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e76:	000ab917          	auipc	s2,0xab
ffffffffc0200e7a:	74290913          	addi	s2,s2,1858 # ffffffffc02ac5b8 <free_area>
ffffffffc0200e7e:	00893783          	ld	a5,8(s2)
ffffffffc0200e82:	e486                	sd	ra,72(sp)
ffffffffc0200e84:	e0a2                	sd	s0,64(sp)
ffffffffc0200e86:	fc26                	sd	s1,56(sp)
ffffffffc0200e88:	f44e                	sd	s3,40(sp)
ffffffffc0200e8a:	f052                	sd	s4,32(sp)
ffffffffc0200e8c:	ec56                	sd	s5,24(sp)
ffffffffc0200e8e:	e85a                	sd	s6,16(sp)
ffffffffc0200e90:	e45e                	sd	s7,8(sp)
ffffffffc0200e92:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e94:	31278463          	beq	a5,s2,ffffffffc020119c <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e98:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200e9c:	8305                	srli	a4,a4,0x1
ffffffffc0200e9e:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200ea0:	30070263          	beqz	a4,ffffffffc02011a4 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200ea4:	4401                	li	s0,0
ffffffffc0200ea6:	4481                	li	s1,0
ffffffffc0200ea8:	a031                	j	ffffffffc0200eb4 <default_check+0x42>
ffffffffc0200eaa:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200eae:	8b09                	andi	a4,a4,2
ffffffffc0200eb0:	2e070a63          	beqz	a4,ffffffffc02011a4 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200eb4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200eb8:	679c                	ld	a5,8(a5)
ffffffffc0200eba:	2485                	addiw	s1,s1,1
ffffffffc0200ebc:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ebe:	ff2796e3          	bne	a5,s2,ffffffffc0200eaa <default_check+0x38>
ffffffffc0200ec2:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200ec4:	05c010ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
ffffffffc0200ec8:	73351e63          	bne	a0,s3,ffffffffc0201604 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ecc:	4505                	li	a0,1
ffffffffc0200ece:	785000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200ed2:	8a2a                	mv	s4,a0
ffffffffc0200ed4:	46050863          	beqz	a0,ffffffffc0201344 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ed8:	4505                	li	a0,1
ffffffffc0200eda:	779000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200ede:	89aa                	mv	s3,a0
ffffffffc0200ee0:	74050263          	beqz	a0,ffffffffc0201624 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ee4:	4505                	li	a0,1
ffffffffc0200ee6:	76d000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200eea:	8aaa                	mv	s5,a0
ffffffffc0200eec:	4c050c63          	beqz	a0,ffffffffc02013c4 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ef0:	2d3a0a63          	beq	s4,s3,ffffffffc02011c4 <default_check+0x352>
ffffffffc0200ef4:	2caa0863          	beq	s4,a0,ffffffffc02011c4 <default_check+0x352>
ffffffffc0200ef8:	2ca98663          	beq	s3,a0,ffffffffc02011c4 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200efc:	000a2783          	lw	a5,0(s4)
ffffffffc0200f00:	2e079263          	bnez	a5,ffffffffc02011e4 <default_check+0x372>
ffffffffc0200f04:	0009a783          	lw	a5,0(s3)
ffffffffc0200f08:	2c079e63          	bnez	a5,ffffffffc02011e4 <default_check+0x372>
ffffffffc0200f0c:	411c                	lw	a5,0(a0)
ffffffffc0200f0e:	2c079b63          	bnez	a5,ffffffffc02011e4 <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200f12:	000ab797          	auipc	a5,0xab
ffffffffc0200f16:	6d678793          	addi	a5,a5,1750 # ffffffffc02ac5e8 <pages>
ffffffffc0200f1a:	639c                	ld	a5,0(a5)
ffffffffc0200f1c:	00008717          	auipc	a4,0x8
ffffffffc0200f20:	e9c70713          	addi	a4,a4,-356 # ffffffffc0208db8 <nbase>
ffffffffc0200f24:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f26:	000ab717          	auipc	a4,0xab
ffffffffc0200f2a:	65270713          	addi	a4,a4,1618 # ffffffffc02ac578 <npage>
ffffffffc0200f2e:	6314                	ld	a3,0(a4)
ffffffffc0200f30:	40fa0733          	sub	a4,s4,a5
ffffffffc0200f34:	8719                	srai	a4,a4,0x6
ffffffffc0200f36:	9732                	add	a4,a4,a2
ffffffffc0200f38:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f3a:	0732                	slli	a4,a4,0xc
ffffffffc0200f3c:	2cd77463          	bleu	a3,a4,ffffffffc0201204 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200f40:	40f98733          	sub	a4,s3,a5
ffffffffc0200f44:	8719                	srai	a4,a4,0x6
ffffffffc0200f46:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f48:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f4a:	4ed77d63          	bleu	a3,a4,ffffffffc0201444 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200f4e:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f52:	8799                	srai	a5,a5,0x6
ffffffffc0200f54:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f56:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f58:	34d7f663          	bleu	a3,a5,ffffffffc02012a4 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200f5c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f5e:	00093c03          	ld	s8,0(s2)
ffffffffc0200f62:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f66:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200f6a:	000ab797          	auipc	a5,0xab
ffffffffc0200f6e:	6527bb23          	sd	s2,1622(a5) # ffffffffc02ac5c0 <free_area+0x8>
ffffffffc0200f72:	000ab797          	auipc	a5,0xab
ffffffffc0200f76:	6527b323          	sd	s2,1606(a5) # ffffffffc02ac5b8 <free_area>
    nr_free = 0;
ffffffffc0200f7a:	000ab797          	auipc	a5,0xab
ffffffffc0200f7e:	6407a723          	sw	zero,1614(a5) # ffffffffc02ac5c8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f82:	6d1000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200f86:	2e051f63          	bnez	a0,ffffffffc0201284 <default_check+0x412>
    free_page(p0);
ffffffffc0200f8a:	4585                	li	a1,1
ffffffffc0200f8c:	8552                	mv	a0,s4
ffffffffc0200f8e:	74d000ef          	jal	ra,ffffffffc0201eda <free_pages>
    free_page(p1);
ffffffffc0200f92:	4585                	li	a1,1
ffffffffc0200f94:	854e                	mv	a0,s3
ffffffffc0200f96:	745000ef          	jal	ra,ffffffffc0201eda <free_pages>
    free_page(p2);
ffffffffc0200f9a:	4585                	li	a1,1
ffffffffc0200f9c:	8556                	mv	a0,s5
ffffffffc0200f9e:	73d000ef          	jal	ra,ffffffffc0201eda <free_pages>
    assert(nr_free == 3);
ffffffffc0200fa2:	01092703          	lw	a4,16(s2)
ffffffffc0200fa6:	478d                	li	a5,3
ffffffffc0200fa8:	2af71e63          	bne	a4,a5,ffffffffc0201264 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fac:	4505                	li	a0,1
ffffffffc0200fae:	6a5000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200fb2:	89aa                	mv	s3,a0
ffffffffc0200fb4:	28050863          	beqz	a0,ffffffffc0201244 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fb8:	4505                	li	a0,1
ffffffffc0200fba:	699000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200fbe:	8aaa                	mv	s5,a0
ffffffffc0200fc0:	3e050263          	beqz	a0,ffffffffc02013a4 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fc4:	4505                	li	a0,1
ffffffffc0200fc6:	68d000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200fca:	8a2a                	mv	s4,a0
ffffffffc0200fcc:	3a050c63          	beqz	a0,ffffffffc0201384 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200fd0:	4505                	li	a0,1
ffffffffc0200fd2:	681000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200fd6:	38051763          	bnez	a0,ffffffffc0201364 <default_check+0x4f2>
    free_page(p0);
ffffffffc0200fda:	4585                	li	a1,1
ffffffffc0200fdc:	854e                	mv	a0,s3
ffffffffc0200fde:	6fd000ef          	jal	ra,ffffffffc0201eda <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200fe2:	00893783          	ld	a5,8(s2)
ffffffffc0200fe6:	23278f63          	beq	a5,s2,ffffffffc0201224 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200fea:	4505                	li	a0,1
ffffffffc0200fec:	667000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200ff0:	32a99a63          	bne	s3,a0,ffffffffc0201324 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0200ff4:	4505                	li	a0,1
ffffffffc0200ff6:	65d000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200ffa:	30051563          	bnez	a0,ffffffffc0201304 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0200ffe:	01092783          	lw	a5,16(s2)
ffffffffc0201002:	2e079163          	bnez	a5,ffffffffc02012e4 <default_check+0x472>
    free_page(p);
ffffffffc0201006:	854e                	mv	a0,s3
ffffffffc0201008:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc020100a:	000ab797          	auipc	a5,0xab
ffffffffc020100e:	5b87b723          	sd	s8,1454(a5) # ffffffffc02ac5b8 <free_area>
ffffffffc0201012:	000ab797          	auipc	a5,0xab
ffffffffc0201016:	5b77b723          	sd	s7,1454(a5) # ffffffffc02ac5c0 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc020101a:	000ab797          	auipc	a5,0xab
ffffffffc020101e:	5b67a723          	sw	s6,1454(a5) # ffffffffc02ac5c8 <free_area+0x10>
    free_page(p);
ffffffffc0201022:	6b9000ef          	jal	ra,ffffffffc0201eda <free_pages>
    free_page(p1);
ffffffffc0201026:	4585                	li	a1,1
ffffffffc0201028:	8556                	mv	a0,s5
ffffffffc020102a:	6b1000ef          	jal	ra,ffffffffc0201eda <free_pages>
    free_page(p2);
ffffffffc020102e:	4585                	li	a1,1
ffffffffc0201030:	8552                	mv	a0,s4
ffffffffc0201032:	6a9000ef          	jal	ra,ffffffffc0201eda <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201036:	4515                	li	a0,5
ffffffffc0201038:	61b000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020103c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020103e:	28050363          	beqz	a0,ffffffffc02012c4 <default_check+0x452>
ffffffffc0201042:	651c                	ld	a5,8(a0)
ffffffffc0201044:	8385                	srli	a5,a5,0x1
ffffffffc0201046:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0201048:	54079e63          	bnez	a5,ffffffffc02015a4 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc020104c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020104e:	00093b03          	ld	s6,0(s2)
ffffffffc0201052:	00893a83          	ld	s5,8(s2)
ffffffffc0201056:	000ab797          	auipc	a5,0xab
ffffffffc020105a:	5727b123          	sd	s2,1378(a5) # ffffffffc02ac5b8 <free_area>
ffffffffc020105e:	000ab797          	auipc	a5,0xab
ffffffffc0201062:	5727b123          	sd	s2,1378(a5) # ffffffffc02ac5c0 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0201066:	5ed000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020106a:	50051d63          	bnez	a0,ffffffffc0201584 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020106e:	08098a13          	addi	s4,s3,128
ffffffffc0201072:	8552                	mv	a0,s4
ffffffffc0201074:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201076:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc020107a:	000ab797          	auipc	a5,0xab
ffffffffc020107e:	5407a723          	sw	zero,1358(a5) # ffffffffc02ac5c8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201082:	659000ef          	jal	ra,ffffffffc0201eda <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201086:	4511                	li	a0,4
ffffffffc0201088:	5cb000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020108c:	4c051c63          	bnez	a0,ffffffffc0201564 <default_check+0x6f2>
ffffffffc0201090:	0889b783          	ld	a5,136(s3)
ffffffffc0201094:	8385                	srli	a5,a5,0x1
ffffffffc0201096:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201098:	4a078663          	beqz	a5,ffffffffc0201544 <default_check+0x6d2>
ffffffffc020109c:	0909a703          	lw	a4,144(s3)
ffffffffc02010a0:	478d                	li	a5,3
ffffffffc02010a2:	4af71163          	bne	a4,a5,ffffffffc0201544 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02010a6:	450d                	li	a0,3
ffffffffc02010a8:	5ab000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc02010ac:	8c2a                	mv	s8,a0
ffffffffc02010ae:	46050b63          	beqz	a0,ffffffffc0201524 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc02010b2:	4505                	li	a0,1
ffffffffc02010b4:	59f000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc02010b8:	44051663          	bnez	a0,ffffffffc0201504 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc02010bc:	438a1463          	bne	s4,s8,ffffffffc02014e4 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02010c0:	4585                	li	a1,1
ffffffffc02010c2:	854e                	mv	a0,s3
ffffffffc02010c4:	617000ef          	jal	ra,ffffffffc0201eda <free_pages>
    free_pages(p1, 3);
ffffffffc02010c8:	458d                	li	a1,3
ffffffffc02010ca:	8552                	mv	a0,s4
ffffffffc02010cc:	60f000ef          	jal	ra,ffffffffc0201eda <free_pages>
ffffffffc02010d0:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02010d4:	04098c13          	addi	s8,s3,64
ffffffffc02010d8:	8385                	srli	a5,a5,0x1
ffffffffc02010da:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010dc:	3e078463          	beqz	a5,ffffffffc02014c4 <default_check+0x652>
ffffffffc02010e0:	0109a703          	lw	a4,16(s3)
ffffffffc02010e4:	4785                	li	a5,1
ffffffffc02010e6:	3cf71f63          	bne	a4,a5,ffffffffc02014c4 <default_check+0x652>
ffffffffc02010ea:	008a3783          	ld	a5,8(s4)
ffffffffc02010ee:	8385                	srli	a5,a5,0x1
ffffffffc02010f0:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010f2:	3a078963          	beqz	a5,ffffffffc02014a4 <default_check+0x632>
ffffffffc02010f6:	010a2703          	lw	a4,16(s4)
ffffffffc02010fa:	478d                	li	a5,3
ffffffffc02010fc:	3af71463          	bne	a4,a5,ffffffffc02014a4 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201100:	4505                	li	a0,1
ffffffffc0201102:	551000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0201106:	36a99f63          	bne	s3,a0,ffffffffc0201484 <default_check+0x612>
    free_page(p0);
ffffffffc020110a:	4585                	li	a1,1
ffffffffc020110c:	5cf000ef          	jal	ra,ffffffffc0201eda <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201110:	4509                	li	a0,2
ffffffffc0201112:	541000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0201116:	34aa1763          	bne	s4,a0,ffffffffc0201464 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc020111a:	4589                	li	a1,2
ffffffffc020111c:	5bf000ef          	jal	ra,ffffffffc0201eda <free_pages>
    free_page(p2);
ffffffffc0201120:	4585                	li	a1,1
ffffffffc0201122:	8562                	mv	a0,s8
ffffffffc0201124:	5b7000ef          	jal	ra,ffffffffc0201eda <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201128:	4515                	li	a0,5
ffffffffc020112a:	529000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020112e:	89aa                	mv	s3,a0
ffffffffc0201130:	48050a63          	beqz	a0,ffffffffc02015c4 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0201134:	4505                	li	a0,1
ffffffffc0201136:	51d000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020113a:	2e051563          	bnez	a0,ffffffffc0201424 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc020113e:	01092783          	lw	a5,16(s2)
ffffffffc0201142:	2c079163          	bnez	a5,ffffffffc0201404 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201146:	4595                	li	a1,5
ffffffffc0201148:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020114a:	000ab797          	auipc	a5,0xab
ffffffffc020114e:	4777af23          	sw	s7,1150(a5) # ffffffffc02ac5c8 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0201152:	000ab797          	auipc	a5,0xab
ffffffffc0201156:	4767b323          	sd	s6,1126(a5) # ffffffffc02ac5b8 <free_area>
ffffffffc020115a:	000ab797          	auipc	a5,0xab
ffffffffc020115e:	4757b323          	sd	s5,1126(a5) # ffffffffc02ac5c0 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0201162:	579000ef          	jal	ra,ffffffffc0201eda <free_pages>
    return listelm->next;
ffffffffc0201166:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020116a:	01278963          	beq	a5,s2,ffffffffc020117c <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020116e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201172:	679c                	ld	a5,8(a5)
ffffffffc0201174:	34fd                	addiw	s1,s1,-1
ffffffffc0201176:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201178:	ff279be3          	bne	a5,s2,ffffffffc020116e <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc020117c:	26049463          	bnez	s1,ffffffffc02013e4 <default_check+0x572>
    assert(total == 0);
ffffffffc0201180:	46041263          	bnez	s0,ffffffffc02015e4 <default_check+0x772>
}
ffffffffc0201184:	60a6                	ld	ra,72(sp)
ffffffffc0201186:	6406                	ld	s0,64(sp)
ffffffffc0201188:	74e2                	ld	s1,56(sp)
ffffffffc020118a:	7942                	ld	s2,48(sp)
ffffffffc020118c:	79a2                	ld	s3,40(sp)
ffffffffc020118e:	7a02                	ld	s4,32(sp)
ffffffffc0201190:	6ae2                	ld	s5,24(sp)
ffffffffc0201192:	6b42                	ld	s6,16(sp)
ffffffffc0201194:	6ba2                	ld	s7,8(sp)
ffffffffc0201196:	6c02                	ld	s8,0(sp)
ffffffffc0201198:	6161                	addi	sp,sp,80
ffffffffc020119a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020119c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020119e:	4401                	li	s0,0
ffffffffc02011a0:	4481                	li	s1,0
ffffffffc02011a2:	b30d                	j	ffffffffc0200ec4 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc02011a4:	00006697          	auipc	a3,0x6
ffffffffc02011a8:	e4468693          	addi	a3,a3,-444 # ffffffffc0206fe8 <commands+0x878>
ffffffffc02011ac:	00006617          	auipc	a2,0x6
ffffffffc02011b0:	a8460613          	addi	a2,a2,-1404 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02011b4:	0f000593          	li	a1,240
ffffffffc02011b8:	00006517          	auipc	a0,0x6
ffffffffc02011bc:	e4050513          	addi	a0,a0,-448 # ffffffffc0206ff8 <commands+0x888>
ffffffffc02011c0:	ac4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02011c4:	00006697          	auipc	a3,0x6
ffffffffc02011c8:	ecc68693          	addi	a3,a3,-308 # ffffffffc0207090 <commands+0x920>
ffffffffc02011cc:	00006617          	auipc	a2,0x6
ffffffffc02011d0:	a6460613          	addi	a2,a2,-1436 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02011d4:	0bd00593          	li	a1,189
ffffffffc02011d8:	00006517          	auipc	a0,0x6
ffffffffc02011dc:	e2050513          	addi	a0,a0,-480 # ffffffffc0206ff8 <commands+0x888>
ffffffffc02011e0:	aa4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02011e4:	00006697          	auipc	a3,0x6
ffffffffc02011e8:	ed468693          	addi	a3,a3,-300 # ffffffffc02070b8 <commands+0x948>
ffffffffc02011ec:	00006617          	auipc	a2,0x6
ffffffffc02011f0:	a4460613          	addi	a2,a2,-1468 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02011f4:	0be00593          	li	a1,190
ffffffffc02011f8:	00006517          	auipc	a0,0x6
ffffffffc02011fc:	e0050513          	addi	a0,a0,-512 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201200:	a84ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201204:	00006697          	auipc	a3,0x6
ffffffffc0201208:	ef468693          	addi	a3,a3,-268 # ffffffffc02070f8 <commands+0x988>
ffffffffc020120c:	00006617          	auipc	a2,0x6
ffffffffc0201210:	a2460613          	addi	a2,a2,-1500 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201214:	0c000593          	li	a1,192
ffffffffc0201218:	00006517          	auipc	a0,0x6
ffffffffc020121c:	de050513          	addi	a0,a0,-544 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201220:	a64ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201224:	00006697          	auipc	a3,0x6
ffffffffc0201228:	f5c68693          	addi	a3,a3,-164 # ffffffffc0207180 <commands+0xa10>
ffffffffc020122c:	00006617          	auipc	a2,0x6
ffffffffc0201230:	a0460613          	addi	a2,a2,-1532 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201234:	0d900593          	li	a1,217
ffffffffc0201238:	00006517          	auipc	a0,0x6
ffffffffc020123c:	dc050513          	addi	a0,a0,-576 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201240:	a44ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201244:	00006697          	auipc	a3,0x6
ffffffffc0201248:	dec68693          	addi	a3,a3,-532 # ffffffffc0207030 <commands+0x8c0>
ffffffffc020124c:	00006617          	auipc	a2,0x6
ffffffffc0201250:	9e460613          	addi	a2,a2,-1564 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201254:	0d200593          	li	a1,210
ffffffffc0201258:	00006517          	auipc	a0,0x6
ffffffffc020125c:	da050513          	addi	a0,a0,-608 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201260:	a24ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 3);
ffffffffc0201264:	00006697          	auipc	a3,0x6
ffffffffc0201268:	f0c68693          	addi	a3,a3,-244 # ffffffffc0207170 <commands+0xa00>
ffffffffc020126c:	00006617          	auipc	a2,0x6
ffffffffc0201270:	9c460613          	addi	a2,a2,-1596 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201274:	0d000593          	li	a1,208
ffffffffc0201278:	00006517          	auipc	a0,0x6
ffffffffc020127c:	d8050513          	addi	a0,a0,-640 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201280:	a04ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201284:	00006697          	auipc	a3,0x6
ffffffffc0201288:	ed468693          	addi	a3,a3,-300 # ffffffffc0207158 <commands+0x9e8>
ffffffffc020128c:	00006617          	auipc	a2,0x6
ffffffffc0201290:	9a460613          	addi	a2,a2,-1628 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201294:	0cb00593          	li	a1,203
ffffffffc0201298:	00006517          	auipc	a0,0x6
ffffffffc020129c:	d6050513          	addi	a0,a0,-672 # ffffffffc0206ff8 <commands+0x888>
ffffffffc02012a0:	9e4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02012a4:	00006697          	auipc	a3,0x6
ffffffffc02012a8:	e9468693          	addi	a3,a3,-364 # ffffffffc0207138 <commands+0x9c8>
ffffffffc02012ac:	00006617          	auipc	a2,0x6
ffffffffc02012b0:	98460613          	addi	a2,a2,-1660 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02012b4:	0c200593          	li	a1,194
ffffffffc02012b8:	00006517          	auipc	a0,0x6
ffffffffc02012bc:	d4050513          	addi	a0,a0,-704 # ffffffffc0206ff8 <commands+0x888>
ffffffffc02012c0:	9c4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 != NULL);
ffffffffc02012c4:	00006697          	auipc	a3,0x6
ffffffffc02012c8:	f0468693          	addi	a3,a3,-252 # ffffffffc02071c8 <commands+0xa58>
ffffffffc02012cc:	00006617          	auipc	a2,0x6
ffffffffc02012d0:	96460613          	addi	a2,a2,-1692 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02012d4:	0f800593          	li	a1,248
ffffffffc02012d8:	00006517          	auipc	a0,0x6
ffffffffc02012dc:	d2050513          	addi	a0,a0,-736 # ffffffffc0206ff8 <commands+0x888>
ffffffffc02012e0:	9a4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 0);
ffffffffc02012e4:	00006697          	auipc	a3,0x6
ffffffffc02012e8:	ed468693          	addi	a3,a3,-300 # ffffffffc02071b8 <commands+0xa48>
ffffffffc02012ec:	00006617          	auipc	a2,0x6
ffffffffc02012f0:	94460613          	addi	a2,a2,-1724 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02012f4:	0df00593          	li	a1,223
ffffffffc02012f8:	00006517          	auipc	a0,0x6
ffffffffc02012fc:	d0050513          	addi	a0,a0,-768 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201300:	984ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201304:	00006697          	auipc	a3,0x6
ffffffffc0201308:	e5468693          	addi	a3,a3,-428 # ffffffffc0207158 <commands+0x9e8>
ffffffffc020130c:	00006617          	auipc	a2,0x6
ffffffffc0201310:	92460613          	addi	a2,a2,-1756 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201314:	0dd00593          	li	a1,221
ffffffffc0201318:	00006517          	auipc	a0,0x6
ffffffffc020131c:	ce050513          	addi	a0,a0,-800 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201320:	964ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201324:	00006697          	auipc	a3,0x6
ffffffffc0201328:	e7468693          	addi	a3,a3,-396 # ffffffffc0207198 <commands+0xa28>
ffffffffc020132c:	00006617          	auipc	a2,0x6
ffffffffc0201330:	90460613          	addi	a2,a2,-1788 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201334:	0dc00593          	li	a1,220
ffffffffc0201338:	00006517          	auipc	a0,0x6
ffffffffc020133c:	cc050513          	addi	a0,a0,-832 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201340:	944ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201344:	00006697          	auipc	a3,0x6
ffffffffc0201348:	cec68693          	addi	a3,a3,-788 # ffffffffc0207030 <commands+0x8c0>
ffffffffc020134c:	00006617          	auipc	a2,0x6
ffffffffc0201350:	8e460613          	addi	a2,a2,-1820 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201354:	0b900593          	li	a1,185
ffffffffc0201358:	00006517          	auipc	a0,0x6
ffffffffc020135c:	ca050513          	addi	a0,a0,-864 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201360:	924ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201364:	00006697          	auipc	a3,0x6
ffffffffc0201368:	df468693          	addi	a3,a3,-524 # ffffffffc0207158 <commands+0x9e8>
ffffffffc020136c:	00006617          	auipc	a2,0x6
ffffffffc0201370:	8c460613          	addi	a2,a2,-1852 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201374:	0d600593          	li	a1,214
ffffffffc0201378:	00006517          	auipc	a0,0x6
ffffffffc020137c:	c8050513          	addi	a0,a0,-896 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201380:	904ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201384:	00006697          	auipc	a3,0x6
ffffffffc0201388:	cec68693          	addi	a3,a3,-788 # ffffffffc0207070 <commands+0x900>
ffffffffc020138c:	00006617          	auipc	a2,0x6
ffffffffc0201390:	8a460613          	addi	a2,a2,-1884 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201394:	0d400593          	li	a1,212
ffffffffc0201398:	00006517          	auipc	a0,0x6
ffffffffc020139c:	c6050513          	addi	a0,a0,-928 # ffffffffc0206ff8 <commands+0x888>
ffffffffc02013a0:	8e4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02013a4:	00006697          	auipc	a3,0x6
ffffffffc02013a8:	cac68693          	addi	a3,a3,-852 # ffffffffc0207050 <commands+0x8e0>
ffffffffc02013ac:	00006617          	auipc	a2,0x6
ffffffffc02013b0:	88460613          	addi	a2,a2,-1916 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02013b4:	0d300593          	li	a1,211
ffffffffc02013b8:	00006517          	auipc	a0,0x6
ffffffffc02013bc:	c4050513          	addi	a0,a0,-960 # ffffffffc0206ff8 <commands+0x888>
ffffffffc02013c0:	8c4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013c4:	00006697          	auipc	a3,0x6
ffffffffc02013c8:	cac68693          	addi	a3,a3,-852 # ffffffffc0207070 <commands+0x900>
ffffffffc02013cc:	00006617          	auipc	a2,0x6
ffffffffc02013d0:	86460613          	addi	a2,a2,-1948 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02013d4:	0bb00593          	li	a1,187
ffffffffc02013d8:	00006517          	auipc	a0,0x6
ffffffffc02013dc:	c2050513          	addi	a0,a0,-992 # ffffffffc0206ff8 <commands+0x888>
ffffffffc02013e0:	8a4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(count == 0);
ffffffffc02013e4:	00006697          	auipc	a3,0x6
ffffffffc02013e8:	f3468693          	addi	a3,a3,-204 # ffffffffc0207318 <commands+0xba8>
ffffffffc02013ec:	00006617          	auipc	a2,0x6
ffffffffc02013f0:	84460613          	addi	a2,a2,-1980 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02013f4:	12500593          	li	a1,293
ffffffffc02013f8:	00006517          	auipc	a0,0x6
ffffffffc02013fc:	c0050513          	addi	a0,a0,-1024 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201400:	884ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 0);
ffffffffc0201404:	00006697          	auipc	a3,0x6
ffffffffc0201408:	db468693          	addi	a3,a3,-588 # ffffffffc02071b8 <commands+0xa48>
ffffffffc020140c:	00006617          	auipc	a2,0x6
ffffffffc0201410:	82460613          	addi	a2,a2,-2012 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201414:	11a00593          	li	a1,282
ffffffffc0201418:	00006517          	auipc	a0,0x6
ffffffffc020141c:	be050513          	addi	a0,a0,-1056 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201420:	864ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201424:	00006697          	auipc	a3,0x6
ffffffffc0201428:	d3468693          	addi	a3,a3,-716 # ffffffffc0207158 <commands+0x9e8>
ffffffffc020142c:	00006617          	auipc	a2,0x6
ffffffffc0201430:	80460613          	addi	a2,a2,-2044 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201434:	11800593          	li	a1,280
ffffffffc0201438:	00006517          	auipc	a0,0x6
ffffffffc020143c:	bc050513          	addi	a0,a0,-1088 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201440:	844ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201444:	00006697          	auipc	a3,0x6
ffffffffc0201448:	cd468693          	addi	a3,a3,-812 # ffffffffc0207118 <commands+0x9a8>
ffffffffc020144c:	00005617          	auipc	a2,0x5
ffffffffc0201450:	7e460613          	addi	a2,a2,2020 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201454:	0c100593          	li	a1,193
ffffffffc0201458:	00006517          	auipc	a0,0x6
ffffffffc020145c:	ba050513          	addi	a0,a0,-1120 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201460:	824ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201464:	00006697          	auipc	a3,0x6
ffffffffc0201468:	e7468693          	addi	a3,a3,-396 # ffffffffc02072d8 <commands+0xb68>
ffffffffc020146c:	00005617          	auipc	a2,0x5
ffffffffc0201470:	7c460613          	addi	a2,a2,1988 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201474:	11200593          	li	a1,274
ffffffffc0201478:	00006517          	auipc	a0,0x6
ffffffffc020147c:	b8050513          	addi	a0,a0,-1152 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201480:	804ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201484:	00006697          	auipc	a3,0x6
ffffffffc0201488:	e3468693          	addi	a3,a3,-460 # ffffffffc02072b8 <commands+0xb48>
ffffffffc020148c:	00005617          	auipc	a2,0x5
ffffffffc0201490:	7a460613          	addi	a2,a2,1956 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201494:	11000593          	li	a1,272
ffffffffc0201498:	00006517          	auipc	a0,0x6
ffffffffc020149c:	b6050513          	addi	a0,a0,-1184 # ffffffffc0206ff8 <commands+0x888>
ffffffffc02014a0:	fe5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02014a4:	00006697          	auipc	a3,0x6
ffffffffc02014a8:	dec68693          	addi	a3,a3,-532 # ffffffffc0207290 <commands+0xb20>
ffffffffc02014ac:	00005617          	auipc	a2,0x5
ffffffffc02014b0:	78460613          	addi	a2,a2,1924 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02014b4:	10e00593          	li	a1,270
ffffffffc02014b8:	00006517          	auipc	a0,0x6
ffffffffc02014bc:	b4050513          	addi	a0,a0,-1216 # ffffffffc0206ff8 <commands+0x888>
ffffffffc02014c0:	fc5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02014c4:	00006697          	auipc	a3,0x6
ffffffffc02014c8:	da468693          	addi	a3,a3,-604 # ffffffffc0207268 <commands+0xaf8>
ffffffffc02014cc:	00005617          	auipc	a2,0x5
ffffffffc02014d0:	76460613          	addi	a2,a2,1892 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02014d4:	10d00593          	li	a1,269
ffffffffc02014d8:	00006517          	auipc	a0,0x6
ffffffffc02014dc:	b2050513          	addi	a0,a0,-1248 # ffffffffc0206ff8 <commands+0x888>
ffffffffc02014e0:	fa5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02014e4:	00006697          	auipc	a3,0x6
ffffffffc02014e8:	d7468693          	addi	a3,a3,-652 # ffffffffc0207258 <commands+0xae8>
ffffffffc02014ec:	00005617          	auipc	a2,0x5
ffffffffc02014f0:	74460613          	addi	a2,a2,1860 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02014f4:	10800593          	li	a1,264
ffffffffc02014f8:	00006517          	auipc	a0,0x6
ffffffffc02014fc:	b0050513          	addi	a0,a0,-1280 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201500:	f85fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201504:	00006697          	auipc	a3,0x6
ffffffffc0201508:	c5468693          	addi	a3,a3,-940 # ffffffffc0207158 <commands+0x9e8>
ffffffffc020150c:	00005617          	auipc	a2,0x5
ffffffffc0201510:	72460613          	addi	a2,a2,1828 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201514:	10700593          	li	a1,263
ffffffffc0201518:	00006517          	auipc	a0,0x6
ffffffffc020151c:	ae050513          	addi	a0,a0,-1312 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201520:	f65fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201524:	00006697          	auipc	a3,0x6
ffffffffc0201528:	d1468693          	addi	a3,a3,-748 # ffffffffc0207238 <commands+0xac8>
ffffffffc020152c:	00005617          	auipc	a2,0x5
ffffffffc0201530:	70460613          	addi	a2,a2,1796 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201534:	10600593          	li	a1,262
ffffffffc0201538:	00006517          	auipc	a0,0x6
ffffffffc020153c:	ac050513          	addi	a0,a0,-1344 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201540:	f45fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201544:	00006697          	auipc	a3,0x6
ffffffffc0201548:	cc468693          	addi	a3,a3,-828 # ffffffffc0207208 <commands+0xa98>
ffffffffc020154c:	00005617          	auipc	a2,0x5
ffffffffc0201550:	6e460613          	addi	a2,a2,1764 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201554:	10500593          	li	a1,261
ffffffffc0201558:	00006517          	auipc	a0,0x6
ffffffffc020155c:	aa050513          	addi	a0,a0,-1376 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201560:	f25fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201564:	00006697          	auipc	a3,0x6
ffffffffc0201568:	c8c68693          	addi	a3,a3,-884 # ffffffffc02071f0 <commands+0xa80>
ffffffffc020156c:	00005617          	auipc	a2,0x5
ffffffffc0201570:	6c460613          	addi	a2,a2,1732 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201574:	10400593          	li	a1,260
ffffffffc0201578:	00006517          	auipc	a0,0x6
ffffffffc020157c:	a8050513          	addi	a0,a0,-1408 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201580:	f05fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201584:	00006697          	auipc	a3,0x6
ffffffffc0201588:	bd468693          	addi	a3,a3,-1068 # ffffffffc0207158 <commands+0x9e8>
ffffffffc020158c:	00005617          	auipc	a2,0x5
ffffffffc0201590:	6a460613          	addi	a2,a2,1700 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201594:	0fe00593          	li	a1,254
ffffffffc0201598:	00006517          	auipc	a0,0x6
ffffffffc020159c:	a6050513          	addi	a0,a0,-1440 # ffffffffc0206ff8 <commands+0x888>
ffffffffc02015a0:	ee5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(!PageProperty(p0));
ffffffffc02015a4:	00006697          	auipc	a3,0x6
ffffffffc02015a8:	c3468693          	addi	a3,a3,-972 # ffffffffc02071d8 <commands+0xa68>
ffffffffc02015ac:	00005617          	auipc	a2,0x5
ffffffffc02015b0:	68460613          	addi	a2,a2,1668 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02015b4:	0f900593          	li	a1,249
ffffffffc02015b8:	00006517          	auipc	a0,0x6
ffffffffc02015bc:	a4050513          	addi	a0,a0,-1472 # ffffffffc0206ff8 <commands+0x888>
ffffffffc02015c0:	ec5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02015c4:	00006697          	auipc	a3,0x6
ffffffffc02015c8:	d3468693          	addi	a3,a3,-716 # ffffffffc02072f8 <commands+0xb88>
ffffffffc02015cc:	00005617          	auipc	a2,0x5
ffffffffc02015d0:	66460613          	addi	a2,a2,1636 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02015d4:	11700593          	li	a1,279
ffffffffc02015d8:	00006517          	auipc	a0,0x6
ffffffffc02015dc:	a2050513          	addi	a0,a0,-1504 # ffffffffc0206ff8 <commands+0x888>
ffffffffc02015e0:	ea5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(total == 0);
ffffffffc02015e4:	00006697          	auipc	a3,0x6
ffffffffc02015e8:	d4468693          	addi	a3,a3,-700 # ffffffffc0207328 <commands+0xbb8>
ffffffffc02015ec:	00005617          	auipc	a2,0x5
ffffffffc02015f0:	64460613          	addi	a2,a2,1604 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02015f4:	12600593          	li	a1,294
ffffffffc02015f8:	00006517          	auipc	a0,0x6
ffffffffc02015fc:	a0050513          	addi	a0,a0,-1536 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201600:	e85fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201604:	00006697          	auipc	a3,0x6
ffffffffc0201608:	a0c68693          	addi	a3,a3,-1524 # ffffffffc0207010 <commands+0x8a0>
ffffffffc020160c:	00005617          	auipc	a2,0x5
ffffffffc0201610:	62460613          	addi	a2,a2,1572 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201614:	0f300593          	li	a1,243
ffffffffc0201618:	00006517          	auipc	a0,0x6
ffffffffc020161c:	9e050513          	addi	a0,a0,-1568 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201620:	e65fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201624:	00006697          	auipc	a3,0x6
ffffffffc0201628:	a2c68693          	addi	a3,a3,-1492 # ffffffffc0207050 <commands+0x8e0>
ffffffffc020162c:	00005617          	auipc	a2,0x5
ffffffffc0201630:	60460613          	addi	a2,a2,1540 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201634:	0ba00593          	li	a1,186
ffffffffc0201638:	00006517          	auipc	a0,0x6
ffffffffc020163c:	9c050513          	addi	a0,a0,-1600 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201640:	e45fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201644 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201644:	1141                	addi	sp,sp,-16
ffffffffc0201646:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201648:	16058e63          	beqz	a1,ffffffffc02017c4 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc020164c:	00659693          	slli	a3,a1,0x6
ffffffffc0201650:	96aa                	add	a3,a3,a0
ffffffffc0201652:	02d50d63          	beq	a0,a3,ffffffffc020168c <default_free_pages+0x48>
ffffffffc0201656:	651c                	ld	a5,8(a0)
ffffffffc0201658:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020165a:	14079563          	bnez	a5,ffffffffc02017a4 <default_free_pages+0x160>
ffffffffc020165e:	651c                	ld	a5,8(a0)
ffffffffc0201660:	8385                	srli	a5,a5,0x1
ffffffffc0201662:	8b85                	andi	a5,a5,1
ffffffffc0201664:	14079063          	bnez	a5,ffffffffc02017a4 <default_free_pages+0x160>
ffffffffc0201668:	87aa                	mv	a5,a0
ffffffffc020166a:	a809                	j	ffffffffc020167c <default_free_pages+0x38>
ffffffffc020166c:	6798                	ld	a4,8(a5)
ffffffffc020166e:	8b05                	andi	a4,a4,1
ffffffffc0201670:	12071a63          	bnez	a4,ffffffffc02017a4 <default_free_pages+0x160>
ffffffffc0201674:	6798                	ld	a4,8(a5)
ffffffffc0201676:	8b09                	andi	a4,a4,2
ffffffffc0201678:	12071663          	bnez	a4,ffffffffc02017a4 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc020167c:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201680:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201684:	04078793          	addi	a5,a5,64
ffffffffc0201688:	fed792e3          	bne	a5,a3,ffffffffc020166c <default_free_pages+0x28>
    base->property = n;
ffffffffc020168c:	2581                	sext.w	a1,a1
ffffffffc020168e:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201690:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201694:	4789                	li	a5,2
ffffffffc0201696:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020169a:	000ab697          	auipc	a3,0xab
ffffffffc020169e:	f1e68693          	addi	a3,a3,-226 # ffffffffc02ac5b8 <free_area>
ffffffffc02016a2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02016a4:	669c                	ld	a5,8(a3)
ffffffffc02016a6:	9db9                	addw	a1,a1,a4
ffffffffc02016a8:	000ab717          	auipc	a4,0xab
ffffffffc02016ac:	f2b72023          	sw	a1,-224(a4) # ffffffffc02ac5c8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02016b0:	0cd78163          	beq	a5,a3,ffffffffc0201772 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc02016b4:	fe878713          	addi	a4,a5,-24
ffffffffc02016b8:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02016ba:	4801                	li	a6,0
ffffffffc02016bc:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02016c0:	00e56a63          	bltu	a0,a4,ffffffffc02016d4 <default_free_pages+0x90>
    return listelm->next;
ffffffffc02016c4:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02016c6:	04d70f63          	beq	a4,a3,ffffffffc0201724 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016ca:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02016cc:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02016d0:	fee57ae3          	bleu	a4,a0,ffffffffc02016c4 <default_free_pages+0x80>
ffffffffc02016d4:	00080663          	beqz	a6,ffffffffc02016e0 <default_free_pages+0x9c>
ffffffffc02016d8:	000ab817          	auipc	a6,0xab
ffffffffc02016dc:	eeb83023          	sd	a1,-288(a6) # ffffffffc02ac5b8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02016e0:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02016e2:	e390                	sd	a2,0(a5)
ffffffffc02016e4:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02016e6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016e8:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02016ea:	06d58a63          	beq	a1,a3,ffffffffc020175e <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc02016ee:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02016f2:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02016f6:	02061793          	slli	a5,a2,0x20
ffffffffc02016fa:	83e9                	srli	a5,a5,0x1a
ffffffffc02016fc:	97ba                	add	a5,a5,a4
ffffffffc02016fe:	04f51b63          	bne	a0,a5,ffffffffc0201754 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc0201702:	491c                	lw	a5,16(a0)
ffffffffc0201704:	9e3d                	addw	a2,a2,a5
ffffffffc0201706:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020170a:	57f5                	li	a5,-3
ffffffffc020170c:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201710:	01853803          	ld	a6,24(a0)
ffffffffc0201714:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0201716:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201718:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc020171c:	659c                	ld	a5,8(a1)
ffffffffc020171e:	01063023          	sd	a6,0(a2)
ffffffffc0201722:	a815                	j	ffffffffc0201756 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0201724:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201726:	f114                	sd	a3,32(a0)
ffffffffc0201728:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020172a:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020172c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020172e:	00d70563          	beq	a4,a3,ffffffffc0201738 <default_free_pages+0xf4>
ffffffffc0201732:	4805                	li	a6,1
ffffffffc0201734:	87ba                	mv	a5,a4
ffffffffc0201736:	bf59                	j	ffffffffc02016cc <default_free_pages+0x88>
ffffffffc0201738:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020173a:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020173c:	00d78d63          	beq	a5,a3,ffffffffc0201756 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0201740:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201744:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201748:	02061793          	slli	a5,a2,0x20
ffffffffc020174c:	83e9                	srli	a5,a5,0x1a
ffffffffc020174e:	97ba                	add	a5,a5,a4
ffffffffc0201750:	faf509e3          	beq	a0,a5,ffffffffc0201702 <default_free_pages+0xbe>
ffffffffc0201754:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201756:	fe878713          	addi	a4,a5,-24
ffffffffc020175a:	00d78963          	beq	a5,a3,ffffffffc020176c <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc020175e:	4910                	lw	a2,16(a0)
ffffffffc0201760:	02061693          	slli	a3,a2,0x20
ffffffffc0201764:	82e9                	srli	a3,a3,0x1a
ffffffffc0201766:	96aa                	add	a3,a3,a0
ffffffffc0201768:	00d70e63          	beq	a4,a3,ffffffffc0201784 <default_free_pages+0x140>
}
ffffffffc020176c:	60a2                	ld	ra,8(sp)
ffffffffc020176e:	0141                	addi	sp,sp,16
ffffffffc0201770:	8082                	ret
ffffffffc0201772:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201774:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201778:	e398                	sd	a4,0(a5)
ffffffffc020177a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020177c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020177e:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201780:	0141                	addi	sp,sp,16
ffffffffc0201782:	8082                	ret
            base->property += p->property;
ffffffffc0201784:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201788:	ff078693          	addi	a3,a5,-16
ffffffffc020178c:	9e39                	addw	a2,a2,a4
ffffffffc020178e:	c910                	sw	a2,16(a0)
ffffffffc0201790:	5775                	li	a4,-3
ffffffffc0201792:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201796:	6398                	ld	a4,0(a5)
ffffffffc0201798:	679c                	ld	a5,8(a5)
}
ffffffffc020179a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020179c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020179e:	e398                	sd	a4,0(a5)
ffffffffc02017a0:	0141                	addi	sp,sp,16
ffffffffc02017a2:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02017a4:	00006697          	auipc	a3,0x6
ffffffffc02017a8:	b9468693          	addi	a3,a3,-1132 # ffffffffc0207338 <commands+0xbc8>
ffffffffc02017ac:	00005617          	auipc	a2,0x5
ffffffffc02017b0:	48460613          	addi	a2,a2,1156 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02017b4:	08300593          	li	a1,131
ffffffffc02017b8:	00006517          	auipc	a0,0x6
ffffffffc02017bc:	84050513          	addi	a0,a0,-1984 # ffffffffc0206ff8 <commands+0x888>
ffffffffc02017c0:	cc5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(n > 0);
ffffffffc02017c4:	00006697          	auipc	a3,0x6
ffffffffc02017c8:	b9c68693          	addi	a3,a3,-1124 # ffffffffc0207360 <commands+0xbf0>
ffffffffc02017cc:	00005617          	auipc	a2,0x5
ffffffffc02017d0:	46460613          	addi	a2,a2,1124 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02017d4:	08000593          	li	a1,128
ffffffffc02017d8:	00006517          	auipc	a0,0x6
ffffffffc02017dc:	82050513          	addi	a0,a0,-2016 # ffffffffc0206ff8 <commands+0x888>
ffffffffc02017e0:	ca5fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02017e4 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02017e4:	c959                	beqz	a0,ffffffffc020187a <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02017e6:	000ab597          	auipc	a1,0xab
ffffffffc02017ea:	dd258593          	addi	a1,a1,-558 # ffffffffc02ac5b8 <free_area>
ffffffffc02017ee:	0105a803          	lw	a6,16(a1)
ffffffffc02017f2:	862a                	mv	a2,a0
ffffffffc02017f4:	02081793          	slli	a5,a6,0x20
ffffffffc02017f8:	9381                	srli	a5,a5,0x20
ffffffffc02017fa:	00a7ee63          	bltu	a5,a0,ffffffffc0201816 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02017fe:	87ae                	mv	a5,a1
ffffffffc0201800:	a801                	j	ffffffffc0201810 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201802:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201806:	02071693          	slli	a3,a4,0x20
ffffffffc020180a:	9281                	srli	a3,a3,0x20
ffffffffc020180c:	00c6f763          	bleu	a2,a3,ffffffffc020181a <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201810:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201812:	feb798e3          	bne	a5,a1,ffffffffc0201802 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201816:	4501                	li	a0,0
}
ffffffffc0201818:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020181a:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc020181e:	dd6d                	beqz	a0,ffffffffc0201818 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201820:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201824:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0201828:	00060e1b          	sext.w	t3,a2
ffffffffc020182c:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201830:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201834:	02d67863          	bleu	a3,a2,ffffffffc0201864 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0201838:	061a                	slli	a2,a2,0x6
ffffffffc020183a:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc020183c:	41c7073b          	subw	a4,a4,t3
ffffffffc0201840:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201842:	00860693          	addi	a3,a2,8
ffffffffc0201846:	4709                	li	a4,2
ffffffffc0201848:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc020184c:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201850:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0201854:	0105a803          	lw	a6,16(a1)
ffffffffc0201858:	e314                	sd	a3,0(a4)
ffffffffc020185a:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc020185e:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0201860:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0201864:	41c8083b          	subw	a6,a6,t3
ffffffffc0201868:	000ab717          	auipc	a4,0xab
ffffffffc020186c:	d7072023          	sw	a6,-672(a4) # ffffffffc02ac5c8 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201870:	5775                	li	a4,-3
ffffffffc0201872:	17c1                	addi	a5,a5,-16
ffffffffc0201874:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201878:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020187a:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020187c:	00006697          	auipc	a3,0x6
ffffffffc0201880:	ae468693          	addi	a3,a3,-1308 # ffffffffc0207360 <commands+0xbf0>
ffffffffc0201884:	00005617          	auipc	a2,0x5
ffffffffc0201888:	3ac60613          	addi	a2,a2,940 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc020188c:	06200593          	li	a1,98
ffffffffc0201890:	00005517          	auipc	a0,0x5
ffffffffc0201894:	76850513          	addi	a0,a0,1896 # ffffffffc0206ff8 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc0201898:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020189a:	bebfe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020189e <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020189e:	1141                	addi	sp,sp,-16
ffffffffc02018a0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02018a2:	c1ed                	beqz	a1,ffffffffc0201984 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc02018a4:	00659693          	slli	a3,a1,0x6
ffffffffc02018a8:	96aa                	add	a3,a3,a0
ffffffffc02018aa:	02d50463          	beq	a0,a3,ffffffffc02018d2 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02018ae:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02018b0:	87aa                	mv	a5,a0
ffffffffc02018b2:	8b05                	andi	a4,a4,1
ffffffffc02018b4:	e709                	bnez	a4,ffffffffc02018be <default_init_memmap+0x20>
ffffffffc02018b6:	a07d                	j	ffffffffc0201964 <default_init_memmap+0xc6>
ffffffffc02018b8:	6798                	ld	a4,8(a5)
ffffffffc02018ba:	8b05                	andi	a4,a4,1
ffffffffc02018bc:	c745                	beqz	a4,ffffffffc0201964 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc02018be:	0007a823          	sw	zero,16(a5)
ffffffffc02018c2:	0007b423          	sd	zero,8(a5)
ffffffffc02018c6:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02018ca:	04078793          	addi	a5,a5,64
ffffffffc02018ce:	fed795e3          	bne	a5,a3,ffffffffc02018b8 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc02018d2:	2581                	sext.w	a1,a1
ffffffffc02018d4:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02018d6:	4789                	li	a5,2
ffffffffc02018d8:	00850713          	addi	a4,a0,8
ffffffffc02018dc:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02018e0:	000ab697          	auipc	a3,0xab
ffffffffc02018e4:	cd868693          	addi	a3,a3,-808 # ffffffffc02ac5b8 <free_area>
ffffffffc02018e8:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02018ea:	669c                	ld	a5,8(a3)
ffffffffc02018ec:	9db9                	addw	a1,a1,a4
ffffffffc02018ee:	000ab717          	auipc	a4,0xab
ffffffffc02018f2:	ccb72d23          	sw	a1,-806(a4) # ffffffffc02ac5c8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02018f6:	04d78a63          	beq	a5,a3,ffffffffc020194a <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc02018fa:	fe878713          	addi	a4,a5,-24
ffffffffc02018fe:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201900:	4801                	li	a6,0
ffffffffc0201902:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201906:	00e56a63          	bltu	a0,a4,ffffffffc020191a <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc020190a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020190c:	02d70563          	beq	a4,a3,ffffffffc0201936 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201910:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201912:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201916:	fee57ae3          	bleu	a4,a0,ffffffffc020190a <default_init_memmap+0x6c>
ffffffffc020191a:	00080663          	beqz	a6,ffffffffc0201926 <default_init_memmap+0x88>
ffffffffc020191e:	000ab717          	auipc	a4,0xab
ffffffffc0201922:	c8b73d23          	sd	a1,-870(a4) # ffffffffc02ac5b8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201926:	6398                	ld	a4,0(a5)
}
ffffffffc0201928:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020192a:	e390                	sd	a2,0(a5)
ffffffffc020192c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020192e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201930:	ed18                	sd	a4,24(a0)
ffffffffc0201932:	0141                	addi	sp,sp,16
ffffffffc0201934:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201936:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201938:	f114                	sd	a3,32(a0)
ffffffffc020193a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020193c:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020193e:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201940:	00d70e63          	beq	a4,a3,ffffffffc020195c <default_init_memmap+0xbe>
ffffffffc0201944:	4805                	li	a6,1
ffffffffc0201946:	87ba                	mv	a5,a4
ffffffffc0201948:	b7e9                	j	ffffffffc0201912 <default_init_memmap+0x74>
}
ffffffffc020194a:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020194c:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201950:	e398                	sd	a4,0(a5)
ffffffffc0201952:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201954:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201956:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201958:	0141                	addi	sp,sp,16
ffffffffc020195a:	8082                	ret
ffffffffc020195c:	60a2                	ld	ra,8(sp)
ffffffffc020195e:	e290                	sd	a2,0(a3)
ffffffffc0201960:	0141                	addi	sp,sp,16
ffffffffc0201962:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201964:	00006697          	auipc	a3,0x6
ffffffffc0201968:	a0468693          	addi	a3,a3,-1532 # ffffffffc0207368 <commands+0xbf8>
ffffffffc020196c:	00005617          	auipc	a2,0x5
ffffffffc0201970:	2c460613          	addi	a2,a2,708 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201974:	04900593          	li	a1,73
ffffffffc0201978:	00005517          	auipc	a0,0x5
ffffffffc020197c:	68050513          	addi	a0,a0,1664 # ffffffffc0206ff8 <commands+0x888>
ffffffffc0201980:	b05fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(n > 0);
ffffffffc0201984:	00006697          	auipc	a3,0x6
ffffffffc0201988:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0207360 <commands+0xbf0>
ffffffffc020198c:	00005617          	auipc	a2,0x5
ffffffffc0201990:	2a460613          	addi	a2,a2,676 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201994:	04600593          	li	a1,70
ffffffffc0201998:	00005517          	auipc	a0,0x5
ffffffffc020199c:	66050513          	addi	a0,a0,1632 # ffffffffc0206ff8 <commands+0x888>
ffffffffc02019a0:	ae5fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02019a4 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02019a4:	c125                	beqz	a0,ffffffffc0201a04 <slob_free+0x60>
		return;

	if (size)
ffffffffc02019a6:	e1a5                	bnez	a1,ffffffffc0201a06 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019a8:	100027f3          	csrr	a5,sstatus
ffffffffc02019ac:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02019ae:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019b0:	e3bd                	bnez	a5,ffffffffc0201a16 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019b2:	0009f797          	auipc	a5,0x9f
ffffffffc02019b6:	79678793          	addi	a5,a5,1942 # ffffffffc02a1148 <slobfree>
ffffffffc02019ba:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019bc:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019be:	00a7fa63          	bleu	a0,a5,ffffffffc02019d2 <slob_free+0x2e>
ffffffffc02019c2:	00e56c63          	bltu	a0,a4,ffffffffc02019da <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019c6:	00e7fa63          	bleu	a4,a5,ffffffffc02019da <slob_free+0x36>
    return 0;
ffffffffc02019ca:	87ba                	mv	a5,a4
ffffffffc02019cc:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019ce:	fea7eae3          	bltu	a5,a0,ffffffffc02019c2 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019d2:	fee7ece3          	bltu	a5,a4,ffffffffc02019ca <slob_free+0x26>
ffffffffc02019d6:	fee57ae3          	bleu	a4,a0,ffffffffc02019ca <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc02019da:	4110                	lw	a2,0(a0)
ffffffffc02019dc:	00461693          	slli	a3,a2,0x4
ffffffffc02019e0:	96aa                	add	a3,a3,a0
ffffffffc02019e2:	08d70b63          	beq	a4,a3,ffffffffc0201a78 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02019e6:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc02019e8:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02019ea:	00469713          	slli	a4,a3,0x4
ffffffffc02019ee:	973e                	add	a4,a4,a5
ffffffffc02019f0:	08e50f63          	beq	a0,a4,ffffffffc0201a8e <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02019f4:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc02019f6:	0009f717          	auipc	a4,0x9f
ffffffffc02019fa:	74f73923          	sd	a5,1874(a4) # ffffffffc02a1148 <slobfree>
    if (flag) {
ffffffffc02019fe:	c199                	beqz	a1,ffffffffc0201a04 <slob_free+0x60>
        intr_enable();
ffffffffc0201a00:	c55fe06f          	j	ffffffffc0200654 <intr_enable>
ffffffffc0201a04:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0201a06:	05bd                	addi	a1,a1,15
ffffffffc0201a08:	8191                	srli	a1,a1,0x4
ffffffffc0201a0a:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a0c:	100027f3          	csrr	a5,sstatus
ffffffffc0201a10:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201a12:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a14:	dfd9                	beqz	a5,ffffffffc02019b2 <slob_free+0xe>
{
ffffffffc0201a16:	1101                	addi	sp,sp,-32
ffffffffc0201a18:	e42a                	sd	a0,8(sp)
ffffffffc0201a1a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201a1c:	c3ffe0ef          	jal	ra,ffffffffc020065a <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a20:	0009f797          	auipc	a5,0x9f
ffffffffc0201a24:	72878793          	addi	a5,a5,1832 # ffffffffc02a1148 <slobfree>
ffffffffc0201a28:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201a2a:	6522                	ld	a0,8(sp)
ffffffffc0201a2c:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a2e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a30:	00a7fa63          	bleu	a0,a5,ffffffffc0201a44 <slob_free+0xa0>
ffffffffc0201a34:	00e56c63          	bltu	a0,a4,ffffffffc0201a4c <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a38:	00e7fa63          	bleu	a4,a5,ffffffffc0201a4c <slob_free+0xa8>
    return 0;
ffffffffc0201a3c:	87ba                	mv	a5,a4
ffffffffc0201a3e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a40:	fea7eae3          	bltu	a5,a0,ffffffffc0201a34 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a44:	fee7ece3          	bltu	a5,a4,ffffffffc0201a3c <slob_free+0x98>
ffffffffc0201a48:	fee57ae3          	bleu	a4,a0,ffffffffc0201a3c <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201a4c:	4110                	lw	a2,0(a0)
ffffffffc0201a4e:	00461693          	slli	a3,a2,0x4
ffffffffc0201a52:	96aa                	add	a3,a3,a0
ffffffffc0201a54:	04d70763          	beq	a4,a3,ffffffffc0201aa2 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201a58:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a5a:	4394                	lw	a3,0(a5)
ffffffffc0201a5c:	00469713          	slli	a4,a3,0x4
ffffffffc0201a60:	973e                	add	a4,a4,a5
ffffffffc0201a62:	04e50663          	beq	a0,a4,ffffffffc0201aae <slob_free+0x10a>
		cur->next = b;
ffffffffc0201a66:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201a68:	0009f717          	auipc	a4,0x9f
ffffffffc0201a6c:	6ef73023          	sd	a5,1760(a4) # ffffffffc02a1148 <slobfree>
    if (flag) {
ffffffffc0201a70:	e58d                	bnez	a1,ffffffffc0201a9a <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201a72:	60e2                	ld	ra,24(sp)
ffffffffc0201a74:	6105                	addi	sp,sp,32
ffffffffc0201a76:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201a78:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a7a:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a7c:	9e35                	addw	a2,a2,a3
ffffffffc0201a7e:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0201a80:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201a82:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a84:	00469713          	slli	a4,a3,0x4
ffffffffc0201a88:	973e                	add	a4,a4,a5
ffffffffc0201a8a:	f6e515e3          	bne	a0,a4,ffffffffc02019f4 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201a8e:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201a90:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201a92:	9eb9                	addw	a3,a3,a4
ffffffffc0201a94:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201a96:	e790                	sd	a2,8(a5)
ffffffffc0201a98:	bfb9                	j	ffffffffc02019f6 <slob_free+0x52>
}
ffffffffc0201a9a:	60e2                	ld	ra,24(sp)
ffffffffc0201a9c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201a9e:	bb7fe06f          	j	ffffffffc0200654 <intr_enable>
		b->units += cur->next->units;
ffffffffc0201aa2:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201aa4:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201aa6:	9e35                	addw	a2,a2,a3
ffffffffc0201aa8:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201aaa:	e518                	sd	a4,8(a0)
ffffffffc0201aac:	b77d                	j	ffffffffc0201a5a <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0201aae:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201ab0:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201ab2:	9eb9                	addw	a3,a3,a4
ffffffffc0201ab4:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201ab6:	e790                	sd	a2,8(a5)
ffffffffc0201ab8:	bf45                	j	ffffffffc0201a68 <slob_free+0xc4>

ffffffffc0201aba <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201aba:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201abc:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201abe:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201ac2:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201ac4:	38e000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
  if(!page)
ffffffffc0201ac8:	c139                	beqz	a0,ffffffffc0201b0e <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc0201aca:	000ab797          	auipc	a5,0xab
ffffffffc0201ace:	b1e78793          	addi	a5,a5,-1250 # ffffffffc02ac5e8 <pages>
ffffffffc0201ad2:	6394                	ld	a3,0(a5)
ffffffffc0201ad4:	00007797          	auipc	a5,0x7
ffffffffc0201ad8:	2e478793          	addi	a5,a5,740 # ffffffffc0208db8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201adc:	000ab717          	auipc	a4,0xab
ffffffffc0201ae0:	a9c70713          	addi	a4,a4,-1380 # ffffffffc02ac578 <npage>
    return page - pages + nbase;
ffffffffc0201ae4:	40d506b3          	sub	a3,a0,a3
ffffffffc0201ae8:	6388                	ld	a0,0(a5)
ffffffffc0201aea:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201aec:	57fd                	li	a5,-1
ffffffffc0201aee:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0201af0:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0201af2:	83b1                	srli	a5,a5,0xc
ffffffffc0201af4:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201af6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201af8:	00e7ff63          	bleu	a4,a5,ffffffffc0201b16 <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0201afc:	000ab797          	auipc	a5,0xab
ffffffffc0201b00:	adc78793          	addi	a5,a5,-1316 # ffffffffc02ac5d8 <va_pa_offset>
ffffffffc0201b04:	6388                	ld	a0,0(a5)
}
ffffffffc0201b06:	60a2                	ld	ra,8(sp)
ffffffffc0201b08:	9536                	add	a0,a0,a3
ffffffffc0201b0a:	0141                	addi	sp,sp,16
ffffffffc0201b0c:	8082                	ret
ffffffffc0201b0e:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0201b10:	4501                	li	a0,0
}
ffffffffc0201b12:	0141                	addi	sp,sp,16
ffffffffc0201b14:	8082                	ret
ffffffffc0201b16:	00006617          	auipc	a2,0x6
ffffffffc0201b1a:	8b260613          	addi	a2,a2,-1870 # ffffffffc02073c8 <default_pmm_manager+0x50>
ffffffffc0201b1e:	06900593          	li	a1,105
ffffffffc0201b22:	00006517          	auipc	a0,0x6
ffffffffc0201b26:	8ce50513          	addi	a0,a0,-1842 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc0201b2a:	95bfe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201b2e <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201b2e:	7179                	addi	sp,sp,-48
ffffffffc0201b30:	f406                	sd	ra,40(sp)
ffffffffc0201b32:	f022                	sd	s0,32(sp)
ffffffffc0201b34:	ec26                	sd	s1,24(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201b36:	01050713          	addi	a4,a0,16
ffffffffc0201b3a:	6785                	lui	a5,0x1
ffffffffc0201b3c:	0cf77b63          	bleu	a5,a4,ffffffffc0201c12 <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201b40:	00f50413          	addi	s0,a0,15
ffffffffc0201b44:	8011                	srli	s0,s0,0x4
ffffffffc0201b46:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b48:	10002673          	csrr	a2,sstatus
ffffffffc0201b4c:	8a09                	andi	a2,a2,2
ffffffffc0201b4e:	ea5d                	bnez	a2,ffffffffc0201c04 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc0201b50:	0009f497          	auipc	s1,0x9f
ffffffffc0201b54:	5f848493          	addi	s1,s1,1528 # ffffffffc02a1148 <slobfree>
ffffffffc0201b58:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b5a:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b5c:	4398                	lw	a4,0(a5)
ffffffffc0201b5e:	0a875763          	ble	s0,a4,ffffffffc0201c0c <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc0201b62:	00f68a63          	beq	a3,a5,ffffffffc0201b76 <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b66:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b68:	4118                	lw	a4,0(a0)
ffffffffc0201b6a:	02875763          	ble	s0,a4,ffffffffc0201b98 <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc0201b6e:	6094                	ld	a3,0(s1)
ffffffffc0201b70:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc0201b72:	fef69ae3          	bne	a3,a5,ffffffffc0201b66 <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc0201b76:	ea39                	bnez	a2,ffffffffc0201bcc <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201b78:	4501                	li	a0,0
ffffffffc0201b7a:	f41ff0ef          	jal	ra,ffffffffc0201aba <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201b7e:	cd29                	beqz	a0,ffffffffc0201bd8 <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201b80:	6585                	lui	a1,0x1
ffffffffc0201b82:	e23ff0ef          	jal	ra,ffffffffc02019a4 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b86:	10002673          	csrr	a2,sstatus
ffffffffc0201b8a:	8a09                	andi	a2,a2,2
ffffffffc0201b8c:	ea1d                	bnez	a2,ffffffffc0201bc2 <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc0201b8e:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b90:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b92:	4118                	lw	a4,0(a0)
ffffffffc0201b94:	fc874de3          	blt	a4,s0,ffffffffc0201b6e <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc0201b98:	04e40663          	beq	s0,a4,ffffffffc0201be4 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0201b9c:	00441693          	slli	a3,s0,0x4
ffffffffc0201ba0:	96aa                	add	a3,a3,a0
ffffffffc0201ba2:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201ba4:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc0201ba6:	9f01                	subw	a4,a4,s0
ffffffffc0201ba8:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201baa:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201bac:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc0201bae:	0009f717          	auipc	a4,0x9f
ffffffffc0201bb2:	58f73d23          	sd	a5,1434(a4) # ffffffffc02a1148 <slobfree>
    if (flag) {
ffffffffc0201bb6:	ee15                	bnez	a2,ffffffffc0201bf2 <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0201bb8:	70a2                	ld	ra,40(sp)
ffffffffc0201bba:	7402                	ld	s0,32(sp)
ffffffffc0201bbc:	64e2                	ld	s1,24(sp)
ffffffffc0201bbe:	6145                	addi	sp,sp,48
ffffffffc0201bc0:	8082                	ret
        intr_disable();
ffffffffc0201bc2:	a99fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc0201bc6:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201bc8:	609c                	ld	a5,0(s1)
ffffffffc0201bca:	b7d9                	j	ffffffffc0201b90 <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0201bcc:	a89fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201bd0:	4501                	li	a0,0
ffffffffc0201bd2:	ee9ff0ef          	jal	ra,ffffffffc0201aba <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201bd6:	f54d                	bnez	a0,ffffffffc0201b80 <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc0201bd8:	70a2                	ld	ra,40(sp)
ffffffffc0201bda:	7402                	ld	s0,32(sp)
ffffffffc0201bdc:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0201bde:	4501                	li	a0,0
}
ffffffffc0201be0:	6145                	addi	sp,sp,48
ffffffffc0201be2:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201be4:	6518                	ld	a4,8(a0)
ffffffffc0201be6:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc0201be8:	0009f717          	auipc	a4,0x9f
ffffffffc0201bec:	56f73023          	sd	a5,1376(a4) # ffffffffc02a1148 <slobfree>
    if (flag) {
ffffffffc0201bf0:	d661                	beqz	a2,ffffffffc0201bb8 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0201bf2:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201bf4:	a61fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
}
ffffffffc0201bf8:	70a2                	ld	ra,40(sp)
ffffffffc0201bfa:	7402                	ld	s0,32(sp)
ffffffffc0201bfc:	6522                	ld	a0,8(sp)
ffffffffc0201bfe:	64e2                	ld	s1,24(sp)
ffffffffc0201c00:	6145                	addi	sp,sp,48
ffffffffc0201c02:	8082                	ret
        intr_disable();
ffffffffc0201c04:	a57fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc0201c08:	4605                	li	a2,1
ffffffffc0201c0a:	b799                	j	ffffffffc0201b50 <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201c0c:	853e                	mv	a0,a5
ffffffffc0201c0e:	87b6                	mv	a5,a3
ffffffffc0201c10:	b761                	j	ffffffffc0201b98 <slob_alloc.isra.1.constprop.3+0x6a>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201c12:	00006697          	auipc	a3,0x6
ffffffffc0201c16:	85668693          	addi	a3,a3,-1962 # ffffffffc0207468 <default_pmm_manager+0xf0>
ffffffffc0201c1a:	00005617          	auipc	a2,0x5
ffffffffc0201c1e:	01660613          	addi	a2,a2,22 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0201c22:	06400593          	li	a1,100
ffffffffc0201c26:	00006517          	auipc	a0,0x6
ffffffffc0201c2a:	86250513          	addi	a0,a0,-1950 # ffffffffc0207488 <default_pmm_manager+0x110>
ffffffffc0201c2e:	857fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201c32 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201c32:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201c34:	00006517          	auipc	a0,0x6
ffffffffc0201c38:	86c50513          	addi	a0,a0,-1940 # ffffffffc02074a0 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc0201c3c:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201c3e:	d50fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201c42:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c44:	00006517          	auipc	a0,0x6
ffffffffc0201c48:	80450513          	addi	a0,a0,-2044 # ffffffffc0207448 <default_pmm_manager+0xd0>
}
ffffffffc0201c4c:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c4e:	d40fe06f          	j	ffffffffc020018e <cprintf>

ffffffffc0201c52 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201c52:	4501                	li	a0,0
ffffffffc0201c54:	8082                	ret

ffffffffc0201c56 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201c56:	1101                	addi	sp,sp,-32
ffffffffc0201c58:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c5a:	6905                	lui	s2,0x1
{
ffffffffc0201c5c:	e822                	sd	s0,16(sp)
ffffffffc0201c5e:	ec06                	sd	ra,24(sp)
ffffffffc0201c60:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c62:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8591>
{
ffffffffc0201c66:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c68:	04a7fc63          	bleu	a0,a5,ffffffffc0201cc0 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201c6c:	4561                	li	a0,24
ffffffffc0201c6e:	ec1ff0ef          	jal	ra,ffffffffc0201b2e <slob_alloc.isra.1.constprop.3>
ffffffffc0201c72:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201c74:	cd21                	beqz	a0,ffffffffc0201ccc <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201c76:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201c7a:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c7c:	00f95763          	ble	a5,s2,ffffffffc0201c8a <kmalloc+0x34>
ffffffffc0201c80:	6705                	lui	a4,0x1
ffffffffc0201c82:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201c84:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c86:	fef74ee3          	blt	a4,a5,ffffffffc0201c82 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201c8a:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201c8c:	e2fff0ef          	jal	ra,ffffffffc0201aba <__slob_get_free_pages.isra.0>
ffffffffc0201c90:	e488                	sd	a0,8(s1)
ffffffffc0201c92:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201c94:	c935                	beqz	a0,ffffffffc0201d08 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c96:	100027f3          	csrr	a5,sstatus
ffffffffc0201c9a:	8b89                	andi	a5,a5,2
ffffffffc0201c9c:	e3a1                	bnez	a5,ffffffffc0201cdc <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201c9e:	000ab797          	auipc	a5,0xab
ffffffffc0201ca2:	8ca78793          	addi	a5,a5,-1846 # ffffffffc02ac568 <bigblocks>
ffffffffc0201ca6:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201ca8:	000ab717          	auipc	a4,0xab
ffffffffc0201cac:	8c973023          	sd	s1,-1856(a4) # ffffffffc02ac568 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201cb0:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201cb2:	8522                	mv	a0,s0
ffffffffc0201cb4:	60e2                	ld	ra,24(sp)
ffffffffc0201cb6:	6442                	ld	s0,16(sp)
ffffffffc0201cb8:	64a2                	ld	s1,8(sp)
ffffffffc0201cba:	6902                	ld	s2,0(sp)
ffffffffc0201cbc:	6105                	addi	sp,sp,32
ffffffffc0201cbe:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201cc0:	0541                	addi	a0,a0,16
ffffffffc0201cc2:	e6dff0ef          	jal	ra,ffffffffc0201b2e <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201cc6:	01050413          	addi	s0,a0,16
ffffffffc0201cca:	f565                	bnez	a0,ffffffffc0201cb2 <kmalloc+0x5c>
ffffffffc0201ccc:	4401                	li	s0,0
}
ffffffffc0201cce:	8522                	mv	a0,s0
ffffffffc0201cd0:	60e2                	ld	ra,24(sp)
ffffffffc0201cd2:	6442                	ld	s0,16(sp)
ffffffffc0201cd4:	64a2                	ld	s1,8(sp)
ffffffffc0201cd6:	6902                	ld	s2,0(sp)
ffffffffc0201cd8:	6105                	addi	sp,sp,32
ffffffffc0201cda:	8082                	ret
        intr_disable();
ffffffffc0201cdc:	97ffe0ef          	jal	ra,ffffffffc020065a <intr_disable>
		bb->next = bigblocks;
ffffffffc0201ce0:	000ab797          	auipc	a5,0xab
ffffffffc0201ce4:	88878793          	addi	a5,a5,-1912 # ffffffffc02ac568 <bigblocks>
ffffffffc0201ce8:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201cea:	000ab717          	auipc	a4,0xab
ffffffffc0201cee:	86973f23          	sd	s1,-1922(a4) # ffffffffc02ac568 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201cf2:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201cf4:	961fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0201cf8:	6480                	ld	s0,8(s1)
}
ffffffffc0201cfa:	60e2                	ld	ra,24(sp)
ffffffffc0201cfc:	64a2                	ld	s1,8(sp)
ffffffffc0201cfe:	8522                	mv	a0,s0
ffffffffc0201d00:	6442                	ld	s0,16(sp)
ffffffffc0201d02:	6902                	ld	s2,0(sp)
ffffffffc0201d04:	6105                	addi	sp,sp,32
ffffffffc0201d06:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d08:	45e1                	li	a1,24
ffffffffc0201d0a:	8526                	mv	a0,s1
ffffffffc0201d0c:	c99ff0ef          	jal	ra,ffffffffc02019a4 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201d10:	b74d                	j	ffffffffc0201cb2 <kmalloc+0x5c>

ffffffffc0201d12 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201d12:	c175                	beqz	a0,ffffffffc0201df6 <kfree+0xe4>
{
ffffffffc0201d14:	1101                	addi	sp,sp,-32
ffffffffc0201d16:	e426                	sd	s1,8(sp)
ffffffffc0201d18:	ec06                	sd	ra,24(sp)
ffffffffc0201d1a:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201d1c:	03451793          	slli	a5,a0,0x34
ffffffffc0201d20:	84aa                	mv	s1,a0
ffffffffc0201d22:	eb8d                	bnez	a5,ffffffffc0201d54 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d24:	100027f3          	csrr	a5,sstatus
ffffffffc0201d28:	8b89                	andi	a5,a5,2
ffffffffc0201d2a:	efc9                	bnez	a5,ffffffffc0201dc4 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d2c:	000ab797          	auipc	a5,0xab
ffffffffc0201d30:	83c78793          	addi	a5,a5,-1988 # ffffffffc02ac568 <bigblocks>
ffffffffc0201d34:	6394                	ld	a3,0(a5)
ffffffffc0201d36:	ce99                	beqz	a3,ffffffffc0201d54 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201d38:	669c                	ld	a5,8(a3)
ffffffffc0201d3a:	6a80                	ld	s0,16(a3)
ffffffffc0201d3c:	0af50e63          	beq	a0,a5,ffffffffc0201df8 <kfree+0xe6>
    return 0;
ffffffffc0201d40:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d42:	c801                	beqz	s0,ffffffffc0201d52 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201d44:	6418                	ld	a4,8(s0)
ffffffffc0201d46:	681c                	ld	a5,16(s0)
ffffffffc0201d48:	00970f63          	beq	a4,s1,ffffffffc0201d66 <kfree+0x54>
ffffffffc0201d4c:	86a2                	mv	a3,s0
ffffffffc0201d4e:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d50:	f875                	bnez	s0,ffffffffc0201d44 <kfree+0x32>
    if (flag) {
ffffffffc0201d52:	e659                	bnez	a2,ffffffffc0201de0 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201d54:	6442                	ld	s0,16(sp)
ffffffffc0201d56:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d58:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201d5c:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d5e:	4581                	li	a1,0
}
ffffffffc0201d60:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d62:	c43ff06f          	j	ffffffffc02019a4 <slob_free>
				*last = bb->next;
ffffffffc0201d66:	ea9c                	sd	a5,16(a3)
ffffffffc0201d68:	e641                	bnez	a2,ffffffffc0201df0 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0201d6a:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201d6e:	4018                	lw	a4,0(s0)
ffffffffc0201d70:	08f4ea63          	bltu	s1,a5,ffffffffc0201e04 <kfree+0xf2>
ffffffffc0201d74:	000ab797          	auipc	a5,0xab
ffffffffc0201d78:	86478793          	addi	a5,a5,-1948 # ffffffffc02ac5d8 <va_pa_offset>
ffffffffc0201d7c:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201d7e:	000aa797          	auipc	a5,0xaa
ffffffffc0201d82:	7fa78793          	addi	a5,a5,2042 # ffffffffc02ac578 <npage>
ffffffffc0201d86:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201d88:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201d8a:	80b1                	srli	s1,s1,0xc
ffffffffc0201d8c:	08f4f963          	bleu	a5,s1,ffffffffc0201e1e <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d90:	00007797          	auipc	a5,0x7
ffffffffc0201d94:	02878793          	addi	a5,a5,40 # ffffffffc0208db8 <nbase>
ffffffffc0201d98:	639c                	ld	a5,0(a5)
ffffffffc0201d9a:	000ab697          	auipc	a3,0xab
ffffffffc0201d9e:	84e68693          	addi	a3,a3,-1970 # ffffffffc02ac5e8 <pages>
ffffffffc0201da2:	6288                	ld	a0,0(a3)
ffffffffc0201da4:	8c9d                	sub	s1,s1,a5
ffffffffc0201da6:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201da8:	4585                	li	a1,1
ffffffffc0201daa:	9526                	add	a0,a0,s1
ffffffffc0201dac:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201db0:	12a000ef          	jal	ra,ffffffffc0201eda <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201db4:	8522                	mv	a0,s0
}
ffffffffc0201db6:	6442                	ld	s0,16(sp)
ffffffffc0201db8:	60e2                	ld	ra,24(sp)
ffffffffc0201dba:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201dbc:	45e1                	li	a1,24
}
ffffffffc0201dbe:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201dc0:	be5ff06f          	j	ffffffffc02019a4 <slob_free>
        intr_disable();
ffffffffc0201dc4:	897fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201dc8:	000aa797          	auipc	a5,0xaa
ffffffffc0201dcc:	7a078793          	addi	a5,a5,1952 # ffffffffc02ac568 <bigblocks>
ffffffffc0201dd0:	6394                	ld	a3,0(a5)
ffffffffc0201dd2:	c699                	beqz	a3,ffffffffc0201de0 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0201dd4:	669c                	ld	a5,8(a3)
ffffffffc0201dd6:	6a80                	ld	s0,16(a3)
ffffffffc0201dd8:	00f48763          	beq	s1,a5,ffffffffc0201de6 <kfree+0xd4>
        return 1;
ffffffffc0201ddc:	4605                	li	a2,1
ffffffffc0201dde:	b795                	j	ffffffffc0201d42 <kfree+0x30>
        intr_enable();
ffffffffc0201de0:	875fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0201de4:	bf85                	j	ffffffffc0201d54 <kfree+0x42>
				*last = bb->next;
ffffffffc0201de6:	000aa797          	auipc	a5,0xaa
ffffffffc0201dea:	7887b123          	sd	s0,1922(a5) # ffffffffc02ac568 <bigblocks>
ffffffffc0201dee:	8436                	mv	s0,a3
ffffffffc0201df0:	865fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0201df4:	bf9d                	j	ffffffffc0201d6a <kfree+0x58>
ffffffffc0201df6:	8082                	ret
ffffffffc0201df8:	000aa797          	auipc	a5,0xaa
ffffffffc0201dfc:	7687b823          	sd	s0,1904(a5) # ffffffffc02ac568 <bigblocks>
ffffffffc0201e00:	8436                	mv	s0,a3
ffffffffc0201e02:	b7a5                	j	ffffffffc0201d6a <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0201e04:	86a6                	mv	a3,s1
ffffffffc0201e06:	00005617          	auipc	a2,0x5
ffffffffc0201e0a:	5fa60613          	addi	a2,a2,1530 # ffffffffc0207400 <default_pmm_manager+0x88>
ffffffffc0201e0e:	06e00593          	li	a1,110
ffffffffc0201e12:	00005517          	auipc	a0,0x5
ffffffffc0201e16:	5de50513          	addi	a0,a0,1502 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc0201e1a:	e6afe0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201e1e:	00005617          	auipc	a2,0x5
ffffffffc0201e22:	60a60613          	addi	a2,a2,1546 # ffffffffc0207428 <default_pmm_manager+0xb0>
ffffffffc0201e26:	06200593          	li	a1,98
ffffffffc0201e2a:	00005517          	auipc	a0,0x5
ffffffffc0201e2e:	5c650513          	addi	a0,a0,1478 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc0201e32:	e52fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201e36 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201e36:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201e38:	00005617          	auipc	a2,0x5
ffffffffc0201e3c:	5f060613          	addi	a2,a2,1520 # ffffffffc0207428 <default_pmm_manager+0xb0>
ffffffffc0201e40:	06200593          	li	a1,98
ffffffffc0201e44:	00005517          	auipc	a0,0x5
ffffffffc0201e48:	5ac50513          	addi	a0,a0,1452 # ffffffffc02073f0 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201e4c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201e4e:	e36fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201e52 <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n)
{
ffffffffc0201e52:	715d                	addi	sp,sp,-80
ffffffffc0201e54:	e0a2                	sd	s0,64(sp)
ffffffffc0201e56:	fc26                	sd	s1,56(sp)
ffffffffc0201e58:	f84a                	sd	s2,48(sp)
ffffffffc0201e5a:	f44e                	sd	s3,40(sp)
ffffffffc0201e5c:	f052                	sd	s4,32(sp)
ffffffffc0201e5e:	ec56                	sd	s5,24(sp)
ffffffffc0201e60:	e486                	sd	ra,72(sp)
ffffffffc0201e62:	842a                	mv	s0,a0
ffffffffc0201e64:	000aa497          	auipc	s1,0xaa
ffffffffc0201e68:	76c48493          	addi	s1,s1,1900 # ffffffffc02ac5d0 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0)
ffffffffc0201e6c:	4985                	li	s3,1
ffffffffc0201e6e:	000aaa17          	auipc	s4,0xaa
ffffffffc0201e72:	71aa0a13          	addi	s4,s4,1818 # ffffffffc02ac588 <swap_init_ok>
            break;

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e76:	0005091b          	sext.w	s2,a0
ffffffffc0201e7a:	000aba97          	auipc	s5,0xab
ffffffffc0201e7e:	84ea8a93          	addi	s5,s5,-1970 # ffffffffc02ac6c8 <check_mm_struct>
ffffffffc0201e82:	a00d                	j	ffffffffc0201ea4 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e84:	609c                	ld	a5,0(s1)
ffffffffc0201e86:	6f9c                	ld	a5,24(a5)
ffffffffc0201e88:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e8a:	4601                	li	a2,0
ffffffffc0201e8c:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0)
ffffffffc0201e8e:	ed0d                	bnez	a0,ffffffffc0201ec8 <alloc_pages+0x76>
ffffffffc0201e90:	0289ec63          	bltu	s3,s0,ffffffffc0201ec8 <alloc_pages+0x76>
ffffffffc0201e94:	000a2783          	lw	a5,0(s4)
ffffffffc0201e98:	2781                	sext.w	a5,a5
ffffffffc0201e9a:	c79d                	beqz	a5,ffffffffc0201ec8 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e9c:	000ab503          	ld	a0,0(s5)
ffffffffc0201ea0:	48d010ef          	jal	ra,ffffffffc0203b2c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ea4:	100027f3          	csrr	a5,sstatus
ffffffffc0201ea8:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201eaa:	8522                	mv	a0,s0
ffffffffc0201eac:	dfe1                	beqz	a5,ffffffffc0201e84 <alloc_pages+0x32>
        intr_disable();
ffffffffc0201eae:	facfe0ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc0201eb2:	609c                	ld	a5,0(s1)
ffffffffc0201eb4:	8522                	mv	a0,s0
ffffffffc0201eb6:	6f9c                	ld	a5,24(a5)
ffffffffc0201eb8:	9782                	jalr	a5
ffffffffc0201eba:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201ebc:	f98fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0201ec0:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201ec2:	4601                	li	a2,0
ffffffffc0201ec4:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0)
ffffffffc0201ec6:	d569                	beqz	a0,ffffffffc0201e90 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201ec8:	60a6                	ld	ra,72(sp)
ffffffffc0201eca:	6406                	ld	s0,64(sp)
ffffffffc0201ecc:	74e2                	ld	s1,56(sp)
ffffffffc0201ece:	7942                	ld	s2,48(sp)
ffffffffc0201ed0:	79a2                	ld	s3,40(sp)
ffffffffc0201ed2:	7a02                	ld	s4,32(sp)
ffffffffc0201ed4:	6ae2                	ld	s5,24(sp)
ffffffffc0201ed6:	6161                	addi	sp,sp,80
ffffffffc0201ed8:	8082                	ret

ffffffffc0201eda <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201eda:	100027f3          	csrr	a5,sstatus
ffffffffc0201ede:	8b89                	andi	a5,a5,2
ffffffffc0201ee0:	eb89                	bnez	a5,ffffffffc0201ef2 <free_pages+0x18>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201ee2:	000aa797          	auipc	a5,0xaa
ffffffffc0201ee6:	6ee78793          	addi	a5,a5,1774 # ffffffffc02ac5d0 <pmm_manager>
ffffffffc0201eea:	639c                	ld	a5,0(a5)
ffffffffc0201eec:	0207b303          	ld	t1,32(a5)
ffffffffc0201ef0:	8302                	jr	t1
{
ffffffffc0201ef2:	1101                	addi	sp,sp,-32
ffffffffc0201ef4:	ec06                	sd	ra,24(sp)
ffffffffc0201ef6:	e822                	sd	s0,16(sp)
ffffffffc0201ef8:	e426                	sd	s1,8(sp)
ffffffffc0201efa:	842a                	mv	s0,a0
ffffffffc0201efc:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201efe:	f5cfe0ef          	jal	ra,ffffffffc020065a <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201f02:	000aa797          	auipc	a5,0xaa
ffffffffc0201f06:	6ce78793          	addi	a5,a5,1742 # ffffffffc02ac5d0 <pmm_manager>
ffffffffc0201f0a:	639c                	ld	a5,0(a5)
ffffffffc0201f0c:	85a6                	mv	a1,s1
ffffffffc0201f0e:	8522                	mv	a0,s0
ffffffffc0201f10:	739c                	ld	a5,32(a5)
ffffffffc0201f12:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201f14:	6442                	ld	s0,16(sp)
ffffffffc0201f16:	60e2                	ld	ra,24(sp)
ffffffffc0201f18:	64a2                	ld	s1,8(sp)
ffffffffc0201f1a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201f1c:	f38fe06f          	j	ffffffffc0200654 <intr_enable>

ffffffffc0201f20 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f20:	100027f3          	csrr	a5,sstatus
ffffffffc0201f24:	8b89                	andi	a5,a5,2
ffffffffc0201f26:	eb89                	bnez	a5,ffffffffc0201f38 <nr_free_pages+0x18>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f28:	000aa797          	auipc	a5,0xaa
ffffffffc0201f2c:	6a878793          	addi	a5,a5,1704 # ffffffffc02ac5d0 <pmm_manager>
ffffffffc0201f30:	639c                	ld	a5,0(a5)
ffffffffc0201f32:	0287b303          	ld	t1,40(a5)
ffffffffc0201f36:	8302                	jr	t1
{
ffffffffc0201f38:	1141                	addi	sp,sp,-16
ffffffffc0201f3a:	e406                	sd	ra,8(sp)
ffffffffc0201f3c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201f3e:	f1cfe0ef          	jal	ra,ffffffffc020065a <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f42:	000aa797          	auipc	a5,0xaa
ffffffffc0201f46:	68e78793          	addi	a5,a5,1678 # ffffffffc02ac5d0 <pmm_manager>
ffffffffc0201f4a:	639c                	ld	a5,0(a5)
ffffffffc0201f4c:	779c                	ld	a5,40(a5)
ffffffffc0201f4e:	9782                	jalr	a5
ffffffffc0201f50:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f52:	f02fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201f56:	8522                	mv	a0,s0
ffffffffc0201f58:	60a2                	ld	ra,8(sp)
ffffffffc0201f5a:	6402                	ld	s0,0(sp)
ffffffffc0201f5c:	0141                	addi	sp,sp,16
ffffffffc0201f5e:	8082                	ret

ffffffffc0201f60 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
ffffffffc0201f60:	7139                	addi	sp,sp,-64
ffffffffc0201f62:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201f64:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201f68:	1ff4f493          	andi	s1,s1,511
ffffffffc0201f6c:	048e                	slli	s1,s1,0x3
ffffffffc0201f6e:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V))
ffffffffc0201f70:	6094                	ld	a3,0(s1)
{
ffffffffc0201f72:	f04a                	sd	s2,32(sp)
ffffffffc0201f74:	ec4e                	sd	s3,24(sp)
ffffffffc0201f76:	e852                	sd	s4,16(sp)
ffffffffc0201f78:	fc06                	sd	ra,56(sp)
ffffffffc0201f7a:	f822                	sd	s0,48(sp)
ffffffffc0201f7c:	e456                	sd	s5,8(sp)
ffffffffc0201f7e:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0201f80:	0016f793          	andi	a5,a3,1
{
ffffffffc0201f84:	892e                	mv	s2,a1
ffffffffc0201f86:	8a32                	mv	s4,a2
ffffffffc0201f88:	000aa997          	auipc	s3,0xaa
ffffffffc0201f8c:	5f098993          	addi	s3,s3,1520 # ffffffffc02ac578 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0201f90:	e7bd                	bnez	a5,ffffffffc0201ffe <get_pte+0x9e>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201f92:	12060c63          	beqz	a2,ffffffffc02020ca <get_pte+0x16a>
ffffffffc0201f96:	4505                	li	a0,1
ffffffffc0201f98:	ebbff0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0201f9c:	842a                	mv	s0,a0
ffffffffc0201f9e:	12050663          	beqz	a0,ffffffffc02020ca <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201fa2:	000aab17          	auipc	s6,0xaa
ffffffffc0201fa6:	646b0b13          	addi	s6,s6,1606 # ffffffffc02ac5e8 <pages>
ffffffffc0201faa:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201fae:	4785                	li	a5,1
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fb0:	000aa997          	auipc	s3,0xaa
ffffffffc0201fb4:	5c898993          	addi	s3,s3,1480 # ffffffffc02ac578 <npage>
    return page - pages + nbase;
ffffffffc0201fb8:	40a40533          	sub	a0,s0,a0
ffffffffc0201fbc:	00080ab7          	lui	s5,0x80
ffffffffc0201fc0:	8519                	srai	a0,a0,0x6
ffffffffc0201fc2:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201fc6:	c01c                	sw	a5,0(s0)
ffffffffc0201fc8:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201fca:	9556                	add	a0,a0,s5
ffffffffc0201fcc:	83b1                	srli	a5,a5,0xc
ffffffffc0201fce:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fd0:	0532                	slli	a0,a0,0xc
ffffffffc0201fd2:	14e7f363          	bleu	a4,a5,ffffffffc0202118 <get_pte+0x1b8>
ffffffffc0201fd6:	000aa797          	auipc	a5,0xaa
ffffffffc0201fda:	60278793          	addi	a5,a5,1538 # ffffffffc02ac5d8 <va_pa_offset>
ffffffffc0201fde:	639c                	ld	a5,0(a5)
ffffffffc0201fe0:	6605                	lui	a2,0x1
ffffffffc0201fe2:	4581                	li	a1,0
ffffffffc0201fe4:	953e                	add	a0,a0,a5
ffffffffc0201fe6:	62e040ef          	jal	ra,ffffffffc0206614 <memset>
    return page - pages + nbase;
ffffffffc0201fea:	000b3683          	ld	a3,0(s6)
ffffffffc0201fee:	40d406b3          	sub	a3,s0,a3
ffffffffc0201ff2:	8699                	srai	a3,a3,0x6
ffffffffc0201ff4:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201ff6:	06aa                	slli	a3,a3,0xa
ffffffffc0201ff8:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201ffc:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201ffe:	77fd                	lui	a5,0xfffff
ffffffffc0202000:	068a                	slli	a3,a3,0x2
ffffffffc0202002:	0009b703          	ld	a4,0(s3)
ffffffffc0202006:	8efd                	and	a3,a3,a5
ffffffffc0202008:	00c6d793          	srli	a5,a3,0xc
ffffffffc020200c:	0ce7f163          	bleu	a4,a5,ffffffffc02020ce <get_pte+0x16e>
ffffffffc0202010:	000aaa97          	auipc	s5,0xaa
ffffffffc0202014:	5c8a8a93          	addi	s5,s5,1480 # ffffffffc02ac5d8 <va_pa_offset>
ffffffffc0202018:	000ab403          	ld	s0,0(s5)
ffffffffc020201c:	01595793          	srli	a5,s2,0x15
ffffffffc0202020:	1ff7f793          	andi	a5,a5,511
ffffffffc0202024:	96a2                	add	a3,a3,s0
ffffffffc0202026:	00379413          	slli	s0,a5,0x3
ffffffffc020202a:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V))
ffffffffc020202c:	6014                	ld	a3,0(s0)
ffffffffc020202e:	0016f793          	andi	a5,a3,1
ffffffffc0202032:	e3ad                	bnez	a5,ffffffffc0202094 <get_pte+0x134>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202034:	080a0b63          	beqz	s4,ffffffffc02020ca <get_pte+0x16a>
ffffffffc0202038:	4505                	li	a0,1
ffffffffc020203a:	e19ff0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020203e:	84aa                	mv	s1,a0
ffffffffc0202040:	c549                	beqz	a0,ffffffffc02020ca <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0202042:	000aab17          	auipc	s6,0xaa
ffffffffc0202046:	5a6b0b13          	addi	s6,s6,1446 # ffffffffc02ac5e8 <pages>
ffffffffc020204a:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc020204e:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0202050:	00080a37          	lui	s4,0x80
ffffffffc0202054:	40a48533          	sub	a0,s1,a0
ffffffffc0202058:	8519                	srai	a0,a0,0x6
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020205a:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc020205e:	c09c                	sw	a5,0(s1)
ffffffffc0202060:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0202062:	9552                	add	a0,a0,s4
ffffffffc0202064:	83b1                	srli	a5,a5,0xc
ffffffffc0202066:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202068:	0532                	slli	a0,a0,0xc
ffffffffc020206a:	08e7fa63          	bleu	a4,a5,ffffffffc02020fe <get_pte+0x19e>
ffffffffc020206e:	000ab783          	ld	a5,0(s5)
ffffffffc0202072:	6605                	lui	a2,0x1
ffffffffc0202074:	4581                	li	a1,0
ffffffffc0202076:	953e                	add	a0,a0,a5
ffffffffc0202078:	59c040ef          	jal	ra,ffffffffc0206614 <memset>
    return page - pages + nbase;
ffffffffc020207c:	000b3683          	ld	a3,0(s6)
ffffffffc0202080:	40d486b3          	sub	a3,s1,a3
ffffffffc0202084:	8699                	srai	a3,a3,0x6
ffffffffc0202086:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202088:	06aa                	slli	a3,a3,0xa
ffffffffc020208a:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020208e:	e014                	sd	a3,0(s0)
ffffffffc0202090:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202094:	068a                	slli	a3,a3,0x2
ffffffffc0202096:	757d                	lui	a0,0xfffff
ffffffffc0202098:	8ee9                	and	a3,a3,a0
ffffffffc020209a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020209e:	04e7f463          	bleu	a4,a5,ffffffffc02020e6 <get_pte+0x186>
ffffffffc02020a2:	000ab503          	ld	a0,0(s5)
ffffffffc02020a6:	00c95793          	srli	a5,s2,0xc
ffffffffc02020aa:	1ff7f793          	andi	a5,a5,511
ffffffffc02020ae:	96aa                	add	a3,a3,a0
ffffffffc02020b0:	00379513          	slli	a0,a5,0x3
ffffffffc02020b4:	9536                	add	a0,a0,a3
}
ffffffffc02020b6:	70e2                	ld	ra,56(sp)
ffffffffc02020b8:	7442                	ld	s0,48(sp)
ffffffffc02020ba:	74a2                	ld	s1,40(sp)
ffffffffc02020bc:	7902                	ld	s2,32(sp)
ffffffffc02020be:	69e2                	ld	s3,24(sp)
ffffffffc02020c0:	6a42                	ld	s4,16(sp)
ffffffffc02020c2:	6aa2                	ld	s5,8(sp)
ffffffffc02020c4:	6b02                	ld	s6,0(sp)
ffffffffc02020c6:	6121                	addi	sp,sp,64
ffffffffc02020c8:	8082                	ret
            return NULL;
ffffffffc02020ca:	4501                	li	a0,0
ffffffffc02020cc:	b7ed                	j	ffffffffc02020b6 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02020ce:	00005617          	auipc	a2,0x5
ffffffffc02020d2:	2fa60613          	addi	a2,a2,762 # ffffffffc02073c8 <default_pmm_manager+0x50>
ffffffffc02020d6:	0f500593          	li	a1,245
ffffffffc02020da:	00005517          	auipc	a0,0x5
ffffffffc02020de:	40e50513          	addi	a0,a0,1038 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc02020e2:	ba2fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02020e6:	00005617          	auipc	a2,0x5
ffffffffc02020ea:	2e260613          	addi	a2,a2,738 # ffffffffc02073c8 <default_pmm_manager+0x50>
ffffffffc02020ee:	10200593          	li	a1,258
ffffffffc02020f2:	00005517          	auipc	a0,0x5
ffffffffc02020f6:	3f650513          	addi	a0,a0,1014 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc02020fa:	b8afe0ef          	jal	ra,ffffffffc0200484 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020fe:	86aa                	mv	a3,a0
ffffffffc0202100:	00005617          	auipc	a2,0x5
ffffffffc0202104:	2c860613          	addi	a2,a2,712 # ffffffffc02073c8 <default_pmm_manager+0x50>
ffffffffc0202108:	0ff00593          	li	a1,255
ffffffffc020210c:	00005517          	auipc	a0,0x5
ffffffffc0202110:	3dc50513          	addi	a0,a0,988 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202114:	b70fe0ef          	jal	ra,ffffffffc0200484 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202118:	86aa                	mv	a3,a0
ffffffffc020211a:	00005617          	auipc	a2,0x5
ffffffffc020211e:	2ae60613          	addi	a2,a2,686 # ffffffffc02073c8 <default_pmm_manager+0x50>
ffffffffc0202122:	0f100593          	li	a1,241
ffffffffc0202126:	00005517          	auipc	a0,0x5
ffffffffc020212a:	3c250513          	addi	a0,a0,962 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc020212e:	b56fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0202132 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc0202132:	1141                	addi	sp,sp,-16
ffffffffc0202134:	e022                	sd	s0,0(sp)
ffffffffc0202136:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202138:	4601                	li	a2,0
{
ffffffffc020213a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020213c:	e25ff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
    if (ptep_store != NULL)
ffffffffc0202140:	c011                	beqz	s0,ffffffffc0202144 <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc0202142:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202144:	c129                	beqz	a0,ffffffffc0202186 <get_page+0x54>
ffffffffc0202146:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202148:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc020214a:	0017f713          	andi	a4,a5,1
ffffffffc020214e:	e709                	bnez	a4,ffffffffc0202158 <get_page+0x26>
}
ffffffffc0202150:	60a2                	ld	ra,8(sp)
ffffffffc0202152:	6402                	ld	s0,0(sp)
ffffffffc0202154:	0141                	addi	sp,sp,16
ffffffffc0202156:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202158:	000aa717          	auipc	a4,0xaa
ffffffffc020215c:	42070713          	addi	a4,a4,1056 # ffffffffc02ac578 <npage>
ffffffffc0202160:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202162:	078a                	slli	a5,a5,0x2
ffffffffc0202164:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202166:	02e7f563          	bleu	a4,a5,ffffffffc0202190 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc020216a:	000aa717          	auipc	a4,0xaa
ffffffffc020216e:	47e70713          	addi	a4,a4,1150 # ffffffffc02ac5e8 <pages>
ffffffffc0202172:	6308                	ld	a0,0(a4)
ffffffffc0202174:	60a2                	ld	ra,8(sp)
ffffffffc0202176:	6402                	ld	s0,0(sp)
ffffffffc0202178:	fff80737          	lui	a4,0xfff80
ffffffffc020217c:	97ba                	add	a5,a5,a4
ffffffffc020217e:	079a                	slli	a5,a5,0x6
ffffffffc0202180:	953e                	add	a0,a0,a5
ffffffffc0202182:	0141                	addi	sp,sp,16
ffffffffc0202184:	8082                	ret
ffffffffc0202186:	60a2                	ld	ra,8(sp)
ffffffffc0202188:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc020218a:	4501                	li	a0,0
}
ffffffffc020218c:	0141                	addi	sp,sp,16
ffffffffc020218e:	8082                	ret
ffffffffc0202190:	ca7ff0ef          	jal	ra,ffffffffc0201e36 <pa2page.part.4>

ffffffffc0202194 <unmap_range>:
        tlb_invalidate(pgdir, la); //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc0202194:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202196:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc020219a:	ec86                	sd	ra,88(sp)
ffffffffc020219c:	e8a2                	sd	s0,80(sp)
ffffffffc020219e:	e4a6                	sd	s1,72(sp)
ffffffffc02021a0:	e0ca                	sd	s2,64(sp)
ffffffffc02021a2:	fc4e                	sd	s3,56(sp)
ffffffffc02021a4:	f852                	sd	s4,48(sp)
ffffffffc02021a6:	f456                	sd	s5,40(sp)
ffffffffc02021a8:	f05a                	sd	s6,32(sp)
ffffffffc02021aa:	ec5e                	sd	s7,24(sp)
ffffffffc02021ac:	e862                	sd	s8,16(sp)
ffffffffc02021ae:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02021b0:	03479713          	slli	a4,a5,0x34
ffffffffc02021b4:	eb71                	bnez	a4,ffffffffc0202288 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc02021b6:	002007b7          	lui	a5,0x200
ffffffffc02021ba:	842e                	mv	s0,a1
ffffffffc02021bc:	0af5e663          	bltu	a1,a5,ffffffffc0202268 <unmap_range+0xd4>
ffffffffc02021c0:	8932                	mv	s2,a2
ffffffffc02021c2:	0ac5f363          	bleu	a2,a1,ffffffffc0202268 <unmap_range+0xd4>
ffffffffc02021c6:	4785                	li	a5,1
ffffffffc02021c8:	07fe                	slli	a5,a5,0x1f
ffffffffc02021ca:	08c7ef63          	bltu	a5,a2,ffffffffc0202268 <unmap_range+0xd4>
ffffffffc02021ce:	89aa                	mv	s3,a0
        }
        if (*ptep != 0)
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02021d0:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02021d2:	000aac97          	auipc	s9,0xaa
ffffffffc02021d6:	3a6c8c93          	addi	s9,s9,934 # ffffffffc02ac578 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02021da:	000aac17          	auipc	s8,0xaa
ffffffffc02021de:	40ec0c13          	addi	s8,s8,1038 # ffffffffc02ac5e8 <pages>
ffffffffc02021e2:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02021e6:	00200b37          	lui	s6,0x200
ffffffffc02021ea:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02021ee:	4601                	li	a2,0
ffffffffc02021f0:	85a2                	mv	a1,s0
ffffffffc02021f2:	854e                	mv	a0,s3
ffffffffc02021f4:	d6dff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc02021f8:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc02021fa:	cd21                	beqz	a0,ffffffffc0202252 <unmap_range+0xbe>
        if (*ptep != 0)
ffffffffc02021fc:	611c                	ld	a5,0(a0)
ffffffffc02021fe:	e38d                	bnez	a5,ffffffffc0202220 <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc0202200:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202202:	ff2466e3          	bltu	s0,s2,ffffffffc02021ee <unmap_range+0x5a>
}
ffffffffc0202206:	60e6                	ld	ra,88(sp)
ffffffffc0202208:	6446                	ld	s0,80(sp)
ffffffffc020220a:	64a6                	ld	s1,72(sp)
ffffffffc020220c:	6906                	ld	s2,64(sp)
ffffffffc020220e:	79e2                	ld	s3,56(sp)
ffffffffc0202210:	7a42                	ld	s4,48(sp)
ffffffffc0202212:	7aa2                	ld	s5,40(sp)
ffffffffc0202214:	7b02                	ld	s6,32(sp)
ffffffffc0202216:	6be2                	ld	s7,24(sp)
ffffffffc0202218:	6c42                	ld	s8,16(sp)
ffffffffc020221a:	6ca2                	ld	s9,8(sp)
ffffffffc020221c:	6125                	addi	sp,sp,96
ffffffffc020221e:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc0202220:	0017f713          	andi	a4,a5,1
ffffffffc0202224:	df71                	beqz	a4,ffffffffc0202200 <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc0202226:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020222a:	078a                	slli	a5,a5,0x2
ffffffffc020222c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020222e:	06e7fd63          	bleu	a4,a5,ffffffffc02022a8 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc0202232:	000c3503          	ld	a0,0(s8)
ffffffffc0202236:	97de                	add	a5,a5,s7
ffffffffc0202238:	079a                	slli	a5,a5,0x6
ffffffffc020223a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020223c:	411c                	lw	a5,0(a0)
ffffffffc020223e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202242:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202244:	cf11                	beqz	a4,ffffffffc0202260 <unmap_range+0xcc>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc0202246:	0004b023          	sd	zero,0(s1)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020224a:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020224e:	9452                	add	s0,s0,s4
ffffffffc0202250:	bf4d                	j	ffffffffc0202202 <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202252:	945a                	add	s0,s0,s6
ffffffffc0202254:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0202258:	d45d                	beqz	s0,ffffffffc0202206 <unmap_range+0x72>
ffffffffc020225a:	f9246ae3          	bltu	s0,s2,ffffffffc02021ee <unmap_range+0x5a>
ffffffffc020225e:	b765                	j	ffffffffc0202206 <unmap_range+0x72>
            free_page(page);
ffffffffc0202260:	4585                	li	a1,1
ffffffffc0202262:	c79ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
ffffffffc0202266:	b7c5                	j	ffffffffc0202246 <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc0202268:	00006697          	auipc	a3,0x6
ffffffffc020226c:	83068693          	addi	a3,a3,-2000 # ffffffffc0207a98 <default_pmm_manager+0x720>
ffffffffc0202270:	00005617          	auipc	a2,0x5
ffffffffc0202274:	9c060613          	addi	a2,a2,-1600 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202278:	12b00593          	li	a1,299
ffffffffc020227c:	00005517          	auipc	a0,0x5
ffffffffc0202280:	26c50513          	addi	a0,a0,620 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202284:	a00fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202288:	00005697          	auipc	a3,0x5
ffffffffc020228c:	7e068693          	addi	a3,a3,2016 # ffffffffc0207a68 <default_pmm_manager+0x6f0>
ffffffffc0202290:	00005617          	auipc	a2,0x5
ffffffffc0202294:	9a060613          	addi	a2,a2,-1632 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202298:	12a00593          	li	a1,298
ffffffffc020229c:	00005517          	auipc	a0,0x5
ffffffffc02022a0:	24c50513          	addi	a0,a0,588 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc02022a4:	9e0fe0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc02022a8:	b8fff0ef          	jal	ra,ffffffffc0201e36 <pa2page.part.4>

ffffffffc02022ac <exit_range>:
{
ffffffffc02022ac:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022ae:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc02022b2:	fc86                	sd	ra,120(sp)
ffffffffc02022b4:	f8a2                	sd	s0,112(sp)
ffffffffc02022b6:	f4a6                	sd	s1,104(sp)
ffffffffc02022b8:	f0ca                	sd	s2,96(sp)
ffffffffc02022ba:	ecce                	sd	s3,88(sp)
ffffffffc02022bc:	e8d2                	sd	s4,80(sp)
ffffffffc02022be:	e4d6                	sd	s5,72(sp)
ffffffffc02022c0:	e0da                	sd	s6,64(sp)
ffffffffc02022c2:	fc5e                	sd	s7,56(sp)
ffffffffc02022c4:	f862                	sd	s8,48(sp)
ffffffffc02022c6:	f466                	sd	s9,40(sp)
ffffffffc02022c8:	f06a                	sd	s10,32(sp)
ffffffffc02022ca:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022cc:	03479713          	slli	a4,a5,0x34
ffffffffc02022d0:	1c071163          	bnez	a4,ffffffffc0202492 <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc02022d4:	002007b7          	lui	a5,0x200
ffffffffc02022d8:	20f5e563          	bltu	a1,a5,ffffffffc02024e2 <exit_range+0x236>
ffffffffc02022dc:	8b32                	mv	s6,a2
ffffffffc02022de:	20c5f263          	bleu	a2,a1,ffffffffc02024e2 <exit_range+0x236>
ffffffffc02022e2:	4785                	li	a5,1
ffffffffc02022e4:	07fe                	slli	a5,a5,0x1f
ffffffffc02022e6:	1ec7ee63          	bltu	a5,a2,ffffffffc02024e2 <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02022ea:	c00009b7          	lui	s3,0xc0000
ffffffffc02022ee:	400007b7          	lui	a5,0x40000
ffffffffc02022f2:	0135f9b3          	and	s3,a1,s3
ffffffffc02022f6:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02022f8:	c0000337          	lui	t1,0xc0000
ffffffffc02022fc:	00698933          	add	s2,s3,t1
ffffffffc0202300:	01e95913          	srli	s2,s2,0x1e
ffffffffc0202304:	1ff97913          	andi	s2,s2,511
ffffffffc0202308:	8e2a                	mv	t3,a0
ffffffffc020230a:	090e                	slli	s2,s2,0x3
ffffffffc020230c:	9972                	add	s2,s2,t3
ffffffffc020230e:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202312:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc0202316:	5dfd                	li	s11,-1
        if (pde1 & PTE_V)
ffffffffc0202318:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020231c:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc020231e:	000aad17          	auipc	s10,0xaa
ffffffffc0202322:	25ad0d13          	addi	s10,s10,602 # ffffffffc02ac578 <npage>
    return KADDR(page2pa(page));
ffffffffc0202326:	00cddd93          	srli	s11,s11,0xc
ffffffffc020232a:	000aa717          	auipc	a4,0xaa
ffffffffc020232e:	2ae70713          	addi	a4,a4,686 # ffffffffc02ac5d8 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc0202332:	000aae97          	auipc	t4,0xaa
ffffffffc0202336:	2b6e8e93          	addi	t4,t4,694 # ffffffffc02ac5e8 <pages>
        if (pde1 & PTE_V)
ffffffffc020233a:	e79d                	bnez	a5,ffffffffc0202368 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc020233c:	12098963          	beqz	s3,ffffffffc020246e <exit_range+0x1c2>
ffffffffc0202340:	400007b7          	lui	a5,0x40000
ffffffffc0202344:	84ce                	mv	s1,s3
ffffffffc0202346:	97ce                	add	a5,a5,s3
ffffffffc0202348:	1369f363          	bleu	s6,s3,ffffffffc020246e <exit_range+0x1c2>
ffffffffc020234c:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc020234e:	00698933          	add	s2,s3,t1
ffffffffc0202352:	01e95913          	srli	s2,s2,0x1e
ffffffffc0202356:	1ff97913          	andi	s2,s2,511
ffffffffc020235a:	090e                	slli	s2,s2,0x3
ffffffffc020235c:	9972                	add	s2,s2,t3
ffffffffc020235e:	00093b83          	ld	s7,0(s2)
        if (pde1 & PTE_V)
ffffffffc0202362:	001bf793          	andi	a5,s7,1
ffffffffc0202366:	dbf9                	beqz	a5,ffffffffc020233c <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202368:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc020236c:	0b8a                	slli	s7,s7,0x2
ffffffffc020236e:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202372:	14fbfc63          	bleu	a5,s7,ffffffffc02024ca <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202376:	fff80ab7          	lui	s5,0xfff80
ffffffffc020237a:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc020237c:	000806b7          	lui	a3,0x80
ffffffffc0202380:	96d6                	add	a3,a3,s5
ffffffffc0202382:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc0202386:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc020238a:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc020238c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020238e:	12f67263          	bleu	a5,a2,ffffffffc02024b2 <exit_range+0x206>
ffffffffc0202392:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc0202396:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202398:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc020239c:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc020239e:	00080837          	lui	a6,0x80
ffffffffc02023a2:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc02023a4:	00200c37          	lui	s8,0x200
ffffffffc02023a8:	a801                	j	ffffffffc02023b8 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc02023aa:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc02023ac:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc02023ae:	c0d9                	beqz	s1,ffffffffc0202434 <exit_range+0x188>
ffffffffc02023b0:	0934f263          	bleu	s3,s1,ffffffffc0202434 <exit_range+0x188>
ffffffffc02023b4:	0d64fc63          	bleu	s6,s1,ffffffffc020248c <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02023b8:	0154d413          	srli	s0,s1,0x15
ffffffffc02023bc:	1ff47413          	andi	s0,s0,511
ffffffffc02023c0:	040e                	slli	s0,s0,0x3
ffffffffc02023c2:	9452                	add	s0,s0,s4
ffffffffc02023c4:	601c                	ld	a5,0(s0)
                if (pde0 & PTE_V)
ffffffffc02023c6:	0017f693          	andi	a3,a5,1
ffffffffc02023ca:	d2e5                	beqz	a3,ffffffffc02023aa <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc02023cc:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023d0:	00279513          	slli	a0,a5,0x2
ffffffffc02023d4:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023d6:	0eb57a63          	bleu	a1,a0,ffffffffc02024ca <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02023da:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc02023dc:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc02023e0:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc02023e4:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02023e6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023e8:	0cb7f563          	bleu	a1,a5,ffffffffc02024b2 <exit_range+0x206>
ffffffffc02023ec:	631c                	ld	a5,0(a4)
ffffffffc02023ee:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02023f0:	015685b3          	add	a1,a3,s5
                        if (pt[i] & PTE_V)
ffffffffc02023f4:	629c                	ld	a5,0(a3)
ffffffffc02023f6:	8b85                	andi	a5,a5,1
ffffffffc02023f8:	fbd5                	bnez	a5,ffffffffc02023ac <exit_range+0x100>
ffffffffc02023fa:	06a1                	addi	a3,a3,8
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02023fc:	fed59ce3          	bne	a1,a3,ffffffffc02023f4 <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc0202400:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc0202404:	4585                	li	a1,1
ffffffffc0202406:	e072                	sd	t3,0(sp)
ffffffffc0202408:	953e                	add	a0,a0,a5
ffffffffc020240a:	ad1ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
                d0start += PTSIZE;
ffffffffc020240e:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202410:	00043023          	sd	zero,0(s0)
ffffffffc0202414:	000aae97          	auipc	t4,0xaa
ffffffffc0202418:	1d4e8e93          	addi	t4,t4,468 # ffffffffc02ac5e8 <pages>
ffffffffc020241c:	6e02                	ld	t3,0(sp)
ffffffffc020241e:	c0000337          	lui	t1,0xc0000
ffffffffc0202422:	fff808b7          	lui	a7,0xfff80
ffffffffc0202426:	00080837          	lui	a6,0x80
ffffffffc020242a:	000aa717          	auipc	a4,0xaa
ffffffffc020242e:	1ae70713          	addi	a4,a4,430 # ffffffffc02ac5d8 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202432:	fcbd                	bnez	s1,ffffffffc02023b0 <exit_range+0x104>
            if (free_pd0)
ffffffffc0202434:	f00c84e3          	beqz	s9,ffffffffc020233c <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202438:	000d3783          	ld	a5,0(s10)
ffffffffc020243c:	e072                	sd	t3,0(sp)
ffffffffc020243e:	08fbf663          	bleu	a5,s7,ffffffffc02024ca <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202442:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc0202446:	67a2                	ld	a5,8(sp)
ffffffffc0202448:	4585                	li	a1,1
ffffffffc020244a:	953e                	add	a0,a0,a5
ffffffffc020244c:	a8fff0ef          	jal	ra,ffffffffc0201eda <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202450:	00093023          	sd	zero,0(s2)
ffffffffc0202454:	000aa717          	auipc	a4,0xaa
ffffffffc0202458:	18470713          	addi	a4,a4,388 # ffffffffc02ac5d8 <va_pa_offset>
ffffffffc020245c:	c0000337          	lui	t1,0xc0000
ffffffffc0202460:	6e02                	ld	t3,0(sp)
ffffffffc0202462:	000aae97          	auipc	t4,0xaa
ffffffffc0202466:	186e8e93          	addi	t4,t4,390 # ffffffffc02ac5e8 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc020246a:	ec099be3          	bnez	s3,ffffffffc0202340 <exit_range+0x94>
}
ffffffffc020246e:	70e6                	ld	ra,120(sp)
ffffffffc0202470:	7446                	ld	s0,112(sp)
ffffffffc0202472:	74a6                	ld	s1,104(sp)
ffffffffc0202474:	7906                	ld	s2,96(sp)
ffffffffc0202476:	69e6                	ld	s3,88(sp)
ffffffffc0202478:	6a46                	ld	s4,80(sp)
ffffffffc020247a:	6aa6                	ld	s5,72(sp)
ffffffffc020247c:	6b06                	ld	s6,64(sp)
ffffffffc020247e:	7be2                	ld	s7,56(sp)
ffffffffc0202480:	7c42                	ld	s8,48(sp)
ffffffffc0202482:	7ca2                	ld	s9,40(sp)
ffffffffc0202484:	7d02                	ld	s10,32(sp)
ffffffffc0202486:	6de2                	ld	s11,24(sp)
ffffffffc0202488:	6109                	addi	sp,sp,128
ffffffffc020248a:	8082                	ret
            if (free_pd0)
ffffffffc020248c:	ea0c8ae3          	beqz	s9,ffffffffc0202340 <exit_range+0x94>
ffffffffc0202490:	b765                	j	ffffffffc0202438 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202492:	00005697          	auipc	a3,0x5
ffffffffc0202496:	5d668693          	addi	a3,a3,1494 # ffffffffc0207a68 <default_pmm_manager+0x6f0>
ffffffffc020249a:	00004617          	auipc	a2,0x4
ffffffffc020249e:	79660613          	addi	a2,a2,1942 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02024a2:	13f00593          	li	a1,319
ffffffffc02024a6:	00005517          	auipc	a0,0x5
ffffffffc02024aa:	04250513          	addi	a0,a0,66 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc02024ae:	fd7fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc02024b2:	00005617          	auipc	a2,0x5
ffffffffc02024b6:	f1660613          	addi	a2,a2,-234 # ffffffffc02073c8 <default_pmm_manager+0x50>
ffffffffc02024ba:	06900593          	li	a1,105
ffffffffc02024be:	00005517          	auipc	a0,0x5
ffffffffc02024c2:	f3250513          	addi	a0,a0,-206 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc02024c6:	fbffd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02024ca:	00005617          	auipc	a2,0x5
ffffffffc02024ce:	f5e60613          	addi	a2,a2,-162 # ffffffffc0207428 <default_pmm_manager+0xb0>
ffffffffc02024d2:	06200593          	li	a1,98
ffffffffc02024d6:	00005517          	auipc	a0,0x5
ffffffffc02024da:	f1a50513          	addi	a0,a0,-230 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc02024de:	fa7fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02024e2:	00005697          	auipc	a3,0x5
ffffffffc02024e6:	5b668693          	addi	a3,a3,1462 # ffffffffc0207a98 <default_pmm_manager+0x720>
ffffffffc02024ea:	00004617          	auipc	a2,0x4
ffffffffc02024ee:	74660613          	addi	a2,a2,1862 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02024f2:	14000593          	li	a1,320
ffffffffc02024f6:	00005517          	auipc	a0,0x5
ffffffffc02024fa:	ff250513          	addi	a0,a0,-14 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc02024fe:	f87fd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0202502 <page_remove>:
{
ffffffffc0202502:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202504:	4601                	li	a2,0
{
ffffffffc0202506:	e426                	sd	s1,8(sp)
ffffffffc0202508:	ec06                	sd	ra,24(sp)
ffffffffc020250a:	e822                	sd	s0,16(sp)
ffffffffc020250c:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020250e:	a53ff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
    if (ptep != NULL)
ffffffffc0202512:	c511                	beqz	a0,ffffffffc020251e <page_remove+0x1c>
    if (*ptep & PTE_V)
ffffffffc0202514:	611c                	ld	a5,0(a0)
ffffffffc0202516:	842a                	mv	s0,a0
ffffffffc0202518:	0017f713          	andi	a4,a5,1
ffffffffc020251c:	e711                	bnez	a4,ffffffffc0202528 <page_remove+0x26>
}
ffffffffc020251e:	60e2                	ld	ra,24(sp)
ffffffffc0202520:	6442                	ld	s0,16(sp)
ffffffffc0202522:	64a2                	ld	s1,8(sp)
ffffffffc0202524:	6105                	addi	sp,sp,32
ffffffffc0202526:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202528:	000aa717          	auipc	a4,0xaa
ffffffffc020252c:	05070713          	addi	a4,a4,80 # ffffffffc02ac578 <npage>
ffffffffc0202530:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202532:	078a                	slli	a5,a5,0x2
ffffffffc0202534:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202536:	02e7fe63          	bleu	a4,a5,ffffffffc0202572 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc020253a:	000aa717          	auipc	a4,0xaa
ffffffffc020253e:	0ae70713          	addi	a4,a4,174 # ffffffffc02ac5e8 <pages>
ffffffffc0202542:	6308                	ld	a0,0(a4)
ffffffffc0202544:	fff80737          	lui	a4,0xfff80
ffffffffc0202548:	97ba                	add	a5,a5,a4
ffffffffc020254a:	079a                	slli	a5,a5,0x6
ffffffffc020254c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020254e:	411c                	lw	a5,0(a0)
ffffffffc0202550:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202554:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202556:	cb11                	beqz	a4,ffffffffc020256a <page_remove+0x68>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc0202558:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020255c:	12048073          	sfence.vma	s1
}
ffffffffc0202560:	60e2                	ld	ra,24(sp)
ffffffffc0202562:	6442                	ld	s0,16(sp)
ffffffffc0202564:	64a2                	ld	s1,8(sp)
ffffffffc0202566:	6105                	addi	sp,sp,32
ffffffffc0202568:	8082                	ret
            free_page(page);
ffffffffc020256a:	4585                	li	a1,1
ffffffffc020256c:	96fff0ef          	jal	ra,ffffffffc0201eda <free_pages>
ffffffffc0202570:	b7e5                	j	ffffffffc0202558 <page_remove+0x56>
ffffffffc0202572:	8c5ff0ef          	jal	ra,ffffffffc0201e36 <pa2page.part.4>

ffffffffc0202576 <page_insert>:
{
ffffffffc0202576:	7179                	addi	sp,sp,-48
ffffffffc0202578:	e44e                	sd	s3,8(sp)
ffffffffc020257a:	89b2                	mv	s3,a2
ffffffffc020257c:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020257e:	4605                	li	a2,1
{
ffffffffc0202580:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202582:	85ce                	mv	a1,s3
{
ffffffffc0202584:	ec26                	sd	s1,24(sp)
ffffffffc0202586:	f406                	sd	ra,40(sp)
ffffffffc0202588:	e84a                	sd	s2,16(sp)
ffffffffc020258a:	e052                	sd	s4,0(sp)
ffffffffc020258c:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020258e:	9d3ff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
    if (ptep == NULL)
ffffffffc0202592:	cd49                	beqz	a0,ffffffffc020262c <page_insert+0xb6>
    page->ref += 1;
ffffffffc0202594:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V)
ffffffffc0202596:	611c                	ld	a5,0(a0)
ffffffffc0202598:	892a                	mv	s2,a0
ffffffffc020259a:	0016871b          	addiw	a4,a3,1
ffffffffc020259e:	c018                	sw	a4,0(s0)
ffffffffc02025a0:	0017f713          	andi	a4,a5,1
ffffffffc02025a4:	ef05                	bnez	a4,ffffffffc02025dc <page_insert+0x66>
ffffffffc02025a6:	000aa797          	auipc	a5,0xaa
ffffffffc02025aa:	04278793          	addi	a5,a5,66 # ffffffffc02ac5e8 <pages>
ffffffffc02025ae:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc02025b0:	8c19                	sub	s0,s0,a4
ffffffffc02025b2:	000806b7          	lui	a3,0x80
ffffffffc02025b6:	8419                	srai	s0,s0,0x6
ffffffffc02025b8:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02025ba:	042a                	slli	s0,s0,0xa
ffffffffc02025bc:	8c45                	or	s0,s0,s1
ffffffffc02025be:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02025c2:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025c6:	12098073          	sfence.vma	s3
    return 0;
ffffffffc02025ca:	4501                	li	a0,0
}
ffffffffc02025cc:	70a2                	ld	ra,40(sp)
ffffffffc02025ce:	7402                	ld	s0,32(sp)
ffffffffc02025d0:	64e2                	ld	s1,24(sp)
ffffffffc02025d2:	6942                	ld	s2,16(sp)
ffffffffc02025d4:	69a2                	ld	s3,8(sp)
ffffffffc02025d6:	6a02                	ld	s4,0(sp)
ffffffffc02025d8:	6145                	addi	sp,sp,48
ffffffffc02025da:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02025dc:	000aa717          	auipc	a4,0xaa
ffffffffc02025e0:	f9c70713          	addi	a4,a4,-100 # ffffffffc02ac578 <npage>
ffffffffc02025e4:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02025e6:	078a                	slli	a5,a5,0x2
ffffffffc02025e8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025ea:	04e7f363          	bleu	a4,a5,ffffffffc0202630 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc02025ee:	000aaa17          	auipc	s4,0xaa
ffffffffc02025f2:	ffaa0a13          	addi	s4,s4,-6 # ffffffffc02ac5e8 <pages>
ffffffffc02025f6:	000a3703          	ld	a4,0(s4)
ffffffffc02025fa:	fff80537          	lui	a0,0xfff80
ffffffffc02025fe:	953e                	add	a0,a0,a5
ffffffffc0202600:	051a                	slli	a0,a0,0x6
ffffffffc0202602:	953a                	add	a0,a0,a4
        if (p == page)
ffffffffc0202604:	00a40a63          	beq	s0,a0,ffffffffc0202618 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0202608:	411c                	lw	a5,0(a0)
ffffffffc020260a:	fff7869b          	addiw	a3,a5,-1
ffffffffc020260e:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0202610:	c691                	beqz	a3,ffffffffc020261c <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202612:	12098073          	sfence.vma	s3
ffffffffc0202616:	bf69                	j	ffffffffc02025b0 <page_insert+0x3a>
ffffffffc0202618:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc020261a:	bf59                	j	ffffffffc02025b0 <page_insert+0x3a>
            free_page(page);
ffffffffc020261c:	4585                	li	a1,1
ffffffffc020261e:	8bdff0ef          	jal	ra,ffffffffc0201eda <free_pages>
ffffffffc0202622:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202626:	12098073          	sfence.vma	s3
ffffffffc020262a:	b759                	j	ffffffffc02025b0 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020262c:	5571                	li	a0,-4
ffffffffc020262e:	bf79                	j	ffffffffc02025cc <page_insert+0x56>
ffffffffc0202630:	807ff0ef          	jal	ra,ffffffffc0201e36 <pa2page.part.4>

ffffffffc0202634 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202634:	00005797          	auipc	a5,0x5
ffffffffc0202638:	d4478793          	addi	a5,a5,-700 # ffffffffc0207378 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020263c:	638c                	ld	a1,0(a5)
{
ffffffffc020263e:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202640:	00005517          	auipc	a0,0x5
ffffffffc0202644:	ed050513          	addi	a0,a0,-304 # ffffffffc0207510 <default_pmm_manager+0x198>
{
ffffffffc0202648:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020264a:	000aa717          	auipc	a4,0xaa
ffffffffc020264e:	f8f73323          	sd	a5,-122(a4) # ffffffffc02ac5d0 <pmm_manager>
{
ffffffffc0202652:	e0a2                	sd	s0,64(sp)
ffffffffc0202654:	fc26                	sd	s1,56(sp)
ffffffffc0202656:	f84a                	sd	s2,48(sp)
ffffffffc0202658:	f44e                	sd	s3,40(sp)
ffffffffc020265a:	f052                	sd	s4,32(sp)
ffffffffc020265c:	ec56                	sd	s5,24(sp)
ffffffffc020265e:	e85a                	sd	s6,16(sp)
ffffffffc0202660:	e45e                	sd	s7,8(sp)
ffffffffc0202662:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202664:	000aa417          	auipc	s0,0xaa
ffffffffc0202668:	f6c40413          	addi	s0,s0,-148 # ffffffffc02ac5d0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020266c:	b23fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pmm_manager->init();
ffffffffc0202670:	601c                	ld	a5,0(s0)
ffffffffc0202672:	000aa497          	auipc	s1,0xaa
ffffffffc0202676:	f0648493          	addi	s1,s1,-250 # ffffffffc02ac578 <npage>
ffffffffc020267a:	000aa917          	auipc	s2,0xaa
ffffffffc020267e:	f6e90913          	addi	s2,s2,-146 # ffffffffc02ac5e8 <pages>
ffffffffc0202682:	679c                	ld	a5,8(a5)
ffffffffc0202684:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202686:	57f5                	li	a5,-3
ffffffffc0202688:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020268a:	00005517          	auipc	a0,0x5
ffffffffc020268e:	e9e50513          	addi	a0,a0,-354 # ffffffffc0207528 <default_pmm_manager+0x1b0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202692:	000aa717          	auipc	a4,0xaa
ffffffffc0202696:	f4f73323          	sd	a5,-186(a4) # ffffffffc02ac5d8 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020269a:	af5fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020269e:	46c5                	li	a3,17
ffffffffc02026a0:	06ee                	slli	a3,a3,0x1b
ffffffffc02026a2:	40100613          	li	a2,1025
ffffffffc02026a6:	16fd                	addi	a3,a3,-1
ffffffffc02026a8:	0656                	slli	a2,a2,0x15
ffffffffc02026aa:	07e005b7          	lui	a1,0x7e00
ffffffffc02026ae:	00005517          	auipc	a0,0x5
ffffffffc02026b2:	e9250513          	addi	a0,a0,-366 # ffffffffc0207540 <default_pmm_manager+0x1c8>
ffffffffc02026b6:	ad9fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026ba:	777d                	lui	a4,0xfffff
ffffffffc02026bc:	000ab797          	auipc	a5,0xab
ffffffffc02026c0:	02378793          	addi	a5,a5,35 # ffffffffc02ad6df <end+0xfff>
ffffffffc02026c4:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02026c6:	00088737          	lui	a4,0x88
ffffffffc02026ca:	000aa697          	auipc	a3,0xaa
ffffffffc02026ce:	eae6b723          	sd	a4,-338(a3) # ffffffffc02ac578 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026d2:	000aa717          	auipc	a4,0xaa
ffffffffc02026d6:	f0f73b23          	sd	a5,-234(a4) # ffffffffc02ac5e8 <pages>
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02026da:	4701                	li	a4,0
ffffffffc02026dc:	4685                	li	a3,1
ffffffffc02026de:	fff80837          	lui	a6,0xfff80
ffffffffc02026e2:	a019                	j	ffffffffc02026e8 <pmm_init+0xb4>
ffffffffc02026e4:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02026e8:	00671613          	slli	a2,a4,0x6
ffffffffc02026ec:	97b2                	add	a5,a5,a2
ffffffffc02026ee:	07a1                	addi	a5,a5,8
ffffffffc02026f0:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02026f4:	6090                	ld	a2,0(s1)
ffffffffc02026f6:	0705                	addi	a4,a4,1
ffffffffc02026f8:	010607b3          	add	a5,a2,a6
ffffffffc02026fc:	fef764e3          	bltu	a4,a5,ffffffffc02026e4 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202700:	00093503          	ld	a0,0(s2)
ffffffffc0202704:	fe0007b7          	lui	a5,0xfe000
ffffffffc0202708:	00661693          	slli	a3,a2,0x6
ffffffffc020270c:	97aa                	add	a5,a5,a0
ffffffffc020270e:	96be                	add	a3,a3,a5
ffffffffc0202710:	c02007b7          	lui	a5,0xc0200
ffffffffc0202714:	7af6ed63          	bltu	a3,a5,ffffffffc0202ece <pmm_init+0x89a>
ffffffffc0202718:	000aa997          	auipc	s3,0xaa
ffffffffc020271c:	ec098993          	addi	s3,s3,-320 # ffffffffc02ac5d8 <va_pa_offset>
ffffffffc0202720:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end)
ffffffffc0202724:	47c5                	li	a5,17
ffffffffc0202726:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202728:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc020272a:	02f6f763          	bleu	a5,a3,ffffffffc0202758 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020272e:	6585                	lui	a1,0x1
ffffffffc0202730:	15fd                	addi	a1,a1,-1
ffffffffc0202732:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0202734:	00c6d713          	srli	a4,a3,0xc
ffffffffc0202738:	48c77a63          	bleu	a2,a4,ffffffffc0202bcc <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc020273c:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020273e:	75fd                	lui	a1,0xfffff
ffffffffc0202740:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc0202742:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0202744:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202746:	40d786b3          	sub	a3,a5,a3
ffffffffc020274a:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc020274c:	00c6d593          	srli	a1,a3,0xc
ffffffffc0202750:	953a                	add	a0,a0,a4
ffffffffc0202752:	9602                	jalr	a2
ffffffffc0202754:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202758:	00005517          	auipc	a0,0x5
ffffffffc020275c:	e1050513          	addi	a0,a0,-496 # ffffffffc0207568 <default_pmm_manager+0x1f0>
ffffffffc0202760:	a2ffd0ef          	jal	ra,ffffffffc020018e <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0202764:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t *)boot_page_table_sv39;
ffffffffc0202766:	000aa417          	auipc	s0,0xaa
ffffffffc020276a:	e0a40413          	addi	s0,s0,-502 # ffffffffc02ac570 <boot_pgdir>
    pmm_manager->check();
ffffffffc020276e:	7b9c                	ld	a5,48(a5)
ffffffffc0202770:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202772:	00005517          	auipc	a0,0x5
ffffffffc0202776:	e0e50513          	addi	a0,a0,-498 # ffffffffc0207580 <default_pmm_manager+0x208>
ffffffffc020277a:	a15fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    boot_pgdir = (pte_t *)boot_page_table_sv39;
ffffffffc020277e:	00009697          	auipc	a3,0x9
ffffffffc0202782:	88268693          	addi	a3,a3,-1918 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0202786:	000aa797          	auipc	a5,0xaa
ffffffffc020278a:	ded7b523          	sd	a3,-534(a5) # ffffffffc02ac570 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020278e:	c02007b7          	lui	a5,0xc0200
ffffffffc0202792:	10f6eae3          	bltu	a3,a5,ffffffffc02030a6 <pmm_init+0xa72>
ffffffffc0202796:	0009b783          	ld	a5,0(s3)
ffffffffc020279a:	8e9d                	sub	a3,a3,a5
ffffffffc020279c:	000aa797          	auipc	a5,0xaa
ffffffffc02027a0:	e4d7b223          	sd	a3,-444(a5) # ffffffffc02ac5e0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();
ffffffffc02027a4:	f7cff0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02027a8:	6098                	ld	a4,0(s1)
ffffffffc02027aa:	c80007b7          	lui	a5,0xc8000
ffffffffc02027ae:	83b1                	srli	a5,a5,0xc
    nr_free_store = nr_free_pages();
ffffffffc02027b0:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02027b2:	0ce7eae3          	bltu	a5,a4,ffffffffc0203086 <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02027b6:	6008                	ld	a0,0(s0)
ffffffffc02027b8:	44050463          	beqz	a0,ffffffffc0202c00 <pmm_init+0x5cc>
ffffffffc02027bc:	6785                	lui	a5,0x1
ffffffffc02027be:	17fd                	addi	a5,a5,-1
ffffffffc02027c0:	8fe9                	and	a5,a5,a0
ffffffffc02027c2:	2781                	sext.w	a5,a5
ffffffffc02027c4:	42079e63          	bnez	a5,ffffffffc0202c00 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02027c8:	4601                	li	a2,0
ffffffffc02027ca:	4581                	li	a1,0
ffffffffc02027cc:	967ff0ef          	jal	ra,ffffffffc0202132 <get_page>
ffffffffc02027d0:	78051b63          	bnez	a0,ffffffffc0202f66 <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02027d4:	4505                	li	a0,1
ffffffffc02027d6:	e7cff0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc02027da:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02027dc:	6008                	ld	a0,0(s0)
ffffffffc02027de:	4681                	li	a3,0
ffffffffc02027e0:	4601                	li	a2,0
ffffffffc02027e2:	85d6                	mv	a1,s5
ffffffffc02027e4:	d93ff0ef          	jal	ra,ffffffffc0202576 <page_insert>
ffffffffc02027e8:	7a051f63          	bnez	a0,ffffffffc0202fa6 <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02027ec:	6008                	ld	a0,0(s0)
ffffffffc02027ee:	4601                	li	a2,0
ffffffffc02027f0:	4581                	li	a1,0
ffffffffc02027f2:	f6eff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc02027f6:	78050863          	beqz	a0,ffffffffc0202f86 <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc02027fa:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027fc:	0017f713          	andi	a4,a5,1
ffffffffc0202800:	3e070463          	beqz	a4,ffffffffc0202be8 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0202804:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202806:	078a                	slli	a5,a5,0x2
ffffffffc0202808:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020280a:	3ce7f163          	bleu	a4,a5,ffffffffc0202bcc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020280e:	00093683          	ld	a3,0(s2)
ffffffffc0202812:	fff80637          	lui	a2,0xfff80
ffffffffc0202816:	97b2                	add	a5,a5,a2
ffffffffc0202818:	079a                	slli	a5,a5,0x6
ffffffffc020281a:	97b6                	add	a5,a5,a3
ffffffffc020281c:	72fa9563          	bne	s5,a5,ffffffffc0202f46 <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc0202820:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8580>
ffffffffc0202824:	4785                	li	a5,1
ffffffffc0202826:	70fb9063          	bne	s7,a5,ffffffffc0202f26 <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020282a:	6008                	ld	a0,0(s0)
ffffffffc020282c:	76fd                	lui	a3,0xfffff
ffffffffc020282e:	611c                	ld	a5,0(a0)
ffffffffc0202830:	078a                	slli	a5,a5,0x2
ffffffffc0202832:	8ff5                	and	a5,a5,a3
ffffffffc0202834:	00c7d613          	srli	a2,a5,0xc
ffffffffc0202838:	66e67e63          	bleu	a4,a2,ffffffffc0202eb4 <pmm_init+0x880>
ffffffffc020283c:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202840:	97e2                	add	a5,a5,s8
ffffffffc0202842:	0007bb03          	ld	s6,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8580>
ffffffffc0202846:	0b0a                	slli	s6,s6,0x2
ffffffffc0202848:	00db7b33          	and	s6,s6,a3
ffffffffc020284c:	00cb5793          	srli	a5,s6,0xc
ffffffffc0202850:	56e7f863          	bleu	a4,a5,ffffffffc0202dc0 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202854:	4601                	li	a2,0
ffffffffc0202856:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202858:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020285a:	f06ff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020285e:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202860:	55651063          	bne	a0,s6,ffffffffc0202da0 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc0202864:	4505                	li	a0,1
ffffffffc0202866:	decff0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020286a:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020286c:	6008                	ld	a0,0(s0)
ffffffffc020286e:	46d1                	li	a3,20
ffffffffc0202870:	6605                	lui	a2,0x1
ffffffffc0202872:	85da                	mv	a1,s6
ffffffffc0202874:	d03ff0ef          	jal	ra,ffffffffc0202576 <page_insert>
ffffffffc0202878:	50051463          	bnez	a0,ffffffffc0202d80 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020287c:	6008                	ld	a0,0(s0)
ffffffffc020287e:	4601                	li	a2,0
ffffffffc0202880:	6585                	lui	a1,0x1
ffffffffc0202882:	edeff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc0202886:	4c050d63          	beqz	a0,ffffffffc0202d60 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc020288a:	611c                	ld	a5,0(a0)
ffffffffc020288c:	0107f713          	andi	a4,a5,16
ffffffffc0202890:	4a070863          	beqz	a4,ffffffffc0202d40 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc0202894:	8b91                	andi	a5,a5,4
ffffffffc0202896:	48078563          	beqz	a5,ffffffffc0202d20 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020289a:	6008                	ld	a0,0(s0)
ffffffffc020289c:	611c                	ld	a5,0(a0)
ffffffffc020289e:	8bc1                	andi	a5,a5,16
ffffffffc02028a0:	46078063          	beqz	a5,ffffffffc0202d00 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc02028a4:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_exit_out_size+0x1f5570>
ffffffffc02028a8:	43779c63          	bne	a5,s7,ffffffffc0202ce0 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02028ac:	4681                	li	a3,0
ffffffffc02028ae:	6605                	lui	a2,0x1
ffffffffc02028b0:	85d6                	mv	a1,s5
ffffffffc02028b2:	cc5ff0ef          	jal	ra,ffffffffc0202576 <page_insert>
ffffffffc02028b6:	40051563          	bnez	a0,ffffffffc0202cc0 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc02028ba:	000aa703          	lw	a4,0(s5)
ffffffffc02028be:	4789                	li	a5,2
ffffffffc02028c0:	3ef71063          	bne	a4,a5,ffffffffc0202ca0 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc02028c4:	000b2783          	lw	a5,0(s6)
ffffffffc02028c8:	3a079c63          	bnez	a5,ffffffffc0202c80 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02028cc:	6008                	ld	a0,0(s0)
ffffffffc02028ce:	4601                	li	a2,0
ffffffffc02028d0:	6585                	lui	a1,0x1
ffffffffc02028d2:	e8eff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc02028d6:	38050563          	beqz	a0,ffffffffc0202c60 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc02028da:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02028dc:	00177793          	andi	a5,a4,1
ffffffffc02028e0:	30078463          	beqz	a5,ffffffffc0202be8 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02028e4:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02028e6:	00271793          	slli	a5,a4,0x2
ffffffffc02028ea:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028ec:	2ed7f063          	bleu	a3,a5,ffffffffc0202bcc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02028f0:	00093683          	ld	a3,0(s2)
ffffffffc02028f4:	fff80637          	lui	a2,0xfff80
ffffffffc02028f8:	97b2                	add	a5,a5,a2
ffffffffc02028fa:	079a                	slli	a5,a5,0x6
ffffffffc02028fc:	97b6                	add	a5,a5,a3
ffffffffc02028fe:	32fa9163          	bne	s5,a5,ffffffffc0202c20 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202902:	8b41                	andi	a4,a4,16
ffffffffc0202904:	70071163          	bnez	a4,ffffffffc0203006 <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc0202908:	6008                	ld	a0,0(s0)
ffffffffc020290a:	4581                	li	a1,0
ffffffffc020290c:	bf7ff0ef          	jal	ra,ffffffffc0202502 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202910:	000aa703          	lw	a4,0(s5)
ffffffffc0202914:	4785                	li	a5,1
ffffffffc0202916:	6cf71863          	bne	a4,a5,ffffffffc0202fe6 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc020291a:	000b2783          	lw	a5,0(s6)
ffffffffc020291e:	6a079463          	bnez	a5,ffffffffc0202fc6 <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202922:	6008                	ld	a0,0(s0)
ffffffffc0202924:	6585                	lui	a1,0x1
ffffffffc0202926:	bddff0ef          	jal	ra,ffffffffc0202502 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020292a:	000aa783          	lw	a5,0(s5)
ffffffffc020292e:	50079363          	bnez	a5,ffffffffc0202e34 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc0202932:	000b2783          	lw	a5,0(s6)
ffffffffc0202936:	4c079f63          	bnez	a5,ffffffffc0202e14 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020293a:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020293e:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202940:	000ab783          	ld	a5,0(s5)
ffffffffc0202944:	078a                	slli	a5,a5,0x2
ffffffffc0202946:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202948:	28c7f263          	bleu	a2,a5,ffffffffc0202bcc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020294c:	fff80737          	lui	a4,0xfff80
ffffffffc0202950:	00093503          	ld	a0,0(s2)
ffffffffc0202954:	97ba                	add	a5,a5,a4
ffffffffc0202956:	079a                	slli	a5,a5,0x6
ffffffffc0202958:	00f50733          	add	a4,a0,a5
ffffffffc020295c:	4314                	lw	a3,0(a4)
ffffffffc020295e:	4705                	li	a4,1
ffffffffc0202960:	48e69a63          	bne	a3,a4,ffffffffc0202df4 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc0202964:	8799                	srai	a5,a5,0x6
ffffffffc0202966:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020296a:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc020296c:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc020296e:	8331                	srli	a4,a4,0xc
ffffffffc0202970:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202972:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202974:	46c77363          	bleu	a2,a4,ffffffffc0202dda <pmm_init+0x7a6>

    pde_t *pd1 = boot_pgdir, *pd0 = page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202978:	0009b683          	ld	a3,0(s3)
ffffffffc020297c:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc020297e:	639c                	ld	a5,0(a5)
ffffffffc0202980:	078a                	slli	a5,a5,0x2
ffffffffc0202982:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202984:	24c7f463          	bleu	a2,a5,ffffffffc0202bcc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202988:	416787b3          	sub	a5,a5,s6
ffffffffc020298c:	079a                	slli	a5,a5,0x6
ffffffffc020298e:	953e                	add	a0,a0,a5
ffffffffc0202990:	4585                	li	a1,1
ffffffffc0202992:	d48ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202996:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc020299a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020299c:	078a                	slli	a5,a5,0x2
ffffffffc020299e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02029a0:	22e7f663          	bleu	a4,a5,ffffffffc0202bcc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02029a4:	00093503          	ld	a0,0(s2)
ffffffffc02029a8:	416787b3          	sub	a5,a5,s6
ffffffffc02029ac:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02029ae:	953e                	add	a0,a0,a5
ffffffffc02029b0:	4585                	li	a1,1
ffffffffc02029b2:	d28ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02029b6:	601c                	ld	a5,0(s0)
ffffffffc02029b8:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02029bc:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc02029c0:	d60ff0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
ffffffffc02029c4:	68aa1163          	bne	s4,a0,ffffffffc0203046 <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02029c8:	00005517          	auipc	a0,0x5
ffffffffc02029cc:	ed050513          	addi	a0,a0,-304 # ffffffffc0207898 <default_pmm_manager+0x520>
ffffffffc02029d0:	fbefd0ef          	jal	ra,ffffffffc020018e <cprintf>
{
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();
ffffffffc02029d4:	d4cff0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc02029d8:	6098                	ld	a4,0(s1)
ffffffffc02029da:	c02007b7          	lui	a5,0xc0200
    nr_free_store = nr_free_pages();
ffffffffc02029de:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc02029e0:	00c71693          	slli	a3,a4,0xc
ffffffffc02029e4:	18d7f563          	bleu	a3,a5,ffffffffc0202b6e <pmm_init+0x53a>
    {
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029e8:	83b1                	srli	a5,a5,0xc
ffffffffc02029ea:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc02029ec:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029f0:	1ae7f163          	bleu	a4,a5,ffffffffc0202b92 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02029f4:	7bfd                	lui	s7,0xfffff
ffffffffc02029f6:	6b05                	lui	s6,0x1
ffffffffc02029f8:	a029                	j	ffffffffc0202a02 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029fa:	00cad713          	srli	a4,s5,0xc
ffffffffc02029fe:	18f77a63          	bleu	a5,a4,ffffffffc0202b92 <pmm_init+0x55e>
ffffffffc0202a02:	0009b583          	ld	a1,0(s3)
ffffffffc0202a06:	4601                	li	a2,0
ffffffffc0202a08:	95d6                	add	a1,a1,s5
ffffffffc0202a0a:	d56ff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc0202a0e:	16050263          	beqz	a0,ffffffffc0202b72 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202a12:	611c                	ld	a5,0(a0)
ffffffffc0202a14:	078a                	slli	a5,a5,0x2
ffffffffc0202a16:	0177f7b3          	and	a5,a5,s7
ffffffffc0202a1a:	19579963          	bne	a5,s5,ffffffffc0202bac <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202a1e:	609c                	ld	a5,0(s1)
ffffffffc0202a20:	9ada                	add	s5,s5,s6
ffffffffc0202a22:	6008                	ld	a0,0(s0)
ffffffffc0202a24:	00c79713          	slli	a4,a5,0xc
ffffffffc0202a28:	fceae9e3          	bltu	s5,a4,ffffffffc02029fa <pmm_init+0x3c6>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc0202a2c:	611c                	ld	a5,0(a0)
ffffffffc0202a2e:	62079c63          	bnez	a5,ffffffffc0203066 <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc0202a32:	4505                	li	a0,1
ffffffffc0202a34:	c1eff0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0202a38:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202a3a:	6008                	ld	a0,0(s0)
ffffffffc0202a3c:	4699                	li	a3,6
ffffffffc0202a3e:	10000613          	li	a2,256
ffffffffc0202a42:	85d6                	mv	a1,s5
ffffffffc0202a44:	b33ff0ef          	jal	ra,ffffffffc0202576 <page_insert>
ffffffffc0202a48:	1e051c63          	bnez	a0,ffffffffc0202c40 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0202a4c:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0202a50:	4785                	li	a5,1
ffffffffc0202a52:	44f71163          	bne	a4,a5,ffffffffc0202e94 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202a56:	6008                	ld	a0,0(s0)
ffffffffc0202a58:	6b05                	lui	s6,0x1
ffffffffc0202a5a:	4699                	li	a3,6
ffffffffc0202a5c:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x8480>
ffffffffc0202a60:	85d6                	mv	a1,s5
ffffffffc0202a62:	b15ff0ef          	jal	ra,ffffffffc0202576 <page_insert>
ffffffffc0202a66:	40051763          	bnez	a0,ffffffffc0202e74 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc0202a6a:	000aa703          	lw	a4,0(s5)
ffffffffc0202a6e:	4789                	li	a5,2
ffffffffc0202a70:	3ef71263          	bne	a4,a5,ffffffffc0202e54 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202a74:	00005597          	auipc	a1,0x5
ffffffffc0202a78:	f5c58593          	addi	a1,a1,-164 # ffffffffc02079d0 <default_pmm_manager+0x658>
ffffffffc0202a7c:	10000513          	li	a0,256
ffffffffc0202a80:	33b030ef          	jal	ra,ffffffffc02065ba <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202a84:	100b0593          	addi	a1,s6,256
ffffffffc0202a88:	10000513          	li	a0,256
ffffffffc0202a8c:	341030ef          	jal	ra,ffffffffc02065cc <strcmp>
ffffffffc0202a90:	44051b63          	bnez	a0,ffffffffc0202ee6 <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0202a94:	00093683          	ld	a3,0(s2)
ffffffffc0202a98:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202a9c:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202a9e:	40da86b3          	sub	a3,s5,a3
ffffffffc0202aa2:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202aa4:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202aa6:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202aa8:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0202aac:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ab0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202ab2:	10f77f63          	bleu	a5,a4,ffffffffc0202bd0 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202ab6:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202aba:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202abe:	96be                	add	a3,a3,a5
ffffffffc0202ac0:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fd52a20>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202ac4:	2b3030ef          	jal	ra,ffffffffc0206576 <strlen>
ffffffffc0202ac8:	54051f63          	bnez	a0,ffffffffc0203026 <pmm_init+0x9f2>

    pde_t *pd1 = boot_pgdir, *pd0 = page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202acc:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202ad0:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ad2:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd52920>
ffffffffc0202ad6:	068a                	slli	a3,a3,0x2
ffffffffc0202ad8:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ada:	0ef6f963          	bleu	a5,a3,ffffffffc0202bcc <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0202ade:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ae2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202ae4:	0efb7663          	bleu	a5,s6,ffffffffc0202bd0 <pmm_init+0x59c>
ffffffffc0202ae8:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202aec:	4585                	li	a1,1
ffffffffc0202aee:	8556                	mv	a0,s5
ffffffffc0202af0:	99b6                	add	s3,s3,a3
ffffffffc0202af2:	be8ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202af6:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202afa:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202afc:	078a                	slli	a5,a5,0x2
ffffffffc0202afe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b00:	0ce7f663          	bleu	a4,a5,ffffffffc0202bcc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b04:	00093503          	ld	a0,0(s2)
ffffffffc0202b08:	fff809b7          	lui	s3,0xfff80
ffffffffc0202b0c:	97ce                	add	a5,a5,s3
ffffffffc0202b0e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202b10:	953e                	add	a0,a0,a5
ffffffffc0202b12:	4585                	li	a1,1
ffffffffc0202b14:	bc6ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b18:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0202b1c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b1e:	078a                	slli	a5,a5,0x2
ffffffffc0202b20:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b22:	0ae7f563          	bleu	a4,a5,ffffffffc0202bcc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b26:	00093503          	ld	a0,0(s2)
ffffffffc0202b2a:	97ce                	add	a5,a5,s3
ffffffffc0202b2c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202b2e:	953e                	add	a0,a0,a5
ffffffffc0202b30:	4585                	li	a1,1
ffffffffc0202b32:	ba8ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202b36:	601c                	ld	a5,0(s0)
ffffffffc0202b38:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0202b3c:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202b40:	be0ff0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
ffffffffc0202b44:	3caa1163          	bne	s4,a0,ffffffffc0202f06 <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202b48:	00005517          	auipc	a0,0x5
ffffffffc0202b4c:	f0050513          	addi	a0,a0,-256 # ffffffffc0207a48 <default_pmm_manager+0x6d0>
ffffffffc0202b50:	e3efd0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0202b54:	6406                	ld	s0,64(sp)
ffffffffc0202b56:	60a6                	ld	ra,72(sp)
ffffffffc0202b58:	74e2                	ld	s1,56(sp)
ffffffffc0202b5a:	7942                	ld	s2,48(sp)
ffffffffc0202b5c:	79a2                	ld	s3,40(sp)
ffffffffc0202b5e:	7a02                	ld	s4,32(sp)
ffffffffc0202b60:	6ae2                	ld	s5,24(sp)
ffffffffc0202b62:	6b42                	ld	s6,16(sp)
ffffffffc0202b64:	6ba2                	ld	s7,8(sp)
ffffffffc0202b66:	6c02                	ld	s8,0(sp)
ffffffffc0202b68:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0202b6a:	8c8ff06f          	j	ffffffffc0201c32 <kmalloc_init>
ffffffffc0202b6e:	6008                	ld	a0,0(s0)
ffffffffc0202b70:	bd75                	j	ffffffffc0202a2c <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202b72:	00005697          	auipc	a3,0x5
ffffffffc0202b76:	d4668693          	addi	a3,a3,-698 # ffffffffc02078b8 <default_pmm_manager+0x540>
ffffffffc0202b7a:	00004617          	auipc	a2,0x4
ffffffffc0202b7e:	0b660613          	addi	a2,a2,182 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202b82:	26c00593          	li	a1,620
ffffffffc0202b86:	00005517          	auipc	a0,0x5
ffffffffc0202b8a:	96250513          	addi	a0,a0,-1694 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202b8e:	8f7fd0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0202b92:	86d6                	mv	a3,s5
ffffffffc0202b94:	00005617          	auipc	a2,0x5
ffffffffc0202b98:	83460613          	addi	a2,a2,-1996 # ffffffffc02073c8 <default_pmm_manager+0x50>
ffffffffc0202b9c:	26c00593          	li	a1,620
ffffffffc0202ba0:	00005517          	auipc	a0,0x5
ffffffffc0202ba4:	94850513          	addi	a0,a0,-1720 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202ba8:	8ddfd0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202bac:	00005697          	auipc	a3,0x5
ffffffffc0202bb0:	d4c68693          	addi	a3,a3,-692 # ffffffffc02078f8 <default_pmm_manager+0x580>
ffffffffc0202bb4:	00004617          	auipc	a2,0x4
ffffffffc0202bb8:	07c60613          	addi	a2,a2,124 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202bbc:	26d00593          	li	a1,621
ffffffffc0202bc0:	00005517          	auipc	a0,0x5
ffffffffc0202bc4:	92850513          	addi	a0,a0,-1752 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202bc8:	8bdfd0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0202bcc:	a6aff0ef          	jal	ra,ffffffffc0201e36 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0202bd0:	00004617          	auipc	a2,0x4
ffffffffc0202bd4:	7f860613          	addi	a2,a2,2040 # ffffffffc02073c8 <default_pmm_manager+0x50>
ffffffffc0202bd8:	06900593          	li	a1,105
ffffffffc0202bdc:	00005517          	auipc	a0,0x5
ffffffffc0202be0:	81450513          	addi	a0,a0,-2028 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc0202be4:	8a1fd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202be8:	00005617          	auipc	a2,0x5
ffffffffc0202bec:	a9860613          	addi	a2,a2,-1384 # ffffffffc0207680 <default_pmm_manager+0x308>
ffffffffc0202bf0:	07400593          	li	a1,116
ffffffffc0202bf4:	00004517          	auipc	a0,0x4
ffffffffc0202bf8:	7fc50513          	addi	a0,a0,2044 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc0202bfc:	889fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202c00:	00005697          	auipc	a3,0x5
ffffffffc0202c04:	9c068693          	addi	a3,a3,-1600 # ffffffffc02075c0 <default_pmm_manager+0x248>
ffffffffc0202c08:	00004617          	auipc	a2,0x4
ffffffffc0202c0c:	02860613          	addi	a2,a2,40 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202c10:	22e00593          	li	a1,558
ffffffffc0202c14:	00005517          	auipc	a0,0x5
ffffffffc0202c18:	8d450513          	addi	a0,a0,-1836 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202c1c:	869fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202c20:	00005697          	auipc	a3,0x5
ffffffffc0202c24:	a8868693          	addi	a3,a3,-1400 # ffffffffc02076a8 <default_pmm_manager+0x330>
ffffffffc0202c28:	00004617          	auipc	a2,0x4
ffffffffc0202c2c:	00860613          	addi	a2,a2,8 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202c30:	24a00593          	li	a1,586
ffffffffc0202c34:	00005517          	auipc	a0,0x5
ffffffffc0202c38:	8b450513          	addi	a0,a0,-1868 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202c3c:	849fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202c40:	00005697          	auipc	a3,0x5
ffffffffc0202c44:	ce868693          	addi	a3,a3,-792 # ffffffffc0207928 <default_pmm_manager+0x5b0>
ffffffffc0202c48:	00004617          	auipc	a2,0x4
ffffffffc0202c4c:	fe860613          	addi	a2,a2,-24 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202c50:	27400593          	li	a1,628
ffffffffc0202c54:	00005517          	auipc	a0,0x5
ffffffffc0202c58:	89450513          	addi	a0,a0,-1900 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202c5c:	829fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202c60:	00005697          	auipc	a3,0x5
ffffffffc0202c64:	ad868693          	addi	a3,a3,-1320 # ffffffffc0207738 <default_pmm_manager+0x3c0>
ffffffffc0202c68:	00004617          	auipc	a2,0x4
ffffffffc0202c6c:	fc860613          	addi	a2,a2,-56 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202c70:	24900593          	li	a1,585
ffffffffc0202c74:	00005517          	auipc	a0,0x5
ffffffffc0202c78:	87450513          	addi	a0,a0,-1932 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202c7c:	809fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202c80:	00005697          	auipc	a3,0x5
ffffffffc0202c84:	b8068693          	addi	a3,a3,-1152 # ffffffffc0207800 <default_pmm_manager+0x488>
ffffffffc0202c88:	00004617          	auipc	a2,0x4
ffffffffc0202c8c:	fa860613          	addi	a2,a2,-88 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202c90:	24800593          	li	a1,584
ffffffffc0202c94:	00005517          	auipc	a0,0x5
ffffffffc0202c98:	85450513          	addi	a0,a0,-1964 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202c9c:	fe8fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202ca0:	00005697          	auipc	a3,0x5
ffffffffc0202ca4:	b4868693          	addi	a3,a3,-1208 # ffffffffc02077e8 <default_pmm_manager+0x470>
ffffffffc0202ca8:	00004617          	auipc	a2,0x4
ffffffffc0202cac:	f8860613          	addi	a2,a2,-120 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202cb0:	24700593          	li	a1,583
ffffffffc0202cb4:	00005517          	auipc	a0,0x5
ffffffffc0202cb8:	83450513          	addi	a0,a0,-1996 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202cbc:	fc8fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202cc0:	00005697          	auipc	a3,0x5
ffffffffc0202cc4:	af868693          	addi	a3,a3,-1288 # ffffffffc02077b8 <default_pmm_manager+0x440>
ffffffffc0202cc8:	00004617          	auipc	a2,0x4
ffffffffc0202ccc:	f6860613          	addi	a2,a2,-152 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202cd0:	24600593          	li	a1,582
ffffffffc0202cd4:	00005517          	auipc	a0,0x5
ffffffffc0202cd8:	81450513          	addi	a0,a0,-2028 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202cdc:	fa8fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202ce0:	00005697          	auipc	a3,0x5
ffffffffc0202ce4:	ac068693          	addi	a3,a3,-1344 # ffffffffc02077a0 <default_pmm_manager+0x428>
ffffffffc0202ce8:	00004617          	auipc	a2,0x4
ffffffffc0202cec:	f4860613          	addi	a2,a2,-184 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202cf0:	24400593          	li	a1,580
ffffffffc0202cf4:	00004517          	auipc	a0,0x4
ffffffffc0202cf8:	7f450513          	addi	a0,a0,2036 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202cfc:	f88fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202d00:	00005697          	auipc	a3,0x5
ffffffffc0202d04:	a8868693          	addi	a3,a3,-1400 # ffffffffc0207788 <default_pmm_manager+0x410>
ffffffffc0202d08:	00004617          	auipc	a2,0x4
ffffffffc0202d0c:	f2860613          	addi	a2,a2,-216 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202d10:	24300593          	li	a1,579
ffffffffc0202d14:	00004517          	auipc	a0,0x4
ffffffffc0202d18:	7d450513          	addi	a0,a0,2004 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202d1c:	f68fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202d20:	00005697          	auipc	a3,0x5
ffffffffc0202d24:	a5868693          	addi	a3,a3,-1448 # ffffffffc0207778 <default_pmm_manager+0x400>
ffffffffc0202d28:	00004617          	auipc	a2,0x4
ffffffffc0202d2c:	f0860613          	addi	a2,a2,-248 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202d30:	24200593          	li	a1,578
ffffffffc0202d34:	00004517          	auipc	a0,0x4
ffffffffc0202d38:	7b450513          	addi	a0,a0,1972 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202d3c:	f48fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202d40:	00005697          	auipc	a3,0x5
ffffffffc0202d44:	a2868693          	addi	a3,a3,-1496 # ffffffffc0207768 <default_pmm_manager+0x3f0>
ffffffffc0202d48:	00004617          	auipc	a2,0x4
ffffffffc0202d4c:	ee860613          	addi	a2,a2,-280 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202d50:	24100593          	li	a1,577
ffffffffc0202d54:	00004517          	auipc	a0,0x4
ffffffffc0202d58:	79450513          	addi	a0,a0,1940 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202d5c:	f28fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202d60:	00005697          	auipc	a3,0x5
ffffffffc0202d64:	9d868693          	addi	a3,a3,-1576 # ffffffffc0207738 <default_pmm_manager+0x3c0>
ffffffffc0202d68:	00004617          	auipc	a2,0x4
ffffffffc0202d6c:	ec860613          	addi	a2,a2,-312 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202d70:	24000593          	li	a1,576
ffffffffc0202d74:	00004517          	auipc	a0,0x4
ffffffffc0202d78:	77450513          	addi	a0,a0,1908 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202d7c:	f08fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d80:	00005697          	auipc	a3,0x5
ffffffffc0202d84:	98068693          	addi	a3,a3,-1664 # ffffffffc0207700 <default_pmm_manager+0x388>
ffffffffc0202d88:	00004617          	auipc	a2,0x4
ffffffffc0202d8c:	ea860613          	addi	a2,a2,-344 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202d90:	23f00593          	li	a1,575
ffffffffc0202d94:	00004517          	auipc	a0,0x4
ffffffffc0202d98:	75450513          	addi	a0,a0,1876 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202d9c:	ee8fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202da0:	00005697          	auipc	a3,0x5
ffffffffc0202da4:	93868693          	addi	a3,a3,-1736 # ffffffffc02076d8 <default_pmm_manager+0x360>
ffffffffc0202da8:	00004617          	auipc	a2,0x4
ffffffffc0202dac:	e8860613          	addi	a2,a2,-376 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202db0:	23c00593          	li	a1,572
ffffffffc0202db4:	00004517          	auipc	a0,0x4
ffffffffc0202db8:	73450513          	addi	a0,a0,1844 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202dbc:	ec8fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202dc0:	86da                	mv	a3,s6
ffffffffc0202dc2:	00004617          	auipc	a2,0x4
ffffffffc0202dc6:	60660613          	addi	a2,a2,1542 # ffffffffc02073c8 <default_pmm_manager+0x50>
ffffffffc0202dca:	23b00593          	li	a1,571
ffffffffc0202dce:	00004517          	auipc	a0,0x4
ffffffffc0202dd2:	71a50513          	addi	a0,a0,1818 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202dd6:	eaefd0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202dda:	86be                	mv	a3,a5
ffffffffc0202ddc:	00004617          	auipc	a2,0x4
ffffffffc0202de0:	5ec60613          	addi	a2,a2,1516 # ffffffffc02073c8 <default_pmm_manager+0x50>
ffffffffc0202de4:	06900593          	li	a1,105
ffffffffc0202de8:	00004517          	auipc	a0,0x4
ffffffffc0202dec:	60850513          	addi	a0,a0,1544 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc0202df0:	e94fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202df4:	00005697          	auipc	a3,0x5
ffffffffc0202df8:	a5468693          	addi	a3,a3,-1452 # ffffffffc0207848 <default_pmm_manager+0x4d0>
ffffffffc0202dfc:	00004617          	auipc	a2,0x4
ffffffffc0202e00:	e3460613          	addi	a2,a2,-460 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202e04:	25500593          	li	a1,597
ffffffffc0202e08:	00004517          	auipc	a0,0x4
ffffffffc0202e0c:	6e050513          	addi	a0,a0,1760 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202e10:	e74fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202e14:	00005697          	auipc	a3,0x5
ffffffffc0202e18:	9ec68693          	addi	a3,a3,-1556 # ffffffffc0207800 <default_pmm_manager+0x488>
ffffffffc0202e1c:	00004617          	auipc	a2,0x4
ffffffffc0202e20:	e1460613          	addi	a2,a2,-492 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202e24:	25300593          	li	a1,595
ffffffffc0202e28:	00004517          	auipc	a0,0x4
ffffffffc0202e2c:	6c050513          	addi	a0,a0,1728 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202e30:	e54fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202e34:	00005697          	auipc	a3,0x5
ffffffffc0202e38:	9fc68693          	addi	a3,a3,-1540 # ffffffffc0207830 <default_pmm_manager+0x4b8>
ffffffffc0202e3c:	00004617          	auipc	a2,0x4
ffffffffc0202e40:	df460613          	addi	a2,a2,-524 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202e44:	25200593          	li	a1,594
ffffffffc0202e48:	00004517          	auipc	a0,0x4
ffffffffc0202e4c:	6a050513          	addi	a0,a0,1696 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202e50:	e34fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202e54:	00005697          	auipc	a3,0x5
ffffffffc0202e58:	b6468693          	addi	a3,a3,-1180 # ffffffffc02079b8 <default_pmm_manager+0x640>
ffffffffc0202e5c:	00004617          	auipc	a2,0x4
ffffffffc0202e60:	dd460613          	addi	a2,a2,-556 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202e64:	27700593          	li	a1,631
ffffffffc0202e68:	00004517          	auipc	a0,0x4
ffffffffc0202e6c:	68050513          	addi	a0,a0,1664 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202e70:	e14fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e74:	00005697          	auipc	a3,0x5
ffffffffc0202e78:	b0468693          	addi	a3,a3,-1276 # ffffffffc0207978 <default_pmm_manager+0x600>
ffffffffc0202e7c:	00004617          	auipc	a2,0x4
ffffffffc0202e80:	db460613          	addi	a2,a2,-588 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202e84:	27600593          	li	a1,630
ffffffffc0202e88:	00004517          	auipc	a0,0x4
ffffffffc0202e8c:	66050513          	addi	a0,a0,1632 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202e90:	df4fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202e94:	00005697          	auipc	a3,0x5
ffffffffc0202e98:	acc68693          	addi	a3,a3,-1332 # ffffffffc0207960 <default_pmm_manager+0x5e8>
ffffffffc0202e9c:	00004617          	auipc	a2,0x4
ffffffffc0202ea0:	d9460613          	addi	a2,a2,-620 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202ea4:	27500593          	li	a1,629
ffffffffc0202ea8:	00004517          	auipc	a0,0x4
ffffffffc0202eac:	64050513          	addi	a0,a0,1600 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202eb0:	dd4fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202eb4:	86be                	mv	a3,a5
ffffffffc0202eb6:	00004617          	auipc	a2,0x4
ffffffffc0202eba:	51260613          	addi	a2,a2,1298 # ffffffffc02073c8 <default_pmm_manager+0x50>
ffffffffc0202ebe:	23a00593          	li	a1,570
ffffffffc0202ec2:	00004517          	auipc	a0,0x4
ffffffffc0202ec6:	62650513          	addi	a0,a0,1574 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202eca:	dbafd0ef          	jal	ra,ffffffffc0200484 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202ece:	00004617          	auipc	a2,0x4
ffffffffc0202ed2:	53260613          	addi	a2,a2,1330 # ffffffffc0207400 <default_pmm_manager+0x88>
ffffffffc0202ed6:	08900593          	li	a1,137
ffffffffc0202eda:	00004517          	auipc	a0,0x4
ffffffffc0202ede:	60e50513          	addi	a0,a0,1550 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202ee2:	da2fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202ee6:	00005697          	auipc	a3,0x5
ffffffffc0202eea:	b0268693          	addi	a3,a3,-1278 # ffffffffc02079e8 <default_pmm_manager+0x670>
ffffffffc0202eee:	00004617          	auipc	a2,0x4
ffffffffc0202ef2:	d4260613          	addi	a2,a2,-702 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202ef6:	27b00593          	li	a1,635
ffffffffc0202efa:	00004517          	auipc	a0,0x4
ffffffffc0202efe:	5ee50513          	addi	a0,a0,1518 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202f02:	d82fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202f06:	00005697          	auipc	a3,0x5
ffffffffc0202f0a:	96a68693          	addi	a3,a3,-1686 # ffffffffc0207870 <default_pmm_manager+0x4f8>
ffffffffc0202f0e:	00004617          	auipc	a2,0x4
ffffffffc0202f12:	d2260613          	addi	a2,a2,-734 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202f16:	28700593          	li	a1,647
ffffffffc0202f1a:	00004517          	auipc	a0,0x4
ffffffffc0202f1e:	5ce50513          	addi	a0,a0,1486 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202f22:	d62fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202f26:	00004697          	auipc	a3,0x4
ffffffffc0202f2a:	79a68693          	addi	a3,a3,1946 # ffffffffc02076c0 <default_pmm_manager+0x348>
ffffffffc0202f2e:	00004617          	auipc	a2,0x4
ffffffffc0202f32:	d0260613          	addi	a2,a2,-766 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202f36:	23800593          	li	a1,568
ffffffffc0202f3a:	00004517          	auipc	a0,0x4
ffffffffc0202f3e:	5ae50513          	addi	a0,a0,1454 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202f42:	d42fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f46:	00004697          	auipc	a3,0x4
ffffffffc0202f4a:	76268693          	addi	a3,a3,1890 # ffffffffc02076a8 <default_pmm_manager+0x330>
ffffffffc0202f4e:	00004617          	auipc	a2,0x4
ffffffffc0202f52:	ce260613          	addi	a2,a2,-798 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202f56:	23700593          	li	a1,567
ffffffffc0202f5a:	00004517          	auipc	a0,0x4
ffffffffc0202f5e:	58e50513          	addi	a0,a0,1422 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202f62:	d22fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202f66:	00004697          	auipc	a3,0x4
ffffffffc0202f6a:	69268693          	addi	a3,a3,1682 # ffffffffc02075f8 <default_pmm_manager+0x280>
ffffffffc0202f6e:	00004617          	auipc	a2,0x4
ffffffffc0202f72:	cc260613          	addi	a2,a2,-830 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202f76:	22f00593          	li	a1,559
ffffffffc0202f7a:	00004517          	auipc	a0,0x4
ffffffffc0202f7e:	56e50513          	addi	a0,a0,1390 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202f82:	d02fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202f86:	00004697          	auipc	a3,0x4
ffffffffc0202f8a:	6ca68693          	addi	a3,a3,1738 # ffffffffc0207650 <default_pmm_manager+0x2d8>
ffffffffc0202f8e:	00004617          	auipc	a2,0x4
ffffffffc0202f92:	ca260613          	addi	a2,a2,-862 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202f96:	23600593          	li	a1,566
ffffffffc0202f9a:	00004517          	auipc	a0,0x4
ffffffffc0202f9e:	54e50513          	addi	a0,a0,1358 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202fa2:	ce2fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202fa6:	00004697          	auipc	a3,0x4
ffffffffc0202faa:	67a68693          	addi	a3,a3,1658 # ffffffffc0207620 <default_pmm_manager+0x2a8>
ffffffffc0202fae:	00004617          	auipc	a2,0x4
ffffffffc0202fb2:	c8260613          	addi	a2,a2,-894 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202fb6:	23300593          	li	a1,563
ffffffffc0202fba:	00004517          	auipc	a0,0x4
ffffffffc0202fbe:	52e50513          	addi	a0,a0,1326 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202fc2:	cc2fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202fc6:	00005697          	auipc	a3,0x5
ffffffffc0202fca:	83a68693          	addi	a3,a3,-1990 # ffffffffc0207800 <default_pmm_manager+0x488>
ffffffffc0202fce:	00004617          	auipc	a2,0x4
ffffffffc0202fd2:	c6260613          	addi	a2,a2,-926 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202fd6:	24f00593          	li	a1,591
ffffffffc0202fda:	00004517          	auipc	a0,0x4
ffffffffc0202fde:	50e50513          	addi	a0,a0,1294 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0202fe2:	ca2fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202fe6:	00004697          	auipc	a3,0x4
ffffffffc0202fea:	6da68693          	addi	a3,a3,1754 # ffffffffc02076c0 <default_pmm_manager+0x348>
ffffffffc0202fee:	00004617          	auipc	a2,0x4
ffffffffc0202ff2:	c4260613          	addi	a2,a2,-958 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0202ff6:	24e00593          	li	a1,590
ffffffffc0202ffa:	00004517          	auipc	a0,0x4
ffffffffc0202ffe:	4ee50513          	addi	a0,a0,1262 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0203002:	c82fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203006:	00005697          	auipc	a3,0x5
ffffffffc020300a:	81268693          	addi	a3,a3,-2030 # ffffffffc0207818 <default_pmm_manager+0x4a0>
ffffffffc020300e:	00004617          	auipc	a2,0x4
ffffffffc0203012:	c2260613          	addi	a2,a2,-990 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203016:	24b00593          	li	a1,587
ffffffffc020301a:	00004517          	auipc	a0,0x4
ffffffffc020301e:	4ce50513          	addi	a0,a0,1230 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0203022:	c62fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203026:	00005697          	auipc	a3,0x5
ffffffffc020302a:	9fa68693          	addi	a3,a3,-1542 # ffffffffc0207a20 <default_pmm_manager+0x6a8>
ffffffffc020302e:	00004617          	auipc	a2,0x4
ffffffffc0203032:	c0260613          	addi	a2,a2,-1022 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203036:	27e00593          	li	a1,638
ffffffffc020303a:	00004517          	auipc	a0,0x4
ffffffffc020303e:	4ae50513          	addi	a0,a0,1198 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0203042:	c42fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0203046:	00005697          	auipc	a3,0x5
ffffffffc020304a:	82a68693          	addi	a3,a3,-2006 # ffffffffc0207870 <default_pmm_manager+0x4f8>
ffffffffc020304e:	00004617          	auipc	a2,0x4
ffffffffc0203052:	be260613          	addi	a2,a2,-1054 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203056:	25d00593          	li	a1,605
ffffffffc020305a:	00004517          	auipc	a0,0x4
ffffffffc020305e:	48e50513          	addi	a0,a0,1166 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0203062:	c22fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203066:	00005697          	auipc	a3,0x5
ffffffffc020306a:	8aa68693          	addi	a3,a3,-1878 # ffffffffc0207910 <default_pmm_manager+0x598>
ffffffffc020306e:	00004617          	auipc	a2,0x4
ffffffffc0203072:	bc260613          	addi	a2,a2,-1086 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203076:	27000593          	li	a1,624
ffffffffc020307a:	00004517          	auipc	a0,0x4
ffffffffc020307e:	46e50513          	addi	a0,a0,1134 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0203082:	c02fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203086:	00004697          	auipc	a3,0x4
ffffffffc020308a:	51a68693          	addi	a3,a3,1306 # ffffffffc02075a0 <default_pmm_manager+0x228>
ffffffffc020308e:	00004617          	auipc	a2,0x4
ffffffffc0203092:	ba260613          	addi	a2,a2,-1118 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203096:	22d00593          	li	a1,557
ffffffffc020309a:	00004517          	auipc	a0,0x4
ffffffffc020309e:	44e50513          	addi	a0,a0,1102 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc02030a2:	be2fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02030a6:	00004617          	auipc	a2,0x4
ffffffffc02030aa:	35a60613          	addi	a2,a2,858 # ffffffffc0207400 <default_pmm_manager+0x88>
ffffffffc02030ae:	0d100593          	li	a1,209
ffffffffc02030b2:	00004517          	auipc	a0,0x4
ffffffffc02030b6:	43650513          	addi	a0,a0,1078 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc02030ba:	bcafd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02030be <copy_range>:
{
ffffffffc02030be:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030c0:	00d667b3          	or	a5,a2,a3
{
ffffffffc02030c4:	f486                	sd	ra,104(sp)
ffffffffc02030c6:	f0a2                	sd	s0,96(sp)
ffffffffc02030c8:	eca6                	sd	s1,88(sp)
ffffffffc02030ca:	e8ca                	sd	s2,80(sp)
ffffffffc02030cc:	e4ce                	sd	s3,72(sp)
ffffffffc02030ce:	e0d2                	sd	s4,64(sp)
ffffffffc02030d0:	fc56                	sd	s5,56(sp)
ffffffffc02030d2:	f85a                	sd	s6,48(sp)
ffffffffc02030d4:	f45e                	sd	s7,40(sp)
ffffffffc02030d6:	f062                	sd	s8,32(sp)
ffffffffc02030d8:	ec66                	sd	s9,24(sp)
ffffffffc02030da:	e86a                	sd	s10,16(sp)
ffffffffc02030dc:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030de:	03479713          	slli	a4,a5,0x34
ffffffffc02030e2:	1e071863          	bnez	a4,ffffffffc02032d2 <copy_range+0x214>
    assert(USER_ACCESS(start, end));
ffffffffc02030e6:	002007b7          	lui	a5,0x200
ffffffffc02030ea:	8432                	mv	s0,a2
ffffffffc02030ec:	16f66b63          	bltu	a2,a5,ffffffffc0203262 <copy_range+0x1a4>
ffffffffc02030f0:	84b6                	mv	s1,a3
ffffffffc02030f2:	16d67863          	bleu	a3,a2,ffffffffc0203262 <copy_range+0x1a4>
ffffffffc02030f6:	4785                	li	a5,1
ffffffffc02030f8:	07fe                	slli	a5,a5,0x1f
ffffffffc02030fa:	16d7e463          	bltu	a5,a3,ffffffffc0203262 <copy_range+0x1a4>
ffffffffc02030fe:	5a7d                	li	s4,-1
ffffffffc0203100:	8aaa                	mv	s5,a0
ffffffffc0203102:	892e                	mv	s2,a1
        start += PGSIZE;
ffffffffc0203104:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203106:	000a9c17          	auipc	s8,0xa9
ffffffffc020310a:	472c0c13          	addi	s8,s8,1138 # ffffffffc02ac578 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020310e:	000a9b97          	auipc	s7,0xa9
ffffffffc0203112:	4dab8b93          	addi	s7,s7,1242 # ffffffffc02ac5e8 <pages>
    return page - pages + nbase;
ffffffffc0203116:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020311a:	00ca5a13          	srli	s4,s4,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc020311e:	4601                	li	a2,0
ffffffffc0203120:	85a2                	mv	a1,s0
ffffffffc0203122:	854a                	mv	a0,s2
ffffffffc0203124:	e3dfe0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc0203128:	8caa                	mv	s9,a0
        if (ptep == NULL)
ffffffffc020312a:	c17d                	beqz	a0,ffffffffc0203210 <copy_range+0x152>
        if (*ptep & PTE_V)
ffffffffc020312c:	611c                	ld	a5,0(a0)
ffffffffc020312e:	8b85                	andi	a5,a5,1
ffffffffc0203130:	e785                	bnez	a5,ffffffffc0203158 <copy_range+0x9a>
        start += PGSIZE;
ffffffffc0203132:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0203134:	fe9465e3          	bltu	s0,s1,ffffffffc020311e <copy_range+0x60>
    return 0;
ffffffffc0203138:	4501                	li	a0,0
}
ffffffffc020313a:	70a6                	ld	ra,104(sp)
ffffffffc020313c:	7406                	ld	s0,96(sp)
ffffffffc020313e:	64e6                	ld	s1,88(sp)
ffffffffc0203140:	6946                	ld	s2,80(sp)
ffffffffc0203142:	69a6                	ld	s3,72(sp)
ffffffffc0203144:	6a06                	ld	s4,64(sp)
ffffffffc0203146:	7ae2                	ld	s5,56(sp)
ffffffffc0203148:	7b42                	ld	s6,48(sp)
ffffffffc020314a:	7ba2                	ld	s7,40(sp)
ffffffffc020314c:	7c02                	ld	s8,32(sp)
ffffffffc020314e:	6ce2                	ld	s9,24(sp)
ffffffffc0203150:	6d42                	ld	s10,16(sp)
ffffffffc0203152:	6da2                	ld	s11,8(sp)
ffffffffc0203154:	6165                	addi	sp,sp,112
ffffffffc0203156:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc0203158:	4605                	li	a2,1
ffffffffc020315a:	85a2                	mv	a1,s0
ffffffffc020315c:	8556                	mv	a0,s5
ffffffffc020315e:	e03fe0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc0203162:	c169                	beqz	a0,ffffffffc0203224 <copy_range+0x166>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0203164:	000cb783          	ld	a5,0(s9)
    if (!(pte & PTE_V)) {
ffffffffc0203168:	0017f713          	andi	a4,a5,1
ffffffffc020316c:	01f7fc93          	andi	s9,a5,31
ffffffffc0203170:	14070563          	beqz	a4,ffffffffc02032ba <copy_range+0x1fc>
    if (PPN(pa) >= npage) {
ffffffffc0203174:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203178:	078a                	slli	a5,a5,0x2
ffffffffc020317a:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020317e:	12d77263          	bleu	a3,a4,ffffffffc02032a2 <copy_range+0x1e4>
    return &pages[PPN(pa) - nbase];
ffffffffc0203182:	000bb783          	ld	a5,0(s7)
ffffffffc0203186:	fff806b7          	lui	a3,0xfff80
ffffffffc020318a:	9736                	add	a4,a4,a3
ffffffffc020318c:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc020318e:	4505                	li	a0,1
ffffffffc0203190:	00e78db3          	add	s11,a5,a4
ffffffffc0203194:	cbffe0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0203198:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc020319a:	0a0d8463          	beqz	s11,ffffffffc0203242 <copy_range+0x184>
            assert(npage != NULL);
ffffffffc020319e:	c175                	beqz	a0,ffffffffc0203282 <copy_range+0x1c4>
    return page - pages + nbase;
ffffffffc02031a0:	000bb703          	ld	a4,0(s7)
    return KADDR(page2pa(page));
ffffffffc02031a4:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc02031a8:	40ed86b3          	sub	a3,s11,a4
ffffffffc02031ac:	8699                	srai	a3,a3,0x6
ffffffffc02031ae:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc02031b0:	0146f7b3          	and	a5,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc02031b4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02031b6:	06c7fa63          	bleu	a2,a5,ffffffffc020322a <copy_range+0x16c>
    return page - pages + nbase;
ffffffffc02031ba:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc02031be:	000a9717          	auipc	a4,0xa9
ffffffffc02031c2:	41a70713          	addi	a4,a4,1050 # ffffffffc02ac5d8 <va_pa_offset>
ffffffffc02031c6:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc02031c8:	8799                	srai	a5,a5,0x6
ffffffffc02031ca:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc02031cc:	0147f733          	and	a4,a5,s4
ffffffffc02031d0:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02031d4:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02031d6:	04c77963          	bleu	a2,a4,ffffffffc0203228 <copy_range+0x16a>
            memcpy(kva_dst, kva_src, PGSIZE);
ffffffffc02031da:	6605                	lui	a2,0x1
ffffffffc02031dc:	953e                	add	a0,a0,a5
ffffffffc02031de:	448030ef          	jal	ra,ffffffffc0206626 <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc02031e2:	86e6                	mv	a3,s9
ffffffffc02031e4:	8622                	mv	a2,s0
ffffffffc02031e6:	85ea                	mv	a1,s10
ffffffffc02031e8:	8556                	mv	a0,s5
ffffffffc02031ea:	b8cff0ef          	jal	ra,ffffffffc0202576 <page_insert>
            assert(ret == 0);
ffffffffc02031ee:	d131                	beqz	a0,ffffffffc0203132 <copy_range+0x74>
ffffffffc02031f0:	00004697          	auipc	a3,0x4
ffffffffc02031f4:	2e868693          	addi	a3,a3,744 # ffffffffc02074d8 <default_pmm_manager+0x160>
ffffffffc02031f8:	00004617          	auipc	a2,0x4
ffffffffc02031fc:	a3860613          	addi	a2,a2,-1480 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203200:	1bd00593          	li	a1,445
ffffffffc0203204:	00004517          	auipc	a0,0x4
ffffffffc0203208:	2e450513          	addi	a0,a0,740 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc020320c:	a78fd0ef          	jal	ra,ffffffffc0200484 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203210:	002007b7          	lui	a5,0x200
ffffffffc0203214:	943e                	add	s0,s0,a5
ffffffffc0203216:	ffe007b7          	lui	a5,0xffe00
ffffffffc020321a:	8c7d                	and	s0,s0,a5
    } while (start != 0 && start < end);
ffffffffc020321c:	dc11                	beqz	s0,ffffffffc0203138 <copy_range+0x7a>
ffffffffc020321e:	f09460e3          	bltu	s0,s1,ffffffffc020311e <copy_range+0x60>
ffffffffc0203222:	bf19                	j	ffffffffc0203138 <copy_range+0x7a>
                return -E_NO_MEM;
ffffffffc0203224:	5571                	li	a0,-4
ffffffffc0203226:	bf11                	j	ffffffffc020313a <copy_range+0x7c>
ffffffffc0203228:	86be                	mv	a3,a5
ffffffffc020322a:	00004617          	auipc	a2,0x4
ffffffffc020322e:	19e60613          	addi	a2,a2,414 # ffffffffc02073c8 <default_pmm_manager+0x50>
ffffffffc0203232:	06900593          	li	a1,105
ffffffffc0203236:	00004517          	auipc	a0,0x4
ffffffffc020323a:	1ba50513          	addi	a0,a0,442 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc020323e:	a46fd0ef          	jal	ra,ffffffffc0200484 <__panic>
            assert(page != NULL);
ffffffffc0203242:	00004697          	auipc	a3,0x4
ffffffffc0203246:	27668693          	addi	a3,a3,630 # ffffffffc02074b8 <default_pmm_manager+0x140>
ffffffffc020324a:	00004617          	auipc	a2,0x4
ffffffffc020324e:	9e660613          	addi	a2,a2,-1562 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203252:	19f00593          	li	a1,415
ffffffffc0203256:	00004517          	auipc	a0,0x4
ffffffffc020325a:	29250513          	addi	a0,a0,658 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc020325e:	a26fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203262:	00005697          	auipc	a3,0x5
ffffffffc0203266:	83668693          	addi	a3,a3,-1994 # ffffffffc0207a98 <default_pmm_manager+0x720>
ffffffffc020326a:	00004617          	auipc	a2,0x4
ffffffffc020326e:	9c660613          	addi	a2,a2,-1594 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203272:	18600593          	li	a1,390
ffffffffc0203276:	00004517          	auipc	a0,0x4
ffffffffc020327a:	27250513          	addi	a0,a0,626 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc020327e:	a06fd0ef          	jal	ra,ffffffffc0200484 <__panic>
            assert(npage != NULL);
ffffffffc0203282:	00004697          	auipc	a3,0x4
ffffffffc0203286:	24668693          	addi	a3,a3,582 # ffffffffc02074c8 <default_pmm_manager+0x150>
ffffffffc020328a:	00004617          	auipc	a2,0x4
ffffffffc020328e:	9a660613          	addi	a2,a2,-1626 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203292:	1a000593          	li	a1,416
ffffffffc0203296:	00004517          	auipc	a0,0x4
ffffffffc020329a:	25250513          	addi	a0,a0,594 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc020329e:	9e6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02032a2:	00004617          	auipc	a2,0x4
ffffffffc02032a6:	18660613          	addi	a2,a2,390 # ffffffffc0207428 <default_pmm_manager+0xb0>
ffffffffc02032aa:	06200593          	li	a1,98
ffffffffc02032ae:	00004517          	auipc	a0,0x4
ffffffffc02032b2:	14250513          	addi	a0,a0,322 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc02032b6:	9cefd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02032ba:	00004617          	auipc	a2,0x4
ffffffffc02032be:	3c660613          	addi	a2,a2,966 # ffffffffc0207680 <default_pmm_manager+0x308>
ffffffffc02032c2:	07400593          	li	a1,116
ffffffffc02032c6:	00004517          	auipc	a0,0x4
ffffffffc02032ca:	12a50513          	addi	a0,a0,298 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc02032ce:	9b6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02032d2:	00004697          	auipc	a3,0x4
ffffffffc02032d6:	79668693          	addi	a3,a3,1942 # ffffffffc0207a68 <default_pmm_manager+0x6f0>
ffffffffc02032da:	00004617          	auipc	a2,0x4
ffffffffc02032de:	95660613          	addi	a2,a2,-1706 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02032e2:	18500593          	li	a1,389
ffffffffc02032e6:	00004517          	auipc	a0,0x4
ffffffffc02032ea:	20250513          	addi	a0,a0,514 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc02032ee:	996fd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02032f2 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02032f2:	12058073          	sfence.vma	a1
}
ffffffffc02032f6:	8082                	ret

ffffffffc02032f8 <pgdir_alloc_page>:
{
ffffffffc02032f8:	7179                	addi	sp,sp,-48
ffffffffc02032fa:	e84a                	sd	s2,16(sp)
ffffffffc02032fc:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02032fe:	4505                	li	a0,1
{
ffffffffc0203300:	f022                	sd	s0,32(sp)
ffffffffc0203302:	ec26                	sd	s1,24(sp)
ffffffffc0203304:	e44e                	sd	s3,8(sp)
ffffffffc0203306:	f406                	sd	ra,40(sp)
ffffffffc0203308:	84ae                	mv	s1,a1
ffffffffc020330a:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020330c:	b47fe0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0203310:	842a                	mv	s0,a0
    if (page != NULL)
ffffffffc0203312:	cd1d                	beqz	a0,ffffffffc0203350 <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc0203314:	85aa                	mv	a1,a0
ffffffffc0203316:	86ce                	mv	a3,s3
ffffffffc0203318:	8626                	mv	a2,s1
ffffffffc020331a:	854a                	mv	a0,s2
ffffffffc020331c:	a5aff0ef          	jal	ra,ffffffffc0202576 <page_insert>
ffffffffc0203320:	e121                	bnez	a0,ffffffffc0203360 <pgdir_alloc_page+0x68>
        if (swap_init_ok)
ffffffffc0203322:	000a9797          	auipc	a5,0xa9
ffffffffc0203326:	26678793          	addi	a5,a5,614 # ffffffffc02ac588 <swap_init_ok>
ffffffffc020332a:	439c                	lw	a5,0(a5)
ffffffffc020332c:	2781                	sext.w	a5,a5
ffffffffc020332e:	c38d                	beqz	a5,ffffffffc0203350 <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL)
ffffffffc0203330:	000a9797          	auipc	a5,0xa9
ffffffffc0203334:	39878793          	addi	a5,a5,920 # ffffffffc02ac6c8 <check_mm_struct>
ffffffffc0203338:	6388                	ld	a0,0(a5)
ffffffffc020333a:	c919                	beqz	a0,ffffffffc0203350 <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc020333c:	4681                	li	a3,0
ffffffffc020333e:	8622                	mv	a2,s0
ffffffffc0203340:	85a6                	mv	a1,s1
ffffffffc0203342:	7da000ef          	jal	ra,ffffffffc0203b1c <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0203346:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0203348:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc020334a:	4785                	li	a5,1
ffffffffc020334c:	02f71063          	bne	a4,a5,ffffffffc020336c <pgdir_alloc_page+0x74>
}
ffffffffc0203350:	8522                	mv	a0,s0
ffffffffc0203352:	70a2                	ld	ra,40(sp)
ffffffffc0203354:	7402                	ld	s0,32(sp)
ffffffffc0203356:	64e2                	ld	s1,24(sp)
ffffffffc0203358:	6942                	ld	s2,16(sp)
ffffffffc020335a:	69a2                	ld	s3,8(sp)
ffffffffc020335c:	6145                	addi	sp,sp,48
ffffffffc020335e:	8082                	ret
            free_page(page);
ffffffffc0203360:	8522                	mv	a0,s0
ffffffffc0203362:	4585                	li	a1,1
ffffffffc0203364:	b77fe0ef          	jal	ra,ffffffffc0201eda <free_pages>
            return NULL;
ffffffffc0203368:	4401                	li	s0,0
ffffffffc020336a:	b7dd                	j	ffffffffc0203350 <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc020336c:	00004697          	auipc	a3,0x4
ffffffffc0203370:	18c68693          	addi	a3,a3,396 # ffffffffc02074f8 <default_pmm_manager+0x180>
ffffffffc0203374:	00004617          	auipc	a2,0x4
ffffffffc0203378:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc020337c:	20a00593          	li	a1,522
ffffffffc0203380:	00004517          	auipc	a0,0x4
ffffffffc0203384:	16850513          	addi	a0,a0,360 # ffffffffc02074e8 <default_pmm_manager+0x170>
ffffffffc0203388:	8fcfd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020338c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020338c:	7135                	addi	sp,sp,-160
ffffffffc020338e:	ed06                	sd	ra,152(sp)
ffffffffc0203390:	e922                	sd	s0,144(sp)
ffffffffc0203392:	e526                	sd	s1,136(sp)
ffffffffc0203394:	e14a                	sd	s2,128(sp)
ffffffffc0203396:	fcce                	sd	s3,120(sp)
ffffffffc0203398:	f8d2                	sd	s4,112(sp)
ffffffffc020339a:	f4d6                	sd	s5,104(sp)
ffffffffc020339c:	f0da                	sd	s6,96(sp)
ffffffffc020339e:	ecde                	sd	s7,88(sp)
ffffffffc02033a0:	e8e2                	sd	s8,80(sp)
ffffffffc02033a2:	e4e6                	sd	s9,72(sp)
ffffffffc02033a4:	e0ea                	sd	s10,64(sp)
ffffffffc02033a6:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02033a8:	7b0010ef          	jal	ra,ffffffffc0204b58 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02033ac:	000a9797          	auipc	a5,0xa9
ffffffffc02033b0:	2cc78793          	addi	a5,a5,716 # ffffffffc02ac678 <max_swap_offset>
ffffffffc02033b4:	6394                	ld	a3,0(a5)
ffffffffc02033b6:	010007b7          	lui	a5,0x1000
ffffffffc02033ba:	17e1                	addi	a5,a5,-8
ffffffffc02033bc:	ff968713          	addi	a4,a3,-7
ffffffffc02033c0:	4ae7ee63          	bltu	a5,a4,ffffffffc020387c <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02033c4:	0009e797          	auipc	a5,0x9e
ffffffffc02033c8:	d4478793          	addi	a5,a5,-700 # ffffffffc02a1108 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02033cc:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02033ce:	000a9697          	auipc	a3,0xa9
ffffffffc02033d2:	1af6b923          	sd	a5,434(a3) # ffffffffc02ac580 <sm>
     int r = sm->init();
ffffffffc02033d6:	9702                	jalr	a4
ffffffffc02033d8:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc02033da:	c10d                	beqz	a0,ffffffffc02033fc <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02033dc:	60ea                	ld	ra,152(sp)
ffffffffc02033de:	644a                	ld	s0,144(sp)
ffffffffc02033e0:	8556                	mv	a0,s5
ffffffffc02033e2:	64aa                	ld	s1,136(sp)
ffffffffc02033e4:	690a                	ld	s2,128(sp)
ffffffffc02033e6:	79e6                	ld	s3,120(sp)
ffffffffc02033e8:	7a46                	ld	s4,112(sp)
ffffffffc02033ea:	7aa6                	ld	s5,104(sp)
ffffffffc02033ec:	7b06                	ld	s6,96(sp)
ffffffffc02033ee:	6be6                	ld	s7,88(sp)
ffffffffc02033f0:	6c46                	ld	s8,80(sp)
ffffffffc02033f2:	6ca6                	ld	s9,72(sp)
ffffffffc02033f4:	6d06                	ld	s10,64(sp)
ffffffffc02033f6:	7de2                	ld	s11,56(sp)
ffffffffc02033f8:	610d                	addi	sp,sp,160
ffffffffc02033fa:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02033fc:	000a9797          	auipc	a5,0xa9
ffffffffc0203400:	18478793          	addi	a5,a5,388 # ffffffffc02ac580 <sm>
ffffffffc0203404:	639c                	ld	a5,0(a5)
ffffffffc0203406:	00004517          	auipc	a0,0x4
ffffffffc020340a:	72a50513          	addi	a0,a0,1834 # ffffffffc0207b30 <default_pmm_manager+0x7b8>
    return listelm->next;
ffffffffc020340e:	000a9417          	auipc	s0,0xa9
ffffffffc0203412:	1aa40413          	addi	s0,s0,426 # ffffffffc02ac5b8 <free_area>
ffffffffc0203416:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203418:	4785                	li	a5,1
ffffffffc020341a:	000a9717          	auipc	a4,0xa9
ffffffffc020341e:	16f72723          	sw	a5,366(a4) # ffffffffc02ac588 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203422:	d6dfc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0203426:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203428:	36878e63          	beq	a5,s0,ffffffffc02037a4 <swap_init+0x418>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020342c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203430:	8305                	srli	a4,a4,0x1
ffffffffc0203432:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203434:	36070c63          	beqz	a4,ffffffffc02037ac <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc0203438:	4481                	li	s1,0
ffffffffc020343a:	4901                	li	s2,0
ffffffffc020343c:	a031                	j	ffffffffc0203448 <swap_init+0xbc>
ffffffffc020343e:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0203442:	8b09                	andi	a4,a4,2
ffffffffc0203444:	36070463          	beqz	a4,ffffffffc02037ac <swap_init+0x420>
        count ++, total += p->property;
ffffffffc0203448:	ff87a703          	lw	a4,-8(a5)
ffffffffc020344c:	679c                	ld	a5,8(a5)
ffffffffc020344e:	2905                	addiw	s2,s2,1
ffffffffc0203450:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203452:	fe8796e3          	bne	a5,s0,ffffffffc020343e <swap_init+0xb2>
ffffffffc0203456:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0203458:	ac9fe0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
ffffffffc020345c:	69351863          	bne	a0,s3,ffffffffc0203aec <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0203460:	8626                	mv	a2,s1
ffffffffc0203462:	85ca                	mv	a1,s2
ffffffffc0203464:	00004517          	auipc	a0,0x4
ffffffffc0203468:	6e450513          	addi	a0,a0,1764 # ffffffffc0207b48 <default_pmm_manager+0x7d0>
ffffffffc020346c:	d23fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0203470:	457000ef          	jal	ra,ffffffffc02040c6 <mm_create>
ffffffffc0203474:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0203476:	60050b63          	beqz	a0,ffffffffc0203a8c <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020347a:	000a9797          	auipc	a5,0xa9
ffffffffc020347e:	24e78793          	addi	a5,a5,590 # ffffffffc02ac6c8 <check_mm_struct>
ffffffffc0203482:	639c                	ld	a5,0(a5)
ffffffffc0203484:	62079463          	bnez	a5,ffffffffc0203aac <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203488:	000a9797          	auipc	a5,0xa9
ffffffffc020348c:	0e878793          	addi	a5,a5,232 # ffffffffc02ac570 <boot_pgdir>
ffffffffc0203490:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0203494:	000a9797          	auipc	a5,0xa9
ffffffffc0203498:	22a7ba23          	sd	a0,564(a5) # ffffffffc02ac6c8 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020349c:	000b3783          	ld	a5,0(s6) # 80000 <_binary_obj___user_exit_out_size+0x75570>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02034a0:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02034a4:	4e079863          	bnez	a5,ffffffffc0203994 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02034a8:	6599                	lui	a1,0x6
ffffffffc02034aa:	460d                	li	a2,3
ffffffffc02034ac:	6505                	lui	a0,0x1
ffffffffc02034ae:	465000ef          	jal	ra,ffffffffc0204112 <vma_create>
ffffffffc02034b2:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02034b4:	50050063          	beqz	a0,ffffffffc02039b4 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc02034b8:	855e                	mv	a0,s7
ffffffffc02034ba:	4c5000ef          	jal	ra,ffffffffc020417e <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02034be:	00004517          	auipc	a0,0x4
ffffffffc02034c2:	6fa50513          	addi	a0,a0,1786 # ffffffffc0207bb8 <default_pmm_manager+0x840>
ffffffffc02034c6:	cc9fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02034ca:	018bb503          	ld	a0,24(s7)
ffffffffc02034ce:	4605                	li	a2,1
ffffffffc02034d0:	6585                	lui	a1,0x1
ffffffffc02034d2:	a8ffe0ef          	jal	ra,ffffffffc0201f60 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02034d6:	4e050f63          	beqz	a0,ffffffffc02039d4 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02034da:	00004517          	auipc	a0,0x4
ffffffffc02034de:	72e50513          	addi	a0,a0,1838 # ffffffffc0207c08 <default_pmm_manager+0x890>
ffffffffc02034e2:	000a9997          	auipc	s3,0xa9
ffffffffc02034e6:	10e98993          	addi	s3,s3,270 # ffffffffc02ac5f0 <check_rp>
ffffffffc02034ea:	ca5fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034ee:	000a9a17          	auipc	s4,0xa9
ffffffffc02034f2:	122a0a13          	addi	s4,s4,290 # ffffffffc02ac610 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02034f6:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc02034f8:	4505                	li	a0,1
ffffffffc02034fa:	959fe0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc02034fe:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0203502:	32050d63          	beqz	a0,ffffffffc020383c <swap_init+0x4b0>
ffffffffc0203506:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0203508:	8b89                	andi	a5,a5,2
ffffffffc020350a:	30079963          	bnez	a5,ffffffffc020381c <swap_init+0x490>
ffffffffc020350e:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203510:	ff4c14e3          	bne	s8,s4,ffffffffc02034f8 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203514:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203516:	000a9c17          	auipc	s8,0xa9
ffffffffc020351a:	0dac0c13          	addi	s8,s8,218 # ffffffffc02ac5f0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc020351e:	ec3e                	sd	a5,24(sp)
ffffffffc0203520:	641c                	ld	a5,8(s0)
ffffffffc0203522:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203524:	481c                	lw	a5,16(s0)
ffffffffc0203526:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0203528:	000a9797          	auipc	a5,0xa9
ffffffffc020352c:	0887bc23          	sd	s0,152(a5) # ffffffffc02ac5c0 <free_area+0x8>
ffffffffc0203530:	000a9797          	auipc	a5,0xa9
ffffffffc0203534:	0887b423          	sd	s0,136(a5) # ffffffffc02ac5b8 <free_area>
     nr_free = 0;
ffffffffc0203538:	000a9797          	auipc	a5,0xa9
ffffffffc020353c:	0807a823          	sw	zero,144(a5) # ffffffffc02ac5c8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0203540:	000c3503          	ld	a0,0(s8)
ffffffffc0203544:	4585                	li	a1,1
ffffffffc0203546:	0c21                	addi	s8,s8,8
ffffffffc0203548:	993fe0ef          	jal	ra,ffffffffc0201eda <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020354c:	ff4c1ae3          	bne	s8,s4,ffffffffc0203540 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203550:	01042c03          	lw	s8,16(s0)
ffffffffc0203554:	4791                	li	a5,4
ffffffffc0203556:	50fc1b63          	bne	s8,a5,ffffffffc0203a6c <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020355a:	00004517          	auipc	a0,0x4
ffffffffc020355e:	73650513          	addi	a0,a0,1846 # ffffffffc0207c90 <default_pmm_manager+0x918>
ffffffffc0203562:	c2dfc0ef          	jal	ra,ffffffffc020018e <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203566:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203568:	000a9797          	auipc	a5,0xa9
ffffffffc020356c:	0207a223          	sw	zero,36(a5) # ffffffffc02ac58c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203570:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0203572:	000a9797          	auipc	a5,0xa9
ffffffffc0203576:	01a78793          	addi	a5,a5,26 # ffffffffc02ac58c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020357a:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x8580>
     assert(pgfault_num==1);
ffffffffc020357e:	4398                	lw	a4,0(a5)
ffffffffc0203580:	4585                	li	a1,1
ffffffffc0203582:	2701                	sext.w	a4,a4
ffffffffc0203584:	38b71863          	bne	a4,a1,ffffffffc0203914 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0203588:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc020358c:	4394                	lw	a3,0(a5)
ffffffffc020358e:	2681                	sext.w	a3,a3
ffffffffc0203590:	3ae69263          	bne	a3,a4,ffffffffc0203934 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203594:	6689                	lui	a3,0x2
ffffffffc0203596:	462d                	li	a2,11
ffffffffc0203598:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7580>
     assert(pgfault_num==2);
ffffffffc020359c:	4398                	lw	a4,0(a5)
ffffffffc020359e:	4589                	li	a1,2
ffffffffc02035a0:	2701                	sext.w	a4,a4
ffffffffc02035a2:	2eb71963          	bne	a4,a1,ffffffffc0203894 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02035a6:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02035aa:	4394                	lw	a3,0(a5)
ffffffffc02035ac:	2681                	sext.w	a3,a3
ffffffffc02035ae:	30e69363          	bne	a3,a4,ffffffffc02038b4 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02035b2:	668d                	lui	a3,0x3
ffffffffc02035b4:	4631                	li	a2,12
ffffffffc02035b6:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6580>
     assert(pgfault_num==3);
ffffffffc02035ba:	4398                	lw	a4,0(a5)
ffffffffc02035bc:	458d                	li	a1,3
ffffffffc02035be:	2701                	sext.w	a4,a4
ffffffffc02035c0:	30b71a63          	bne	a4,a1,ffffffffc02038d4 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02035c4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02035c8:	4394                	lw	a3,0(a5)
ffffffffc02035ca:	2681                	sext.w	a3,a3
ffffffffc02035cc:	32e69463          	bne	a3,a4,ffffffffc02038f4 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02035d0:	6691                	lui	a3,0x4
ffffffffc02035d2:	4635                	li	a2,13
ffffffffc02035d4:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5580>
     assert(pgfault_num==4);
ffffffffc02035d8:	4398                	lw	a4,0(a5)
ffffffffc02035da:	2701                	sext.w	a4,a4
ffffffffc02035dc:	37871c63          	bne	a4,s8,ffffffffc0203954 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02035e0:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02035e4:	439c                	lw	a5,0(a5)
ffffffffc02035e6:	2781                	sext.w	a5,a5
ffffffffc02035e8:	38e79663          	bne	a5,a4,ffffffffc0203974 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02035ec:	481c                	lw	a5,16(s0)
ffffffffc02035ee:	40079363          	bnez	a5,ffffffffc02039f4 <swap_init+0x668>
ffffffffc02035f2:	000a9797          	auipc	a5,0xa9
ffffffffc02035f6:	01e78793          	addi	a5,a5,30 # ffffffffc02ac610 <swap_in_seq_no>
ffffffffc02035fa:	000a9717          	auipc	a4,0xa9
ffffffffc02035fe:	03e70713          	addi	a4,a4,62 # ffffffffc02ac638 <swap_out_seq_no>
ffffffffc0203602:	000a9617          	auipc	a2,0xa9
ffffffffc0203606:	03660613          	addi	a2,a2,54 # ffffffffc02ac638 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc020360a:	56fd                	li	a3,-1
ffffffffc020360c:	c394                	sw	a3,0(a5)
ffffffffc020360e:	c314                	sw	a3,0(a4)
ffffffffc0203610:	0791                	addi	a5,a5,4
ffffffffc0203612:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203614:	fef61ce3          	bne	a2,a5,ffffffffc020360c <swap_init+0x280>
ffffffffc0203618:	000a9697          	auipc	a3,0xa9
ffffffffc020361c:	08068693          	addi	a3,a3,128 # ffffffffc02ac698 <check_ptep>
ffffffffc0203620:	000a9817          	auipc	a6,0xa9
ffffffffc0203624:	fd080813          	addi	a6,a6,-48 # ffffffffc02ac5f0 <check_rp>
ffffffffc0203628:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc020362a:	000a9c97          	auipc	s9,0xa9
ffffffffc020362e:	f4ec8c93          	addi	s9,s9,-178 # ffffffffc02ac578 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203632:	00005d97          	auipc	s11,0x5
ffffffffc0203636:	786d8d93          	addi	s11,s11,1926 # ffffffffc0208db8 <nbase>
ffffffffc020363a:	000a9c17          	auipc	s8,0xa9
ffffffffc020363e:	faec0c13          	addi	s8,s8,-82 # ffffffffc02ac5e8 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0203642:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203646:	4601                	li	a2,0
ffffffffc0203648:	85ea                	mv	a1,s10
ffffffffc020364a:	855a                	mv	a0,s6
ffffffffc020364c:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc020364e:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203650:	911fe0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc0203654:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203656:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203658:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc020365a:	20050163          	beqz	a0,ffffffffc020385c <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020365e:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203660:	0017f613          	andi	a2,a5,1
ffffffffc0203664:	1a060063          	beqz	a2,ffffffffc0203804 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc0203668:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020366c:	078a                	slli	a5,a5,0x2
ffffffffc020366e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203670:	14c7fe63          	bleu	a2,a5,ffffffffc02037cc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203674:	000db703          	ld	a4,0(s11)
ffffffffc0203678:	000c3603          	ld	a2,0(s8)
ffffffffc020367c:	00083583          	ld	a1,0(a6)
ffffffffc0203680:	8f99                	sub	a5,a5,a4
ffffffffc0203682:	079a                	slli	a5,a5,0x6
ffffffffc0203684:	e43a                	sd	a4,8(sp)
ffffffffc0203686:	97b2                	add	a5,a5,a2
ffffffffc0203688:	14f59e63          	bne	a1,a5,ffffffffc02037e4 <swap_init+0x458>
ffffffffc020368c:	6785                	lui	a5,0x1
ffffffffc020368e:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203690:	6795                	lui	a5,0x5
ffffffffc0203692:	06a1                	addi	a3,a3,8
ffffffffc0203694:	0821                	addi	a6,a6,8
ffffffffc0203696:	fafd16e3          	bne	s10,a5,ffffffffc0203642 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020369a:	00004517          	auipc	a0,0x4
ffffffffc020369e:	69e50513          	addi	a0,a0,1694 # ffffffffc0207d38 <default_pmm_manager+0x9c0>
ffffffffc02036a2:	aedfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = sm->check_swap();
ffffffffc02036a6:	000a9797          	auipc	a5,0xa9
ffffffffc02036aa:	eda78793          	addi	a5,a5,-294 # ffffffffc02ac580 <sm>
ffffffffc02036ae:	639c                	ld	a5,0(a5)
ffffffffc02036b0:	7f9c                	ld	a5,56(a5)
ffffffffc02036b2:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02036b4:	40051c63          	bnez	a0,ffffffffc0203acc <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc02036b8:	77a2                	ld	a5,40(sp)
ffffffffc02036ba:	000a9717          	auipc	a4,0xa9
ffffffffc02036be:	f0f72723          	sw	a5,-242(a4) # ffffffffc02ac5c8 <free_area+0x10>
     free_list = free_list_store;
ffffffffc02036c2:	67e2                	ld	a5,24(sp)
ffffffffc02036c4:	000a9717          	auipc	a4,0xa9
ffffffffc02036c8:	eef73a23          	sd	a5,-268(a4) # ffffffffc02ac5b8 <free_area>
ffffffffc02036cc:	7782                	ld	a5,32(sp)
ffffffffc02036ce:	000a9717          	auipc	a4,0xa9
ffffffffc02036d2:	eef73923          	sd	a5,-270(a4) # ffffffffc02ac5c0 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02036d6:	0009b503          	ld	a0,0(s3)
ffffffffc02036da:	4585                	li	a1,1
ffffffffc02036dc:	09a1                	addi	s3,s3,8
ffffffffc02036de:	ffcfe0ef          	jal	ra,ffffffffc0201eda <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02036e2:	ff499ae3          	bne	s3,s4,ffffffffc02036d6 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02036e6:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc02036ea:	855e                	mv	a0,s7
ffffffffc02036ec:	361000ef          	jal	ra,ffffffffc020424c <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02036f0:	000a9797          	auipc	a5,0xa9
ffffffffc02036f4:	e8078793          	addi	a5,a5,-384 # ffffffffc02ac570 <boot_pgdir>
ffffffffc02036f8:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc02036fa:	000a9697          	auipc	a3,0xa9
ffffffffc02036fe:	fc06b723          	sd	zero,-50(a3) # ffffffffc02ac6c8 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc0203702:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203706:	6394                	ld	a3,0(a5)
ffffffffc0203708:	068a                	slli	a3,a3,0x2
ffffffffc020370a:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020370c:	0ce6f063          	bleu	a4,a3,ffffffffc02037cc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203710:	67a2                	ld	a5,8(sp)
ffffffffc0203712:	000c3503          	ld	a0,0(s8)
ffffffffc0203716:	8e9d                	sub	a3,a3,a5
ffffffffc0203718:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc020371a:	8699                	srai	a3,a3,0x6
ffffffffc020371c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020371e:	57fd                	li	a5,-1
ffffffffc0203720:	83b1                	srli	a5,a5,0xc
ffffffffc0203722:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203724:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203726:	2ee7f763          	bleu	a4,a5,ffffffffc0203a14 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc020372a:	000a9797          	auipc	a5,0xa9
ffffffffc020372e:	eae78793          	addi	a5,a5,-338 # ffffffffc02ac5d8 <va_pa_offset>
ffffffffc0203732:	639c                	ld	a5,0(a5)
ffffffffc0203734:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203736:	629c                	ld	a5,0(a3)
ffffffffc0203738:	078a                	slli	a5,a5,0x2
ffffffffc020373a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020373c:	08e7f863          	bleu	a4,a5,ffffffffc02037cc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203740:	69a2                	ld	s3,8(sp)
ffffffffc0203742:	4585                	li	a1,1
ffffffffc0203744:	413787b3          	sub	a5,a5,s3
ffffffffc0203748:	079a                	slli	a5,a5,0x6
ffffffffc020374a:	953e                	add	a0,a0,a5
ffffffffc020374c:	f8efe0ef          	jal	ra,ffffffffc0201eda <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203750:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203754:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203758:	078a                	slli	a5,a5,0x2
ffffffffc020375a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020375c:	06e7f863          	bleu	a4,a5,ffffffffc02037cc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203760:	000c3503          	ld	a0,0(s8)
ffffffffc0203764:	413787b3          	sub	a5,a5,s3
ffffffffc0203768:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc020376a:	4585                	li	a1,1
ffffffffc020376c:	953e                	add	a0,a0,a5
ffffffffc020376e:	f6cfe0ef          	jal	ra,ffffffffc0201eda <free_pages>
     pgdir[0] = 0;
ffffffffc0203772:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203776:	12000073          	sfence.vma
    return listelm->next;
ffffffffc020377a:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020377c:	00878963          	beq	a5,s0,ffffffffc020378e <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203780:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203784:	679c                	ld	a5,8(a5)
ffffffffc0203786:	397d                	addiw	s2,s2,-1
ffffffffc0203788:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020378a:	fe879be3          	bne	a5,s0,ffffffffc0203780 <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc020378e:	28091f63          	bnez	s2,ffffffffc0203a2c <swap_init+0x6a0>
     assert(total==0);
ffffffffc0203792:	2a049d63          	bnez	s1,ffffffffc0203a4c <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203796:	00004517          	auipc	a0,0x4
ffffffffc020379a:	5f250513          	addi	a0,a0,1522 # ffffffffc0207d88 <default_pmm_manager+0xa10>
ffffffffc020379e:	9f1fc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02037a2:	b92d                	j	ffffffffc02033dc <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc02037a4:	4481                	li	s1,0
ffffffffc02037a6:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc02037a8:	4981                	li	s3,0
ffffffffc02037aa:	b17d                	j	ffffffffc0203458 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc02037ac:	00004697          	auipc	a3,0x4
ffffffffc02037b0:	83c68693          	addi	a3,a3,-1988 # ffffffffc0206fe8 <commands+0x878>
ffffffffc02037b4:	00003617          	auipc	a2,0x3
ffffffffc02037b8:	47c60613          	addi	a2,a2,1148 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02037bc:	0bc00593          	li	a1,188
ffffffffc02037c0:	00004517          	auipc	a0,0x4
ffffffffc02037c4:	36050513          	addi	a0,a0,864 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc02037c8:	cbdfc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02037cc:	00004617          	auipc	a2,0x4
ffffffffc02037d0:	c5c60613          	addi	a2,a2,-932 # ffffffffc0207428 <default_pmm_manager+0xb0>
ffffffffc02037d4:	06200593          	li	a1,98
ffffffffc02037d8:	00004517          	auipc	a0,0x4
ffffffffc02037dc:	c1850513          	addi	a0,a0,-1000 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc02037e0:	ca5fc0ef          	jal	ra,ffffffffc0200484 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02037e4:	00004697          	auipc	a3,0x4
ffffffffc02037e8:	52c68693          	addi	a3,a3,1324 # ffffffffc0207d10 <default_pmm_manager+0x998>
ffffffffc02037ec:	00003617          	auipc	a2,0x3
ffffffffc02037f0:	44460613          	addi	a2,a2,1092 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02037f4:	0fc00593          	li	a1,252
ffffffffc02037f8:	00004517          	auipc	a0,0x4
ffffffffc02037fc:	32850513          	addi	a0,a0,808 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203800:	c85fc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203804:	00004617          	auipc	a2,0x4
ffffffffc0203808:	e7c60613          	addi	a2,a2,-388 # ffffffffc0207680 <default_pmm_manager+0x308>
ffffffffc020380c:	07400593          	li	a1,116
ffffffffc0203810:	00004517          	auipc	a0,0x4
ffffffffc0203814:	be050513          	addi	a0,a0,-1056 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc0203818:	c6dfc0ef          	jal	ra,ffffffffc0200484 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020381c:	00004697          	auipc	a3,0x4
ffffffffc0203820:	42c68693          	addi	a3,a3,1068 # ffffffffc0207c48 <default_pmm_manager+0x8d0>
ffffffffc0203824:	00003617          	auipc	a2,0x3
ffffffffc0203828:	40c60613          	addi	a2,a2,1036 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc020382c:	0dd00593          	li	a1,221
ffffffffc0203830:	00004517          	auipc	a0,0x4
ffffffffc0203834:	2f050513          	addi	a0,a0,752 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203838:	c4dfc0ef          	jal	ra,ffffffffc0200484 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc020383c:	00004697          	auipc	a3,0x4
ffffffffc0203840:	3f468693          	addi	a3,a3,1012 # ffffffffc0207c30 <default_pmm_manager+0x8b8>
ffffffffc0203844:	00003617          	auipc	a2,0x3
ffffffffc0203848:	3ec60613          	addi	a2,a2,1004 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc020384c:	0dc00593          	li	a1,220
ffffffffc0203850:	00004517          	auipc	a0,0x4
ffffffffc0203854:	2d050513          	addi	a0,a0,720 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203858:	c2dfc0ef          	jal	ra,ffffffffc0200484 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc020385c:	00004697          	auipc	a3,0x4
ffffffffc0203860:	49c68693          	addi	a3,a3,1180 # ffffffffc0207cf8 <default_pmm_manager+0x980>
ffffffffc0203864:	00003617          	auipc	a2,0x3
ffffffffc0203868:	3cc60613          	addi	a2,a2,972 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc020386c:	0fb00593          	li	a1,251
ffffffffc0203870:	00004517          	auipc	a0,0x4
ffffffffc0203874:	2b050513          	addi	a0,a0,688 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203878:	c0dfc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020387c:	00004617          	auipc	a2,0x4
ffffffffc0203880:	28460613          	addi	a2,a2,644 # ffffffffc0207b00 <default_pmm_manager+0x788>
ffffffffc0203884:	02800593          	li	a1,40
ffffffffc0203888:	00004517          	auipc	a0,0x4
ffffffffc020388c:	29850513          	addi	a0,a0,664 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203890:	bf5fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==2);
ffffffffc0203894:	00004697          	auipc	a3,0x4
ffffffffc0203898:	43468693          	addi	a3,a3,1076 # ffffffffc0207cc8 <default_pmm_manager+0x950>
ffffffffc020389c:	00003617          	auipc	a2,0x3
ffffffffc02038a0:	39460613          	addi	a2,a2,916 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02038a4:	09700593          	li	a1,151
ffffffffc02038a8:	00004517          	auipc	a0,0x4
ffffffffc02038ac:	27850513          	addi	a0,a0,632 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc02038b0:	bd5fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==2);
ffffffffc02038b4:	00004697          	auipc	a3,0x4
ffffffffc02038b8:	41468693          	addi	a3,a3,1044 # ffffffffc0207cc8 <default_pmm_manager+0x950>
ffffffffc02038bc:	00003617          	auipc	a2,0x3
ffffffffc02038c0:	37460613          	addi	a2,a2,884 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02038c4:	09900593          	li	a1,153
ffffffffc02038c8:	00004517          	auipc	a0,0x4
ffffffffc02038cc:	25850513          	addi	a0,a0,600 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc02038d0:	bb5fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==3);
ffffffffc02038d4:	00004697          	auipc	a3,0x4
ffffffffc02038d8:	40468693          	addi	a3,a3,1028 # ffffffffc0207cd8 <default_pmm_manager+0x960>
ffffffffc02038dc:	00003617          	auipc	a2,0x3
ffffffffc02038e0:	35460613          	addi	a2,a2,852 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02038e4:	09b00593          	li	a1,155
ffffffffc02038e8:	00004517          	auipc	a0,0x4
ffffffffc02038ec:	23850513          	addi	a0,a0,568 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc02038f0:	b95fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==3);
ffffffffc02038f4:	00004697          	auipc	a3,0x4
ffffffffc02038f8:	3e468693          	addi	a3,a3,996 # ffffffffc0207cd8 <default_pmm_manager+0x960>
ffffffffc02038fc:	00003617          	auipc	a2,0x3
ffffffffc0203900:	33460613          	addi	a2,a2,820 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203904:	09d00593          	li	a1,157
ffffffffc0203908:	00004517          	auipc	a0,0x4
ffffffffc020390c:	21850513          	addi	a0,a0,536 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203910:	b75fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==1);
ffffffffc0203914:	00004697          	auipc	a3,0x4
ffffffffc0203918:	3a468693          	addi	a3,a3,932 # ffffffffc0207cb8 <default_pmm_manager+0x940>
ffffffffc020391c:	00003617          	auipc	a2,0x3
ffffffffc0203920:	31460613          	addi	a2,a2,788 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203924:	09300593          	li	a1,147
ffffffffc0203928:	00004517          	auipc	a0,0x4
ffffffffc020392c:	1f850513          	addi	a0,a0,504 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203930:	b55fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==1);
ffffffffc0203934:	00004697          	auipc	a3,0x4
ffffffffc0203938:	38468693          	addi	a3,a3,900 # ffffffffc0207cb8 <default_pmm_manager+0x940>
ffffffffc020393c:	00003617          	auipc	a2,0x3
ffffffffc0203940:	2f460613          	addi	a2,a2,756 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203944:	09500593          	li	a1,149
ffffffffc0203948:	00004517          	auipc	a0,0x4
ffffffffc020394c:	1d850513          	addi	a0,a0,472 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203950:	b35fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==4);
ffffffffc0203954:	00004697          	auipc	a3,0x4
ffffffffc0203958:	39468693          	addi	a3,a3,916 # ffffffffc0207ce8 <default_pmm_manager+0x970>
ffffffffc020395c:	00003617          	auipc	a2,0x3
ffffffffc0203960:	2d460613          	addi	a2,a2,724 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203964:	09f00593          	li	a1,159
ffffffffc0203968:	00004517          	auipc	a0,0x4
ffffffffc020396c:	1b850513          	addi	a0,a0,440 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203970:	b15fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==4);
ffffffffc0203974:	00004697          	auipc	a3,0x4
ffffffffc0203978:	37468693          	addi	a3,a3,884 # ffffffffc0207ce8 <default_pmm_manager+0x970>
ffffffffc020397c:	00003617          	auipc	a2,0x3
ffffffffc0203980:	2b460613          	addi	a2,a2,692 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203984:	0a100593          	li	a1,161
ffffffffc0203988:	00004517          	auipc	a0,0x4
ffffffffc020398c:	19850513          	addi	a0,a0,408 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203990:	af5fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203994:	00004697          	auipc	a3,0x4
ffffffffc0203998:	20468693          	addi	a3,a3,516 # ffffffffc0207b98 <default_pmm_manager+0x820>
ffffffffc020399c:	00003617          	auipc	a2,0x3
ffffffffc02039a0:	29460613          	addi	a2,a2,660 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02039a4:	0cc00593          	li	a1,204
ffffffffc02039a8:	00004517          	auipc	a0,0x4
ffffffffc02039ac:	17850513          	addi	a0,a0,376 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc02039b0:	ad5fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(vma != NULL);
ffffffffc02039b4:	00004697          	auipc	a3,0x4
ffffffffc02039b8:	1f468693          	addi	a3,a3,500 # ffffffffc0207ba8 <default_pmm_manager+0x830>
ffffffffc02039bc:	00003617          	auipc	a2,0x3
ffffffffc02039c0:	27460613          	addi	a2,a2,628 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02039c4:	0cf00593          	li	a1,207
ffffffffc02039c8:	00004517          	auipc	a0,0x4
ffffffffc02039cc:	15850513          	addi	a0,a0,344 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc02039d0:	ab5fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02039d4:	00004697          	auipc	a3,0x4
ffffffffc02039d8:	21c68693          	addi	a3,a3,540 # ffffffffc0207bf0 <default_pmm_manager+0x878>
ffffffffc02039dc:	00003617          	auipc	a2,0x3
ffffffffc02039e0:	25460613          	addi	a2,a2,596 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02039e4:	0d700593          	li	a1,215
ffffffffc02039e8:	00004517          	auipc	a0,0x4
ffffffffc02039ec:	13850513          	addi	a0,a0,312 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc02039f0:	a95fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert( nr_free == 0);         
ffffffffc02039f4:	00003697          	auipc	a3,0x3
ffffffffc02039f8:	7c468693          	addi	a3,a3,1988 # ffffffffc02071b8 <commands+0xa48>
ffffffffc02039fc:	00003617          	auipc	a2,0x3
ffffffffc0203a00:	23460613          	addi	a2,a2,564 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203a04:	0f300593          	li	a1,243
ffffffffc0203a08:	00004517          	auipc	a0,0x4
ffffffffc0203a0c:	11850513          	addi	a0,a0,280 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203a10:	a75fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203a14:	00004617          	auipc	a2,0x4
ffffffffc0203a18:	9b460613          	addi	a2,a2,-1612 # ffffffffc02073c8 <default_pmm_manager+0x50>
ffffffffc0203a1c:	06900593          	li	a1,105
ffffffffc0203a20:	00004517          	auipc	a0,0x4
ffffffffc0203a24:	9d050513          	addi	a0,a0,-1584 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc0203a28:	a5dfc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(count==0);
ffffffffc0203a2c:	00004697          	auipc	a3,0x4
ffffffffc0203a30:	33c68693          	addi	a3,a3,828 # ffffffffc0207d68 <default_pmm_manager+0x9f0>
ffffffffc0203a34:	00003617          	auipc	a2,0x3
ffffffffc0203a38:	1fc60613          	addi	a2,a2,508 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203a3c:	11d00593          	li	a1,285
ffffffffc0203a40:	00004517          	auipc	a0,0x4
ffffffffc0203a44:	0e050513          	addi	a0,a0,224 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203a48:	a3dfc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(total==0);
ffffffffc0203a4c:	00004697          	auipc	a3,0x4
ffffffffc0203a50:	32c68693          	addi	a3,a3,812 # ffffffffc0207d78 <default_pmm_manager+0xa00>
ffffffffc0203a54:	00003617          	auipc	a2,0x3
ffffffffc0203a58:	1dc60613          	addi	a2,a2,476 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203a5c:	11e00593          	li	a1,286
ffffffffc0203a60:	00004517          	auipc	a0,0x4
ffffffffc0203a64:	0c050513          	addi	a0,a0,192 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203a68:	a1dfc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203a6c:	00004697          	auipc	a3,0x4
ffffffffc0203a70:	1fc68693          	addi	a3,a3,508 # ffffffffc0207c68 <default_pmm_manager+0x8f0>
ffffffffc0203a74:	00003617          	auipc	a2,0x3
ffffffffc0203a78:	1bc60613          	addi	a2,a2,444 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203a7c:	0ea00593          	li	a1,234
ffffffffc0203a80:	00004517          	auipc	a0,0x4
ffffffffc0203a84:	0a050513          	addi	a0,a0,160 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203a88:	9fdfc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(mm != NULL);
ffffffffc0203a8c:	00004697          	auipc	a3,0x4
ffffffffc0203a90:	0e468693          	addi	a3,a3,228 # ffffffffc0207b70 <default_pmm_manager+0x7f8>
ffffffffc0203a94:	00003617          	auipc	a2,0x3
ffffffffc0203a98:	19c60613          	addi	a2,a2,412 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203a9c:	0c400593          	li	a1,196
ffffffffc0203aa0:	00004517          	auipc	a0,0x4
ffffffffc0203aa4:	08050513          	addi	a0,a0,128 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203aa8:	9ddfc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203aac:	00004697          	auipc	a3,0x4
ffffffffc0203ab0:	0d468693          	addi	a3,a3,212 # ffffffffc0207b80 <default_pmm_manager+0x808>
ffffffffc0203ab4:	00003617          	auipc	a2,0x3
ffffffffc0203ab8:	17c60613          	addi	a2,a2,380 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203abc:	0c700593          	li	a1,199
ffffffffc0203ac0:	00004517          	auipc	a0,0x4
ffffffffc0203ac4:	06050513          	addi	a0,a0,96 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203ac8:	9bdfc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(ret==0);
ffffffffc0203acc:	00004697          	auipc	a3,0x4
ffffffffc0203ad0:	29468693          	addi	a3,a3,660 # ffffffffc0207d60 <default_pmm_manager+0x9e8>
ffffffffc0203ad4:	00003617          	auipc	a2,0x3
ffffffffc0203ad8:	15c60613          	addi	a2,a2,348 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203adc:	10200593          	li	a1,258
ffffffffc0203ae0:	00004517          	auipc	a0,0x4
ffffffffc0203ae4:	04050513          	addi	a0,a0,64 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203ae8:	99dfc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203aec:	00003697          	auipc	a3,0x3
ffffffffc0203af0:	52468693          	addi	a3,a3,1316 # ffffffffc0207010 <commands+0x8a0>
ffffffffc0203af4:	00003617          	auipc	a2,0x3
ffffffffc0203af8:	13c60613          	addi	a2,a2,316 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203afc:	0bf00593          	li	a1,191
ffffffffc0203b00:	00004517          	auipc	a0,0x4
ffffffffc0203b04:	02050513          	addi	a0,a0,32 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203b08:	97dfc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203b0c <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203b0c:	000a9797          	auipc	a5,0xa9
ffffffffc0203b10:	a7478793          	addi	a5,a5,-1420 # ffffffffc02ac580 <sm>
ffffffffc0203b14:	639c                	ld	a5,0(a5)
ffffffffc0203b16:	0107b303          	ld	t1,16(a5)
ffffffffc0203b1a:	8302                	jr	t1

ffffffffc0203b1c <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203b1c:	000a9797          	auipc	a5,0xa9
ffffffffc0203b20:	a6478793          	addi	a5,a5,-1436 # ffffffffc02ac580 <sm>
ffffffffc0203b24:	639c                	ld	a5,0(a5)
ffffffffc0203b26:	0207b303          	ld	t1,32(a5)
ffffffffc0203b2a:	8302                	jr	t1

ffffffffc0203b2c <swap_out>:
{
ffffffffc0203b2c:	711d                	addi	sp,sp,-96
ffffffffc0203b2e:	ec86                	sd	ra,88(sp)
ffffffffc0203b30:	e8a2                	sd	s0,80(sp)
ffffffffc0203b32:	e4a6                	sd	s1,72(sp)
ffffffffc0203b34:	e0ca                	sd	s2,64(sp)
ffffffffc0203b36:	fc4e                	sd	s3,56(sp)
ffffffffc0203b38:	f852                	sd	s4,48(sp)
ffffffffc0203b3a:	f456                	sd	s5,40(sp)
ffffffffc0203b3c:	f05a                	sd	s6,32(sp)
ffffffffc0203b3e:	ec5e                	sd	s7,24(sp)
ffffffffc0203b40:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203b42:	cde9                	beqz	a1,ffffffffc0203c1c <swap_out+0xf0>
ffffffffc0203b44:	8ab2                	mv	s5,a2
ffffffffc0203b46:	892a                	mv	s2,a0
ffffffffc0203b48:	8a2e                	mv	s4,a1
ffffffffc0203b4a:	4401                	li	s0,0
ffffffffc0203b4c:	000a9997          	auipc	s3,0xa9
ffffffffc0203b50:	a3498993          	addi	s3,s3,-1484 # ffffffffc02ac580 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b54:	00004b17          	auipc	s6,0x4
ffffffffc0203b58:	2b4b0b13          	addi	s6,s6,692 # ffffffffc0207e08 <default_pmm_manager+0xa90>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203b5c:	00004b97          	auipc	s7,0x4
ffffffffc0203b60:	294b8b93          	addi	s7,s7,660 # ffffffffc0207df0 <default_pmm_manager+0xa78>
ffffffffc0203b64:	a825                	j	ffffffffc0203b9c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b66:	67a2                	ld	a5,8(sp)
ffffffffc0203b68:	8626                	mv	a2,s1
ffffffffc0203b6a:	85a2                	mv	a1,s0
ffffffffc0203b6c:	7f94                	ld	a3,56(a5)
ffffffffc0203b6e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203b70:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b72:	82b1                	srli	a3,a3,0xc
ffffffffc0203b74:	0685                	addi	a3,a3,1
ffffffffc0203b76:	e18fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b7a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203b7c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b7e:	7d1c                	ld	a5,56(a0)
ffffffffc0203b80:	83b1                	srli	a5,a5,0xc
ffffffffc0203b82:	0785                	addi	a5,a5,1
ffffffffc0203b84:	07a2                	slli	a5,a5,0x8
ffffffffc0203b86:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203b8a:	b50fe0ef          	jal	ra,ffffffffc0201eda <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203b8e:	01893503          	ld	a0,24(s2)
ffffffffc0203b92:	85a6                	mv	a1,s1
ffffffffc0203b94:	f5eff0ef          	jal	ra,ffffffffc02032f2 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203b98:	048a0d63          	beq	s4,s0,ffffffffc0203bf2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203b9c:	0009b783          	ld	a5,0(s3)
ffffffffc0203ba0:	8656                	mv	a2,s5
ffffffffc0203ba2:	002c                	addi	a1,sp,8
ffffffffc0203ba4:	7b9c                	ld	a5,48(a5)
ffffffffc0203ba6:	854a                	mv	a0,s2
ffffffffc0203ba8:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203baa:	e12d                	bnez	a0,ffffffffc0203c0c <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203bac:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203bae:	01893503          	ld	a0,24(s2)
ffffffffc0203bb2:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203bb4:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203bb6:	85a6                	mv	a1,s1
ffffffffc0203bb8:	ba8fe0ef          	jal	ra,ffffffffc0201f60 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203bbc:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203bbe:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203bc0:	8b85                	andi	a5,a5,1
ffffffffc0203bc2:	cfb9                	beqz	a5,ffffffffc0203c20 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203bc4:	65a2                	ld	a1,8(sp)
ffffffffc0203bc6:	7d9c                	ld	a5,56(a1)
ffffffffc0203bc8:	83b1                	srli	a5,a5,0xc
ffffffffc0203bca:	00178513          	addi	a0,a5,1
ffffffffc0203bce:	0522                	slli	a0,a0,0x8
ffffffffc0203bd0:	058010ef          	jal	ra,ffffffffc0204c28 <swapfs_write>
ffffffffc0203bd4:	d949                	beqz	a0,ffffffffc0203b66 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203bd6:	855e                	mv	a0,s7
ffffffffc0203bd8:	db6fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203bdc:	0009b783          	ld	a5,0(s3)
ffffffffc0203be0:	6622                	ld	a2,8(sp)
ffffffffc0203be2:	4681                	li	a3,0
ffffffffc0203be4:	739c                	ld	a5,32(a5)
ffffffffc0203be6:	85a6                	mv	a1,s1
ffffffffc0203be8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203bea:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203bec:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203bee:	fa8a17e3          	bne	s4,s0,ffffffffc0203b9c <swap_out+0x70>
}
ffffffffc0203bf2:	8522                	mv	a0,s0
ffffffffc0203bf4:	60e6                	ld	ra,88(sp)
ffffffffc0203bf6:	6446                	ld	s0,80(sp)
ffffffffc0203bf8:	64a6                	ld	s1,72(sp)
ffffffffc0203bfa:	6906                	ld	s2,64(sp)
ffffffffc0203bfc:	79e2                	ld	s3,56(sp)
ffffffffc0203bfe:	7a42                	ld	s4,48(sp)
ffffffffc0203c00:	7aa2                	ld	s5,40(sp)
ffffffffc0203c02:	7b02                	ld	s6,32(sp)
ffffffffc0203c04:	6be2                	ld	s7,24(sp)
ffffffffc0203c06:	6c42                	ld	s8,16(sp)
ffffffffc0203c08:	6125                	addi	sp,sp,96
ffffffffc0203c0a:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203c0c:	85a2                	mv	a1,s0
ffffffffc0203c0e:	00004517          	auipc	a0,0x4
ffffffffc0203c12:	19a50513          	addi	a0,a0,410 # ffffffffc0207da8 <default_pmm_manager+0xa30>
ffffffffc0203c16:	d78fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                  break;
ffffffffc0203c1a:	bfe1                	j	ffffffffc0203bf2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203c1c:	4401                	li	s0,0
ffffffffc0203c1e:	bfd1                	j	ffffffffc0203bf2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c20:	00004697          	auipc	a3,0x4
ffffffffc0203c24:	1b868693          	addi	a3,a3,440 # ffffffffc0207dd8 <default_pmm_manager+0xa60>
ffffffffc0203c28:	00003617          	auipc	a2,0x3
ffffffffc0203c2c:	00860613          	addi	a2,a2,8 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203c30:	06800593          	li	a1,104
ffffffffc0203c34:	00004517          	auipc	a0,0x4
ffffffffc0203c38:	eec50513          	addi	a0,a0,-276 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203c3c:	849fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203c40 <swap_in>:
{
ffffffffc0203c40:	7179                	addi	sp,sp,-48
ffffffffc0203c42:	e84a                	sd	s2,16(sp)
ffffffffc0203c44:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203c46:	4505                	li	a0,1
{
ffffffffc0203c48:	ec26                	sd	s1,24(sp)
ffffffffc0203c4a:	e44e                	sd	s3,8(sp)
ffffffffc0203c4c:	f406                	sd	ra,40(sp)
ffffffffc0203c4e:	f022                	sd	s0,32(sp)
ffffffffc0203c50:	84ae                	mv	s1,a1
ffffffffc0203c52:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203c54:	9fefe0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203c58:	c129                	beqz	a0,ffffffffc0203c9a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203c5a:	842a                	mv	s0,a0
ffffffffc0203c5c:	01893503          	ld	a0,24(s2)
ffffffffc0203c60:	4601                	li	a2,0
ffffffffc0203c62:	85a6                	mv	a1,s1
ffffffffc0203c64:	afcfe0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc0203c68:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203c6a:	6108                	ld	a0,0(a0)
ffffffffc0203c6c:	85a2                	mv	a1,s0
ffffffffc0203c6e:	723000ef          	jal	ra,ffffffffc0204b90 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203c72:	00093583          	ld	a1,0(s2)
ffffffffc0203c76:	8626                	mv	a2,s1
ffffffffc0203c78:	00004517          	auipc	a0,0x4
ffffffffc0203c7c:	e4850513          	addi	a0,a0,-440 # ffffffffc0207ac0 <default_pmm_manager+0x748>
ffffffffc0203c80:	81a1                	srli	a1,a1,0x8
ffffffffc0203c82:	d0cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0203c86:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203c88:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203c8c:	7402                	ld	s0,32(sp)
ffffffffc0203c8e:	64e2                	ld	s1,24(sp)
ffffffffc0203c90:	6942                	ld	s2,16(sp)
ffffffffc0203c92:	69a2                	ld	s3,8(sp)
ffffffffc0203c94:	4501                	li	a0,0
ffffffffc0203c96:	6145                	addi	sp,sp,48
ffffffffc0203c98:	8082                	ret
     assert(result!=NULL);
ffffffffc0203c9a:	00004697          	auipc	a3,0x4
ffffffffc0203c9e:	e1668693          	addi	a3,a3,-490 # ffffffffc0207ab0 <default_pmm_manager+0x738>
ffffffffc0203ca2:	00003617          	auipc	a2,0x3
ffffffffc0203ca6:	f8e60613          	addi	a2,a2,-114 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203caa:	07e00593          	li	a1,126
ffffffffc0203cae:	00004517          	auipc	a0,0x4
ffffffffc0203cb2:	e7250513          	addi	a0,a0,-398 # ffffffffc0207b20 <default_pmm_manager+0x7a8>
ffffffffc0203cb6:	fcefc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203cba <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203cba:	000a9797          	auipc	a5,0xa9
ffffffffc0203cbe:	9fe78793          	addi	a5,a5,-1538 # ffffffffc02ac6b8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{
    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
ffffffffc0203cc2:	f51c                	sd	a5,40(a0)
ffffffffc0203cc4:	e79c                	sd	a5,8(a5)
ffffffffc0203cc6:	e39c                	sd	a5,0(a5)
    // cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    return 0;
}
ffffffffc0203cc8:	4501                	li	a0,0
ffffffffc0203cca:	8082                	ret

ffffffffc0203ccc <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203ccc:	4501                	li	a0,0
ffffffffc0203cce:	8082                	ret

ffffffffc0203cd0 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203cd0:	4501                	li	a0,0
ffffffffc0203cd2:	8082                	ret

ffffffffc0203cd4 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{
    return 0;
}
ffffffffc0203cd4:	4501                	li	a0,0
ffffffffc0203cd6:	8082                	ret

ffffffffc0203cd8 <_fifo_check_swap>:
{
ffffffffc0203cd8:	711d                	addi	sp,sp,-96
ffffffffc0203cda:	fc4e                	sd	s3,56(sp)
ffffffffc0203cdc:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203cde:	00004517          	auipc	a0,0x4
ffffffffc0203ce2:	16a50513          	addi	a0,a0,362 # ffffffffc0207e48 <default_pmm_manager+0xad0>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203ce6:	698d                	lui	s3,0x3
ffffffffc0203ce8:	4a31                	li	s4,12
{
ffffffffc0203cea:	e8a2                	sd	s0,80(sp)
ffffffffc0203cec:	e4a6                	sd	s1,72(sp)
ffffffffc0203cee:	ec86                	sd	ra,88(sp)
ffffffffc0203cf0:	e0ca                	sd	s2,64(sp)
ffffffffc0203cf2:	f456                	sd	s5,40(sp)
ffffffffc0203cf4:	f05a                	sd	s6,32(sp)
ffffffffc0203cf6:	ec5e                	sd	s7,24(sp)
ffffffffc0203cf8:	e862                	sd	s8,16(sp)
ffffffffc0203cfa:	e466                	sd	s9,8(sp)
    assert(pgfault_num == 4);
ffffffffc0203cfc:	000a9417          	auipc	s0,0xa9
ffffffffc0203d00:	89040413          	addi	s0,s0,-1904 # ffffffffc02ac58c <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d04:	c8afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d08:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6580>
    assert(pgfault_num == 4);
ffffffffc0203d0c:	4004                	lw	s1,0(s0)
ffffffffc0203d0e:	4791                	li	a5,4
ffffffffc0203d10:	2481                	sext.w	s1,s1
ffffffffc0203d12:	14f49963          	bne	s1,a5,ffffffffc0203e64 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d16:	00004517          	auipc	a0,0x4
ffffffffc0203d1a:	18a50513          	addi	a0,a0,394 # ffffffffc0207ea0 <default_pmm_manager+0xb28>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d1e:	6a85                	lui	s5,0x1
ffffffffc0203d20:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d22:	c6cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d26:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8580>
    assert(pgfault_num == 4);
ffffffffc0203d2a:	00042903          	lw	s2,0(s0)
ffffffffc0203d2e:	2901                	sext.w	s2,s2
ffffffffc0203d30:	2a991a63          	bne	s2,s1,ffffffffc0203fe4 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d34:	00004517          	auipc	a0,0x4
ffffffffc0203d38:	19450513          	addi	a0,a0,404 # ffffffffc0207ec8 <default_pmm_manager+0xb50>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d3c:	6b91                	lui	s7,0x4
ffffffffc0203d3e:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d40:	c4efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d44:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5580>
    assert(pgfault_num == 4);
ffffffffc0203d48:	4004                	lw	s1,0(s0)
ffffffffc0203d4a:	2481                	sext.w	s1,s1
ffffffffc0203d4c:	27249c63          	bne	s1,s2,ffffffffc0203fc4 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d50:	00004517          	auipc	a0,0x4
ffffffffc0203d54:	1a050513          	addi	a0,a0,416 # ffffffffc0207ef0 <default_pmm_manager+0xb78>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d58:	6909                	lui	s2,0x2
ffffffffc0203d5a:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d5c:	c32fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d60:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x7580>
    assert(pgfault_num == 4);
ffffffffc0203d64:	401c                	lw	a5,0(s0)
ffffffffc0203d66:	2781                	sext.w	a5,a5
ffffffffc0203d68:	22979e63          	bne	a5,s1,ffffffffc0203fa4 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d6c:	00004517          	auipc	a0,0x4
ffffffffc0203d70:	1ac50513          	addi	a0,a0,428 # ffffffffc0207f18 <default_pmm_manager+0xba0>
ffffffffc0203d74:	c1afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d78:	6795                	lui	a5,0x5
ffffffffc0203d7a:	4739                	li	a4,14
ffffffffc0203d7c:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4580>
    assert(pgfault_num == 5);
ffffffffc0203d80:	4004                	lw	s1,0(s0)
ffffffffc0203d82:	4795                	li	a5,5
ffffffffc0203d84:	2481                	sext.w	s1,s1
ffffffffc0203d86:	1ef49f63          	bne	s1,a5,ffffffffc0203f84 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d8a:	00004517          	auipc	a0,0x4
ffffffffc0203d8e:	16650513          	addi	a0,a0,358 # ffffffffc0207ef0 <default_pmm_manager+0xb78>
ffffffffc0203d92:	bfcfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d96:	01990023          	sb	s9,0(s2)
    assert(pgfault_num == 5);
ffffffffc0203d9a:	401c                	lw	a5,0(s0)
ffffffffc0203d9c:	2781                	sext.w	a5,a5
ffffffffc0203d9e:	1c979363          	bne	a5,s1,ffffffffc0203f64 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203da2:	00004517          	auipc	a0,0x4
ffffffffc0203da6:	0fe50513          	addi	a0,a0,254 # ffffffffc0207ea0 <default_pmm_manager+0xb28>
ffffffffc0203daa:	be4fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203dae:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num == 6);
ffffffffc0203db2:	401c                	lw	a5,0(s0)
ffffffffc0203db4:	4719                	li	a4,6
ffffffffc0203db6:	2781                	sext.w	a5,a5
ffffffffc0203db8:	18e79663          	bne	a5,a4,ffffffffc0203f44 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203dbc:	00004517          	auipc	a0,0x4
ffffffffc0203dc0:	13450513          	addi	a0,a0,308 # ffffffffc0207ef0 <default_pmm_manager+0xb78>
ffffffffc0203dc4:	bcafc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203dc8:	01990023          	sb	s9,0(s2)
    assert(pgfault_num == 7);
ffffffffc0203dcc:	401c                	lw	a5,0(s0)
ffffffffc0203dce:	471d                	li	a4,7
ffffffffc0203dd0:	2781                	sext.w	a5,a5
ffffffffc0203dd2:	14e79963          	bne	a5,a4,ffffffffc0203f24 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203dd6:	00004517          	auipc	a0,0x4
ffffffffc0203dda:	07250513          	addi	a0,a0,114 # ffffffffc0207e48 <default_pmm_manager+0xad0>
ffffffffc0203dde:	bb0fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203de2:	01498023          	sb	s4,0(s3)
    assert(pgfault_num == 8);
ffffffffc0203de6:	401c                	lw	a5,0(s0)
ffffffffc0203de8:	4721                	li	a4,8
ffffffffc0203dea:	2781                	sext.w	a5,a5
ffffffffc0203dec:	10e79c63          	bne	a5,a4,ffffffffc0203f04 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203df0:	00004517          	auipc	a0,0x4
ffffffffc0203df4:	0d850513          	addi	a0,a0,216 # ffffffffc0207ec8 <default_pmm_manager+0xb50>
ffffffffc0203df8:	b96fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203dfc:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num == 9);
ffffffffc0203e00:	401c                	lw	a5,0(s0)
ffffffffc0203e02:	4725                	li	a4,9
ffffffffc0203e04:	2781                	sext.w	a5,a5
ffffffffc0203e06:	0ce79f63          	bne	a5,a4,ffffffffc0203ee4 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203e0a:	00004517          	auipc	a0,0x4
ffffffffc0203e0e:	10e50513          	addi	a0,a0,270 # ffffffffc0207f18 <default_pmm_manager+0xba0>
ffffffffc0203e12:	b7cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203e16:	6795                	lui	a5,0x5
ffffffffc0203e18:	4739                	li	a4,14
ffffffffc0203e1a:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4580>
    assert(pgfault_num == 10);
ffffffffc0203e1e:	4004                	lw	s1,0(s0)
ffffffffc0203e20:	47a9                	li	a5,10
ffffffffc0203e22:	2481                	sext.w	s1,s1
ffffffffc0203e24:	0af49063          	bne	s1,a5,ffffffffc0203ec4 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e28:	00004517          	auipc	a0,0x4
ffffffffc0203e2c:	07850513          	addi	a0,a0,120 # ffffffffc0207ea0 <default_pmm_manager+0xb28>
ffffffffc0203e30:	b5efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e34:	6785                	lui	a5,0x1
ffffffffc0203e36:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8580>
ffffffffc0203e3a:	06979563          	bne	a5,s1,ffffffffc0203ea4 <_fifo_check_swap+0x1cc>
    assert(pgfault_num == 11);
ffffffffc0203e3e:	401c                	lw	a5,0(s0)
ffffffffc0203e40:	472d                	li	a4,11
ffffffffc0203e42:	2781                	sext.w	a5,a5
ffffffffc0203e44:	04e79063          	bne	a5,a4,ffffffffc0203e84 <_fifo_check_swap+0x1ac>
}
ffffffffc0203e48:	60e6                	ld	ra,88(sp)
ffffffffc0203e4a:	6446                	ld	s0,80(sp)
ffffffffc0203e4c:	64a6                	ld	s1,72(sp)
ffffffffc0203e4e:	6906                	ld	s2,64(sp)
ffffffffc0203e50:	79e2                	ld	s3,56(sp)
ffffffffc0203e52:	7a42                	ld	s4,48(sp)
ffffffffc0203e54:	7aa2                	ld	s5,40(sp)
ffffffffc0203e56:	7b02                	ld	s6,32(sp)
ffffffffc0203e58:	6be2                	ld	s7,24(sp)
ffffffffc0203e5a:	6c42                	ld	s8,16(sp)
ffffffffc0203e5c:	6ca2                	ld	s9,8(sp)
ffffffffc0203e5e:	4501                	li	a0,0
ffffffffc0203e60:	6125                	addi	sp,sp,96
ffffffffc0203e62:	8082                	ret
    assert(pgfault_num == 4);
ffffffffc0203e64:	00004697          	auipc	a3,0x4
ffffffffc0203e68:	00c68693          	addi	a3,a3,12 # ffffffffc0207e70 <default_pmm_manager+0xaf8>
ffffffffc0203e6c:	00003617          	auipc	a2,0x3
ffffffffc0203e70:	dc460613          	addi	a2,a2,-572 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203e74:	05200593          	li	a1,82
ffffffffc0203e78:	00004517          	auipc	a0,0x4
ffffffffc0203e7c:	01050513          	addi	a0,a0,16 # ffffffffc0207e88 <default_pmm_manager+0xb10>
ffffffffc0203e80:	e04fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num == 11);
ffffffffc0203e84:	00004697          	auipc	a3,0x4
ffffffffc0203e88:	17468693          	addi	a3,a3,372 # ffffffffc0207ff8 <default_pmm_manager+0xc80>
ffffffffc0203e8c:	00003617          	auipc	a2,0x3
ffffffffc0203e90:	da460613          	addi	a2,a2,-604 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203e94:	07400593          	li	a1,116
ffffffffc0203e98:	00004517          	auipc	a0,0x4
ffffffffc0203e9c:	ff050513          	addi	a0,a0,-16 # ffffffffc0207e88 <default_pmm_manager+0xb10>
ffffffffc0203ea0:	de4fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203ea4:	00004697          	auipc	a3,0x4
ffffffffc0203ea8:	12c68693          	addi	a3,a3,300 # ffffffffc0207fd0 <default_pmm_manager+0xc58>
ffffffffc0203eac:	00003617          	auipc	a2,0x3
ffffffffc0203eb0:	d8460613          	addi	a2,a2,-636 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203eb4:	07200593          	li	a1,114
ffffffffc0203eb8:	00004517          	auipc	a0,0x4
ffffffffc0203ebc:	fd050513          	addi	a0,a0,-48 # ffffffffc0207e88 <default_pmm_manager+0xb10>
ffffffffc0203ec0:	dc4fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num == 10);
ffffffffc0203ec4:	00004697          	auipc	a3,0x4
ffffffffc0203ec8:	0f468693          	addi	a3,a3,244 # ffffffffc0207fb8 <default_pmm_manager+0xc40>
ffffffffc0203ecc:	00003617          	auipc	a2,0x3
ffffffffc0203ed0:	d6460613          	addi	a2,a2,-668 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203ed4:	07000593          	li	a1,112
ffffffffc0203ed8:	00004517          	auipc	a0,0x4
ffffffffc0203edc:	fb050513          	addi	a0,a0,-80 # ffffffffc0207e88 <default_pmm_manager+0xb10>
ffffffffc0203ee0:	da4fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num == 9);
ffffffffc0203ee4:	00004697          	auipc	a3,0x4
ffffffffc0203ee8:	0bc68693          	addi	a3,a3,188 # ffffffffc0207fa0 <default_pmm_manager+0xc28>
ffffffffc0203eec:	00003617          	auipc	a2,0x3
ffffffffc0203ef0:	d4460613          	addi	a2,a2,-700 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203ef4:	06d00593          	li	a1,109
ffffffffc0203ef8:	00004517          	auipc	a0,0x4
ffffffffc0203efc:	f9050513          	addi	a0,a0,-112 # ffffffffc0207e88 <default_pmm_manager+0xb10>
ffffffffc0203f00:	d84fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num == 8);
ffffffffc0203f04:	00004697          	auipc	a3,0x4
ffffffffc0203f08:	08468693          	addi	a3,a3,132 # ffffffffc0207f88 <default_pmm_manager+0xc10>
ffffffffc0203f0c:	00003617          	auipc	a2,0x3
ffffffffc0203f10:	d2460613          	addi	a2,a2,-732 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203f14:	06a00593          	li	a1,106
ffffffffc0203f18:	00004517          	auipc	a0,0x4
ffffffffc0203f1c:	f7050513          	addi	a0,a0,-144 # ffffffffc0207e88 <default_pmm_manager+0xb10>
ffffffffc0203f20:	d64fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num == 7);
ffffffffc0203f24:	00004697          	auipc	a3,0x4
ffffffffc0203f28:	04c68693          	addi	a3,a3,76 # ffffffffc0207f70 <default_pmm_manager+0xbf8>
ffffffffc0203f2c:	00003617          	auipc	a2,0x3
ffffffffc0203f30:	d0460613          	addi	a2,a2,-764 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203f34:	06700593          	li	a1,103
ffffffffc0203f38:	00004517          	auipc	a0,0x4
ffffffffc0203f3c:	f5050513          	addi	a0,a0,-176 # ffffffffc0207e88 <default_pmm_manager+0xb10>
ffffffffc0203f40:	d44fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num == 6);
ffffffffc0203f44:	00004697          	auipc	a3,0x4
ffffffffc0203f48:	01468693          	addi	a3,a3,20 # ffffffffc0207f58 <default_pmm_manager+0xbe0>
ffffffffc0203f4c:	00003617          	auipc	a2,0x3
ffffffffc0203f50:	ce460613          	addi	a2,a2,-796 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203f54:	06400593          	li	a1,100
ffffffffc0203f58:	00004517          	auipc	a0,0x4
ffffffffc0203f5c:	f3050513          	addi	a0,a0,-208 # ffffffffc0207e88 <default_pmm_manager+0xb10>
ffffffffc0203f60:	d24fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num == 5);
ffffffffc0203f64:	00004697          	auipc	a3,0x4
ffffffffc0203f68:	fdc68693          	addi	a3,a3,-36 # ffffffffc0207f40 <default_pmm_manager+0xbc8>
ffffffffc0203f6c:	00003617          	auipc	a2,0x3
ffffffffc0203f70:	cc460613          	addi	a2,a2,-828 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203f74:	06100593          	li	a1,97
ffffffffc0203f78:	00004517          	auipc	a0,0x4
ffffffffc0203f7c:	f1050513          	addi	a0,a0,-240 # ffffffffc0207e88 <default_pmm_manager+0xb10>
ffffffffc0203f80:	d04fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num == 5);
ffffffffc0203f84:	00004697          	auipc	a3,0x4
ffffffffc0203f88:	fbc68693          	addi	a3,a3,-68 # ffffffffc0207f40 <default_pmm_manager+0xbc8>
ffffffffc0203f8c:	00003617          	auipc	a2,0x3
ffffffffc0203f90:	ca460613          	addi	a2,a2,-860 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203f94:	05e00593          	li	a1,94
ffffffffc0203f98:	00004517          	auipc	a0,0x4
ffffffffc0203f9c:	ef050513          	addi	a0,a0,-272 # ffffffffc0207e88 <default_pmm_manager+0xb10>
ffffffffc0203fa0:	ce4fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num == 4);
ffffffffc0203fa4:	00004697          	auipc	a3,0x4
ffffffffc0203fa8:	ecc68693          	addi	a3,a3,-308 # ffffffffc0207e70 <default_pmm_manager+0xaf8>
ffffffffc0203fac:	00003617          	auipc	a2,0x3
ffffffffc0203fb0:	c8460613          	addi	a2,a2,-892 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203fb4:	05b00593          	li	a1,91
ffffffffc0203fb8:	00004517          	auipc	a0,0x4
ffffffffc0203fbc:	ed050513          	addi	a0,a0,-304 # ffffffffc0207e88 <default_pmm_manager+0xb10>
ffffffffc0203fc0:	cc4fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num == 4);
ffffffffc0203fc4:	00004697          	auipc	a3,0x4
ffffffffc0203fc8:	eac68693          	addi	a3,a3,-340 # ffffffffc0207e70 <default_pmm_manager+0xaf8>
ffffffffc0203fcc:	00003617          	auipc	a2,0x3
ffffffffc0203fd0:	c6460613          	addi	a2,a2,-924 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203fd4:	05800593          	li	a1,88
ffffffffc0203fd8:	00004517          	auipc	a0,0x4
ffffffffc0203fdc:	eb050513          	addi	a0,a0,-336 # ffffffffc0207e88 <default_pmm_manager+0xb10>
ffffffffc0203fe0:	ca4fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num == 4);
ffffffffc0203fe4:	00004697          	auipc	a3,0x4
ffffffffc0203fe8:	e8c68693          	addi	a3,a3,-372 # ffffffffc0207e70 <default_pmm_manager+0xaf8>
ffffffffc0203fec:	00003617          	auipc	a2,0x3
ffffffffc0203ff0:	c4460613          	addi	a2,a2,-956 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0203ff4:	05500593          	li	a1,85
ffffffffc0203ff8:	00004517          	auipc	a0,0x4
ffffffffc0203ffc:	e9050513          	addi	a0,a0,-368 # ffffffffc0207e88 <default_pmm_manager+0xb10>
ffffffffc0204000:	c84fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204004 <_fifo_swap_out_victim>:
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
ffffffffc0204004:	751c                	ld	a5,40(a0)
{
ffffffffc0204006:	1141                	addi	sp,sp,-16
ffffffffc0204008:	e406                	sd	ra,8(sp)
    assert(head != NULL);
ffffffffc020400a:	cf91                	beqz	a5,ffffffffc0204026 <_fifo_swap_out_victim+0x22>
    assert(in_tick == 0);
ffffffffc020400c:	ee0d                	bnez	a2,ffffffffc0204046 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc020400e:	679c                	ld	a5,8(a5)
}
ffffffffc0204010:	60a2                	ld	ra,8(sp)
ffffffffc0204012:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0204014:	6394                	ld	a3,0(a5)
ffffffffc0204016:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0204018:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc020401c:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020401e:	e314                	sd	a3,0(a4)
ffffffffc0204020:	e19c                	sd	a5,0(a1)
}
ffffffffc0204022:	0141                	addi	sp,sp,16
ffffffffc0204024:	8082                	ret
    assert(head != NULL);
ffffffffc0204026:	00004697          	auipc	a3,0x4
ffffffffc020402a:	00a68693          	addi	a3,a3,10 # ffffffffc0208030 <default_pmm_manager+0xcb8>
ffffffffc020402e:	00003617          	auipc	a2,0x3
ffffffffc0204032:	c0260613          	addi	a2,a2,-1022 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0204036:	04100593          	li	a1,65
ffffffffc020403a:	00004517          	auipc	a0,0x4
ffffffffc020403e:	e4e50513          	addi	a0,a0,-434 # ffffffffc0207e88 <default_pmm_manager+0xb10>
ffffffffc0204042:	c42fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(in_tick == 0);
ffffffffc0204046:	00004697          	auipc	a3,0x4
ffffffffc020404a:	ffa68693          	addi	a3,a3,-6 # ffffffffc0208040 <default_pmm_manager+0xcc8>
ffffffffc020404e:	00003617          	auipc	a2,0x3
ffffffffc0204052:	be260613          	addi	a2,a2,-1054 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0204056:	04200593          	li	a1,66
ffffffffc020405a:	00004517          	auipc	a0,0x4
ffffffffc020405e:	e2e50513          	addi	a0,a0,-466 # ffffffffc0207e88 <default_pmm_manager+0xb10>
ffffffffc0204062:	c22fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204066 <_fifo_map_swappable>:
    list_entry_t *entry = &(page->pra_page_link);
ffffffffc0204066:	02860713          	addi	a4,a2,40
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
ffffffffc020406a:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020406c:	cb09                	beqz	a4,ffffffffc020407e <_fifo_map_swappable+0x18>
ffffffffc020406e:	cb81                	beqz	a5,ffffffffc020407e <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204070:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0204072:	e398                	sd	a4,0(a5)
}
ffffffffc0204074:	4501                	li	a0,0
ffffffffc0204076:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0204078:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020407a:	f614                	sd	a3,40(a2)
ffffffffc020407c:	8082                	ret
{
ffffffffc020407e:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0204080:	00004697          	auipc	a3,0x4
ffffffffc0204084:	f9068693          	addi	a3,a3,-112 # ffffffffc0208010 <default_pmm_manager+0xc98>
ffffffffc0204088:	00003617          	auipc	a2,0x3
ffffffffc020408c:	ba860613          	addi	a2,a2,-1112 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0204090:	03200593          	li	a1,50
ffffffffc0204094:	00004517          	auipc	a0,0x4
ffffffffc0204098:	df450513          	addi	a0,a0,-524 # ffffffffc0207e88 <default_pmm_manager+0xb10>
{
ffffffffc020409c:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc020409e:	be6fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02040a2 <check_vma_overlap.isra.0.part.1>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02040a2:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02040a4:	00004697          	auipc	a3,0x4
ffffffffc02040a8:	fc468693          	addi	a3,a3,-60 # ffffffffc0208068 <default_pmm_manager+0xcf0>
ffffffffc02040ac:	00003617          	auipc	a2,0x3
ffffffffc02040b0:	b8460613          	addi	a2,a2,-1148 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02040b4:	07900593          	li	a1,121
ffffffffc02040b8:	00004517          	auipc	a0,0x4
ffffffffc02040bc:	fd050513          	addi	a0,a0,-48 # ffffffffc0208088 <default_pmm_manager+0xd10>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02040c0:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02040c2:	bc2fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02040c6 <mm_create>:
{
ffffffffc02040c6:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02040c8:	04000513          	li	a0,64
{
ffffffffc02040cc:	e022                	sd	s0,0(sp)
ffffffffc02040ce:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02040d0:	b87fd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc02040d4:	842a                	mv	s0,a0
    if (mm != NULL)
ffffffffc02040d6:	c515                	beqz	a0,ffffffffc0204102 <mm_create+0x3c>
        if (swap_init_ok)
ffffffffc02040d8:	000a8797          	auipc	a5,0xa8
ffffffffc02040dc:	4b078793          	addi	a5,a5,1200 # ffffffffc02ac588 <swap_init_ok>
ffffffffc02040e0:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc02040e2:	e408                	sd	a0,8(s0)
ffffffffc02040e4:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02040e6:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02040ea:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02040ee:	02052023          	sw	zero,32(a0)
        if (swap_init_ok)
ffffffffc02040f2:	2781                	sext.w	a5,a5
ffffffffc02040f4:	ef81                	bnez	a5,ffffffffc020410c <mm_create+0x46>
            mm->sm_priv = NULL;
ffffffffc02040f6:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc02040fa:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc02040fe:	02043c23          	sd	zero,56(s0)
}
ffffffffc0204102:	8522                	mv	a0,s0
ffffffffc0204104:	60a2                	ld	ra,8(sp)
ffffffffc0204106:	6402                	ld	s0,0(sp)
ffffffffc0204108:	0141                	addi	sp,sp,16
ffffffffc020410a:	8082                	ret
            swap_init_mm(mm);
ffffffffc020410c:	a01ff0ef          	jal	ra,ffffffffc0203b0c <swap_init_mm>
ffffffffc0204110:	b7ed                	j	ffffffffc02040fa <mm_create+0x34>

ffffffffc0204112 <vma_create>:
{
ffffffffc0204112:	1101                	addi	sp,sp,-32
ffffffffc0204114:	e04a                	sd	s2,0(sp)
ffffffffc0204116:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204118:	03000513          	li	a0,48
{
ffffffffc020411c:	e822                	sd	s0,16(sp)
ffffffffc020411e:	e426                	sd	s1,8(sp)
ffffffffc0204120:	ec06                	sd	ra,24(sp)
ffffffffc0204122:	84ae                	mv	s1,a1
ffffffffc0204124:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204126:	b31fd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
    if (vma != NULL)
ffffffffc020412a:	c509                	beqz	a0,ffffffffc0204134 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020412c:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204130:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204132:	cd00                	sw	s0,24(a0)
}
ffffffffc0204134:	60e2                	ld	ra,24(sp)
ffffffffc0204136:	6442                	ld	s0,16(sp)
ffffffffc0204138:	64a2                	ld	s1,8(sp)
ffffffffc020413a:	6902                	ld	s2,0(sp)
ffffffffc020413c:	6105                	addi	sp,sp,32
ffffffffc020413e:	8082                	ret

ffffffffc0204140 <find_vma>:
    if (mm != NULL)
ffffffffc0204140:	c51d                	beqz	a0,ffffffffc020416e <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0204142:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0204144:	c781                	beqz	a5,ffffffffc020414c <find_vma+0xc>
ffffffffc0204146:	6798                	ld	a4,8(a5)
ffffffffc0204148:	02e5f663          	bleu	a4,a1,ffffffffc0204174 <find_vma+0x34>
            list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc020414c:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc020414e:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0204150:	00f50f63          	beq	a0,a5,ffffffffc020416e <find_vma+0x2e>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0204154:	fe87b703          	ld	a4,-24(a5)
ffffffffc0204158:	fee5ebe3          	bltu	a1,a4,ffffffffc020414e <find_vma+0xe>
ffffffffc020415c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0204160:	fee5f7e3          	bleu	a4,a1,ffffffffc020414e <find_vma+0xe>
                vma = le2vma(le, list_link);
ffffffffc0204164:	1781                	addi	a5,a5,-32
        if (vma != NULL)
ffffffffc0204166:	c781                	beqz	a5,ffffffffc020416e <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0204168:	e91c                	sd	a5,16(a0)
}
ffffffffc020416a:	853e                	mv	a0,a5
ffffffffc020416c:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc020416e:	4781                	li	a5,0
}
ffffffffc0204170:	853e                	mv	a0,a5
ffffffffc0204172:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0204174:	6b98                	ld	a4,16(a5)
ffffffffc0204176:	fce5fbe3          	bleu	a4,a1,ffffffffc020414c <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc020417a:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc020417c:	b7fd                	j	ffffffffc020416a <find_vma+0x2a>

ffffffffc020417e <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc020417e:	6590                	ld	a2,8(a1)
ffffffffc0204180:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x8570>
{
ffffffffc0204184:	1141                	addi	sp,sp,-16
ffffffffc0204186:	e406                	sd	ra,8(sp)
ffffffffc0204188:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020418a:	01066863          	bltu	a2,a6,ffffffffc020419a <insert_vma_struct+0x1c>
ffffffffc020418e:	a8b9                	j	ffffffffc02041ec <insert_vma_struct+0x6e>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0204190:	fe87b683          	ld	a3,-24(a5)
ffffffffc0204194:	04d66763          	bltu	a2,a3,ffffffffc02041e2 <insert_vma_struct+0x64>
ffffffffc0204198:	873e                	mv	a4,a5
ffffffffc020419a:	671c                	ld	a5,8(a4)
    while ((le = list_next(le)) != list)
ffffffffc020419c:	fef51ae3          	bne	a0,a5,ffffffffc0204190 <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc02041a0:	02a70463          	beq	a4,a0,ffffffffc02041c8 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02041a4:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02041a8:	fe873883          	ld	a7,-24(a4)
ffffffffc02041ac:	08d8f063          	bleu	a3,a7,ffffffffc020422c <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041b0:	04d66e63          	bltu	a2,a3,ffffffffc020420c <insert_vma_struct+0x8e>
    }
    if (le_next != list)
ffffffffc02041b4:	00f50a63          	beq	a0,a5,ffffffffc02041c8 <insert_vma_struct+0x4a>
ffffffffc02041b8:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041bc:	0506e863          	bltu	a3,a6,ffffffffc020420c <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02041c0:	ff07b603          	ld	a2,-16(a5)
ffffffffc02041c4:	02c6f263          	bleu	a2,a3,ffffffffc02041e8 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc02041c8:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02041ca:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02041cc:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02041d0:	e390                	sd	a2,0(a5)
ffffffffc02041d2:	e710                	sd	a2,8(a4)
}
ffffffffc02041d4:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02041d6:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02041d8:	f198                	sd	a4,32(a1)
    mm->map_count++;
ffffffffc02041da:	2685                	addiw	a3,a3,1
ffffffffc02041dc:	d114                	sw	a3,32(a0)
}
ffffffffc02041de:	0141                	addi	sp,sp,16
ffffffffc02041e0:	8082                	ret
    if (le_prev != list)
ffffffffc02041e2:	fca711e3          	bne	a4,a0,ffffffffc02041a4 <insert_vma_struct+0x26>
ffffffffc02041e6:	bfd9                	j	ffffffffc02041bc <insert_vma_struct+0x3e>
ffffffffc02041e8:	ebbff0ef          	jal	ra,ffffffffc02040a2 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02041ec:	00004697          	auipc	a3,0x4
ffffffffc02041f0:	fd468693          	addi	a3,a3,-44 # ffffffffc02081c0 <default_pmm_manager+0xe48>
ffffffffc02041f4:	00003617          	auipc	a2,0x3
ffffffffc02041f8:	a3c60613          	addi	a2,a2,-1476 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02041fc:	07f00593          	li	a1,127
ffffffffc0204200:	00004517          	auipc	a0,0x4
ffffffffc0204204:	e8850513          	addi	a0,a0,-376 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc0204208:	a7cfc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020420c:	00004697          	auipc	a3,0x4
ffffffffc0204210:	ff468693          	addi	a3,a3,-12 # ffffffffc0208200 <default_pmm_manager+0xe88>
ffffffffc0204214:	00003617          	auipc	a2,0x3
ffffffffc0204218:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc020421c:	07800593          	li	a1,120
ffffffffc0204220:	00004517          	auipc	a0,0x4
ffffffffc0204224:	e6850513          	addi	a0,a0,-408 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc0204228:	a5cfc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020422c:	00004697          	auipc	a3,0x4
ffffffffc0204230:	fb468693          	addi	a3,a3,-76 # ffffffffc02081e0 <default_pmm_manager+0xe68>
ffffffffc0204234:	00003617          	auipc	a2,0x3
ffffffffc0204238:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc020423c:	07700593          	li	a1,119
ffffffffc0204240:	00004517          	auipc	a0,0x4
ffffffffc0204244:	e4850513          	addi	a0,a0,-440 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc0204248:	a3cfc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020424c <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc020424c:	591c                	lw	a5,48(a0)
{
ffffffffc020424e:	1141                	addi	sp,sp,-16
ffffffffc0204250:	e406                	sd	ra,8(sp)
ffffffffc0204252:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0204254:	e78d                	bnez	a5,ffffffffc020427e <mm_destroy+0x32>
ffffffffc0204256:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0204258:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc020425a:	00a40c63          	beq	s0,a0,ffffffffc0204272 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020425e:	6118                	ld	a4,0(a0)
ffffffffc0204260:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc0204262:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0204264:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0204266:	e398                	sd	a4,0(a5)
ffffffffc0204268:	aabfd0ef          	jal	ra,ffffffffc0201d12 <kfree>
    return listelm->next;
ffffffffc020426c:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc020426e:	fea418e3          	bne	s0,a0,ffffffffc020425e <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc0204272:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc0204274:	6402                	ld	s0,0(sp)
ffffffffc0204276:	60a2                	ld	ra,8(sp)
ffffffffc0204278:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc020427a:	a99fd06f          	j	ffffffffc0201d12 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020427e:	00004697          	auipc	a3,0x4
ffffffffc0204282:	fa268693          	addi	a3,a3,-94 # ffffffffc0208220 <default_pmm_manager+0xea8>
ffffffffc0204286:	00003617          	auipc	a2,0x3
ffffffffc020428a:	9aa60613          	addi	a2,a2,-1622 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc020428e:	0a300593          	li	a1,163
ffffffffc0204292:	00004517          	auipc	a0,0x4
ffffffffc0204296:	df650513          	addi	a0,a0,-522 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc020429a:	9eafc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020429e <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020429e:	6785                	lui	a5,0x1
{
ffffffffc02042a0:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042a2:	17fd                	addi	a5,a5,-1
ffffffffc02042a4:	787d                	lui	a6,0xfffff
{
ffffffffc02042a6:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042a8:	00f60433          	add	s0,a2,a5
{
ffffffffc02042ac:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042ae:	942e                	add	s0,s0,a1
{
ffffffffc02042b0:	fc06                	sd	ra,56(sp)
ffffffffc02042b2:	f04a                	sd	s2,32(sp)
ffffffffc02042b4:	ec4e                	sd	s3,24(sp)
ffffffffc02042b6:	e852                	sd	s4,16(sp)
ffffffffc02042b8:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042ba:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end))
ffffffffc02042be:	002007b7          	lui	a5,0x200
ffffffffc02042c2:	01047433          	and	s0,s0,a6
ffffffffc02042c6:	06f4e363          	bltu	s1,a5,ffffffffc020432c <mm_map+0x8e>
ffffffffc02042ca:	0684f163          	bleu	s0,s1,ffffffffc020432c <mm_map+0x8e>
ffffffffc02042ce:	4785                	li	a5,1
ffffffffc02042d0:	07fe                	slli	a5,a5,0x1f
ffffffffc02042d2:	0487ed63          	bltu	a5,s0,ffffffffc020432c <mm_map+0x8e>
ffffffffc02042d6:	89aa                	mv	s3,a0
ffffffffc02042d8:	8a3a                	mv	s4,a4
ffffffffc02042da:	8ab6                	mv	s5,a3
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02042dc:	c931                	beqz	a0,ffffffffc0204330 <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc02042de:	85a6                	mv	a1,s1
ffffffffc02042e0:	e61ff0ef          	jal	ra,ffffffffc0204140 <find_vma>
ffffffffc02042e4:	c501                	beqz	a0,ffffffffc02042ec <mm_map+0x4e>
ffffffffc02042e6:	651c                	ld	a5,8(a0)
ffffffffc02042e8:	0487e263          	bltu	a5,s0,ffffffffc020432c <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02042ec:	03000513          	li	a0,48
ffffffffc02042f0:	967fd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc02042f4:	892a                	mv	s2,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02042f6:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc02042f8:	02090163          	beqz	s2,ffffffffc020431a <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02042fc:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02042fe:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0204302:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0204306:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc020430a:	85ca                	mv	a1,s2
ffffffffc020430c:	e73ff0ef          	jal	ra,ffffffffc020417e <insert_vma_struct>
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0204310:	4501                	li	a0,0
    if (vma_store != NULL)
ffffffffc0204312:	000a0463          	beqz	s4,ffffffffc020431a <mm_map+0x7c>
        *vma_store = vma;
ffffffffc0204316:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc020431a:	70e2                	ld	ra,56(sp)
ffffffffc020431c:	7442                	ld	s0,48(sp)
ffffffffc020431e:	74a2                	ld	s1,40(sp)
ffffffffc0204320:	7902                	ld	s2,32(sp)
ffffffffc0204322:	69e2                	ld	s3,24(sp)
ffffffffc0204324:	6a42                	ld	s4,16(sp)
ffffffffc0204326:	6aa2                	ld	s5,8(sp)
ffffffffc0204328:	6121                	addi	sp,sp,64
ffffffffc020432a:	8082                	ret
        return -E_INVAL;
ffffffffc020432c:	5575                	li	a0,-3
ffffffffc020432e:	b7f5                	j	ffffffffc020431a <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc0204330:	00004697          	auipc	a3,0x4
ffffffffc0204334:	84068693          	addi	a3,a3,-1984 # ffffffffc0207b70 <default_pmm_manager+0x7f8>
ffffffffc0204338:	00003617          	auipc	a2,0x3
ffffffffc020433c:	8f860613          	addi	a2,a2,-1800 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0204340:	0b800593          	li	a1,184
ffffffffc0204344:	00004517          	auipc	a0,0x4
ffffffffc0204348:	d4450513          	addi	a0,a0,-700 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc020434c:	938fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204350 <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc0204350:	7139                	addi	sp,sp,-64
ffffffffc0204352:	fc06                	sd	ra,56(sp)
ffffffffc0204354:	f822                	sd	s0,48(sp)
ffffffffc0204356:	f426                	sd	s1,40(sp)
ffffffffc0204358:	f04a                	sd	s2,32(sp)
ffffffffc020435a:	ec4e                	sd	s3,24(sp)
ffffffffc020435c:	e852                	sd	s4,16(sp)
ffffffffc020435e:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0204360:	c535                	beqz	a0,ffffffffc02043cc <dup_mmap+0x7c>
ffffffffc0204362:	892a                	mv	s2,a0
ffffffffc0204364:	84ae                	mv	s1,a1
    // mmap_list为虚拟地址空间的首地址
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0204366:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0204368:	e59d                	bnez	a1,ffffffffc0204396 <dup_mmap+0x46>
ffffffffc020436a:	a08d                	j	ffffffffc02043cc <dup_mmap+0x7c>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma); // 向新进程插入新创建的段
ffffffffc020436c:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc020436e:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5578>
        insert_vma_struct(to, nvma); // 向新进程插入新创建的段
ffffffffc0204372:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc0204374:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc0204378:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma); // 向新进程插入新创建的段
ffffffffc020437c:	e03ff0ef          	jal	ra,ffffffffc020417e <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc0204380:	ff043683          	ld	a3,-16(s0)
ffffffffc0204384:	fe843603          	ld	a2,-24(s0)
ffffffffc0204388:	6c8c                	ld	a1,24(s1)
ffffffffc020438a:	01893503          	ld	a0,24(s2)
ffffffffc020438e:	4701                	li	a4,0
ffffffffc0204390:	d2ffe0ef          	jal	ra,ffffffffc02030be <copy_range>
ffffffffc0204394:	e105                	bnez	a0,ffffffffc02043b4 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc0204396:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) // 遍历所有段
ffffffffc0204398:	02848863          	beq	s1,s0,ffffffffc02043c8 <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020439c:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02043a0:	fe843a83          	ld	s5,-24(s0)
ffffffffc02043a4:	ff043a03          	ld	s4,-16(s0)
ffffffffc02043a8:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043ac:	8abfd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc02043b0:	87aa                	mv	a5,a0
    if (vma != NULL)
ffffffffc02043b2:	fd4d                	bnez	a0,ffffffffc020436c <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02043b4:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02043b6:	70e2                	ld	ra,56(sp)
ffffffffc02043b8:	7442                	ld	s0,48(sp)
ffffffffc02043ba:	74a2                	ld	s1,40(sp)
ffffffffc02043bc:	7902                	ld	s2,32(sp)
ffffffffc02043be:	69e2                	ld	s3,24(sp)
ffffffffc02043c0:	6a42                	ld	s4,16(sp)
ffffffffc02043c2:	6aa2                	ld	s5,8(sp)
ffffffffc02043c4:	6121                	addi	sp,sp,64
ffffffffc02043c6:	8082                	ret
    return 0;
ffffffffc02043c8:	4501                	li	a0,0
ffffffffc02043ca:	b7f5                	j	ffffffffc02043b6 <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc02043cc:	00004697          	auipc	a3,0x4
ffffffffc02043d0:	db468693          	addi	a3,a3,-588 # ffffffffc0208180 <default_pmm_manager+0xe08>
ffffffffc02043d4:	00003617          	auipc	a2,0x3
ffffffffc02043d8:	85c60613          	addi	a2,a2,-1956 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02043dc:	0d400593          	li	a1,212
ffffffffc02043e0:	00004517          	auipc	a0,0x4
ffffffffc02043e4:	ca850513          	addi	a0,a0,-856 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc02043e8:	89cfc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02043ec <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc02043ec:	1101                	addi	sp,sp,-32
ffffffffc02043ee:	ec06                	sd	ra,24(sp)
ffffffffc02043f0:	e822                	sd	s0,16(sp)
ffffffffc02043f2:	e426                	sd	s1,8(sp)
ffffffffc02043f4:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02043f6:	c531                	beqz	a0,ffffffffc0204442 <exit_mmap+0x56>
ffffffffc02043f8:	591c                	lw	a5,48(a0)
ffffffffc02043fa:	84aa                	mv	s1,a0
ffffffffc02043fc:	e3b9                	bnez	a5,ffffffffc0204442 <exit_mmap+0x56>
    return listelm->next;
ffffffffc02043fe:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0204400:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc0204404:	02850663          	beq	a0,s0,ffffffffc0204430 <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204408:	ff043603          	ld	a2,-16(s0)
ffffffffc020440c:	fe843583          	ld	a1,-24(s0)
ffffffffc0204410:	854a                	mv	a0,s2
ffffffffc0204412:	d83fd0ef          	jal	ra,ffffffffc0202194 <unmap_range>
ffffffffc0204416:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0204418:	fe8498e3          	bne	s1,s0,ffffffffc0204408 <exit_mmap+0x1c>
ffffffffc020441c:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc020441e:	00848c63          	beq	s1,s0,ffffffffc0204436 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204422:	ff043603          	ld	a2,-16(s0)
ffffffffc0204426:	fe843583          	ld	a1,-24(s0)
ffffffffc020442a:	854a                	mv	a0,s2
ffffffffc020442c:	e81fd0ef          	jal	ra,ffffffffc02022ac <exit_range>
ffffffffc0204430:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0204432:	fe8498e3          	bne	s1,s0,ffffffffc0204422 <exit_mmap+0x36>
    }
}
ffffffffc0204436:	60e2                	ld	ra,24(sp)
ffffffffc0204438:	6442                	ld	s0,16(sp)
ffffffffc020443a:	64a2                	ld	s1,8(sp)
ffffffffc020443c:	6902                	ld	s2,0(sp)
ffffffffc020443e:	6105                	addi	sp,sp,32
ffffffffc0204440:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204442:	00004697          	auipc	a3,0x4
ffffffffc0204446:	d5e68693          	addi	a3,a3,-674 # ffffffffc02081a0 <default_pmm_manager+0xe28>
ffffffffc020444a:	00002617          	auipc	a2,0x2
ffffffffc020444e:	7e660613          	addi	a2,a2,2022 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0204452:	0ee00593          	li	a1,238
ffffffffc0204456:	00004517          	auipc	a0,0x4
ffffffffc020445a:	c3250513          	addi	a0,a0,-974 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc020445e:	826fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204462 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0204462:	7139                	addi	sp,sp,-64
ffffffffc0204464:	f822                	sd	s0,48(sp)
ffffffffc0204466:	f426                	sd	s1,40(sp)
ffffffffc0204468:	fc06                	sd	ra,56(sp)
ffffffffc020446a:	f04a                	sd	s2,32(sp)
ffffffffc020446c:	ec4e                	sd	s3,24(sp)
ffffffffc020446e:	e852                	sd	s4,16(sp)
ffffffffc0204470:	e456                	sd	s5,8(sp)
static void
check_vma_struct(void)
{
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0204472:	c55ff0ef          	jal	ra,ffffffffc02040c6 <mm_create>
    assert(mm != NULL);
ffffffffc0204476:	842a                	mv	s0,a0
ffffffffc0204478:	03200493          	li	s1,50
ffffffffc020447c:	e919                	bnez	a0,ffffffffc0204492 <vmm_init+0x30>
ffffffffc020447e:	a989                	j	ffffffffc02048d0 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0204480:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204482:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204484:	00052c23          	sw	zero,24(a0)
    int i;
    for (i = step1; i >= 1; i--)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204488:	14ed                	addi	s1,s1,-5
ffffffffc020448a:	8522                	mv	a0,s0
ffffffffc020448c:	cf3ff0ef          	jal	ra,ffffffffc020417e <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0204490:	c88d                	beqz	s1,ffffffffc02044c2 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204492:	03000513          	li	a0,48
ffffffffc0204496:	fc0fd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc020449a:	85aa                	mv	a1,a0
ffffffffc020449c:	00248793          	addi	a5,s1,2
    if (vma != NULL)
ffffffffc02044a0:	f165                	bnez	a0,ffffffffc0204480 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc02044a2:	00003697          	auipc	a3,0x3
ffffffffc02044a6:	70668693          	addi	a3,a3,1798 # ffffffffc0207ba8 <default_pmm_manager+0x830>
ffffffffc02044aa:	00002617          	auipc	a2,0x2
ffffffffc02044ae:	78660613          	addi	a2,a2,1926 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02044b2:	13200593          	li	a1,306
ffffffffc02044b6:	00004517          	auipc	a0,0x4
ffffffffc02044ba:	bd250513          	addi	a0,a0,-1070 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc02044be:	fc7fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    for (i = step1; i >= 1; i--)
ffffffffc02044c2:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc02044c6:	1f900913          	li	s2,505
ffffffffc02044ca:	a819                	j	ffffffffc02044e0 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc02044cc:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02044ce:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02044d0:	00052c23          	sw	zero,24(a0)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02044d4:	0495                	addi	s1,s1,5
ffffffffc02044d6:	8522                	mv	a0,s0
ffffffffc02044d8:	ca7ff0ef          	jal	ra,ffffffffc020417e <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc02044dc:	03248a63          	beq	s1,s2,ffffffffc0204510 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044e0:	03000513          	li	a0,48
ffffffffc02044e4:	f72fd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc02044e8:	85aa                	mv	a1,a0
ffffffffc02044ea:	00248793          	addi	a5,s1,2
    if (vma != NULL)
ffffffffc02044ee:	fd79                	bnez	a0,ffffffffc02044cc <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc02044f0:	00003697          	auipc	a3,0x3
ffffffffc02044f4:	6b868693          	addi	a3,a3,1720 # ffffffffc0207ba8 <default_pmm_manager+0x830>
ffffffffc02044f8:	00002617          	auipc	a2,0x2
ffffffffc02044fc:	73860613          	addi	a2,a2,1848 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0204500:	13900593          	li	a1,313
ffffffffc0204504:	00004517          	auipc	a0,0x4
ffffffffc0204508:	b8450513          	addi	a0,a0,-1148 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc020450c:	f79fb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0204510:	6418                	ld	a4,8(s0)
ffffffffc0204512:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0204514:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0204518:	2ee40063          	beq	s0,a4,ffffffffc02047f8 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020451c:	fe873603          	ld	a2,-24(a4)
ffffffffc0204520:	ffe78693          	addi	a3,a5,-2
ffffffffc0204524:	24d61a63          	bne	a2,a3,ffffffffc0204778 <vmm_init+0x316>
ffffffffc0204528:	ff073683          	ld	a3,-16(a4)
ffffffffc020452c:	24f69663          	bne	a3,a5,ffffffffc0204778 <vmm_init+0x316>
ffffffffc0204530:	0795                	addi	a5,a5,5
ffffffffc0204532:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i++)
ffffffffc0204534:	feb792e3          	bne	a5,a1,ffffffffc0204518 <vmm_init+0xb6>
ffffffffc0204538:	491d                	li	s2,7
ffffffffc020453a:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc020453c:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0204540:	85a6                	mv	a1,s1
ffffffffc0204542:	8522                	mv	a0,s0
ffffffffc0204544:	bfdff0ef          	jal	ra,ffffffffc0204140 <find_vma>
ffffffffc0204548:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc020454a:	30050763          	beqz	a0,ffffffffc0204858 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc020454e:	00148593          	addi	a1,s1,1
ffffffffc0204552:	8522                	mv	a0,s0
ffffffffc0204554:	bedff0ef          	jal	ra,ffffffffc0204140 <find_vma>
ffffffffc0204558:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020455a:	2c050f63          	beqz	a0,ffffffffc0204838 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc020455e:	85ca                	mv	a1,s2
ffffffffc0204560:	8522                	mv	a0,s0
ffffffffc0204562:	bdfff0ef          	jal	ra,ffffffffc0204140 <find_vma>
        assert(vma3 == NULL);
ffffffffc0204566:	2a051963          	bnez	a0,ffffffffc0204818 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc020456a:	00348593          	addi	a1,s1,3
ffffffffc020456e:	8522                	mv	a0,s0
ffffffffc0204570:	bd1ff0ef          	jal	ra,ffffffffc0204140 <find_vma>
        assert(vma4 == NULL);
ffffffffc0204574:	32051263          	bnez	a0,ffffffffc0204898 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0204578:	00448593          	addi	a1,s1,4
ffffffffc020457c:	8522                	mv	a0,s0
ffffffffc020457e:	bc3ff0ef          	jal	ra,ffffffffc0204140 <find_vma>
        assert(vma5 == NULL);
ffffffffc0204582:	2e051b63          	bnez	a0,ffffffffc0204878 <vmm_init+0x416>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0204586:	008a3783          	ld	a5,8(s4)
ffffffffc020458a:	20979763          	bne	a5,s1,ffffffffc0204798 <vmm_init+0x336>
ffffffffc020458e:	010a3783          	ld	a5,16(s4)
ffffffffc0204592:	21279363          	bne	a5,s2,ffffffffc0204798 <vmm_init+0x336>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0204596:	0089b783          	ld	a5,8(s3)
ffffffffc020459a:	20979f63          	bne	a5,s1,ffffffffc02047b8 <vmm_init+0x356>
ffffffffc020459e:	0109b783          	ld	a5,16(s3)
ffffffffc02045a2:	21279b63          	bne	a5,s2,ffffffffc02047b8 <vmm_init+0x356>
ffffffffc02045a6:	0495                	addi	s1,s1,5
ffffffffc02045a8:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc02045aa:	f9549be3          	bne	s1,s5,ffffffffc0204540 <vmm_init+0xde>
ffffffffc02045ae:	4491                	li	s1,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc02045b0:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc02045b2:	85a6                	mv	a1,s1
ffffffffc02045b4:	8522                	mv	a0,s0
ffffffffc02045b6:	b8bff0ef          	jal	ra,ffffffffc0204140 <find_vma>
ffffffffc02045ba:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL)
ffffffffc02045be:	c90d                	beqz	a0,ffffffffc02045f0 <vmm_init+0x18e>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc02045c0:	6914                	ld	a3,16(a0)
ffffffffc02045c2:	6510                	ld	a2,8(a0)
ffffffffc02045c4:	00004517          	auipc	a0,0x4
ffffffffc02045c8:	d7450513          	addi	a0,a0,-652 # ffffffffc0208338 <default_pmm_manager+0xfc0>
ffffffffc02045cc:	bc3fb0ef          	jal	ra,ffffffffc020018e <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02045d0:	00004697          	auipc	a3,0x4
ffffffffc02045d4:	d9068693          	addi	a3,a3,-624 # ffffffffc0208360 <default_pmm_manager+0xfe8>
ffffffffc02045d8:	00002617          	auipc	a2,0x2
ffffffffc02045dc:	65860613          	addi	a2,a2,1624 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02045e0:	15f00593          	li	a1,351
ffffffffc02045e4:	00004517          	auipc	a0,0x4
ffffffffc02045e8:	aa450513          	addi	a0,a0,-1372 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc02045ec:	e99fb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc02045f0:	14fd                	addi	s1,s1,-1
    for (i = 4; i >= 0; i--)
ffffffffc02045f2:	fd2490e3          	bne	s1,s2,ffffffffc02045b2 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc02045f6:	8522                	mv	a0,s0
ffffffffc02045f8:	c55ff0ef          	jal	ra,ffffffffc020424c <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02045fc:	00004517          	auipc	a0,0x4
ffffffffc0204600:	d7c50513          	addi	a0,a0,-644 # ffffffffc0208378 <default_pmm_manager+0x1000>
ffffffffc0204604:	b8bfb0ef          	jal	ra,ffffffffc020018e <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void)
{
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0204608:	919fd0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
ffffffffc020460c:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc020460e:	ab9ff0ef          	jal	ra,ffffffffc02040c6 <mm_create>
ffffffffc0204612:	000a8797          	auipc	a5,0xa8
ffffffffc0204616:	0aa7bb23          	sd	a0,182(a5) # ffffffffc02ac6c8 <check_mm_struct>
ffffffffc020461a:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc020461c:	36050663          	beqz	a0,ffffffffc0204988 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204620:	000a8797          	auipc	a5,0xa8
ffffffffc0204624:	f5078793          	addi	a5,a5,-176 # ffffffffc02ac570 <boot_pgdir>
ffffffffc0204628:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc020462c:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204630:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0204634:	2c079e63          	bnez	a5,ffffffffc0204910 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204638:	03000513          	li	a0,48
ffffffffc020463c:	e1afd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc0204640:	842a                	mv	s0,a0
    if (vma != NULL)
ffffffffc0204642:	18050b63          	beqz	a0,ffffffffc02047d8 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0204646:	002007b7          	lui	a5,0x200
ffffffffc020464a:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc020464c:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020464e:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0204650:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0204652:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0204654:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0204658:	b27ff0ef          	jal	ra,ffffffffc020417e <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020465c:	10000593          	li	a1,256
ffffffffc0204660:	8526                	mv	a0,s1
ffffffffc0204662:	adfff0ef          	jal	ra,ffffffffc0204140 <find_vma>
ffffffffc0204666:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i++)
ffffffffc020466a:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020466e:	2ca41163          	bne	s0,a0,ffffffffc0204930 <vmm_init+0x4ce>
    {
        *(char *)(addr + i) = i;
ffffffffc0204672:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5570>
        sum += i;
ffffffffc0204676:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i++)
ffffffffc0204678:	fee79de3          	bne	a5,a4,ffffffffc0204672 <vmm_init+0x210>
        sum += i;
ffffffffc020467c:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i++)
ffffffffc020467e:	10000793          	li	a5,256
        sum += i;
ffffffffc0204682:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x822a>
    }
    for (i = 0; i < 100; i++)
ffffffffc0204686:	16400613          	li	a2,356
    {
        sum -= *(char *)(addr + i);
ffffffffc020468a:	0007c683          	lbu	a3,0(a5)
ffffffffc020468e:	0785                	addi	a5,a5,1
ffffffffc0204690:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i++)
ffffffffc0204692:	fec79ce3          	bne	a5,a2,ffffffffc020468a <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc0204696:	2c071963          	bnez	a4,ffffffffc0204968 <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc020469a:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020469e:	000a8a97          	auipc	s5,0xa8
ffffffffc02046a2:	edaa8a93          	addi	s5,s5,-294 # ffffffffc02ac578 <npage>
ffffffffc02046a6:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046aa:	078a                	slli	a5,a5,0x2
ffffffffc02046ac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02046ae:	20e7f563          	bleu	a4,a5,ffffffffc02048b8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02046b2:	00004697          	auipc	a3,0x4
ffffffffc02046b6:	70668693          	addi	a3,a3,1798 # ffffffffc0208db8 <nbase>
ffffffffc02046ba:	0006ba03          	ld	s4,0(a3)
ffffffffc02046be:	414786b3          	sub	a3,a5,s4
ffffffffc02046c2:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02046c4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02046c6:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc02046c8:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02046ca:	83b1                	srli	a5,a5,0xc
ffffffffc02046cc:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02046ce:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02046d0:	28e7f063          	bleu	a4,a5,ffffffffc0204950 <vmm_init+0x4ee>
ffffffffc02046d4:	000a8797          	auipc	a5,0xa8
ffffffffc02046d8:	f0478793          	addi	a5,a5,-252 # ffffffffc02ac5d8 <va_pa_offset>
ffffffffc02046dc:	6380                	ld	s0,0(a5)

    pde_t *pd1 = pgdir, *pd0 = page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02046de:	4581                	li	a1,0
ffffffffc02046e0:	854a                	mv	a0,s2
ffffffffc02046e2:	9436                	add	s0,s0,a3
ffffffffc02046e4:	e1ffd0ef          	jal	ra,ffffffffc0202502 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046e8:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02046ea:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046ee:	078a                	slli	a5,a5,0x2
ffffffffc02046f0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02046f2:	1ce7f363          	bleu	a4,a5,ffffffffc02048b8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02046f6:	000a8417          	auipc	s0,0xa8
ffffffffc02046fa:	ef240413          	addi	s0,s0,-270 # ffffffffc02ac5e8 <pages>
ffffffffc02046fe:	6008                	ld	a0,0(s0)
ffffffffc0204700:	414787b3          	sub	a5,a5,s4
ffffffffc0204704:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0204706:	953e                	add	a0,a0,a5
ffffffffc0204708:	4585                	li	a1,1
ffffffffc020470a:	fd0fd0ef          	jal	ra,ffffffffc0201eda <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020470e:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204712:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204716:	078a                	slli	a5,a5,0x2
ffffffffc0204718:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020471a:	18e7ff63          	bleu	a4,a5,ffffffffc02048b8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc020471e:	6008                	ld	a0,0(s0)
ffffffffc0204720:	414787b3          	sub	a5,a5,s4
ffffffffc0204724:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0204726:	4585                	li	a1,1
ffffffffc0204728:	953e                	add	a0,a0,a5
ffffffffc020472a:	fb0fd0ef          	jal	ra,ffffffffc0201eda <free_pages>
    pgdir[0] = 0;
ffffffffc020472e:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0204732:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0204736:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc020473a:	8526                	mv	a0,s1
ffffffffc020473c:	b11ff0ef          	jal	ra,ffffffffc020424c <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0204740:	000a8797          	auipc	a5,0xa8
ffffffffc0204744:	f807b423          	sd	zero,-120(a5) # ffffffffc02ac6c8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204748:	fd8fd0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
ffffffffc020474c:	1aa99263          	bne	s3,a0,ffffffffc02048f0 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0204750:	00004517          	auipc	a0,0x4
ffffffffc0204754:	cb850513          	addi	a0,a0,-840 # ffffffffc0208408 <default_pmm_manager+0x1090>
ffffffffc0204758:	a37fb0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc020475c:	7442                	ld	s0,48(sp)
ffffffffc020475e:	70e2                	ld	ra,56(sp)
ffffffffc0204760:	74a2                	ld	s1,40(sp)
ffffffffc0204762:	7902                	ld	s2,32(sp)
ffffffffc0204764:	69e2                	ld	s3,24(sp)
ffffffffc0204766:	6a42                	ld	s4,16(sp)
ffffffffc0204768:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020476a:	00004517          	auipc	a0,0x4
ffffffffc020476e:	cbe50513          	addi	a0,a0,-834 # ffffffffc0208428 <default_pmm_manager+0x10b0>
}
ffffffffc0204772:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204774:	a1bfb06f          	j	ffffffffc020018e <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204778:	00004697          	auipc	a3,0x4
ffffffffc020477c:	ad868693          	addi	a3,a3,-1320 # ffffffffc0208250 <default_pmm_manager+0xed8>
ffffffffc0204780:	00002617          	auipc	a2,0x2
ffffffffc0204784:	4b060613          	addi	a2,a2,1200 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0204788:	14300593          	li	a1,323
ffffffffc020478c:	00004517          	auipc	a0,0x4
ffffffffc0204790:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc0204794:	cf1fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0204798:	00004697          	auipc	a3,0x4
ffffffffc020479c:	b4068693          	addi	a3,a3,-1216 # ffffffffc02082d8 <default_pmm_manager+0xf60>
ffffffffc02047a0:	00002617          	auipc	a2,0x2
ffffffffc02047a4:	49060613          	addi	a2,a2,1168 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02047a8:	15400593          	li	a1,340
ffffffffc02047ac:	00004517          	auipc	a0,0x4
ffffffffc02047b0:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc02047b4:	cd1fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc02047b8:	00004697          	auipc	a3,0x4
ffffffffc02047bc:	b5068693          	addi	a3,a3,-1200 # ffffffffc0208308 <default_pmm_manager+0xf90>
ffffffffc02047c0:	00002617          	auipc	a2,0x2
ffffffffc02047c4:	47060613          	addi	a2,a2,1136 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02047c8:	15500593          	li	a1,341
ffffffffc02047cc:	00004517          	auipc	a0,0x4
ffffffffc02047d0:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc02047d4:	cb1fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(vma != NULL);
ffffffffc02047d8:	00003697          	auipc	a3,0x3
ffffffffc02047dc:	3d068693          	addi	a3,a3,976 # ffffffffc0207ba8 <default_pmm_manager+0x830>
ffffffffc02047e0:	00002617          	auipc	a2,0x2
ffffffffc02047e4:	45060613          	addi	a2,a2,1104 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02047e8:	17700593          	li	a1,375
ffffffffc02047ec:	00004517          	auipc	a0,0x4
ffffffffc02047f0:	89c50513          	addi	a0,a0,-1892 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc02047f4:	c91fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02047f8:	00004697          	auipc	a3,0x4
ffffffffc02047fc:	a4068693          	addi	a3,a3,-1472 # ffffffffc0208238 <default_pmm_manager+0xec0>
ffffffffc0204800:	00002617          	auipc	a2,0x2
ffffffffc0204804:	43060613          	addi	a2,a2,1072 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0204808:	14100593          	li	a1,321
ffffffffc020480c:	00004517          	auipc	a0,0x4
ffffffffc0204810:	87c50513          	addi	a0,a0,-1924 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc0204814:	c71fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma3 == NULL);
ffffffffc0204818:	00004697          	auipc	a3,0x4
ffffffffc020481c:	a9068693          	addi	a3,a3,-1392 # ffffffffc02082a8 <default_pmm_manager+0xf30>
ffffffffc0204820:	00002617          	auipc	a2,0x2
ffffffffc0204824:	41060613          	addi	a2,a2,1040 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0204828:	14e00593          	li	a1,334
ffffffffc020482c:	00004517          	auipc	a0,0x4
ffffffffc0204830:	85c50513          	addi	a0,a0,-1956 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc0204834:	c51fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma2 != NULL);
ffffffffc0204838:	00004697          	auipc	a3,0x4
ffffffffc020483c:	a6068693          	addi	a3,a3,-1440 # ffffffffc0208298 <default_pmm_manager+0xf20>
ffffffffc0204840:	00002617          	auipc	a2,0x2
ffffffffc0204844:	3f060613          	addi	a2,a2,1008 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0204848:	14c00593          	li	a1,332
ffffffffc020484c:	00004517          	auipc	a0,0x4
ffffffffc0204850:	83c50513          	addi	a0,a0,-1988 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc0204854:	c31fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma1 != NULL);
ffffffffc0204858:	00004697          	auipc	a3,0x4
ffffffffc020485c:	a3068693          	addi	a3,a3,-1488 # ffffffffc0208288 <default_pmm_manager+0xf10>
ffffffffc0204860:	00002617          	auipc	a2,0x2
ffffffffc0204864:	3d060613          	addi	a2,a2,976 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0204868:	14a00593          	li	a1,330
ffffffffc020486c:	00004517          	auipc	a0,0x4
ffffffffc0204870:	81c50513          	addi	a0,a0,-2020 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc0204874:	c11fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma5 == NULL);
ffffffffc0204878:	00004697          	auipc	a3,0x4
ffffffffc020487c:	a5068693          	addi	a3,a3,-1456 # ffffffffc02082c8 <default_pmm_manager+0xf50>
ffffffffc0204880:	00002617          	auipc	a2,0x2
ffffffffc0204884:	3b060613          	addi	a2,a2,944 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0204888:	15200593          	li	a1,338
ffffffffc020488c:	00003517          	auipc	a0,0x3
ffffffffc0204890:	7fc50513          	addi	a0,a0,2044 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc0204894:	bf1fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma4 == NULL);
ffffffffc0204898:	00004697          	auipc	a3,0x4
ffffffffc020489c:	a2068693          	addi	a3,a3,-1504 # ffffffffc02082b8 <default_pmm_manager+0xf40>
ffffffffc02048a0:	00002617          	auipc	a2,0x2
ffffffffc02048a4:	39060613          	addi	a2,a2,912 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02048a8:	15000593          	li	a1,336
ffffffffc02048ac:	00003517          	auipc	a0,0x3
ffffffffc02048b0:	7dc50513          	addi	a0,a0,2012 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc02048b4:	bd1fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02048b8:	00003617          	auipc	a2,0x3
ffffffffc02048bc:	b7060613          	addi	a2,a2,-1168 # ffffffffc0207428 <default_pmm_manager+0xb0>
ffffffffc02048c0:	06200593          	li	a1,98
ffffffffc02048c4:	00003517          	auipc	a0,0x3
ffffffffc02048c8:	b2c50513          	addi	a0,a0,-1236 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc02048cc:	bb9fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(mm != NULL);
ffffffffc02048d0:	00003697          	auipc	a3,0x3
ffffffffc02048d4:	2a068693          	addi	a3,a3,672 # ffffffffc0207b70 <default_pmm_manager+0x7f8>
ffffffffc02048d8:	00002617          	auipc	a2,0x2
ffffffffc02048dc:	35860613          	addi	a2,a2,856 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02048e0:	12a00593          	li	a1,298
ffffffffc02048e4:	00003517          	auipc	a0,0x3
ffffffffc02048e8:	7a450513          	addi	a0,a0,1956 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc02048ec:	b99fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02048f0:	00004697          	auipc	a3,0x4
ffffffffc02048f4:	af068693          	addi	a3,a3,-1296 # ffffffffc02083e0 <default_pmm_manager+0x1068>
ffffffffc02048f8:	00002617          	auipc	a2,0x2
ffffffffc02048fc:	33860613          	addi	a2,a2,824 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0204900:	19700593          	li	a1,407
ffffffffc0204904:	00003517          	auipc	a0,0x3
ffffffffc0204908:	78450513          	addi	a0,a0,1924 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc020490c:	b79fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0204910:	00003697          	auipc	a3,0x3
ffffffffc0204914:	28868693          	addi	a3,a3,648 # ffffffffc0207b98 <default_pmm_manager+0x820>
ffffffffc0204918:	00002617          	auipc	a2,0x2
ffffffffc020491c:	31860613          	addi	a2,a2,792 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0204920:	17400593          	li	a1,372
ffffffffc0204924:	00003517          	auipc	a0,0x3
ffffffffc0204928:	76450513          	addi	a0,a0,1892 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc020492c:	b59fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0204930:	00004697          	auipc	a3,0x4
ffffffffc0204934:	a8068693          	addi	a3,a3,-1408 # ffffffffc02083b0 <default_pmm_manager+0x1038>
ffffffffc0204938:	00002617          	auipc	a2,0x2
ffffffffc020493c:	2f860613          	addi	a2,a2,760 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0204940:	17c00593          	li	a1,380
ffffffffc0204944:	00003517          	auipc	a0,0x3
ffffffffc0204948:	74450513          	addi	a0,a0,1860 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc020494c:	b39fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204950:	00003617          	auipc	a2,0x3
ffffffffc0204954:	a7860613          	addi	a2,a2,-1416 # ffffffffc02073c8 <default_pmm_manager+0x50>
ffffffffc0204958:	06900593          	li	a1,105
ffffffffc020495c:	00003517          	auipc	a0,0x3
ffffffffc0204960:	a9450513          	addi	a0,a0,-1388 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc0204964:	b21fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(sum == 0);
ffffffffc0204968:	00004697          	auipc	a3,0x4
ffffffffc020496c:	a6868693          	addi	a3,a3,-1432 # ffffffffc02083d0 <default_pmm_manager+0x1058>
ffffffffc0204970:	00002617          	auipc	a2,0x2
ffffffffc0204974:	2c060613          	addi	a2,a2,704 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0204978:	18a00593          	li	a1,394
ffffffffc020497c:	00003517          	auipc	a0,0x3
ffffffffc0204980:	70c50513          	addi	a0,a0,1804 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc0204984:	b01fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0204988:	00004697          	auipc	a3,0x4
ffffffffc020498c:	a1068693          	addi	a3,a3,-1520 # ffffffffc0208398 <default_pmm_manager+0x1020>
ffffffffc0204990:	00002617          	auipc	a2,0x2
ffffffffc0204994:	2a060613          	addi	a2,a2,672 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0204998:	17000593          	li	a1,368
ffffffffc020499c:	00003517          	auipc	a0,0x3
ffffffffc02049a0:	6ec50513          	addi	a0,a0,1772 # ffffffffc0208088 <default_pmm_manager+0xd10>
ffffffffc02049a4:	ae1fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02049a8 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr)
{
ffffffffc02049a8:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    // try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02049aa:	85b2                	mv	a1,a2
{
ffffffffc02049ac:	f022                	sd	s0,32(sp)
ffffffffc02049ae:	ec26                	sd	s1,24(sp)
ffffffffc02049b0:	f406                	sd	ra,40(sp)
ffffffffc02049b2:	e84a                	sd	s2,16(sp)
ffffffffc02049b4:	8432                	mv	s0,a2
ffffffffc02049b6:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02049b8:	f88ff0ef          	jal	ra,ffffffffc0204140 <find_vma>

    pgfault_num++;
ffffffffc02049bc:	000a8797          	auipc	a5,0xa8
ffffffffc02049c0:	bd078793          	addi	a5,a5,-1072 # ffffffffc02ac58c <pgfault_num>
ffffffffc02049c4:	439c                	lw	a5,0(a5)
ffffffffc02049c6:	2785                	addiw	a5,a5,1
ffffffffc02049c8:	000a8717          	auipc	a4,0xa8
ffffffffc02049cc:	bcf72223          	sw	a5,-1084(a4) # ffffffffc02ac58c <pgfault_num>
    // If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr)
ffffffffc02049d0:	c949                	beqz	a0,ffffffffc0204a62 <do_pgfault+0xba>
ffffffffc02049d2:	651c                	ld	a5,8(a0)
ffffffffc02049d4:	08f46763          	bltu	s0,a5,ffffffffc0204a62 <do_pgfault+0xba>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE)
ffffffffc02049d8:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02049da:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE)
ffffffffc02049dc:	8b89                	andi	a5,a5,2
ffffffffc02049de:	e3ad                	bnez	a5,ffffffffc0204a40 <do_pgfault+0x98>
    {
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049e0:	767d                	lui	a2,0xfffff

    pte_t *ptep = NULL;

    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL)
ffffffffc02049e2:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049e4:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL)
ffffffffc02049e6:	85a2                	mv	a1,s0
ffffffffc02049e8:	4605                	li	a2,1
ffffffffc02049ea:	d76fd0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc02049ee:	c179                	beqz	a0,ffffffffc0204ab4 <do_pgfault+0x10c>
    {
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }

    if (*ptep == 0)
ffffffffc02049f0:	610c                	ld	a1,0(a0)
ffffffffc02049f2:	c9a9                	beqz	a1,ffffffffc0204a44 <do_pgfault+0x9c>
         *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
         *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
         *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
         *    swap_map_swappable ： 设置页面可交换
         */
        if (swap_init_ok)
ffffffffc02049f4:	000a8797          	auipc	a5,0xa8
ffffffffc02049f8:	b9478793          	addi	a5,a5,-1132 # ffffffffc02ac588 <swap_init_ok>
ffffffffc02049fc:	439c                	lw	a5,0(a5)
ffffffffc02049fe:	2781                	sext.w	a5,a5
ffffffffc0204a00:	cbb5                	beqz	a5,ffffffffc0204a74 <do_pgfault+0xcc>
            // map of phy addr <--->
            // logical addr
            //(3) make the page swappable.

            // (1) 尝试加载正确的磁盘页面的内容到内存中的页面
            int result = swap_in(mm, addr, &page); // ***在这里进swap_in函数
ffffffffc0204a02:	0030                	addi	a2,sp,8
ffffffffc0204a04:	85a2                	mv	a1,s0
ffffffffc0204a06:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0204a08:	e402                	sd	zero,8(sp)
            int result = swap_in(mm, addr, &page); // ***在这里进swap_in函数
ffffffffc0204a0a:	a36ff0ef          	jal	ra,ffffffffc0203c40 <swap_in>
            if (result != 0)
ffffffffc0204a0e:	e93d                	bnez	a0,ffffffffc0204a84 <do_pgfault+0xdc>
                cprintf("swap_in failed\n");
                goto failed;
            }

            // (2) 设置物理地址和逻辑地址的映射
            if (page_insert(mm->pgdir, page, addr, perm) != 0)
ffffffffc0204a10:	65a2                	ld	a1,8(sp)
ffffffffc0204a12:	6c88                	ld	a0,24(s1)
ffffffffc0204a14:	86ca                	mv	a3,s2
ffffffffc0204a16:	8622                	mv	a2,s0
ffffffffc0204a18:	b5ffd0ef          	jal	ra,ffffffffc0202576 <page_insert>
ffffffffc0204a1c:	ed25                	bnez	a0,ffffffffc0204a94 <do_pgfault+0xec>
                cprintf("page_insert failed\n");
                goto failed;
            }

            // (3) 设置页面为可交换的
            if (swap_map_swappable(mm, addr, page, 1) != 0)
ffffffffc0204a1e:	6622                	ld	a2,8(sp)
ffffffffc0204a20:	4685                	li	a3,1
ffffffffc0204a22:	85a2                	mv	a1,s0
ffffffffc0204a24:	8526                	mv	a0,s1
ffffffffc0204a26:	8f6ff0ef          	jal	ra,ffffffffc0203b1c <swap_map_swappable>
ffffffffc0204a2a:	87aa                	mv	a5,a0
ffffffffc0204a2c:	ed25                	bnez	a0,ffffffffc0204aa4 <do_pgfault+0xfc>
            {
                cprintf("swap_map_swappable failed\n");
                goto failed;
            }
            page->pra_vaddr = addr; // 标记这个页面将来是可以再换出的
ffffffffc0204a2e:	6722                	ld	a4,8(sp)
ffffffffc0204a30:	ff00                	sd	s0,56(a4)
    }

    ret = 0;
failed:
    return ret;
}
ffffffffc0204a32:	70a2                	ld	ra,40(sp)
ffffffffc0204a34:	7402                	ld	s0,32(sp)
ffffffffc0204a36:	64e2                	ld	s1,24(sp)
ffffffffc0204a38:	6942                	ld	s2,16(sp)
ffffffffc0204a3a:	853e                	mv	a0,a5
ffffffffc0204a3c:	6145                	addi	sp,sp,48
ffffffffc0204a3e:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204a40:	495d                	li	s2,23
ffffffffc0204a42:	bf79                	j	ffffffffc02049e0 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL)
ffffffffc0204a44:	6c88                	ld	a0,24(s1)
ffffffffc0204a46:	864a                	mv	a2,s2
ffffffffc0204a48:	85a2                	mv	a1,s0
ffffffffc0204a4a:	8affe0ef          	jal	ra,ffffffffc02032f8 <pgdir_alloc_page>
    ret = 0;
ffffffffc0204a4e:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL)
ffffffffc0204a50:	f16d                	bnez	a0,ffffffffc0204a32 <do_pgfault+0x8a>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204a52:	00003517          	auipc	a0,0x3
ffffffffc0204a56:	69650513          	addi	a0,a0,1686 # ffffffffc02080e8 <default_pmm_manager+0xd70>
ffffffffc0204a5a:	f34fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a5e:	57f1                	li	a5,-4
            goto failed;
ffffffffc0204a60:	bfc9                	j	ffffffffc0204a32 <do_pgfault+0x8a>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204a62:	85a2                	mv	a1,s0
ffffffffc0204a64:	00003517          	auipc	a0,0x3
ffffffffc0204a68:	63450513          	addi	a0,a0,1588 # ffffffffc0208098 <default_pmm_manager+0xd20>
ffffffffc0204a6c:	f22fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = -E_INVAL;
ffffffffc0204a70:	57f5                	li	a5,-3
        goto failed;
ffffffffc0204a72:	b7c1                	j	ffffffffc0204a32 <do_pgfault+0x8a>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204a74:	00003517          	auipc	a0,0x3
ffffffffc0204a78:	6e450513          	addi	a0,a0,1764 # ffffffffc0208158 <default_pmm_manager+0xde0>
ffffffffc0204a7c:	f12fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a80:	57f1                	li	a5,-4
            goto failed;
ffffffffc0204a82:	bf45                	j	ffffffffc0204a32 <do_pgfault+0x8a>
                cprintf("swap_in failed\n");
ffffffffc0204a84:	00003517          	auipc	a0,0x3
ffffffffc0204a88:	68c50513          	addi	a0,a0,1676 # ffffffffc0208110 <default_pmm_manager+0xd98>
ffffffffc0204a8c:	f02fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a90:	57f1                	li	a5,-4
ffffffffc0204a92:	b745                	j	ffffffffc0204a32 <do_pgfault+0x8a>
                cprintf("page_insert failed\n");
ffffffffc0204a94:	00003517          	auipc	a0,0x3
ffffffffc0204a98:	68c50513          	addi	a0,a0,1676 # ffffffffc0208120 <default_pmm_manager+0xda8>
ffffffffc0204a9c:	ef2fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204aa0:	57f1                	li	a5,-4
ffffffffc0204aa2:	bf41                	j	ffffffffc0204a32 <do_pgfault+0x8a>
                cprintf("swap_map_swappable failed\n");
ffffffffc0204aa4:	00003517          	auipc	a0,0x3
ffffffffc0204aa8:	69450513          	addi	a0,a0,1684 # ffffffffc0208138 <default_pmm_manager+0xdc0>
ffffffffc0204aac:	ee2fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204ab0:	57f1                	li	a5,-4
ffffffffc0204ab2:	b741                	j	ffffffffc0204a32 <do_pgfault+0x8a>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204ab4:	00003517          	auipc	a0,0x3
ffffffffc0204ab8:	61450513          	addi	a0,a0,1556 # ffffffffc02080c8 <default_pmm_manager+0xd50>
ffffffffc0204abc:	ed2fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204ac0:	57f1                	li	a5,-4
        goto failed;
ffffffffc0204ac2:	bf85                	j	ffffffffc0204a32 <do_pgfault+0x8a>

ffffffffc0204ac4 <user_mem_check>:

bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0204ac4:	7179                	addi	sp,sp,-48
ffffffffc0204ac6:	f022                	sd	s0,32(sp)
ffffffffc0204ac8:	f406                	sd	ra,40(sp)
ffffffffc0204aca:	ec26                	sd	s1,24(sp)
ffffffffc0204acc:	e84a                	sd	s2,16(sp)
ffffffffc0204ace:	e44e                	sd	s3,8(sp)
ffffffffc0204ad0:	e052                	sd	s4,0(sp)
ffffffffc0204ad2:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0204ad4:	c135                	beqz	a0,ffffffffc0204b38 <user_mem_check+0x74>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0204ad6:	002007b7          	lui	a5,0x200
ffffffffc0204ada:	04f5e663          	bltu	a1,a5,ffffffffc0204b26 <user_mem_check+0x62>
ffffffffc0204ade:	00c584b3          	add	s1,a1,a2
ffffffffc0204ae2:	0495f263          	bleu	s1,a1,ffffffffc0204b26 <user_mem_check+0x62>
ffffffffc0204ae6:	4785                	li	a5,1
ffffffffc0204ae8:	07fe                	slli	a5,a5,0x1f
ffffffffc0204aea:	0297ee63          	bltu	a5,s1,ffffffffc0204b26 <user_mem_check+0x62>
ffffffffc0204aee:	892a                	mv	s2,a0
ffffffffc0204af0:	89b6                	mv	s3,a3
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0204af2:	6a05                	lui	s4,0x1
ffffffffc0204af4:	a821                	j	ffffffffc0204b0c <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0204af6:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE)
ffffffffc0204afa:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0204afc:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0204afe:	c685                	beqz	a3,ffffffffc0204b26 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0204b00:	c399                	beqz	a5,ffffffffc0204b06 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0204b02:	02e46263          	bltu	s0,a4,ffffffffc0204b26 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204b06:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0204b08:	04947663          	bleu	s1,s0,ffffffffc0204b54 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc0204b0c:	85a2                	mv	a1,s0
ffffffffc0204b0e:	854a                	mv	a0,s2
ffffffffc0204b10:	e30ff0ef          	jal	ra,ffffffffc0204140 <find_vma>
ffffffffc0204b14:	c909                	beqz	a0,ffffffffc0204b26 <user_mem_check+0x62>
ffffffffc0204b16:	6518                	ld	a4,8(a0)
ffffffffc0204b18:	00e46763          	bltu	s0,a4,ffffffffc0204b26 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0204b1c:	4d1c                	lw	a5,24(a0)
ffffffffc0204b1e:	fc099ce3          	bnez	s3,ffffffffc0204af6 <user_mem_check+0x32>
ffffffffc0204b22:	8b85                	andi	a5,a5,1
ffffffffc0204b24:	f3ed                	bnez	a5,ffffffffc0204b06 <user_mem_check+0x42>
            return 0;
ffffffffc0204b26:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204b28:	70a2                	ld	ra,40(sp)
ffffffffc0204b2a:	7402                	ld	s0,32(sp)
ffffffffc0204b2c:	64e2                	ld	s1,24(sp)
ffffffffc0204b2e:	6942                	ld	s2,16(sp)
ffffffffc0204b30:	69a2                	ld	s3,8(sp)
ffffffffc0204b32:	6a02                	ld	s4,0(sp)
ffffffffc0204b34:	6145                	addi	sp,sp,48
ffffffffc0204b36:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204b38:	c02007b7          	lui	a5,0xc0200
ffffffffc0204b3c:	4501                	li	a0,0
ffffffffc0204b3e:	fef5e5e3          	bltu	a1,a5,ffffffffc0204b28 <user_mem_check+0x64>
ffffffffc0204b42:	962e                	add	a2,a2,a1
ffffffffc0204b44:	fec5f2e3          	bleu	a2,a1,ffffffffc0204b28 <user_mem_check+0x64>
ffffffffc0204b48:	c8000537          	lui	a0,0xc8000
ffffffffc0204b4c:	0505                	addi	a0,a0,1
ffffffffc0204b4e:	00a63533          	sltu	a0,a2,a0
ffffffffc0204b52:	bfd9                	j	ffffffffc0204b28 <user_mem_check+0x64>
        return 1;
ffffffffc0204b54:	4505                	li	a0,1
ffffffffc0204b56:	bfc9                	j	ffffffffc0204b28 <user_mem_check+0x64>

ffffffffc0204b58 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204b58:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b5a:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204b5c:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b5e:	aa1fb0ef          	jal	ra,ffffffffc02005fe <ide_device_valid>
ffffffffc0204b62:	cd01                	beqz	a0,ffffffffc0204b7a <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b64:	4505                	li	a0,1
ffffffffc0204b66:	a9ffb0ef          	jal	ra,ffffffffc0200604 <ide_device_size>
}
ffffffffc0204b6a:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b6c:	810d                	srli	a0,a0,0x3
ffffffffc0204b6e:	000a8797          	auipc	a5,0xa8
ffffffffc0204b72:	b0a7b523          	sd	a0,-1270(a5) # ffffffffc02ac678 <max_swap_offset>
}
ffffffffc0204b76:	0141                	addi	sp,sp,16
ffffffffc0204b78:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204b7a:	00004617          	auipc	a2,0x4
ffffffffc0204b7e:	8c660613          	addi	a2,a2,-1850 # ffffffffc0208440 <default_pmm_manager+0x10c8>
ffffffffc0204b82:	45b5                	li	a1,13
ffffffffc0204b84:	00004517          	auipc	a0,0x4
ffffffffc0204b88:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0208460 <default_pmm_manager+0x10e8>
ffffffffc0204b8c:	8f9fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204b90 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204b90:	1141                	addi	sp,sp,-16
ffffffffc0204b92:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b94:	00855793          	srli	a5,a0,0x8
ffffffffc0204b98:	cfb9                	beqz	a5,ffffffffc0204bf6 <swapfs_read+0x66>
ffffffffc0204b9a:	000a8717          	auipc	a4,0xa8
ffffffffc0204b9e:	ade70713          	addi	a4,a4,-1314 # ffffffffc02ac678 <max_swap_offset>
ffffffffc0204ba2:	6318                	ld	a4,0(a4)
ffffffffc0204ba4:	04e7f963          	bleu	a4,a5,ffffffffc0204bf6 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204ba8:	000a8717          	auipc	a4,0xa8
ffffffffc0204bac:	a4070713          	addi	a4,a4,-1472 # ffffffffc02ac5e8 <pages>
ffffffffc0204bb0:	6310                	ld	a2,0(a4)
ffffffffc0204bb2:	00004717          	auipc	a4,0x4
ffffffffc0204bb6:	20670713          	addi	a4,a4,518 # ffffffffc0208db8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204bba:	000a8697          	auipc	a3,0xa8
ffffffffc0204bbe:	9be68693          	addi	a3,a3,-1602 # ffffffffc02ac578 <npage>
    return page - pages + nbase;
ffffffffc0204bc2:	40c58633          	sub	a2,a1,a2
ffffffffc0204bc6:	630c                	ld	a1,0(a4)
ffffffffc0204bc8:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204bca:	577d                	li	a4,-1
ffffffffc0204bcc:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204bce:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204bd0:	8331                	srli	a4,a4,0xc
ffffffffc0204bd2:	8f71                	and	a4,a4,a2
ffffffffc0204bd4:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204bd8:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204bda:	02d77a63          	bleu	a3,a4,ffffffffc0204c0e <swapfs_read+0x7e>
ffffffffc0204bde:	000a8797          	auipc	a5,0xa8
ffffffffc0204be2:	9fa78793          	addi	a5,a5,-1542 # ffffffffc02ac5d8 <va_pa_offset>
ffffffffc0204be6:	639c                	ld	a5,0(a5)
}
ffffffffc0204be8:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bea:	46a1                	li	a3,8
ffffffffc0204bec:	963e                	add	a2,a2,a5
ffffffffc0204bee:	4505                	li	a0,1
}
ffffffffc0204bf0:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bf2:	a19fb06f          	j	ffffffffc020060a <ide_read_secs>
ffffffffc0204bf6:	86aa                	mv	a3,a0
ffffffffc0204bf8:	00004617          	auipc	a2,0x4
ffffffffc0204bfc:	88060613          	addi	a2,a2,-1920 # ffffffffc0208478 <default_pmm_manager+0x1100>
ffffffffc0204c00:	45d1                	li	a1,20
ffffffffc0204c02:	00004517          	auipc	a0,0x4
ffffffffc0204c06:	85e50513          	addi	a0,a0,-1954 # ffffffffc0208460 <default_pmm_manager+0x10e8>
ffffffffc0204c0a:	87bfb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0204c0e:	86b2                	mv	a3,a2
ffffffffc0204c10:	06900593          	li	a1,105
ffffffffc0204c14:	00002617          	auipc	a2,0x2
ffffffffc0204c18:	7b460613          	addi	a2,a2,1972 # ffffffffc02073c8 <default_pmm_manager+0x50>
ffffffffc0204c1c:	00002517          	auipc	a0,0x2
ffffffffc0204c20:	7d450513          	addi	a0,a0,2004 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc0204c24:	861fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204c28 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204c28:	1141                	addi	sp,sp,-16
ffffffffc0204c2a:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c2c:	00855793          	srli	a5,a0,0x8
ffffffffc0204c30:	cfb9                	beqz	a5,ffffffffc0204c8e <swapfs_write+0x66>
ffffffffc0204c32:	000a8717          	auipc	a4,0xa8
ffffffffc0204c36:	a4670713          	addi	a4,a4,-1466 # ffffffffc02ac678 <max_swap_offset>
ffffffffc0204c3a:	6318                	ld	a4,0(a4)
ffffffffc0204c3c:	04e7f963          	bleu	a4,a5,ffffffffc0204c8e <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204c40:	000a8717          	auipc	a4,0xa8
ffffffffc0204c44:	9a870713          	addi	a4,a4,-1624 # ffffffffc02ac5e8 <pages>
ffffffffc0204c48:	6310                	ld	a2,0(a4)
ffffffffc0204c4a:	00004717          	auipc	a4,0x4
ffffffffc0204c4e:	16e70713          	addi	a4,a4,366 # ffffffffc0208db8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204c52:	000a8697          	auipc	a3,0xa8
ffffffffc0204c56:	92668693          	addi	a3,a3,-1754 # ffffffffc02ac578 <npage>
    return page - pages + nbase;
ffffffffc0204c5a:	40c58633          	sub	a2,a1,a2
ffffffffc0204c5e:	630c                	ld	a1,0(a4)
ffffffffc0204c60:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204c62:	577d                	li	a4,-1
ffffffffc0204c64:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204c66:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204c68:	8331                	srli	a4,a4,0xc
ffffffffc0204c6a:	8f71                	and	a4,a4,a2
ffffffffc0204c6c:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c70:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c72:	02d77a63          	bleu	a3,a4,ffffffffc0204ca6 <swapfs_write+0x7e>
ffffffffc0204c76:	000a8797          	auipc	a5,0xa8
ffffffffc0204c7a:	96278793          	addi	a5,a5,-1694 # ffffffffc02ac5d8 <va_pa_offset>
ffffffffc0204c7e:	639c                	ld	a5,0(a5)
}
ffffffffc0204c80:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c82:	46a1                	li	a3,8
ffffffffc0204c84:	963e                	add	a2,a2,a5
ffffffffc0204c86:	4505                	li	a0,1
}
ffffffffc0204c88:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c8a:	9a5fb06f          	j	ffffffffc020062e <ide_write_secs>
ffffffffc0204c8e:	86aa                	mv	a3,a0
ffffffffc0204c90:	00003617          	auipc	a2,0x3
ffffffffc0204c94:	7e860613          	addi	a2,a2,2024 # ffffffffc0208478 <default_pmm_manager+0x1100>
ffffffffc0204c98:	45e5                	li	a1,25
ffffffffc0204c9a:	00003517          	auipc	a0,0x3
ffffffffc0204c9e:	7c650513          	addi	a0,a0,1990 # ffffffffc0208460 <default_pmm_manager+0x10e8>
ffffffffc0204ca2:	fe2fb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0204ca6:	86b2                	mv	a3,a2
ffffffffc0204ca8:	06900593          	li	a1,105
ffffffffc0204cac:	00002617          	auipc	a2,0x2
ffffffffc0204cb0:	71c60613          	addi	a2,a2,1820 # ffffffffc02073c8 <default_pmm_manager+0x50>
ffffffffc0204cb4:	00002517          	auipc	a0,0x2
ffffffffc0204cb8:	73c50513          	addi	a0,a0,1852 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc0204cbc:	fc8fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204cc0 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204cc0:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204cc2:	9402                	jalr	s0

	jal do_exit
ffffffffc0204cc4:	726000ef          	jal	ra,ffffffffc02053ea <do_exit>

ffffffffc0204cc8 <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0204cc8:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204cca:	10800513          	li	a0,264
{
ffffffffc0204cce:	e022                	sd	s0,0(sp)
ffffffffc0204cd0:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204cd2:	f85fc0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc0204cd6:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0204cd8:	c939                	beqz	a0,ffffffffc0204d2e <alloc_proc+0x66>
         *       struct trapframe *tf;                       // Trap frame for current interrupt
         *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
         *       uint32_t flags;                             // Process flag
         *       char name[PROC_NAME_LEN + 1];               // Process name
         */
        proc->state = PROC_UNINIT; // 设置进程为初始态
ffffffffc0204cda:	57fd                	li	a5,-1
ffffffffc0204cdc:	1782                	slli	a5,a5,0x20
ffffffffc0204cde:	e11c                	sd	a5,0(a0)
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204ce0:	07000613          	li	a2,112
ffffffffc0204ce4:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc0204ce6:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0204cea:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204cee:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204cf2:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204cf6:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204cfa:	03050513          	addi	a0,a0,48
ffffffffc0204cfe:	117010ef          	jal	ra,ffffffffc0206614 <memset>
        proc->tf = NULL;
        proc->cr3 = boot_cr3; // 使用内核页目录表的基址
ffffffffc0204d02:	000a8797          	auipc	a5,0xa8
ffffffffc0204d06:	8de78793          	addi	a5,a5,-1826 # ffffffffc02ac5e0 <boot_cr3>
ffffffffc0204d0a:	639c                	ld	a5,0(a5)
        proc->tf = NULL;
ffffffffc0204d0c:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc0204d10:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3; // 使用内核页目录表的基址
ffffffffc0204d14:	f45c                	sd	a5,168(s0)
        memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0204d16:	463d                	li	a2,15
ffffffffc0204d18:	4581                	li	a1,0
ffffffffc0204d1a:	0b440513          	addi	a0,s0,180
ffffffffc0204d1e:	0f7010ef          	jal	ra,ffffffffc0206614 <memset>
        /*
         * below fields(add in LAB5) in proc_struct need to be initialized
         *       uint32_t wait_state;                        // waiting state
         *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
         */
        proc->wait_state = 0;                        // PCB新增的条目，初始化进程等待状态
ffffffffc0204d22:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->yptr = proc->cptr = NULL; // 设置指针为空
ffffffffc0204d26:	0e043823          	sd	zero,240(s0)
ffffffffc0204d2a:	0e043c23          	sd	zero,248(s0)
        // ffang：这两行代码主要是初始化进程等待状态、和进程的相关指针，例如父进程、子进程、同胞等等。
        // 其中的wait_state是进程控制块中新增的条目。避免之后由于未定义或未初始化导致管理用户进程时出现错误。
    }
    return proc;
}
ffffffffc0204d2e:	8522                	mv	a0,s0
ffffffffc0204d30:	60a2                	ld	ra,8(sp)
ffffffffc0204d32:	6402                	ld	s0,0(sp)
ffffffffc0204d34:	0141                	addi	sp,sp,16
ffffffffc0204d36:	8082                	ret

ffffffffc0204d38 <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0204d38:	000a8797          	auipc	a5,0xa8
ffffffffc0204d3c:	85878793          	addi	a5,a5,-1960 # ffffffffc02ac590 <current>
ffffffffc0204d40:	639c                	ld	a5,0(a5)
ffffffffc0204d42:	73c8                	ld	a0,160(a5)
ffffffffc0204d44:	866fc06f          	j	ffffffffc0200daa <forkrets>

ffffffffc0204d48 <user_main>:
// user_main - kernel thread used to exec a user program
static int
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d48:	000a8797          	auipc	a5,0xa8
ffffffffc0204d4c:	84878793          	addi	a5,a5,-1976 # ffffffffc02ac590 <current>
ffffffffc0204d50:	639c                	ld	a5,0(a5)
{
ffffffffc0204d52:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d54:	00004617          	auipc	a2,0x4
ffffffffc0204d58:	b3460613          	addi	a2,a2,-1228 # ffffffffc0208888 <default_pmm_manager+0x1510>
ffffffffc0204d5c:	43cc                	lw	a1,4(a5)
ffffffffc0204d5e:	00004517          	auipc	a0,0x4
ffffffffc0204d62:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0208898 <default_pmm_manager+0x1520>
{
ffffffffc0204d66:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d68:	c26fb0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0204d6c:	00004797          	auipc	a5,0x4
ffffffffc0204d70:	b1c78793          	addi	a5,a5,-1252 # ffffffffc0208888 <default_pmm_manager+0x1510>
ffffffffc0204d74:	3fe05717          	auipc	a4,0x3fe05
ffffffffc0204d78:	57470713          	addi	a4,a4,1396 # a2e8 <_binary_obj___user_forktest_out_size>
ffffffffc0204d7c:	e43a                	sd	a4,8(sp)
    int64_t ret = 0, len = strlen(name);
ffffffffc0204d7e:	853e                	mv	a0,a5
ffffffffc0204d80:	00043717          	auipc	a4,0x43
ffffffffc0204d84:	32070713          	addi	a4,a4,800 # ffffffffc02480a0 <_binary_obj___user_forktest_out_start>
ffffffffc0204d88:	f03a                	sd	a4,32(sp)
ffffffffc0204d8a:	f43e                	sd	a5,40(sp)
ffffffffc0204d8c:	e802                	sd	zero,16(sp)
ffffffffc0204d8e:	7e8010ef          	jal	ra,ffffffffc0206576 <strlen>
ffffffffc0204d92:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204d94:	4511                	li	a0,4
ffffffffc0204d96:	55a2                	lw	a1,40(sp)
ffffffffc0204d98:	4662                	lw	a2,24(sp)
ffffffffc0204d9a:	5682                	lw	a3,32(sp)
ffffffffc0204d9c:	4722                	lw	a4,8(sp)
ffffffffc0204d9e:	48a9                	li	a7,10
ffffffffc0204da0:	9002                	ebreak
ffffffffc0204da2:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204da4:	65c2                	ld	a1,16(sp)
ffffffffc0204da6:	00004517          	auipc	a0,0x4
ffffffffc0204daa:	b1a50513          	addi	a0,a0,-1254 # ffffffffc02088c0 <default_pmm_manager+0x1548>
ffffffffc0204dae:	be0fb0ef          	jal	ra,ffffffffc020018e <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204db2:	00004617          	auipc	a2,0x4
ffffffffc0204db6:	b1e60613          	addi	a2,a2,-1250 # ffffffffc02088d0 <default_pmm_manager+0x1558>
ffffffffc0204dba:	3c500593          	li	a1,965
ffffffffc0204dbe:	00004517          	auipc	a0,0x4
ffffffffc0204dc2:	b3250513          	addi	a0,a0,-1230 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc0204dc6:	ebefb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204dca <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204dca:	6d14                	ld	a3,24(a0)
{
ffffffffc0204dcc:	1141                	addi	sp,sp,-16
ffffffffc0204dce:	e406                	sd	ra,8(sp)
ffffffffc0204dd0:	c02007b7          	lui	a5,0xc0200
ffffffffc0204dd4:	04f6e263          	bltu	a3,a5,ffffffffc0204e18 <put_pgdir+0x4e>
ffffffffc0204dd8:	000a8797          	auipc	a5,0xa8
ffffffffc0204ddc:	80078793          	addi	a5,a5,-2048 # ffffffffc02ac5d8 <va_pa_offset>
ffffffffc0204de0:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204de2:	000a7797          	auipc	a5,0xa7
ffffffffc0204de6:	79678793          	addi	a5,a5,1942 # ffffffffc02ac578 <npage>
ffffffffc0204dea:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204dec:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204dee:	82b1                	srli	a3,a3,0xc
ffffffffc0204df0:	04f6f063          	bleu	a5,a3,ffffffffc0204e30 <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204df4:	00004797          	auipc	a5,0x4
ffffffffc0204df8:	fc478793          	addi	a5,a5,-60 # ffffffffc0208db8 <nbase>
ffffffffc0204dfc:	639c                	ld	a5,0(a5)
ffffffffc0204dfe:	000a7717          	auipc	a4,0xa7
ffffffffc0204e02:	7ea70713          	addi	a4,a4,2026 # ffffffffc02ac5e8 <pages>
ffffffffc0204e06:	6308                	ld	a0,0(a4)
}
ffffffffc0204e08:	60a2                	ld	ra,8(sp)
ffffffffc0204e0a:	8e9d                	sub	a3,a3,a5
ffffffffc0204e0c:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204e0e:	4585                	li	a1,1
ffffffffc0204e10:	9536                	add	a0,a0,a3
}
ffffffffc0204e12:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204e14:	8c6fd06f          	j	ffffffffc0201eda <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204e18:	00002617          	auipc	a2,0x2
ffffffffc0204e1c:	5e860613          	addi	a2,a2,1512 # ffffffffc0207400 <default_pmm_manager+0x88>
ffffffffc0204e20:	06e00593          	li	a1,110
ffffffffc0204e24:	00002517          	auipc	a0,0x2
ffffffffc0204e28:	5cc50513          	addi	a0,a0,1484 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc0204e2c:	e58fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204e30:	00002617          	auipc	a2,0x2
ffffffffc0204e34:	5f860613          	addi	a2,a2,1528 # ffffffffc0207428 <default_pmm_manager+0xb0>
ffffffffc0204e38:	06200593          	li	a1,98
ffffffffc0204e3c:	00002517          	auipc	a0,0x2
ffffffffc0204e40:	5b450513          	addi	a0,a0,1460 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc0204e44:	e40fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204e48 <setup_pgdir>:
{
ffffffffc0204e48:	1101                	addi	sp,sp,-32
ffffffffc0204e4a:	e426                	sd	s1,8(sp)
ffffffffc0204e4c:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL)
ffffffffc0204e4e:	4505                	li	a0,1
{
ffffffffc0204e50:	ec06                	sd	ra,24(sp)
ffffffffc0204e52:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL)
ffffffffc0204e54:	ffffc0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0204e58:	c125                	beqz	a0,ffffffffc0204eb8 <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204e5a:	000a7797          	auipc	a5,0xa7
ffffffffc0204e5e:	78e78793          	addi	a5,a5,1934 # ffffffffc02ac5e8 <pages>
ffffffffc0204e62:	6394                	ld	a3,0(a5)
ffffffffc0204e64:	00004797          	auipc	a5,0x4
ffffffffc0204e68:	f5478793          	addi	a5,a5,-172 # ffffffffc0208db8 <nbase>
ffffffffc0204e6c:	6380                	ld	s0,0(a5)
ffffffffc0204e6e:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204e72:	000a7717          	auipc	a4,0xa7
ffffffffc0204e76:	70670713          	addi	a4,a4,1798 # ffffffffc02ac578 <npage>
    return page - pages + nbase;
ffffffffc0204e7a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204e7c:	57fd                	li	a5,-1
ffffffffc0204e7e:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204e80:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204e82:	83b1                	srli	a5,a5,0xc
ffffffffc0204e84:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e86:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e88:	02e7fa63          	bleu	a4,a5,ffffffffc0204ebc <setup_pgdir+0x74>
ffffffffc0204e8c:	000a7797          	auipc	a5,0xa7
ffffffffc0204e90:	74c78793          	addi	a5,a5,1868 # ffffffffc02ac5d8 <va_pa_offset>
ffffffffc0204e94:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204e96:	000a7797          	auipc	a5,0xa7
ffffffffc0204e9a:	6da78793          	addi	a5,a5,1754 # ffffffffc02ac570 <boot_pgdir>
ffffffffc0204e9e:	638c                	ld	a1,0(a5)
ffffffffc0204ea0:	9436                	add	s0,s0,a3
ffffffffc0204ea2:	6605                	lui	a2,0x1
ffffffffc0204ea4:	8522                	mv	a0,s0
ffffffffc0204ea6:	780010ef          	jal	ra,ffffffffc0206626 <memcpy>
    return 0;
ffffffffc0204eaa:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0204eac:	ec80                	sd	s0,24(s1)
}
ffffffffc0204eae:	60e2                	ld	ra,24(sp)
ffffffffc0204eb0:	6442                	ld	s0,16(sp)
ffffffffc0204eb2:	64a2                	ld	s1,8(sp)
ffffffffc0204eb4:	6105                	addi	sp,sp,32
ffffffffc0204eb6:	8082                	ret
        return -E_NO_MEM;
ffffffffc0204eb8:	5571                	li	a0,-4
ffffffffc0204eba:	bfd5                	j	ffffffffc0204eae <setup_pgdir+0x66>
ffffffffc0204ebc:	00002617          	auipc	a2,0x2
ffffffffc0204ec0:	50c60613          	addi	a2,a2,1292 # ffffffffc02073c8 <default_pmm_manager+0x50>
ffffffffc0204ec4:	06900593          	li	a1,105
ffffffffc0204ec8:	00002517          	auipc	a0,0x2
ffffffffc0204ecc:	52850513          	addi	a0,a0,1320 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc0204ed0:	db4fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204ed4 <set_proc_name>:
{
ffffffffc0204ed4:	1101                	addi	sp,sp,-32
ffffffffc0204ed6:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ed8:	0b450413          	addi	s0,a0,180
{
ffffffffc0204edc:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ede:	4641                	li	a2,16
{
ffffffffc0204ee0:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ee2:	8522                	mv	a0,s0
ffffffffc0204ee4:	4581                	li	a1,0
{
ffffffffc0204ee6:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ee8:	72c010ef          	jal	ra,ffffffffc0206614 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204eec:	8522                	mv	a0,s0
}
ffffffffc0204eee:	6442                	ld	s0,16(sp)
ffffffffc0204ef0:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ef2:	85a6                	mv	a1,s1
}
ffffffffc0204ef4:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ef6:	463d                	li	a2,15
}
ffffffffc0204ef8:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204efa:	72c0106f          	j	ffffffffc0206626 <memcpy>

ffffffffc0204efe <proc_run>:
{
ffffffffc0204efe:	1101                	addi	sp,sp,-32
    if (proc != current)
ffffffffc0204f00:	000a7797          	auipc	a5,0xa7
ffffffffc0204f04:	69078793          	addi	a5,a5,1680 # ffffffffc02ac590 <current>
{
ffffffffc0204f08:	e426                	sd	s1,8(sp)
    if (proc != current)
ffffffffc0204f0a:	6384                	ld	s1,0(a5)
{
ffffffffc0204f0c:	ec06                	sd	ra,24(sp)
ffffffffc0204f0e:	e822                	sd	s0,16(sp)
ffffffffc0204f10:	e04a                	sd	s2,0(sp)
    if (proc != current)
ffffffffc0204f12:	02a48b63          	beq	s1,a0,ffffffffc0204f48 <proc_run+0x4a>
ffffffffc0204f16:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f18:	100027f3          	csrr	a5,sstatus
ffffffffc0204f1c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f1e:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f20:	e3a9                	bnez	a5,ffffffffc0204f62 <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204f22:	745c                	ld	a5,168(s0)
            current = proc;
ffffffffc0204f24:	000a7717          	auipc	a4,0xa7
ffffffffc0204f28:	66873623          	sd	s0,1644(a4) # ffffffffc02ac590 <current>
ffffffffc0204f2c:	577d                	li	a4,-1
ffffffffc0204f2e:	177e                	slli	a4,a4,0x3f
ffffffffc0204f30:	83b1                	srli	a5,a5,0xc
ffffffffc0204f32:	8fd9                	or	a5,a5,a4
ffffffffc0204f34:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0204f38:	03040593          	addi	a1,s0,48
ffffffffc0204f3c:	03048513          	addi	a0,s1,48
ffffffffc0204f40:	7cb000ef          	jal	ra,ffffffffc0205f0a <switch_to>
    if (flag) {
ffffffffc0204f44:	00091863          	bnez	s2,ffffffffc0204f54 <proc_run+0x56>
}
ffffffffc0204f48:	60e2                	ld	ra,24(sp)
ffffffffc0204f4a:	6442                	ld	s0,16(sp)
ffffffffc0204f4c:	64a2                	ld	s1,8(sp)
ffffffffc0204f4e:	6902                	ld	s2,0(sp)
ffffffffc0204f50:	6105                	addi	sp,sp,32
ffffffffc0204f52:	8082                	ret
ffffffffc0204f54:	6442                	ld	s0,16(sp)
ffffffffc0204f56:	60e2                	ld	ra,24(sp)
ffffffffc0204f58:	64a2                	ld	s1,8(sp)
ffffffffc0204f5a:	6902                	ld	s2,0(sp)
ffffffffc0204f5c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204f5e:	ef6fb06f          	j	ffffffffc0200654 <intr_enable>
        intr_disable();
ffffffffc0204f62:	ef8fb0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0204f66:	4905                	li	s2,1
ffffffffc0204f68:	bf6d                	j	ffffffffc0204f22 <proc_run+0x24>

ffffffffc0204f6a <find_proc>:
    if (0 < pid && pid < MAX_PID)
ffffffffc0204f6a:	0005071b          	sext.w	a4,a0
ffffffffc0204f6e:	6789                	lui	a5,0x2
ffffffffc0204f70:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204f74:	17f9                	addi	a5,a5,-2
ffffffffc0204f76:	04d7e063          	bltu	a5,a3,ffffffffc0204fb6 <find_proc+0x4c>
{
ffffffffc0204f7a:	1141                	addi	sp,sp,-16
ffffffffc0204f7c:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f7e:	45a9                	li	a1,10
ffffffffc0204f80:	842a                	mv	s0,a0
ffffffffc0204f82:	853a                	mv	a0,a4
{
ffffffffc0204f84:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f86:	1e0010ef          	jal	ra,ffffffffc0206166 <hash32>
ffffffffc0204f8a:	02051693          	slli	a3,a0,0x20
ffffffffc0204f8e:	82f1                	srli	a3,a3,0x1c
ffffffffc0204f90:	000a3517          	auipc	a0,0xa3
ffffffffc0204f94:	5c850513          	addi	a0,a0,1480 # ffffffffc02a8558 <hash_list>
ffffffffc0204f98:	96aa                	add	a3,a3,a0
ffffffffc0204f9a:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0204f9c:	a029                	j	ffffffffc0204fa6 <find_proc+0x3c>
            if (proc->pid == pid)
ffffffffc0204f9e:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7654>
ffffffffc0204fa2:	00870c63          	beq	a4,s0,ffffffffc0204fba <find_proc+0x50>
ffffffffc0204fa6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204fa8:	fef69be3          	bne	a3,a5,ffffffffc0204f9e <find_proc+0x34>
}
ffffffffc0204fac:	60a2                	ld	ra,8(sp)
ffffffffc0204fae:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0204fb0:	4501                	li	a0,0
}
ffffffffc0204fb2:	0141                	addi	sp,sp,16
ffffffffc0204fb4:	8082                	ret
    return NULL;
ffffffffc0204fb6:	4501                	li	a0,0
}
ffffffffc0204fb8:	8082                	ret
ffffffffc0204fba:	60a2                	ld	ra,8(sp)
ffffffffc0204fbc:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204fbe:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204fc2:	0141                	addi	sp,sp,16
ffffffffc0204fc4:	8082                	ret

ffffffffc0204fc6 <do_fork>:
{
ffffffffc0204fc6:	7159                	addi	sp,sp,-112
ffffffffc0204fc8:	eca6                	sd	s1,88(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0204fca:	000a7497          	auipc	s1,0xa7
ffffffffc0204fce:	5de48493          	addi	s1,s1,1502 # ffffffffc02ac5a8 <nr_process>
ffffffffc0204fd2:	4098                	lw	a4,0(s1)
{
ffffffffc0204fd4:	f486                	sd	ra,104(sp)
ffffffffc0204fd6:	f0a2                	sd	s0,96(sp)
ffffffffc0204fd8:	e8ca                	sd	s2,80(sp)
ffffffffc0204fda:	e4ce                	sd	s3,72(sp)
ffffffffc0204fdc:	e0d2                	sd	s4,64(sp)
ffffffffc0204fde:	fc56                	sd	s5,56(sp)
ffffffffc0204fe0:	f85a                	sd	s6,48(sp)
ffffffffc0204fe2:	f45e                	sd	s7,40(sp)
ffffffffc0204fe4:	f062                	sd	s8,32(sp)
ffffffffc0204fe6:	ec66                	sd	s9,24(sp)
ffffffffc0204fe8:	e86a                	sd	s10,16(sp)
ffffffffc0204fea:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0204fec:	6785                	lui	a5,0x1
ffffffffc0204fee:	30f75363          	ble	a5,a4,ffffffffc02052f4 <do_fork+0x32e>
ffffffffc0204ff2:	892a                	mv	s2,a0
ffffffffc0204ff4:	8a2e                	mv	s4,a1
ffffffffc0204ff6:	8432                	mv	s0,a2
    proc = alloc_proc(); // 本质上是用kmlloc函数分配了一块内存空间，然后将proc指向这块内存空间
ffffffffc0204ff8:	cd1ff0ef          	jal	ra,ffffffffc0204cc8 <alloc_proc>
ffffffffc0204ffc:	8baa                	mv	s7,a0
    if (proc == NULL)
ffffffffc0204ffe:	2e050d63          	beqz	a0,ffffffffc02052f8 <do_fork+0x332>
    proc->parent = current;           // 将子进程的父进程设置为当前进程
ffffffffc0205002:	000a7c17          	auipc	s8,0xa7
ffffffffc0205006:	58ec0c13          	addi	s8,s8,1422 # ffffffffc02ac590 <current>
ffffffffc020500a:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0); // 确保进程在等待（确保当前进程的wait_state为0）
ffffffffc020500e:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8494>
    proc->parent = current;           // 将子进程的父进程设置为当前进程
ffffffffc0205012:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0); // 确保进程在等待（确保当前进程的wait_state为0）
ffffffffc0205014:	30071263          	bnez	a4,ffffffffc0205318 <do_fork+0x352>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0205018:	4509                	li	a0,2
ffffffffc020501a:	e39fc0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
    if (page != NULL)
ffffffffc020501e:	2c050963          	beqz	a0,ffffffffc02052f0 <do_fork+0x32a>
    return page - pages + nbase;
ffffffffc0205022:	000a7997          	auipc	s3,0xa7
ffffffffc0205026:	5c698993          	addi	s3,s3,1478 # ffffffffc02ac5e8 <pages>
ffffffffc020502a:	0009b683          	ld	a3,0(s3)
ffffffffc020502e:	00004a97          	auipc	s5,0x4
ffffffffc0205032:	d8aa8a93          	addi	s5,s5,-630 # ffffffffc0208db8 <nbase>
ffffffffc0205036:	000ab783          	ld	a5,0(s5)
ffffffffc020503a:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc020503e:	000a7b17          	auipc	s6,0xa7
ffffffffc0205042:	53ab0b13          	addi	s6,s6,1338 # ffffffffc02ac578 <npage>
    return page - pages + nbase;
ffffffffc0205046:	8699                	srai	a3,a3,0x6
ffffffffc0205048:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020504a:	000b3703          	ld	a4,0(s6)
ffffffffc020504e:	57fd                	li	a5,-1
ffffffffc0205050:	83b1                	srli	a5,a5,0xc
ffffffffc0205052:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205054:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205056:	2ae7f563          	bleu	a4,a5,ffffffffc0205300 <do_fork+0x33a>
ffffffffc020505a:	000a7d97          	auipc	s11,0xa7
ffffffffc020505e:	57ed8d93          	addi	s11,s11,1406 # ffffffffc02ac5d8 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0205062:	000c3703          	ld	a4,0(s8)
ffffffffc0205066:	000db783          	ld	a5,0(s11)
ffffffffc020506a:	02873c03          	ld	s8,40(a4)
ffffffffc020506e:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0205070:	00dbb823          	sd	a3,16(s7)
    if (oldmm == NULL)
ffffffffc0205074:	020c0a63          	beqz	s8,ffffffffc02050a8 <do_fork+0xe2>
    if (clone_flags & CLONE_VM)
ffffffffc0205078:	10097913          	andi	s2,s2,256
ffffffffc020507c:	1a090a63          	beqz	s2,ffffffffc0205230 <do_fork+0x26a>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0205080:	030c2703          	lw	a4,48(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205084:	018c3783          	ld	a5,24(s8)
ffffffffc0205088:	c02006b7          	lui	a3,0xc0200
ffffffffc020508c:	2705                	addiw	a4,a4,1
ffffffffc020508e:	02ec2823          	sw	a4,48(s8)
    proc->mm = mm;
ffffffffc0205092:	038bb423          	sd	s8,40(s7)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205096:	2ad7e163          	bltu	a5,a3,ffffffffc0205338 <do_fork+0x372>
ffffffffc020509a:	000db703          	ld	a4,0(s11)
ffffffffc020509e:	010bb683          	ld	a3,16(s7)
ffffffffc02050a2:	8f99                	sub	a5,a5,a4
ffffffffc02050a4:	0afbb423          	sd	a5,168(s7)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02050a8:	6789                	lui	a5,0x2
ffffffffc02050aa:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76a0>
ffffffffc02050ae:	96be                	add	a3,a3,a5
ffffffffc02050b0:	0adbb023          	sd	a3,160(s7)
    *(proc->tf) = *tf;
ffffffffc02050b4:	87b6                	mv	a5,a3
ffffffffc02050b6:	12040813          	addi	a6,s0,288
ffffffffc02050ba:	6008                	ld	a0,0(s0)
ffffffffc02050bc:	640c                	ld	a1,8(s0)
ffffffffc02050be:	6810                	ld	a2,16(s0)
ffffffffc02050c0:	6c18                	ld	a4,24(s0)
ffffffffc02050c2:	e388                	sd	a0,0(a5)
ffffffffc02050c4:	e78c                	sd	a1,8(a5)
ffffffffc02050c6:	eb90                	sd	a2,16(a5)
ffffffffc02050c8:	ef98                	sd	a4,24(a5)
ffffffffc02050ca:	02040413          	addi	s0,s0,32
ffffffffc02050ce:	02078793          	addi	a5,a5,32
ffffffffc02050d2:	ff0414e3          	bne	s0,a6,ffffffffc02050ba <do_fork+0xf4>
    proc->tf->gpr.a0 = 0;
ffffffffc02050d6:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02050da:	140a0963          	beqz	s4,ffffffffc020522c <do_fork+0x266>
ffffffffc02050de:	0146b823          	sd	s4,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02050e2:	00000797          	auipc	a5,0x0
ffffffffc02050e6:	c5678793          	addi	a5,a5,-938 # ffffffffc0204d38 <forkret>
ffffffffc02050ea:	02fbb823          	sd	a5,48(s7)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02050ee:	02dbbc23          	sd	a3,56(s7)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050f2:	100027f3          	csrr	a5,sstatus
ffffffffc02050f6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02050f8:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050fa:	1a079763          	bnez	a5,ffffffffc02052a8 <do_fork+0x2e2>
    if (++last_pid >= MAX_PID)
ffffffffc02050fe:	0009c797          	auipc	a5,0x9c
ffffffffc0205102:	05278793          	addi	a5,a5,82 # ffffffffc02a1150 <last_pid.1691>
ffffffffc0205106:	439c                	lw	a5,0(a5)
ffffffffc0205108:	6709                	lui	a4,0x2
ffffffffc020510a:	0017851b          	addiw	a0,a5,1
ffffffffc020510e:	0009c697          	auipc	a3,0x9c
ffffffffc0205112:	04a6a123          	sw	a0,66(a3) # ffffffffc02a1150 <last_pid.1691>
ffffffffc0205116:	16e55a63          	ble	a4,a0,ffffffffc020528a <do_fork+0x2c4>
    if (last_pid >= next_safe)
ffffffffc020511a:	0009c797          	auipc	a5,0x9c
ffffffffc020511e:	03a78793          	addi	a5,a5,58 # ffffffffc02a1154 <next_safe.1690>
ffffffffc0205122:	439c                	lw	a5,0(a5)
ffffffffc0205124:	000a7597          	auipc	a1,0xa7
ffffffffc0205128:	5ac58593          	addi	a1,a1,1452 # ffffffffc02ac6d0 <proc_list>
ffffffffc020512c:	06f54163          	blt	a0,a5,ffffffffc020518e <do_fork+0x1c8>
        next_safe = MAX_PID;
ffffffffc0205130:	6789                	lui	a5,0x2
ffffffffc0205132:	0009c717          	auipc	a4,0x9c
ffffffffc0205136:	02f72123          	sw	a5,34(a4) # ffffffffc02a1154 <next_safe.1690>
ffffffffc020513a:	4801                	li	a6,0
ffffffffc020513c:	87aa                	mv	a5,a0
ffffffffc020513e:	000a7597          	auipc	a1,0xa7
ffffffffc0205142:	59258593          	addi	a1,a1,1426 # ffffffffc02ac6d0 <proc_list>
    repeat:
ffffffffc0205146:	6309                	lui	t1,0x2
ffffffffc0205148:	88c2                	mv	a7,a6
ffffffffc020514a:	6609                	lui	a2,0x2
        le = list;
ffffffffc020514c:	000a7697          	auipc	a3,0xa7
ffffffffc0205150:	58468693          	addi	a3,a3,1412 # ffffffffc02ac6d0 <proc_list>
ffffffffc0205154:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list)
ffffffffc0205156:	00b68f63          	beq	a3,a1,ffffffffc0205174 <do_fork+0x1ae>
            if (proc->pid == last_pid)
ffffffffc020515a:	f3c6a703          	lw	a4,-196(a3)
ffffffffc020515e:	0ce78263          	beq	a5,a4,ffffffffc0205222 <do_fork+0x25c>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0205162:	fee7d9e3          	ble	a4,a5,ffffffffc0205154 <do_fork+0x18e>
ffffffffc0205166:	fec757e3          	ble	a2,a4,ffffffffc0205154 <do_fork+0x18e>
ffffffffc020516a:	6694                	ld	a3,8(a3)
ffffffffc020516c:	863a                	mv	a2,a4
ffffffffc020516e:	4885                	li	a7,1
        while ((le = list_next(le)) != list)
ffffffffc0205170:	feb695e3          	bne	a3,a1,ffffffffc020515a <do_fork+0x194>
ffffffffc0205174:	00080763          	beqz	a6,ffffffffc0205182 <do_fork+0x1bc>
ffffffffc0205178:	0009c717          	auipc	a4,0x9c
ffffffffc020517c:	fcf72c23          	sw	a5,-40(a4) # ffffffffc02a1150 <last_pid.1691>
ffffffffc0205180:	853e                	mv	a0,a5
ffffffffc0205182:	00088663          	beqz	a7,ffffffffc020518e <do_fork+0x1c8>
ffffffffc0205186:	0009c797          	auipc	a5,0x9c
ffffffffc020518a:	fcc7a723          	sw	a2,-50(a5) # ffffffffc02a1154 <next_safe.1690>
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc020518e:	020bb703          	ld	a4,32(s7)
    __list_add(elm, listelm, listelm->next);
ffffffffc0205192:	6594                	ld	a3,8(a1)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0205194:	0c8b8613          	addi	a2,s7,200
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0205198:	7b7c                	ld	a5,240(a4)
        proc->pid = get_pid(); // 分配一个新的不重复的pid
ffffffffc020519a:	00aba223          	sw	a0,4(s7)
    prev->next = next->prev = elm;
ffffffffc020519e:	e290                	sd	a2,0(a3)
ffffffffc02051a0:	000a7817          	auipc	a6,0xa7
ffffffffc02051a4:	52c83c23          	sd	a2,1336(a6) # ffffffffc02ac6d8 <proc_list+0x8>
    elm->next = next;
ffffffffc02051a8:	0cdbb823          	sd	a3,208(s7)
    elm->prev = prev;
ffffffffc02051ac:	0cbbb423          	sd	a1,200(s7)
    proc->yptr = NULL;
ffffffffc02051b0:	0e0bbc23          	sd	zero,248(s7)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02051b4:	10fbb023          	sd	a5,256(s7)
ffffffffc02051b8:	c399                	beqz	a5,ffffffffc02051be <do_fork+0x1f8>
        proc->optr->yptr = proc;
ffffffffc02051ba:	0f77bc23          	sd	s7,248(a5)
    nr_process++;
ffffffffc02051be:	409c                	lw	a5,0(s1)
    proc->parent->cptr = proc;
ffffffffc02051c0:	0f773823          	sd	s7,240(a4)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02051c4:	45a9                	li	a1,10
    nr_process++;
ffffffffc02051c6:	2785                	addiw	a5,a5,1
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02051c8:	2501                	sext.w	a0,a0
    nr_process++;
ffffffffc02051ca:	000a7717          	auipc	a4,0xa7
ffffffffc02051ce:	3cf72f23          	sw	a5,990(a4) # ffffffffc02ac5a8 <nr_process>
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02051d2:	795000ef          	jal	ra,ffffffffc0206166 <hash32>
ffffffffc02051d6:	1502                	slli	a0,a0,0x20
ffffffffc02051d8:	000a3797          	auipc	a5,0xa3
ffffffffc02051dc:	38078793          	addi	a5,a5,896 # ffffffffc02a8558 <hash_list>
ffffffffc02051e0:	8171                	srli	a0,a0,0x1c
ffffffffc02051e2:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02051e4:	651c                	ld	a5,8(a0)
ffffffffc02051e6:	0d8b8713          	addi	a4,s7,216
    prev->next = next->prev = elm;
ffffffffc02051ea:	e398                	sd	a4,0(a5)
ffffffffc02051ec:	e518                	sd	a4,8(a0)
    elm->next = next;
ffffffffc02051ee:	0efbb023          	sd	a5,224(s7)
    elm->prev = prev;
ffffffffc02051f2:	0cabbc23          	sd	a0,216(s7)
    if (flag) {
ffffffffc02051f6:	e04d                	bnez	s0,ffffffffc0205298 <do_fork+0x2d2>
    wakeup_proc(proc); // 设置proc的state为PROC_RUNNABLE，使得进程可以被调度执行
ffffffffc02051f8:	855e                	mv	a0,s7
ffffffffc02051fa:	57b000ef          	jal	ra,ffffffffc0205f74 <wakeup_proc>
    ret = proc->pid;
ffffffffc02051fe:	004ba903          	lw	s2,4(s7)
}
ffffffffc0205202:	70a6                	ld	ra,104(sp)
ffffffffc0205204:	7406                	ld	s0,96(sp)
ffffffffc0205206:	854a                	mv	a0,s2
ffffffffc0205208:	64e6                	ld	s1,88(sp)
ffffffffc020520a:	6946                	ld	s2,80(sp)
ffffffffc020520c:	69a6                	ld	s3,72(sp)
ffffffffc020520e:	6a06                	ld	s4,64(sp)
ffffffffc0205210:	7ae2                	ld	s5,56(sp)
ffffffffc0205212:	7b42                	ld	s6,48(sp)
ffffffffc0205214:	7ba2                	ld	s7,40(sp)
ffffffffc0205216:	7c02                	ld	s8,32(sp)
ffffffffc0205218:	6ce2                	ld	s9,24(sp)
ffffffffc020521a:	6d42                	ld	s10,16(sp)
ffffffffc020521c:	6da2                	ld	s11,8(sp)
ffffffffc020521e:	6165                	addi	sp,sp,112
ffffffffc0205220:	8082                	ret
                if (++last_pid >= next_safe)
ffffffffc0205222:	2785                	addiw	a5,a5,1
ffffffffc0205224:	06c7dd63          	ble	a2,a5,ffffffffc020529e <do_fork+0x2d8>
ffffffffc0205228:	4805                	li	a6,1
ffffffffc020522a:	b72d                	j	ffffffffc0205154 <do_fork+0x18e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020522c:	8a36                	mv	s4,a3
ffffffffc020522e:	bd45                	j	ffffffffc02050de <do_fork+0x118>
    if ((mm = mm_create()) == NULL)
ffffffffc0205230:	e97fe0ef          	jal	ra,ffffffffc02040c6 <mm_create>
ffffffffc0205234:	8caa                	mv	s9,a0
ffffffffc0205236:	c179                	beqz	a0,ffffffffc02052fc <do_fork+0x336>
    if (setup_pgdir(mm) != 0)
ffffffffc0205238:	c11ff0ef          	jal	ra,ffffffffc0204e48 <setup_pgdir>
ffffffffc020523c:	e935                	bnez	a0,ffffffffc02052b0 <do_fork+0x2ea>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc020523e:	038c0d13          	addi	s10,s8,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0205242:	4785                	li	a5,1
ffffffffc0205244:	40fd37af          	amoor.d	a5,a5,(s10)
ffffffffc0205248:	8b85                	andi	a5,a5,1
ffffffffc020524a:	4905                	li	s2,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc020524c:	c799                	beqz	a5,ffffffffc020525a <do_fork+0x294>
        schedule();
ffffffffc020524e:	5a3000ef          	jal	ra,ffffffffc0205ff0 <schedule>
ffffffffc0205252:	412d37af          	amoor.d	a5,s2,(s10)
ffffffffc0205256:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc0205258:	fbfd                	bnez	a5,ffffffffc020524e <do_fork+0x288>
        ret = dup_mmap(mm, oldmm);
ffffffffc020525a:	85e2                	mv	a1,s8
ffffffffc020525c:	8566                	mv	a0,s9
ffffffffc020525e:	8f2ff0ef          	jal	ra,ffffffffc0204350 <dup_mmap>
ffffffffc0205262:	892a                	mv	s2,a0
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0205264:	57f9                	li	a5,-2
ffffffffc0205266:	60fd37af          	amoand.d	a5,a5,(s10)
ffffffffc020526a:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc020526c:	0e078363          	beqz	a5,ffffffffc0205352 <do_fork+0x38c>
    if (ret != 0)
ffffffffc0205270:	8c66                	mv	s8,s9
ffffffffc0205272:	e00507e3          	beqz	a0,ffffffffc0205080 <do_fork+0xba>
    exit_mmap(mm);
ffffffffc0205276:	8566                	mv	a0,s9
ffffffffc0205278:	974ff0ef          	jal	ra,ffffffffc02043ec <exit_mmap>
    put_pgdir(mm);
ffffffffc020527c:	8566                	mv	a0,s9
ffffffffc020527e:	b4dff0ef          	jal	ra,ffffffffc0204dca <put_pgdir>
    mm_destroy(mm);
ffffffffc0205282:	8566                	mv	a0,s9
ffffffffc0205284:	fc9fe0ef          	jal	ra,ffffffffc020424c <mm_destroy>
    if (ret != 0)
ffffffffc0205288:	a805                	j	ffffffffc02052b8 <do_fork+0x2f2>
        last_pid = 1;
ffffffffc020528a:	4785                	li	a5,1
ffffffffc020528c:	0009c717          	auipc	a4,0x9c
ffffffffc0205290:	ecf72223          	sw	a5,-316(a4) # ffffffffc02a1150 <last_pid.1691>
ffffffffc0205294:	4505                	li	a0,1
ffffffffc0205296:	bd69                	j	ffffffffc0205130 <do_fork+0x16a>
        intr_enable();
ffffffffc0205298:	bbcfb0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc020529c:	bfb1                	j	ffffffffc02051f8 <do_fork+0x232>
                    if (last_pid >= MAX_PID)
ffffffffc020529e:	0067c363          	blt	a5,t1,ffffffffc02052a4 <do_fork+0x2de>
                        last_pid = 1;
ffffffffc02052a2:	4785                	li	a5,1
                    goto repeat;
ffffffffc02052a4:	4805                	li	a6,1
ffffffffc02052a6:	b54d                	j	ffffffffc0205148 <do_fork+0x182>
        intr_disable();
ffffffffc02052a8:	bb2fb0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc02052ac:	4405                	li	s0,1
ffffffffc02052ae:	bd81                	j	ffffffffc02050fe <do_fork+0x138>
    mm_destroy(mm);
ffffffffc02052b0:	8566                	mv	a0,s9
ffffffffc02052b2:	f9bfe0ef          	jal	ra,ffffffffc020424c <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc02052b6:	5971                	li	s2,-4
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02052b8:	010bb683          	ld	a3,16(s7)
    return pa2page(PADDR(kva));
ffffffffc02052bc:	c02007b7          	lui	a5,0xc0200
ffffffffc02052c0:	0cf6e163          	bltu	a3,a5,ffffffffc0205382 <do_fork+0x3bc>
ffffffffc02052c4:	000db703          	ld	a4,0(s11)
    if (PPN(pa) >= npage) {
ffffffffc02052c8:	000b3783          	ld	a5,0(s6)
    return pa2page(PADDR(kva));
ffffffffc02052cc:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02052ce:	82b1                	srli	a3,a3,0xc
ffffffffc02052d0:	08f6fd63          	bleu	a5,a3,ffffffffc020536a <do_fork+0x3a4>
    return &pages[PPN(pa) - nbase];
ffffffffc02052d4:	000ab783          	ld	a5,0(s5)
ffffffffc02052d8:	0009b503          	ld	a0,0(s3)
ffffffffc02052dc:	4589                	li	a1,2
ffffffffc02052de:	8e9d                	sub	a3,a3,a5
ffffffffc02052e0:	069a                	slli	a3,a3,0x6
ffffffffc02052e2:	9536                	add	a0,a0,a3
ffffffffc02052e4:	bf7fc0ef          	jal	ra,ffffffffc0201eda <free_pages>
    kfree(proc);
ffffffffc02052e8:	855e                	mv	a0,s7
ffffffffc02052ea:	a29fc0ef          	jal	ra,ffffffffc0201d12 <kfree>
    return ret;
ffffffffc02052ee:	bf11                	j	ffffffffc0205202 <do_fork+0x23c>
    return -E_NO_MEM;
ffffffffc02052f0:	5971                	li	s2,-4
ffffffffc02052f2:	bfdd                	j	ffffffffc02052e8 <do_fork+0x322>
    int ret = -E_NO_FREE_PROC;
ffffffffc02052f4:	596d                	li	s2,-5
ffffffffc02052f6:	b731                	j	ffffffffc0205202 <do_fork+0x23c>
    ret = -E_NO_MEM;
ffffffffc02052f8:	5971                	li	s2,-4
ffffffffc02052fa:	b721                	j	ffffffffc0205202 <do_fork+0x23c>
    int ret = -E_NO_MEM;
ffffffffc02052fc:	5971                	li	s2,-4
ffffffffc02052fe:	bf6d                	j	ffffffffc02052b8 <do_fork+0x2f2>
    return KADDR(page2pa(page));
ffffffffc0205300:	00002617          	auipc	a2,0x2
ffffffffc0205304:	0c860613          	addi	a2,a2,200 # ffffffffc02073c8 <default_pmm_manager+0x50>
ffffffffc0205308:	06900593          	li	a1,105
ffffffffc020530c:	00002517          	auipc	a0,0x2
ffffffffc0205310:	0e450513          	addi	a0,a0,228 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc0205314:	970fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(current->wait_state == 0); // 确保进程在等待（确保当前进程的wait_state为0）
ffffffffc0205318:	00003697          	auipc	a3,0x3
ffffffffc020531c:	34868693          	addi	a3,a3,840 # ffffffffc0208660 <default_pmm_manager+0x12e8>
ffffffffc0205320:	00002617          	auipc	a2,0x2
ffffffffc0205324:	91060613          	addi	a2,a2,-1776 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0205328:	1d100593          	li	a1,465
ffffffffc020532c:	00003517          	auipc	a0,0x3
ffffffffc0205330:	5c450513          	addi	a0,a0,1476 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc0205334:	950fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205338:	86be                	mv	a3,a5
ffffffffc020533a:	00002617          	auipc	a2,0x2
ffffffffc020533e:	0c660613          	addi	a2,a2,198 # ffffffffc0207400 <default_pmm_manager+0x88>
ffffffffc0205342:	18e00593          	li	a1,398
ffffffffc0205346:	00003517          	auipc	a0,0x3
ffffffffc020534a:	5aa50513          	addi	a0,a0,1450 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc020534e:	936fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("Unlock failed.\n");
ffffffffc0205352:	00003617          	auipc	a2,0x3
ffffffffc0205356:	32e60613          	addi	a2,a2,814 # ffffffffc0208680 <default_pmm_manager+0x1308>
ffffffffc020535a:	03100593          	li	a1,49
ffffffffc020535e:	00003517          	auipc	a0,0x3
ffffffffc0205362:	33250513          	addi	a0,a0,818 # ffffffffc0208690 <default_pmm_manager+0x1318>
ffffffffc0205366:	91efb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020536a:	00002617          	auipc	a2,0x2
ffffffffc020536e:	0be60613          	addi	a2,a2,190 # ffffffffc0207428 <default_pmm_manager+0xb0>
ffffffffc0205372:	06200593          	li	a1,98
ffffffffc0205376:	00002517          	auipc	a0,0x2
ffffffffc020537a:	07a50513          	addi	a0,a0,122 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc020537e:	906fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205382:	00002617          	auipc	a2,0x2
ffffffffc0205386:	07e60613          	addi	a2,a2,126 # ffffffffc0207400 <default_pmm_manager+0x88>
ffffffffc020538a:	06e00593          	li	a1,110
ffffffffc020538e:	00002517          	auipc	a0,0x2
ffffffffc0205392:	06250513          	addi	a0,a0,98 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc0205396:	8eefb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020539a <kernel_thread>:
{
ffffffffc020539a:	7129                	addi	sp,sp,-320
ffffffffc020539c:	fa22                	sd	s0,304(sp)
ffffffffc020539e:	f626                	sd	s1,296(sp)
ffffffffc02053a0:	f24a                	sd	s2,288(sp)
ffffffffc02053a2:	84ae                	mv	s1,a1
ffffffffc02053a4:	892a                	mv	s2,a0
ffffffffc02053a6:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053a8:	4581                	li	a1,0
ffffffffc02053aa:	12000613          	li	a2,288
ffffffffc02053ae:	850a                	mv	a0,sp
{
ffffffffc02053b0:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053b2:	262010ef          	jal	ra,ffffffffc0206614 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02053b6:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02053b8:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02053ba:	100027f3          	csrr	a5,sstatus
ffffffffc02053be:	edd7f793          	andi	a5,a5,-291
ffffffffc02053c2:	1207e793          	ori	a5,a5,288
ffffffffc02053c6:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053c8:	860a                	mv	a2,sp
ffffffffc02053ca:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053ce:	00000797          	auipc	a5,0x0
ffffffffc02053d2:	8f278793          	addi	a5,a5,-1806 # ffffffffc0204cc0 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053d6:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053d8:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053da:	bedff0ef          	jal	ra,ffffffffc0204fc6 <do_fork>
}
ffffffffc02053de:	70f2                	ld	ra,312(sp)
ffffffffc02053e0:	7452                	ld	s0,304(sp)
ffffffffc02053e2:	74b2                	ld	s1,296(sp)
ffffffffc02053e4:	7912                	ld	s2,288(sp)
ffffffffc02053e6:	6131                	addi	sp,sp,320
ffffffffc02053e8:	8082                	ret

ffffffffc02053ea <do_exit>:
{
ffffffffc02053ea:	7179                	addi	sp,sp,-48
ffffffffc02053ec:	e84a                	sd	s2,16(sp)
    if (current == idleproc)
ffffffffc02053ee:	000a7717          	auipc	a4,0xa7
ffffffffc02053f2:	1aa70713          	addi	a4,a4,426 # ffffffffc02ac598 <idleproc>
ffffffffc02053f6:	000a7917          	auipc	s2,0xa7
ffffffffc02053fa:	19a90913          	addi	s2,s2,410 # ffffffffc02ac590 <current>
ffffffffc02053fe:	00093783          	ld	a5,0(s2)
ffffffffc0205402:	6318                	ld	a4,0(a4)
{
ffffffffc0205404:	f406                	sd	ra,40(sp)
ffffffffc0205406:	f022                	sd	s0,32(sp)
ffffffffc0205408:	ec26                	sd	s1,24(sp)
ffffffffc020540a:	e44e                	sd	s3,8(sp)
ffffffffc020540c:	e052                	sd	s4,0(sp)
    if (current == idleproc)
ffffffffc020540e:	0ce78c63          	beq	a5,a4,ffffffffc02054e6 <do_exit+0xfc>
    if (current == initproc)
ffffffffc0205412:	000a7417          	auipc	s0,0xa7
ffffffffc0205416:	18e40413          	addi	s0,s0,398 # ffffffffc02ac5a0 <initproc>
ffffffffc020541a:	6018                	ld	a4,0(s0)
ffffffffc020541c:	0ee78b63          	beq	a5,a4,ffffffffc0205512 <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc0205420:	7784                	ld	s1,40(a5)
ffffffffc0205422:	89aa                	mv	s3,a0
    if (mm != NULL)
ffffffffc0205424:	c48d                	beqz	s1,ffffffffc020544e <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc0205426:	000a7797          	auipc	a5,0xa7
ffffffffc020542a:	1ba78793          	addi	a5,a5,442 # ffffffffc02ac5e0 <boot_cr3>
ffffffffc020542e:	639c                	ld	a5,0(a5)
ffffffffc0205430:	577d                	li	a4,-1
ffffffffc0205432:	177e                	slli	a4,a4,0x3f
ffffffffc0205434:	83b1                	srli	a5,a5,0xc
ffffffffc0205436:	8fd9                	or	a5,a5,a4
ffffffffc0205438:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc020543c:	589c                	lw	a5,48(s1)
ffffffffc020543e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205442:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0)
ffffffffc0205444:	cf4d                	beqz	a4,ffffffffc02054fe <do_exit+0x114>
        current->mm = NULL;
ffffffffc0205446:	00093783          	ld	a5,0(s2)
ffffffffc020544a:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc020544e:	00093783          	ld	a5,0(s2)
ffffffffc0205452:	470d                	li	a4,3
ffffffffc0205454:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205456:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020545a:	100027f3          	csrr	a5,sstatus
ffffffffc020545e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205460:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205462:	e7e1                	bnez	a5,ffffffffc020552a <do_exit+0x140>
        proc = current->parent;
ffffffffc0205464:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD)
ffffffffc0205468:	800007b7          	lui	a5,0x80000
ffffffffc020546c:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc020546e:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc0205470:	0ec52703          	lw	a4,236(a0)
ffffffffc0205474:	0af70f63          	beq	a4,a5,ffffffffc0205532 <do_exit+0x148>
ffffffffc0205478:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD)
ffffffffc020547c:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE)
ffffffffc0205480:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD)
ffffffffc0205482:	0985                	addi	s3,s3,1
        while (current->cptr != NULL)
ffffffffc0205484:	7afc                	ld	a5,240(a3)
ffffffffc0205486:	cb95                	beqz	a5,ffffffffc02054ba <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc0205488:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5670>
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc020548c:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc020548e:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0205490:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0205492:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0205496:	10e7b023          	sd	a4,256(a5)
ffffffffc020549a:	c311                	beqz	a4,ffffffffc020549e <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc020549c:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc020549e:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02054a0:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02054a2:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc02054a4:	fe9710e3          	bne	a4,s1,ffffffffc0205484 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc02054a8:	0ec52783          	lw	a5,236(a0)
ffffffffc02054ac:	fd379ce3          	bne	a5,s3,ffffffffc0205484 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02054b0:	2c5000ef          	jal	ra,ffffffffc0205f74 <wakeup_proc>
ffffffffc02054b4:	00093683          	ld	a3,0(s2)
ffffffffc02054b8:	b7f1                	j	ffffffffc0205484 <do_exit+0x9a>
    if (flag) {
ffffffffc02054ba:	020a1363          	bnez	s4,ffffffffc02054e0 <do_exit+0xf6>
    schedule();
ffffffffc02054be:	333000ef          	jal	ra,ffffffffc0205ff0 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02054c2:	00093783          	ld	a5,0(s2)
ffffffffc02054c6:	00003617          	auipc	a2,0x3
ffffffffc02054ca:	17a60613          	addi	a2,a2,378 # ffffffffc0208640 <default_pmm_manager+0x12c8>
ffffffffc02054ce:	24800593          	li	a1,584
ffffffffc02054d2:	43d4                	lw	a3,4(a5)
ffffffffc02054d4:	00003517          	auipc	a0,0x3
ffffffffc02054d8:	41c50513          	addi	a0,a0,1052 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc02054dc:	fa9fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        intr_enable();
ffffffffc02054e0:	974fb0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc02054e4:	bfe9                	j	ffffffffc02054be <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc02054e6:	00003617          	auipc	a2,0x3
ffffffffc02054ea:	13a60613          	addi	a2,a2,314 # ffffffffc0208620 <default_pmm_manager+0x12a8>
ffffffffc02054ee:	21400593          	li	a1,532
ffffffffc02054f2:	00003517          	auipc	a0,0x3
ffffffffc02054f6:	3fe50513          	addi	a0,a0,1022 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc02054fa:	f8bfa0ef          	jal	ra,ffffffffc0200484 <__panic>
            exit_mmap(mm);
ffffffffc02054fe:	8526                	mv	a0,s1
ffffffffc0205500:	eedfe0ef          	jal	ra,ffffffffc02043ec <exit_mmap>
            put_pgdir(mm);
ffffffffc0205504:	8526                	mv	a0,s1
ffffffffc0205506:	8c5ff0ef          	jal	ra,ffffffffc0204dca <put_pgdir>
            mm_destroy(mm);
ffffffffc020550a:	8526                	mv	a0,s1
ffffffffc020550c:	d41fe0ef          	jal	ra,ffffffffc020424c <mm_destroy>
ffffffffc0205510:	bf1d                	j	ffffffffc0205446 <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc0205512:	00003617          	auipc	a2,0x3
ffffffffc0205516:	11e60613          	addi	a2,a2,286 # ffffffffc0208630 <default_pmm_manager+0x12b8>
ffffffffc020551a:	21800593          	li	a1,536
ffffffffc020551e:	00003517          	auipc	a0,0x3
ffffffffc0205522:	3d250513          	addi	a0,a0,978 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc0205526:	f5ffa0ef          	jal	ra,ffffffffc0200484 <__panic>
        intr_disable();
ffffffffc020552a:	930fb0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc020552e:	4a05                	li	s4,1
ffffffffc0205530:	bf15                	j	ffffffffc0205464 <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc0205532:	243000ef          	jal	ra,ffffffffc0205f74 <wakeup_proc>
ffffffffc0205536:	b789                	j	ffffffffc0205478 <do_exit+0x8e>

ffffffffc0205538 <do_wait.part.1>:
int do_wait(int pid, int *code_store)
ffffffffc0205538:	7139                	addi	sp,sp,-64
ffffffffc020553a:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc020553c:	80000a37          	lui	s4,0x80000
int do_wait(int pid, int *code_store)
ffffffffc0205540:	f426                	sd	s1,40(sp)
ffffffffc0205542:	f04a                	sd	s2,32(sp)
ffffffffc0205544:	ec4e                	sd	s3,24(sp)
ffffffffc0205546:	e456                	sd	s5,8(sp)
ffffffffc0205548:	e05a                	sd	s6,0(sp)
ffffffffc020554a:	fc06                	sd	ra,56(sp)
ffffffffc020554c:	f822                	sd	s0,48(sp)
ffffffffc020554e:	89aa                	mv	s3,a0
ffffffffc0205550:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc0205552:	000a7917          	auipc	s2,0xa7
ffffffffc0205556:	03e90913          	addi	s2,s2,62 # ffffffffc02ac590 <current>
            if (proc->state == PROC_ZOMBIE)
ffffffffc020555a:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc020555c:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc020555e:	2a05                	addiw	s4,s4,1
    if (pid != 0)
ffffffffc0205560:	02098f63          	beqz	s3,ffffffffc020559e <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc0205564:	854e                	mv	a0,s3
ffffffffc0205566:	a05ff0ef          	jal	ra,ffffffffc0204f6a <find_proc>
ffffffffc020556a:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current)
ffffffffc020556c:	12050063          	beqz	a0,ffffffffc020568c <do_wait.part.1+0x154>
ffffffffc0205570:	00093703          	ld	a4,0(s2)
ffffffffc0205574:	711c                	ld	a5,32(a0)
ffffffffc0205576:	10e79b63          	bne	a5,a4,ffffffffc020568c <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE)
ffffffffc020557a:	411c                	lw	a5,0(a0)
ffffffffc020557c:	02978c63          	beq	a5,s1,ffffffffc02055b4 <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc0205580:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc0205584:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc0205588:	269000ef          	jal	ra,ffffffffc0205ff0 <schedule>
        if (current->flags & PF_EXITING)
ffffffffc020558c:	00093783          	ld	a5,0(s2)
ffffffffc0205590:	0b07a783          	lw	a5,176(a5)
ffffffffc0205594:	8b85                	andi	a5,a5,1
ffffffffc0205596:	d7e9                	beqz	a5,ffffffffc0205560 <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc0205598:	555d                	li	a0,-9
ffffffffc020559a:	e51ff0ef          	jal	ra,ffffffffc02053ea <do_exit>
        proc = current->cptr;
ffffffffc020559e:	00093703          	ld	a4,0(s2)
ffffffffc02055a2:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr)
ffffffffc02055a4:	e409                	bnez	s0,ffffffffc02055ae <do_wait.part.1+0x76>
ffffffffc02055a6:	a0dd                	j	ffffffffc020568c <do_wait.part.1+0x154>
ffffffffc02055a8:	10043403          	ld	s0,256(s0)
ffffffffc02055ac:	d871                	beqz	s0,ffffffffc0205580 <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02055ae:	401c                	lw	a5,0(s0)
ffffffffc02055b0:	fe979ce3          	bne	a5,s1,ffffffffc02055a8 <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc)
ffffffffc02055b4:	000a7797          	auipc	a5,0xa7
ffffffffc02055b8:	fe478793          	addi	a5,a5,-28 # ffffffffc02ac598 <idleproc>
ffffffffc02055bc:	639c                	ld	a5,0(a5)
ffffffffc02055be:	0c878d63          	beq	a5,s0,ffffffffc0205698 <do_wait.part.1+0x160>
ffffffffc02055c2:	000a7797          	auipc	a5,0xa7
ffffffffc02055c6:	fde78793          	addi	a5,a5,-34 # ffffffffc02ac5a0 <initproc>
ffffffffc02055ca:	639c                	ld	a5,0(a5)
ffffffffc02055cc:	0cf40663          	beq	s0,a5,ffffffffc0205698 <do_wait.part.1+0x160>
    if (code_store != NULL)
ffffffffc02055d0:	000b0663          	beqz	s6,ffffffffc02055dc <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc02055d4:	0e842783          	lw	a5,232(s0)
ffffffffc02055d8:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055dc:	100027f3          	csrr	a5,sstatus
ffffffffc02055e0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02055e2:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055e4:	e7d5                	bnez	a5,ffffffffc0205690 <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc02055e6:	6c70                	ld	a2,216(s0)
ffffffffc02055e8:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL)
ffffffffc02055ea:	10043703          	ld	a4,256(s0)
ffffffffc02055ee:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02055f0:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055f2:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02055f4:	6470                	ld	a2,200(s0)
ffffffffc02055f6:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02055f8:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055fa:	e290                	sd	a2,0(a3)
ffffffffc02055fc:	c319                	beqz	a4,ffffffffc0205602 <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc02055fe:	ff7c                	sd	a5,248(a4)
ffffffffc0205600:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL)
ffffffffc0205602:	c3d1                	beqz	a5,ffffffffc0205686 <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc0205604:	10e7b023          	sd	a4,256(a5)
    nr_process--;
ffffffffc0205608:	000a7797          	auipc	a5,0xa7
ffffffffc020560c:	fa078793          	addi	a5,a5,-96 # ffffffffc02ac5a8 <nr_process>
ffffffffc0205610:	439c                	lw	a5,0(a5)
ffffffffc0205612:	37fd                	addiw	a5,a5,-1
ffffffffc0205614:	000a7717          	auipc	a4,0xa7
ffffffffc0205618:	f8f72a23          	sw	a5,-108(a4) # ffffffffc02ac5a8 <nr_process>
    if (flag) {
ffffffffc020561c:	e1b5                	bnez	a1,ffffffffc0205680 <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020561e:	6814                	ld	a3,16(s0)
ffffffffc0205620:	c02007b7          	lui	a5,0xc0200
ffffffffc0205624:	0af6e263          	bltu	a3,a5,ffffffffc02056c8 <do_wait.part.1+0x190>
ffffffffc0205628:	000a7797          	auipc	a5,0xa7
ffffffffc020562c:	fb078793          	addi	a5,a5,-80 # ffffffffc02ac5d8 <va_pa_offset>
ffffffffc0205630:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0205632:	000a7797          	auipc	a5,0xa7
ffffffffc0205636:	f4678793          	addi	a5,a5,-186 # ffffffffc02ac578 <npage>
ffffffffc020563a:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc020563c:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc020563e:	82b1                	srli	a3,a3,0xc
ffffffffc0205640:	06f6f863          	bleu	a5,a3,ffffffffc02056b0 <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc0205644:	00003797          	auipc	a5,0x3
ffffffffc0205648:	77478793          	addi	a5,a5,1908 # ffffffffc0208db8 <nbase>
ffffffffc020564c:	639c                	ld	a5,0(a5)
ffffffffc020564e:	000a7717          	auipc	a4,0xa7
ffffffffc0205652:	f9a70713          	addi	a4,a4,-102 # ffffffffc02ac5e8 <pages>
ffffffffc0205656:	6308                	ld	a0,0(a4)
ffffffffc0205658:	8e9d                	sub	a3,a3,a5
ffffffffc020565a:	069a                	slli	a3,a3,0x6
ffffffffc020565c:	9536                	add	a0,a0,a3
ffffffffc020565e:	4589                	li	a1,2
ffffffffc0205660:	87bfc0ef          	jal	ra,ffffffffc0201eda <free_pages>
    kfree(proc);
ffffffffc0205664:	8522                	mv	a0,s0
ffffffffc0205666:	eacfc0ef          	jal	ra,ffffffffc0201d12 <kfree>
    return 0;
ffffffffc020566a:	4501                	li	a0,0
}
ffffffffc020566c:	70e2                	ld	ra,56(sp)
ffffffffc020566e:	7442                	ld	s0,48(sp)
ffffffffc0205670:	74a2                	ld	s1,40(sp)
ffffffffc0205672:	7902                	ld	s2,32(sp)
ffffffffc0205674:	69e2                	ld	s3,24(sp)
ffffffffc0205676:	6a42                	ld	s4,16(sp)
ffffffffc0205678:	6aa2                	ld	s5,8(sp)
ffffffffc020567a:	6b02                	ld	s6,0(sp)
ffffffffc020567c:	6121                	addi	sp,sp,64
ffffffffc020567e:	8082                	ret
        intr_enable();
ffffffffc0205680:	fd5fa0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0205684:	bf69                	j	ffffffffc020561e <do_wait.part.1+0xe6>
        proc->parent->cptr = proc->optr;
ffffffffc0205686:	701c                	ld	a5,32(s0)
ffffffffc0205688:	fbf8                	sd	a4,240(a5)
ffffffffc020568a:	bfbd                	j	ffffffffc0205608 <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc020568c:	5579                	li	a0,-2
ffffffffc020568e:	bff9                	j	ffffffffc020566c <do_wait.part.1+0x134>
        intr_disable();
ffffffffc0205690:	fcbfa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0205694:	4585                	li	a1,1
ffffffffc0205696:	bf81                	j	ffffffffc02055e6 <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc0205698:	00003617          	auipc	a2,0x3
ffffffffc020569c:	01060613          	addi	a2,a2,16 # ffffffffc02086a8 <default_pmm_manager+0x1330>
ffffffffc02056a0:	36d00593          	li	a1,877
ffffffffc02056a4:	00003517          	auipc	a0,0x3
ffffffffc02056a8:	24c50513          	addi	a0,a0,588 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc02056ac:	dd9fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02056b0:	00002617          	auipc	a2,0x2
ffffffffc02056b4:	d7860613          	addi	a2,a2,-648 # ffffffffc0207428 <default_pmm_manager+0xb0>
ffffffffc02056b8:	06200593          	li	a1,98
ffffffffc02056bc:	00002517          	auipc	a0,0x2
ffffffffc02056c0:	d3450513          	addi	a0,a0,-716 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc02056c4:	dc1fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02056c8:	00002617          	auipc	a2,0x2
ffffffffc02056cc:	d3860613          	addi	a2,a2,-712 # ffffffffc0207400 <default_pmm_manager+0x88>
ffffffffc02056d0:	06e00593          	li	a1,110
ffffffffc02056d4:	00002517          	auipc	a0,0x2
ffffffffc02056d8:	d1c50513          	addi	a0,a0,-740 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc02056dc:	da9fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02056e0 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc02056e0:	1141                	addi	sp,sp,-16
ffffffffc02056e2:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02056e4:	83dfc0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02056e8:	d6afc0ef          	jal	ra,ffffffffc0201c52 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02056ec:	4601                	li	a2,0
ffffffffc02056ee:	4581                	li	a1,0
ffffffffc02056f0:	fffff517          	auipc	a0,0xfffff
ffffffffc02056f4:	65850513          	addi	a0,a0,1624 # ffffffffc0204d48 <user_main>
ffffffffc02056f8:	ca3ff0ef          	jal	ra,ffffffffc020539a <kernel_thread>
    if (pid <= 0)
ffffffffc02056fc:	00a04563          	bgtz	a0,ffffffffc0205706 <init_main+0x26>
ffffffffc0205700:	a841                	j	ffffffffc0205790 <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc0205702:	0ef000ef          	jal	ra,ffffffffc0205ff0 <schedule>
    if (code_store != NULL)
ffffffffc0205706:	4581                	li	a1,0
ffffffffc0205708:	4501                	li	a0,0
ffffffffc020570a:	e2fff0ef          	jal	ra,ffffffffc0205538 <do_wait.part.1>
    while (do_wait(0, NULL) == 0)
ffffffffc020570e:	d975                	beqz	a0,ffffffffc0205702 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205710:	00003517          	auipc	a0,0x3
ffffffffc0205714:	fd850513          	addi	a0,a0,-40 # ffffffffc02086e8 <default_pmm_manager+0x1370>
ffffffffc0205718:	a77fa0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020571c:	000a7797          	auipc	a5,0xa7
ffffffffc0205720:	e8478793          	addi	a5,a5,-380 # ffffffffc02ac5a0 <initproc>
ffffffffc0205724:	639c                	ld	a5,0(a5)
ffffffffc0205726:	7bf8                	ld	a4,240(a5)
ffffffffc0205728:	e721                	bnez	a4,ffffffffc0205770 <init_main+0x90>
ffffffffc020572a:	7ff8                	ld	a4,248(a5)
ffffffffc020572c:	e331                	bnez	a4,ffffffffc0205770 <init_main+0x90>
ffffffffc020572e:	1007b703          	ld	a4,256(a5)
ffffffffc0205732:	ef1d                	bnez	a4,ffffffffc0205770 <init_main+0x90>
    assert(nr_process == 2);
ffffffffc0205734:	000a7717          	auipc	a4,0xa7
ffffffffc0205738:	e7470713          	addi	a4,a4,-396 # ffffffffc02ac5a8 <nr_process>
ffffffffc020573c:	4314                	lw	a3,0(a4)
ffffffffc020573e:	4709                	li	a4,2
ffffffffc0205740:	0ae69463          	bne	a3,a4,ffffffffc02057e8 <init_main+0x108>
    return listelm->next;
ffffffffc0205744:	000a7697          	auipc	a3,0xa7
ffffffffc0205748:	f8c68693          	addi	a3,a3,-116 # ffffffffc02ac6d0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020574c:	6698                	ld	a4,8(a3)
ffffffffc020574e:	0c878793          	addi	a5,a5,200
ffffffffc0205752:	06f71b63          	bne	a4,a5,ffffffffc02057c8 <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205756:	629c                	ld	a5,0(a3)
ffffffffc0205758:	04f71863          	bne	a4,a5,ffffffffc02057a8 <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc020575c:	00003517          	auipc	a0,0x3
ffffffffc0205760:	07450513          	addi	a0,a0,116 # ffffffffc02087d0 <default_pmm_manager+0x1458>
ffffffffc0205764:	a2bfa0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
}
ffffffffc0205768:	60a2                	ld	ra,8(sp)
ffffffffc020576a:	4501                	li	a0,0
ffffffffc020576c:	0141                	addi	sp,sp,16
ffffffffc020576e:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205770:	00003697          	auipc	a3,0x3
ffffffffc0205774:	fa068693          	addi	a3,a3,-96 # ffffffffc0208710 <default_pmm_manager+0x1398>
ffffffffc0205778:	00001617          	auipc	a2,0x1
ffffffffc020577c:	4b860613          	addi	a2,a2,1208 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0205780:	3db00593          	li	a1,987
ffffffffc0205784:	00003517          	auipc	a0,0x3
ffffffffc0205788:	16c50513          	addi	a0,a0,364 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc020578c:	cf9fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("create user_main failed.\n");
ffffffffc0205790:	00003617          	auipc	a2,0x3
ffffffffc0205794:	f3860613          	addi	a2,a2,-200 # ffffffffc02086c8 <default_pmm_manager+0x1350>
ffffffffc0205798:	3d200593          	li	a1,978
ffffffffc020579c:	00003517          	auipc	a0,0x3
ffffffffc02057a0:	15450513          	addi	a0,a0,340 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc02057a4:	ce1fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02057a8:	00003697          	auipc	a3,0x3
ffffffffc02057ac:	ff868693          	addi	a3,a3,-8 # ffffffffc02087a0 <default_pmm_manager+0x1428>
ffffffffc02057b0:	00001617          	auipc	a2,0x1
ffffffffc02057b4:	48060613          	addi	a2,a2,1152 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02057b8:	3de00593          	li	a1,990
ffffffffc02057bc:	00003517          	auipc	a0,0x3
ffffffffc02057c0:	13450513          	addi	a0,a0,308 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc02057c4:	cc1fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02057c8:	00003697          	auipc	a3,0x3
ffffffffc02057cc:	fa868693          	addi	a3,a3,-88 # ffffffffc0208770 <default_pmm_manager+0x13f8>
ffffffffc02057d0:	00001617          	auipc	a2,0x1
ffffffffc02057d4:	46060613          	addi	a2,a2,1120 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02057d8:	3dd00593          	li	a1,989
ffffffffc02057dc:	00003517          	auipc	a0,0x3
ffffffffc02057e0:	11450513          	addi	a0,a0,276 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc02057e4:	ca1fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_process == 2);
ffffffffc02057e8:	00003697          	auipc	a3,0x3
ffffffffc02057ec:	f7868693          	addi	a3,a3,-136 # ffffffffc0208760 <default_pmm_manager+0x13e8>
ffffffffc02057f0:	00001617          	auipc	a2,0x1
ffffffffc02057f4:	44060613          	addi	a2,a2,1088 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc02057f8:	3dc00593          	li	a1,988
ffffffffc02057fc:	00003517          	auipc	a0,0x3
ffffffffc0205800:	0f450513          	addi	a0,a0,244 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc0205804:	c81fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205808 <do_execve>:
{
ffffffffc0205808:	7135                	addi	sp,sp,-160
ffffffffc020580a:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020580c:	000a7a17          	auipc	s4,0xa7
ffffffffc0205810:	d84a0a13          	addi	s4,s4,-636 # ffffffffc02ac590 <current>
ffffffffc0205814:	000a3783          	ld	a5,0(s4)
{
ffffffffc0205818:	e14a                	sd	s2,128(sp)
ffffffffc020581a:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020581c:	0287b903          	ld	s2,40(a5)
{
ffffffffc0205820:	fcce                	sd	s3,120(sp)
ffffffffc0205822:	f0da                	sd	s6,96(sp)
ffffffffc0205824:	89aa                	mv	s3,a0
ffffffffc0205826:	842e                	mv	s0,a1
ffffffffc0205828:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc020582a:	4681                	li	a3,0
ffffffffc020582c:	862e                	mv	a2,a1
ffffffffc020582e:	85aa                	mv	a1,a0
ffffffffc0205830:	854a                	mv	a0,s2
{
ffffffffc0205832:	ed06                	sd	ra,152(sp)
ffffffffc0205834:	e526                	sd	s1,136(sp)
ffffffffc0205836:	f4d6                	sd	s5,104(sp)
ffffffffc0205838:	ecde                	sd	s7,88(sp)
ffffffffc020583a:	e8e2                	sd	s8,80(sp)
ffffffffc020583c:	e4e6                	sd	s9,72(sp)
ffffffffc020583e:	e0ea                	sd	s10,64(sp)
ffffffffc0205840:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0205842:	a82ff0ef          	jal	ra,ffffffffc0204ac4 <user_mem_check>
ffffffffc0205846:	40050663          	beqz	a0,ffffffffc0205c52 <do_execve+0x44a>
    memset(local_name, 0, sizeof(local_name));
ffffffffc020584a:	4641                	li	a2,16
ffffffffc020584c:	4581                	li	a1,0
ffffffffc020584e:	1008                	addi	a0,sp,32
ffffffffc0205850:	5c5000ef          	jal	ra,ffffffffc0206614 <memset>
    memcpy(local_name, name, len);
ffffffffc0205854:	47bd                	li	a5,15
ffffffffc0205856:	8622                	mv	a2,s0
ffffffffc0205858:	0687ee63          	bltu	a5,s0,ffffffffc02058d4 <do_execve+0xcc>
ffffffffc020585c:	85ce                	mv	a1,s3
ffffffffc020585e:	1008                	addi	a0,sp,32
ffffffffc0205860:	5c7000ef          	jal	ra,ffffffffc0206626 <memcpy>
    if (mm != NULL)
ffffffffc0205864:	06090f63          	beqz	s2,ffffffffc02058e2 <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc0205868:	00002517          	auipc	a0,0x2
ffffffffc020586c:	30850513          	addi	a0,a0,776 # ffffffffc0207b70 <default_pmm_manager+0x7f8>
ffffffffc0205870:	957fa0ef          	jal	ra,ffffffffc02001c6 <cputs>
        lcr3(boot_cr3); ////转入内核态
ffffffffc0205874:	000a7797          	auipc	a5,0xa7
ffffffffc0205878:	d6c78793          	addi	a5,a5,-660 # ffffffffc02ac5e0 <boot_cr3>
ffffffffc020587c:	639c                	ld	a5,0(a5)
ffffffffc020587e:	577d                	li	a4,-1
ffffffffc0205880:	177e                	slli	a4,a4,0x3f
ffffffffc0205882:	83b1                	srli	a5,a5,0xc
ffffffffc0205884:	8fd9                	or	a5,a5,a4
ffffffffc0205886:	18079073          	csrw	satp,a5
ffffffffc020588a:	03092783          	lw	a5,48(s2)
ffffffffc020588e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205892:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0)
ffffffffc0205896:	28070d63          	beqz	a4,ffffffffc0205b30 <do_execve+0x328>
        current->mm = NULL;
ffffffffc020589a:	000a3783          	ld	a5,0(s4)
ffffffffc020589e:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc02058a2:	825fe0ef          	jal	ra,ffffffffc02040c6 <mm_create>
ffffffffc02058a6:	892a                	mv	s2,a0
ffffffffc02058a8:	c135                	beqz	a0,ffffffffc020590c <do_execve+0x104>
    if (setup_pgdir(mm) != 0)
ffffffffc02058aa:	d9eff0ef          	jal	ra,ffffffffc0204e48 <setup_pgdir>
ffffffffc02058ae:	e931                	bnez	a0,ffffffffc0205902 <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc02058b0:	000b2703          	lw	a4,0(s6)
ffffffffc02058b4:	464c47b7          	lui	a5,0x464c4
ffffffffc02058b8:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9aef>
ffffffffc02058bc:	04f70a63          	beq	a4,a5,ffffffffc0205910 <do_execve+0x108>
    put_pgdir(mm);
ffffffffc02058c0:	854a                	mv	a0,s2
ffffffffc02058c2:	d08ff0ef          	jal	ra,ffffffffc0204dca <put_pgdir>
    mm_destroy(mm);
ffffffffc02058c6:	854a                	mv	a0,s2
ffffffffc02058c8:	985fe0ef          	jal	ra,ffffffffc020424c <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc02058cc:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc02058ce:	854e                	mv	a0,s3
ffffffffc02058d0:	b1bff0ef          	jal	ra,ffffffffc02053ea <do_exit>
    memcpy(local_name, name, len);
ffffffffc02058d4:	463d                	li	a2,15
ffffffffc02058d6:	85ce                	mv	a1,s3
ffffffffc02058d8:	1008                	addi	a0,sp,32
ffffffffc02058da:	54d000ef          	jal	ra,ffffffffc0206626 <memcpy>
    if (mm != NULL)
ffffffffc02058de:	f80915e3          	bnez	s2,ffffffffc0205868 <do_execve+0x60>
    if (current->mm != NULL)
ffffffffc02058e2:	000a3783          	ld	a5,0(s4)
ffffffffc02058e6:	779c                	ld	a5,40(a5)
ffffffffc02058e8:	dfcd                	beqz	a5,ffffffffc02058a2 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02058ea:	00003617          	auipc	a2,0x3
ffffffffc02058ee:	bae60613          	addi	a2,a2,-1106 # ffffffffc0208498 <default_pmm_manager+0x1120>
ffffffffc02058f2:	25400593          	li	a1,596
ffffffffc02058f6:	00003517          	auipc	a0,0x3
ffffffffc02058fa:	ffa50513          	addi	a0,a0,-6 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc02058fe:	b87fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    mm_destroy(mm);
ffffffffc0205902:	854a                	mv	a0,s2
ffffffffc0205904:	949fe0ef          	jal	ra,ffffffffc020424c <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0205908:	59f1                	li	s3,-4
ffffffffc020590a:	b7d1                	j	ffffffffc02058ce <do_execve+0xc6>
ffffffffc020590c:	59f1                	li	s3,-4
ffffffffc020590e:	b7c1                	j	ffffffffc02058ce <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205910:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205914:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205918:	00371793          	slli	a5,a4,0x3
ffffffffc020591c:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020591e:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205920:	078e                	slli	a5,a5,0x3
ffffffffc0205922:	97a2                	add	a5,a5,s0
ffffffffc0205924:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph++)
ffffffffc0205926:	02f47b63          	bleu	a5,s0,ffffffffc020595c <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc020592a:	5bfd                	li	s7,-1
ffffffffc020592c:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc0205930:	000a7d97          	auipc	s11,0xa7
ffffffffc0205934:	cb8d8d93          	addi	s11,s11,-840 # ffffffffc02ac5e8 <pages>
ffffffffc0205938:	00003d17          	auipc	s10,0x3
ffffffffc020593c:	480d0d13          	addi	s10,s10,1152 # ffffffffc0208db8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0205940:	e43e                	sd	a5,8(sp)
ffffffffc0205942:	000a7c97          	auipc	s9,0xa7
ffffffffc0205946:	c36c8c93          	addi	s9,s9,-970 # ffffffffc02ac578 <npage>
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc020594a:	4018                	lw	a4,0(s0)
ffffffffc020594c:	4785                	li	a5,1
ffffffffc020594e:	0ef70f63          	beq	a4,a5,ffffffffc0205a4c <do_execve+0x244>
    for (; ph < ph_end; ph++)
ffffffffc0205952:	67e2                	ld	a5,24(sp)
ffffffffc0205954:	03840413          	addi	s0,s0,56
ffffffffc0205958:	fef469e3          	bltu	s0,a5,ffffffffc020594a <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc020595c:	4701                	li	a4,0
ffffffffc020595e:	46ad                	li	a3,11
ffffffffc0205960:	00100637          	lui	a2,0x100
ffffffffc0205964:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205968:	854a                	mv	a0,s2
ffffffffc020596a:	935fe0ef          	jal	ra,ffffffffc020429e <mm_map>
ffffffffc020596e:	89aa                	mv	s3,a0
ffffffffc0205970:	1a051663          	bnez	a0,ffffffffc0205b1c <do_execve+0x314>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0205974:	01893503          	ld	a0,24(s2)
ffffffffc0205978:	467d                	li	a2,31
ffffffffc020597a:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc020597e:	97bfd0ef          	jal	ra,ffffffffc02032f8 <pgdir_alloc_page>
ffffffffc0205982:	36050463          	beqz	a0,ffffffffc0205cea <do_execve+0x4e2>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205986:	01893503          	ld	a0,24(s2)
ffffffffc020598a:	467d                	li	a2,31
ffffffffc020598c:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205990:	969fd0ef          	jal	ra,ffffffffc02032f8 <pgdir_alloc_page>
ffffffffc0205994:	32050b63          	beqz	a0,ffffffffc0205cca <do_execve+0x4c2>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205998:	01893503          	ld	a0,24(s2)
ffffffffc020599c:	467d                	li	a2,31
ffffffffc020599e:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02059a2:	957fd0ef          	jal	ra,ffffffffc02032f8 <pgdir_alloc_page>
ffffffffc02059a6:	30050263          	beqz	a0,ffffffffc0205caa <do_execve+0x4a2>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc02059aa:	01893503          	ld	a0,24(s2)
ffffffffc02059ae:	467d                	li	a2,31
ffffffffc02059b0:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc02059b4:	945fd0ef          	jal	ra,ffffffffc02032f8 <pgdir_alloc_page>
ffffffffc02059b8:	2c050963          	beqz	a0,ffffffffc0205c8a <do_execve+0x482>
    mm->mm_count += 1;
ffffffffc02059bc:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc02059c0:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059c4:	01893683          	ld	a3,24(s2)
ffffffffc02059c8:	2785                	addiw	a5,a5,1
ffffffffc02059ca:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc02059ce:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf5598>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059d2:	c02007b7          	lui	a5,0xc0200
ffffffffc02059d6:	28f6ee63          	bltu	a3,a5,ffffffffc0205c72 <do_execve+0x46a>
ffffffffc02059da:	000a7797          	auipc	a5,0xa7
ffffffffc02059de:	bfe78793          	addi	a5,a5,-1026 # ffffffffc02ac5d8 <va_pa_offset>
ffffffffc02059e2:	639c                	ld	a5,0(a5)
ffffffffc02059e4:	577d                	li	a4,-1
ffffffffc02059e6:	177e                	slli	a4,a4,0x3f
ffffffffc02059e8:	8e9d                	sub	a3,a3,a5
ffffffffc02059ea:	00c6d793          	srli	a5,a3,0xc
ffffffffc02059ee:	f654                	sd	a3,168(a2)
ffffffffc02059f0:	8fd9                	or	a5,a5,a4
ffffffffc02059f2:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc02059f6:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02059f8:	4581                	li	a1,0
ffffffffc02059fa:	12000613          	li	a2,288
ffffffffc02059fe:	8522                	mv	a0,s0
ffffffffc0205a00:	415000ef          	jal	ra,ffffffffc0206614 <memset>
    tf->epc = elf->e_entry;
ffffffffc0205a04:	018b3703          	ld	a4,24(s6)
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a08:	4785                	li	a5,1
ffffffffc0205a0a:	07fe                	slli	a5,a5,0x1f
ffffffffc0205a0c:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205a0e:	10e43423          	sd	a4,264(s0)
    tf->status = (read_csr(sstatus) | SSTATUS_SPIE) & ~SSTATUS_SPP;
ffffffffc0205a12:	100027f3          	csrr	a5,sstatus
ffffffffc0205a16:	edf7f793          	andi	a5,a5,-289
    set_proc_name(current, local_name);
ffffffffc0205a1a:	000a3503          	ld	a0,0(s4)
    tf->status = (read_csr(sstatus) | SSTATUS_SPIE) & ~SSTATUS_SPP;
ffffffffc0205a1e:	0207e793          	ori	a5,a5,32
ffffffffc0205a22:	10f43023          	sd	a5,256(s0)
    set_proc_name(current, local_name);
ffffffffc0205a26:	100c                	addi	a1,sp,32
ffffffffc0205a28:	cacff0ef          	jal	ra,ffffffffc0204ed4 <set_proc_name>
}
ffffffffc0205a2c:	60ea                	ld	ra,152(sp)
ffffffffc0205a2e:	644a                	ld	s0,144(sp)
ffffffffc0205a30:	854e                	mv	a0,s3
ffffffffc0205a32:	64aa                	ld	s1,136(sp)
ffffffffc0205a34:	690a                	ld	s2,128(sp)
ffffffffc0205a36:	79e6                	ld	s3,120(sp)
ffffffffc0205a38:	7a46                	ld	s4,112(sp)
ffffffffc0205a3a:	7aa6                	ld	s5,104(sp)
ffffffffc0205a3c:	7b06                	ld	s6,96(sp)
ffffffffc0205a3e:	6be6                	ld	s7,88(sp)
ffffffffc0205a40:	6c46                	ld	s8,80(sp)
ffffffffc0205a42:	6ca6                	ld	s9,72(sp)
ffffffffc0205a44:	6d06                	ld	s10,64(sp)
ffffffffc0205a46:	7de2                	ld	s11,56(sp)
ffffffffc0205a48:	610d                	addi	sp,sp,160
ffffffffc0205a4a:	8082                	ret
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0205a4c:	7410                	ld	a2,40(s0)
ffffffffc0205a4e:	701c                	ld	a5,32(s0)
ffffffffc0205a50:	20f66363          	bltu	a2,a5,ffffffffc0205c56 <do_execve+0x44e>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0205a54:	405c                	lw	a5,4(s0)
            vm_flags |= VM_EXEC;
ffffffffc0205a56:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W)
ffffffffc0205a5a:	0027f713          	andi	a4,a5,2
            vm_flags |= VM_EXEC;
ffffffffc0205a5e:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W)
ffffffffc0205a60:	0e071263          	bnez	a4,ffffffffc0205b44 <do_execve+0x33c>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a64:	4745                	li	a4,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0205a66:	8b91                	andi	a5,a5,4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a68:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R)
ffffffffc0205a6a:	c789                	beqz	a5,ffffffffc0205a74 <do_execve+0x26c>
            perm |= PTE_R;
ffffffffc0205a6c:	47cd                	li	a5,19
            vm_flags |= VM_READ;
ffffffffc0205a6e:	0016e693          	ori	a3,a3,1
            perm |= PTE_R;
ffffffffc0205a72:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE)
ffffffffc0205a74:	0026f793          	andi	a5,a3,2
ffffffffc0205a78:	efe1                	bnez	a5,ffffffffc0205b50 <do_execve+0x348>
        if (vm_flags & VM_EXEC)
ffffffffc0205a7a:	0046f793          	andi	a5,a3,4
ffffffffc0205a7e:	c789                	beqz	a5,ffffffffc0205a88 <do_execve+0x280>
            perm |= PTE_X;
ffffffffc0205a80:	6782                	ld	a5,0(sp)
ffffffffc0205a82:	0087e793          	ori	a5,a5,8
ffffffffc0205a86:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0205a88:	680c                	ld	a1,16(s0)
ffffffffc0205a8a:	4701                	li	a4,0
ffffffffc0205a8c:	854a                	mv	a0,s2
ffffffffc0205a8e:	811fe0ef          	jal	ra,ffffffffc020429e <mm_map>
ffffffffc0205a92:	89aa                	mv	s3,a0
ffffffffc0205a94:	e541                	bnez	a0,ffffffffc0205b1c <do_execve+0x314>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a96:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205a9a:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a9e:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205aa2:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205aa4:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205aa6:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205aa8:	00fbfc33          	and	s8,s7,a5
        while (start < end)
ffffffffc0205aac:	053bef63          	bltu	s7,s3,ffffffffc0205b0a <do_execve+0x302>
ffffffffc0205ab0:	aa79                	j	ffffffffc0205c4e <do_execve+0x446>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205ab2:	6785                	lui	a5,0x1
ffffffffc0205ab4:	418b8533          	sub	a0,s7,s8
ffffffffc0205ab8:	9c3e                	add	s8,s8,a5
ffffffffc0205aba:	417c0833          	sub	a6,s8,s7
            if (end < la)
ffffffffc0205abe:	0189f463          	bleu	s8,s3,ffffffffc0205ac6 <do_execve+0x2be>
                size -= la - end;
ffffffffc0205ac2:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205ac6:	000db683          	ld	a3,0(s11)
ffffffffc0205aca:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205ace:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205ad0:	40d486b3          	sub	a3,s1,a3
ffffffffc0205ad4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205ad6:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205ada:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205adc:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205ae0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205ae2:	16c5fc63          	bleu	a2,a1,ffffffffc0205c5a <do_execve+0x452>
ffffffffc0205ae6:	000a7797          	auipc	a5,0xa7
ffffffffc0205aea:	af278793          	addi	a5,a5,-1294 # ffffffffc02ac5d8 <va_pa_offset>
ffffffffc0205aee:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205af2:	85d6                	mv	a1,s5
ffffffffc0205af4:	8642                	mv	a2,a6
ffffffffc0205af6:	96c6                	add	a3,a3,a7
ffffffffc0205af8:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205afa:	9bc2                	add	s7,s7,a6
ffffffffc0205afc:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205afe:	329000ef          	jal	ra,ffffffffc0206626 <memcpy>
            start += size, from += size;
ffffffffc0205b02:	6842                	ld	a6,16(sp)
ffffffffc0205b04:	9ac2                	add	s5,s5,a6
        while (start < end)
ffffffffc0205b06:	053bf863          	bleu	s3,s7,ffffffffc0205b56 <do_execve+0x34e>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0205b0a:	01893503          	ld	a0,24(s2)
ffffffffc0205b0e:	6602                	ld	a2,0(sp)
ffffffffc0205b10:	85e2                	mv	a1,s8
ffffffffc0205b12:	fe6fd0ef          	jal	ra,ffffffffc02032f8 <pgdir_alloc_page>
ffffffffc0205b16:	84aa                	mv	s1,a0
ffffffffc0205b18:	fd49                	bnez	a0,ffffffffc0205ab2 <do_execve+0x2aa>
        ret = -E_NO_MEM;
ffffffffc0205b1a:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205b1c:	854a                	mv	a0,s2
ffffffffc0205b1e:	8cffe0ef          	jal	ra,ffffffffc02043ec <exit_mmap>
    put_pgdir(mm);
ffffffffc0205b22:	854a                	mv	a0,s2
ffffffffc0205b24:	aa6ff0ef          	jal	ra,ffffffffc0204dca <put_pgdir>
    mm_destroy(mm);
ffffffffc0205b28:	854a                	mv	a0,s2
ffffffffc0205b2a:	f22fe0ef          	jal	ra,ffffffffc020424c <mm_destroy>
    return ret;
ffffffffc0205b2e:	b345                	j	ffffffffc02058ce <do_execve+0xc6>
            exit_mmap(mm);  // 清空内存管理部分和对应页表
ffffffffc0205b30:	854a                	mv	a0,s2
ffffffffc0205b32:	8bbfe0ef          	jal	ra,ffffffffc02043ec <exit_mmap>
            put_pgdir(mm);  // 清空页表
ffffffffc0205b36:	854a                	mv	a0,s2
ffffffffc0205b38:	a92ff0ef          	jal	ra,ffffffffc0204dca <put_pgdir>
            mm_destroy(mm); // 清空缓存
ffffffffc0205b3c:	854a                	mv	a0,s2
ffffffffc0205b3e:	f0efe0ef          	jal	ra,ffffffffc020424c <mm_destroy>
ffffffffc0205b42:	bba1                	j	ffffffffc020589a <do_execve+0x92>
            vm_flags |= VM_WRITE;
ffffffffc0205b44:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0205b48:	8b91                	andi	a5,a5,4
            vm_flags |= VM_WRITE;
ffffffffc0205b4a:	2681                	sext.w	a3,a3
        if (ph->p_flags & ELF_PF_R)
ffffffffc0205b4c:	f20790e3          	bnez	a5,ffffffffc0205a6c <do_execve+0x264>
            perm |= (PTE_W | PTE_R);
ffffffffc0205b50:	47dd                	li	a5,23
ffffffffc0205b52:	e03e                	sd	a5,0(sp)
ffffffffc0205b54:	b71d                	j	ffffffffc0205a7a <do_execve+0x272>
ffffffffc0205b56:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205b5a:	7414                	ld	a3,40(s0)
ffffffffc0205b5c:	99b6                	add	s3,s3,a3
        if (start < la)
ffffffffc0205b5e:	098bf163          	bleu	s8,s7,ffffffffc0205be0 <do_execve+0x3d8>
            if (start == end)
ffffffffc0205b62:	df7988e3          	beq	s3,s7,ffffffffc0205952 <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205b66:	6505                	lui	a0,0x1
ffffffffc0205b68:	955e                	add	a0,a0,s7
ffffffffc0205b6a:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205b6e:	41798ab3          	sub	s5,s3,s7
            if (end < la)
ffffffffc0205b72:	0d89fb63          	bleu	s8,s3,ffffffffc0205c48 <do_execve+0x440>
    return page - pages + nbase;
ffffffffc0205b76:	000db683          	ld	a3,0(s11)
ffffffffc0205b7a:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205b7e:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205b80:	40d486b3          	sub	a3,s1,a3
ffffffffc0205b84:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205b86:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205b8a:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205b8c:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b90:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b92:	0cc5f463          	bleu	a2,a1,ffffffffc0205c5a <do_execve+0x452>
ffffffffc0205b96:	000a7617          	auipc	a2,0xa7
ffffffffc0205b9a:	a4260613          	addi	a2,a2,-1470 # ffffffffc02ac5d8 <va_pa_offset>
ffffffffc0205b9e:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205ba2:	4581                	li	a1,0
ffffffffc0205ba4:	8656                	mv	a2,s5
ffffffffc0205ba6:	96c2                	add	a3,a3,a6
ffffffffc0205ba8:	9536                	add	a0,a0,a3
ffffffffc0205baa:	26b000ef          	jal	ra,ffffffffc0206614 <memset>
            start += size;
ffffffffc0205bae:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205bb2:	0389f463          	bleu	s8,s3,ffffffffc0205bda <do_execve+0x3d2>
ffffffffc0205bb6:	d8e98ee3          	beq	s3,a4,ffffffffc0205952 <do_execve+0x14a>
ffffffffc0205bba:	00003697          	auipc	a3,0x3
ffffffffc0205bbe:	90668693          	addi	a3,a3,-1786 # ffffffffc02084c0 <default_pmm_manager+0x1148>
ffffffffc0205bc2:	00001617          	auipc	a2,0x1
ffffffffc0205bc6:	06e60613          	addi	a2,a2,110 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0205bca:	2bd00593          	li	a1,701
ffffffffc0205bce:	00003517          	auipc	a0,0x3
ffffffffc0205bd2:	d2250513          	addi	a0,a0,-734 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc0205bd6:	8affa0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0205bda:	ff8710e3          	bne	a4,s8,ffffffffc0205bba <do_execve+0x3b2>
ffffffffc0205bde:	8be2                	mv	s7,s8
ffffffffc0205be0:	000a7a97          	auipc	s5,0xa7
ffffffffc0205be4:	9f8a8a93          	addi	s5,s5,-1544 # ffffffffc02ac5d8 <va_pa_offset>
        while (start < end)
ffffffffc0205be8:	053be763          	bltu	s7,s3,ffffffffc0205c36 <do_execve+0x42e>
ffffffffc0205bec:	b39d                	j	ffffffffc0205952 <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205bee:	6785                	lui	a5,0x1
ffffffffc0205bf0:	418b8533          	sub	a0,s7,s8
ffffffffc0205bf4:	9c3e                	add	s8,s8,a5
ffffffffc0205bf6:	417c0633          	sub	a2,s8,s7
            if (end < la)
ffffffffc0205bfa:	0189f463          	bleu	s8,s3,ffffffffc0205c02 <do_execve+0x3fa>
                size -= la - end;
ffffffffc0205bfe:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205c02:	000db683          	ld	a3,0(s11)
ffffffffc0205c06:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205c0a:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205c0c:	40d486b3          	sub	a3,s1,a3
ffffffffc0205c10:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205c12:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205c16:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205c18:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c1c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c1e:	02b87e63          	bleu	a1,a6,ffffffffc0205c5a <do_execve+0x452>
ffffffffc0205c22:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205c26:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c28:	4581                	li	a1,0
ffffffffc0205c2a:	96c2                	add	a3,a3,a6
ffffffffc0205c2c:	9536                	add	a0,a0,a3
ffffffffc0205c2e:	1e7000ef          	jal	ra,ffffffffc0206614 <memset>
        while (start < end)
ffffffffc0205c32:	d33bf0e3          	bleu	s3,s7,ffffffffc0205952 <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0205c36:	01893503          	ld	a0,24(s2)
ffffffffc0205c3a:	6602                	ld	a2,0(sp)
ffffffffc0205c3c:	85e2                	mv	a1,s8
ffffffffc0205c3e:	ebafd0ef          	jal	ra,ffffffffc02032f8 <pgdir_alloc_page>
ffffffffc0205c42:	84aa                	mv	s1,a0
ffffffffc0205c44:	f54d                	bnez	a0,ffffffffc0205bee <do_execve+0x3e6>
ffffffffc0205c46:	bdd1                	j	ffffffffc0205b1a <do_execve+0x312>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205c48:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205c4c:	b72d                	j	ffffffffc0205b76 <do_execve+0x36e>
        while (start < end)
ffffffffc0205c4e:	89de                	mv	s3,s7
ffffffffc0205c50:	b729                	j	ffffffffc0205b5a <do_execve+0x352>
        return -E_INVAL;
ffffffffc0205c52:	59f5                	li	s3,-3
ffffffffc0205c54:	bbe1                	j	ffffffffc0205a2c <do_execve+0x224>
            ret = -E_INVAL_ELF;
ffffffffc0205c56:	59e1                	li	s3,-8
ffffffffc0205c58:	b5d1                	j	ffffffffc0205b1c <do_execve+0x314>
ffffffffc0205c5a:	00001617          	auipc	a2,0x1
ffffffffc0205c5e:	76e60613          	addi	a2,a2,1902 # ffffffffc02073c8 <default_pmm_manager+0x50>
ffffffffc0205c62:	06900593          	li	a1,105
ffffffffc0205c66:	00001517          	auipc	a0,0x1
ffffffffc0205c6a:	78a50513          	addi	a0,a0,1930 # ffffffffc02073f0 <default_pmm_manager+0x78>
ffffffffc0205c6e:	817fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205c72:	00001617          	auipc	a2,0x1
ffffffffc0205c76:	78e60613          	addi	a2,a2,1934 # ffffffffc0207400 <default_pmm_manager+0x88>
ffffffffc0205c7a:	2dc00593          	li	a1,732
ffffffffc0205c7e:	00003517          	auipc	a0,0x3
ffffffffc0205c82:	c7250513          	addi	a0,a0,-910 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc0205c86:	ffefa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205c8a:	00003697          	auipc	a3,0x3
ffffffffc0205c8e:	94e68693          	addi	a3,a3,-1714 # ffffffffc02085d8 <default_pmm_manager+0x1260>
ffffffffc0205c92:	00001617          	auipc	a2,0x1
ffffffffc0205c96:	f9e60613          	addi	a2,a2,-98 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0205c9a:	2d700593          	li	a1,727
ffffffffc0205c9e:	00003517          	auipc	a0,0x3
ffffffffc0205ca2:	c5250513          	addi	a0,a0,-942 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc0205ca6:	fdefa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205caa:	00003697          	auipc	a3,0x3
ffffffffc0205cae:	8e668693          	addi	a3,a3,-1818 # ffffffffc0208590 <default_pmm_manager+0x1218>
ffffffffc0205cb2:	00001617          	auipc	a2,0x1
ffffffffc0205cb6:	f7e60613          	addi	a2,a2,-130 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0205cba:	2d600593          	li	a1,726
ffffffffc0205cbe:	00003517          	auipc	a0,0x3
ffffffffc0205cc2:	c3250513          	addi	a0,a0,-974 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc0205cc6:	fbefa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205cca:	00003697          	auipc	a3,0x3
ffffffffc0205cce:	87e68693          	addi	a3,a3,-1922 # ffffffffc0208548 <default_pmm_manager+0x11d0>
ffffffffc0205cd2:	00001617          	auipc	a2,0x1
ffffffffc0205cd6:	f5e60613          	addi	a2,a2,-162 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0205cda:	2d500593          	li	a1,725
ffffffffc0205cde:	00003517          	auipc	a0,0x3
ffffffffc0205ce2:	c1250513          	addi	a0,a0,-1006 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc0205ce6:	f9efa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0205cea:	00003697          	auipc	a3,0x3
ffffffffc0205cee:	81668693          	addi	a3,a3,-2026 # ffffffffc0208500 <default_pmm_manager+0x1188>
ffffffffc0205cf2:	00001617          	auipc	a2,0x1
ffffffffc0205cf6:	f3e60613          	addi	a2,a2,-194 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0205cfa:	2d400593          	li	a1,724
ffffffffc0205cfe:	00003517          	auipc	a0,0x3
ffffffffc0205d02:	bf250513          	addi	a0,a0,-1038 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc0205d06:	f7efa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205d0a <do_yield>:
    current->need_resched = 1;
ffffffffc0205d0a:	000a7797          	auipc	a5,0xa7
ffffffffc0205d0e:	88678793          	addi	a5,a5,-1914 # ffffffffc02ac590 <current>
ffffffffc0205d12:	639c                	ld	a5,0(a5)
ffffffffc0205d14:	4705                	li	a4,1
}
ffffffffc0205d16:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205d18:	ef98                	sd	a4,24(a5)
}
ffffffffc0205d1a:	8082                	ret

ffffffffc0205d1c <do_wait>:
{
ffffffffc0205d1c:	1101                	addi	sp,sp,-32
ffffffffc0205d1e:	e822                	sd	s0,16(sp)
ffffffffc0205d20:	e426                	sd	s1,8(sp)
ffffffffc0205d22:	ec06                	sd	ra,24(sp)
ffffffffc0205d24:	842e                	mv	s0,a1
ffffffffc0205d26:	84aa                	mv	s1,a0
    if (code_store != NULL)
ffffffffc0205d28:	cd81                	beqz	a1,ffffffffc0205d40 <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205d2a:	000a7797          	auipc	a5,0xa7
ffffffffc0205d2e:	86678793          	addi	a5,a5,-1946 # ffffffffc02ac590 <current>
ffffffffc0205d32:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0205d34:	4685                	li	a3,1
ffffffffc0205d36:	4611                	li	a2,4
ffffffffc0205d38:	7788                	ld	a0,40(a5)
ffffffffc0205d3a:	d8bfe0ef          	jal	ra,ffffffffc0204ac4 <user_mem_check>
ffffffffc0205d3e:	c909                	beqz	a0,ffffffffc0205d50 <do_wait+0x34>
ffffffffc0205d40:	85a2                	mv	a1,s0
}
ffffffffc0205d42:	6442                	ld	s0,16(sp)
ffffffffc0205d44:	60e2                	ld	ra,24(sp)
ffffffffc0205d46:	8526                	mv	a0,s1
ffffffffc0205d48:	64a2                	ld	s1,8(sp)
ffffffffc0205d4a:	6105                	addi	sp,sp,32
ffffffffc0205d4c:	fecff06f          	j	ffffffffc0205538 <do_wait.part.1>
ffffffffc0205d50:	60e2                	ld	ra,24(sp)
ffffffffc0205d52:	6442                	ld	s0,16(sp)
ffffffffc0205d54:	64a2                	ld	s1,8(sp)
ffffffffc0205d56:	5575                	li	a0,-3
ffffffffc0205d58:	6105                	addi	sp,sp,32
ffffffffc0205d5a:	8082                	ret

ffffffffc0205d5c <do_kill>:
{
ffffffffc0205d5c:	1141                	addi	sp,sp,-16
ffffffffc0205d5e:	e406                	sd	ra,8(sp)
ffffffffc0205d60:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL)
ffffffffc0205d62:	a08ff0ef          	jal	ra,ffffffffc0204f6a <find_proc>
ffffffffc0205d66:	cd0d                	beqz	a0,ffffffffc0205da0 <do_kill+0x44>
        if (!(proc->flags & PF_EXITING))
ffffffffc0205d68:	0b052703          	lw	a4,176(a0)
ffffffffc0205d6c:	00177693          	andi	a3,a4,1
ffffffffc0205d70:	e695                	bnez	a3,ffffffffc0205d9c <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205d72:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205d76:	00176713          	ori	a4,a4,1
ffffffffc0205d7a:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205d7e:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205d80:	0006c763          	bltz	a3,ffffffffc0205d8e <do_kill+0x32>
}
ffffffffc0205d84:	8522                	mv	a0,s0
ffffffffc0205d86:	60a2                	ld	ra,8(sp)
ffffffffc0205d88:	6402                	ld	s0,0(sp)
ffffffffc0205d8a:	0141                	addi	sp,sp,16
ffffffffc0205d8c:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205d8e:	1e6000ef          	jal	ra,ffffffffc0205f74 <wakeup_proc>
}
ffffffffc0205d92:	8522                	mv	a0,s0
ffffffffc0205d94:	60a2                	ld	ra,8(sp)
ffffffffc0205d96:	6402                	ld	s0,0(sp)
ffffffffc0205d98:	0141                	addi	sp,sp,16
ffffffffc0205d9a:	8082                	ret
        return -E_KILLED;
ffffffffc0205d9c:	545d                	li	s0,-9
ffffffffc0205d9e:	b7dd                	j	ffffffffc0205d84 <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205da0:	5475                	li	s0,-3
ffffffffc0205da2:	b7cd                	j	ffffffffc0205d84 <do_kill+0x28>

ffffffffc0205da4 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205da4:	000a7797          	auipc	a5,0xa7
ffffffffc0205da8:	92c78793          	addi	a5,a5,-1748 # ffffffffc02ac6d0 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc0205dac:	1101                	addi	sp,sp,-32
ffffffffc0205dae:	000a7717          	auipc	a4,0xa7
ffffffffc0205db2:	92f73523          	sd	a5,-1750(a4) # ffffffffc02ac6d8 <proc_list+0x8>
ffffffffc0205db6:	000a7717          	auipc	a4,0xa7
ffffffffc0205dba:	90f73d23          	sd	a5,-1766(a4) # ffffffffc02ac6d0 <proc_list>
ffffffffc0205dbe:	ec06                	sd	ra,24(sp)
ffffffffc0205dc0:	e822                	sd	s0,16(sp)
ffffffffc0205dc2:	e426                	sd	s1,8(sp)
ffffffffc0205dc4:	000a2797          	auipc	a5,0xa2
ffffffffc0205dc8:	79478793          	addi	a5,a5,1940 # ffffffffc02a8558 <hash_list>
ffffffffc0205dcc:	000a6717          	auipc	a4,0xa6
ffffffffc0205dd0:	78c70713          	addi	a4,a4,1932 # ffffffffc02ac558 <is_panic>
ffffffffc0205dd4:	e79c                	sd	a5,8(a5)
ffffffffc0205dd6:	e39c                	sd	a5,0(a5)
ffffffffc0205dd8:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0205dda:	fee79de3          	bne	a5,a4,ffffffffc0205dd4 <proc_init+0x30>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc0205dde:	eebfe0ef          	jal	ra,ffffffffc0204cc8 <alloc_proc>
ffffffffc0205de2:	000a6717          	auipc	a4,0xa6
ffffffffc0205de6:	7aa73b23          	sd	a0,1974(a4) # ffffffffc02ac598 <idleproc>
ffffffffc0205dea:	000a6497          	auipc	s1,0xa6
ffffffffc0205dee:	7ae48493          	addi	s1,s1,1966 # ffffffffc02ac598 <idleproc>
ffffffffc0205df2:	c559                	beqz	a0,ffffffffc0205e80 <proc_init+0xdc>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205df4:	4709                	li	a4,2
ffffffffc0205df6:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205df8:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205dfa:	00003717          	auipc	a4,0x3
ffffffffc0205dfe:	20670713          	addi	a4,a4,518 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205e02:	00003597          	auipc	a1,0x3
ffffffffc0205e06:	a0658593          	addi	a1,a1,-1530 # ffffffffc0208808 <default_pmm_manager+0x1490>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e0a:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205e0c:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205e0e:	8c6ff0ef          	jal	ra,ffffffffc0204ed4 <set_proc_name>
    nr_process++;
ffffffffc0205e12:	000a6797          	auipc	a5,0xa6
ffffffffc0205e16:	79678793          	addi	a5,a5,1942 # ffffffffc02ac5a8 <nr_process>
ffffffffc0205e1a:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205e1c:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e1e:	4601                	li	a2,0
    nr_process++;
ffffffffc0205e20:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e22:	4581                	li	a1,0
ffffffffc0205e24:	00000517          	auipc	a0,0x0
ffffffffc0205e28:	8bc50513          	addi	a0,a0,-1860 # ffffffffc02056e0 <init_main>
    nr_process++;
ffffffffc0205e2c:	000a6697          	auipc	a3,0xa6
ffffffffc0205e30:	76f6ae23          	sw	a5,1916(a3) # ffffffffc02ac5a8 <nr_process>
    current = idleproc;
ffffffffc0205e34:	000a6797          	auipc	a5,0xa6
ffffffffc0205e38:	74e7be23          	sd	a4,1884(a5) # ffffffffc02ac590 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e3c:	d5eff0ef          	jal	ra,ffffffffc020539a <kernel_thread>
    if (pid <= 0)
ffffffffc0205e40:	08a05c63          	blez	a0,ffffffffc0205ed8 <proc_init+0x134>
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205e44:	926ff0ef          	jal	ra,ffffffffc0204f6a <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205e48:	00003597          	auipc	a1,0x3
ffffffffc0205e4c:	9e858593          	addi	a1,a1,-1560 # ffffffffc0208830 <default_pmm_manager+0x14b8>
    initproc = find_proc(pid);
ffffffffc0205e50:	000a6797          	auipc	a5,0xa6
ffffffffc0205e54:	74a7b823          	sd	a0,1872(a5) # ffffffffc02ac5a0 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205e58:	87cff0ef          	jal	ra,ffffffffc0204ed4 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e5c:	609c                	ld	a5,0(s1)
ffffffffc0205e5e:	cfa9                	beqz	a5,ffffffffc0205eb8 <proc_init+0x114>
ffffffffc0205e60:	43dc                	lw	a5,4(a5)
ffffffffc0205e62:	ebb9                	bnez	a5,ffffffffc0205eb8 <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e64:	000a6797          	auipc	a5,0xa6
ffffffffc0205e68:	73c78793          	addi	a5,a5,1852 # ffffffffc02ac5a0 <initproc>
ffffffffc0205e6c:	639c                	ld	a5,0(a5)
ffffffffc0205e6e:	c78d                	beqz	a5,ffffffffc0205e98 <proc_init+0xf4>
ffffffffc0205e70:	43dc                	lw	a5,4(a5)
ffffffffc0205e72:	02879363          	bne	a5,s0,ffffffffc0205e98 <proc_init+0xf4>
}
ffffffffc0205e76:	60e2                	ld	ra,24(sp)
ffffffffc0205e78:	6442                	ld	s0,16(sp)
ffffffffc0205e7a:	64a2                	ld	s1,8(sp)
ffffffffc0205e7c:	6105                	addi	sp,sp,32
ffffffffc0205e7e:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205e80:	00003617          	auipc	a2,0x3
ffffffffc0205e84:	97060613          	addi	a2,a2,-1680 # ffffffffc02087f0 <default_pmm_manager+0x1478>
ffffffffc0205e88:	3f200593          	li	a1,1010
ffffffffc0205e8c:	00003517          	auipc	a0,0x3
ffffffffc0205e90:	a6450513          	addi	a0,a0,-1436 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc0205e94:	df0fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e98:	00003697          	auipc	a3,0x3
ffffffffc0205e9c:	9c868693          	addi	a3,a3,-1592 # ffffffffc0208860 <default_pmm_manager+0x14e8>
ffffffffc0205ea0:	00001617          	auipc	a2,0x1
ffffffffc0205ea4:	d9060613          	addi	a2,a2,-624 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0205ea8:	40800593          	li	a1,1032
ffffffffc0205eac:	00003517          	auipc	a0,0x3
ffffffffc0205eb0:	a4450513          	addi	a0,a0,-1468 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc0205eb4:	dd0fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205eb8:	00003697          	auipc	a3,0x3
ffffffffc0205ebc:	98068693          	addi	a3,a3,-1664 # ffffffffc0208838 <default_pmm_manager+0x14c0>
ffffffffc0205ec0:	00001617          	auipc	a2,0x1
ffffffffc0205ec4:	d7060613          	addi	a2,a2,-656 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0205ec8:	40700593          	li	a1,1031
ffffffffc0205ecc:	00003517          	auipc	a0,0x3
ffffffffc0205ed0:	a2450513          	addi	a0,a0,-1500 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc0205ed4:	db0fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("create init_main failed.\n");
ffffffffc0205ed8:	00003617          	auipc	a2,0x3
ffffffffc0205edc:	93860613          	addi	a2,a2,-1736 # ffffffffc0208810 <default_pmm_manager+0x1498>
ffffffffc0205ee0:	40100593          	li	a1,1025
ffffffffc0205ee4:	00003517          	auipc	a0,0x3
ffffffffc0205ee8:	a0c50513          	addi	a0,a0,-1524 # ffffffffc02088f0 <default_pmm_manager+0x1578>
ffffffffc0205eec:	d98fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205ef0 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc0205ef0:	1141                	addi	sp,sp,-16
ffffffffc0205ef2:	e022                	sd	s0,0(sp)
ffffffffc0205ef4:	e406                	sd	ra,8(sp)
ffffffffc0205ef6:	000a6417          	auipc	s0,0xa6
ffffffffc0205efa:	69a40413          	addi	s0,s0,1690 # ffffffffc02ac590 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc0205efe:	6018                	ld	a4,0(s0)
ffffffffc0205f00:	6f1c                	ld	a5,24(a4)
ffffffffc0205f02:	dffd                	beqz	a5,ffffffffc0205f00 <cpu_idle+0x10>
        {
            schedule();
ffffffffc0205f04:	0ec000ef          	jal	ra,ffffffffc0205ff0 <schedule>
ffffffffc0205f08:	bfdd                	j	ffffffffc0205efe <cpu_idle+0xe>

ffffffffc0205f0a <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205f0a:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205f0e:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205f12:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205f14:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205f16:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205f1a:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205f1e:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205f22:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205f26:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205f2a:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0205f2e:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205f32:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205f36:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205f3a:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205f3e:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205f42:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205f46:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0205f48:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205f4a:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205f4e:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205f52:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205f56:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0205f5a:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0205f5e:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0205f62:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0205f66:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0205f6a:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0205f6e:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0205f72:	8082                	ret

ffffffffc0205f74 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f74:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205f76:	1101                	addi	sp,sp,-32
ffffffffc0205f78:	ec06                	sd	ra,24(sp)
ffffffffc0205f7a:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f7c:	478d                	li	a5,3
ffffffffc0205f7e:	04f70a63          	beq	a4,a5,ffffffffc0205fd2 <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f82:	100027f3          	csrr	a5,sstatus
ffffffffc0205f86:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205f88:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f8a:	ef8d                	bnez	a5,ffffffffc0205fc4 <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205f8c:	4789                	li	a5,2
ffffffffc0205f8e:	00f70f63          	beq	a4,a5,ffffffffc0205fac <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc0205f92:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0205f94:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc0205f98:	e409                	bnez	s0,ffffffffc0205fa2 <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205f9a:	60e2                	ld	ra,24(sp)
ffffffffc0205f9c:	6442                	ld	s0,16(sp)
ffffffffc0205f9e:	6105                	addi	sp,sp,32
ffffffffc0205fa0:	8082                	ret
ffffffffc0205fa2:	6442                	ld	s0,16(sp)
ffffffffc0205fa4:	60e2                	ld	ra,24(sp)
ffffffffc0205fa6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205fa8:	eacfa06f          	j	ffffffffc0200654 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205fac:	00003617          	auipc	a2,0x3
ffffffffc0205fb0:	99460613          	addi	a2,a2,-1644 # ffffffffc0208940 <default_pmm_manager+0x15c8>
ffffffffc0205fb4:	45c9                	li	a1,18
ffffffffc0205fb6:	00003517          	auipc	a0,0x3
ffffffffc0205fba:	97250513          	addi	a0,a0,-1678 # ffffffffc0208928 <default_pmm_manager+0x15b0>
ffffffffc0205fbe:	d32fa0ef          	jal	ra,ffffffffc02004f0 <__warn>
ffffffffc0205fc2:	bfd9                	j	ffffffffc0205f98 <wakeup_proc+0x24>
ffffffffc0205fc4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205fc6:	e94fa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0205fca:	6522                	ld	a0,8(sp)
ffffffffc0205fcc:	4405                	li	s0,1
ffffffffc0205fce:	4118                	lw	a4,0(a0)
ffffffffc0205fd0:	bf75                	j	ffffffffc0205f8c <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205fd2:	00003697          	auipc	a3,0x3
ffffffffc0205fd6:	93668693          	addi	a3,a3,-1738 # ffffffffc0208908 <default_pmm_manager+0x1590>
ffffffffc0205fda:	00001617          	auipc	a2,0x1
ffffffffc0205fde:	c5660613          	addi	a2,a2,-938 # ffffffffc0206c30 <commands+0x4c0>
ffffffffc0205fe2:	45a5                	li	a1,9
ffffffffc0205fe4:	00003517          	auipc	a0,0x3
ffffffffc0205fe8:	94450513          	addi	a0,a0,-1724 # ffffffffc0208928 <default_pmm_manager+0x15b0>
ffffffffc0205fec:	c98fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205ff0 <schedule>:

void
schedule(void) {
ffffffffc0205ff0:	1141                	addi	sp,sp,-16
ffffffffc0205ff2:	e406                	sd	ra,8(sp)
ffffffffc0205ff4:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205ff6:	100027f3          	csrr	a5,sstatus
ffffffffc0205ffa:	8b89                	andi	a5,a5,2
ffffffffc0205ffc:	4401                	li	s0,0
ffffffffc0205ffe:	e3d1                	bnez	a5,ffffffffc0206082 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0206000:	000a6797          	auipc	a5,0xa6
ffffffffc0206004:	59078793          	addi	a5,a5,1424 # ffffffffc02ac590 <current>
ffffffffc0206008:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020600c:	000a6797          	auipc	a5,0xa6
ffffffffc0206010:	58c78793          	addi	a5,a5,1420 # ffffffffc02ac598 <idleproc>
ffffffffc0206014:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0206016:	0008bc23          	sd	zero,24(a7) # fffffffffff80018 <end+0x3fcd3938>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020601a:	04a88e63          	beq	a7,a0,ffffffffc0206076 <schedule+0x86>
ffffffffc020601e:	0c888693          	addi	a3,a7,200
ffffffffc0206022:	000a6617          	auipc	a2,0xa6
ffffffffc0206026:	6ae60613          	addi	a2,a2,1710 # ffffffffc02ac6d0 <proc_list>
        le = last;
ffffffffc020602a:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc020602c:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc020602e:	4809                	li	a6,2
    return listelm->next;
ffffffffc0206030:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0206032:	00c78863          	beq	a5,a2,ffffffffc0206042 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206036:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc020603a:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc020603e:	01070463          	beq	a4,a6,ffffffffc0206046 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0206042:	fef697e3          	bne	a3,a5,ffffffffc0206030 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206046:	c589                	beqz	a1,ffffffffc0206050 <schedule+0x60>
ffffffffc0206048:	4198                	lw	a4,0(a1)
ffffffffc020604a:	4789                	li	a5,2
ffffffffc020604c:	00f70e63          	beq	a4,a5,ffffffffc0206068 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0206050:	451c                	lw	a5,8(a0)
ffffffffc0206052:	2785                	addiw	a5,a5,1
ffffffffc0206054:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0206056:	00a88463          	beq	a7,a0,ffffffffc020605e <schedule+0x6e>
            proc_run(next);
ffffffffc020605a:	ea5fe0ef          	jal	ra,ffffffffc0204efe <proc_run>
    if (flag) {
ffffffffc020605e:	e419                	bnez	s0,ffffffffc020606c <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206060:	60a2                	ld	ra,8(sp)
ffffffffc0206062:	6402                	ld	s0,0(sp)
ffffffffc0206064:	0141                	addi	sp,sp,16
ffffffffc0206066:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206068:	852e                	mv	a0,a1
ffffffffc020606a:	b7dd                	j	ffffffffc0206050 <schedule+0x60>
}
ffffffffc020606c:	6402                	ld	s0,0(sp)
ffffffffc020606e:	60a2                	ld	ra,8(sp)
ffffffffc0206070:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0206072:	de2fa06f          	j	ffffffffc0200654 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206076:	000a6617          	auipc	a2,0xa6
ffffffffc020607a:	65a60613          	addi	a2,a2,1626 # ffffffffc02ac6d0 <proc_list>
ffffffffc020607e:	86b2                	mv	a3,a2
ffffffffc0206080:	b76d                	j	ffffffffc020602a <schedule+0x3a>
        intr_disable();
ffffffffc0206082:	dd8fa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0206086:	4405                	li	s0,1
ffffffffc0206088:	bfa5                	j	ffffffffc0206000 <schedule+0x10>

ffffffffc020608a <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc020608a:	000a6797          	auipc	a5,0xa6
ffffffffc020608e:	50678793          	addi	a5,a5,1286 # ffffffffc02ac590 <current>
ffffffffc0206092:	639c                	ld	a5,0(a5)
}
ffffffffc0206094:	43c8                	lw	a0,4(a5)
ffffffffc0206096:	8082                	ret

ffffffffc0206098 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206098:	4501                	li	a0,0
ffffffffc020609a:	8082                	ret

ffffffffc020609c <sys_putc>:
    cputchar(c);
ffffffffc020609c:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc020609e:	1141                	addi	sp,sp,-16
ffffffffc02060a0:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc02060a2:	920fa0ef          	jal	ra,ffffffffc02001c2 <cputchar>
}
ffffffffc02060a6:	60a2                	ld	ra,8(sp)
ffffffffc02060a8:	4501                	li	a0,0
ffffffffc02060aa:	0141                	addi	sp,sp,16
ffffffffc02060ac:	8082                	ret

ffffffffc02060ae <sys_kill>:
    return do_kill(pid);
ffffffffc02060ae:	4108                	lw	a0,0(a0)
ffffffffc02060b0:	cadff06f          	j	ffffffffc0205d5c <do_kill>

ffffffffc02060b4 <sys_yield>:
    return do_yield();
ffffffffc02060b4:	c57ff06f          	j	ffffffffc0205d0a <do_yield>

ffffffffc02060b8 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02060b8:	6d14                	ld	a3,24(a0)
ffffffffc02060ba:	6910                	ld	a2,16(a0)
ffffffffc02060bc:	650c                	ld	a1,8(a0)
ffffffffc02060be:	6108                	ld	a0,0(a0)
ffffffffc02060c0:	f48ff06f          	j	ffffffffc0205808 <do_execve>

ffffffffc02060c4 <sys_wait>:
    return do_wait(pid, store);
ffffffffc02060c4:	650c                	ld	a1,8(a0)
ffffffffc02060c6:	4108                	lw	a0,0(a0)
ffffffffc02060c8:	c55ff06f          	j	ffffffffc0205d1c <do_wait>

ffffffffc02060cc <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02060cc:	000a6797          	auipc	a5,0xa6
ffffffffc02060d0:	4c478793          	addi	a5,a5,1220 # ffffffffc02ac590 <current>
ffffffffc02060d4:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc02060d6:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc02060d8:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02060da:	6a0c                	ld	a1,16(a2)
ffffffffc02060dc:	eebfe06f          	j	ffffffffc0204fc6 <do_fork>

ffffffffc02060e0 <sys_exit>:
    return do_exit(error_code);
ffffffffc02060e0:	4108                	lw	a0,0(a0)
ffffffffc02060e2:	b08ff06f          	j	ffffffffc02053ea <do_exit>

ffffffffc02060e6 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02060e6:	715d                	addi	sp,sp,-80
ffffffffc02060e8:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060ea:	000a6497          	auipc	s1,0xa6
ffffffffc02060ee:	4a648493          	addi	s1,s1,1190 # ffffffffc02ac590 <current>
ffffffffc02060f2:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02060f4:	e0a2                	sd	s0,64(sp)
ffffffffc02060f6:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060f8:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02060fa:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060fc:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02060fe:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206102:	0327ee63          	bltu	a5,s2,ffffffffc020613e <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0206106:	00391713          	slli	a4,s2,0x3
ffffffffc020610a:	00003797          	auipc	a5,0x3
ffffffffc020610e:	89e78793          	addi	a5,a5,-1890 # ffffffffc02089a8 <syscalls>
ffffffffc0206112:	97ba                	add	a5,a5,a4
ffffffffc0206114:	639c                	ld	a5,0(a5)
ffffffffc0206116:	c785                	beqz	a5,ffffffffc020613e <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0206118:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc020611a:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc020611c:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc020611e:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0206120:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0206122:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0206124:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0206126:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0206128:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc020612a:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020612c:	0028                	addi	a0,sp,8
ffffffffc020612e:	9782                	jalr	a5
ffffffffc0206130:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0206132:	60a6                	ld	ra,72(sp)
ffffffffc0206134:	6406                	ld	s0,64(sp)
ffffffffc0206136:	74e2                	ld	s1,56(sp)
ffffffffc0206138:	7942                	ld	s2,48(sp)
ffffffffc020613a:	6161                	addi	sp,sp,80
ffffffffc020613c:	8082                	ret
    print_trapframe(tf);
ffffffffc020613e:	8522                	mv	a0,s0
ffffffffc0206140:	f0afa0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0206144:	609c                	ld	a5,0(s1)
ffffffffc0206146:	86ca                	mv	a3,s2
ffffffffc0206148:	00003617          	auipc	a2,0x3
ffffffffc020614c:	81860613          	addi	a2,a2,-2024 # ffffffffc0208960 <default_pmm_manager+0x15e8>
ffffffffc0206150:	43d8                	lw	a4,4(a5)
ffffffffc0206152:	06300593          	li	a1,99
ffffffffc0206156:	0b478793          	addi	a5,a5,180
ffffffffc020615a:	00003517          	auipc	a0,0x3
ffffffffc020615e:	83650513          	addi	a0,a0,-1994 # ffffffffc0208990 <default_pmm_manager+0x1618>
ffffffffc0206162:	b22fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0206166 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0206166:	9e3707b7          	lui	a5,0x9e370
ffffffffc020616a:	2785                	addiw	a5,a5,1
ffffffffc020616c:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0206170:	02000793          	li	a5,32
ffffffffc0206174:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0206178:	00b5553b          	srlw	a0,a0,a1
ffffffffc020617c:	8082                	ret

ffffffffc020617e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020617e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206182:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0206184:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206188:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020618a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020618e:	f022                	sd	s0,32(sp)
ffffffffc0206190:	ec26                	sd	s1,24(sp)
ffffffffc0206192:	e84a                	sd	s2,16(sp)
ffffffffc0206194:	f406                	sd	ra,40(sp)
ffffffffc0206196:	e44e                	sd	s3,8(sp)
ffffffffc0206198:	84aa                	mv	s1,a0
ffffffffc020619a:	892e                	mv	s2,a1
ffffffffc020619c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02061a0:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02061a2:	03067e63          	bleu	a6,a2,ffffffffc02061de <printnum+0x60>
ffffffffc02061a6:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02061a8:	00805763          	blez	s0,ffffffffc02061b6 <printnum+0x38>
ffffffffc02061ac:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02061ae:	85ca                	mv	a1,s2
ffffffffc02061b0:	854e                	mv	a0,s3
ffffffffc02061b2:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02061b4:	fc65                	bnez	s0,ffffffffc02061ac <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02061b6:	1a02                	slli	s4,s4,0x20
ffffffffc02061b8:	020a5a13          	srli	s4,s4,0x20
ffffffffc02061bc:	00003797          	auipc	a5,0x3
ffffffffc02061c0:	b0c78793          	addi	a5,a5,-1268 # ffffffffc0208cc8 <error_string+0xc8>
ffffffffc02061c4:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02061c6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02061c8:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02061cc:	70a2                	ld	ra,40(sp)
ffffffffc02061ce:	69a2                	ld	s3,8(sp)
ffffffffc02061d0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02061d2:	85ca                	mv	a1,s2
ffffffffc02061d4:	8326                	mv	t1,s1
}
ffffffffc02061d6:	6942                	ld	s2,16(sp)
ffffffffc02061d8:	64e2                	ld	s1,24(sp)
ffffffffc02061da:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02061dc:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02061de:	03065633          	divu	a2,a2,a6
ffffffffc02061e2:	8722                	mv	a4,s0
ffffffffc02061e4:	f9bff0ef          	jal	ra,ffffffffc020617e <printnum>
ffffffffc02061e8:	b7f9                	j	ffffffffc02061b6 <printnum+0x38>

ffffffffc02061ea <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02061ea:	7119                	addi	sp,sp,-128
ffffffffc02061ec:	f4a6                	sd	s1,104(sp)
ffffffffc02061ee:	f0ca                	sd	s2,96(sp)
ffffffffc02061f0:	e8d2                	sd	s4,80(sp)
ffffffffc02061f2:	e4d6                	sd	s5,72(sp)
ffffffffc02061f4:	e0da                	sd	s6,64(sp)
ffffffffc02061f6:	fc5e                	sd	s7,56(sp)
ffffffffc02061f8:	f862                	sd	s8,48(sp)
ffffffffc02061fa:	f06a                	sd	s10,32(sp)
ffffffffc02061fc:	fc86                	sd	ra,120(sp)
ffffffffc02061fe:	f8a2                	sd	s0,112(sp)
ffffffffc0206200:	ecce                	sd	s3,88(sp)
ffffffffc0206202:	f466                	sd	s9,40(sp)
ffffffffc0206204:	ec6e                	sd	s11,24(sp)
ffffffffc0206206:	892a                	mv	s2,a0
ffffffffc0206208:	84ae                	mv	s1,a1
ffffffffc020620a:	8d32                	mv	s10,a2
ffffffffc020620c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020620e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206210:	00003a17          	auipc	s4,0x3
ffffffffc0206214:	898a0a13          	addi	s4,s4,-1896 # ffffffffc0208aa8 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206218:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020621c:	00003c17          	auipc	s8,0x3
ffffffffc0206220:	9e4c0c13          	addi	s8,s8,-1564 # ffffffffc0208c00 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206224:	000d4503          	lbu	a0,0(s10)
ffffffffc0206228:	02500793          	li	a5,37
ffffffffc020622c:	001d0413          	addi	s0,s10,1
ffffffffc0206230:	00f50e63          	beq	a0,a5,ffffffffc020624c <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0206234:	c521                	beqz	a0,ffffffffc020627c <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206236:	02500993          	li	s3,37
ffffffffc020623a:	a011                	j	ffffffffc020623e <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc020623c:	c121                	beqz	a0,ffffffffc020627c <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc020623e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206240:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0206242:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206244:	fff44503          	lbu	a0,-1(s0)
ffffffffc0206248:	ff351ae3          	bne	a0,s3,ffffffffc020623c <vprintfmt+0x52>
ffffffffc020624c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0206250:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0206254:	4981                	li	s3,0
ffffffffc0206256:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0206258:	5cfd                	li	s9,-1
ffffffffc020625a:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020625c:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0206260:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206262:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0206266:	0ff6f693          	andi	a3,a3,255
ffffffffc020626a:	00140d13          	addi	s10,s0,1
ffffffffc020626e:	20d5e563          	bltu	a1,a3,ffffffffc0206478 <vprintfmt+0x28e>
ffffffffc0206272:	068a                	slli	a3,a3,0x2
ffffffffc0206274:	96d2                	add	a3,a3,s4
ffffffffc0206276:	4294                	lw	a3,0(a3)
ffffffffc0206278:	96d2                	add	a3,a3,s4
ffffffffc020627a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020627c:	70e6                	ld	ra,120(sp)
ffffffffc020627e:	7446                	ld	s0,112(sp)
ffffffffc0206280:	74a6                	ld	s1,104(sp)
ffffffffc0206282:	7906                	ld	s2,96(sp)
ffffffffc0206284:	69e6                	ld	s3,88(sp)
ffffffffc0206286:	6a46                	ld	s4,80(sp)
ffffffffc0206288:	6aa6                	ld	s5,72(sp)
ffffffffc020628a:	6b06                	ld	s6,64(sp)
ffffffffc020628c:	7be2                	ld	s7,56(sp)
ffffffffc020628e:	7c42                	ld	s8,48(sp)
ffffffffc0206290:	7ca2                	ld	s9,40(sp)
ffffffffc0206292:	7d02                	ld	s10,32(sp)
ffffffffc0206294:	6de2                	ld	s11,24(sp)
ffffffffc0206296:	6109                	addi	sp,sp,128
ffffffffc0206298:	8082                	ret
    if (lflag >= 2) {
ffffffffc020629a:	4705                	li	a4,1
ffffffffc020629c:	008a8593          	addi	a1,s5,8
ffffffffc02062a0:	01074463          	blt	a4,a6,ffffffffc02062a8 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02062a4:	26080363          	beqz	a6,ffffffffc020650a <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02062a8:	000ab603          	ld	a2,0(s5)
ffffffffc02062ac:	46c1                	li	a3,16
ffffffffc02062ae:	8aae                	mv	s5,a1
ffffffffc02062b0:	a06d                	j	ffffffffc020635a <vprintfmt+0x170>
            goto reswitch;
ffffffffc02062b2:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02062b6:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062b8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02062ba:	b765                	j	ffffffffc0206262 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02062bc:	000aa503          	lw	a0,0(s5)
ffffffffc02062c0:	85a6                	mv	a1,s1
ffffffffc02062c2:	0aa1                	addi	s5,s5,8
ffffffffc02062c4:	9902                	jalr	s2
            break;
ffffffffc02062c6:	bfb9                	j	ffffffffc0206224 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02062c8:	4705                	li	a4,1
ffffffffc02062ca:	008a8993          	addi	s3,s5,8
ffffffffc02062ce:	01074463          	blt	a4,a6,ffffffffc02062d6 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02062d2:	22080463          	beqz	a6,ffffffffc02064fa <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02062d6:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02062da:	24044463          	bltz	s0,ffffffffc0206522 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02062de:	8622                	mv	a2,s0
ffffffffc02062e0:	8ace                	mv	s5,s3
ffffffffc02062e2:	46a9                	li	a3,10
ffffffffc02062e4:	a89d                	j	ffffffffc020635a <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02062e6:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02062ea:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02062ec:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02062ee:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02062f2:	8fb5                	xor	a5,a5,a3
ffffffffc02062f4:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02062f8:	1ad74363          	blt	a4,a3,ffffffffc020649e <vprintfmt+0x2b4>
ffffffffc02062fc:	00369793          	slli	a5,a3,0x3
ffffffffc0206300:	97e2                	add	a5,a5,s8
ffffffffc0206302:	639c                	ld	a5,0(a5)
ffffffffc0206304:	18078d63          	beqz	a5,ffffffffc020649e <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0206308:	86be                	mv	a3,a5
ffffffffc020630a:	00000617          	auipc	a2,0x0
ffffffffc020630e:	35e60613          	addi	a2,a2,862 # ffffffffc0206668 <etext+0x2a>
ffffffffc0206312:	85a6                	mv	a1,s1
ffffffffc0206314:	854a                	mv	a0,s2
ffffffffc0206316:	240000ef          	jal	ra,ffffffffc0206556 <printfmt>
ffffffffc020631a:	b729                	j	ffffffffc0206224 <vprintfmt+0x3a>
            lflag ++;
ffffffffc020631c:	00144603          	lbu	a2,1(s0)
ffffffffc0206320:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206322:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206324:	bf3d                	j	ffffffffc0206262 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0206326:	4705                	li	a4,1
ffffffffc0206328:	008a8593          	addi	a1,s5,8
ffffffffc020632c:	01074463          	blt	a4,a6,ffffffffc0206334 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0206330:	1e080263          	beqz	a6,ffffffffc0206514 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0206334:	000ab603          	ld	a2,0(s5)
ffffffffc0206338:	46a1                	li	a3,8
ffffffffc020633a:	8aae                	mv	s5,a1
ffffffffc020633c:	a839                	j	ffffffffc020635a <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc020633e:	03000513          	li	a0,48
ffffffffc0206342:	85a6                	mv	a1,s1
ffffffffc0206344:	e03e                	sd	a5,0(sp)
ffffffffc0206346:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0206348:	85a6                	mv	a1,s1
ffffffffc020634a:	07800513          	li	a0,120
ffffffffc020634e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206350:	0aa1                	addi	s5,s5,8
ffffffffc0206352:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0206356:	6782                	ld	a5,0(sp)
ffffffffc0206358:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020635a:	876e                	mv	a4,s11
ffffffffc020635c:	85a6                	mv	a1,s1
ffffffffc020635e:	854a                	mv	a0,s2
ffffffffc0206360:	e1fff0ef          	jal	ra,ffffffffc020617e <printnum>
            break;
ffffffffc0206364:	b5c1                	j	ffffffffc0206224 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206366:	000ab603          	ld	a2,0(s5)
ffffffffc020636a:	0aa1                	addi	s5,s5,8
ffffffffc020636c:	1c060663          	beqz	a2,ffffffffc0206538 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0206370:	00160413          	addi	s0,a2,1
ffffffffc0206374:	17b05c63          	blez	s11,ffffffffc02064ec <vprintfmt+0x302>
ffffffffc0206378:	02d00593          	li	a1,45
ffffffffc020637c:	14b79263          	bne	a5,a1,ffffffffc02064c0 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206380:	00064783          	lbu	a5,0(a2)
ffffffffc0206384:	0007851b          	sext.w	a0,a5
ffffffffc0206388:	c905                	beqz	a0,ffffffffc02063b8 <vprintfmt+0x1ce>
ffffffffc020638a:	000cc563          	bltz	s9,ffffffffc0206394 <vprintfmt+0x1aa>
ffffffffc020638e:	3cfd                	addiw	s9,s9,-1
ffffffffc0206390:	036c8263          	beq	s9,s6,ffffffffc02063b4 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0206394:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206396:	18098463          	beqz	s3,ffffffffc020651e <vprintfmt+0x334>
ffffffffc020639a:	3781                	addiw	a5,a5,-32
ffffffffc020639c:	18fbf163          	bleu	a5,s7,ffffffffc020651e <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02063a0:	03f00513          	li	a0,63
ffffffffc02063a4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02063a6:	0405                	addi	s0,s0,1
ffffffffc02063a8:	fff44783          	lbu	a5,-1(s0)
ffffffffc02063ac:	3dfd                	addiw	s11,s11,-1
ffffffffc02063ae:	0007851b          	sext.w	a0,a5
ffffffffc02063b2:	fd61                	bnez	a0,ffffffffc020638a <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02063b4:	e7b058e3          	blez	s11,ffffffffc0206224 <vprintfmt+0x3a>
ffffffffc02063b8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02063ba:	85a6                	mv	a1,s1
ffffffffc02063bc:	02000513          	li	a0,32
ffffffffc02063c0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02063c2:	e60d81e3          	beqz	s11,ffffffffc0206224 <vprintfmt+0x3a>
ffffffffc02063c6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02063c8:	85a6                	mv	a1,s1
ffffffffc02063ca:	02000513          	li	a0,32
ffffffffc02063ce:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02063d0:	fe0d94e3          	bnez	s11,ffffffffc02063b8 <vprintfmt+0x1ce>
ffffffffc02063d4:	bd81                	j	ffffffffc0206224 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02063d6:	4705                	li	a4,1
ffffffffc02063d8:	008a8593          	addi	a1,s5,8
ffffffffc02063dc:	01074463          	blt	a4,a6,ffffffffc02063e4 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02063e0:	12080063          	beqz	a6,ffffffffc0206500 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02063e4:	000ab603          	ld	a2,0(s5)
ffffffffc02063e8:	46a9                	li	a3,10
ffffffffc02063ea:	8aae                	mv	s5,a1
ffffffffc02063ec:	b7bd                	j	ffffffffc020635a <vprintfmt+0x170>
ffffffffc02063ee:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02063f2:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063f6:	846a                	mv	s0,s10
ffffffffc02063f8:	b5ad                	j	ffffffffc0206262 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02063fa:	85a6                	mv	a1,s1
ffffffffc02063fc:	02500513          	li	a0,37
ffffffffc0206400:	9902                	jalr	s2
            break;
ffffffffc0206402:	b50d                	j	ffffffffc0206224 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0206404:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0206408:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020640c:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020640e:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0206410:	e40dd9e3          	bgez	s11,ffffffffc0206262 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0206414:	8de6                	mv	s11,s9
ffffffffc0206416:	5cfd                	li	s9,-1
ffffffffc0206418:	b5a9                	j	ffffffffc0206262 <vprintfmt+0x78>
            goto reswitch;
ffffffffc020641a:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc020641e:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206422:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206424:	bd3d                	j	ffffffffc0206262 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0206426:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020642a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020642e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0206430:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0206434:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206438:	fcd56ce3          	bltu	a0,a3,ffffffffc0206410 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020643c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020643e:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0206442:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0206446:	0196873b          	addw	a4,a3,s9
ffffffffc020644a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020644e:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0206452:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0206456:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020645a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020645e:	fcd57fe3          	bleu	a3,a0,ffffffffc020643c <vprintfmt+0x252>
ffffffffc0206462:	b77d                	j	ffffffffc0206410 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0206464:	fffdc693          	not	a3,s11
ffffffffc0206468:	96fd                	srai	a3,a3,0x3f
ffffffffc020646a:	00ddfdb3          	and	s11,s11,a3
ffffffffc020646e:	00144603          	lbu	a2,1(s0)
ffffffffc0206472:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206474:	846a                	mv	s0,s10
ffffffffc0206476:	b3f5                	j	ffffffffc0206262 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0206478:	85a6                	mv	a1,s1
ffffffffc020647a:	02500513          	li	a0,37
ffffffffc020647e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0206480:	fff44703          	lbu	a4,-1(s0)
ffffffffc0206484:	02500793          	li	a5,37
ffffffffc0206488:	8d22                	mv	s10,s0
ffffffffc020648a:	d8f70de3          	beq	a4,a5,ffffffffc0206224 <vprintfmt+0x3a>
ffffffffc020648e:	02500713          	li	a4,37
ffffffffc0206492:	1d7d                	addi	s10,s10,-1
ffffffffc0206494:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0206498:	fee79de3          	bne	a5,a4,ffffffffc0206492 <vprintfmt+0x2a8>
ffffffffc020649c:	b361                	j	ffffffffc0206224 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020649e:	00003617          	auipc	a2,0x3
ffffffffc02064a2:	90a60613          	addi	a2,a2,-1782 # ffffffffc0208da8 <error_string+0x1a8>
ffffffffc02064a6:	85a6                	mv	a1,s1
ffffffffc02064a8:	854a                	mv	a0,s2
ffffffffc02064aa:	0ac000ef          	jal	ra,ffffffffc0206556 <printfmt>
ffffffffc02064ae:	bb9d                	j	ffffffffc0206224 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02064b0:	00003617          	auipc	a2,0x3
ffffffffc02064b4:	8f060613          	addi	a2,a2,-1808 # ffffffffc0208da0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc02064b8:	00003417          	auipc	s0,0x3
ffffffffc02064bc:	8e940413          	addi	s0,s0,-1815 # ffffffffc0208da1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02064c0:	8532                	mv	a0,a2
ffffffffc02064c2:	85e6                	mv	a1,s9
ffffffffc02064c4:	e032                	sd	a2,0(sp)
ffffffffc02064c6:	e43e                	sd	a5,8(sp)
ffffffffc02064c8:	0cc000ef          	jal	ra,ffffffffc0206594 <strnlen>
ffffffffc02064cc:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02064d0:	6602                	ld	a2,0(sp)
ffffffffc02064d2:	01b05d63          	blez	s11,ffffffffc02064ec <vprintfmt+0x302>
ffffffffc02064d6:	67a2                	ld	a5,8(sp)
ffffffffc02064d8:	2781                	sext.w	a5,a5
ffffffffc02064da:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02064dc:	6522                	ld	a0,8(sp)
ffffffffc02064de:	85a6                	mv	a1,s1
ffffffffc02064e0:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02064e2:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02064e4:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02064e6:	6602                	ld	a2,0(sp)
ffffffffc02064e8:	fe0d9ae3          	bnez	s11,ffffffffc02064dc <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064ec:	00064783          	lbu	a5,0(a2)
ffffffffc02064f0:	0007851b          	sext.w	a0,a5
ffffffffc02064f4:	e8051be3          	bnez	a0,ffffffffc020638a <vprintfmt+0x1a0>
ffffffffc02064f8:	b335                	j	ffffffffc0206224 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02064fa:	000aa403          	lw	s0,0(s5)
ffffffffc02064fe:	bbf1                	j	ffffffffc02062da <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0206500:	000ae603          	lwu	a2,0(s5)
ffffffffc0206504:	46a9                	li	a3,10
ffffffffc0206506:	8aae                	mv	s5,a1
ffffffffc0206508:	bd89                	j	ffffffffc020635a <vprintfmt+0x170>
ffffffffc020650a:	000ae603          	lwu	a2,0(s5)
ffffffffc020650e:	46c1                	li	a3,16
ffffffffc0206510:	8aae                	mv	s5,a1
ffffffffc0206512:	b5a1                	j	ffffffffc020635a <vprintfmt+0x170>
ffffffffc0206514:	000ae603          	lwu	a2,0(s5)
ffffffffc0206518:	46a1                	li	a3,8
ffffffffc020651a:	8aae                	mv	s5,a1
ffffffffc020651c:	bd3d                	j	ffffffffc020635a <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc020651e:	9902                	jalr	s2
ffffffffc0206520:	b559                	j	ffffffffc02063a6 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0206522:	85a6                	mv	a1,s1
ffffffffc0206524:	02d00513          	li	a0,45
ffffffffc0206528:	e03e                	sd	a5,0(sp)
ffffffffc020652a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020652c:	8ace                	mv	s5,s3
ffffffffc020652e:	40800633          	neg	a2,s0
ffffffffc0206532:	46a9                	li	a3,10
ffffffffc0206534:	6782                	ld	a5,0(sp)
ffffffffc0206536:	b515                	j	ffffffffc020635a <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0206538:	01b05663          	blez	s11,ffffffffc0206544 <vprintfmt+0x35a>
ffffffffc020653c:	02d00693          	li	a3,45
ffffffffc0206540:	f6d798e3          	bne	a5,a3,ffffffffc02064b0 <vprintfmt+0x2c6>
ffffffffc0206544:	00003417          	auipc	s0,0x3
ffffffffc0206548:	85d40413          	addi	s0,s0,-1955 # ffffffffc0208da1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020654c:	02800513          	li	a0,40
ffffffffc0206550:	02800793          	li	a5,40
ffffffffc0206554:	bd1d                	j	ffffffffc020638a <vprintfmt+0x1a0>

ffffffffc0206556 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206556:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0206558:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020655c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020655e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206560:	ec06                	sd	ra,24(sp)
ffffffffc0206562:	f83a                	sd	a4,48(sp)
ffffffffc0206564:	fc3e                	sd	a5,56(sp)
ffffffffc0206566:	e0c2                	sd	a6,64(sp)
ffffffffc0206568:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020656a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020656c:	c7fff0ef          	jal	ra,ffffffffc02061ea <vprintfmt>
}
ffffffffc0206570:	60e2                	ld	ra,24(sp)
ffffffffc0206572:	6161                	addi	sp,sp,80
ffffffffc0206574:	8082                	ret

ffffffffc0206576 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0206576:	00054783          	lbu	a5,0(a0)
ffffffffc020657a:	cb91                	beqz	a5,ffffffffc020658e <strlen+0x18>
    size_t cnt = 0;
ffffffffc020657c:	4781                	li	a5,0
        cnt ++;
ffffffffc020657e:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0206580:	00f50733          	add	a4,a0,a5
ffffffffc0206584:	00074703          	lbu	a4,0(a4)
ffffffffc0206588:	fb7d                	bnez	a4,ffffffffc020657e <strlen+0x8>
    }
    return cnt;
}
ffffffffc020658a:	853e                	mv	a0,a5
ffffffffc020658c:	8082                	ret
    size_t cnt = 0;
ffffffffc020658e:	4781                	li	a5,0
}
ffffffffc0206590:	853e                	mv	a0,a5
ffffffffc0206592:	8082                	ret

ffffffffc0206594 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206594:	c185                	beqz	a1,ffffffffc02065b4 <strnlen+0x20>
ffffffffc0206596:	00054783          	lbu	a5,0(a0)
ffffffffc020659a:	cf89                	beqz	a5,ffffffffc02065b4 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc020659c:	4781                	li	a5,0
ffffffffc020659e:	a021                	j	ffffffffc02065a6 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02065a0:	00074703          	lbu	a4,0(a4)
ffffffffc02065a4:	c711                	beqz	a4,ffffffffc02065b0 <strnlen+0x1c>
        cnt ++;
ffffffffc02065a6:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02065a8:	00f50733          	add	a4,a0,a5
ffffffffc02065ac:	fef59ae3          	bne	a1,a5,ffffffffc02065a0 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02065b0:	853e                	mv	a0,a5
ffffffffc02065b2:	8082                	ret
    size_t cnt = 0;
ffffffffc02065b4:	4781                	li	a5,0
}
ffffffffc02065b6:	853e                	mv	a0,a5
ffffffffc02065b8:	8082                	ret

ffffffffc02065ba <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02065ba:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02065bc:	0585                	addi	a1,a1,1
ffffffffc02065be:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02065c2:	0785                	addi	a5,a5,1
ffffffffc02065c4:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02065c8:	fb75                	bnez	a4,ffffffffc02065bc <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02065ca:	8082                	ret

ffffffffc02065cc <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02065cc:	00054783          	lbu	a5,0(a0)
ffffffffc02065d0:	0005c703          	lbu	a4,0(a1)
ffffffffc02065d4:	cb91                	beqz	a5,ffffffffc02065e8 <strcmp+0x1c>
ffffffffc02065d6:	00e79c63          	bne	a5,a4,ffffffffc02065ee <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02065da:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02065dc:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02065e0:	0585                	addi	a1,a1,1
ffffffffc02065e2:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02065e6:	fbe5                	bnez	a5,ffffffffc02065d6 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02065e8:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02065ea:	9d19                	subw	a0,a0,a4
ffffffffc02065ec:	8082                	ret
ffffffffc02065ee:	0007851b          	sext.w	a0,a5
ffffffffc02065f2:	9d19                	subw	a0,a0,a4
ffffffffc02065f4:	8082                	ret

ffffffffc02065f6 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02065f6:	00054783          	lbu	a5,0(a0)
ffffffffc02065fa:	cb91                	beqz	a5,ffffffffc020660e <strchr+0x18>
        if (*s == c) {
ffffffffc02065fc:	00b79563          	bne	a5,a1,ffffffffc0206606 <strchr+0x10>
ffffffffc0206600:	a809                	j	ffffffffc0206612 <strchr+0x1c>
ffffffffc0206602:	00b78763          	beq	a5,a1,ffffffffc0206610 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0206606:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0206608:	00054783          	lbu	a5,0(a0)
ffffffffc020660c:	fbfd                	bnez	a5,ffffffffc0206602 <strchr+0xc>
    }
    return NULL;
ffffffffc020660e:	4501                	li	a0,0
}
ffffffffc0206610:	8082                	ret
ffffffffc0206612:	8082                	ret

ffffffffc0206614 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0206614:	ca01                	beqz	a2,ffffffffc0206624 <memset+0x10>
ffffffffc0206616:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0206618:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020661a:	0785                	addi	a5,a5,1
ffffffffc020661c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0206620:	fec79de3          	bne	a5,a2,ffffffffc020661a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0206624:	8082                	ret

ffffffffc0206626 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0206626:	ca19                	beqz	a2,ffffffffc020663c <memcpy+0x16>
ffffffffc0206628:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020662a:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020662c:	0585                	addi	a1,a1,1
ffffffffc020662e:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0206632:	0785                	addi	a5,a5,1
ffffffffc0206634:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0206638:	fec59ae3          	bne	a1,a2,ffffffffc020662c <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020663c:	8082                	ret
