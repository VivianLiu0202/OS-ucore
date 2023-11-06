
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	02e50513          	addi	a0,a0,46 # ffffffffc020a060 <buf>
ffffffffc020003a:	00015617          	auipc	a2,0x15
ffffffffc020003e:	59e60613          	addi	a2,a2,1438 # ffffffffc02155d8 <end>
ffffffffc0200042:	1141                	addi	sp,sp,-16
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
ffffffffc0200048:	e406                	sd	ra,8(sp)
ffffffffc020004a:	637040ef          	jal	ra,ffffffffc0204e80 <memset>
ffffffffc020004e:	49e000ef          	jal	ra,ffffffffc02004ec <cons_init>
ffffffffc0200052:	00005597          	auipc	a1,0x5
ffffffffc0200056:	e7e58593          	addi	a1,a1,-386 # ffffffffc0204ed0 <etext+0x2>
ffffffffc020005a:	00005517          	auipc	a0,0x5
ffffffffc020005e:	e9650513          	addi	a0,a0,-362 # ffffffffc0204ef0 <etext+0x22>
ffffffffc0200062:	128000ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200066:	16c000ef          	jal	ra,ffffffffc02001d2 <print_kerninfo>
ffffffffc020006a:	699010ef          	jal	ra,ffffffffc0201f02 <pmm_init>
ffffffffc020006e:	552000ef          	jal	ra,ffffffffc02005c0 <pic_init>
ffffffffc0200072:	5c0000ef          	jal	ra,ffffffffc0200632 <idt_init>
ffffffffc0200076:	199030ef          	jal	ra,ffffffffc0203a0e <vmm_init>
ffffffffc020007a:	5da040ef          	jal	ra,ffffffffc0204654 <proc_init>
ffffffffc020007e:	4e0000ef          	jal	ra,ffffffffc020055e <ide_init>
ffffffffc0200082:	2f5020ef          	jal	ra,ffffffffc0202b76 <swap_init>
ffffffffc0200086:	414000ef          	jal	ra,ffffffffc020049a <clock_init>
ffffffffc020008a:	52a000ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc020008e:	013040ef          	jal	ra,ffffffffc02048a0 <cpu_idle>

ffffffffc0200092 <readline>:
ffffffffc0200092:	715d                	addi	sp,sp,-80
ffffffffc0200094:	e486                	sd	ra,72(sp)
ffffffffc0200096:	e0a2                	sd	s0,64(sp)
ffffffffc0200098:	fc26                	sd	s1,56(sp)
ffffffffc020009a:	f84a                	sd	s2,48(sp)
ffffffffc020009c:	f44e                	sd	s3,40(sp)
ffffffffc020009e:	f052                	sd	s4,32(sp)
ffffffffc02000a0:	ec56                	sd	s5,24(sp)
ffffffffc02000a2:	e85a                	sd	s6,16(sp)
ffffffffc02000a4:	e45e                	sd	s7,8(sp)
ffffffffc02000a6:	c901                	beqz	a0,ffffffffc02000b6 <readline+0x24>
ffffffffc02000a8:	85aa                	mv	a1,a0
ffffffffc02000aa:	00005517          	auipc	a0,0x5
ffffffffc02000ae:	e4e50513          	addi	a0,a0,-434 # ffffffffc0204ef8 <etext+0x2a>
ffffffffc02000b2:	0d8000ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02000b6:	4481                	li	s1,0
ffffffffc02000b8:	497d                	li	s2,31
ffffffffc02000ba:	4a21                	li	s4,8
ffffffffc02000bc:	4aa9                	li	s5,10
ffffffffc02000be:	4b35                	li	s6,13
ffffffffc02000c0:	0000ab97          	auipc	s7,0xa
ffffffffc02000c4:	fa0b8b93          	addi	s7,s7,-96 # ffffffffc020a060 <buf>
ffffffffc02000c8:	3fe00993          	li	s3,1022
ffffffffc02000cc:	0f6000ef          	jal	ra,ffffffffc02001c2 <getchar>
ffffffffc02000d0:	842a                	mv	s0,a0
ffffffffc02000d2:	02054363          	bltz	a0,ffffffffc02000f8 <readline+0x66>
ffffffffc02000d6:	02a95363          	bge	s2,a0,ffffffffc02000fc <readline+0x6a>
ffffffffc02000da:	fe99c9e3          	blt	s3,s1,ffffffffc02000cc <readline+0x3a>
ffffffffc02000de:	8522                	mv	a0,s0
ffffffffc02000e0:	0e0000ef          	jal	ra,ffffffffc02001c0 <cputchar>
ffffffffc02000e4:	009b87b3          	add	a5,s7,s1
ffffffffc02000e8:	00878023          	sb	s0,0(a5)
ffffffffc02000ec:	0d6000ef          	jal	ra,ffffffffc02001c2 <getchar>
ffffffffc02000f0:	2485                	addiw	s1,s1,1
ffffffffc02000f2:	842a                	mv	s0,a0
ffffffffc02000f4:	fe0551e3          	bgez	a0,ffffffffc02000d6 <readline+0x44>
ffffffffc02000f8:	4501                	li	a0,0
ffffffffc02000fa:	a081                	j	ffffffffc020013a <readline+0xa8>
ffffffffc02000fc:	03451163          	bne	a0,s4,ffffffffc020011e <readline+0x8c>
ffffffffc0200100:	c489                	beqz	s1,ffffffffc020010a <readline+0x78>
ffffffffc0200102:	0be000ef          	jal	ra,ffffffffc02001c0 <cputchar>
ffffffffc0200106:	34fd                	addiw	s1,s1,-1
ffffffffc0200108:	b7d1                	j	ffffffffc02000cc <readline+0x3a>
ffffffffc020010a:	0b8000ef          	jal	ra,ffffffffc02001c2 <getchar>
ffffffffc020010e:	842a                	mv	s0,a0
ffffffffc0200110:	47a1                	li	a5,8
ffffffffc0200112:	fe0543e3          	bltz	a0,ffffffffc02000f8 <readline+0x66>
ffffffffc0200116:	fca944e3          	blt	s2,a0,ffffffffc02000de <readline+0x4c>
ffffffffc020011a:	fef508e3          	beq	a0,a5,ffffffffc020010a <readline+0x78>
ffffffffc020011e:	01540463          	beq	s0,s5,ffffffffc0200126 <readline+0x94>
ffffffffc0200122:	fb6415e3          	bne	s0,s6,ffffffffc02000cc <readline+0x3a>
ffffffffc0200126:	8522                	mv	a0,s0
ffffffffc0200128:	098000ef          	jal	ra,ffffffffc02001c0 <cputchar>
ffffffffc020012c:	0000a517          	auipc	a0,0xa
ffffffffc0200130:	f3450513          	addi	a0,a0,-204 # ffffffffc020a060 <buf>
ffffffffc0200134:	94aa                	add	s1,s1,a0
ffffffffc0200136:	00048023          	sb	zero,0(s1)
ffffffffc020013a:	60a6                	ld	ra,72(sp)
ffffffffc020013c:	6406                	ld	s0,64(sp)
ffffffffc020013e:	74e2                	ld	s1,56(sp)
ffffffffc0200140:	7942                	ld	s2,48(sp)
ffffffffc0200142:	79a2                	ld	s3,40(sp)
ffffffffc0200144:	7a02                	ld	s4,32(sp)
ffffffffc0200146:	6ae2                	ld	s5,24(sp)
ffffffffc0200148:	6b42                	ld	s6,16(sp)
ffffffffc020014a:	6ba2                	ld	s7,8(sp)
ffffffffc020014c:	6161                	addi	sp,sp,80
ffffffffc020014e:	8082                	ret

ffffffffc0200150 <cputch>:
ffffffffc0200150:	1141                	addi	sp,sp,-16
ffffffffc0200152:	e022                	sd	s0,0(sp)
ffffffffc0200154:	e406                	sd	ra,8(sp)
ffffffffc0200156:	842e                	mv	s0,a1
ffffffffc0200158:	396000ef          	jal	ra,ffffffffc02004ee <cons_putc>
ffffffffc020015c:	401c                	lw	a5,0(s0)
ffffffffc020015e:	60a2                	ld	ra,8(sp)
ffffffffc0200160:	2785                	addiw	a5,a5,1
ffffffffc0200162:	c01c                	sw	a5,0(s0)
ffffffffc0200164:	6402                	ld	s0,0(sp)
ffffffffc0200166:	0141                	addi	sp,sp,16
ffffffffc0200168:	8082                	ret

ffffffffc020016a <vcprintf>:
ffffffffc020016a:	1101                	addi	sp,sp,-32
ffffffffc020016c:	862a                	mv	a2,a0
ffffffffc020016e:	86ae                	mv	a3,a1
ffffffffc0200170:	00000517          	auipc	a0,0x0
ffffffffc0200174:	fe050513          	addi	a0,a0,-32 # ffffffffc0200150 <cputch>
ffffffffc0200178:	006c                	addi	a1,sp,12
ffffffffc020017a:	ec06                	sd	ra,24(sp)
ffffffffc020017c:	c602                	sw	zero,12(sp)
ffffffffc020017e:	0f1040ef          	jal	ra,ffffffffc0204a6e <vprintfmt>
ffffffffc0200182:	60e2                	ld	ra,24(sp)
ffffffffc0200184:	4532                	lw	a0,12(sp)
ffffffffc0200186:	6105                	addi	sp,sp,32
ffffffffc0200188:	8082                	ret

ffffffffc020018a <cprintf>:
ffffffffc020018a:	711d                	addi	sp,sp,-96
ffffffffc020018c:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
ffffffffc0200190:	8e2a                	mv	t3,a0
ffffffffc0200192:	f42e                	sd	a1,40(sp)
ffffffffc0200194:	f832                	sd	a2,48(sp)
ffffffffc0200196:	fc36                	sd	a3,56(sp)
ffffffffc0200198:	00000517          	auipc	a0,0x0
ffffffffc020019c:	fb850513          	addi	a0,a0,-72 # ffffffffc0200150 <cputch>
ffffffffc02001a0:	004c                	addi	a1,sp,4
ffffffffc02001a2:	869a                	mv	a3,t1
ffffffffc02001a4:	8672                	mv	a2,t3
ffffffffc02001a6:	ec06                	sd	ra,24(sp)
ffffffffc02001a8:	e0ba                	sd	a4,64(sp)
ffffffffc02001aa:	e4be                	sd	a5,72(sp)
ffffffffc02001ac:	e8c2                	sd	a6,80(sp)
ffffffffc02001ae:	ecc6                	sd	a7,88(sp)
ffffffffc02001b0:	e41a                	sd	t1,8(sp)
ffffffffc02001b2:	c202                	sw	zero,4(sp)
ffffffffc02001b4:	0bb040ef          	jal	ra,ffffffffc0204a6e <vprintfmt>
ffffffffc02001b8:	60e2                	ld	ra,24(sp)
ffffffffc02001ba:	4512                	lw	a0,4(sp)
ffffffffc02001bc:	6125                	addi	sp,sp,96
ffffffffc02001be:	8082                	ret

ffffffffc02001c0 <cputchar>:
ffffffffc02001c0:	a63d                	j	ffffffffc02004ee <cons_putc>

ffffffffc02001c2 <getchar>:
ffffffffc02001c2:	1141                	addi	sp,sp,-16
ffffffffc02001c4:	e406                	sd	ra,8(sp)
ffffffffc02001c6:	35c000ef          	jal	ra,ffffffffc0200522 <cons_getc>
ffffffffc02001ca:	dd75                	beqz	a0,ffffffffc02001c6 <getchar+0x4>
ffffffffc02001cc:	60a2                	ld	ra,8(sp)
ffffffffc02001ce:	0141                	addi	sp,sp,16
ffffffffc02001d0:	8082                	ret

ffffffffc02001d2 <print_kerninfo>:
ffffffffc02001d2:	1141                	addi	sp,sp,-16
ffffffffc02001d4:	00005517          	auipc	a0,0x5
ffffffffc02001d8:	d2c50513          	addi	a0,a0,-724 # ffffffffc0204f00 <etext+0x32>
ffffffffc02001dc:	e406                	sd	ra,8(sp)
ffffffffc02001de:	fadff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02001e2:	00000597          	auipc	a1,0x0
ffffffffc02001e6:	e5058593          	addi	a1,a1,-432 # ffffffffc0200032 <kern_init>
ffffffffc02001ea:	00005517          	auipc	a0,0x5
ffffffffc02001ee:	d3650513          	addi	a0,a0,-714 # ffffffffc0204f20 <etext+0x52>
ffffffffc02001f2:	f99ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02001f6:	00005597          	auipc	a1,0x5
ffffffffc02001fa:	cd858593          	addi	a1,a1,-808 # ffffffffc0204ece <etext>
ffffffffc02001fe:	00005517          	auipc	a0,0x5
ffffffffc0200202:	d4250513          	addi	a0,a0,-702 # ffffffffc0204f40 <etext+0x72>
ffffffffc0200206:	f85ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020020a:	0000a597          	auipc	a1,0xa
ffffffffc020020e:	e5658593          	addi	a1,a1,-426 # ffffffffc020a060 <buf>
ffffffffc0200212:	00005517          	auipc	a0,0x5
ffffffffc0200216:	d4e50513          	addi	a0,a0,-690 # ffffffffc0204f60 <etext+0x92>
ffffffffc020021a:	f71ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020021e:	00015597          	auipc	a1,0x15
ffffffffc0200222:	3ba58593          	addi	a1,a1,954 # ffffffffc02155d8 <end>
ffffffffc0200226:	00005517          	auipc	a0,0x5
ffffffffc020022a:	d5a50513          	addi	a0,a0,-678 # ffffffffc0204f80 <etext+0xb2>
ffffffffc020022e:	f5dff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200232:	00015797          	auipc	a5,0x15
ffffffffc0200236:	7a578793          	addi	a5,a5,1957 # ffffffffc02159d7 <end+0x3ff>
ffffffffc020023a:	00000717          	auipc	a4,0x0
ffffffffc020023e:	df870713          	addi	a4,a4,-520 # ffffffffc0200032 <kern_init>
ffffffffc0200242:	8f99                	sub	a5,a5,a4
ffffffffc0200244:	43f7d593          	srai	a1,a5,0x3f
ffffffffc0200248:	60a2                	ld	ra,8(sp)
ffffffffc020024a:	3ff5f593          	andi	a1,a1,1023
ffffffffc020024e:	95be                	add	a1,a1,a5
ffffffffc0200250:	85a9                	srai	a1,a1,0xa
ffffffffc0200252:	00005517          	auipc	a0,0x5
ffffffffc0200256:	d4e50513          	addi	a0,a0,-690 # ffffffffc0204fa0 <etext+0xd2>
ffffffffc020025a:	0141                	addi	sp,sp,16
ffffffffc020025c:	b73d                	j	ffffffffc020018a <cprintf>

ffffffffc020025e <print_stackframe>:
ffffffffc020025e:	1141                	addi	sp,sp,-16
ffffffffc0200260:	00005617          	auipc	a2,0x5
ffffffffc0200264:	d7060613          	addi	a2,a2,-656 # ffffffffc0204fd0 <etext+0x102>
ffffffffc0200268:	04d00593          	li	a1,77
ffffffffc020026c:	00005517          	auipc	a0,0x5
ffffffffc0200270:	d7c50513          	addi	a0,a0,-644 # ffffffffc0204fe8 <etext+0x11a>
ffffffffc0200274:	e406                	sd	ra,8(sp)
ffffffffc0200276:	1c8000ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc020027a <mon_help>:
ffffffffc020027a:	1141                	addi	sp,sp,-16
ffffffffc020027c:	00005617          	auipc	a2,0x5
ffffffffc0200280:	d8460613          	addi	a2,a2,-636 # ffffffffc0205000 <etext+0x132>
ffffffffc0200284:	00005597          	auipc	a1,0x5
ffffffffc0200288:	d9c58593          	addi	a1,a1,-612 # ffffffffc0205020 <etext+0x152>
ffffffffc020028c:	00005517          	auipc	a0,0x5
ffffffffc0200290:	d9c50513          	addi	a0,a0,-612 # ffffffffc0205028 <etext+0x15a>
ffffffffc0200294:	e406                	sd	ra,8(sp)
ffffffffc0200296:	ef5ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020029a:	00005617          	auipc	a2,0x5
ffffffffc020029e:	d9e60613          	addi	a2,a2,-610 # ffffffffc0205038 <etext+0x16a>
ffffffffc02002a2:	00005597          	auipc	a1,0x5
ffffffffc02002a6:	dbe58593          	addi	a1,a1,-578 # ffffffffc0205060 <etext+0x192>
ffffffffc02002aa:	00005517          	auipc	a0,0x5
ffffffffc02002ae:	d7e50513          	addi	a0,a0,-642 # ffffffffc0205028 <etext+0x15a>
ffffffffc02002b2:	ed9ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02002b6:	00005617          	auipc	a2,0x5
ffffffffc02002ba:	dba60613          	addi	a2,a2,-582 # ffffffffc0205070 <etext+0x1a2>
ffffffffc02002be:	00005597          	auipc	a1,0x5
ffffffffc02002c2:	dd258593          	addi	a1,a1,-558 # ffffffffc0205090 <etext+0x1c2>
ffffffffc02002c6:	00005517          	auipc	a0,0x5
ffffffffc02002ca:	d6250513          	addi	a0,a0,-670 # ffffffffc0205028 <etext+0x15a>
ffffffffc02002ce:	ebdff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02002d2:	60a2                	ld	ra,8(sp)
ffffffffc02002d4:	4501                	li	a0,0
ffffffffc02002d6:	0141                	addi	sp,sp,16
ffffffffc02002d8:	8082                	ret

ffffffffc02002da <mon_kerninfo>:
ffffffffc02002da:	1141                	addi	sp,sp,-16
ffffffffc02002dc:	e406                	sd	ra,8(sp)
ffffffffc02002de:	ef5ff0ef          	jal	ra,ffffffffc02001d2 <print_kerninfo>
ffffffffc02002e2:	60a2                	ld	ra,8(sp)
ffffffffc02002e4:	4501                	li	a0,0
ffffffffc02002e6:	0141                	addi	sp,sp,16
ffffffffc02002e8:	8082                	ret

ffffffffc02002ea <mon_backtrace>:
ffffffffc02002ea:	1141                	addi	sp,sp,-16
ffffffffc02002ec:	e406                	sd	ra,8(sp)
ffffffffc02002ee:	f71ff0ef          	jal	ra,ffffffffc020025e <print_stackframe>
ffffffffc02002f2:	60a2                	ld	ra,8(sp)
ffffffffc02002f4:	4501                	li	a0,0
ffffffffc02002f6:	0141                	addi	sp,sp,16
ffffffffc02002f8:	8082                	ret

ffffffffc02002fa <kmonitor>:
ffffffffc02002fa:	7115                	addi	sp,sp,-224
ffffffffc02002fc:	f15a                	sd	s6,160(sp)
ffffffffc02002fe:	8b2a                	mv	s6,a0
ffffffffc0200300:	00005517          	auipc	a0,0x5
ffffffffc0200304:	da050513          	addi	a0,a0,-608 # ffffffffc02050a0 <etext+0x1d2>
ffffffffc0200308:	ed86                	sd	ra,216(sp)
ffffffffc020030a:	e9a2                	sd	s0,208(sp)
ffffffffc020030c:	e5a6                	sd	s1,200(sp)
ffffffffc020030e:	e1ca                	sd	s2,192(sp)
ffffffffc0200310:	fd4e                	sd	s3,184(sp)
ffffffffc0200312:	f952                	sd	s4,176(sp)
ffffffffc0200314:	f556                	sd	s5,168(sp)
ffffffffc0200316:	ed5e                	sd	s7,152(sp)
ffffffffc0200318:	e962                	sd	s8,144(sp)
ffffffffc020031a:	e566                	sd	s9,136(sp)
ffffffffc020031c:	e16a                	sd	s10,128(sp)
ffffffffc020031e:	e6dff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200322:	00005517          	auipc	a0,0x5
ffffffffc0200326:	da650513          	addi	a0,a0,-602 # ffffffffc02050c8 <etext+0x1fa>
ffffffffc020032a:	e61ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020032e:	000b0563          	beqz	s6,ffffffffc0200338 <kmonitor+0x3e>
ffffffffc0200332:	855a                	mv	a0,s6
ffffffffc0200334:	4e4000ef          	jal	ra,ffffffffc0200818 <print_trapframe>
ffffffffc0200338:	4501                	li	a0,0
ffffffffc020033a:	4581                	li	a1,0
ffffffffc020033c:	4601                	li	a2,0
ffffffffc020033e:	48a1                	li	a7,8
ffffffffc0200340:	00000073          	ecall
ffffffffc0200344:	00005c17          	auipc	s8,0x5
ffffffffc0200348:	df4c0c13          	addi	s8,s8,-524 # ffffffffc0205138 <commands>
ffffffffc020034c:	00005917          	auipc	s2,0x5
ffffffffc0200350:	da490913          	addi	s2,s2,-604 # ffffffffc02050f0 <etext+0x222>
ffffffffc0200354:	00005497          	auipc	s1,0x5
ffffffffc0200358:	da448493          	addi	s1,s1,-604 # ffffffffc02050f8 <etext+0x22a>
ffffffffc020035c:	49bd                	li	s3,15
ffffffffc020035e:	00005a97          	auipc	s5,0x5
ffffffffc0200362:	da2a8a93          	addi	s5,s5,-606 # ffffffffc0205100 <etext+0x232>
ffffffffc0200366:	4a0d                	li	s4,3
ffffffffc0200368:	00005b97          	auipc	s7,0x5
ffffffffc020036c:	db8b8b93          	addi	s7,s7,-584 # ffffffffc0205120 <etext+0x252>
ffffffffc0200370:	854a                	mv	a0,s2
ffffffffc0200372:	d21ff0ef          	jal	ra,ffffffffc0200092 <readline>
ffffffffc0200376:	842a                	mv	s0,a0
ffffffffc0200378:	dd65                	beqz	a0,ffffffffc0200370 <kmonitor+0x76>
ffffffffc020037a:	00054583          	lbu	a1,0(a0)
ffffffffc020037e:	4c81                	li	s9,0
ffffffffc0200380:	e59d                	bnez	a1,ffffffffc02003ae <kmonitor+0xb4>
ffffffffc0200382:	fe0c87e3          	beqz	s9,ffffffffc0200370 <kmonitor+0x76>
ffffffffc0200386:	00005d17          	auipc	s10,0x5
ffffffffc020038a:	db2d0d13          	addi	s10,s10,-590 # ffffffffc0205138 <commands>
ffffffffc020038e:	4401                	li	s0,0
ffffffffc0200390:	000d3503          	ld	a0,0(s10)
ffffffffc0200394:	6582                	ld	a1,0(sp)
ffffffffc0200396:	0d61                	addi	s10,s10,24
ffffffffc0200398:	29b040ef          	jal	ra,ffffffffc0204e32 <strcmp>
ffffffffc020039c:	c535                	beqz	a0,ffffffffc0200408 <kmonitor+0x10e>
ffffffffc020039e:	2405                	addiw	s0,s0,1
ffffffffc02003a0:	ff4418e3          	bne	s0,s4,ffffffffc0200390 <kmonitor+0x96>
ffffffffc02003a4:	6582                	ld	a1,0(sp)
ffffffffc02003a6:	855e                	mv	a0,s7
ffffffffc02003a8:	de3ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02003ac:	b7d1                	j	ffffffffc0200370 <kmonitor+0x76>
ffffffffc02003ae:	8526                	mv	a0,s1
ffffffffc02003b0:	2bb040ef          	jal	ra,ffffffffc0204e6a <strchr>
ffffffffc02003b4:	c901                	beqz	a0,ffffffffc02003c4 <kmonitor+0xca>
ffffffffc02003b6:	00144583          	lbu	a1,1(s0)
ffffffffc02003ba:	00040023          	sb	zero,0(s0)
ffffffffc02003be:	0405                	addi	s0,s0,1
ffffffffc02003c0:	d1e9                	beqz	a1,ffffffffc0200382 <kmonitor+0x88>
ffffffffc02003c2:	b7f5                	j	ffffffffc02003ae <kmonitor+0xb4>
ffffffffc02003c4:	00044783          	lbu	a5,0(s0)
ffffffffc02003c8:	dfcd                	beqz	a5,ffffffffc0200382 <kmonitor+0x88>
ffffffffc02003ca:	033c8a63          	beq	s9,s3,ffffffffc02003fe <kmonitor+0x104>
ffffffffc02003ce:	003c9793          	slli	a5,s9,0x3
ffffffffc02003d2:	08078793          	addi	a5,a5,128
ffffffffc02003d6:	978a                	add	a5,a5,sp
ffffffffc02003d8:	f887b023          	sd	s0,-128(a5)
ffffffffc02003dc:	00044583          	lbu	a1,0(s0)
ffffffffc02003e0:	2c85                	addiw	s9,s9,1
ffffffffc02003e2:	e591                	bnez	a1,ffffffffc02003ee <kmonitor+0xf4>
ffffffffc02003e4:	b74d                	j	ffffffffc0200386 <kmonitor+0x8c>
ffffffffc02003e6:	00144583          	lbu	a1,1(s0)
ffffffffc02003ea:	0405                	addi	s0,s0,1
ffffffffc02003ec:	d9d9                	beqz	a1,ffffffffc0200382 <kmonitor+0x88>
ffffffffc02003ee:	8526                	mv	a0,s1
ffffffffc02003f0:	27b040ef          	jal	ra,ffffffffc0204e6a <strchr>
ffffffffc02003f4:	d96d                	beqz	a0,ffffffffc02003e6 <kmonitor+0xec>
ffffffffc02003f6:	00044583          	lbu	a1,0(s0)
ffffffffc02003fa:	d5c1                	beqz	a1,ffffffffc0200382 <kmonitor+0x88>
ffffffffc02003fc:	bf4d                	j	ffffffffc02003ae <kmonitor+0xb4>
ffffffffc02003fe:	45c1                	li	a1,16
ffffffffc0200400:	8556                	mv	a0,s5
ffffffffc0200402:	d89ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200406:	b7e1                	j	ffffffffc02003ce <kmonitor+0xd4>
ffffffffc0200408:	00141793          	slli	a5,s0,0x1
ffffffffc020040c:	97a2                	add	a5,a5,s0
ffffffffc020040e:	078e                	slli	a5,a5,0x3
ffffffffc0200410:	97e2                	add	a5,a5,s8
ffffffffc0200412:	6b9c                	ld	a5,16(a5)
ffffffffc0200414:	865a                	mv	a2,s6
ffffffffc0200416:	002c                	addi	a1,sp,8
ffffffffc0200418:	fffc851b          	addiw	a0,s9,-1
ffffffffc020041c:	9782                	jalr	a5
ffffffffc020041e:	f40559e3          	bgez	a0,ffffffffc0200370 <kmonitor+0x76>
ffffffffc0200422:	60ee                	ld	ra,216(sp)
ffffffffc0200424:	644e                	ld	s0,208(sp)
ffffffffc0200426:	64ae                	ld	s1,200(sp)
ffffffffc0200428:	690e                	ld	s2,192(sp)
ffffffffc020042a:	79ea                	ld	s3,184(sp)
ffffffffc020042c:	7a4a                	ld	s4,176(sp)
ffffffffc020042e:	7aaa                	ld	s5,168(sp)
ffffffffc0200430:	7b0a                	ld	s6,160(sp)
ffffffffc0200432:	6bea                	ld	s7,152(sp)
ffffffffc0200434:	6c4a                	ld	s8,144(sp)
ffffffffc0200436:	6caa                	ld	s9,136(sp)
ffffffffc0200438:	6d0a                	ld	s10,128(sp)
ffffffffc020043a:	612d                	addi	sp,sp,224
ffffffffc020043c:	8082                	ret

ffffffffc020043e <__panic>:
ffffffffc020043e:	00015317          	auipc	t1,0x15
ffffffffc0200442:	0fa30313          	addi	t1,t1,250 # ffffffffc0215538 <is_panic>
ffffffffc0200446:	00032e03          	lw	t3,0(t1)
ffffffffc020044a:	715d                	addi	sp,sp,-80
ffffffffc020044c:	ec06                	sd	ra,24(sp)
ffffffffc020044e:	e822                	sd	s0,16(sp)
ffffffffc0200450:	f436                	sd	a3,40(sp)
ffffffffc0200452:	f83a                	sd	a4,48(sp)
ffffffffc0200454:	fc3e                	sd	a5,56(sp)
ffffffffc0200456:	e0c2                	sd	a6,64(sp)
ffffffffc0200458:	e4c6                	sd	a7,72(sp)
ffffffffc020045a:	020e1a63          	bnez	t3,ffffffffc020048e <__panic+0x50>
ffffffffc020045e:	4785                	li	a5,1
ffffffffc0200460:	00f32023          	sw	a5,0(t1)
ffffffffc0200464:	8432                	mv	s0,a2
ffffffffc0200466:	103c                	addi	a5,sp,40
ffffffffc0200468:	862e                	mv	a2,a1
ffffffffc020046a:	85aa                	mv	a1,a0
ffffffffc020046c:	00005517          	auipc	a0,0x5
ffffffffc0200470:	d1450513          	addi	a0,a0,-748 # ffffffffc0205180 <commands+0x48>
ffffffffc0200474:	e43e                	sd	a5,8(sp)
ffffffffc0200476:	d15ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020047a:	65a2                	ld	a1,8(sp)
ffffffffc020047c:	8522                	mv	a0,s0
ffffffffc020047e:	cedff0ef          	jal	ra,ffffffffc020016a <vcprintf>
ffffffffc0200482:	00006517          	auipc	a0,0x6
ffffffffc0200486:	c6e50513          	addi	a0,a0,-914 # ffffffffc02060f0 <default_pmm_manager+0x4d0>
ffffffffc020048a:	d01ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020048e:	12c000ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0200492:	4501                	li	a0,0
ffffffffc0200494:	e67ff0ef          	jal	ra,ffffffffc02002fa <kmonitor>
ffffffffc0200498:	bfed                	j	ffffffffc0200492 <__panic+0x54>

ffffffffc020049a <clock_init>:
ffffffffc020049a:	67e1                	lui	a5,0x18
ffffffffc020049c:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02004a0:	00015717          	auipc	a4,0x15
ffffffffc02004a4:	0af73023          	sd	a5,160(a4) # ffffffffc0215540 <timebase>
ffffffffc02004a8:	c0102573          	rdtime	a0
ffffffffc02004ac:	4581                	li	a1,0
ffffffffc02004ae:	953e                	add	a0,a0,a5
ffffffffc02004b0:	4601                	li	a2,0
ffffffffc02004b2:	4881                	li	a7,0
ffffffffc02004b4:	00000073          	ecall
ffffffffc02004b8:	02000793          	li	a5,32
ffffffffc02004bc:	1047a7f3          	csrrs	a5,sie,a5
ffffffffc02004c0:	00005517          	auipc	a0,0x5
ffffffffc02004c4:	ce050513          	addi	a0,a0,-800 # ffffffffc02051a0 <commands+0x68>
ffffffffc02004c8:	00015797          	auipc	a5,0x15
ffffffffc02004cc:	0807b023          	sd	zero,128(a5) # ffffffffc0215548 <ticks>
ffffffffc02004d0:	b96d                	j	ffffffffc020018a <cprintf>

ffffffffc02004d2 <clock_set_next_event>:
ffffffffc02004d2:	c0102573          	rdtime	a0
ffffffffc02004d6:	00015797          	auipc	a5,0x15
ffffffffc02004da:	06a7b783          	ld	a5,106(a5) # ffffffffc0215540 <timebase>
ffffffffc02004de:	953e                	add	a0,a0,a5
ffffffffc02004e0:	4581                	li	a1,0
ffffffffc02004e2:	4601                	li	a2,0
ffffffffc02004e4:	4881                	li	a7,0
ffffffffc02004e6:	00000073          	ecall
ffffffffc02004ea:	8082                	ret

ffffffffc02004ec <cons_init>:
ffffffffc02004ec:	8082                	ret

ffffffffc02004ee <cons_putc>:
ffffffffc02004ee:	100027f3          	csrr	a5,sstatus
ffffffffc02004f2:	8b89                	andi	a5,a5,2
ffffffffc02004f4:	0ff57513          	andi	a0,a0,255
ffffffffc02004f8:	e799                	bnez	a5,ffffffffc0200506 <cons_putc+0x18>
ffffffffc02004fa:	4581                	li	a1,0
ffffffffc02004fc:	4601                	li	a2,0
ffffffffc02004fe:	4885                	li	a7,1
ffffffffc0200500:	00000073          	ecall
ffffffffc0200504:	8082                	ret
ffffffffc0200506:	1101                	addi	sp,sp,-32
ffffffffc0200508:	ec06                	sd	ra,24(sp)
ffffffffc020050a:	e42a                	sd	a0,8(sp)
ffffffffc020050c:	0ae000ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0200510:	6522                	ld	a0,8(sp)
ffffffffc0200512:	4581                	li	a1,0
ffffffffc0200514:	4601                	li	a2,0
ffffffffc0200516:	4885                	li	a7,1
ffffffffc0200518:	00000073          	ecall
ffffffffc020051c:	60e2                	ld	ra,24(sp)
ffffffffc020051e:	6105                	addi	sp,sp,32
ffffffffc0200520:	a851                	j	ffffffffc02005b4 <intr_enable>

ffffffffc0200522 <cons_getc>:
ffffffffc0200522:	100027f3          	csrr	a5,sstatus
ffffffffc0200526:	8b89                	andi	a5,a5,2
ffffffffc0200528:	eb89                	bnez	a5,ffffffffc020053a <cons_getc+0x18>
ffffffffc020052a:	4501                	li	a0,0
ffffffffc020052c:	4581                	li	a1,0
ffffffffc020052e:	4601                	li	a2,0
ffffffffc0200530:	4889                	li	a7,2
ffffffffc0200532:	00000073          	ecall
ffffffffc0200536:	2501                	sext.w	a0,a0
ffffffffc0200538:	8082                	ret
ffffffffc020053a:	1101                	addi	sp,sp,-32
ffffffffc020053c:	ec06                	sd	ra,24(sp)
ffffffffc020053e:	07c000ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0200542:	4501                	li	a0,0
ffffffffc0200544:	4581                	li	a1,0
ffffffffc0200546:	4601                	li	a2,0
ffffffffc0200548:	4889                	li	a7,2
ffffffffc020054a:	00000073          	ecall
ffffffffc020054e:	2501                	sext.w	a0,a0
ffffffffc0200550:	e42a                	sd	a0,8(sp)
ffffffffc0200552:	062000ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0200556:	60e2                	ld	ra,24(sp)
ffffffffc0200558:	6522                	ld	a0,8(sp)
ffffffffc020055a:	6105                	addi	sp,sp,32
ffffffffc020055c:	8082                	ret

ffffffffc020055e <ide_init>:
ffffffffc020055e:	8082                	ret

ffffffffc0200560 <ide_device_valid>:
ffffffffc0200560:	00253513          	sltiu	a0,a0,2
ffffffffc0200564:	8082                	ret

ffffffffc0200566 <ide_device_size>:
ffffffffc0200566:	03800513          	li	a0,56
ffffffffc020056a:	8082                	ret

ffffffffc020056c <ide_read_secs>:
ffffffffc020056c:	0000a797          	auipc	a5,0xa
ffffffffc0200570:	ef478793          	addi	a5,a5,-268 # ffffffffc020a460 <ide>
ffffffffc0200574:	0095959b          	slliw	a1,a1,0x9
ffffffffc0200578:	1141                	addi	sp,sp,-16
ffffffffc020057a:	8532                	mv	a0,a2
ffffffffc020057c:	95be                	add	a1,a1,a5
ffffffffc020057e:	00969613          	slli	a2,a3,0x9
ffffffffc0200582:	e406                	sd	ra,8(sp)
ffffffffc0200584:	10f040ef          	jal	ra,ffffffffc0204e92 <memcpy>
ffffffffc0200588:	60a2                	ld	ra,8(sp)
ffffffffc020058a:	4501                	li	a0,0
ffffffffc020058c:	0141                	addi	sp,sp,16
ffffffffc020058e:	8082                	ret

ffffffffc0200590 <ide_write_secs>:
ffffffffc0200590:	0095979b          	slliw	a5,a1,0x9
ffffffffc0200594:	0000a517          	auipc	a0,0xa
ffffffffc0200598:	ecc50513          	addi	a0,a0,-308 # ffffffffc020a460 <ide>
ffffffffc020059c:	1141                	addi	sp,sp,-16
ffffffffc020059e:	85b2                	mv	a1,a2
ffffffffc02005a0:	953e                	add	a0,a0,a5
ffffffffc02005a2:	00969613          	slli	a2,a3,0x9
ffffffffc02005a6:	e406                	sd	ra,8(sp)
ffffffffc02005a8:	0eb040ef          	jal	ra,ffffffffc0204e92 <memcpy>
ffffffffc02005ac:	60a2                	ld	ra,8(sp)
ffffffffc02005ae:	4501                	li	a0,0
ffffffffc02005b0:	0141                	addi	sp,sp,16
ffffffffc02005b2:	8082                	ret

ffffffffc02005b4 <intr_enable>:
ffffffffc02005b4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005b8:	8082                	ret

ffffffffc02005ba <intr_disable>:
ffffffffc02005ba:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005be:	8082                	ret

ffffffffc02005c0 <pic_init>:
ffffffffc02005c0:	8082                	ret

ffffffffc02005c2 <pgfault_handler>:
ffffffffc02005c2:	10053783          	ld	a5,256(a0)
ffffffffc02005c6:	1141                	addi	sp,sp,-16
ffffffffc02005c8:	e022                	sd	s0,0(sp)
ffffffffc02005ca:	e406                	sd	ra,8(sp)
ffffffffc02005cc:	1007f793          	andi	a5,a5,256
ffffffffc02005d0:	11053583          	ld	a1,272(a0)
ffffffffc02005d4:	842a                	mv	s0,a0
ffffffffc02005d6:	04b00613          	li	a2,75
ffffffffc02005da:	e399                	bnez	a5,ffffffffc02005e0 <pgfault_handler+0x1e>
ffffffffc02005dc:	05500613          	li	a2,85
ffffffffc02005e0:	11843703          	ld	a4,280(s0)
ffffffffc02005e4:	47bd                	li	a5,15
ffffffffc02005e6:	05200693          	li	a3,82
ffffffffc02005ea:	00f71463          	bne	a4,a5,ffffffffc02005f2 <pgfault_handler+0x30>
ffffffffc02005ee:	05700693          	li	a3,87
ffffffffc02005f2:	00005517          	auipc	a0,0x5
ffffffffc02005f6:	bce50513          	addi	a0,a0,-1074 # ffffffffc02051c0 <commands+0x88>
ffffffffc02005fa:	b91ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02005fe:	00015517          	auipc	a0,0x15
ffffffffc0200602:	fb253503          	ld	a0,-78(a0) # ffffffffc02155b0 <check_mm_struct>
ffffffffc0200606:	c911                	beqz	a0,ffffffffc020061a <pgfault_handler+0x58>
ffffffffc0200608:	11043603          	ld	a2,272(s0)
ffffffffc020060c:	11842583          	lw	a1,280(s0)
ffffffffc0200610:	6402                	ld	s0,0(sp)
ffffffffc0200612:	60a2                	ld	ra,8(sp)
ffffffffc0200614:	0141                	addi	sp,sp,16
ffffffffc0200616:	1e50306f          	j	ffffffffc0203ffa <do_pgfault>
ffffffffc020061a:	00005617          	auipc	a2,0x5
ffffffffc020061e:	bc660613          	addi	a2,a2,-1082 # ffffffffc02051e0 <commands+0xa8>
ffffffffc0200622:	07300593          	li	a1,115
ffffffffc0200626:	00005517          	auipc	a0,0x5
ffffffffc020062a:	bd250513          	addi	a0,a0,-1070 # ffffffffc02051f8 <commands+0xc0>
ffffffffc020062e:	e11ff0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0200632 <idt_init>:
ffffffffc0200632:	14005073          	csrwi	sscratch,0
ffffffffc0200636:	00000797          	auipc	a5,0x0
ffffffffc020063a:	4a278793          	addi	a5,a5,1186 # ffffffffc0200ad8 <__alltraps>
ffffffffc020063e:	10579073          	csrw	stvec,a5
ffffffffc0200642:	000407b7          	lui	a5,0x40
ffffffffc0200646:	1007a7f3          	csrrs	a5,sstatus,a5
ffffffffc020064a:	8082                	ret

ffffffffc020064c <print_regs>:
ffffffffc020064c:	610c                	ld	a1,0(a0)
ffffffffc020064e:	1141                	addi	sp,sp,-16
ffffffffc0200650:	e022                	sd	s0,0(sp)
ffffffffc0200652:	842a                	mv	s0,a0
ffffffffc0200654:	00005517          	auipc	a0,0x5
ffffffffc0200658:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0205210 <commands+0xd8>
ffffffffc020065c:	e406                	sd	ra,8(sp)
ffffffffc020065e:	b2dff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200662:	640c                	ld	a1,8(s0)
ffffffffc0200664:	00005517          	auipc	a0,0x5
ffffffffc0200668:	bc450513          	addi	a0,a0,-1084 # ffffffffc0205228 <commands+0xf0>
ffffffffc020066c:	b1fff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200670:	680c                	ld	a1,16(s0)
ffffffffc0200672:	00005517          	auipc	a0,0x5
ffffffffc0200676:	bce50513          	addi	a0,a0,-1074 # ffffffffc0205240 <commands+0x108>
ffffffffc020067a:	b11ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020067e:	6c0c                	ld	a1,24(s0)
ffffffffc0200680:	00005517          	auipc	a0,0x5
ffffffffc0200684:	bd850513          	addi	a0,a0,-1064 # ffffffffc0205258 <commands+0x120>
ffffffffc0200688:	b03ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020068c:	700c                	ld	a1,32(s0)
ffffffffc020068e:	00005517          	auipc	a0,0x5
ffffffffc0200692:	be250513          	addi	a0,a0,-1054 # ffffffffc0205270 <commands+0x138>
ffffffffc0200696:	af5ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020069a:	740c                	ld	a1,40(s0)
ffffffffc020069c:	00005517          	auipc	a0,0x5
ffffffffc02006a0:	bec50513          	addi	a0,a0,-1044 # ffffffffc0205288 <commands+0x150>
ffffffffc02006a4:	ae7ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02006a8:	780c                	ld	a1,48(s0)
ffffffffc02006aa:	00005517          	auipc	a0,0x5
ffffffffc02006ae:	bf650513          	addi	a0,a0,-1034 # ffffffffc02052a0 <commands+0x168>
ffffffffc02006b2:	ad9ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02006b6:	7c0c                	ld	a1,56(s0)
ffffffffc02006b8:	00005517          	auipc	a0,0x5
ffffffffc02006bc:	c0050513          	addi	a0,a0,-1024 # ffffffffc02052b8 <commands+0x180>
ffffffffc02006c0:	acbff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02006c4:	602c                	ld	a1,64(s0)
ffffffffc02006c6:	00005517          	auipc	a0,0x5
ffffffffc02006ca:	c0a50513          	addi	a0,a0,-1014 # ffffffffc02052d0 <commands+0x198>
ffffffffc02006ce:	abdff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02006d2:	642c                	ld	a1,72(s0)
ffffffffc02006d4:	00005517          	auipc	a0,0x5
ffffffffc02006d8:	c1450513          	addi	a0,a0,-1004 # ffffffffc02052e8 <commands+0x1b0>
ffffffffc02006dc:	aafff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02006e0:	682c                	ld	a1,80(s0)
ffffffffc02006e2:	00005517          	auipc	a0,0x5
ffffffffc02006e6:	c1e50513          	addi	a0,a0,-994 # ffffffffc0205300 <commands+0x1c8>
ffffffffc02006ea:	aa1ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02006ee:	6c2c                	ld	a1,88(s0)
ffffffffc02006f0:	00005517          	auipc	a0,0x5
ffffffffc02006f4:	c2850513          	addi	a0,a0,-984 # ffffffffc0205318 <commands+0x1e0>
ffffffffc02006f8:	a93ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02006fc:	702c                	ld	a1,96(s0)
ffffffffc02006fe:	00005517          	auipc	a0,0x5
ffffffffc0200702:	c3250513          	addi	a0,a0,-974 # ffffffffc0205330 <commands+0x1f8>
ffffffffc0200706:	a85ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020070a:	742c                	ld	a1,104(s0)
ffffffffc020070c:	00005517          	auipc	a0,0x5
ffffffffc0200710:	c3c50513          	addi	a0,a0,-964 # ffffffffc0205348 <commands+0x210>
ffffffffc0200714:	a77ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200718:	782c                	ld	a1,112(s0)
ffffffffc020071a:	00005517          	auipc	a0,0x5
ffffffffc020071e:	c4650513          	addi	a0,a0,-954 # ffffffffc0205360 <commands+0x228>
ffffffffc0200722:	a69ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200726:	7c2c                	ld	a1,120(s0)
ffffffffc0200728:	00005517          	auipc	a0,0x5
ffffffffc020072c:	c5050513          	addi	a0,a0,-944 # ffffffffc0205378 <commands+0x240>
ffffffffc0200730:	a5bff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200734:	604c                	ld	a1,128(s0)
ffffffffc0200736:	00005517          	auipc	a0,0x5
ffffffffc020073a:	c5a50513          	addi	a0,a0,-934 # ffffffffc0205390 <commands+0x258>
ffffffffc020073e:	a4dff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200742:	644c                	ld	a1,136(s0)
ffffffffc0200744:	00005517          	auipc	a0,0x5
ffffffffc0200748:	c6450513          	addi	a0,a0,-924 # ffffffffc02053a8 <commands+0x270>
ffffffffc020074c:	a3fff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200750:	684c                	ld	a1,144(s0)
ffffffffc0200752:	00005517          	auipc	a0,0x5
ffffffffc0200756:	c6e50513          	addi	a0,a0,-914 # ffffffffc02053c0 <commands+0x288>
ffffffffc020075a:	a31ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020075e:	6c4c                	ld	a1,152(s0)
ffffffffc0200760:	00005517          	auipc	a0,0x5
ffffffffc0200764:	c7850513          	addi	a0,a0,-904 # ffffffffc02053d8 <commands+0x2a0>
ffffffffc0200768:	a23ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020076c:	704c                	ld	a1,160(s0)
ffffffffc020076e:	00005517          	auipc	a0,0x5
ffffffffc0200772:	c8250513          	addi	a0,a0,-894 # ffffffffc02053f0 <commands+0x2b8>
ffffffffc0200776:	a15ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020077a:	744c                	ld	a1,168(s0)
ffffffffc020077c:	00005517          	auipc	a0,0x5
ffffffffc0200780:	c8c50513          	addi	a0,a0,-884 # ffffffffc0205408 <commands+0x2d0>
ffffffffc0200784:	a07ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200788:	784c                	ld	a1,176(s0)
ffffffffc020078a:	00005517          	auipc	a0,0x5
ffffffffc020078e:	c9650513          	addi	a0,a0,-874 # ffffffffc0205420 <commands+0x2e8>
ffffffffc0200792:	9f9ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200796:	7c4c                	ld	a1,184(s0)
ffffffffc0200798:	00005517          	auipc	a0,0x5
ffffffffc020079c:	ca050513          	addi	a0,a0,-864 # ffffffffc0205438 <commands+0x300>
ffffffffc02007a0:	9ebff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02007a4:	606c                	ld	a1,192(s0)
ffffffffc02007a6:	00005517          	auipc	a0,0x5
ffffffffc02007aa:	caa50513          	addi	a0,a0,-854 # ffffffffc0205450 <commands+0x318>
ffffffffc02007ae:	9ddff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02007b2:	646c                	ld	a1,200(s0)
ffffffffc02007b4:	00005517          	auipc	a0,0x5
ffffffffc02007b8:	cb450513          	addi	a0,a0,-844 # ffffffffc0205468 <commands+0x330>
ffffffffc02007bc:	9cfff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02007c0:	686c                	ld	a1,208(s0)
ffffffffc02007c2:	00005517          	auipc	a0,0x5
ffffffffc02007c6:	cbe50513          	addi	a0,a0,-834 # ffffffffc0205480 <commands+0x348>
ffffffffc02007ca:	9c1ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02007ce:	6c6c                	ld	a1,216(s0)
ffffffffc02007d0:	00005517          	auipc	a0,0x5
ffffffffc02007d4:	cc850513          	addi	a0,a0,-824 # ffffffffc0205498 <commands+0x360>
ffffffffc02007d8:	9b3ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02007dc:	706c                	ld	a1,224(s0)
ffffffffc02007de:	00005517          	auipc	a0,0x5
ffffffffc02007e2:	cd250513          	addi	a0,a0,-814 # ffffffffc02054b0 <commands+0x378>
ffffffffc02007e6:	9a5ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02007ea:	746c                	ld	a1,232(s0)
ffffffffc02007ec:	00005517          	auipc	a0,0x5
ffffffffc02007f0:	cdc50513          	addi	a0,a0,-804 # ffffffffc02054c8 <commands+0x390>
ffffffffc02007f4:	997ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02007f8:	786c                	ld	a1,240(s0)
ffffffffc02007fa:	00005517          	auipc	a0,0x5
ffffffffc02007fe:	ce650513          	addi	a0,a0,-794 # ffffffffc02054e0 <commands+0x3a8>
ffffffffc0200802:	989ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200806:	7c6c                	ld	a1,248(s0)
ffffffffc0200808:	6402                	ld	s0,0(sp)
ffffffffc020080a:	60a2                	ld	ra,8(sp)
ffffffffc020080c:	00005517          	auipc	a0,0x5
ffffffffc0200810:	cec50513          	addi	a0,a0,-788 # ffffffffc02054f8 <commands+0x3c0>
ffffffffc0200814:	0141                	addi	sp,sp,16
ffffffffc0200816:	ba95                	j	ffffffffc020018a <cprintf>

ffffffffc0200818 <print_trapframe>:
ffffffffc0200818:	1141                	addi	sp,sp,-16
ffffffffc020081a:	e022                	sd	s0,0(sp)
ffffffffc020081c:	85aa                	mv	a1,a0
ffffffffc020081e:	842a                	mv	s0,a0
ffffffffc0200820:	00005517          	auipc	a0,0x5
ffffffffc0200824:	cf050513          	addi	a0,a0,-784 # ffffffffc0205510 <commands+0x3d8>
ffffffffc0200828:	e406                	sd	ra,8(sp)
ffffffffc020082a:	961ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020082e:	8522                	mv	a0,s0
ffffffffc0200830:	e1dff0ef          	jal	ra,ffffffffc020064c <print_regs>
ffffffffc0200834:	10043583          	ld	a1,256(s0)
ffffffffc0200838:	00005517          	auipc	a0,0x5
ffffffffc020083c:	cf050513          	addi	a0,a0,-784 # ffffffffc0205528 <commands+0x3f0>
ffffffffc0200840:	94bff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200844:	10843583          	ld	a1,264(s0)
ffffffffc0200848:	00005517          	auipc	a0,0x5
ffffffffc020084c:	cf850513          	addi	a0,a0,-776 # ffffffffc0205540 <commands+0x408>
ffffffffc0200850:	93bff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200854:	11043583          	ld	a1,272(s0)
ffffffffc0200858:	00005517          	auipc	a0,0x5
ffffffffc020085c:	d0050513          	addi	a0,a0,-768 # ffffffffc0205558 <commands+0x420>
ffffffffc0200860:	92bff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200864:	11843583          	ld	a1,280(s0)
ffffffffc0200868:	6402                	ld	s0,0(sp)
ffffffffc020086a:	60a2                	ld	ra,8(sp)
ffffffffc020086c:	00005517          	auipc	a0,0x5
ffffffffc0200870:	d0450513          	addi	a0,a0,-764 # ffffffffc0205570 <commands+0x438>
ffffffffc0200874:	0141                	addi	sp,sp,16
ffffffffc0200876:	915ff06f          	j	ffffffffc020018a <cprintf>

ffffffffc020087a <interrupt_handler>:
ffffffffc020087a:	11853783          	ld	a5,280(a0)
ffffffffc020087e:	472d                	li	a4,11
ffffffffc0200880:	0786                	slli	a5,a5,0x1
ffffffffc0200882:	8385                	srli	a5,a5,0x1
ffffffffc0200884:	06f76c63          	bltu	a4,a5,ffffffffc02008fc <interrupt_handler+0x82>
ffffffffc0200888:	00005717          	auipc	a4,0x5
ffffffffc020088c:	db070713          	addi	a4,a4,-592 # ffffffffc0205638 <commands+0x500>
ffffffffc0200890:	078a                	slli	a5,a5,0x2
ffffffffc0200892:	97ba                	add	a5,a5,a4
ffffffffc0200894:	439c                	lw	a5,0(a5)
ffffffffc0200896:	97ba                	add	a5,a5,a4
ffffffffc0200898:	8782                	jr	a5
ffffffffc020089a:	00005517          	auipc	a0,0x5
ffffffffc020089e:	d4e50513          	addi	a0,a0,-690 # ffffffffc02055e8 <commands+0x4b0>
ffffffffc02008a2:	8e9ff06f          	j	ffffffffc020018a <cprintf>
ffffffffc02008a6:	00005517          	auipc	a0,0x5
ffffffffc02008aa:	d2250513          	addi	a0,a0,-734 # ffffffffc02055c8 <commands+0x490>
ffffffffc02008ae:	8ddff06f          	j	ffffffffc020018a <cprintf>
ffffffffc02008b2:	00005517          	auipc	a0,0x5
ffffffffc02008b6:	cd650513          	addi	a0,a0,-810 # ffffffffc0205588 <commands+0x450>
ffffffffc02008ba:	8d1ff06f          	j	ffffffffc020018a <cprintf>
ffffffffc02008be:	00005517          	auipc	a0,0x5
ffffffffc02008c2:	cea50513          	addi	a0,a0,-790 # ffffffffc02055a8 <commands+0x470>
ffffffffc02008c6:	8c5ff06f          	j	ffffffffc020018a <cprintf>
ffffffffc02008ca:	1141                	addi	sp,sp,-16
ffffffffc02008cc:	e406                	sd	ra,8(sp)
ffffffffc02008ce:	c05ff0ef          	jal	ra,ffffffffc02004d2 <clock_set_next_event>
ffffffffc02008d2:	00015797          	auipc	a5,0x15
ffffffffc02008d6:	c7678793          	addi	a5,a5,-906 # ffffffffc0215548 <ticks>
ffffffffc02008da:	6398                	ld	a4,0(a5)
ffffffffc02008dc:	06400693          	li	a3,100
ffffffffc02008e0:	0705                	addi	a4,a4,1
ffffffffc02008e2:	e398                	sd	a4,0(a5)
ffffffffc02008e4:	639c                	ld	a5,0(a5)
ffffffffc02008e6:	00d78c63          	beq	a5,a3,ffffffffc02008fe <interrupt_handler+0x84>
ffffffffc02008ea:	60a2                	ld	ra,8(sp)
ffffffffc02008ec:	0141                	addi	sp,sp,16
ffffffffc02008ee:	8082                	ret
ffffffffc02008f0:	00005517          	auipc	a0,0x5
ffffffffc02008f4:	d2850513          	addi	a0,a0,-728 # ffffffffc0205618 <commands+0x4e0>
ffffffffc02008f8:	893ff06f          	j	ffffffffc020018a <cprintf>
ffffffffc02008fc:	bf31                	j	ffffffffc0200818 <print_trapframe>
ffffffffc02008fe:	06400593          	li	a1,100
ffffffffc0200902:	00005517          	auipc	a0,0x5
ffffffffc0200906:	d0650513          	addi	a0,a0,-762 # ffffffffc0205608 <commands+0x4d0>
ffffffffc020090a:	00015797          	auipc	a5,0x15
ffffffffc020090e:	c207bf23          	sd	zero,-962(a5) # ffffffffc0215548 <ticks>
ffffffffc0200912:	879ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200916:	00015797          	auipc	a5,0x15
ffffffffc020091a:	c3a78793          	addi	a5,a5,-966 # ffffffffc0215550 <num>
ffffffffc020091e:	6394                	ld	a3,0(a5)
ffffffffc0200920:	4729                	li	a4,10
ffffffffc0200922:	00e69863          	bne	a3,a4,ffffffffc0200932 <interrupt_handler+0xb8>
ffffffffc0200926:	4501                	li	a0,0
ffffffffc0200928:	4581                	li	a1,0
ffffffffc020092a:	4601                	li	a2,0
ffffffffc020092c:	48a1                	li	a7,8
ffffffffc020092e:	00000073          	ecall
ffffffffc0200932:	6398                	ld	a4,0(a5)
ffffffffc0200934:	0705                	addi	a4,a4,1
ffffffffc0200936:	e398                	sd	a4,0(a5)
ffffffffc0200938:	bf4d                	j	ffffffffc02008ea <interrupt_handler+0x70>

ffffffffc020093a <exception_handler>:
ffffffffc020093a:	11853783          	ld	a5,280(a0)
ffffffffc020093e:	1101                	addi	sp,sp,-32
ffffffffc0200940:	e822                	sd	s0,16(sp)
ffffffffc0200942:	ec06                	sd	ra,24(sp)
ffffffffc0200944:	e426                	sd	s1,8(sp)
ffffffffc0200946:	473d                	li	a4,15
ffffffffc0200948:	842a                	mv	s0,a0
ffffffffc020094a:	14f76a63          	bltu	a4,a5,ffffffffc0200a9e <exception_handler+0x164>
ffffffffc020094e:	00005717          	auipc	a4,0x5
ffffffffc0200952:	ed270713          	addi	a4,a4,-302 # ffffffffc0205820 <commands+0x6e8>
ffffffffc0200956:	078a                	slli	a5,a5,0x2
ffffffffc0200958:	97ba                	add	a5,a5,a4
ffffffffc020095a:	439c                	lw	a5,0(a5)
ffffffffc020095c:	97ba                	add	a5,a5,a4
ffffffffc020095e:	8782                	jr	a5
ffffffffc0200960:	00005517          	auipc	a0,0x5
ffffffffc0200964:	ea850513          	addi	a0,a0,-344 # ffffffffc0205808 <commands+0x6d0>
ffffffffc0200968:	823ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020096c:	8522                	mv	a0,s0
ffffffffc020096e:	c55ff0ef          	jal	ra,ffffffffc02005c2 <pgfault_handler>
ffffffffc0200972:	84aa                	mv	s1,a0
ffffffffc0200974:	12051b63          	bnez	a0,ffffffffc0200aaa <exception_handler+0x170>
ffffffffc0200978:	60e2                	ld	ra,24(sp)
ffffffffc020097a:	6442                	ld	s0,16(sp)
ffffffffc020097c:	64a2                	ld	s1,8(sp)
ffffffffc020097e:	6105                	addi	sp,sp,32
ffffffffc0200980:	8082                	ret
ffffffffc0200982:	00005517          	auipc	a0,0x5
ffffffffc0200986:	ce650513          	addi	a0,a0,-794 # ffffffffc0205668 <commands+0x530>
ffffffffc020098a:	6442                	ld	s0,16(sp)
ffffffffc020098c:	60e2                	ld	ra,24(sp)
ffffffffc020098e:	64a2                	ld	s1,8(sp)
ffffffffc0200990:	6105                	addi	sp,sp,32
ffffffffc0200992:	ff8ff06f          	j	ffffffffc020018a <cprintf>
ffffffffc0200996:	00005517          	auipc	a0,0x5
ffffffffc020099a:	cf250513          	addi	a0,a0,-782 # ffffffffc0205688 <commands+0x550>
ffffffffc020099e:	b7f5                	j	ffffffffc020098a <exception_handler+0x50>
ffffffffc02009a0:	00005517          	auipc	a0,0x5
ffffffffc02009a4:	d0850513          	addi	a0,a0,-760 # ffffffffc02056a8 <commands+0x570>
ffffffffc02009a8:	b7cd                	j	ffffffffc020098a <exception_handler+0x50>
ffffffffc02009aa:	00005517          	auipc	a0,0x5
ffffffffc02009ae:	d1650513          	addi	a0,a0,-746 # ffffffffc02056c0 <commands+0x588>
ffffffffc02009b2:	bfe1                	j	ffffffffc020098a <exception_handler+0x50>
ffffffffc02009b4:	00005517          	auipc	a0,0x5
ffffffffc02009b8:	d1c50513          	addi	a0,a0,-740 # ffffffffc02056d0 <commands+0x598>
ffffffffc02009bc:	b7f9                	j	ffffffffc020098a <exception_handler+0x50>
ffffffffc02009be:	00005517          	auipc	a0,0x5
ffffffffc02009c2:	d3250513          	addi	a0,a0,-718 # ffffffffc02056f0 <commands+0x5b8>
ffffffffc02009c6:	fc4ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02009ca:	8522                	mv	a0,s0
ffffffffc02009cc:	bf7ff0ef          	jal	ra,ffffffffc02005c2 <pgfault_handler>
ffffffffc02009d0:	84aa                	mv	s1,a0
ffffffffc02009d2:	d15d                	beqz	a0,ffffffffc0200978 <exception_handler+0x3e>
ffffffffc02009d4:	8522                	mv	a0,s0
ffffffffc02009d6:	e43ff0ef          	jal	ra,ffffffffc0200818 <print_trapframe>
ffffffffc02009da:	86a6                	mv	a3,s1
ffffffffc02009dc:	00005617          	auipc	a2,0x5
ffffffffc02009e0:	d2c60613          	addi	a2,a2,-724 # ffffffffc0205708 <commands+0x5d0>
ffffffffc02009e4:	0d000593          	li	a1,208
ffffffffc02009e8:	00005517          	auipc	a0,0x5
ffffffffc02009ec:	81050513          	addi	a0,a0,-2032 # ffffffffc02051f8 <commands+0xc0>
ffffffffc02009f0:	a4fff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02009f4:	00005517          	auipc	a0,0x5
ffffffffc02009f8:	d3450513          	addi	a0,a0,-716 # ffffffffc0205728 <commands+0x5f0>
ffffffffc02009fc:	b779                	j	ffffffffc020098a <exception_handler+0x50>
ffffffffc02009fe:	00005517          	auipc	a0,0x5
ffffffffc0200a02:	d4250513          	addi	a0,a0,-702 # ffffffffc0205740 <commands+0x608>
ffffffffc0200a06:	f84ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200a0a:	8522                	mv	a0,s0
ffffffffc0200a0c:	bb7ff0ef          	jal	ra,ffffffffc02005c2 <pgfault_handler>
ffffffffc0200a10:	84aa                	mv	s1,a0
ffffffffc0200a12:	d13d                	beqz	a0,ffffffffc0200978 <exception_handler+0x3e>
ffffffffc0200a14:	8522                	mv	a0,s0
ffffffffc0200a16:	e03ff0ef          	jal	ra,ffffffffc0200818 <print_trapframe>
ffffffffc0200a1a:	86a6                	mv	a3,s1
ffffffffc0200a1c:	00005617          	auipc	a2,0x5
ffffffffc0200a20:	cec60613          	addi	a2,a2,-788 # ffffffffc0205708 <commands+0x5d0>
ffffffffc0200a24:	0da00593          	li	a1,218
ffffffffc0200a28:	00004517          	auipc	a0,0x4
ffffffffc0200a2c:	7d050513          	addi	a0,a0,2000 # ffffffffc02051f8 <commands+0xc0>
ffffffffc0200a30:	a0fff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200a34:	00005517          	auipc	a0,0x5
ffffffffc0200a38:	d2450513          	addi	a0,a0,-732 # ffffffffc0205758 <commands+0x620>
ffffffffc0200a3c:	b7b9                	j	ffffffffc020098a <exception_handler+0x50>
ffffffffc0200a3e:	00005517          	auipc	a0,0x5
ffffffffc0200a42:	d3a50513          	addi	a0,a0,-710 # ffffffffc0205778 <commands+0x640>
ffffffffc0200a46:	b791                	j	ffffffffc020098a <exception_handler+0x50>
ffffffffc0200a48:	00005517          	auipc	a0,0x5
ffffffffc0200a4c:	d5050513          	addi	a0,a0,-688 # ffffffffc0205798 <commands+0x660>
ffffffffc0200a50:	bf2d                	j	ffffffffc020098a <exception_handler+0x50>
ffffffffc0200a52:	00005517          	auipc	a0,0x5
ffffffffc0200a56:	d6650513          	addi	a0,a0,-666 # ffffffffc02057b8 <commands+0x680>
ffffffffc0200a5a:	bf05                	j	ffffffffc020098a <exception_handler+0x50>
ffffffffc0200a5c:	00005517          	auipc	a0,0x5
ffffffffc0200a60:	d7c50513          	addi	a0,a0,-644 # ffffffffc02057d8 <commands+0x6a0>
ffffffffc0200a64:	b71d                	j	ffffffffc020098a <exception_handler+0x50>
ffffffffc0200a66:	00005517          	auipc	a0,0x5
ffffffffc0200a6a:	d8a50513          	addi	a0,a0,-630 # ffffffffc02057f0 <commands+0x6b8>
ffffffffc0200a6e:	f1cff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200a72:	8522                	mv	a0,s0
ffffffffc0200a74:	b4fff0ef          	jal	ra,ffffffffc02005c2 <pgfault_handler>
ffffffffc0200a78:	84aa                	mv	s1,a0
ffffffffc0200a7a:	ee050fe3          	beqz	a0,ffffffffc0200978 <exception_handler+0x3e>
ffffffffc0200a7e:	8522                	mv	a0,s0
ffffffffc0200a80:	d99ff0ef          	jal	ra,ffffffffc0200818 <print_trapframe>
ffffffffc0200a84:	86a6                	mv	a3,s1
ffffffffc0200a86:	00005617          	auipc	a2,0x5
ffffffffc0200a8a:	c8260613          	addi	a2,a2,-894 # ffffffffc0205708 <commands+0x5d0>
ffffffffc0200a8e:	0f000593          	li	a1,240
ffffffffc0200a92:	00004517          	auipc	a0,0x4
ffffffffc0200a96:	76650513          	addi	a0,a0,1894 # ffffffffc02051f8 <commands+0xc0>
ffffffffc0200a9a:	9a5ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200a9e:	8522                	mv	a0,s0
ffffffffc0200aa0:	6442                	ld	s0,16(sp)
ffffffffc0200aa2:	60e2                	ld	ra,24(sp)
ffffffffc0200aa4:	64a2                	ld	s1,8(sp)
ffffffffc0200aa6:	6105                	addi	sp,sp,32
ffffffffc0200aa8:	bb85                	j	ffffffffc0200818 <print_trapframe>
ffffffffc0200aaa:	8522                	mv	a0,s0
ffffffffc0200aac:	d6dff0ef          	jal	ra,ffffffffc0200818 <print_trapframe>
ffffffffc0200ab0:	86a6                	mv	a3,s1
ffffffffc0200ab2:	00005617          	auipc	a2,0x5
ffffffffc0200ab6:	c5660613          	addi	a2,a2,-938 # ffffffffc0205708 <commands+0x5d0>
ffffffffc0200aba:	0f700593          	li	a1,247
ffffffffc0200abe:	00004517          	auipc	a0,0x4
ffffffffc0200ac2:	73a50513          	addi	a0,a0,1850 # ffffffffc02051f8 <commands+0xc0>
ffffffffc0200ac6:	979ff0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0200aca <trap>:
ffffffffc0200aca:	11853783          	ld	a5,280(a0)
ffffffffc0200ace:	0007c363          	bltz	a5,ffffffffc0200ad4 <trap+0xa>
ffffffffc0200ad2:	b5a5                	j	ffffffffc020093a <exception_handler>
ffffffffc0200ad4:	b35d                	j	ffffffffc020087a <interrupt_handler>
	...

ffffffffc0200ad8 <__alltraps>:
ffffffffc0200ad8:	14011073          	csrw	sscratch,sp
ffffffffc0200adc:	712d                	addi	sp,sp,-288
ffffffffc0200ade:	e406                	sd	ra,8(sp)
ffffffffc0200ae0:	ec0e                	sd	gp,24(sp)
ffffffffc0200ae2:	f012                	sd	tp,32(sp)
ffffffffc0200ae4:	f416                	sd	t0,40(sp)
ffffffffc0200ae6:	f81a                	sd	t1,48(sp)
ffffffffc0200ae8:	fc1e                	sd	t2,56(sp)
ffffffffc0200aea:	e0a2                	sd	s0,64(sp)
ffffffffc0200aec:	e4a6                	sd	s1,72(sp)
ffffffffc0200aee:	e8aa                	sd	a0,80(sp)
ffffffffc0200af0:	ecae                	sd	a1,88(sp)
ffffffffc0200af2:	f0b2                	sd	a2,96(sp)
ffffffffc0200af4:	f4b6                	sd	a3,104(sp)
ffffffffc0200af6:	f8ba                	sd	a4,112(sp)
ffffffffc0200af8:	fcbe                	sd	a5,120(sp)
ffffffffc0200afa:	e142                	sd	a6,128(sp)
ffffffffc0200afc:	e546                	sd	a7,136(sp)
ffffffffc0200afe:	e94a                	sd	s2,144(sp)
ffffffffc0200b00:	ed4e                	sd	s3,152(sp)
ffffffffc0200b02:	f152                	sd	s4,160(sp)
ffffffffc0200b04:	f556                	sd	s5,168(sp)
ffffffffc0200b06:	f95a                	sd	s6,176(sp)
ffffffffc0200b08:	fd5e                	sd	s7,184(sp)
ffffffffc0200b0a:	e1e2                	sd	s8,192(sp)
ffffffffc0200b0c:	e5e6                	sd	s9,200(sp)
ffffffffc0200b0e:	e9ea                	sd	s10,208(sp)
ffffffffc0200b10:	edee                	sd	s11,216(sp)
ffffffffc0200b12:	f1f2                	sd	t3,224(sp)
ffffffffc0200b14:	f5f6                	sd	t4,232(sp)
ffffffffc0200b16:	f9fa                	sd	t5,240(sp)
ffffffffc0200b18:	fdfe                	sd	t6,248(sp)
ffffffffc0200b1a:	14002473          	csrr	s0,sscratch
ffffffffc0200b1e:	100024f3          	csrr	s1,sstatus
ffffffffc0200b22:	14102973          	csrr	s2,sepc
ffffffffc0200b26:	143029f3          	csrr	s3,stval
ffffffffc0200b2a:	14202a73          	csrr	s4,scause
ffffffffc0200b2e:	e822                	sd	s0,16(sp)
ffffffffc0200b30:	e226                	sd	s1,256(sp)
ffffffffc0200b32:	e64a                	sd	s2,264(sp)
ffffffffc0200b34:	ea4e                	sd	s3,272(sp)
ffffffffc0200b36:	ee52                	sd	s4,280(sp)
ffffffffc0200b38:	850a                	mv	a0,sp
ffffffffc0200b3a:	f91ff0ef          	jal	ra,ffffffffc0200aca <trap>

ffffffffc0200b3e <__trapret>:
ffffffffc0200b3e:	6492                	ld	s1,256(sp)
ffffffffc0200b40:	6932                	ld	s2,264(sp)
ffffffffc0200b42:	10049073          	csrw	sstatus,s1
ffffffffc0200b46:	14191073          	csrw	sepc,s2
ffffffffc0200b4a:	60a2                	ld	ra,8(sp)
ffffffffc0200b4c:	61e2                	ld	gp,24(sp)
ffffffffc0200b4e:	7202                	ld	tp,32(sp)
ffffffffc0200b50:	72a2                	ld	t0,40(sp)
ffffffffc0200b52:	7342                	ld	t1,48(sp)
ffffffffc0200b54:	73e2                	ld	t2,56(sp)
ffffffffc0200b56:	6406                	ld	s0,64(sp)
ffffffffc0200b58:	64a6                	ld	s1,72(sp)
ffffffffc0200b5a:	6546                	ld	a0,80(sp)
ffffffffc0200b5c:	65e6                	ld	a1,88(sp)
ffffffffc0200b5e:	7606                	ld	a2,96(sp)
ffffffffc0200b60:	76a6                	ld	a3,104(sp)
ffffffffc0200b62:	7746                	ld	a4,112(sp)
ffffffffc0200b64:	77e6                	ld	a5,120(sp)
ffffffffc0200b66:	680a                	ld	a6,128(sp)
ffffffffc0200b68:	68aa                	ld	a7,136(sp)
ffffffffc0200b6a:	694a                	ld	s2,144(sp)
ffffffffc0200b6c:	69ea                	ld	s3,152(sp)
ffffffffc0200b6e:	7a0a                	ld	s4,160(sp)
ffffffffc0200b70:	7aaa                	ld	s5,168(sp)
ffffffffc0200b72:	7b4a                	ld	s6,176(sp)
ffffffffc0200b74:	7bea                	ld	s7,184(sp)
ffffffffc0200b76:	6c0e                	ld	s8,192(sp)
ffffffffc0200b78:	6cae                	ld	s9,200(sp)
ffffffffc0200b7a:	6d4e                	ld	s10,208(sp)
ffffffffc0200b7c:	6dee                	ld	s11,216(sp)
ffffffffc0200b7e:	7e0e                	ld	t3,224(sp)
ffffffffc0200b80:	7eae                	ld	t4,232(sp)
ffffffffc0200b82:	7f4e                	ld	t5,240(sp)
ffffffffc0200b84:	7fee                	ld	t6,248(sp)
ffffffffc0200b86:	6142                	ld	sp,16(sp)
ffffffffc0200b88:	10200073          	sret

ffffffffc0200b8c <forkrets>:
ffffffffc0200b8c:	812a                	mv	sp,a0
ffffffffc0200b8e:	bf45                	j	ffffffffc0200b3e <__trapret>
	...

ffffffffc0200b92 <default_init>:
ffffffffc0200b92:	00011797          	auipc	a5,0x11
ffffffffc0200b96:	8ce78793          	addi	a5,a5,-1842 # ffffffffc0211460 <free_area>
ffffffffc0200b9a:	e79c                	sd	a5,8(a5)
ffffffffc0200b9c:	e39c                	sd	a5,0(a5)
ffffffffc0200b9e:	0007a823          	sw	zero,16(a5)
ffffffffc0200ba2:	8082                	ret

ffffffffc0200ba4 <default_nr_free_pages>:
ffffffffc0200ba4:	00011517          	auipc	a0,0x11
ffffffffc0200ba8:	8cc56503          	lwu	a0,-1844(a0) # ffffffffc0211470 <free_area+0x10>
ffffffffc0200bac:	8082                	ret

ffffffffc0200bae <default_check>:
ffffffffc0200bae:	715d                	addi	sp,sp,-80
ffffffffc0200bb0:	e0a2                	sd	s0,64(sp)
ffffffffc0200bb2:	00011417          	auipc	s0,0x11
ffffffffc0200bb6:	8ae40413          	addi	s0,s0,-1874 # ffffffffc0211460 <free_area>
ffffffffc0200bba:	641c                	ld	a5,8(s0)
ffffffffc0200bbc:	e486                	sd	ra,72(sp)
ffffffffc0200bbe:	fc26                	sd	s1,56(sp)
ffffffffc0200bc0:	f84a                	sd	s2,48(sp)
ffffffffc0200bc2:	f44e                	sd	s3,40(sp)
ffffffffc0200bc4:	f052                	sd	s4,32(sp)
ffffffffc0200bc6:	ec56                	sd	s5,24(sp)
ffffffffc0200bc8:	e85a                	sd	s6,16(sp)
ffffffffc0200bca:	e45e                	sd	s7,8(sp)
ffffffffc0200bcc:	e062                	sd	s8,0(sp)
ffffffffc0200bce:	2a878d63          	beq	a5,s0,ffffffffc0200e88 <default_check+0x2da>
ffffffffc0200bd2:	4481                	li	s1,0
ffffffffc0200bd4:	4901                	li	s2,0
ffffffffc0200bd6:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200bda:	8b09                	andi	a4,a4,2
ffffffffc0200bdc:	2a070a63          	beqz	a4,ffffffffc0200e90 <default_check+0x2e2>
ffffffffc0200be0:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200be4:	679c                	ld	a5,8(a5)
ffffffffc0200be6:	2905                	addiw	s2,s2,1
ffffffffc0200be8:	9cb9                	addw	s1,s1,a4
ffffffffc0200bea:	fe8796e3          	bne	a5,s0,ffffffffc0200bd6 <default_check+0x28>
ffffffffc0200bee:	89a6                	mv	s3,s1
ffffffffc0200bf0:	721000ef          	jal	ra,ffffffffc0201b10 <nr_free_pages>
ffffffffc0200bf4:	6f351e63          	bne	a0,s3,ffffffffc02012f0 <default_check+0x742>
ffffffffc0200bf8:	4505                	li	a0,1
ffffffffc0200bfa:	647000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0200bfe:	8aaa                	mv	s5,a0
ffffffffc0200c00:	42050863          	beqz	a0,ffffffffc0201030 <default_check+0x482>
ffffffffc0200c04:	4505                	li	a0,1
ffffffffc0200c06:	63b000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0200c0a:	89aa                	mv	s3,a0
ffffffffc0200c0c:	70050263          	beqz	a0,ffffffffc0201310 <default_check+0x762>
ffffffffc0200c10:	4505                	li	a0,1
ffffffffc0200c12:	62f000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0200c16:	8a2a                	mv	s4,a0
ffffffffc0200c18:	48050c63          	beqz	a0,ffffffffc02010b0 <default_check+0x502>
ffffffffc0200c1c:	293a8a63          	beq	s5,s3,ffffffffc0200eb0 <default_check+0x302>
ffffffffc0200c20:	28aa8863          	beq	s5,a0,ffffffffc0200eb0 <default_check+0x302>
ffffffffc0200c24:	28a98663          	beq	s3,a0,ffffffffc0200eb0 <default_check+0x302>
ffffffffc0200c28:	000aa783          	lw	a5,0(s5)
ffffffffc0200c2c:	2a079263          	bnez	a5,ffffffffc0200ed0 <default_check+0x322>
ffffffffc0200c30:	0009a783          	lw	a5,0(s3)
ffffffffc0200c34:	28079e63          	bnez	a5,ffffffffc0200ed0 <default_check+0x322>
ffffffffc0200c38:	411c                	lw	a5,0(a0)
ffffffffc0200c3a:	28079b63          	bnez	a5,ffffffffc0200ed0 <default_check+0x322>
ffffffffc0200c3e:	00015797          	auipc	a5,0x15
ffffffffc0200c42:	94a7b783          	ld	a5,-1718(a5) # ffffffffc0215588 <pages>
ffffffffc0200c46:	40fa8733          	sub	a4,s5,a5
ffffffffc0200c4a:	00006617          	auipc	a2,0x6
ffffffffc0200c4e:	3ae63603          	ld	a2,942(a2) # ffffffffc0206ff8 <nbase>
ffffffffc0200c52:	8719                	srai	a4,a4,0x6
ffffffffc0200c54:	9732                	add	a4,a4,a2
ffffffffc0200c56:	00015697          	auipc	a3,0x15
ffffffffc0200c5a:	92a6b683          	ld	a3,-1750(a3) # ffffffffc0215580 <npage>
ffffffffc0200c5e:	06b2                	slli	a3,a3,0xc
ffffffffc0200c60:	0732                	slli	a4,a4,0xc
ffffffffc0200c62:	28d77763          	bgeu	a4,a3,ffffffffc0200ef0 <default_check+0x342>
ffffffffc0200c66:	40f98733          	sub	a4,s3,a5
ffffffffc0200c6a:	8719                	srai	a4,a4,0x6
ffffffffc0200c6c:	9732                	add	a4,a4,a2
ffffffffc0200c6e:	0732                	slli	a4,a4,0xc
ffffffffc0200c70:	4cd77063          	bgeu	a4,a3,ffffffffc0201130 <default_check+0x582>
ffffffffc0200c74:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c78:	8799                	srai	a5,a5,0x6
ffffffffc0200c7a:	97b2                	add	a5,a5,a2
ffffffffc0200c7c:	07b2                	slli	a5,a5,0xc
ffffffffc0200c7e:	30d7f963          	bgeu	a5,a3,ffffffffc0200f90 <default_check+0x3e2>
ffffffffc0200c82:	4505                	li	a0,1
ffffffffc0200c84:	00043c03          	ld	s8,0(s0)
ffffffffc0200c88:	00843b83          	ld	s7,8(s0)
ffffffffc0200c8c:	01042b03          	lw	s6,16(s0)
ffffffffc0200c90:	e400                	sd	s0,8(s0)
ffffffffc0200c92:	e000                	sd	s0,0(s0)
ffffffffc0200c94:	00010797          	auipc	a5,0x10
ffffffffc0200c98:	7c07ae23          	sw	zero,2012(a5) # ffffffffc0211470 <free_area+0x10>
ffffffffc0200c9c:	5a5000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0200ca0:	2c051863          	bnez	a0,ffffffffc0200f70 <default_check+0x3c2>
ffffffffc0200ca4:	4585                	li	a1,1
ffffffffc0200ca6:	8556                	mv	a0,s5
ffffffffc0200ca8:	629000ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0200cac:	4585                	li	a1,1
ffffffffc0200cae:	854e                	mv	a0,s3
ffffffffc0200cb0:	621000ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0200cb4:	4585                	li	a1,1
ffffffffc0200cb6:	8552                	mv	a0,s4
ffffffffc0200cb8:	619000ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0200cbc:	4818                	lw	a4,16(s0)
ffffffffc0200cbe:	478d                	li	a5,3
ffffffffc0200cc0:	28f71863          	bne	a4,a5,ffffffffc0200f50 <default_check+0x3a2>
ffffffffc0200cc4:	4505                	li	a0,1
ffffffffc0200cc6:	57b000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0200cca:	89aa                	mv	s3,a0
ffffffffc0200ccc:	26050263          	beqz	a0,ffffffffc0200f30 <default_check+0x382>
ffffffffc0200cd0:	4505                	li	a0,1
ffffffffc0200cd2:	56f000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0200cd6:	8aaa                	mv	s5,a0
ffffffffc0200cd8:	3a050c63          	beqz	a0,ffffffffc0201090 <default_check+0x4e2>
ffffffffc0200cdc:	4505                	li	a0,1
ffffffffc0200cde:	563000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0200ce2:	8a2a                	mv	s4,a0
ffffffffc0200ce4:	38050663          	beqz	a0,ffffffffc0201070 <default_check+0x4c2>
ffffffffc0200ce8:	4505                	li	a0,1
ffffffffc0200cea:	557000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0200cee:	36051163          	bnez	a0,ffffffffc0201050 <default_check+0x4a2>
ffffffffc0200cf2:	4585                	li	a1,1
ffffffffc0200cf4:	854e                	mv	a0,s3
ffffffffc0200cf6:	5db000ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0200cfa:	641c                	ld	a5,8(s0)
ffffffffc0200cfc:	20878a63          	beq	a5,s0,ffffffffc0200f10 <default_check+0x362>
ffffffffc0200d00:	4505                	li	a0,1
ffffffffc0200d02:	53f000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0200d06:	30a99563          	bne	s3,a0,ffffffffc0201010 <default_check+0x462>
ffffffffc0200d0a:	4505                	li	a0,1
ffffffffc0200d0c:	535000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0200d10:	2e051063          	bnez	a0,ffffffffc0200ff0 <default_check+0x442>
ffffffffc0200d14:	481c                	lw	a5,16(s0)
ffffffffc0200d16:	2a079d63          	bnez	a5,ffffffffc0200fd0 <default_check+0x422>
ffffffffc0200d1a:	854e                	mv	a0,s3
ffffffffc0200d1c:	4585                	li	a1,1
ffffffffc0200d1e:	01843023          	sd	s8,0(s0)
ffffffffc0200d22:	01743423          	sd	s7,8(s0)
ffffffffc0200d26:	01642823          	sw	s6,16(s0)
ffffffffc0200d2a:	5a7000ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0200d2e:	4585                	li	a1,1
ffffffffc0200d30:	8556                	mv	a0,s5
ffffffffc0200d32:	59f000ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0200d36:	4585                	li	a1,1
ffffffffc0200d38:	8552                	mv	a0,s4
ffffffffc0200d3a:	597000ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0200d3e:	4515                	li	a0,5
ffffffffc0200d40:	501000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0200d44:	89aa                	mv	s3,a0
ffffffffc0200d46:	26050563          	beqz	a0,ffffffffc0200fb0 <default_check+0x402>
ffffffffc0200d4a:	651c                	ld	a5,8(a0)
ffffffffc0200d4c:	8385                	srli	a5,a5,0x1
ffffffffc0200d4e:	8b85                	andi	a5,a5,1
ffffffffc0200d50:	54079063          	bnez	a5,ffffffffc0201290 <default_check+0x6e2>
ffffffffc0200d54:	4505                	li	a0,1
ffffffffc0200d56:	00043b03          	ld	s6,0(s0)
ffffffffc0200d5a:	00843a83          	ld	s5,8(s0)
ffffffffc0200d5e:	e000                	sd	s0,0(s0)
ffffffffc0200d60:	e400                	sd	s0,8(s0)
ffffffffc0200d62:	4df000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0200d66:	50051563          	bnez	a0,ffffffffc0201270 <default_check+0x6c2>
ffffffffc0200d6a:	08098a13          	addi	s4,s3,128
ffffffffc0200d6e:	8552                	mv	a0,s4
ffffffffc0200d70:	458d                	li	a1,3
ffffffffc0200d72:	01042b83          	lw	s7,16(s0)
ffffffffc0200d76:	00010797          	auipc	a5,0x10
ffffffffc0200d7a:	6e07ad23          	sw	zero,1786(a5) # ffffffffc0211470 <free_area+0x10>
ffffffffc0200d7e:	553000ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0200d82:	4511                	li	a0,4
ffffffffc0200d84:	4bd000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0200d88:	4c051463          	bnez	a0,ffffffffc0201250 <default_check+0x6a2>
ffffffffc0200d8c:	0889b783          	ld	a5,136(s3)
ffffffffc0200d90:	8385                	srli	a5,a5,0x1
ffffffffc0200d92:	8b85                	andi	a5,a5,1
ffffffffc0200d94:	48078e63          	beqz	a5,ffffffffc0201230 <default_check+0x682>
ffffffffc0200d98:	0909a703          	lw	a4,144(s3)
ffffffffc0200d9c:	478d                	li	a5,3
ffffffffc0200d9e:	48f71963          	bne	a4,a5,ffffffffc0201230 <default_check+0x682>
ffffffffc0200da2:	450d                	li	a0,3
ffffffffc0200da4:	49d000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0200da8:	8c2a                	mv	s8,a0
ffffffffc0200daa:	46050363          	beqz	a0,ffffffffc0201210 <default_check+0x662>
ffffffffc0200dae:	4505                	li	a0,1
ffffffffc0200db0:	491000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0200db4:	42051e63          	bnez	a0,ffffffffc02011f0 <default_check+0x642>
ffffffffc0200db8:	418a1c63          	bne	s4,s8,ffffffffc02011d0 <default_check+0x622>
ffffffffc0200dbc:	4585                	li	a1,1
ffffffffc0200dbe:	854e                	mv	a0,s3
ffffffffc0200dc0:	511000ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0200dc4:	458d                	li	a1,3
ffffffffc0200dc6:	8552                	mv	a0,s4
ffffffffc0200dc8:	509000ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0200dcc:	0089b783          	ld	a5,8(s3)
ffffffffc0200dd0:	04098c13          	addi	s8,s3,64
ffffffffc0200dd4:	8385                	srli	a5,a5,0x1
ffffffffc0200dd6:	8b85                	andi	a5,a5,1
ffffffffc0200dd8:	3c078c63          	beqz	a5,ffffffffc02011b0 <default_check+0x602>
ffffffffc0200ddc:	0109a703          	lw	a4,16(s3)
ffffffffc0200de0:	4785                	li	a5,1
ffffffffc0200de2:	3cf71763          	bne	a4,a5,ffffffffc02011b0 <default_check+0x602>
ffffffffc0200de6:	008a3783          	ld	a5,8(s4)
ffffffffc0200dea:	8385                	srli	a5,a5,0x1
ffffffffc0200dec:	8b85                	andi	a5,a5,1
ffffffffc0200dee:	3a078163          	beqz	a5,ffffffffc0201190 <default_check+0x5e2>
ffffffffc0200df2:	010a2703          	lw	a4,16(s4)
ffffffffc0200df6:	478d                	li	a5,3
ffffffffc0200df8:	38f71c63          	bne	a4,a5,ffffffffc0201190 <default_check+0x5e2>
ffffffffc0200dfc:	4505                	li	a0,1
ffffffffc0200dfe:	443000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0200e02:	36a99763          	bne	s3,a0,ffffffffc0201170 <default_check+0x5c2>
ffffffffc0200e06:	4585                	li	a1,1
ffffffffc0200e08:	4c9000ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0200e0c:	4509                	li	a0,2
ffffffffc0200e0e:	433000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0200e12:	32aa1f63          	bne	s4,a0,ffffffffc0201150 <default_check+0x5a2>
ffffffffc0200e16:	4589                	li	a1,2
ffffffffc0200e18:	4b9000ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0200e1c:	4585                	li	a1,1
ffffffffc0200e1e:	8562                	mv	a0,s8
ffffffffc0200e20:	4b1000ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0200e24:	4515                	li	a0,5
ffffffffc0200e26:	41b000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0200e2a:	89aa                	mv	s3,a0
ffffffffc0200e2c:	48050263          	beqz	a0,ffffffffc02012b0 <default_check+0x702>
ffffffffc0200e30:	4505                	li	a0,1
ffffffffc0200e32:	40f000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0200e36:	2c051d63          	bnez	a0,ffffffffc0201110 <default_check+0x562>
ffffffffc0200e3a:	481c                	lw	a5,16(s0)
ffffffffc0200e3c:	2a079a63          	bnez	a5,ffffffffc02010f0 <default_check+0x542>
ffffffffc0200e40:	4595                	li	a1,5
ffffffffc0200e42:	854e                	mv	a0,s3
ffffffffc0200e44:	01742823          	sw	s7,16(s0)
ffffffffc0200e48:	01643023          	sd	s6,0(s0)
ffffffffc0200e4c:	01543423          	sd	s5,8(s0)
ffffffffc0200e50:	481000ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0200e54:	641c                	ld	a5,8(s0)
ffffffffc0200e56:	00878963          	beq	a5,s0,ffffffffc0200e68 <default_check+0x2ba>
ffffffffc0200e5a:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e5e:	679c                	ld	a5,8(a5)
ffffffffc0200e60:	397d                	addiw	s2,s2,-1
ffffffffc0200e62:	9c99                	subw	s1,s1,a4
ffffffffc0200e64:	fe879be3          	bne	a5,s0,ffffffffc0200e5a <default_check+0x2ac>
ffffffffc0200e68:	26091463          	bnez	s2,ffffffffc02010d0 <default_check+0x522>
ffffffffc0200e6c:	46049263          	bnez	s1,ffffffffc02012d0 <default_check+0x722>
ffffffffc0200e70:	60a6                	ld	ra,72(sp)
ffffffffc0200e72:	6406                	ld	s0,64(sp)
ffffffffc0200e74:	74e2                	ld	s1,56(sp)
ffffffffc0200e76:	7942                	ld	s2,48(sp)
ffffffffc0200e78:	79a2                	ld	s3,40(sp)
ffffffffc0200e7a:	7a02                	ld	s4,32(sp)
ffffffffc0200e7c:	6ae2                	ld	s5,24(sp)
ffffffffc0200e7e:	6b42                	ld	s6,16(sp)
ffffffffc0200e80:	6ba2                	ld	s7,8(sp)
ffffffffc0200e82:	6c02                	ld	s8,0(sp)
ffffffffc0200e84:	6161                	addi	sp,sp,80
ffffffffc0200e86:	8082                	ret
ffffffffc0200e88:	4981                	li	s3,0
ffffffffc0200e8a:	4481                	li	s1,0
ffffffffc0200e8c:	4901                	li	s2,0
ffffffffc0200e8e:	b38d                	j	ffffffffc0200bf0 <default_check+0x42>
ffffffffc0200e90:	00005697          	auipc	a3,0x5
ffffffffc0200e94:	9d068693          	addi	a3,a3,-1584 # ffffffffc0205860 <commands+0x728>
ffffffffc0200e98:	00005617          	auipc	a2,0x5
ffffffffc0200e9c:	9d860613          	addi	a2,a2,-1576 # ffffffffc0205870 <commands+0x738>
ffffffffc0200ea0:	0f000593          	li	a1,240
ffffffffc0200ea4:	00005517          	auipc	a0,0x5
ffffffffc0200ea8:	9e450513          	addi	a0,a0,-1564 # ffffffffc0205888 <commands+0x750>
ffffffffc0200eac:	d92ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200eb0:	00005697          	auipc	a3,0x5
ffffffffc0200eb4:	a7068693          	addi	a3,a3,-1424 # ffffffffc0205920 <commands+0x7e8>
ffffffffc0200eb8:	00005617          	auipc	a2,0x5
ffffffffc0200ebc:	9b860613          	addi	a2,a2,-1608 # ffffffffc0205870 <commands+0x738>
ffffffffc0200ec0:	0bd00593          	li	a1,189
ffffffffc0200ec4:	00005517          	auipc	a0,0x5
ffffffffc0200ec8:	9c450513          	addi	a0,a0,-1596 # ffffffffc0205888 <commands+0x750>
ffffffffc0200ecc:	d72ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200ed0:	00005697          	auipc	a3,0x5
ffffffffc0200ed4:	a7868693          	addi	a3,a3,-1416 # ffffffffc0205948 <commands+0x810>
ffffffffc0200ed8:	00005617          	auipc	a2,0x5
ffffffffc0200edc:	99860613          	addi	a2,a2,-1640 # ffffffffc0205870 <commands+0x738>
ffffffffc0200ee0:	0be00593          	li	a1,190
ffffffffc0200ee4:	00005517          	auipc	a0,0x5
ffffffffc0200ee8:	9a450513          	addi	a0,a0,-1628 # ffffffffc0205888 <commands+0x750>
ffffffffc0200eec:	d52ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200ef0:	00005697          	auipc	a3,0x5
ffffffffc0200ef4:	a9868693          	addi	a3,a3,-1384 # ffffffffc0205988 <commands+0x850>
ffffffffc0200ef8:	00005617          	auipc	a2,0x5
ffffffffc0200efc:	97860613          	addi	a2,a2,-1672 # ffffffffc0205870 <commands+0x738>
ffffffffc0200f00:	0c000593          	li	a1,192
ffffffffc0200f04:	00005517          	auipc	a0,0x5
ffffffffc0200f08:	98450513          	addi	a0,a0,-1660 # ffffffffc0205888 <commands+0x750>
ffffffffc0200f0c:	d32ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200f10:	00005697          	auipc	a3,0x5
ffffffffc0200f14:	b0068693          	addi	a3,a3,-1280 # ffffffffc0205a10 <commands+0x8d8>
ffffffffc0200f18:	00005617          	auipc	a2,0x5
ffffffffc0200f1c:	95860613          	addi	a2,a2,-1704 # ffffffffc0205870 <commands+0x738>
ffffffffc0200f20:	0d900593          	li	a1,217
ffffffffc0200f24:	00005517          	auipc	a0,0x5
ffffffffc0200f28:	96450513          	addi	a0,a0,-1692 # ffffffffc0205888 <commands+0x750>
ffffffffc0200f2c:	d12ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200f30:	00005697          	auipc	a3,0x5
ffffffffc0200f34:	99068693          	addi	a3,a3,-1648 # ffffffffc02058c0 <commands+0x788>
ffffffffc0200f38:	00005617          	auipc	a2,0x5
ffffffffc0200f3c:	93860613          	addi	a2,a2,-1736 # ffffffffc0205870 <commands+0x738>
ffffffffc0200f40:	0d200593          	li	a1,210
ffffffffc0200f44:	00005517          	auipc	a0,0x5
ffffffffc0200f48:	94450513          	addi	a0,a0,-1724 # ffffffffc0205888 <commands+0x750>
ffffffffc0200f4c:	cf2ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200f50:	00005697          	auipc	a3,0x5
ffffffffc0200f54:	ab068693          	addi	a3,a3,-1360 # ffffffffc0205a00 <commands+0x8c8>
ffffffffc0200f58:	00005617          	auipc	a2,0x5
ffffffffc0200f5c:	91860613          	addi	a2,a2,-1768 # ffffffffc0205870 <commands+0x738>
ffffffffc0200f60:	0d000593          	li	a1,208
ffffffffc0200f64:	00005517          	auipc	a0,0x5
ffffffffc0200f68:	92450513          	addi	a0,a0,-1756 # ffffffffc0205888 <commands+0x750>
ffffffffc0200f6c:	cd2ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200f70:	00005697          	auipc	a3,0x5
ffffffffc0200f74:	a7868693          	addi	a3,a3,-1416 # ffffffffc02059e8 <commands+0x8b0>
ffffffffc0200f78:	00005617          	auipc	a2,0x5
ffffffffc0200f7c:	8f860613          	addi	a2,a2,-1800 # ffffffffc0205870 <commands+0x738>
ffffffffc0200f80:	0cb00593          	li	a1,203
ffffffffc0200f84:	00005517          	auipc	a0,0x5
ffffffffc0200f88:	90450513          	addi	a0,a0,-1788 # ffffffffc0205888 <commands+0x750>
ffffffffc0200f8c:	cb2ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200f90:	00005697          	auipc	a3,0x5
ffffffffc0200f94:	a3868693          	addi	a3,a3,-1480 # ffffffffc02059c8 <commands+0x890>
ffffffffc0200f98:	00005617          	auipc	a2,0x5
ffffffffc0200f9c:	8d860613          	addi	a2,a2,-1832 # ffffffffc0205870 <commands+0x738>
ffffffffc0200fa0:	0c200593          	li	a1,194
ffffffffc0200fa4:	00005517          	auipc	a0,0x5
ffffffffc0200fa8:	8e450513          	addi	a0,a0,-1820 # ffffffffc0205888 <commands+0x750>
ffffffffc0200fac:	c92ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200fb0:	00005697          	auipc	a3,0x5
ffffffffc0200fb4:	aa868693          	addi	a3,a3,-1368 # ffffffffc0205a58 <commands+0x920>
ffffffffc0200fb8:	00005617          	auipc	a2,0x5
ffffffffc0200fbc:	8b860613          	addi	a2,a2,-1864 # ffffffffc0205870 <commands+0x738>
ffffffffc0200fc0:	0f800593          	li	a1,248
ffffffffc0200fc4:	00005517          	auipc	a0,0x5
ffffffffc0200fc8:	8c450513          	addi	a0,a0,-1852 # ffffffffc0205888 <commands+0x750>
ffffffffc0200fcc:	c72ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200fd0:	00005697          	auipc	a3,0x5
ffffffffc0200fd4:	a7868693          	addi	a3,a3,-1416 # ffffffffc0205a48 <commands+0x910>
ffffffffc0200fd8:	00005617          	auipc	a2,0x5
ffffffffc0200fdc:	89860613          	addi	a2,a2,-1896 # ffffffffc0205870 <commands+0x738>
ffffffffc0200fe0:	0df00593          	li	a1,223
ffffffffc0200fe4:	00005517          	auipc	a0,0x5
ffffffffc0200fe8:	8a450513          	addi	a0,a0,-1884 # ffffffffc0205888 <commands+0x750>
ffffffffc0200fec:	c52ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200ff0:	00005697          	auipc	a3,0x5
ffffffffc0200ff4:	9f868693          	addi	a3,a3,-1544 # ffffffffc02059e8 <commands+0x8b0>
ffffffffc0200ff8:	00005617          	auipc	a2,0x5
ffffffffc0200ffc:	87860613          	addi	a2,a2,-1928 # ffffffffc0205870 <commands+0x738>
ffffffffc0201000:	0dd00593          	li	a1,221
ffffffffc0201004:	00005517          	auipc	a0,0x5
ffffffffc0201008:	88450513          	addi	a0,a0,-1916 # ffffffffc0205888 <commands+0x750>
ffffffffc020100c:	c32ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201010:	00005697          	auipc	a3,0x5
ffffffffc0201014:	a1868693          	addi	a3,a3,-1512 # ffffffffc0205a28 <commands+0x8f0>
ffffffffc0201018:	00005617          	auipc	a2,0x5
ffffffffc020101c:	85860613          	addi	a2,a2,-1960 # ffffffffc0205870 <commands+0x738>
ffffffffc0201020:	0dc00593          	li	a1,220
ffffffffc0201024:	00005517          	auipc	a0,0x5
ffffffffc0201028:	86450513          	addi	a0,a0,-1948 # ffffffffc0205888 <commands+0x750>
ffffffffc020102c:	c12ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201030:	00005697          	auipc	a3,0x5
ffffffffc0201034:	89068693          	addi	a3,a3,-1904 # ffffffffc02058c0 <commands+0x788>
ffffffffc0201038:	00005617          	auipc	a2,0x5
ffffffffc020103c:	83860613          	addi	a2,a2,-1992 # ffffffffc0205870 <commands+0x738>
ffffffffc0201040:	0b900593          	li	a1,185
ffffffffc0201044:	00005517          	auipc	a0,0x5
ffffffffc0201048:	84450513          	addi	a0,a0,-1980 # ffffffffc0205888 <commands+0x750>
ffffffffc020104c:	bf2ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201050:	00005697          	auipc	a3,0x5
ffffffffc0201054:	99868693          	addi	a3,a3,-1640 # ffffffffc02059e8 <commands+0x8b0>
ffffffffc0201058:	00005617          	auipc	a2,0x5
ffffffffc020105c:	81860613          	addi	a2,a2,-2024 # ffffffffc0205870 <commands+0x738>
ffffffffc0201060:	0d600593          	li	a1,214
ffffffffc0201064:	00005517          	auipc	a0,0x5
ffffffffc0201068:	82450513          	addi	a0,a0,-2012 # ffffffffc0205888 <commands+0x750>
ffffffffc020106c:	bd2ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201070:	00005697          	auipc	a3,0x5
ffffffffc0201074:	89068693          	addi	a3,a3,-1904 # ffffffffc0205900 <commands+0x7c8>
ffffffffc0201078:	00004617          	auipc	a2,0x4
ffffffffc020107c:	7f860613          	addi	a2,a2,2040 # ffffffffc0205870 <commands+0x738>
ffffffffc0201080:	0d400593          	li	a1,212
ffffffffc0201084:	00005517          	auipc	a0,0x5
ffffffffc0201088:	80450513          	addi	a0,a0,-2044 # ffffffffc0205888 <commands+0x750>
ffffffffc020108c:	bb2ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201090:	00005697          	auipc	a3,0x5
ffffffffc0201094:	85068693          	addi	a3,a3,-1968 # ffffffffc02058e0 <commands+0x7a8>
ffffffffc0201098:	00004617          	auipc	a2,0x4
ffffffffc020109c:	7d860613          	addi	a2,a2,2008 # ffffffffc0205870 <commands+0x738>
ffffffffc02010a0:	0d300593          	li	a1,211
ffffffffc02010a4:	00004517          	auipc	a0,0x4
ffffffffc02010a8:	7e450513          	addi	a0,a0,2020 # ffffffffc0205888 <commands+0x750>
ffffffffc02010ac:	b92ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02010b0:	00005697          	auipc	a3,0x5
ffffffffc02010b4:	85068693          	addi	a3,a3,-1968 # ffffffffc0205900 <commands+0x7c8>
ffffffffc02010b8:	00004617          	auipc	a2,0x4
ffffffffc02010bc:	7b860613          	addi	a2,a2,1976 # ffffffffc0205870 <commands+0x738>
ffffffffc02010c0:	0bb00593          	li	a1,187
ffffffffc02010c4:	00004517          	auipc	a0,0x4
ffffffffc02010c8:	7c450513          	addi	a0,a0,1988 # ffffffffc0205888 <commands+0x750>
ffffffffc02010cc:	b72ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02010d0:	00005697          	auipc	a3,0x5
ffffffffc02010d4:	ad868693          	addi	a3,a3,-1320 # ffffffffc0205ba8 <commands+0xa70>
ffffffffc02010d8:	00004617          	auipc	a2,0x4
ffffffffc02010dc:	79860613          	addi	a2,a2,1944 # ffffffffc0205870 <commands+0x738>
ffffffffc02010e0:	12500593          	li	a1,293
ffffffffc02010e4:	00004517          	auipc	a0,0x4
ffffffffc02010e8:	7a450513          	addi	a0,a0,1956 # ffffffffc0205888 <commands+0x750>
ffffffffc02010ec:	b52ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02010f0:	00005697          	auipc	a3,0x5
ffffffffc02010f4:	95868693          	addi	a3,a3,-1704 # ffffffffc0205a48 <commands+0x910>
ffffffffc02010f8:	00004617          	auipc	a2,0x4
ffffffffc02010fc:	77860613          	addi	a2,a2,1912 # ffffffffc0205870 <commands+0x738>
ffffffffc0201100:	11a00593          	li	a1,282
ffffffffc0201104:	00004517          	auipc	a0,0x4
ffffffffc0201108:	78450513          	addi	a0,a0,1924 # ffffffffc0205888 <commands+0x750>
ffffffffc020110c:	b32ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201110:	00005697          	auipc	a3,0x5
ffffffffc0201114:	8d868693          	addi	a3,a3,-1832 # ffffffffc02059e8 <commands+0x8b0>
ffffffffc0201118:	00004617          	auipc	a2,0x4
ffffffffc020111c:	75860613          	addi	a2,a2,1880 # ffffffffc0205870 <commands+0x738>
ffffffffc0201120:	11800593          	li	a1,280
ffffffffc0201124:	00004517          	auipc	a0,0x4
ffffffffc0201128:	76450513          	addi	a0,a0,1892 # ffffffffc0205888 <commands+0x750>
ffffffffc020112c:	b12ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201130:	00005697          	auipc	a3,0x5
ffffffffc0201134:	87868693          	addi	a3,a3,-1928 # ffffffffc02059a8 <commands+0x870>
ffffffffc0201138:	00004617          	auipc	a2,0x4
ffffffffc020113c:	73860613          	addi	a2,a2,1848 # ffffffffc0205870 <commands+0x738>
ffffffffc0201140:	0c100593          	li	a1,193
ffffffffc0201144:	00004517          	auipc	a0,0x4
ffffffffc0201148:	74450513          	addi	a0,a0,1860 # ffffffffc0205888 <commands+0x750>
ffffffffc020114c:	af2ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201150:	00005697          	auipc	a3,0x5
ffffffffc0201154:	a1868693          	addi	a3,a3,-1512 # ffffffffc0205b68 <commands+0xa30>
ffffffffc0201158:	00004617          	auipc	a2,0x4
ffffffffc020115c:	71860613          	addi	a2,a2,1816 # ffffffffc0205870 <commands+0x738>
ffffffffc0201160:	11200593          	li	a1,274
ffffffffc0201164:	00004517          	auipc	a0,0x4
ffffffffc0201168:	72450513          	addi	a0,a0,1828 # ffffffffc0205888 <commands+0x750>
ffffffffc020116c:	ad2ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201170:	00005697          	auipc	a3,0x5
ffffffffc0201174:	9d868693          	addi	a3,a3,-1576 # ffffffffc0205b48 <commands+0xa10>
ffffffffc0201178:	00004617          	auipc	a2,0x4
ffffffffc020117c:	6f860613          	addi	a2,a2,1784 # ffffffffc0205870 <commands+0x738>
ffffffffc0201180:	11000593          	li	a1,272
ffffffffc0201184:	00004517          	auipc	a0,0x4
ffffffffc0201188:	70450513          	addi	a0,a0,1796 # ffffffffc0205888 <commands+0x750>
ffffffffc020118c:	ab2ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201190:	00005697          	auipc	a3,0x5
ffffffffc0201194:	99068693          	addi	a3,a3,-1648 # ffffffffc0205b20 <commands+0x9e8>
ffffffffc0201198:	00004617          	auipc	a2,0x4
ffffffffc020119c:	6d860613          	addi	a2,a2,1752 # ffffffffc0205870 <commands+0x738>
ffffffffc02011a0:	10e00593          	li	a1,270
ffffffffc02011a4:	00004517          	auipc	a0,0x4
ffffffffc02011a8:	6e450513          	addi	a0,a0,1764 # ffffffffc0205888 <commands+0x750>
ffffffffc02011ac:	a92ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02011b0:	00005697          	auipc	a3,0x5
ffffffffc02011b4:	94868693          	addi	a3,a3,-1720 # ffffffffc0205af8 <commands+0x9c0>
ffffffffc02011b8:	00004617          	auipc	a2,0x4
ffffffffc02011bc:	6b860613          	addi	a2,a2,1720 # ffffffffc0205870 <commands+0x738>
ffffffffc02011c0:	10d00593          	li	a1,269
ffffffffc02011c4:	00004517          	auipc	a0,0x4
ffffffffc02011c8:	6c450513          	addi	a0,a0,1732 # ffffffffc0205888 <commands+0x750>
ffffffffc02011cc:	a72ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02011d0:	00005697          	auipc	a3,0x5
ffffffffc02011d4:	91868693          	addi	a3,a3,-1768 # ffffffffc0205ae8 <commands+0x9b0>
ffffffffc02011d8:	00004617          	auipc	a2,0x4
ffffffffc02011dc:	69860613          	addi	a2,a2,1688 # ffffffffc0205870 <commands+0x738>
ffffffffc02011e0:	10800593          	li	a1,264
ffffffffc02011e4:	00004517          	auipc	a0,0x4
ffffffffc02011e8:	6a450513          	addi	a0,a0,1700 # ffffffffc0205888 <commands+0x750>
ffffffffc02011ec:	a52ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02011f0:	00004697          	auipc	a3,0x4
ffffffffc02011f4:	7f868693          	addi	a3,a3,2040 # ffffffffc02059e8 <commands+0x8b0>
ffffffffc02011f8:	00004617          	auipc	a2,0x4
ffffffffc02011fc:	67860613          	addi	a2,a2,1656 # ffffffffc0205870 <commands+0x738>
ffffffffc0201200:	10700593          	li	a1,263
ffffffffc0201204:	00004517          	auipc	a0,0x4
ffffffffc0201208:	68450513          	addi	a0,a0,1668 # ffffffffc0205888 <commands+0x750>
ffffffffc020120c:	a32ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201210:	00005697          	auipc	a3,0x5
ffffffffc0201214:	8b868693          	addi	a3,a3,-1864 # ffffffffc0205ac8 <commands+0x990>
ffffffffc0201218:	00004617          	auipc	a2,0x4
ffffffffc020121c:	65860613          	addi	a2,a2,1624 # ffffffffc0205870 <commands+0x738>
ffffffffc0201220:	10600593          	li	a1,262
ffffffffc0201224:	00004517          	auipc	a0,0x4
ffffffffc0201228:	66450513          	addi	a0,a0,1636 # ffffffffc0205888 <commands+0x750>
ffffffffc020122c:	a12ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201230:	00005697          	auipc	a3,0x5
ffffffffc0201234:	86868693          	addi	a3,a3,-1944 # ffffffffc0205a98 <commands+0x960>
ffffffffc0201238:	00004617          	auipc	a2,0x4
ffffffffc020123c:	63860613          	addi	a2,a2,1592 # ffffffffc0205870 <commands+0x738>
ffffffffc0201240:	10500593          	li	a1,261
ffffffffc0201244:	00004517          	auipc	a0,0x4
ffffffffc0201248:	64450513          	addi	a0,a0,1604 # ffffffffc0205888 <commands+0x750>
ffffffffc020124c:	9f2ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201250:	00005697          	auipc	a3,0x5
ffffffffc0201254:	83068693          	addi	a3,a3,-2000 # ffffffffc0205a80 <commands+0x948>
ffffffffc0201258:	00004617          	auipc	a2,0x4
ffffffffc020125c:	61860613          	addi	a2,a2,1560 # ffffffffc0205870 <commands+0x738>
ffffffffc0201260:	10400593          	li	a1,260
ffffffffc0201264:	00004517          	auipc	a0,0x4
ffffffffc0201268:	62450513          	addi	a0,a0,1572 # ffffffffc0205888 <commands+0x750>
ffffffffc020126c:	9d2ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201270:	00004697          	auipc	a3,0x4
ffffffffc0201274:	77868693          	addi	a3,a3,1912 # ffffffffc02059e8 <commands+0x8b0>
ffffffffc0201278:	00004617          	auipc	a2,0x4
ffffffffc020127c:	5f860613          	addi	a2,a2,1528 # ffffffffc0205870 <commands+0x738>
ffffffffc0201280:	0fe00593          	li	a1,254
ffffffffc0201284:	00004517          	auipc	a0,0x4
ffffffffc0201288:	60450513          	addi	a0,a0,1540 # ffffffffc0205888 <commands+0x750>
ffffffffc020128c:	9b2ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201290:	00004697          	auipc	a3,0x4
ffffffffc0201294:	7d868693          	addi	a3,a3,2008 # ffffffffc0205a68 <commands+0x930>
ffffffffc0201298:	00004617          	auipc	a2,0x4
ffffffffc020129c:	5d860613          	addi	a2,a2,1496 # ffffffffc0205870 <commands+0x738>
ffffffffc02012a0:	0f900593          	li	a1,249
ffffffffc02012a4:	00004517          	auipc	a0,0x4
ffffffffc02012a8:	5e450513          	addi	a0,a0,1508 # ffffffffc0205888 <commands+0x750>
ffffffffc02012ac:	992ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02012b0:	00005697          	auipc	a3,0x5
ffffffffc02012b4:	8d868693          	addi	a3,a3,-1832 # ffffffffc0205b88 <commands+0xa50>
ffffffffc02012b8:	00004617          	auipc	a2,0x4
ffffffffc02012bc:	5b860613          	addi	a2,a2,1464 # ffffffffc0205870 <commands+0x738>
ffffffffc02012c0:	11700593          	li	a1,279
ffffffffc02012c4:	00004517          	auipc	a0,0x4
ffffffffc02012c8:	5c450513          	addi	a0,a0,1476 # ffffffffc0205888 <commands+0x750>
ffffffffc02012cc:	972ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02012d0:	00005697          	auipc	a3,0x5
ffffffffc02012d4:	8e868693          	addi	a3,a3,-1816 # ffffffffc0205bb8 <commands+0xa80>
ffffffffc02012d8:	00004617          	auipc	a2,0x4
ffffffffc02012dc:	59860613          	addi	a2,a2,1432 # ffffffffc0205870 <commands+0x738>
ffffffffc02012e0:	12600593          	li	a1,294
ffffffffc02012e4:	00004517          	auipc	a0,0x4
ffffffffc02012e8:	5a450513          	addi	a0,a0,1444 # ffffffffc0205888 <commands+0x750>
ffffffffc02012ec:	952ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02012f0:	00004697          	auipc	a3,0x4
ffffffffc02012f4:	5b068693          	addi	a3,a3,1456 # ffffffffc02058a0 <commands+0x768>
ffffffffc02012f8:	00004617          	auipc	a2,0x4
ffffffffc02012fc:	57860613          	addi	a2,a2,1400 # ffffffffc0205870 <commands+0x738>
ffffffffc0201300:	0f300593          	li	a1,243
ffffffffc0201304:	00004517          	auipc	a0,0x4
ffffffffc0201308:	58450513          	addi	a0,a0,1412 # ffffffffc0205888 <commands+0x750>
ffffffffc020130c:	932ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201310:	00004697          	auipc	a3,0x4
ffffffffc0201314:	5d068693          	addi	a3,a3,1488 # ffffffffc02058e0 <commands+0x7a8>
ffffffffc0201318:	00004617          	auipc	a2,0x4
ffffffffc020131c:	55860613          	addi	a2,a2,1368 # ffffffffc0205870 <commands+0x738>
ffffffffc0201320:	0ba00593          	li	a1,186
ffffffffc0201324:	00004517          	auipc	a0,0x4
ffffffffc0201328:	56450513          	addi	a0,a0,1380 # ffffffffc0205888 <commands+0x750>
ffffffffc020132c:	912ff0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0201330 <default_free_pages>:
ffffffffc0201330:	1141                	addi	sp,sp,-16
ffffffffc0201332:	e406                	sd	ra,8(sp)
ffffffffc0201334:	14058463          	beqz	a1,ffffffffc020147c <default_free_pages+0x14c>
ffffffffc0201338:	00659713          	slli	a4,a1,0x6
ffffffffc020133c:	00e506b3          	add	a3,a0,a4
ffffffffc0201340:	87aa                	mv	a5,a0
ffffffffc0201342:	c30d                	beqz	a4,ffffffffc0201364 <default_free_pages+0x34>
ffffffffc0201344:	6798                	ld	a4,8(a5)
ffffffffc0201346:	8b05                	andi	a4,a4,1
ffffffffc0201348:	10071a63          	bnez	a4,ffffffffc020145c <default_free_pages+0x12c>
ffffffffc020134c:	6798                	ld	a4,8(a5)
ffffffffc020134e:	8b09                	andi	a4,a4,2
ffffffffc0201350:	10071663          	bnez	a4,ffffffffc020145c <default_free_pages+0x12c>
ffffffffc0201354:	0007b423          	sd	zero,8(a5)
ffffffffc0201358:	0007a023          	sw	zero,0(a5)
ffffffffc020135c:	04078793          	addi	a5,a5,64
ffffffffc0201360:	fed792e3          	bne	a5,a3,ffffffffc0201344 <default_free_pages+0x14>
ffffffffc0201364:	2581                	sext.w	a1,a1
ffffffffc0201366:	c90c                	sw	a1,16(a0)
ffffffffc0201368:	00850893          	addi	a7,a0,8
ffffffffc020136c:	4789                	li	a5,2
ffffffffc020136e:	40f8b02f          	amoor.d	zero,a5,(a7)
ffffffffc0201372:	00010697          	auipc	a3,0x10
ffffffffc0201376:	0ee68693          	addi	a3,a3,238 # ffffffffc0211460 <free_area>
ffffffffc020137a:	4a98                	lw	a4,16(a3)
ffffffffc020137c:	669c                	ld	a5,8(a3)
ffffffffc020137e:	9f2d                	addw	a4,a4,a1
ffffffffc0201380:	ca98                	sw	a4,16(a3)
ffffffffc0201382:	0ad78163          	beq	a5,a3,ffffffffc0201424 <default_free_pages+0xf4>
ffffffffc0201386:	fe878713          	addi	a4,a5,-24
ffffffffc020138a:	4581                	li	a1,0
ffffffffc020138c:	01850613          	addi	a2,a0,24
ffffffffc0201390:	00e56a63          	bltu	a0,a4,ffffffffc02013a4 <default_free_pages+0x74>
ffffffffc0201394:	6798                	ld	a4,8(a5)
ffffffffc0201396:	04d70c63          	beq	a4,a3,ffffffffc02013ee <default_free_pages+0xbe>
ffffffffc020139a:	87ba                	mv	a5,a4
ffffffffc020139c:	fe878713          	addi	a4,a5,-24
ffffffffc02013a0:	fee57ae3          	bgeu	a0,a4,ffffffffc0201394 <default_free_pages+0x64>
ffffffffc02013a4:	c199                	beqz	a1,ffffffffc02013aa <default_free_pages+0x7a>
ffffffffc02013a6:	0106b023          	sd	a6,0(a3)
ffffffffc02013aa:	6398                	ld	a4,0(a5)
ffffffffc02013ac:	e390                	sd	a2,0(a5)
ffffffffc02013ae:	e710                	sd	a2,8(a4)
ffffffffc02013b0:	f11c                	sd	a5,32(a0)
ffffffffc02013b2:	ed18                	sd	a4,24(a0)
ffffffffc02013b4:	00d70d63          	beq	a4,a3,ffffffffc02013ce <default_free_pages+0x9e>
ffffffffc02013b8:	ff872583          	lw	a1,-8(a4)
ffffffffc02013bc:	fe870613          	addi	a2,a4,-24
ffffffffc02013c0:	02059813          	slli	a6,a1,0x20
ffffffffc02013c4:	01a85793          	srli	a5,a6,0x1a
ffffffffc02013c8:	97b2                	add	a5,a5,a2
ffffffffc02013ca:	02f50c63          	beq	a0,a5,ffffffffc0201402 <default_free_pages+0xd2>
ffffffffc02013ce:	711c                	ld	a5,32(a0)
ffffffffc02013d0:	00d78c63          	beq	a5,a3,ffffffffc02013e8 <default_free_pages+0xb8>
ffffffffc02013d4:	4910                	lw	a2,16(a0)
ffffffffc02013d6:	fe878693          	addi	a3,a5,-24
ffffffffc02013da:	02061593          	slli	a1,a2,0x20
ffffffffc02013de:	01a5d713          	srli	a4,a1,0x1a
ffffffffc02013e2:	972a                	add	a4,a4,a0
ffffffffc02013e4:	04e68c63          	beq	a3,a4,ffffffffc020143c <default_free_pages+0x10c>
ffffffffc02013e8:	60a2                	ld	ra,8(sp)
ffffffffc02013ea:	0141                	addi	sp,sp,16
ffffffffc02013ec:	8082                	ret
ffffffffc02013ee:	e790                	sd	a2,8(a5)
ffffffffc02013f0:	f114                	sd	a3,32(a0)
ffffffffc02013f2:	6798                	ld	a4,8(a5)
ffffffffc02013f4:	ed1c                	sd	a5,24(a0)
ffffffffc02013f6:	8832                	mv	a6,a2
ffffffffc02013f8:	02d70f63          	beq	a4,a3,ffffffffc0201436 <default_free_pages+0x106>
ffffffffc02013fc:	4585                	li	a1,1
ffffffffc02013fe:	87ba                	mv	a5,a4
ffffffffc0201400:	bf71                	j	ffffffffc020139c <default_free_pages+0x6c>
ffffffffc0201402:	491c                	lw	a5,16(a0)
ffffffffc0201404:	9fad                	addw	a5,a5,a1
ffffffffc0201406:	fef72c23          	sw	a5,-8(a4)
ffffffffc020140a:	57f5                	li	a5,-3
ffffffffc020140c:	60f8b02f          	amoand.d	zero,a5,(a7)
ffffffffc0201410:	01853803          	ld	a6,24(a0)
ffffffffc0201414:	710c                	ld	a1,32(a0)
ffffffffc0201416:	8532                	mv	a0,a2
ffffffffc0201418:	00b83423          	sd	a1,8(a6)
ffffffffc020141c:	671c                	ld	a5,8(a4)
ffffffffc020141e:	0105b023          	sd	a6,0(a1)
ffffffffc0201422:	b77d                	j	ffffffffc02013d0 <default_free_pages+0xa0>
ffffffffc0201424:	60a2                	ld	ra,8(sp)
ffffffffc0201426:	01850713          	addi	a4,a0,24
ffffffffc020142a:	e398                	sd	a4,0(a5)
ffffffffc020142c:	e798                	sd	a4,8(a5)
ffffffffc020142e:	f11c                	sd	a5,32(a0)
ffffffffc0201430:	ed1c                	sd	a5,24(a0)
ffffffffc0201432:	0141                	addi	sp,sp,16
ffffffffc0201434:	8082                	ret
ffffffffc0201436:	e290                	sd	a2,0(a3)
ffffffffc0201438:	873e                	mv	a4,a5
ffffffffc020143a:	bfad                	j	ffffffffc02013b4 <default_free_pages+0x84>
ffffffffc020143c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201440:	ff078693          	addi	a3,a5,-16
ffffffffc0201444:	9f31                	addw	a4,a4,a2
ffffffffc0201446:	c918                	sw	a4,16(a0)
ffffffffc0201448:	5775                	li	a4,-3
ffffffffc020144a:	60e6b02f          	amoand.d	zero,a4,(a3)
ffffffffc020144e:	6398                	ld	a4,0(a5)
ffffffffc0201450:	679c                	ld	a5,8(a5)
ffffffffc0201452:	60a2                	ld	ra,8(sp)
ffffffffc0201454:	e71c                	sd	a5,8(a4)
ffffffffc0201456:	e398                	sd	a4,0(a5)
ffffffffc0201458:	0141                	addi	sp,sp,16
ffffffffc020145a:	8082                	ret
ffffffffc020145c:	00004697          	auipc	a3,0x4
ffffffffc0201460:	77468693          	addi	a3,a3,1908 # ffffffffc0205bd0 <commands+0xa98>
ffffffffc0201464:	00004617          	auipc	a2,0x4
ffffffffc0201468:	40c60613          	addi	a2,a2,1036 # ffffffffc0205870 <commands+0x738>
ffffffffc020146c:	08300593          	li	a1,131
ffffffffc0201470:	00004517          	auipc	a0,0x4
ffffffffc0201474:	41850513          	addi	a0,a0,1048 # ffffffffc0205888 <commands+0x750>
ffffffffc0201478:	fc7fe0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020147c:	00004697          	auipc	a3,0x4
ffffffffc0201480:	74c68693          	addi	a3,a3,1868 # ffffffffc0205bc8 <commands+0xa90>
ffffffffc0201484:	00004617          	auipc	a2,0x4
ffffffffc0201488:	3ec60613          	addi	a2,a2,1004 # ffffffffc0205870 <commands+0x738>
ffffffffc020148c:	08000593          	li	a1,128
ffffffffc0201490:	00004517          	auipc	a0,0x4
ffffffffc0201494:	3f850513          	addi	a0,a0,1016 # ffffffffc0205888 <commands+0x750>
ffffffffc0201498:	fa7fe0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc020149c <default_alloc_pages>:
ffffffffc020149c:	c949                	beqz	a0,ffffffffc020152e <default_alloc_pages+0x92>
ffffffffc020149e:	00010617          	auipc	a2,0x10
ffffffffc02014a2:	fc260613          	addi	a2,a2,-62 # ffffffffc0211460 <free_area>
ffffffffc02014a6:	4a0c                	lw	a1,16(a2)
ffffffffc02014a8:	872a                	mv	a4,a0
ffffffffc02014aa:	02059793          	slli	a5,a1,0x20
ffffffffc02014ae:	9381                	srli	a5,a5,0x20
ffffffffc02014b0:	00a7eb63          	bltu	a5,a0,ffffffffc02014c6 <default_alloc_pages+0x2a>
ffffffffc02014b4:	87b2                	mv	a5,a2
ffffffffc02014b6:	a029                	j	ffffffffc02014c0 <default_alloc_pages+0x24>
ffffffffc02014b8:	ff87e683          	lwu	a3,-8(a5)
ffffffffc02014bc:	00e6f763          	bgeu	a3,a4,ffffffffc02014ca <default_alloc_pages+0x2e>
ffffffffc02014c0:	679c                	ld	a5,8(a5)
ffffffffc02014c2:	fec79be3          	bne	a5,a2,ffffffffc02014b8 <default_alloc_pages+0x1c>
ffffffffc02014c6:	4501                	li	a0,0
ffffffffc02014c8:	8082                	ret
ffffffffc02014ca:	0087b883          	ld	a7,8(a5)
ffffffffc02014ce:	ff87a803          	lw	a6,-8(a5)
ffffffffc02014d2:	6394                	ld	a3,0(a5)
ffffffffc02014d4:	fe878513          	addi	a0,a5,-24
ffffffffc02014d8:	02081313          	slli	t1,a6,0x20
ffffffffc02014dc:	0116b423          	sd	a7,8(a3)
ffffffffc02014e0:	00d8b023          	sd	a3,0(a7)
ffffffffc02014e4:	02035313          	srli	t1,t1,0x20
ffffffffc02014e8:	0007089b          	sext.w	a7,a4
ffffffffc02014ec:	02677963          	bgeu	a4,t1,ffffffffc020151e <default_alloc_pages+0x82>
ffffffffc02014f0:	071a                	slli	a4,a4,0x6
ffffffffc02014f2:	972a                	add	a4,a4,a0
ffffffffc02014f4:	4118083b          	subw	a6,a6,a7
ffffffffc02014f8:	01072823          	sw	a6,16(a4)
ffffffffc02014fc:	4589                	li	a1,2
ffffffffc02014fe:	00870813          	addi	a6,a4,8
ffffffffc0201502:	40b8302f          	amoor.d	zero,a1,(a6)
ffffffffc0201506:	0086b803          	ld	a6,8(a3)
ffffffffc020150a:	01870313          	addi	t1,a4,24
ffffffffc020150e:	4a0c                	lw	a1,16(a2)
ffffffffc0201510:	00683023          	sd	t1,0(a6)
ffffffffc0201514:	0066b423          	sd	t1,8(a3)
ffffffffc0201518:	03073023          	sd	a6,32(a4)
ffffffffc020151c:	ef14                	sd	a3,24(a4)
ffffffffc020151e:	411585bb          	subw	a1,a1,a7
ffffffffc0201522:	ca0c                	sw	a1,16(a2)
ffffffffc0201524:	5775                	li	a4,-3
ffffffffc0201526:	17c1                	addi	a5,a5,-16
ffffffffc0201528:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc020152c:	8082                	ret
ffffffffc020152e:	1141                	addi	sp,sp,-16
ffffffffc0201530:	00004697          	auipc	a3,0x4
ffffffffc0201534:	69868693          	addi	a3,a3,1688 # ffffffffc0205bc8 <commands+0xa90>
ffffffffc0201538:	00004617          	auipc	a2,0x4
ffffffffc020153c:	33860613          	addi	a2,a2,824 # ffffffffc0205870 <commands+0x738>
ffffffffc0201540:	06200593          	li	a1,98
ffffffffc0201544:	00004517          	auipc	a0,0x4
ffffffffc0201548:	34450513          	addi	a0,a0,836 # ffffffffc0205888 <commands+0x750>
ffffffffc020154c:	e406                	sd	ra,8(sp)
ffffffffc020154e:	ef1fe0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0201552 <default_init_memmap>:
ffffffffc0201552:	1141                	addi	sp,sp,-16
ffffffffc0201554:	e406                	sd	ra,8(sp)
ffffffffc0201556:	c5f1                	beqz	a1,ffffffffc0201622 <default_init_memmap+0xd0>
ffffffffc0201558:	00659713          	slli	a4,a1,0x6
ffffffffc020155c:	00e506b3          	add	a3,a0,a4
ffffffffc0201560:	87aa                	mv	a5,a0
ffffffffc0201562:	cf11                	beqz	a4,ffffffffc020157e <default_init_memmap+0x2c>
ffffffffc0201564:	6798                	ld	a4,8(a5)
ffffffffc0201566:	8b05                	andi	a4,a4,1
ffffffffc0201568:	cf49                	beqz	a4,ffffffffc0201602 <default_init_memmap+0xb0>
ffffffffc020156a:	0007a823          	sw	zero,16(a5)
ffffffffc020156e:	0007b423          	sd	zero,8(a5)
ffffffffc0201572:	0007a023          	sw	zero,0(a5)
ffffffffc0201576:	04078793          	addi	a5,a5,64
ffffffffc020157a:	fed795e3          	bne	a5,a3,ffffffffc0201564 <default_init_memmap+0x12>
ffffffffc020157e:	2581                	sext.w	a1,a1
ffffffffc0201580:	c90c                	sw	a1,16(a0)
ffffffffc0201582:	4789                	li	a5,2
ffffffffc0201584:	00850713          	addi	a4,a0,8
ffffffffc0201588:	40f7302f          	amoor.d	zero,a5,(a4)
ffffffffc020158c:	00010697          	auipc	a3,0x10
ffffffffc0201590:	ed468693          	addi	a3,a3,-300 # ffffffffc0211460 <free_area>
ffffffffc0201594:	4a98                	lw	a4,16(a3)
ffffffffc0201596:	669c                	ld	a5,8(a3)
ffffffffc0201598:	9f2d                	addw	a4,a4,a1
ffffffffc020159a:	ca98                	sw	a4,16(a3)
ffffffffc020159c:	04d78663          	beq	a5,a3,ffffffffc02015e8 <default_init_memmap+0x96>
ffffffffc02015a0:	fe878713          	addi	a4,a5,-24
ffffffffc02015a4:	4581                	li	a1,0
ffffffffc02015a6:	01850613          	addi	a2,a0,24
ffffffffc02015aa:	00e56a63          	bltu	a0,a4,ffffffffc02015be <default_init_memmap+0x6c>
ffffffffc02015ae:	6798                	ld	a4,8(a5)
ffffffffc02015b0:	02d70263          	beq	a4,a3,ffffffffc02015d4 <default_init_memmap+0x82>
ffffffffc02015b4:	87ba                	mv	a5,a4
ffffffffc02015b6:	fe878713          	addi	a4,a5,-24
ffffffffc02015ba:	fee57ae3          	bgeu	a0,a4,ffffffffc02015ae <default_init_memmap+0x5c>
ffffffffc02015be:	c199                	beqz	a1,ffffffffc02015c4 <default_init_memmap+0x72>
ffffffffc02015c0:	0106b023          	sd	a6,0(a3)
ffffffffc02015c4:	6398                	ld	a4,0(a5)
ffffffffc02015c6:	60a2                	ld	ra,8(sp)
ffffffffc02015c8:	e390                	sd	a2,0(a5)
ffffffffc02015ca:	e710                	sd	a2,8(a4)
ffffffffc02015cc:	f11c                	sd	a5,32(a0)
ffffffffc02015ce:	ed18                	sd	a4,24(a0)
ffffffffc02015d0:	0141                	addi	sp,sp,16
ffffffffc02015d2:	8082                	ret
ffffffffc02015d4:	e790                	sd	a2,8(a5)
ffffffffc02015d6:	f114                	sd	a3,32(a0)
ffffffffc02015d8:	6798                	ld	a4,8(a5)
ffffffffc02015da:	ed1c                	sd	a5,24(a0)
ffffffffc02015dc:	8832                	mv	a6,a2
ffffffffc02015de:	00d70e63          	beq	a4,a3,ffffffffc02015fa <default_init_memmap+0xa8>
ffffffffc02015e2:	4585                	li	a1,1
ffffffffc02015e4:	87ba                	mv	a5,a4
ffffffffc02015e6:	bfc1                	j	ffffffffc02015b6 <default_init_memmap+0x64>
ffffffffc02015e8:	60a2                	ld	ra,8(sp)
ffffffffc02015ea:	01850713          	addi	a4,a0,24
ffffffffc02015ee:	e398                	sd	a4,0(a5)
ffffffffc02015f0:	e798                	sd	a4,8(a5)
ffffffffc02015f2:	f11c                	sd	a5,32(a0)
ffffffffc02015f4:	ed1c                	sd	a5,24(a0)
ffffffffc02015f6:	0141                	addi	sp,sp,16
ffffffffc02015f8:	8082                	ret
ffffffffc02015fa:	60a2                	ld	ra,8(sp)
ffffffffc02015fc:	e290                	sd	a2,0(a3)
ffffffffc02015fe:	0141                	addi	sp,sp,16
ffffffffc0201600:	8082                	ret
ffffffffc0201602:	00004697          	auipc	a3,0x4
ffffffffc0201606:	5f668693          	addi	a3,a3,1526 # ffffffffc0205bf8 <commands+0xac0>
ffffffffc020160a:	00004617          	auipc	a2,0x4
ffffffffc020160e:	26660613          	addi	a2,a2,614 # ffffffffc0205870 <commands+0x738>
ffffffffc0201612:	04900593          	li	a1,73
ffffffffc0201616:	00004517          	auipc	a0,0x4
ffffffffc020161a:	27250513          	addi	a0,a0,626 # ffffffffc0205888 <commands+0x750>
ffffffffc020161e:	e21fe0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201622:	00004697          	auipc	a3,0x4
ffffffffc0201626:	5a668693          	addi	a3,a3,1446 # ffffffffc0205bc8 <commands+0xa90>
ffffffffc020162a:	00004617          	auipc	a2,0x4
ffffffffc020162e:	24660613          	addi	a2,a2,582 # ffffffffc0205870 <commands+0x738>
ffffffffc0201632:	04600593          	li	a1,70
ffffffffc0201636:	00004517          	auipc	a0,0x4
ffffffffc020163a:	25250513          	addi	a0,a0,594 # ffffffffc0205888 <commands+0x750>
ffffffffc020163e:	e01fe0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0201642 <slob_free>:
ffffffffc0201642:	c955                	beqz	a0,ffffffffc02016f6 <slob_free+0xb4>
ffffffffc0201644:	1141                	addi	sp,sp,-16
ffffffffc0201646:	e022                	sd	s0,0(sp)
ffffffffc0201648:	e406                	sd	ra,8(sp)
ffffffffc020164a:	842a                	mv	s0,a0
ffffffffc020164c:	e9c9                	bnez	a1,ffffffffc02016de <slob_free+0x9c>
ffffffffc020164e:	100027f3          	csrr	a5,sstatus
ffffffffc0201652:	8b89                	andi	a5,a5,2
ffffffffc0201654:	4501                	li	a0,0
ffffffffc0201656:	efc1                	bnez	a5,ffffffffc02016ee <slob_free+0xac>
ffffffffc0201658:	00009617          	auipc	a2,0x9
ffffffffc020165c:	9f860613          	addi	a2,a2,-1544 # ffffffffc020a050 <slobfree>
ffffffffc0201660:	621c                	ld	a5,0(a2)
ffffffffc0201662:	873e                	mv	a4,a5
ffffffffc0201664:	679c                	ld	a5,8(a5)
ffffffffc0201666:	02877a63          	bgeu	a4,s0,ffffffffc020169a <slob_free+0x58>
ffffffffc020166a:	00f46463          	bltu	s0,a5,ffffffffc0201672 <slob_free+0x30>
ffffffffc020166e:	fef76ae3          	bltu	a4,a5,ffffffffc0201662 <slob_free+0x20>
ffffffffc0201672:	400c                	lw	a1,0(s0)
ffffffffc0201674:	00459693          	slli	a3,a1,0x4
ffffffffc0201678:	96a2                	add	a3,a3,s0
ffffffffc020167a:	02d78a63          	beq	a5,a3,ffffffffc02016ae <slob_free+0x6c>
ffffffffc020167e:	430c                	lw	a1,0(a4)
ffffffffc0201680:	e41c                	sd	a5,8(s0)
ffffffffc0201682:	00459693          	slli	a3,a1,0x4
ffffffffc0201686:	96ba                	add	a3,a3,a4
ffffffffc0201688:	02d40e63          	beq	s0,a3,ffffffffc02016c4 <slob_free+0x82>
ffffffffc020168c:	e700                	sd	s0,8(a4)
ffffffffc020168e:	e218                	sd	a4,0(a2)
ffffffffc0201690:	e131                	bnez	a0,ffffffffc02016d4 <slob_free+0x92>
ffffffffc0201692:	60a2                	ld	ra,8(sp)
ffffffffc0201694:	6402                	ld	s0,0(sp)
ffffffffc0201696:	0141                	addi	sp,sp,16
ffffffffc0201698:	8082                	ret
ffffffffc020169a:	fcf764e3          	bltu	a4,a5,ffffffffc0201662 <slob_free+0x20>
ffffffffc020169e:	fcf472e3          	bgeu	s0,a5,ffffffffc0201662 <slob_free+0x20>
ffffffffc02016a2:	400c                	lw	a1,0(s0)
ffffffffc02016a4:	00459693          	slli	a3,a1,0x4
ffffffffc02016a8:	96a2                	add	a3,a3,s0
ffffffffc02016aa:	fcd79ae3          	bne	a5,a3,ffffffffc020167e <slob_free+0x3c>
ffffffffc02016ae:	4394                	lw	a3,0(a5)
ffffffffc02016b0:	679c                	ld	a5,8(a5)
ffffffffc02016b2:	9ead                	addw	a3,a3,a1
ffffffffc02016b4:	c014                	sw	a3,0(s0)
ffffffffc02016b6:	430c                	lw	a1,0(a4)
ffffffffc02016b8:	e41c                	sd	a5,8(s0)
ffffffffc02016ba:	00459693          	slli	a3,a1,0x4
ffffffffc02016be:	96ba                	add	a3,a3,a4
ffffffffc02016c0:	fcd416e3          	bne	s0,a3,ffffffffc020168c <slob_free+0x4a>
ffffffffc02016c4:	4014                	lw	a3,0(s0)
ffffffffc02016c6:	843e                	mv	s0,a5
ffffffffc02016c8:	e700                	sd	s0,8(a4)
ffffffffc02016ca:	00b687bb          	addw	a5,a3,a1
ffffffffc02016ce:	c31c                	sw	a5,0(a4)
ffffffffc02016d0:	e218                	sd	a4,0(a2)
ffffffffc02016d2:	d161                	beqz	a0,ffffffffc0201692 <slob_free+0x50>
ffffffffc02016d4:	6402                	ld	s0,0(sp)
ffffffffc02016d6:	60a2                	ld	ra,8(sp)
ffffffffc02016d8:	0141                	addi	sp,sp,16
ffffffffc02016da:	edbfe06f          	j	ffffffffc02005b4 <intr_enable>
ffffffffc02016de:	25bd                	addiw	a1,a1,15
ffffffffc02016e0:	8191                	srli	a1,a1,0x4
ffffffffc02016e2:	c10c                	sw	a1,0(a0)
ffffffffc02016e4:	100027f3          	csrr	a5,sstatus
ffffffffc02016e8:	8b89                	andi	a5,a5,2
ffffffffc02016ea:	4501                	li	a0,0
ffffffffc02016ec:	d7b5                	beqz	a5,ffffffffc0201658 <slob_free+0x16>
ffffffffc02016ee:	ecdfe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc02016f2:	4505                	li	a0,1
ffffffffc02016f4:	b795                	j	ffffffffc0201658 <slob_free+0x16>
ffffffffc02016f6:	8082                	ret

ffffffffc02016f8 <__slob_get_free_pages.constprop.0>:
ffffffffc02016f8:	4785                	li	a5,1
ffffffffc02016fa:	1141                	addi	sp,sp,-16
ffffffffc02016fc:	00a7953b          	sllw	a0,a5,a0
ffffffffc0201700:	e406                	sd	ra,8(sp)
ffffffffc0201702:	33e000ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0201706:	c91d                	beqz	a0,ffffffffc020173c <__slob_get_free_pages.constprop.0+0x44>
ffffffffc0201708:	00014797          	auipc	a5,0x14
ffffffffc020170c:	e807b783          	ld	a5,-384(a5) # ffffffffc0215588 <pages>
ffffffffc0201710:	8d1d                	sub	a0,a0,a5
ffffffffc0201712:	8519                	srai	a0,a0,0x6
ffffffffc0201714:	00006797          	auipc	a5,0x6
ffffffffc0201718:	8e47b783          	ld	a5,-1820(a5) # ffffffffc0206ff8 <nbase>
ffffffffc020171c:	953e                	add	a0,a0,a5
ffffffffc020171e:	00c51793          	slli	a5,a0,0xc
ffffffffc0201722:	83b1                	srli	a5,a5,0xc
ffffffffc0201724:	00014717          	auipc	a4,0x14
ffffffffc0201728:	e5c73703          	ld	a4,-420(a4) # ffffffffc0215580 <npage>
ffffffffc020172c:	0532                	slli	a0,a0,0xc
ffffffffc020172e:	00e7fa63          	bgeu	a5,a4,ffffffffc0201742 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201732:	00014797          	auipc	a5,0x14
ffffffffc0201736:	e467b783          	ld	a5,-442(a5) # ffffffffc0215578 <va_pa_offset>
ffffffffc020173a:	953e                	add	a0,a0,a5
ffffffffc020173c:	60a2                	ld	ra,8(sp)
ffffffffc020173e:	0141                	addi	sp,sp,16
ffffffffc0201740:	8082                	ret
ffffffffc0201742:	86aa                	mv	a3,a0
ffffffffc0201744:	00004617          	auipc	a2,0x4
ffffffffc0201748:	51460613          	addi	a2,a2,1300 # ffffffffc0205c58 <default_pmm_manager+0x38>
ffffffffc020174c:	08b00593          	li	a1,139
ffffffffc0201750:	00004517          	auipc	a0,0x4
ffffffffc0201754:	53050513          	addi	a0,a0,1328 # ffffffffc0205c80 <default_pmm_manager+0x60>
ffffffffc0201758:	ce7fe0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc020175c <slob_alloc.constprop.0>:
ffffffffc020175c:	1101                	addi	sp,sp,-32
ffffffffc020175e:	ec06                	sd	ra,24(sp)
ffffffffc0201760:	e822                	sd	s0,16(sp)
ffffffffc0201762:	e426                	sd	s1,8(sp)
ffffffffc0201764:	e04a                	sd	s2,0(sp)
ffffffffc0201766:	01050713          	addi	a4,a0,16
ffffffffc020176a:	6785                	lui	a5,0x1
ffffffffc020176c:	0cf77363          	bgeu	a4,a5,ffffffffc0201832 <slob_alloc.constprop.0+0xd6>
ffffffffc0201770:	00f50493          	addi	s1,a0,15
ffffffffc0201774:	8091                	srli	s1,s1,0x4
ffffffffc0201776:	2481                	sext.w	s1,s1
ffffffffc0201778:	10002673          	csrr	a2,sstatus
ffffffffc020177c:	8a09                	andi	a2,a2,2
ffffffffc020177e:	e25d                	bnez	a2,ffffffffc0201824 <slob_alloc.constprop.0+0xc8>
ffffffffc0201780:	00009917          	auipc	s2,0x9
ffffffffc0201784:	8d090913          	addi	s2,s2,-1840 # ffffffffc020a050 <slobfree>
ffffffffc0201788:	00093683          	ld	a3,0(s2)
ffffffffc020178c:	669c                	ld	a5,8(a3)
ffffffffc020178e:	4398                	lw	a4,0(a5)
ffffffffc0201790:	08975e63          	bge	a4,s1,ffffffffc020182c <slob_alloc.constprop.0+0xd0>
ffffffffc0201794:	00d78b63          	beq	a5,a3,ffffffffc02017aa <slob_alloc.constprop.0+0x4e>
ffffffffc0201798:	6780                	ld	s0,8(a5)
ffffffffc020179a:	4018                	lw	a4,0(s0)
ffffffffc020179c:	02975a63          	bge	a4,s1,ffffffffc02017d0 <slob_alloc.constprop.0+0x74>
ffffffffc02017a0:	00093683          	ld	a3,0(s2)
ffffffffc02017a4:	87a2                	mv	a5,s0
ffffffffc02017a6:	fed799e3          	bne	a5,a3,ffffffffc0201798 <slob_alloc.constprop.0+0x3c>
ffffffffc02017aa:	ee31                	bnez	a2,ffffffffc0201806 <slob_alloc.constprop.0+0xaa>
ffffffffc02017ac:	4501                	li	a0,0
ffffffffc02017ae:	f4bff0ef          	jal	ra,ffffffffc02016f8 <__slob_get_free_pages.constprop.0>
ffffffffc02017b2:	842a                	mv	s0,a0
ffffffffc02017b4:	cd05                	beqz	a0,ffffffffc02017ec <slob_alloc.constprop.0+0x90>
ffffffffc02017b6:	6585                	lui	a1,0x1
ffffffffc02017b8:	e8bff0ef          	jal	ra,ffffffffc0201642 <slob_free>
ffffffffc02017bc:	10002673          	csrr	a2,sstatus
ffffffffc02017c0:	8a09                	andi	a2,a2,2
ffffffffc02017c2:	ee05                	bnez	a2,ffffffffc02017fa <slob_alloc.constprop.0+0x9e>
ffffffffc02017c4:	00093783          	ld	a5,0(s2)
ffffffffc02017c8:	6780                	ld	s0,8(a5)
ffffffffc02017ca:	4018                	lw	a4,0(s0)
ffffffffc02017cc:	fc974ae3          	blt	a4,s1,ffffffffc02017a0 <slob_alloc.constprop.0+0x44>
ffffffffc02017d0:	04e48763          	beq	s1,a4,ffffffffc020181e <slob_alloc.constprop.0+0xc2>
ffffffffc02017d4:	00449693          	slli	a3,s1,0x4
ffffffffc02017d8:	96a2                	add	a3,a3,s0
ffffffffc02017da:	e794                	sd	a3,8(a5)
ffffffffc02017dc:	640c                	ld	a1,8(s0)
ffffffffc02017de:	9f05                	subw	a4,a4,s1
ffffffffc02017e0:	c298                	sw	a4,0(a3)
ffffffffc02017e2:	e68c                	sd	a1,8(a3)
ffffffffc02017e4:	c004                	sw	s1,0(s0)
ffffffffc02017e6:	00f93023          	sd	a5,0(s2)
ffffffffc02017ea:	e20d                	bnez	a2,ffffffffc020180c <slob_alloc.constprop.0+0xb0>
ffffffffc02017ec:	60e2                	ld	ra,24(sp)
ffffffffc02017ee:	8522                	mv	a0,s0
ffffffffc02017f0:	6442                	ld	s0,16(sp)
ffffffffc02017f2:	64a2                	ld	s1,8(sp)
ffffffffc02017f4:	6902                	ld	s2,0(sp)
ffffffffc02017f6:	6105                	addi	sp,sp,32
ffffffffc02017f8:	8082                	ret
ffffffffc02017fa:	dc1fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc02017fe:	00093783          	ld	a5,0(s2)
ffffffffc0201802:	4605                	li	a2,1
ffffffffc0201804:	b7d1                	j	ffffffffc02017c8 <slob_alloc.constprop.0+0x6c>
ffffffffc0201806:	daffe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc020180a:	b74d                	j	ffffffffc02017ac <slob_alloc.constprop.0+0x50>
ffffffffc020180c:	da9fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0201810:	60e2                	ld	ra,24(sp)
ffffffffc0201812:	8522                	mv	a0,s0
ffffffffc0201814:	6442                	ld	s0,16(sp)
ffffffffc0201816:	64a2                	ld	s1,8(sp)
ffffffffc0201818:	6902                	ld	s2,0(sp)
ffffffffc020181a:	6105                	addi	sp,sp,32
ffffffffc020181c:	8082                	ret
ffffffffc020181e:	6418                	ld	a4,8(s0)
ffffffffc0201820:	e798                	sd	a4,8(a5)
ffffffffc0201822:	b7d1                	j	ffffffffc02017e6 <slob_alloc.constprop.0+0x8a>
ffffffffc0201824:	d97fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0201828:	4605                	li	a2,1
ffffffffc020182a:	bf99                	j	ffffffffc0201780 <slob_alloc.constprop.0+0x24>
ffffffffc020182c:	843e                	mv	s0,a5
ffffffffc020182e:	87b6                	mv	a5,a3
ffffffffc0201830:	b745                	j	ffffffffc02017d0 <slob_alloc.constprop.0+0x74>
ffffffffc0201832:	00004697          	auipc	a3,0x4
ffffffffc0201836:	45e68693          	addi	a3,a3,1118 # ffffffffc0205c90 <default_pmm_manager+0x70>
ffffffffc020183a:	00004617          	auipc	a2,0x4
ffffffffc020183e:	03660613          	addi	a2,a2,54 # ffffffffc0205870 <commands+0x738>
ffffffffc0201842:	06300593          	li	a1,99
ffffffffc0201846:	00004517          	auipc	a0,0x4
ffffffffc020184a:	46a50513          	addi	a0,a0,1130 # ffffffffc0205cb0 <default_pmm_manager+0x90>
ffffffffc020184e:	bf1fe0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0201852 <kmalloc_init>:
ffffffffc0201852:	1141                	addi	sp,sp,-16
ffffffffc0201854:	00004517          	auipc	a0,0x4
ffffffffc0201858:	47450513          	addi	a0,a0,1140 # ffffffffc0205cc8 <default_pmm_manager+0xa8>
ffffffffc020185c:	e406                	sd	ra,8(sp)
ffffffffc020185e:	92dfe0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0201862:	60a2                	ld	ra,8(sp)
ffffffffc0201864:	00004517          	auipc	a0,0x4
ffffffffc0201868:	47c50513          	addi	a0,a0,1148 # ffffffffc0205ce0 <default_pmm_manager+0xc0>
ffffffffc020186c:	0141                	addi	sp,sp,16
ffffffffc020186e:	91dfe06f          	j	ffffffffc020018a <cprintf>

ffffffffc0201872 <kmalloc>:
ffffffffc0201872:	1101                	addi	sp,sp,-32
ffffffffc0201874:	e04a                	sd	s2,0(sp)
ffffffffc0201876:	6905                	lui	s2,0x1
ffffffffc0201878:	e822                	sd	s0,16(sp)
ffffffffc020187a:	ec06                	sd	ra,24(sp)
ffffffffc020187c:	e426                	sd	s1,8(sp)
ffffffffc020187e:	fef90793          	addi	a5,s2,-17 # fef <kern_entry-0xffffffffc01ff011>
ffffffffc0201882:	842a                	mv	s0,a0
ffffffffc0201884:	04a7f763          	bgeu	a5,a0,ffffffffc02018d2 <kmalloc+0x60>
ffffffffc0201888:	4561                	li	a0,24
ffffffffc020188a:	ed3ff0ef          	jal	ra,ffffffffc020175c <slob_alloc.constprop.0>
ffffffffc020188e:	84aa                	mv	s1,a0
ffffffffc0201890:	c539                	beqz	a0,ffffffffc02018de <kmalloc+0x6c>
ffffffffc0201892:	0004079b          	sext.w	a5,s0
ffffffffc0201896:	4501                	li	a0,0
ffffffffc0201898:	00f95763          	bge	s2,a5,ffffffffc02018a6 <kmalloc+0x34>
ffffffffc020189c:	6705                	lui	a4,0x1
ffffffffc020189e:	8785                	srai	a5,a5,0x1
ffffffffc02018a0:	2505                	addiw	a0,a0,1
ffffffffc02018a2:	fef74ee3          	blt	a4,a5,ffffffffc020189e <kmalloc+0x2c>
ffffffffc02018a6:	c088                	sw	a0,0(s1)
ffffffffc02018a8:	e51ff0ef          	jal	ra,ffffffffc02016f8 <__slob_get_free_pages.constprop.0>
ffffffffc02018ac:	e488                	sd	a0,8(s1)
ffffffffc02018ae:	cd21                	beqz	a0,ffffffffc0201906 <kmalloc+0x94>
ffffffffc02018b0:	100027f3          	csrr	a5,sstatus
ffffffffc02018b4:	8b89                	andi	a5,a5,2
ffffffffc02018b6:	e795                	bnez	a5,ffffffffc02018e2 <kmalloc+0x70>
ffffffffc02018b8:	00014797          	auipc	a5,0x14
ffffffffc02018bc:	ca078793          	addi	a5,a5,-864 # ffffffffc0215558 <bigblocks>
ffffffffc02018c0:	6398                	ld	a4,0(a5)
ffffffffc02018c2:	e384                	sd	s1,0(a5)
ffffffffc02018c4:	e898                	sd	a4,16(s1)
ffffffffc02018c6:	60e2                	ld	ra,24(sp)
ffffffffc02018c8:	6442                	ld	s0,16(sp)
ffffffffc02018ca:	64a2                	ld	s1,8(sp)
ffffffffc02018cc:	6902                	ld	s2,0(sp)
ffffffffc02018ce:	6105                	addi	sp,sp,32
ffffffffc02018d0:	8082                	ret
ffffffffc02018d2:	0541                	addi	a0,a0,16
ffffffffc02018d4:	e89ff0ef          	jal	ra,ffffffffc020175c <slob_alloc.constprop.0>
ffffffffc02018d8:	87aa                	mv	a5,a0
ffffffffc02018da:	0541                	addi	a0,a0,16
ffffffffc02018dc:	f7ed                	bnez	a5,ffffffffc02018c6 <kmalloc+0x54>
ffffffffc02018de:	4501                	li	a0,0
ffffffffc02018e0:	b7dd                	j	ffffffffc02018c6 <kmalloc+0x54>
ffffffffc02018e2:	cd9fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc02018e6:	00014797          	auipc	a5,0x14
ffffffffc02018ea:	c7278793          	addi	a5,a5,-910 # ffffffffc0215558 <bigblocks>
ffffffffc02018ee:	6398                	ld	a4,0(a5)
ffffffffc02018f0:	e384                	sd	s1,0(a5)
ffffffffc02018f2:	e898                	sd	a4,16(s1)
ffffffffc02018f4:	cc1fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc02018f8:	60e2                	ld	ra,24(sp)
ffffffffc02018fa:	6442                	ld	s0,16(sp)
ffffffffc02018fc:	6488                	ld	a0,8(s1)
ffffffffc02018fe:	6902                	ld	s2,0(sp)
ffffffffc0201900:	64a2                	ld	s1,8(sp)
ffffffffc0201902:	6105                	addi	sp,sp,32
ffffffffc0201904:	8082                	ret
ffffffffc0201906:	8526                	mv	a0,s1
ffffffffc0201908:	45e1                	li	a1,24
ffffffffc020190a:	d39ff0ef          	jal	ra,ffffffffc0201642 <slob_free>
ffffffffc020190e:	4501                	li	a0,0
ffffffffc0201910:	bf5d                	j	ffffffffc02018c6 <kmalloc+0x54>

ffffffffc0201912 <kfree>:
ffffffffc0201912:	c169                	beqz	a0,ffffffffc02019d4 <kfree+0xc2>
ffffffffc0201914:	1101                	addi	sp,sp,-32
ffffffffc0201916:	e822                	sd	s0,16(sp)
ffffffffc0201918:	ec06                	sd	ra,24(sp)
ffffffffc020191a:	e426                	sd	s1,8(sp)
ffffffffc020191c:	03451793          	slli	a5,a0,0x34
ffffffffc0201920:	842a                	mv	s0,a0
ffffffffc0201922:	e3d9                	bnez	a5,ffffffffc02019a8 <kfree+0x96>
ffffffffc0201924:	100027f3          	csrr	a5,sstatus
ffffffffc0201928:	8b89                	andi	a5,a5,2
ffffffffc020192a:	e7d9                	bnez	a5,ffffffffc02019b8 <kfree+0xa6>
ffffffffc020192c:	00014797          	auipc	a5,0x14
ffffffffc0201930:	c2c7b783          	ld	a5,-980(a5) # ffffffffc0215558 <bigblocks>
ffffffffc0201934:	4601                	li	a2,0
ffffffffc0201936:	cbad                	beqz	a5,ffffffffc02019a8 <kfree+0x96>
ffffffffc0201938:	00014697          	auipc	a3,0x14
ffffffffc020193c:	c2068693          	addi	a3,a3,-992 # ffffffffc0215558 <bigblocks>
ffffffffc0201940:	a021                	j	ffffffffc0201948 <kfree+0x36>
ffffffffc0201942:	01048693          	addi	a3,s1,16
ffffffffc0201946:	c3a5                	beqz	a5,ffffffffc02019a6 <kfree+0x94>
ffffffffc0201948:	6798                	ld	a4,8(a5)
ffffffffc020194a:	84be                	mv	s1,a5
ffffffffc020194c:	6b9c                	ld	a5,16(a5)
ffffffffc020194e:	fe871ae3          	bne	a4,s0,ffffffffc0201942 <kfree+0x30>
ffffffffc0201952:	e29c                	sd	a5,0(a3)
ffffffffc0201954:	ee2d                	bnez	a2,ffffffffc02019ce <kfree+0xbc>
ffffffffc0201956:	c02007b7          	lui	a5,0xc0200
ffffffffc020195a:	4098                	lw	a4,0(s1)
ffffffffc020195c:	08f46963          	bltu	s0,a5,ffffffffc02019ee <kfree+0xdc>
ffffffffc0201960:	00014797          	auipc	a5,0x14
ffffffffc0201964:	c187b783          	ld	a5,-1000(a5) # ffffffffc0215578 <va_pa_offset>
ffffffffc0201968:	8c1d                	sub	s0,s0,a5
ffffffffc020196a:	8031                	srli	s0,s0,0xc
ffffffffc020196c:	00014797          	auipc	a5,0x14
ffffffffc0201970:	c147b783          	ld	a5,-1004(a5) # ffffffffc0215580 <npage>
ffffffffc0201974:	06f47163          	bgeu	s0,a5,ffffffffc02019d6 <kfree+0xc4>
ffffffffc0201978:	00005797          	auipc	a5,0x5
ffffffffc020197c:	6807b783          	ld	a5,1664(a5) # ffffffffc0206ff8 <nbase>
ffffffffc0201980:	8c1d                	sub	s0,s0,a5
ffffffffc0201982:	041a                	slli	s0,s0,0x6
ffffffffc0201984:	00014517          	auipc	a0,0x14
ffffffffc0201988:	c0453503          	ld	a0,-1020(a0) # ffffffffc0215588 <pages>
ffffffffc020198c:	4585                	li	a1,1
ffffffffc020198e:	9522                	add	a0,a0,s0
ffffffffc0201990:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201994:	13c000ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0201998:	6442                	ld	s0,16(sp)
ffffffffc020199a:	60e2                	ld	ra,24(sp)
ffffffffc020199c:	8526                	mv	a0,s1
ffffffffc020199e:	64a2                	ld	s1,8(sp)
ffffffffc02019a0:	45e1                	li	a1,24
ffffffffc02019a2:	6105                	addi	sp,sp,32
ffffffffc02019a4:	b979                	j	ffffffffc0201642 <slob_free>
ffffffffc02019a6:	e20d                	bnez	a2,ffffffffc02019c8 <kfree+0xb6>
ffffffffc02019a8:	ff040513          	addi	a0,s0,-16
ffffffffc02019ac:	6442                	ld	s0,16(sp)
ffffffffc02019ae:	60e2                	ld	ra,24(sp)
ffffffffc02019b0:	64a2                	ld	s1,8(sp)
ffffffffc02019b2:	4581                	li	a1,0
ffffffffc02019b4:	6105                	addi	sp,sp,32
ffffffffc02019b6:	b171                	j	ffffffffc0201642 <slob_free>
ffffffffc02019b8:	c03fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc02019bc:	00014797          	auipc	a5,0x14
ffffffffc02019c0:	b9c7b783          	ld	a5,-1124(a5) # ffffffffc0215558 <bigblocks>
ffffffffc02019c4:	4605                	li	a2,1
ffffffffc02019c6:	fbad                	bnez	a5,ffffffffc0201938 <kfree+0x26>
ffffffffc02019c8:	bedfe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc02019cc:	bff1                	j	ffffffffc02019a8 <kfree+0x96>
ffffffffc02019ce:	be7fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc02019d2:	b751                	j	ffffffffc0201956 <kfree+0x44>
ffffffffc02019d4:	8082                	ret
ffffffffc02019d6:	00004617          	auipc	a2,0x4
ffffffffc02019da:	35260613          	addi	a2,a2,850 # ffffffffc0205d28 <default_pmm_manager+0x108>
ffffffffc02019de:	08000593          	li	a1,128
ffffffffc02019e2:	00004517          	auipc	a0,0x4
ffffffffc02019e6:	29e50513          	addi	a0,a0,670 # ffffffffc0205c80 <default_pmm_manager+0x60>
ffffffffc02019ea:	a55fe0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02019ee:	86a2                	mv	a3,s0
ffffffffc02019f0:	00004617          	auipc	a2,0x4
ffffffffc02019f4:	31060613          	addi	a2,a2,784 # ffffffffc0205d00 <default_pmm_manager+0xe0>
ffffffffc02019f8:	09400593          	li	a1,148
ffffffffc02019fc:	00004517          	auipc	a0,0x4
ffffffffc0201a00:	28450513          	addi	a0,a0,644 # ffffffffc0205c80 <default_pmm_manager+0x60>
ffffffffc0201a04:	a3bfe0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0201a08 <pa2page.part.0>:
ffffffffc0201a08:	1141                	addi	sp,sp,-16
ffffffffc0201a0a:	00004617          	auipc	a2,0x4
ffffffffc0201a0e:	31e60613          	addi	a2,a2,798 # ffffffffc0205d28 <default_pmm_manager+0x108>
ffffffffc0201a12:	08000593          	li	a1,128
ffffffffc0201a16:	00004517          	auipc	a0,0x4
ffffffffc0201a1a:	26a50513          	addi	a0,a0,618 # ffffffffc0205c80 <default_pmm_manager+0x60>
ffffffffc0201a1e:	e406                	sd	ra,8(sp)
ffffffffc0201a20:	a1ffe0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0201a24 <pte2page.part.0>:
ffffffffc0201a24:	1141                	addi	sp,sp,-16
ffffffffc0201a26:	00004617          	auipc	a2,0x4
ffffffffc0201a2a:	32260613          	addi	a2,a2,802 # ffffffffc0205d48 <default_pmm_manager+0x128>
ffffffffc0201a2e:	09f00593          	li	a1,159
ffffffffc0201a32:	00004517          	auipc	a0,0x4
ffffffffc0201a36:	24e50513          	addi	a0,a0,590 # ffffffffc0205c80 <default_pmm_manager+0x60>
ffffffffc0201a3a:	e406                	sd	ra,8(sp)
ffffffffc0201a3c:	a03fe0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0201a40 <alloc_pages>:
ffffffffc0201a40:	7139                	addi	sp,sp,-64
ffffffffc0201a42:	f426                	sd	s1,40(sp)
ffffffffc0201a44:	f04a                	sd	s2,32(sp)
ffffffffc0201a46:	ec4e                	sd	s3,24(sp)
ffffffffc0201a48:	e852                	sd	s4,16(sp)
ffffffffc0201a4a:	e456                	sd	s5,8(sp)
ffffffffc0201a4c:	e05a                	sd	s6,0(sp)
ffffffffc0201a4e:	fc06                	sd	ra,56(sp)
ffffffffc0201a50:	f822                	sd	s0,48(sp)
ffffffffc0201a52:	84aa                	mv	s1,a0
ffffffffc0201a54:	00014917          	auipc	s2,0x14
ffffffffc0201a58:	b0c90913          	addi	s2,s2,-1268 # ffffffffc0215560 <pmm_manager>
ffffffffc0201a5c:	4a05                	li	s4,1
ffffffffc0201a5e:	00014a97          	auipc	s5,0x14
ffffffffc0201a62:	b32a8a93          	addi	s5,s5,-1230 # ffffffffc0215590 <swap_init_ok>
ffffffffc0201a66:	0005099b          	sext.w	s3,a0
ffffffffc0201a6a:	00014b17          	auipc	s6,0x14
ffffffffc0201a6e:	b46b0b13          	addi	s6,s6,-1210 # ffffffffc02155b0 <check_mm_struct>
ffffffffc0201a72:	a015                	j	ffffffffc0201a96 <alloc_pages+0x56>
ffffffffc0201a74:	00093783          	ld	a5,0(s2)
ffffffffc0201a78:	6f9c                	ld	a5,24(a5)
ffffffffc0201a7a:	9782                	jalr	a5
ffffffffc0201a7c:	842a                	mv	s0,a0
ffffffffc0201a7e:	4601                	li	a2,0
ffffffffc0201a80:	85ce                	mv	a1,s3
ffffffffc0201a82:	ec05                	bnez	s0,ffffffffc0201aba <alloc_pages+0x7a>
ffffffffc0201a84:	029a6b63          	bltu	s4,s1,ffffffffc0201aba <alloc_pages+0x7a>
ffffffffc0201a88:	000aa783          	lw	a5,0(s5)
ffffffffc0201a8c:	c79d                	beqz	a5,ffffffffc0201aba <alloc_pages+0x7a>
ffffffffc0201a8e:	000b3503          	ld	a0,0(s6)
ffffffffc0201a92:	035010ef          	jal	ra,ffffffffc02032c6 <swap_out>
ffffffffc0201a96:	100027f3          	csrr	a5,sstatus
ffffffffc0201a9a:	8b89                	andi	a5,a5,2
ffffffffc0201a9c:	8526                	mv	a0,s1
ffffffffc0201a9e:	dbf9                	beqz	a5,ffffffffc0201a74 <alloc_pages+0x34>
ffffffffc0201aa0:	b1bfe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0201aa4:	00093783          	ld	a5,0(s2)
ffffffffc0201aa8:	8526                	mv	a0,s1
ffffffffc0201aaa:	6f9c                	ld	a5,24(a5)
ffffffffc0201aac:	9782                	jalr	a5
ffffffffc0201aae:	842a                	mv	s0,a0
ffffffffc0201ab0:	b05fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0201ab4:	4601                	li	a2,0
ffffffffc0201ab6:	85ce                	mv	a1,s3
ffffffffc0201ab8:	d471                	beqz	s0,ffffffffc0201a84 <alloc_pages+0x44>
ffffffffc0201aba:	70e2                	ld	ra,56(sp)
ffffffffc0201abc:	8522                	mv	a0,s0
ffffffffc0201abe:	7442                	ld	s0,48(sp)
ffffffffc0201ac0:	74a2                	ld	s1,40(sp)
ffffffffc0201ac2:	7902                	ld	s2,32(sp)
ffffffffc0201ac4:	69e2                	ld	s3,24(sp)
ffffffffc0201ac6:	6a42                	ld	s4,16(sp)
ffffffffc0201ac8:	6aa2                	ld	s5,8(sp)
ffffffffc0201aca:	6b02                	ld	s6,0(sp)
ffffffffc0201acc:	6121                	addi	sp,sp,64
ffffffffc0201ace:	8082                	ret

ffffffffc0201ad0 <free_pages>:
ffffffffc0201ad0:	100027f3          	csrr	a5,sstatus
ffffffffc0201ad4:	8b89                	andi	a5,a5,2
ffffffffc0201ad6:	e799                	bnez	a5,ffffffffc0201ae4 <free_pages+0x14>
ffffffffc0201ad8:	00014797          	auipc	a5,0x14
ffffffffc0201adc:	a887b783          	ld	a5,-1400(a5) # ffffffffc0215560 <pmm_manager>
ffffffffc0201ae0:	739c                	ld	a5,32(a5)
ffffffffc0201ae2:	8782                	jr	a5
ffffffffc0201ae4:	1101                	addi	sp,sp,-32
ffffffffc0201ae6:	ec06                	sd	ra,24(sp)
ffffffffc0201ae8:	e822                	sd	s0,16(sp)
ffffffffc0201aea:	e426                	sd	s1,8(sp)
ffffffffc0201aec:	842a                	mv	s0,a0
ffffffffc0201aee:	84ae                	mv	s1,a1
ffffffffc0201af0:	acbfe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0201af4:	00014797          	auipc	a5,0x14
ffffffffc0201af8:	a6c7b783          	ld	a5,-1428(a5) # ffffffffc0215560 <pmm_manager>
ffffffffc0201afc:	739c                	ld	a5,32(a5)
ffffffffc0201afe:	85a6                	mv	a1,s1
ffffffffc0201b00:	8522                	mv	a0,s0
ffffffffc0201b02:	9782                	jalr	a5
ffffffffc0201b04:	6442                	ld	s0,16(sp)
ffffffffc0201b06:	60e2                	ld	ra,24(sp)
ffffffffc0201b08:	64a2                	ld	s1,8(sp)
ffffffffc0201b0a:	6105                	addi	sp,sp,32
ffffffffc0201b0c:	aa9fe06f          	j	ffffffffc02005b4 <intr_enable>

ffffffffc0201b10 <nr_free_pages>:
ffffffffc0201b10:	100027f3          	csrr	a5,sstatus
ffffffffc0201b14:	8b89                	andi	a5,a5,2
ffffffffc0201b16:	e799                	bnez	a5,ffffffffc0201b24 <nr_free_pages+0x14>
ffffffffc0201b18:	00014797          	auipc	a5,0x14
ffffffffc0201b1c:	a487b783          	ld	a5,-1464(a5) # ffffffffc0215560 <pmm_manager>
ffffffffc0201b20:	779c                	ld	a5,40(a5)
ffffffffc0201b22:	8782                	jr	a5
ffffffffc0201b24:	1141                	addi	sp,sp,-16
ffffffffc0201b26:	e406                	sd	ra,8(sp)
ffffffffc0201b28:	e022                	sd	s0,0(sp)
ffffffffc0201b2a:	a91fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0201b2e:	00014797          	auipc	a5,0x14
ffffffffc0201b32:	a327b783          	ld	a5,-1486(a5) # ffffffffc0215560 <pmm_manager>
ffffffffc0201b36:	779c                	ld	a5,40(a5)
ffffffffc0201b38:	9782                	jalr	a5
ffffffffc0201b3a:	842a                	mv	s0,a0
ffffffffc0201b3c:	a79fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0201b40:	60a2                	ld	ra,8(sp)
ffffffffc0201b42:	8522                	mv	a0,s0
ffffffffc0201b44:	6402                	ld	s0,0(sp)
ffffffffc0201b46:	0141                	addi	sp,sp,16
ffffffffc0201b48:	8082                	ret

ffffffffc0201b4a <get_pte>:
ffffffffc0201b4a:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201b4e:	1ff7f793          	andi	a5,a5,511
ffffffffc0201b52:	7139                	addi	sp,sp,-64
ffffffffc0201b54:	078e                	slli	a5,a5,0x3
ffffffffc0201b56:	f426                	sd	s1,40(sp)
ffffffffc0201b58:	00f504b3          	add	s1,a0,a5
ffffffffc0201b5c:	6094                	ld	a3,0(s1)
ffffffffc0201b5e:	f04a                	sd	s2,32(sp)
ffffffffc0201b60:	ec4e                	sd	s3,24(sp)
ffffffffc0201b62:	e852                	sd	s4,16(sp)
ffffffffc0201b64:	fc06                	sd	ra,56(sp)
ffffffffc0201b66:	f822                	sd	s0,48(sp)
ffffffffc0201b68:	e456                	sd	s5,8(sp)
ffffffffc0201b6a:	e05a                	sd	s6,0(sp)
ffffffffc0201b6c:	0016f793          	andi	a5,a3,1
ffffffffc0201b70:	892e                	mv	s2,a1
ffffffffc0201b72:	89b2                	mv	s3,a2
ffffffffc0201b74:	00014a17          	auipc	s4,0x14
ffffffffc0201b78:	a0ca0a13          	addi	s4,s4,-1524 # ffffffffc0215580 <npage>
ffffffffc0201b7c:	e7b5                	bnez	a5,ffffffffc0201be8 <get_pte+0x9e>
ffffffffc0201b7e:	12060b63          	beqz	a2,ffffffffc0201cb4 <get_pte+0x16a>
ffffffffc0201b82:	4505                	li	a0,1
ffffffffc0201b84:	ebdff0ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0201b88:	842a                	mv	s0,a0
ffffffffc0201b8a:	12050563          	beqz	a0,ffffffffc0201cb4 <get_pte+0x16a>
ffffffffc0201b8e:	00014b17          	auipc	s6,0x14
ffffffffc0201b92:	9fab0b13          	addi	s6,s6,-1542 # ffffffffc0215588 <pages>
ffffffffc0201b96:	000b3503          	ld	a0,0(s6)
ffffffffc0201b9a:	00080ab7          	lui	s5,0x80
ffffffffc0201b9e:	00014a17          	auipc	s4,0x14
ffffffffc0201ba2:	9e2a0a13          	addi	s4,s4,-1566 # ffffffffc0215580 <npage>
ffffffffc0201ba6:	40a40533          	sub	a0,s0,a0
ffffffffc0201baa:	8519                	srai	a0,a0,0x6
ffffffffc0201bac:	9556                	add	a0,a0,s5
ffffffffc0201bae:	000a3703          	ld	a4,0(s4)
ffffffffc0201bb2:	00c51793          	slli	a5,a0,0xc
ffffffffc0201bb6:	4685                	li	a3,1
ffffffffc0201bb8:	c014                	sw	a3,0(s0)
ffffffffc0201bba:	83b1                	srli	a5,a5,0xc
ffffffffc0201bbc:	0532                	slli	a0,a0,0xc
ffffffffc0201bbe:	14e7f163          	bgeu	a5,a4,ffffffffc0201d00 <get_pte+0x1b6>
ffffffffc0201bc2:	00014797          	auipc	a5,0x14
ffffffffc0201bc6:	9b67b783          	ld	a5,-1610(a5) # ffffffffc0215578 <va_pa_offset>
ffffffffc0201bca:	953e                	add	a0,a0,a5
ffffffffc0201bcc:	6605                	lui	a2,0x1
ffffffffc0201bce:	4581                	li	a1,0
ffffffffc0201bd0:	2b0030ef          	jal	ra,ffffffffc0204e80 <memset>
ffffffffc0201bd4:	000b3783          	ld	a5,0(s6)
ffffffffc0201bd8:	40f406b3          	sub	a3,s0,a5
ffffffffc0201bdc:	8699                	srai	a3,a3,0x6
ffffffffc0201bde:	96d6                	add	a3,a3,s5
ffffffffc0201be0:	06aa                	slli	a3,a3,0xa
ffffffffc0201be2:	0116e693          	ori	a3,a3,17
ffffffffc0201be6:	e094                	sd	a3,0(s1)
ffffffffc0201be8:	77fd                	lui	a5,0xfffff
ffffffffc0201bea:	068a                	slli	a3,a3,0x2
ffffffffc0201bec:	000a3703          	ld	a4,0(s4)
ffffffffc0201bf0:	8efd                	and	a3,a3,a5
ffffffffc0201bf2:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201bf6:	0ce7f163          	bgeu	a5,a4,ffffffffc0201cb8 <get_pte+0x16e>
ffffffffc0201bfa:	00014a97          	auipc	s5,0x14
ffffffffc0201bfe:	97ea8a93          	addi	s5,s5,-1666 # ffffffffc0215578 <va_pa_offset>
ffffffffc0201c02:	000ab603          	ld	a2,0(s5)
ffffffffc0201c06:	01595793          	srli	a5,s2,0x15
ffffffffc0201c0a:	1ff7f793          	andi	a5,a5,511
ffffffffc0201c0e:	96b2                	add	a3,a3,a2
ffffffffc0201c10:	078e                	slli	a5,a5,0x3
ffffffffc0201c12:	00f68433          	add	s0,a3,a5
ffffffffc0201c16:	6014                	ld	a3,0(s0)
ffffffffc0201c18:	0016f793          	andi	a5,a3,1
ffffffffc0201c1c:	e3ad                	bnez	a5,ffffffffc0201c7e <get_pte+0x134>
ffffffffc0201c1e:	08098b63          	beqz	s3,ffffffffc0201cb4 <get_pte+0x16a>
ffffffffc0201c22:	4505                	li	a0,1
ffffffffc0201c24:	e1dff0ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0201c28:	84aa                	mv	s1,a0
ffffffffc0201c2a:	c549                	beqz	a0,ffffffffc0201cb4 <get_pte+0x16a>
ffffffffc0201c2c:	00014b17          	auipc	s6,0x14
ffffffffc0201c30:	95cb0b13          	addi	s6,s6,-1700 # ffffffffc0215588 <pages>
ffffffffc0201c34:	000b3683          	ld	a3,0(s6)
ffffffffc0201c38:	000809b7          	lui	s3,0x80
ffffffffc0201c3c:	000a3703          	ld	a4,0(s4)
ffffffffc0201c40:	40d506b3          	sub	a3,a0,a3
ffffffffc0201c44:	8699                	srai	a3,a3,0x6
ffffffffc0201c46:	96ce                	add	a3,a3,s3
ffffffffc0201c48:	00c69793          	slli	a5,a3,0xc
ffffffffc0201c4c:	4605                	li	a2,1
ffffffffc0201c4e:	c110                	sw	a2,0(a0)
ffffffffc0201c50:	83b1                	srli	a5,a5,0xc
ffffffffc0201c52:	06b2                	slli	a3,a3,0xc
ffffffffc0201c54:	08e7fa63          	bgeu	a5,a4,ffffffffc0201ce8 <get_pte+0x19e>
ffffffffc0201c58:	000ab503          	ld	a0,0(s5)
ffffffffc0201c5c:	6605                	lui	a2,0x1
ffffffffc0201c5e:	4581                	li	a1,0
ffffffffc0201c60:	9536                	add	a0,a0,a3
ffffffffc0201c62:	21e030ef          	jal	ra,ffffffffc0204e80 <memset>
ffffffffc0201c66:	000b3783          	ld	a5,0(s6)
ffffffffc0201c6a:	40f486b3          	sub	a3,s1,a5
ffffffffc0201c6e:	8699                	srai	a3,a3,0x6
ffffffffc0201c70:	96ce                	add	a3,a3,s3
ffffffffc0201c72:	06aa                	slli	a3,a3,0xa
ffffffffc0201c74:	0116e693          	ori	a3,a3,17
ffffffffc0201c78:	e014                	sd	a3,0(s0)
ffffffffc0201c7a:	000a3703          	ld	a4,0(s4)
ffffffffc0201c7e:	77fd                	lui	a5,0xfffff
ffffffffc0201c80:	068a                	slli	a3,a3,0x2
ffffffffc0201c82:	8efd                	and	a3,a3,a5
ffffffffc0201c84:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201c88:	04e7f463          	bgeu	a5,a4,ffffffffc0201cd0 <get_pte+0x186>
ffffffffc0201c8c:	000ab783          	ld	a5,0(s5)
ffffffffc0201c90:	00c95913          	srli	s2,s2,0xc
ffffffffc0201c94:	1ff97913          	andi	s2,s2,511
ffffffffc0201c98:	96be                	add	a3,a3,a5
ffffffffc0201c9a:	090e                	slli	s2,s2,0x3
ffffffffc0201c9c:	01268533          	add	a0,a3,s2
ffffffffc0201ca0:	70e2                	ld	ra,56(sp)
ffffffffc0201ca2:	7442                	ld	s0,48(sp)
ffffffffc0201ca4:	74a2                	ld	s1,40(sp)
ffffffffc0201ca6:	7902                	ld	s2,32(sp)
ffffffffc0201ca8:	69e2                	ld	s3,24(sp)
ffffffffc0201caa:	6a42                	ld	s4,16(sp)
ffffffffc0201cac:	6aa2                	ld	s5,8(sp)
ffffffffc0201cae:	6b02                	ld	s6,0(sp)
ffffffffc0201cb0:	6121                	addi	sp,sp,64
ffffffffc0201cb2:	8082                	ret
ffffffffc0201cb4:	4501                	li	a0,0
ffffffffc0201cb6:	b7ed                	j	ffffffffc0201ca0 <get_pte+0x156>
ffffffffc0201cb8:	00004617          	auipc	a2,0x4
ffffffffc0201cbc:	fa060613          	addi	a2,a2,-96 # ffffffffc0205c58 <default_pmm_manager+0x38>
ffffffffc0201cc0:	0f900593          	li	a1,249
ffffffffc0201cc4:	00004517          	auipc	a0,0x4
ffffffffc0201cc8:	0ac50513          	addi	a0,a0,172 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0201ccc:	f72fe0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201cd0:	00004617          	auipc	a2,0x4
ffffffffc0201cd4:	f8860613          	addi	a2,a2,-120 # ffffffffc0205c58 <default_pmm_manager+0x38>
ffffffffc0201cd8:	10900593          	li	a1,265
ffffffffc0201cdc:	00004517          	auipc	a0,0x4
ffffffffc0201ce0:	09450513          	addi	a0,a0,148 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0201ce4:	f5afe0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201ce8:	00004617          	auipc	a2,0x4
ffffffffc0201cec:	f7060613          	addi	a2,a2,-144 # ffffffffc0205c58 <default_pmm_manager+0x38>
ffffffffc0201cf0:	10500593          	li	a1,261
ffffffffc0201cf4:	00004517          	auipc	a0,0x4
ffffffffc0201cf8:	07c50513          	addi	a0,a0,124 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0201cfc:	f42fe0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201d00:	86aa                	mv	a3,a0
ffffffffc0201d02:	00004617          	auipc	a2,0x4
ffffffffc0201d06:	f5660613          	addi	a2,a2,-170 # ffffffffc0205c58 <default_pmm_manager+0x38>
ffffffffc0201d0a:	0f100593          	li	a1,241
ffffffffc0201d0e:	00004517          	auipc	a0,0x4
ffffffffc0201d12:	06250513          	addi	a0,a0,98 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0201d16:	f28fe0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0201d1a <get_page>:
ffffffffc0201d1a:	1141                	addi	sp,sp,-16
ffffffffc0201d1c:	e022                	sd	s0,0(sp)
ffffffffc0201d1e:	8432                	mv	s0,a2
ffffffffc0201d20:	4601                	li	a2,0
ffffffffc0201d22:	e406                	sd	ra,8(sp)
ffffffffc0201d24:	e27ff0ef          	jal	ra,ffffffffc0201b4a <get_pte>
ffffffffc0201d28:	c011                	beqz	s0,ffffffffc0201d2c <get_page+0x12>
ffffffffc0201d2a:	e008                	sd	a0,0(s0)
ffffffffc0201d2c:	c511                	beqz	a0,ffffffffc0201d38 <get_page+0x1e>
ffffffffc0201d2e:	611c                	ld	a5,0(a0)
ffffffffc0201d30:	4501                	li	a0,0
ffffffffc0201d32:	0017f713          	andi	a4,a5,1
ffffffffc0201d36:	e709                	bnez	a4,ffffffffc0201d40 <get_page+0x26>
ffffffffc0201d38:	60a2                	ld	ra,8(sp)
ffffffffc0201d3a:	6402                	ld	s0,0(sp)
ffffffffc0201d3c:	0141                	addi	sp,sp,16
ffffffffc0201d3e:	8082                	ret
ffffffffc0201d40:	078a                	slli	a5,a5,0x2
ffffffffc0201d42:	83b1                	srli	a5,a5,0xc
ffffffffc0201d44:	00014717          	auipc	a4,0x14
ffffffffc0201d48:	83c73703          	ld	a4,-1988(a4) # ffffffffc0215580 <npage>
ffffffffc0201d4c:	00e7ff63          	bgeu	a5,a4,ffffffffc0201d6a <get_page+0x50>
ffffffffc0201d50:	60a2                	ld	ra,8(sp)
ffffffffc0201d52:	6402                	ld	s0,0(sp)
ffffffffc0201d54:	fff80737          	lui	a4,0xfff80
ffffffffc0201d58:	97ba                	add	a5,a5,a4
ffffffffc0201d5a:	00014517          	auipc	a0,0x14
ffffffffc0201d5e:	82e53503          	ld	a0,-2002(a0) # ffffffffc0215588 <pages>
ffffffffc0201d62:	079a                	slli	a5,a5,0x6
ffffffffc0201d64:	953e                	add	a0,a0,a5
ffffffffc0201d66:	0141                	addi	sp,sp,16
ffffffffc0201d68:	8082                	ret
ffffffffc0201d6a:	c9fff0ef          	jal	ra,ffffffffc0201a08 <pa2page.part.0>

ffffffffc0201d6e <page_remove>:
ffffffffc0201d6e:	7179                	addi	sp,sp,-48
ffffffffc0201d70:	4601                	li	a2,0
ffffffffc0201d72:	ec26                	sd	s1,24(sp)
ffffffffc0201d74:	f406                	sd	ra,40(sp)
ffffffffc0201d76:	f022                	sd	s0,32(sp)
ffffffffc0201d78:	84ae                	mv	s1,a1
ffffffffc0201d7a:	dd1ff0ef          	jal	ra,ffffffffc0201b4a <get_pte>
ffffffffc0201d7e:	c511                	beqz	a0,ffffffffc0201d8a <page_remove+0x1c>
ffffffffc0201d80:	611c                	ld	a5,0(a0)
ffffffffc0201d82:	842a                	mv	s0,a0
ffffffffc0201d84:	0017f713          	andi	a4,a5,1
ffffffffc0201d88:	e711                	bnez	a4,ffffffffc0201d94 <page_remove+0x26>
ffffffffc0201d8a:	70a2                	ld	ra,40(sp)
ffffffffc0201d8c:	7402                	ld	s0,32(sp)
ffffffffc0201d8e:	64e2                	ld	s1,24(sp)
ffffffffc0201d90:	6145                	addi	sp,sp,48
ffffffffc0201d92:	8082                	ret
ffffffffc0201d94:	078a                	slli	a5,a5,0x2
ffffffffc0201d96:	83b1                	srli	a5,a5,0xc
ffffffffc0201d98:	00013717          	auipc	a4,0x13
ffffffffc0201d9c:	7e873703          	ld	a4,2024(a4) # ffffffffc0215580 <npage>
ffffffffc0201da0:	06e7f363          	bgeu	a5,a4,ffffffffc0201e06 <page_remove+0x98>
ffffffffc0201da4:	fff80737          	lui	a4,0xfff80
ffffffffc0201da8:	97ba                	add	a5,a5,a4
ffffffffc0201daa:	079a                	slli	a5,a5,0x6
ffffffffc0201dac:	00013517          	auipc	a0,0x13
ffffffffc0201db0:	7dc53503          	ld	a0,2012(a0) # ffffffffc0215588 <pages>
ffffffffc0201db4:	953e                	add	a0,a0,a5
ffffffffc0201db6:	411c                	lw	a5,0(a0)
ffffffffc0201db8:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201dbc:	c118                	sw	a4,0(a0)
ffffffffc0201dbe:	cb11                	beqz	a4,ffffffffc0201dd2 <page_remove+0x64>
ffffffffc0201dc0:	00043023          	sd	zero,0(s0)
ffffffffc0201dc4:	12048073          	sfence.vma	s1
ffffffffc0201dc8:	70a2                	ld	ra,40(sp)
ffffffffc0201dca:	7402                	ld	s0,32(sp)
ffffffffc0201dcc:	64e2                	ld	s1,24(sp)
ffffffffc0201dce:	6145                	addi	sp,sp,48
ffffffffc0201dd0:	8082                	ret
ffffffffc0201dd2:	100027f3          	csrr	a5,sstatus
ffffffffc0201dd6:	8b89                	andi	a5,a5,2
ffffffffc0201dd8:	eb89                	bnez	a5,ffffffffc0201dea <page_remove+0x7c>
ffffffffc0201dda:	00013797          	auipc	a5,0x13
ffffffffc0201dde:	7867b783          	ld	a5,1926(a5) # ffffffffc0215560 <pmm_manager>
ffffffffc0201de2:	739c                	ld	a5,32(a5)
ffffffffc0201de4:	4585                	li	a1,1
ffffffffc0201de6:	9782                	jalr	a5
ffffffffc0201de8:	bfe1                	j	ffffffffc0201dc0 <page_remove+0x52>
ffffffffc0201dea:	e42a                	sd	a0,8(sp)
ffffffffc0201dec:	fcefe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0201df0:	00013797          	auipc	a5,0x13
ffffffffc0201df4:	7707b783          	ld	a5,1904(a5) # ffffffffc0215560 <pmm_manager>
ffffffffc0201df8:	739c                	ld	a5,32(a5)
ffffffffc0201dfa:	6522                	ld	a0,8(sp)
ffffffffc0201dfc:	4585                	li	a1,1
ffffffffc0201dfe:	9782                	jalr	a5
ffffffffc0201e00:	fb4fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0201e04:	bf75                	j	ffffffffc0201dc0 <page_remove+0x52>
ffffffffc0201e06:	c03ff0ef          	jal	ra,ffffffffc0201a08 <pa2page.part.0>

ffffffffc0201e0a <page_insert>:
ffffffffc0201e0a:	7139                	addi	sp,sp,-64
ffffffffc0201e0c:	e852                	sd	s4,16(sp)
ffffffffc0201e0e:	8a32                	mv	s4,a2
ffffffffc0201e10:	f822                	sd	s0,48(sp)
ffffffffc0201e12:	4605                	li	a2,1
ffffffffc0201e14:	842e                	mv	s0,a1
ffffffffc0201e16:	85d2                	mv	a1,s4
ffffffffc0201e18:	f426                	sd	s1,40(sp)
ffffffffc0201e1a:	fc06                	sd	ra,56(sp)
ffffffffc0201e1c:	f04a                	sd	s2,32(sp)
ffffffffc0201e1e:	ec4e                	sd	s3,24(sp)
ffffffffc0201e20:	e456                	sd	s5,8(sp)
ffffffffc0201e22:	84b6                	mv	s1,a3
ffffffffc0201e24:	d27ff0ef          	jal	ra,ffffffffc0201b4a <get_pte>
ffffffffc0201e28:	c969                	beqz	a0,ffffffffc0201efa <page_insert+0xf0>
ffffffffc0201e2a:	4014                	lw	a3,0(s0)
ffffffffc0201e2c:	611c                	ld	a5,0(a0)
ffffffffc0201e2e:	89aa                	mv	s3,a0
ffffffffc0201e30:	0016871b          	addiw	a4,a3,1
ffffffffc0201e34:	c018                	sw	a4,0(s0)
ffffffffc0201e36:	0017f713          	andi	a4,a5,1
ffffffffc0201e3a:	ef05                	bnez	a4,ffffffffc0201e72 <page_insert+0x68>
ffffffffc0201e3c:	00013717          	auipc	a4,0x13
ffffffffc0201e40:	74c73703          	ld	a4,1868(a4) # ffffffffc0215588 <pages>
ffffffffc0201e44:	8c19                	sub	s0,s0,a4
ffffffffc0201e46:	000807b7          	lui	a5,0x80
ffffffffc0201e4a:	8419                	srai	s0,s0,0x6
ffffffffc0201e4c:	943e                	add	s0,s0,a5
ffffffffc0201e4e:	042a                	slli	s0,s0,0xa
ffffffffc0201e50:	8cc1                	or	s1,s1,s0
ffffffffc0201e52:	0014e493          	ori	s1,s1,1
ffffffffc0201e56:	0099b023          	sd	s1,0(s3) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0201e5a:	120a0073          	sfence.vma	s4
ffffffffc0201e5e:	4501                	li	a0,0
ffffffffc0201e60:	70e2                	ld	ra,56(sp)
ffffffffc0201e62:	7442                	ld	s0,48(sp)
ffffffffc0201e64:	74a2                	ld	s1,40(sp)
ffffffffc0201e66:	7902                	ld	s2,32(sp)
ffffffffc0201e68:	69e2                	ld	s3,24(sp)
ffffffffc0201e6a:	6a42                	ld	s4,16(sp)
ffffffffc0201e6c:	6aa2                	ld	s5,8(sp)
ffffffffc0201e6e:	6121                	addi	sp,sp,64
ffffffffc0201e70:	8082                	ret
ffffffffc0201e72:	078a                	slli	a5,a5,0x2
ffffffffc0201e74:	83b1                	srli	a5,a5,0xc
ffffffffc0201e76:	00013717          	auipc	a4,0x13
ffffffffc0201e7a:	70a73703          	ld	a4,1802(a4) # ffffffffc0215580 <npage>
ffffffffc0201e7e:	08e7f063          	bgeu	a5,a4,ffffffffc0201efe <page_insert+0xf4>
ffffffffc0201e82:	00013a97          	auipc	s5,0x13
ffffffffc0201e86:	706a8a93          	addi	s5,s5,1798 # ffffffffc0215588 <pages>
ffffffffc0201e8a:	000ab703          	ld	a4,0(s5)
ffffffffc0201e8e:	fff80637          	lui	a2,0xfff80
ffffffffc0201e92:	00c78933          	add	s2,a5,a2
ffffffffc0201e96:	091a                	slli	s2,s2,0x6
ffffffffc0201e98:	993a                	add	s2,s2,a4
ffffffffc0201e9a:	01240c63          	beq	s0,s2,ffffffffc0201eb2 <page_insert+0xa8>
ffffffffc0201e9e:	00092783          	lw	a5,0(s2)
ffffffffc0201ea2:	fff7869b          	addiw	a3,a5,-1
ffffffffc0201ea6:	00d92023          	sw	a3,0(s2)
ffffffffc0201eaa:	c691                	beqz	a3,ffffffffc0201eb6 <page_insert+0xac>
ffffffffc0201eac:	120a0073          	sfence.vma	s4
ffffffffc0201eb0:	bf51                	j	ffffffffc0201e44 <page_insert+0x3a>
ffffffffc0201eb2:	c014                	sw	a3,0(s0)
ffffffffc0201eb4:	bf41                	j	ffffffffc0201e44 <page_insert+0x3a>
ffffffffc0201eb6:	100027f3          	csrr	a5,sstatus
ffffffffc0201eba:	8b89                	andi	a5,a5,2
ffffffffc0201ebc:	ef91                	bnez	a5,ffffffffc0201ed8 <page_insert+0xce>
ffffffffc0201ebe:	00013797          	auipc	a5,0x13
ffffffffc0201ec2:	6a27b783          	ld	a5,1698(a5) # ffffffffc0215560 <pmm_manager>
ffffffffc0201ec6:	739c                	ld	a5,32(a5)
ffffffffc0201ec8:	4585                	li	a1,1
ffffffffc0201eca:	854a                	mv	a0,s2
ffffffffc0201ecc:	9782                	jalr	a5
ffffffffc0201ece:	000ab703          	ld	a4,0(s5)
ffffffffc0201ed2:	120a0073          	sfence.vma	s4
ffffffffc0201ed6:	b7bd                	j	ffffffffc0201e44 <page_insert+0x3a>
ffffffffc0201ed8:	ee2fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0201edc:	00013797          	auipc	a5,0x13
ffffffffc0201ee0:	6847b783          	ld	a5,1668(a5) # ffffffffc0215560 <pmm_manager>
ffffffffc0201ee4:	739c                	ld	a5,32(a5)
ffffffffc0201ee6:	4585                	li	a1,1
ffffffffc0201ee8:	854a                	mv	a0,s2
ffffffffc0201eea:	9782                	jalr	a5
ffffffffc0201eec:	ec8fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0201ef0:	000ab703          	ld	a4,0(s5)
ffffffffc0201ef4:	120a0073          	sfence.vma	s4
ffffffffc0201ef8:	b7b1                	j	ffffffffc0201e44 <page_insert+0x3a>
ffffffffc0201efa:	5571                	li	a0,-4
ffffffffc0201efc:	b795                	j	ffffffffc0201e60 <page_insert+0x56>
ffffffffc0201efe:	b0bff0ef          	jal	ra,ffffffffc0201a08 <pa2page.part.0>

ffffffffc0201f02 <pmm_init>:
ffffffffc0201f02:	00004797          	auipc	a5,0x4
ffffffffc0201f06:	d1e78793          	addi	a5,a5,-738 # ffffffffc0205c20 <default_pmm_manager>
ffffffffc0201f0a:	638c                	ld	a1,0(a5)
ffffffffc0201f0c:	711d                	addi	sp,sp,-96
ffffffffc0201f0e:	ec86                	sd	ra,88(sp)
ffffffffc0201f10:	e4a6                	sd	s1,72(sp)
ffffffffc0201f12:	fc4e                	sd	s3,56(sp)
ffffffffc0201f14:	f05a                	sd	s6,32(sp)
ffffffffc0201f16:	ec5e                	sd	s7,24(sp)
ffffffffc0201f18:	e8a2                	sd	s0,80(sp)
ffffffffc0201f1a:	e0ca                	sd	s2,64(sp)
ffffffffc0201f1c:	f852                	sd	s4,48(sp)
ffffffffc0201f1e:	f456                	sd	s5,40(sp)
ffffffffc0201f20:	e862                	sd	s8,16(sp)
ffffffffc0201f22:	00013b97          	auipc	s7,0x13
ffffffffc0201f26:	63eb8b93          	addi	s7,s7,1598 # ffffffffc0215560 <pmm_manager>
ffffffffc0201f2a:	00004517          	auipc	a0,0x4
ffffffffc0201f2e:	e5650513          	addi	a0,a0,-426 # ffffffffc0205d80 <default_pmm_manager+0x160>
ffffffffc0201f32:	00fbb023          	sd	a5,0(s7)
ffffffffc0201f36:	a54fe0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0201f3a:	000bb783          	ld	a5,0(s7)
ffffffffc0201f3e:	00013997          	auipc	s3,0x13
ffffffffc0201f42:	63a98993          	addi	s3,s3,1594 # ffffffffc0215578 <va_pa_offset>
ffffffffc0201f46:	00013497          	auipc	s1,0x13
ffffffffc0201f4a:	63a48493          	addi	s1,s1,1594 # ffffffffc0215580 <npage>
ffffffffc0201f4e:	679c                	ld	a5,8(a5)
ffffffffc0201f50:	00013b17          	auipc	s6,0x13
ffffffffc0201f54:	638b0b13          	addi	s6,s6,1592 # ffffffffc0215588 <pages>
ffffffffc0201f58:	9782                	jalr	a5
ffffffffc0201f5a:	57f5                	li	a5,-3
ffffffffc0201f5c:	07fa                	slli	a5,a5,0x1e
ffffffffc0201f5e:	00004517          	auipc	a0,0x4
ffffffffc0201f62:	e3a50513          	addi	a0,a0,-454 # ffffffffc0205d98 <default_pmm_manager+0x178>
ffffffffc0201f66:	00f9b023          	sd	a5,0(s3)
ffffffffc0201f6a:	a20fe0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0201f6e:	46c5                	li	a3,17
ffffffffc0201f70:	06ee                	slli	a3,a3,0x1b
ffffffffc0201f72:	40100613          	li	a2,1025
ffffffffc0201f76:	16fd                	addi	a3,a3,-1
ffffffffc0201f78:	0656                	slli	a2,a2,0x15
ffffffffc0201f7a:	07e005b7          	lui	a1,0x7e00
ffffffffc0201f7e:	00004517          	auipc	a0,0x4
ffffffffc0201f82:	e3250513          	addi	a0,a0,-462 # ffffffffc0205db0 <default_pmm_manager+0x190>
ffffffffc0201f86:	a04fe0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0201f8a:	777d                	lui	a4,0xfffff
ffffffffc0201f8c:	00014797          	auipc	a5,0x14
ffffffffc0201f90:	64b78793          	addi	a5,a5,1611 # ffffffffc02165d7 <end+0xfff>
ffffffffc0201f94:	8ff9                	and	a5,a5,a4
ffffffffc0201f96:	00088737          	lui	a4,0x88
ffffffffc0201f9a:	e098                	sd	a4,0(s1)
ffffffffc0201f9c:	00fb3023          	sd	a5,0(s6)
ffffffffc0201fa0:	4705                	li	a4,1
ffffffffc0201fa2:	07a1                	addi	a5,a5,8
ffffffffc0201fa4:	40e7b02f          	amoor.d	zero,a4,(a5)
ffffffffc0201fa8:	4505                	li	a0,1
ffffffffc0201faa:	fff805b7          	lui	a1,0xfff80
ffffffffc0201fae:	000b3783          	ld	a5,0(s6)
ffffffffc0201fb2:	00671693          	slli	a3,a4,0x6
ffffffffc0201fb6:	97b6                	add	a5,a5,a3
ffffffffc0201fb8:	07a1                	addi	a5,a5,8
ffffffffc0201fba:	40a7b02f          	amoor.d	zero,a0,(a5)
ffffffffc0201fbe:	6090                	ld	a2,0(s1)
ffffffffc0201fc0:	0705                	addi	a4,a4,1
ffffffffc0201fc2:	00b607b3          	add	a5,a2,a1
ffffffffc0201fc6:	fef764e3          	bltu	a4,a5,ffffffffc0201fae <pmm_init+0xac>
ffffffffc0201fca:	000b3503          	ld	a0,0(s6)
ffffffffc0201fce:	079a                	slli	a5,a5,0x6
ffffffffc0201fd0:	c0200737          	lui	a4,0xc0200
ffffffffc0201fd4:	00f506b3          	add	a3,a0,a5
ffffffffc0201fd8:	60e6e363          	bltu	a3,a4,ffffffffc02025de <pmm_init+0x6dc>
ffffffffc0201fdc:	0009b583          	ld	a1,0(s3)
ffffffffc0201fe0:	4745                	li	a4,17
ffffffffc0201fe2:	076e                	slli	a4,a4,0x1b
ffffffffc0201fe4:	8e8d                	sub	a3,a3,a1
ffffffffc0201fe6:	4ae6e263          	bltu	a3,a4,ffffffffc020248a <pmm_init+0x588>
ffffffffc0201fea:	00004517          	auipc	a0,0x4
ffffffffc0201fee:	dee50513          	addi	a0,a0,-530 # ffffffffc0205dd8 <default_pmm_manager+0x1b8>
ffffffffc0201ff2:	998fe0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0201ff6:	000bb783          	ld	a5,0(s7)
ffffffffc0201ffa:	00013917          	auipc	s2,0x13
ffffffffc0201ffe:	57690913          	addi	s2,s2,1398 # ffffffffc0215570 <boot_pgdir>
ffffffffc0202002:	7b9c                	ld	a5,48(a5)
ffffffffc0202004:	9782                	jalr	a5
ffffffffc0202006:	00004517          	auipc	a0,0x4
ffffffffc020200a:	dea50513          	addi	a0,a0,-534 # ffffffffc0205df0 <default_pmm_manager+0x1d0>
ffffffffc020200e:	97cfe0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0202012:	00007697          	auipc	a3,0x7
ffffffffc0202016:	fee68693          	addi	a3,a3,-18 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc020201a:	00d93023          	sd	a3,0(s2)
ffffffffc020201e:	c02007b7          	lui	a5,0xc0200
ffffffffc0202022:	5cf6ea63          	bltu	a3,a5,ffffffffc02025f6 <pmm_init+0x6f4>
ffffffffc0202026:	0009b783          	ld	a5,0(s3)
ffffffffc020202a:	8e9d                	sub	a3,a3,a5
ffffffffc020202c:	00013797          	auipc	a5,0x13
ffffffffc0202030:	52d7be23          	sd	a3,1340(a5) # ffffffffc0215568 <boot_cr3>
ffffffffc0202034:	100027f3          	csrr	a5,sstatus
ffffffffc0202038:	8b89                	andi	a5,a5,2
ffffffffc020203a:	48079063          	bnez	a5,ffffffffc02024ba <pmm_init+0x5b8>
ffffffffc020203e:	000bb783          	ld	a5,0(s7)
ffffffffc0202042:	779c                	ld	a5,40(a5)
ffffffffc0202044:	9782                	jalr	a5
ffffffffc0202046:	842a                	mv	s0,a0
ffffffffc0202048:	6098                	ld	a4,0(s1)
ffffffffc020204a:	c80007b7          	lui	a5,0xc8000
ffffffffc020204e:	83b1                	srli	a5,a5,0xc
ffffffffc0202050:	5ce7ef63          	bltu	a5,a4,ffffffffc020262e <pmm_init+0x72c>
ffffffffc0202054:	00093503          	ld	a0,0(s2)
ffffffffc0202058:	5a050b63          	beqz	a0,ffffffffc020260e <pmm_init+0x70c>
ffffffffc020205c:	03451793          	slli	a5,a0,0x34
ffffffffc0202060:	5a079763          	bnez	a5,ffffffffc020260e <pmm_init+0x70c>
ffffffffc0202064:	4601                	li	a2,0
ffffffffc0202066:	4581                	li	a1,0
ffffffffc0202068:	cb3ff0ef          	jal	ra,ffffffffc0201d1a <get_page>
ffffffffc020206c:	62051363          	bnez	a0,ffffffffc0202692 <pmm_init+0x790>
ffffffffc0202070:	4505                	li	a0,1
ffffffffc0202072:	9cfff0ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0202076:	8a2a                	mv	s4,a0
ffffffffc0202078:	00093503          	ld	a0,0(s2)
ffffffffc020207c:	4681                	li	a3,0
ffffffffc020207e:	4601                	li	a2,0
ffffffffc0202080:	85d2                	mv	a1,s4
ffffffffc0202082:	d89ff0ef          	jal	ra,ffffffffc0201e0a <page_insert>
ffffffffc0202086:	5e051663          	bnez	a0,ffffffffc0202672 <pmm_init+0x770>
ffffffffc020208a:	00093503          	ld	a0,0(s2)
ffffffffc020208e:	4601                	li	a2,0
ffffffffc0202090:	4581                	li	a1,0
ffffffffc0202092:	ab9ff0ef          	jal	ra,ffffffffc0201b4a <get_pte>
ffffffffc0202096:	5a050e63          	beqz	a0,ffffffffc0202652 <pmm_init+0x750>
ffffffffc020209a:	611c                	ld	a5,0(a0)
ffffffffc020209c:	0017f713          	andi	a4,a5,1
ffffffffc02020a0:	5a070763          	beqz	a4,ffffffffc020264e <pmm_init+0x74c>
ffffffffc02020a4:	6098                	ld	a4,0(s1)
ffffffffc02020a6:	078a                	slli	a5,a5,0x2
ffffffffc02020a8:	83b1                	srli	a5,a5,0xc
ffffffffc02020aa:	52e7f863          	bgeu	a5,a4,ffffffffc02025da <pmm_init+0x6d8>
ffffffffc02020ae:	000b3683          	ld	a3,0(s6)
ffffffffc02020b2:	fff80637          	lui	a2,0xfff80
ffffffffc02020b6:	97b2                	add	a5,a5,a2
ffffffffc02020b8:	079a                	slli	a5,a5,0x6
ffffffffc02020ba:	97b6                	add	a5,a5,a3
ffffffffc02020bc:	10fa14e3          	bne	s4,a5,ffffffffc02029c4 <pmm_init+0xac2>
ffffffffc02020c0:	000a2683          	lw	a3,0(s4)
ffffffffc02020c4:	4785                	li	a5,1
ffffffffc02020c6:	12f69be3          	bne	a3,a5,ffffffffc02029fc <pmm_init+0xafa>
ffffffffc02020ca:	00093503          	ld	a0,0(s2)
ffffffffc02020ce:	77fd                	lui	a5,0xfffff
ffffffffc02020d0:	6114                	ld	a3,0(a0)
ffffffffc02020d2:	068a                	slli	a3,a3,0x2
ffffffffc02020d4:	8efd                	and	a3,a3,a5
ffffffffc02020d6:	00c6d613          	srli	a2,a3,0xc
ffffffffc02020da:	10e675e3          	bgeu	a2,a4,ffffffffc02029e4 <pmm_init+0xae2>
ffffffffc02020de:	0009bc03          	ld	s8,0(s3)
ffffffffc02020e2:	96e2                	add	a3,a3,s8
ffffffffc02020e4:	0006ba83          	ld	s5,0(a3)
ffffffffc02020e8:	0a8a                	slli	s5,s5,0x2
ffffffffc02020ea:	00fafab3          	and	s5,s5,a5
ffffffffc02020ee:	00cad793          	srli	a5,s5,0xc
ffffffffc02020f2:	62e7f063          	bgeu	a5,a4,ffffffffc0202712 <pmm_init+0x810>
ffffffffc02020f6:	4601                	li	a2,0
ffffffffc02020f8:	6585                	lui	a1,0x1
ffffffffc02020fa:	9c56                	add	s8,s8,s5
ffffffffc02020fc:	a4fff0ef          	jal	ra,ffffffffc0201b4a <get_pte>
ffffffffc0202100:	0c21                	addi	s8,s8,8
ffffffffc0202102:	5f851863          	bne	a0,s8,ffffffffc02026f2 <pmm_init+0x7f0>
ffffffffc0202106:	4505                	li	a0,1
ffffffffc0202108:	939ff0ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc020210c:	8aaa                	mv	s5,a0
ffffffffc020210e:	00093503          	ld	a0,0(s2)
ffffffffc0202112:	46d1                	li	a3,20
ffffffffc0202114:	6605                	lui	a2,0x1
ffffffffc0202116:	85d6                	mv	a1,s5
ffffffffc0202118:	cf3ff0ef          	jal	ra,ffffffffc0201e0a <page_insert>
ffffffffc020211c:	58051b63          	bnez	a0,ffffffffc02026b2 <pmm_init+0x7b0>
ffffffffc0202120:	00093503          	ld	a0,0(s2)
ffffffffc0202124:	4601                	li	a2,0
ffffffffc0202126:	6585                	lui	a1,0x1
ffffffffc0202128:	a23ff0ef          	jal	ra,ffffffffc0201b4a <get_pte>
ffffffffc020212c:	0e0508e3          	beqz	a0,ffffffffc0202a1c <pmm_init+0xb1a>
ffffffffc0202130:	611c                	ld	a5,0(a0)
ffffffffc0202132:	0107f713          	andi	a4,a5,16
ffffffffc0202136:	6e070b63          	beqz	a4,ffffffffc020282c <pmm_init+0x92a>
ffffffffc020213a:	8b91                	andi	a5,a5,4
ffffffffc020213c:	6a078863          	beqz	a5,ffffffffc02027ec <pmm_init+0x8ea>
ffffffffc0202140:	00093503          	ld	a0,0(s2)
ffffffffc0202144:	611c                	ld	a5,0(a0)
ffffffffc0202146:	8bc1                	andi	a5,a5,16
ffffffffc0202148:	68078263          	beqz	a5,ffffffffc02027cc <pmm_init+0x8ca>
ffffffffc020214c:	000aa703          	lw	a4,0(s5)
ffffffffc0202150:	4785                	li	a5,1
ffffffffc0202152:	58f71063          	bne	a4,a5,ffffffffc02026d2 <pmm_init+0x7d0>
ffffffffc0202156:	4681                	li	a3,0
ffffffffc0202158:	6605                	lui	a2,0x1
ffffffffc020215a:	85d2                	mv	a1,s4
ffffffffc020215c:	cafff0ef          	jal	ra,ffffffffc0201e0a <page_insert>
ffffffffc0202160:	62051663          	bnez	a0,ffffffffc020278c <pmm_init+0x88a>
ffffffffc0202164:	000a2703          	lw	a4,0(s4)
ffffffffc0202168:	4789                	li	a5,2
ffffffffc020216a:	60f71163          	bne	a4,a5,ffffffffc020276c <pmm_init+0x86a>
ffffffffc020216e:	000aa783          	lw	a5,0(s5)
ffffffffc0202172:	5c079d63          	bnez	a5,ffffffffc020274c <pmm_init+0x84a>
ffffffffc0202176:	00093503          	ld	a0,0(s2)
ffffffffc020217a:	4601                	li	a2,0
ffffffffc020217c:	6585                	lui	a1,0x1
ffffffffc020217e:	9cdff0ef          	jal	ra,ffffffffc0201b4a <get_pte>
ffffffffc0202182:	5a050563          	beqz	a0,ffffffffc020272c <pmm_init+0x82a>
ffffffffc0202186:	6118                	ld	a4,0(a0)
ffffffffc0202188:	00177793          	andi	a5,a4,1
ffffffffc020218c:	4c078163          	beqz	a5,ffffffffc020264e <pmm_init+0x74c>
ffffffffc0202190:	6094                	ld	a3,0(s1)
ffffffffc0202192:	00271793          	slli	a5,a4,0x2
ffffffffc0202196:	83b1                	srli	a5,a5,0xc
ffffffffc0202198:	44d7f163          	bgeu	a5,a3,ffffffffc02025da <pmm_init+0x6d8>
ffffffffc020219c:	000b3683          	ld	a3,0(s6)
ffffffffc02021a0:	fff80637          	lui	a2,0xfff80
ffffffffc02021a4:	97b2                	add	a5,a5,a2
ffffffffc02021a6:	079a                	slli	a5,a5,0x6
ffffffffc02021a8:	97b6                	add	a5,a5,a3
ffffffffc02021aa:	6efa1163          	bne	s4,a5,ffffffffc020288c <pmm_init+0x98a>
ffffffffc02021ae:	8b41                	andi	a4,a4,16
ffffffffc02021b0:	6a071e63          	bnez	a4,ffffffffc020286c <pmm_init+0x96a>
ffffffffc02021b4:	00093503          	ld	a0,0(s2)
ffffffffc02021b8:	4581                	li	a1,0
ffffffffc02021ba:	bb5ff0ef          	jal	ra,ffffffffc0201d6e <page_remove>
ffffffffc02021be:	000a2703          	lw	a4,0(s4)
ffffffffc02021c2:	4785                	li	a5,1
ffffffffc02021c4:	68f71463          	bne	a4,a5,ffffffffc020284c <pmm_init+0x94a>
ffffffffc02021c8:	000aa783          	lw	a5,0(s5)
ffffffffc02021cc:	74079c63          	bnez	a5,ffffffffc0202924 <pmm_init+0xa22>
ffffffffc02021d0:	00093503          	ld	a0,0(s2)
ffffffffc02021d4:	6585                	lui	a1,0x1
ffffffffc02021d6:	b99ff0ef          	jal	ra,ffffffffc0201d6e <page_remove>
ffffffffc02021da:	000a2783          	lw	a5,0(s4)
ffffffffc02021de:	72079363          	bnez	a5,ffffffffc0202904 <pmm_init+0xa02>
ffffffffc02021e2:	000aa783          	lw	a5,0(s5)
ffffffffc02021e6:	6e079f63          	bnez	a5,ffffffffc02028e4 <pmm_init+0x9e2>
ffffffffc02021ea:	00093a03          	ld	s4,0(s2)
ffffffffc02021ee:	6098                	ld	a4,0(s1)
ffffffffc02021f0:	000a3783          	ld	a5,0(s4)
ffffffffc02021f4:	078a                	slli	a5,a5,0x2
ffffffffc02021f6:	83b1                	srli	a5,a5,0xc
ffffffffc02021f8:	3ee7f163          	bgeu	a5,a4,ffffffffc02025da <pmm_init+0x6d8>
ffffffffc02021fc:	fff806b7          	lui	a3,0xfff80
ffffffffc0202200:	000b3503          	ld	a0,0(s6)
ffffffffc0202204:	97b6                	add	a5,a5,a3
ffffffffc0202206:	079a                	slli	a5,a5,0x6
ffffffffc0202208:	00f506b3          	add	a3,a0,a5
ffffffffc020220c:	4290                	lw	a2,0(a3)
ffffffffc020220e:	4685                	li	a3,1
ffffffffc0202210:	6ad61a63          	bne	a2,a3,ffffffffc02028c4 <pmm_init+0x9c2>
ffffffffc0202214:	8799                	srai	a5,a5,0x6
ffffffffc0202216:	00080637          	lui	a2,0x80
ffffffffc020221a:	97b2                	add	a5,a5,a2
ffffffffc020221c:	00c79693          	slli	a3,a5,0xc
ffffffffc0202220:	68e7f663          	bgeu	a5,a4,ffffffffc02028ac <pmm_init+0x9aa>
ffffffffc0202224:	0009b783          	ld	a5,0(s3)
ffffffffc0202228:	97b6                	add	a5,a5,a3
ffffffffc020222a:	639c                	ld	a5,0(a5)
ffffffffc020222c:	078a                	slli	a5,a5,0x2
ffffffffc020222e:	83b1                	srli	a5,a5,0xc
ffffffffc0202230:	3ae7f563          	bgeu	a5,a4,ffffffffc02025da <pmm_init+0x6d8>
ffffffffc0202234:	8f91                	sub	a5,a5,a2
ffffffffc0202236:	079a                	slli	a5,a5,0x6
ffffffffc0202238:	953e                	add	a0,a0,a5
ffffffffc020223a:	100027f3          	csrr	a5,sstatus
ffffffffc020223e:	8b89                	andi	a5,a5,2
ffffffffc0202240:	2c079763          	bnez	a5,ffffffffc020250e <pmm_init+0x60c>
ffffffffc0202244:	000bb783          	ld	a5,0(s7)
ffffffffc0202248:	4585                	li	a1,1
ffffffffc020224a:	739c                	ld	a5,32(a5)
ffffffffc020224c:	9782                	jalr	a5
ffffffffc020224e:	000a3783          	ld	a5,0(s4)
ffffffffc0202252:	6098                	ld	a4,0(s1)
ffffffffc0202254:	078a                	slli	a5,a5,0x2
ffffffffc0202256:	83b1                	srli	a5,a5,0xc
ffffffffc0202258:	38e7f163          	bgeu	a5,a4,ffffffffc02025da <pmm_init+0x6d8>
ffffffffc020225c:	000b3503          	ld	a0,0(s6)
ffffffffc0202260:	fff80737          	lui	a4,0xfff80
ffffffffc0202264:	97ba                	add	a5,a5,a4
ffffffffc0202266:	079a                	slli	a5,a5,0x6
ffffffffc0202268:	953e                	add	a0,a0,a5
ffffffffc020226a:	100027f3          	csrr	a5,sstatus
ffffffffc020226e:	8b89                	andi	a5,a5,2
ffffffffc0202270:	28079363          	bnez	a5,ffffffffc02024f6 <pmm_init+0x5f4>
ffffffffc0202274:	000bb783          	ld	a5,0(s7)
ffffffffc0202278:	4585                	li	a1,1
ffffffffc020227a:	739c                	ld	a5,32(a5)
ffffffffc020227c:	9782                	jalr	a5
ffffffffc020227e:	00093783          	ld	a5,0(s2)
ffffffffc0202282:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fde9a28>
ffffffffc0202286:	12000073          	sfence.vma
ffffffffc020228a:	100027f3          	csrr	a5,sstatus
ffffffffc020228e:	8b89                	andi	a5,a5,2
ffffffffc0202290:	24079963          	bnez	a5,ffffffffc02024e2 <pmm_init+0x5e0>
ffffffffc0202294:	000bb783          	ld	a5,0(s7)
ffffffffc0202298:	779c                	ld	a5,40(a5)
ffffffffc020229a:	9782                	jalr	a5
ffffffffc020229c:	8a2a                	mv	s4,a0
ffffffffc020229e:	71441363          	bne	s0,s4,ffffffffc02029a4 <pmm_init+0xaa2>
ffffffffc02022a2:	00004517          	auipc	a0,0x4
ffffffffc02022a6:	e3650513          	addi	a0,a0,-458 # ffffffffc02060d8 <default_pmm_manager+0x4b8>
ffffffffc02022aa:	ee1fd0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02022ae:	100027f3          	csrr	a5,sstatus
ffffffffc02022b2:	8b89                	andi	a5,a5,2
ffffffffc02022b4:	20079d63          	bnez	a5,ffffffffc02024ce <pmm_init+0x5cc>
ffffffffc02022b8:	000bb783          	ld	a5,0(s7)
ffffffffc02022bc:	779c                	ld	a5,40(a5)
ffffffffc02022be:	9782                	jalr	a5
ffffffffc02022c0:	8c2a                	mv	s8,a0
ffffffffc02022c2:	6098                	ld	a4,0(s1)
ffffffffc02022c4:	c0200437          	lui	s0,0xc0200
ffffffffc02022c8:	7afd                	lui	s5,0xfffff
ffffffffc02022ca:	00c71793          	slli	a5,a4,0xc
ffffffffc02022ce:	6a05                	lui	s4,0x1
ffffffffc02022d0:	02f47c63          	bgeu	s0,a5,ffffffffc0202308 <pmm_init+0x406>
ffffffffc02022d4:	00c45793          	srli	a5,s0,0xc
ffffffffc02022d8:	00093503          	ld	a0,0(s2)
ffffffffc02022dc:	2ee7f263          	bgeu	a5,a4,ffffffffc02025c0 <pmm_init+0x6be>
ffffffffc02022e0:	0009b583          	ld	a1,0(s3)
ffffffffc02022e4:	4601                	li	a2,0
ffffffffc02022e6:	95a2                	add	a1,a1,s0
ffffffffc02022e8:	863ff0ef          	jal	ra,ffffffffc0201b4a <get_pte>
ffffffffc02022ec:	2a050a63          	beqz	a0,ffffffffc02025a0 <pmm_init+0x69e>
ffffffffc02022f0:	611c                	ld	a5,0(a0)
ffffffffc02022f2:	078a                	slli	a5,a5,0x2
ffffffffc02022f4:	0157f7b3          	and	a5,a5,s5
ffffffffc02022f8:	28879463          	bne	a5,s0,ffffffffc0202580 <pmm_init+0x67e>
ffffffffc02022fc:	6098                	ld	a4,0(s1)
ffffffffc02022fe:	9452                	add	s0,s0,s4
ffffffffc0202300:	00c71793          	slli	a5,a4,0xc
ffffffffc0202304:	fcf468e3          	bltu	s0,a5,ffffffffc02022d4 <pmm_init+0x3d2>
ffffffffc0202308:	00093783          	ld	a5,0(s2)
ffffffffc020230c:	639c                	ld	a5,0(a5)
ffffffffc020230e:	66079b63          	bnez	a5,ffffffffc0202984 <pmm_init+0xa82>
ffffffffc0202312:	4505                	li	a0,1
ffffffffc0202314:	f2cff0ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0202318:	842a                	mv	s0,a0
ffffffffc020231a:	00093503          	ld	a0,0(s2)
ffffffffc020231e:	4699                	li	a3,6
ffffffffc0202320:	10000613          	li	a2,256
ffffffffc0202324:	85a2                	mv	a1,s0
ffffffffc0202326:	ae5ff0ef          	jal	ra,ffffffffc0201e0a <page_insert>
ffffffffc020232a:	62051d63          	bnez	a0,ffffffffc0202964 <pmm_init+0xa62>
ffffffffc020232e:	4018                	lw	a4,0(s0)
ffffffffc0202330:	4785                	li	a5,1
ffffffffc0202332:	60f71963          	bne	a4,a5,ffffffffc0202944 <pmm_init+0xa42>
ffffffffc0202336:	00093503          	ld	a0,0(s2)
ffffffffc020233a:	6a05                	lui	s4,0x1
ffffffffc020233c:	4699                	li	a3,6
ffffffffc020233e:	100a0613          	addi	a2,s4,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0202342:	85a2                	mv	a1,s0
ffffffffc0202344:	ac7ff0ef          	jal	ra,ffffffffc0201e0a <page_insert>
ffffffffc0202348:	46051263          	bnez	a0,ffffffffc02027ac <pmm_init+0x8aa>
ffffffffc020234c:	4018                	lw	a4,0(s0)
ffffffffc020234e:	4789                	li	a5,2
ffffffffc0202350:	72f71663          	bne	a4,a5,ffffffffc0202a7c <pmm_init+0xb7a>
ffffffffc0202354:	00004597          	auipc	a1,0x4
ffffffffc0202358:	ebc58593          	addi	a1,a1,-324 # ffffffffc0206210 <default_pmm_manager+0x5f0>
ffffffffc020235c:	10000513          	li	a0,256
ffffffffc0202360:	2c1020ef          	jal	ra,ffffffffc0204e20 <strcpy>
ffffffffc0202364:	100a0593          	addi	a1,s4,256
ffffffffc0202368:	10000513          	li	a0,256
ffffffffc020236c:	2c7020ef          	jal	ra,ffffffffc0204e32 <strcmp>
ffffffffc0202370:	6e051663          	bnez	a0,ffffffffc0202a5c <pmm_init+0xb5a>
ffffffffc0202374:	000b3683          	ld	a3,0(s6)
ffffffffc0202378:	000807b7          	lui	a5,0x80
ffffffffc020237c:	6098                	ld	a4,0(s1)
ffffffffc020237e:	40d406b3          	sub	a3,s0,a3
ffffffffc0202382:	8699                	srai	a3,a3,0x6
ffffffffc0202384:	96be                	add	a3,a3,a5
ffffffffc0202386:	00c69793          	slli	a5,a3,0xc
ffffffffc020238a:	83b1                	srli	a5,a5,0xc
ffffffffc020238c:	06b2                	slli	a3,a3,0xc
ffffffffc020238e:	50e7ff63          	bgeu	a5,a4,ffffffffc02028ac <pmm_init+0x9aa>
ffffffffc0202392:	0009b783          	ld	a5,0(s3)
ffffffffc0202396:	10000513          	li	a0,256
ffffffffc020239a:	97b6                	add	a5,a5,a3
ffffffffc020239c:	10078023          	sb	zero,256(a5) # 80100 <kern_entry-0xffffffffc017ff00>
ffffffffc02023a0:	24b020ef          	jal	ra,ffffffffc0204dea <strlen>
ffffffffc02023a4:	68051c63          	bnez	a0,ffffffffc0202a3c <pmm_init+0xb3a>
ffffffffc02023a8:	00093a03          	ld	s4,0(s2)
ffffffffc02023ac:	6098                	ld	a4,0(s1)
ffffffffc02023ae:	000a3783          	ld	a5,0(s4)
ffffffffc02023b2:	078a                	slli	a5,a5,0x2
ffffffffc02023b4:	83b1                	srli	a5,a5,0xc
ffffffffc02023b6:	22e7f263          	bgeu	a5,a4,ffffffffc02025da <pmm_init+0x6d8>
ffffffffc02023ba:	00c79693          	slli	a3,a5,0xc
ffffffffc02023be:	4ee7f763          	bgeu	a5,a4,ffffffffc02028ac <pmm_init+0x9aa>
ffffffffc02023c2:	0009b783          	ld	a5,0(s3)
ffffffffc02023c6:	00f689b3          	add	s3,a3,a5
ffffffffc02023ca:	100027f3          	csrr	a5,sstatus
ffffffffc02023ce:	8b89                	andi	a5,a5,2
ffffffffc02023d0:	18079d63          	bnez	a5,ffffffffc020256a <pmm_init+0x668>
ffffffffc02023d4:	000bb783          	ld	a5,0(s7)
ffffffffc02023d8:	4585                	li	a1,1
ffffffffc02023da:	8522                	mv	a0,s0
ffffffffc02023dc:	739c                	ld	a5,32(a5)
ffffffffc02023de:	9782                	jalr	a5
ffffffffc02023e0:	0009b783          	ld	a5,0(s3)
ffffffffc02023e4:	6098                	ld	a4,0(s1)
ffffffffc02023e6:	078a                	slli	a5,a5,0x2
ffffffffc02023e8:	83b1                	srli	a5,a5,0xc
ffffffffc02023ea:	1ee7f863          	bgeu	a5,a4,ffffffffc02025da <pmm_init+0x6d8>
ffffffffc02023ee:	000b3503          	ld	a0,0(s6)
ffffffffc02023f2:	fff80737          	lui	a4,0xfff80
ffffffffc02023f6:	97ba                	add	a5,a5,a4
ffffffffc02023f8:	079a                	slli	a5,a5,0x6
ffffffffc02023fa:	953e                	add	a0,a0,a5
ffffffffc02023fc:	100027f3          	csrr	a5,sstatus
ffffffffc0202400:	8b89                	andi	a5,a5,2
ffffffffc0202402:	14079863          	bnez	a5,ffffffffc0202552 <pmm_init+0x650>
ffffffffc0202406:	000bb783          	ld	a5,0(s7)
ffffffffc020240a:	4585                	li	a1,1
ffffffffc020240c:	739c                	ld	a5,32(a5)
ffffffffc020240e:	9782                	jalr	a5
ffffffffc0202410:	000a3783          	ld	a5,0(s4)
ffffffffc0202414:	6098                	ld	a4,0(s1)
ffffffffc0202416:	078a                	slli	a5,a5,0x2
ffffffffc0202418:	83b1                	srli	a5,a5,0xc
ffffffffc020241a:	1ce7f063          	bgeu	a5,a4,ffffffffc02025da <pmm_init+0x6d8>
ffffffffc020241e:	000b3503          	ld	a0,0(s6)
ffffffffc0202422:	fff80737          	lui	a4,0xfff80
ffffffffc0202426:	97ba                	add	a5,a5,a4
ffffffffc0202428:	079a                	slli	a5,a5,0x6
ffffffffc020242a:	953e                	add	a0,a0,a5
ffffffffc020242c:	100027f3          	csrr	a5,sstatus
ffffffffc0202430:	8b89                	andi	a5,a5,2
ffffffffc0202432:	10079463          	bnez	a5,ffffffffc020253a <pmm_init+0x638>
ffffffffc0202436:	000bb783          	ld	a5,0(s7)
ffffffffc020243a:	4585                	li	a1,1
ffffffffc020243c:	739c                	ld	a5,32(a5)
ffffffffc020243e:	9782                	jalr	a5
ffffffffc0202440:	00093783          	ld	a5,0(s2)
ffffffffc0202444:	0007b023          	sd	zero,0(a5)
ffffffffc0202448:	12000073          	sfence.vma
ffffffffc020244c:	100027f3          	csrr	a5,sstatus
ffffffffc0202450:	8b89                	andi	a5,a5,2
ffffffffc0202452:	0c079a63          	bnez	a5,ffffffffc0202526 <pmm_init+0x624>
ffffffffc0202456:	000bb783          	ld	a5,0(s7)
ffffffffc020245a:	779c                	ld	a5,40(a5)
ffffffffc020245c:	9782                	jalr	a5
ffffffffc020245e:	842a                	mv	s0,a0
ffffffffc0202460:	3a8c1663          	bne	s8,s0,ffffffffc020280c <pmm_init+0x90a>
ffffffffc0202464:	00004517          	auipc	a0,0x4
ffffffffc0202468:	e2450513          	addi	a0,a0,-476 # ffffffffc0206288 <default_pmm_manager+0x668>
ffffffffc020246c:	d1ffd0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0202470:	6446                	ld	s0,80(sp)
ffffffffc0202472:	60e6                	ld	ra,88(sp)
ffffffffc0202474:	64a6                	ld	s1,72(sp)
ffffffffc0202476:	6906                	ld	s2,64(sp)
ffffffffc0202478:	79e2                	ld	s3,56(sp)
ffffffffc020247a:	7a42                	ld	s4,48(sp)
ffffffffc020247c:	7aa2                	ld	s5,40(sp)
ffffffffc020247e:	7b02                	ld	s6,32(sp)
ffffffffc0202480:	6be2                	ld	s7,24(sp)
ffffffffc0202482:	6c42                	ld	s8,16(sp)
ffffffffc0202484:	6125                	addi	sp,sp,96
ffffffffc0202486:	bccff06f          	j	ffffffffc0201852 <kmalloc_init>
ffffffffc020248a:	6785                	lui	a5,0x1
ffffffffc020248c:	17fd                	addi	a5,a5,-1
ffffffffc020248e:	96be                	add	a3,a3,a5
ffffffffc0202490:	77fd                	lui	a5,0xfffff
ffffffffc0202492:	8ff5                	and	a5,a5,a3
ffffffffc0202494:	00c7d693          	srli	a3,a5,0xc
ffffffffc0202498:	14c6f163          	bgeu	a3,a2,ffffffffc02025da <pmm_init+0x6d8>
ffffffffc020249c:	000bb603          	ld	a2,0(s7)
ffffffffc02024a0:	fff805b7          	lui	a1,0xfff80
ffffffffc02024a4:	96ae                	add	a3,a3,a1
ffffffffc02024a6:	6a10                	ld	a2,16(a2)
ffffffffc02024a8:	8f1d                	sub	a4,a4,a5
ffffffffc02024aa:	069a                	slli	a3,a3,0x6
ffffffffc02024ac:	00c75593          	srli	a1,a4,0xc
ffffffffc02024b0:	9536                	add	a0,a0,a3
ffffffffc02024b2:	9602                	jalr	a2
ffffffffc02024b4:	0009b583          	ld	a1,0(s3)
ffffffffc02024b8:	be0d                	j	ffffffffc0201fea <pmm_init+0xe8>
ffffffffc02024ba:	900fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc02024be:	000bb783          	ld	a5,0(s7)
ffffffffc02024c2:	779c                	ld	a5,40(a5)
ffffffffc02024c4:	9782                	jalr	a5
ffffffffc02024c6:	842a                	mv	s0,a0
ffffffffc02024c8:	8ecfe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc02024cc:	beb5                	j	ffffffffc0202048 <pmm_init+0x146>
ffffffffc02024ce:	8ecfe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc02024d2:	000bb783          	ld	a5,0(s7)
ffffffffc02024d6:	779c                	ld	a5,40(a5)
ffffffffc02024d8:	9782                	jalr	a5
ffffffffc02024da:	8c2a                	mv	s8,a0
ffffffffc02024dc:	8d8fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc02024e0:	b3cd                	j	ffffffffc02022c2 <pmm_init+0x3c0>
ffffffffc02024e2:	8d8fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc02024e6:	000bb783          	ld	a5,0(s7)
ffffffffc02024ea:	779c                	ld	a5,40(a5)
ffffffffc02024ec:	9782                	jalr	a5
ffffffffc02024ee:	8a2a                	mv	s4,a0
ffffffffc02024f0:	8c4fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc02024f4:	b36d                	j	ffffffffc020229e <pmm_init+0x39c>
ffffffffc02024f6:	e42a                	sd	a0,8(sp)
ffffffffc02024f8:	8c2fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc02024fc:	000bb783          	ld	a5,0(s7)
ffffffffc0202500:	6522                	ld	a0,8(sp)
ffffffffc0202502:	4585                	li	a1,1
ffffffffc0202504:	739c                	ld	a5,32(a5)
ffffffffc0202506:	9782                	jalr	a5
ffffffffc0202508:	8acfe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc020250c:	bb8d                	j	ffffffffc020227e <pmm_init+0x37c>
ffffffffc020250e:	e42a                	sd	a0,8(sp)
ffffffffc0202510:	8aafe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0202514:	000bb783          	ld	a5,0(s7)
ffffffffc0202518:	6522                	ld	a0,8(sp)
ffffffffc020251a:	4585                	li	a1,1
ffffffffc020251c:	739c                	ld	a5,32(a5)
ffffffffc020251e:	9782                	jalr	a5
ffffffffc0202520:	894fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0202524:	b32d                	j	ffffffffc020224e <pmm_init+0x34c>
ffffffffc0202526:	894fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc020252a:	000bb783          	ld	a5,0(s7)
ffffffffc020252e:	779c                	ld	a5,40(a5)
ffffffffc0202530:	9782                	jalr	a5
ffffffffc0202532:	842a                	mv	s0,a0
ffffffffc0202534:	880fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0202538:	b725                	j	ffffffffc0202460 <pmm_init+0x55e>
ffffffffc020253a:	e42a                	sd	a0,8(sp)
ffffffffc020253c:	87efe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0202540:	000bb783          	ld	a5,0(s7)
ffffffffc0202544:	6522                	ld	a0,8(sp)
ffffffffc0202546:	4585                	li	a1,1
ffffffffc0202548:	739c                	ld	a5,32(a5)
ffffffffc020254a:	9782                	jalr	a5
ffffffffc020254c:	868fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0202550:	bdc5                	j	ffffffffc0202440 <pmm_init+0x53e>
ffffffffc0202552:	e42a                	sd	a0,8(sp)
ffffffffc0202554:	866fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0202558:	000bb783          	ld	a5,0(s7)
ffffffffc020255c:	6522                	ld	a0,8(sp)
ffffffffc020255e:	4585                	li	a1,1
ffffffffc0202560:	739c                	ld	a5,32(a5)
ffffffffc0202562:	9782                	jalr	a5
ffffffffc0202564:	850fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0202568:	b565                	j	ffffffffc0202410 <pmm_init+0x50e>
ffffffffc020256a:	850fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc020256e:	000bb783          	ld	a5,0(s7)
ffffffffc0202572:	4585                	li	a1,1
ffffffffc0202574:	8522                	mv	a0,s0
ffffffffc0202576:	739c                	ld	a5,32(a5)
ffffffffc0202578:	9782                	jalr	a5
ffffffffc020257a:	83afe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc020257e:	b58d                	j	ffffffffc02023e0 <pmm_init+0x4de>
ffffffffc0202580:	00004697          	auipc	a3,0x4
ffffffffc0202584:	bb868693          	addi	a3,a3,-1096 # ffffffffc0206138 <default_pmm_manager+0x518>
ffffffffc0202588:	00003617          	auipc	a2,0x3
ffffffffc020258c:	2e860613          	addi	a2,a2,744 # ffffffffc0205870 <commands+0x738>
ffffffffc0202590:	1d000593          	li	a1,464
ffffffffc0202594:	00003517          	auipc	a0,0x3
ffffffffc0202598:	7dc50513          	addi	a0,a0,2012 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc020259c:	ea3fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02025a0:	00004697          	auipc	a3,0x4
ffffffffc02025a4:	b5868693          	addi	a3,a3,-1192 # ffffffffc02060f8 <default_pmm_manager+0x4d8>
ffffffffc02025a8:	00003617          	auipc	a2,0x3
ffffffffc02025ac:	2c860613          	addi	a2,a2,712 # ffffffffc0205870 <commands+0x738>
ffffffffc02025b0:	1cf00593          	li	a1,463
ffffffffc02025b4:	00003517          	auipc	a0,0x3
ffffffffc02025b8:	7bc50513          	addi	a0,a0,1980 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc02025bc:	e83fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02025c0:	86a2                	mv	a3,s0
ffffffffc02025c2:	00003617          	auipc	a2,0x3
ffffffffc02025c6:	69660613          	addi	a2,a2,1686 # ffffffffc0205c58 <default_pmm_manager+0x38>
ffffffffc02025ca:	1cf00593          	li	a1,463
ffffffffc02025ce:	00003517          	auipc	a0,0x3
ffffffffc02025d2:	7a250513          	addi	a0,a0,1954 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc02025d6:	e69fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02025da:	c2eff0ef          	jal	ra,ffffffffc0201a08 <pa2page.part.0>
ffffffffc02025de:	00003617          	auipc	a2,0x3
ffffffffc02025e2:	72260613          	addi	a2,a2,1826 # ffffffffc0205d00 <default_pmm_manager+0xe0>
ffffffffc02025e6:	08500593          	li	a1,133
ffffffffc02025ea:	00003517          	auipc	a0,0x3
ffffffffc02025ee:	78650513          	addi	a0,a0,1926 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc02025f2:	e4dfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02025f6:	00003617          	auipc	a2,0x3
ffffffffc02025fa:	70a60613          	addi	a2,a2,1802 # ffffffffc0205d00 <default_pmm_manager+0xe0>
ffffffffc02025fe:	0c900593          	li	a1,201
ffffffffc0202602:	00003517          	auipc	a0,0x3
ffffffffc0202606:	76e50513          	addi	a0,a0,1902 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc020260a:	e35fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020260e:	00004697          	auipc	a3,0x4
ffffffffc0202612:	82268693          	addi	a3,a3,-2014 # ffffffffc0205e30 <default_pmm_manager+0x210>
ffffffffc0202616:	00003617          	auipc	a2,0x3
ffffffffc020261a:	25a60613          	addi	a2,a2,602 # ffffffffc0205870 <commands+0x738>
ffffffffc020261e:	18700593          	li	a1,391
ffffffffc0202622:	00003517          	auipc	a0,0x3
ffffffffc0202626:	74e50513          	addi	a0,a0,1870 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc020262a:	e15fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020262e:	00003697          	auipc	a3,0x3
ffffffffc0202632:	7e268693          	addi	a3,a3,2018 # ffffffffc0205e10 <default_pmm_manager+0x1f0>
ffffffffc0202636:	00003617          	auipc	a2,0x3
ffffffffc020263a:	23a60613          	addi	a2,a2,570 # ffffffffc0205870 <commands+0x738>
ffffffffc020263e:	18500593          	li	a1,389
ffffffffc0202642:	00003517          	auipc	a0,0x3
ffffffffc0202646:	72e50513          	addi	a0,a0,1838 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc020264a:	df5fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020264e:	bd6ff0ef          	jal	ra,ffffffffc0201a24 <pte2page.part.0>
ffffffffc0202652:	00004697          	auipc	a3,0x4
ffffffffc0202656:	86e68693          	addi	a3,a3,-1938 # ffffffffc0205ec0 <default_pmm_manager+0x2a0>
ffffffffc020265a:	00003617          	auipc	a2,0x3
ffffffffc020265e:	21660613          	addi	a2,a2,534 # ffffffffc0205870 <commands+0x738>
ffffffffc0202662:	19400593          	li	a1,404
ffffffffc0202666:	00003517          	auipc	a0,0x3
ffffffffc020266a:	70a50513          	addi	a0,a0,1802 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc020266e:	dd1fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202672:	00004697          	auipc	a3,0x4
ffffffffc0202676:	81e68693          	addi	a3,a3,-2018 # ffffffffc0205e90 <default_pmm_manager+0x270>
ffffffffc020267a:	00003617          	auipc	a2,0x3
ffffffffc020267e:	1f660613          	addi	a2,a2,502 # ffffffffc0205870 <commands+0x738>
ffffffffc0202682:	18f00593          	li	a1,399
ffffffffc0202686:	00003517          	auipc	a0,0x3
ffffffffc020268a:	6ea50513          	addi	a0,a0,1770 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc020268e:	db1fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202692:	00003697          	auipc	a3,0x3
ffffffffc0202696:	7d668693          	addi	a3,a3,2006 # ffffffffc0205e68 <default_pmm_manager+0x248>
ffffffffc020269a:	00003617          	auipc	a2,0x3
ffffffffc020269e:	1d660613          	addi	a2,a2,470 # ffffffffc0205870 <commands+0x738>
ffffffffc02026a2:	18900593          	li	a1,393
ffffffffc02026a6:	00003517          	auipc	a0,0x3
ffffffffc02026aa:	6ca50513          	addi	a0,a0,1738 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc02026ae:	d91fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02026b2:	00004697          	auipc	a3,0x4
ffffffffc02026b6:	89668693          	addi	a3,a3,-1898 # ffffffffc0205f48 <default_pmm_manager+0x328>
ffffffffc02026ba:	00003617          	auipc	a2,0x3
ffffffffc02026be:	1b660613          	addi	a2,a2,438 # ffffffffc0205870 <commands+0x738>
ffffffffc02026c2:	19f00593          	li	a1,415
ffffffffc02026c6:	00003517          	auipc	a0,0x3
ffffffffc02026ca:	6aa50513          	addi	a0,a0,1706 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc02026ce:	d71fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02026d2:	00004697          	auipc	a3,0x4
ffffffffc02026d6:	91668693          	addi	a3,a3,-1770 # ffffffffc0205fe8 <default_pmm_manager+0x3c8>
ffffffffc02026da:	00003617          	auipc	a2,0x3
ffffffffc02026de:	19660613          	addi	a2,a2,406 # ffffffffc0205870 <commands+0x738>
ffffffffc02026e2:	1a500593          	li	a1,421
ffffffffc02026e6:	00003517          	auipc	a0,0x3
ffffffffc02026ea:	68a50513          	addi	a0,a0,1674 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc02026ee:	d51fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02026f2:	00004697          	auipc	a3,0x4
ffffffffc02026f6:	82e68693          	addi	a3,a3,-2002 # ffffffffc0205f20 <default_pmm_manager+0x300>
ffffffffc02026fa:	00003617          	auipc	a2,0x3
ffffffffc02026fe:	17660613          	addi	a2,a2,374 # ffffffffc0205870 <commands+0x738>
ffffffffc0202702:	19b00593          	li	a1,411
ffffffffc0202706:	00003517          	auipc	a0,0x3
ffffffffc020270a:	66a50513          	addi	a0,a0,1642 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc020270e:	d31fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202712:	86d6                	mv	a3,s5
ffffffffc0202714:	00003617          	auipc	a2,0x3
ffffffffc0202718:	54460613          	addi	a2,a2,1348 # ffffffffc0205c58 <default_pmm_manager+0x38>
ffffffffc020271c:	19a00593          	li	a1,410
ffffffffc0202720:	00003517          	auipc	a0,0x3
ffffffffc0202724:	65050513          	addi	a0,a0,1616 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202728:	d17fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020272c:	00004697          	auipc	a3,0x4
ffffffffc0202730:	85468693          	addi	a3,a3,-1964 # ffffffffc0205f80 <default_pmm_manager+0x360>
ffffffffc0202734:	00003617          	auipc	a2,0x3
ffffffffc0202738:	13c60613          	addi	a2,a2,316 # ffffffffc0205870 <commands+0x738>
ffffffffc020273c:	1ad00593          	li	a1,429
ffffffffc0202740:	00003517          	auipc	a0,0x3
ffffffffc0202744:	63050513          	addi	a0,a0,1584 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202748:	cf7fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020274c:	00004697          	auipc	a3,0x4
ffffffffc0202750:	8fc68693          	addi	a3,a3,-1796 # ffffffffc0206048 <default_pmm_manager+0x428>
ffffffffc0202754:	00003617          	auipc	a2,0x3
ffffffffc0202758:	11c60613          	addi	a2,a2,284 # ffffffffc0205870 <commands+0x738>
ffffffffc020275c:	1aa00593          	li	a1,426
ffffffffc0202760:	00003517          	auipc	a0,0x3
ffffffffc0202764:	61050513          	addi	a0,a0,1552 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202768:	cd7fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020276c:	00004697          	auipc	a3,0x4
ffffffffc0202770:	8c468693          	addi	a3,a3,-1852 # ffffffffc0206030 <default_pmm_manager+0x410>
ffffffffc0202774:	00003617          	auipc	a2,0x3
ffffffffc0202778:	0fc60613          	addi	a2,a2,252 # ffffffffc0205870 <commands+0x738>
ffffffffc020277c:	1a900593          	li	a1,425
ffffffffc0202780:	00003517          	auipc	a0,0x3
ffffffffc0202784:	5f050513          	addi	a0,a0,1520 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202788:	cb7fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020278c:	00004697          	auipc	a3,0x4
ffffffffc0202790:	87468693          	addi	a3,a3,-1932 # ffffffffc0206000 <default_pmm_manager+0x3e0>
ffffffffc0202794:	00003617          	auipc	a2,0x3
ffffffffc0202798:	0dc60613          	addi	a2,a2,220 # ffffffffc0205870 <commands+0x738>
ffffffffc020279c:	1a800593          	li	a1,424
ffffffffc02027a0:	00003517          	auipc	a0,0x3
ffffffffc02027a4:	5d050513          	addi	a0,a0,1488 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc02027a8:	c97fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02027ac:	00004697          	auipc	a3,0x4
ffffffffc02027b0:	a0c68693          	addi	a3,a3,-1524 # ffffffffc02061b8 <default_pmm_manager+0x598>
ffffffffc02027b4:	00003617          	auipc	a2,0x3
ffffffffc02027b8:	0bc60613          	addi	a2,a2,188 # ffffffffc0205870 <commands+0x738>
ffffffffc02027bc:	1d900593          	li	a1,473
ffffffffc02027c0:	00003517          	auipc	a0,0x3
ffffffffc02027c4:	5b050513          	addi	a0,a0,1456 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc02027c8:	c77fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02027cc:	00004697          	auipc	a3,0x4
ffffffffc02027d0:	80468693          	addi	a3,a3,-2044 # ffffffffc0205fd0 <default_pmm_manager+0x3b0>
ffffffffc02027d4:	00003617          	auipc	a2,0x3
ffffffffc02027d8:	09c60613          	addi	a2,a2,156 # ffffffffc0205870 <commands+0x738>
ffffffffc02027dc:	1a400593          	li	a1,420
ffffffffc02027e0:	00003517          	auipc	a0,0x3
ffffffffc02027e4:	59050513          	addi	a0,a0,1424 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc02027e8:	c57fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02027ec:	00003697          	auipc	a3,0x3
ffffffffc02027f0:	7d468693          	addi	a3,a3,2004 # ffffffffc0205fc0 <default_pmm_manager+0x3a0>
ffffffffc02027f4:	00003617          	auipc	a2,0x3
ffffffffc02027f8:	07c60613          	addi	a2,a2,124 # ffffffffc0205870 <commands+0x738>
ffffffffc02027fc:	1a300593          	li	a1,419
ffffffffc0202800:	00003517          	auipc	a0,0x3
ffffffffc0202804:	57050513          	addi	a0,a0,1392 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202808:	c37fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020280c:	00004697          	auipc	a3,0x4
ffffffffc0202810:	8ac68693          	addi	a3,a3,-1876 # ffffffffc02060b8 <default_pmm_manager+0x498>
ffffffffc0202814:	00003617          	auipc	a2,0x3
ffffffffc0202818:	05c60613          	addi	a2,a2,92 # ffffffffc0205870 <commands+0x738>
ffffffffc020281c:	1ea00593          	li	a1,490
ffffffffc0202820:	00003517          	auipc	a0,0x3
ffffffffc0202824:	55050513          	addi	a0,a0,1360 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202828:	c17fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020282c:	00003697          	auipc	a3,0x3
ffffffffc0202830:	78468693          	addi	a3,a3,1924 # ffffffffc0205fb0 <default_pmm_manager+0x390>
ffffffffc0202834:	00003617          	auipc	a2,0x3
ffffffffc0202838:	03c60613          	addi	a2,a2,60 # ffffffffc0205870 <commands+0x738>
ffffffffc020283c:	1a200593          	li	a1,418
ffffffffc0202840:	00003517          	auipc	a0,0x3
ffffffffc0202844:	53050513          	addi	a0,a0,1328 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202848:	bf7fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020284c:	00003697          	auipc	a3,0x3
ffffffffc0202850:	6bc68693          	addi	a3,a3,1724 # ffffffffc0205f08 <default_pmm_manager+0x2e8>
ffffffffc0202854:	00003617          	auipc	a2,0x3
ffffffffc0202858:	01c60613          	addi	a2,a2,28 # ffffffffc0205870 <commands+0x738>
ffffffffc020285c:	1b300593          	li	a1,435
ffffffffc0202860:	00003517          	auipc	a0,0x3
ffffffffc0202864:	51050513          	addi	a0,a0,1296 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202868:	bd7fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020286c:	00003697          	auipc	a3,0x3
ffffffffc0202870:	7f468693          	addi	a3,a3,2036 # ffffffffc0206060 <default_pmm_manager+0x440>
ffffffffc0202874:	00003617          	auipc	a2,0x3
ffffffffc0202878:	ffc60613          	addi	a2,a2,-4 # ffffffffc0205870 <commands+0x738>
ffffffffc020287c:	1af00593          	li	a1,431
ffffffffc0202880:	00003517          	auipc	a0,0x3
ffffffffc0202884:	4f050513          	addi	a0,a0,1264 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202888:	bb7fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020288c:	00003697          	auipc	a3,0x3
ffffffffc0202890:	66468693          	addi	a3,a3,1636 # ffffffffc0205ef0 <default_pmm_manager+0x2d0>
ffffffffc0202894:	00003617          	auipc	a2,0x3
ffffffffc0202898:	fdc60613          	addi	a2,a2,-36 # ffffffffc0205870 <commands+0x738>
ffffffffc020289c:	1ae00593          	li	a1,430
ffffffffc02028a0:	00003517          	auipc	a0,0x3
ffffffffc02028a4:	4d050513          	addi	a0,a0,1232 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc02028a8:	b97fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02028ac:	00003617          	auipc	a2,0x3
ffffffffc02028b0:	3ac60613          	addi	a2,a2,940 # ffffffffc0205c58 <default_pmm_manager+0x38>
ffffffffc02028b4:	08b00593          	li	a1,139
ffffffffc02028b8:	00003517          	auipc	a0,0x3
ffffffffc02028bc:	3c850513          	addi	a0,a0,968 # ffffffffc0205c80 <default_pmm_manager+0x60>
ffffffffc02028c0:	b7ffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02028c4:	00003697          	auipc	a3,0x3
ffffffffc02028c8:	7cc68693          	addi	a3,a3,1996 # ffffffffc0206090 <default_pmm_manager+0x470>
ffffffffc02028cc:	00003617          	auipc	a2,0x3
ffffffffc02028d0:	fa460613          	addi	a2,a2,-92 # ffffffffc0205870 <commands+0x738>
ffffffffc02028d4:	1ba00593          	li	a1,442
ffffffffc02028d8:	00003517          	auipc	a0,0x3
ffffffffc02028dc:	49850513          	addi	a0,a0,1176 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc02028e0:	b5ffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02028e4:	00003697          	auipc	a3,0x3
ffffffffc02028e8:	76468693          	addi	a3,a3,1892 # ffffffffc0206048 <default_pmm_manager+0x428>
ffffffffc02028ec:	00003617          	auipc	a2,0x3
ffffffffc02028f0:	f8460613          	addi	a2,a2,-124 # ffffffffc0205870 <commands+0x738>
ffffffffc02028f4:	1b800593          	li	a1,440
ffffffffc02028f8:	00003517          	auipc	a0,0x3
ffffffffc02028fc:	47850513          	addi	a0,a0,1144 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202900:	b3ffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202904:	00003697          	auipc	a3,0x3
ffffffffc0202908:	77468693          	addi	a3,a3,1908 # ffffffffc0206078 <default_pmm_manager+0x458>
ffffffffc020290c:	00003617          	auipc	a2,0x3
ffffffffc0202910:	f6460613          	addi	a2,a2,-156 # ffffffffc0205870 <commands+0x738>
ffffffffc0202914:	1b700593          	li	a1,439
ffffffffc0202918:	00003517          	auipc	a0,0x3
ffffffffc020291c:	45850513          	addi	a0,a0,1112 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202920:	b1ffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202924:	00003697          	auipc	a3,0x3
ffffffffc0202928:	72468693          	addi	a3,a3,1828 # ffffffffc0206048 <default_pmm_manager+0x428>
ffffffffc020292c:	00003617          	auipc	a2,0x3
ffffffffc0202930:	f4460613          	addi	a2,a2,-188 # ffffffffc0205870 <commands+0x738>
ffffffffc0202934:	1b400593          	li	a1,436
ffffffffc0202938:	00003517          	auipc	a0,0x3
ffffffffc020293c:	43850513          	addi	a0,a0,1080 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202940:	afffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202944:	00004697          	auipc	a3,0x4
ffffffffc0202948:	85c68693          	addi	a3,a3,-1956 # ffffffffc02061a0 <default_pmm_manager+0x580>
ffffffffc020294c:	00003617          	auipc	a2,0x3
ffffffffc0202950:	f2460613          	addi	a2,a2,-220 # ffffffffc0205870 <commands+0x738>
ffffffffc0202954:	1d800593          	li	a1,472
ffffffffc0202958:	00003517          	auipc	a0,0x3
ffffffffc020295c:	41850513          	addi	a0,a0,1048 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202960:	adffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202964:	00004697          	auipc	a3,0x4
ffffffffc0202968:	80468693          	addi	a3,a3,-2044 # ffffffffc0206168 <default_pmm_manager+0x548>
ffffffffc020296c:	00003617          	auipc	a2,0x3
ffffffffc0202970:	f0460613          	addi	a2,a2,-252 # ffffffffc0205870 <commands+0x738>
ffffffffc0202974:	1d700593          	li	a1,471
ffffffffc0202978:	00003517          	auipc	a0,0x3
ffffffffc020297c:	3f850513          	addi	a0,a0,1016 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202980:	abffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202984:	00003697          	auipc	a3,0x3
ffffffffc0202988:	7cc68693          	addi	a3,a3,1996 # ffffffffc0206150 <default_pmm_manager+0x530>
ffffffffc020298c:	00003617          	auipc	a2,0x3
ffffffffc0202990:	ee460613          	addi	a2,a2,-284 # ffffffffc0205870 <commands+0x738>
ffffffffc0202994:	1d300593          	li	a1,467
ffffffffc0202998:	00003517          	auipc	a0,0x3
ffffffffc020299c:	3d850513          	addi	a0,a0,984 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc02029a0:	a9ffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02029a4:	00003697          	auipc	a3,0x3
ffffffffc02029a8:	71468693          	addi	a3,a3,1812 # ffffffffc02060b8 <default_pmm_manager+0x498>
ffffffffc02029ac:	00003617          	auipc	a2,0x3
ffffffffc02029b0:	ec460613          	addi	a2,a2,-316 # ffffffffc0205870 <commands+0x738>
ffffffffc02029b4:	1c200593          	li	a1,450
ffffffffc02029b8:	00003517          	auipc	a0,0x3
ffffffffc02029bc:	3b850513          	addi	a0,a0,952 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc02029c0:	a7ffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02029c4:	00003697          	auipc	a3,0x3
ffffffffc02029c8:	52c68693          	addi	a3,a3,1324 # ffffffffc0205ef0 <default_pmm_manager+0x2d0>
ffffffffc02029cc:	00003617          	auipc	a2,0x3
ffffffffc02029d0:	ea460613          	addi	a2,a2,-348 # ffffffffc0205870 <commands+0x738>
ffffffffc02029d4:	19500593          	li	a1,405
ffffffffc02029d8:	00003517          	auipc	a0,0x3
ffffffffc02029dc:	39850513          	addi	a0,a0,920 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc02029e0:	a5ffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02029e4:	00003617          	auipc	a2,0x3
ffffffffc02029e8:	27460613          	addi	a2,a2,628 # ffffffffc0205c58 <default_pmm_manager+0x38>
ffffffffc02029ec:	19900593          	li	a1,409
ffffffffc02029f0:	00003517          	auipc	a0,0x3
ffffffffc02029f4:	38050513          	addi	a0,a0,896 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc02029f8:	a47fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02029fc:	00003697          	auipc	a3,0x3
ffffffffc0202a00:	50c68693          	addi	a3,a3,1292 # ffffffffc0205f08 <default_pmm_manager+0x2e8>
ffffffffc0202a04:	00003617          	auipc	a2,0x3
ffffffffc0202a08:	e6c60613          	addi	a2,a2,-404 # ffffffffc0205870 <commands+0x738>
ffffffffc0202a0c:	19600593          	li	a1,406
ffffffffc0202a10:	00003517          	auipc	a0,0x3
ffffffffc0202a14:	36050513          	addi	a0,a0,864 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202a18:	a27fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202a1c:	00003697          	auipc	a3,0x3
ffffffffc0202a20:	56468693          	addi	a3,a3,1380 # ffffffffc0205f80 <default_pmm_manager+0x360>
ffffffffc0202a24:	00003617          	auipc	a2,0x3
ffffffffc0202a28:	e4c60613          	addi	a2,a2,-436 # ffffffffc0205870 <commands+0x738>
ffffffffc0202a2c:	1a100593          	li	a1,417
ffffffffc0202a30:	00003517          	auipc	a0,0x3
ffffffffc0202a34:	34050513          	addi	a0,a0,832 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202a38:	a07fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202a3c:	00004697          	auipc	a3,0x4
ffffffffc0202a40:	82468693          	addi	a3,a3,-2012 # ffffffffc0206260 <default_pmm_manager+0x640>
ffffffffc0202a44:	00003617          	auipc	a2,0x3
ffffffffc0202a48:	e2c60613          	addi	a2,a2,-468 # ffffffffc0205870 <commands+0x738>
ffffffffc0202a4c:	1e100593          	li	a1,481
ffffffffc0202a50:	00003517          	auipc	a0,0x3
ffffffffc0202a54:	32050513          	addi	a0,a0,800 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202a58:	9e7fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202a5c:	00003697          	auipc	a3,0x3
ffffffffc0202a60:	7cc68693          	addi	a3,a3,1996 # ffffffffc0206228 <default_pmm_manager+0x608>
ffffffffc0202a64:	00003617          	auipc	a2,0x3
ffffffffc0202a68:	e0c60613          	addi	a2,a2,-500 # ffffffffc0205870 <commands+0x738>
ffffffffc0202a6c:	1de00593          	li	a1,478
ffffffffc0202a70:	00003517          	auipc	a0,0x3
ffffffffc0202a74:	30050513          	addi	a0,a0,768 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202a78:	9c7fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202a7c:	00003697          	auipc	a3,0x3
ffffffffc0202a80:	77c68693          	addi	a3,a3,1916 # ffffffffc02061f8 <default_pmm_manager+0x5d8>
ffffffffc0202a84:	00003617          	auipc	a2,0x3
ffffffffc0202a88:	dec60613          	addi	a2,a2,-532 # ffffffffc0205870 <commands+0x738>
ffffffffc0202a8c:	1da00593          	li	a1,474
ffffffffc0202a90:	00003517          	auipc	a0,0x3
ffffffffc0202a94:	2e050513          	addi	a0,a0,736 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202a98:	9a7fd0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0202a9c <tlb_invalidate>:
ffffffffc0202a9c:	12058073          	sfence.vma	a1
ffffffffc0202aa0:	8082                	ret

ffffffffc0202aa2 <pgdir_alloc_page>:
ffffffffc0202aa2:	7179                	addi	sp,sp,-48
ffffffffc0202aa4:	e84a                	sd	s2,16(sp)
ffffffffc0202aa6:	892a                	mv	s2,a0
ffffffffc0202aa8:	4505                	li	a0,1
ffffffffc0202aaa:	ec26                	sd	s1,24(sp)
ffffffffc0202aac:	e44e                	sd	s3,8(sp)
ffffffffc0202aae:	f406                	sd	ra,40(sp)
ffffffffc0202ab0:	f022                	sd	s0,32(sp)
ffffffffc0202ab2:	84ae                	mv	s1,a1
ffffffffc0202ab4:	89b2                	mv	s3,a2
ffffffffc0202ab6:	f8bfe0ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0202aba:	c131                	beqz	a0,ffffffffc0202afe <pgdir_alloc_page+0x5c>
ffffffffc0202abc:	842a                	mv	s0,a0
ffffffffc0202abe:	85aa                	mv	a1,a0
ffffffffc0202ac0:	86ce                	mv	a3,s3
ffffffffc0202ac2:	8626                	mv	a2,s1
ffffffffc0202ac4:	854a                	mv	a0,s2
ffffffffc0202ac6:	b44ff0ef          	jal	ra,ffffffffc0201e0a <page_insert>
ffffffffc0202aca:	ed11                	bnez	a0,ffffffffc0202ae6 <pgdir_alloc_page+0x44>
ffffffffc0202acc:	00013797          	auipc	a5,0x13
ffffffffc0202ad0:	ac47a783          	lw	a5,-1340(a5) # ffffffffc0215590 <swap_init_ok>
ffffffffc0202ad4:	e79d                	bnez	a5,ffffffffc0202b02 <pgdir_alloc_page+0x60>
ffffffffc0202ad6:	70a2                	ld	ra,40(sp)
ffffffffc0202ad8:	8522                	mv	a0,s0
ffffffffc0202ada:	7402                	ld	s0,32(sp)
ffffffffc0202adc:	64e2                	ld	s1,24(sp)
ffffffffc0202ade:	6942                	ld	s2,16(sp)
ffffffffc0202ae0:	69a2                	ld	s3,8(sp)
ffffffffc0202ae2:	6145                	addi	sp,sp,48
ffffffffc0202ae4:	8082                	ret
ffffffffc0202ae6:	100027f3          	csrr	a5,sstatus
ffffffffc0202aea:	8b89                	andi	a5,a5,2
ffffffffc0202aec:	eba9                	bnez	a5,ffffffffc0202b3e <pgdir_alloc_page+0x9c>
ffffffffc0202aee:	00013797          	auipc	a5,0x13
ffffffffc0202af2:	a727b783          	ld	a5,-1422(a5) # ffffffffc0215560 <pmm_manager>
ffffffffc0202af6:	739c                	ld	a5,32(a5)
ffffffffc0202af8:	4585                	li	a1,1
ffffffffc0202afa:	8522                	mv	a0,s0
ffffffffc0202afc:	9782                	jalr	a5
ffffffffc0202afe:	4401                	li	s0,0
ffffffffc0202b00:	bfd9                	j	ffffffffc0202ad6 <pgdir_alloc_page+0x34>
ffffffffc0202b02:	4681                	li	a3,0
ffffffffc0202b04:	8622                	mv	a2,s0
ffffffffc0202b06:	85a6                	mv	a1,s1
ffffffffc0202b08:	00013517          	auipc	a0,0x13
ffffffffc0202b0c:	aa853503          	ld	a0,-1368(a0) # ffffffffc02155b0 <check_mm_struct>
ffffffffc0202b10:	7aa000ef          	jal	ra,ffffffffc02032ba <swap_map_swappable>
ffffffffc0202b14:	4018                	lw	a4,0(s0)
ffffffffc0202b16:	fc04                	sd	s1,56(s0)
ffffffffc0202b18:	4785                	li	a5,1
ffffffffc0202b1a:	faf70ee3          	beq	a4,a5,ffffffffc0202ad6 <pgdir_alloc_page+0x34>
ffffffffc0202b1e:	00003697          	auipc	a3,0x3
ffffffffc0202b22:	78a68693          	addi	a3,a3,1930 # ffffffffc02062a8 <default_pmm_manager+0x688>
ffffffffc0202b26:	00003617          	auipc	a2,0x3
ffffffffc0202b2a:	d4a60613          	addi	a2,a2,-694 # ffffffffc0205870 <commands+0x738>
ffffffffc0202b2e:	16800593          	li	a1,360
ffffffffc0202b32:	00003517          	auipc	a0,0x3
ffffffffc0202b36:	23e50513          	addi	a0,a0,574 # ffffffffc0205d70 <default_pmm_manager+0x150>
ffffffffc0202b3a:	905fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202b3e:	a7dfd0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0202b42:	00013797          	auipc	a5,0x13
ffffffffc0202b46:	a1e7b783          	ld	a5,-1506(a5) # ffffffffc0215560 <pmm_manager>
ffffffffc0202b4a:	739c                	ld	a5,32(a5)
ffffffffc0202b4c:	8522                	mv	a0,s0
ffffffffc0202b4e:	4585                	li	a1,1
ffffffffc0202b50:	9782                	jalr	a5
ffffffffc0202b52:	4401                	li	s0,0
ffffffffc0202b54:	a61fd0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0202b58:	bfbd                	j	ffffffffc0202ad6 <pgdir_alloc_page+0x34>

ffffffffc0202b5a <pa2page.part.0>:
ffffffffc0202b5a:	1141                	addi	sp,sp,-16
ffffffffc0202b5c:	00003617          	auipc	a2,0x3
ffffffffc0202b60:	1cc60613          	addi	a2,a2,460 # ffffffffc0205d28 <default_pmm_manager+0x108>
ffffffffc0202b64:	08000593          	li	a1,128
ffffffffc0202b68:	00003517          	auipc	a0,0x3
ffffffffc0202b6c:	11850513          	addi	a0,a0,280 # ffffffffc0205c80 <default_pmm_manager+0x60>
ffffffffc0202b70:	e406                	sd	ra,8(sp)
ffffffffc0202b72:	8cdfd0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0202b76 <swap_init>:
ffffffffc0202b76:	7135                	addi	sp,sp,-160
ffffffffc0202b78:	ed06                	sd	ra,152(sp)
ffffffffc0202b7a:	e922                	sd	s0,144(sp)
ffffffffc0202b7c:	e526                	sd	s1,136(sp)
ffffffffc0202b7e:	e14a                	sd	s2,128(sp)
ffffffffc0202b80:	fcce                	sd	s3,120(sp)
ffffffffc0202b82:	f8d2                	sd	s4,112(sp)
ffffffffc0202b84:	f4d6                	sd	s5,104(sp)
ffffffffc0202b86:	f0da                	sd	s6,96(sp)
ffffffffc0202b88:	ecde                	sd	s7,88(sp)
ffffffffc0202b8a:	e8e2                	sd	s8,80(sp)
ffffffffc0202b8c:	e4e6                	sd	s9,72(sp)
ffffffffc0202b8e:	e0ea                	sd	s10,64(sp)
ffffffffc0202b90:	fc6e                	sd	s11,56(sp)
ffffffffc0202b92:	57a010ef          	jal	ra,ffffffffc020410c <swapfs_init>
ffffffffc0202b96:	00013697          	auipc	a3,0x13
ffffffffc0202b9a:	a026b683          	ld	a3,-1534(a3) # ffffffffc0215598 <max_swap_offset>
ffffffffc0202b9e:	010007b7          	lui	a5,0x1000
ffffffffc0202ba2:	ff968713          	addi	a4,a3,-7
ffffffffc0202ba6:	17e1                	addi	a5,a5,-8
ffffffffc0202ba8:	40e7ef63          	bltu	a5,a4,ffffffffc0202fc6 <swap_init+0x450>
ffffffffc0202bac:	00007797          	auipc	a5,0x7
ffffffffc0202bb0:	46478793          	addi	a5,a5,1124 # ffffffffc020a010 <swap_manager_fifo>
ffffffffc0202bb4:	6798                	ld	a4,8(a5)
ffffffffc0202bb6:	00013b17          	auipc	s6,0x13
ffffffffc0202bba:	9eab0b13          	addi	s6,s6,-1558 # ffffffffc02155a0 <sm>
ffffffffc0202bbe:	00fb3023          	sd	a5,0(s6)
ffffffffc0202bc2:	9702                	jalr	a4
ffffffffc0202bc4:	892a                	mv	s2,a0
ffffffffc0202bc6:	c10d                	beqz	a0,ffffffffc0202be8 <swap_init+0x72>
ffffffffc0202bc8:	60ea                	ld	ra,152(sp)
ffffffffc0202bca:	644a                	ld	s0,144(sp)
ffffffffc0202bcc:	64aa                	ld	s1,136(sp)
ffffffffc0202bce:	79e6                	ld	s3,120(sp)
ffffffffc0202bd0:	7a46                	ld	s4,112(sp)
ffffffffc0202bd2:	7aa6                	ld	s5,104(sp)
ffffffffc0202bd4:	7b06                	ld	s6,96(sp)
ffffffffc0202bd6:	6be6                	ld	s7,88(sp)
ffffffffc0202bd8:	6c46                	ld	s8,80(sp)
ffffffffc0202bda:	6ca6                	ld	s9,72(sp)
ffffffffc0202bdc:	6d06                	ld	s10,64(sp)
ffffffffc0202bde:	7de2                	ld	s11,56(sp)
ffffffffc0202be0:	854a                	mv	a0,s2
ffffffffc0202be2:	690a                	ld	s2,128(sp)
ffffffffc0202be4:	610d                	addi	sp,sp,160
ffffffffc0202be6:	8082                	ret
ffffffffc0202be8:	000b3783          	ld	a5,0(s6)
ffffffffc0202bec:	00003517          	auipc	a0,0x3
ffffffffc0202bf0:	70450513          	addi	a0,a0,1796 # ffffffffc02062f0 <default_pmm_manager+0x6d0>
ffffffffc0202bf4:	0000f417          	auipc	s0,0xf
ffffffffc0202bf8:	86c40413          	addi	s0,s0,-1940 # ffffffffc0211460 <free_area>
ffffffffc0202bfc:	638c                	ld	a1,0(a5)
ffffffffc0202bfe:	4785                	li	a5,1
ffffffffc0202c00:	00013717          	auipc	a4,0x13
ffffffffc0202c04:	98f72823          	sw	a5,-1648(a4) # ffffffffc0215590 <swap_init_ok>
ffffffffc0202c08:	d82fd0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0202c0c:	641c                	ld	a5,8(s0)
ffffffffc0202c0e:	4d81                	li	s11,0
ffffffffc0202c10:	4d01                	li	s10,0
ffffffffc0202c12:	32878a63          	beq	a5,s0,ffffffffc0202f46 <swap_init+0x3d0>
ffffffffc0202c16:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202c1a:	8b09                	andi	a4,a4,2
ffffffffc0202c1c:	32070763          	beqz	a4,ffffffffc0202f4a <swap_init+0x3d4>
ffffffffc0202c20:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202c24:	679c                	ld	a5,8(a5)
ffffffffc0202c26:	2d05                	addiw	s10,s10,1
ffffffffc0202c28:	01b70dbb          	addw	s11,a4,s11
ffffffffc0202c2c:	fe8795e3          	bne	a5,s0,ffffffffc0202c16 <swap_init+0xa0>
ffffffffc0202c30:	84ee                	mv	s1,s11
ffffffffc0202c32:	edffe0ef          	jal	ra,ffffffffc0201b10 <nr_free_pages>
ffffffffc0202c36:	42951063          	bne	a0,s1,ffffffffc0203056 <swap_init+0x4e0>
ffffffffc0202c3a:	866e                	mv	a2,s11
ffffffffc0202c3c:	85ea                	mv	a1,s10
ffffffffc0202c3e:	00003517          	auipc	a0,0x3
ffffffffc0202c42:	6ca50513          	addi	a0,a0,1738 # ffffffffc0206308 <default_pmm_manager+0x6e8>
ffffffffc0202c46:	d44fd0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0202c4a:	411000ef          	jal	ra,ffffffffc020385a <mm_create>
ffffffffc0202c4e:	e82a                	sd	a0,16(sp)
ffffffffc0202c50:	46050363          	beqz	a0,ffffffffc02030b6 <swap_init+0x540>
ffffffffc0202c54:	00013797          	auipc	a5,0x13
ffffffffc0202c58:	95c78793          	addi	a5,a5,-1700 # ffffffffc02155b0 <check_mm_struct>
ffffffffc0202c5c:	6398                	ld	a4,0(a5)
ffffffffc0202c5e:	3c071c63          	bnez	a4,ffffffffc0203036 <swap_init+0x4c0>
ffffffffc0202c62:	00013717          	auipc	a4,0x13
ffffffffc0202c66:	90e70713          	addi	a4,a4,-1778 # ffffffffc0215570 <boot_pgdir>
ffffffffc0202c6a:	00073a83          	ld	s5,0(a4)
ffffffffc0202c6e:	6742                	ld	a4,16(sp)
ffffffffc0202c70:	e398                	sd	a4,0(a5)
ffffffffc0202c72:	000ab783          	ld	a5,0(s5) # fffffffffffff000 <end+0x3fde9a28>
ffffffffc0202c76:	01573c23          	sd	s5,24(a4)
ffffffffc0202c7a:	40079e63          	bnez	a5,ffffffffc0203096 <swap_init+0x520>
ffffffffc0202c7e:	6599                	lui	a1,0x6
ffffffffc0202c80:	460d                	li	a2,3
ffffffffc0202c82:	6505                	lui	a0,0x1
ffffffffc0202c84:	41f000ef          	jal	ra,ffffffffc02038a2 <vma_create>
ffffffffc0202c88:	85aa                	mv	a1,a0
ffffffffc0202c8a:	52050263          	beqz	a0,ffffffffc02031ae <swap_init+0x638>
ffffffffc0202c8e:	64c2                	ld	s1,16(sp)
ffffffffc0202c90:	8526                	mv	a0,s1
ffffffffc0202c92:	47f000ef          	jal	ra,ffffffffc0203910 <insert_vma_struct>
ffffffffc0202c96:	00003517          	auipc	a0,0x3
ffffffffc0202c9a:	6e250513          	addi	a0,a0,1762 # ffffffffc0206378 <default_pmm_manager+0x758>
ffffffffc0202c9e:	cecfd0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0202ca2:	6c88                	ld	a0,24(s1)
ffffffffc0202ca4:	4605                	li	a2,1
ffffffffc0202ca6:	6585                	lui	a1,0x1
ffffffffc0202ca8:	ea3fe0ef          	jal	ra,ffffffffc0201b4a <get_pte>
ffffffffc0202cac:	4c050163          	beqz	a0,ffffffffc020316e <swap_init+0x5f8>
ffffffffc0202cb0:	00003517          	auipc	a0,0x3
ffffffffc0202cb4:	71850513          	addi	a0,a0,1816 # ffffffffc02063c8 <default_pmm_manager+0x7a8>
ffffffffc0202cb8:	0000e497          	auipc	s1,0xe
ffffffffc0202cbc:	7e048493          	addi	s1,s1,2016 # ffffffffc0211498 <check_rp>
ffffffffc0202cc0:	ccafd0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0202cc4:	0000e997          	auipc	s3,0xe
ffffffffc0202cc8:	7f498993          	addi	s3,s3,2036 # ffffffffc02114b8 <swap_out_seq_no>
ffffffffc0202ccc:	8ba6                	mv	s7,s1
ffffffffc0202cce:	4505                	li	a0,1
ffffffffc0202cd0:	d71fe0ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc0202cd4:	00abb023          	sd	a0,0(s7)
ffffffffc0202cd8:	2c050763          	beqz	a0,ffffffffc0202fa6 <swap_init+0x430>
ffffffffc0202cdc:	651c                	ld	a5,8(a0)
ffffffffc0202cde:	8b89                	andi	a5,a5,2
ffffffffc0202ce0:	32079b63          	bnez	a5,ffffffffc0203016 <swap_init+0x4a0>
ffffffffc0202ce4:	0ba1                	addi	s7,s7,8
ffffffffc0202ce6:	ff3b94e3          	bne	s7,s3,ffffffffc0202cce <swap_init+0x158>
ffffffffc0202cea:	601c                	ld	a5,0(s0)
ffffffffc0202cec:	0000eb97          	auipc	s7,0xe
ffffffffc0202cf0:	7acb8b93          	addi	s7,s7,1964 # ffffffffc0211498 <check_rp>
ffffffffc0202cf4:	e000                	sd	s0,0(s0)
ffffffffc0202cf6:	f43e                	sd	a5,40(sp)
ffffffffc0202cf8:	641c                	ld	a5,8(s0)
ffffffffc0202cfa:	e400                	sd	s0,8(s0)
ffffffffc0202cfc:	f03e                	sd	a5,32(sp)
ffffffffc0202cfe:	481c                	lw	a5,16(s0)
ffffffffc0202d00:	ec3e                	sd	a5,24(sp)
ffffffffc0202d02:	0000e797          	auipc	a5,0xe
ffffffffc0202d06:	7607a723          	sw	zero,1902(a5) # ffffffffc0211470 <free_area+0x10>
ffffffffc0202d0a:	000bb503          	ld	a0,0(s7)
ffffffffc0202d0e:	4585                	li	a1,1
ffffffffc0202d10:	0ba1                	addi	s7,s7,8
ffffffffc0202d12:	dbffe0ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0202d16:	ff3b9ae3          	bne	s7,s3,ffffffffc0202d0a <swap_init+0x194>
ffffffffc0202d1a:	01042b83          	lw	s7,16(s0)
ffffffffc0202d1e:	4791                	li	a5,4
ffffffffc0202d20:	42fb9763          	bne	s7,a5,ffffffffc020314e <swap_init+0x5d8>
ffffffffc0202d24:	00003517          	auipc	a0,0x3
ffffffffc0202d28:	72c50513          	addi	a0,a0,1836 # ffffffffc0206450 <default_pmm_manager+0x830>
ffffffffc0202d2c:	c5efd0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0202d30:	6685                	lui	a3,0x1
ffffffffc0202d32:	00013797          	auipc	a5,0x13
ffffffffc0202d36:	8607ab23          	sw	zero,-1930(a5) # ffffffffc02155a8 <pgfault_num>
ffffffffc0202d3a:	4629                	li	a2,10
ffffffffc0202d3c:	00c68023          	sb	a2,0(a3) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0202d40:	00013717          	auipc	a4,0x13
ffffffffc0202d44:	86872703          	lw	a4,-1944(a4) # ffffffffc02155a8 <pgfault_num>
ffffffffc0202d48:	4585                	li	a1,1
ffffffffc0202d4a:	00013797          	auipc	a5,0x13
ffffffffc0202d4e:	85e78793          	addi	a5,a5,-1954 # ffffffffc02155a8 <pgfault_num>
ffffffffc0202d52:	52b71e63          	bne	a4,a1,ffffffffc020328e <swap_init+0x718>
ffffffffc0202d56:	00c68823          	sb	a2,16(a3)
ffffffffc0202d5a:	4394                	lw	a3,0(a5)
ffffffffc0202d5c:	3ce69963          	bne	a3,a4,ffffffffc020312e <swap_init+0x5b8>
ffffffffc0202d60:	6709                	lui	a4,0x2
ffffffffc0202d62:	46ad                	li	a3,11
ffffffffc0202d64:	00d70023          	sb	a3,0(a4) # 2000 <kern_entry-0xffffffffc01fe000>
ffffffffc0202d68:	4390                	lw	a2,0(a5)
ffffffffc0202d6a:	4509                	li	a0,2
ffffffffc0202d6c:	0006059b          	sext.w	a1,a2
ffffffffc0202d70:	48a61f63          	bne	a2,a0,ffffffffc020320e <swap_init+0x698>
ffffffffc0202d74:	00d70823          	sb	a3,16(a4)
ffffffffc0202d78:	4398                	lw	a4,0(a5)
ffffffffc0202d7a:	4ab71a63          	bne	a4,a1,ffffffffc020322e <swap_init+0x6b8>
ffffffffc0202d7e:	670d                	lui	a4,0x3
ffffffffc0202d80:	46b1                	li	a3,12
ffffffffc0202d82:	00d70023          	sb	a3,0(a4) # 3000 <kern_entry-0xffffffffc01fd000>
ffffffffc0202d86:	4390                	lw	a2,0(a5)
ffffffffc0202d88:	450d                	li	a0,3
ffffffffc0202d8a:	0006059b          	sext.w	a1,a2
ffffffffc0202d8e:	4ca61063          	bne	a2,a0,ffffffffc020324e <swap_init+0x6d8>
ffffffffc0202d92:	00d70823          	sb	a3,16(a4)
ffffffffc0202d96:	4398                	lw	a4,0(a5)
ffffffffc0202d98:	4cb71b63          	bne	a4,a1,ffffffffc020326e <swap_init+0x6f8>
ffffffffc0202d9c:	6711                	lui	a4,0x4
ffffffffc0202d9e:	46b5                	li	a3,13
ffffffffc0202da0:	00d70023          	sb	a3,0(a4) # 4000 <kern_entry-0xffffffffc01fc000>
ffffffffc0202da4:	4390                	lw	a2,0(a5)
ffffffffc0202da6:	0006059b          	sext.w	a1,a2
ffffffffc0202daa:	43761263          	bne	a2,s7,ffffffffc02031ce <swap_init+0x658>
ffffffffc0202dae:	00d70823          	sb	a3,16(a4)
ffffffffc0202db2:	439c                	lw	a5,0(a5)
ffffffffc0202db4:	42b79d63          	bne	a5,a1,ffffffffc02031ee <swap_init+0x678>
ffffffffc0202db8:	481c                	lw	a5,16(s0)
ffffffffc0202dba:	2a079e63          	bnez	a5,ffffffffc0203076 <swap_init+0x500>
ffffffffc0202dbe:	0000e797          	auipc	a5,0xe
ffffffffc0202dc2:	72278793          	addi	a5,a5,1826 # ffffffffc02114e0 <swap_in_seq_no>
ffffffffc0202dc6:	0000e717          	auipc	a4,0xe
ffffffffc0202dca:	6f270713          	addi	a4,a4,1778 # ffffffffc02114b8 <swap_out_seq_no>
ffffffffc0202dce:	0000e617          	auipc	a2,0xe
ffffffffc0202dd2:	73a60613          	addi	a2,a2,1850 # ffffffffc0211508 <pra_list_head>
ffffffffc0202dd6:	56fd                	li	a3,-1
ffffffffc0202dd8:	c394                	sw	a3,0(a5)
ffffffffc0202dda:	c314                	sw	a3,0(a4)
ffffffffc0202ddc:	0791                	addi	a5,a5,4
ffffffffc0202dde:	0711                	addi	a4,a4,4
ffffffffc0202de0:	fec79ce3          	bne	a5,a2,ffffffffc0202dd8 <swap_init+0x262>
ffffffffc0202de4:	0000e717          	auipc	a4,0xe
ffffffffc0202de8:	69470713          	addi	a4,a4,1684 # ffffffffc0211478 <check_ptep>
ffffffffc0202dec:	0000e697          	auipc	a3,0xe
ffffffffc0202df0:	6ac68693          	addi	a3,a3,1708 # ffffffffc0211498 <check_rp>
ffffffffc0202df4:	6a05                	lui	s4,0x1
ffffffffc0202df6:	00012b97          	auipc	s7,0x12
ffffffffc0202dfa:	78ab8b93          	addi	s7,s7,1930 # ffffffffc0215580 <npage>
ffffffffc0202dfe:	00012c17          	auipc	s8,0x12
ffffffffc0202e02:	78ac0c13          	addi	s8,s8,1930 # ffffffffc0215588 <pages>
ffffffffc0202e06:	00004c97          	auipc	s9,0x4
ffffffffc0202e0a:	1f2c8c93          	addi	s9,s9,498 # ffffffffc0206ff8 <nbase>
ffffffffc0202e0e:	00073023          	sd	zero,0(a4)
ffffffffc0202e12:	4601                	li	a2,0
ffffffffc0202e14:	85d2                	mv	a1,s4
ffffffffc0202e16:	8556                	mv	a0,s5
ffffffffc0202e18:	e436                	sd	a3,8(sp)
ffffffffc0202e1a:	e03a                	sd	a4,0(sp)
ffffffffc0202e1c:	d2ffe0ef          	jal	ra,ffffffffc0201b4a <get_pte>
ffffffffc0202e20:	6702                	ld	a4,0(sp)
ffffffffc0202e22:	66a2                	ld	a3,8(sp)
ffffffffc0202e24:	e308                	sd	a0,0(a4)
ffffffffc0202e26:	1a050c63          	beqz	a0,ffffffffc0202fde <swap_init+0x468>
ffffffffc0202e2a:	611c                	ld	a5,0(a0)
ffffffffc0202e2c:	0017f613          	andi	a2,a5,1
ffffffffc0202e30:	1c060763          	beqz	a2,ffffffffc0202ffe <swap_init+0x488>
ffffffffc0202e34:	000bb603          	ld	a2,0(s7)
ffffffffc0202e38:	078a                	slli	a5,a5,0x2
ffffffffc0202e3a:	83b1                	srli	a5,a5,0xc
ffffffffc0202e3c:	12c7f963          	bgeu	a5,a2,ffffffffc0202f6e <swap_init+0x3f8>
ffffffffc0202e40:	000cb303          	ld	t1,0(s9)
ffffffffc0202e44:	000c3603          	ld	a2,0(s8)
ffffffffc0202e48:	6288                	ld	a0,0(a3)
ffffffffc0202e4a:	406787b3          	sub	a5,a5,t1
ffffffffc0202e4e:	079a                	slli	a5,a5,0x6
ffffffffc0202e50:	97b2                	add	a5,a5,a2
ffffffffc0202e52:	6605                	lui	a2,0x1
ffffffffc0202e54:	06a1                	addi	a3,a3,8
ffffffffc0202e56:	0721                	addi	a4,a4,8
ffffffffc0202e58:	9a32                	add	s4,s4,a2
ffffffffc0202e5a:	12f51663          	bne	a0,a5,ffffffffc0202f86 <swap_init+0x410>
ffffffffc0202e5e:	6795                	lui	a5,0x5
ffffffffc0202e60:	fafa17e3          	bne	s4,a5,ffffffffc0202e0e <swap_init+0x298>
ffffffffc0202e64:	00003517          	auipc	a0,0x3
ffffffffc0202e68:	69450513          	addi	a0,a0,1684 # ffffffffc02064f8 <default_pmm_manager+0x8d8>
ffffffffc0202e6c:	b1efd0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0202e70:	000b3783          	ld	a5,0(s6)
ffffffffc0202e74:	7f9c                	ld	a5,56(a5)
ffffffffc0202e76:	9782                	jalr	a5
ffffffffc0202e78:	30051b63          	bnez	a0,ffffffffc020318e <swap_init+0x618>
ffffffffc0202e7c:	67e2                	ld	a5,24(sp)
ffffffffc0202e7e:	c81c                	sw	a5,16(s0)
ffffffffc0202e80:	77a2                	ld	a5,40(sp)
ffffffffc0202e82:	e01c                	sd	a5,0(s0)
ffffffffc0202e84:	7782                	ld	a5,32(sp)
ffffffffc0202e86:	e41c                	sd	a5,8(s0)
ffffffffc0202e88:	6088                	ld	a0,0(s1)
ffffffffc0202e8a:	4585                	li	a1,1
ffffffffc0202e8c:	04a1                	addi	s1,s1,8
ffffffffc0202e8e:	c43fe0ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0202e92:	ff349be3          	bne	s1,s3,ffffffffc0202e88 <swap_init+0x312>
ffffffffc0202e96:	6542                	ld	a0,16(sp)
ffffffffc0202e98:	349000ef          	jal	ra,ffffffffc02039e0 <mm_destroy>
ffffffffc0202e9c:	00012797          	auipc	a5,0x12
ffffffffc0202ea0:	6d478793          	addi	a5,a5,1748 # ffffffffc0215570 <boot_pgdir>
ffffffffc0202ea4:	639c                	ld	a5,0(a5)
ffffffffc0202ea6:	000bb703          	ld	a4,0(s7)
ffffffffc0202eaa:	639c                	ld	a5,0(a5)
ffffffffc0202eac:	078a                	slli	a5,a5,0x2
ffffffffc0202eae:	83b1                	srli	a5,a5,0xc
ffffffffc0202eb0:	0ae7fd63          	bgeu	a5,a4,ffffffffc0202f6a <swap_init+0x3f4>
ffffffffc0202eb4:	000cb483          	ld	s1,0(s9)
ffffffffc0202eb8:	000c3503          	ld	a0,0(s8)
ffffffffc0202ebc:	409786b3          	sub	a3,a5,s1
ffffffffc0202ec0:	069a                	slli	a3,a3,0x6
ffffffffc0202ec2:	8699                	srai	a3,a3,0x6
ffffffffc0202ec4:	96a6                	add	a3,a3,s1
ffffffffc0202ec6:	00c69793          	slli	a5,a3,0xc
ffffffffc0202eca:	83b1                	srli	a5,a5,0xc
ffffffffc0202ecc:	06b2                	slli	a3,a3,0xc
ffffffffc0202ece:	22e7f463          	bgeu	a5,a4,ffffffffc02030f6 <swap_init+0x580>
ffffffffc0202ed2:	00012797          	auipc	a5,0x12
ffffffffc0202ed6:	6a67b783          	ld	a5,1702(a5) # ffffffffc0215578 <va_pa_offset>
ffffffffc0202eda:	97b6                	add	a5,a5,a3
ffffffffc0202edc:	639c                	ld	a5,0(a5)
ffffffffc0202ede:	078a                	slli	a5,a5,0x2
ffffffffc0202ee0:	83b1                	srli	a5,a5,0xc
ffffffffc0202ee2:	08e7f463          	bgeu	a5,a4,ffffffffc0202f6a <swap_init+0x3f4>
ffffffffc0202ee6:	8f85                	sub	a5,a5,s1
ffffffffc0202ee8:	079a                	slli	a5,a5,0x6
ffffffffc0202eea:	953e                	add	a0,a0,a5
ffffffffc0202eec:	4585                	li	a1,1
ffffffffc0202eee:	be3fe0ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0202ef2:	000ab783          	ld	a5,0(s5)
ffffffffc0202ef6:	000bb703          	ld	a4,0(s7)
ffffffffc0202efa:	078a                	slli	a5,a5,0x2
ffffffffc0202efc:	83b1                	srli	a5,a5,0xc
ffffffffc0202efe:	06e7f663          	bgeu	a5,a4,ffffffffc0202f6a <swap_init+0x3f4>
ffffffffc0202f02:	000c3503          	ld	a0,0(s8)
ffffffffc0202f06:	8f85                	sub	a5,a5,s1
ffffffffc0202f08:	079a                	slli	a5,a5,0x6
ffffffffc0202f0a:	4585                	li	a1,1
ffffffffc0202f0c:	953e                	add	a0,a0,a5
ffffffffc0202f0e:	bc3fe0ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0202f12:	000ab023          	sd	zero,0(s5)
ffffffffc0202f16:	12000073          	sfence.vma
ffffffffc0202f1a:	641c                	ld	a5,8(s0)
ffffffffc0202f1c:	00878a63          	beq	a5,s0,ffffffffc0202f30 <swap_init+0x3ba>
ffffffffc0202f20:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202f24:	679c                	ld	a5,8(a5)
ffffffffc0202f26:	3d7d                	addiw	s10,s10,-1
ffffffffc0202f28:	40ed8dbb          	subw	s11,s11,a4
ffffffffc0202f2c:	fe879ae3          	bne	a5,s0,ffffffffc0202f20 <swap_init+0x3aa>
ffffffffc0202f30:	1c0d1f63          	bnez	s10,ffffffffc020310e <swap_init+0x598>
ffffffffc0202f34:	1a0d9163          	bnez	s11,ffffffffc02030d6 <swap_init+0x560>
ffffffffc0202f38:	00003517          	auipc	a0,0x3
ffffffffc0202f3c:	61050513          	addi	a0,a0,1552 # ffffffffc0206548 <default_pmm_manager+0x928>
ffffffffc0202f40:	a4afd0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0202f44:	b151                	j	ffffffffc0202bc8 <swap_init+0x52>
ffffffffc0202f46:	4481                	li	s1,0
ffffffffc0202f48:	b1ed                	j	ffffffffc0202c32 <swap_init+0xbc>
ffffffffc0202f4a:	00003697          	auipc	a3,0x3
ffffffffc0202f4e:	91668693          	addi	a3,a3,-1770 # ffffffffc0205860 <commands+0x728>
ffffffffc0202f52:	00003617          	auipc	a2,0x3
ffffffffc0202f56:	91e60613          	addi	a2,a2,-1762 # ffffffffc0205870 <commands+0x738>
ffffffffc0202f5a:	0cf00593          	li	a1,207
ffffffffc0202f5e:	00003517          	auipc	a0,0x3
ffffffffc0202f62:	38250513          	addi	a0,a0,898 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc0202f66:	cd8fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202f6a:	bf1ff0ef          	jal	ra,ffffffffc0202b5a <pa2page.part.0>
ffffffffc0202f6e:	00003617          	auipc	a2,0x3
ffffffffc0202f72:	dba60613          	addi	a2,a2,-582 # ffffffffc0205d28 <default_pmm_manager+0x108>
ffffffffc0202f76:	08000593          	li	a1,128
ffffffffc0202f7a:	00003517          	auipc	a0,0x3
ffffffffc0202f7e:	d0650513          	addi	a0,a0,-762 # ffffffffc0205c80 <default_pmm_manager+0x60>
ffffffffc0202f82:	cbcfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202f86:	00003697          	auipc	a3,0x3
ffffffffc0202f8a:	54a68693          	addi	a3,a3,1354 # ffffffffc02064d0 <default_pmm_manager+0x8b0>
ffffffffc0202f8e:	00003617          	auipc	a2,0x3
ffffffffc0202f92:	8e260613          	addi	a2,a2,-1822 # ffffffffc0205870 <commands+0x738>
ffffffffc0202f96:	11200593          	li	a1,274
ffffffffc0202f9a:	00003517          	auipc	a0,0x3
ffffffffc0202f9e:	34650513          	addi	a0,a0,838 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc0202fa2:	c9cfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202fa6:	00003697          	auipc	a3,0x3
ffffffffc0202faa:	44a68693          	addi	a3,a3,1098 # ffffffffc02063f0 <default_pmm_manager+0x7d0>
ffffffffc0202fae:	00003617          	auipc	a2,0x3
ffffffffc0202fb2:	8c260613          	addi	a2,a2,-1854 # ffffffffc0205870 <commands+0x738>
ffffffffc0202fb6:	0f100593          	li	a1,241
ffffffffc0202fba:	00003517          	auipc	a0,0x3
ffffffffc0202fbe:	32650513          	addi	a0,a0,806 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc0202fc2:	c7cfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202fc6:	00003617          	auipc	a2,0x3
ffffffffc0202fca:	2fa60613          	addi	a2,a2,762 # ffffffffc02062c0 <default_pmm_manager+0x6a0>
ffffffffc0202fce:	02c00593          	li	a1,44
ffffffffc0202fd2:	00003517          	auipc	a0,0x3
ffffffffc0202fd6:	30e50513          	addi	a0,a0,782 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc0202fda:	c64fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202fde:	00003697          	auipc	a3,0x3
ffffffffc0202fe2:	4da68693          	addi	a3,a3,1242 # ffffffffc02064b8 <default_pmm_manager+0x898>
ffffffffc0202fe6:	00003617          	auipc	a2,0x3
ffffffffc0202fea:	88a60613          	addi	a2,a2,-1910 # ffffffffc0205870 <commands+0x738>
ffffffffc0202fee:	11100593          	li	a1,273
ffffffffc0202ff2:	00003517          	auipc	a0,0x3
ffffffffc0202ff6:	2ee50513          	addi	a0,a0,750 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc0202ffa:	c44fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202ffe:	00003617          	auipc	a2,0x3
ffffffffc0203002:	d4a60613          	addi	a2,a2,-694 # ffffffffc0205d48 <default_pmm_manager+0x128>
ffffffffc0203006:	09f00593          	li	a1,159
ffffffffc020300a:	00003517          	auipc	a0,0x3
ffffffffc020300e:	c7650513          	addi	a0,a0,-906 # ffffffffc0205c80 <default_pmm_manager+0x60>
ffffffffc0203012:	c2cfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203016:	00003697          	auipc	a3,0x3
ffffffffc020301a:	3f268693          	addi	a3,a3,1010 # ffffffffc0206408 <default_pmm_manager+0x7e8>
ffffffffc020301e:	00003617          	auipc	a2,0x3
ffffffffc0203022:	85260613          	addi	a2,a2,-1966 # ffffffffc0205870 <commands+0x738>
ffffffffc0203026:	0f200593          	li	a1,242
ffffffffc020302a:	00003517          	auipc	a0,0x3
ffffffffc020302e:	2b650513          	addi	a0,a0,694 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc0203032:	c0cfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203036:	00003697          	auipc	a3,0x3
ffffffffc020303a:	30a68693          	addi	a3,a3,778 # ffffffffc0206340 <default_pmm_manager+0x720>
ffffffffc020303e:	00003617          	auipc	a2,0x3
ffffffffc0203042:	83260613          	addi	a2,a2,-1998 # ffffffffc0205870 <commands+0x738>
ffffffffc0203046:	0da00593          	li	a1,218
ffffffffc020304a:	00003517          	auipc	a0,0x3
ffffffffc020304e:	29650513          	addi	a0,a0,662 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc0203052:	becfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203056:	00003697          	auipc	a3,0x3
ffffffffc020305a:	84a68693          	addi	a3,a3,-1974 # ffffffffc02058a0 <commands+0x768>
ffffffffc020305e:	00003617          	auipc	a2,0x3
ffffffffc0203062:	81260613          	addi	a2,a2,-2030 # ffffffffc0205870 <commands+0x738>
ffffffffc0203066:	0d200593          	li	a1,210
ffffffffc020306a:	00003517          	auipc	a0,0x3
ffffffffc020306e:	27650513          	addi	a0,a0,630 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc0203072:	bccfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203076:	00003697          	auipc	a3,0x3
ffffffffc020307a:	9d268693          	addi	a3,a3,-1582 # ffffffffc0205a48 <commands+0x910>
ffffffffc020307e:	00002617          	auipc	a2,0x2
ffffffffc0203082:	7f260613          	addi	a2,a2,2034 # ffffffffc0205870 <commands+0x738>
ffffffffc0203086:	10900593          	li	a1,265
ffffffffc020308a:	00003517          	auipc	a0,0x3
ffffffffc020308e:	25650513          	addi	a0,a0,598 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc0203092:	bacfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203096:	00003697          	auipc	a3,0x3
ffffffffc020309a:	2c268693          	addi	a3,a3,706 # ffffffffc0206358 <default_pmm_manager+0x738>
ffffffffc020309e:	00002617          	auipc	a2,0x2
ffffffffc02030a2:	7d260613          	addi	a2,a2,2002 # ffffffffc0205870 <commands+0x738>
ffffffffc02030a6:	0df00593          	li	a1,223
ffffffffc02030aa:	00003517          	auipc	a0,0x3
ffffffffc02030ae:	23650513          	addi	a0,a0,566 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc02030b2:	b8cfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02030b6:	00003697          	auipc	a3,0x3
ffffffffc02030ba:	27a68693          	addi	a3,a3,634 # ffffffffc0206330 <default_pmm_manager+0x710>
ffffffffc02030be:	00002617          	auipc	a2,0x2
ffffffffc02030c2:	7b260613          	addi	a2,a2,1970 # ffffffffc0205870 <commands+0x738>
ffffffffc02030c6:	0d700593          	li	a1,215
ffffffffc02030ca:	00003517          	auipc	a0,0x3
ffffffffc02030ce:	21650513          	addi	a0,a0,534 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc02030d2:	b6cfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02030d6:	00003697          	auipc	a3,0x3
ffffffffc02030da:	46268693          	addi	a3,a3,1122 # ffffffffc0206538 <default_pmm_manager+0x918>
ffffffffc02030de:	00002617          	auipc	a2,0x2
ffffffffc02030e2:	79260613          	addi	a2,a2,1938 # ffffffffc0205870 <commands+0x738>
ffffffffc02030e6:	13200593          	li	a1,306
ffffffffc02030ea:	00003517          	auipc	a0,0x3
ffffffffc02030ee:	1f650513          	addi	a0,a0,502 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc02030f2:	b4cfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02030f6:	00003617          	auipc	a2,0x3
ffffffffc02030fa:	b6260613          	addi	a2,a2,-1182 # ffffffffc0205c58 <default_pmm_manager+0x38>
ffffffffc02030fe:	08b00593          	li	a1,139
ffffffffc0203102:	00003517          	auipc	a0,0x3
ffffffffc0203106:	b7e50513          	addi	a0,a0,-1154 # ffffffffc0205c80 <default_pmm_manager+0x60>
ffffffffc020310a:	b34fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020310e:	00003697          	auipc	a3,0x3
ffffffffc0203112:	41a68693          	addi	a3,a3,1050 # ffffffffc0206528 <default_pmm_manager+0x908>
ffffffffc0203116:	00002617          	auipc	a2,0x2
ffffffffc020311a:	75a60613          	addi	a2,a2,1882 # ffffffffc0205870 <commands+0x738>
ffffffffc020311e:	13100593          	li	a1,305
ffffffffc0203122:	00003517          	auipc	a0,0x3
ffffffffc0203126:	1be50513          	addi	a0,a0,446 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc020312a:	b14fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020312e:	00003697          	auipc	a3,0x3
ffffffffc0203132:	34a68693          	addi	a3,a3,842 # ffffffffc0206478 <default_pmm_manager+0x858>
ffffffffc0203136:	00002617          	auipc	a2,0x2
ffffffffc020313a:	73a60613          	addi	a2,a2,1850 # ffffffffc0205870 <commands+0x738>
ffffffffc020313e:	0a300593          	li	a1,163
ffffffffc0203142:	00003517          	auipc	a0,0x3
ffffffffc0203146:	19e50513          	addi	a0,a0,414 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc020314a:	af4fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020314e:	00003697          	auipc	a3,0x3
ffffffffc0203152:	2da68693          	addi	a3,a3,730 # ffffffffc0206428 <default_pmm_manager+0x808>
ffffffffc0203156:	00002617          	auipc	a2,0x2
ffffffffc020315a:	71a60613          	addi	a2,a2,1818 # ffffffffc0205870 <commands+0x738>
ffffffffc020315e:	10000593          	li	a1,256
ffffffffc0203162:	00003517          	auipc	a0,0x3
ffffffffc0203166:	17e50513          	addi	a0,a0,382 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc020316a:	ad4fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020316e:	00003697          	auipc	a3,0x3
ffffffffc0203172:	24268693          	addi	a3,a3,578 # ffffffffc02063b0 <default_pmm_manager+0x790>
ffffffffc0203176:	00002617          	auipc	a2,0x2
ffffffffc020317a:	6fa60613          	addi	a2,a2,1786 # ffffffffc0205870 <commands+0x738>
ffffffffc020317e:	0eb00593          	li	a1,235
ffffffffc0203182:	00003517          	auipc	a0,0x3
ffffffffc0203186:	15e50513          	addi	a0,a0,350 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc020318a:	ab4fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020318e:	00003697          	auipc	a3,0x3
ffffffffc0203192:	39268693          	addi	a3,a3,914 # ffffffffc0206520 <default_pmm_manager+0x900>
ffffffffc0203196:	00002617          	auipc	a2,0x2
ffffffffc020319a:	6da60613          	addi	a2,a2,1754 # ffffffffc0205870 <commands+0x738>
ffffffffc020319e:	11800593          	li	a1,280
ffffffffc02031a2:	00003517          	auipc	a0,0x3
ffffffffc02031a6:	13e50513          	addi	a0,a0,318 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc02031aa:	a94fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02031ae:	00003697          	auipc	a3,0x3
ffffffffc02031b2:	1ba68693          	addi	a3,a3,442 # ffffffffc0206368 <default_pmm_manager+0x748>
ffffffffc02031b6:	00002617          	auipc	a2,0x2
ffffffffc02031ba:	6ba60613          	addi	a2,a2,1722 # ffffffffc0205870 <commands+0x738>
ffffffffc02031be:	0e300593          	li	a1,227
ffffffffc02031c2:	00003517          	auipc	a0,0x3
ffffffffc02031c6:	11e50513          	addi	a0,a0,286 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc02031ca:	a74fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02031ce:	00003697          	auipc	a3,0x3
ffffffffc02031d2:	2da68693          	addi	a3,a3,730 # ffffffffc02064a8 <default_pmm_manager+0x888>
ffffffffc02031d6:	00002617          	auipc	a2,0x2
ffffffffc02031da:	69a60613          	addi	a2,a2,1690 # ffffffffc0205870 <commands+0x738>
ffffffffc02031de:	0ad00593          	li	a1,173
ffffffffc02031e2:	00003517          	auipc	a0,0x3
ffffffffc02031e6:	0fe50513          	addi	a0,a0,254 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc02031ea:	a54fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02031ee:	00003697          	auipc	a3,0x3
ffffffffc02031f2:	2ba68693          	addi	a3,a3,698 # ffffffffc02064a8 <default_pmm_manager+0x888>
ffffffffc02031f6:	00002617          	auipc	a2,0x2
ffffffffc02031fa:	67a60613          	addi	a2,a2,1658 # ffffffffc0205870 <commands+0x738>
ffffffffc02031fe:	0af00593          	li	a1,175
ffffffffc0203202:	00003517          	auipc	a0,0x3
ffffffffc0203206:	0de50513          	addi	a0,a0,222 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc020320a:	a34fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020320e:	00003697          	auipc	a3,0x3
ffffffffc0203212:	27a68693          	addi	a3,a3,634 # ffffffffc0206488 <default_pmm_manager+0x868>
ffffffffc0203216:	00002617          	auipc	a2,0x2
ffffffffc020321a:	65a60613          	addi	a2,a2,1626 # ffffffffc0205870 <commands+0x738>
ffffffffc020321e:	0a500593          	li	a1,165
ffffffffc0203222:	00003517          	auipc	a0,0x3
ffffffffc0203226:	0be50513          	addi	a0,a0,190 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc020322a:	a14fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020322e:	00003697          	auipc	a3,0x3
ffffffffc0203232:	25a68693          	addi	a3,a3,602 # ffffffffc0206488 <default_pmm_manager+0x868>
ffffffffc0203236:	00002617          	auipc	a2,0x2
ffffffffc020323a:	63a60613          	addi	a2,a2,1594 # ffffffffc0205870 <commands+0x738>
ffffffffc020323e:	0a700593          	li	a1,167
ffffffffc0203242:	00003517          	auipc	a0,0x3
ffffffffc0203246:	09e50513          	addi	a0,a0,158 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc020324a:	9f4fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020324e:	00003697          	auipc	a3,0x3
ffffffffc0203252:	24a68693          	addi	a3,a3,586 # ffffffffc0206498 <default_pmm_manager+0x878>
ffffffffc0203256:	00002617          	auipc	a2,0x2
ffffffffc020325a:	61a60613          	addi	a2,a2,1562 # ffffffffc0205870 <commands+0x738>
ffffffffc020325e:	0a900593          	li	a1,169
ffffffffc0203262:	00003517          	auipc	a0,0x3
ffffffffc0203266:	07e50513          	addi	a0,a0,126 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc020326a:	9d4fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020326e:	00003697          	auipc	a3,0x3
ffffffffc0203272:	22a68693          	addi	a3,a3,554 # ffffffffc0206498 <default_pmm_manager+0x878>
ffffffffc0203276:	00002617          	auipc	a2,0x2
ffffffffc020327a:	5fa60613          	addi	a2,a2,1530 # ffffffffc0205870 <commands+0x738>
ffffffffc020327e:	0ab00593          	li	a1,171
ffffffffc0203282:	00003517          	auipc	a0,0x3
ffffffffc0203286:	05e50513          	addi	a0,a0,94 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc020328a:	9b4fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020328e:	00003697          	auipc	a3,0x3
ffffffffc0203292:	1ea68693          	addi	a3,a3,490 # ffffffffc0206478 <default_pmm_manager+0x858>
ffffffffc0203296:	00002617          	auipc	a2,0x2
ffffffffc020329a:	5da60613          	addi	a2,a2,1498 # ffffffffc0205870 <commands+0x738>
ffffffffc020329e:	0a100593          	li	a1,161
ffffffffc02032a2:	00003517          	auipc	a0,0x3
ffffffffc02032a6:	03e50513          	addi	a0,a0,62 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc02032aa:	994fd0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc02032ae <swap_init_mm>:
ffffffffc02032ae:	00012797          	auipc	a5,0x12
ffffffffc02032b2:	2f27b783          	ld	a5,754(a5) # ffffffffc02155a0 <sm>
ffffffffc02032b6:	6b9c                	ld	a5,16(a5)
ffffffffc02032b8:	8782                	jr	a5

ffffffffc02032ba <swap_map_swappable>:
ffffffffc02032ba:	00012797          	auipc	a5,0x12
ffffffffc02032be:	2e67b783          	ld	a5,742(a5) # ffffffffc02155a0 <sm>
ffffffffc02032c2:	739c                	ld	a5,32(a5)
ffffffffc02032c4:	8782                	jr	a5

ffffffffc02032c6 <swap_out>:
ffffffffc02032c6:	711d                	addi	sp,sp,-96
ffffffffc02032c8:	ec86                	sd	ra,88(sp)
ffffffffc02032ca:	e8a2                	sd	s0,80(sp)
ffffffffc02032cc:	e4a6                	sd	s1,72(sp)
ffffffffc02032ce:	e0ca                	sd	s2,64(sp)
ffffffffc02032d0:	fc4e                	sd	s3,56(sp)
ffffffffc02032d2:	f852                	sd	s4,48(sp)
ffffffffc02032d4:	f456                	sd	s5,40(sp)
ffffffffc02032d6:	f05a                	sd	s6,32(sp)
ffffffffc02032d8:	ec5e                	sd	s7,24(sp)
ffffffffc02032da:	e862                	sd	s8,16(sp)
ffffffffc02032dc:	cde9                	beqz	a1,ffffffffc02033b6 <swap_out+0xf0>
ffffffffc02032de:	8a2e                	mv	s4,a1
ffffffffc02032e0:	892a                	mv	s2,a0
ffffffffc02032e2:	8ab2                	mv	s5,a2
ffffffffc02032e4:	4401                	li	s0,0
ffffffffc02032e6:	00012997          	auipc	s3,0x12
ffffffffc02032ea:	2ba98993          	addi	s3,s3,698 # ffffffffc02155a0 <sm>
ffffffffc02032ee:	00003b17          	auipc	s6,0x3
ffffffffc02032f2:	2dab0b13          	addi	s6,s6,730 # ffffffffc02065c8 <default_pmm_manager+0x9a8>
ffffffffc02032f6:	00003b97          	auipc	s7,0x3
ffffffffc02032fa:	2bab8b93          	addi	s7,s7,698 # ffffffffc02065b0 <default_pmm_manager+0x990>
ffffffffc02032fe:	a825                	j	ffffffffc0203336 <swap_out+0x70>
ffffffffc0203300:	67a2                	ld	a5,8(sp)
ffffffffc0203302:	8626                	mv	a2,s1
ffffffffc0203304:	85a2                	mv	a1,s0
ffffffffc0203306:	7f94                	ld	a3,56(a5)
ffffffffc0203308:	855a                	mv	a0,s6
ffffffffc020330a:	2405                	addiw	s0,s0,1
ffffffffc020330c:	82b1                	srli	a3,a3,0xc
ffffffffc020330e:	0685                	addi	a3,a3,1
ffffffffc0203310:	e7bfc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0203314:	6522                	ld	a0,8(sp)
ffffffffc0203316:	4585                	li	a1,1
ffffffffc0203318:	7d1c                	ld	a5,56(a0)
ffffffffc020331a:	83b1                	srli	a5,a5,0xc
ffffffffc020331c:	0785                	addi	a5,a5,1
ffffffffc020331e:	07a2                	slli	a5,a5,0x8
ffffffffc0203320:	00fc3023          	sd	a5,0(s8)
ffffffffc0203324:	facfe0ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0203328:	01893503          	ld	a0,24(s2)
ffffffffc020332c:	85a6                	mv	a1,s1
ffffffffc020332e:	f6eff0ef          	jal	ra,ffffffffc0202a9c <tlb_invalidate>
ffffffffc0203332:	048a0d63          	beq	s4,s0,ffffffffc020338c <swap_out+0xc6>
ffffffffc0203336:	0009b783          	ld	a5,0(s3)
ffffffffc020333a:	8656                	mv	a2,s5
ffffffffc020333c:	002c                	addi	a1,sp,8
ffffffffc020333e:	7b9c                	ld	a5,48(a5)
ffffffffc0203340:	854a                	mv	a0,s2
ffffffffc0203342:	9782                	jalr	a5
ffffffffc0203344:	e12d                	bnez	a0,ffffffffc02033a6 <swap_out+0xe0>
ffffffffc0203346:	67a2                	ld	a5,8(sp)
ffffffffc0203348:	01893503          	ld	a0,24(s2)
ffffffffc020334c:	4601                	li	a2,0
ffffffffc020334e:	7f84                	ld	s1,56(a5)
ffffffffc0203350:	85a6                	mv	a1,s1
ffffffffc0203352:	ff8fe0ef          	jal	ra,ffffffffc0201b4a <get_pte>
ffffffffc0203356:	611c                	ld	a5,0(a0)
ffffffffc0203358:	8c2a                	mv	s8,a0
ffffffffc020335a:	8b85                	andi	a5,a5,1
ffffffffc020335c:	cfb9                	beqz	a5,ffffffffc02033ba <swap_out+0xf4>
ffffffffc020335e:	65a2                	ld	a1,8(sp)
ffffffffc0203360:	7d9c                	ld	a5,56(a1)
ffffffffc0203362:	83b1                	srli	a5,a5,0xc
ffffffffc0203364:	0785                	addi	a5,a5,1
ffffffffc0203366:	00879513          	slli	a0,a5,0x8
ffffffffc020336a:	669000ef          	jal	ra,ffffffffc02041d2 <swapfs_write>
ffffffffc020336e:	d949                	beqz	a0,ffffffffc0203300 <swap_out+0x3a>
ffffffffc0203370:	855e                	mv	a0,s7
ffffffffc0203372:	e19fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0203376:	0009b783          	ld	a5,0(s3)
ffffffffc020337a:	6622                	ld	a2,8(sp)
ffffffffc020337c:	4681                	li	a3,0
ffffffffc020337e:	739c                	ld	a5,32(a5)
ffffffffc0203380:	85a6                	mv	a1,s1
ffffffffc0203382:	854a                	mv	a0,s2
ffffffffc0203384:	2405                	addiw	s0,s0,1
ffffffffc0203386:	9782                	jalr	a5
ffffffffc0203388:	fa8a17e3          	bne	s4,s0,ffffffffc0203336 <swap_out+0x70>
ffffffffc020338c:	60e6                	ld	ra,88(sp)
ffffffffc020338e:	8522                	mv	a0,s0
ffffffffc0203390:	6446                	ld	s0,80(sp)
ffffffffc0203392:	64a6                	ld	s1,72(sp)
ffffffffc0203394:	6906                	ld	s2,64(sp)
ffffffffc0203396:	79e2                	ld	s3,56(sp)
ffffffffc0203398:	7a42                	ld	s4,48(sp)
ffffffffc020339a:	7aa2                	ld	s5,40(sp)
ffffffffc020339c:	7b02                	ld	s6,32(sp)
ffffffffc020339e:	6be2                	ld	s7,24(sp)
ffffffffc02033a0:	6c42                	ld	s8,16(sp)
ffffffffc02033a2:	6125                	addi	sp,sp,96
ffffffffc02033a4:	8082                	ret
ffffffffc02033a6:	85a2                	mv	a1,s0
ffffffffc02033a8:	00003517          	auipc	a0,0x3
ffffffffc02033ac:	1c050513          	addi	a0,a0,448 # ffffffffc0206568 <default_pmm_manager+0x948>
ffffffffc02033b0:	ddbfc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02033b4:	bfe1                	j	ffffffffc020338c <swap_out+0xc6>
ffffffffc02033b6:	4401                	li	s0,0
ffffffffc02033b8:	bfd1                	j	ffffffffc020338c <swap_out+0xc6>
ffffffffc02033ba:	00003697          	auipc	a3,0x3
ffffffffc02033be:	1de68693          	addi	a3,a3,478 # ffffffffc0206598 <default_pmm_manager+0x978>
ffffffffc02033c2:	00002617          	auipc	a2,0x2
ffffffffc02033c6:	4ae60613          	addi	a2,a2,1198 # ffffffffc0205870 <commands+0x738>
ffffffffc02033ca:	06c00593          	li	a1,108
ffffffffc02033ce:	00003517          	auipc	a0,0x3
ffffffffc02033d2:	f1250513          	addi	a0,a0,-238 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc02033d6:	868fd0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc02033da <swap_in>:
ffffffffc02033da:	7179                	addi	sp,sp,-48
ffffffffc02033dc:	e84a                	sd	s2,16(sp)
ffffffffc02033de:	892a                	mv	s2,a0
ffffffffc02033e0:	4505                	li	a0,1
ffffffffc02033e2:	ec26                	sd	s1,24(sp)
ffffffffc02033e4:	e44e                	sd	s3,8(sp)
ffffffffc02033e6:	f406                	sd	ra,40(sp)
ffffffffc02033e8:	f022                	sd	s0,32(sp)
ffffffffc02033ea:	84ae                	mv	s1,a1
ffffffffc02033ec:	89b2                	mv	s3,a2
ffffffffc02033ee:	e52fe0ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc02033f2:	c129                	beqz	a0,ffffffffc0203434 <swap_in+0x5a>
ffffffffc02033f4:	842a                	mv	s0,a0
ffffffffc02033f6:	01893503          	ld	a0,24(s2)
ffffffffc02033fa:	4601                	li	a2,0
ffffffffc02033fc:	85a6                	mv	a1,s1
ffffffffc02033fe:	f4cfe0ef          	jal	ra,ffffffffc0201b4a <get_pte>
ffffffffc0203402:	892a                	mv	s2,a0
ffffffffc0203404:	6108                	ld	a0,0(a0)
ffffffffc0203406:	85a2                	mv	a1,s0
ffffffffc0203408:	53d000ef          	jal	ra,ffffffffc0204144 <swapfs_read>
ffffffffc020340c:	00093583          	ld	a1,0(s2)
ffffffffc0203410:	8626                	mv	a2,s1
ffffffffc0203412:	00003517          	auipc	a0,0x3
ffffffffc0203416:	20650513          	addi	a0,a0,518 # ffffffffc0206618 <default_pmm_manager+0x9f8>
ffffffffc020341a:	81a1                	srli	a1,a1,0x8
ffffffffc020341c:	d6ffc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0203420:	70a2                	ld	ra,40(sp)
ffffffffc0203422:	0089b023          	sd	s0,0(s3)
ffffffffc0203426:	7402                	ld	s0,32(sp)
ffffffffc0203428:	64e2                	ld	s1,24(sp)
ffffffffc020342a:	6942                	ld	s2,16(sp)
ffffffffc020342c:	69a2                	ld	s3,8(sp)
ffffffffc020342e:	4501                	li	a0,0
ffffffffc0203430:	6145                	addi	sp,sp,48
ffffffffc0203432:	8082                	ret
ffffffffc0203434:	00003697          	auipc	a3,0x3
ffffffffc0203438:	1d468693          	addi	a3,a3,468 # ffffffffc0206608 <default_pmm_manager+0x9e8>
ffffffffc020343c:	00002617          	auipc	a2,0x2
ffffffffc0203440:	43460613          	addi	a2,a2,1076 # ffffffffc0205870 <commands+0x738>
ffffffffc0203444:	08900593          	li	a1,137
ffffffffc0203448:	00003517          	auipc	a0,0x3
ffffffffc020344c:	e9850513          	addi	a0,a0,-360 # ffffffffc02062e0 <default_pmm_manager+0x6c0>
ffffffffc0203450:	feffc0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0203454 <_fifo_init_mm>:
ffffffffc0203454:	0000e797          	auipc	a5,0xe
ffffffffc0203458:	0b478793          	addi	a5,a5,180 # ffffffffc0211508 <pra_list_head>
ffffffffc020345c:	f51c                	sd	a5,40(a0)
ffffffffc020345e:	e79c                	sd	a5,8(a5)
ffffffffc0203460:	e39c                	sd	a5,0(a5)
ffffffffc0203462:	4501                	li	a0,0
ffffffffc0203464:	8082                	ret

ffffffffc0203466 <_fifo_init>:
ffffffffc0203466:	4501                	li	a0,0
ffffffffc0203468:	8082                	ret

ffffffffc020346a <_fifo_set_unswappable>:
ffffffffc020346a:	4501                	li	a0,0
ffffffffc020346c:	8082                	ret

ffffffffc020346e <_fifo_tick_event>:
ffffffffc020346e:	4501                	li	a0,0
ffffffffc0203470:	8082                	ret

ffffffffc0203472 <_fifo_check_swap>:
ffffffffc0203472:	711d                	addi	sp,sp,-96
ffffffffc0203474:	fc4e                	sd	s3,56(sp)
ffffffffc0203476:	f852                	sd	s4,48(sp)
ffffffffc0203478:	00003517          	auipc	a0,0x3
ffffffffc020347c:	1e050513          	addi	a0,a0,480 # ffffffffc0206658 <default_pmm_manager+0xa38>
ffffffffc0203480:	698d                	lui	s3,0x3
ffffffffc0203482:	4a31                	li	s4,12
ffffffffc0203484:	e4a6                	sd	s1,72(sp)
ffffffffc0203486:	ec86                	sd	ra,88(sp)
ffffffffc0203488:	e8a2                	sd	s0,80(sp)
ffffffffc020348a:	e0ca                	sd	s2,64(sp)
ffffffffc020348c:	f456                	sd	s5,40(sp)
ffffffffc020348e:	f05a                	sd	s6,32(sp)
ffffffffc0203490:	ec5e                	sd	s7,24(sp)
ffffffffc0203492:	e862                	sd	s8,16(sp)
ffffffffc0203494:	e466                	sd	s9,8(sp)
ffffffffc0203496:	cf5fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020349a:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
ffffffffc020349e:	00012497          	auipc	s1,0x12
ffffffffc02034a2:	10a4a483          	lw	s1,266(s1) # ffffffffc02155a8 <pgfault_num>
ffffffffc02034a6:	4791                	li	a5,4
ffffffffc02034a8:	14f49963          	bne	s1,a5,ffffffffc02035fa <_fifo_check_swap+0x188>
ffffffffc02034ac:	00003517          	auipc	a0,0x3
ffffffffc02034b0:	1ec50513          	addi	a0,a0,492 # ffffffffc0206698 <default_pmm_manager+0xa78>
ffffffffc02034b4:	6a85                	lui	s5,0x1
ffffffffc02034b6:	4b29                	li	s6,10
ffffffffc02034b8:	cd3fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02034bc:	00012417          	auipc	s0,0x12
ffffffffc02034c0:	0ec40413          	addi	s0,s0,236 # ffffffffc02155a8 <pgfault_num>
ffffffffc02034c4:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02034c8:	401c                	lw	a5,0(s0)
ffffffffc02034ca:	0007891b          	sext.w	s2,a5
ffffffffc02034ce:	2a979663          	bne	a5,s1,ffffffffc020377a <_fifo_check_swap+0x308>
ffffffffc02034d2:	00003517          	auipc	a0,0x3
ffffffffc02034d6:	1ee50513          	addi	a0,a0,494 # ffffffffc02066c0 <default_pmm_manager+0xaa0>
ffffffffc02034da:	6b91                	lui	s7,0x4
ffffffffc02034dc:	4c35                	li	s8,13
ffffffffc02034de:	cadfc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02034e2:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
ffffffffc02034e6:	401c                	lw	a5,0(s0)
ffffffffc02034e8:	00078c9b          	sext.w	s9,a5
ffffffffc02034ec:	27279763          	bne	a5,s2,ffffffffc020375a <_fifo_check_swap+0x2e8>
ffffffffc02034f0:	00003517          	auipc	a0,0x3
ffffffffc02034f4:	1f850513          	addi	a0,a0,504 # ffffffffc02066e8 <default_pmm_manager+0xac8>
ffffffffc02034f8:	6489                	lui	s1,0x2
ffffffffc02034fa:	492d                	li	s2,11
ffffffffc02034fc:	c8ffc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0203500:	01248023          	sb	s2,0(s1) # 2000 <kern_entry-0xffffffffc01fe000>
ffffffffc0203504:	401c                	lw	a5,0(s0)
ffffffffc0203506:	23979a63          	bne	a5,s9,ffffffffc020373a <_fifo_check_swap+0x2c8>
ffffffffc020350a:	00003517          	auipc	a0,0x3
ffffffffc020350e:	20650513          	addi	a0,a0,518 # ffffffffc0206710 <default_pmm_manager+0xaf0>
ffffffffc0203512:	c79fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0203516:	6795                	lui	a5,0x5
ffffffffc0203518:	4739                	li	a4,14
ffffffffc020351a:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
ffffffffc020351e:	401c                	lw	a5,0(s0)
ffffffffc0203520:	4715                	li	a4,5
ffffffffc0203522:	00078c9b          	sext.w	s9,a5
ffffffffc0203526:	1ee79a63          	bne	a5,a4,ffffffffc020371a <_fifo_check_swap+0x2a8>
ffffffffc020352a:	00003517          	auipc	a0,0x3
ffffffffc020352e:	1be50513          	addi	a0,a0,446 # ffffffffc02066e8 <default_pmm_manager+0xac8>
ffffffffc0203532:	c59fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0203536:	01248023          	sb	s2,0(s1)
ffffffffc020353a:	401c                	lw	a5,0(s0)
ffffffffc020353c:	1b979f63          	bne	a5,s9,ffffffffc02036fa <_fifo_check_swap+0x288>
ffffffffc0203540:	00003517          	auipc	a0,0x3
ffffffffc0203544:	15850513          	addi	a0,a0,344 # ffffffffc0206698 <default_pmm_manager+0xa78>
ffffffffc0203548:	c43fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020354c:	016a8023          	sb	s6,0(s5)
ffffffffc0203550:	4018                	lw	a4,0(s0)
ffffffffc0203552:	4799                	li	a5,6
ffffffffc0203554:	18f71363          	bne	a4,a5,ffffffffc02036da <_fifo_check_swap+0x268>
ffffffffc0203558:	00003517          	auipc	a0,0x3
ffffffffc020355c:	19050513          	addi	a0,a0,400 # ffffffffc02066e8 <default_pmm_manager+0xac8>
ffffffffc0203560:	c2bfc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0203564:	01248023          	sb	s2,0(s1)
ffffffffc0203568:	4018                	lw	a4,0(s0)
ffffffffc020356a:	479d                	li	a5,7
ffffffffc020356c:	14f71763          	bne	a4,a5,ffffffffc02036ba <_fifo_check_swap+0x248>
ffffffffc0203570:	00003517          	auipc	a0,0x3
ffffffffc0203574:	0e850513          	addi	a0,a0,232 # ffffffffc0206658 <default_pmm_manager+0xa38>
ffffffffc0203578:	c13fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020357c:	01498023          	sb	s4,0(s3)
ffffffffc0203580:	4018                	lw	a4,0(s0)
ffffffffc0203582:	47a1                	li	a5,8
ffffffffc0203584:	10f71b63          	bne	a4,a5,ffffffffc020369a <_fifo_check_swap+0x228>
ffffffffc0203588:	00003517          	auipc	a0,0x3
ffffffffc020358c:	13850513          	addi	a0,a0,312 # ffffffffc02066c0 <default_pmm_manager+0xaa0>
ffffffffc0203590:	bfbfc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0203594:	018b8023          	sb	s8,0(s7)
ffffffffc0203598:	4018                	lw	a4,0(s0)
ffffffffc020359a:	47a5                	li	a5,9
ffffffffc020359c:	0cf71f63          	bne	a4,a5,ffffffffc020367a <_fifo_check_swap+0x208>
ffffffffc02035a0:	00003517          	auipc	a0,0x3
ffffffffc02035a4:	17050513          	addi	a0,a0,368 # ffffffffc0206710 <default_pmm_manager+0xaf0>
ffffffffc02035a8:	be3fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02035ac:	6795                	lui	a5,0x5
ffffffffc02035ae:	4739                	li	a4,14
ffffffffc02035b0:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
ffffffffc02035b4:	401c                	lw	a5,0(s0)
ffffffffc02035b6:	4729                	li	a4,10
ffffffffc02035b8:	0007849b          	sext.w	s1,a5
ffffffffc02035bc:	08e79f63          	bne	a5,a4,ffffffffc020365a <_fifo_check_swap+0x1e8>
ffffffffc02035c0:	00003517          	auipc	a0,0x3
ffffffffc02035c4:	0d850513          	addi	a0,a0,216 # ffffffffc0206698 <default_pmm_manager+0xa78>
ffffffffc02035c8:	bc3fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02035cc:	6785                	lui	a5,0x1
ffffffffc02035ce:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02035d2:	06979463          	bne	a5,s1,ffffffffc020363a <_fifo_check_swap+0x1c8>
ffffffffc02035d6:	4018                	lw	a4,0(s0)
ffffffffc02035d8:	47ad                	li	a5,11
ffffffffc02035da:	04f71063          	bne	a4,a5,ffffffffc020361a <_fifo_check_swap+0x1a8>
ffffffffc02035de:	60e6                	ld	ra,88(sp)
ffffffffc02035e0:	6446                	ld	s0,80(sp)
ffffffffc02035e2:	64a6                	ld	s1,72(sp)
ffffffffc02035e4:	6906                	ld	s2,64(sp)
ffffffffc02035e6:	79e2                	ld	s3,56(sp)
ffffffffc02035e8:	7a42                	ld	s4,48(sp)
ffffffffc02035ea:	7aa2                	ld	s5,40(sp)
ffffffffc02035ec:	7b02                	ld	s6,32(sp)
ffffffffc02035ee:	6be2                	ld	s7,24(sp)
ffffffffc02035f0:	6c42                	ld	s8,16(sp)
ffffffffc02035f2:	6ca2                	ld	s9,8(sp)
ffffffffc02035f4:	4501                	li	a0,0
ffffffffc02035f6:	6125                	addi	sp,sp,96
ffffffffc02035f8:	8082                	ret
ffffffffc02035fa:	00003697          	auipc	a3,0x3
ffffffffc02035fe:	eae68693          	addi	a3,a3,-338 # ffffffffc02064a8 <default_pmm_manager+0x888>
ffffffffc0203602:	00002617          	auipc	a2,0x2
ffffffffc0203606:	26e60613          	addi	a2,a2,622 # ffffffffc0205870 <commands+0x738>
ffffffffc020360a:	05b00593          	li	a1,91
ffffffffc020360e:	00003517          	auipc	a0,0x3
ffffffffc0203612:	07250513          	addi	a0,a0,114 # ffffffffc0206680 <default_pmm_manager+0xa60>
ffffffffc0203616:	e29fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020361a:	00003697          	auipc	a3,0x3
ffffffffc020361e:	1a668693          	addi	a3,a3,422 # ffffffffc02067c0 <default_pmm_manager+0xba0>
ffffffffc0203622:	00002617          	auipc	a2,0x2
ffffffffc0203626:	24e60613          	addi	a2,a2,590 # ffffffffc0205870 <commands+0x738>
ffffffffc020362a:	07d00593          	li	a1,125
ffffffffc020362e:	00003517          	auipc	a0,0x3
ffffffffc0203632:	05250513          	addi	a0,a0,82 # ffffffffc0206680 <default_pmm_manager+0xa60>
ffffffffc0203636:	e09fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020363a:	00003697          	auipc	a3,0x3
ffffffffc020363e:	15e68693          	addi	a3,a3,350 # ffffffffc0206798 <default_pmm_manager+0xb78>
ffffffffc0203642:	00002617          	auipc	a2,0x2
ffffffffc0203646:	22e60613          	addi	a2,a2,558 # ffffffffc0205870 <commands+0x738>
ffffffffc020364a:	07b00593          	li	a1,123
ffffffffc020364e:	00003517          	auipc	a0,0x3
ffffffffc0203652:	03250513          	addi	a0,a0,50 # ffffffffc0206680 <default_pmm_manager+0xa60>
ffffffffc0203656:	de9fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020365a:	00003697          	auipc	a3,0x3
ffffffffc020365e:	12e68693          	addi	a3,a3,302 # ffffffffc0206788 <default_pmm_manager+0xb68>
ffffffffc0203662:	00002617          	auipc	a2,0x2
ffffffffc0203666:	20e60613          	addi	a2,a2,526 # ffffffffc0205870 <commands+0x738>
ffffffffc020366a:	07900593          	li	a1,121
ffffffffc020366e:	00003517          	auipc	a0,0x3
ffffffffc0203672:	01250513          	addi	a0,a0,18 # ffffffffc0206680 <default_pmm_manager+0xa60>
ffffffffc0203676:	dc9fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020367a:	00003697          	auipc	a3,0x3
ffffffffc020367e:	0fe68693          	addi	a3,a3,254 # ffffffffc0206778 <default_pmm_manager+0xb58>
ffffffffc0203682:	00002617          	auipc	a2,0x2
ffffffffc0203686:	1ee60613          	addi	a2,a2,494 # ffffffffc0205870 <commands+0x738>
ffffffffc020368a:	07600593          	li	a1,118
ffffffffc020368e:	00003517          	auipc	a0,0x3
ffffffffc0203692:	ff250513          	addi	a0,a0,-14 # ffffffffc0206680 <default_pmm_manager+0xa60>
ffffffffc0203696:	da9fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020369a:	00003697          	auipc	a3,0x3
ffffffffc020369e:	0ce68693          	addi	a3,a3,206 # ffffffffc0206768 <default_pmm_manager+0xb48>
ffffffffc02036a2:	00002617          	auipc	a2,0x2
ffffffffc02036a6:	1ce60613          	addi	a2,a2,462 # ffffffffc0205870 <commands+0x738>
ffffffffc02036aa:	07300593          	li	a1,115
ffffffffc02036ae:	00003517          	auipc	a0,0x3
ffffffffc02036b2:	fd250513          	addi	a0,a0,-46 # ffffffffc0206680 <default_pmm_manager+0xa60>
ffffffffc02036b6:	d89fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02036ba:	00003697          	auipc	a3,0x3
ffffffffc02036be:	09e68693          	addi	a3,a3,158 # ffffffffc0206758 <default_pmm_manager+0xb38>
ffffffffc02036c2:	00002617          	auipc	a2,0x2
ffffffffc02036c6:	1ae60613          	addi	a2,a2,430 # ffffffffc0205870 <commands+0x738>
ffffffffc02036ca:	07000593          	li	a1,112
ffffffffc02036ce:	00003517          	auipc	a0,0x3
ffffffffc02036d2:	fb250513          	addi	a0,a0,-78 # ffffffffc0206680 <default_pmm_manager+0xa60>
ffffffffc02036d6:	d69fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02036da:	00003697          	auipc	a3,0x3
ffffffffc02036de:	06e68693          	addi	a3,a3,110 # ffffffffc0206748 <default_pmm_manager+0xb28>
ffffffffc02036e2:	00002617          	auipc	a2,0x2
ffffffffc02036e6:	18e60613          	addi	a2,a2,398 # ffffffffc0205870 <commands+0x738>
ffffffffc02036ea:	06d00593          	li	a1,109
ffffffffc02036ee:	00003517          	auipc	a0,0x3
ffffffffc02036f2:	f9250513          	addi	a0,a0,-110 # ffffffffc0206680 <default_pmm_manager+0xa60>
ffffffffc02036f6:	d49fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02036fa:	00003697          	auipc	a3,0x3
ffffffffc02036fe:	03e68693          	addi	a3,a3,62 # ffffffffc0206738 <default_pmm_manager+0xb18>
ffffffffc0203702:	00002617          	auipc	a2,0x2
ffffffffc0203706:	16e60613          	addi	a2,a2,366 # ffffffffc0205870 <commands+0x738>
ffffffffc020370a:	06a00593          	li	a1,106
ffffffffc020370e:	00003517          	auipc	a0,0x3
ffffffffc0203712:	f7250513          	addi	a0,a0,-142 # ffffffffc0206680 <default_pmm_manager+0xa60>
ffffffffc0203716:	d29fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020371a:	00003697          	auipc	a3,0x3
ffffffffc020371e:	01e68693          	addi	a3,a3,30 # ffffffffc0206738 <default_pmm_manager+0xb18>
ffffffffc0203722:	00002617          	auipc	a2,0x2
ffffffffc0203726:	14e60613          	addi	a2,a2,334 # ffffffffc0205870 <commands+0x738>
ffffffffc020372a:	06700593          	li	a1,103
ffffffffc020372e:	00003517          	auipc	a0,0x3
ffffffffc0203732:	f5250513          	addi	a0,a0,-174 # ffffffffc0206680 <default_pmm_manager+0xa60>
ffffffffc0203736:	d09fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020373a:	00003697          	auipc	a3,0x3
ffffffffc020373e:	d6e68693          	addi	a3,a3,-658 # ffffffffc02064a8 <default_pmm_manager+0x888>
ffffffffc0203742:	00002617          	auipc	a2,0x2
ffffffffc0203746:	12e60613          	addi	a2,a2,302 # ffffffffc0205870 <commands+0x738>
ffffffffc020374a:	06400593          	li	a1,100
ffffffffc020374e:	00003517          	auipc	a0,0x3
ffffffffc0203752:	f3250513          	addi	a0,a0,-206 # ffffffffc0206680 <default_pmm_manager+0xa60>
ffffffffc0203756:	ce9fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020375a:	00003697          	auipc	a3,0x3
ffffffffc020375e:	d4e68693          	addi	a3,a3,-690 # ffffffffc02064a8 <default_pmm_manager+0x888>
ffffffffc0203762:	00002617          	auipc	a2,0x2
ffffffffc0203766:	10e60613          	addi	a2,a2,270 # ffffffffc0205870 <commands+0x738>
ffffffffc020376a:	06100593          	li	a1,97
ffffffffc020376e:	00003517          	auipc	a0,0x3
ffffffffc0203772:	f1250513          	addi	a0,a0,-238 # ffffffffc0206680 <default_pmm_manager+0xa60>
ffffffffc0203776:	cc9fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020377a:	00003697          	auipc	a3,0x3
ffffffffc020377e:	d2e68693          	addi	a3,a3,-722 # ffffffffc02064a8 <default_pmm_manager+0x888>
ffffffffc0203782:	00002617          	auipc	a2,0x2
ffffffffc0203786:	0ee60613          	addi	a2,a2,238 # ffffffffc0205870 <commands+0x738>
ffffffffc020378a:	05e00593          	li	a1,94
ffffffffc020378e:	00003517          	auipc	a0,0x3
ffffffffc0203792:	ef250513          	addi	a0,a0,-270 # ffffffffc0206680 <default_pmm_manager+0xa60>
ffffffffc0203796:	ca9fc0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc020379a <_fifo_swap_out_victim>:
ffffffffc020379a:	751c                	ld	a5,40(a0)
ffffffffc020379c:	1141                	addi	sp,sp,-16
ffffffffc020379e:	e406                	sd	ra,8(sp)
ffffffffc02037a0:	cf91                	beqz	a5,ffffffffc02037bc <_fifo_swap_out_victim+0x22>
ffffffffc02037a2:	ee0d                	bnez	a2,ffffffffc02037dc <_fifo_swap_out_victim+0x42>
ffffffffc02037a4:	679c                	ld	a5,8(a5)
ffffffffc02037a6:	60a2                	ld	ra,8(sp)
ffffffffc02037a8:	4501                	li	a0,0
ffffffffc02037aa:	6394                	ld	a3,0(a5)
ffffffffc02037ac:	6798                	ld	a4,8(a5)
ffffffffc02037ae:	fd878793          	addi	a5,a5,-40
ffffffffc02037b2:	e698                	sd	a4,8(a3)
ffffffffc02037b4:	e314                	sd	a3,0(a4)
ffffffffc02037b6:	e19c                	sd	a5,0(a1)
ffffffffc02037b8:	0141                	addi	sp,sp,16
ffffffffc02037ba:	8082                	ret
ffffffffc02037bc:	00003697          	auipc	a3,0x3
ffffffffc02037c0:	01468693          	addi	a3,a3,20 # ffffffffc02067d0 <default_pmm_manager+0xbb0>
ffffffffc02037c4:	00002617          	auipc	a2,0x2
ffffffffc02037c8:	0ac60613          	addi	a2,a2,172 # ffffffffc0205870 <commands+0x738>
ffffffffc02037cc:	04b00593          	li	a1,75
ffffffffc02037d0:	00003517          	auipc	a0,0x3
ffffffffc02037d4:	eb050513          	addi	a0,a0,-336 # ffffffffc0206680 <default_pmm_manager+0xa60>
ffffffffc02037d8:	c67fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02037dc:	00003697          	auipc	a3,0x3
ffffffffc02037e0:	00468693          	addi	a3,a3,4 # ffffffffc02067e0 <default_pmm_manager+0xbc0>
ffffffffc02037e4:	00002617          	auipc	a2,0x2
ffffffffc02037e8:	08c60613          	addi	a2,a2,140 # ffffffffc0205870 <commands+0x738>
ffffffffc02037ec:	04c00593          	li	a1,76
ffffffffc02037f0:	00003517          	auipc	a0,0x3
ffffffffc02037f4:	e9050513          	addi	a0,a0,-368 # ffffffffc0206680 <default_pmm_manager+0xa60>
ffffffffc02037f8:	c47fc0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc02037fc <_fifo_map_swappable>:
ffffffffc02037fc:	751c                	ld	a5,40(a0)
ffffffffc02037fe:	cb91                	beqz	a5,ffffffffc0203812 <_fifo_map_swappable+0x16>
ffffffffc0203800:	6394                	ld	a3,0(a5)
ffffffffc0203802:	02860713          	addi	a4,a2,40
ffffffffc0203806:	e398                	sd	a4,0(a5)
ffffffffc0203808:	e698                	sd	a4,8(a3)
ffffffffc020380a:	4501                	li	a0,0
ffffffffc020380c:	fa1c                	sd	a5,48(a2)
ffffffffc020380e:	f614                	sd	a3,40(a2)
ffffffffc0203810:	8082                	ret
ffffffffc0203812:	1141                	addi	sp,sp,-16
ffffffffc0203814:	00003697          	auipc	a3,0x3
ffffffffc0203818:	fdc68693          	addi	a3,a3,-36 # ffffffffc02067f0 <default_pmm_manager+0xbd0>
ffffffffc020381c:	00002617          	auipc	a2,0x2
ffffffffc0203820:	05460613          	addi	a2,a2,84 # ffffffffc0205870 <commands+0x738>
ffffffffc0203824:	03900593          	li	a1,57
ffffffffc0203828:	00003517          	auipc	a0,0x3
ffffffffc020382c:	e5850513          	addi	a0,a0,-424 # ffffffffc0206680 <default_pmm_manager+0xa60>
ffffffffc0203830:	e406                	sd	ra,8(sp)
ffffffffc0203832:	c0dfc0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0203836 <check_vma_overlap.part.0>:
ffffffffc0203836:	1141                	addi	sp,sp,-16
ffffffffc0203838:	00003697          	auipc	a3,0x3
ffffffffc020383c:	ff068693          	addi	a3,a3,-16 # ffffffffc0206828 <default_pmm_manager+0xc08>
ffffffffc0203840:	00002617          	auipc	a2,0x2
ffffffffc0203844:	03060613          	addi	a2,a2,48 # ffffffffc0205870 <commands+0x738>
ffffffffc0203848:	09600593          	li	a1,150
ffffffffc020384c:	00003517          	auipc	a0,0x3
ffffffffc0203850:	ffc50513          	addi	a0,a0,-4 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203854:	e406                	sd	ra,8(sp)
ffffffffc0203856:	be9fc0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc020385a <mm_create>:
ffffffffc020385a:	1141                	addi	sp,sp,-16
ffffffffc020385c:	03000513          	li	a0,48
ffffffffc0203860:	e022                	sd	s0,0(sp)
ffffffffc0203862:	e406                	sd	ra,8(sp)
ffffffffc0203864:	80efe0ef          	jal	ra,ffffffffc0201872 <kmalloc>
ffffffffc0203868:	842a                	mv	s0,a0
ffffffffc020386a:	c105                	beqz	a0,ffffffffc020388a <mm_create+0x30>
ffffffffc020386c:	e408                	sd	a0,8(s0)
ffffffffc020386e:	e008                	sd	a0,0(s0)
ffffffffc0203870:	00053823          	sd	zero,16(a0)
ffffffffc0203874:	00053c23          	sd	zero,24(a0)
ffffffffc0203878:	02052023          	sw	zero,32(a0)
ffffffffc020387c:	00012797          	auipc	a5,0x12
ffffffffc0203880:	d147a783          	lw	a5,-748(a5) # ffffffffc0215590 <swap_init_ok>
ffffffffc0203884:	eb81                	bnez	a5,ffffffffc0203894 <mm_create+0x3a>
ffffffffc0203886:	02053423          	sd	zero,40(a0)
ffffffffc020388a:	60a2                	ld	ra,8(sp)
ffffffffc020388c:	8522                	mv	a0,s0
ffffffffc020388e:	6402                	ld	s0,0(sp)
ffffffffc0203890:	0141                	addi	sp,sp,16
ffffffffc0203892:	8082                	ret
ffffffffc0203894:	a1bff0ef          	jal	ra,ffffffffc02032ae <swap_init_mm>
ffffffffc0203898:	60a2                	ld	ra,8(sp)
ffffffffc020389a:	8522                	mv	a0,s0
ffffffffc020389c:	6402                	ld	s0,0(sp)
ffffffffc020389e:	0141                	addi	sp,sp,16
ffffffffc02038a0:	8082                	ret

ffffffffc02038a2 <vma_create>:
ffffffffc02038a2:	1101                	addi	sp,sp,-32
ffffffffc02038a4:	e04a                	sd	s2,0(sp)
ffffffffc02038a6:	892a                	mv	s2,a0
ffffffffc02038a8:	03000513          	li	a0,48
ffffffffc02038ac:	e822                	sd	s0,16(sp)
ffffffffc02038ae:	e426                	sd	s1,8(sp)
ffffffffc02038b0:	ec06                	sd	ra,24(sp)
ffffffffc02038b2:	84ae                	mv	s1,a1
ffffffffc02038b4:	8432                	mv	s0,a2
ffffffffc02038b6:	fbdfd0ef          	jal	ra,ffffffffc0201872 <kmalloc>
ffffffffc02038ba:	c509                	beqz	a0,ffffffffc02038c4 <vma_create+0x22>
ffffffffc02038bc:	01253423          	sd	s2,8(a0)
ffffffffc02038c0:	e904                	sd	s1,16(a0)
ffffffffc02038c2:	cd00                	sw	s0,24(a0)
ffffffffc02038c4:	60e2                	ld	ra,24(sp)
ffffffffc02038c6:	6442                	ld	s0,16(sp)
ffffffffc02038c8:	64a2                	ld	s1,8(sp)
ffffffffc02038ca:	6902                	ld	s2,0(sp)
ffffffffc02038cc:	6105                	addi	sp,sp,32
ffffffffc02038ce:	8082                	ret

ffffffffc02038d0 <find_vma>:
ffffffffc02038d0:	86aa                	mv	a3,a0
ffffffffc02038d2:	c505                	beqz	a0,ffffffffc02038fa <find_vma+0x2a>
ffffffffc02038d4:	6908                	ld	a0,16(a0)
ffffffffc02038d6:	c501                	beqz	a0,ffffffffc02038de <find_vma+0xe>
ffffffffc02038d8:	651c                	ld	a5,8(a0)
ffffffffc02038da:	02f5f663          	bgeu	a1,a5,ffffffffc0203906 <find_vma+0x36>
ffffffffc02038de:	669c                	ld	a5,8(a3)
ffffffffc02038e0:	00f68d63          	beq	a3,a5,ffffffffc02038fa <find_vma+0x2a>
ffffffffc02038e4:	fe87b703          	ld	a4,-24(a5)
ffffffffc02038e8:	00e5e663          	bltu	a1,a4,ffffffffc02038f4 <find_vma+0x24>
ffffffffc02038ec:	ff07b703          	ld	a4,-16(a5)
ffffffffc02038f0:	00e5e763          	bltu	a1,a4,ffffffffc02038fe <find_vma+0x2e>
ffffffffc02038f4:	679c                	ld	a5,8(a5)
ffffffffc02038f6:	fef697e3          	bne	a3,a5,ffffffffc02038e4 <find_vma+0x14>
ffffffffc02038fa:	4501                	li	a0,0
ffffffffc02038fc:	8082                	ret
ffffffffc02038fe:	fe078513          	addi	a0,a5,-32
ffffffffc0203902:	ea88                	sd	a0,16(a3)
ffffffffc0203904:	8082                	ret
ffffffffc0203906:	691c                	ld	a5,16(a0)
ffffffffc0203908:	fcf5fbe3          	bgeu	a1,a5,ffffffffc02038de <find_vma+0xe>
ffffffffc020390c:	ea88                	sd	a0,16(a3)
ffffffffc020390e:	8082                	ret

ffffffffc0203910 <insert_vma_struct>:
ffffffffc0203910:	6590                	ld	a2,8(a1)
ffffffffc0203912:	0105b803          	ld	a6,16(a1) # 1010 <kern_entry-0xffffffffc01feff0>
ffffffffc0203916:	1141                	addi	sp,sp,-16
ffffffffc0203918:	e406                	sd	ra,8(sp)
ffffffffc020391a:	87aa                	mv	a5,a0
ffffffffc020391c:	01066763          	bltu	a2,a6,ffffffffc020392a <insert_vma_struct+0x1a>
ffffffffc0203920:	a085                	j	ffffffffc0203980 <insert_vma_struct+0x70>
ffffffffc0203922:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203926:	04e66863          	bltu	a2,a4,ffffffffc0203976 <insert_vma_struct+0x66>
ffffffffc020392a:	86be                	mv	a3,a5
ffffffffc020392c:	679c                	ld	a5,8(a5)
ffffffffc020392e:	fef51ae3          	bne	a0,a5,ffffffffc0203922 <insert_vma_struct+0x12>
ffffffffc0203932:	02a68463          	beq	a3,a0,ffffffffc020395a <insert_vma_struct+0x4a>
ffffffffc0203936:	ff06b703          	ld	a4,-16(a3)
ffffffffc020393a:	fe86b883          	ld	a7,-24(a3)
ffffffffc020393e:	08e8f163          	bgeu	a7,a4,ffffffffc02039c0 <insert_vma_struct+0xb0>
ffffffffc0203942:	04e66f63          	bltu	a2,a4,ffffffffc02039a0 <insert_vma_struct+0x90>
ffffffffc0203946:	00f50a63          	beq	a0,a5,ffffffffc020395a <insert_vma_struct+0x4a>
ffffffffc020394a:	fe87b703          	ld	a4,-24(a5)
ffffffffc020394e:	05076963          	bltu	a4,a6,ffffffffc02039a0 <insert_vma_struct+0x90>
ffffffffc0203952:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203956:	02c77363          	bgeu	a4,a2,ffffffffc020397c <insert_vma_struct+0x6c>
ffffffffc020395a:	5118                	lw	a4,32(a0)
ffffffffc020395c:	e188                	sd	a0,0(a1)
ffffffffc020395e:	02058613          	addi	a2,a1,32
ffffffffc0203962:	e390                	sd	a2,0(a5)
ffffffffc0203964:	e690                	sd	a2,8(a3)
ffffffffc0203966:	60a2                	ld	ra,8(sp)
ffffffffc0203968:	f59c                	sd	a5,40(a1)
ffffffffc020396a:	f194                	sd	a3,32(a1)
ffffffffc020396c:	0017079b          	addiw	a5,a4,1
ffffffffc0203970:	d11c                	sw	a5,32(a0)
ffffffffc0203972:	0141                	addi	sp,sp,16
ffffffffc0203974:	8082                	ret
ffffffffc0203976:	fca690e3          	bne	a3,a0,ffffffffc0203936 <insert_vma_struct+0x26>
ffffffffc020397a:	bfd1                	j	ffffffffc020394e <insert_vma_struct+0x3e>
ffffffffc020397c:	ebbff0ef          	jal	ra,ffffffffc0203836 <check_vma_overlap.part.0>
ffffffffc0203980:	00003697          	auipc	a3,0x3
ffffffffc0203984:	ed868693          	addi	a3,a3,-296 # ffffffffc0206858 <default_pmm_manager+0xc38>
ffffffffc0203988:	00002617          	auipc	a2,0x2
ffffffffc020398c:	ee860613          	addi	a2,a2,-280 # ffffffffc0205870 <commands+0x738>
ffffffffc0203990:	09f00593          	li	a1,159
ffffffffc0203994:	00003517          	auipc	a0,0x3
ffffffffc0203998:	eb450513          	addi	a0,a0,-332 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc020399c:	aa3fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02039a0:	00003697          	auipc	a3,0x3
ffffffffc02039a4:	ef868693          	addi	a3,a3,-264 # ffffffffc0206898 <default_pmm_manager+0xc78>
ffffffffc02039a8:	00002617          	auipc	a2,0x2
ffffffffc02039ac:	ec860613          	addi	a2,a2,-312 # ffffffffc0205870 <commands+0x738>
ffffffffc02039b0:	09500593          	li	a1,149
ffffffffc02039b4:	00003517          	auipc	a0,0x3
ffffffffc02039b8:	e9450513          	addi	a0,a0,-364 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc02039bc:	a83fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02039c0:	00003697          	auipc	a3,0x3
ffffffffc02039c4:	eb868693          	addi	a3,a3,-328 # ffffffffc0206878 <default_pmm_manager+0xc58>
ffffffffc02039c8:	00002617          	auipc	a2,0x2
ffffffffc02039cc:	ea860613          	addi	a2,a2,-344 # ffffffffc0205870 <commands+0x738>
ffffffffc02039d0:	09400593          	li	a1,148
ffffffffc02039d4:	00003517          	auipc	a0,0x3
ffffffffc02039d8:	e7450513          	addi	a0,a0,-396 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc02039dc:	a63fc0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc02039e0 <mm_destroy>:
ffffffffc02039e0:	1141                	addi	sp,sp,-16
ffffffffc02039e2:	e022                	sd	s0,0(sp)
ffffffffc02039e4:	842a                	mv	s0,a0
ffffffffc02039e6:	6508                	ld	a0,8(a0)
ffffffffc02039e8:	e406                	sd	ra,8(sp)
ffffffffc02039ea:	00a40c63          	beq	s0,a0,ffffffffc0203a02 <mm_destroy+0x22>
ffffffffc02039ee:	6118                	ld	a4,0(a0)
ffffffffc02039f0:	651c                	ld	a5,8(a0)
ffffffffc02039f2:	1501                	addi	a0,a0,-32
ffffffffc02039f4:	e71c                	sd	a5,8(a4)
ffffffffc02039f6:	e398                	sd	a4,0(a5)
ffffffffc02039f8:	f1bfd0ef          	jal	ra,ffffffffc0201912 <kfree>
ffffffffc02039fc:	6408                	ld	a0,8(s0)
ffffffffc02039fe:	fea418e3          	bne	s0,a0,ffffffffc02039ee <mm_destroy+0xe>
ffffffffc0203a02:	8522                	mv	a0,s0
ffffffffc0203a04:	6402                	ld	s0,0(sp)
ffffffffc0203a06:	60a2                	ld	ra,8(sp)
ffffffffc0203a08:	0141                	addi	sp,sp,16
ffffffffc0203a0a:	f09fd06f          	j	ffffffffc0201912 <kfree>

ffffffffc0203a0e <vmm_init>:
ffffffffc0203a0e:	7139                	addi	sp,sp,-64
ffffffffc0203a10:	03000513          	li	a0,48
ffffffffc0203a14:	fc06                	sd	ra,56(sp)
ffffffffc0203a16:	f822                	sd	s0,48(sp)
ffffffffc0203a18:	f426                	sd	s1,40(sp)
ffffffffc0203a1a:	f04a                	sd	s2,32(sp)
ffffffffc0203a1c:	ec4e                	sd	s3,24(sp)
ffffffffc0203a1e:	e852                	sd	s4,16(sp)
ffffffffc0203a20:	e456                	sd	s5,8(sp)
ffffffffc0203a22:	e05a                	sd	s6,0(sp)
ffffffffc0203a24:	e4ffd0ef          	jal	ra,ffffffffc0201872 <kmalloc>
ffffffffc0203a28:	34050063          	beqz	a0,ffffffffc0203d68 <vmm_init+0x35a>
ffffffffc0203a2c:	e508                	sd	a0,8(a0)
ffffffffc0203a2e:	e108                	sd	a0,0(a0)
ffffffffc0203a30:	00053823          	sd	zero,16(a0)
ffffffffc0203a34:	00053c23          	sd	zero,24(a0)
ffffffffc0203a38:	02052023          	sw	zero,32(a0)
ffffffffc0203a3c:	00012797          	auipc	a5,0x12
ffffffffc0203a40:	b547a783          	lw	a5,-1196(a5) # ffffffffc0215590 <swap_init_ok>
ffffffffc0203a44:	842a                	mv	s0,a0
ffffffffc0203a46:	2e079e63          	bnez	a5,ffffffffc0203d42 <vmm_init+0x334>
ffffffffc0203a4a:	02053423          	sd	zero,40(a0)
ffffffffc0203a4e:	03200493          	li	s1,50
ffffffffc0203a52:	03000513          	li	a0,48
ffffffffc0203a56:	e1dfd0ef          	jal	ra,ffffffffc0201872 <kmalloc>
ffffffffc0203a5a:	85aa                	mv	a1,a0
ffffffffc0203a5c:	00248793          	addi	a5,s1,2
ffffffffc0203a60:	2e050463          	beqz	a0,ffffffffc0203d48 <vmm_init+0x33a>
ffffffffc0203a64:	e504                	sd	s1,8(a0)
ffffffffc0203a66:	e91c                	sd	a5,16(a0)
ffffffffc0203a68:	00052c23          	sw	zero,24(a0)
ffffffffc0203a6c:	14ed                	addi	s1,s1,-5
ffffffffc0203a6e:	8522                	mv	a0,s0
ffffffffc0203a70:	ea1ff0ef          	jal	ra,ffffffffc0203910 <insert_vma_struct>
ffffffffc0203a74:	fcf9                	bnez	s1,ffffffffc0203a52 <vmm_init+0x44>
ffffffffc0203a76:	03700493          	li	s1,55
ffffffffc0203a7a:	1f900913          	li	s2,505
ffffffffc0203a7e:	03000513          	li	a0,48
ffffffffc0203a82:	df1fd0ef          	jal	ra,ffffffffc0201872 <kmalloc>
ffffffffc0203a86:	85aa                	mv	a1,a0
ffffffffc0203a88:	30050063          	beqz	a0,ffffffffc0203d88 <vmm_init+0x37a>
ffffffffc0203a8c:	00248793          	addi	a5,s1,2
ffffffffc0203a90:	e504                	sd	s1,8(a0)
ffffffffc0203a92:	e91c                	sd	a5,16(a0)
ffffffffc0203a94:	00052c23          	sw	zero,24(a0)
ffffffffc0203a98:	0495                	addi	s1,s1,5
ffffffffc0203a9a:	8522                	mv	a0,s0
ffffffffc0203a9c:	e75ff0ef          	jal	ra,ffffffffc0203910 <insert_vma_struct>
ffffffffc0203aa0:	fd249fe3          	bne	s1,s2,ffffffffc0203a7e <vmm_init+0x70>
ffffffffc0203aa4:	00843a03          	ld	s4,8(s0)
ffffffffc0203aa8:	3a8a0763          	beq	s4,s0,ffffffffc0203e56 <vmm_init+0x448>
ffffffffc0203aac:	87d2                	mv	a5,s4
ffffffffc0203aae:	4715                	li	a4,5
ffffffffc0203ab0:	1f400593          	li	a1,500
ffffffffc0203ab4:	a021                	j	ffffffffc0203abc <vmm_init+0xae>
ffffffffc0203ab6:	0715                	addi	a4,a4,5
ffffffffc0203ab8:	38878f63          	beq	a5,s0,ffffffffc0203e56 <vmm_init+0x448>
ffffffffc0203abc:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203ac0:	36e69b63          	bne	a3,a4,ffffffffc0203e36 <vmm_init+0x428>
ffffffffc0203ac4:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203ac8:	00270693          	addi	a3,a4,2
ffffffffc0203acc:	36d61563          	bne	a2,a3,ffffffffc0203e36 <vmm_init+0x428>
ffffffffc0203ad0:	679c                	ld	a5,8(a5)
ffffffffc0203ad2:	feb712e3          	bne	a4,a1,ffffffffc0203ab6 <vmm_init+0xa8>
ffffffffc0203ad6:	4a9d                	li	s5,7
ffffffffc0203ad8:	4495                	li	s1,5
ffffffffc0203ada:	1f900b13          	li	s6,505
ffffffffc0203ade:	85a6                	mv	a1,s1
ffffffffc0203ae0:	8522                	mv	a0,s0
ffffffffc0203ae2:	defff0ef          	jal	ra,ffffffffc02038d0 <find_vma>
ffffffffc0203ae6:	89aa                	mv	s3,a0
ffffffffc0203ae8:	3a050763          	beqz	a0,ffffffffc0203e96 <vmm_init+0x488>
ffffffffc0203aec:	00148593          	addi	a1,s1,1
ffffffffc0203af0:	8522                	mv	a0,s0
ffffffffc0203af2:	ddfff0ef          	jal	ra,ffffffffc02038d0 <find_vma>
ffffffffc0203af6:	892a                	mv	s2,a0
ffffffffc0203af8:	36050f63          	beqz	a0,ffffffffc0203e76 <vmm_init+0x468>
ffffffffc0203afc:	85d6                	mv	a1,s5
ffffffffc0203afe:	8522                	mv	a0,s0
ffffffffc0203b00:	dd1ff0ef          	jal	ra,ffffffffc02038d0 <find_vma>
ffffffffc0203b04:	3e051963          	bnez	a0,ffffffffc0203ef6 <vmm_init+0x4e8>
ffffffffc0203b08:	00348593          	addi	a1,s1,3
ffffffffc0203b0c:	8522                	mv	a0,s0
ffffffffc0203b0e:	dc3ff0ef          	jal	ra,ffffffffc02038d0 <find_vma>
ffffffffc0203b12:	3c051263          	bnez	a0,ffffffffc0203ed6 <vmm_init+0x4c8>
ffffffffc0203b16:	00448593          	addi	a1,s1,4
ffffffffc0203b1a:	8522                	mv	a0,s0
ffffffffc0203b1c:	db5ff0ef          	jal	ra,ffffffffc02038d0 <find_vma>
ffffffffc0203b20:	38051b63          	bnez	a0,ffffffffc0203eb6 <vmm_init+0x4a8>
ffffffffc0203b24:	0089b783          	ld	a5,8(s3)
ffffffffc0203b28:	2ef49763          	bne	s1,a5,ffffffffc0203e16 <vmm_init+0x408>
ffffffffc0203b2c:	0109b783          	ld	a5,16(s3)
ffffffffc0203b30:	2f579363          	bne	a5,s5,ffffffffc0203e16 <vmm_init+0x408>
ffffffffc0203b34:	00893783          	ld	a5,8(s2)
ffffffffc0203b38:	2af49f63          	bne	s1,a5,ffffffffc0203df6 <vmm_init+0x3e8>
ffffffffc0203b3c:	01093783          	ld	a5,16(s2)
ffffffffc0203b40:	2b579b63          	bne	a5,s5,ffffffffc0203df6 <vmm_init+0x3e8>
ffffffffc0203b44:	0495                	addi	s1,s1,5
ffffffffc0203b46:	0a95                	addi	s5,s5,5
ffffffffc0203b48:	f9649be3          	bne	s1,s6,ffffffffc0203ade <vmm_init+0xd0>
ffffffffc0203b4c:	4491                	li	s1,4
ffffffffc0203b4e:	597d                	li	s2,-1
ffffffffc0203b50:	85a6                	mv	a1,s1
ffffffffc0203b52:	8522                	mv	a0,s0
ffffffffc0203b54:	d7dff0ef          	jal	ra,ffffffffc02038d0 <find_vma>
ffffffffc0203b58:	3a051f63          	bnez	a0,ffffffffc0203f16 <vmm_init+0x508>
ffffffffc0203b5c:	14fd                	addi	s1,s1,-1
ffffffffc0203b5e:	ff2499e3          	bne	s1,s2,ffffffffc0203b50 <vmm_init+0x142>
ffffffffc0203b62:	000a3703          	ld	a4,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0203b66:	008a3783          	ld	a5,8(s4)
ffffffffc0203b6a:	fe0a0513          	addi	a0,s4,-32
ffffffffc0203b6e:	e71c                	sd	a5,8(a4)
ffffffffc0203b70:	e398                	sd	a4,0(a5)
ffffffffc0203b72:	da1fd0ef          	jal	ra,ffffffffc0201912 <kfree>
ffffffffc0203b76:	00843a03          	ld	s4,8(s0)
ffffffffc0203b7a:	ff4414e3          	bne	s0,s4,ffffffffc0203b62 <vmm_init+0x154>
ffffffffc0203b7e:	8522                	mv	a0,s0
ffffffffc0203b80:	d93fd0ef          	jal	ra,ffffffffc0201912 <kfree>
ffffffffc0203b84:	00003517          	auipc	a0,0x3
ffffffffc0203b88:	e7450513          	addi	a0,a0,-396 # ffffffffc02069f8 <default_pmm_manager+0xdd8>
ffffffffc0203b8c:	dfefc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0203b90:	f81fd0ef          	jal	ra,ffffffffc0201b10 <nr_free_pages>
ffffffffc0203b94:	84aa                	mv	s1,a0
ffffffffc0203b96:	03000513          	li	a0,48
ffffffffc0203b9a:	cd9fd0ef          	jal	ra,ffffffffc0201872 <kmalloc>
ffffffffc0203b9e:	842a                	mv	s0,a0
ffffffffc0203ba0:	22050463          	beqz	a0,ffffffffc0203dc8 <vmm_init+0x3ba>
ffffffffc0203ba4:	00012797          	auipc	a5,0x12
ffffffffc0203ba8:	9ec7a783          	lw	a5,-1556(a5) # ffffffffc0215590 <swap_init_ok>
ffffffffc0203bac:	e508                	sd	a0,8(a0)
ffffffffc0203bae:	e108                	sd	a0,0(a0)
ffffffffc0203bb0:	00053823          	sd	zero,16(a0)
ffffffffc0203bb4:	00053c23          	sd	zero,24(a0)
ffffffffc0203bb8:	02052023          	sw	zero,32(a0)
ffffffffc0203bbc:	22079a63          	bnez	a5,ffffffffc0203df0 <vmm_init+0x3e2>
ffffffffc0203bc0:	02053423          	sd	zero,40(a0)
ffffffffc0203bc4:	00012917          	auipc	s2,0x12
ffffffffc0203bc8:	9ac93903          	ld	s2,-1620(s2) # ffffffffc0215570 <boot_pgdir>
ffffffffc0203bcc:	00093783          	ld	a5,0(s2)
ffffffffc0203bd0:	00012717          	auipc	a4,0x12
ffffffffc0203bd4:	9e873023          	sd	s0,-1568(a4) # ffffffffc02155b0 <check_mm_struct>
ffffffffc0203bd8:	01243c23          	sd	s2,24(s0)
ffffffffc0203bdc:	3c079f63          	bnez	a5,ffffffffc0203fba <vmm_init+0x5ac>
ffffffffc0203be0:	03000513          	li	a0,48
ffffffffc0203be4:	c8ffd0ef          	jal	ra,ffffffffc0201872 <kmalloc>
ffffffffc0203be8:	89aa                	mv	s3,a0
ffffffffc0203bea:	1a050f63          	beqz	a0,ffffffffc0203da8 <vmm_init+0x39a>
ffffffffc0203bee:	002007b7          	lui	a5,0x200
ffffffffc0203bf2:	00f9b823          	sd	a5,16(s3)
ffffffffc0203bf6:	4789                	li	a5,2
ffffffffc0203bf8:	85aa                	mv	a1,a0
ffffffffc0203bfa:	00f9ac23          	sw	a5,24(s3)
ffffffffc0203bfe:	8522                	mv	a0,s0
ffffffffc0203c00:	0009b423          	sd	zero,8(s3)
ffffffffc0203c04:	d0dff0ef          	jal	ra,ffffffffc0203910 <insert_vma_struct>
ffffffffc0203c08:	10000593          	li	a1,256
ffffffffc0203c0c:	8522                	mv	a0,s0
ffffffffc0203c0e:	cc3ff0ef          	jal	ra,ffffffffc02038d0 <find_vma>
ffffffffc0203c12:	10000793          	li	a5,256
ffffffffc0203c16:	16400713          	li	a4,356
ffffffffc0203c1a:	38a99063          	bne	s3,a0,ffffffffc0203f9a <vmm_init+0x58c>
ffffffffc0203c1e:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
ffffffffc0203c22:	0785                	addi	a5,a5,1
ffffffffc0203c24:	fee79de3          	bne	a5,a4,ffffffffc0203c1e <vmm_init+0x210>
ffffffffc0203c28:	6705                	lui	a4,0x1
ffffffffc0203c2a:	10000793          	li	a5,256
ffffffffc0203c2e:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
ffffffffc0203c32:	16400613          	li	a2,356
ffffffffc0203c36:	0007c683          	lbu	a3,0(a5)
ffffffffc0203c3a:	0785                	addi	a5,a5,1
ffffffffc0203c3c:	9f15                	subw	a4,a4,a3
ffffffffc0203c3e:	fec79ce3          	bne	a5,a2,ffffffffc0203c36 <vmm_init+0x228>
ffffffffc0203c42:	32071c63          	bnez	a4,ffffffffc0203f7a <vmm_init+0x56c>
ffffffffc0203c46:	00093783          	ld	a5,0(s2)
ffffffffc0203c4a:	00012a97          	auipc	s5,0x12
ffffffffc0203c4e:	936a8a93          	addi	s5,s5,-1738 # ffffffffc0215580 <npage>
ffffffffc0203c52:	000ab703          	ld	a4,0(s5)
ffffffffc0203c56:	078a                	slli	a5,a5,0x2
ffffffffc0203c58:	83b1                	srli	a5,a5,0xc
ffffffffc0203c5a:	30e7f463          	bgeu	a5,a4,ffffffffc0203f62 <vmm_init+0x554>
ffffffffc0203c5e:	00003a17          	auipc	s4,0x3
ffffffffc0203c62:	39aa3a03          	ld	s4,922(s4) # ffffffffc0206ff8 <nbase>
ffffffffc0203c66:	414786b3          	sub	a3,a5,s4
ffffffffc0203c6a:	069a                	slli	a3,a3,0x6
ffffffffc0203c6c:	8699                	srai	a3,a3,0x6
ffffffffc0203c6e:	96d2                	add	a3,a3,s4
ffffffffc0203c70:	00c69793          	slli	a5,a3,0xc
ffffffffc0203c74:	83b1                	srli	a5,a5,0xc
ffffffffc0203c76:	06b2                	slli	a3,a3,0xc
ffffffffc0203c78:	2ce7f963          	bgeu	a5,a4,ffffffffc0203f4a <vmm_init+0x53c>
ffffffffc0203c7c:	00012797          	auipc	a5,0x12
ffffffffc0203c80:	8fc7b783          	ld	a5,-1796(a5) # ffffffffc0215578 <va_pa_offset>
ffffffffc0203c84:	4581                	li	a1,0
ffffffffc0203c86:	854a                	mv	a0,s2
ffffffffc0203c88:	00f689b3          	add	s3,a3,a5
ffffffffc0203c8c:	8e2fe0ef          	jal	ra,ffffffffc0201d6e <page_remove>
ffffffffc0203c90:	0009b783          	ld	a5,0(s3)
ffffffffc0203c94:	000ab703          	ld	a4,0(s5)
ffffffffc0203c98:	078a                	slli	a5,a5,0x2
ffffffffc0203c9a:	83b1                	srli	a5,a5,0xc
ffffffffc0203c9c:	2ce7f363          	bgeu	a5,a4,ffffffffc0203f62 <vmm_init+0x554>
ffffffffc0203ca0:	00012997          	auipc	s3,0x12
ffffffffc0203ca4:	8e898993          	addi	s3,s3,-1816 # ffffffffc0215588 <pages>
ffffffffc0203ca8:	0009b503          	ld	a0,0(s3)
ffffffffc0203cac:	414787b3          	sub	a5,a5,s4
ffffffffc0203cb0:	079a                	slli	a5,a5,0x6
ffffffffc0203cb2:	953e                	add	a0,a0,a5
ffffffffc0203cb4:	4585                	li	a1,1
ffffffffc0203cb6:	e1bfd0ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0203cba:	00093783          	ld	a5,0(s2)
ffffffffc0203cbe:	000ab703          	ld	a4,0(s5)
ffffffffc0203cc2:	078a                	slli	a5,a5,0x2
ffffffffc0203cc4:	83b1                	srli	a5,a5,0xc
ffffffffc0203cc6:	28e7fe63          	bgeu	a5,a4,ffffffffc0203f62 <vmm_init+0x554>
ffffffffc0203cca:	0009b503          	ld	a0,0(s3)
ffffffffc0203cce:	414787b3          	sub	a5,a5,s4
ffffffffc0203cd2:	079a                	slli	a5,a5,0x6
ffffffffc0203cd4:	4585                	li	a1,1
ffffffffc0203cd6:	953e                	add	a0,a0,a5
ffffffffc0203cd8:	df9fd0ef          	jal	ra,ffffffffc0201ad0 <free_pages>
ffffffffc0203cdc:	00093023          	sd	zero,0(s2)
ffffffffc0203ce0:	12000073          	sfence.vma
ffffffffc0203ce4:	6408                	ld	a0,8(s0)
ffffffffc0203ce6:	00043c23          	sd	zero,24(s0)
ffffffffc0203cea:	00a40c63          	beq	s0,a0,ffffffffc0203d02 <vmm_init+0x2f4>
ffffffffc0203cee:	6118                	ld	a4,0(a0)
ffffffffc0203cf0:	651c                	ld	a5,8(a0)
ffffffffc0203cf2:	1501                	addi	a0,a0,-32
ffffffffc0203cf4:	e71c                	sd	a5,8(a4)
ffffffffc0203cf6:	e398                	sd	a4,0(a5)
ffffffffc0203cf8:	c1bfd0ef          	jal	ra,ffffffffc0201912 <kfree>
ffffffffc0203cfc:	6408                	ld	a0,8(s0)
ffffffffc0203cfe:	fea418e3          	bne	s0,a0,ffffffffc0203cee <vmm_init+0x2e0>
ffffffffc0203d02:	8522                	mv	a0,s0
ffffffffc0203d04:	c0ffd0ef          	jal	ra,ffffffffc0201912 <kfree>
ffffffffc0203d08:	00012797          	auipc	a5,0x12
ffffffffc0203d0c:	8a07b423          	sd	zero,-1880(a5) # ffffffffc02155b0 <check_mm_struct>
ffffffffc0203d10:	e01fd0ef          	jal	ra,ffffffffc0201b10 <nr_free_pages>
ffffffffc0203d14:	2ca49363          	bne	s1,a0,ffffffffc0203fda <vmm_init+0x5cc>
ffffffffc0203d18:	00003517          	auipc	a0,0x3
ffffffffc0203d1c:	d7050513          	addi	a0,a0,-656 # ffffffffc0206a88 <default_pmm_manager+0xe68>
ffffffffc0203d20:	c6afc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0203d24:	7442                	ld	s0,48(sp)
ffffffffc0203d26:	70e2                	ld	ra,56(sp)
ffffffffc0203d28:	74a2                	ld	s1,40(sp)
ffffffffc0203d2a:	7902                	ld	s2,32(sp)
ffffffffc0203d2c:	69e2                	ld	s3,24(sp)
ffffffffc0203d2e:	6a42                	ld	s4,16(sp)
ffffffffc0203d30:	6aa2                	ld	s5,8(sp)
ffffffffc0203d32:	6b02                	ld	s6,0(sp)
ffffffffc0203d34:	00003517          	auipc	a0,0x3
ffffffffc0203d38:	d7450513          	addi	a0,a0,-652 # ffffffffc0206aa8 <default_pmm_manager+0xe88>
ffffffffc0203d3c:	6121                	addi	sp,sp,64
ffffffffc0203d3e:	c4cfc06f          	j	ffffffffc020018a <cprintf>
ffffffffc0203d42:	d6cff0ef          	jal	ra,ffffffffc02032ae <swap_init_mm>
ffffffffc0203d46:	b321                	j	ffffffffc0203a4e <vmm_init+0x40>
ffffffffc0203d48:	00002697          	auipc	a3,0x2
ffffffffc0203d4c:	62068693          	addi	a3,a3,1568 # ffffffffc0206368 <default_pmm_manager+0x748>
ffffffffc0203d50:	00002617          	auipc	a2,0x2
ffffffffc0203d54:	b2060613          	addi	a2,a2,-1248 # ffffffffc0205870 <commands+0x738>
ffffffffc0203d58:	0ef00593          	li	a1,239
ffffffffc0203d5c:	00003517          	auipc	a0,0x3
ffffffffc0203d60:	aec50513          	addi	a0,a0,-1300 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203d64:	edafc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203d68:	00002697          	auipc	a3,0x2
ffffffffc0203d6c:	5c868693          	addi	a3,a3,1480 # ffffffffc0206330 <default_pmm_manager+0x710>
ffffffffc0203d70:	00002617          	auipc	a2,0x2
ffffffffc0203d74:	b0060613          	addi	a2,a2,-1280 # ffffffffc0205870 <commands+0x738>
ffffffffc0203d78:	0e800593          	li	a1,232
ffffffffc0203d7c:	00003517          	auipc	a0,0x3
ffffffffc0203d80:	acc50513          	addi	a0,a0,-1332 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203d84:	ebafc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203d88:	00002697          	auipc	a3,0x2
ffffffffc0203d8c:	5e068693          	addi	a3,a3,1504 # ffffffffc0206368 <default_pmm_manager+0x748>
ffffffffc0203d90:	00002617          	auipc	a2,0x2
ffffffffc0203d94:	ae060613          	addi	a2,a2,-1312 # ffffffffc0205870 <commands+0x738>
ffffffffc0203d98:	0f500593          	li	a1,245
ffffffffc0203d9c:	00003517          	auipc	a0,0x3
ffffffffc0203da0:	aac50513          	addi	a0,a0,-1364 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203da4:	e9afc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203da8:	00002697          	auipc	a3,0x2
ffffffffc0203dac:	5c068693          	addi	a3,a3,1472 # ffffffffc0206368 <default_pmm_manager+0x748>
ffffffffc0203db0:	00002617          	auipc	a2,0x2
ffffffffc0203db4:	ac060613          	addi	a2,a2,-1344 # ffffffffc0205870 <commands+0x738>
ffffffffc0203db8:	12e00593          	li	a1,302
ffffffffc0203dbc:	00003517          	auipc	a0,0x3
ffffffffc0203dc0:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203dc4:	e7afc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203dc8:	00003697          	auipc	a3,0x3
ffffffffc0203dcc:	c5068693          	addi	a3,a3,-944 # ffffffffc0206a18 <default_pmm_manager+0xdf8>
ffffffffc0203dd0:	00002617          	auipc	a2,0x2
ffffffffc0203dd4:	aa060613          	addi	a2,a2,-1376 # ffffffffc0205870 <commands+0x738>
ffffffffc0203dd8:	12700593          	li	a1,295
ffffffffc0203ddc:	00003517          	auipc	a0,0x3
ffffffffc0203de0:	a6c50513          	addi	a0,a0,-1428 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203de4:	00011797          	auipc	a5,0x11
ffffffffc0203de8:	7c07b623          	sd	zero,1996(a5) # ffffffffc02155b0 <check_mm_struct>
ffffffffc0203dec:	e52fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203df0:	cbeff0ef          	jal	ra,ffffffffc02032ae <swap_init_mm>
ffffffffc0203df4:	bbc1                	j	ffffffffc0203bc4 <vmm_init+0x1b6>
ffffffffc0203df6:	00003697          	auipc	a3,0x3
ffffffffc0203dfa:	b9268693          	addi	a3,a3,-1134 # ffffffffc0206988 <default_pmm_manager+0xd68>
ffffffffc0203dfe:	00002617          	auipc	a2,0x2
ffffffffc0203e02:	a7260613          	addi	a2,a2,-1422 # ffffffffc0205870 <commands+0x738>
ffffffffc0203e06:	10f00593          	li	a1,271
ffffffffc0203e0a:	00003517          	auipc	a0,0x3
ffffffffc0203e0e:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203e12:	e2cfc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203e16:	00003697          	auipc	a3,0x3
ffffffffc0203e1a:	b4268693          	addi	a3,a3,-1214 # ffffffffc0206958 <default_pmm_manager+0xd38>
ffffffffc0203e1e:	00002617          	auipc	a2,0x2
ffffffffc0203e22:	a5260613          	addi	a2,a2,-1454 # ffffffffc0205870 <commands+0x738>
ffffffffc0203e26:	10e00593          	li	a1,270
ffffffffc0203e2a:	00003517          	auipc	a0,0x3
ffffffffc0203e2e:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203e32:	e0cfc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203e36:	00003697          	auipc	a3,0x3
ffffffffc0203e3a:	a9a68693          	addi	a3,a3,-1382 # ffffffffc02068d0 <default_pmm_manager+0xcb0>
ffffffffc0203e3e:	00002617          	auipc	a2,0x2
ffffffffc0203e42:	a3260613          	addi	a2,a2,-1486 # ffffffffc0205870 <commands+0x738>
ffffffffc0203e46:	0fe00593          	li	a1,254
ffffffffc0203e4a:	00003517          	auipc	a0,0x3
ffffffffc0203e4e:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203e52:	decfc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203e56:	00003697          	auipc	a3,0x3
ffffffffc0203e5a:	a6268693          	addi	a3,a3,-1438 # ffffffffc02068b8 <default_pmm_manager+0xc98>
ffffffffc0203e5e:	00002617          	auipc	a2,0x2
ffffffffc0203e62:	a1260613          	addi	a2,a2,-1518 # ffffffffc0205870 <commands+0x738>
ffffffffc0203e66:	0fc00593          	li	a1,252
ffffffffc0203e6a:	00003517          	auipc	a0,0x3
ffffffffc0203e6e:	9de50513          	addi	a0,a0,-1570 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203e72:	dccfc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203e76:	00003697          	auipc	a3,0x3
ffffffffc0203e7a:	aa268693          	addi	a3,a3,-1374 # ffffffffc0206918 <default_pmm_manager+0xcf8>
ffffffffc0203e7e:	00002617          	auipc	a2,0x2
ffffffffc0203e82:	9f260613          	addi	a2,a2,-1550 # ffffffffc0205870 <commands+0x738>
ffffffffc0203e86:	10600593          	li	a1,262
ffffffffc0203e8a:	00003517          	auipc	a0,0x3
ffffffffc0203e8e:	9be50513          	addi	a0,a0,-1602 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203e92:	dacfc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203e96:	00003697          	auipc	a3,0x3
ffffffffc0203e9a:	a7268693          	addi	a3,a3,-1422 # ffffffffc0206908 <default_pmm_manager+0xce8>
ffffffffc0203e9e:	00002617          	auipc	a2,0x2
ffffffffc0203ea2:	9d260613          	addi	a2,a2,-1582 # ffffffffc0205870 <commands+0x738>
ffffffffc0203ea6:	10400593          	li	a1,260
ffffffffc0203eaa:	00003517          	auipc	a0,0x3
ffffffffc0203eae:	99e50513          	addi	a0,a0,-1634 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203eb2:	d8cfc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203eb6:	00003697          	auipc	a3,0x3
ffffffffc0203eba:	a9268693          	addi	a3,a3,-1390 # ffffffffc0206948 <default_pmm_manager+0xd28>
ffffffffc0203ebe:	00002617          	auipc	a2,0x2
ffffffffc0203ec2:	9b260613          	addi	a2,a2,-1614 # ffffffffc0205870 <commands+0x738>
ffffffffc0203ec6:	10c00593          	li	a1,268
ffffffffc0203eca:	00003517          	auipc	a0,0x3
ffffffffc0203ece:	97e50513          	addi	a0,a0,-1666 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203ed2:	d6cfc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203ed6:	00003697          	auipc	a3,0x3
ffffffffc0203eda:	a6268693          	addi	a3,a3,-1438 # ffffffffc0206938 <default_pmm_manager+0xd18>
ffffffffc0203ede:	00002617          	auipc	a2,0x2
ffffffffc0203ee2:	99260613          	addi	a2,a2,-1646 # ffffffffc0205870 <commands+0x738>
ffffffffc0203ee6:	10a00593          	li	a1,266
ffffffffc0203eea:	00003517          	auipc	a0,0x3
ffffffffc0203eee:	95e50513          	addi	a0,a0,-1698 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203ef2:	d4cfc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203ef6:	00003697          	auipc	a3,0x3
ffffffffc0203efa:	a3268693          	addi	a3,a3,-1486 # ffffffffc0206928 <default_pmm_manager+0xd08>
ffffffffc0203efe:	00002617          	auipc	a2,0x2
ffffffffc0203f02:	97260613          	addi	a2,a2,-1678 # ffffffffc0205870 <commands+0x738>
ffffffffc0203f06:	10800593          	li	a1,264
ffffffffc0203f0a:	00003517          	auipc	a0,0x3
ffffffffc0203f0e:	93e50513          	addi	a0,a0,-1730 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203f12:	d2cfc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203f16:	6914                	ld	a3,16(a0)
ffffffffc0203f18:	6510                	ld	a2,8(a0)
ffffffffc0203f1a:	0004859b          	sext.w	a1,s1
ffffffffc0203f1e:	00003517          	auipc	a0,0x3
ffffffffc0203f22:	a9a50513          	addi	a0,a0,-1382 # ffffffffc02069b8 <default_pmm_manager+0xd98>
ffffffffc0203f26:	a64fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0203f2a:	00003697          	auipc	a3,0x3
ffffffffc0203f2e:	ab668693          	addi	a3,a3,-1354 # ffffffffc02069e0 <default_pmm_manager+0xdc0>
ffffffffc0203f32:	00002617          	auipc	a2,0x2
ffffffffc0203f36:	93e60613          	addi	a2,a2,-1730 # ffffffffc0205870 <commands+0x738>
ffffffffc0203f3a:	11700593          	li	a1,279
ffffffffc0203f3e:	00003517          	auipc	a0,0x3
ffffffffc0203f42:	90a50513          	addi	a0,a0,-1782 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203f46:	cf8fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203f4a:	00002617          	auipc	a2,0x2
ffffffffc0203f4e:	d0e60613          	addi	a2,a2,-754 # ffffffffc0205c58 <default_pmm_manager+0x38>
ffffffffc0203f52:	08b00593          	li	a1,139
ffffffffc0203f56:	00002517          	auipc	a0,0x2
ffffffffc0203f5a:	d2a50513          	addi	a0,a0,-726 # ffffffffc0205c80 <default_pmm_manager+0x60>
ffffffffc0203f5e:	ce0fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203f62:	00002617          	auipc	a2,0x2
ffffffffc0203f66:	dc660613          	addi	a2,a2,-570 # ffffffffc0205d28 <default_pmm_manager+0x108>
ffffffffc0203f6a:	08000593          	li	a1,128
ffffffffc0203f6e:	00002517          	auipc	a0,0x2
ffffffffc0203f72:	d1250513          	addi	a0,a0,-750 # ffffffffc0205c80 <default_pmm_manager+0x60>
ffffffffc0203f76:	cc8fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203f7a:	00003697          	auipc	a3,0x3
ffffffffc0203f7e:	ad668693          	addi	a3,a3,-1322 # ffffffffc0206a50 <default_pmm_manager+0xe30>
ffffffffc0203f82:	00002617          	auipc	a2,0x2
ffffffffc0203f86:	8ee60613          	addi	a2,a2,-1810 # ffffffffc0205870 <commands+0x738>
ffffffffc0203f8a:	13d00593          	li	a1,317
ffffffffc0203f8e:	00003517          	auipc	a0,0x3
ffffffffc0203f92:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203f96:	ca8fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203f9a:	00003697          	auipc	a3,0x3
ffffffffc0203f9e:	a9668693          	addi	a3,a3,-1386 # ffffffffc0206a30 <default_pmm_manager+0xe10>
ffffffffc0203fa2:	00002617          	auipc	a2,0x2
ffffffffc0203fa6:	8ce60613          	addi	a2,a2,-1842 # ffffffffc0205870 <commands+0x738>
ffffffffc0203faa:	13300593          	li	a1,307
ffffffffc0203fae:	00003517          	auipc	a0,0x3
ffffffffc0203fb2:	89a50513          	addi	a0,a0,-1894 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203fb6:	c88fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203fba:	00002697          	auipc	a3,0x2
ffffffffc0203fbe:	39e68693          	addi	a3,a3,926 # ffffffffc0206358 <default_pmm_manager+0x738>
ffffffffc0203fc2:	00002617          	auipc	a2,0x2
ffffffffc0203fc6:	8ae60613          	addi	a2,a2,-1874 # ffffffffc0205870 <commands+0x738>
ffffffffc0203fca:	12b00593          	li	a1,299
ffffffffc0203fce:	00003517          	auipc	a0,0x3
ffffffffc0203fd2:	87a50513          	addi	a0,a0,-1926 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203fd6:	c68fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203fda:	00003697          	auipc	a3,0x3
ffffffffc0203fde:	a8668693          	addi	a3,a3,-1402 # ffffffffc0206a60 <default_pmm_manager+0xe40>
ffffffffc0203fe2:	00002617          	auipc	a2,0x2
ffffffffc0203fe6:	88e60613          	addi	a2,a2,-1906 # ffffffffc0205870 <commands+0x738>
ffffffffc0203fea:	14a00593          	li	a1,330
ffffffffc0203fee:	00003517          	auipc	a0,0x3
ffffffffc0203ff2:	85a50513          	addi	a0,a0,-1958 # ffffffffc0206848 <default_pmm_manager+0xc28>
ffffffffc0203ff6:	c48fc0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0203ffa <do_pgfault>:
ffffffffc0203ffa:	7179                	addi	sp,sp,-48
ffffffffc0203ffc:	85b2                	mv	a1,a2
ffffffffc0203ffe:	f022                	sd	s0,32(sp)
ffffffffc0204000:	ec26                	sd	s1,24(sp)
ffffffffc0204002:	f406                	sd	ra,40(sp)
ffffffffc0204004:	e84a                	sd	s2,16(sp)
ffffffffc0204006:	8432                	mv	s0,a2
ffffffffc0204008:	84aa                	mv	s1,a0
ffffffffc020400a:	8c7ff0ef          	jal	ra,ffffffffc02038d0 <find_vma>
ffffffffc020400e:	00011797          	auipc	a5,0x11
ffffffffc0204012:	59a7a783          	lw	a5,1434(a5) # ffffffffc02155a8 <pgfault_num>
ffffffffc0204016:	2785                	addiw	a5,a5,1
ffffffffc0204018:	00011717          	auipc	a4,0x11
ffffffffc020401c:	58f72823          	sw	a5,1424(a4) # ffffffffc02155a8 <pgfault_num>
ffffffffc0204020:	c549                	beqz	a0,ffffffffc02040aa <do_pgfault+0xb0>
ffffffffc0204022:	651c                	ld	a5,8(a0)
ffffffffc0204024:	08f46363          	bltu	s0,a5,ffffffffc02040aa <do_pgfault+0xb0>
ffffffffc0204028:	4d1c                	lw	a5,24(a0)
ffffffffc020402a:	495d                	li	s2,23
ffffffffc020402c:	8b89                	andi	a5,a5,2
ffffffffc020402e:	cfb1                	beqz	a5,ffffffffc020408a <do_pgfault+0x90>
ffffffffc0204030:	77fd                	lui	a5,0xfffff
ffffffffc0204032:	6c88                	ld	a0,24(s1)
ffffffffc0204034:	8c7d                	and	s0,s0,a5
ffffffffc0204036:	4605                	li	a2,1
ffffffffc0204038:	85a2                	mv	a1,s0
ffffffffc020403a:	b11fd0ef          	jal	ra,ffffffffc0201b4a <get_pte>
ffffffffc020403e:	cd5d                	beqz	a0,ffffffffc02040fc <do_pgfault+0x102>
ffffffffc0204040:	610c                	ld	a1,0(a0)
ffffffffc0204042:	c5b1                	beqz	a1,ffffffffc020408e <do_pgfault+0x94>
ffffffffc0204044:	00011797          	auipc	a5,0x11
ffffffffc0204048:	54c7a783          	lw	a5,1356(a5) # ffffffffc0215590 <swap_init_ok>
ffffffffc020404c:	cba5                	beqz	a5,ffffffffc02040bc <do_pgfault+0xc2>
ffffffffc020404e:	0030                	addi	a2,sp,8
ffffffffc0204050:	85a2                	mv	a1,s0
ffffffffc0204052:	8526                	mv	a0,s1
ffffffffc0204054:	e402                	sd	zero,8(sp)
ffffffffc0204056:	b84ff0ef          	jal	ra,ffffffffc02033da <swap_in>
ffffffffc020405a:	e92d                	bnez	a0,ffffffffc02040cc <do_pgfault+0xd2>
ffffffffc020405c:	65a2                	ld	a1,8(sp)
ffffffffc020405e:	6c88                	ld	a0,24(s1)
ffffffffc0204060:	86ca                	mv	a3,s2
ffffffffc0204062:	8622                	mv	a2,s0
ffffffffc0204064:	da7fd0ef          	jal	ra,ffffffffc0201e0a <page_insert>
ffffffffc0204068:	e935                	bnez	a0,ffffffffc02040dc <do_pgfault+0xe2>
ffffffffc020406a:	6622                	ld	a2,8(sp)
ffffffffc020406c:	4685                	li	a3,1
ffffffffc020406e:	85a2                	mv	a1,s0
ffffffffc0204070:	8526                	mv	a0,s1
ffffffffc0204072:	a48ff0ef          	jal	ra,ffffffffc02032ba <swap_map_swappable>
ffffffffc0204076:	e93d                	bnez	a0,ffffffffc02040ec <do_pgfault+0xf2>
ffffffffc0204078:	67a2                	ld	a5,8(sp)
ffffffffc020407a:	ff80                	sd	s0,56(a5)
ffffffffc020407c:	4501                	li	a0,0
ffffffffc020407e:	70a2                	ld	ra,40(sp)
ffffffffc0204080:	7402                	ld	s0,32(sp)
ffffffffc0204082:	64e2                	ld	s1,24(sp)
ffffffffc0204084:	6942                	ld	s2,16(sp)
ffffffffc0204086:	6145                	addi	sp,sp,48
ffffffffc0204088:	8082                	ret
ffffffffc020408a:	4941                	li	s2,16
ffffffffc020408c:	b755                	j	ffffffffc0204030 <do_pgfault+0x36>
ffffffffc020408e:	6c88                	ld	a0,24(s1)
ffffffffc0204090:	864a                	mv	a2,s2
ffffffffc0204092:	85a2                	mv	a1,s0
ffffffffc0204094:	a0ffe0ef          	jal	ra,ffffffffc0202aa2 <pgdir_alloc_page>
ffffffffc0204098:	f175                	bnez	a0,ffffffffc020407c <do_pgfault+0x82>
ffffffffc020409a:	00003517          	auipc	a0,0x3
ffffffffc020409e:	a7650513          	addi	a0,a0,-1418 # ffffffffc0206b10 <default_pmm_manager+0xef0>
ffffffffc02040a2:	8e8fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02040a6:	5571                	li	a0,-4
ffffffffc02040a8:	bfd9                	j	ffffffffc020407e <do_pgfault+0x84>
ffffffffc02040aa:	85a2                	mv	a1,s0
ffffffffc02040ac:	00003517          	auipc	a0,0x3
ffffffffc02040b0:	a1450513          	addi	a0,a0,-1516 # ffffffffc0206ac0 <default_pmm_manager+0xea0>
ffffffffc02040b4:	8d6fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02040b8:	5575                	li	a0,-3
ffffffffc02040ba:	b7d1                	j	ffffffffc020407e <do_pgfault+0x84>
ffffffffc02040bc:	00003517          	auipc	a0,0x3
ffffffffc02040c0:	ac450513          	addi	a0,a0,-1340 # ffffffffc0206b80 <default_pmm_manager+0xf60>
ffffffffc02040c4:	8c6fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02040c8:	5571                	li	a0,-4
ffffffffc02040ca:	bf55                	j	ffffffffc020407e <do_pgfault+0x84>
ffffffffc02040cc:	00003517          	auipc	a0,0x3
ffffffffc02040d0:	a6c50513          	addi	a0,a0,-1428 # ffffffffc0206b38 <default_pmm_manager+0xf18>
ffffffffc02040d4:	8b6fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02040d8:	5571                	li	a0,-4
ffffffffc02040da:	b755                	j	ffffffffc020407e <do_pgfault+0x84>
ffffffffc02040dc:	00003517          	auipc	a0,0x3
ffffffffc02040e0:	a6c50513          	addi	a0,a0,-1428 # ffffffffc0206b48 <default_pmm_manager+0xf28>
ffffffffc02040e4:	8a6fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02040e8:	5571                	li	a0,-4
ffffffffc02040ea:	bf51                	j	ffffffffc020407e <do_pgfault+0x84>
ffffffffc02040ec:	00003517          	auipc	a0,0x3
ffffffffc02040f0:	a7450513          	addi	a0,a0,-1420 # ffffffffc0206b60 <default_pmm_manager+0xf40>
ffffffffc02040f4:	896fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02040f8:	5571                	li	a0,-4
ffffffffc02040fa:	b751                	j	ffffffffc020407e <do_pgfault+0x84>
ffffffffc02040fc:	00003517          	auipc	a0,0x3
ffffffffc0204100:	9f450513          	addi	a0,a0,-1548 # ffffffffc0206af0 <default_pmm_manager+0xed0>
ffffffffc0204104:	886fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0204108:	5571                	li	a0,-4
ffffffffc020410a:	bf95                	j	ffffffffc020407e <do_pgfault+0x84>

ffffffffc020410c <swapfs_init>:
ffffffffc020410c:	1141                	addi	sp,sp,-16
ffffffffc020410e:	4505                	li	a0,1
ffffffffc0204110:	e406                	sd	ra,8(sp)
ffffffffc0204112:	c4efc0ef          	jal	ra,ffffffffc0200560 <ide_device_valid>
ffffffffc0204116:	cd01                	beqz	a0,ffffffffc020412e <swapfs_init+0x22>
ffffffffc0204118:	4505                	li	a0,1
ffffffffc020411a:	c4cfc0ef          	jal	ra,ffffffffc0200566 <ide_device_size>
ffffffffc020411e:	60a2                	ld	ra,8(sp)
ffffffffc0204120:	810d                	srli	a0,a0,0x3
ffffffffc0204122:	00011797          	auipc	a5,0x11
ffffffffc0204126:	46a7bb23          	sd	a0,1142(a5) # ffffffffc0215598 <max_swap_offset>
ffffffffc020412a:	0141                	addi	sp,sp,16
ffffffffc020412c:	8082                	ret
ffffffffc020412e:	00003617          	auipc	a2,0x3
ffffffffc0204132:	a7a60613          	addi	a2,a2,-1414 # ffffffffc0206ba8 <default_pmm_manager+0xf88>
ffffffffc0204136:	45b9                	li	a1,14
ffffffffc0204138:	00003517          	auipc	a0,0x3
ffffffffc020413c:	a9050513          	addi	a0,a0,-1392 # ffffffffc0206bc8 <default_pmm_manager+0xfa8>
ffffffffc0204140:	afefc0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0204144 <swapfs_read>:
ffffffffc0204144:	1141                	addi	sp,sp,-16
ffffffffc0204146:	e406                	sd	ra,8(sp)
ffffffffc0204148:	00855793          	srli	a5,a0,0x8
ffffffffc020414c:	cbb1                	beqz	a5,ffffffffc02041a0 <swapfs_read+0x5c>
ffffffffc020414e:	00011717          	auipc	a4,0x11
ffffffffc0204152:	44a73703          	ld	a4,1098(a4) # ffffffffc0215598 <max_swap_offset>
ffffffffc0204156:	04e7f563          	bgeu	a5,a4,ffffffffc02041a0 <swapfs_read+0x5c>
ffffffffc020415a:	00011717          	auipc	a4,0x11
ffffffffc020415e:	42e73703          	ld	a4,1070(a4) # ffffffffc0215588 <pages>
ffffffffc0204162:	8d99                	sub	a1,a1,a4
ffffffffc0204164:	4065d613          	srai	a2,a1,0x6
ffffffffc0204168:	00003717          	auipc	a4,0x3
ffffffffc020416c:	e9073703          	ld	a4,-368(a4) # ffffffffc0206ff8 <nbase>
ffffffffc0204170:	963a                	add	a2,a2,a4
ffffffffc0204172:	00c61713          	slli	a4,a2,0xc
ffffffffc0204176:	8331                	srli	a4,a4,0xc
ffffffffc0204178:	00011697          	auipc	a3,0x11
ffffffffc020417c:	4086b683          	ld	a3,1032(a3) # ffffffffc0215580 <npage>
ffffffffc0204180:	0037959b          	slliw	a1,a5,0x3
ffffffffc0204184:	0632                	slli	a2,a2,0xc
ffffffffc0204186:	02d77963          	bgeu	a4,a3,ffffffffc02041b8 <swapfs_read+0x74>
ffffffffc020418a:	60a2                	ld	ra,8(sp)
ffffffffc020418c:	00011797          	auipc	a5,0x11
ffffffffc0204190:	3ec7b783          	ld	a5,1004(a5) # ffffffffc0215578 <va_pa_offset>
ffffffffc0204194:	46a1                	li	a3,8
ffffffffc0204196:	963e                	add	a2,a2,a5
ffffffffc0204198:	4505                	li	a0,1
ffffffffc020419a:	0141                	addi	sp,sp,16
ffffffffc020419c:	bd0fc06f          	j	ffffffffc020056c <ide_read_secs>
ffffffffc02041a0:	86aa                	mv	a3,a0
ffffffffc02041a2:	00003617          	auipc	a2,0x3
ffffffffc02041a6:	a3e60613          	addi	a2,a2,-1474 # ffffffffc0206be0 <default_pmm_manager+0xfc0>
ffffffffc02041aa:	45e5                	li	a1,25
ffffffffc02041ac:	00003517          	auipc	a0,0x3
ffffffffc02041b0:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0206bc8 <default_pmm_manager+0xfa8>
ffffffffc02041b4:	a8afc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02041b8:	86b2                	mv	a3,a2
ffffffffc02041ba:	08b00593          	li	a1,139
ffffffffc02041be:	00002617          	auipc	a2,0x2
ffffffffc02041c2:	a9a60613          	addi	a2,a2,-1382 # ffffffffc0205c58 <default_pmm_manager+0x38>
ffffffffc02041c6:	00002517          	auipc	a0,0x2
ffffffffc02041ca:	aba50513          	addi	a0,a0,-1350 # ffffffffc0205c80 <default_pmm_manager+0x60>
ffffffffc02041ce:	a70fc0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc02041d2 <swapfs_write>:
ffffffffc02041d2:	1141                	addi	sp,sp,-16
ffffffffc02041d4:	e406                	sd	ra,8(sp)
ffffffffc02041d6:	00855793          	srli	a5,a0,0x8
ffffffffc02041da:	cbb1                	beqz	a5,ffffffffc020422e <swapfs_write+0x5c>
ffffffffc02041dc:	00011717          	auipc	a4,0x11
ffffffffc02041e0:	3bc73703          	ld	a4,956(a4) # ffffffffc0215598 <max_swap_offset>
ffffffffc02041e4:	04e7f563          	bgeu	a5,a4,ffffffffc020422e <swapfs_write+0x5c>
ffffffffc02041e8:	00011717          	auipc	a4,0x11
ffffffffc02041ec:	3a073703          	ld	a4,928(a4) # ffffffffc0215588 <pages>
ffffffffc02041f0:	8d99                	sub	a1,a1,a4
ffffffffc02041f2:	4065d613          	srai	a2,a1,0x6
ffffffffc02041f6:	00003717          	auipc	a4,0x3
ffffffffc02041fa:	e0273703          	ld	a4,-510(a4) # ffffffffc0206ff8 <nbase>
ffffffffc02041fe:	963a                	add	a2,a2,a4
ffffffffc0204200:	00c61713          	slli	a4,a2,0xc
ffffffffc0204204:	8331                	srli	a4,a4,0xc
ffffffffc0204206:	00011697          	auipc	a3,0x11
ffffffffc020420a:	37a6b683          	ld	a3,890(a3) # ffffffffc0215580 <npage>
ffffffffc020420e:	0037959b          	slliw	a1,a5,0x3
ffffffffc0204212:	0632                	slli	a2,a2,0xc
ffffffffc0204214:	02d77963          	bgeu	a4,a3,ffffffffc0204246 <swapfs_write+0x74>
ffffffffc0204218:	60a2                	ld	ra,8(sp)
ffffffffc020421a:	00011797          	auipc	a5,0x11
ffffffffc020421e:	35e7b783          	ld	a5,862(a5) # ffffffffc0215578 <va_pa_offset>
ffffffffc0204222:	46a1                	li	a3,8
ffffffffc0204224:	963e                	add	a2,a2,a5
ffffffffc0204226:	4505                	li	a0,1
ffffffffc0204228:	0141                	addi	sp,sp,16
ffffffffc020422a:	b66fc06f          	j	ffffffffc0200590 <ide_write_secs>
ffffffffc020422e:	86aa                	mv	a3,a0
ffffffffc0204230:	00003617          	auipc	a2,0x3
ffffffffc0204234:	9b060613          	addi	a2,a2,-1616 # ffffffffc0206be0 <default_pmm_manager+0xfc0>
ffffffffc0204238:	45f9                	li	a1,30
ffffffffc020423a:	00003517          	auipc	a0,0x3
ffffffffc020423e:	98e50513          	addi	a0,a0,-1650 # ffffffffc0206bc8 <default_pmm_manager+0xfa8>
ffffffffc0204242:	9fcfc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0204246:	86b2                	mv	a3,a2
ffffffffc0204248:	08b00593          	li	a1,139
ffffffffc020424c:	00002617          	auipc	a2,0x2
ffffffffc0204250:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0205c58 <default_pmm_manager+0x38>
ffffffffc0204254:	00002517          	auipc	a0,0x2
ffffffffc0204258:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0205c80 <default_pmm_manager+0x60>
ffffffffc020425c:	9e2fc0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0204260 <kernel_thread_entry>:
ffffffffc0204260:	8526                	mv	a0,s1
ffffffffc0204262:	9402                	jalr	s0
ffffffffc0204264:	3d4000ef          	jal	ra,ffffffffc0204638 <do_exit>

ffffffffc0204268 <alloc_proc>:
ffffffffc0204268:	1141                	addi	sp,sp,-16
ffffffffc020426a:	0e800513          	li	a0,232
ffffffffc020426e:	e022                	sd	s0,0(sp)
ffffffffc0204270:	e406                	sd	ra,8(sp)
ffffffffc0204272:	e00fd0ef          	jal	ra,ffffffffc0201872 <kmalloc>
ffffffffc0204276:	842a                	mv	s0,a0
ffffffffc0204278:	c521                	beqz	a0,ffffffffc02042c0 <alloc_proc+0x58>
ffffffffc020427a:	57fd                	li	a5,-1
ffffffffc020427c:	1782                	slli	a5,a5,0x20
ffffffffc020427e:	e11c                	sd	a5,0(a0)
ffffffffc0204280:	07000613          	li	a2,112
ffffffffc0204284:	4581                	li	a1,0
ffffffffc0204286:	00052423          	sw	zero,8(a0)
ffffffffc020428a:	00053823          	sd	zero,16(a0)
ffffffffc020428e:	00052c23          	sw	zero,24(a0)
ffffffffc0204292:	02053023          	sd	zero,32(a0)
ffffffffc0204296:	02053423          	sd	zero,40(a0)
ffffffffc020429a:	03050513          	addi	a0,a0,48
ffffffffc020429e:	3e3000ef          	jal	ra,ffffffffc0204e80 <memset>
ffffffffc02042a2:	00011797          	auipc	a5,0x11
ffffffffc02042a6:	2c67b783          	ld	a5,710(a5) # ffffffffc0215568 <boot_cr3>
ffffffffc02042aa:	0a043023          	sd	zero,160(s0)
ffffffffc02042ae:	f45c                	sd	a5,168(s0)
ffffffffc02042b0:	0a042823          	sw	zero,176(s0)
ffffffffc02042b4:	463d                	li	a2,15
ffffffffc02042b6:	4581                	li	a1,0
ffffffffc02042b8:	0b440513          	addi	a0,s0,180
ffffffffc02042bc:	3c5000ef          	jal	ra,ffffffffc0204e80 <memset>
ffffffffc02042c0:	60a2                	ld	ra,8(sp)
ffffffffc02042c2:	8522                	mv	a0,s0
ffffffffc02042c4:	6402                	ld	s0,0(sp)
ffffffffc02042c6:	0141                	addi	sp,sp,16
ffffffffc02042c8:	8082                	ret

ffffffffc02042ca <forkret>:
ffffffffc02042ca:	00011797          	auipc	a5,0x11
ffffffffc02042ce:	2f67b783          	ld	a5,758(a5) # ffffffffc02155c0 <current>
ffffffffc02042d2:	73c8                	ld	a0,160(a5)
ffffffffc02042d4:	8b9fc06f          	j	ffffffffc0200b8c <forkrets>

ffffffffc02042d8 <init_main>:
ffffffffc02042d8:	1101                	addi	sp,sp,-32
ffffffffc02042da:	e822                	sd	s0,16(sp)
ffffffffc02042dc:	e426                	sd	s1,8(sp)
ffffffffc02042de:	842a                	mv	s0,a0
ffffffffc02042e0:	00011497          	auipc	s1,0x11
ffffffffc02042e4:	2e04b483          	ld	s1,736(s1) # ffffffffc02155c0 <current>
ffffffffc02042e8:	4641                	li	a2,16
ffffffffc02042ea:	4581                	li	a1,0
ffffffffc02042ec:	0000d517          	auipc	a0,0xd
ffffffffc02042f0:	22c50513          	addi	a0,a0,556 # ffffffffc0211518 <name.2>
ffffffffc02042f4:	ec06                	sd	ra,24(sp)
ffffffffc02042f6:	e04a                	sd	s2,0(sp)
ffffffffc02042f8:	0044a903          	lw	s2,4(s1)
ffffffffc02042fc:	385000ef          	jal	ra,ffffffffc0204e80 <memset>
ffffffffc0204300:	0b448593          	addi	a1,s1,180
ffffffffc0204304:	463d                	li	a2,15
ffffffffc0204306:	0000d517          	auipc	a0,0xd
ffffffffc020430a:	21250513          	addi	a0,a0,530 # ffffffffc0211518 <name.2>
ffffffffc020430e:	385000ef          	jal	ra,ffffffffc0204e92 <memcpy>
ffffffffc0204312:	862a                	mv	a2,a0
ffffffffc0204314:	85ca                	mv	a1,s2
ffffffffc0204316:	00003517          	auipc	a0,0x3
ffffffffc020431a:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0206c00 <default_pmm_manager+0xfe0>
ffffffffc020431e:	e6dfb0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0204322:	85a2                	mv	a1,s0
ffffffffc0204324:	00003517          	auipc	a0,0x3
ffffffffc0204328:	90450513          	addi	a0,a0,-1788 # ffffffffc0206c28 <default_pmm_manager+0x1008>
ffffffffc020432c:	e5ffb0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0204330:	00003517          	auipc	a0,0x3
ffffffffc0204334:	90850513          	addi	a0,a0,-1784 # ffffffffc0206c38 <default_pmm_manager+0x1018>
ffffffffc0204338:	e53fb0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020433c:	60e2                	ld	ra,24(sp)
ffffffffc020433e:	6442                	ld	s0,16(sp)
ffffffffc0204340:	64a2                	ld	s1,8(sp)
ffffffffc0204342:	6902                	ld	s2,0(sp)
ffffffffc0204344:	4501                	li	a0,0
ffffffffc0204346:	6105                	addi	sp,sp,32
ffffffffc0204348:	8082                	ret

ffffffffc020434a <proc_run>:
ffffffffc020434a:	7179                	addi	sp,sp,-48
ffffffffc020434c:	ec4a                	sd	s2,24(sp)
ffffffffc020434e:	00011917          	auipc	s2,0x11
ffffffffc0204352:	27290913          	addi	s2,s2,626 # ffffffffc02155c0 <current>
ffffffffc0204356:	f026                	sd	s1,32(sp)
ffffffffc0204358:	00093483          	ld	s1,0(s2)
ffffffffc020435c:	f406                	sd	ra,40(sp)
ffffffffc020435e:	e84e                	sd	s3,16(sp)
ffffffffc0204360:	02a48963          	beq	s1,a0,ffffffffc0204392 <proc_run+0x48>
ffffffffc0204364:	100027f3          	csrr	a5,sstatus
ffffffffc0204368:	8b89                	andi	a5,a5,2
ffffffffc020436a:	4981                	li	s3,0
ffffffffc020436c:	e3a1                	bnez	a5,ffffffffc02043ac <proc_run+0x62>
ffffffffc020436e:	755c                	ld	a5,168(a0)
ffffffffc0204370:	80000737          	lui	a4,0x80000
ffffffffc0204374:	00a93023          	sd	a0,0(s2)
ffffffffc0204378:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc020437c:	8fd9                	or	a5,a5,a4
ffffffffc020437e:	18079073          	csrw	satp,a5
ffffffffc0204382:	03050593          	addi	a1,a0,48
ffffffffc0204386:	03048513          	addi	a0,s1,48
ffffffffc020438a:	530000ef          	jal	ra,ffffffffc02048ba <switch_to>
ffffffffc020438e:	00099863          	bnez	s3,ffffffffc020439e <proc_run+0x54>
ffffffffc0204392:	70a2                	ld	ra,40(sp)
ffffffffc0204394:	7482                	ld	s1,32(sp)
ffffffffc0204396:	6962                	ld	s2,24(sp)
ffffffffc0204398:	69c2                	ld	s3,16(sp)
ffffffffc020439a:	6145                	addi	sp,sp,48
ffffffffc020439c:	8082                	ret
ffffffffc020439e:	70a2                	ld	ra,40(sp)
ffffffffc02043a0:	7482                	ld	s1,32(sp)
ffffffffc02043a2:	6962                	ld	s2,24(sp)
ffffffffc02043a4:	69c2                	ld	s3,16(sp)
ffffffffc02043a6:	6145                	addi	sp,sp,48
ffffffffc02043a8:	a0cfc06f          	j	ffffffffc02005b4 <intr_enable>
ffffffffc02043ac:	e42a                	sd	a0,8(sp)
ffffffffc02043ae:	a0cfc0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc02043b2:	6522                	ld	a0,8(sp)
ffffffffc02043b4:	4985                	li	s3,1
ffffffffc02043b6:	bf65                	j	ffffffffc020436e <proc_run+0x24>

ffffffffc02043b8 <do_fork>:
ffffffffc02043b8:	7179                	addi	sp,sp,-48
ffffffffc02043ba:	f022                	sd	s0,32(sp)
ffffffffc02043bc:	00011417          	auipc	s0,0x11
ffffffffc02043c0:	1fc40413          	addi	s0,s0,508 # ffffffffc02155b8 <nr_process>
ffffffffc02043c4:	4018                	lw	a4,0(s0)
ffffffffc02043c6:	f406                	sd	ra,40(sp)
ffffffffc02043c8:	ec26                	sd	s1,24(sp)
ffffffffc02043ca:	e84a                	sd	s2,16(sp)
ffffffffc02043cc:	e44e                	sd	s3,8(sp)
ffffffffc02043ce:	6785                	lui	a5,0x1
ffffffffc02043d0:	1cf75e63          	bge	a4,a5,ffffffffc02045ac <do_fork+0x1f4>
ffffffffc02043d4:	892e                	mv	s2,a1
ffffffffc02043d6:	89b2                	mv	s3,a2
ffffffffc02043d8:	e91ff0ef          	jal	ra,ffffffffc0204268 <alloc_proc>
ffffffffc02043dc:	84aa                	mv	s1,a0
ffffffffc02043de:	14050063          	beqz	a0,ffffffffc020451e <do_fork+0x166>
ffffffffc02043e2:	4509                	li	a0,2
ffffffffc02043e4:	e5cfd0ef          	jal	ra,ffffffffc0201a40 <alloc_pages>
ffffffffc02043e8:	12050863          	beqz	a0,ffffffffc0204518 <do_fork+0x160>
ffffffffc02043ec:	00011797          	auipc	a5,0x11
ffffffffc02043f0:	19c7b783          	ld	a5,412(a5) # ffffffffc0215588 <pages>
ffffffffc02043f4:	40f506b3          	sub	a3,a0,a5
ffffffffc02043f8:	8699                	srai	a3,a3,0x6
ffffffffc02043fa:	00003797          	auipc	a5,0x3
ffffffffc02043fe:	bfe7b783          	ld	a5,-1026(a5) # ffffffffc0206ff8 <nbase>
ffffffffc0204402:	96be                	add	a3,a3,a5
ffffffffc0204404:	00c69793          	slli	a5,a3,0xc
ffffffffc0204408:	83b1                	srli	a5,a5,0xc
ffffffffc020440a:	00011717          	auipc	a4,0x11
ffffffffc020440e:	17673703          	ld	a4,374(a4) # ffffffffc0215580 <npage>
ffffffffc0204412:	06b2                	slli	a3,a3,0xc
ffffffffc0204414:	18e7fe63          	bgeu	a5,a4,ffffffffc02045b0 <do_fork+0x1f8>
ffffffffc0204418:	00011797          	auipc	a5,0x11
ffffffffc020441c:	1a87b783          	ld	a5,424(a5) # ffffffffc02155c0 <current>
ffffffffc0204420:	779c                	ld	a5,40(a5)
ffffffffc0204422:	00011717          	auipc	a4,0x11
ffffffffc0204426:	15673703          	ld	a4,342(a4) # ffffffffc0215578 <va_pa_offset>
ffffffffc020442a:	96ba                	add	a3,a3,a4
ffffffffc020442c:	e894                	sd	a3,16(s1)
ffffffffc020442e:	18079d63          	bnez	a5,ffffffffc02045c8 <do_fork+0x210>
ffffffffc0204432:	6789                	lui	a5,0x2
ffffffffc0204434:	ee078793          	addi	a5,a5,-288 # 1ee0 <kern_entry-0xffffffffc01fe120>
ffffffffc0204438:	96be                	add	a3,a3,a5
ffffffffc020443a:	864e                	mv	a2,s3
ffffffffc020443c:	f0d4                	sd	a3,160(s1)
ffffffffc020443e:	87b6                	mv	a5,a3
ffffffffc0204440:	12098893          	addi	a7,s3,288
ffffffffc0204444:	00063803          	ld	a6,0(a2)
ffffffffc0204448:	6608                	ld	a0,8(a2)
ffffffffc020444a:	6a0c                	ld	a1,16(a2)
ffffffffc020444c:	6e18                	ld	a4,24(a2)
ffffffffc020444e:	0107b023          	sd	a6,0(a5)
ffffffffc0204452:	e788                	sd	a0,8(a5)
ffffffffc0204454:	eb8c                	sd	a1,16(a5)
ffffffffc0204456:	ef98                	sd	a4,24(a5)
ffffffffc0204458:	02060613          	addi	a2,a2,32
ffffffffc020445c:	02078793          	addi	a5,a5,32
ffffffffc0204460:	ff1612e3          	bne	a2,a7,ffffffffc0204444 <do_fork+0x8c>
ffffffffc0204464:	0406b823          	sd	zero,80(a3)
ffffffffc0204468:	12090363          	beqz	s2,ffffffffc020458e <do_fork+0x1d6>
ffffffffc020446c:	0126b823          	sd	s2,16(a3)
ffffffffc0204470:	00000797          	auipc	a5,0x0
ffffffffc0204474:	e5a78793          	addi	a5,a5,-422 # ffffffffc02042ca <forkret>
ffffffffc0204478:	f89c                	sd	a5,48(s1)
ffffffffc020447a:	fc94                	sd	a3,56(s1)
ffffffffc020447c:	100027f3          	csrr	a5,sstatus
ffffffffc0204480:	8b89                	andi	a5,a5,2
ffffffffc0204482:	4981                	li	s3,0
ffffffffc0204484:	12079063          	bnez	a5,ffffffffc02045a4 <do_fork+0x1ec>
ffffffffc0204488:	00006817          	auipc	a6,0x6
ffffffffc020448c:	bd480813          	addi	a6,a6,-1068 # ffffffffc020a05c <last_pid.1>
ffffffffc0204490:	00082783          	lw	a5,0(a6)
ffffffffc0204494:	6709                	lui	a4,0x2
ffffffffc0204496:	0017851b          	addiw	a0,a5,1
ffffffffc020449a:	00a82023          	sw	a0,0(a6)
ffffffffc020449e:	08e55263          	bge	a0,a4,ffffffffc0204522 <do_fork+0x16a>
ffffffffc02044a2:	00006317          	auipc	t1,0x6
ffffffffc02044a6:	bb630313          	addi	t1,t1,-1098 # ffffffffc020a058 <next_safe.0>
ffffffffc02044aa:	00032783          	lw	a5,0(t1)
ffffffffc02044ae:	00011917          	auipc	s2,0x11
ffffffffc02044b2:	07a90913          	addi	s2,s2,122 # ffffffffc0215528 <proc_list>
ffffffffc02044b6:	06f55e63          	bge	a0,a5,ffffffffc0204532 <do_fork+0x17a>
ffffffffc02044ba:	c0c8                	sw	a0,4(s1)
ffffffffc02044bc:	45a9                	li	a1,10
ffffffffc02044be:	2501                	sext.w	a0,a0
ffffffffc02044c0:	52a000ef          	jal	ra,ffffffffc02049ea <hash32>
ffffffffc02044c4:	02051793          	slli	a5,a0,0x20
ffffffffc02044c8:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02044cc:	0000d797          	auipc	a5,0xd
ffffffffc02044d0:	05c78793          	addi	a5,a5,92 # ffffffffc0211528 <hash_list>
ffffffffc02044d4:	953e                	add	a0,a0,a5
ffffffffc02044d6:	6510                	ld	a2,8(a0)
ffffffffc02044d8:	0d848793          	addi	a5,s1,216
ffffffffc02044dc:	00893683          	ld	a3,8(s2)
ffffffffc02044e0:	4018                	lw	a4,0(s0)
ffffffffc02044e2:	e21c                	sd	a5,0(a2)
ffffffffc02044e4:	e51c                	sd	a5,8(a0)
ffffffffc02044e6:	f0f0                	sd	a2,224(s1)
ffffffffc02044e8:	0c848793          	addi	a5,s1,200
ffffffffc02044ec:	ece8                	sd	a0,216(s1)
ffffffffc02044ee:	e29c                	sd	a5,0(a3)
ffffffffc02044f0:	2705                	addiw	a4,a4,1
ffffffffc02044f2:	00f93423          	sd	a5,8(s2)
ffffffffc02044f6:	e8f4                	sd	a3,208(s1)
ffffffffc02044f8:	0d24b423          	sd	s2,200(s1)
ffffffffc02044fc:	c018                	sw	a4,0(s0)
ffffffffc02044fe:	08099a63          	bnez	s3,ffffffffc0204592 <do_fork+0x1da>
ffffffffc0204502:	8526                	mv	a0,s1
ffffffffc0204504:	420000ef          	jal	ra,ffffffffc0204924 <wakeup_proc>
ffffffffc0204508:	40c8                	lw	a0,4(s1)
ffffffffc020450a:	70a2                	ld	ra,40(sp)
ffffffffc020450c:	7402                	ld	s0,32(sp)
ffffffffc020450e:	64e2                	ld	s1,24(sp)
ffffffffc0204510:	6942                	ld	s2,16(sp)
ffffffffc0204512:	69a2                	ld	s3,8(sp)
ffffffffc0204514:	6145                	addi	sp,sp,48
ffffffffc0204516:	8082                	ret
ffffffffc0204518:	8526                	mv	a0,s1
ffffffffc020451a:	bf8fd0ef          	jal	ra,ffffffffc0201912 <kfree>
ffffffffc020451e:	5571                	li	a0,-4
ffffffffc0204520:	b7ed                	j	ffffffffc020450a <do_fork+0x152>
ffffffffc0204522:	4785                	li	a5,1
ffffffffc0204524:	00f82023          	sw	a5,0(a6)
ffffffffc0204528:	4505                	li	a0,1
ffffffffc020452a:	00006317          	auipc	t1,0x6
ffffffffc020452e:	b2e30313          	addi	t1,t1,-1234 # ffffffffc020a058 <next_safe.0>
ffffffffc0204532:	00011917          	auipc	s2,0x11
ffffffffc0204536:	ff690913          	addi	s2,s2,-10 # ffffffffc0215528 <proc_list>
ffffffffc020453a:	00893e03          	ld	t3,8(s2)
ffffffffc020453e:	6789                	lui	a5,0x2
ffffffffc0204540:	00f32023          	sw	a5,0(t1)
ffffffffc0204544:	86aa                	mv	a3,a0
ffffffffc0204546:	4581                	li	a1,0
ffffffffc0204548:	032e0e63          	beq	t3,s2,ffffffffc0204584 <do_fork+0x1cc>
ffffffffc020454c:	88ae                	mv	a7,a1
ffffffffc020454e:	87f2                	mv	a5,t3
ffffffffc0204550:	6609                	lui	a2,0x2
ffffffffc0204552:	a811                	j	ffffffffc0204566 <do_fork+0x1ae>
ffffffffc0204554:	00e6d663          	bge	a3,a4,ffffffffc0204560 <do_fork+0x1a8>
ffffffffc0204558:	00c75463          	bge	a4,a2,ffffffffc0204560 <do_fork+0x1a8>
ffffffffc020455c:	863a                	mv	a2,a4
ffffffffc020455e:	4885                	li	a7,1
ffffffffc0204560:	679c                	ld	a5,8(a5)
ffffffffc0204562:	01278d63          	beq	a5,s2,ffffffffc020457c <do_fork+0x1c4>
ffffffffc0204566:	f3c7a703          	lw	a4,-196(a5) # 1f3c <kern_entry-0xffffffffc01fe0c4>
ffffffffc020456a:	fed715e3          	bne	a4,a3,ffffffffc0204554 <do_fork+0x19c>
ffffffffc020456e:	2685                	addiw	a3,a3,1
ffffffffc0204570:	02c6d463          	bge	a3,a2,ffffffffc0204598 <do_fork+0x1e0>
ffffffffc0204574:	679c                	ld	a5,8(a5)
ffffffffc0204576:	4585                	li	a1,1
ffffffffc0204578:	ff2797e3          	bne	a5,s2,ffffffffc0204566 <do_fork+0x1ae>
ffffffffc020457c:	00088463          	beqz	a7,ffffffffc0204584 <do_fork+0x1cc>
ffffffffc0204580:	00c32023          	sw	a2,0(t1)
ffffffffc0204584:	d99d                	beqz	a1,ffffffffc02044ba <do_fork+0x102>
ffffffffc0204586:	00d82023          	sw	a3,0(a6)
ffffffffc020458a:	8536                	mv	a0,a3
ffffffffc020458c:	b73d                	j	ffffffffc02044ba <do_fork+0x102>
ffffffffc020458e:	8936                	mv	s2,a3
ffffffffc0204590:	bdf1                	j	ffffffffc020446c <do_fork+0xb4>
ffffffffc0204592:	822fc0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0204596:	b7b5                	j	ffffffffc0204502 <do_fork+0x14a>
ffffffffc0204598:	6789                	lui	a5,0x2
ffffffffc020459a:	00f6c363          	blt	a3,a5,ffffffffc02045a0 <do_fork+0x1e8>
ffffffffc020459e:	4685                	li	a3,1
ffffffffc02045a0:	4585                	li	a1,1
ffffffffc02045a2:	b75d                	j	ffffffffc0204548 <do_fork+0x190>
ffffffffc02045a4:	816fc0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc02045a8:	4985                	li	s3,1
ffffffffc02045aa:	bdf9                	j	ffffffffc0204488 <do_fork+0xd0>
ffffffffc02045ac:	556d                	li	a0,-5
ffffffffc02045ae:	bfb1                	j	ffffffffc020450a <do_fork+0x152>
ffffffffc02045b0:	00001617          	auipc	a2,0x1
ffffffffc02045b4:	6a860613          	addi	a2,a2,1704 # ffffffffc0205c58 <default_pmm_manager+0x38>
ffffffffc02045b8:	08b00593          	li	a1,139
ffffffffc02045bc:	00001517          	auipc	a0,0x1
ffffffffc02045c0:	6c450513          	addi	a0,a0,1732 # ffffffffc0205c80 <default_pmm_manager+0x60>
ffffffffc02045c4:	e7bfb0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02045c8:	00002697          	auipc	a3,0x2
ffffffffc02045cc:	69068693          	addi	a3,a3,1680 # ffffffffc0206c58 <default_pmm_manager+0x1038>
ffffffffc02045d0:	00001617          	auipc	a2,0x1
ffffffffc02045d4:	2a060613          	addi	a2,a2,672 # ffffffffc0205870 <commands+0x738>
ffffffffc02045d8:	12b00593          	li	a1,299
ffffffffc02045dc:	00002517          	auipc	a0,0x2
ffffffffc02045e0:	69450513          	addi	a0,a0,1684 # ffffffffc0206c70 <default_pmm_manager+0x1050>
ffffffffc02045e4:	e5bfb0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc02045e8 <kernel_thread>:
ffffffffc02045e8:	7129                	addi	sp,sp,-320
ffffffffc02045ea:	fa22                	sd	s0,304(sp)
ffffffffc02045ec:	f626                	sd	s1,296(sp)
ffffffffc02045ee:	f24a                	sd	s2,288(sp)
ffffffffc02045f0:	84ae                	mv	s1,a1
ffffffffc02045f2:	892a                	mv	s2,a0
ffffffffc02045f4:	8432                	mv	s0,a2
ffffffffc02045f6:	4581                	li	a1,0
ffffffffc02045f8:	12000613          	li	a2,288
ffffffffc02045fc:	850a                	mv	a0,sp
ffffffffc02045fe:	fe06                	sd	ra,312(sp)
ffffffffc0204600:	081000ef          	jal	ra,ffffffffc0204e80 <memset>
ffffffffc0204604:	e0ca                	sd	s2,64(sp)
ffffffffc0204606:	e4a6                	sd	s1,72(sp)
ffffffffc0204608:	100027f3          	csrr	a5,sstatus
ffffffffc020460c:	edd7f793          	andi	a5,a5,-291
ffffffffc0204610:	1207e793          	ori	a5,a5,288
ffffffffc0204614:	e23e                	sd	a5,256(sp)
ffffffffc0204616:	860a                	mv	a2,sp
ffffffffc0204618:	10046513          	ori	a0,s0,256
ffffffffc020461c:	00000797          	auipc	a5,0x0
ffffffffc0204620:	c4478793          	addi	a5,a5,-956 # ffffffffc0204260 <kernel_thread_entry>
ffffffffc0204624:	4581                	li	a1,0
ffffffffc0204626:	e63e                	sd	a5,264(sp)
ffffffffc0204628:	d91ff0ef          	jal	ra,ffffffffc02043b8 <do_fork>
ffffffffc020462c:	70f2                	ld	ra,312(sp)
ffffffffc020462e:	7452                	ld	s0,304(sp)
ffffffffc0204630:	74b2                	ld	s1,296(sp)
ffffffffc0204632:	7912                	ld	s2,288(sp)
ffffffffc0204634:	6131                	addi	sp,sp,320
ffffffffc0204636:	8082                	ret

ffffffffc0204638 <do_exit>:
ffffffffc0204638:	1141                	addi	sp,sp,-16
ffffffffc020463a:	00002617          	auipc	a2,0x2
ffffffffc020463e:	64e60613          	addi	a2,a2,1614 # ffffffffc0206c88 <default_pmm_manager+0x1068>
ffffffffc0204642:	19900593          	li	a1,409
ffffffffc0204646:	00002517          	auipc	a0,0x2
ffffffffc020464a:	62a50513          	addi	a0,a0,1578 # ffffffffc0206c70 <default_pmm_manager+0x1050>
ffffffffc020464e:	e406                	sd	ra,8(sp)
ffffffffc0204650:	deffb0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0204654 <proc_init>:
ffffffffc0204654:	7179                	addi	sp,sp,-48
ffffffffc0204656:	ec26                	sd	s1,24(sp)
ffffffffc0204658:	00011797          	auipc	a5,0x11
ffffffffc020465c:	ed078793          	addi	a5,a5,-304 # ffffffffc0215528 <proc_list>
ffffffffc0204660:	f406                	sd	ra,40(sp)
ffffffffc0204662:	f022                	sd	s0,32(sp)
ffffffffc0204664:	e84a                	sd	s2,16(sp)
ffffffffc0204666:	e44e                	sd	s3,8(sp)
ffffffffc0204668:	0000d497          	auipc	s1,0xd
ffffffffc020466c:	ec048493          	addi	s1,s1,-320 # ffffffffc0211528 <hash_list>
ffffffffc0204670:	e79c                	sd	a5,8(a5)
ffffffffc0204672:	e39c                	sd	a5,0(a5)
ffffffffc0204674:	00011717          	auipc	a4,0x11
ffffffffc0204678:	eb470713          	addi	a4,a4,-332 # ffffffffc0215528 <proc_list>
ffffffffc020467c:	87a6                	mv	a5,s1
ffffffffc020467e:	e79c                	sd	a5,8(a5)
ffffffffc0204680:	e39c                	sd	a5,0(a5)
ffffffffc0204682:	07c1                	addi	a5,a5,16
ffffffffc0204684:	fee79de3          	bne	a5,a4,ffffffffc020467e <proc_init+0x2a>
ffffffffc0204688:	be1ff0ef          	jal	ra,ffffffffc0204268 <alloc_proc>
ffffffffc020468c:	00011917          	auipc	s2,0x11
ffffffffc0204690:	f4490913          	addi	s2,s2,-188 # ffffffffc02155d0 <idleproc>
ffffffffc0204694:	00a93023          	sd	a0,0(s2)
ffffffffc0204698:	18050c63          	beqz	a0,ffffffffc0204830 <proc_init+0x1dc>
ffffffffc020469c:	07000513          	li	a0,112
ffffffffc02046a0:	9d2fd0ef          	jal	ra,ffffffffc0201872 <kmalloc>
ffffffffc02046a4:	07000613          	li	a2,112
ffffffffc02046a8:	4581                	li	a1,0
ffffffffc02046aa:	842a                	mv	s0,a0
ffffffffc02046ac:	7d4000ef          	jal	ra,ffffffffc0204e80 <memset>
ffffffffc02046b0:	00093503          	ld	a0,0(s2)
ffffffffc02046b4:	85a2                	mv	a1,s0
ffffffffc02046b6:	07000613          	li	a2,112
ffffffffc02046ba:	03050513          	addi	a0,a0,48
ffffffffc02046be:	7ec000ef          	jal	ra,ffffffffc0204eaa <memcmp>
ffffffffc02046c2:	89aa                	mv	s3,a0
ffffffffc02046c4:	453d                	li	a0,15
ffffffffc02046c6:	9acfd0ef          	jal	ra,ffffffffc0201872 <kmalloc>
ffffffffc02046ca:	463d                	li	a2,15
ffffffffc02046cc:	4581                	li	a1,0
ffffffffc02046ce:	842a                	mv	s0,a0
ffffffffc02046d0:	7b0000ef          	jal	ra,ffffffffc0204e80 <memset>
ffffffffc02046d4:	00093503          	ld	a0,0(s2)
ffffffffc02046d8:	463d                	li	a2,15
ffffffffc02046da:	85a2                	mv	a1,s0
ffffffffc02046dc:	0b450513          	addi	a0,a0,180
ffffffffc02046e0:	7ca000ef          	jal	ra,ffffffffc0204eaa <memcmp>
ffffffffc02046e4:	00093783          	ld	a5,0(s2)
ffffffffc02046e8:	00011717          	auipc	a4,0x11
ffffffffc02046ec:	e8073703          	ld	a4,-384(a4) # ffffffffc0215568 <boot_cr3>
ffffffffc02046f0:	77d4                	ld	a3,168(a5)
ffffffffc02046f2:	0ee68563          	beq	a3,a4,ffffffffc02047dc <proc_init+0x188>
ffffffffc02046f6:	4709                	li	a4,2
ffffffffc02046f8:	e398                	sd	a4,0(a5)
ffffffffc02046fa:	00003717          	auipc	a4,0x3
ffffffffc02046fe:	90670713          	addi	a4,a4,-1786 # ffffffffc0207000 <bootstack>
ffffffffc0204702:	0b478413          	addi	s0,a5,180
ffffffffc0204706:	eb98                	sd	a4,16(a5)
ffffffffc0204708:	4705                	li	a4,1
ffffffffc020470a:	cf98                	sw	a4,24(a5)
ffffffffc020470c:	4641                	li	a2,16
ffffffffc020470e:	4581                	li	a1,0
ffffffffc0204710:	8522                	mv	a0,s0
ffffffffc0204712:	76e000ef          	jal	ra,ffffffffc0204e80 <memset>
ffffffffc0204716:	463d                	li	a2,15
ffffffffc0204718:	00002597          	auipc	a1,0x2
ffffffffc020471c:	5b858593          	addi	a1,a1,1464 # ffffffffc0206cd0 <default_pmm_manager+0x10b0>
ffffffffc0204720:	8522                	mv	a0,s0
ffffffffc0204722:	770000ef          	jal	ra,ffffffffc0204e92 <memcpy>
ffffffffc0204726:	00011717          	auipc	a4,0x11
ffffffffc020472a:	e9270713          	addi	a4,a4,-366 # ffffffffc02155b8 <nr_process>
ffffffffc020472e:	431c                	lw	a5,0(a4)
ffffffffc0204730:	00093683          	ld	a3,0(s2)
ffffffffc0204734:	4601                	li	a2,0
ffffffffc0204736:	2785                	addiw	a5,a5,1
ffffffffc0204738:	00002597          	auipc	a1,0x2
ffffffffc020473c:	5a058593          	addi	a1,a1,1440 # ffffffffc0206cd8 <default_pmm_manager+0x10b8>
ffffffffc0204740:	00000517          	auipc	a0,0x0
ffffffffc0204744:	b9850513          	addi	a0,a0,-1128 # ffffffffc02042d8 <init_main>
ffffffffc0204748:	c31c                	sw	a5,0(a4)
ffffffffc020474a:	00011797          	auipc	a5,0x11
ffffffffc020474e:	e6d7bb23          	sd	a3,-394(a5) # ffffffffc02155c0 <current>
ffffffffc0204752:	e97ff0ef          	jal	ra,ffffffffc02045e8 <kernel_thread>
ffffffffc0204756:	842a                	mv	s0,a0
ffffffffc0204758:	0ea05863          	blez	a0,ffffffffc0204848 <proc_init+0x1f4>
ffffffffc020475c:	6789                	lui	a5,0x2
ffffffffc020475e:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204762:	17f9                	addi	a5,a5,-2
ffffffffc0204764:	2501                	sext.w	a0,a0
ffffffffc0204766:	02e7e463          	bltu	a5,a4,ffffffffc020478e <proc_init+0x13a>
ffffffffc020476a:	45a9                	li	a1,10
ffffffffc020476c:	27e000ef          	jal	ra,ffffffffc02049ea <hash32>
ffffffffc0204770:	02051713          	slli	a4,a0,0x20
ffffffffc0204774:	01c75793          	srli	a5,a4,0x1c
ffffffffc0204778:	00f486b3          	add	a3,s1,a5
ffffffffc020477c:	87b6                	mv	a5,a3
ffffffffc020477e:	a029                	j	ffffffffc0204788 <proc_init+0x134>
ffffffffc0204780:	f2c7a703          	lw	a4,-212(a5) # 1f2c <kern_entry-0xffffffffc01fe0d4>
ffffffffc0204784:	0a870363          	beq	a4,s0,ffffffffc020482a <proc_init+0x1d6>
ffffffffc0204788:	679c                	ld	a5,8(a5)
ffffffffc020478a:	fef69be3          	bne	a3,a5,ffffffffc0204780 <proc_init+0x12c>
ffffffffc020478e:	4781                	li	a5,0
ffffffffc0204790:	0b478493          	addi	s1,a5,180
ffffffffc0204794:	4641                	li	a2,16
ffffffffc0204796:	4581                	li	a1,0
ffffffffc0204798:	00011417          	auipc	s0,0x11
ffffffffc020479c:	e3040413          	addi	s0,s0,-464 # ffffffffc02155c8 <initproc>
ffffffffc02047a0:	8526                	mv	a0,s1
ffffffffc02047a2:	e01c                	sd	a5,0(s0)
ffffffffc02047a4:	6dc000ef          	jal	ra,ffffffffc0204e80 <memset>
ffffffffc02047a8:	463d                	li	a2,15
ffffffffc02047aa:	00002597          	auipc	a1,0x2
ffffffffc02047ae:	55e58593          	addi	a1,a1,1374 # ffffffffc0206d08 <default_pmm_manager+0x10e8>
ffffffffc02047b2:	8526                	mv	a0,s1
ffffffffc02047b4:	6de000ef          	jal	ra,ffffffffc0204e92 <memcpy>
ffffffffc02047b8:	00093783          	ld	a5,0(s2)
ffffffffc02047bc:	c3f1                	beqz	a5,ffffffffc0204880 <proc_init+0x22c>
ffffffffc02047be:	43dc                	lw	a5,4(a5)
ffffffffc02047c0:	e3e1                	bnez	a5,ffffffffc0204880 <proc_init+0x22c>
ffffffffc02047c2:	601c                	ld	a5,0(s0)
ffffffffc02047c4:	cfd1                	beqz	a5,ffffffffc0204860 <proc_init+0x20c>
ffffffffc02047c6:	43d8                	lw	a4,4(a5)
ffffffffc02047c8:	4785                	li	a5,1
ffffffffc02047ca:	08f71b63          	bne	a4,a5,ffffffffc0204860 <proc_init+0x20c>
ffffffffc02047ce:	70a2                	ld	ra,40(sp)
ffffffffc02047d0:	7402                	ld	s0,32(sp)
ffffffffc02047d2:	64e2                	ld	s1,24(sp)
ffffffffc02047d4:	6942                	ld	s2,16(sp)
ffffffffc02047d6:	69a2                	ld	s3,8(sp)
ffffffffc02047d8:	6145                	addi	sp,sp,48
ffffffffc02047da:	8082                	ret
ffffffffc02047dc:	73d8                	ld	a4,160(a5)
ffffffffc02047de:	ff01                	bnez	a4,ffffffffc02046f6 <proc_init+0xa2>
ffffffffc02047e0:	f0099be3          	bnez	s3,ffffffffc02046f6 <proc_init+0xa2>
ffffffffc02047e4:	6394                	ld	a3,0(a5)
ffffffffc02047e6:	577d                	li	a4,-1
ffffffffc02047e8:	1702                	slli	a4,a4,0x20
ffffffffc02047ea:	f0e696e3          	bne	a3,a4,ffffffffc02046f6 <proc_init+0xa2>
ffffffffc02047ee:	4798                	lw	a4,8(a5)
ffffffffc02047f0:	f00713e3          	bnez	a4,ffffffffc02046f6 <proc_init+0xa2>
ffffffffc02047f4:	6b98                	ld	a4,16(a5)
ffffffffc02047f6:	f00710e3          	bnez	a4,ffffffffc02046f6 <proc_init+0xa2>
ffffffffc02047fa:	4f98                	lw	a4,24(a5)
ffffffffc02047fc:	ee071de3          	bnez	a4,ffffffffc02046f6 <proc_init+0xa2>
ffffffffc0204800:	7398                	ld	a4,32(a5)
ffffffffc0204802:	ee071ae3          	bnez	a4,ffffffffc02046f6 <proc_init+0xa2>
ffffffffc0204806:	7798                	ld	a4,40(a5)
ffffffffc0204808:	ee0717e3          	bnez	a4,ffffffffc02046f6 <proc_init+0xa2>
ffffffffc020480c:	0b07a703          	lw	a4,176(a5)
ffffffffc0204810:	8f49                	or	a4,a4,a0
ffffffffc0204812:	2701                	sext.w	a4,a4
ffffffffc0204814:	ee0711e3          	bnez	a4,ffffffffc02046f6 <proc_init+0xa2>
ffffffffc0204818:	00002517          	auipc	a0,0x2
ffffffffc020481c:	4a050513          	addi	a0,a0,1184 # ffffffffc0206cb8 <default_pmm_manager+0x1098>
ffffffffc0204820:	96bfb0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0204824:	00093783          	ld	a5,0(s2)
ffffffffc0204828:	b5f9                	j	ffffffffc02046f6 <proc_init+0xa2>
ffffffffc020482a:	f2878793          	addi	a5,a5,-216
ffffffffc020482e:	b78d                	j	ffffffffc0204790 <proc_init+0x13c>
ffffffffc0204830:	00002617          	auipc	a2,0x2
ffffffffc0204834:	47060613          	addi	a2,a2,1136 # ffffffffc0206ca0 <default_pmm_manager+0x1080>
ffffffffc0204838:	1b200593          	li	a1,434
ffffffffc020483c:	00002517          	auipc	a0,0x2
ffffffffc0204840:	43450513          	addi	a0,a0,1076 # ffffffffc0206c70 <default_pmm_manager+0x1050>
ffffffffc0204844:	bfbfb0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0204848:	00002617          	auipc	a2,0x2
ffffffffc020484c:	4a060613          	addi	a2,a2,1184 # ffffffffc0206ce8 <default_pmm_manager+0x10c8>
ffffffffc0204850:	1d300593          	li	a1,467
ffffffffc0204854:	00002517          	auipc	a0,0x2
ffffffffc0204858:	41c50513          	addi	a0,a0,1052 # ffffffffc0206c70 <default_pmm_manager+0x1050>
ffffffffc020485c:	be3fb0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0204860:	00002697          	auipc	a3,0x2
ffffffffc0204864:	4d868693          	addi	a3,a3,1240 # ffffffffc0206d38 <default_pmm_manager+0x1118>
ffffffffc0204868:	00001617          	auipc	a2,0x1
ffffffffc020486c:	00860613          	addi	a2,a2,8 # ffffffffc0205870 <commands+0x738>
ffffffffc0204870:	1da00593          	li	a1,474
ffffffffc0204874:	00002517          	auipc	a0,0x2
ffffffffc0204878:	3fc50513          	addi	a0,a0,1020 # ffffffffc0206c70 <default_pmm_manager+0x1050>
ffffffffc020487c:	bc3fb0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0204880:	00002697          	auipc	a3,0x2
ffffffffc0204884:	49068693          	addi	a3,a3,1168 # ffffffffc0206d10 <default_pmm_manager+0x10f0>
ffffffffc0204888:	00001617          	auipc	a2,0x1
ffffffffc020488c:	fe860613          	addi	a2,a2,-24 # ffffffffc0205870 <commands+0x738>
ffffffffc0204890:	1d900593          	li	a1,473
ffffffffc0204894:	00002517          	auipc	a0,0x2
ffffffffc0204898:	3dc50513          	addi	a0,a0,988 # ffffffffc0206c70 <default_pmm_manager+0x1050>
ffffffffc020489c:	ba3fb0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc02048a0 <cpu_idle>:
ffffffffc02048a0:	1141                	addi	sp,sp,-16
ffffffffc02048a2:	e022                	sd	s0,0(sp)
ffffffffc02048a4:	e406                	sd	ra,8(sp)
ffffffffc02048a6:	00011417          	auipc	s0,0x11
ffffffffc02048aa:	d1a40413          	addi	s0,s0,-742 # ffffffffc02155c0 <current>
ffffffffc02048ae:	6018                	ld	a4,0(s0)
ffffffffc02048b0:	4f1c                	lw	a5,24(a4)
ffffffffc02048b2:	dffd                	beqz	a5,ffffffffc02048b0 <cpu_idle+0x10>
ffffffffc02048b4:	0a2000ef          	jal	ra,ffffffffc0204956 <schedule>
ffffffffc02048b8:	bfdd                	j	ffffffffc02048ae <cpu_idle+0xe>

ffffffffc02048ba <switch_to>:
ffffffffc02048ba:	00153023          	sd	ra,0(a0)
ffffffffc02048be:	00253423          	sd	sp,8(a0)
ffffffffc02048c2:	e900                	sd	s0,16(a0)
ffffffffc02048c4:	ed04                	sd	s1,24(a0)
ffffffffc02048c6:	03253023          	sd	s2,32(a0)
ffffffffc02048ca:	03353423          	sd	s3,40(a0)
ffffffffc02048ce:	03453823          	sd	s4,48(a0)
ffffffffc02048d2:	03553c23          	sd	s5,56(a0)
ffffffffc02048d6:	05653023          	sd	s6,64(a0)
ffffffffc02048da:	05753423          	sd	s7,72(a0)
ffffffffc02048de:	05853823          	sd	s8,80(a0)
ffffffffc02048e2:	05953c23          	sd	s9,88(a0)
ffffffffc02048e6:	07a53023          	sd	s10,96(a0)
ffffffffc02048ea:	07b53423          	sd	s11,104(a0)
ffffffffc02048ee:	0005b083          	ld	ra,0(a1)
ffffffffc02048f2:	0085b103          	ld	sp,8(a1)
ffffffffc02048f6:	6980                	ld	s0,16(a1)
ffffffffc02048f8:	6d84                	ld	s1,24(a1)
ffffffffc02048fa:	0205b903          	ld	s2,32(a1)
ffffffffc02048fe:	0285b983          	ld	s3,40(a1)
ffffffffc0204902:	0305ba03          	ld	s4,48(a1)
ffffffffc0204906:	0385ba83          	ld	s5,56(a1)
ffffffffc020490a:	0405bb03          	ld	s6,64(a1)
ffffffffc020490e:	0485bb83          	ld	s7,72(a1)
ffffffffc0204912:	0505bc03          	ld	s8,80(a1)
ffffffffc0204916:	0585bc83          	ld	s9,88(a1)
ffffffffc020491a:	0605bd03          	ld	s10,96(a1)
ffffffffc020491e:	0685bd83          	ld	s11,104(a1)
ffffffffc0204922:	8082                	ret

ffffffffc0204924 <wakeup_proc>:
ffffffffc0204924:	411c                	lw	a5,0(a0)
ffffffffc0204926:	4705                	li	a4,1
ffffffffc0204928:	37f9                	addiw	a5,a5,-2
ffffffffc020492a:	00f77563          	bgeu	a4,a5,ffffffffc0204934 <wakeup_proc+0x10>
ffffffffc020492e:	4789                	li	a5,2
ffffffffc0204930:	c11c                	sw	a5,0(a0)
ffffffffc0204932:	8082                	ret
ffffffffc0204934:	1141                	addi	sp,sp,-16
ffffffffc0204936:	00002697          	auipc	a3,0x2
ffffffffc020493a:	42a68693          	addi	a3,a3,1066 # ffffffffc0206d60 <default_pmm_manager+0x1140>
ffffffffc020493e:	00001617          	auipc	a2,0x1
ffffffffc0204942:	f3260613          	addi	a2,a2,-206 # ffffffffc0205870 <commands+0x738>
ffffffffc0204946:	45a5                	li	a1,9
ffffffffc0204948:	00002517          	auipc	a0,0x2
ffffffffc020494c:	45850513          	addi	a0,a0,1112 # ffffffffc0206da0 <default_pmm_manager+0x1180>
ffffffffc0204950:	e406                	sd	ra,8(sp)
ffffffffc0204952:	aedfb0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0204956 <schedule>:
ffffffffc0204956:	1141                	addi	sp,sp,-16
ffffffffc0204958:	e406                	sd	ra,8(sp)
ffffffffc020495a:	e022                	sd	s0,0(sp)
ffffffffc020495c:	100027f3          	csrr	a5,sstatus
ffffffffc0204960:	8b89                	andi	a5,a5,2
ffffffffc0204962:	4401                	li	s0,0
ffffffffc0204964:	efbd                	bnez	a5,ffffffffc02049e2 <schedule+0x8c>
ffffffffc0204966:	00011897          	auipc	a7,0x11
ffffffffc020496a:	c5a8b883          	ld	a7,-934(a7) # ffffffffc02155c0 <current>
ffffffffc020496e:	0008ac23          	sw	zero,24(a7)
ffffffffc0204972:	00011517          	auipc	a0,0x11
ffffffffc0204976:	c5e53503          	ld	a0,-930(a0) # ffffffffc02155d0 <idleproc>
ffffffffc020497a:	04a88e63          	beq	a7,a0,ffffffffc02049d6 <schedule+0x80>
ffffffffc020497e:	0c888693          	addi	a3,a7,200
ffffffffc0204982:	00011617          	auipc	a2,0x11
ffffffffc0204986:	ba660613          	addi	a2,a2,-1114 # ffffffffc0215528 <proc_list>
ffffffffc020498a:	87b6                	mv	a5,a3
ffffffffc020498c:	4581                	li	a1,0
ffffffffc020498e:	4809                	li	a6,2
ffffffffc0204990:	679c                	ld	a5,8(a5)
ffffffffc0204992:	00c78863          	beq	a5,a2,ffffffffc02049a2 <schedule+0x4c>
ffffffffc0204996:	f387a703          	lw	a4,-200(a5)
ffffffffc020499a:	f3878593          	addi	a1,a5,-200
ffffffffc020499e:	03070163          	beq	a4,a6,ffffffffc02049c0 <schedule+0x6a>
ffffffffc02049a2:	fef697e3          	bne	a3,a5,ffffffffc0204990 <schedule+0x3a>
ffffffffc02049a6:	ed89                	bnez	a1,ffffffffc02049c0 <schedule+0x6a>
ffffffffc02049a8:	451c                	lw	a5,8(a0)
ffffffffc02049aa:	2785                	addiw	a5,a5,1
ffffffffc02049ac:	c51c                	sw	a5,8(a0)
ffffffffc02049ae:	00a88463          	beq	a7,a0,ffffffffc02049b6 <schedule+0x60>
ffffffffc02049b2:	999ff0ef          	jal	ra,ffffffffc020434a <proc_run>
ffffffffc02049b6:	e819                	bnez	s0,ffffffffc02049cc <schedule+0x76>
ffffffffc02049b8:	60a2                	ld	ra,8(sp)
ffffffffc02049ba:	6402                	ld	s0,0(sp)
ffffffffc02049bc:	0141                	addi	sp,sp,16
ffffffffc02049be:	8082                	ret
ffffffffc02049c0:	4198                	lw	a4,0(a1)
ffffffffc02049c2:	4789                	li	a5,2
ffffffffc02049c4:	fef712e3          	bne	a4,a5,ffffffffc02049a8 <schedule+0x52>
ffffffffc02049c8:	852e                	mv	a0,a1
ffffffffc02049ca:	bff9                	j	ffffffffc02049a8 <schedule+0x52>
ffffffffc02049cc:	6402                	ld	s0,0(sp)
ffffffffc02049ce:	60a2                	ld	ra,8(sp)
ffffffffc02049d0:	0141                	addi	sp,sp,16
ffffffffc02049d2:	be3fb06f          	j	ffffffffc02005b4 <intr_enable>
ffffffffc02049d6:	00011617          	auipc	a2,0x11
ffffffffc02049da:	b5260613          	addi	a2,a2,-1198 # ffffffffc0215528 <proc_list>
ffffffffc02049de:	86b2                	mv	a3,a2
ffffffffc02049e0:	b76d                	j	ffffffffc020498a <schedule+0x34>
ffffffffc02049e2:	bd9fb0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc02049e6:	4405                	li	s0,1
ffffffffc02049e8:	bfbd                	j	ffffffffc0204966 <schedule+0x10>

ffffffffc02049ea <hash32>:
ffffffffc02049ea:	9e3707b7          	lui	a5,0x9e370
ffffffffc02049ee:	2785                	addiw	a5,a5,1
ffffffffc02049f0:	02a787bb          	mulw	a5,a5,a0
ffffffffc02049f4:	02000513          	li	a0,32
ffffffffc02049f8:	9d0d                	subw	a0,a0,a1
ffffffffc02049fa:	00a7d53b          	srlw	a0,a5,a0
ffffffffc02049fe:	8082                	ret

ffffffffc0204a00 <printnum>:
ffffffffc0204a00:	02069813          	slli	a6,a3,0x20
ffffffffc0204a04:	7179                	addi	sp,sp,-48
ffffffffc0204a06:	02085813          	srli	a6,a6,0x20
ffffffffc0204a0a:	e052                	sd	s4,0(sp)
ffffffffc0204a0c:	03067a33          	remu	s4,a2,a6
ffffffffc0204a10:	f022                	sd	s0,32(sp)
ffffffffc0204a12:	ec26                	sd	s1,24(sp)
ffffffffc0204a14:	e84a                	sd	s2,16(sp)
ffffffffc0204a16:	f406                	sd	ra,40(sp)
ffffffffc0204a18:	e44e                	sd	s3,8(sp)
ffffffffc0204a1a:	84aa                	mv	s1,a0
ffffffffc0204a1c:	892e                	mv	s2,a1
ffffffffc0204a1e:	fff7041b          	addiw	s0,a4,-1
ffffffffc0204a22:	2a01                	sext.w	s4,s4
ffffffffc0204a24:	03067f63          	bgeu	a2,a6,ffffffffc0204a62 <printnum+0x62>
ffffffffc0204a28:	89be                	mv	s3,a5
ffffffffc0204a2a:	4785                	li	a5,1
ffffffffc0204a2c:	00e7d763          	bge	a5,a4,ffffffffc0204a3a <printnum+0x3a>
ffffffffc0204a30:	347d                	addiw	s0,s0,-1
ffffffffc0204a32:	85ca                	mv	a1,s2
ffffffffc0204a34:	854e                	mv	a0,s3
ffffffffc0204a36:	9482                	jalr	s1
ffffffffc0204a38:	fc65                	bnez	s0,ffffffffc0204a30 <printnum+0x30>
ffffffffc0204a3a:	1a02                	slli	s4,s4,0x20
ffffffffc0204a3c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204a40:	00002797          	auipc	a5,0x2
ffffffffc0204a44:	37878793          	addi	a5,a5,888 # ffffffffc0206db8 <default_pmm_manager+0x1198>
ffffffffc0204a48:	97d2                	add	a5,a5,s4
ffffffffc0204a4a:	7402                	ld	s0,32(sp)
ffffffffc0204a4c:	0007c503          	lbu	a0,0(a5)
ffffffffc0204a50:	70a2                	ld	ra,40(sp)
ffffffffc0204a52:	69a2                	ld	s3,8(sp)
ffffffffc0204a54:	6a02                	ld	s4,0(sp)
ffffffffc0204a56:	85ca                	mv	a1,s2
ffffffffc0204a58:	87a6                	mv	a5,s1
ffffffffc0204a5a:	6942                	ld	s2,16(sp)
ffffffffc0204a5c:	64e2                	ld	s1,24(sp)
ffffffffc0204a5e:	6145                	addi	sp,sp,48
ffffffffc0204a60:	8782                	jr	a5
ffffffffc0204a62:	03065633          	divu	a2,a2,a6
ffffffffc0204a66:	8722                	mv	a4,s0
ffffffffc0204a68:	f99ff0ef          	jal	ra,ffffffffc0204a00 <printnum>
ffffffffc0204a6c:	b7f9                	j	ffffffffc0204a3a <printnum+0x3a>

ffffffffc0204a6e <vprintfmt>:
ffffffffc0204a6e:	7119                	addi	sp,sp,-128
ffffffffc0204a70:	f4a6                	sd	s1,104(sp)
ffffffffc0204a72:	f0ca                	sd	s2,96(sp)
ffffffffc0204a74:	ecce                	sd	s3,88(sp)
ffffffffc0204a76:	e8d2                	sd	s4,80(sp)
ffffffffc0204a78:	e4d6                	sd	s5,72(sp)
ffffffffc0204a7a:	e0da                	sd	s6,64(sp)
ffffffffc0204a7c:	f862                	sd	s8,48(sp)
ffffffffc0204a7e:	fc86                	sd	ra,120(sp)
ffffffffc0204a80:	f8a2                	sd	s0,112(sp)
ffffffffc0204a82:	fc5e                	sd	s7,56(sp)
ffffffffc0204a84:	f466                	sd	s9,40(sp)
ffffffffc0204a86:	f06a                	sd	s10,32(sp)
ffffffffc0204a88:	ec6e                	sd	s11,24(sp)
ffffffffc0204a8a:	892a                	mv	s2,a0
ffffffffc0204a8c:	84ae                	mv	s1,a1
ffffffffc0204a8e:	8c32                	mv	s8,a2
ffffffffc0204a90:	8a36                	mv	s4,a3
ffffffffc0204a92:	02500993          	li	s3,37
ffffffffc0204a96:	05500b13          	li	s6,85
ffffffffc0204a9a:	00002a97          	auipc	s5,0x2
ffffffffc0204a9e:	34aa8a93          	addi	s5,s5,842 # ffffffffc0206de4 <default_pmm_manager+0x11c4>
ffffffffc0204aa2:	000c4503          	lbu	a0,0(s8)
ffffffffc0204aa6:	001c0413          	addi	s0,s8,1
ffffffffc0204aaa:	01350a63          	beq	a0,s3,ffffffffc0204abe <vprintfmt+0x50>
ffffffffc0204aae:	cd0d                	beqz	a0,ffffffffc0204ae8 <vprintfmt+0x7a>
ffffffffc0204ab0:	85a6                	mv	a1,s1
ffffffffc0204ab2:	0405                	addi	s0,s0,1
ffffffffc0204ab4:	9902                	jalr	s2
ffffffffc0204ab6:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204aba:	ff351ae3          	bne	a0,s3,ffffffffc0204aae <vprintfmt+0x40>
ffffffffc0204abe:	02000d93          	li	s11,32
ffffffffc0204ac2:	4b81                	li	s7,0
ffffffffc0204ac4:	4601                	li	a2,0
ffffffffc0204ac6:	5d7d                	li	s10,-1
ffffffffc0204ac8:	5cfd                	li	s9,-1
ffffffffc0204aca:	00044683          	lbu	a3,0(s0)
ffffffffc0204ace:	00140c13          	addi	s8,s0,1
ffffffffc0204ad2:	fdd6859b          	addiw	a1,a3,-35
ffffffffc0204ad6:	0ff5f593          	andi	a1,a1,255
ffffffffc0204ada:	02bb6663          	bltu	s6,a1,ffffffffc0204b06 <vprintfmt+0x98>
ffffffffc0204ade:	058a                	slli	a1,a1,0x2
ffffffffc0204ae0:	95d6                	add	a1,a1,s5
ffffffffc0204ae2:	4198                	lw	a4,0(a1)
ffffffffc0204ae4:	9756                	add	a4,a4,s5
ffffffffc0204ae6:	8702                	jr	a4
ffffffffc0204ae8:	70e6                	ld	ra,120(sp)
ffffffffc0204aea:	7446                	ld	s0,112(sp)
ffffffffc0204aec:	74a6                	ld	s1,104(sp)
ffffffffc0204aee:	7906                	ld	s2,96(sp)
ffffffffc0204af0:	69e6                	ld	s3,88(sp)
ffffffffc0204af2:	6a46                	ld	s4,80(sp)
ffffffffc0204af4:	6aa6                	ld	s5,72(sp)
ffffffffc0204af6:	6b06                	ld	s6,64(sp)
ffffffffc0204af8:	7be2                	ld	s7,56(sp)
ffffffffc0204afa:	7c42                	ld	s8,48(sp)
ffffffffc0204afc:	7ca2                	ld	s9,40(sp)
ffffffffc0204afe:	7d02                	ld	s10,32(sp)
ffffffffc0204b00:	6de2                	ld	s11,24(sp)
ffffffffc0204b02:	6109                	addi	sp,sp,128
ffffffffc0204b04:	8082                	ret
ffffffffc0204b06:	85a6                	mv	a1,s1
ffffffffc0204b08:	02500513          	li	a0,37
ffffffffc0204b0c:	9902                	jalr	s2
ffffffffc0204b0e:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204b12:	02500793          	li	a5,37
ffffffffc0204b16:	8c22                	mv	s8,s0
ffffffffc0204b18:	f8f705e3          	beq	a4,a5,ffffffffc0204aa2 <vprintfmt+0x34>
ffffffffc0204b1c:	02500713          	li	a4,37
ffffffffc0204b20:	ffec4783          	lbu	a5,-2(s8)
ffffffffc0204b24:	1c7d                	addi	s8,s8,-1
ffffffffc0204b26:	fee79de3          	bne	a5,a4,ffffffffc0204b20 <vprintfmt+0xb2>
ffffffffc0204b2a:	bfa5                	j	ffffffffc0204aa2 <vprintfmt+0x34>
ffffffffc0204b2c:	00144783          	lbu	a5,1(s0)
ffffffffc0204b30:	4725                	li	a4,9
ffffffffc0204b32:	fd068d1b          	addiw	s10,a3,-48
ffffffffc0204b36:	fd07859b          	addiw	a1,a5,-48
ffffffffc0204b3a:	0007869b          	sext.w	a3,a5
ffffffffc0204b3e:	8462                	mv	s0,s8
ffffffffc0204b40:	02b76563          	bltu	a4,a1,ffffffffc0204b6a <vprintfmt+0xfc>
ffffffffc0204b44:	4525                	li	a0,9
ffffffffc0204b46:	00144783          	lbu	a5,1(s0)
ffffffffc0204b4a:	002d171b          	slliw	a4,s10,0x2
ffffffffc0204b4e:	01a7073b          	addw	a4,a4,s10
ffffffffc0204b52:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204b56:	9f35                	addw	a4,a4,a3
ffffffffc0204b58:	fd07859b          	addiw	a1,a5,-48
ffffffffc0204b5c:	0405                	addi	s0,s0,1
ffffffffc0204b5e:	fd070d1b          	addiw	s10,a4,-48
ffffffffc0204b62:	0007869b          	sext.w	a3,a5
ffffffffc0204b66:	feb570e3          	bgeu	a0,a1,ffffffffc0204b46 <vprintfmt+0xd8>
ffffffffc0204b6a:	f60cd0e3          	bgez	s9,ffffffffc0204aca <vprintfmt+0x5c>
ffffffffc0204b6e:	8cea                	mv	s9,s10
ffffffffc0204b70:	5d7d                	li	s10,-1
ffffffffc0204b72:	bfa1                	j	ffffffffc0204aca <vprintfmt+0x5c>
ffffffffc0204b74:	8db6                	mv	s11,a3
ffffffffc0204b76:	8462                	mv	s0,s8
ffffffffc0204b78:	bf89                	j	ffffffffc0204aca <vprintfmt+0x5c>
ffffffffc0204b7a:	8462                	mv	s0,s8
ffffffffc0204b7c:	4b85                	li	s7,1
ffffffffc0204b7e:	b7b1                	j	ffffffffc0204aca <vprintfmt+0x5c>
ffffffffc0204b80:	4785                	li	a5,1
ffffffffc0204b82:	008a0713          	addi	a4,s4,8
ffffffffc0204b86:	00c7c463          	blt	a5,a2,ffffffffc0204b8e <vprintfmt+0x120>
ffffffffc0204b8a:	1a060263          	beqz	a2,ffffffffc0204d2e <vprintfmt+0x2c0>
ffffffffc0204b8e:	000a3603          	ld	a2,0(s4)
ffffffffc0204b92:	46c1                	li	a3,16
ffffffffc0204b94:	8a3a                	mv	s4,a4
ffffffffc0204b96:	000d879b          	sext.w	a5,s11
ffffffffc0204b9a:	8766                	mv	a4,s9
ffffffffc0204b9c:	85a6                	mv	a1,s1
ffffffffc0204b9e:	854a                	mv	a0,s2
ffffffffc0204ba0:	e61ff0ef          	jal	ra,ffffffffc0204a00 <printnum>
ffffffffc0204ba4:	bdfd                	j	ffffffffc0204aa2 <vprintfmt+0x34>
ffffffffc0204ba6:	000a2503          	lw	a0,0(s4)
ffffffffc0204baa:	85a6                	mv	a1,s1
ffffffffc0204bac:	0a21                	addi	s4,s4,8
ffffffffc0204bae:	9902                	jalr	s2
ffffffffc0204bb0:	bdcd                	j	ffffffffc0204aa2 <vprintfmt+0x34>
ffffffffc0204bb2:	4785                	li	a5,1
ffffffffc0204bb4:	008a0713          	addi	a4,s4,8
ffffffffc0204bb8:	00c7c463          	blt	a5,a2,ffffffffc0204bc0 <vprintfmt+0x152>
ffffffffc0204bbc:	16060463          	beqz	a2,ffffffffc0204d24 <vprintfmt+0x2b6>
ffffffffc0204bc0:	000a3603          	ld	a2,0(s4)
ffffffffc0204bc4:	46a9                	li	a3,10
ffffffffc0204bc6:	8a3a                	mv	s4,a4
ffffffffc0204bc8:	b7f9                	j	ffffffffc0204b96 <vprintfmt+0x128>
ffffffffc0204bca:	03000513          	li	a0,48
ffffffffc0204bce:	85a6                	mv	a1,s1
ffffffffc0204bd0:	9902                	jalr	s2
ffffffffc0204bd2:	85a6                	mv	a1,s1
ffffffffc0204bd4:	07800513          	li	a0,120
ffffffffc0204bd8:	9902                	jalr	s2
ffffffffc0204bda:	0a21                	addi	s4,s4,8
ffffffffc0204bdc:	46c1                	li	a3,16
ffffffffc0204bde:	ff8a3603          	ld	a2,-8(s4)
ffffffffc0204be2:	bf55                	j	ffffffffc0204b96 <vprintfmt+0x128>
ffffffffc0204be4:	85a6                	mv	a1,s1
ffffffffc0204be6:	02500513          	li	a0,37
ffffffffc0204bea:	9902                	jalr	s2
ffffffffc0204bec:	bd5d                	j	ffffffffc0204aa2 <vprintfmt+0x34>
ffffffffc0204bee:	000a2d03          	lw	s10,0(s4)
ffffffffc0204bf2:	8462                	mv	s0,s8
ffffffffc0204bf4:	0a21                	addi	s4,s4,8
ffffffffc0204bf6:	bf95                	j	ffffffffc0204b6a <vprintfmt+0xfc>
ffffffffc0204bf8:	4785                	li	a5,1
ffffffffc0204bfa:	008a0713          	addi	a4,s4,8
ffffffffc0204bfe:	00c7c463          	blt	a5,a2,ffffffffc0204c06 <vprintfmt+0x198>
ffffffffc0204c02:	10060c63          	beqz	a2,ffffffffc0204d1a <vprintfmt+0x2ac>
ffffffffc0204c06:	000a3603          	ld	a2,0(s4)
ffffffffc0204c0a:	46a1                	li	a3,8
ffffffffc0204c0c:	8a3a                	mv	s4,a4
ffffffffc0204c0e:	b761                	j	ffffffffc0204b96 <vprintfmt+0x128>
ffffffffc0204c10:	fffcc793          	not	a5,s9
ffffffffc0204c14:	97fd                	srai	a5,a5,0x3f
ffffffffc0204c16:	00fcf7b3          	and	a5,s9,a5
ffffffffc0204c1a:	00078c9b          	sext.w	s9,a5
ffffffffc0204c1e:	8462                	mv	s0,s8
ffffffffc0204c20:	b56d                	j	ffffffffc0204aca <vprintfmt+0x5c>
ffffffffc0204c22:	000a3403          	ld	s0,0(s4)
ffffffffc0204c26:	008a0793          	addi	a5,s4,8
ffffffffc0204c2a:	e43e                	sd	a5,8(sp)
ffffffffc0204c2c:	12040163          	beqz	s0,ffffffffc0204d4e <vprintfmt+0x2e0>
ffffffffc0204c30:	0d905963          	blez	s9,ffffffffc0204d02 <vprintfmt+0x294>
ffffffffc0204c34:	02d00793          	li	a5,45
ffffffffc0204c38:	00140a13          	addi	s4,s0,1
ffffffffc0204c3c:	12fd9863          	bne	s11,a5,ffffffffc0204d6c <vprintfmt+0x2fe>
ffffffffc0204c40:	00044783          	lbu	a5,0(s0)
ffffffffc0204c44:	0007851b          	sext.w	a0,a5
ffffffffc0204c48:	cb9d                	beqz	a5,ffffffffc0204c7e <vprintfmt+0x210>
ffffffffc0204c4a:	547d                	li	s0,-1
ffffffffc0204c4c:	05e00d93          	li	s11,94
ffffffffc0204c50:	000d4563          	bltz	s10,ffffffffc0204c5a <vprintfmt+0x1ec>
ffffffffc0204c54:	3d7d                	addiw	s10,s10,-1
ffffffffc0204c56:	028d0263          	beq	s10,s0,ffffffffc0204c7a <vprintfmt+0x20c>
ffffffffc0204c5a:	85a6                	mv	a1,s1
ffffffffc0204c5c:	0c0b8e63          	beqz	s7,ffffffffc0204d38 <vprintfmt+0x2ca>
ffffffffc0204c60:	3781                	addiw	a5,a5,-32
ffffffffc0204c62:	0cfdfb63          	bgeu	s11,a5,ffffffffc0204d38 <vprintfmt+0x2ca>
ffffffffc0204c66:	03f00513          	li	a0,63
ffffffffc0204c6a:	9902                	jalr	s2
ffffffffc0204c6c:	000a4783          	lbu	a5,0(s4)
ffffffffc0204c70:	3cfd                	addiw	s9,s9,-1
ffffffffc0204c72:	0a05                	addi	s4,s4,1
ffffffffc0204c74:	0007851b          	sext.w	a0,a5
ffffffffc0204c78:	ffe1                	bnez	a5,ffffffffc0204c50 <vprintfmt+0x1e2>
ffffffffc0204c7a:	01905963          	blez	s9,ffffffffc0204c8c <vprintfmt+0x21e>
ffffffffc0204c7e:	3cfd                	addiw	s9,s9,-1
ffffffffc0204c80:	85a6                	mv	a1,s1
ffffffffc0204c82:	02000513          	li	a0,32
ffffffffc0204c86:	9902                	jalr	s2
ffffffffc0204c88:	fe0c9be3          	bnez	s9,ffffffffc0204c7e <vprintfmt+0x210>
ffffffffc0204c8c:	6a22                	ld	s4,8(sp)
ffffffffc0204c8e:	bd11                	j	ffffffffc0204aa2 <vprintfmt+0x34>
ffffffffc0204c90:	4785                	li	a5,1
ffffffffc0204c92:	008a0b93          	addi	s7,s4,8
ffffffffc0204c96:	00c7c363          	blt	a5,a2,ffffffffc0204c9c <vprintfmt+0x22e>
ffffffffc0204c9a:	ce2d                	beqz	a2,ffffffffc0204d14 <vprintfmt+0x2a6>
ffffffffc0204c9c:	000a3403          	ld	s0,0(s4)
ffffffffc0204ca0:	08044e63          	bltz	s0,ffffffffc0204d3c <vprintfmt+0x2ce>
ffffffffc0204ca4:	8622                	mv	a2,s0
ffffffffc0204ca6:	8a5e                	mv	s4,s7
ffffffffc0204ca8:	46a9                	li	a3,10
ffffffffc0204caa:	b5f5                	j	ffffffffc0204b96 <vprintfmt+0x128>
ffffffffc0204cac:	000a2783          	lw	a5,0(s4)
ffffffffc0204cb0:	4619                	li	a2,6
ffffffffc0204cb2:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc0204cb6:	8fb9                	xor	a5,a5,a4
ffffffffc0204cb8:	40e786bb          	subw	a3,a5,a4
ffffffffc0204cbc:	02d64663          	blt	a2,a3,ffffffffc0204ce8 <vprintfmt+0x27a>
ffffffffc0204cc0:	00369713          	slli	a4,a3,0x3
ffffffffc0204cc4:	00002797          	auipc	a5,0x2
ffffffffc0204cc8:	2fc78793          	addi	a5,a5,764 # ffffffffc0206fc0 <error_string>
ffffffffc0204ccc:	97ba                	add	a5,a5,a4
ffffffffc0204cce:	639c                	ld	a5,0(a5)
ffffffffc0204cd0:	cf81                	beqz	a5,ffffffffc0204ce8 <vprintfmt+0x27a>
ffffffffc0204cd2:	86be                	mv	a3,a5
ffffffffc0204cd4:	00000617          	auipc	a2,0x0
ffffffffc0204cd8:	22460613          	addi	a2,a2,548 # ffffffffc0204ef8 <etext+0x2a>
ffffffffc0204cdc:	85a6                	mv	a1,s1
ffffffffc0204cde:	854a                	mv	a0,s2
ffffffffc0204ce0:	0ea000ef          	jal	ra,ffffffffc0204dca <printfmt>
ffffffffc0204ce4:	0a21                	addi	s4,s4,8
ffffffffc0204ce6:	bb75                	j	ffffffffc0204aa2 <vprintfmt+0x34>
ffffffffc0204ce8:	00002617          	auipc	a2,0x2
ffffffffc0204cec:	0f060613          	addi	a2,a2,240 # ffffffffc0206dd8 <default_pmm_manager+0x11b8>
ffffffffc0204cf0:	85a6                	mv	a1,s1
ffffffffc0204cf2:	854a                	mv	a0,s2
ffffffffc0204cf4:	0d6000ef          	jal	ra,ffffffffc0204dca <printfmt>
ffffffffc0204cf8:	0a21                	addi	s4,s4,8
ffffffffc0204cfa:	b365                	j	ffffffffc0204aa2 <vprintfmt+0x34>
ffffffffc0204cfc:	2605                	addiw	a2,a2,1
ffffffffc0204cfe:	8462                	mv	s0,s8
ffffffffc0204d00:	b3e9                	j	ffffffffc0204aca <vprintfmt+0x5c>
ffffffffc0204d02:	00044783          	lbu	a5,0(s0)
ffffffffc0204d06:	00140a13          	addi	s4,s0,1
ffffffffc0204d0a:	0007851b          	sext.w	a0,a5
ffffffffc0204d0e:	ff95                	bnez	a5,ffffffffc0204c4a <vprintfmt+0x1dc>
ffffffffc0204d10:	6a22                	ld	s4,8(sp)
ffffffffc0204d12:	bb41                	j	ffffffffc0204aa2 <vprintfmt+0x34>
ffffffffc0204d14:	000a2403          	lw	s0,0(s4)
ffffffffc0204d18:	b761                	j	ffffffffc0204ca0 <vprintfmt+0x232>
ffffffffc0204d1a:	000a6603          	lwu	a2,0(s4)
ffffffffc0204d1e:	46a1                	li	a3,8
ffffffffc0204d20:	8a3a                	mv	s4,a4
ffffffffc0204d22:	bd95                	j	ffffffffc0204b96 <vprintfmt+0x128>
ffffffffc0204d24:	000a6603          	lwu	a2,0(s4)
ffffffffc0204d28:	46a9                	li	a3,10
ffffffffc0204d2a:	8a3a                	mv	s4,a4
ffffffffc0204d2c:	b5ad                	j	ffffffffc0204b96 <vprintfmt+0x128>
ffffffffc0204d2e:	000a6603          	lwu	a2,0(s4)
ffffffffc0204d32:	46c1                	li	a3,16
ffffffffc0204d34:	8a3a                	mv	s4,a4
ffffffffc0204d36:	b585                	j	ffffffffc0204b96 <vprintfmt+0x128>
ffffffffc0204d38:	9902                	jalr	s2
ffffffffc0204d3a:	bf0d                	j	ffffffffc0204c6c <vprintfmt+0x1fe>
ffffffffc0204d3c:	85a6                	mv	a1,s1
ffffffffc0204d3e:	02d00513          	li	a0,45
ffffffffc0204d42:	9902                	jalr	s2
ffffffffc0204d44:	8a5e                	mv	s4,s7
ffffffffc0204d46:	40800633          	neg	a2,s0
ffffffffc0204d4a:	46a9                	li	a3,10
ffffffffc0204d4c:	b5a9                	j	ffffffffc0204b96 <vprintfmt+0x128>
ffffffffc0204d4e:	01905663          	blez	s9,ffffffffc0204d5a <vprintfmt+0x2ec>
ffffffffc0204d52:	02d00793          	li	a5,45
ffffffffc0204d56:	04fd9263          	bne	s11,a5,ffffffffc0204d9a <vprintfmt+0x32c>
ffffffffc0204d5a:	00002a17          	auipc	s4,0x2
ffffffffc0204d5e:	077a0a13          	addi	s4,s4,119 # ffffffffc0206dd1 <default_pmm_manager+0x11b1>
ffffffffc0204d62:	02800513          	li	a0,40
ffffffffc0204d66:	02800793          	li	a5,40
ffffffffc0204d6a:	b5c5                	j	ffffffffc0204c4a <vprintfmt+0x1dc>
ffffffffc0204d6c:	85ea                	mv	a1,s10
ffffffffc0204d6e:	8522                	mv	a0,s0
ffffffffc0204d70:	094000ef          	jal	ra,ffffffffc0204e04 <strnlen>
ffffffffc0204d74:	40ac8cbb          	subw	s9,s9,a0
ffffffffc0204d78:	01905963          	blez	s9,ffffffffc0204d8a <vprintfmt+0x31c>
ffffffffc0204d7c:	2d81                	sext.w	s11,s11
ffffffffc0204d7e:	3cfd                	addiw	s9,s9,-1
ffffffffc0204d80:	85a6                	mv	a1,s1
ffffffffc0204d82:	856e                	mv	a0,s11
ffffffffc0204d84:	9902                	jalr	s2
ffffffffc0204d86:	fe0c9ce3          	bnez	s9,ffffffffc0204d7e <vprintfmt+0x310>
ffffffffc0204d8a:	00044783          	lbu	a5,0(s0)
ffffffffc0204d8e:	0007851b          	sext.w	a0,a5
ffffffffc0204d92:	ea079ce3          	bnez	a5,ffffffffc0204c4a <vprintfmt+0x1dc>
ffffffffc0204d96:	6a22                	ld	s4,8(sp)
ffffffffc0204d98:	b329                	j	ffffffffc0204aa2 <vprintfmt+0x34>
ffffffffc0204d9a:	85ea                	mv	a1,s10
ffffffffc0204d9c:	00002517          	auipc	a0,0x2
ffffffffc0204da0:	03450513          	addi	a0,a0,52 # ffffffffc0206dd0 <default_pmm_manager+0x11b0>
ffffffffc0204da4:	060000ef          	jal	ra,ffffffffc0204e04 <strnlen>
ffffffffc0204da8:	40ac8cbb          	subw	s9,s9,a0
ffffffffc0204dac:	00002a17          	auipc	s4,0x2
ffffffffc0204db0:	025a0a13          	addi	s4,s4,37 # ffffffffc0206dd1 <default_pmm_manager+0x11b1>
ffffffffc0204db4:	00002417          	auipc	s0,0x2
ffffffffc0204db8:	01c40413          	addi	s0,s0,28 # ffffffffc0206dd0 <default_pmm_manager+0x11b0>
ffffffffc0204dbc:	02800513          	li	a0,40
ffffffffc0204dc0:	02800793          	li	a5,40
ffffffffc0204dc4:	fb904ce3          	bgtz	s9,ffffffffc0204d7c <vprintfmt+0x30e>
ffffffffc0204dc8:	b549                	j	ffffffffc0204c4a <vprintfmt+0x1dc>

ffffffffc0204dca <printfmt>:
ffffffffc0204dca:	715d                	addi	sp,sp,-80
ffffffffc0204dcc:	02810313          	addi	t1,sp,40
ffffffffc0204dd0:	f436                	sd	a3,40(sp)
ffffffffc0204dd2:	869a                	mv	a3,t1
ffffffffc0204dd4:	ec06                	sd	ra,24(sp)
ffffffffc0204dd6:	f83a                	sd	a4,48(sp)
ffffffffc0204dd8:	fc3e                	sd	a5,56(sp)
ffffffffc0204dda:	e0c2                	sd	a6,64(sp)
ffffffffc0204ddc:	e4c6                	sd	a7,72(sp)
ffffffffc0204dde:	e41a                	sd	t1,8(sp)
ffffffffc0204de0:	c8fff0ef          	jal	ra,ffffffffc0204a6e <vprintfmt>
ffffffffc0204de4:	60e2                	ld	ra,24(sp)
ffffffffc0204de6:	6161                	addi	sp,sp,80
ffffffffc0204de8:	8082                	ret

ffffffffc0204dea <strlen>:
ffffffffc0204dea:	00054783          	lbu	a5,0(a0)
ffffffffc0204dee:	872a                	mv	a4,a0
ffffffffc0204df0:	4501                	li	a0,0
ffffffffc0204df2:	cb81                	beqz	a5,ffffffffc0204e02 <strlen+0x18>
ffffffffc0204df4:	0505                	addi	a0,a0,1
ffffffffc0204df6:	00a707b3          	add	a5,a4,a0
ffffffffc0204dfa:	0007c783          	lbu	a5,0(a5)
ffffffffc0204dfe:	fbfd                	bnez	a5,ffffffffc0204df4 <strlen+0xa>
ffffffffc0204e00:	8082                	ret
ffffffffc0204e02:	8082                	ret

ffffffffc0204e04 <strnlen>:
ffffffffc0204e04:	4781                	li	a5,0
ffffffffc0204e06:	e589                	bnez	a1,ffffffffc0204e10 <strnlen+0xc>
ffffffffc0204e08:	a811                	j	ffffffffc0204e1c <strnlen+0x18>
ffffffffc0204e0a:	0785                	addi	a5,a5,1
ffffffffc0204e0c:	00f58863          	beq	a1,a5,ffffffffc0204e1c <strnlen+0x18>
ffffffffc0204e10:	00f50733          	add	a4,a0,a5
ffffffffc0204e14:	00074703          	lbu	a4,0(a4)
ffffffffc0204e18:	fb6d                	bnez	a4,ffffffffc0204e0a <strnlen+0x6>
ffffffffc0204e1a:	85be                	mv	a1,a5
ffffffffc0204e1c:	852e                	mv	a0,a1
ffffffffc0204e1e:	8082                	ret

ffffffffc0204e20 <strcpy>:
ffffffffc0204e20:	87aa                	mv	a5,a0
ffffffffc0204e22:	0005c703          	lbu	a4,0(a1)
ffffffffc0204e26:	0785                	addi	a5,a5,1
ffffffffc0204e28:	0585                	addi	a1,a1,1
ffffffffc0204e2a:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204e2e:	fb75                	bnez	a4,ffffffffc0204e22 <strcpy+0x2>
ffffffffc0204e30:	8082                	ret

ffffffffc0204e32 <strcmp>:
ffffffffc0204e32:	00054783          	lbu	a5,0(a0)
ffffffffc0204e36:	e791                	bnez	a5,ffffffffc0204e42 <strcmp+0x10>
ffffffffc0204e38:	a02d                	j	ffffffffc0204e62 <strcmp+0x30>
ffffffffc0204e3a:	00054783          	lbu	a5,0(a0)
ffffffffc0204e3e:	cf89                	beqz	a5,ffffffffc0204e58 <strcmp+0x26>
ffffffffc0204e40:	85b6                	mv	a1,a3
ffffffffc0204e42:	0005c703          	lbu	a4,0(a1)
ffffffffc0204e46:	0505                	addi	a0,a0,1
ffffffffc0204e48:	00158693          	addi	a3,a1,1
ffffffffc0204e4c:	fef707e3          	beq	a4,a5,ffffffffc0204e3a <strcmp+0x8>
ffffffffc0204e50:	0007851b          	sext.w	a0,a5
ffffffffc0204e54:	9d19                	subw	a0,a0,a4
ffffffffc0204e56:	8082                	ret
ffffffffc0204e58:	0015c703          	lbu	a4,1(a1)
ffffffffc0204e5c:	4501                	li	a0,0
ffffffffc0204e5e:	9d19                	subw	a0,a0,a4
ffffffffc0204e60:	8082                	ret
ffffffffc0204e62:	0005c703          	lbu	a4,0(a1)
ffffffffc0204e66:	4501                	li	a0,0
ffffffffc0204e68:	b7f5                	j	ffffffffc0204e54 <strcmp+0x22>

ffffffffc0204e6a <strchr>:
ffffffffc0204e6a:	00054783          	lbu	a5,0(a0)
ffffffffc0204e6e:	c799                	beqz	a5,ffffffffc0204e7c <strchr+0x12>
ffffffffc0204e70:	00f58763          	beq	a1,a5,ffffffffc0204e7e <strchr+0x14>
ffffffffc0204e74:	00154783          	lbu	a5,1(a0)
ffffffffc0204e78:	0505                	addi	a0,a0,1
ffffffffc0204e7a:	fbfd                	bnez	a5,ffffffffc0204e70 <strchr+0x6>
ffffffffc0204e7c:	4501                	li	a0,0
ffffffffc0204e7e:	8082                	ret

ffffffffc0204e80 <memset>:
ffffffffc0204e80:	ca01                	beqz	a2,ffffffffc0204e90 <memset+0x10>
ffffffffc0204e82:	962a                	add	a2,a2,a0
ffffffffc0204e84:	87aa                	mv	a5,a0
ffffffffc0204e86:	0785                	addi	a5,a5,1
ffffffffc0204e88:	feb78fa3          	sb	a1,-1(a5)
ffffffffc0204e8c:	fec79de3          	bne	a5,a2,ffffffffc0204e86 <memset+0x6>
ffffffffc0204e90:	8082                	ret

ffffffffc0204e92 <memcpy>:
ffffffffc0204e92:	ca19                	beqz	a2,ffffffffc0204ea8 <memcpy+0x16>
ffffffffc0204e94:	962e                	add	a2,a2,a1
ffffffffc0204e96:	87aa                	mv	a5,a0
ffffffffc0204e98:	0005c703          	lbu	a4,0(a1)
ffffffffc0204e9c:	0585                	addi	a1,a1,1
ffffffffc0204e9e:	0785                	addi	a5,a5,1
ffffffffc0204ea0:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204ea4:	fec59ae3          	bne	a1,a2,ffffffffc0204e98 <memcpy+0x6>
ffffffffc0204ea8:	8082                	ret

ffffffffc0204eaa <memcmp>:
ffffffffc0204eaa:	c205                	beqz	a2,ffffffffc0204eca <memcmp+0x20>
ffffffffc0204eac:	962e                	add	a2,a2,a1
ffffffffc0204eae:	a019                	j	ffffffffc0204eb4 <memcmp+0xa>
ffffffffc0204eb0:	00c58d63          	beq	a1,a2,ffffffffc0204eca <memcmp+0x20>
ffffffffc0204eb4:	00054783          	lbu	a5,0(a0)
ffffffffc0204eb8:	0005c703          	lbu	a4,0(a1)
ffffffffc0204ebc:	0505                	addi	a0,a0,1
ffffffffc0204ebe:	0585                	addi	a1,a1,1
ffffffffc0204ec0:	fee788e3          	beq	a5,a4,ffffffffc0204eb0 <memcmp+0x6>
ffffffffc0204ec4:	40e7853b          	subw	a0,a5,a4
ffffffffc0204ec8:	8082                	ret
ffffffffc0204eca:	4501                	li	a0,0
ffffffffc0204ecc:	8082                	ret
