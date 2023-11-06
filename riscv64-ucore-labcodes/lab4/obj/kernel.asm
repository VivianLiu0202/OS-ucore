
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
ffffffffc0200036:	02650513          	addi	a0,a0,38 # ffffffffc020a058 <buf>
ffffffffc020003a:	00015617          	auipc	a2,0x15
ffffffffc020003e:	58e60613          	addi	a2,a2,1422 # ffffffffc02155c8 <end>
ffffffffc0200042:	1141                	addi	sp,sp,-16
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
ffffffffc0200048:	e406                	sd	ra,8(sp)
ffffffffc020004a:	221040ef          	jal	ra,ffffffffc0204a6a <memset>
ffffffffc020004e:	49e000ef          	jal	ra,ffffffffc02004ec <cons_init>
ffffffffc0200052:	00005597          	auipc	a1,0x5
ffffffffc0200056:	a6658593          	addi	a1,a1,-1434 # ffffffffc0204ab8 <etext>
ffffffffc020005a:	00005517          	auipc	a0,0x5
ffffffffc020005e:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0204ad8 <etext+0x20>
ffffffffc0200062:	128000ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200066:	16c000ef          	jal	ra,ffffffffc02001d2 <print_kerninfo>
ffffffffc020006a:	671010ef          	jal	ra,ffffffffc0201eda <pmm_init>
ffffffffc020006e:	552000ef          	jal	ra,ffffffffc02005c0 <pic_init>
ffffffffc0200072:	5c0000ef          	jal	ra,ffffffffc0200632 <idt_init>
ffffffffc0200076:	171030ef          	jal	ra,ffffffffc02039e6 <vmm_init>
ffffffffc020007a:	25c040ef          	jal	ra,ffffffffc02042d6 <proc_init>
ffffffffc020007e:	4e0000ef          	jal	ra,ffffffffc020055e <ide_init>
ffffffffc0200082:	2cd020ef          	jal	ra,ffffffffc0202b4e <swap_init>
ffffffffc0200086:	414000ef          	jal	ra,ffffffffc020049a <clock_init>
ffffffffc020008a:	52a000ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc020008e:	498040ef          	jal	ra,ffffffffc0204526 <cpu_idle>

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
ffffffffc02000ae:	a3650513          	addi	a0,a0,-1482 # ffffffffc0204ae0 <etext+0x28>
ffffffffc02000b2:	0d8000ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02000b6:	4481                	li	s1,0
ffffffffc02000b8:	497d                	li	s2,31
ffffffffc02000ba:	4a21                	li	s4,8
ffffffffc02000bc:	4aa9                	li	s5,10
ffffffffc02000be:	4b35                	li	s6,13
ffffffffc02000c0:	0000ab97          	auipc	s7,0xa
ffffffffc02000c4:	f98b8b93          	addi	s7,s7,-104 # ffffffffc020a058 <buf>
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
ffffffffc0200130:	f2c50513          	addi	a0,a0,-212 # ffffffffc020a058 <buf>
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
ffffffffc020017e:	4da040ef          	jal	ra,ffffffffc0204658 <vprintfmt>
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
ffffffffc02001b4:	4a4040ef          	jal	ra,ffffffffc0204658 <vprintfmt>
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
ffffffffc02001d8:	91450513          	addi	a0,a0,-1772 # ffffffffc0204ae8 <etext+0x30>
ffffffffc02001dc:	e406                	sd	ra,8(sp)
ffffffffc02001de:	fadff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02001e2:	00000597          	auipc	a1,0x0
ffffffffc02001e6:	e5058593          	addi	a1,a1,-432 # ffffffffc0200032 <kern_init>
ffffffffc02001ea:	00005517          	auipc	a0,0x5
ffffffffc02001ee:	91e50513          	addi	a0,a0,-1762 # ffffffffc0204b08 <etext+0x50>
ffffffffc02001f2:	f99ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02001f6:	00005597          	auipc	a1,0x5
ffffffffc02001fa:	8c258593          	addi	a1,a1,-1854 # ffffffffc0204ab8 <etext>
ffffffffc02001fe:	00005517          	auipc	a0,0x5
ffffffffc0200202:	92a50513          	addi	a0,a0,-1750 # ffffffffc0204b28 <etext+0x70>
ffffffffc0200206:	f85ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020020a:	0000a597          	auipc	a1,0xa
ffffffffc020020e:	e4e58593          	addi	a1,a1,-434 # ffffffffc020a058 <buf>
ffffffffc0200212:	00005517          	auipc	a0,0x5
ffffffffc0200216:	93650513          	addi	a0,a0,-1738 # ffffffffc0204b48 <etext+0x90>
ffffffffc020021a:	f71ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020021e:	00015597          	auipc	a1,0x15
ffffffffc0200222:	3aa58593          	addi	a1,a1,938 # ffffffffc02155c8 <end>
ffffffffc0200226:	00005517          	auipc	a0,0x5
ffffffffc020022a:	94250513          	addi	a0,a0,-1726 # ffffffffc0204b68 <etext+0xb0>
ffffffffc020022e:	f5dff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200232:	00015797          	auipc	a5,0x15
ffffffffc0200236:	79578793          	addi	a5,a5,1941 # ffffffffc02159c7 <end+0x3ff>
ffffffffc020023a:	00000717          	auipc	a4,0x0
ffffffffc020023e:	df870713          	addi	a4,a4,-520 # ffffffffc0200032 <kern_init>
ffffffffc0200242:	8f99                	sub	a5,a5,a4
ffffffffc0200244:	43f7d593          	srai	a1,a5,0x3f
ffffffffc0200248:	60a2                	ld	ra,8(sp)
ffffffffc020024a:	3ff5f593          	andi	a1,a1,1023
ffffffffc020024e:	95be                	add	a1,a1,a5
ffffffffc0200250:	85a9                	srai	a1,a1,0xa
ffffffffc0200252:	00005517          	auipc	a0,0x5
ffffffffc0200256:	93650513          	addi	a0,a0,-1738 # ffffffffc0204b88 <etext+0xd0>
ffffffffc020025a:	0141                	addi	sp,sp,16
ffffffffc020025c:	b73d                	j	ffffffffc020018a <cprintf>

ffffffffc020025e <print_stackframe>:
ffffffffc020025e:	1141                	addi	sp,sp,-16
ffffffffc0200260:	00005617          	auipc	a2,0x5
ffffffffc0200264:	95860613          	addi	a2,a2,-1704 # ffffffffc0204bb8 <etext+0x100>
ffffffffc0200268:	04d00593          	li	a1,77
ffffffffc020026c:	00005517          	auipc	a0,0x5
ffffffffc0200270:	96450513          	addi	a0,a0,-1692 # ffffffffc0204bd0 <etext+0x118>
ffffffffc0200274:	e406                	sd	ra,8(sp)
ffffffffc0200276:	1c8000ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc020027a <mon_help>:
ffffffffc020027a:	1141                	addi	sp,sp,-16
ffffffffc020027c:	00005617          	auipc	a2,0x5
ffffffffc0200280:	96c60613          	addi	a2,a2,-1684 # ffffffffc0204be8 <etext+0x130>
ffffffffc0200284:	00005597          	auipc	a1,0x5
ffffffffc0200288:	98458593          	addi	a1,a1,-1660 # ffffffffc0204c08 <etext+0x150>
ffffffffc020028c:	00005517          	auipc	a0,0x5
ffffffffc0200290:	98450513          	addi	a0,a0,-1660 # ffffffffc0204c10 <etext+0x158>
ffffffffc0200294:	e406                	sd	ra,8(sp)
ffffffffc0200296:	ef5ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020029a:	00005617          	auipc	a2,0x5
ffffffffc020029e:	98660613          	addi	a2,a2,-1658 # ffffffffc0204c20 <etext+0x168>
ffffffffc02002a2:	00005597          	auipc	a1,0x5
ffffffffc02002a6:	9a658593          	addi	a1,a1,-1626 # ffffffffc0204c48 <etext+0x190>
ffffffffc02002aa:	00005517          	auipc	a0,0x5
ffffffffc02002ae:	96650513          	addi	a0,a0,-1690 # ffffffffc0204c10 <etext+0x158>
ffffffffc02002b2:	ed9ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02002b6:	00005617          	auipc	a2,0x5
ffffffffc02002ba:	9a260613          	addi	a2,a2,-1630 # ffffffffc0204c58 <etext+0x1a0>
ffffffffc02002be:	00005597          	auipc	a1,0x5
ffffffffc02002c2:	9ba58593          	addi	a1,a1,-1606 # ffffffffc0204c78 <etext+0x1c0>
ffffffffc02002c6:	00005517          	auipc	a0,0x5
ffffffffc02002ca:	94a50513          	addi	a0,a0,-1718 # ffffffffc0204c10 <etext+0x158>
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
ffffffffc0200304:	98850513          	addi	a0,a0,-1656 # ffffffffc0204c88 <etext+0x1d0>
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
ffffffffc0200326:	98e50513          	addi	a0,a0,-1650 # ffffffffc0204cb0 <etext+0x1f8>
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
ffffffffc0200348:	9dcc0c13          	addi	s8,s8,-1572 # ffffffffc0204d20 <commands>
ffffffffc020034c:	00005917          	auipc	s2,0x5
ffffffffc0200350:	98c90913          	addi	s2,s2,-1652 # ffffffffc0204cd8 <etext+0x220>
ffffffffc0200354:	00005497          	auipc	s1,0x5
ffffffffc0200358:	98c48493          	addi	s1,s1,-1652 # ffffffffc0204ce0 <etext+0x228>
ffffffffc020035c:	49bd                	li	s3,15
ffffffffc020035e:	00005a97          	auipc	s5,0x5
ffffffffc0200362:	98aa8a93          	addi	s5,s5,-1654 # ffffffffc0204ce8 <etext+0x230>
ffffffffc0200366:	4a0d                	li	s4,3
ffffffffc0200368:	00005b97          	auipc	s7,0x5
ffffffffc020036c:	9a0b8b93          	addi	s7,s7,-1632 # ffffffffc0204d08 <etext+0x250>
ffffffffc0200370:	854a                	mv	a0,s2
ffffffffc0200372:	d21ff0ef          	jal	ra,ffffffffc0200092 <readline>
ffffffffc0200376:	842a                	mv	s0,a0
ffffffffc0200378:	dd65                	beqz	a0,ffffffffc0200370 <kmonitor+0x76>
ffffffffc020037a:	00054583          	lbu	a1,0(a0)
ffffffffc020037e:	4c81                	li	s9,0
ffffffffc0200380:	e59d                	bnez	a1,ffffffffc02003ae <kmonitor+0xb4>
ffffffffc0200382:	fe0c87e3          	beqz	s9,ffffffffc0200370 <kmonitor+0x76>
ffffffffc0200386:	00005d17          	auipc	s10,0x5
ffffffffc020038a:	99ad0d13          	addi	s10,s10,-1638 # ffffffffc0204d20 <commands>
ffffffffc020038e:	4401                	li	s0,0
ffffffffc0200390:	000d3503          	ld	a0,0(s10)
ffffffffc0200394:	6582                	ld	a1,0(sp)
ffffffffc0200396:	0d61                	addi	s10,s10,24
ffffffffc0200398:	684040ef          	jal	ra,ffffffffc0204a1c <strcmp>
ffffffffc020039c:	c535                	beqz	a0,ffffffffc0200408 <kmonitor+0x10e>
ffffffffc020039e:	2405                	addiw	s0,s0,1
ffffffffc02003a0:	ff4418e3          	bne	s0,s4,ffffffffc0200390 <kmonitor+0x96>
ffffffffc02003a4:	6582                	ld	a1,0(sp)
ffffffffc02003a6:	855e                	mv	a0,s7
ffffffffc02003a8:	de3ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02003ac:	b7d1                	j	ffffffffc0200370 <kmonitor+0x76>
ffffffffc02003ae:	8526                	mv	a0,s1
ffffffffc02003b0:	6a4040ef          	jal	ra,ffffffffc0204a54 <strchr>
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
ffffffffc02003f0:	664040ef          	jal	ra,ffffffffc0204a54 <strchr>
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
ffffffffc0200442:	0f230313          	addi	t1,t1,242 # ffffffffc0215530 <is_panic>
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
ffffffffc0200470:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0204d68 <commands+0x48>
ffffffffc0200474:	e43e                	sd	a5,8(sp)
ffffffffc0200476:	d15ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020047a:	65a2                	ld	a1,8(sp)
ffffffffc020047c:	8522                	mv	a0,s0
ffffffffc020047e:	cedff0ef          	jal	ra,ffffffffc020016a <vcprintf>
ffffffffc0200482:	00006517          	auipc	a0,0x6
ffffffffc0200486:	85650513          	addi	a0,a0,-1962 # ffffffffc0205cd8 <default_pmm_manager+0x4d0>
ffffffffc020048a:	d01ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020048e:	12c000ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0200492:	4501                	li	a0,0
ffffffffc0200494:	e67ff0ef          	jal	ra,ffffffffc02002fa <kmonitor>
ffffffffc0200498:	bfed                	j	ffffffffc0200492 <__panic+0x54>

ffffffffc020049a <clock_init>:
ffffffffc020049a:	67e1                	lui	a5,0x18
ffffffffc020049c:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02004a0:	00015717          	auipc	a4,0x15
ffffffffc02004a4:	08f73c23          	sd	a5,152(a4) # ffffffffc0215538 <timebase>
ffffffffc02004a8:	c0102573          	rdtime	a0
ffffffffc02004ac:	4581                	li	a1,0
ffffffffc02004ae:	953e                	add	a0,a0,a5
ffffffffc02004b0:	4601                	li	a2,0
ffffffffc02004b2:	4881                	li	a7,0
ffffffffc02004b4:	00000073          	ecall
ffffffffc02004b8:	02000793          	li	a5,32
ffffffffc02004bc:	1047a7f3          	csrrs	a5,sie,a5
ffffffffc02004c0:	00005517          	auipc	a0,0x5
ffffffffc02004c4:	8c850513          	addi	a0,a0,-1848 # ffffffffc0204d88 <commands+0x68>
ffffffffc02004c8:	00015797          	auipc	a5,0x15
ffffffffc02004cc:	0607bc23          	sd	zero,120(a5) # ffffffffc0215540 <ticks>
ffffffffc02004d0:	b96d                	j	ffffffffc020018a <cprintf>

ffffffffc02004d2 <clock_set_next_event>:
ffffffffc02004d2:	c0102573          	rdtime	a0
ffffffffc02004d6:	00015797          	auipc	a5,0x15
ffffffffc02004da:	0627b783          	ld	a5,98(a5) # ffffffffc0215538 <timebase>
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
ffffffffc0200570:	eec78793          	addi	a5,a5,-276 # ffffffffc020a458 <ide>
ffffffffc0200574:	0095959b          	slliw	a1,a1,0x9
ffffffffc0200578:	1141                	addi	sp,sp,-16
ffffffffc020057a:	8532                	mv	a0,a2
ffffffffc020057c:	95be                	add	a1,a1,a5
ffffffffc020057e:	00969613          	slli	a2,a3,0x9
ffffffffc0200582:	e406                	sd	ra,8(sp)
ffffffffc0200584:	4f8040ef          	jal	ra,ffffffffc0204a7c <memcpy>
ffffffffc0200588:	60a2                	ld	ra,8(sp)
ffffffffc020058a:	4501                	li	a0,0
ffffffffc020058c:	0141                	addi	sp,sp,16
ffffffffc020058e:	8082                	ret

ffffffffc0200590 <ide_write_secs>:
ffffffffc0200590:	0095979b          	slliw	a5,a1,0x9
ffffffffc0200594:	0000a517          	auipc	a0,0xa
ffffffffc0200598:	ec450513          	addi	a0,a0,-316 # ffffffffc020a458 <ide>
ffffffffc020059c:	1141                	addi	sp,sp,-16
ffffffffc020059e:	85b2                	mv	a1,a2
ffffffffc02005a0:	953e                	add	a0,a0,a5
ffffffffc02005a2:	00969613          	slli	a2,a3,0x9
ffffffffc02005a6:	e406                	sd	ra,8(sp)
ffffffffc02005a8:	4d4040ef          	jal	ra,ffffffffc0204a7c <memcpy>
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
ffffffffc02005f2:	00004517          	auipc	a0,0x4
ffffffffc02005f6:	7b650513          	addi	a0,a0,1974 # ffffffffc0204da8 <commands+0x88>
ffffffffc02005fa:	b91ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02005fe:	00015517          	auipc	a0,0x15
ffffffffc0200602:	fa253503          	ld	a0,-94(a0) # ffffffffc02155a0 <check_mm_struct>
ffffffffc0200606:	c911                	beqz	a0,ffffffffc020061a <pgfault_handler+0x58>
ffffffffc0200608:	11043603          	ld	a2,272(s0)
ffffffffc020060c:	11842583          	lw	a1,280(s0)
ffffffffc0200610:	6402                	ld	s0,0(sp)
ffffffffc0200612:	60a2                	ld	ra,8(sp)
ffffffffc0200614:	0141                	addi	sp,sp,16
ffffffffc0200616:	1bd0306f          	j	ffffffffc0203fd2 <do_pgfault>
ffffffffc020061a:	00004617          	auipc	a2,0x4
ffffffffc020061e:	7ae60613          	addi	a2,a2,1966 # ffffffffc0204dc8 <commands+0xa8>
ffffffffc0200622:	06200593          	li	a1,98
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	7ba50513          	addi	a0,a0,1978 # ffffffffc0204de0 <commands+0xc0>
ffffffffc020062e:	e11ff0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0200632 <idt_init>:
ffffffffc0200632:	14005073          	csrwi	sscratch,0
ffffffffc0200636:	00000797          	auipc	a5,0x0
ffffffffc020063a:	47a78793          	addi	a5,a5,1146 # ffffffffc0200ab0 <__alltraps>
ffffffffc020063e:	10579073          	csrw	stvec,a5
ffffffffc0200642:	000407b7          	lui	a5,0x40
ffffffffc0200646:	1007a7f3          	csrrs	a5,sstatus,a5
ffffffffc020064a:	8082                	ret

ffffffffc020064c <print_regs>:
ffffffffc020064c:	610c                	ld	a1,0(a0)
ffffffffc020064e:	1141                	addi	sp,sp,-16
ffffffffc0200650:	e022                	sd	s0,0(sp)
ffffffffc0200652:	842a                	mv	s0,a0
ffffffffc0200654:	00004517          	auipc	a0,0x4
ffffffffc0200658:	7a450513          	addi	a0,a0,1956 # ffffffffc0204df8 <commands+0xd8>
ffffffffc020065c:	e406                	sd	ra,8(sp)
ffffffffc020065e:	b2dff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200662:	640c                	ld	a1,8(s0)
ffffffffc0200664:	00004517          	auipc	a0,0x4
ffffffffc0200668:	7ac50513          	addi	a0,a0,1964 # ffffffffc0204e10 <commands+0xf0>
ffffffffc020066c:	b1fff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200670:	680c                	ld	a1,16(s0)
ffffffffc0200672:	00004517          	auipc	a0,0x4
ffffffffc0200676:	7b650513          	addi	a0,a0,1974 # ffffffffc0204e28 <commands+0x108>
ffffffffc020067a:	b11ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020067e:	6c0c                	ld	a1,24(s0)
ffffffffc0200680:	00004517          	auipc	a0,0x4
ffffffffc0200684:	7c050513          	addi	a0,a0,1984 # ffffffffc0204e40 <commands+0x120>
ffffffffc0200688:	b03ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020068c:	700c                	ld	a1,32(s0)
ffffffffc020068e:	00004517          	auipc	a0,0x4
ffffffffc0200692:	7ca50513          	addi	a0,a0,1994 # ffffffffc0204e58 <commands+0x138>
ffffffffc0200696:	af5ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020069a:	740c                	ld	a1,40(s0)
ffffffffc020069c:	00004517          	auipc	a0,0x4
ffffffffc02006a0:	7d450513          	addi	a0,a0,2004 # ffffffffc0204e70 <commands+0x150>
ffffffffc02006a4:	ae7ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02006a8:	780c                	ld	a1,48(s0)
ffffffffc02006aa:	00004517          	auipc	a0,0x4
ffffffffc02006ae:	7de50513          	addi	a0,a0,2014 # ffffffffc0204e88 <commands+0x168>
ffffffffc02006b2:	ad9ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02006b6:	7c0c                	ld	a1,56(s0)
ffffffffc02006b8:	00004517          	auipc	a0,0x4
ffffffffc02006bc:	7e850513          	addi	a0,a0,2024 # ffffffffc0204ea0 <commands+0x180>
ffffffffc02006c0:	acbff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02006c4:	602c                	ld	a1,64(s0)
ffffffffc02006c6:	00004517          	auipc	a0,0x4
ffffffffc02006ca:	7f250513          	addi	a0,a0,2034 # ffffffffc0204eb8 <commands+0x198>
ffffffffc02006ce:	abdff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02006d2:	642c                	ld	a1,72(s0)
ffffffffc02006d4:	00004517          	auipc	a0,0x4
ffffffffc02006d8:	7fc50513          	addi	a0,a0,2044 # ffffffffc0204ed0 <commands+0x1b0>
ffffffffc02006dc:	aafff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02006e0:	682c                	ld	a1,80(s0)
ffffffffc02006e2:	00005517          	auipc	a0,0x5
ffffffffc02006e6:	80650513          	addi	a0,a0,-2042 # ffffffffc0204ee8 <commands+0x1c8>
ffffffffc02006ea:	aa1ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02006ee:	6c2c                	ld	a1,88(s0)
ffffffffc02006f0:	00005517          	auipc	a0,0x5
ffffffffc02006f4:	81050513          	addi	a0,a0,-2032 # ffffffffc0204f00 <commands+0x1e0>
ffffffffc02006f8:	a93ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02006fc:	702c                	ld	a1,96(s0)
ffffffffc02006fe:	00005517          	auipc	a0,0x5
ffffffffc0200702:	81a50513          	addi	a0,a0,-2022 # ffffffffc0204f18 <commands+0x1f8>
ffffffffc0200706:	a85ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020070a:	742c                	ld	a1,104(s0)
ffffffffc020070c:	00005517          	auipc	a0,0x5
ffffffffc0200710:	82450513          	addi	a0,a0,-2012 # ffffffffc0204f30 <commands+0x210>
ffffffffc0200714:	a77ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200718:	782c                	ld	a1,112(s0)
ffffffffc020071a:	00005517          	auipc	a0,0x5
ffffffffc020071e:	82e50513          	addi	a0,a0,-2002 # ffffffffc0204f48 <commands+0x228>
ffffffffc0200722:	a69ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200726:	7c2c                	ld	a1,120(s0)
ffffffffc0200728:	00005517          	auipc	a0,0x5
ffffffffc020072c:	83850513          	addi	a0,a0,-1992 # ffffffffc0204f60 <commands+0x240>
ffffffffc0200730:	a5bff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200734:	604c                	ld	a1,128(s0)
ffffffffc0200736:	00005517          	auipc	a0,0x5
ffffffffc020073a:	84250513          	addi	a0,a0,-1982 # ffffffffc0204f78 <commands+0x258>
ffffffffc020073e:	a4dff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200742:	644c                	ld	a1,136(s0)
ffffffffc0200744:	00005517          	auipc	a0,0x5
ffffffffc0200748:	84c50513          	addi	a0,a0,-1972 # ffffffffc0204f90 <commands+0x270>
ffffffffc020074c:	a3fff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200750:	684c                	ld	a1,144(s0)
ffffffffc0200752:	00005517          	auipc	a0,0x5
ffffffffc0200756:	85650513          	addi	a0,a0,-1962 # ffffffffc0204fa8 <commands+0x288>
ffffffffc020075a:	a31ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020075e:	6c4c                	ld	a1,152(s0)
ffffffffc0200760:	00005517          	auipc	a0,0x5
ffffffffc0200764:	86050513          	addi	a0,a0,-1952 # ffffffffc0204fc0 <commands+0x2a0>
ffffffffc0200768:	a23ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020076c:	704c                	ld	a1,160(s0)
ffffffffc020076e:	00005517          	auipc	a0,0x5
ffffffffc0200772:	86a50513          	addi	a0,a0,-1942 # ffffffffc0204fd8 <commands+0x2b8>
ffffffffc0200776:	a15ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020077a:	744c                	ld	a1,168(s0)
ffffffffc020077c:	00005517          	auipc	a0,0x5
ffffffffc0200780:	87450513          	addi	a0,a0,-1932 # ffffffffc0204ff0 <commands+0x2d0>
ffffffffc0200784:	a07ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200788:	784c                	ld	a1,176(s0)
ffffffffc020078a:	00005517          	auipc	a0,0x5
ffffffffc020078e:	87e50513          	addi	a0,a0,-1922 # ffffffffc0205008 <commands+0x2e8>
ffffffffc0200792:	9f9ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200796:	7c4c                	ld	a1,184(s0)
ffffffffc0200798:	00005517          	auipc	a0,0x5
ffffffffc020079c:	88850513          	addi	a0,a0,-1912 # ffffffffc0205020 <commands+0x300>
ffffffffc02007a0:	9ebff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02007a4:	606c                	ld	a1,192(s0)
ffffffffc02007a6:	00005517          	auipc	a0,0x5
ffffffffc02007aa:	89250513          	addi	a0,a0,-1902 # ffffffffc0205038 <commands+0x318>
ffffffffc02007ae:	9ddff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02007b2:	646c                	ld	a1,200(s0)
ffffffffc02007b4:	00005517          	auipc	a0,0x5
ffffffffc02007b8:	89c50513          	addi	a0,a0,-1892 # ffffffffc0205050 <commands+0x330>
ffffffffc02007bc:	9cfff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02007c0:	686c                	ld	a1,208(s0)
ffffffffc02007c2:	00005517          	auipc	a0,0x5
ffffffffc02007c6:	8a650513          	addi	a0,a0,-1882 # ffffffffc0205068 <commands+0x348>
ffffffffc02007ca:	9c1ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02007ce:	6c6c                	ld	a1,216(s0)
ffffffffc02007d0:	00005517          	auipc	a0,0x5
ffffffffc02007d4:	8b050513          	addi	a0,a0,-1872 # ffffffffc0205080 <commands+0x360>
ffffffffc02007d8:	9b3ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02007dc:	706c                	ld	a1,224(s0)
ffffffffc02007de:	00005517          	auipc	a0,0x5
ffffffffc02007e2:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0205098 <commands+0x378>
ffffffffc02007e6:	9a5ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02007ea:	746c                	ld	a1,232(s0)
ffffffffc02007ec:	00005517          	auipc	a0,0x5
ffffffffc02007f0:	8c450513          	addi	a0,a0,-1852 # ffffffffc02050b0 <commands+0x390>
ffffffffc02007f4:	997ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02007f8:	786c                	ld	a1,240(s0)
ffffffffc02007fa:	00005517          	auipc	a0,0x5
ffffffffc02007fe:	8ce50513          	addi	a0,a0,-1842 # ffffffffc02050c8 <commands+0x3a8>
ffffffffc0200802:	989ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200806:	7c6c                	ld	a1,248(s0)
ffffffffc0200808:	6402                	ld	s0,0(sp)
ffffffffc020080a:	60a2                	ld	ra,8(sp)
ffffffffc020080c:	00005517          	auipc	a0,0x5
ffffffffc0200810:	8d450513          	addi	a0,a0,-1836 # ffffffffc02050e0 <commands+0x3c0>
ffffffffc0200814:	0141                	addi	sp,sp,16
ffffffffc0200816:	ba95                	j	ffffffffc020018a <cprintf>

ffffffffc0200818 <print_trapframe>:
ffffffffc0200818:	1141                	addi	sp,sp,-16
ffffffffc020081a:	e022                	sd	s0,0(sp)
ffffffffc020081c:	85aa                	mv	a1,a0
ffffffffc020081e:	842a                	mv	s0,a0
ffffffffc0200820:	00005517          	auipc	a0,0x5
ffffffffc0200824:	8d850513          	addi	a0,a0,-1832 # ffffffffc02050f8 <commands+0x3d8>
ffffffffc0200828:	e406                	sd	ra,8(sp)
ffffffffc020082a:	961ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020082e:	8522                	mv	a0,s0
ffffffffc0200830:	e1dff0ef          	jal	ra,ffffffffc020064c <print_regs>
ffffffffc0200834:	10043583          	ld	a1,256(s0)
ffffffffc0200838:	00005517          	auipc	a0,0x5
ffffffffc020083c:	8d850513          	addi	a0,a0,-1832 # ffffffffc0205110 <commands+0x3f0>
ffffffffc0200840:	94bff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200844:	10843583          	ld	a1,264(s0)
ffffffffc0200848:	00005517          	auipc	a0,0x5
ffffffffc020084c:	8e050513          	addi	a0,a0,-1824 # ffffffffc0205128 <commands+0x408>
ffffffffc0200850:	93bff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200854:	11043583          	ld	a1,272(s0)
ffffffffc0200858:	00005517          	auipc	a0,0x5
ffffffffc020085c:	8e850513          	addi	a0,a0,-1816 # ffffffffc0205140 <commands+0x420>
ffffffffc0200860:	92bff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200864:	11843583          	ld	a1,280(s0)
ffffffffc0200868:	6402                	ld	s0,0(sp)
ffffffffc020086a:	60a2                	ld	ra,8(sp)
ffffffffc020086c:	00005517          	auipc	a0,0x5
ffffffffc0200870:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0205158 <commands+0x438>
ffffffffc0200874:	0141                	addi	sp,sp,16
ffffffffc0200876:	915ff06f          	j	ffffffffc020018a <cprintf>

ffffffffc020087a <interrupt_handler>:
ffffffffc020087a:	11853783          	ld	a5,280(a0)
ffffffffc020087e:	472d                	li	a4,11
ffffffffc0200880:	0786                	slli	a5,a5,0x1
ffffffffc0200882:	8385                	srli	a5,a5,0x1
ffffffffc0200884:	06f76c63          	bltu	a4,a5,ffffffffc02008fc <interrupt_handler+0x82>
ffffffffc0200888:	00005717          	auipc	a4,0x5
ffffffffc020088c:	99870713          	addi	a4,a4,-1640 # ffffffffc0205220 <commands+0x500>
ffffffffc0200890:	078a                	slli	a5,a5,0x2
ffffffffc0200892:	97ba                	add	a5,a5,a4
ffffffffc0200894:	439c                	lw	a5,0(a5)
ffffffffc0200896:	97ba                	add	a5,a5,a4
ffffffffc0200898:	8782                	jr	a5
ffffffffc020089a:	00005517          	auipc	a0,0x5
ffffffffc020089e:	93650513          	addi	a0,a0,-1738 # ffffffffc02051d0 <commands+0x4b0>
ffffffffc02008a2:	8e9ff06f          	j	ffffffffc020018a <cprintf>
ffffffffc02008a6:	00005517          	auipc	a0,0x5
ffffffffc02008aa:	90a50513          	addi	a0,a0,-1782 # ffffffffc02051b0 <commands+0x490>
ffffffffc02008ae:	8ddff06f          	j	ffffffffc020018a <cprintf>
ffffffffc02008b2:	00005517          	auipc	a0,0x5
ffffffffc02008b6:	8be50513          	addi	a0,a0,-1858 # ffffffffc0205170 <commands+0x450>
ffffffffc02008ba:	8d1ff06f          	j	ffffffffc020018a <cprintf>
ffffffffc02008be:	00005517          	auipc	a0,0x5
ffffffffc02008c2:	8d250513          	addi	a0,a0,-1838 # ffffffffc0205190 <commands+0x470>
ffffffffc02008c6:	8c5ff06f          	j	ffffffffc020018a <cprintf>
ffffffffc02008ca:	1141                	addi	sp,sp,-16
ffffffffc02008cc:	e406                	sd	ra,8(sp)
ffffffffc02008ce:	c05ff0ef          	jal	ra,ffffffffc02004d2 <clock_set_next_event>
ffffffffc02008d2:	00015697          	auipc	a3,0x15
ffffffffc02008d6:	c6e68693          	addi	a3,a3,-914 # ffffffffc0215540 <ticks>
ffffffffc02008da:	629c                	ld	a5,0(a3)
ffffffffc02008dc:	06400713          	li	a4,100
ffffffffc02008e0:	0785                	addi	a5,a5,1
ffffffffc02008e2:	02e7f733          	remu	a4,a5,a4
ffffffffc02008e6:	e29c                	sd	a5,0(a3)
ffffffffc02008e8:	cb19                	beqz	a4,ffffffffc02008fe <interrupt_handler+0x84>
ffffffffc02008ea:	60a2                	ld	ra,8(sp)
ffffffffc02008ec:	0141                	addi	sp,sp,16
ffffffffc02008ee:	8082                	ret
ffffffffc02008f0:	00005517          	auipc	a0,0x5
ffffffffc02008f4:	91050513          	addi	a0,a0,-1776 # ffffffffc0205200 <commands+0x4e0>
ffffffffc02008f8:	893ff06f          	j	ffffffffc020018a <cprintf>
ffffffffc02008fc:	bf31                	j	ffffffffc0200818 <print_trapframe>
ffffffffc02008fe:	60a2                	ld	ra,8(sp)
ffffffffc0200900:	06400593          	li	a1,100
ffffffffc0200904:	00005517          	auipc	a0,0x5
ffffffffc0200908:	8ec50513          	addi	a0,a0,-1812 # ffffffffc02051f0 <commands+0x4d0>
ffffffffc020090c:	0141                	addi	sp,sp,16
ffffffffc020090e:	87dff06f          	j	ffffffffc020018a <cprintf>

ffffffffc0200912 <exception_handler>:
ffffffffc0200912:	11853783          	ld	a5,280(a0)
ffffffffc0200916:	1101                	addi	sp,sp,-32
ffffffffc0200918:	e822                	sd	s0,16(sp)
ffffffffc020091a:	ec06                	sd	ra,24(sp)
ffffffffc020091c:	e426                	sd	s1,8(sp)
ffffffffc020091e:	473d                	li	a4,15
ffffffffc0200920:	842a                	mv	s0,a0
ffffffffc0200922:	14f76a63          	bltu	a4,a5,ffffffffc0200a76 <exception_handler+0x164>
ffffffffc0200926:	00005717          	auipc	a4,0x5
ffffffffc020092a:	ae270713          	addi	a4,a4,-1310 # ffffffffc0205408 <commands+0x6e8>
ffffffffc020092e:	078a                	slli	a5,a5,0x2
ffffffffc0200930:	97ba                	add	a5,a5,a4
ffffffffc0200932:	439c                	lw	a5,0(a5)
ffffffffc0200934:	97ba                	add	a5,a5,a4
ffffffffc0200936:	8782                	jr	a5
ffffffffc0200938:	00005517          	auipc	a0,0x5
ffffffffc020093c:	ab850513          	addi	a0,a0,-1352 # ffffffffc02053f0 <commands+0x6d0>
ffffffffc0200940:	84bff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200944:	8522                	mv	a0,s0
ffffffffc0200946:	c7dff0ef          	jal	ra,ffffffffc02005c2 <pgfault_handler>
ffffffffc020094a:	84aa                	mv	s1,a0
ffffffffc020094c:	12051b63          	bnez	a0,ffffffffc0200a82 <exception_handler+0x170>
ffffffffc0200950:	60e2                	ld	ra,24(sp)
ffffffffc0200952:	6442                	ld	s0,16(sp)
ffffffffc0200954:	64a2                	ld	s1,8(sp)
ffffffffc0200956:	6105                	addi	sp,sp,32
ffffffffc0200958:	8082                	ret
ffffffffc020095a:	00005517          	auipc	a0,0x5
ffffffffc020095e:	8f650513          	addi	a0,a0,-1802 # ffffffffc0205250 <commands+0x530>
ffffffffc0200962:	6442                	ld	s0,16(sp)
ffffffffc0200964:	60e2                	ld	ra,24(sp)
ffffffffc0200966:	64a2                	ld	s1,8(sp)
ffffffffc0200968:	6105                	addi	sp,sp,32
ffffffffc020096a:	821ff06f          	j	ffffffffc020018a <cprintf>
ffffffffc020096e:	00005517          	auipc	a0,0x5
ffffffffc0200972:	90250513          	addi	a0,a0,-1790 # ffffffffc0205270 <commands+0x550>
ffffffffc0200976:	b7f5                	j	ffffffffc0200962 <exception_handler+0x50>
ffffffffc0200978:	00005517          	auipc	a0,0x5
ffffffffc020097c:	91850513          	addi	a0,a0,-1768 # ffffffffc0205290 <commands+0x570>
ffffffffc0200980:	b7cd                	j	ffffffffc0200962 <exception_handler+0x50>
ffffffffc0200982:	00005517          	auipc	a0,0x5
ffffffffc0200986:	92650513          	addi	a0,a0,-1754 # ffffffffc02052a8 <commands+0x588>
ffffffffc020098a:	bfe1                	j	ffffffffc0200962 <exception_handler+0x50>
ffffffffc020098c:	00005517          	auipc	a0,0x5
ffffffffc0200990:	92c50513          	addi	a0,a0,-1748 # ffffffffc02052b8 <commands+0x598>
ffffffffc0200994:	b7f9                	j	ffffffffc0200962 <exception_handler+0x50>
ffffffffc0200996:	00005517          	auipc	a0,0x5
ffffffffc020099a:	94250513          	addi	a0,a0,-1726 # ffffffffc02052d8 <commands+0x5b8>
ffffffffc020099e:	fecff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02009a2:	8522                	mv	a0,s0
ffffffffc02009a4:	c1fff0ef          	jal	ra,ffffffffc02005c2 <pgfault_handler>
ffffffffc02009a8:	84aa                	mv	s1,a0
ffffffffc02009aa:	d15d                	beqz	a0,ffffffffc0200950 <exception_handler+0x3e>
ffffffffc02009ac:	8522                	mv	a0,s0
ffffffffc02009ae:	e6bff0ef          	jal	ra,ffffffffc0200818 <print_trapframe>
ffffffffc02009b2:	86a6                	mv	a3,s1
ffffffffc02009b4:	00005617          	auipc	a2,0x5
ffffffffc02009b8:	93c60613          	addi	a2,a2,-1732 # ffffffffc02052f0 <commands+0x5d0>
ffffffffc02009bc:	0b300593          	li	a1,179
ffffffffc02009c0:	00004517          	auipc	a0,0x4
ffffffffc02009c4:	42050513          	addi	a0,a0,1056 # ffffffffc0204de0 <commands+0xc0>
ffffffffc02009c8:	a77ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02009cc:	00005517          	auipc	a0,0x5
ffffffffc02009d0:	94450513          	addi	a0,a0,-1724 # ffffffffc0205310 <commands+0x5f0>
ffffffffc02009d4:	b779                	j	ffffffffc0200962 <exception_handler+0x50>
ffffffffc02009d6:	00005517          	auipc	a0,0x5
ffffffffc02009da:	95250513          	addi	a0,a0,-1710 # ffffffffc0205328 <commands+0x608>
ffffffffc02009de:	facff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02009e2:	8522                	mv	a0,s0
ffffffffc02009e4:	bdfff0ef          	jal	ra,ffffffffc02005c2 <pgfault_handler>
ffffffffc02009e8:	84aa                	mv	s1,a0
ffffffffc02009ea:	d13d                	beqz	a0,ffffffffc0200950 <exception_handler+0x3e>
ffffffffc02009ec:	8522                	mv	a0,s0
ffffffffc02009ee:	e2bff0ef          	jal	ra,ffffffffc0200818 <print_trapframe>
ffffffffc02009f2:	86a6                	mv	a3,s1
ffffffffc02009f4:	00005617          	auipc	a2,0x5
ffffffffc02009f8:	8fc60613          	addi	a2,a2,-1796 # ffffffffc02052f0 <commands+0x5d0>
ffffffffc02009fc:	0bd00593          	li	a1,189
ffffffffc0200a00:	00004517          	auipc	a0,0x4
ffffffffc0200a04:	3e050513          	addi	a0,a0,992 # ffffffffc0204de0 <commands+0xc0>
ffffffffc0200a08:	a37ff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200a0c:	00005517          	auipc	a0,0x5
ffffffffc0200a10:	93450513          	addi	a0,a0,-1740 # ffffffffc0205340 <commands+0x620>
ffffffffc0200a14:	b7b9                	j	ffffffffc0200962 <exception_handler+0x50>
ffffffffc0200a16:	00005517          	auipc	a0,0x5
ffffffffc0200a1a:	94a50513          	addi	a0,a0,-1718 # ffffffffc0205360 <commands+0x640>
ffffffffc0200a1e:	b791                	j	ffffffffc0200962 <exception_handler+0x50>
ffffffffc0200a20:	00005517          	auipc	a0,0x5
ffffffffc0200a24:	96050513          	addi	a0,a0,-1696 # ffffffffc0205380 <commands+0x660>
ffffffffc0200a28:	bf2d                	j	ffffffffc0200962 <exception_handler+0x50>
ffffffffc0200a2a:	00005517          	auipc	a0,0x5
ffffffffc0200a2e:	97650513          	addi	a0,a0,-1674 # ffffffffc02053a0 <commands+0x680>
ffffffffc0200a32:	bf05                	j	ffffffffc0200962 <exception_handler+0x50>
ffffffffc0200a34:	00005517          	auipc	a0,0x5
ffffffffc0200a38:	98c50513          	addi	a0,a0,-1652 # ffffffffc02053c0 <commands+0x6a0>
ffffffffc0200a3c:	b71d                	j	ffffffffc0200962 <exception_handler+0x50>
ffffffffc0200a3e:	00005517          	auipc	a0,0x5
ffffffffc0200a42:	99a50513          	addi	a0,a0,-1638 # ffffffffc02053d8 <commands+0x6b8>
ffffffffc0200a46:	f44ff0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0200a4a:	8522                	mv	a0,s0
ffffffffc0200a4c:	b77ff0ef          	jal	ra,ffffffffc02005c2 <pgfault_handler>
ffffffffc0200a50:	84aa                	mv	s1,a0
ffffffffc0200a52:	ee050fe3          	beqz	a0,ffffffffc0200950 <exception_handler+0x3e>
ffffffffc0200a56:	8522                	mv	a0,s0
ffffffffc0200a58:	dc1ff0ef          	jal	ra,ffffffffc0200818 <print_trapframe>
ffffffffc0200a5c:	86a6                	mv	a3,s1
ffffffffc0200a5e:	00005617          	auipc	a2,0x5
ffffffffc0200a62:	89260613          	addi	a2,a2,-1902 # ffffffffc02052f0 <commands+0x5d0>
ffffffffc0200a66:	0d300593          	li	a1,211
ffffffffc0200a6a:	00004517          	auipc	a0,0x4
ffffffffc0200a6e:	37650513          	addi	a0,a0,886 # ffffffffc0204de0 <commands+0xc0>
ffffffffc0200a72:	9cdff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200a76:	8522                	mv	a0,s0
ffffffffc0200a78:	6442                	ld	s0,16(sp)
ffffffffc0200a7a:	60e2                	ld	ra,24(sp)
ffffffffc0200a7c:	64a2                	ld	s1,8(sp)
ffffffffc0200a7e:	6105                	addi	sp,sp,32
ffffffffc0200a80:	bb61                	j	ffffffffc0200818 <print_trapframe>
ffffffffc0200a82:	8522                	mv	a0,s0
ffffffffc0200a84:	d95ff0ef          	jal	ra,ffffffffc0200818 <print_trapframe>
ffffffffc0200a88:	86a6                	mv	a3,s1
ffffffffc0200a8a:	00005617          	auipc	a2,0x5
ffffffffc0200a8e:	86660613          	addi	a2,a2,-1946 # ffffffffc02052f0 <commands+0x5d0>
ffffffffc0200a92:	0da00593          	li	a1,218
ffffffffc0200a96:	00004517          	auipc	a0,0x4
ffffffffc0200a9a:	34a50513          	addi	a0,a0,842 # ffffffffc0204de0 <commands+0xc0>
ffffffffc0200a9e:	9a1ff0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0200aa2 <trap>:
ffffffffc0200aa2:	11853783          	ld	a5,280(a0)
ffffffffc0200aa6:	0007c363          	bltz	a5,ffffffffc0200aac <trap+0xa>
ffffffffc0200aaa:	b5a5                	j	ffffffffc0200912 <exception_handler>
ffffffffc0200aac:	b3f9                	j	ffffffffc020087a <interrupt_handler>
	...

ffffffffc0200ab0 <__alltraps>:
ffffffffc0200ab0:	14011073          	csrw	sscratch,sp
ffffffffc0200ab4:	712d                	addi	sp,sp,-288
ffffffffc0200ab6:	e406                	sd	ra,8(sp)
ffffffffc0200ab8:	ec0e                	sd	gp,24(sp)
ffffffffc0200aba:	f012                	sd	tp,32(sp)
ffffffffc0200abc:	f416                	sd	t0,40(sp)
ffffffffc0200abe:	f81a                	sd	t1,48(sp)
ffffffffc0200ac0:	fc1e                	sd	t2,56(sp)
ffffffffc0200ac2:	e0a2                	sd	s0,64(sp)
ffffffffc0200ac4:	e4a6                	sd	s1,72(sp)
ffffffffc0200ac6:	e8aa                	sd	a0,80(sp)
ffffffffc0200ac8:	ecae                	sd	a1,88(sp)
ffffffffc0200aca:	f0b2                	sd	a2,96(sp)
ffffffffc0200acc:	f4b6                	sd	a3,104(sp)
ffffffffc0200ace:	f8ba                	sd	a4,112(sp)
ffffffffc0200ad0:	fcbe                	sd	a5,120(sp)
ffffffffc0200ad2:	e142                	sd	a6,128(sp)
ffffffffc0200ad4:	e546                	sd	a7,136(sp)
ffffffffc0200ad6:	e94a                	sd	s2,144(sp)
ffffffffc0200ad8:	ed4e                	sd	s3,152(sp)
ffffffffc0200ada:	f152                	sd	s4,160(sp)
ffffffffc0200adc:	f556                	sd	s5,168(sp)
ffffffffc0200ade:	f95a                	sd	s6,176(sp)
ffffffffc0200ae0:	fd5e                	sd	s7,184(sp)
ffffffffc0200ae2:	e1e2                	sd	s8,192(sp)
ffffffffc0200ae4:	e5e6                	sd	s9,200(sp)
ffffffffc0200ae6:	e9ea                	sd	s10,208(sp)
ffffffffc0200ae8:	edee                	sd	s11,216(sp)
ffffffffc0200aea:	f1f2                	sd	t3,224(sp)
ffffffffc0200aec:	f5f6                	sd	t4,232(sp)
ffffffffc0200aee:	f9fa                	sd	t5,240(sp)
ffffffffc0200af0:	fdfe                	sd	t6,248(sp)
ffffffffc0200af2:	14002473          	csrr	s0,sscratch
ffffffffc0200af6:	100024f3          	csrr	s1,sstatus
ffffffffc0200afa:	14102973          	csrr	s2,sepc
ffffffffc0200afe:	143029f3          	csrr	s3,stval
ffffffffc0200b02:	14202a73          	csrr	s4,scause
ffffffffc0200b06:	e822                	sd	s0,16(sp)
ffffffffc0200b08:	e226                	sd	s1,256(sp)
ffffffffc0200b0a:	e64a                	sd	s2,264(sp)
ffffffffc0200b0c:	ea4e                	sd	s3,272(sp)
ffffffffc0200b0e:	ee52                	sd	s4,280(sp)
ffffffffc0200b10:	850a                	mv	a0,sp
ffffffffc0200b12:	f91ff0ef          	jal	ra,ffffffffc0200aa2 <trap>

ffffffffc0200b16 <__trapret>:
ffffffffc0200b16:	6492                	ld	s1,256(sp)
ffffffffc0200b18:	6932                	ld	s2,264(sp)
ffffffffc0200b1a:	10049073          	csrw	sstatus,s1
ffffffffc0200b1e:	14191073          	csrw	sepc,s2
ffffffffc0200b22:	60a2                	ld	ra,8(sp)
ffffffffc0200b24:	61e2                	ld	gp,24(sp)
ffffffffc0200b26:	7202                	ld	tp,32(sp)
ffffffffc0200b28:	72a2                	ld	t0,40(sp)
ffffffffc0200b2a:	7342                	ld	t1,48(sp)
ffffffffc0200b2c:	73e2                	ld	t2,56(sp)
ffffffffc0200b2e:	6406                	ld	s0,64(sp)
ffffffffc0200b30:	64a6                	ld	s1,72(sp)
ffffffffc0200b32:	6546                	ld	a0,80(sp)
ffffffffc0200b34:	65e6                	ld	a1,88(sp)
ffffffffc0200b36:	7606                	ld	a2,96(sp)
ffffffffc0200b38:	76a6                	ld	a3,104(sp)
ffffffffc0200b3a:	7746                	ld	a4,112(sp)
ffffffffc0200b3c:	77e6                	ld	a5,120(sp)
ffffffffc0200b3e:	680a                	ld	a6,128(sp)
ffffffffc0200b40:	68aa                	ld	a7,136(sp)
ffffffffc0200b42:	694a                	ld	s2,144(sp)
ffffffffc0200b44:	69ea                	ld	s3,152(sp)
ffffffffc0200b46:	7a0a                	ld	s4,160(sp)
ffffffffc0200b48:	7aaa                	ld	s5,168(sp)
ffffffffc0200b4a:	7b4a                	ld	s6,176(sp)
ffffffffc0200b4c:	7bea                	ld	s7,184(sp)
ffffffffc0200b4e:	6c0e                	ld	s8,192(sp)
ffffffffc0200b50:	6cae                	ld	s9,200(sp)
ffffffffc0200b52:	6d4e                	ld	s10,208(sp)
ffffffffc0200b54:	6dee                	ld	s11,216(sp)
ffffffffc0200b56:	7e0e                	ld	t3,224(sp)
ffffffffc0200b58:	7eae                	ld	t4,232(sp)
ffffffffc0200b5a:	7f4e                	ld	t5,240(sp)
ffffffffc0200b5c:	7fee                	ld	t6,248(sp)
ffffffffc0200b5e:	6142                	ld	sp,16(sp)
ffffffffc0200b60:	10200073          	sret

ffffffffc0200b64 <forkrets>:
ffffffffc0200b64:	812a                	mv	sp,a0
ffffffffc0200b66:	bf45                	j	ffffffffc0200b16 <__trapret>
	...

ffffffffc0200b6a <default_init>:
ffffffffc0200b6a:	00011797          	auipc	a5,0x11
ffffffffc0200b6e:	8ee78793          	addi	a5,a5,-1810 # ffffffffc0211458 <free_area>
ffffffffc0200b72:	e79c                	sd	a5,8(a5)
ffffffffc0200b74:	e39c                	sd	a5,0(a5)
ffffffffc0200b76:	0007a823          	sw	zero,16(a5)
ffffffffc0200b7a:	8082                	ret

ffffffffc0200b7c <default_nr_free_pages>:
ffffffffc0200b7c:	00011517          	auipc	a0,0x11
ffffffffc0200b80:	8ec56503          	lwu	a0,-1812(a0) # ffffffffc0211468 <free_area+0x10>
ffffffffc0200b84:	8082                	ret

ffffffffc0200b86 <default_check>:
ffffffffc0200b86:	715d                	addi	sp,sp,-80
ffffffffc0200b88:	e0a2                	sd	s0,64(sp)
ffffffffc0200b8a:	00011417          	auipc	s0,0x11
ffffffffc0200b8e:	8ce40413          	addi	s0,s0,-1842 # ffffffffc0211458 <free_area>
ffffffffc0200b92:	641c                	ld	a5,8(s0)
ffffffffc0200b94:	e486                	sd	ra,72(sp)
ffffffffc0200b96:	fc26                	sd	s1,56(sp)
ffffffffc0200b98:	f84a                	sd	s2,48(sp)
ffffffffc0200b9a:	f44e                	sd	s3,40(sp)
ffffffffc0200b9c:	f052                	sd	s4,32(sp)
ffffffffc0200b9e:	ec56                	sd	s5,24(sp)
ffffffffc0200ba0:	e85a                	sd	s6,16(sp)
ffffffffc0200ba2:	e45e                	sd	s7,8(sp)
ffffffffc0200ba4:	e062                	sd	s8,0(sp)
ffffffffc0200ba6:	2a878d63          	beq	a5,s0,ffffffffc0200e60 <default_check+0x2da>
ffffffffc0200baa:	4481                	li	s1,0
ffffffffc0200bac:	4901                	li	s2,0
ffffffffc0200bae:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200bb2:	8b09                	andi	a4,a4,2
ffffffffc0200bb4:	2a070a63          	beqz	a4,ffffffffc0200e68 <default_check+0x2e2>
ffffffffc0200bb8:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200bbc:	679c                	ld	a5,8(a5)
ffffffffc0200bbe:	2905                	addiw	s2,s2,1
ffffffffc0200bc0:	9cb9                	addw	s1,s1,a4
ffffffffc0200bc2:	fe8796e3          	bne	a5,s0,ffffffffc0200bae <default_check+0x28>
ffffffffc0200bc6:	89a6                	mv	s3,s1
ffffffffc0200bc8:	721000ef          	jal	ra,ffffffffc0201ae8 <nr_free_pages>
ffffffffc0200bcc:	6f351e63          	bne	a0,s3,ffffffffc02012c8 <default_check+0x742>
ffffffffc0200bd0:	4505                	li	a0,1
ffffffffc0200bd2:	647000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0200bd6:	8aaa                	mv	s5,a0
ffffffffc0200bd8:	42050863          	beqz	a0,ffffffffc0201008 <default_check+0x482>
ffffffffc0200bdc:	4505                	li	a0,1
ffffffffc0200bde:	63b000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0200be2:	89aa                	mv	s3,a0
ffffffffc0200be4:	70050263          	beqz	a0,ffffffffc02012e8 <default_check+0x762>
ffffffffc0200be8:	4505                	li	a0,1
ffffffffc0200bea:	62f000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0200bee:	8a2a                	mv	s4,a0
ffffffffc0200bf0:	48050c63          	beqz	a0,ffffffffc0201088 <default_check+0x502>
ffffffffc0200bf4:	293a8a63          	beq	s5,s3,ffffffffc0200e88 <default_check+0x302>
ffffffffc0200bf8:	28aa8863          	beq	s5,a0,ffffffffc0200e88 <default_check+0x302>
ffffffffc0200bfc:	28a98663          	beq	s3,a0,ffffffffc0200e88 <default_check+0x302>
ffffffffc0200c00:	000aa783          	lw	a5,0(s5)
ffffffffc0200c04:	2a079263          	bnez	a5,ffffffffc0200ea8 <default_check+0x322>
ffffffffc0200c08:	0009a783          	lw	a5,0(s3)
ffffffffc0200c0c:	28079e63          	bnez	a5,ffffffffc0200ea8 <default_check+0x322>
ffffffffc0200c10:	411c                	lw	a5,0(a0)
ffffffffc0200c12:	28079b63          	bnez	a5,ffffffffc0200ea8 <default_check+0x322>
ffffffffc0200c16:	00015797          	auipc	a5,0x15
ffffffffc0200c1a:	9627b783          	ld	a5,-1694(a5) # ffffffffc0215578 <pages>
ffffffffc0200c1e:	40fa8733          	sub	a4,s5,a5
ffffffffc0200c22:	00006617          	auipc	a2,0x6
ffffffffc0200c26:	f4e63603          	ld	a2,-178(a2) # ffffffffc0206b70 <nbase>
ffffffffc0200c2a:	8719                	srai	a4,a4,0x6
ffffffffc0200c2c:	9732                	add	a4,a4,a2
ffffffffc0200c2e:	00015697          	auipc	a3,0x15
ffffffffc0200c32:	9426b683          	ld	a3,-1726(a3) # ffffffffc0215570 <npage>
ffffffffc0200c36:	06b2                	slli	a3,a3,0xc
ffffffffc0200c38:	0732                	slli	a4,a4,0xc
ffffffffc0200c3a:	28d77763          	bgeu	a4,a3,ffffffffc0200ec8 <default_check+0x342>
ffffffffc0200c3e:	40f98733          	sub	a4,s3,a5
ffffffffc0200c42:	8719                	srai	a4,a4,0x6
ffffffffc0200c44:	9732                	add	a4,a4,a2
ffffffffc0200c46:	0732                	slli	a4,a4,0xc
ffffffffc0200c48:	4cd77063          	bgeu	a4,a3,ffffffffc0201108 <default_check+0x582>
ffffffffc0200c4c:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c50:	8799                	srai	a5,a5,0x6
ffffffffc0200c52:	97b2                	add	a5,a5,a2
ffffffffc0200c54:	07b2                	slli	a5,a5,0xc
ffffffffc0200c56:	30d7f963          	bgeu	a5,a3,ffffffffc0200f68 <default_check+0x3e2>
ffffffffc0200c5a:	4505                	li	a0,1
ffffffffc0200c5c:	00043c03          	ld	s8,0(s0)
ffffffffc0200c60:	00843b83          	ld	s7,8(s0)
ffffffffc0200c64:	01042b03          	lw	s6,16(s0)
ffffffffc0200c68:	e400                	sd	s0,8(s0)
ffffffffc0200c6a:	e000                	sd	s0,0(s0)
ffffffffc0200c6c:	00010797          	auipc	a5,0x10
ffffffffc0200c70:	7e07ae23          	sw	zero,2044(a5) # ffffffffc0211468 <free_area+0x10>
ffffffffc0200c74:	5a5000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0200c78:	2c051863          	bnez	a0,ffffffffc0200f48 <default_check+0x3c2>
ffffffffc0200c7c:	4585                	li	a1,1
ffffffffc0200c7e:	8556                	mv	a0,s5
ffffffffc0200c80:	629000ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0200c84:	4585                	li	a1,1
ffffffffc0200c86:	854e                	mv	a0,s3
ffffffffc0200c88:	621000ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0200c8c:	4585                	li	a1,1
ffffffffc0200c8e:	8552                	mv	a0,s4
ffffffffc0200c90:	619000ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0200c94:	4818                	lw	a4,16(s0)
ffffffffc0200c96:	478d                	li	a5,3
ffffffffc0200c98:	28f71863          	bne	a4,a5,ffffffffc0200f28 <default_check+0x3a2>
ffffffffc0200c9c:	4505                	li	a0,1
ffffffffc0200c9e:	57b000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0200ca2:	89aa                	mv	s3,a0
ffffffffc0200ca4:	26050263          	beqz	a0,ffffffffc0200f08 <default_check+0x382>
ffffffffc0200ca8:	4505                	li	a0,1
ffffffffc0200caa:	56f000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0200cae:	8aaa                	mv	s5,a0
ffffffffc0200cb0:	3a050c63          	beqz	a0,ffffffffc0201068 <default_check+0x4e2>
ffffffffc0200cb4:	4505                	li	a0,1
ffffffffc0200cb6:	563000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0200cba:	8a2a                	mv	s4,a0
ffffffffc0200cbc:	38050663          	beqz	a0,ffffffffc0201048 <default_check+0x4c2>
ffffffffc0200cc0:	4505                	li	a0,1
ffffffffc0200cc2:	557000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0200cc6:	36051163          	bnez	a0,ffffffffc0201028 <default_check+0x4a2>
ffffffffc0200cca:	4585                	li	a1,1
ffffffffc0200ccc:	854e                	mv	a0,s3
ffffffffc0200cce:	5db000ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0200cd2:	641c                	ld	a5,8(s0)
ffffffffc0200cd4:	20878a63          	beq	a5,s0,ffffffffc0200ee8 <default_check+0x362>
ffffffffc0200cd8:	4505                	li	a0,1
ffffffffc0200cda:	53f000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0200cde:	30a99563          	bne	s3,a0,ffffffffc0200fe8 <default_check+0x462>
ffffffffc0200ce2:	4505                	li	a0,1
ffffffffc0200ce4:	535000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0200ce8:	2e051063          	bnez	a0,ffffffffc0200fc8 <default_check+0x442>
ffffffffc0200cec:	481c                	lw	a5,16(s0)
ffffffffc0200cee:	2a079d63          	bnez	a5,ffffffffc0200fa8 <default_check+0x422>
ffffffffc0200cf2:	854e                	mv	a0,s3
ffffffffc0200cf4:	4585                	li	a1,1
ffffffffc0200cf6:	01843023          	sd	s8,0(s0)
ffffffffc0200cfa:	01743423          	sd	s7,8(s0)
ffffffffc0200cfe:	01642823          	sw	s6,16(s0)
ffffffffc0200d02:	5a7000ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0200d06:	4585                	li	a1,1
ffffffffc0200d08:	8556                	mv	a0,s5
ffffffffc0200d0a:	59f000ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0200d0e:	4585                	li	a1,1
ffffffffc0200d10:	8552                	mv	a0,s4
ffffffffc0200d12:	597000ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0200d16:	4515                	li	a0,5
ffffffffc0200d18:	501000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0200d1c:	89aa                	mv	s3,a0
ffffffffc0200d1e:	26050563          	beqz	a0,ffffffffc0200f88 <default_check+0x402>
ffffffffc0200d22:	651c                	ld	a5,8(a0)
ffffffffc0200d24:	8385                	srli	a5,a5,0x1
ffffffffc0200d26:	8b85                	andi	a5,a5,1
ffffffffc0200d28:	54079063          	bnez	a5,ffffffffc0201268 <default_check+0x6e2>
ffffffffc0200d2c:	4505                	li	a0,1
ffffffffc0200d2e:	00043b03          	ld	s6,0(s0)
ffffffffc0200d32:	00843a83          	ld	s5,8(s0)
ffffffffc0200d36:	e000                	sd	s0,0(s0)
ffffffffc0200d38:	e400                	sd	s0,8(s0)
ffffffffc0200d3a:	4df000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0200d3e:	50051563          	bnez	a0,ffffffffc0201248 <default_check+0x6c2>
ffffffffc0200d42:	08098a13          	addi	s4,s3,128
ffffffffc0200d46:	8552                	mv	a0,s4
ffffffffc0200d48:	458d                	li	a1,3
ffffffffc0200d4a:	01042b83          	lw	s7,16(s0)
ffffffffc0200d4e:	00010797          	auipc	a5,0x10
ffffffffc0200d52:	7007ad23          	sw	zero,1818(a5) # ffffffffc0211468 <free_area+0x10>
ffffffffc0200d56:	553000ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0200d5a:	4511                	li	a0,4
ffffffffc0200d5c:	4bd000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0200d60:	4c051463          	bnez	a0,ffffffffc0201228 <default_check+0x6a2>
ffffffffc0200d64:	0889b783          	ld	a5,136(s3)
ffffffffc0200d68:	8385                	srli	a5,a5,0x1
ffffffffc0200d6a:	8b85                	andi	a5,a5,1
ffffffffc0200d6c:	48078e63          	beqz	a5,ffffffffc0201208 <default_check+0x682>
ffffffffc0200d70:	0909a703          	lw	a4,144(s3)
ffffffffc0200d74:	478d                	li	a5,3
ffffffffc0200d76:	48f71963          	bne	a4,a5,ffffffffc0201208 <default_check+0x682>
ffffffffc0200d7a:	450d                	li	a0,3
ffffffffc0200d7c:	49d000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0200d80:	8c2a                	mv	s8,a0
ffffffffc0200d82:	46050363          	beqz	a0,ffffffffc02011e8 <default_check+0x662>
ffffffffc0200d86:	4505                	li	a0,1
ffffffffc0200d88:	491000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0200d8c:	42051e63          	bnez	a0,ffffffffc02011c8 <default_check+0x642>
ffffffffc0200d90:	418a1c63          	bne	s4,s8,ffffffffc02011a8 <default_check+0x622>
ffffffffc0200d94:	4585                	li	a1,1
ffffffffc0200d96:	854e                	mv	a0,s3
ffffffffc0200d98:	511000ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0200d9c:	458d                	li	a1,3
ffffffffc0200d9e:	8552                	mv	a0,s4
ffffffffc0200da0:	509000ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0200da4:	0089b783          	ld	a5,8(s3)
ffffffffc0200da8:	04098c13          	addi	s8,s3,64
ffffffffc0200dac:	8385                	srli	a5,a5,0x1
ffffffffc0200dae:	8b85                	andi	a5,a5,1
ffffffffc0200db0:	3c078c63          	beqz	a5,ffffffffc0201188 <default_check+0x602>
ffffffffc0200db4:	0109a703          	lw	a4,16(s3)
ffffffffc0200db8:	4785                	li	a5,1
ffffffffc0200dba:	3cf71763          	bne	a4,a5,ffffffffc0201188 <default_check+0x602>
ffffffffc0200dbe:	008a3783          	ld	a5,8(s4)
ffffffffc0200dc2:	8385                	srli	a5,a5,0x1
ffffffffc0200dc4:	8b85                	andi	a5,a5,1
ffffffffc0200dc6:	3a078163          	beqz	a5,ffffffffc0201168 <default_check+0x5e2>
ffffffffc0200dca:	010a2703          	lw	a4,16(s4)
ffffffffc0200dce:	478d                	li	a5,3
ffffffffc0200dd0:	38f71c63          	bne	a4,a5,ffffffffc0201168 <default_check+0x5e2>
ffffffffc0200dd4:	4505                	li	a0,1
ffffffffc0200dd6:	443000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0200dda:	36a99763          	bne	s3,a0,ffffffffc0201148 <default_check+0x5c2>
ffffffffc0200dde:	4585                	li	a1,1
ffffffffc0200de0:	4c9000ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0200de4:	4509                	li	a0,2
ffffffffc0200de6:	433000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0200dea:	32aa1f63          	bne	s4,a0,ffffffffc0201128 <default_check+0x5a2>
ffffffffc0200dee:	4589                	li	a1,2
ffffffffc0200df0:	4b9000ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0200df4:	4585                	li	a1,1
ffffffffc0200df6:	8562                	mv	a0,s8
ffffffffc0200df8:	4b1000ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0200dfc:	4515                	li	a0,5
ffffffffc0200dfe:	41b000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0200e02:	89aa                	mv	s3,a0
ffffffffc0200e04:	48050263          	beqz	a0,ffffffffc0201288 <default_check+0x702>
ffffffffc0200e08:	4505                	li	a0,1
ffffffffc0200e0a:	40f000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0200e0e:	2c051d63          	bnez	a0,ffffffffc02010e8 <default_check+0x562>
ffffffffc0200e12:	481c                	lw	a5,16(s0)
ffffffffc0200e14:	2a079a63          	bnez	a5,ffffffffc02010c8 <default_check+0x542>
ffffffffc0200e18:	4595                	li	a1,5
ffffffffc0200e1a:	854e                	mv	a0,s3
ffffffffc0200e1c:	01742823          	sw	s7,16(s0)
ffffffffc0200e20:	01643023          	sd	s6,0(s0)
ffffffffc0200e24:	01543423          	sd	s5,8(s0)
ffffffffc0200e28:	481000ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0200e2c:	641c                	ld	a5,8(s0)
ffffffffc0200e2e:	00878963          	beq	a5,s0,ffffffffc0200e40 <default_check+0x2ba>
ffffffffc0200e32:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e36:	679c                	ld	a5,8(a5)
ffffffffc0200e38:	397d                	addiw	s2,s2,-1
ffffffffc0200e3a:	9c99                	subw	s1,s1,a4
ffffffffc0200e3c:	fe879be3          	bne	a5,s0,ffffffffc0200e32 <default_check+0x2ac>
ffffffffc0200e40:	26091463          	bnez	s2,ffffffffc02010a8 <default_check+0x522>
ffffffffc0200e44:	46049263          	bnez	s1,ffffffffc02012a8 <default_check+0x722>
ffffffffc0200e48:	60a6                	ld	ra,72(sp)
ffffffffc0200e4a:	6406                	ld	s0,64(sp)
ffffffffc0200e4c:	74e2                	ld	s1,56(sp)
ffffffffc0200e4e:	7942                	ld	s2,48(sp)
ffffffffc0200e50:	79a2                	ld	s3,40(sp)
ffffffffc0200e52:	7a02                	ld	s4,32(sp)
ffffffffc0200e54:	6ae2                	ld	s5,24(sp)
ffffffffc0200e56:	6b42                	ld	s6,16(sp)
ffffffffc0200e58:	6ba2                	ld	s7,8(sp)
ffffffffc0200e5a:	6c02                	ld	s8,0(sp)
ffffffffc0200e5c:	6161                	addi	sp,sp,80
ffffffffc0200e5e:	8082                	ret
ffffffffc0200e60:	4981                	li	s3,0
ffffffffc0200e62:	4481                	li	s1,0
ffffffffc0200e64:	4901                	li	s2,0
ffffffffc0200e66:	b38d                	j	ffffffffc0200bc8 <default_check+0x42>
ffffffffc0200e68:	00004697          	auipc	a3,0x4
ffffffffc0200e6c:	5e068693          	addi	a3,a3,1504 # ffffffffc0205448 <commands+0x728>
ffffffffc0200e70:	00004617          	auipc	a2,0x4
ffffffffc0200e74:	5e860613          	addi	a2,a2,1512 # ffffffffc0205458 <commands+0x738>
ffffffffc0200e78:	0f000593          	li	a1,240
ffffffffc0200e7c:	00004517          	auipc	a0,0x4
ffffffffc0200e80:	5f450513          	addi	a0,a0,1524 # ffffffffc0205470 <commands+0x750>
ffffffffc0200e84:	dbaff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200e88:	00004697          	auipc	a3,0x4
ffffffffc0200e8c:	68068693          	addi	a3,a3,1664 # ffffffffc0205508 <commands+0x7e8>
ffffffffc0200e90:	00004617          	auipc	a2,0x4
ffffffffc0200e94:	5c860613          	addi	a2,a2,1480 # ffffffffc0205458 <commands+0x738>
ffffffffc0200e98:	0bd00593          	li	a1,189
ffffffffc0200e9c:	00004517          	auipc	a0,0x4
ffffffffc0200ea0:	5d450513          	addi	a0,a0,1492 # ffffffffc0205470 <commands+0x750>
ffffffffc0200ea4:	d9aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200ea8:	00004697          	auipc	a3,0x4
ffffffffc0200eac:	68868693          	addi	a3,a3,1672 # ffffffffc0205530 <commands+0x810>
ffffffffc0200eb0:	00004617          	auipc	a2,0x4
ffffffffc0200eb4:	5a860613          	addi	a2,a2,1448 # ffffffffc0205458 <commands+0x738>
ffffffffc0200eb8:	0be00593          	li	a1,190
ffffffffc0200ebc:	00004517          	auipc	a0,0x4
ffffffffc0200ec0:	5b450513          	addi	a0,a0,1460 # ffffffffc0205470 <commands+0x750>
ffffffffc0200ec4:	d7aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200ec8:	00004697          	auipc	a3,0x4
ffffffffc0200ecc:	6a868693          	addi	a3,a3,1704 # ffffffffc0205570 <commands+0x850>
ffffffffc0200ed0:	00004617          	auipc	a2,0x4
ffffffffc0200ed4:	58860613          	addi	a2,a2,1416 # ffffffffc0205458 <commands+0x738>
ffffffffc0200ed8:	0c000593          	li	a1,192
ffffffffc0200edc:	00004517          	auipc	a0,0x4
ffffffffc0200ee0:	59450513          	addi	a0,a0,1428 # ffffffffc0205470 <commands+0x750>
ffffffffc0200ee4:	d5aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200ee8:	00004697          	auipc	a3,0x4
ffffffffc0200eec:	71068693          	addi	a3,a3,1808 # ffffffffc02055f8 <commands+0x8d8>
ffffffffc0200ef0:	00004617          	auipc	a2,0x4
ffffffffc0200ef4:	56860613          	addi	a2,a2,1384 # ffffffffc0205458 <commands+0x738>
ffffffffc0200ef8:	0d900593          	li	a1,217
ffffffffc0200efc:	00004517          	auipc	a0,0x4
ffffffffc0200f00:	57450513          	addi	a0,a0,1396 # ffffffffc0205470 <commands+0x750>
ffffffffc0200f04:	d3aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200f08:	00004697          	auipc	a3,0x4
ffffffffc0200f0c:	5a068693          	addi	a3,a3,1440 # ffffffffc02054a8 <commands+0x788>
ffffffffc0200f10:	00004617          	auipc	a2,0x4
ffffffffc0200f14:	54860613          	addi	a2,a2,1352 # ffffffffc0205458 <commands+0x738>
ffffffffc0200f18:	0d200593          	li	a1,210
ffffffffc0200f1c:	00004517          	auipc	a0,0x4
ffffffffc0200f20:	55450513          	addi	a0,a0,1364 # ffffffffc0205470 <commands+0x750>
ffffffffc0200f24:	d1aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200f28:	00004697          	auipc	a3,0x4
ffffffffc0200f2c:	6c068693          	addi	a3,a3,1728 # ffffffffc02055e8 <commands+0x8c8>
ffffffffc0200f30:	00004617          	auipc	a2,0x4
ffffffffc0200f34:	52860613          	addi	a2,a2,1320 # ffffffffc0205458 <commands+0x738>
ffffffffc0200f38:	0d000593          	li	a1,208
ffffffffc0200f3c:	00004517          	auipc	a0,0x4
ffffffffc0200f40:	53450513          	addi	a0,a0,1332 # ffffffffc0205470 <commands+0x750>
ffffffffc0200f44:	cfaff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200f48:	00004697          	auipc	a3,0x4
ffffffffc0200f4c:	68868693          	addi	a3,a3,1672 # ffffffffc02055d0 <commands+0x8b0>
ffffffffc0200f50:	00004617          	auipc	a2,0x4
ffffffffc0200f54:	50860613          	addi	a2,a2,1288 # ffffffffc0205458 <commands+0x738>
ffffffffc0200f58:	0cb00593          	li	a1,203
ffffffffc0200f5c:	00004517          	auipc	a0,0x4
ffffffffc0200f60:	51450513          	addi	a0,a0,1300 # ffffffffc0205470 <commands+0x750>
ffffffffc0200f64:	cdaff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200f68:	00004697          	auipc	a3,0x4
ffffffffc0200f6c:	64868693          	addi	a3,a3,1608 # ffffffffc02055b0 <commands+0x890>
ffffffffc0200f70:	00004617          	auipc	a2,0x4
ffffffffc0200f74:	4e860613          	addi	a2,a2,1256 # ffffffffc0205458 <commands+0x738>
ffffffffc0200f78:	0c200593          	li	a1,194
ffffffffc0200f7c:	00004517          	auipc	a0,0x4
ffffffffc0200f80:	4f450513          	addi	a0,a0,1268 # ffffffffc0205470 <commands+0x750>
ffffffffc0200f84:	cbaff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200f88:	00004697          	auipc	a3,0x4
ffffffffc0200f8c:	6b868693          	addi	a3,a3,1720 # ffffffffc0205640 <commands+0x920>
ffffffffc0200f90:	00004617          	auipc	a2,0x4
ffffffffc0200f94:	4c860613          	addi	a2,a2,1224 # ffffffffc0205458 <commands+0x738>
ffffffffc0200f98:	0f800593          	li	a1,248
ffffffffc0200f9c:	00004517          	auipc	a0,0x4
ffffffffc0200fa0:	4d450513          	addi	a0,a0,1236 # ffffffffc0205470 <commands+0x750>
ffffffffc0200fa4:	c9aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200fa8:	00004697          	auipc	a3,0x4
ffffffffc0200fac:	68868693          	addi	a3,a3,1672 # ffffffffc0205630 <commands+0x910>
ffffffffc0200fb0:	00004617          	auipc	a2,0x4
ffffffffc0200fb4:	4a860613          	addi	a2,a2,1192 # ffffffffc0205458 <commands+0x738>
ffffffffc0200fb8:	0df00593          	li	a1,223
ffffffffc0200fbc:	00004517          	auipc	a0,0x4
ffffffffc0200fc0:	4b450513          	addi	a0,a0,1204 # ffffffffc0205470 <commands+0x750>
ffffffffc0200fc4:	c7aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200fc8:	00004697          	auipc	a3,0x4
ffffffffc0200fcc:	60868693          	addi	a3,a3,1544 # ffffffffc02055d0 <commands+0x8b0>
ffffffffc0200fd0:	00004617          	auipc	a2,0x4
ffffffffc0200fd4:	48860613          	addi	a2,a2,1160 # ffffffffc0205458 <commands+0x738>
ffffffffc0200fd8:	0dd00593          	li	a1,221
ffffffffc0200fdc:	00004517          	auipc	a0,0x4
ffffffffc0200fe0:	49450513          	addi	a0,a0,1172 # ffffffffc0205470 <commands+0x750>
ffffffffc0200fe4:	c5aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0200fe8:	00004697          	auipc	a3,0x4
ffffffffc0200fec:	62868693          	addi	a3,a3,1576 # ffffffffc0205610 <commands+0x8f0>
ffffffffc0200ff0:	00004617          	auipc	a2,0x4
ffffffffc0200ff4:	46860613          	addi	a2,a2,1128 # ffffffffc0205458 <commands+0x738>
ffffffffc0200ff8:	0dc00593          	li	a1,220
ffffffffc0200ffc:	00004517          	auipc	a0,0x4
ffffffffc0201000:	47450513          	addi	a0,a0,1140 # ffffffffc0205470 <commands+0x750>
ffffffffc0201004:	c3aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201008:	00004697          	auipc	a3,0x4
ffffffffc020100c:	4a068693          	addi	a3,a3,1184 # ffffffffc02054a8 <commands+0x788>
ffffffffc0201010:	00004617          	auipc	a2,0x4
ffffffffc0201014:	44860613          	addi	a2,a2,1096 # ffffffffc0205458 <commands+0x738>
ffffffffc0201018:	0b900593          	li	a1,185
ffffffffc020101c:	00004517          	auipc	a0,0x4
ffffffffc0201020:	45450513          	addi	a0,a0,1108 # ffffffffc0205470 <commands+0x750>
ffffffffc0201024:	c1aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201028:	00004697          	auipc	a3,0x4
ffffffffc020102c:	5a868693          	addi	a3,a3,1448 # ffffffffc02055d0 <commands+0x8b0>
ffffffffc0201030:	00004617          	auipc	a2,0x4
ffffffffc0201034:	42860613          	addi	a2,a2,1064 # ffffffffc0205458 <commands+0x738>
ffffffffc0201038:	0d600593          	li	a1,214
ffffffffc020103c:	00004517          	auipc	a0,0x4
ffffffffc0201040:	43450513          	addi	a0,a0,1076 # ffffffffc0205470 <commands+0x750>
ffffffffc0201044:	bfaff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201048:	00004697          	auipc	a3,0x4
ffffffffc020104c:	4a068693          	addi	a3,a3,1184 # ffffffffc02054e8 <commands+0x7c8>
ffffffffc0201050:	00004617          	auipc	a2,0x4
ffffffffc0201054:	40860613          	addi	a2,a2,1032 # ffffffffc0205458 <commands+0x738>
ffffffffc0201058:	0d400593          	li	a1,212
ffffffffc020105c:	00004517          	auipc	a0,0x4
ffffffffc0201060:	41450513          	addi	a0,a0,1044 # ffffffffc0205470 <commands+0x750>
ffffffffc0201064:	bdaff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201068:	00004697          	auipc	a3,0x4
ffffffffc020106c:	46068693          	addi	a3,a3,1120 # ffffffffc02054c8 <commands+0x7a8>
ffffffffc0201070:	00004617          	auipc	a2,0x4
ffffffffc0201074:	3e860613          	addi	a2,a2,1000 # ffffffffc0205458 <commands+0x738>
ffffffffc0201078:	0d300593          	li	a1,211
ffffffffc020107c:	00004517          	auipc	a0,0x4
ffffffffc0201080:	3f450513          	addi	a0,a0,1012 # ffffffffc0205470 <commands+0x750>
ffffffffc0201084:	bbaff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201088:	00004697          	auipc	a3,0x4
ffffffffc020108c:	46068693          	addi	a3,a3,1120 # ffffffffc02054e8 <commands+0x7c8>
ffffffffc0201090:	00004617          	auipc	a2,0x4
ffffffffc0201094:	3c860613          	addi	a2,a2,968 # ffffffffc0205458 <commands+0x738>
ffffffffc0201098:	0bb00593          	li	a1,187
ffffffffc020109c:	00004517          	auipc	a0,0x4
ffffffffc02010a0:	3d450513          	addi	a0,a0,980 # ffffffffc0205470 <commands+0x750>
ffffffffc02010a4:	b9aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02010a8:	00004697          	auipc	a3,0x4
ffffffffc02010ac:	6e868693          	addi	a3,a3,1768 # ffffffffc0205790 <commands+0xa70>
ffffffffc02010b0:	00004617          	auipc	a2,0x4
ffffffffc02010b4:	3a860613          	addi	a2,a2,936 # ffffffffc0205458 <commands+0x738>
ffffffffc02010b8:	12500593          	li	a1,293
ffffffffc02010bc:	00004517          	auipc	a0,0x4
ffffffffc02010c0:	3b450513          	addi	a0,a0,948 # ffffffffc0205470 <commands+0x750>
ffffffffc02010c4:	b7aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02010c8:	00004697          	auipc	a3,0x4
ffffffffc02010cc:	56868693          	addi	a3,a3,1384 # ffffffffc0205630 <commands+0x910>
ffffffffc02010d0:	00004617          	auipc	a2,0x4
ffffffffc02010d4:	38860613          	addi	a2,a2,904 # ffffffffc0205458 <commands+0x738>
ffffffffc02010d8:	11a00593          	li	a1,282
ffffffffc02010dc:	00004517          	auipc	a0,0x4
ffffffffc02010e0:	39450513          	addi	a0,a0,916 # ffffffffc0205470 <commands+0x750>
ffffffffc02010e4:	b5aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02010e8:	00004697          	auipc	a3,0x4
ffffffffc02010ec:	4e868693          	addi	a3,a3,1256 # ffffffffc02055d0 <commands+0x8b0>
ffffffffc02010f0:	00004617          	auipc	a2,0x4
ffffffffc02010f4:	36860613          	addi	a2,a2,872 # ffffffffc0205458 <commands+0x738>
ffffffffc02010f8:	11800593          	li	a1,280
ffffffffc02010fc:	00004517          	auipc	a0,0x4
ffffffffc0201100:	37450513          	addi	a0,a0,884 # ffffffffc0205470 <commands+0x750>
ffffffffc0201104:	b3aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201108:	00004697          	auipc	a3,0x4
ffffffffc020110c:	48868693          	addi	a3,a3,1160 # ffffffffc0205590 <commands+0x870>
ffffffffc0201110:	00004617          	auipc	a2,0x4
ffffffffc0201114:	34860613          	addi	a2,a2,840 # ffffffffc0205458 <commands+0x738>
ffffffffc0201118:	0c100593          	li	a1,193
ffffffffc020111c:	00004517          	auipc	a0,0x4
ffffffffc0201120:	35450513          	addi	a0,a0,852 # ffffffffc0205470 <commands+0x750>
ffffffffc0201124:	b1aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201128:	00004697          	auipc	a3,0x4
ffffffffc020112c:	62868693          	addi	a3,a3,1576 # ffffffffc0205750 <commands+0xa30>
ffffffffc0201130:	00004617          	auipc	a2,0x4
ffffffffc0201134:	32860613          	addi	a2,a2,808 # ffffffffc0205458 <commands+0x738>
ffffffffc0201138:	11200593          	li	a1,274
ffffffffc020113c:	00004517          	auipc	a0,0x4
ffffffffc0201140:	33450513          	addi	a0,a0,820 # ffffffffc0205470 <commands+0x750>
ffffffffc0201144:	afaff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201148:	00004697          	auipc	a3,0x4
ffffffffc020114c:	5e868693          	addi	a3,a3,1512 # ffffffffc0205730 <commands+0xa10>
ffffffffc0201150:	00004617          	auipc	a2,0x4
ffffffffc0201154:	30860613          	addi	a2,a2,776 # ffffffffc0205458 <commands+0x738>
ffffffffc0201158:	11000593          	li	a1,272
ffffffffc020115c:	00004517          	auipc	a0,0x4
ffffffffc0201160:	31450513          	addi	a0,a0,788 # ffffffffc0205470 <commands+0x750>
ffffffffc0201164:	adaff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201168:	00004697          	auipc	a3,0x4
ffffffffc020116c:	5a068693          	addi	a3,a3,1440 # ffffffffc0205708 <commands+0x9e8>
ffffffffc0201170:	00004617          	auipc	a2,0x4
ffffffffc0201174:	2e860613          	addi	a2,a2,744 # ffffffffc0205458 <commands+0x738>
ffffffffc0201178:	10e00593          	li	a1,270
ffffffffc020117c:	00004517          	auipc	a0,0x4
ffffffffc0201180:	2f450513          	addi	a0,a0,756 # ffffffffc0205470 <commands+0x750>
ffffffffc0201184:	abaff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201188:	00004697          	auipc	a3,0x4
ffffffffc020118c:	55868693          	addi	a3,a3,1368 # ffffffffc02056e0 <commands+0x9c0>
ffffffffc0201190:	00004617          	auipc	a2,0x4
ffffffffc0201194:	2c860613          	addi	a2,a2,712 # ffffffffc0205458 <commands+0x738>
ffffffffc0201198:	10d00593          	li	a1,269
ffffffffc020119c:	00004517          	auipc	a0,0x4
ffffffffc02011a0:	2d450513          	addi	a0,a0,724 # ffffffffc0205470 <commands+0x750>
ffffffffc02011a4:	a9aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02011a8:	00004697          	auipc	a3,0x4
ffffffffc02011ac:	52868693          	addi	a3,a3,1320 # ffffffffc02056d0 <commands+0x9b0>
ffffffffc02011b0:	00004617          	auipc	a2,0x4
ffffffffc02011b4:	2a860613          	addi	a2,a2,680 # ffffffffc0205458 <commands+0x738>
ffffffffc02011b8:	10800593          	li	a1,264
ffffffffc02011bc:	00004517          	auipc	a0,0x4
ffffffffc02011c0:	2b450513          	addi	a0,a0,692 # ffffffffc0205470 <commands+0x750>
ffffffffc02011c4:	a7aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02011c8:	00004697          	auipc	a3,0x4
ffffffffc02011cc:	40868693          	addi	a3,a3,1032 # ffffffffc02055d0 <commands+0x8b0>
ffffffffc02011d0:	00004617          	auipc	a2,0x4
ffffffffc02011d4:	28860613          	addi	a2,a2,648 # ffffffffc0205458 <commands+0x738>
ffffffffc02011d8:	10700593          	li	a1,263
ffffffffc02011dc:	00004517          	auipc	a0,0x4
ffffffffc02011e0:	29450513          	addi	a0,a0,660 # ffffffffc0205470 <commands+0x750>
ffffffffc02011e4:	a5aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02011e8:	00004697          	auipc	a3,0x4
ffffffffc02011ec:	4c868693          	addi	a3,a3,1224 # ffffffffc02056b0 <commands+0x990>
ffffffffc02011f0:	00004617          	auipc	a2,0x4
ffffffffc02011f4:	26860613          	addi	a2,a2,616 # ffffffffc0205458 <commands+0x738>
ffffffffc02011f8:	10600593          	li	a1,262
ffffffffc02011fc:	00004517          	auipc	a0,0x4
ffffffffc0201200:	27450513          	addi	a0,a0,628 # ffffffffc0205470 <commands+0x750>
ffffffffc0201204:	a3aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201208:	00004697          	auipc	a3,0x4
ffffffffc020120c:	47868693          	addi	a3,a3,1144 # ffffffffc0205680 <commands+0x960>
ffffffffc0201210:	00004617          	auipc	a2,0x4
ffffffffc0201214:	24860613          	addi	a2,a2,584 # ffffffffc0205458 <commands+0x738>
ffffffffc0201218:	10500593          	li	a1,261
ffffffffc020121c:	00004517          	auipc	a0,0x4
ffffffffc0201220:	25450513          	addi	a0,a0,596 # ffffffffc0205470 <commands+0x750>
ffffffffc0201224:	a1aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201228:	00004697          	auipc	a3,0x4
ffffffffc020122c:	44068693          	addi	a3,a3,1088 # ffffffffc0205668 <commands+0x948>
ffffffffc0201230:	00004617          	auipc	a2,0x4
ffffffffc0201234:	22860613          	addi	a2,a2,552 # ffffffffc0205458 <commands+0x738>
ffffffffc0201238:	10400593          	li	a1,260
ffffffffc020123c:	00004517          	auipc	a0,0x4
ffffffffc0201240:	23450513          	addi	a0,a0,564 # ffffffffc0205470 <commands+0x750>
ffffffffc0201244:	9faff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201248:	00004697          	auipc	a3,0x4
ffffffffc020124c:	38868693          	addi	a3,a3,904 # ffffffffc02055d0 <commands+0x8b0>
ffffffffc0201250:	00004617          	auipc	a2,0x4
ffffffffc0201254:	20860613          	addi	a2,a2,520 # ffffffffc0205458 <commands+0x738>
ffffffffc0201258:	0fe00593          	li	a1,254
ffffffffc020125c:	00004517          	auipc	a0,0x4
ffffffffc0201260:	21450513          	addi	a0,a0,532 # ffffffffc0205470 <commands+0x750>
ffffffffc0201264:	9daff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201268:	00004697          	auipc	a3,0x4
ffffffffc020126c:	3e868693          	addi	a3,a3,1000 # ffffffffc0205650 <commands+0x930>
ffffffffc0201270:	00004617          	auipc	a2,0x4
ffffffffc0201274:	1e860613          	addi	a2,a2,488 # ffffffffc0205458 <commands+0x738>
ffffffffc0201278:	0f900593          	li	a1,249
ffffffffc020127c:	00004517          	auipc	a0,0x4
ffffffffc0201280:	1f450513          	addi	a0,a0,500 # ffffffffc0205470 <commands+0x750>
ffffffffc0201284:	9baff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201288:	00004697          	auipc	a3,0x4
ffffffffc020128c:	4e868693          	addi	a3,a3,1256 # ffffffffc0205770 <commands+0xa50>
ffffffffc0201290:	00004617          	auipc	a2,0x4
ffffffffc0201294:	1c860613          	addi	a2,a2,456 # ffffffffc0205458 <commands+0x738>
ffffffffc0201298:	11700593          	li	a1,279
ffffffffc020129c:	00004517          	auipc	a0,0x4
ffffffffc02012a0:	1d450513          	addi	a0,a0,468 # ffffffffc0205470 <commands+0x750>
ffffffffc02012a4:	99aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02012a8:	00004697          	auipc	a3,0x4
ffffffffc02012ac:	4f868693          	addi	a3,a3,1272 # ffffffffc02057a0 <commands+0xa80>
ffffffffc02012b0:	00004617          	auipc	a2,0x4
ffffffffc02012b4:	1a860613          	addi	a2,a2,424 # ffffffffc0205458 <commands+0x738>
ffffffffc02012b8:	12600593          	li	a1,294
ffffffffc02012bc:	00004517          	auipc	a0,0x4
ffffffffc02012c0:	1b450513          	addi	a0,a0,436 # ffffffffc0205470 <commands+0x750>
ffffffffc02012c4:	97aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02012c8:	00004697          	auipc	a3,0x4
ffffffffc02012cc:	1c068693          	addi	a3,a3,448 # ffffffffc0205488 <commands+0x768>
ffffffffc02012d0:	00004617          	auipc	a2,0x4
ffffffffc02012d4:	18860613          	addi	a2,a2,392 # ffffffffc0205458 <commands+0x738>
ffffffffc02012d8:	0f300593          	li	a1,243
ffffffffc02012dc:	00004517          	auipc	a0,0x4
ffffffffc02012e0:	19450513          	addi	a0,a0,404 # ffffffffc0205470 <commands+0x750>
ffffffffc02012e4:	95aff0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02012e8:	00004697          	auipc	a3,0x4
ffffffffc02012ec:	1e068693          	addi	a3,a3,480 # ffffffffc02054c8 <commands+0x7a8>
ffffffffc02012f0:	00004617          	auipc	a2,0x4
ffffffffc02012f4:	16860613          	addi	a2,a2,360 # ffffffffc0205458 <commands+0x738>
ffffffffc02012f8:	0ba00593          	li	a1,186
ffffffffc02012fc:	00004517          	auipc	a0,0x4
ffffffffc0201300:	17450513          	addi	a0,a0,372 # ffffffffc0205470 <commands+0x750>
ffffffffc0201304:	93aff0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0201308 <default_free_pages>:
ffffffffc0201308:	1141                	addi	sp,sp,-16
ffffffffc020130a:	e406                	sd	ra,8(sp)
ffffffffc020130c:	14058463          	beqz	a1,ffffffffc0201454 <default_free_pages+0x14c>
ffffffffc0201310:	00659713          	slli	a4,a1,0x6
ffffffffc0201314:	00e506b3          	add	a3,a0,a4
ffffffffc0201318:	87aa                	mv	a5,a0
ffffffffc020131a:	c30d                	beqz	a4,ffffffffc020133c <default_free_pages+0x34>
ffffffffc020131c:	6798                	ld	a4,8(a5)
ffffffffc020131e:	8b05                	andi	a4,a4,1
ffffffffc0201320:	10071a63          	bnez	a4,ffffffffc0201434 <default_free_pages+0x12c>
ffffffffc0201324:	6798                	ld	a4,8(a5)
ffffffffc0201326:	8b09                	andi	a4,a4,2
ffffffffc0201328:	10071663          	bnez	a4,ffffffffc0201434 <default_free_pages+0x12c>
ffffffffc020132c:	0007b423          	sd	zero,8(a5)
ffffffffc0201330:	0007a023          	sw	zero,0(a5)
ffffffffc0201334:	04078793          	addi	a5,a5,64
ffffffffc0201338:	fed792e3          	bne	a5,a3,ffffffffc020131c <default_free_pages+0x14>
ffffffffc020133c:	2581                	sext.w	a1,a1
ffffffffc020133e:	c90c                	sw	a1,16(a0)
ffffffffc0201340:	00850893          	addi	a7,a0,8
ffffffffc0201344:	4789                	li	a5,2
ffffffffc0201346:	40f8b02f          	amoor.d	zero,a5,(a7)
ffffffffc020134a:	00010697          	auipc	a3,0x10
ffffffffc020134e:	10e68693          	addi	a3,a3,270 # ffffffffc0211458 <free_area>
ffffffffc0201352:	4a98                	lw	a4,16(a3)
ffffffffc0201354:	669c                	ld	a5,8(a3)
ffffffffc0201356:	9f2d                	addw	a4,a4,a1
ffffffffc0201358:	ca98                	sw	a4,16(a3)
ffffffffc020135a:	0ad78163          	beq	a5,a3,ffffffffc02013fc <default_free_pages+0xf4>
ffffffffc020135e:	fe878713          	addi	a4,a5,-24
ffffffffc0201362:	4581                	li	a1,0
ffffffffc0201364:	01850613          	addi	a2,a0,24
ffffffffc0201368:	00e56a63          	bltu	a0,a4,ffffffffc020137c <default_free_pages+0x74>
ffffffffc020136c:	6798                	ld	a4,8(a5)
ffffffffc020136e:	04d70c63          	beq	a4,a3,ffffffffc02013c6 <default_free_pages+0xbe>
ffffffffc0201372:	87ba                	mv	a5,a4
ffffffffc0201374:	fe878713          	addi	a4,a5,-24
ffffffffc0201378:	fee57ae3          	bgeu	a0,a4,ffffffffc020136c <default_free_pages+0x64>
ffffffffc020137c:	c199                	beqz	a1,ffffffffc0201382 <default_free_pages+0x7a>
ffffffffc020137e:	0106b023          	sd	a6,0(a3)
ffffffffc0201382:	6398                	ld	a4,0(a5)
ffffffffc0201384:	e390                	sd	a2,0(a5)
ffffffffc0201386:	e710                	sd	a2,8(a4)
ffffffffc0201388:	f11c                	sd	a5,32(a0)
ffffffffc020138a:	ed18                	sd	a4,24(a0)
ffffffffc020138c:	00d70d63          	beq	a4,a3,ffffffffc02013a6 <default_free_pages+0x9e>
ffffffffc0201390:	ff872583          	lw	a1,-8(a4)
ffffffffc0201394:	fe870613          	addi	a2,a4,-24
ffffffffc0201398:	02059813          	slli	a6,a1,0x20
ffffffffc020139c:	01a85793          	srli	a5,a6,0x1a
ffffffffc02013a0:	97b2                	add	a5,a5,a2
ffffffffc02013a2:	02f50c63          	beq	a0,a5,ffffffffc02013da <default_free_pages+0xd2>
ffffffffc02013a6:	711c                	ld	a5,32(a0)
ffffffffc02013a8:	00d78c63          	beq	a5,a3,ffffffffc02013c0 <default_free_pages+0xb8>
ffffffffc02013ac:	4910                	lw	a2,16(a0)
ffffffffc02013ae:	fe878693          	addi	a3,a5,-24
ffffffffc02013b2:	02061593          	slli	a1,a2,0x20
ffffffffc02013b6:	01a5d713          	srli	a4,a1,0x1a
ffffffffc02013ba:	972a                	add	a4,a4,a0
ffffffffc02013bc:	04e68c63          	beq	a3,a4,ffffffffc0201414 <default_free_pages+0x10c>
ffffffffc02013c0:	60a2                	ld	ra,8(sp)
ffffffffc02013c2:	0141                	addi	sp,sp,16
ffffffffc02013c4:	8082                	ret
ffffffffc02013c6:	e790                	sd	a2,8(a5)
ffffffffc02013c8:	f114                	sd	a3,32(a0)
ffffffffc02013ca:	6798                	ld	a4,8(a5)
ffffffffc02013cc:	ed1c                	sd	a5,24(a0)
ffffffffc02013ce:	8832                	mv	a6,a2
ffffffffc02013d0:	02d70f63          	beq	a4,a3,ffffffffc020140e <default_free_pages+0x106>
ffffffffc02013d4:	4585                	li	a1,1
ffffffffc02013d6:	87ba                	mv	a5,a4
ffffffffc02013d8:	bf71                	j	ffffffffc0201374 <default_free_pages+0x6c>
ffffffffc02013da:	491c                	lw	a5,16(a0)
ffffffffc02013dc:	9fad                	addw	a5,a5,a1
ffffffffc02013de:	fef72c23          	sw	a5,-8(a4)
ffffffffc02013e2:	57f5                	li	a5,-3
ffffffffc02013e4:	60f8b02f          	amoand.d	zero,a5,(a7)
ffffffffc02013e8:	01853803          	ld	a6,24(a0)
ffffffffc02013ec:	710c                	ld	a1,32(a0)
ffffffffc02013ee:	8532                	mv	a0,a2
ffffffffc02013f0:	00b83423          	sd	a1,8(a6)
ffffffffc02013f4:	671c                	ld	a5,8(a4)
ffffffffc02013f6:	0105b023          	sd	a6,0(a1)
ffffffffc02013fa:	b77d                	j	ffffffffc02013a8 <default_free_pages+0xa0>
ffffffffc02013fc:	60a2                	ld	ra,8(sp)
ffffffffc02013fe:	01850713          	addi	a4,a0,24
ffffffffc0201402:	e398                	sd	a4,0(a5)
ffffffffc0201404:	e798                	sd	a4,8(a5)
ffffffffc0201406:	f11c                	sd	a5,32(a0)
ffffffffc0201408:	ed1c                	sd	a5,24(a0)
ffffffffc020140a:	0141                	addi	sp,sp,16
ffffffffc020140c:	8082                	ret
ffffffffc020140e:	e290                	sd	a2,0(a3)
ffffffffc0201410:	873e                	mv	a4,a5
ffffffffc0201412:	bfad                	j	ffffffffc020138c <default_free_pages+0x84>
ffffffffc0201414:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201418:	ff078693          	addi	a3,a5,-16
ffffffffc020141c:	9f31                	addw	a4,a4,a2
ffffffffc020141e:	c918                	sw	a4,16(a0)
ffffffffc0201420:	5775                	li	a4,-3
ffffffffc0201422:	60e6b02f          	amoand.d	zero,a4,(a3)
ffffffffc0201426:	6398                	ld	a4,0(a5)
ffffffffc0201428:	679c                	ld	a5,8(a5)
ffffffffc020142a:	60a2                	ld	ra,8(sp)
ffffffffc020142c:	e71c                	sd	a5,8(a4)
ffffffffc020142e:	e398                	sd	a4,0(a5)
ffffffffc0201430:	0141                	addi	sp,sp,16
ffffffffc0201432:	8082                	ret
ffffffffc0201434:	00004697          	auipc	a3,0x4
ffffffffc0201438:	38468693          	addi	a3,a3,900 # ffffffffc02057b8 <commands+0xa98>
ffffffffc020143c:	00004617          	auipc	a2,0x4
ffffffffc0201440:	01c60613          	addi	a2,a2,28 # ffffffffc0205458 <commands+0x738>
ffffffffc0201444:	08300593          	li	a1,131
ffffffffc0201448:	00004517          	auipc	a0,0x4
ffffffffc020144c:	02850513          	addi	a0,a0,40 # ffffffffc0205470 <commands+0x750>
ffffffffc0201450:	feffe0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201454:	00004697          	auipc	a3,0x4
ffffffffc0201458:	35c68693          	addi	a3,a3,860 # ffffffffc02057b0 <commands+0xa90>
ffffffffc020145c:	00004617          	auipc	a2,0x4
ffffffffc0201460:	ffc60613          	addi	a2,a2,-4 # ffffffffc0205458 <commands+0x738>
ffffffffc0201464:	08000593          	li	a1,128
ffffffffc0201468:	00004517          	auipc	a0,0x4
ffffffffc020146c:	00850513          	addi	a0,a0,8 # ffffffffc0205470 <commands+0x750>
ffffffffc0201470:	fcffe0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0201474 <default_alloc_pages>:
ffffffffc0201474:	c949                	beqz	a0,ffffffffc0201506 <default_alloc_pages+0x92>
ffffffffc0201476:	00010617          	auipc	a2,0x10
ffffffffc020147a:	fe260613          	addi	a2,a2,-30 # ffffffffc0211458 <free_area>
ffffffffc020147e:	4a0c                	lw	a1,16(a2)
ffffffffc0201480:	872a                	mv	a4,a0
ffffffffc0201482:	02059793          	slli	a5,a1,0x20
ffffffffc0201486:	9381                	srli	a5,a5,0x20
ffffffffc0201488:	00a7eb63          	bltu	a5,a0,ffffffffc020149e <default_alloc_pages+0x2a>
ffffffffc020148c:	87b2                	mv	a5,a2
ffffffffc020148e:	a029                	j	ffffffffc0201498 <default_alloc_pages+0x24>
ffffffffc0201490:	ff87e683          	lwu	a3,-8(a5)
ffffffffc0201494:	00e6f763          	bgeu	a3,a4,ffffffffc02014a2 <default_alloc_pages+0x2e>
ffffffffc0201498:	679c                	ld	a5,8(a5)
ffffffffc020149a:	fec79be3          	bne	a5,a2,ffffffffc0201490 <default_alloc_pages+0x1c>
ffffffffc020149e:	4501                	li	a0,0
ffffffffc02014a0:	8082                	ret
ffffffffc02014a2:	0087b883          	ld	a7,8(a5)
ffffffffc02014a6:	ff87a803          	lw	a6,-8(a5)
ffffffffc02014aa:	6394                	ld	a3,0(a5)
ffffffffc02014ac:	fe878513          	addi	a0,a5,-24
ffffffffc02014b0:	02081313          	slli	t1,a6,0x20
ffffffffc02014b4:	0116b423          	sd	a7,8(a3)
ffffffffc02014b8:	00d8b023          	sd	a3,0(a7)
ffffffffc02014bc:	02035313          	srli	t1,t1,0x20
ffffffffc02014c0:	0007089b          	sext.w	a7,a4
ffffffffc02014c4:	02677963          	bgeu	a4,t1,ffffffffc02014f6 <default_alloc_pages+0x82>
ffffffffc02014c8:	071a                	slli	a4,a4,0x6
ffffffffc02014ca:	972a                	add	a4,a4,a0
ffffffffc02014cc:	4118083b          	subw	a6,a6,a7
ffffffffc02014d0:	01072823          	sw	a6,16(a4)
ffffffffc02014d4:	4589                	li	a1,2
ffffffffc02014d6:	00870813          	addi	a6,a4,8
ffffffffc02014da:	40b8302f          	amoor.d	zero,a1,(a6)
ffffffffc02014de:	0086b803          	ld	a6,8(a3)
ffffffffc02014e2:	01870313          	addi	t1,a4,24
ffffffffc02014e6:	4a0c                	lw	a1,16(a2)
ffffffffc02014e8:	00683023          	sd	t1,0(a6)
ffffffffc02014ec:	0066b423          	sd	t1,8(a3)
ffffffffc02014f0:	03073023          	sd	a6,32(a4)
ffffffffc02014f4:	ef14                	sd	a3,24(a4)
ffffffffc02014f6:	411585bb          	subw	a1,a1,a7
ffffffffc02014fa:	ca0c                	sw	a1,16(a2)
ffffffffc02014fc:	5775                	li	a4,-3
ffffffffc02014fe:	17c1                	addi	a5,a5,-16
ffffffffc0201500:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201504:	8082                	ret
ffffffffc0201506:	1141                	addi	sp,sp,-16
ffffffffc0201508:	00004697          	auipc	a3,0x4
ffffffffc020150c:	2a868693          	addi	a3,a3,680 # ffffffffc02057b0 <commands+0xa90>
ffffffffc0201510:	00004617          	auipc	a2,0x4
ffffffffc0201514:	f4860613          	addi	a2,a2,-184 # ffffffffc0205458 <commands+0x738>
ffffffffc0201518:	06200593          	li	a1,98
ffffffffc020151c:	00004517          	auipc	a0,0x4
ffffffffc0201520:	f5450513          	addi	a0,a0,-172 # ffffffffc0205470 <commands+0x750>
ffffffffc0201524:	e406                	sd	ra,8(sp)
ffffffffc0201526:	f19fe0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc020152a <default_init_memmap>:
ffffffffc020152a:	1141                	addi	sp,sp,-16
ffffffffc020152c:	e406                	sd	ra,8(sp)
ffffffffc020152e:	c5f1                	beqz	a1,ffffffffc02015fa <default_init_memmap+0xd0>
ffffffffc0201530:	00659713          	slli	a4,a1,0x6
ffffffffc0201534:	00e506b3          	add	a3,a0,a4
ffffffffc0201538:	87aa                	mv	a5,a0
ffffffffc020153a:	cf11                	beqz	a4,ffffffffc0201556 <default_init_memmap+0x2c>
ffffffffc020153c:	6798                	ld	a4,8(a5)
ffffffffc020153e:	8b05                	andi	a4,a4,1
ffffffffc0201540:	cf49                	beqz	a4,ffffffffc02015da <default_init_memmap+0xb0>
ffffffffc0201542:	0007a823          	sw	zero,16(a5)
ffffffffc0201546:	0007b423          	sd	zero,8(a5)
ffffffffc020154a:	0007a023          	sw	zero,0(a5)
ffffffffc020154e:	04078793          	addi	a5,a5,64
ffffffffc0201552:	fed795e3          	bne	a5,a3,ffffffffc020153c <default_init_memmap+0x12>
ffffffffc0201556:	2581                	sext.w	a1,a1
ffffffffc0201558:	c90c                	sw	a1,16(a0)
ffffffffc020155a:	4789                	li	a5,2
ffffffffc020155c:	00850713          	addi	a4,a0,8
ffffffffc0201560:	40f7302f          	amoor.d	zero,a5,(a4)
ffffffffc0201564:	00010697          	auipc	a3,0x10
ffffffffc0201568:	ef468693          	addi	a3,a3,-268 # ffffffffc0211458 <free_area>
ffffffffc020156c:	4a98                	lw	a4,16(a3)
ffffffffc020156e:	669c                	ld	a5,8(a3)
ffffffffc0201570:	9f2d                	addw	a4,a4,a1
ffffffffc0201572:	ca98                	sw	a4,16(a3)
ffffffffc0201574:	04d78663          	beq	a5,a3,ffffffffc02015c0 <default_init_memmap+0x96>
ffffffffc0201578:	fe878713          	addi	a4,a5,-24
ffffffffc020157c:	4581                	li	a1,0
ffffffffc020157e:	01850613          	addi	a2,a0,24
ffffffffc0201582:	00e56a63          	bltu	a0,a4,ffffffffc0201596 <default_init_memmap+0x6c>
ffffffffc0201586:	6798                	ld	a4,8(a5)
ffffffffc0201588:	02d70263          	beq	a4,a3,ffffffffc02015ac <default_init_memmap+0x82>
ffffffffc020158c:	87ba                	mv	a5,a4
ffffffffc020158e:	fe878713          	addi	a4,a5,-24
ffffffffc0201592:	fee57ae3          	bgeu	a0,a4,ffffffffc0201586 <default_init_memmap+0x5c>
ffffffffc0201596:	c199                	beqz	a1,ffffffffc020159c <default_init_memmap+0x72>
ffffffffc0201598:	0106b023          	sd	a6,0(a3)
ffffffffc020159c:	6398                	ld	a4,0(a5)
ffffffffc020159e:	60a2                	ld	ra,8(sp)
ffffffffc02015a0:	e390                	sd	a2,0(a5)
ffffffffc02015a2:	e710                	sd	a2,8(a4)
ffffffffc02015a4:	f11c                	sd	a5,32(a0)
ffffffffc02015a6:	ed18                	sd	a4,24(a0)
ffffffffc02015a8:	0141                	addi	sp,sp,16
ffffffffc02015aa:	8082                	ret
ffffffffc02015ac:	e790                	sd	a2,8(a5)
ffffffffc02015ae:	f114                	sd	a3,32(a0)
ffffffffc02015b0:	6798                	ld	a4,8(a5)
ffffffffc02015b2:	ed1c                	sd	a5,24(a0)
ffffffffc02015b4:	8832                	mv	a6,a2
ffffffffc02015b6:	00d70e63          	beq	a4,a3,ffffffffc02015d2 <default_init_memmap+0xa8>
ffffffffc02015ba:	4585                	li	a1,1
ffffffffc02015bc:	87ba                	mv	a5,a4
ffffffffc02015be:	bfc1                	j	ffffffffc020158e <default_init_memmap+0x64>
ffffffffc02015c0:	60a2                	ld	ra,8(sp)
ffffffffc02015c2:	01850713          	addi	a4,a0,24
ffffffffc02015c6:	e398                	sd	a4,0(a5)
ffffffffc02015c8:	e798                	sd	a4,8(a5)
ffffffffc02015ca:	f11c                	sd	a5,32(a0)
ffffffffc02015cc:	ed1c                	sd	a5,24(a0)
ffffffffc02015ce:	0141                	addi	sp,sp,16
ffffffffc02015d0:	8082                	ret
ffffffffc02015d2:	60a2                	ld	ra,8(sp)
ffffffffc02015d4:	e290                	sd	a2,0(a3)
ffffffffc02015d6:	0141                	addi	sp,sp,16
ffffffffc02015d8:	8082                	ret
ffffffffc02015da:	00004697          	auipc	a3,0x4
ffffffffc02015de:	20668693          	addi	a3,a3,518 # ffffffffc02057e0 <commands+0xac0>
ffffffffc02015e2:	00004617          	auipc	a2,0x4
ffffffffc02015e6:	e7660613          	addi	a2,a2,-394 # ffffffffc0205458 <commands+0x738>
ffffffffc02015ea:	04900593          	li	a1,73
ffffffffc02015ee:	00004517          	auipc	a0,0x4
ffffffffc02015f2:	e8250513          	addi	a0,a0,-382 # ffffffffc0205470 <commands+0x750>
ffffffffc02015f6:	e49fe0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02015fa:	00004697          	auipc	a3,0x4
ffffffffc02015fe:	1b668693          	addi	a3,a3,438 # ffffffffc02057b0 <commands+0xa90>
ffffffffc0201602:	00004617          	auipc	a2,0x4
ffffffffc0201606:	e5660613          	addi	a2,a2,-426 # ffffffffc0205458 <commands+0x738>
ffffffffc020160a:	04600593          	li	a1,70
ffffffffc020160e:	00004517          	auipc	a0,0x4
ffffffffc0201612:	e6250513          	addi	a0,a0,-414 # ffffffffc0205470 <commands+0x750>
ffffffffc0201616:	e29fe0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc020161a <slob_free>:
ffffffffc020161a:	c955                	beqz	a0,ffffffffc02016ce <slob_free+0xb4>
ffffffffc020161c:	1141                	addi	sp,sp,-16
ffffffffc020161e:	e022                	sd	s0,0(sp)
ffffffffc0201620:	e406                	sd	ra,8(sp)
ffffffffc0201622:	842a                	mv	s0,a0
ffffffffc0201624:	e9c9                	bnez	a1,ffffffffc02016b6 <slob_free+0x9c>
ffffffffc0201626:	100027f3          	csrr	a5,sstatus
ffffffffc020162a:	8b89                	andi	a5,a5,2
ffffffffc020162c:	4501                	li	a0,0
ffffffffc020162e:	efc1                	bnez	a5,ffffffffc02016c6 <slob_free+0xac>
ffffffffc0201630:	00009617          	auipc	a2,0x9
ffffffffc0201634:	a2060613          	addi	a2,a2,-1504 # ffffffffc020a050 <slobfree>
ffffffffc0201638:	621c                	ld	a5,0(a2)
ffffffffc020163a:	873e                	mv	a4,a5
ffffffffc020163c:	679c                	ld	a5,8(a5)
ffffffffc020163e:	02877a63          	bgeu	a4,s0,ffffffffc0201672 <slob_free+0x58>
ffffffffc0201642:	00f46463          	bltu	s0,a5,ffffffffc020164a <slob_free+0x30>
ffffffffc0201646:	fef76ae3          	bltu	a4,a5,ffffffffc020163a <slob_free+0x20>
ffffffffc020164a:	400c                	lw	a1,0(s0)
ffffffffc020164c:	00459693          	slli	a3,a1,0x4
ffffffffc0201650:	96a2                	add	a3,a3,s0
ffffffffc0201652:	02d78a63          	beq	a5,a3,ffffffffc0201686 <slob_free+0x6c>
ffffffffc0201656:	430c                	lw	a1,0(a4)
ffffffffc0201658:	e41c                	sd	a5,8(s0)
ffffffffc020165a:	00459693          	slli	a3,a1,0x4
ffffffffc020165e:	96ba                	add	a3,a3,a4
ffffffffc0201660:	02d40e63          	beq	s0,a3,ffffffffc020169c <slob_free+0x82>
ffffffffc0201664:	e700                	sd	s0,8(a4)
ffffffffc0201666:	e218                	sd	a4,0(a2)
ffffffffc0201668:	e131                	bnez	a0,ffffffffc02016ac <slob_free+0x92>
ffffffffc020166a:	60a2                	ld	ra,8(sp)
ffffffffc020166c:	6402                	ld	s0,0(sp)
ffffffffc020166e:	0141                	addi	sp,sp,16
ffffffffc0201670:	8082                	ret
ffffffffc0201672:	fcf764e3          	bltu	a4,a5,ffffffffc020163a <slob_free+0x20>
ffffffffc0201676:	fcf472e3          	bgeu	s0,a5,ffffffffc020163a <slob_free+0x20>
ffffffffc020167a:	400c                	lw	a1,0(s0)
ffffffffc020167c:	00459693          	slli	a3,a1,0x4
ffffffffc0201680:	96a2                	add	a3,a3,s0
ffffffffc0201682:	fcd79ae3          	bne	a5,a3,ffffffffc0201656 <slob_free+0x3c>
ffffffffc0201686:	4394                	lw	a3,0(a5)
ffffffffc0201688:	679c                	ld	a5,8(a5)
ffffffffc020168a:	9ead                	addw	a3,a3,a1
ffffffffc020168c:	c014                	sw	a3,0(s0)
ffffffffc020168e:	430c                	lw	a1,0(a4)
ffffffffc0201690:	e41c                	sd	a5,8(s0)
ffffffffc0201692:	00459693          	slli	a3,a1,0x4
ffffffffc0201696:	96ba                	add	a3,a3,a4
ffffffffc0201698:	fcd416e3          	bne	s0,a3,ffffffffc0201664 <slob_free+0x4a>
ffffffffc020169c:	4014                	lw	a3,0(s0)
ffffffffc020169e:	843e                	mv	s0,a5
ffffffffc02016a0:	e700                	sd	s0,8(a4)
ffffffffc02016a2:	00b687bb          	addw	a5,a3,a1
ffffffffc02016a6:	c31c                	sw	a5,0(a4)
ffffffffc02016a8:	e218                	sd	a4,0(a2)
ffffffffc02016aa:	d161                	beqz	a0,ffffffffc020166a <slob_free+0x50>
ffffffffc02016ac:	6402                	ld	s0,0(sp)
ffffffffc02016ae:	60a2                	ld	ra,8(sp)
ffffffffc02016b0:	0141                	addi	sp,sp,16
ffffffffc02016b2:	f03fe06f          	j	ffffffffc02005b4 <intr_enable>
ffffffffc02016b6:	25bd                	addiw	a1,a1,15
ffffffffc02016b8:	8191                	srli	a1,a1,0x4
ffffffffc02016ba:	c10c                	sw	a1,0(a0)
ffffffffc02016bc:	100027f3          	csrr	a5,sstatus
ffffffffc02016c0:	8b89                	andi	a5,a5,2
ffffffffc02016c2:	4501                	li	a0,0
ffffffffc02016c4:	d7b5                	beqz	a5,ffffffffc0201630 <slob_free+0x16>
ffffffffc02016c6:	ef5fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc02016ca:	4505                	li	a0,1
ffffffffc02016cc:	b795                	j	ffffffffc0201630 <slob_free+0x16>
ffffffffc02016ce:	8082                	ret

ffffffffc02016d0 <__slob_get_free_pages.constprop.0>:
ffffffffc02016d0:	4785                	li	a5,1
ffffffffc02016d2:	1141                	addi	sp,sp,-16
ffffffffc02016d4:	00a7953b          	sllw	a0,a5,a0
ffffffffc02016d8:	e406                	sd	ra,8(sp)
ffffffffc02016da:	33e000ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc02016de:	c91d                	beqz	a0,ffffffffc0201714 <__slob_get_free_pages.constprop.0+0x44>
ffffffffc02016e0:	00014797          	auipc	a5,0x14
ffffffffc02016e4:	e987b783          	ld	a5,-360(a5) # ffffffffc0215578 <pages>
ffffffffc02016e8:	8d1d                	sub	a0,a0,a5
ffffffffc02016ea:	8519                	srai	a0,a0,0x6
ffffffffc02016ec:	00005797          	auipc	a5,0x5
ffffffffc02016f0:	4847b783          	ld	a5,1156(a5) # ffffffffc0206b70 <nbase>
ffffffffc02016f4:	953e                	add	a0,a0,a5
ffffffffc02016f6:	00c51793          	slli	a5,a0,0xc
ffffffffc02016fa:	83b1                	srli	a5,a5,0xc
ffffffffc02016fc:	00014717          	auipc	a4,0x14
ffffffffc0201700:	e7473703          	ld	a4,-396(a4) # ffffffffc0215570 <npage>
ffffffffc0201704:	0532                	slli	a0,a0,0xc
ffffffffc0201706:	00e7fa63          	bgeu	a5,a4,ffffffffc020171a <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc020170a:	00014797          	auipc	a5,0x14
ffffffffc020170e:	e5e7b783          	ld	a5,-418(a5) # ffffffffc0215568 <va_pa_offset>
ffffffffc0201712:	953e                	add	a0,a0,a5
ffffffffc0201714:	60a2                	ld	ra,8(sp)
ffffffffc0201716:	0141                	addi	sp,sp,16
ffffffffc0201718:	8082                	ret
ffffffffc020171a:	86aa                	mv	a3,a0
ffffffffc020171c:	00004617          	auipc	a2,0x4
ffffffffc0201720:	12460613          	addi	a2,a2,292 # ffffffffc0205840 <default_pmm_manager+0x38>
ffffffffc0201724:	08b00593          	li	a1,139
ffffffffc0201728:	00004517          	auipc	a0,0x4
ffffffffc020172c:	14050513          	addi	a0,a0,320 # ffffffffc0205868 <default_pmm_manager+0x60>
ffffffffc0201730:	d0ffe0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0201734 <slob_alloc.constprop.0>:
ffffffffc0201734:	1101                	addi	sp,sp,-32
ffffffffc0201736:	ec06                	sd	ra,24(sp)
ffffffffc0201738:	e822                	sd	s0,16(sp)
ffffffffc020173a:	e426                	sd	s1,8(sp)
ffffffffc020173c:	e04a                	sd	s2,0(sp)
ffffffffc020173e:	01050713          	addi	a4,a0,16
ffffffffc0201742:	6785                	lui	a5,0x1
ffffffffc0201744:	0cf77363          	bgeu	a4,a5,ffffffffc020180a <slob_alloc.constprop.0+0xd6>
ffffffffc0201748:	00f50493          	addi	s1,a0,15
ffffffffc020174c:	8091                	srli	s1,s1,0x4
ffffffffc020174e:	2481                	sext.w	s1,s1
ffffffffc0201750:	10002673          	csrr	a2,sstatus
ffffffffc0201754:	8a09                	andi	a2,a2,2
ffffffffc0201756:	e25d                	bnez	a2,ffffffffc02017fc <slob_alloc.constprop.0+0xc8>
ffffffffc0201758:	00009917          	auipc	s2,0x9
ffffffffc020175c:	8f890913          	addi	s2,s2,-1800 # ffffffffc020a050 <slobfree>
ffffffffc0201760:	00093683          	ld	a3,0(s2)
ffffffffc0201764:	669c                	ld	a5,8(a3)
ffffffffc0201766:	4398                	lw	a4,0(a5)
ffffffffc0201768:	08975e63          	bge	a4,s1,ffffffffc0201804 <slob_alloc.constprop.0+0xd0>
ffffffffc020176c:	00d78b63          	beq	a5,a3,ffffffffc0201782 <slob_alloc.constprop.0+0x4e>
ffffffffc0201770:	6780                	ld	s0,8(a5)
ffffffffc0201772:	4018                	lw	a4,0(s0)
ffffffffc0201774:	02975a63          	bge	a4,s1,ffffffffc02017a8 <slob_alloc.constprop.0+0x74>
ffffffffc0201778:	00093683          	ld	a3,0(s2)
ffffffffc020177c:	87a2                	mv	a5,s0
ffffffffc020177e:	fed799e3          	bne	a5,a3,ffffffffc0201770 <slob_alloc.constprop.0+0x3c>
ffffffffc0201782:	ee31                	bnez	a2,ffffffffc02017de <slob_alloc.constprop.0+0xaa>
ffffffffc0201784:	4501                	li	a0,0
ffffffffc0201786:	f4bff0ef          	jal	ra,ffffffffc02016d0 <__slob_get_free_pages.constprop.0>
ffffffffc020178a:	842a                	mv	s0,a0
ffffffffc020178c:	cd05                	beqz	a0,ffffffffc02017c4 <slob_alloc.constprop.0+0x90>
ffffffffc020178e:	6585                	lui	a1,0x1
ffffffffc0201790:	e8bff0ef          	jal	ra,ffffffffc020161a <slob_free>
ffffffffc0201794:	10002673          	csrr	a2,sstatus
ffffffffc0201798:	8a09                	andi	a2,a2,2
ffffffffc020179a:	ee05                	bnez	a2,ffffffffc02017d2 <slob_alloc.constprop.0+0x9e>
ffffffffc020179c:	00093783          	ld	a5,0(s2)
ffffffffc02017a0:	6780                	ld	s0,8(a5)
ffffffffc02017a2:	4018                	lw	a4,0(s0)
ffffffffc02017a4:	fc974ae3          	blt	a4,s1,ffffffffc0201778 <slob_alloc.constprop.0+0x44>
ffffffffc02017a8:	04e48763          	beq	s1,a4,ffffffffc02017f6 <slob_alloc.constprop.0+0xc2>
ffffffffc02017ac:	00449693          	slli	a3,s1,0x4
ffffffffc02017b0:	96a2                	add	a3,a3,s0
ffffffffc02017b2:	e794                	sd	a3,8(a5)
ffffffffc02017b4:	640c                	ld	a1,8(s0)
ffffffffc02017b6:	9f05                	subw	a4,a4,s1
ffffffffc02017b8:	c298                	sw	a4,0(a3)
ffffffffc02017ba:	e68c                	sd	a1,8(a3)
ffffffffc02017bc:	c004                	sw	s1,0(s0)
ffffffffc02017be:	00f93023          	sd	a5,0(s2)
ffffffffc02017c2:	e20d                	bnez	a2,ffffffffc02017e4 <slob_alloc.constprop.0+0xb0>
ffffffffc02017c4:	60e2                	ld	ra,24(sp)
ffffffffc02017c6:	8522                	mv	a0,s0
ffffffffc02017c8:	6442                	ld	s0,16(sp)
ffffffffc02017ca:	64a2                	ld	s1,8(sp)
ffffffffc02017cc:	6902                	ld	s2,0(sp)
ffffffffc02017ce:	6105                	addi	sp,sp,32
ffffffffc02017d0:	8082                	ret
ffffffffc02017d2:	de9fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc02017d6:	00093783          	ld	a5,0(s2)
ffffffffc02017da:	4605                	li	a2,1
ffffffffc02017dc:	b7d1                	j	ffffffffc02017a0 <slob_alloc.constprop.0+0x6c>
ffffffffc02017de:	dd7fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc02017e2:	b74d                	j	ffffffffc0201784 <slob_alloc.constprop.0+0x50>
ffffffffc02017e4:	dd1fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc02017e8:	60e2                	ld	ra,24(sp)
ffffffffc02017ea:	8522                	mv	a0,s0
ffffffffc02017ec:	6442                	ld	s0,16(sp)
ffffffffc02017ee:	64a2                	ld	s1,8(sp)
ffffffffc02017f0:	6902                	ld	s2,0(sp)
ffffffffc02017f2:	6105                	addi	sp,sp,32
ffffffffc02017f4:	8082                	ret
ffffffffc02017f6:	6418                	ld	a4,8(s0)
ffffffffc02017f8:	e798                	sd	a4,8(a5)
ffffffffc02017fa:	b7d1                	j	ffffffffc02017be <slob_alloc.constprop.0+0x8a>
ffffffffc02017fc:	dbffe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0201800:	4605                	li	a2,1
ffffffffc0201802:	bf99                	j	ffffffffc0201758 <slob_alloc.constprop.0+0x24>
ffffffffc0201804:	843e                	mv	s0,a5
ffffffffc0201806:	87b6                	mv	a5,a3
ffffffffc0201808:	b745                	j	ffffffffc02017a8 <slob_alloc.constprop.0+0x74>
ffffffffc020180a:	00004697          	auipc	a3,0x4
ffffffffc020180e:	06e68693          	addi	a3,a3,110 # ffffffffc0205878 <default_pmm_manager+0x70>
ffffffffc0201812:	00004617          	auipc	a2,0x4
ffffffffc0201816:	c4660613          	addi	a2,a2,-954 # ffffffffc0205458 <commands+0x738>
ffffffffc020181a:	06300593          	li	a1,99
ffffffffc020181e:	00004517          	auipc	a0,0x4
ffffffffc0201822:	07a50513          	addi	a0,a0,122 # ffffffffc0205898 <default_pmm_manager+0x90>
ffffffffc0201826:	c19fe0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc020182a <kmalloc_init>:
ffffffffc020182a:	1141                	addi	sp,sp,-16
ffffffffc020182c:	00004517          	auipc	a0,0x4
ffffffffc0201830:	08450513          	addi	a0,a0,132 # ffffffffc02058b0 <default_pmm_manager+0xa8>
ffffffffc0201834:	e406                	sd	ra,8(sp)
ffffffffc0201836:	955fe0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020183a:	60a2                	ld	ra,8(sp)
ffffffffc020183c:	00004517          	auipc	a0,0x4
ffffffffc0201840:	08c50513          	addi	a0,a0,140 # ffffffffc02058c8 <default_pmm_manager+0xc0>
ffffffffc0201844:	0141                	addi	sp,sp,16
ffffffffc0201846:	945fe06f          	j	ffffffffc020018a <cprintf>

ffffffffc020184a <kmalloc>:
ffffffffc020184a:	1101                	addi	sp,sp,-32
ffffffffc020184c:	e04a                	sd	s2,0(sp)
ffffffffc020184e:	6905                	lui	s2,0x1
ffffffffc0201850:	e822                	sd	s0,16(sp)
ffffffffc0201852:	ec06                	sd	ra,24(sp)
ffffffffc0201854:	e426                	sd	s1,8(sp)
ffffffffc0201856:	fef90793          	addi	a5,s2,-17 # fef <kern_entry-0xffffffffc01ff011>
ffffffffc020185a:	842a                	mv	s0,a0
ffffffffc020185c:	04a7f763          	bgeu	a5,a0,ffffffffc02018aa <kmalloc+0x60>
ffffffffc0201860:	4561                	li	a0,24
ffffffffc0201862:	ed3ff0ef          	jal	ra,ffffffffc0201734 <slob_alloc.constprop.0>
ffffffffc0201866:	84aa                	mv	s1,a0
ffffffffc0201868:	c539                	beqz	a0,ffffffffc02018b6 <kmalloc+0x6c>
ffffffffc020186a:	0004079b          	sext.w	a5,s0
ffffffffc020186e:	4501                	li	a0,0
ffffffffc0201870:	00f95763          	bge	s2,a5,ffffffffc020187e <kmalloc+0x34>
ffffffffc0201874:	6705                	lui	a4,0x1
ffffffffc0201876:	8785                	srai	a5,a5,0x1
ffffffffc0201878:	2505                	addiw	a0,a0,1
ffffffffc020187a:	fef74ee3          	blt	a4,a5,ffffffffc0201876 <kmalloc+0x2c>
ffffffffc020187e:	c088                	sw	a0,0(s1)
ffffffffc0201880:	e51ff0ef          	jal	ra,ffffffffc02016d0 <__slob_get_free_pages.constprop.0>
ffffffffc0201884:	e488                	sd	a0,8(s1)
ffffffffc0201886:	cd21                	beqz	a0,ffffffffc02018de <kmalloc+0x94>
ffffffffc0201888:	100027f3          	csrr	a5,sstatus
ffffffffc020188c:	8b89                	andi	a5,a5,2
ffffffffc020188e:	e795                	bnez	a5,ffffffffc02018ba <kmalloc+0x70>
ffffffffc0201890:	00014797          	auipc	a5,0x14
ffffffffc0201894:	cb878793          	addi	a5,a5,-840 # ffffffffc0215548 <bigblocks>
ffffffffc0201898:	6398                	ld	a4,0(a5)
ffffffffc020189a:	e384                	sd	s1,0(a5)
ffffffffc020189c:	e898                	sd	a4,16(s1)
ffffffffc020189e:	60e2                	ld	ra,24(sp)
ffffffffc02018a0:	6442                	ld	s0,16(sp)
ffffffffc02018a2:	64a2                	ld	s1,8(sp)
ffffffffc02018a4:	6902                	ld	s2,0(sp)
ffffffffc02018a6:	6105                	addi	sp,sp,32
ffffffffc02018a8:	8082                	ret
ffffffffc02018aa:	0541                	addi	a0,a0,16
ffffffffc02018ac:	e89ff0ef          	jal	ra,ffffffffc0201734 <slob_alloc.constprop.0>
ffffffffc02018b0:	87aa                	mv	a5,a0
ffffffffc02018b2:	0541                	addi	a0,a0,16
ffffffffc02018b4:	f7ed                	bnez	a5,ffffffffc020189e <kmalloc+0x54>
ffffffffc02018b6:	4501                	li	a0,0
ffffffffc02018b8:	b7dd                	j	ffffffffc020189e <kmalloc+0x54>
ffffffffc02018ba:	d01fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc02018be:	00014797          	auipc	a5,0x14
ffffffffc02018c2:	c8a78793          	addi	a5,a5,-886 # ffffffffc0215548 <bigblocks>
ffffffffc02018c6:	6398                	ld	a4,0(a5)
ffffffffc02018c8:	e384                	sd	s1,0(a5)
ffffffffc02018ca:	e898                	sd	a4,16(s1)
ffffffffc02018cc:	ce9fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc02018d0:	60e2                	ld	ra,24(sp)
ffffffffc02018d2:	6442                	ld	s0,16(sp)
ffffffffc02018d4:	6488                	ld	a0,8(s1)
ffffffffc02018d6:	6902                	ld	s2,0(sp)
ffffffffc02018d8:	64a2                	ld	s1,8(sp)
ffffffffc02018da:	6105                	addi	sp,sp,32
ffffffffc02018dc:	8082                	ret
ffffffffc02018de:	8526                	mv	a0,s1
ffffffffc02018e0:	45e1                	li	a1,24
ffffffffc02018e2:	d39ff0ef          	jal	ra,ffffffffc020161a <slob_free>
ffffffffc02018e6:	4501                	li	a0,0
ffffffffc02018e8:	bf5d                	j	ffffffffc020189e <kmalloc+0x54>

ffffffffc02018ea <kfree>:
ffffffffc02018ea:	c169                	beqz	a0,ffffffffc02019ac <kfree+0xc2>
ffffffffc02018ec:	1101                	addi	sp,sp,-32
ffffffffc02018ee:	e822                	sd	s0,16(sp)
ffffffffc02018f0:	ec06                	sd	ra,24(sp)
ffffffffc02018f2:	e426                	sd	s1,8(sp)
ffffffffc02018f4:	03451793          	slli	a5,a0,0x34
ffffffffc02018f8:	842a                	mv	s0,a0
ffffffffc02018fa:	e3d9                	bnez	a5,ffffffffc0201980 <kfree+0x96>
ffffffffc02018fc:	100027f3          	csrr	a5,sstatus
ffffffffc0201900:	8b89                	andi	a5,a5,2
ffffffffc0201902:	e7d9                	bnez	a5,ffffffffc0201990 <kfree+0xa6>
ffffffffc0201904:	00014797          	auipc	a5,0x14
ffffffffc0201908:	c447b783          	ld	a5,-956(a5) # ffffffffc0215548 <bigblocks>
ffffffffc020190c:	4601                	li	a2,0
ffffffffc020190e:	cbad                	beqz	a5,ffffffffc0201980 <kfree+0x96>
ffffffffc0201910:	00014697          	auipc	a3,0x14
ffffffffc0201914:	c3868693          	addi	a3,a3,-968 # ffffffffc0215548 <bigblocks>
ffffffffc0201918:	a021                	j	ffffffffc0201920 <kfree+0x36>
ffffffffc020191a:	01048693          	addi	a3,s1,16
ffffffffc020191e:	c3a5                	beqz	a5,ffffffffc020197e <kfree+0x94>
ffffffffc0201920:	6798                	ld	a4,8(a5)
ffffffffc0201922:	84be                	mv	s1,a5
ffffffffc0201924:	6b9c                	ld	a5,16(a5)
ffffffffc0201926:	fe871ae3          	bne	a4,s0,ffffffffc020191a <kfree+0x30>
ffffffffc020192a:	e29c                	sd	a5,0(a3)
ffffffffc020192c:	ee2d                	bnez	a2,ffffffffc02019a6 <kfree+0xbc>
ffffffffc020192e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201932:	4098                	lw	a4,0(s1)
ffffffffc0201934:	08f46963          	bltu	s0,a5,ffffffffc02019c6 <kfree+0xdc>
ffffffffc0201938:	00014797          	auipc	a5,0x14
ffffffffc020193c:	c307b783          	ld	a5,-976(a5) # ffffffffc0215568 <va_pa_offset>
ffffffffc0201940:	8c1d                	sub	s0,s0,a5
ffffffffc0201942:	8031                	srli	s0,s0,0xc
ffffffffc0201944:	00014797          	auipc	a5,0x14
ffffffffc0201948:	c2c7b783          	ld	a5,-980(a5) # ffffffffc0215570 <npage>
ffffffffc020194c:	06f47163          	bgeu	s0,a5,ffffffffc02019ae <kfree+0xc4>
ffffffffc0201950:	00005797          	auipc	a5,0x5
ffffffffc0201954:	2207b783          	ld	a5,544(a5) # ffffffffc0206b70 <nbase>
ffffffffc0201958:	8c1d                	sub	s0,s0,a5
ffffffffc020195a:	041a                	slli	s0,s0,0x6
ffffffffc020195c:	00014517          	auipc	a0,0x14
ffffffffc0201960:	c1c53503          	ld	a0,-996(a0) # ffffffffc0215578 <pages>
ffffffffc0201964:	4585                	li	a1,1
ffffffffc0201966:	9522                	add	a0,a0,s0
ffffffffc0201968:	00e595bb          	sllw	a1,a1,a4
ffffffffc020196c:	13c000ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0201970:	6442                	ld	s0,16(sp)
ffffffffc0201972:	60e2                	ld	ra,24(sp)
ffffffffc0201974:	8526                	mv	a0,s1
ffffffffc0201976:	64a2                	ld	s1,8(sp)
ffffffffc0201978:	45e1                	li	a1,24
ffffffffc020197a:	6105                	addi	sp,sp,32
ffffffffc020197c:	b979                	j	ffffffffc020161a <slob_free>
ffffffffc020197e:	e20d                	bnez	a2,ffffffffc02019a0 <kfree+0xb6>
ffffffffc0201980:	ff040513          	addi	a0,s0,-16
ffffffffc0201984:	6442                	ld	s0,16(sp)
ffffffffc0201986:	60e2                	ld	ra,24(sp)
ffffffffc0201988:	64a2                	ld	s1,8(sp)
ffffffffc020198a:	4581                	li	a1,0
ffffffffc020198c:	6105                	addi	sp,sp,32
ffffffffc020198e:	b171                	j	ffffffffc020161a <slob_free>
ffffffffc0201990:	c2bfe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0201994:	00014797          	auipc	a5,0x14
ffffffffc0201998:	bb47b783          	ld	a5,-1100(a5) # ffffffffc0215548 <bigblocks>
ffffffffc020199c:	4605                	li	a2,1
ffffffffc020199e:	fbad                	bnez	a5,ffffffffc0201910 <kfree+0x26>
ffffffffc02019a0:	c15fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc02019a4:	bff1                	j	ffffffffc0201980 <kfree+0x96>
ffffffffc02019a6:	c0ffe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc02019aa:	b751                	j	ffffffffc020192e <kfree+0x44>
ffffffffc02019ac:	8082                	ret
ffffffffc02019ae:	00004617          	auipc	a2,0x4
ffffffffc02019b2:	f6260613          	addi	a2,a2,-158 # ffffffffc0205910 <default_pmm_manager+0x108>
ffffffffc02019b6:	08000593          	li	a1,128
ffffffffc02019ba:	00004517          	auipc	a0,0x4
ffffffffc02019be:	eae50513          	addi	a0,a0,-338 # ffffffffc0205868 <default_pmm_manager+0x60>
ffffffffc02019c2:	a7dfe0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02019c6:	86a2                	mv	a3,s0
ffffffffc02019c8:	00004617          	auipc	a2,0x4
ffffffffc02019cc:	f2060613          	addi	a2,a2,-224 # ffffffffc02058e8 <default_pmm_manager+0xe0>
ffffffffc02019d0:	09400593          	li	a1,148
ffffffffc02019d4:	00004517          	auipc	a0,0x4
ffffffffc02019d8:	e9450513          	addi	a0,a0,-364 # ffffffffc0205868 <default_pmm_manager+0x60>
ffffffffc02019dc:	a63fe0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc02019e0 <pa2page.part.0>:
ffffffffc02019e0:	1141                	addi	sp,sp,-16
ffffffffc02019e2:	00004617          	auipc	a2,0x4
ffffffffc02019e6:	f2e60613          	addi	a2,a2,-210 # ffffffffc0205910 <default_pmm_manager+0x108>
ffffffffc02019ea:	08000593          	li	a1,128
ffffffffc02019ee:	00004517          	auipc	a0,0x4
ffffffffc02019f2:	e7a50513          	addi	a0,a0,-390 # ffffffffc0205868 <default_pmm_manager+0x60>
ffffffffc02019f6:	e406                	sd	ra,8(sp)
ffffffffc02019f8:	a47fe0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc02019fc <pte2page.part.0>:
ffffffffc02019fc:	1141                	addi	sp,sp,-16
ffffffffc02019fe:	00004617          	auipc	a2,0x4
ffffffffc0201a02:	f3260613          	addi	a2,a2,-206 # ffffffffc0205930 <default_pmm_manager+0x128>
ffffffffc0201a06:	09f00593          	li	a1,159
ffffffffc0201a0a:	00004517          	auipc	a0,0x4
ffffffffc0201a0e:	e5e50513          	addi	a0,a0,-418 # ffffffffc0205868 <default_pmm_manager+0x60>
ffffffffc0201a12:	e406                	sd	ra,8(sp)
ffffffffc0201a14:	a2bfe0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0201a18 <alloc_pages>:
ffffffffc0201a18:	7139                	addi	sp,sp,-64
ffffffffc0201a1a:	f426                	sd	s1,40(sp)
ffffffffc0201a1c:	f04a                	sd	s2,32(sp)
ffffffffc0201a1e:	ec4e                	sd	s3,24(sp)
ffffffffc0201a20:	e852                	sd	s4,16(sp)
ffffffffc0201a22:	e456                	sd	s5,8(sp)
ffffffffc0201a24:	e05a                	sd	s6,0(sp)
ffffffffc0201a26:	fc06                	sd	ra,56(sp)
ffffffffc0201a28:	f822                	sd	s0,48(sp)
ffffffffc0201a2a:	84aa                	mv	s1,a0
ffffffffc0201a2c:	00014917          	auipc	s2,0x14
ffffffffc0201a30:	b2490913          	addi	s2,s2,-1244 # ffffffffc0215550 <pmm_manager>
ffffffffc0201a34:	4a05                	li	s4,1
ffffffffc0201a36:	00014a97          	auipc	s5,0x14
ffffffffc0201a3a:	b4aa8a93          	addi	s5,s5,-1206 # ffffffffc0215580 <swap_init_ok>
ffffffffc0201a3e:	0005099b          	sext.w	s3,a0
ffffffffc0201a42:	00014b17          	auipc	s6,0x14
ffffffffc0201a46:	b5eb0b13          	addi	s6,s6,-1186 # ffffffffc02155a0 <check_mm_struct>
ffffffffc0201a4a:	a015                	j	ffffffffc0201a6e <alloc_pages+0x56>
ffffffffc0201a4c:	00093783          	ld	a5,0(s2)
ffffffffc0201a50:	6f9c                	ld	a5,24(a5)
ffffffffc0201a52:	9782                	jalr	a5
ffffffffc0201a54:	842a                	mv	s0,a0
ffffffffc0201a56:	4601                	li	a2,0
ffffffffc0201a58:	85ce                	mv	a1,s3
ffffffffc0201a5a:	ec05                	bnez	s0,ffffffffc0201a92 <alloc_pages+0x7a>
ffffffffc0201a5c:	029a6b63          	bltu	s4,s1,ffffffffc0201a92 <alloc_pages+0x7a>
ffffffffc0201a60:	000aa783          	lw	a5,0(s5)
ffffffffc0201a64:	c79d                	beqz	a5,ffffffffc0201a92 <alloc_pages+0x7a>
ffffffffc0201a66:	000b3503          	ld	a0,0(s6)
ffffffffc0201a6a:	035010ef          	jal	ra,ffffffffc020329e <swap_out>
ffffffffc0201a6e:	100027f3          	csrr	a5,sstatus
ffffffffc0201a72:	8b89                	andi	a5,a5,2
ffffffffc0201a74:	8526                	mv	a0,s1
ffffffffc0201a76:	dbf9                	beqz	a5,ffffffffc0201a4c <alloc_pages+0x34>
ffffffffc0201a78:	b43fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0201a7c:	00093783          	ld	a5,0(s2)
ffffffffc0201a80:	8526                	mv	a0,s1
ffffffffc0201a82:	6f9c                	ld	a5,24(a5)
ffffffffc0201a84:	9782                	jalr	a5
ffffffffc0201a86:	842a                	mv	s0,a0
ffffffffc0201a88:	b2dfe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0201a8c:	4601                	li	a2,0
ffffffffc0201a8e:	85ce                	mv	a1,s3
ffffffffc0201a90:	d471                	beqz	s0,ffffffffc0201a5c <alloc_pages+0x44>
ffffffffc0201a92:	70e2                	ld	ra,56(sp)
ffffffffc0201a94:	8522                	mv	a0,s0
ffffffffc0201a96:	7442                	ld	s0,48(sp)
ffffffffc0201a98:	74a2                	ld	s1,40(sp)
ffffffffc0201a9a:	7902                	ld	s2,32(sp)
ffffffffc0201a9c:	69e2                	ld	s3,24(sp)
ffffffffc0201a9e:	6a42                	ld	s4,16(sp)
ffffffffc0201aa0:	6aa2                	ld	s5,8(sp)
ffffffffc0201aa2:	6b02                	ld	s6,0(sp)
ffffffffc0201aa4:	6121                	addi	sp,sp,64
ffffffffc0201aa6:	8082                	ret

ffffffffc0201aa8 <free_pages>:
ffffffffc0201aa8:	100027f3          	csrr	a5,sstatus
ffffffffc0201aac:	8b89                	andi	a5,a5,2
ffffffffc0201aae:	e799                	bnez	a5,ffffffffc0201abc <free_pages+0x14>
ffffffffc0201ab0:	00014797          	auipc	a5,0x14
ffffffffc0201ab4:	aa07b783          	ld	a5,-1376(a5) # ffffffffc0215550 <pmm_manager>
ffffffffc0201ab8:	739c                	ld	a5,32(a5)
ffffffffc0201aba:	8782                	jr	a5
ffffffffc0201abc:	1101                	addi	sp,sp,-32
ffffffffc0201abe:	ec06                	sd	ra,24(sp)
ffffffffc0201ac0:	e822                	sd	s0,16(sp)
ffffffffc0201ac2:	e426                	sd	s1,8(sp)
ffffffffc0201ac4:	842a                	mv	s0,a0
ffffffffc0201ac6:	84ae                	mv	s1,a1
ffffffffc0201ac8:	af3fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0201acc:	00014797          	auipc	a5,0x14
ffffffffc0201ad0:	a847b783          	ld	a5,-1404(a5) # ffffffffc0215550 <pmm_manager>
ffffffffc0201ad4:	739c                	ld	a5,32(a5)
ffffffffc0201ad6:	85a6                	mv	a1,s1
ffffffffc0201ad8:	8522                	mv	a0,s0
ffffffffc0201ada:	9782                	jalr	a5
ffffffffc0201adc:	6442                	ld	s0,16(sp)
ffffffffc0201ade:	60e2                	ld	ra,24(sp)
ffffffffc0201ae0:	64a2                	ld	s1,8(sp)
ffffffffc0201ae2:	6105                	addi	sp,sp,32
ffffffffc0201ae4:	ad1fe06f          	j	ffffffffc02005b4 <intr_enable>

ffffffffc0201ae8 <nr_free_pages>:
ffffffffc0201ae8:	100027f3          	csrr	a5,sstatus
ffffffffc0201aec:	8b89                	andi	a5,a5,2
ffffffffc0201aee:	e799                	bnez	a5,ffffffffc0201afc <nr_free_pages+0x14>
ffffffffc0201af0:	00014797          	auipc	a5,0x14
ffffffffc0201af4:	a607b783          	ld	a5,-1440(a5) # ffffffffc0215550 <pmm_manager>
ffffffffc0201af8:	779c                	ld	a5,40(a5)
ffffffffc0201afa:	8782                	jr	a5
ffffffffc0201afc:	1141                	addi	sp,sp,-16
ffffffffc0201afe:	e406                	sd	ra,8(sp)
ffffffffc0201b00:	e022                	sd	s0,0(sp)
ffffffffc0201b02:	ab9fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0201b06:	00014797          	auipc	a5,0x14
ffffffffc0201b0a:	a4a7b783          	ld	a5,-1462(a5) # ffffffffc0215550 <pmm_manager>
ffffffffc0201b0e:	779c                	ld	a5,40(a5)
ffffffffc0201b10:	9782                	jalr	a5
ffffffffc0201b12:	842a                	mv	s0,a0
ffffffffc0201b14:	aa1fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0201b18:	60a2                	ld	ra,8(sp)
ffffffffc0201b1a:	8522                	mv	a0,s0
ffffffffc0201b1c:	6402                	ld	s0,0(sp)
ffffffffc0201b1e:	0141                	addi	sp,sp,16
ffffffffc0201b20:	8082                	ret

ffffffffc0201b22 <get_pte>:
ffffffffc0201b22:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201b26:	1ff7f793          	andi	a5,a5,511
ffffffffc0201b2a:	7139                	addi	sp,sp,-64
ffffffffc0201b2c:	078e                	slli	a5,a5,0x3
ffffffffc0201b2e:	f426                	sd	s1,40(sp)
ffffffffc0201b30:	00f504b3          	add	s1,a0,a5
ffffffffc0201b34:	6094                	ld	a3,0(s1)
ffffffffc0201b36:	f04a                	sd	s2,32(sp)
ffffffffc0201b38:	ec4e                	sd	s3,24(sp)
ffffffffc0201b3a:	e852                	sd	s4,16(sp)
ffffffffc0201b3c:	fc06                	sd	ra,56(sp)
ffffffffc0201b3e:	f822                	sd	s0,48(sp)
ffffffffc0201b40:	e456                	sd	s5,8(sp)
ffffffffc0201b42:	e05a                	sd	s6,0(sp)
ffffffffc0201b44:	0016f793          	andi	a5,a3,1
ffffffffc0201b48:	892e                	mv	s2,a1
ffffffffc0201b4a:	89b2                	mv	s3,a2
ffffffffc0201b4c:	00014a17          	auipc	s4,0x14
ffffffffc0201b50:	a24a0a13          	addi	s4,s4,-1500 # ffffffffc0215570 <npage>
ffffffffc0201b54:	e7b5                	bnez	a5,ffffffffc0201bc0 <get_pte+0x9e>
ffffffffc0201b56:	12060b63          	beqz	a2,ffffffffc0201c8c <get_pte+0x16a>
ffffffffc0201b5a:	4505                	li	a0,1
ffffffffc0201b5c:	ebdff0ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0201b60:	842a                	mv	s0,a0
ffffffffc0201b62:	12050563          	beqz	a0,ffffffffc0201c8c <get_pte+0x16a>
ffffffffc0201b66:	00014b17          	auipc	s6,0x14
ffffffffc0201b6a:	a12b0b13          	addi	s6,s6,-1518 # ffffffffc0215578 <pages>
ffffffffc0201b6e:	000b3503          	ld	a0,0(s6)
ffffffffc0201b72:	00080ab7          	lui	s5,0x80
ffffffffc0201b76:	00014a17          	auipc	s4,0x14
ffffffffc0201b7a:	9faa0a13          	addi	s4,s4,-1542 # ffffffffc0215570 <npage>
ffffffffc0201b7e:	40a40533          	sub	a0,s0,a0
ffffffffc0201b82:	8519                	srai	a0,a0,0x6
ffffffffc0201b84:	9556                	add	a0,a0,s5
ffffffffc0201b86:	000a3703          	ld	a4,0(s4)
ffffffffc0201b8a:	00c51793          	slli	a5,a0,0xc
ffffffffc0201b8e:	4685                	li	a3,1
ffffffffc0201b90:	c014                	sw	a3,0(s0)
ffffffffc0201b92:	83b1                	srli	a5,a5,0xc
ffffffffc0201b94:	0532                	slli	a0,a0,0xc
ffffffffc0201b96:	14e7f163          	bgeu	a5,a4,ffffffffc0201cd8 <get_pte+0x1b6>
ffffffffc0201b9a:	00014797          	auipc	a5,0x14
ffffffffc0201b9e:	9ce7b783          	ld	a5,-1586(a5) # ffffffffc0215568 <va_pa_offset>
ffffffffc0201ba2:	953e                	add	a0,a0,a5
ffffffffc0201ba4:	6605                	lui	a2,0x1
ffffffffc0201ba6:	4581                	li	a1,0
ffffffffc0201ba8:	6c3020ef          	jal	ra,ffffffffc0204a6a <memset>
ffffffffc0201bac:	000b3783          	ld	a5,0(s6)
ffffffffc0201bb0:	40f406b3          	sub	a3,s0,a5
ffffffffc0201bb4:	8699                	srai	a3,a3,0x6
ffffffffc0201bb6:	96d6                	add	a3,a3,s5
ffffffffc0201bb8:	06aa                	slli	a3,a3,0xa
ffffffffc0201bba:	0116e693          	ori	a3,a3,17
ffffffffc0201bbe:	e094                	sd	a3,0(s1)
ffffffffc0201bc0:	77fd                	lui	a5,0xfffff
ffffffffc0201bc2:	068a                	slli	a3,a3,0x2
ffffffffc0201bc4:	000a3703          	ld	a4,0(s4)
ffffffffc0201bc8:	8efd                	and	a3,a3,a5
ffffffffc0201bca:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201bce:	0ce7f163          	bgeu	a5,a4,ffffffffc0201c90 <get_pte+0x16e>
ffffffffc0201bd2:	00014a97          	auipc	s5,0x14
ffffffffc0201bd6:	996a8a93          	addi	s5,s5,-1642 # ffffffffc0215568 <va_pa_offset>
ffffffffc0201bda:	000ab603          	ld	a2,0(s5)
ffffffffc0201bde:	01595793          	srli	a5,s2,0x15
ffffffffc0201be2:	1ff7f793          	andi	a5,a5,511
ffffffffc0201be6:	96b2                	add	a3,a3,a2
ffffffffc0201be8:	078e                	slli	a5,a5,0x3
ffffffffc0201bea:	00f68433          	add	s0,a3,a5
ffffffffc0201bee:	6014                	ld	a3,0(s0)
ffffffffc0201bf0:	0016f793          	andi	a5,a3,1
ffffffffc0201bf4:	e3ad                	bnez	a5,ffffffffc0201c56 <get_pte+0x134>
ffffffffc0201bf6:	08098b63          	beqz	s3,ffffffffc0201c8c <get_pte+0x16a>
ffffffffc0201bfa:	4505                	li	a0,1
ffffffffc0201bfc:	e1dff0ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0201c00:	84aa                	mv	s1,a0
ffffffffc0201c02:	c549                	beqz	a0,ffffffffc0201c8c <get_pte+0x16a>
ffffffffc0201c04:	00014b17          	auipc	s6,0x14
ffffffffc0201c08:	974b0b13          	addi	s6,s6,-1676 # ffffffffc0215578 <pages>
ffffffffc0201c0c:	000b3683          	ld	a3,0(s6)
ffffffffc0201c10:	000809b7          	lui	s3,0x80
ffffffffc0201c14:	000a3703          	ld	a4,0(s4)
ffffffffc0201c18:	40d506b3          	sub	a3,a0,a3
ffffffffc0201c1c:	8699                	srai	a3,a3,0x6
ffffffffc0201c1e:	96ce                	add	a3,a3,s3
ffffffffc0201c20:	00c69793          	slli	a5,a3,0xc
ffffffffc0201c24:	4605                	li	a2,1
ffffffffc0201c26:	c110                	sw	a2,0(a0)
ffffffffc0201c28:	83b1                	srli	a5,a5,0xc
ffffffffc0201c2a:	06b2                	slli	a3,a3,0xc
ffffffffc0201c2c:	08e7fa63          	bgeu	a5,a4,ffffffffc0201cc0 <get_pte+0x19e>
ffffffffc0201c30:	000ab503          	ld	a0,0(s5)
ffffffffc0201c34:	6605                	lui	a2,0x1
ffffffffc0201c36:	4581                	li	a1,0
ffffffffc0201c38:	9536                	add	a0,a0,a3
ffffffffc0201c3a:	631020ef          	jal	ra,ffffffffc0204a6a <memset>
ffffffffc0201c3e:	000b3783          	ld	a5,0(s6)
ffffffffc0201c42:	40f486b3          	sub	a3,s1,a5
ffffffffc0201c46:	8699                	srai	a3,a3,0x6
ffffffffc0201c48:	96ce                	add	a3,a3,s3
ffffffffc0201c4a:	06aa                	slli	a3,a3,0xa
ffffffffc0201c4c:	0116e693          	ori	a3,a3,17
ffffffffc0201c50:	e014                	sd	a3,0(s0)
ffffffffc0201c52:	000a3703          	ld	a4,0(s4)
ffffffffc0201c56:	77fd                	lui	a5,0xfffff
ffffffffc0201c58:	068a                	slli	a3,a3,0x2
ffffffffc0201c5a:	8efd                	and	a3,a3,a5
ffffffffc0201c5c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201c60:	04e7f463          	bgeu	a5,a4,ffffffffc0201ca8 <get_pte+0x186>
ffffffffc0201c64:	000ab783          	ld	a5,0(s5)
ffffffffc0201c68:	00c95913          	srli	s2,s2,0xc
ffffffffc0201c6c:	1ff97913          	andi	s2,s2,511
ffffffffc0201c70:	96be                	add	a3,a3,a5
ffffffffc0201c72:	090e                	slli	s2,s2,0x3
ffffffffc0201c74:	01268533          	add	a0,a3,s2
ffffffffc0201c78:	70e2                	ld	ra,56(sp)
ffffffffc0201c7a:	7442                	ld	s0,48(sp)
ffffffffc0201c7c:	74a2                	ld	s1,40(sp)
ffffffffc0201c7e:	7902                	ld	s2,32(sp)
ffffffffc0201c80:	69e2                	ld	s3,24(sp)
ffffffffc0201c82:	6a42                	ld	s4,16(sp)
ffffffffc0201c84:	6aa2                	ld	s5,8(sp)
ffffffffc0201c86:	6b02                	ld	s6,0(sp)
ffffffffc0201c88:	6121                	addi	sp,sp,64
ffffffffc0201c8a:	8082                	ret
ffffffffc0201c8c:	4501                	li	a0,0
ffffffffc0201c8e:	b7ed                	j	ffffffffc0201c78 <get_pte+0x156>
ffffffffc0201c90:	00004617          	auipc	a2,0x4
ffffffffc0201c94:	bb060613          	addi	a2,a2,-1104 # ffffffffc0205840 <default_pmm_manager+0x38>
ffffffffc0201c98:	0f900593          	li	a1,249
ffffffffc0201c9c:	00004517          	auipc	a0,0x4
ffffffffc0201ca0:	cbc50513          	addi	a0,a0,-836 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0201ca4:	f9afe0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201ca8:	00004617          	auipc	a2,0x4
ffffffffc0201cac:	b9860613          	addi	a2,a2,-1128 # ffffffffc0205840 <default_pmm_manager+0x38>
ffffffffc0201cb0:	10900593          	li	a1,265
ffffffffc0201cb4:	00004517          	auipc	a0,0x4
ffffffffc0201cb8:	ca450513          	addi	a0,a0,-860 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0201cbc:	f82fe0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201cc0:	00004617          	auipc	a2,0x4
ffffffffc0201cc4:	b8060613          	addi	a2,a2,-1152 # ffffffffc0205840 <default_pmm_manager+0x38>
ffffffffc0201cc8:	10500593          	li	a1,261
ffffffffc0201ccc:	00004517          	auipc	a0,0x4
ffffffffc0201cd0:	c8c50513          	addi	a0,a0,-884 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0201cd4:	f6afe0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0201cd8:	86aa                	mv	a3,a0
ffffffffc0201cda:	00004617          	auipc	a2,0x4
ffffffffc0201cde:	b6660613          	addi	a2,a2,-1178 # ffffffffc0205840 <default_pmm_manager+0x38>
ffffffffc0201ce2:	0f100593          	li	a1,241
ffffffffc0201ce6:	00004517          	auipc	a0,0x4
ffffffffc0201cea:	c7250513          	addi	a0,a0,-910 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0201cee:	f50fe0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0201cf2 <get_page>:
ffffffffc0201cf2:	1141                	addi	sp,sp,-16
ffffffffc0201cf4:	e022                	sd	s0,0(sp)
ffffffffc0201cf6:	8432                	mv	s0,a2
ffffffffc0201cf8:	4601                	li	a2,0
ffffffffc0201cfa:	e406                	sd	ra,8(sp)
ffffffffc0201cfc:	e27ff0ef          	jal	ra,ffffffffc0201b22 <get_pte>
ffffffffc0201d00:	c011                	beqz	s0,ffffffffc0201d04 <get_page+0x12>
ffffffffc0201d02:	e008                	sd	a0,0(s0)
ffffffffc0201d04:	c511                	beqz	a0,ffffffffc0201d10 <get_page+0x1e>
ffffffffc0201d06:	611c                	ld	a5,0(a0)
ffffffffc0201d08:	4501                	li	a0,0
ffffffffc0201d0a:	0017f713          	andi	a4,a5,1
ffffffffc0201d0e:	e709                	bnez	a4,ffffffffc0201d18 <get_page+0x26>
ffffffffc0201d10:	60a2                	ld	ra,8(sp)
ffffffffc0201d12:	6402                	ld	s0,0(sp)
ffffffffc0201d14:	0141                	addi	sp,sp,16
ffffffffc0201d16:	8082                	ret
ffffffffc0201d18:	078a                	slli	a5,a5,0x2
ffffffffc0201d1a:	83b1                	srli	a5,a5,0xc
ffffffffc0201d1c:	00014717          	auipc	a4,0x14
ffffffffc0201d20:	85473703          	ld	a4,-1964(a4) # ffffffffc0215570 <npage>
ffffffffc0201d24:	00e7ff63          	bgeu	a5,a4,ffffffffc0201d42 <get_page+0x50>
ffffffffc0201d28:	60a2                	ld	ra,8(sp)
ffffffffc0201d2a:	6402                	ld	s0,0(sp)
ffffffffc0201d2c:	fff80737          	lui	a4,0xfff80
ffffffffc0201d30:	97ba                	add	a5,a5,a4
ffffffffc0201d32:	00014517          	auipc	a0,0x14
ffffffffc0201d36:	84653503          	ld	a0,-1978(a0) # ffffffffc0215578 <pages>
ffffffffc0201d3a:	079a                	slli	a5,a5,0x6
ffffffffc0201d3c:	953e                	add	a0,a0,a5
ffffffffc0201d3e:	0141                	addi	sp,sp,16
ffffffffc0201d40:	8082                	ret
ffffffffc0201d42:	c9fff0ef          	jal	ra,ffffffffc02019e0 <pa2page.part.0>

ffffffffc0201d46 <page_remove>:
ffffffffc0201d46:	7179                	addi	sp,sp,-48
ffffffffc0201d48:	4601                	li	a2,0
ffffffffc0201d4a:	ec26                	sd	s1,24(sp)
ffffffffc0201d4c:	f406                	sd	ra,40(sp)
ffffffffc0201d4e:	f022                	sd	s0,32(sp)
ffffffffc0201d50:	84ae                	mv	s1,a1
ffffffffc0201d52:	dd1ff0ef          	jal	ra,ffffffffc0201b22 <get_pte>
ffffffffc0201d56:	c511                	beqz	a0,ffffffffc0201d62 <page_remove+0x1c>
ffffffffc0201d58:	611c                	ld	a5,0(a0)
ffffffffc0201d5a:	842a                	mv	s0,a0
ffffffffc0201d5c:	0017f713          	andi	a4,a5,1
ffffffffc0201d60:	e711                	bnez	a4,ffffffffc0201d6c <page_remove+0x26>
ffffffffc0201d62:	70a2                	ld	ra,40(sp)
ffffffffc0201d64:	7402                	ld	s0,32(sp)
ffffffffc0201d66:	64e2                	ld	s1,24(sp)
ffffffffc0201d68:	6145                	addi	sp,sp,48
ffffffffc0201d6a:	8082                	ret
ffffffffc0201d6c:	078a                	slli	a5,a5,0x2
ffffffffc0201d6e:	83b1                	srli	a5,a5,0xc
ffffffffc0201d70:	00014717          	auipc	a4,0x14
ffffffffc0201d74:	80073703          	ld	a4,-2048(a4) # ffffffffc0215570 <npage>
ffffffffc0201d78:	06e7f363          	bgeu	a5,a4,ffffffffc0201dde <page_remove+0x98>
ffffffffc0201d7c:	fff80737          	lui	a4,0xfff80
ffffffffc0201d80:	97ba                	add	a5,a5,a4
ffffffffc0201d82:	079a                	slli	a5,a5,0x6
ffffffffc0201d84:	00013517          	auipc	a0,0x13
ffffffffc0201d88:	7f453503          	ld	a0,2036(a0) # ffffffffc0215578 <pages>
ffffffffc0201d8c:	953e                	add	a0,a0,a5
ffffffffc0201d8e:	411c                	lw	a5,0(a0)
ffffffffc0201d90:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201d94:	c118                	sw	a4,0(a0)
ffffffffc0201d96:	cb11                	beqz	a4,ffffffffc0201daa <page_remove+0x64>
ffffffffc0201d98:	00043023          	sd	zero,0(s0)
ffffffffc0201d9c:	12048073          	sfence.vma	s1
ffffffffc0201da0:	70a2                	ld	ra,40(sp)
ffffffffc0201da2:	7402                	ld	s0,32(sp)
ffffffffc0201da4:	64e2                	ld	s1,24(sp)
ffffffffc0201da6:	6145                	addi	sp,sp,48
ffffffffc0201da8:	8082                	ret
ffffffffc0201daa:	100027f3          	csrr	a5,sstatus
ffffffffc0201dae:	8b89                	andi	a5,a5,2
ffffffffc0201db0:	eb89                	bnez	a5,ffffffffc0201dc2 <page_remove+0x7c>
ffffffffc0201db2:	00013797          	auipc	a5,0x13
ffffffffc0201db6:	79e7b783          	ld	a5,1950(a5) # ffffffffc0215550 <pmm_manager>
ffffffffc0201dba:	739c                	ld	a5,32(a5)
ffffffffc0201dbc:	4585                	li	a1,1
ffffffffc0201dbe:	9782                	jalr	a5
ffffffffc0201dc0:	bfe1                	j	ffffffffc0201d98 <page_remove+0x52>
ffffffffc0201dc2:	e42a                	sd	a0,8(sp)
ffffffffc0201dc4:	ff6fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0201dc8:	00013797          	auipc	a5,0x13
ffffffffc0201dcc:	7887b783          	ld	a5,1928(a5) # ffffffffc0215550 <pmm_manager>
ffffffffc0201dd0:	739c                	ld	a5,32(a5)
ffffffffc0201dd2:	6522                	ld	a0,8(sp)
ffffffffc0201dd4:	4585                	li	a1,1
ffffffffc0201dd6:	9782                	jalr	a5
ffffffffc0201dd8:	fdcfe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0201ddc:	bf75                	j	ffffffffc0201d98 <page_remove+0x52>
ffffffffc0201dde:	c03ff0ef          	jal	ra,ffffffffc02019e0 <pa2page.part.0>

ffffffffc0201de2 <page_insert>:
ffffffffc0201de2:	7139                	addi	sp,sp,-64
ffffffffc0201de4:	e852                	sd	s4,16(sp)
ffffffffc0201de6:	8a32                	mv	s4,a2
ffffffffc0201de8:	f822                	sd	s0,48(sp)
ffffffffc0201dea:	4605                	li	a2,1
ffffffffc0201dec:	842e                	mv	s0,a1
ffffffffc0201dee:	85d2                	mv	a1,s4
ffffffffc0201df0:	f426                	sd	s1,40(sp)
ffffffffc0201df2:	fc06                	sd	ra,56(sp)
ffffffffc0201df4:	f04a                	sd	s2,32(sp)
ffffffffc0201df6:	ec4e                	sd	s3,24(sp)
ffffffffc0201df8:	e456                	sd	s5,8(sp)
ffffffffc0201dfa:	84b6                	mv	s1,a3
ffffffffc0201dfc:	d27ff0ef          	jal	ra,ffffffffc0201b22 <get_pte>
ffffffffc0201e00:	c969                	beqz	a0,ffffffffc0201ed2 <page_insert+0xf0>
ffffffffc0201e02:	4014                	lw	a3,0(s0)
ffffffffc0201e04:	611c                	ld	a5,0(a0)
ffffffffc0201e06:	89aa                	mv	s3,a0
ffffffffc0201e08:	0016871b          	addiw	a4,a3,1
ffffffffc0201e0c:	c018                	sw	a4,0(s0)
ffffffffc0201e0e:	0017f713          	andi	a4,a5,1
ffffffffc0201e12:	ef05                	bnez	a4,ffffffffc0201e4a <page_insert+0x68>
ffffffffc0201e14:	00013717          	auipc	a4,0x13
ffffffffc0201e18:	76473703          	ld	a4,1892(a4) # ffffffffc0215578 <pages>
ffffffffc0201e1c:	8c19                	sub	s0,s0,a4
ffffffffc0201e1e:	000807b7          	lui	a5,0x80
ffffffffc0201e22:	8419                	srai	s0,s0,0x6
ffffffffc0201e24:	943e                	add	s0,s0,a5
ffffffffc0201e26:	042a                	slli	s0,s0,0xa
ffffffffc0201e28:	8cc1                	or	s1,s1,s0
ffffffffc0201e2a:	0014e493          	ori	s1,s1,1
ffffffffc0201e2e:	0099b023          	sd	s1,0(s3) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0201e32:	120a0073          	sfence.vma	s4
ffffffffc0201e36:	4501                	li	a0,0
ffffffffc0201e38:	70e2                	ld	ra,56(sp)
ffffffffc0201e3a:	7442                	ld	s0,48(sp)
ffffffffc0201e3c:	74a2                	ld	s1,40(sp)
ffffffffc0201e3e:	7902                	ld	s2,32(sp)
ffffffffc0201e40:	69e2                	ld	s3,24(sp)
ffffffffc0201e42:	6a42                	ld	s4,16(sp)
ffffffffc0201e44:	6aa2                	ld	s5,8(sp)
ffffffffc0201e46:	6121                	addi	sp,sp,64
ffffffffc0201e48:	8082                	ret
ffffffffc0201e4a:	078a                	slli	a5,a5,0x2
ffffffffc0201e4c:	83b1                	srli	a5,a5,0xc
ffffffffc0201e4e:	00013717          	auipc	a4,0x13
ffffffffc0201e52:	72273703          	ld	a4,1826(a4) # ffffffffc0215570 <npage>
ffffffffc0201e56:	08e7f063          	bgeu	a5,a4,ffffffffc0201ed6 <page_insert+0xf4>
ffffffffc0201e5a:	00013a97          	auipc	s5,0x13
ffffffffc0201e5e:	71ea8a93          	addi	s5,s5,1822 # ffffffffc0215578 <pages>
ffffffffc0201e62:	000ab703          	ld	a4,0(s5)
ffffffffc0201e66:	fff80637          	lui	a2,0xfff80
ffffffffc0201e6a:	00c78933          	add	s2,a5,a2
ffffffffc0201e6e:	091a                	slli	s2,s2,0x6
ffffffffc0201e70:	993a                	add	s2,s2,a4
ffffffffc0201e72:	01240c63          	beq	s0,s2,ffffffffc0201e8a <page_insert+0xa8>
ffffffffc0201e76:	00092783          	lw	a5,0(s2)
ffffffffc0201e7a:	fff7869b          	addiw	a3,a5,-1
ffffffffc0201e7e:	00d92023          	sw	a3,0(s2)
ffffffffc0201e82:	c691                	beqz	a3,ffffffffc0201e8e <page_insert+0xac>
ffffffffc0201e84:	120a0073          	sfence.vma	s4
ffffffffc0201e88:	bf51                	j	ffffffffc0201e1c <page_insert+0x3a>
ffffffffc0201e8a:	c014                	sw	a3,0(s0)
ffffffffc0201e8c:	bf41                	j	ffffffffc0201e1c <page_insert+0x3a>
ffffffffc0201e8e:	100027f3          	csrr	a5,sstatus
ffffffffc0201e92:	8b89                	andi	a5,a5,2
ffffffffc0201e94:	ef91                	bnez	a5,ffffffffc0201eb0 <page_insert+0xce>
ffffffffc0201e96:	00013797          	auipc	a5,0x13
ffffffffc0201e9a:	6ba7b783          	ld	a5,1722(a5) # ffffffffc0215550 <pmm_manager>
ffffffffc0201e9e:	739c                	ld	a5,32(a5)
ffffffffc0201ea0:	4585                	li	a1,1
ffffffffc0201ea2:	854a                	mv	a0,s2
ffffffffc0201ea4:	9782                	jalr	a5
ffffffffc0201ea6:	000ab703          	ld	a4,0(s5)
ffffffffc0201eaa:	120a0073          	sfence.vma	s4
ffffffffc0201eae:	b7bd                	j	ffffffffc0201e1c <page_insert+0x3a>
ffffffffc0201eb0:	f0afe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0201eb4:	00013797          	auipc	a5,0x13
ffffffffc0201eb8:	69c7b783          	ld	a5,1692(a5) # ffffffffc0215550 <pmm_manager>
ffffffffc0201ebc:	739c                	ld	a5,32(a5)
ffffffffc0201ebe:	4585                	li	a1,1
ffffffffc0201ec0:	854a                	mv	a0,s2
ffffffffc0201ec2:	9782                	jalr	a5
ffffffffc0201ec4:	ef0fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0201ec8:	000ab703          	ld	a4,0(s5)
ffffffffc0201ecc:	120a0073          	sfence.vma	s4
ffffffffc0201ed0:	b7b1                	j	ffffffffc0201e1c <page_insert+0x3a>
ffffffffc0201ed2:	5571                	li	a0,-4
ffffffffc0201ed4:	b795                	j	ffffffffc0201e38 <page_insert+0x56>
ffffffffc0201ed6:	b0bff0ef          	jal	ra,ffffffffc02019e0 <pa2page.part.0>

ffffffffc0201eda <pmm_init>:
ffffffffc0201eda:	00004797          	auipc	a5,0x4
ffffffffc0201ede:	92e78793          	addi	a5,a5,-1746 # ffffffffc0205808 <default_pmm_manager>
ffffffffc0201ee2:	638c                	ld	a1,0(a5)
ffffffffc0201ee4:	711d                	addi	sp,sp,-96
ffffffffc0201ee6:	ec86                	sd	ra,88(sp)
ffffffffc0201ee8:	e4a6                	sd	s1,72(sp)
ffffffffc0201eea:	fc4e                	sd	s3,56(sp)
ffffffffc0201eec:	f05a                	sd	s6,32(sp)
ffffffffc0201eee:	ec5e                	sd	s7,24(sp)
ffffffffc0201ef0:	e8a2                	sd	s0,80(sp)
ffffffffc0201ef2:	e0ca                	sd	s2,64(sp)
ffffffffc0201ef4:	f852                	sd	s4,48(sp)
ffffffffc0201ef6:	f456                	sd	s5,40(sp)
ffffffffc0201ef8:	e862                	sd	s8,16(sp)
ffffffffc0201efa:	00013b97          	auipc	s7,0x13
ffffffffc0201efe:	656b8b93          	addi	s7,s7,1622 # ffffffffc0215550 <pmm_manager>
ffffffffc0201f02:	00004517          	auipc	a0,0x4
ffffffffc0201f06:	a6650513          	addi	a0,a0,-1434 # ffffffffc0205968 <default_pmm_manager+0x160>
ffffffffc0201f0a:	00fbb023          	sd	a5,0(s7)
ffffffffc0201f0e:	a7cfe0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0201f12:	000bb783          	ld	a5,0(s7)
ffffffffc0201f16:	00013997          	auipc	s3,0x13
ffffffffc0201f1a:	65298993          	addi	s3,s3,1618 # ffffffffc0215568 <va_pa_offset>
ffffffffc0201f1e:	00013497          	auipc	s1,0x13
ffffffffc0201f22:	65248493          	addi	s1,s1,1618 # ffffffffc0215570 <npage>
ffffffffc0201f26:	679c                	ld	a5,8(a5)
ffffffffc0201f28:	00013b17          	auipc	s6,0x13
ffffffffc0201f2c:	650b0b13          	addi	s6,s6,1616 # ffffffffc0215578 <pages>
ffffffffc0201f30:	9782                	jalr	a5
ffffffffc0201f32:	57f5                	li	a5,-3
ffffffffc0201f34:	07fa                	slli	a5,a5,0x1e
ffffffffc0201f36:	00004517          	auipc	a0,0x4
ffffffffc0201f3a:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0205980 <default_pmm_manager+0x178>
ffffffffc0201f3e:	00f9b023          	sd	a5,0(s3)
ffffffffc0201f42:	a48fe0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0201f46:	46c5                	li	a3,17
ffffffffc0201f48:	06ee                	slli	a3,a3,0x1b
ffffffffc0201f4a:	40100613          	li	a2,1025
ffffffffc0201f4e:	16fd                	addi	a3,a3,-1
ffffffffc0201f50:	0656                	slli	a2,a2,0x15
ffffffffc0201f52:	07e005b7          	lui	a1,0x7e00
ffffffffc0201f56:	00004517          	auipc	a0,0x4
ffffffffc0201f5a:	a4250513          	addi	a0,a0,-1470 # ffffffffc0205998 <default_pmm_manager+0x190>
ffffffffc0201f5e:	a2cfe0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0201f62:	777d                	lui	a4,0xfffff
ffffffffc0201f64:	00014797          	auipc	a5,0x14
ffffffffc0201f68:	66378793          	addi	a5,a5,1635 # ffffffffc02165c7 <end+0xfff>
ffffffffc0201f6c:	8ff9                	and	a5,a5,a4
ffffffffc0201f6e:	00088737          	lui	a4,0x88
ffffffffc0201f72:	e098                	sd	a4,0(s1)
ffffffffc0201f74:	00fb3023          	sd	a5,0(s6)
ffffffffc0201f78:	4705                	li	a4,1
ffffffffc0201f7a:	07a1                	addi	a5,a5,8
ffffffffc0201f7c:	40e7b02f          	amoor.d	zero,a4,(a5)
ffffffffc0201f80:	4505                	li	a0,1
ffffffffc0201f82:	fff805b7          	lui	a1,0xfff80
ffffffffc0201f86:	000b3783          	ld	a5,0(s6)
ffffffffc0201f8a:	00671693          	slli	a3,a4,0x6
ffffffffc0201f8e:	97b6                	add	a5,a5,a3
ffffffffc0201f90:	07a1                	addi	a5,a5,8
ffffffffc0201f92:	40a7b02f          	amoor.d	zero,a0,(a5)
ffffffffc0201f96:	6090                	ld	a2,0(s1)
ffffffffc0201f98:	0705                	addi	a4,a4,1
ffffffffc0201f9a:	00b607b3          	add	a5,a2,a1
ffffffffc0201f9e:	fef764e3          	bltu	a4,a5,ffffffffc0201f86 <pmm_init+0xac>
ffffffffc0201fa2:	000b3503          	ld	a0,0(s6)
ffffffffc0201fa6:	079a                	slli	a5,a5,0x6
ffffffffc0201fa8:	c0200737          	lui	a4,0xc0200
ffffffffc0201fac:	00f506b3          	add	a3,a0,a5
ffffffffc0201fb0:	60e6e363          	bltu	a3,a4,ffffffffc02025b6 <pmm_init+0x6dc>
ffffffffc0201fb4:	0009b583          	ld	a1,0(s3)
ffffffffc0201fb8:	4745                	li	a4,17
ffffffffc0201fba:	076e                	slli	a4,a4,0x1b
ffffffffc0201fbc:	8e8d                	sub	a3,a3,a1
ffffffffc0201fbe:	4ae6e263          	bltu	a3,a4,ffffffffc0202462 <pmm_init+0x588>
ffffffffc0201fc2:	00004517          	auipc	a0,0x4
ffffffffc0201fc6:	9fe50513          	addi	a0,a0,-1538 # ffffffffc02059c0 <default_pmm_manager+0x1b8>
ffffffffc0201fca:	9c0fe0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0201fce:	000bb783          	ld	a5,0(s7)
ffffffffc0201fd2:	00013917          	auipc	s2,0x13
ffffffffc0201fd6:	58e90913          	addi	s2,s2,1422 # ffffffffc0215560 <boot_pgdir>
ffffffffc0201fda:	7b9c                	ld	a5,48(a5)
ffffffffc0201fdc:	9782                	jalr	a5
ffffffffc0201fde:	00004517          	auipc	a0,0x4
ffffffffc0201fe2:	9fa50513          	addi	a0,a0,-1542 # ffffffffc02059d8 <default_pmm_manager+0x1d0>
ffffffffc0201fe6:	9a4fe0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0201fea:	00007697          	auipc	a3,0x7
ffffffffc0201fee:	01668693          	addi	a3,a3,22 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201ff2:	00d93023          	sd	a3,0(s2)
ffffffffc0201ff6:	c02007b7          	lui	a5,0xc0200
ffffffffc0201ffa:	5cf6ea63          	bltu	a3,a5,ffffffffc02025ce <pmm_init+0x6f4>
ffffffffc0201ffe:	0009b783          	ld	a5,0(s3)
ffffffffc0202002:	8e9d                	sub	a3,a3,a5
ffffffffc0202004:	00013797          	auipc	a5,0x13
ffffffffc0202008:	54d7ba23          	sd	a3,1364(a5) # ffffffffc0215558 <boot_cr3>
ffffffffc020200c:	100027f3          	csrr	a5,sstatus
ffffffffc0202010:	8b89                	andi	a5,a5,2
ffffffffc0202012:	48079063          	bnez	a5,ffffffffc0202492 <pmm_init+0x5b8>
ffffffffc0202016:	000bb783          	ld	a5,0(s7)
ffffffffc020201a:	779c                	ld	a5,40(a5)
ffffffffc020201c:	9782                	jalr	a5
ffffffffc020201e:	842a                	mv	s0,a0
ffffffffc0202020:	6098                	ld	a4,0(s1)
ffffffffc0202022:	c80007b7          	lui	a5,0xc8000
ffffffffc0202026:	83b1                	srli	a5,a5,0xc
ffffffffc0202028:	5ce7ef63          	bltu	a5,a4,ffffffffc0202606 <pmm_init+0x72c>
ffffffffc020202c:	00093503          	ld	a0,0(s2)
ffffffffc0202030:	5a050b63          	beqz	a0,ffffffffc02025e6 <pmm_init+0x70c>
ffffffffc0202034:	03451793          	slli	a5,a0,0x34
ffffffffc0202038:	5a079763          	bnez	a5,ffffffffc02025e6 <pmm_init+0x70c>
ffffffffc020203c:	4601                	li	a2,0
ffffffffc020203e:	4581                	li	a1,0
ffffffffc0202040:	cb3ff0ef          	jal	ra,ffffffffc0201cf2 <get_page>
ffffffffc0202044:	62051363          	bnez	a0,ffffffffc020266a <pmm_init+0x790>
ffffffffc0202048:	4505                	li	a0,1
ffffffffc020204a:	9cfff0ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc020204e:	8a2a                	mv	s4,a0
ffffffffc0202050:	00093503          	ld	a0,0(s2)
ffffffffc0202054:	4681                	li	a3,0
ffffffffc0202056:	4601                	li	a2,0
ffffffffc0202058:	85d2                	mv	a1,s4
ffffffffc020205a:	d89ff0ef          	jal	ra,ffffffffc0201de2 <page_insert>
ffffffffc020205e:	5e051663          	bnez	a0,ffffffffc020264a <pmm_init+0x770>
ffffffffc0202062:	00093503          	ld	a0,0(s2)
ffffffffc0202066:	4601                	li	a2,0
ffffffffc0202068:	4581                	li	a1,0
ffffffffc020206a:	ab9ff0ef          	jal	ra,ffffffffc0201b22 <get_pte>
ffffffffc020206e:	5a050e63          	beqz	a0,ffffffffc020262a <pmm_init+0x750>
ffffffffc0202072:	611c                	ld	a5,0(a0)
ffffffffc0202074:	0017f713          	andi	a4,a5,1
ffffffffc0202078:	5a070763          	beqz	a4,ffffffffc0202626 <pmm_init+0x74c>
ffffffffc020207c:	6098                	ld	a4,0(s1)
ffffffffc020207e:	078a                	slli	a5,a5,0x2
ffffffffc0202080:	83b1                	srli	a5,a5,0xc
ffffffffc0202082:	52e7f863          	bgeu	a5,a4,ffffffffc02025b2 <pmm_init+0x6d8>
ffffffffc0202086:	000b3683          	ld	a3,0(s6)
ffffffffc020208a:	fff80637          	lui	a2,0xfff80
ffffffffc020208e:	97b2                	add	a5,a5,a2
ffffffffc0202090:	079a                	slli	a5,a5,0x6
ffffffffc0202092:	97b6                	add	a5,a5,a3
ffffffffc0202094:	10fa14e3          	bne	s4,a5,ffffffffc020299c <pmm_init+0xac2>
ffffffffc0202098:	000a2683          	lw	a3,0(s4)
ffffffffc020209c:	4785                	li	a5,1
ffffffffc020209e:	12f69be3          	bne	a3,a5,ffffffffc02029d4 <pmm_init+0xafa>
ffffffffc02020a2:	00093503          	ld	a0,0(s2)
ffffffffc02020a6:	77fd                	lui	a5,0xfffff
ffffffffc02020a8:	6114                	ld	a3,0(a0)
ffffffffc02020aa:	068a                	slli	a3,a3,0x2
ffffffffc02020ac:	8efd                	and	a3,a3,a5
ffffffffc02020ae:	00c6d613          	srli	a2,a3,0xc
ffffffffc02020b2:	10e675e3          	bgeu	a2,a4,ffffffffc02029bc <pmm_init+0xae2>
ffffffffc02020b6:	0009bc03          	ld	s8,0(s3)
ffffffffc02020ba:	96e2                	add	a3,a3,s8
ffffffffc02020bc:	0006ba83          	ld	s5,0(a3)
ffffffffc02020c0:	0a8a                	slli	s5,s5,0x2
ffffffffc02020c2:	00fafab3          	and	s5,s5,a5
ffffffffc02020c6:	00cad793          	srli	a5,s5,0xc
ffffffffc02020ca:	62e7f063          	bgeu	a5,a4,ffffffffc02026ea <pmm_init+0x810>
ffffffffc02020ce:	4601                	li	a2,0
ffffffffc02020d0:	6585                	lui	a1,0x1
ffffffffc02020d2:	9c56                	add	s8,s8,s5
ffffffffc02020d4:	a4fff0ef          	jal	ra,ffffffffc0201b22 <get_pte>
ffffffffc02020d8:	0c21                	addi	s8,s8,8
ffffffffc02020da:	5f851863          	bne	a0,s8,ffffffffc02026ca <pmm_init+0x7f0>
ffffffffc02020de:	4505                	li	a0,1
ffffffffc02020e0:	939ff0ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc02020e4:	8aaa                	mv	s5,a0
ffffffffc02020e6:	00093503          	ld	a0,0(s2)
ffffffffc02020ea:	46d1                	li	a3,20
ffffffffc02020ec:	6605                	lui	a2,0x1
ffffffffc02020ee:	85d6                	mv	a1,s5
ffffffffc02020f0:	cf3ff0ef          	jal	ra,ffffffffc0201de2 <page_insert>
ffffffffc02020f4:	58051b63          	bnez	a0,ffffffffc020268a <pmm_init+0x7b0>
ffffffffc02020f8:	00093503          	ld	a0,0(s2)
ffffffffc02020fc:	4601                	li	a2,0
ffffffffc02020fe:	6585                	lui	a1,0x1
ffffffffc0202100:	a23ff0ef          	jal	ra,ffffffffc0201b22 <get_pte>
ffffffffc0202104:	0e0508e3          	beqz	a0,ffffffffc02029f4 <pmm_init+0xb1a>
ffffffffc0202108:	611c                	ld	a5,0(a0)
ffffffffc020210a:	0107f713          	andi	a4,a5,16
ffffffffc020210e:	6e070b63          	beqz	a4,ffffffffc0202804 <pmm_init+0x92a>
ffffffffc0202112:	8b91                	andi	a5,a5,4
ffffffffc0202114:	6a078863          	beqz	a5,ffffffffc02027c4 <pmm_init+0x8ea>
ffffffffc0202118:	00093503          	ld	a0,0(s2)
ffffffffc020211c:	611c                	ld	a5,0(a0)
ffffffffc020211e:	8bc1                	andi	a5,a5,16
ffffffffc0202120:	68078263          	beqz	a5,ffffffffc02027a4 <pmm_init+0x8ca>
ffffffffc0202124:	000aa703          	lw	a4,0(s5)
ffffffffc0202128:	4785                	li	a5,1
ffffffffc020212a:	58f71063          	bne	a4,a5,ffffffffc02026aa <pmm_init+0x7d0>
ffffffffc020212e:	4681                	li	a3,0
ffffffffc0202130:	6605                	lui	a2,0x1
ffffffffc0202132:	85d2                	mv	a1,s4
ffffffffc0202134:	cafff0ef          	jal	ra,ffffffffc0201de2 <page_insert>
ffffffffc0202138:	62051663          	bnez	a0,ffffffffc0202764 <pmm_init+0x88a>
ffffffffc020213c:	000a2703          	lw	a4,0(s4)
ffffffffc0202140:	4789                	li	a5,2
ffffffffc0202142:	60f71163          	bne	a4,a5,ffffffffc0202744 <pmm_init+0x86a>
ffffffffc0202146:	000aa783          	lw	a5,0(s5)
ffffffffc020214a:	5c079d63          	bnez	a5,ffffffffc0202724 <pmm_init+0x84a>
ffffffffc020214e:	00093503          	ld	a0,0(s2)
ffffffffc0202152:	4601                	li	a2,0
ffffffffc0202154:	6585                	lui	a1,0x1
ffffffffc0202156:	9cdff0ef          	jal	ra,ffffffffc0201b22 <get_pte>
ffffffffc020215a:	5a050563          	beqz	a0,ffffffffc0202704 <pmm_init+0x82a>
ffffffffc020215e:	6118                	ld	a4,0(a0)
ffffffffc0202160:	00177793          	andi	a5,a4,1
ffffffffc0202164:	4c078163          	beqz	a5,ffffffffc0202626 <pmm_init+0x74c>
ffffffffc0202168:	6094                	ld	a3,0(s1)
ffffffffc020216a:	00271793          	slli	a5,a4,0x2
ffffffffc020216e:	83b1                	srli	a5,a5,0xc
ffffffffc0202170:	44d7f163          	bgeu	a5,a3,ffffffffc02025b2 <pmm_init+0x6d8>
ffffffffc0202174:	000b3683          	ld	a3,0(s6)
ffffffffc0202178:	fff80637          	lui	a2,0xfff80
ffffffffc020217c:	97b2                	add	a5,a5,a2
ffffffffc020217e:	079a                	slli	a5,a5,0x6
ffffffffc0202180:	97b6                	add	a5,a5,a3
ffffffffc0202182:	6efa1163          	bne	s4,a5,ffffffffc0202864 <pmm_init+0x98a>
ffffffffc0202186:	8b41                	andi	a4,a4,16
ffffffffc0202188:	6a071e63          	bnez	a4,ffffffffc0202844 <pmm_init+0x96a>
ffffffffc020218c:	00093503          	ld	a0,0(s2)
ffffffffc0202190:	4581                	li	a1,0
ffffffffc0202192:	bb5ff0ef          	jal	ra,ffffffffc0201d46 <page_remove>
ffffffffc0202196:	000a2703          	lw	a4,0(s4)
ffffffffc020219a:	4785                	li	a5,1
ffffffffc020219c:	68f71463          	bne	a4,a5,ffffffffc0202824 <pmm_init+0x94a>
ffffffffc02021a0:	000aa783          	lw	a5,0(s5)
ffffffffc02021a4:	74079c63          	bnez	a5,ffffffffc02028fc <pmm_init+0xa22>
ffffffffc02021a8:	00093503          	ld	a0,0(s2)
ffffffffc02021ac:	6585                	lui	a1,0x1
ffffffffc02021ae:	b99ff0ef          	jal	ra,ffffffffc0201d46 <page_remove>
ffffffffc02021b2:	000a2783          	lw	a5,0(s4)
ffffffffc02021b6:	72079363          	bnez	a5,ffffffffc02028dc <pmm_init+0xa02>
ffffffffc02021ba:	000aa783          	lw	a5,0(s5)
ffffffffc02021be:	6e079f63          	bnez	a5,ffffffffc02028bc <pmm_init+0x9e2>
ffffffffc02021c2:	00093a03          	ld	s4,0(s2)
ffffffffc02021c6:	6098                	ld	a4,0(s1)
ffffffffc02021c8:	000a3783          	ld	a5,0(s4)
ffffffffc02021cc:	078a                	slli	a5,a5,0x2
ffffffffc02021ce:	83b1                	srli	a5,a5,0xc
ffffffffc02021d0:	3ee7f163          	bgeu	a5,a4,ffffffffc02025b2 <pmm_init+0x6d8>
ffffffffc02021d4:	fff806b7          	lui	a3,0xfff80
ffffffffc02021d8:	000b3503          	ld	a0,0(s6)
ffffffffc02021dc:	97b6                	add	a5,a5,a3
ffffffffc02021de:	079a                	slli	a5,a5,0x6
ffffffffc02021e0:	00f506b3          	add	a3,a0,a5
ffffffffc02021e4:	4290                	lw	a2,0(a3)
ffffffffc02021e6:	4685                	li	a3,1
ffffffffc02021e8:	6ad61a63          	bne	a2,a3,ffffffffc020289c <pmm_init+0x9c2>
ffffffffc02021ec:	8799                	srai	a5,a5,0x6
ffffffffc02021ee:	00080637          	lui	a2,0x80
ffffffffc02021f2:	97b2                	add	a5,a5,a2
ffffffffc02021f4:	00c79693          	slli	a3,a5,0xc
ffffffffc02021f8:	68e7f663          	bgeu	a5,a4,ffffffffc0202884 <pmm_init+0x9aa>
ffffffffc02021fc:	0009b783          	ld	a5,0(s3)
ffffffffc0202200:	97b6                	add	a5,a5,a3
ffffffffc0202202:	639c                	ld	a5,0(a5)
ffffffffc0202204:	078a                	slli	a5,a5,0x2
ffffffffc0202206:	83b1                	srli	a5,a5,0xc
ffffffffc0202208:	3ae7f563          	bgeu	a5,a4,ffffffffc02025b2 <pmm_init+0x6d8>
ffffffffc020220c:	8f91                	sub	a5,a5,a2
ffffffffc020220e:	079a                	slli	a5,a5,0x6
ffffffffc0202210:	953e                	add	a0,a0,a5
ffffffffc0202212:	100027f3          	csrr	a5,sstatus
ffffffffc0202216:	8b89                	andi	a5,a5,2
ffffffffc0202218:	2c079763          	bnez	a5,ffffffffc02024e6 <pmm_init+0x60c>
ffffffffc020221c:	000bb783          	ld	a5,0(s7)
ffffffffc0202220:	4585                	li	a1,1
ffffffffc0202222:	739c                	ld	a5,32(a5)
ffffffffc0202224:	9782                	jalr	a5
ffffffffc0202226:	000a3783          	ld	a5,0(s4)
ffffffffc020222a:	6098                	ld	a4,0(s1)
ffffffffc020222c:	078a                	slli	a5,a5,0x2
ffffffffc020222e:	83b1                	srli	a5,a5,0xc
ffffffffc0202230:	38e7f163          	bgeu	a5,a4,ffffffffc02025b2 <pmm_init+0x6d8>
ffffffffc0202234:	000b3503          	ld	a0,0(s6)
ffffffffc0202238:	fff80737          	lui	a4,0xfff80
ffffffffc020223c:	97ba                	add	a5,a5,a4
ffffffffc020223e:	079a                	slli	a5,a5,0x6
ffffffffc0202240:	953e                	add	a0,a0,a5
ffffffffc0202242:	100027f3          	csrr	a5,sstatus
ffffffffc0202246:	8b89                	andi	a5,a5,2
ffffffffc0202248:	28079363          	bnez	a5,ffffffffc02024ce <pmm_init+0x5f4>
ffffffffc020224c:	000bb783          	ld	a5,0(s7)
ffffffffc0202250:	4585                	li	a1,1
ffffffffc0202252:	739c                	ld	a5,32(a5)
ffffffffc0202254:	9782                	jalr	a5
ffffffffc0202256:	00093783          	ld	a5,0(s2)
ffffffffc020225a:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fde9a38>
ffffffffc020225e:	12000073          	sfence.vma
ffffffffc0202262:	100027f3          	csrr	a5,sstatus
ffffffffc0202266:	8b89                	andi	a5,a5,2
ffffffffc0202268:	24079963          	bnez	a5,ffffffffc02024ba <pmm_init+0x5e0>
ffffffffc020226c:	000bb783          	ld	a5,0(s7)
ffffffffc0202270:	779c                	ld	a5,40(a5)
ffffffffc0202272:	9782                	jalr	a5
ffffffffc0202274:	8a2a                	mv	s4,a0
ffffffffc0202276:	71441363          	bne	s0,s4,ffffffffc020297c <pmm_init+0xaa2>
ffffffffc020227a:	00004517          	auipc	a0,0x4
ffffffffc020227e:	a4650513          	addi	a0,a0,-1466 # ffffffffc0205cc0 <default_pmm_manager+0x4b8>
ffffffffc0202282:	f09fd0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0202286:	100027f3          	csrr	a5,sstatus
ffffffffc020228a:	8b89                	andi	a5,a5,2
ffffffffc020228c:	20079d63          	bnez	a5,ffffffffc02024a6 <pmm_init+0x5cc>
ffffffffc0202290:	000bb783          	ld	a5,0(s7)
ffffffffc0202294:	779c                	ld	a5,40(a5)
ffffffffc0202296:	9782                	jalr	a5
ffffffffc0202298:	8c2a                	mv	s8,a0
ffffffffc020229a:	6098                	ld	a4,0(s1)
ffffffffc020229c:	c0200437          	lui	s0,0xc0200
ffffffffc02022a0:	7afd                	lui	s5,0xfffff
ffffffffc02022a2:	00c71793          	slli	a5,a4,0xc
ffffffffc02022a6:	6a05                	lui	s4,0x1
ffffffffc02022a8:	02f47c63          	bgeu	s0,a5,ffffffffc02022e0 <pmm_init+0x406>
ffffffffc02022ac:	00c45793          	srli	a5,s0,0xc
ffffffffc02022b0:	00093503          	ld	a0,0(s2)
ffffffffc02022b4:	2ee7f263          	bgeu	a5,a4,ffffffffc0202598 <pmm_init+0x6be>
ffffffffc02022b8:	0009b583          	ld	a1,0(s3)
ffffffffc02022bc:	4601                	li	a2,0
ffffffffc02022be:	95a2                	add	a1,a1,s0
ffffffffc02022c0:	863ff0ef          	jal	ra,ffffffffc0201b22 <get_pte>
ffffffffc02022c4:	2a050a63          	beqz	a0,ffffffffc0202578 <pmm_init+0x69e>
ffffffffc02022c8:	611c                	ld	a5,0(a0)
ffffffffc02022ca:	078a                	slli	a5,a5,0x2
ffffffffc02022cc:	0157f7b3          	and	a5,a5,s5
ffffffffc02022d0:	28879463          	bne	a5,s0,ffffffffc0202558 <pmm_init+0x67e>
ffffffffc02022d4:	6098                	ld	a4,0(s1)
ffffffffc02022d6:	9452                	add	s0,s0,s4
ffffffffc02022d8:	00c71793          	slli	a5,a4,0xc
ffffffffc02022dc:	fcf468e3          	bltu	s0,a5,ffffffffc02022ac <pmm_init+0x3d2>
ffffffffc02022e0:	00093783          	ld	a5,0(s2)
ffffffffc02022e4:	639c                	ld	a5,0(a5)
ffffffffc02022e6:	66079b63          	bnez	a5,ffffffffc020295c <pmm_init+0xa82>
ffffffffc02022ea:	4505                	li	a0,1
ffffffffc02022ec:	f2cff0ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc02022f0:	842a                	mv	s0,a0
ffffffffc02022f2:	00093503          	ld	a0,0(s2)
ffffffffc02022f6:	4699                	li	a3,6
ffffffffc02022f8:	10000613          	li	a2,256
ffffffffc02022fc:	85a2                	mv	a1,s0
ffffffffc02022fe:	ae5ff0ef          	jal	ra,ffffffffc0201de2 <page_insert>
ffffffffc0202302:	62051d63          	bnez	a0,ffffffffc020293c <pmm_init+0xa62>
ffffffffc0202306:	4018                	lw	a4,0(s0)
ffffffffc0202308:	4785                	li	a5,1
ffffffffc020230a:	60f71963          	bne	a4,a5,ffffffffc020291c <pmm_init+0xa42>
ffffffffc020230e:	00093503          	ld	a0,0(s2)
ffffffffc0202312:	6a05                	lui	s4,0x1
ffffffffc0202314:	4699                	li	a3,6
ffffffffc0202316:	100a0613          	addi	a2,s4,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc020231a:	85a2                	mv	a1,s0
ffffffffc020231c:	ac7ff0ef          	jal	ra,ffffffffc0201de2 <page_insert>
ffffffffc0202320:	46051263          	bnez	a0,ffffffffc0202784 <pmm_init+0x8aa>
ffffffffc0202324:	4018                	lw	a4,0(s0)
ffffffffc0202326:	4789                	li	a5,2
ffffffffc0202328:	72f71663          	bne	a4,a5,ffffffffc0202a54 <pmm_init+0xb7a>
ffffffffc020232c:	00004597          	auipc	a1,0x4
ffffffffc0202330:	acc58593          	addi	a1,a1,-1332 # ffffffffc0205df8 <default_pmm_manager+0x5f0>
ffffffffc0202334:	10000513          	li	a0,256
ffffffffc0202338:	6d2020ef          	jal	ra,ffffffffc0204a0a <strcpy>
ffffffffc020233c:	100a0593          	addi	a1,s4,256
ffffffffc0202340:	10000513          	li	a0,256
ffffffffc0202344:	6d8020ef          	jal	ra,ffffffffc0204a1c <strcmp>
ffffffffc0202348:	6e051663          	bnez	a0,ffffffffc0202a34 <pmm_init+0xb5a>
ffffffffc020234c:	000b3683          	ld	a3,0(s6)
ffffffffc0202350:	000807b7          	lui	a5,0x80
ffffffffc0202354:	6098                	ld	a4,0(s1)
ffffffffc0202356:	40d406b3          	sub	a3,s0,a3
ffffffffc020235a:	8699                	srai	a3,a3,0x6
ffffffffc020235c:	96be                	add	a3,a3,a5
ffffffffc020235e:	00c69793          	slli	a5,a3,0xc
ffffffffc0202362:	83b1                	srli	a5,a5,0xc
ffffffffc0202364:	06b2                	slli	a3,a3,0xc
ffffffffc0202366:	50e7ff63          	bgeu	a5,a4,ffffffffc0202884 <pmm_init+0x9aa>
ffffffffc020236a:	0009b783          	ld	a5,0(s3)
ffffffffc020236e:	10000513          	li	a0,256
ffffffffc0202372:	97b6                	add	a5,a5,a3
ffffffffc0202374:	10078023          	sb	zero,256(a5) # 80100 <kern_entry-0xffffffffc017ff00>
ffffffffc0202378:	65c020ef          	jal	ra,ffffffffc02049d4 <strlen>
ffffffffc020237c:	68051c63          	bnez	a0,ffffffffc0202a14 <pmm_init+0xb3a>
ffffffffc0202380:	00093a03          	ld	s4,0(s2)
ffffffffc0202384:	6098                	ld	a4,0(s1)
ffffffffc0202386:	000a3783          	ld	a5,0(s4)
ffffffffc020238a:	078a                	slli	a5,a5,0x2
ffffffffc020238c:	83b1                	srli	a5,a5,0xc
ffffffffc020238e:	22e7f263          	bgeu	a5,a4,ffffffffc02025b2 <pmm_init+0x6d8>
ffffffffc0202392:	00c79693          	slli	a3,a5,0xc
ffffffffc0202396:	4ee7f763          	bgeu	a5,a4,ffffffffc0202884 <pmm_init+0x9aa>
ffffffffc020239a:	0009b783          	ld	a5,0(s3)
ffffffffc020239e:	00f689b3          	add	s3,a3,a5
ffffffffc02023a2:	100027f3          	csrr	a5,sstatus
ffffffffc02023a6:	8b89                	andi	a5,a5,2
ffffffffc02023a8:	18079d63          	bnez	a5,ffffffffc0202542 <pmm_init+0x668>
ffffffffc02023ac:	000bb783          	ld	a5,0(s7)
ffffffffc02023b0:	4585                	li	a1,1
ffffffffc02023b2:	8522                	mv	a0,s0
ffffffffc02023b4:	739c                	ld	a5,32(a5)
ffffffffc02023b6:	9782                	jalr	a5
ffffffffc02023b8:	0009b783          	ld	a5,0(s3)
ffffffffc02023bc:	6098                	ld	a4,0(s1)
ffffffffc02023be:	078a                	slli	a5,a5,0x2
ffffffffc02023c0:	83b1                	srli	a5,a5,0xc
ffffffffc02023c2:	1ee7f863          	bgeu	a5,a4,ffffffffc02025b2 <pmm_init+0x6d8>
ffffffffc02023c6:	000b3503          	ld	a0,0(s6)
ffffffffc02023ca:	fff80737          	lui	a4,0xfff80
ffffffffc02023ce:	97ba                	add	a5,a5,a4
ffffffffc02023d0:	079a                	slli	a5,a5,0x6
ffffffffc02023d2:	953e                	add	a0,a0,a5
ffffffffc02023d4:	100027f3          	csrr	a5,sstatus
ffffffffc02023d8:	8b89                	andi	a5,a5,2
ffffffffc02023da:	14079863          	bnez	a5,ffffffffc020252a <pmm_init+0x650>
ffffffffc02023de:	000bb783          	ld	a5,0(s7)
ffffffffc02023e2:	4585                	li	a1,1
ffffffffc02023e4:	739c                	ld	a5,32(a5)
ffffffffc02023e6:	9782                	jalr	a5
ffffffffc02023e8:	000a3783          	ld	a5,0(s4)
ffffffffc02023ec:	6098                	ld	a4,0(s1)
ffffffffc02023ee:	078a                	slli	a5,a5,0x2
ffffffffc02023f0:	83b1                	srli	a5,a5,0xc
ffffffffc02023f2:	1ce7f063          	bgeu	a5,a4,ffffffffc02025b2 <pmm_init+0x6d8>
ffffffffc02023f6:	000b3503          	ld	a0,0(s6)
ffffffffc02023fa:	fff80737          	lui	a4,0xfff80
ffffffffc02023fe:	97ba                	add	a5,a5,a4
ffffffffc0202400:	079a                	slli	a5,a5,0x6
ffffffffc0202402:	953e                	add	a0,a0,a5
ffffffffc0202404:	100027f3          	csrr	a5,sstatus
ffffffffc0202408:	8b89                	andi	a5,a5,2
ffffffffc020240a:	10079463          	bnez	a5,ffffffffc0202512 <pmm_init+0x638>
ffffffffc020240e:	000bb783          	ld	a5,0(s7)
ffffffffc0202412:	4585                	li	a1,1
ffffffffc0202414:	739c                	ld	a5,32(a5)
ffffffffc0202416:	9782                	jalr	a5
ffffffffc0202418:	00093783          	ld	a5,0(s2)
ffffffffc020241c:	0007b023          	sd	zero,0(a5)
ffffffffc0202420:	12000073          	sfence.vma
ffffffffc0202424:	100027f3          	csrr	a5,sstatus
ffffffffc0202428:	8b89                	andi	a5,a5,2
ffffffffc020242a:	0c079a63          	bnez	a5,ffffffffc02024fe <pmm_init+0x624>
ffffffffc020242e:	000bb783          	ld	a5,0(s7)
ffffffffc0202432:	779c                	ld	a5,40(a5)
ffffffffc0202434:	9782                	jalr	a5
ffffffffc0202436:	842a                	mv	s0,a0
ffffffffc0202438:	3a8c1663          	bne	s8,s0,ffffffffc02027e4 <pmm_init+0x90a>
ffffffffc020243c:	00004517          	auipc	a0,0x4
ffffffffc0202440:	a3450513          	addi	a0,a0,-1484 # ffffffffc0205e70 <default_pmm_manager+0x668>
ffffffffc0202444:	d47fd0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0202448:	6446                	ld	s0,80(sp)
ffffffffc020244a:	60e6                	ld	ra,88(sp)
ffffffffc020244c:	64a6                	ld	s1,72(sp)
ffffffffc020244e:	6906                	ld	s2,64(sp)
ffffffffc0202450:	79e2                	ld	s3,56(sp)
ffffffffc0202452:	7a42                	ld	s4,48(sp)
ffffffffc0202454:	7aa2                	ld	s5,40(sp)
ffffffffc0202456:	7b02                	ld	s6,32(sp)
ffffffffc0202458:	6be2                	ld	s7,24(sp)
ffffffffc020245a:	6c42                	ld	s8,16(sp)
ffffffffc020245c:	6125                	addi	sp,sp,96
ffffffffc020245e:	bccff06f          	j	ffffffffc020182a <kmalloc_init>
ffffffffc0202462:	6785                	lui	a5,0x1
ffffffffc0202464:	17fd                	addi	a5,a5,-1
ffffffffc0202466:	96be                	add	a3,a3,a5
ffffffffc0202468:	77fd                	lui	a5,0xfffff
ffffffffc020246a:	8ff5                	and	a5,a5,a3
ffffffffc020246c:	00c7d693          	srli	a3,a5,0xc
ffffffffc0202470:	14c6f163          	bgeu	a3,a2,ffffffffc02025b2 <pmm_init+0x6d8>
ffffffffc0202474:	000bb603          	ld	a2,0(s7)
ffffffffc0202478:	fff805b7          	lui	a1,0xfff80
ffffffffc020247c:	96ae                	add	a3,a3,a1
ffffffffc020247e:	6a10                	ld	a2,16(a2)
ffffffffc0202480:	8f1d                	sub	a4,a4,a5
ffffffffc0202482:	069a                	slli	a3,a3,0x6
ffffffffc0202484:	00c75593          	srli	a1,a4,0xc
ffffffffc0202488:	9536                	add	a0,a0,a3
ffffffffc020248a:	9602                	jalr	a2
ffffffffc020248c:	0009b583          	ld	a1,0(s3)
ffffffffc0202490:	be0d                	j	ffffffffc0201fc2 <pmm_init+0xe8>
ffffffffc0202492:	928fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0202496:	000bb783          	ld	a5,0(s7)
ffffffffc020249a:	779c                	ld	a5,40(a5)
ffffffffc020249c:	9782                	jalr	a5
ffffffffc020249e:	842a                	mv	s0,a0
ffffffffc02024a0:	914fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc02024a4:	beb5                	j	ffffffffc0202020 <pmm_init+0x146>
ffffffffc02024a6:	914fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc02024aa:	000bb783          	ld	a5,0(s7)
ffffffffc02024ae:	779c                	ld	a5,40(a5)
ffffffffc02024b0:	9782                	jalr	a5
ffffffffc02024b2:	8c2a                	mv	s8,a0
ffffffffc02024b4:	900fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc02024b8:	b3cd                	j	ffffffffc020229a <pmm_init+0x3c0>
ffffffffc02024ba:	900fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc02024be:	000bb783          	ld	a5,0(s7)
ffffffffc02024c2:	779c                	ld	a5,40(a5)
ffffffffc02024c4:	9782                	jalr	a5
ffffffffc02024c6:	8a2a                	mv	s4,a0
ffffffffc02024c8:	8ecfe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc02024cc:	b36d                	j	ffffffffc0202276 <pmm_init+0x39c>
ffffffffc02024ce:	e42a                	sd	a0,8(sp)
ffffffffc02024d0:	8eafe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc02024d4:	000bb783          	ld	a5,0(s7)
ffffffffc02024d8:	6522                	ld	a0,8(sp)
ffffffffc02024da:	4585                	li	a1,1
ffffffffc02024dc:	739c                	ld	a5,32(a5)
ffffffffc02024de:	9782                	jalr	a5
ffffffffc02024e0:	8d4fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc02024e4:	bb8d                	j	ffffffffc0202256 <pmm_init+0x37c>
ffffffffc02024e6:	e42a                	sd	a0,8(sp)
ffffffffc02024e8:	8d2fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc02024ec:	000bb783          	ld	a5,0(s7)
ffffffffc02024f0:	6522                	ld	a0,8(sp)
ffffffffc02024f2:	4585                	li	a1,1
ffffffffc02024f4:	739c                	ld	a5,32(a5)
ffffffffc02024f6:	9782                	jalr	a5
ffffffffc02024f8:	8bcfe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc02024fc:	b32d                	j	ffffffffc0202226 <pmm_init+0x34c>
ffffffffc02024fe:	8bcfe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0202502:	000bb783          	ld	a5,0(s7)
ffffffffc0202506:	779c                	ld	a5,40(a5)
ffffffffc0202508:	9782                	jalr	a5
ffffffffc020250a:	842a                	mv	s0,a0
ffffffffc020250c:	8a8fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0202510:	b725                	j	ffffffffc0202438 <pmm_init+0x55e>
ffffffffc0202512:	e42a                	sd	a0,8(sp)
ffffffffc0202514:	8a6fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0202518:	000bb783          	ld	a5,0(s7)
ffffffffc020251c:	6522                	ld	a0,8(sp)
ffffffffc020251e:	4585                	li	a1,1
ffffffffc0202520:	739c                	ld	a5,32(a5)
ffffffffc0202522:	9782                	jalr	a5
ffffffffc0202524:	890fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0202528:	bdc5                	j	ffffffffc0202418 <pmm_init+0x53e>
ffffffffc020252a:	e42a                	sd	a0,8(sp)
ffffffffc020252c:	88efe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0202530:	000bb783          	ld	a5,0(s7)
ffffffffc0202534:	6522                	ld	a0,8(sp)
ffffffffc0202536:	4585                	li	a1,1
ffffffffc0202538:	739c                	ld	a5,32(a5)
ffffffffc020253a:	9782                	jalr	a5
ffffffffc020253c:	878fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0202540:	b565                	j	ffffffffc02023e8 <pmm_init+0x50e>
ffffffffc0202542:	878fe0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0202546:	000bb783          	ld	a5,0(s7)
ffffffffc020254a:	4585                	li	a1,1
ffffffffc020254c:	8522                	mv	a0,s0
ffffffffc020254e:	739c                	ld	a5,32(a5)
ffffffffc0202550:	9782                	jalr	a5
ffffffffc0202552:	862fe0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0202556:	b58d                	j	ffffffffc02023b8 <pmm_init+0x4de>
ffffffffc0202558:	00003697          	auipc	a3,0x3
ffffffffc020255c:	7c868693          	addi	a3,a3,1992 # ffffffffc0205d20 <default_pmm_manager+0x518>
ffffffffc0202560:	00003617          	auipc	a2,0x3
ffffffffc0202564:	ef860613          	addi	a2,a2,-264 # ffffffffc0205458 <commands+0x738>
ffffffffc0202568:	1d000593          	li	a1,464
ffffffffc020256c:	00003517          	auipc	a0,0x3
ffffffffc0202570:	3ec50513          	addi	a0,a0,1004 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202574:	ecbfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202578:	00003697          	auipc	a3,0x3
ffffffffc020257c:	76868693          	addi	a3,a3,1896 # ffffffffc0205ce0 <default_pmm_manager+0x4d8>
ffffffffc0202580:	00003617          	auipc	a2,0x3
ffffffffc0202584:	ed860613          	addi	a2,a2,-296 # ffffffffc0205458 <commands+0x738>
ffffffffc0202588:	1cf00593          	li	a1,463
ffffffffc020258c:	00003517          	auipc	a0,0x3
ffffffffc0202590:	3cc50513          	addi	a0,a0,972 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202594:	eabfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202598:	86a2                	mv	a3,s0
ffffffffc020259a:	00003617          	auipc	a2,0x3
ffffffffc020259e:	2a660613          	addi	a2,a2,678 # ffffffffc0205840 <default_pmm_manager+0x38>
ffffffffc02025a2:	1cf00593          	li	a1,463
ffffffffc02025a6:	00003517          	auipc	a0,0x3
ffffffffc02025aa:	3b250513          	addi	a0,a0,946 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc02025ae:	e91fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02025b2:	c2eff0ef          	jal	ra,ffffffffc02019e0 <pa2page.part.0>
ffffffffc02025b6:	00003617          	auipc	a2,0x3
ffffffffc02025ba:	33260613          	addi	a2,a2,818 # ffffffffc02058e8 <default_pmm_manager+0xe0>
ffffffffc02025be:	08500593          	li	a1,133
ffffffffc02025c2:	00003517          	auipc	a0,0x3
ffffffffc02025c6:	39650513          	addi	a0,a0,918 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc02025ca:	e75fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02025ce:	00003617          	auipc	a2,0x3
ffffffffc02025d2:	31a60613          	addi	a2,a2,794 # ffffffffc02058e8 <default_pmm_manager+0xe0>
ffffffffc02025d6:	0c900593          	li	a1,201
ffffffffc02025da:	00003517          	auipc	a0,0x3
ffffffffc02025de:	37e50513          	addi	a0,a0,894 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc02025e2:	e5dfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02025e6:	00003697          	auipc	a3,0x3
ffffffffc02025ea:	43268693          	addi	a3,a3,1074 # ffffffffc0205a18 <default_pmm_manager+0x210>
ffffffffc02025ee:	00003617          	auipc	a2,0x3
ffffffffc02025f2:	e6a60613          	addi	a2,a2,-406 # ffffffffc0205458 <commands+0x738>
ffffffffc02025f6:	18700593          	li	a1,391
ffffffffc02025fa:	00003517          	auipc	a0,0x3
ffffffffc02025fe:	35e50513          	addi	a0,a0,862 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202602:	e3dfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202606:	00003697          	auipc	a3,0x3
ffffffffc020260a:	3f268693          	addi	a3,a3,1010 # ffffffffc02059f8 <default_pmm_manager+0x1f0>
ffffffffc020260e:	00003617          	auipc	a2,0x3
ffffffffc0202612:	e4a60613          	addi	a2,a2,-438 # ffffffffc0205458 <commands+0x738>
ffffffffc0202616:	18500593          	li	a1,389
ffffffffc020261a:	00003517          	auipc	a0,0x3
ffffffffc020261e:	33e50513          	addi	a0,a0,830 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202622:	e1dfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202626:	bd6ff0ef          	jal	ra,ffffffffc02019fc <pte2page.part.0>
ffffffffc020262a:	00003697          	auipc	a3,0x3
ffffffffc020262e:	47e68693          	addi	a3,a3,1150 # ffffffffc0205aa8 <default_pmm_manager+0x2a0>
ffffffffc0202632:	00003617          	auipc	a2,0x3
ffffffffc0202636:	e2660613          	addi	a2,a2,-474 # ffffffffc0205458 <commands+0x738>
ffffffffc020263a:	19400593          	li	a1,404
ffffffffc020263e:	00003517          	auipc	a0,0x3
ffffffffc0202642:	31a50513          	addi	a0,a0,794 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202646:	df9fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020264a:	00003697          	auipc	a3,0x3
ffffffffc020264e:	42e68693          	addi	a3,a3,1070 # ffffffffc0205a78 <default_pmm_manager+0x270>
ffffffffc0202652:	00003617          	auipc	a2,0x3
ffffffffc0202656:	e0660613          	addi	a2,a2,-506 # ffffffffc0205458 <commands+0x738>
ffffffffc020265a:	18f00593          	li	a1,399
ffffffffc020265e:	00003517          	auipc	a0,0x3
ffffffffc0202662:	2fa50513          	addi	a0,a0,762 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202666:	dd9fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020266a:	00003697          	auipc	a3,0x3
ffffffffc020266e:	3e668693          	addi	a3,a3,998 # ffffffffc0205a50 <default_pmm_manager+0x248>
ffffffffc0202672:	00003617          	auipc	a2,0x3
ffffffffc0202676:	de660613          	addi	a2,a2,-538 # ffffffffc0205458 <commands+0x738>
ffffffffc020267a:	18900593          	li	a1,393
ffffffffc020267e:	00003517          	auipc	a0,0x3
ffffffffc0202682:	2da50513          	addi	a0,a0,730 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202686:	db9fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020268a:	00003697          	auipc	a3,0x3
ffffffffc020268e:	4a668693          	addi	a3,a3,1190 # ffffffffc0205b30 <default_pmm_manager+0x328>
ffffffffc0202692:	00003617          	auipc	a2,0x3
ffffffffc0202696:	dc660613          	addi	a2,a2,-570 # ffffffffc0205458 <commands+0x738>
ffffffffc020269a:	19f00593          	li	a1,415
ffffffffc020269e:	00003517          	auipc	a0,0x3
ffffffffc02026a2:	2ba50513          	addi	a0,a0,698 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc02026a6:	d99fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02026aa:	00003697          	auipc	a3,0x3
ffffffffc02026ae:	52668693          	addi	a3,a3,1318 # ffffffffc0205bd0 <default_pmm_manager+0x3c8>
ffffffffc02026b2:	00003617          	auipc	a2,0x3
ffffffffc02026b6:	da660613          	addi	a2,a2,-602 # ffffffffc0205458 <commands+0x738>
ffffffffc02026ba:	1a500593          	li	a1,421
ffffffffc02026be:	00003517          	auipc	a0,0x3
ffffffffc02026c2:	29a50513          	addi	a0,a0,666 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc02026c6:	d79fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02026ca:	00003697          	auipc	a3,0x3
ffffffffc02026ce:	43e68693          	addi	a3,a3,1086 # ffffffffc0205b08 <default_pmm_manager+0x300>
ffffffffc02026d2:	00003617          	auipc	a2,0x3
ffffffffc02026d6:	d8660613          	addi	a2,a2,-634 # ffffffffc0205458 <commands+0x738>
ffffffffc02026da:	19b00593          	li	a1,411
ffffffffc02026de:	00003517          	auipc	a0,0x3
ffffffffc02026e2:	27a50513          	addi	a0,a0,634 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc02026e6:	d59fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02026ea:	86d6                	mv	a3,s5
ffffffffc02026ec:	00003617          	auipc	a2,0x3
ffffffffc02026f0:	15460613          	addi	a2,a2,340 # ffffffffc0205840 <default_pmm_manager+0x38>
ffffffffc02026f4:	19a00593          	li	a1,410
ffffffffc02026f8:	00003517          	auipc	a0,0x3
ffffffffc02026fc:	26050513          	addi	a0,a0,608 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202700:	d3ffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202704:	00003697          	auipc	a3,0x3
ffffffffc0202708:	46468693          	addi	a3,a3,1124 # ffffffffc0205b68 <default_pmm_manager+0x360>
ffffffffc020270c:	00003617          	auipc	a2,0x3
ffffffffc0202710:	d4c60613          	addi	a2,a2,-692 # ffffffffc0205458 <commands+0x738>
ffffffffc0202714:	1ad00593          	li	a1,429
ffffffffc0202718:	00003517          	auipc	a0,0x3
ffffffffc020271c:	24050513          	addi	a0,a0,576 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202720:	d1ffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202724:	00003697          	auipc	a3,0x3
ffffffffc0202728:	50c68693          	addi	a3,a3,1292 # ffffffffc0205c30 <default_pmm_manager+0x428>
ffffffffc020272c:	00003617          	auipc	a2,0x3
ffffffffc0202730:	d2c60613          	addi	a2,a2,-724 # ffffffffc0205458 <commands+0x738>
ffffffffc0202734:	1aa00593          	li	a1,426
ffffffffc0202738:	00003517          	auipc	a0,0x3
ffffffffc020273c:	22050513          	addi	a0,a0,544 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202740:	cfffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202744:	00003697          	auipc	a3,0x3
ffffffffc0202748:	4d468693          	addi	a3,a3,1236 # ffffffffc0205c18 <default_pmm_manager+0x410>
ffffffffc020274c:	00003617          	auipc	a2,0x3
ffffffffc0202750:	d0c60613          	addi	a2,a2,-756 # ffffffffc0205458 <commands+0x738>
ffffffffc0202754:	1a900593          	li	a1,425
ffffffffc0202758:	00003517          	auipc	a0,0x3
ffffffffc020275c:	20050513          	addi	a0,a0,512 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202760:	cdffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202764:	00003697          	auipc	a3,0x3
ffffffffc0202768:	48468693          	addi	a3,a3,1156 # ffffffffc0205be8 <default_pmm_manager+0x3e0>
ffffffffc020276c:	00003617          	auipc	a2,0x3
ffffffffc0202770:	cec60613          	addi	a2,a2,-788 # ffffffffc0205458 <commands+0x738>
ffffffffc0202774:	1a800593          	li	a1,424
ffffffffc0202778:	00003517          	auipc	a0,0x3
ffffffffc020277c:	1e050513          	addi	a0,a0,480 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202780:	cbffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202784:	00003697          	auipc	a3,0x3
ffffffffc0202788:	61c68693          	addi	a3,a3,1564 # ffffffffc0205da0 <default_pmm_manager+0x598>
ffffffffc020278c:	00003617          	auipc	a2,0x3
ffffffffc0202790:	ccc60613          	addi	a2,a2,-820 # ffffffffc0205458 <commands+0x738>
ffffffffc0202794:	1d900593          	li	a1,473
ffffffffc0202798:	00003517          	auipc	a0,0x3
ffffffffc020279c:	1c050513          	addi	a0,a0,448 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc02027a0:	c9ffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02027a4:	00003697          	auipc	a3,0x3
ffffffffc02027a8:	41468693          	addi	a3,a3,1044 # ffffffffc0205bb8 <default_pmm_manager+0x3b0>
ffffffffc02027ac:	00003617          	auipc	a2,0x3
ffffffffc02027b0:	cac60613          	addi	a2,a2,-852 # ffffffffc0205458 <commands+0x738>
ffffffffc02027b4:	1a400593          	li	a1,420
ffffffffc02027b8:	00003517          	auipc	a0,0x3
ffffffffc02027bc:	1a050513          	addi	a0,a0,416 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc02027c0:	c7ffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02027c4:	00003697          	auipc	a3,0x3
ffffffffc02027c8:	3e468693          	addi	a3,a3,996 # ffffffffc0205ba8 <default_pmm_manager+0x3a0>
ffffffffc02027cc:	00003617          	auipc	a2,0x3
ffffffffc02027d0:	c8c60613          	addi	a2,a2,-884 # ffffffffc0205458 <commands+0x738>
ffffffffc02027d4:	1a300593          	li	a1,419
ffffffffc02027d8:	00003517          	auipc	a0,0x3
ffffffffc02027dc:	18050513          	addi	a0,a0,384 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc02027e0:	c5ffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02027e4:	00003697          	auipc	a3,0x3
ffffffffc02027e8:	4bc68693          	addi	a3,a3,1212 # ffffffffc0205ca0 <default_pmm_manager+0x498>
ffffffffc02027ec:	00003617          	auipc	a2,0x3
ffffffffc02027f0:	c6c60613          	addi	a2,a2,-916 # ffffffffc0205458 <commands+0x738>
ffffffffc02027f4:	1ea00593          	li	a1,490
ffffffffc02027f8:	00003517          	auipc	a0,0x3
ffffffffc02027fc:	16050513          	addi	a0,a0,352 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202800:	c3ffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202804:	00003697          	auipc	a3,0x3
ffffffffc0202808:	39468693          	addi	a3,a3,916 # ffffffffc0205b98 <default_pmm_manager+0x390>
ffffffffc020280c:	00003617          	auipc	a2,0x3
ffffffffc0202810:	c4c60613          	addi	a2,a2,-948 # ffffffffc0205458 <commands+0x738>
ffffffffc0202814:	1a200593          	li	a1,418
ffffffffc0202818:	00003517          	auipc	a0,0x3
ffffffffc020281c:	14050513          	addi	a0,a0,320 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202820:	c1ffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202824:	00003697          	auipc	a3,0x3
ffffffffc0202828:	2cc68693          	addi	a3,a3,716 # ffffffffc0205af0 <default_pmm_manager+0x2e8>
ffffffffc020282c:	00003617          	auipc	a2,0x3
ffffffffc0202830:	c2c60613          	addi	a2,a2,-980 # ffffffffc0205458 <commands+0x738>
ffffffffc0202834:	1b300593          	li	a1,435
ffffffffc0202838:	00003517          	auipc	a0,0x3
ffffffffc020283c:	12050513          	addi	a0,a0,288 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202840:	bfffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202844:	00003697          	auipc	a3,0x3
ffffffffc0202848:	40468693          	addi	a3,a3,1028 # ffffffffc0205c48 <default_pmm_manager+0x440>
ffffffffc020284c:	00003617          	auipc	a2,0x3
ffffffffc0202850:	c0c60613          	addi	a2,a2,-1012 # ffffffffc0205458 <commands+0x738>
ffffffffc0202854:	1af00593          	li	a1,431
ffffffffc0202858:	00003517          	auipc	a0,0x3
ffffffffc020285c:	10050513          	addi	a0,a0,256 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202860:	bdffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202864:	00003697          	auipc	a3,0x3
ffffffffc0202868:	27468693          	addi	a3,a3,628 # ffffffffc0205ad8 <default_pmm_manager+0x2d0>
ffffffffc020286c:	00003617          	auipc	a2,0x3
ffffffffc0202870:	bec60613          	addi	a2,a2,-1044 # ffffffffc0205458 <commands+0x738>
ffffffffc0202874:	1ae00593          	li	a1,430
ffffffffc0202878:	00003517          	auipc	a0,0x3
ffffffffc020287c:	0e050513          	addi	a0,a0,224 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202880:	bbffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202884:	00003617          	auipc	a2,0x3
ffffffffc0202888:	fbc60613          	addi	a2,a2,-68 # ffffffffc0205840 <default_pmm_manager+0x38>
ffffffffc020288c:	08b00593          	li	a1,139
ffffffffc0202890:	00003517          	auipc	a0,0x3
ffffffffc0202894:	fd850513          	addi	a0,a0,-40 # ffffffffc0205868 <default_pmm_manager+0x60>
ffffffffc0202898:	ba7fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020289c:	00003697          	auipc	a3,0x3
ffffffffc02028a0:	3dc68693          	addi	a3,a3,988 # ffffffffc0205c78 <default_pmm_manager+0x470>
ffffffffc02028a4:	00003617          	auipc	a2,0x3
ffffffffc02028a8:	bb460613          	addi	a2,a2,-1100 # ffffffffc0205458 <commands+0x738>
ffffffffc02028ac:	1ba00593          	li	a1,442
ffffffffc02028b0:	00003517          	auipc	a0,0x3
ffffffffc02028b4:	0a850513          	addi	a0,a0,168 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc02028b8:	b87fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02028bc:	00003697          	auipc	a3,0x3
ffffffffc02028c0:	37468693          	addi	a3,a3,884 # ffffffffc0205c30 <default_pmm_manager+0x428>
ffffffffc02028c4:	00003617          	auipc	a2,0x3
ffffffffc02028c8:	b9460613          	addi	a2,a2,-1132 # ffffffffc0205458 <commands+0x738>
ffffffffc02028cc:	1b800593          	li	a1,440
ffffffffc02028d0:	00003517          	auipc	a0,0x3
ffffffffc02028d4:	08850513          	addi	a0,a0,136 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc02028d8:	b67fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02028dc:	00003697          	auipc	a3,0x3
ffffffffc02028e0:	38468693          	addi	a3,a3,900 # ffffffffc0205c60 <default_pmm_manager+0x458>
ffffffffc02028e4:	00003617          	auipc	a2,0x3
ffffffffc02028e8:	b7460613          	addi	a2,a2,-1164 # ffffffffc0205458 <commands+0x738>
ffffffffc02028ec:	1b700593          	li	a1,439
ffffffffc02028f0:	00003517          	auipc	a0,0x3
ffffffffc02028f4:	06850513          	addi	a0,a0,104 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc02028f8:	b47fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02028fc:	00003697          	auipc	a3,0x3
ffffffffc0202900:	33468693          	addi	a3,a3,820 # ffffffffc0205c30 <default_pmm_manager+0x428>
ffffffffc0202904:	00003617          	auipc	a2,0x3
ffffffffc0202908:	b5460613          	addi	a2,a2,-1196 # ffffffffc0205458 <commands+0x738>
ffffffffc020290c:	1b400593          	li	a1,436
ffffffffc0202910:	00003517          	auipc	a0,0x3
ffffffffc0202914:	04850513          	addi	a0,a0,72 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202918:	b27fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020291c:	00003697          	auipc	a3,0x3
ffffffffc0202920:	46c68693          	addi	a3,a3,1132 # ffffffffc0205d88 <default_pmm_manager+0x580>
ffffffffc0202924:	00003617          	auipc	a2,0x3
ffffffffc0202928:	b3460613          	addi	a2,a2,-1228 # ffffffffc0205458 <commands+0x738>
ffffffffc020292c:	1d800593          	li	a1,472
ffffffffc0202930:	00003517          	auipc	a0,0x3
ffffffffc0202934:	02850513          	addi	a0,a0,40 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202938:	b07fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020293c:	00003697          	auipc	a3,0x3
ffffffffc0202940:	41468693          	addi	a3,a3,1044 # ffffffffc0205d50 <default_pmm_manager+0x548>
ffffffffc0202944:	00003617          	auipc	a2,0x3
ffffffffc0202948:	b1460613          	addi	a2,a2,-1260 # ffffffffc0205458 <commands+0x738>
ffffffffc020294c:	1d700593          	li	a1,471
ffffffffc0202950:	00003517          	auipc	a0,0x3
ffffffffc0202954:	00850513          	addi	a0,a0,8 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202958:	ae7fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020295c:	00003697          	auipc	a3,0x3
ffffffffc0202960:	3dc68693          	addi	a3,a3,988 # ffffffffc0205d38 <default_pmm_manager+0x530>
ffffffffc0202964:	00003617          	auipc	a2,0x3
ffffffffc0202968:	af460613          	addi	a2,a2,-1292 # ffffffffc0205458 <commands+0x738>
ffffffffc020296c:	1d300593          	li	a1,467
ffffffffc0202970:	00003517          	auipc	a0,0x3
ffffffffc0202974:	fe850513          	addi	a0,a0,-24 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202978:	ac7fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020297c:	00003697          	auipc	a3,0x3
ffffffffc0202980:	32468693          	addi	a3,a3,804 # ffffffffc0205ca0 <default_pmm_manager+0x498>
ffffffffc0202984:	00003617          	auipc	a2,0x3
ffffffffc0202988:	ad460613          	addi	a2,a2,-1324 # ffffffffc0205458 <commands+0x738>
ffffffffc020298c:	1c200593          	li	a1,450
ffffffffc0202990:	00003517          	auipc	a0,0x3
ffffffffc0202994:	fc850513          	addi	a0,a0,-56 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202998:	aa7fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020299c:	00003697          	auipc	a3,0x3
ffffffffc02029a0:	13c68693          	addi	a3,a3,316 # ffffffffc0205ad8 <default_pmm_manager+0x2d0>
ffffffffc02029a4:	00003617          	auipc	a2,0x3
ffffffffc02029a8:	ab460613          	addi	a2,a2,-1356 # ffffffffc0205458 <commands+0x738>
ffffffffc02029ac:	19500593          	li	a1,405
ffffffffc02029b0:	00003517          	auipc	a0,0x3
ffffffffc02029b4:	fa850513          	addi	a0,a0,-88 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc02029b8:	a87fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02029bc:	00003617          	auipc	a2,0x3
ffffffffc02029c0:	e8460613          	addi	a2,a2,-380 # ffffffffc0205840 <default_pmm_manager+0x38>
ffffffffc02029c4:	19900593          	li	a1,409
ffffffffc02029c8:	00003517          	auipc	a0,0x3
ffffffffc02029cc:	f9050513          	addi	a0,a0,-112 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc02029d0:	a6ffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02029d4:	00003697          	auipc	a3,0x3
ffffffffc02029d8:	11c68693          	addi	a3,a3,284 # ffffffffc0205af0 <default_pmm_manager+0x2e8>
ffffffffc02029dc:	00003617          	auipc	a2,0x3
ffffffffc02029e0:	a7c60613          	addi	a2,a2,-1412 # ffffffffc0205458 <commands+0x738>
ffffffffc02029e4:	19600593          	li	a1,406
ffffffffc02029e8:	00003517          	auipc	a0,0x3
ffffffffc02029ec:	f7050513          	addi	a0,a0,-144 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc02029f0:	a4ffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02029f4:	00003697          	auipc	a3,0x3
ffffffffc02029f8:	17468693          	addi	a3,a3,372 # ffffffffc0205b68 <default_pmm_manager+0x360>
ffffffffc02029fc:	00003617          	auipc	a2,0x3
ffffffffc0202a00:	a5c60613          	addi	a2,a2,-1444 # ffffffffc0205458 <commands+0x738>
ffffffffc0202a04:	1a100593          	li	a1,417
ffffffffc0202a08:	00003517          	auipc	a0,0x3
ffffffffc0202a0c:	f5050513          	addi	a0,a0,-176 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202a10:	a2ffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202a14:	00003697          	auipc	a3,0x3
ffffffffc0202a18:	43468693          	addi	a3,a3,1076 # ffffffffc0205e48 <default_pmm_manager+0x640>
ffffffffc0202a1c:	00003617          	auipc	a2,0x3
ffffffffc0202a20:	a3c60613          	addi	a2,a2,-1476 # ffffffffc0205458 <commands+0x738>
ffffffffc0202a24:	1e100593          	li	a1,481
ffffffffc0202a28:	00003517          	auipc	a0,0x3
ffffffffc0202a2c:	f3050513          	addi	a0,a0,-208 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202a30:	a0ffd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202a34:	00003697          	auipc	a3,0x3
ffffffffc0202a38:	3dc68693          	addi	a3,a3,988 # ffffffffc0205e10 <default_pmm_manager+0x608>
ffffffffc0202a3c:	00003617          	auipc	a2,0x3
ffffffffc0202a40:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0205458 <commands+0x738>
ffffffffc0202a44:	1de00593          	li	a1,478
ffffffffc0202a48:	00003517          	auipc	a0,0x3
ffffffffc0202a4c:	f1050513          	addi	a0,a0,-240 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202a50:	9effd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202a54:	00003697          	auipc	a3,0x3
ffffffffc0202a58:	38c68693          	addi	a3,a3,908 # ffffffffc0205de0 <default_pmm_manager+0x5d8>
ffffffffc0202a5c:	00003617          	auipc	a2,0x3
ffffffffc0202a60:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0205458 <commands+0x738>
ffffffffc0202a64:	1da00593          	li	a1,474
ffffffffc0202a68:	00003517          	auipc	a0,0x3
ffffffffc0202a6c:	ef050513          	addi	a0,a0,-272 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202a70:	9cffd0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0202a74 <tlb_invalidate>:
ffffffffc0202a74:	12058073          	sfence.vma	a1
ffffffffc0202a78:	8082                	ret

ffffffffc0202a7a <pgdir_alloc_page>:
ffffffffc0202a7a:	7179                	addi	sp,sp,-48
ffffffffc0202a7c:	e84a                	sd	s2,16(sp)
ffffffffc0202a7e:	892a                	mv	s2,a0
ffffffffc0202a80:	4505                	li	a0,1
ffffffffc0202a82:	ec26                	sd	s1,24(sp)
ffffffffc0202a84:	e44e                	sd	s3,8(sp)
ffffffffc0202a86:	f406                	sd	ra,40(sp)
ffffffffc0202a88:	f022                	sd	s0,32(sp)
ffffffffc0202a8a:	84ae                	mv	s1,a1
ffffffffc0202a8c:	89b2                	mv	s3,a2
ffffffffc0202a8e:	f8bfe0ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0202a92:	c131                	beqz	a0,ffffffffc0202ad6 <pgdir_alloc_page+0x5c>
ffffffffc0202a94:	842a                	mv	s0,a0
ffffffffc0202a96:	85aa                	mv	a1,a0
ffffffffc0202a98:	86ce                	mv	a3,s3
ffffffffc0202a9a:	8626                	mv	a2,s1
ffffffffc0202a9c:	854a                	mv	a0,s2
ffffffffc0202a9e:	b44ff0ef          	jal	ra,ffffffffc0201de2 <page_insert>
ffffffffc0202aa2:	ed11                	bnez	a0,ffffffffc0202abe <pgdir_alloc_page+0x44>
ffffffffc0202aa4:	00013797          	auipc	a5,0x13
ffffffffc0202aa8:	adc7a783          	lw	a5,-1316(a5) # ffffffffc0215580 <swap_init_ok>
ffffffffc0202aac:	e79d                	bnez	a5,ffffffffc0202ada <pgdir_alloc_page+0x60>
ffffffffc0202aae:	70a2                	ld	ra,40(sp)
ffffffffc0202ab0:	8522                	mv	a0,s0
ffffffffc0202ab2:	7402                	ld	s0,32(sp)
ffffffffc0202ab4:	64e2                	ld	s1,24(sp)
ffffffffc0202ab6:	6942                	ld	s2,16(sp)
ffffffffc0202ab8:	69a2                	ld	s3,8(sp)
ffffffffc0202aba:	6145                	addi	sp,sp,48
ffffffffc0202abc:	8082                	ret
ffffffffc0202abe:	100027f3          	csrr	a5,sstatus
ffffffffc0202ac2:	8b89                	andi	a5,a5,2
ffffffffc0202ac4:	eba9                	bnez	a5,ffffffffc0202b16 <pgdir_alloc_page+0x9c>
ffffffffc0202ac6:	00013797          	auipc	a5,0x13
ffffffffc0202aca:	a8a7b783          	ld	a5,-1398(a5) # ffffffffc0215550 <pmm_manager>
ffffffffc0202ace:	739c                	ld	a5,32(a5)
ffffffffc0202ad0:	4585                	li	a1,1
ffffffffc0202ad2:	8522                	mv	a0,s0
ffffffffc0202ad4:	9782                	jalr	a5
ffffffffc0202ad6:	4401                	li	s0,0
ffffffffc0202ad8:	bfd9                	j	ffffffffc0202aae <pgdir_alloc_page+0x34>
ffffffffc0202ada:	4681                	li	a3,0
ffffffffc0202adc:	8622                	mv	a2,s0
ffffffffc0202ade:	85a6                	mv	a1,s1
ffffffffc0202ae0:	00013517          	auipc	a0,0x13
ffffffffc0202ae4:	ac053503          	ld	a0,-1344(a0) # ffffffffc02155a0 <check_mm_struct>
ffffffffc0202ae8:	7aa000ef          	jal	ra,ffffffffc0203292 <swap_map_swappable>
ffffffffc0202aec:	4018                	lw	a4,0(s0)
ffffffffc0202aee:	fc04                	sd	s1,56(s0)
ffffffffc0202af0:	4785                	li	a5,1
ffffffffc0202af2:	faf70ee3          	beq	a4,a5,ffffffffc0202aae <pgdir_alloc_page+0x34>
ffffffffc0202af6:	00003697          	auipc	a3,0x3
ffffffffc0202afa:	39a68693          	addi	a3,a3,922 # ffffffffc0205e90 <default_pmm_manager+0x688>
ffffffffc0202afe:	00003617          	auipc	a2,0x3
ffffffffc0202b02:	95a60613          	addi	a2,a2,-1702 # ffffffffc0205458 <commands+0x738>
ffffffffc0202b06:	16800593          	li	a1,360
ffffffffc0202b0a:	00003517          	auipc	a0,0x3
ffffffffc0202b0e:	e4e50513          	addi	a0,a0,-434 # ffffffffc0205958 <default_pmm_manager+0x150>
ffffffffc0202b12:	92dfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202b16:	aa5fd0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc0202b1a:	00013797          	auipc	a5,0x13
ffffffffc0202b1e:	a367b783          	ld	a5,-1482(a5) # ffffffffc0215550 <pmm_manager>
ffffffffc0202b22:	739c                	ld	a5,32(a5)
ffffffffc0202b24:	8522                	mv	a0,s0
ffffffffc0202b26:	4585                	li	a1,1
ffffffffc0202b28:	9782                	jalr	a5
ffffffffc0202b2a:	4401                	li	s0,0
ffffffffc0202b2c:	a89fd0ef          	jal	ra,ffffffffc02005b4 <intr_enable>
ffffffffc0202b30:	bfbd                	j	ffffffffc0202aae <pgdir_alloc_page+0x34>

ffffffffc0202b32 <pa2page.part.0>:
ffffffffc0202b32:	1141                	addi	sp,sp,-16
ffffffffc0202b34:	00003617          	auipc	a2,0x3
ffffffffc0202b38:	ddc60613          	addi	a2,a2,-548 # ffffffffc0205910 <default_pmm_manager+0x108>
ffffffffc0202b3c:	08000593          	li	a1,128
ffffffffc0202b40:	00003517          	auipc	a0,0x3
ffffffffc0202b44:	d2850513          	addi	a0,a0,-728 # ffffffffc0205868 <default_pmm_manager+0x60>
ffffffffc0202b48:	e406                	sd	ra,8(sp)
ffffffffc0202b4a:	8f5fd0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0202b4e <swap_init>:
ffffffffc0202b4e:	7135                	addi	sp,sp,-160
ffffffffc0202b50:	ed06                	sd	ra,152(sp)
ffffffffc0202b52:	e922                	sd	s0,144(sp)
ffffffffc0202b54:	e526                	sd	s1,136(sp)
ffffffffc0202b56:	e14a                	sd	s2,128(sp)
ffffffffc0202b58:	fcce                	sd	s3,120(sp)
ffffffffc0202b5a:	f8d2                	sd	s4,112(sp)
ffffffffc0202b5c:	f4d6                	sd	s5,104(sp)
ffffffffc0202b5e:	f0da                	sd	s6,96(sp)
ffffffffc0202b60:	ecde                	sd	s7,88(sp)
ffffffffc0202b62:	e8e2                	sd	s8,80(sp)
ffffffffc0202b64:	e4e6                	sd	s9,72(sp)
ffffffffc0202b66:	e0ea                	sd	s10,64(sp)
ffffffffc0202b68:	fc6e                	sd	s11,56(sp)
ffffffffc0202b6a:	57a010ef          	jal	ra,ffffffffc02040e4 <swapfs_init>
ffffffffc0202b6e:	00013697          	auipc	a3,0x13
ffffffffc0202b72:	a1a6b683          	ld	a3,-1510(a3) # ffffffffc0215588 <max_swap_offset>
ffffffffc0202b76:	010007b7          	lui	a5,0x1000
ffffffffc0202b7a:	ff968713          	addi	a4,a3,-7
ffffffffc0202b7e:	17e1                	addi	a5,a5,-8
ffffffffc0202b80:	40e7ef63          	bltu	a5,a4,ffffffffc0202f9e <swap_init+0x450>
ffffffffc0202b84:	00007797          	auipc	a5,0x7
ffffffffc0202b88:	48c78793          	addi	a5,a5,1164 # ffffffffc020a010 <swap_manager_fifo>
ffffffffc0202b8c:	6798                	ld	a4,8(a5)
ffffffffc0202b8e:	00013b17          	auipc	s6,0x13
ffffffffc0202b92:	a02b0b13          	addi	s6,s6,-1534 # ffffffffc0215590 <sm>
ffffffffc0202b96:	00fb3023          	sd	a5,0(s6)
ffffffffc0202b9a:	9702                	jalr	a4
ffffffffc0202b9c:	892a                	mv	s2,a0
ffffffffc0202b9e:	c10d                	beqz	a0,ffffffffc0202bc0 <swap_init+0x72>
ffffffffc0202ba0:	60ea                	ld	ra,152(sp)
ffffffffc0202ba2:	644a                	ld	s0,144(sp)
ffffffffc0202ba4:	64aa                	ld	s1,136(sp)
ffffffffc0202ba6:	79e6                	ld	s3,120(sp)
ffffffffc0202ba8:	7a46                	ld	s4,112(sp)
ffffffffc0202baa:	7aa6                	ld	s5,104(sp)
ffffffffc0202bac:	7b06                	ld	s6,96(sp)
ffffffffc0202bae:	6be6                	ld	s7,88(sp)
ffffffffc0202bb0:	6c46                	ld	s8,80(sp)
ffffffffc0202bb2:	6ca6                	ld	s9,72(sp)
ffffffffc0202bb4:	6d06                	ld	s10,64(sp)
ffffffffc0202bb6:	7de2                	ld	s11,56(sp)
ffffffffc0202bb8:	854a                	mv	a0,s2
ffffffffc0202bba:	690a                	ld	s2,128(sp)
ffffffffc0202bbc:	610d                	addi	sp,sp,160
ffffffffc0202bbe:	8082                	ret
ffffffffc0202bc0:	000b3783          	ld	a5,0(s6)
ffffffffc0202bc4:	00003517          	auipc	a0,0x3
ffffffffc0202bc8:	31450513          	addi	a0,a0,788 # ffffffffc0205ed8 <default_pmm_manager+0x6d0>
ffffffffc0202bcc:	0000f417          	auipc	s0,0xf
ffffffffc0202bd0:	88c40413          	addi	s0,s0,-1908 # ffffffffc0211458 <free_area>
ffffffffc0202bd4:	638c                	ld	a1,0(a5)
ffffffffc0202bd6:	4785                	li	a5,1
ffffffffc0202bd8:	00013717          	auipc	a4,0x13
ffffffffc0202bdc:	9af72423          	sw	a5,-1624(a4) # ffffffffc0215580 <swap_init_ok>
ffffffffc0202be0:	daafd0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0202be4:	641c                	ld	a5,8(s0)
ffffffffc0202be6:	4d81                	li	s11,0
ffffffffc0202be8:	4d01                	li	s10,0
ffffffffc0202bea:	32878a63          	beq	a5,s0,ffffffffc0202f1e <swap_init+0x3d0>
ffffffffc0202bee:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202bf2:	8b09                	andi	a4,a4,2
ffffffffc0202bf4:	32070763          	beqz	a4,ffffffffc0202f22 <swap_init+0x3d4>
ffffffffc0202bf8:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202bfc:	679c                	ld	a5,8(a5)
ffffffffc0202bfe:	2d05                	addiw	s10,s10,1
ffffffffc0202c00:	01b70dbb          	addw	s11,a4,s11
ffffffffc0202c04:	fe8795e3          	bne	a5,s0,ffffffffc0202bee <swap_init+0xa0>
ffffffffc0202c08:	84ee                	mv	s1,s11
ffffffffc0202c0a:	edffe0ef          	jal	ra,ffffffffc0201ae8 <nr_free_pages>
ffffffffc0202c0e:	42951063          	bne	a0,s1,ffffffffc020302e <swap_init+0x4e0>
ffffffffc0202c12:	866e                	mv	a2,s11
ffffffffc0202c14:	85ea                	mv	a1,s10
ffffffffc0202c16:	00003517          	auipc	a0,0x3
ffffffffc0202c1a:	2da50513          	addi	a0,a0,730 # ffffffffc0205ef0 <default_pmm_manager+0x6e8>
ffffffffc0202c1e:	d6cfd0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0202c22:	411000ef          	jal	ra,ffffffffc0203832 <mm_create>
ffffffffc0202c26:	e82a                	sd	a0,16(sp)
ffffffffc0202c28:	46050363          	beqz	a0,ffffffffc020308e <swap_init+0x540>
ffffffffc0202c2c:	00013797          	auipc	a5,0x13
ffffffffc0202c30:	97478793          	addi	a5,a5,-1676 # ffffffffc02155a0 <check_mm_struct>
ffffffffc0202c34:	6398                	ld	a4,0(a5)
ffffffffc0202c36:	3c071c63          	bnez	a4,ffffffffc020300e <swap_init+0x4c0>
ffffffffc0202c3a:	00013717          	auipc	a4,0x13
ffffffffc0202c3e:	92670713          	addi	a4,a4,-1754 # ffffffffc0215560 <boot_pgdir>
ffffffffc0202c42:	00073a83          	ld	s5,0(a4)
ffffffffc0202c46:	6742                	ld	a4,16(sp)
ffffffffc0202c48:	e398                	sd	a4,0(a5)
ffffffffc0202c4a:	000ab783          	ld	a5,0(s5) # fffffffffffff000 <end+0x3fde9a38>
ffffffffc0202c4e:	01573c23          	sd	s5,24(a4)
ffffffffc0202c52:	40079e63          	bnez	a5,ffffffffc020306e <swap_init+0x520>
ffffffffc0202c56:	6599                	lui	a1,0x6
ffffffffc0202c58:	460d                	li	a2,3
ffffffffc0202c5a:	6505                	lui	a0,0x1
ffffffffc0202c5c:	41f000ef          	jal	ra,ffffffffc020387a <vma_create>
ffffffffc0202c60:	85aa                	mv	a1,a0
ffffffffc0202c62:	52050263          	beqz	a0,ffffffffc0203186 <swap_init+0x638>
ffffffffc0202c66:	64c2                	ld	s1,16(sp)
ffffffffc0202c68:	8526                	mv	a0,s1
ffffffffc0202c6a:	47f000ef          	jal	ra,ffffffffc02038e8 <insert_vma_struct>
ffffffffc0202c6e:	00003517          	auipc	a0,0x3
ffffffffc0202c72:	2f250513          	addi	a0,a0,754 # ffffffffc0205f60 <default_pmm_manager+0x758>
ffffffffc0202c76:	d14fd0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0202c7a:	6c88                	ld	a0,24(s1)
ffffffffc0202c7c:	4605                	li	a2,1
ffffffffc0202c7e:	6585                	lui	a1,0x1
ffffffffc0202c80:	ea3fe0ef          	jal	ra,ffffffffc0201b22 <get_pte>
ffffffffc0202c84:	4c050163          	beqz	a0,ffffffffc0203146 <swap_init+0x5f8>
ffffffffc0202c88:	00003517          	auipc	a0,0x3
ffffffffc0202c8c:	32850513          	addi	a0,a0,808 # ffffffffc0205fb0 <default_pmm_manager+0x7a8>
ffffffffc0202c90:	0000f497          	auipc	s1,0xf
ffffffffc0202c94:	80048493          	addi	s1,s1,-2048 # ffffffffc0211490 <check_rp>
ffffffffc0202c98:	cf2fd0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0202c9c:	0000f997          	auipc	s3,0xf
ffffffffc0202ca0:	81498993          	addi	s3,s3,-2028 # ffffffffc02114b0 <swap_out_seq_no>
ffffffffc0202ca4:	8ba6                	mv	s7,s1
ffffffffc0202ca6:	4505                	li	a0,1
ffffffffc0202ca8:	d71fe0ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc0202cac:	00abb023          	sd	a0,0(s7)
ffffffffc0202cb0:	2c050763          	beqz	a0,ffffffffc0202f7e <swap_init+0x430>
ffffffffc0202cb4:	651c                	ld	a5,8(a0)
ffffffffc0202cb6:	8b89                	andi	a5,a5,2
ffffffffc0202cb8:	32079b63          	bnez	a5,ffffffffc0202fee <swap_init+0x4a0>
ffffffffc0202cbc:	0ba1                	addi	s7,s7,8
ffffffffc0202cbe:	ff3b94e3          	bne	s7,s3,ffffffffc0202ca6 <swap_init+0x158>
ffffffffc0202cc2:	601c                	ld	a5,0(s0)
ffffffffc0202cc4:	0000eb97          	auipc	s7,0xe
ffffffffc0202cc8:	7ccb8b93          	addi	s7,s7,1996 # ffffffffc0211490 <check_rp>
ffffffffc0202ccc:	e000                	sd	s0,0(s0)
ffffffffc0202cce:	f43e                	sd	a5,40(sp)
ffffffffc0202cd0:	641c                	ld	a5,8(s0)
ffffffffc0202cd2:	e400                	sd	s0,8(s0)
ffffffffc0202cd4:	f03e                	sd	a5,32(sp)
ffffffffc0202cd6:	481c                	lw	a5,16(s0)
ffffffffc0202cd8:	ec3e                	sd	a5,24(sp)
ffffffffc0202cda:	0000e797          	auipc	a5,0xe
ffffffffc0202cde:	7807a723          	sw	zero,1934(a5) # ffffffffc0211468 <free_area+0x10>
ffffffffc0202ce2:	000bb503          	ld	a0,0(s7)
ffffffffc0202ce6:	4585                	li	a1,1
ffffffffc0202ce8:	0ba1                	addi	s7,s7,8
ffffffffc0202cea:	dbffe0ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0202cee:	ff3b9ae3          	bne	s7,s3,ffffffffc0202ce2 <swap_init+0x194>
ffffffffc0202cf2:	01042b83          	lw	s7,16(s0)
ffffffffc0202cf6:	4791                	li	a5,4
ffffffffc0202cf8:	42fb9763          	bne	s7,a5,ffffffffc0203126 <swap_init+0x5d8>
ffffffffc0202cfc:	00003517          	auipc	a0,0x3
ffffffffc0202d00:	33c50513          	addi	a0,a0,828 # ffffffffc0206038 <default_pmm_manager+0x830>
ffffffffc0202d04:	c86fd0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0202d08:	6685                	lui	a3,0x1
ffffffffc0202d0a:	00013797          	auipc	a5,0x13
ffffffffc0202d0e:	8807a723          	sw	zero,-1906(a5) # ffffffffc0215598 <pgfault_num>
ffffffffc0202d12:	4629                	li	a2,10
ffffffffc0202d14:	00c68023          	sb	a2,0(a3) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0202d18:	00013717          	auipc	a4,0x13
ffffffffc0202d1c:	88072703          	lw	a4,-1920(a4) # ffffffffc0215598 <pgfault_num>
ffffffffc0202d20:	4585                	li	a1,1
ffffffffc0202d22:	00013797          	auipc	a5,0x13
ffffffffc0202d26:	87678793          	addi	a5,a5,-1930 # ffffffffc0215598 <pgfault_num>
ffffffffc0202d2a:	52b71e63          	bne	a4,a1,ffffffffc0203266 <swap_init+0x718>
ffffffffc0202d2e:	00c68823          	sb	a2,16(a3)
ffffffffc0202d32:	4394                	lw	a3,0(a5)
ffffffffc0202d34:	3ce69963          	bne	a3,a4,ffffffffc0203106 <swap_init+0x5b8>
ffffffffc0202d38:	6709                	lui	a4,0x2
ffffffffc0202d3a:	46ad                	li	a3,11
ffffffffc0202d3c:	00d70023          	sb	a3,0(a4) # 2000 <kern_entry-0xffffffffc01fe000>
ffffffffc0202d40:	4390                	lw	a2,0(a5)
ffffffffc0202d42:	4509                	li	a0,2
ffffffffc0202d44:	0006059b          	sext.w	a1,a2
ffffffffc0202d48:	48a61f63          	bne	a2,a0,ffffffffc02031e6 <swap_init+0x698>
ffffffffc0202d4c:	00d70823          	sb	a3,16(a4)
ffffffffc0202d50:	4398                	lw	a4,0(a5)
ffffffffc0202d52:	4ab71a63          	bne	a4,a1,ffffffffc0203206 <swap_init+0x6b8>
ffffffffc0202d56:	670d                	lui	a4,0x3
ffffffffc0202d58:	46b1                	li	a3,12
ffffffffc0202d5a:	00d70023          	sb	a3,0(a4) # 3000 <kern_entry-0xffffffffc01fd000>
ffffffffc0202d5e:	4390                	lw	a2,0(a5)
ffffffffc0202d60:	450d                	li	a0,3
ffffffffc0202d62:	0006059b          	sext.w	a1,a2
ffffffffc0202d66:	4ca61063          	bne	a2,a0,ffffffffc0203226 <swap_init+0x6d8>
ffffffffc0202d6a:	00d70823          	sb	a3,16(a4)
ffffffffc0202d6e:	4398                	lw	a4,0(a5)
ffffffffc0202d70:	4cb71b63          	bne	a4,a1,ffffffffc0203246 <swap_init+0x6f8>
ffffffffc0202d74:	6711                	lui	a4,0x4
ffffffffc0202d76:	46b5                	li	a3,13
ffffffffc0202d78:	00d70023          	sb	a3,0(a4) # 4000 <kern_entry-0xffffffffc01fc000>
ffffffffc0202d7c:	4390                	lw	a2,0(a5)
ffffffffc0202d7e:	0006059b          	sext.w	a1,a2
ffffffffc0202d82:	43761263          	bne	a2,s7,ffffffffc02031a6 <swap_init+0x658>
ffffffffc0202d86:	00d70823          	sb	a3,16(a4)
ffffffffc0202d8a:	439c                	lw	a5,0(a5)
ffffffffc0202d8c:	42b79d63          	bne	a5,a1,ffffffffc02031c6 <swap_init+0x678>
ffffffffc0202d90:	481c                	lw	a5,16(s0)
ffffffffc0202d92:	2a079e63          	bnez	a5,ffffffffc020304e <swap_init+0x500>
ffffffffc0202d96:	0000e797          	auipc	a5,0xe
ffffffffc0202d9a:	74278793          	addi	a5,a5,1858 # ffffffffc02114d8 <swap_in_seq_no>
ffffffffc0202d9e:	0000e717          	auipc	a4,0xe
ffffffffc0202da2:	71270713          	addi	a4,a4,1810 # ffffffffc02114b0 <swap_out_seq_no>
ffffffffc0202da6:	0000e617          	auipc	a2,0xe
ffffffffc0202daa:	75a60613          	addi	a2,a2,1882 # ffffffffc0211500 <pra_list_head>
ffffffffc0202dae:	56fd                	li	a3,-1
ffffffffc0202db0:	c394                	sw	a3,0(a5)
ffffffffc0202db2:	c314                	sw	a3,0(a4)
ffffffffc0202db4:	0791                	addi	a5,a5,4
ffffffffc0202db6:	0711                	addi	a4,a4,4
ffffffffc0202db8:	fec79ce3          	bne	a5,a2,ffffffffc0202db0 <swap_init+0x262>
ffffffffc0202dbc:	0000e717          	auipc	a4,0xe
ffffffffc0202dc0:	6b470713          	addi	a4,a4,1716 # ffffffffc0211470 <check_ptep>
ffffffffc0202dc4:	0000e697          	auipc	a3,0xe
ffffffffc0202dc8:	6cc68693          	addi	a3,a3,1740 # ffffffffc0211490 <check_rp>
ffffffffc0202dcc:	6a05                	lui	s4,0x1
ffffffffc0202dce:	00012b97          	auipc	s7,0x12
ffffffffc0202dd2:	7a2b8b93          	addi	s7,s7,1954 # ffffffffc0215570 <npage>
ffffffffc0202dd6:	00012c17          	auipc	s8,0x12
ffffffffc0202dda:	7a2c0c13          	addi	s8,s8,1954 # ffffffffc0215578 <pages>
ffffffffc0202dde:	00004c97          	auipc	s9,0x4
ffffffffc0202de2:	d92c8c93          	addi	s9,s9,-622 # ffffffffc0206b70 <nbase>
ffffffffc0202de6:	00073023          	sd	zero,0(a4)
ffffffffc0202dea:	4601                	li	a2,0
ffffffffc0202dec:	85d2                	mv	a1,s4
ffffffffc0202dee:	8556                	mv	a0,s5
ffffffffc0202df0:	e436                	sd	a3,8(sp)
ffffffffc0202df2:	e03a                	sd	a4,0(sp)
ffffffffc0202df4:	d2ffe0ef          	jal	ra,ffffffffc0201b22 <get_pte>
ffffffffc0202df8:	6702                	ld	a4,0(sp)
ffffffffc0202dfa:	66a2                	ld	a3,8(sp)
ffffffffc0202dfc:	e308                	sd	a0,0(a4)
ffffffffc0202dfe:	1a050c63          	beqz	a0,ffffffffc0202fb6 <swap_init+0x468>
ffffffffc0202e02:	611c                	ld	a5,0(a0)
ffffffffc0202e04:	0017f613          	andi	a2,a5,1
ffffffffc0202e08:	1c060763          	beqz	a2,ffffffffc0202fd6 <swap_init+0x488>
ffffffffc0202e0c:	000bb603          	ld	a2,0(s7)
ffffffffc0202e10:	078a                	slli	a5,a5,0x2
ffffffffc0202e12:	83b1                	srli	a5,a5,0xc
ffffffffc0202e14:	12c7f963          	bgeu	a5,a2,ffffffffc0202f46 <swap_init+0x3f8>
ffffffffc0202e18:	000cb303          	ld	t1,0(s9)
ffffffffc0202e1c:	000c3603          	ld	a2,0(s8)
ffffffffc0202e20:	6288                	ld	a0,0(a3)
ffffffffc0202e22:	406787b3          	sub	a5,a5,t1
ffffffffc0202e26:	079a                	slli	a5,a5,0x6
ffffffffc0202e28:	97b2                	add	a5,a5,a2
ffffffffc0202e2a:	6605                	lui	a2,0x1
ffffffffc0202e2c:	06a1                	addi	a3,a3,8
ffffffffc0202e2e:	0721                	addi	a4,a4,8
ffffffffc0202e30:	9a32                	add	s4,s4,a2
ffffffffc0202e32:	12f51663          	bne	a0,a5,ffffffffc0202f5e <swap_init+0x410>
ffffffffc0202e36:	6795                	lui	a5,0x5
ffffffffc0202e38:	fafa17e3          	bne	s4,a5,ffffffffc0202de6 <swap_init+0x298>
ffffffffc0202e3c:	00003517          	auipc	a0,0x3
ffffffffc0202e40:	2a450513          	addi	a0,a0,676 # ffffffffc02060e0 <default_pmm_manager+0x8d8>
ffffffffc0202e44:	b46fd0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0202e48:	000b3783          	ld	a5,0(s6)
ffffffffc0202e4c:	7f9c                	ld	a5,56(a5)
ffffffffc0202e4e:	9782                	jalr	a5
ffffffffc0202e50:	30051b63          	bnez	a0,ffffffffc0203166 <swap_init+0x618>
ffffffffc0202e54:	67e2                	ld	a5,24(sp)
ffffffffc0202e56:	c81c                	sw	a5,16(s0)
ffffffffc0202e58:	77a2                	ld	a5,40(sp)
ffffffffc0202e5a:	e01c                	sd	a5,0(s0)
ffffffffc0202e5c:	7782                	ld	a5,32(sp)
ffffffffc0202e5e:	e41c                	sd	a5,8(s0)
ffffffffc0202e60:	6088                	ld	a0,0(s1)
ffffffffc0202e62:	4585                	li	a1,1
ffffffffc0202e64:	04a1                	addi	s1,s1,8
ffffffffc0202e66:	c43fe0ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0202e6a:	ff349be3          	bne	s1,s3,ffffffffc0202e60 <swap_init+0x312>
ffffffffc0202e6e:	6542                	ld	a0,16(sp)
ffffffffc0202e70:	349000ef          	jal	ra,ffffffffc02039b8 <mm_destroy>
ffffffffc0202e74:	00012797          	auipc	a5,0x12
ffffffffc0202e78:	6ec78793          	addi	a5,a5,1772 # ffffffffc0215560 <boot_pgdir>
ffffffffc0202e7c:	639c                	ld	a5,0(a5)
ffffffffc0202e7e:	000bb703          	ld	a4,0(s7)
ffffffffc0202e82:	639c                	ld	a5,0(a5)
ffffffffc0202e84:	078a                	slli	a5,a5,0x2
ffffffffc0202e86:	83b1                	srli	a5,a5,0xc
ffffffffc0202e88:	0ae7fd63          	bgeu	a5,a4,ffffffffc0202f42 <swap_init+0x3f4>
ffffffffc0202e8c:	000cb483          	ld	s1,0(s9)
ffffffffc0202e90:	000c3503          	ld	a0,0(s8)
ffffffffc0202e94:	409786b3          	sub	a3,a5,s1
ffffffffc0202e98:	069a                	slli	a3,a3,0x6
ffffffffc0202e9a:	8699                	srai	a3,a3,0x6
ffffffffc0202e9c:	96a6                	add	a3,a3,s1
ffffffffc0202e9e:	00c69793          	slli	a5,a3,0xc
ffffffffc0202ea2:	83b1                	srli	a5,a5,0xc
ffffffffc0202ea4:	06b2                	slli	a3,a3,0xc
ffffffffc0202ea6:	22e7f463          	bgeu	a5,a4,ffffffffc02030ce <swap_init+0x580>
ffffffffc0202eaa:	00012797          	auipc	a5,0x12
ffffffffc0202eae:	6be7b783          	ld	a5,1726(a5) # ffffffffc0215568 <va_pa_offset>
ffffffffc0202eb2:	97b6                	add	a5,a5,a3
ffffffffc0202eb4:	639c                	ld	a5,0(a5)
ffffffffc0202eb6:	078a                	slli	a5,a5,0x2
ffffffffc0202eb8:	83b1                	srli	a5,a5,0xc
ffffffffc0202eba:	08e7f463          	bgeu	a5,a4,ffffffffc0202f42 <swap_init+0x3f4>
ffffffffc0202ebe:	8f85                	sub	a5,a5,s1
ffffffffc0202ec0:	079a                	slli	a5,a5,0x6
ffffffffc0202ec2:	953e                	add	a0,a0,a5
ffffffffc0202ec4:	4585                	li	a1,1
ffffffffc0202ec6:	be3fe0ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0202eca:	000ab783          	ld	a5,0(s5)
ffffffffc0202ece:	000bb703          	ld	a4,0(s7)
ffffffffc0202ed2:	078a                	slli	a5,a5,0x2
ffffffffc0202ed4:	83b1                	srli	a5,a5,0xc
ffffffffc0202ed6:	06e7f663          	bgeu	a5,a4,ffffffffc0202f42 <swap_init+0x3f4>
ffffffffc0202eda:	000c3503          	ld	a0,0(s8)
ffffffffc0202ede:	8f85                	sub	a5,a5,s1
ffffffffc0202ee0:	079a                	slli	a5,a5,0x6
ffffffffc0202ee2:	4585                	li	a1,1
ffffffffc0202ee4:	953e                	add	a0,a0,a5
ffffffffc0202ee6:	bc3fe0ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0202eea:	000ab023          	sd	zero,0(s5)
ffffffffc0202eee:	12000073          	sfence.vma
ffffffffc0202ef2:	641c                	ld	a5,8(s0)
ffffffffc0202ef4:	00878a63          	beq	a5,s0,ffffffffc0202f08 <swap_init+0x3ba>
ffffffffc0202ef8:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202efc:	679c                	ld	a5,8(a5)
ffffffffc0202efe:	3d7d                	addiw	s10,s10,-1
ffffffffc0202f00:	40ed8dbb          	subw	s11,s11,a4
ffffffffc0202f04:	fe879ae3          	bne	a5,s0,ffffffffc0202ef8 <swap_init+0x3aa>
ffffffffc0202f08:	1c0d1f63          	bnez	s10,ffffffffc02030e6 <swap_init+0x598>
ffffffffc0202f0c:	1a0d9163          	bnez	s11,ffffffffc02030ae <swap_init+0x560>
ffffffffc0202f10:	00003517          	auipc	a0,0x3
ffffffffc0202f14:	22050513          	addi	a0,a0,544 # ffffffffc0206130 <default_pmm_manager+0x928>
ffffffffc0202f18:	a72fd0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0202f1c:	b151                	j	ffffffffc0202ba0 <swap_init+0x52>
ffffffffc0202f1e:	4481                	li	s1,0
ffffffffc0202f20:	b1ed                	j	ffffffffc0202c0a <swap_init+0xbc>
ffffffffc0202f22:	00002697          	auipc	a3,0x2
ffffffffc0202f26:	52668693          	addi	a3,a3,1318 # ffffffffc0205448 <commands+0x728>
ffffffffc0202f2a:	00002617          	auipc	a2,0x2
ffffffffc0202f2e:	52e60613          	addi	a2,a2,1326 # ffffffffc0205458 <commands+0x738>
ffffffffc0202f32:	0cf00593          	li	a1,207
ffffffffc0202f36:	00003517          	auipc	a0,0x3
ffffffffc0202f3a:	f9250513          	addi	a0,a0,-110 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc0202f3e:	d00fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202f42:	bf1ff0ef          	jal	ra,ffffffffc0202b32 <pa2page.part.0>
ffffffffc0202f46:	00003617          	auipc	a2,0x3
ffffffffc0202f4a:	9ca60613          	addi	a2,a2,-1590 # ffffffffc0205910 <default_pmm_manager+0x108>
ffffffffc0202f4e:	08000593          	li	a1,128
ffffffffc0202f52:	00003517          	auipc	a0,0x3
ffffffffc0202f56:	91650513          	addi	a0,a0,-1770 # ffffffffc0205868 <default_pmm_manager+0x60>
ffffffffc0202f5a:	ce4fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202f5e:	00003697          	auipc	a3,0x3
ffffffffc0202f62:	15a68693          	addi	a3,a3,346 # ffffffffc02060b8 <default_pmm_manager+0x8b0>
ffffffffc0202f66:	00002617          	auipc	a2,0x2
ffffffffc0202f6a:	4f260613          	addi	a2,a2,1266 # ffffffffc0205458 <commands+0x738>
ffffffffc0202f6e:	11200593          	li	a1,274
ffffffffc0202f72:	00003517          	auipc	a0,0x3
ffffffffc0202f76:	f5650513          	addi	a0,a0,-170 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc0202f7a:	cc4fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202f7e:	00003697          	auipc	a3,0x3
ffffffffc0202f82:	05a68693          	addi	a3,a3,90 # ffffffffc0205fd8 <default_pmm_manager+0x7d0>
ffffffffc0202f86:	00002617          	auipc	a2,0x2
ffffffffc0202f8a:	4d260613          	addi	a2,a2,1234 # ffffffffc0205458 <commands+0x738>
ffffffffc0202f8e:	0f100593          	li	a1,241
ffffffffc0202f92:	00003517          	auipc	a0,0x3
ffffffffc0202f96:	f3650513          	addi	a0,a0,-202 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc0202f9a:	ca4fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202f9e:	00003617          	auipc	a2,0x3
ffffffffc0202fa2:	f0a60613          	addi	a2,a2,-246 # ffffffffc0205ea8 <default_pmm_manager+0x6a0>
ffffffffc0202fa6:	02c00593          	li	a1,44
ffffffffc0202faa:	00003517          	auipc	a0,0x3
ffffffffc0202fae:	f1e50513          	addi	a0,a0,-226 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc0202fb2:	c8cfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202fb6:	00003697          	auipc	a3,0x3
ffffffffc0202fba:	0ea68693          	addi	a3,a3,234 # ffffffffc02060a0 <default_pmm_manager+0x898>
ffffffffc0202fbe:	00002617          	auipc	a2,0x2
ffffffffc0202fc2:	49a60613          	addi	a2,a2,1178 # ffffffffc0205458 <commands+0x738>
ffffffffc0202fc6:	11100593          	li	a1,273
ffffffffc0202fca:	00003517          	auipc	a0,0x3
ffffffffc0202fce:	efe50513          	addi	a0,a0,-258 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc0202fd2:	c6cfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202fd6:	00003617          	auipc	a2,0x3
ffffffffc0202fda:	95a60613          	addi	a2,a2,-1702 # ffffffffc0205930 <default_pmm_manager+0x128>
ffffffffc0202fde:	09f00593          	li	a1,159
ffffffffc0202fe2:	00003517          	auipc	a0,0x3
ffffffffc0202fe6:	88650513          	addi	a0,a0,-1914 # ffffffffc0205868 <default_pmm_manager+0x60>
ffffffffc0202fea:	c54fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0202fee:	00003697          	auipc	a3,0x3
ffffffffc0202ff2:	00268693          	addi	a3,a3,2 # ffffffffc0205ff0 <default_pmm_manager+0x7e8>
ffffffffc0202ff6:	00002617          	auipc	a2,0x2
ffffffffc0202ffa:	46260613          	addi	a2,a2,1122 # ffffffffc0205458 <commands+0x738>
ffffffffc0202ffe:	0f200593          	li	a1,242
ffffffffc0203002:	00003517          	auipc	a0,0x3
ffffffffc0203006:	ec650513          	addi	a0,a0,-314 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc020300a:	c34fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020300e:	00003697          	auipc	a3,0x3
ffffffffc0203012:	f1a68693          	addi	a3,a3,-230 # ffffffffc0205f28 <default_pmm_manager+0x720>
ffffffffc0203016:	00002617          	auipc	a2,0x2
ffffffffc020301a:	44260613          	addi	a2,a2,1090 # ffffffffc0205458 <commands+0x738>
ffffffffc020301e:	0da00593          	li	a1,218
ffffffffc0203022:	00003517          	auipc	a0,0x3
ffffffffc0203026:	ea650513          	addi	a0,a0,-346 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc020302a:	c14fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020302e:	00002697          	auipc	a3,0x2
ffffffffc0203032:	45a68693          	addi	a3,a3,1114 # ffffffffc0205488 <commands+0x768>
ffffffffc0203036:	00002617          	auipc	a2,0x2
ffffffffc020303a:	42260613          	addi	a2,a2,1058 # ffffffffc0205458 <commands+0x738>
ffffffffc020303e:	0d200593          	li	a1,210
ffffffffc0203042:	00003517          	auipc	a0,0x3
ffffffffc0203046:	e8650513          	addi	a0,a0,-378 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc020304a:	bf4fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020304e:	00002697          	auipc	a3,0x2
ffffffffc0203052:	5e268693          	addi	a3,a3,1506 # ffffffffc0205630 <commands+0x910>
ffffffffc0203056:	00002617          	auipc	a2,0x2
ffffffffc020305a:	40260613          	addi	a2,a2,1026 # ffffffffc0205458 <commands+0x738>
ffffffffc020305e:	10900593          	li	a1,265
ffffffffc0203062:	00003517          	auipc	a0,0x3
ffffffffc0203066:	e6650513          	addi	a0,a0,-410 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc020306a:	bd4fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020306e:	00003697          	auipc	a3,0x3
ffffffffc0203072:	ed268693          	addi	a3,a3,-302 # ffffffffc0205f40 <default_pmm_manager+0x738>
ffffffffc0203076:	00002617          	auipc	a2,0x2
ffffffffc020307a:	3e260613          	addi	a2,a2,994 # ffffffffc0205458 <commands+0x738>
ffffffffc020307e:	0df00593          	li	a1,223
ffffffffc0203082:	00003517          	auipc	a0,0x3
ffffffffc0203086:	e4650513          	addi	a0,a0,-442 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc020308a:	bb4fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020308e:	00003697          	auipc	a3,0x3
ffffffffc0203092:	e8a68693          	addi	a3,a3,-374 # ffffffffc0205f18 <default_pmm_manager+0x710>
ffffffffc0203096:	00002617          	auipc	a2,0x2
ffffffffc020309a:	3c260613          	addi	a2,a2,962 # ffffffffc0205458 <commands+0x738>
ffffffffc020309e:	0d700593          	li	a1,215
ffffffffc02030a2:	00003517          	auipc	a0,0x3
ffffffffc02030a6:	e2650513          	addi	a0,a0,-474 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc02030aa:	b94fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02030ae:	00003697          	auipc	a3,0x3
ffffffffc02030b2:	07268693          	addi	a3,a3,114 # ffffffffc0206120 <default_pmm_manager+0x918>
ffffffffc02030b6:	00002617          	auipc	a2,0x2
ffffffffc02030ba:	3a260613          	addi	a2,a2,930 # ffffffffc0205458 <commands+0x738>
ffffffffc02030be:	13200593          	li	a1,306
ffffffffc02030c2:	00003517          	auipc	a0,0x3
ffffffffc02030c6:	e0650513          	addi	a0,a0,-506 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc02030ca:	b74fd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02030ce:	00002617          	auipc	a2,0x2
ffffffffc02030d2:	77260613          	addi	a2,a2,1906 # ffffffffc0205840 <default_pmm_manager+0x38>
ffffffffc02030d6:	08b00593          	li	a1,139
ffffffffc02030da:	00002517          	auipc	a0,0x2
ffffffffc02030de:	78e50513          	addi	a0,a0,1934 # ffffffffc0205868 <default_pmm_manager+0x60>
ffffffffc02030e2:	b5cfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02030e6:	00003697          	auipc	a3,0x3
ffffffffc02030ea:	02a68693          	addi	a3,a3,42 # ffffffffc0206110 <default_pmm_manager+0x908>
ffffffffc02030ee:	00002617          	auipc	a2,0x2
ffffffffc02030f2:	36a60613          	addi	a2,a2,874 # ffffffffc0205458 <commands+0x738>
ffffffffc02030f6:	13100593          	li	a1,305
ffffffffc02030fa:	00003517          	auipc	a0,0x3
ffffffffc02030fe:	dce50513          	addi	a0,a0,-562 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc0203102:	b3cfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203106:	00003697          	auipc	a3,0x3
ffffffffc020310a:	f5a68693          	addi	a3,a3,-166 # ffffffffc0206060 <default_pmm_manager+0x858>
ffffffffc020310e:	00002617          	auipc	a2,0x2
ffffffffc0203112:	34a60613          	addi	a2,a2,842 # ffffffffc0205458 <commands+0x738>
ffffffffc0203116:	0a300593          	li	a1,163
ffffffffc020311a:	00003517          	auipc	a0,0x3
ffffffffc020311e:	dae50513          	addi	a0,a0,-594 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc0203122:	b1cfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203126:	00003697          	auipc	a3,0x3
ffffffffc020312a:	eea68693          	addi	a3,a3,-278 # ffffffffc0206010 <default_pmm_manager+0x808>
ffffffffc020312e:	00002617          	auipc	a2,0x2
ffffffffc0203132:	32a60613          	addi	a2,a2,810 # ffffffffc0205458 <commands+0x738>
ffffffffc0203136:	10000593          	li	a1,256
ffffffffc020313a:	00003517          	auipc	a0,0x3
ffffffffc020313e:	d8e50513          	addi	a0,a0,-626 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc0203142:	afcfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203146:	00003697          	auipc	a3,0x3
ffffffffc020314a:	e5268693          	addi	a3,a3,-430 # ffffffffc0205f98 <default_pmm_manager+0x790>
ffffffffc020314e:	00002617          	auipc	a2,0x2
ffffffffc0203152:	30a60613          	addi	a2,a2,778 # ffffffffc0205458 <commands+0x738>
ffffffffc0203156:	0eb00593          	li	a1,235
ffffffffc020315a:	00003517          	auipc	a0,0x3
ffffffffc020315e:	d6e50513          	addi	a0,a0,-658 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc0203162:	adcfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203166:	00003697          	auipc	a3,0x3
ffffffffc020316a:	fa268693          	addi	a3,a3,-94 # ffffffffc0206108 <default_pmm_manager+0x900>
ffffffffc020316e:	00002617          	auipc	a2,0x2
ffffffffc0203172:	2ea60613          	addi	a2,a2,746 # ffffffffc0205458 <commands+0x738>
ffffffffc0203176:	11800593          	li	a1,280
ffffffffc020317a:	00003517          	auipc	a0,0x3
ffffffffc020317e:	d4e50513          	addi	a0,a0,-690 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc0203182:	abcfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203186:	00003697          	auipc	a3,0x3
ffffffffc020318a:	dca68693          	addi	a3,a3,-566 # ffffffffc0205f50 <default_pmm_manager+0x748>
ffffffffc020318e:	00002617          	auipc	a2,0x2
ffffffffc0203192:	2ca60613          	addi	a2,a2,714 # ffffffffc0205458 <commands+0x738>
ffffffffc0203196:	0e300593          	li	a1,227
ffffffffc020319a:	00003517          	auipc	a0,0x3
ffffffffc020319e:	d2e50513          	addi	a0,a0,-722 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc02031a2:	a9cfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02031a6:	00003697          	auipc	a3,0x3
ffffffffc02031aa:	eea68693          	addi	a3,a3,-278 # ffffffffc0206090 <default_pmm_manager+0x888>
ffffffffc02031ae:	00002617          	auipc	a2,0x2
ffffffffc02031b2:	2aa60613          	addi	a2,a2,682 # ffffffffc0205458 <commands+0x738>
ffffffffc02031b6:	0ad00593          	li	a1,173
ffffffffc02031ba:	00003517          	auipc	a0,0x3
ffffffffc02031be:	d0e50513          	addi	a0,a0,-754 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc02031c2:	a7cfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02031c6:	00003697          	auipc	a3,0x3
ffffffffc02031ca:	eca68693          	addi	a3,a3,-310 # ffffffffc0206090 <default_pmm_manager+0x888>
ffffffffc02031ce:	00002617          	auipc	a2,0x2
ffffffffc02031d2:	28a60613          	addi	a2,a2,650 # ffffffffc0205458 <commands+0x738>
ffffffffc02031d6:	0af00593          	li	a1,175
ffffffffc02031da:	00003517          	auipc	a0,0x3
ffffffffc02031de:	cee50513          	addi	a0,a0,-786 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc02031e2:	a5cfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02031e6:	00003697          	auipc	a3,0x3
ffffffffc02031ea:	e8a68693          	addi	a3,a3,-374 # ffffffffc0206070 <default_pmm_manager+0x868>
ffffffffc02031ee:	00002617          	auipc	a2,0x2
ffffffffc02031f2:	26a60613          	addi	a2,a2,618 # ffffffffc0205458 <commands+0x738>
ffffffffc02031f6:	0a500593          	li	a1,165
ffffffffc02031fa:	00003517          	auipc	a0,0x3
ffffffffc02031fe:	cce50513          	addi	a0,a0,-818 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc0203202:	a3cfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203206:	00003697          	auipc	a3,0x3
ffffffffc020320a:	e6a68693          	addi	a3,a3,-406 # ffffffffc0206070 <default_pmm_manager+0x868>
ffffffffc020320e:	00002617          	auipc	a2,0x2
ffffffffc0203212:	24a60613          	addi	a2,a2,586 # ffffffffc0205458 <commands+0x738>
ffffffffc0203216:	0a700593          	li	a1,167
ffffffffc020321a:	00003517          	auipc	a0,0x3
ffffffffc020321e:	cae50513          	addi	a0,a0,-850 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc0203222:	a1cfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203226:	00003697          	auipc	a3,0x3
ffffffffc020322a:	e5a68693          	addi	a3,a3,-422 # ffffffffc0206080 <default_pmm_manager+0x878>
ffffffffc020322e:	00002617          	auipc	a2,0x2
ffffffffc0203232:	22a60613          	addi	a2,a2,554 # ffffffffc0205458 <commands+0x738>
ffffffffc0203236:	0a900593          	li	a1,169
ffffffffc020323a:	00003517          	auipc	a0,0x3
ffffffffc020323e:	c8e50513          	addi	a0,a0,-882 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc0203242:	9fcfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203246:	00003697          	auipc	a3,0x3
ffffffffc020324a:	e3a68693          	addi	a3,a3,-454 # ffffffffc0206080 <default_pmm_manager+0x878>
ffffffffc020324e:	00002617          	auipc	a2,0x2
ffffffffc0203252:	20a60613          	addi	a2,a2,522 # ffffffffc0205458 <commands+0x738>
ffffffffc0203256:	0ab00593          	li	a1,171
ffffffffc020325a:	00003517          	auipc	a0,0x3
ffffffffc020325e:	c6e50513          	addi	a0,a0,-914 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc0203262:	9dcfd0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203266:	00003697          	auipc	a3,0x3
ffffffffc020326a:	dfa68693          	addi	a3,a3,-518 # ffffffffc0206060 <default_pmm_manager+0x858>
ffffffffc020326e:	00002617          	auipc	a2,0x2
ffffffffc0203272:	1ea60613          	addi	a2,a2,490 # ffffffffc0205458 <commands+0x738>
ffffffffc0203276:	0a100593          	li	a1,161
ffffffffc020327a:	00003517          	auipc	a0,0x3
ffffffffc020327e:	c4e50513          	addi	a0,a0,-946 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc0203282:	9bcfd0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0203286 <swap_init_mm>:
ffffffffc0203286:	00012797          	auipc	a5,0x12
ffffffffc020328a:	30a7b783          	ld	a5,778(a5) # ffffffffc0215590 <sm>
ffffffffc020328e:	6b9c                	ld	a5,16(a5)
ffffffffc0203290:	8782                	jr	a5

ffffffffc0203292 <swap_map_swappable>:
ffffffffc0203292:	00012797          	auipc	a5,0x12
ffffffffc0203296:	2fe7b783          	ld	a5,766(a5) # ffffffffc0215590 <sm>
ffffffffc020329a:	739c                	ld	a5,32(a5)
ffffffffc020329c:	8782                	jr	a5

ffffffffc020329e <swap_out>:
ffffffffc020329e:	711d                	addi	sp,sp,-96
ffffffffc02032a0:	ec86                	sd	ra,88(sp)
ffffffffc02032a2:	e8a2                	sd	s0,80(sp)
ffffffffc02032a4:	e4a6                	sd	s1,72(sp)
ffffffffc02032a6:	e0ca                	sd	s2,64(sp)
ffffffffc02032a8:	fc4e                	sd	s3,56(sp)
ffffffffc02032aa:	f852                	sd	s4,48(sp)
ffffffffc02032ac:	f456                	sd	s5,40(sp)
ffffffffc02032ae:	f05a                	sd	s6,32(sp)
ffffffffc02032b0:	ec5e                	sd	s7,24(sp)
ffffffffc02032b2:	e862                	sd	s8,16(sp)
ffffffffc02032b4:	cde9                	beqz	a1,ffffffffc020338e <swap_out+0xf0>
ffffffffc02032b6:	8a2e                	mv	s4,a1
ffffffffc02032b8:	892a                	mv	s2,a0
ffffffffc02032ba:	8ab2                	mv	s5,a2
ffffffffc02032bc:	4401                	li	s0,0
ffffffffc02032be:	00012997          	auipc	s3,0x12
ffffffffc02032c2:	2d298993          	addi	s3,s3,722 # ffffffffc0215590 <sm>
ffffffffc02032c6:	00003b17          	auipc	s6,0x3
ffffffffc02032ca:	eeab0b13          	addi	s6,s6,-278 # ffffffffc02061b0 <default_pmm_manager+0x9a8>
ffffffffc02032ce:	00003b97          	auipc	s7,0x3
ffffffffc02032d2:	ecab8b93          	addi	s7,s7,-310 # ffffffffc0206198 <default_pmm_manager+0x990>
ffffffffc02032d6:	a825                	j	ffffffffc020330e <swap_out+0x70>
ffffffffc02032d8:	67a2                	ld	a5,8(sp)
ffffffffc02032da:	8626                	mv	a2,s1
ffffffffc02032dc:	85a2                	mv	a1,s0
ffffffffc02032de:	7f94                	ld	a3,56(a5)
ffffffffc02032e0:	855a                	mv	a0,s6
ffffffffc02032e2:	2405                	addiw	s0,s0,1
ffffffffc02032e4:	82b1                	srli	a3,a3,0xc
ffffffffc02032e6:	0685                	addi	a3,a3,1
ffffffffc02032e8:	ea3fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02032ec:	6522                	ld	a0,8(sp)
ffffffffc02032ee:	4585                	li	a1,1
ffffffffc02032f0:	7d1c                	ld	a5,56(a0)
ffffffffc02032f2:	83b1                	srli	a5,a5,0xc
ffffffffc02032f4:	0785                	addi	a5,a5,1
ffffffffc02032f6:	07a2                	slli	a5,a5,0x8
ffffffffc02032f8:	00fc3023          	sd	a5,0(s8)
ffffffffc02032fc:	facfe0ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0203300:	01893503          	ld	a0,24(s2)
ffffffffc0203304:	85a6                	mv	a1,s1
ffffffffc0203306:	f6eff0ef          	jal	ra,ffffffffc0202a74 <tlb_invalidate>
ffffffffc020330a:	048a0d63          	beq	s4,s0,ffffffffc0203364 <swap_out+0xc6>
ffffffffc020330e:	0009b783          	ld	a5,0(s3)
ffffffffc0203312:	8656                	mv	a2,s5
ffffffffc0203314:	002c                	addi	a1,sp,8
ffffffffc0203316:	7b9c                	ld	a5,48(a5)
ffffffffc0203318:	854a                	mv	a0,s2
ffffffffc020331a:	9782                	jalr	a5
ffffffffc020331c:	e12d                	bnez	a0,ffffffffc020337e <swap_out+0xe0>
ffffffffc020331e:	67a2                	ld	a5,8(sp)
ffffffffc0203320:	01893503          	ld	a0,24(s2)
ffffffffc0203324:	4601                	li	a2,0
ffffffffc0203326:	7f84                	ld	s1,56(a5)
ffffffffc0203328:	85a6                	mv	a1,s1
ffffffffc020332a:	ff8fe0ef          	jal	ra,ffffffffc0201b22 <get_pte>
ffffffffc020332e:	611c                	ld	a5,0(a0)
ffffffffc0203330:	8c2a                	mv	s8,a0
ffffffffc0203332:	8b85                	andi	a5,a5,1
ffffffffc0203334:	cfb9                	beqz	a5,ffffffffc0203392 <swap_out+0xf4>
ffffffffc0203336:	65a2                	ld	a1,8(sp)
ffffffffc0203338:	7d9c                	ld	a5,56(a1)
ffffffffc020333a:	83b1                	srli	a5,a5,0xc
ffffffffc020333c:	0785                	addi	a5,a5,1
ffffffffc020333e:	00879513          	slli	a0,a5,0x8
ffffffffc0203342:	669000ef          	jal	ra,ffffffffc02041aa <swapfs_write>
ffffffffc0203346:	d949                	beqz	a0,ffffffffc02032d8 <swap_out+0x3a>
ffffffffc0203348:	855e                	mv	a0,s7
ffffffffc020334a:	e41fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020334e:	0009b783          	ld	a5,0(s3)
ffffffffc0203352:	6622                	ld	a2,8(sp)
ffffffffc0203354:	4681                	li	a3,0
ffffffffc0203356:	739c                	ld	a5,32(a5)
ffffffffc0203358:	85a6                	mv	a1,s1
ffffffffc020335a:	854a                	mv	a0,s2
ffffffffc020335c:	2405                	addiw	s0,s0,1
ffffffffc020335e:	9782                	jalr	a5
ffffffffc0203360:	fa8a17e3          	bne	s4,s0,ffffffffc020330e <swap_out+0x70>
ffffffffc0203364:	60e6                	ld	ra,88(sp)
ffffffffc0203366:	8522                	mv	a0,s0
ffffffffc0203368:	6446                	ld	s0,80(sp)
ffffffffc020336a:	64a6                	ld	s1,72(sp)
ffffffffc020336c:	6906                	ld	s2,64(sp)
ffffffffc020336e:	79e2                	ld	s3,56(sp)
ffffffffc0203370:	7a42                	ld	s4,48(sp)
ffffffffc0203372:	7aa2                	ld	s5,40(sp)
ffffffffc0203374:	7b02                	ld	s6,32(sp)
ffffffffc0203376:	6be2                	ld	s7,24(sp)
ffffffffc0203378:	6c42                	ld	s8,16(sp)
ffffffffc020337a:	6125                	addi	sp,sp,96
ffffffffc020337c:	8082                	ret
ffffffffc020337e:	85a2                	mv	a1,s0
ffffffffc0203380:	00003517          	auipc	a0,0x3
ffffffffc0203384:	dd050513          	addi	a0,a0,-560 # ffffffffc0206150 <default_pmm_manager+0x948>
ffffffffc0203388:	e03fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020338c:	bfe1                	j	ffffffffc0203364 <swap_out+0xc6>
ffffffffc020338e:	4401                	li	s0,0
ffffffffc0203390:	bfd1                	j	ffffffffc0203364 <swap_out+0xc6>
ffffffffc0203392:	00003697          	auipc	a3,0x3
ffffffffc0203396:	dee68693          	addi	a3,a3,-530 # ffffffffc0206180 <default_pmm_manager+0x978>
ffffffffc020339a:	00002617          	auipc	a2,0x2
ffffffffc020339e:	0be60613          	addi	a2,a2,190 # ffffffffc0205458 <commands+0x738>
ffffffffc02033a2:	06c00593          	li	a1,108
ffffffffc02033a6:	00003517          	auipc	a0,0x3
ffffffffc02033aa:	b2250513          	addi	a0,a0,-1246 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc02033ae:	890fd0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc02033b2 <swap_in>:
ffffffffc02033b2:	7179                	addi	sp,sp,-48
ffffffffc02033b4:	e84a                	sd	s2,16(sp)
ffffffffc02033b6:	892a                	mv	s2,a0
ffffffffc02033b8:	4505                	li	a0,1
ffffffffc02033ba:	ec26                	sd	s1,24(sp)
ffffffffc02033bc:	e44e                	sd	s3,8(sp)
ffffffffc02033be:	f406                	sd	ra,40(sp)
ffffffffc02033c0:	f022                	sd	s0,32(sp)
ffffffffc02033c2:	84ae                	mv	s1,a1
ffffffffc02033c4:	89b2                	mv	s3,a2
ffffffffc02033c6:	e52fe0ef          	jal	ra,ffffffffc0201a18 <alloc_pages>
ffffffffc02033ca:	c129                	beqz	a0,ffffffffc020340c <swap_in+0x5a>
ffffffffc02033cc:	842a                	mv	s0,a0
ffffffffc02033ce:	01893503          	ld	a0,24(s2)
ffffffffc02033d2:	4601                	li	a2,0
ffffffffc02033d4:	85a6                	mv	a1,s1
ffffffffc02033d6:	f4cfe0ef          	jal	ra,ffffffffc0201b22 <get_pte>
ffffffffc02033da:	892a                	mv	s2,a0
ffffffffc02033dc:	6108                	ld	a0,0(a0)
ffffffffc02033de:	85a2                	mv	a1,s0
ffffffffc02033e0:	53d000ef          	jal	ra,ffffffffc020411c <swapfs_read>
ffffffffc02033e4:	00093583          	ld	a1,0(s2)
ffffffffc02033e8:	8626                	mv	a2,s1
ffffffffc02033ea:	00003517          	auipc	a0,0x3
ffffffffc02033ee:	e1650513          	addi	a0,a0,-490 # ffffffffc0206200 <default_pmm_manager+0x9f8>
ffffffffc02033f2:	81a1                	srli	a1,a1,0x8
ffffffffc02033f4:	d97fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02033f8:	70a2                	ld	ra,40(sp)
ffffffffc02033fa:	0089b023          	sd	s0,0(s3)
ffffffffc02033fe:	7402                	ld	s0,32(sp)
ffffffffc0203400:	64e2                	ld	s1,24(sp)
ffffffffc0203402:	6942                	ld	s2,16(sp)
ffffffffc0203404:	69a2                	ld	s3,8(sp)
ffffffffc0203406:	4501                	li	a0,0
ffffffffc0203408:	6145                	addi	sp,sp,48
ffffffffc020340a:	8082                	ret
ffffffffc020340c:	00003697          	auipc	a3,0x3
ffffffffc0203410:	de468693          	addi	a3,a3,-540 # ffffffffc02061f0 <default_pmm_manager+0x9e8>
ffffffffc0203414:	00002617          	auipc	a2,0x2
ffffffffc0203418:	04460613          	addi	a2,a2,68 # ffffffffc0205458 <commands+0x738>
ffffffffc020341c:	08900593          	li	a1,137
ffffffffc0203420:	00003517          	auipc	a0,0x3
ffffffffc0203424:	aa850513          	addi	a0,a0,-1368 # ffffffffc0205ec8 <default_pmm_manager+0x6c0>
ffffffffc0203428:	816fd0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc020342c <_fifo_init_mm>:
ffffffffc020342c:	0000e797          	auipc	a5,0xe
ffffffffc0203430:	0d478793          	addi	a5,a5,212 # ffffffffc0211500 <pra_list_head>
ffffffffc0203434:	f51c                	sd	a5,40(a0)
ffffffffc0203436:	e79c                	sd	a5,8(a5)
ffffffffc0203438:	e39c                	sd	a5,0(a5)
ffffffffc020343a:	4501                	li	a0,0
ffffffffc020343c:	8082                	ret

ffffffffc020343e <_fifo_init>:
ffffffffc020343e:	4501                	li	a0,0
ffffffffc0203440:	8082                	ret

ffffffffc0203442 <_fifo_set_unswappable>:
ffffffffc0203442:	4501                	li	a0,0
ffffffffc0203444:	8082                	ret

ffffffffc0203446 <_fifo_tick_event>:
ffffffffc0203446:	4501                	li	a0,0
ffffffffc0203448:	8082                	ret

ffffffffc020344a <_fifo_check_swap>:
ffffffffc020344a:	711d                	addi	sp,sp,-96
ffffffffc020344c:	fc4e                	sd	s3,56(sp)
ffffffffc020344e:	f852                	sd	s4,48(sp)
ffffffffc0203450:	00003517          	auipc	a0,0x3
ffffffffc0203454:	df050513          	addi	a0,a0,-528 # ffffffffc0206240 <default_pmm_manager+0xa38>
ffffffffc0203458:	698d                	lui	s3,0x3
ffffffffc020345a:	4a31                	li	s4,12
ffffffffc020345c:	e4a6                	sd	s1,72(sp)
ffffffffc020345e:	ec86                	sd	ra,88(sp)
ffffffffc0203460:	e8a2                	sd	s0,80(sp)
ffffffffc0203462:	e0ca                	sd	s2,64(sp)
ffffffffc0203464:	f456                	sd	s5,40(sp)
ffffffffc0203466:	f05a                	sd	s6,32(sp)
ffffffffc0203468:	ec5e                	sd	s7,24(sp)
ffffffffc020346a:	e862                	sd	s8,16(sp)
ffffffffc020346c:	e466                	sd	s9,8(sp)
ffffffffc020346e:	d1dfc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0203472:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
ffffffffc0203476:	00012497          	auipc	s1,0x12
ffffffffc020347a:	1224a483          	lw	s1,290(s1) # ffffffffc0215598 <pgfault_num>
ffffffffc020347e:	4791                	li	a5,4
ffffffffc0203480:	14f49963          	bne	s1,a5,ffffffffc02035d2 <_fifo_check_swap+0x188>
ffffffffc0203484:	00003517          	auipc	a0,0x3
ffffffffc0203488:	dfc50513          	addi	a0,a0,-516 # ffffffffc0206280 <default_pmm_manager+0xa78>
ffffffffc020348c:	6a85                	lui	s5,0x1
ffffffffc020348e:	4b29                	li	s6,10
ffffffffc0203490:	cfbfc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0203494:	00012417          	auipc	s0,0x12
ffffffffc0203498:	10440413          	addi	s0,s0,260 # ffffffffc0215598 <pgfault_num>
ffffffffc020349c:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02034a0:	401c                	lw	a5,0(s0)
ffffffffc02034a2:	0007891b          	sext.w	s2,a5
ffffffffc02034a6:	2a979663          	bne	a5,s1,ffffffffc0203752 <_fifo_check_swap+0x308>
ffffffffc02034aa:	00003517          	auipc	a0,0x3
ffffffffc02034ae:	dfe50513          	addi	a0,a0,-514 # ffffffffc02062a8 <default_pmm_manager+0xaa0>
ffffffffc02034b2:	6b91                	lui	s7,0x4
ffffffffc02034b4:	4c35                	li	s8,13
ffffffffc02034b6:	cd5fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02034ba:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
ffffffffc02034be:	401c                	lw	a5,0(s0)
ffffffffc02034c0:	00078c9b          	sext.w	s9,a5
ffffffffc02034c4:	27279763          	bne	a5,s2,ffffffffc0203732 <_fifo_check_swap+0x2e8>
ffffffffc02034c8:	00003517          	auipc	a0,0x3
ffffffffc02034cc:	e0850513          	addi	a0,a0,-504 # ffffffffc02062d0 <default_pmm_manager+0xac8>
ffffffffc02034d0:	6489                	lui	s1,0x2
ffffffffc02034d2:	492d                	li	s2,11
ffffffffc02034d4:	cb7fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02034d8:	01248023          	sb	s2,0(s1) # 2000 <kern_entry-0xffffffffc01fe000>
ffffffffc02034dc:	401c                	lw	a5,0(s0)
ffffffffc02034de:	23979a63          	bne	a5,s9,ffffffffc0203712 <_fifo_check_swap+0x2c8>
ffffffffc02034e2:	00003517          	auipc	a0,0x3
ffffffffc02034e6:	e1650513          	addi	a0,a0,-490 # ffffffffc02062f8 <default_pmm_manager+0xaf0>
ffffffffc02034ea:	ca1fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02034ee:	6795                	lui	a5,0x5
ffffffffc02034f0:	4739                	li	a4,14
ffffffffc02034f2:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
ffffffffc02034f6:	401c                	lw	a5,0(s0)
ffffffffc02034f8:	4715                	li	a4,5
ffffffffc02034fa:	00078c9b          	sext.w	s9,a5
ffffffffc02034fe:	1ee79a63          	bne	a5,a4,ffffffffc02036f2 <_fifo_check_swap+0x2a8>
ffffffffc0203502:	00003517          	auipc	a0,0x3
ffffffffc0203506:	dce50513          	addi	a0,a0,-562 # ffffffffc02062d0 <default_pmm_manager+0xac8>
ffffffffc020350a:	c81fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020350e:	01248023          	sb	s2,0(s1)
ffffffffc0203512:	401c                	lw	a5,0(s0)
ffffffffc0203514:	1b979f63          	bne	a5,s9,ffffffffc02036d2 <_fifo_check_swap+0x288>
ffffffffc0203518:	00003517          	auipc	a0,0x3
ffffffffc020351c:	d6850513          	addi	a0,a0,-664 # ffffffffc0206280 <default_pmm_manager+0xa78>
ffffffffc0203520:	c6bfc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0203524:	016a8023          	sb	s6,0(s5)
ffffffffc0203528:	4018                	lw	a4,0(s0)
ffffffffc020352a:	4799                	li	a5,6
ffffffffc020352c:	18f71363          	bne	a4,a5,ffffffffc02036b2 <_fifo_check_swap+0x268>
ffffffffc0203530:	00003517          	auipc	a0,0x3
ffffffffc0203534:	da050513          	addi	a0,a0,-608 # ffffffffc02062d0 <default_pmm_manager+0xac8>
ffffffffc0203538:	c53fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020353c:	01248023          	sb	s2,0(s1)
ffffffffc0203540:	4018                	lw	a4,0(s0)
ffffffffc0203542:	479d                	li	a5,7
ffffffffc0203544:	14f71763          	bne	a4,a5,ffffffffc0203692 <_fifo_check_swap+0x248>
ffffffffc0203548:	00003517          	auipc	a0,0x3
ffffffffc020354c:	cf850513          	addi	a0,a0,-776 # ffffffffc0206240 <default_pmm_manager+0xa38>
ffffffffc0203550:	c3bfc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0203554:	01498023          	sb	s4,0(s3)
ffffffffc0203558:	4018                	lw	a4,0(s0)
ffffffffc020355a:	47a1                	li	a5,8
ffffffffc020355c:	10f71b63          	bne	a4,a5,ffffffffc0203672 <_fifo_check_swap+0x228>
ffffffffc0203560:	00003517          	auipc	a0,0x3
ffffffffc0203564:	d4850513          	addi	a0,a0,-696 # ffffffffc02062a8 <default_pmm_manager+0xaa0>
ffffffffc0203568:	c23fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020356c:	018b8023          	sb	s8,0(s7)
ffffffffc0203570:	4018                	lw	a4,0(s0)
ffffffffc0203572:	47a5                	li	a5,9
ffffffffc0203574:	0cf71f63          	bne	a4,a5,ffffffffc0203652 <_fifo_check_swap+0x208>
ffffffffc0203578:	00003517          	auipc	a0,0x3
ffffffffc020357c:	d8050513          	addi	a0,a0,-640 # ffffffffc02062f8 <default_pmm_manager+0xaf0>
ffffffffc0203580:	c0bfc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0203584:	6795                	lui	a5,0x5
ffffffffc0203586:	4739                	li	a4,14
ffffffffc0203588:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
ffffffffc020358c:	401c                	lw	a5,0(s0)
ffffffffc020358e:	4729                	li	a4,10
ffffffffc0203590:	0007849b          	sext.w	s1,a5
ffffffffc0203594:	08e79f63          	bne	a5,a4,ffffffffc0203632 <_fifo_check_swap+0x1e8>
ffffffffc0203598:	00003517          	auipc	a0,0x3
ffffffffc020359c:	ce850513          	addi	a0,a0,-792 # ffffffffc0206280 <default_pmm_manager+0xa78>
ffffffffc02035a0:	bebfc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02035a4:	6785                	lui	a5,0x1
ffffffffc02035a6:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02035aa:	06979463          	bne	a5,s1,ffffffffc0203612 <_fifo_check_swap+0x1c8>
ffffffffc02035ae:	4018                	lw	a4,0(s0)
ffffffffc02035b0:	47ad                	li	a5,11
ffffffffc02035b2:	04f71063          	bne	a4,a5,ffffffffc02035f2 <_fifo_check_swap+0x1a8>
ffffffffc02035b6:	60e6                	ld	ra,88(sp)
ffffffffc02035b8:	6446                	ld	s0,80(sp)
ffffffffc02035ba:	64a6                	ld	s1,72(sp)
ffffffffc02035bc:	6906                	ld	s2,64(sp)
ffffffffc02035be:	79e2                	ld	s3,56(sp)
ffffffffc02035c0:	7a42                	ld	s4,48(sp)
ffffffffc02035c2:	7aa2                	ld	s5,40(sp)
ffffffffc02035c4:	7b02                	ld	s6,32(sp)
ffffffffc02035c6:	6be2                	ld	s7,24(sp)
ffffffffc02035c8:	6c42                	ld	s8,16(sp)
ffffffffc02035ca:	6ca2                	ld	s9,8(sp)
ffffffffc02035cc:	4501                	li	a0,0
ffffffffc02035ce:	6125                	addi	sp,sp,96
ffffffffc02035d0:	8082                	ret
ffffffffc02035d2:	00003697          	auipc	a3,0x3
ffffffffc02035d6:	abe68693          	addi	a3,a3,-1346 # ffffffffc0206090 <default_pmm_manager+0x888>
ffffffffc02035da:	00002617          	auipc	a2,0x2
ffffffffc02035de:	e7e60613          	addi	a2,a2,-386 # ffffffffc0205458 <commands+0x738>
ffffffffc02035e2:	05b00593          	li	a1,91
ffffffffc02035e6:	00003517          	auipc	a0,0x3
ffffffffc02035ea:	c8250513          	addi	a0,a0,-894 # ffffffffc0206268 <default_pmm_manager+0xa60>
ffffffffc02035ee:	e51fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02035f2:	00003697          	auipc	a3,0x3
ffffffffc02035f6:	db668693          	addi	a3,a3,-586 # ffffffffc02063a8 <default_pmm_manager+0xba0>
ffffffffc02035fa:	00002617          	auipc	a2,0x2
ffffffffc02035fe:	e5e60613          	addi	a2,a2,-418 # ffffffffc0205458 <commands+0x738>
ffffffffc0203602:	07d00593          	li	a1,125
ffffffffc0203606:	00003517          	auipc	a0,0x3
ffffffffc020360a:	c6250513          	addi	a0,a0,-926 # ffffffffc0206268 <default_pmm_manager+0xa60>
ffffffffc020360e:	e31fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203612:	00003697          	auipc	a3,0x3
ffffffffc0203616:	d6e68693          	addi	a3,a3,-658 # ffffffffc0206380 <default_pmm_manager+0xb78>
ffffffffc020361a:	00002617          	auipc	a2,0x2
ffffffffc020361e:	e3e60613          	addi	a2,a2,-450 # ffffffffc0205458 <commands+0x738>
ffffffffc0203622:	07b00593          	li	a1,123
ffffffffc0203626:	00003517          	auipc	a0,0x3
ffffffffc020362a:	c4250513          	addi	a0,a0,-958 # ffffffffc0206268 <default_pmm_manager+0xa60>
ffffffffc020362e:	e11fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203632:	00003697          	auipc	a3,0x3
ffffffffc0203636:	d3e68693          	addi	a3,a3,-706 # ffffffffc0206370 <default_pmm_manager+0xb68>
ffffffffc020363a:	00002617          	auipc	a2,0x2
ffffffffc020363e:	e1e60613          	addi	a2,a2,-482 # ffffffffc0205458 <commands+0x738>
ffffffffc0203642:	07900593          	li	a1,121
ffffffffc0203646:	00003517          	auipc	a0,0x3
ffffffffc020364a:	c2250513          	addi	a0,a0,-990 # ffffffffc0206268 <default_pmm_manager+0xa60>
ffffffffc020364e:	df1fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203652:	00003697          	auipc	a3,0x3
ffffffffc0203656:	d0e68693          	addi	a3,a3,-754 # ffffffffc0206360 <default_pmm_manager+0xb58>
ffffffffc020365a:	00002617          	auipc	a2,0x2
ffffffffc020365e:	dfe60613          	addi	a2,a2,-514 # ffffffffc0205458 <commands+0x738>
ffffffffc0203662:	07600593          	li	a1,118
ffffffffc0203666:	00003517          	auipc	a0,0x3
ffffffffc020366a:	c0250513          	addi	a0,a0,-1022 # ffffffffc0206268 <default_pmm_manager+0xa60>
ffffffffc020366e:	dd1fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203672:	00003697          	auipc	a3,0x3
ffffffffc0203676:	cde68693          	addi	a3,a3,-802 # ffffffffc0206350 <default_pmm_manager+0xb48>
ffffffffc020367a:	00002617          	auipc	a2,0x2
ffffffffc020367e:	dde60613          	addi	a2,a2,-546 # ffffffffc0205458 <commands+0x738>
ffffffffc0203682:	07300593          	li	a1,115
ffffffffc0203686:	00003517          	auipc	a0,0x3
ffffffffc020368a:	be250513          	addi	a0,a0,-1054 # ffffffffc0206268 <default_pmm_manager+0xa60>
ffffffffc020368e:	db1fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203692:	00003697          	auipc	a3,0x3
ffffffffc0203696:	cae68693          	addi	a3,a3,-850 # ffffffffc0206340 <default_pmm_manager+0xb38>
ffffffffc020369a:	00002617          	auipc	a2,0x2
ffffffffc020369e:	dbe60613          	addi	a2,a2,-578 # ffffffffc0205458 <commands+0x738>
ffffffffc02036a2:	07000593          	li	a1,112
ffffffffc02036a6:	00003517          	auipc	a0,0x3
ffffffffc02036aa:	bc250513          	addi	a0,a0,-1086 # ffffffffc0206268 <default_pmm_manager+0xa60>
ffffffffc02036ae:	d91fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02036b2:	00003697          	auipc	a3,0x3
ffffffffc02036b6:	c7e68693          	addi	a3,a3,-898 # ffffffffc0206330 <default_pmm_manager+0xb28>
ffffffffc02036ba:	00002617          	auipc	a2,0x2
ffffffffc02036be:	d9e60613          	addi	a2,a2,-610 # ffffffffc0205458 <commands+0x738>
ffffffffc02036c2:	06d00593          	li	a1,109
ffffffffc02036c6:	00003517          	auipc	a0,0x3
ffffffffc02036ca:	ba250513          	addi	a0,a0,-1118 # ffffffffc0206268 <default_pmm_manager+0xa60>
ffffffffc02036ce:	d71fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02036d2:	00003697          	auipc	a3,0x3
ffffffffc02036d6:	c4e68693          	addi	a3,a3,-946 # ffffffffc0206320 <default_pmm_manager+0xb18>
ffffffffc02036da:	00002617          	auipc	a2,0x2
ffffffffc02036de:	d7e60613          	addi	a2,a2,-642 # ffffffffc0205458 <commands+0x738>
ffffffffc02036e2:	06a00593          	li	a1,106
ffffffffc02036e6:	00003517          	auipc	a0,0x3
ffffffffc02036ea:	b8250513          	addi	a0,a0,-1150 # ffffffffc0206268 <default_pmm_manager+0xa60>
ffffffffc02036ee:	d51fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02036f2:	00003697          	auipc	a3,0x3
ffffffffc02036f6:	c2e68693          	addi	a3,a3,-978 # ffffffffc0206320 <default_pmm_manager+0xb18>
ffffffffc02036fa:	00002617          	auipc	a2,0x2
ffffffffc02036fe:	d5e60613          	addi	a2,a2,-674 # ffffffffc0205458 <commands+0x738>
ffffffffc0203702:	06700593          	li	a1,103
ffffffffc0203706:	00003517          	auipc	a0,0x3
ffffffffc020370a:	b6250513          	addi	a0,a0,-1182 # ffffffffc0206268 <default_pmm_manager+0xa60>
ffffffffc020370e:	d31fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203712:	00003697          	auipc	a3,0x3
ffffffffc0203716:	97e68693          	addi	a3,a3,-1666 # ffffffffc0206090 <default_pmm_manager+0x888>
ffffffffc020371a:	00002617          	auipc	a2,0x2
ffffffffc020371e:	d3e60613          	addi	a2,a2,-706 # ffffffffc0205458 <commands+0x738>
ffffffffc0203722:	06400593          	li	a1,100
ffffffffc0203726:	00003517          	auipc	a0,0x3
ffffffffc020372a:	b4250513          	addi	a0,a0,-1214 # ffffffffc0206268 <default_pmm_manager+0xa60>
ffffffffc020372e:	d11fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203732:	00003697          	auipc	a3,0x3
ffffffffc0203736:	95e68693          	addi	a3,a3,-1698 # ffffffffc0206090 <default_pmm_manager+0x888>
ffffffffc020373a:	00002617          	auipc	a2,0x2
ffffffffc020373e:	d1e60613          	addi	a2,a2,-738 # ffffffffc0205458 <commands+0x738>
ffffffffc0203742:	06100593          	li	a1,97
ffffffffc0203746:	00003517          	auipc	a0,0x3
ffffffffc020374a:	b2250513          	addi	a0,a0,-1246 # ffffffffc0206268 <default_pmm_manager+0xa60>
ffffffffc020374e:	cf1fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203752:	00003697          	auipc	a3,0x3
ffffffffc0203756:	93e68693          	addi	a3,a3,-1730 # ffffffffc0206090 <default_pmm_manager+0x888>
ffffffffc020375a:	00002617          	auipc	a2,0x2
ffffffffc020375e:	cfe60613          	addi	a2,a2,-770 # ffffffffc0205458 <commands+0x738>
ffffffffc0203762:	05e00593          	li	a1,94
ffffffffc0203766:	00003517          	auipc	a0,0x3
ffffffffc020376a:	b0250513          	addi	a0,a0,-1278 # ffffffffc0206268 <default_pmm_manager+0xa60>
ffffffffc020376e:	cd1fc0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0203772 <_fifo_swap_out_victim>:
ffffffffc0203772:	751c                	ld	a5,40(a0)
ffffffffc0203774:	1141                	addi	sp,sp,-16
ffffffffc0203776:	e406                	sd	ra,8(sp)
ffffffffc0203778:	cf91                	beqz	a5,ffffffffc0203794 <_fifo_swap_out_victim+0x22>
ffffffffc020377a:	ee0d                	bnez	a2,ffffffffc02037b4 <_fifo_swap_out_victim+0x42>
ffffffffc020377c:	679c                	ld	a5,8(a5)
ffffffffc020377e:	60a2                	ld	ra,8(sp)
ffffffffc0203780:	4501                	li	a0,0
ffffffffc0203782:	6394                	ld	a3,0(a5)
ffffffffc0203784:	6798                	ld	a4,8(a5)
ffffffffc0203786:	fd878793          	addi	a5,a5,-40
ffffffffc020378a:	e698                	sd	a4,8(a3)
ffffffffc020378c:	e314                	sd	a3,0(a4)
ffffffffc020378e:	e19c                	sd	a5,0(a1)
ffffffffc0203790:	0141                	addi	sp,sp,16
ffffffffc0203792:	8082                	ret
ffffffffc0203794:	00003697          	auipc	a3,0x3
ffffffffc0203798:	c2468693          	addi	a3,a3,-988 # ffffffffc02063b8 <default_pmm_manager+0xbb0>
ffffffffc020379c:	00002617          	auipc	a2,0x2
ffffffffc02037a0:	cbc60613          	addi	a2,a2,-836 # ffffffffc0205458 <commands+0x738>
ffffffffc02037a4:	04b00593          	li	a1,75
ffffffffc02037a8:	00003517          	auipc	a0,0x3
ffffffffc02037ac:	ac050513          	addi	a0,a0,-1344 # ffffffffc0206268 <default_pmm_manager+0xa60>
ffffffffc02037b0:	c8ffc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02037b4:	00003697          	auipc	a3,0x3
ffffffffc02037b8:	c1468693          	addi	a3,a3,-1004 # ffffffffc02063c8 <default_pmm_manager+0xbc0>
ffffffffc02037bc:	00002617          	auipc	a2,0x2
ffffffffc02037c0:	c9c60613          	addi	a2,a2,-868 # ffffffffc0205458 <commands+0x738>
ffffffffc02037c4:	04c00593          	li	a1,76
ffffffffc02037c8:	00003517          	auipc	a0,0x3
ffffffffc02037cc:	aa050513          	addi	a0,a0,-1376 # ffffffffc0206268 <default_pmm_manager+0xa60>
ffffffffc02037d0:	c6ffc0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc02037d4 <_fifo_map_swappable>:
ffffffffc02037d4:	751c                	ld	a5,40(a0)
ffffffffc02037d6:	cb91                	beqz	a5,ffffffffc02037ea <_fifo_map_swappable+0x16>
ffffffffc02037d8:	6394                	ld	a3,0(a5)
ffffffffc02037da:	02860713          	addi	a4,a2,40
ffffffffc02037de:	e398                	sd	a4,0(a5)
ffffffffc02037e0:	e698                	sd	a4,8(a3)
ffffffffc02037e2:	4501                	li	a0,0
ffffffffc02037e4:	fa1c                	sd	a5,48(a2)
ffffffffc02037e6:	f614                	sd	a3,40(a2)
ffffffffc02037e8:	8082                	ret
ffffffffc02037ea:	1141                	addi	sp,sp,-16
ffffffffc02037ec:	00003697          	auipc	a3,0x3
ffffffffc02037f0:	bec68693          	addi	a3,a3,-1044 # ffffffffc02063d8 <default_pmm_manager+0xbd0>
ffffffffc02037f4:	00002617          	auipc	a2,0x2
ffffffffc02037f8:	c6460613          	addi	a2,a2,-924 # ffffffffc0205458 <commands+0x738>
ffffffffc02037fc:	03900593          	li	a1,57
ffffffffc0203800:	00003517          	auipc	a0,0x3
ffffffffc0203804:	a6850513          	addi	a0,a0,-1432 # ffffffffc0206268 <default_pmm_manager+0xa60>
ffffffffc0203808:	e406                	sd	ra,8(sp)
ffffffffc020380a:	c35fc0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc020380e <check_vma_overlap.part.0>:
ffffffffc020380e:	1141                	addi	sp,sp,-16
ffffffffc0203810:	00003697          	auipc	a3,0x3
ffffffffc0203814:	c0068693          	addi	a3,a3,-1024 # ffffffffc0206410 <default_pmm_manager+0xc08>
ffffffffc0203818:	00002617          	auipc	a2,0x2
ffffffffc020381c:	c4060613          	addi	a2,a2,-960 # ffffffffc0205458 <commands+0x738>
ffffffffc0203820:	09600593          	li	a1,150
ffffffffc0203824:	00003517          	auipc	a0,0x3
ffffffffc0203828:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc020382c:	e406                	sd	ra,8(sp)
ffffffffc020382e:	c11fc0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0203832 <mm_create>:
ffffffffc0203832:	1141                	addi	sp,sp,-16
ffffffffc0203834:	03000513          	li	a0,48
ffffffffc0203838:	e022                	sd	s0,0(sp)
ffffffffc020383a:	e406                	sd	ra,8(sp)
ffffffffc020383c:	80efe0ef          	jal	ra,ffffffffc020184a <kmalloc>
ffffffffc0203840:	842a                	mv	s0,a0
ffffffffc0203842:	c105                	beqz	a0,ffffffffc0203862 <mm_create+0x30>
ffffffffc0203844:	e408                	sd	a0,8(s0)
ffffffffc0203846:	e008                	sd	a0,0(s0)
ffffffffc0203848:	00053823          	sd	zero,16(a0)
ffffffffc020384c:	00053c23          	sd	zero,24(a0)
ffffffffc0203850:	02052023          	sw	zero,32(a0)
ffffffffc0203854:	00012797          	auipc	a5,0x12
ffffffffc0203858:	d2c7a783          	lw	a5,-724(a5) # ffffffffc0215580 <swap_init_ok>
ffffffffc020385c:	eb81                	bnez	a5,ffffffffc020386c <mm_create+0x3a>
ffffffffc020385e:	02053423          	sd	zero,40(a0)
ffffffffc0203862:	60a2                	ld	ra,8(sp)
ffffffffc0203864:	8522                	mv	a0,s0
ffffffffc0203866:	6402                	ld	s0,0(sp)
ffffffffc0203868:	0141                	addi	sp,sp,16
ffffffffc020386a:	8082                	ret
ffffffffc020386c:	a1bff0ef          	jal	ra,ffffffffc0203286 <swap_init_mm>
ffffffffc0203870:	60a2                	ld	ra,8(sp)
ffffffffc0203872:	8522                	mv	a0,s0
ffffffffc0203874:	6402                	ld	s0,0(sp)
ffffffffc0203876:	0141                	addi	sp,sp,16
ffffffffc0203878:	8082                	ret

ffffffffc020387a <vma_create>:
ffffffffc020387a:	1101                	addi	sp,sp,-32
ffffffffc020387c:	e04a                	sd	s2,0(sp)
ffffffffc020387e:	892a                	mv	s2,a0
ffffffffc0203880:	03000513          	li	a0,48
ffffffffc0203884:	e822                	sd	s0,16(sp)
ffffffffc0203886:	e426                	sd	s1,8(sp)
ffffffffc0203888:	ec06                	sd	ra,24(sp)
ffffffffc020388a:	84ae                	mv	s1,a1
ffffffffc020388c:	8432                	mv	s0,a2
ffffffffc020388e:	fbdfd0ef          	jal	ra,ffffffffc020184a <kmalloc>
ffffffffc0203892:	c509                	beqz	a0,ffffffffc020389c <vma_create+0x22>
ffffffffc0203894:	01253423          	sd	s2,8(a0)
ffffffffc0203898:	e904                	sd	s1,16(a0)
ffffffffc020389a:	cd00                	sw	s0,24(a0)
ffffffffc020389c:	60e2                	ld	ra,24(sp)
ffffffffc020389e:	6442                	ld	s0,16(sp)
ffffffffc02038a0:	64a2                	ld	s1,8(sp)
ffffffffc02038a2:	6902                	ld	s2,0(sp)
ffffffffc02038a4:	6105                	addi	sp,sp,32
ffffffffc02038a6:	8082                	ret

ffffffffc02038a8 <find_vma>:
ffffffffc02038a8:	86aa                	mv	a3,a0
ffffffffc02038aa:	c505                	beqz	a0,ffffffffc02038d2 <find_vma+0x2a>
ffffffffc02038ac:	6908                	ld	a0,16(a0)
ffffffffc02038ae:	c501                	beqz	a0,ffffffffc02038b6 <find_vma+0xe>
ffffffffc02038b0:	651c                	ld	a5,8(a0)
ffffffffc02038b2:	02f5f663          	bgeu	a1,a5,ffffffffc02038de <find_vma+0x36>
ffffffffc02038b6:	669c                	ld	a5,8(a3)
ffffffffc02038b8:	00f68d63          	beq	a3,a5,ffffffffc02038d2 <find_vma+0x2a>
ffffffffc02038bc:	fe87b703          	ld	a4,-24(a5)
ffffffffc02038c0:	00e5e663          	bltu	a1,a4,ffffffffc02038cc <find_vma+0x24>
ffffffffc02038c4:	ff07b703          	ld	a4,-16(a5)
ffffffffc02038c8:	00e5e763          	bltu	a1,a4,ffffffffc02038d6 <find_vma+0x2e>
ffffffffc02038cc:	679c                	ld	a5,8(a5)
ffffffffc02038ce:	fef697e3          	bne	a3,a5,ffffffffc02038bc <find_vma+0x14>
ffffffffc02038d2:	4501                	li	a0,0
ffffffffc02038d4:	8082                	ret
ffffffffc02038d6:	fe078513          	addi	a0,a5,-32
ffffffffc02038da:	ea88                	sd	a0,16(a3)
ffffffffc02038dc:	8082                	ret
ffffffffc02038de:	691c                	ld	a5,16(a0)
ffffffffc02038e0:	fcf5fbe3          	bgeu	a1,a5,ffffffffc02038b6 <find_vma+0xe>
ffffffffc02038e4:	ea88                	sd	a0,16(a3)
ffffffffc02038e6:	8082                	ret

ffffffffc02038e8 <insert_vma_struct>:
ffffffffc02038e8:	6590                	ld	a2,8(a1)
ffffffffc02038ea:	0105b803          	ld	a6,16(a1) # 1010 <kern_entry-0xffffffffc01feff0>
ffffffffc02038ee:	1141                	addi	sp,sp,-16
ffffffffc02038f0:	e406                	sd	ra,8(sp)
ffffffffc02038f2:	87aa                	mv	a5,a0
ffffffffc02038f4:	01066763          	bltu	a2,a6,ffffffffc0203902 <insert_vma_struct+0x1a>
ffffffffc02038f8:	a085                	j	ffffffffc0203958 <insert_vma_struct+0x70>
ffffffffc02038fa:	fe87b703          	ld	a4,-24(a5)
ffffffffc02038fe:	04e66863          	bltu	a2,a4,ffffffffc020394e <insert_vma_struct+0x66>
ffffffffc0203902:	86be                	mv	a3,a5
ffffffffc0203904:	679c                	ld	a5,8(a5)
ffffffffc0203906:	fef51ae3          	bne	a0,a5,ffffffffc02038fa <insert_vma_struct+0x12>
ffffffffc020390a:	02a68463          	beq	a3,a0,ffffffffc0203932 <insert_vma_struct+0x4a>
ffffffffc020390e:	ff06b703          	ld	a4,-16(a3)
ffffffffc0203912:	fe86b883          	ld	a7,-24(a3)
ffffffffc0203916:	08e8f163          	bgeu	a7,a4,ffffffffc0203998 <insert_vma_struct+0xb0>
ffffffffc020391a:	04e66f63          	bltu	a2,a4,ffffffffc0203978 <insert_vma_struct+0x90>
ffffffffc020391e:	00f50a63          	beq	a0,a5,ffffffffc0203932 <insert_vma_struct+0x4a>
ffffffffc0203922:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203926:	05076963          	bltu	a4,a6,ffffffffc0203978 <insert_vma_struct+0x90>
ffffffffc020392a:	ff07b603          	ld	a2,-16(a5)
ffffffffc020392e:	02c77363          	bgeu	a4,a2,ffffffffc0203954 <insert_vma_struct+0x6c>
ffffffffc0203932:	5118                	lw	a4,32(a0)
ffffffffc0203934:	e188                	sd	a0,0(a1)
ffffffffc0203936:	02058613          	addi	a2,a1,32
ffffffffc020393a:	e390                	sd	a2,0(a5)
ffffffffc020393c:	e690                	sd	a2,8(a3)
ffffffffc020393e:	60a2                	ld	ra,8(sp)
ffffffffc0203940:	f59c                	sd	a5,40(a1)
ffffffffc0203942:	f194                	sd	a3,32(a1)
ffffffffc0203944:	0017079b          	addiw	a5,a4,1
ffffffffc0203948:	d11c                	sw	a5,32(a0)
ffffffffc020394a:	0141                	addi	sp,sp,16
ffffffffc020394c:	8082                	ret
ffffffffc020394e:	fca690e3          	bne	a3,a0,ffffffffc020390e <insert_vma_struct+0x26>
ffffffffc0203952:	bfd1                	j	ffffffffc0203926 <insert_vma_struct+0x3e>
ffffffffc0203954:	ebbff0ef          	jal	ra,ffffffffc020380e <check_vma_overlap.part.0>
ffffffffc0203958:	00003697          	auipc	a3,0x3
ffffffffc020395c:	ae868693          	addi	a3,a3,-1304 # ffffffffc0206440 <default_pmm_manager+0xc38>
ffffffffc0203960:	00002617          	auipc	a2,0x2
ffffffffc0203964:	af860613          	addi	a2,a2,-1288 # ffffffffc0205458 <commands+0x738>
ffffffffc0203968:	09f00593          	li	a1,159
ffffffffc020396c:	00003517          	auipc	a0,0x3
ffffffffc0203970:	ac450513          	addi	a0,a0,-1340 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203974:	acbfc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203978:	00003697          	auipc	a3,0x3
ffffffffc020397c:	b0868693          	addi	a3,a3,-1272 # ffffffffc0206480 <default_pmm_manager+0xc78>
ffffffffc0203980:	00002617          	auipc	a2,0x2
ffffffffc0203984:	ad860613          	addi	a2,a2,-1320 # ffffffffc0205458 <commands+0x738>
ffffffffc0203988:	09500593          	li	a1,149
ffffffffc020398c:	00003517          	auipc	a0,0x3
ffffffffc0203990:	aa450513          	addi	a0,a0,-1372 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203994:	aabfc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203998:	00003697          	auipc	a3,0x3
ffffffffc020399c:	ac868693          	addi	a3,a3,-1336 # ffffffffc0206460 <default_pmm_manager+0xc58>
ffffffffc02039a0:	00002617          	auipc	a2,0x2
ffffffffc02039a4:	ab860613          	addi	a2,a2,-1352 # ffffffffc0205458 <commands+0x738>
ffffffffc02039a8:	09400593          	li	a1,148
ffffffffc02039ac:	00003517          	auipc	a0,0x3
ffffffffc02039b0:	a8450513          	addi	a0,a0,-1404 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc02039b4:	a8bfc0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc02039b8 <mm_destroy>:
ffffffffc02039b8:	1141                	addi	sp,sp,-16
ffffffffc02039ba:	e022                	sd	s0,0(sp)
ffffffffc02039bc:	842a                	mv	s0,a0
ffffffffc02039be:	6508                	ld	a0,8(a0)
ffffffffc02039c0:	e406                	sd	ra,8(sp)
ffffffffc02039c2:	00a40c63          	beq	s0,a0,ffffffffc02039da <mm_destroy+0x22>
ffffffffc02039c6:	6118                	ld	a4,0(a0)
ffffffffc02039c8:	651c                	ld	a5,8(a0)
ffffffffc02039ca:	1501                	addi	a0,a0,-32
ffffffffc02039cc:	e71c                	sd	a5,8(a4)
ffffffffc02039ce:	e398                	sd	a4,0(a5)
ffffffffc02039d0:	f1bfd0ef          	jal	ra,ffffffffc02018ea <kfree>
ffffffffc02039d4:	6408                	ld	a0,8(s0)
ffffffffc02039d6:	fea418e3          	bne	s0,a0,ffffffffc02039c6 <mm_destroy+0xe>
ffffffffc02039da:	8522                	mv	a0,s0
ffffffffc02039dc:	6402                	ld	s0,0(sp)
ffffffffc02039de:	60a2                	ld	ra,8(sp)
ffffffffc02039e0:	0141                	addi	sp,sp,16
ffffffffc02039e2:	f09fd06f          	j	ffffffffc02018ea <kfree>

ffffffffc02039e6 <vmm_init>:
ffffffffc02039e6:	7139                	addi	sp,sp,-64
ffffffffc02039e8:	03000513          	li	a0,48
ffffffffc02039ec:	fc06                	sd	ra,56(sp)
ffffffffc02039ee:	f822                	sd	s0,48(sp)
ffffffffc02039f0:	f426                	sd	s1,40(sp)
ffffffffc02039f2:	f04a                	sd	s2,32(sp)
ffffffffc02039f4:	ec4e                	sd	s3,24(sp)
ffffffffc02039f6:	e852                	sd	s4,16(sp)
ffffffffc02039f8:	e456                	sd	s5,8(sp)
ffffffffc02039fa:	e05a                	sd	s6,0(sp)
ffffffffc02039fc:	e4ffd0ef          	jal	ra,ffffffffc020184a <kmalloc>
ffffffffc0203a00:	34050063          	beqz	a0,ffffffffc0203d40 <vmm_init+0x35a>
ffffffffc0203a04:	e508                	sd	a0,8(a0)
ffffffffc0203a06:	e108                	sd	a0,0(a0)
ffffffffc0203a08:	00053823          	sd	zero,16(a0)
ffffffffc0203a0c:	00053c23          	sd	zero,24(a0)
ffffffffc0203a10:	02052023          	sw	zero,32(a0)
ffffffffc0203a14:	00012797          	auipc	a5,0x12
ffffffffc0203a18:	b6c7a783          	lw	a5,-1172(a5) # ffffffffc0215580 <swap_init_ok>
ffffffffc0203a1c:	842a                	mv	s0,a0
ffffffffc0203a1e:	2e079e63          	bnez	a5,ffffffffc0203d1a <vmm_init+0x334>
ffffffffc0203a22:	02053423          	sd	zero,40(a0)
ffffffffc0203a26:	03200493          	li	s1,50
ffffffffc0203a2a:	03000513          	li	a0,48
ffffffffc0203a2e:	e1dfd0ef          	jal	ra,ffffffffc020184a <kmalloc>
ffffffffc0203a32:	85aa                	mv	a1,a0
ffffffffc0203a34:	00248793          	addi	a5,s1,2
ffffffffc0203a38:	2e050463          	beqz	a0,ffffffffc0203d20 <vmm_init+0x33a>
ffffffffc0203a3c:	e504                	sd	s1,8(a0)
ffffffffc0203a3e:	e91c                	sd	a5,16(a0)
ffffffffc0203a40:	00052c23          	sw	zero,24(a0)
ffffffffc0203a44:	14ed                	addi	s1,s1,-5
ffffffffc0203a46:	8522                	mv	a0,s0
ffffffffc0203a48:	ea1ff0ef          	jal	ra,ffffffffc02038e8 <insert_vma_struct>
ffffffffc0203a4c:	fcf9                	bnez	s1,ffffffffc0203a2a <vmm_init+0x44>
ffffffffc0203a4e:	03700493          	li	s1,55
ffffffffc0203a52:	1f900913          	li	s2,505
ffffffffc0203a56:	03000513          	li	a0,48
ffffffffc0203a5a:	df1fd0ef          	jal	ra,ffffffffc020184a <kmalloc>
ffffffffc0203a5e:	85aa                	mv	a1,a0
ffffffffc0203a60:	30050063          	beqz	a0,ffffffffc0203d60 <vmm_init+0x37a>
ffffffffc0203a64:	00248793          	addi	a5,s1,2
ffffffffc0203a68:	e504                	sd	s1,8(a0)
ffffffffc0203a6a:	e91c                	sd	a5,16(a0)
ffffffffc0203a6c:	00052c23          	sw	zero,24(a0)
ffffffffc0203a70:	0495                	addi	s1,s1,5
ffffffffc0203a72:	8522                	mv	a0,s0
ffffffffc0203a74:	e75ff0ef          	jal	ra,ffffffffc02038e8 <insert_vma_struct>
ffffffffc0203a78:	fd249fe3          	bne	s1,s2,ffffffffc0203a56 <vmm_init+0x70>
ffffffffc0203a7c:	00843a03          	ld	s4,8(s0)
ffffffffc0203a80:	3a8a0763          	beq	s4,s0,ffffffffc0203e2e <vmm_init+0x448>
ffffffffc0203a84:	87d2                	mv	a5,s4
ffffffffc0203a86:	4715                	li	a4,5
ffffffffc0203a88:	1f400593          	li	a1,500
ffffffffc0203a8c:	a021                	j	ffffffffc0203a94 <vmm_init+0xae>
ffffffffc0203a8e:	0715                	addi	a4,a4,5
ffffffffc0203a90:	38878f63          	beq	a5,s0,ffffffffc0203e2e <vmm_init+0x448>
ffffffffc0203a94:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203a98:	36e69b63          	bne	a3,a4,ffffffffc0203e0e <vmm_init+0x428>
ffffffffc0203a9c:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203aa0:	00270693          	addi	a3,a4,2
ffffffffc0203aa4:	36d61563          	bne	a2,a3,ffffffffc0203e0e <vmm_init+0x428>
ffffffffc0203aa8:	679c                	ld	a5,8(a5)
ffffffffc0203aaa:	feb712e3          	bne	a4,a1,ffffffffc0203a8e <vmm_init+0xa8>
ffffffffc0203aae:	4a9d                	li	s5,7
ffffffffc0203ab0:	4495                	li	s1,5
ffffffffc0203ab2:	1f900b13          	li	s6,505
ffffffffc0203ab6:	85a6                	mv	a1,s1
ffffffffc0203ab8:	8522                	mv	a0,s0
ffffffffc0203aba:	defff0ef          	jal	ra,ffffffffc02038a8 <find_vma>
ffffffffc0203abe:	89aa                	mv	s3,a0
ffffffffc0203ac0:	3a050763          	beqz	a0,ffffffffc0203e6e <vmm_init+0x488>
ffffffffc0203ac4:	00148593          	addi	a1,s1,1
ffffffffc0203ac8:	8522                	mv	a0,s0
ffffffffc0203aca:	ddfff0ef          	jal	ra,ffffffffc02038a8 <find_vma>
ffffffffc0203ace:	892a                	mv	s2,a0
ffffffffc0203ad0:	36050f63          	beqz	a0,ffffffffc0203e4e <vmm_init+0x468>
ffffffffc0203ad4:	85d6                	mv	a1,s5
ffffffffc0203ad6:	8522                	mv	a0,s0
ffffffffc0203ad8:	dd1ff0ef          	jal	ra,ffffffffc02038a8 <find_vma>
ffffffffc0203adc:	3e051963          	bnez	a0,ffffffffc0203ece <vmm_init+0x4e8>
ffffffffc0203ae0:	00348593          	addi	a1,s1,3
ffffffffc0203ae4:	8522                	mv	a0,s0
ffffffffc0203ae6:	dc3ff0ef          	jal	ra,ffffffffc02038a8 <find_vma>
ffffffffc0203aea:	3c051263          	bnez	a0,ffffffffc0203eae <vmm_init+0x4c8>
ffffffffc0203aee:	00448593          	addi	a1,s1,4
ffffffffc0203af2:	8522                	mv	a0,s0
ffffffffc0203af4:	db5ff0ef          	jal	ra,ffffffffc02038a8 <find_vma>
ffffffffc0203af8:	38051b63          	bnez	a0,ffffffffc0203e8e <vmm_init+0x4a8>
ffffffffc0203afc:	0089b783          	ld	a5,8(s3)
ffffffffc0203b00:	2ef49763          	bne	s1,a5,ffffffffc0203dee <vmm_init+0x408>
ffffffffc0203b04:	0109b783          	ld	a5,16(s3)
ffffffffc0203b08:	2f579363          	bne	a5,s5,ffffffffc0203dee <vmm_init+0x408>
ffffffffc0203b0c:	00893783          	ld	a5,8(s2)
ffffffffc0203b10:	2af49f63          	bne	s1,a5,ffffffffc0203dce <vmm_init+0x3e8>
ffffffffc0203b14:	01093783          	ld	a5,16(s2)
ffffffffc0203b18:	2b579b63          	bne	a5,s5,ffffffffc0203dce <vmm_init+0x3e8>
ffffffffc0203b1c:	0495                	addi	s1,s1,5
ffffffffc0203b1e:	0a95                	addi	s5,s5,5
ffffffffc0203b20:	f9649be3          	bne	s1,s6,ffffffffc0203ab6 <vmm_init+0xd0>
ffffffffc0203b24:	4491                	li	s1,4
ffffffffc0203b26:	597d                	li	s2,-1
ffffffffc0203b28:	85a6                	mv	a1,s1
ffffffffc0203b2a:	8522                	mv	a0,s0
ffffffffc0203b2c:	d7dff0ef          	jal	ra,ffffffffc02038a8 <find_vma>
ffffffffc0203b30:	3a051f63          	bnez	a0,ffffffffc0203eee <vmm_init+0x508>
ffffffffc0203b34:	14fd                	addi	s1,s1,-1
ffffffffc0203b36:	ff2499e3          	bne	s1,s2,ffffffffc0203b28 <vmm_init+0x142>
ffffffffc0203b3a:	000a3703          	ld	a4,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0203b3e:	008a3783          	ld	a5,8(s4)
ffffffffc0203b42:	fe0a0513          	addi	a0,s4,-32
ffffffffc0203b46:	e71c                	sd	a5,8(a4)
ffffffffc0203b48:	e398                	sd	a4,0(a5)
ffffffffc0203b4a:	da1fd0ef          	jal	ra,ffffffffc02018ea <kfree>
ffffffffc0203b4e:	00843a03          	ld	s4,8(s0)
ffffffffc0203b52:	ff4414e3          	bne	s0,s4,ffffffffc0203b3a <vmm_init+0x154>
ffffffffc0203b56:	8522                	mv	a0,s0
ffffffffc0203b58:	d93fd0ef          	jal	ra,ffffffffc02018ea <kfree>
ffffffffc0203b5c:	00003517          	auipc	a0,0x3
ffffffffc0203b60:	a8450513          	addi	a0,a0,-1404 # ffffffffc02065e0 <default_pmm_manager+0xdd8>
ffffffffc0203b64:	e26fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0203b68:	f81fd0ef          	jal	ra,ffffffffc0201ae8 <nr_free_pages>
ffffffffc0203b6c:	84aa                	mv	s1,a0
ffffffffc0203b6e:	03000513          	li	a0,48
ffffffffc0203b72:	cd9fd0ef          	jal	ra,ffffffffc020184a <kmalloc>
ffffffffc0203b76:	842a                	mv	s0,a0
ffffffffc0203b78:	22050463          	beqz	a0,ffffffffc0203da0 <vmm_init+0x3ba>
ffffffffc0203b7c:	00012797          	auipc	a5,0x12
ffffffffc0203b80:	a047a783          	lw	a5,-1532(a5) # ffffffffc0215580 <swap_init_ok>
ffffffffc0203b84:	e508                	sd	a0,8(a0)
ffffffffc0203b86:	e108                	sd	a0,0(a0)
ffffffffc0203b88:	00053823          	sd	zero,16(a0)
ffffffffc0203b8c:	00053c23          	sd	zero,24(a0)
ffffffffc0203b90:	02052023          	sw	zero,32(a0)
ffffffffc0203b94:	22079a63          	bnez	a5,ffffffffc0203dc8 <vmm_init+0x3e2>
ffffffffc0203b98:	02053423          	sd	zero,40(a0)
ffffffffc0203b9c:	00012917          	auipc	s2,0x12
ffffffffc0203ba0:	9c493903          	ld	s2,-1596(s2) # ffffffffc0215560 <boot_pgdir>
ffffffffc0203ba4:	00093783          	ld	a5,0(s2)
ffffffffc0203ba8:	00012717          	auipc	a4,0x12
ffffffffc0203bac:	9e873c23          	sd	s0,-1544(a4) # ffffffffc02155a0 <check_mm_struct>
ffffffffc0203bb0:	01243c23          	sd	s2,24(s0)
ffffffffc0203bb4:	3c079f63          	bnez	a5,ffffffffc0203f92 <vmm_init+0x5ac>
ffffffffc0203bb8:	03000513          	li	a0,48
ffffffffc0203bbc:	c8ffd0ef          	jal	ra,ffffffffc020184a <kmalloc>
ffffffffc0203bc0:	89aa                	mv	s3,a0
ffffffffc0203bc2:	1a050f63          	beqz	a0,ffffffffc0203d80 <vmm_init+0x39a>
ffffffffc0203bc6:	002007b7          	lui	a5,0x200
ffffffffc0203bca:	00f9b823          	sd	a5,16(s3)
ffffffffc0203bce:	4789                	li	a5,2
ffffffffc0203bd0:	85aa                	mv	a1,a0
ffffffffc0203bd2:	00f9ac23          	sw	a5,24(s3)
ffffffffc0203bd6:	8522                	mv	a0,s0
ffffffffc0203bd8:	0009b423          	sd	zero,8(s3)
ffffffffc0203bdc:	d0dff0ef          	jal	ra,ffffffffc02038e8 <insert_vma_struct>
ffffffffc0203be0:	10000593          	li	a1,256
ffffffffc0203be4:	8522                	mv	a0,s0
ffffffffc0203be6:	cc3ff0ef          	jal	ra,ffffffffc02038a8 <find_vma>
ffffffffc0203bea:	10000793          	li	a5,256
ffffffffc0203bee:	16400713          	li	a4,356
ffffffffc0203bf2:	38a99063          	bne	s3,a0,ffffffffc0203f72 <vmm_init+0x58c>
ffffffffc0203bf6:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
ffffffffc0203bfa:	0785                	addi	a5,a5,1
ffffffffc0203bfc:	fee79de3          	bne	a5,a4,ffffffffc0203bf6 <vmm_init+0x210>
ffffffffc0203c00:	6705                	lui	a4,0x1
ffffffffc0203c02:	10000793          	li	a5,256
ffffffffc0203c06:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
ffffffffc0203c0a:	16400613          	li	a2,356
ffffffffc0203c0e:	0007c683          	lbu	a3,0(a5)
ffffffffc0203c12:	0785                	addi	a5,a5,1
ffffffffc0203c14:	9f15                	subw	a4,a4,a3
ffffffffc0203c16:	fec79ce3          	bne	a5,a2,ffffffffc0203c0e <vmm_init+0x228>
ffffffffc0203c1a:	32071c63          	bnez	a4,ffffffffc0203f52 <vmm_init+0x56c>
ffffffffc0203c1e:	00093783          	ld	a5,0(s2)
ffffffffc0203c22:	00012a97          	auipc	s5,0x12
ffffffffc0203c26:	94ea8a93          	addi	s5,s5,-1714 # ffffffffc0215570 <npage>
ffffffffc0203c2a:	000ab703          	ld	a4,0(s5)
ffffffffc0203c2e:	078a                	slli	a5,a5,0x2
ffffffffc0203c30:	83b1                	srli	a5,a5,0xc
ffffffffc0203c32:	30e7f463          	bgeu	a5,a4,ffffffffc0203f3a <vmm_init+0x554>
ffffffffc0203c36:	00003a17          	auipc	s4,0x3
ffffffffc0203c3a:	f3aa3a03          	ld	s4,-198(s4) # ffffffffc0206b70 <nbase>
ffffffffc0203c3e:	414786b3          	sub	a3,a5,s4
ffffffffc0203c42:	069a                	slli	a3,a3,0x6
ffffffffc0203c44:	8699                	srai	a3,a3,0x6
ffffffffc0203c46:	96d2                	add	a3,a3,s4
ffffffffc0203c48:	00c69793          	slli	a5,a3,0xc
ffffffffc0203c4c:	83b1                	srli	a5,a5,0xc
ffffffffc0203c4e:	06b2                	slli	a3,a3,0xc
ffffffffc0203c50:	2ce7f963          	bgeu	a5,a4,ffffffffc0203f22 <vmm_init+0x53c>
ffffffffc0203c54:	00012797          	auipc	a5,0x12
ffffffffc0203c58:	9147b783          	ld	a5,-1772(a5) # ffffffffc0215568 <va_pa_offset>
ffffffffc0203c5c:	4581                	li	a1,0
ffffffffc0203c5e:	854a                	mv	a0,s2
ffffffffc0203c60:	00f689b3          	add	s3,a3,a5
ffffffffc0203c64:	8e2fe0ef          	jal	ra,ffffffffc0201d46 <page_remove>
ffffffffc0203c68:	0009b783          	ld	a5,0(s3)
ffffffffc0203c6c:	000ab703          	ld	a4,0(s5)
ffffffffc0203c70:	078a                	slli	a5,a5,0x2
ffffffffc0203c72:	83b1                	srli	a5,a5,0xc
ffffffffc0203c74:	2ce7f363          	bgeu	a5,a4,ffffffffc0203f3a <vmm_init+0x554>
ffffffffc0203c78:	00012997          	auipc	s3,0x12
ffffffffc0203c7c:	90098993          	addi	s3,s3,-1792 # ffffffffc0215578 <pages>
ffffffffc0203c80:	0009b503          	ld	a0,0(s3)
ffffffffc0203c84:	414787b3          	sub	a5,a5,s4
ffffffffc0203c88:	079a                	slli	a5,a5,0x6
ffffffffc0203c8a:	953e                	add	a0,a0,a5
ffffffffc0203c8c:	4585                	li	a1,1
ffffffffc0203c8e:	e1bfd0ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0203c92:	00093783          	ld	a5,0(s2)
ffffffffc0203c96:	000ab703          	ld	a4,0(s5)
ffffffffc0203c9a:	078a                	slli	a5,a5,0x2
ffffffffc0203c9c:	83b1                	srli	a5,a5,0xc
ffffffffc0203c9e:	28e7fe63          	bgeu	a5,a4,ffffffffc0203f3a <vmm_init+0x554>
ffffffffc0203ca2:	0009b503          	ld	a0,0(s3)
ffffffffc0203ca6:	414787b3          	sub	a5,a5,s4
ffffffffc0203caa:	079a                	slli	a5,a5,0x6
ffffffffc0203cac:	4585                	li	a1,1
ffffffffc0203cae:	953e                	add	a0,a0,a5
ffffffffc0203cb0:	df9fd0ef          	jal	ra,ffffffffc0201aa8 <free_pages>
ffffffffc0203cb4:	00093023          	sd	zero,0(s2)
ffffffffc0203cb8:	12000073          	sfence.vma
ffffffffc0203cbc:	6408                	ld	a0,8(s0)
ffffffffc0203cbe:	00043c23          	sd	zero,24(s0)
ffffffffc0203cc2:	00a40c63          	beq	s0,a0,ffffffffc0203cda <vmm_init+0x2f4>
ffffffffc0203cc6:	6118                	ld	a4,0(a0)
ffffffffc0203cc8:	651c                	ld	a5,8(a0)
ffffffffc0203cca:	1501                	addi	a0,a0,-32
ffffffffc0203ccc:	e71c                	sd	a5,8(a4)
ffffffffc0203cce:	e398                	sd	a4,0(a5)
ffffffffc0203cd0:	c1bfd0ef          	jal	ra,ffffffffc02018ea <kfree>
ffffffffc0203cd4:	6408                	ld	a0,8(s0)
ffffffffc0203cd6:	fea418e3          	bne	s0,a0,ffffffffc0203cc6 <vmm_init+0x2e0>
ffffffffc0203cda:	8522                	mv	a0,s0
ffffffffc0203cdc:	c0ffd0ef          	jal	ra,ffffffffc02018ea <kfree>
ffffffffc0203ce0:	00012797          	auipc	a5,0x12
ffffffffc0203ce4:	8c07b023          	sd	zero,-1856(a5) # ffffffffc02155a0 <check_mm_struct>
ffffffffc0203ce8:	e01fd0ef          	jal	ra,ffffffffc0201ae8 <nr_free_pages>
ffffffffc0203cec:	2ca49363          	bne	s1,a0,ffffffffc0203fb2 <vmm_init+0x5cc>
ffffffffc0203cf0:	00003517          	auipc	a0,0x3
ffffffffc0203cf4:	98050513          	addi	a0,a0,-1664 # ffffffffc0206670 <default_pmm_manager+0xe68>
ffffffffc0203cf8:	c92fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0203cfc:	7442                	ld	s0,48(sp)
ffffffffc0203cfe:	70e2                	ld	ra,56(sp)
ffffffffc0203d00:	74a2                	ld	s1,40(sp)
ffffffffc0203d02:	7902                	ld	s2,32(sp)
ffffffffc0203d04:	69e2                	ld	s3,24(sp)
ffffffffc0203d06:	6a42                	ld	s4,16(sp)
ffffffffc0203d08:	6aa2                	ld	s5,8(sp)
ffffffffc0203d0a:	6b02                	ld	s6,0(sp)
ffffffffc0203d0c:	00003517          	auipc	a0,0x3
ffffffffc0203d10:	98450513          	addi	a0,a0,-1660 # ffffffffc0206690 <default_pmm_manager+0xe88>
ffffffffc0203d14:	6121                	addi	sp,sp,64
ffffffffc0203d16:	c74fc06f          	j	ffffffffc020018a <cprintf>
ffffffffc0203d1a:	d6cff0ef          	jal	ra,ffffffffc0203286 <swap_init_mm>
ffffffffc0203d1e:	b321                	j	ffffffffc0203a26 <vmm_init+0x40>
ffffffffc0203d20:	00002697          	auipc	a3,0x2
ffffffffc0203d24:	23068693          	addi	a3,a3,560 # ffffffffc0205f50 <default_pmm_manager+0x748>
ffffffffc0203d28:	00001617          	auipc	a2,0x1
ffffffffc0203d2c:	73060613          	addi	a2,a2,1840 # ffffffffc0205458 <commands+0x738>
ffffffffc0203d30:	0ef00593          	li	a1,239
ffffffffc0203d34:	00002517          	auipc	a0,0x2
ffffffffc0203d38:	6fc50513          	addi	a0,a0,1788 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203d3c:	f02fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203d40:	00002697          	auipc	a3,0x2
ffffffffc0203d44:	1d868693          	addi	a3,a3,472 # ffffffffc0205f18 <default_pmm_manager+0x710>
ffffffffc0203d48:	00001617          	auipc	a2,0x1
ffffffffc0203d4c:	71060613          	addi	a2,a2,1808 # ffffffffc0205458 <commands+0x738>
ffffffffc0203d50:	0e800593          	li	a1,232
ffffffffc0203d54:	00002517          	auipc	a0,0x2
ffffffffc0203d58:	6dc50513          	addi	a0,a0,1756 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203d5c:	ee2fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203d60:	00002697          	auipc	a3,0x2
ffffffffc0203d64:	1f068693          	addi	a3,a3,496 # ffffffffc0205f50 <default_pmm_manager+0x748>
ffffffffc0203d68:	00001617          	auipc	a2,0x1
ffffffffc0203d6c:	6f060613          	addi	a2,a2,1776 # ffffffffc0205458 <commands+0x738>
ffffffffc0203d70:	0f500593          	li	a1,245
ffffffffc0203d74:	00002517          	auipc	a0,0x2
ffffffffc0203d78:	6bc50513          	addi	a0,a0,1724 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203d7c:	ec2fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203d80:	00002697          	auipc	a3,0x2
ffffffffc0203d84:	1d068693          	addi	a3,a3,464 # ffffffffc0205f50 <default_pmm_manager+0x748>
ffffffffc0203d88:	00001617          	auipc	a2,0x1
ffffffffc0203d8c:	6d060613          	addi	a2,a2,1744 # ffffffffc0205458 <commands+0x738>
ffffffffc0203d90:	12e00593          	li	a1,302
ffffffffc0203d94:	00002517          	auipc	a0,0x2
ffffffffc0203d98:	69c50513          	addi	a0,a0,1692 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203d9c:	ea2fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203da0:	00003697          	auipc	a3,0x3
ffffffffc0203da4:	86068693          	addi	a3,a3,-1952 # ffffffffc0206600 <default_pmm_manager+0xdf8>
ffffffffc0203da8:	00001617          	auipc	a2,0x1
ffffffffc0203dac:	6b060613          	addi	a2,a2,1712 # ffffffffc0205458 <commands+0x738>
ffffffffc0203db0:	12700593          	li	a1,295
ffffffffc0203db4:	00002517          	auipc	a0,0x2
ffffffffc0203db8:	67c50513          	addi	a0,a0,1660 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203dbc:	00011797          	auipc	a5,0x11
ffffffffc0203dc0:	7e07b223          	sd	zero,2020(a5) # ffffffffc02155a0 <check_mm_struct>
ffffffffc0203dc4:	e7afc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203dc8:	cbeff0ef          	jal	ra,ffffffffc0203286 <swap_init_mm>
ffffffffc0203dcc:	bbc1                	j	ffffffffc0203b9c <vmm_init+0x1b6>
ffffffffc0203dce:	00002697          	auipc	a3,0x2
ffffffffc0203dd2:	7a268693          	addi	a3,a3,1954 # ffffffffc0206570 <default_pmm_manager+0xd68>
ffffffffc0203dd6:	00001617          	auipc	a2,0x1
ffffffffc0203dda:	68260613          	addi	a2,a2,1666 # ffffffffc0205458 <commands+0x738>
ffffffffc0203dde:	10f00593          	li	a1,271
ffffffffc0203de2:	00002517          	auipc	a0,0x2
ffffffffc0203de6:	64e50513          	addi	a0,a0,1614 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203dea:	e54fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203dee:	00002697          	auipc	a3,0x2
ffffffffc0203df2:	75268693          	addi	a3,a3,1874 # ffffffffc0206540 <default_pmm_manager+0xd38>
ffffffffc0203df6:	00001617          	auipc	a2,0x1
ffffffffc0203dfa:	66260613          	addi	a2,a2,1634 # ffffffffc0205458 <commands+0x738>
ffffffffc0203dfe:	10e00593          	li	a1,270
ffffffffc0203e02:	00002517          	auipc	a0,0x2
ffffffffc0203e06:	62e50513          	addi	a0,a0,1582 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203e0a:	e34fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203e0e:	00002697          	auipc	a3,0x2
ffffffffc0203e12:	6aa68693          	addi	a3,a3,1706 # ffffffffc02064b8 <default_pmm_manager+0xcb0>
ffffffffc0203e16:	00001617          	auipc	a2,0x1
ffffffffc0203e1a:	64260613          	addi	a2,a2,1602 # ffffffffc0205458 <commands+0x738>
ffffffffc0203e1e:	0fe00593          	li	a1,254
ffffffffc0203e22:	00002517          	auipc	a0,0x2
ffffffffc0203e26:	60e50513          	addi	a0,a0,1550 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203e2a:	e14fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203e2e:	00002697          	auipc	a3,0x2
ffffffffc0203e32:	67268693          	addi	a3,a3,1650 # ffffffffc02064a0 <default_pmm_manager+0xc98>
ffffffffc0203e36:	00001617          	auipc	a2,0x1
ffffffffc0203e3a:	62260613          	addi	a2,a2,1570 # ffffffffc0205458 <commands+0x738>
ffffffffc0203e3e:	0fc00593          	li	a1,252
ffffffffc0203e42:	00002517          	auipc	a0,0x2
ffffffffc0203e46:	5ee50513          	addi	a0,a0,1518 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203e4a:	df4fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203e4e:	00002697          	auipc	a3,0x2
ffffffffc0203e52:	6b268693          	addi	a3,a3,1714 # ffffffffc0206500 <default_pmm_manager+0xcf8>
ffffffffc0203e56:	00001617          	auipc	a2,0x1
ffffffffc0203e5a:	60260613          	addi	a2,a2,1538 # ffffffffc0205458 <commands+0x738>
ffffffffc0203e5e:	10600593          	li	a1,262
ffffffffc0203e62:	00002517          	auipc	a0,0x2
ffffffffc0203e66:	5ce50513          	addi	a0,a0,1486 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203e6a:	dd4fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203e6e:	00002697          	auipc	a3,0x2
ffffffffc0203e72:	68268693          	addi	a3,a3,1666 # ffffffffc02064f0 <default_pmm_manager+0xce8>
ffffffffc0203e76:	00001617          	auipc	a2,0x1
ffffffffc0203e7a:	5e260613          	addi	a2,a2,1506 # ffffffffc0205458 <commands+0x738>
ffffffffc0203e7e:	10400593          	li	a1,260
ffffffffc0203e82:	00002517          	auipc	a0,0x2
ffffffffc0203e86:	5ae50513          	addi	a0,a0,1454 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203e8a:	db4fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203e8e:	00002697          	auipc	a3,0x2
ffffffffc0203e92:	6a268693          	addi	a3,a3,1698 # ffffffffc0206530 <default_pmm_manager+0xd28>
ffffffffc0203e96:	00001617          	auipc	a2,0x1
ffffffffc0203e9a:	5c260613          	addi	a2,a2,1474 # ffffffffc0205458 <commands+0x738>
ffffffffc0203e9e:	10c00593          	li	a1,268
ffffffffc0203ea2:	00002517          	auipc	a0,0x2
ffffffffc0203ea6:	58e50513          	addi	a0,a0,1422 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203eaa:	d94fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203eae:	00002697          	auipc	a3,0x2
ffffffffc0203eb2:	67268693          	addi	a3,a3,1650 # ffffffffc0206520 <default_pmm_manager+0xd18>
ffffffffc0203eb6:	00001617          	auipc	a2,0x1
ffffffffc0203eba:	5a260613          	addi	a2,a2,1442 # ffffffffc0205458 <commands+0x738>
ffffffffc0203ebe:	10a00593          	li	a1,266
ffffffffc0203ec2:	00002517          	auipc	a0,0x2
ffffffffc0203ec6:	56e50513          	addi	a0,a0,1390 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203eca:	d74fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203ece:	00002697          	auipc	a3,0x2
ffffffffc0203ed2:	64268693          	addi	a3,a3,1602 # ffffffffc0206510 <default_pmm_manager+0xd08>
ffffffffc0203ed6:	00001617          	auipc	a2,0x1
ffffffffc0203eda:	58260613          	addi	a2,a2,1410 # ffffffffc0205458 <commands+0x738>
ffffffffc0203ede:	10800593          	li	a1,264
ffffffffc0203ee2:	00002517          	auipc	a0,0x2
ffffffffc0203ee6:	54e50513          	addi	a0,a0,1358 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203eea:	d54fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203eee:	6914                	ld	a3,16(a0)
ffffffffc0203ef0:	6510                	ld	a2,8(a0)
ffffffffc0203ef2:	0004859b          	sext.w	a1,s1
ffffffffc0203ef6:	00002517          	auipc	a0,0x2
ffffffffc0203efa:	6aa50513          	addi	a0,a0,1706 # ffffffffc02065a0 <default_pmm_manager+0xd98>
ffffffffc0203efe:	a8cfc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0203f02:	00002697          	auipc	a3,0x2
ffffffffc0203f06:	6c668693          	addi	a3,a3,1734 # ffffffffc02065c8 <default_pmm_manager+0xdc0>
ffffffffc0203f0a:	00001617          	auipc	a2,0x1
ffffffffc0203f0e:	54e60613          	addi	a2,a2,1358 # ffffffffc0205458 <commands+0x738>
ffffffffc0203f12:	11700593          	li	a1,279
ffffffffc0203f16:	00002517          	auipc	a0,0x2
ffffffffc0203f1a:	51a50513          	addi	a0,a0,1306 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203f1e:	d20fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203f22:	00002617          	auipc	a2,0x2
ffffffffc0203f26:	91e60613          	addi	a2,a2,-1762 # ffffffffc0205840 <default_pmm_manager+0x38>
ffffffffc0203f2a:	08b00593          	li	a1,139
ffffffffc0203f2e:	00002517          	auipc	a0,0x2
ffffffffc0203f32:	93a50513          	addi	a0,a0,-1734 # ffffffffc0205868 <default_pmm_manager+0x60>
ffffffffc0203f36:	d08fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203f3a:	00002617          	auipc	a2,0x2
ffffffffc0203f3e:	9d660613          	addi	a2,a2,-1578 # ffffffffc0205910 <default_pmm_manager+0x108>
ffffffffc0203f42:	08000593          	li	a1,128
ffffffffc0203f46:	00002517          	auipc	a0,0x2
ffffffffc0203f4a:	92250513          	addi	a0,a0,-1758 # ffffffffc0205868 <default_pmm_manager+0x60>
ffffffffc0203f4e:	cf0fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203f52:	00002697          	auipc	a3,0x2
ffffffffc0203f56:	6e668693          	addi	a3,a3,1766 # ffffffffc0206638 <default_pmm_manager+0xe30>
ffffffffc0203f5a:	00001617          	auipc	a2,0x1
ffffffffc0203f5e:	4fe60613          	addi	a2,a2,1278 # ffffffffc0205458 <commands+0x738>
ffffffffc0203f62:	13d00593          	li	a1,317
ffffffffc0203f66:	00002517          	auipc	a0,0x2
ffffffffc0203f6a:	4ca50513          	addi	a0,a0,1226 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203f6e:	cd0fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203f72:	00002697          	auipc	a3,0x2
ffffffffc0203f76:	6a668693          	addi	a3,a3,1702 # ffffffffc0206618 <default_pmm_manager+0xe10>
ffffffffc0203f7a:	00001617          	auipc	a2,0x1
ffffffffc0203f7e:	4de60613          	addi	a2,a2,1246 # ffffffffc0205458 <commands+0x738>
ffffffffc0203f82:	13300593          	li	a1,307
ffffffffc0203f86:	00002517          	auipc	a0,0x2
ffffffffc0203f8a:	4aa50513          	addi	a0,a0,1194 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203f8e:	cb0fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203f92:	00002697          	auipc	a3,0x2
ffffffffc0203f96:	fae68693          	addi	a3,a3,-82 # ffffffffc0205f40 <default_pmm_manager+0x738>
ffffffffc0203f9a:	00001617          	auipc	a2,0x1
ffffffffc0203f9e:	4be60613          	addi	a2,a2,1214 # ffffffffc0205458 <commands+0x738>
ffffffffc0203fa2:	12b00593          	li	a1,299
ffffffffc0203fa6:	00002517          	auipc	a0,0x2
ffffffffc0203faa:	48a50513          	addi	a0,a0,1162 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203fae:	c90fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0203fb2:	00002697          	auipc	a3,0x2
ffffffffc0203fb6:	69668693          	addi	a3,a3,1686 # ffffffffc0206648 <default_pmm_manager+0xe40>
ffffffffc0203fba:	00001617          	auipc	a2,0x1
ffffffffc0203fbe:	49e60613          	addi	a2,a2,1182 # ffffffffc0205458 <commands+0x738>
ffffffffc0203fc2:	14a00593          	li	a1,330
ffffffffc0203fc6:	00002517          	auipc	a0,0x2
ffffffffc0203fca:	46a50513          	addi	a0,a0,1130 # ffffffffc0206430 <default_pmm_manager+0xc28>
ffffffffc0203fce:	c70fc0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0203fd2 <do_pgfault>:
ffffffffc0203fd2:	7179                	addi	sp,sp,-48
ffffffffc0203fd4:	85b2                	mv	a1,a2
ffffffffc0203fd6:	f022                	sd	s0,32(sp)
ffffffffc0203fd8:	ec26                	sd	s1,24(sp)
ffffffffc0203fda:	f406                	sd	ra,40(sp)
ffffffffc0203fdc:	e84a                	sd	s2,16(sp)
ffffffffc0203fde:	8432                	mv	s0,a2
ffffffffc0203fe0:	84aa                	mv	s1,a0
ffffffffc0203fe2:	8c7ff0ef          	jal	ra,ffffffffc02038a8 <find_vma>
ffffffffc0203fe6:	00011797          	auipc	a5,0x11
ffffffffc0203fea:	5b27a783          	lw	a5,1458(a5) # ffffffffc0215598 <pgfault_num>
ffffffffc0203fee:	2785                	addiw	a5,a5,1
ffffffffc0203ff0:	00011717          	auipc	a4,0x11
ffffffffc0203ff4:	5af72423          	sw	a5,1448(a4) # ffffffffc0215598 <pgfault_num>
ffffffffc0203ff8:	c549                	beqz	a0,ffffffffc0204082 <do_pgfault+0xb0>
ffffffffc0203ffa:	651c                	ld	a5,8(a0)
ffffffffc0203ffc:	08f46363          	bltu	s0,a5,ffffffffc0204082 <do_pgfault+0xb0>
ffffffffc0204000:	4d1c                	lw	a5,24(a0)
ffffffffc0204002:	495d                	li	s2,23
ffffffffc0204004:	8b89                	andi	a5,a5,2
ffffffffc0204006:	cfb1                	beqz	a5,ffffffffc0204062 <do_pgfault+0x90>
ffffffffc0204008:	77fd                	lui	a5,0xfffff
ffffffffc020400a:	6c88                	ld	a0,24(s1)
ffffffffc020400c:	8c7d                	and	s0,s0,a5
ffffffffc020400e:	4605                	li	a2,1
ffffffffc0204010:	85a2                	mv	a1,s0
ffffffffc0204012:	b11fd0ef          	jal	ra,ffffffffc0201b22 <get_pte>
ffffffffc0204016:	cd5d                	beqz	a0,ffffffffc02040d4 <do_pgfault+0x102>
ffffffffc0204018:	610c                	ld	a1,0(a0)
ffffffffc020401a:	c5b1                	beqz	a1,ffffffffc0204066 <do_pgfault+0x94>
ffffffffc020401c:	00011797          	auipc	a5,0x11
ffffffffc0204020:	5647a783          	lw	a5,1380(a5) # ffffffffc0215580 <swap_init_ok>
ffffffffc0204024:	cba5                	beqz	a5,ffffffffc0204094 <do_pgfault+0xc2>
ffffffffc0204026:	0030                	addi	a2,sp,8
ffffffffc0204028:	85a2                	mv	a1,s0
ffffffffc020402a:	8526                	mv	a0,s1
ffffffffc020402c:	e402                	sd	zero,8(sp)
ffffffffc020402e:	b84ff0ef          	jal	ra,ffffffffc02033b2 <swap_in>
ffffffffc0204032:	e92d                	bnez	a0,ffffffffc02040a4 <do_pgfault+0xd2>
ffffffffc0204034:	65a2                	ld	a1,8(sp)
ffffffffc0204036:	6c88                	ld	a0,24(s1)
ffffffffc0204038:	86ca                	mv	a3,s2
ffffffffc020403a:	8622                	mv	a2,s0
ffffffffc020403c:	da7fd0ef          	jal	ra,ffffffffc0201de2 <page_insert>
ffffffffc0204040:	e935                	bnez	a0,ffffffffc02040b4 <do_pgfault+0xe2>
ffffffffc0204042:	6622                	ld	a2,8(sp)
ffffffffc0204044:	4685                	li	a3,1
ffffffffc0204046:	85a2                	mv	a1,s0
ffffffffc0204048:	8526                	mv	a0,s1
ffffffffc020404a:	a48ff0ef          	jal	ra,ffffffffc0203292 <swap_map_swappable>
ffffffffc020404e:	e93d                	bnez	a0,ffffffffc02040c4 <do_pgfault+0xf2>
ffffffffc0204050:	67a2                	ld	a5,8(sp)
ffffffffc0204052:	ff80                	sd	s0,56(a5)
ffffffffc0204054:	4501                	li	a0,0
ffffffffc0204056:	70a2                	ld	ra,40(sp)
ffffffffc0204058:	7402                	ld	s0,32(sp)
ffffffffc020405a:	64e2                	ld	s1,24(sp)
ffffffffc020405c:	6942                	ld	s2,16(sp)
ffffffffc020405e:	6145                	addi	sp,sp,48
ffffffffc0204060:	8082                	ret
ffffffffc0204062:	4941                	li	s2,16
ffffffffc0204064:	b755                	j	ffffffffc0204008 <do_pgfault+0x36>
ffffffffc0204066:	6c88                	ld	a0,24(s1)
ffffffffc0204068:	864a                	mv	a2,s2
ffffffffc020406a:	85a2                	mv	a1,s0
ffffffffc020406c:	a0ffe0ef          	jal	ra,ffffffffc0202a7a <pgdir_alloc_page>
ffffffffc0204070:	f175                	bnez	a0,ffffffffc0204054 <do_pgfault+0x82>
ffffffffc0204072:	00002517          	auipc	a0,0x2
ffffffffc0204076:	68650513          	addi	a0,a0,1670 # ffffffffc02066f8 <default_pmm_manager+0xef0>
ffffffffc020407a:	910fc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020407e:	5571                	li	a0,-4
ffffffffc0204080:	bfd9                	j	ffffffffc0204056 <do_pgfault+0x84>
ffffffffc0204082:	85a2                	mv	a1,s0
ffffffffc0204084:	00002517          	auipc	a0,0x2
ffffffffc0204088:	62450513          	addi	a0,a0,1572 # ffffffffc02066a8 <default_pmm_manager+0xea0>
ffffffffc020408c:	8fefc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0204090:	5575                	li	a0,-3
ffffffffc0204092:	b7d1                	j	ffffffffc0204056 <do_pgfault+0x84>
ffffffffc0204094:	00002517          	auipc	a0,0x2
ffffffffc0204098:	6d450513          	addi	a0,a0,1748 # ffffffffc0206768 <default_pmm_manager+0xf60>
ffffffffc020409c:	8eefc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02040a0:	5571                	li	a0,-4
ffffffffc02040a2:	bf55                	j	ffffffffc0204056 <do_pgfault+0x84>
ffffffffc02040a4:	00002517          	auipc	a0,0x2
ffffffffc02040a8:	67c50513          	addi	a0,a0,1660 # ffffffffc0206720 <default_pmm_manager+0xf18>
ffffffffc02040ac:	8defc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02040b0:	5571                	li	a0,-4
ffffffffc02040b2:	b755                	j	ffffffffc0204056 <do_pgfault+0x84>
ffffffffc02040b4:	00002517          	auipc	a0,0x2
ffffffffc02040b8:	67c50513          	addi	a0,a0,1660 # ffffffffc0206730 <default_pmm_manager+0xf28>
ffffffffc02040bc:	8cefc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02040c0:	5571                	li	a0,-4
ffffffffc02040c2:	bf51                	j	ffffffffc0204056 <do_pgfault+0x84>
ffffffffc02040c4:	00002517          	auipc	a0,0x2
ffffffffc02040c8:	68450513          	addi	a0,a0,1668 # ffffffffc0206748 <default_pmm_manager+0xf40>
ffffffffc02040cc:	8befc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02040d0:	5571                	li	a0,-4
ffffffffc02040d2:	b751                	j	ffffffffc0204056 <do_pgfault+0x84>
ffffffffc02040d4:	00002517          	auipc	a0,0x2
ffffffffc02040d8:	60450513          	addi	a0,a0,1540 # ffffffffc02066d8 <default_pmm_manager+0xed0>
ffffffffc02040dc:	8aefc0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02040e0:	5571                	li	a0,-4
ffffffffc02040e2:	bf95                	j	ffffffffc0204056 <do_pgfault+0x84>

ffffffffc02040e4 <swapfs_init>:
ffffffffc02040e4:	1141                	addi	sp,sp,-16
ffffffffc02040e6:	4505                	li	a0,1
ffffffffc02040e8:	e406                	sd	ra,8(sp)
ffffffffc02040ea:	c76fc0ef          	jal	ra,ffffffffc0200560 <ide_device_valid>
ffffffffc02040ee:	cd01                	beqz	a0,ffffffffc0204106 <swapfs_init+0x22>
ffffffffc02040f0:	4505                	li	a0,1
ffffffffc02040f2:	c74fc0ef          	jal	ra,ffffffffc0200566 <ide_device_size>
ffffffffc02040f6:	60a2                	ld	ra,8(sp)
ffffffffc02040f8:	810d                	srli	a0,a0,0x3
ffffffffc02040fa:	00011797          	auipc	a5,0x11
ffffffffc02040fe:	48a7b723          	sd	a0,1166(a5) # ffffffffc0215588 <max_swap_offset>
ffffffffc0204102:	0141                	addi	sp,sp,16
ffffffffc0204104:	8082                	ret
ffffffffc0204106:	00002617          	auipc	a2,0x2
ffffffffc020410a:	68a60613          	addi	a2,a2,1674 # ffffffffc0206790 <default_pmm_manager+0xf88>
ffffffffc020410e:	45b9                	li	a1,14
ffffffffc0204110:	00002517          	auipc	a0,0x2
ffffffffc0204114:	6a050513          	addi	a0,a0,1696 # ffffffffc02067b0 <default_pmm_manager+0xfa8>
ffffffffc0204118:	b26fc0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc020411c <swapfs_read>:
ffffffffc020411c:	1141                	addi	sp,sp,-16
ffffffffc020411e:	e406                	sd	ra,8(sp)
ffffffffc0204120:	00855793          	srli	a5,a0,0x8
ffffffffc0204124:	cbb1                	beqz	a5,ffffffffc0204178 <swapfs_read+0x5c>
ffffffffc0204126:	00011717          	auipc	a4,0x11
ffffffffc020412a:	46273703          	ld	a4,1122(a4) # ffffffffc0215588 <max_swap_offset>
ffffffffc020412e:	04e7f563          	bgeu	a5,a4,ffffffffc0204178 <swapfs_read+0x5c>
ffffffffc0204132:	00011717          	auipc	a4,0x11
ffffffffc0204136:	44673703          	ld	a4,1094(a4) # ffffffffc0215578 <pages>
ffffffffc020413a:	8d99                	sub	a1,a1,a4
ffffffffc020413c:	4065d613          	srai	a2,a1,0x6
ffffffffc0204140:	00003717          	auipc	a4,0x3
ffffffffc0204144:	a3073703          	ld	a4,-1488(a4) # ffffffffc0206b70 <nbase>
ffffffffc0204148:	963a                	add	a2,a2,a4
ffffffffc020414a:	00c61713          	slli	a4,a2,0xc
ffffffffc020414e:	8331                	srli	a4,a4,0xc
ffffffffc0204150:	00011697          	auipc	a3,0x11
ffffffffc0204154:	4206b683          	ld	a3,1056(a3) # ffffffffc0215570 <npage>
ffffffffc0204158:	0037959b          	slliw	a1,a5,0x3
ffffffffc020415c:	0632                	slli	a2,a2,0xc
ffffffffc020415e:	02d77963          	bgeu	a4,a3,ffffffffc0204190 <swapfs_read+0x74>
ffffffffc0204162:	60a2                	ld	ra,8(sp)
ffffffffc0204164:	00011797          	auipc	a5,0x11
ffffffffc0204168:	4047b783          	ld	a5,1028(a5) # ffffffffc0215568 <va_pa_offset>
ffffffffc020416c:	46a1                	li	a3,8
ffffffffc020416e:	963e                	add	a2,a2,a5
ffffffffc0204170:	4505                	li	a0,1
ffffffffc0204172:	0141                	addi	sp,sp,16
ffffffffc0204174:	bf8fc06f          	j	ffffffffc020056c <ide_read_secs>
ffffffffc0204178:	86aa                	mv	a3,a0
ffffffffc020417a:	00002617          	auipc	a2,0x2
ffffffffc020417e:	64e60613          	addi	a2,a2,1614 # ffffffffc02067c8 <default_pmm_manager+0xfc0>
ffffffffc0204182:	45e5                	li	a1,25
ffffffffc0204184:	00002517          	auipc	a0,0x2
ffffffffc0204188:	62c50513          	addi	a0,a0,1580 # ffffffffc02067b0 <default_pmm_manager+0xfa8>
ffffffffc020418c:	ab2fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0204190:	86b2                	mv	a3,a2
ffffffffc0204192:	08b00593          	li	a1,139
ffffffffc0204196:	00001617          	auipc	a2,0x1
ffffffffc020419a:	6aa60613          	addi	a2,a2,1706 # ffffffffc0205840 <default_pmm_manager+0x38>
ffffffffc020419e:	00001517          	auipc	a0,0x1
ffffffffc02041a2:	6ca50513          	addi	a0,a0,1738 # ffffffffc0205868 <default_pmm_manager+0x60>
ffffffffc02041a6:	a98fc0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc02041aa <swapfs_write>:
ffffffffc02041aa:	1141                	addi	sp,sp,-16
ffffffffc02041ac:	e406                	sd	ra,8(sp)
ffffffffc02041ae:	00855793          	srli	a5,a0,0x8
ffffffffc02041b2:	cbb1                	beqz	a5,ffffffffc0204206 <swapfs_write+0x5c>
ffffffffc02041b4:	00011717          	auipc	a4,0x11
ffffffffc02041b8:	3d473703          	ld	a4,980(a4) # ffffffffc0215588 <max_swap_offset>
ffffffffc02041bc:	04e7f563          	bgeu	a5,a4,ffffffffc0204206 <swapfs_write+0x5c>
ffffffffc02041c0:	00011717          	auipc	a4,0x11
ffffffffc02041c4:	3b873703          	ld	a4,952(a4) # ffffffffc0215578 <pages>
ffffffffc02041c8:	8d99                	sub	a1,a1,a4
ffffffffc02041ca:	4065d613          	srai	a2,a1,0x6
ffffffffc02041ce:	00003717          	auipc	a4,0x3
ffffffffc02041d2:	9a273703          	ld	a4,-1630(a4) # ffffffffc0206b70 <nbase>
ffffffffc02041d6:	963a                	add	a2,a2,a4
ffffffffc02041d8:	00c61713          	slli	a4,a2,0xc
ffffffffc02041dc:	8331                	srli	a4,a4,0xc
ffffffffc02041de:	00011697          	auipc	a3,0x11
ffffffffc02041e2:	3926b683          	ld	a3,914(a3) # ffffffffc0215570 <npage>
ffffffffc02041e6:	0037959b          	slliw	a1,a5,0x3
ffffffffc02041ea:	0632                	slli	a2,a2,0xc
ffffffffc02041ec:	02d77963          	bgeu	a4,a3,ffffffffc020421e <swapfs_write+0x74>
ffffffffc02041f0:	60a2                	ld	ra,8(sp)
ffffffffc02041f2:	00011797          	auipc	a5,0x11
ffffffffc02041f6:	3767b783          	ld	a5,886(a5) # ffffffffc0215568 <va_pa_offset>
ffffffffc02041fa:	46a1                	li	a3,8
ffffffffc02041fc:	963e                	add	a2,a2,a5
ffffffffc02041fe:	4505                	li	a0,1
ffffffffc0204200:	0141                	addi	sp,sp,16
ffffffffc0204202:	b8efc06f          	j	ffffffffc0200590 <ide_write_secs>
ffffffffc0204206:	86aa                	mv	a3,a0
ffffffffc0204208:	00002617          	auipc	a2,0x2
ffffffffc020420c:	5c060613          	addi	a2,a2,1472 # ffffffffc02067c8 <default_pmm_manager+0xfc0>
ffffffffc0204210:	45f9                	li	a1,30
ffffffffc0204212:	00002517          	auipc	a0,0x2
ffffffffc0204216:	59e50513          	addi	a0,a0,1438 # ffffffffc02067b0 <default_pmm_manager+0xfa8>
ffffffffc020421a:	a24fc0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc020421e:	86b2                	mv	a3,a2
ffffffffc0204220:	08b00593          	li	a1,139
ffffffffc0204224:	00001617          	auipc	a2,0x1
ffffffffc0204228:	61c60613          	addi	a2,a2,1564 # ffffffffc0205840 <default_pmm_manager+0x38>
ffffffffc020422c:	00001517          	auipc	a0,0x1
ffffffffc0204230:	63c50513          	addi	a0,a0,1596 # ffffffffc0205868 <default_pmm_manager+0x60>
ffffffffc0204234:	a0afc0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0204238 <init_main>:
ffffffffc0204238:	1101                	addi	sp,sp,-32
ffffffffc020423a:	e822                	sd	s0,16(sp)
ffffffffc020423c:	e426                	sd	s1,8(sp)
ffffffffc020423e:	842a                	mv	s0,a0
ffffffffc0204240:	00011497          	auipc	s1,0x11
ffffffffc0204244:	3704b483          	ld	s1,880(s1) # ffffffffc02155b0 <current>
ffffffffc0204248:	4641                	li	a2,16
ffffffffc020424a:	4581                	li	a1,0
ffffffffc020424c:	0000d517          	auipc	a0,0xd
ffffffffc0204250:	2c450513          	addi	a0,a0,708 # ffffffffc0211510 <name.0>
ffffffffc0204254:	ec06                	sd	ra,24(sp)
ffffffffc0204256:	e04a                	sd	s2,0(sp)
ffffffffc0204258:	0044a903          	lw	s2,4(s1)
ffffffffc020425c:	00f000ef          	jal	ra,ffffffffc0204a6a <memset>
ffffffffc0204260:	0b448593          	addi	a1,s1,180
ffffffffc0204264:	463d                	li	a2,15
ffffffffc0204266:	0000d517          	auipc	a0,0xd
ffffffffc020426a:	2aa50513          	addi	a0,a0,682 # ffffffffc0211510 <name.0>
ffffffffc020426e:	00f000ef          	jal	ra,ffffffffc0204a7c <memcpy>
ffffffffc0204272:	862a                	mv	a2,a0
ffffffffc0204274:	85ca                	mv	a1,s2
ffffffffc0204276:	00002517          	auipc	a0,0x2
ffffffffc020427a:	57250513          	addi	a0,a0,1394 # ffffffffc02067e8 <default_pmm_manager+0xfe0>
ffffffffc020427e:	f0dfb0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0204282:	85a2                	mv	a1,s0
ffffffffc0204284:	00002517          	auipc	a0,0x2
ffffffffc0204288:	58c50513          	addi	a0,a0,1420 # ffffffffc0206810 <default_pmm_manager+0x1008>
ffffffffc020428c:	efffb0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc0204290:	00002517          	auipc	a0,0x2
ffffffffc0204294:	59050513          	addi	a0,a0,1424 # ffffffffc0206820 <default_pmm_manager+0x1018>
ffffffffc0204298:	ef3fb0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc020429c:	60e2                	ld	ra,24(sp)
ffffffffc020429e:	6442                	ld	s0,16(sp)
ffffffffc02042a0:	64a2                	ld	s1,8(sp)
ffffffffc02042a2:	6902                	ld	s2,0(sp)
ffffffffc02042a4:	4501                	li	a0,0
ffffffffc02042a6:	6105                	addi	sp,sp,32
ffffffffc02042a8:	8082                	ret

ffffffffc02042aa <proc_run>:
ffffffffc02042aa:	8082                	ret

ffffffffc02042ac <kernel_thread>:
ffffffffc02042ac:	7169                	addi	sp,sp,-304
ffffffffc02042ae:	12000613          	li	a2,288
ffffffffc02042b2:	4581                	li	a1,0
ffffffffc02042b4:	850a                	mv	a0,sp
ffffffffc02042b6:	f606                	sd	ra,296(sp)
ffffffffc02042b8:	7b2000ef          	jal	ra,ffffffffc0204a6a <memset>
ffffffffc02042bc:	100027f3          	csrr	a5,sstatus
ffffffffc02042c0:	70b2                	ld	ra,296(sp)
ffffffffc02042c2:	00011517          	auipc	a0,0x11
ffffffffc02042c6:	2e652503          	lw	a0,742(a0) # ffffffffc02155a8 <nr_process>
ffffffffc02042ca:	6785                	lui	a5,0x1
ffffffffc02042cc:	00f52533          	slt	a0,a0,a5
ffffffffc02042d0:	156d                	addi	a0,a0,-5
ffffffffc02042d2:	6155                	addi	sp,sp,304
ffffffffc02042d4:	8082                	ret

ffffffffc02042d6 <proc_init>:
ffffffffc02042d6:	7179                	addi	sp,sp,-48
ffffffffc02042d8:	ec26                	sd	s1,24(sp)
ffffffffc02042da:	00011797          	auipc	a5,0x11
ffffffffc02042de:	24678793          	addi	a5,a5,582 # ffffffffc0215520 <proc_list>
ffffffffc02042e2:	f406                	sd	ra,40(sp)
ffffffffc02042e4:	f022                	sd	s0,32(sp)
ffffffffc02042e6:	e84a                	sd	s2,16(sp)
ffffffffc02042e8:	e44e                	sd	s3,8(sp)
ffffffffc02042ea:	0000d497          	auipc	s1,0xd
ffffffffc02042ee:	23648493          	addi	s1,s1,566 # ffffffffc0211520 <hash_list>
ffffffffc02042f2:	e79c                	sd	a5,8(a5)
ffffffffc02042f4:	e39c                	sd	a5,0(a5)
ffffffffc02042f6:	00011717          	auipc	a4,0x11
ffffffffc02042fa:	22a70713          	addi	a4,a4,554 # ffffffffc0215520 <proc_list>
ffffffffc02042fe:	87a6                	mv	a5,s1
ffffffffc0204300:	e79c                	sd	a5,8(a5)
ffffffffc0204302:	e39c                	sd	a5,0(a5)
ffffffffc0204304:	07c1                	addi	a5,a5,16
ffffffffc0204306:	fee79de3          	bne	a5,a4,ffffffffc0204300 <proc_init+0x2a>
ffffffffc020430a:	0e800513          	li	a0,232
ffffffffc020430e:	d3cfd0ef          	jal	ra,ffffffffc020184a <kmalloc>
ffffffffc0204312:	00011917          	auipc	s2,0x11
ffffffffc0204316:	2ae90913          	addi	s2,s2,686 # ffffffffc02155c0 <idleproc>
ffffffffc020431a:	00a93023          	sd	a0,0(s2)
ffffffffc020431e:	18050c63          	beqz	a0,ffffffffc02044b6 <proc_init+0x1e0>
ffffffffc0204322:	07000513          	li	a0,112
ffffffffc0204326:	d24fd0ef          	jal	ra,ffffffffc020184a <kmalloc>
ffffffffc020432a:	07000613          	li	a2,112
ffffffffc020432e:	4581                	li	a1,0
ffffffffc0204330:	842a                	mv	s0,a0
ffffffffc0204332:	738000ef          	jal	ra,ffffffffc0204a6a <memset>
ffffffffc0204336:	00093503          	ld	a0,0(s2)
ffffffffc020433a:	85a2                	mv	a1,s0
ffffffffc020433c:	07000613          	li	a2,112
ffffffffc0204340:	03050513          	addi	a0,a0,48
ffffffffc0204344:	750000ef          	jal	ra,ffffffffc0204a94 <memcmp>
ffffffffc0204348:	89aa                	mv	s3,a0
ffffffffc020434a:	453d                	li	a0,15
ffffffffc020434c:	cfefd0ef          	jal	ra,ffffffffc020184a <kmalloc>
ffffffffc0204350:	463d                	li	a2,15
ffffffffc0204352:	4581                	li	a1,0
ffffffffc0204354:	842a                	mv	s0,a0
ffffffffc0204356:	714000ef          	jal	ra,ffffffffc0204a6a <memset>
ffffffffc020435a:	00093503          	ld	a0,0(s2)
ffffffffc020435e:	463d                	li	a2,15
ffffffffc0204360:	85a2                	mv	a1,s0
ffffffffc0204362:	0b450513          	addi	a0,a0,180
ffffffffc0204366:	72e000ef          	jal	ra,ffffffffc0204a94 <memcmp>
ffffffffc020436a:	00093783          	ld	a5,0(s2)
ffffffffc020436e:	00011717          	auipc	a4,0x11
ffffffffc0204372:	1ea73703          	ld	a4,490(a4) # ffffffffc0215558 <boot_cr3>
ffffffffc0204376:	77d4                	ld	a3,168(a5)
ffffffffc0204378:	0ee68563          	beq	a3,a4,ffffffffc0204462 <proc_init+0x18c>
ffffffffc020437c:	4709                	li	a4,2
ffffffffc020437e:	e398                	sd	a4,0(a5)
ffffffffc0204380:	00003717          	auipc	a4,0x3
ffffffffc0204384:	c8070713          	addi	a4,a4,-896 # ffffffffc0207000 <bootstack>
ffffffffc0204388:	0b478413          	addi	s0,a5,180
ffffffffc020438c:	eb98                	sd	a4,16(a5)
ffffffffc020438e:	4705                	li	a4,1
ffffffffc0204390:	cf98                	sw	a4,24(a5)
ffffffffc0204392:	4641                	li	a2,16
ffffffffc0204394:	4581                	li	a1,0
ffffffffc0204396:	8522                	mv	a0,s0
ffffffffc0204398:	6d2000ef          	jal	ra,ffffffffc0204a6a <memset>
ffffffffc020439c:	463d                	li	a2,15
ffffffffc020439e:	00002597          	auipc	a1,0x2
ffffffffc02043a2:	50258593          	addi	a1,a1,1282 # ffffffffc02068a0 <default_pmm_manager+0x1098>
ffffffffc02043a6:	8522                	mv	a0,s0
ffffffffc02043a8:	6d4000ef          	jal	ra,ffffffffc0204a7c <memcpy>
ffffffffc02043ac:	00011717          	auipc	a4,0x11
ffffffffc02043b0:	1fc70713          	addi	a4,a4,508 # ffffffffc02155a8 <nr_process>
ffffffffc02043b4:	431c                	lw	a5,0(a4)
ffffffffc02043b6:	00093683          	ld	a3,0(s2)
ffffffffc02043ba:	4601                	li	a2,0
ffffffffc02043bc:	2785                	addiw	a5,a5,1
ffffffffc02043be:	00002597          	auipc	a1,0x2
ffffffffc02043c2:	4ea58593          	addi	a1,a1,1258 # ffffffffc02068a8 <default_pmm_manager+0x10a0>
ffffffffc02043c6:	00000517          	auipc	a0,0x0
ffffffffc02043ca:	e7250513          	addi	a0,a0,-398 # ffffffffc0204238 <init_main>
ffffffffc02043ce:	c31c                	sw	a5,0(a4)
ffffffffc02043d0:	00011797          	auipc	a5,0x11
ffffffffc02043d4:	1ed7b023          	sd	a3,480(a5) # ffffffffc02155b0 <current>
ffffffffc02043d8:	ed5ff0ef          	jal	ra,ffffffffc02042ac <kernel_thread>
ffffffffc02043dc:	842a                	mv	s0,a0
ffffffffc02043de:	0ea05863          	blez	a0,ffffffffc02044ce <proc_init+0x1f8>
ffffffffc02043e2:	6789                	lui	a5,0x2
ffffffffc02043e4:	fff5071b          	addiw	a4,a0,-1
ffffffffc02043e8:	17f9                	addi	a5,a5,-2
ffffffffc02043ea:	2501                	sext.w	a0,a0
ffffffffc02043ec:	02e7e463          	bltu	a5,a4,ffffffffc0204414 <proc_init+0x13e>
ffffffffc02043f0:	45a9                	li	a1,10
ffffffffc02043f2:	1e2000ef          	jal	ra,ffffffffc02045d4 <hash32>
ffffffffc02043f6:	02051713          	slli	a4,a0,0x20
ffffffffc02043fa:	01c75793          	srli	a5,a4,0x1c
ffffffffc02043fe:	00f486b3          	add	a3,s1,a5
ffffffffc0204402:	87b6                	mv	a5,a3
ffffffffc0204404:	a029                	j	ffffffffc020440e <proc_init+0x138>
ffffffffc0204406:	f2c7a703          	lw	a4,-212(a5) # 1f2c <kern_entry-0xffffffffc01fe0d4>
ffffffffc020440a:	0a870363          	beq	a4,s0,ffffffffc02044b0 <proc_init+0x1da>
ffffffffc020440e:	679c                	ld	a5,8(a5)
ffffffffc0204410:	fef69be3          	bne	a3,a5,ffffffffc0204406 <proc_init+0x130>
ffffffffc0204414:	4781                	li	a5,0
ffffffffc0204416:	0b478493          	addi	s1,a5,180
ffffffffc020441a:	4641                	li	a2,16
ffffffffc020441c:	4581                	li	a1,0
ffffffffc020441e:	00011417          	auipc	s0,0x11
ffffffffc0204422:	19a40413          	addi	s0,s0,410 # ffffffffc02155b8 <initproc>
ffffffffc0204426:	8526                	mv	a0,s1
ffffffffc0204428:	e01c                	sd	a5,0(s0)
ffffffffc020442a:	640000ef          	jal	ra,ffffffffc0204a6a <memset>
ffffffffc020442e:	463d                	li	a2,15
ffffffffc0204430:	00002597          	auipc	a1,0x2
ffffffffc0204434:	4a858593          	addi	a1,a1,1192 # ffffffffc02068d8 <default_pmm_manager+0x10d0>
ffffffffc0204438:	8526                	mv	a0,s1
ffffffffc020443a:	642000ef          	jal	ra,ffffffffc0204a7c <memcpy>
ffffffffc020443e:	00093783          	ld	a5,0(s2)
ffffffffc0204442:	c3f1                	beqz	a5,ffffffffc0204506 <proc_init+0x230>
ffffffffc0204444:	43dc                	lw	a5,4(a5)
ffffffffc0204446:	e3e1                	bnez	a5,ffffffffc0204506 <proc_init+0x230>
ffffffffc0204448:	601c                	ld	a5,0(s0)
ffffffffc020444a:	cfd1                	beqz	a5,ffffffffc02044e6 <proc_init+0x210>
ffffffffc020444c:	43d8                	lw	a4,4(a5)
ffffffffc020444e:	4785                	li	a5,1
ffffffffc0204450:	08f71b63          	bne	a4,a5,ffffffffc02044e6 <proc_init+0x210>
ffffffffc0204454:	70a2                	ld	ra,40(sp)
ffffffffc0204456:	7402                	ld	s0,32(sp)
ffffffffc0204458:	64e2                	ld	s1,24(sp)
ffffffffc020445a:	6942                	ld	s2,16(sp)
ffffffffc020445c:	69a2                	ld	s3,8(sp)
ffffffffc020445e:	6145                	addi	sp,sp,48
ffffffffc0204460:	8082                	ret
ffffffffc0204462:	73d8                	ld	a4,160(a5)
ffffffffc0204464:	ff01                	bnez	a4,ffffffffc020437c <proc_init+0xa6>
ffffffffc0204466:	f0099be3          	bnez	s3,ffffffffc020437c <proc_init+0xa6>
ffffffffc020446a:	6394                	ld	a3,0(a5)
ffffffffc020446c:	577d                	li	a4,-1
ffffffffc020446e:	1702                	slli	a4,a4,0x20
ffffffffc0204470:	f0e696e3          	bne	a3,a4,ffffffffc020437c <proc_init+0xa6>
ffffffffc0204474:	4798                	lw	a4,8(a5)
ffffffffc0204476:	f00713e3          	bnez	a4,ffffffffc020437c <proc_init+0xa6>
ffffffffc020447a:	6b98                	ld	a4,16(a5)
ffffffffc020447c:	f00710e3          	bnez	a4,ffffffffc020437c <proc_init+0xa6>
ffffffffc0204480:	4f98                	lw	a4,24(a5)
ffffffffc0204482:	ee071de3          	bnez	a4,ffffffffc020437c <proc_init+0xa6>
ffffffffc0204486:	7398                	ld	a4,32(a5)
ffffffffc0204488:	ee071ae3          	bnez	a4,ffffffffc020437c <proc_init+0xa6>
ffffffffc020448c:	7798                	ld	a4,40(a5)
ffffffffc020448e:	ee0717e3          	bnez	a4,ffffffffc020437c <proc_init+0xa6>
ffffffffc0204492:	0b07a703          	lw	a4,176(a5)
ffffffffc0204496:	8f49                	or	a4,a4,a0
ffffffffc0204498:	2701                	sext.w	a4,a4
ffffffffc020449a:	ee0711e3          	bnez	a4,ffffffffc020437c <proc_init+0xa6>
ffffffffc020449e:	00002517          	auipc	a0,0x2
ffffffffc02044a2:	3ea50513          	addi	a0,a0,1002 # ffffffffc0206888 <default_pmm_manager+0x1080>
ffffffffc02044a6:	ce5fb0ef          	jal	ra,ffffffffc020018a <cprintf>
ffffffffc02044aa:	00093783          	ld	a5,0(s2)
ffffffffc02044ae:	b5f9                	j	ffffffffc020437c <proc_init+0xa6>
ffffffffc02044b0:	f2878793          	addi	a5,a5,-216
ffffffffc02044b4:	b78d                	j	ffffffffc0204416 <proc_init+0x140>
ffffffffc02044b6:	00002617          	auipc	a2,0x2
ffffffffc02044ba:	3ba60613          	addi	a2,a2,954 # ffffffffc0206870 <default_pmm_manager+0x1068>
ffffffffc02044be:	15800593          	li	a1,344
ffffffffc02044c2:	00002517          	auipc	a0,0x2
ffffffffc02044c6:	39650513          	addi	a0,a0,918 # ffffffffc0206858 <default_pmm_manager+0x1050>
ffffffffc02044ca:	f75fb0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02044ce:	00002617          	auipc	a2,0x2
ffffffffc02044d2:	3ea60613          	addi	a2,a2,1002 # ffffffffc02068b8 <default_pmm_manager+0x10b0>
ffffffffc02044d6:	17800593          	li	a1,376
ffffffffc02044da:	00002517          	auipc	a0,0x2
ffffffffc02044de:	37e50513          	addi	a0,a0,894 # ffffffffc0206858 <default_pmm_manager+0x1050>
ffffffffc02044e2:	f5dfb0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc02044e6:	00002697          	auipc	a3,0x2
ffffffffc02044ea:	42268693          	addi	a3,a3,1058 # ffffffffc0206908 <default_pmm_manager+0x1100>
ffffffffc02044ee:	00001617          	auipc	a2,0x1
ffffffffc02044f2:	f6a60613          	addi	a2,a2,-150 # ffffffffc0205458 <commands+0x738>
ffffffffc02044f6:	17f00593          	li	a1,383
ffffffffc02044fa:	00002517          	auipc	a0,0x2
ffffffffc02044fe:	35e50513          	addi	a0,a0,862 # ffffffffc0206858 <default_pmm_manager+0x1050>
ffffffffc0204502:	f3dfb0ef          	jal	ra,ffffffffc020043e <__panic>
ffffffffc0204506:	00002697          	auipc	a3,0x2
ffffffffc020450a:	3da68693          	addi	a3,a3,986 # ffffffffc02068e0 <default_pmm_manager+0x10d8>
ffffffffc020450e:	00001617          	auipc	a2,0x1
ffffffffc0204512:	f4a60613          	addi	a2,a2,-182 # ffffffffc0205458 <commands+0x738>
ffffffffc0204516:	17e00593          	li	a1,382
ffffffffc020451a:	00002517          	auipc	a0,0x2
ffffffffc020451e:	33e50513          	addi	a0,a0,830 # ffffffffc0206858 <default_pmm_manager+0x1050>
ffffffffc0204522:	f1dfb0ef          	jal	ra,ffffffffc020043e <__panic>

ffffffffc0204526 <cpu_idle>:
ffffffffc0204526:	1141                	addi	sp,sp,-16
ffffffffc0204528:	e022                	sd	s0,0(sp)
ffffffffc020452a:	e406                	sd	ra,8(sp)
ffffffffc020452c:	00011417          	auipc	s0,0x11
ffffffffc0204530:	08440413          	addi	s0,s0,132 # ffffffffc02155b0 <current>
ffffffffc0204534:	6018                	ld	a4,0(s0)
ffffffffc0204536:	4f1c                	lw	a5,24(a4)
ffffffffc0204538:	dffd                	beqz	a5,ffffffffc0204536 <cpu_idle+0x10>
ffffffffc020453a:	006000ef          	jal	ra,ffffffffc0204540 <schedule>
ffffffffc020453e:	bfdd                	j	ffffffffc0204534 <cpu_idle+0xe>

ffffffffc0204540 <schedule>:
ffffffffc0204540:	1141                	addi	sp,sp,-16
ffffffffc0204542:	e406                	sd	ra,8(sp)
ffffffffc0204544:	e022                	sd	s0,0(sp)
ffffffffc0204546:	100027f3          	csrr	a5,sstatus
ffffffffc020454a:	8b89                	andi	a5,a5,2
ffffffffc020454c:	4401                	li	s0,0
ffffffffc020454e:	efbd                	bnez	a5,ffffffffc02045cc <schedule+0x8c>
ffffffffc0204550:	00011897          	auipc	a7,0x11
ffffffffc0204554:	0608b883          	ld	a7,96(a7) # ffffffffc02155b0 <current>
ffffffffc0204558:	0008ac23          	sw	zero,24(a7)
ffffffffc020455c:	00011517          	auipc	a0,0x11
ffffffffc0204560:	06453503          	ld	a0,100(a0) # ffffffffc02155c0 <idleproc>
ffffffffc0204564:	04a88e63          	beq	a7,a0,ffffffffc02045c0 <schedule+0x80>
ffffffffc0204568:	0c888693          	addi	a3,a7,200
ffffffffc020456c:	00011617          	auipc	a2,0x11
ffffffffc0204570:	fb460613          	addi	a2,a2,-76 # ffffffffc0215520 <proc_list>
ffffffffc0204574:	87b6                	mv	a5,a3
ffffffffc0204576:	4581                	li	a1,0
ffffffffc0204578:	4809                	li	a6,2
ffffffffc020457a:	679c                	ld	a5,8(a5)
ffffffffc020457c:	00c78863          	beq	a5,a2,ffffffffc020458c <schedule+0x4c>
ffffffffc0204580:	f387a703          	lw	a4,-200(a5)
ffffffffc0204584:	f3878593          	addi	a1,a5,-200
ffffffffc0204588:	03070163          	beq	a4,a6,ffffffffc02045aa <schedule+0x6a>
ffffffffc020458c:	fef697e3          	bne	a3,a5,ffffffffc020457a <schedule+0x3a>
ffffffffc0204590:	ed89                	bnez	a1,ffffffffc02045aa <schedule+0x6a>
ffffffffc0204592:	451c                	lw	a5,8(a0)
ffffffffc0204594:	2785                	addiw	a5,a5,1
ffffffffc0204596:	c51c                	sw	a5,8(a0)
ffffffffc0204598:	00a88463          	beq	a7,a0,ffffffffc02045a0 <schedule+0x60>
ffffffffc020459c:	d0fff0ef          	jal	ra,ffffffffc02042aa <proc_run>
ffffffffc02045a0:	e819                	bnez	s0,ffffffffc02045b6 <schedule+0x76>
ffffffffc02045a2:	60a2                	ld	ra,8(sp)
ffffffffc02045a4:	6402                	ld	s0,0(sp)
ffffffffc02045a6:	0141                	addi	sp,sp,16
ffffffffc02045a8:	8082                	ret
ffffffffc02045aa:	4198                	lw	a4,0(a1)
ffffffffc02045ac:	4789                	li	a5,2
ffffffffc02045ae:	fef712e3          	bne	a4,a5,ffffffffc0204592 <schedule+0x52>
ffffffffc02045b2:	852e                	mv	a0,a1
ffffffffc02045b4:	bff9                	j	ffffffffc0204592 <schedule+0x52>
ffffffffc02045b6:	6402                	ld	s0,0(sp)
ffffffffc02045b8:	60a2                	ld	ra,8(sp)
ffffffffc02045ba:	0141                	addi	sp,sp,16
ffffffffc02045bc:	ff9fb06f          	j	ffffffffc02005b4 <intr_enable>
ffffffffc02045c0:	00011617          	auipc	a2,0x11
ffffffffc02045c4:	f6060613          	addi	a2,a2,-160 # ffffffffc0215520 <proc_list>
ffffffffc02045c8:	86b2                	mv	a3,a2
ffffffffc02045ca:	b76d                	j	ffffffffc0204574 <schedule+0x34>
ffffffffc02045cc:	feffb0ef          	jal	ra,ffffffffc02005ba <intr_disable>
ffffffffc02045d0:	4405                	li	s0,1
ffffffffc02045d2:	bfbd                	j	ffffffffc0204550 <schedule+0x10>

ffffffffc02045d4 <hash32>:
ffffffffc02045d4:	9e3707b7          	lui	a5,0x9e370
ffffffffc02045d8:	2785                	addiw	a5,a5,1
ffffffffc02045da:	02a787bb          	mulw	a5,a5,a0
ffffffffc02045de:	02000513          	li	a0,32
ffffffffc02045e2:	9d0d                	subw	a0,a0,a1
ffffffffc02045e4:	00a7d53b          	srlw	a0,a5,a0
ffffffffc02045e8:	8082                	ret

ffffffffc02045ea <printnum>:
ffffffffc02045ea:	02069813          	slli	a6,a3,0x20
ffffffffc02045ee:	7179                	addi	sp,sp,-48
ffffffffc02045f0:	02085813          	srli	a6,a6,0x20
ffffffffc02045f4:	e052                	sd	s4,0(sp)
ffffffffc02045f6:	03067a33          	remu	s4,a2,a6
ffffffffc02045fa:	f022                	sd	s0,32(sp)
ffffffffc02045fc:	ec26                	sd	s1,24(sp)
ffffffffc02045fe:	e84a                	sd	s2,16(sp)
ffffffffc0204600:	f406                	sd	ra,40(sp)
ffffffffc0204602:	e44e                	sd	s3,8(sp)
ffffffffc0204604:	84aa                	mv	s1,a0
ffffffffc0204606:	892e                	mv	s2,a1
ffffffffc0204608:	fff7041b          	addiw	s0,a4,-1
ffffffffc020460c:	2a01                	sext.w	s4,s4
ffffffffc020460e:	03067f63          	bgeu	a2,a6,ffffffffc020464c <printnum+0x62>
ffffffffc0204612:	89be                	mv	s3,a5
ffffffffc0204614:	4785                	li	a5,1
ffffffffc0204616:	00e7d763          	bge	a5,a4,ffffffffc0204624 <printnum+0x3a>
ffffffffc020461a:	347d                	addiw	s0,s0,-1
ffffffffc020461c:	85ca                	mv	a1,s2
ffffffffc020461e:	854e                	mv	a0,s3
ffffffffc0204620:	9482                	jalr	s1
ffffffffc0204622:	fc65                	bnez	s0,ffffffffc020461a <printnum+0x30>
ffffffffc0204624:	1a02                	slli	s4,s4,0x20
ffffffffc0204626:	020a5a13          	srli	s4,s4,0x20
ffffffffc020462a:	00002797          	auipc	a5,0x2
ffffffffc020462e:	30678793          	addi	a5,a5,774 # ffffffffc0206930 <default_pmm_manager+0x1128>
ffffffffc0204632:	97d2                	add	a5,a5,s4
ffffffffc0204634:	7402                	ld	s0,32(sp)
ffffffffc0204636:	0007c503          	lbu	a0,0(a5)
ffffffffc020463a:	70a2                	ld	ra,40(sp)
ffffffffc020463c:	69a2                	ld	s3,8(sp)
ffffffffc020463e:	6a02                	ld	s4,0(sp)
ffffffffc0204640:	85ca                	mv	a1,s2
ffffffffc0204642:	87a6                	mv	a5,s1
ffffffffc0204644:	6942                	ld	s2,16(sp)
ffffffffc0204646:	64e2                	ld	s1,24(sp)
ffffffffc0204648:	6145                	addi	sp,sp,48
ffffffffc020464a:	8782                	jr	a5
ffffffffc020464c:	03065633          	divu	a2,a2,a6
ffffffffc0204650:	8722                	mv	a4,s0
ffffffffc0204652:	f99ff0ef          	jal	ra,ffffffffc02045ea <printnum>
ffffffffc0204656:	b7f9                	j	ffffffffc0204624 <printnum+0x3a>

ffffffffc0204658 <vprintfmt>:
ffffffffc0204658:	7119                	addi	sp,sp,-128
ffffffffc020465a:	f4a6                	sd	s1,104(sp)
ffffffffc020465c:	f0ca                	sd	s2,96(sp)
ffffffffc020465e:	ecce                	sd	s3,88(sp)
ffffffffc0204660:	e8d2                	sd	s4,80(sp)
ffffffffc0204662:	e4d6                	sd	s5,72(sp)
ffffffffc0204664:	e0da                	sd	s6,64(sp)
ffffffffc0204666:	f862                	sd	s8,48(sp)
ffffffffc0204668:	fc86                	sd	ra,120(sp)
ffffffffc020466a:	f8a2                	sd	s0,112(sp)
ffffffffc020466c:	fc5e                	sd	s7,56(sp)
ffffffffc020466e:	f466                	sd	s9,40(sp)
ffffffffc0204670:	f06a                	sd	s10,32(sp)
ffffffffc0204672:	ec6e                	sd	s11,24(sp)
ffffffffc0204674:	892a                	mv	s2,a0
ffffffffc0204676:	84ae                	mv	s1,a1
ffffffffc0204678:	8c32                	mv	s8,a2
ffffffffc020467a:	8a36                	mv	s4,a3
ffffffffc020467c:	02500993          	li	s3,37
ffffffffc0204680:	05500b13          	li	s6,85
ffffffffc0204684:	00002a97          	auipc	s5,0x2
ffffffffc0204688:	2d8a8a93          	addi	s5,s5,728 # ffffffffc020695c <default_pmm_manager+0x1154>
ffffffffc020468c:	000c4503          	lbu	a0,0(s8)
ffffffffc0204690:	001c0413          	addi	s0,s8,1
ffffffffc0204694:	01350a63          	beq	a0,s3,ffffffffc02046a8 <vprintfmt+0x50>
ffffffffc0204698:	cd0d                	beqz	a0,ffffffffc02046d2 <vprintfmt+0x7a>
ffffffffc020469a:	85a6                	mv	a1,s1
ffffffffc020469c:	0405                	addi	s0,s0,1
ffffffffc020469e:	9902                	jalr	s2
ffffffffc02046a0:	fff44503          	lbu	a0,-1(s0)
ffffffffc02046a4:	ff351ae3          	bne	a0,s3,ffffffffc0204698 <vprintfmt+0x40>
ffffffffc02046a8:	02000d93          	li	s11,32
ffffffffc02046ac:	4b81                	li	s7,0
ffffffffc02046ae:	4601                	li	a2,0
ffffffffc02046b0:	5d7d                	li	s10,-1
ffffffffc02046b2:	5cfd                	li	s9,-1
ffffffffc02046b4:	00044683          	lbu	a3,0(s0)
ffffffffc02046b8:	00140c13          	addi	s8,s0,1
ffffffffc02046bc:	fdd6859b          	addiw	a1,a3,-35
ffffffffc02046c0:	0ff5f593          	andi	a1,a1,255
ffffffffc02046c4:	02bb6663          	bltu	s6,a1,ffffffffc02046f0 <vprintfmt+0x98>
ffffffffc02046c8:	058a                	slli	a1,a1,0x2
ffffffffc02046ca:	95d6                	add	a1,a1,s5
ffffffffc02046cc:	4198                	lw	a4,0(a1)
ffffffffc02046ce:	9756                	add	a4,a4,s5
ffffffffc02046d0:	8702                	jr	a4
ffffffffc02046d2:	70e6                	ld	ra,120(sp)
ffffffffc02046d4:	7446                	ld	s0,112(sp)
ffffffffc02046d6:	74a6                	ld	s1,104(sp)
ffffffffc02046d8:	7906                	ld	s2,96(sp)
ffffffffc02046da:	69e6                	ld	s3,88(sp)
ffffffffc02046dc:	6a46                	ld	s4,80(sp)
ffffffffc02046de:	6aa6                	ld	s5,72(sp)
ffffffffc02046e0:	6b06                	ld	s6,64(sp)
ffffffffc02046e2:	7be2                	ld	s7,56(sp)
ffffffffc02046e4:	7c42                	ld	s8,48(sp)
ffffffffc02046e6:	7ca2                	ld	s9,40(sp)
ffffffffc02046e8:	7d02                	ld	s10,32(sp)
ffffffffc02046ea:	6de2                	ld	s11,24(sp)
ffffffffc02046ec:	6109                	addi	sp,sp,128
ffffffffc02046ee:	8082                	ret
ffffffffc02046f0:	85a6                	mv	a1,s1
ffffffffc02046f2:	02500513          	li	a0,37
ffffffffc02046f6:	9902                	jalr	s2
ffffffffc02046f8:	fff44703          	lbu	a4,-1(s0)
ffffffffc02046fc:	02500793          	li	a5,37
ffffffffc0204700:	8c22                	mv	s8,s0
ffffffffc0204702:	f8f705e3          	beq	a4,a5,ffffffffc020468c <vprintfmt+0x34>
ffffffffc0204706:	02500713          	li	a4,37
ffffffffc020470a:	ffec4783          	lbu	a5,-2(s8)
ffffffffc020470e:	1c7d                	addi	s8,s8,-1
ffffffffc0204710:	fee79de3          	bne	a5,a4,ffffffffc020470a <vprintfmt+0xb2>
ffffffffc0204714:	bfa5                	j	ffffffffc020468c <vprintfmt+0x34>
ffffffffc0204716:	00144783          	lbu	a5,1(s0)
ffffffffc020471a:	4725                	li	a4,9
ffffffffc020471c:	fd068d1b          	addiw	s10,a3,-48
ffffffffc0204720:	fd07859b          	addiw	a1,a5,-48
ffffffffc0204724:	0007869b          	sext.w	a3,a5
ffffffffc0204728:	8462                	mv	s0,s8
ffffffffc020472a:	02b76563          	bltu	a4,a1,ffffffffc0204754 <vprintfmt+0xfc>
ffffffffc020472e:	4525                	li	a0,9
ffffffffc0204730:	00144783          	lbu	a5,1(s0)
ffffffffc0204734:	002d171b          	slliw	a4,s10,0x2
ffffffffc0204738:	01a7073b          	addw	a4,a4,s10
ffffffffc020473c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204740:	9f35                	addw	a4,a4,a3
ffffffffc0204742:	fd07859b          	addiw	a1,a5,-48
ffffffffc0204746:	0405                	addi	s0,s0,1
ffffffffc0204748:	fd070d1b          	addiw	s10,a4,-48
ffffffffc020474c:	0007869b          	sext.w	a3,a5
ffffffffc0204750:	feb570e3          	bgeu	a0,a1,ffffffffc0204730 <vprintfmt+0xd8>
ffffffffc0204754:	f60cd0e3          	bgez	s9,ffffffffc02046b4 <vprintfmt+0x5c>
ffffffffc0204758:	8cea                	mv	s9,s10
ffffffffc020475a:	5d7d                	li	s10,-1
ffffffffc020475c:	bfa1                	j	ffffffffc02046b4 <vprintfmt+0x5c>
ffffffffc020475e:	8db6                	mv	s11,a3
ffffffffc0204760:	8462                	mv	s0,s8
ffffffffc0204762:	bf89                	j	ffffffffc02046b4 <vprintfmt+0x5c>
ffffffffc0204764:	8462                	mv	s0,s8
ffffffffc0204766:	4b85                	li	s7,1
ffffffffc0204768:	b7b1                	j	ffffffffc02046b4 <vprintfmt+0x5c>
ffffffffc020476a:	4785                	li	a5,1
ffffffffc020476c:	008a0713          	addi	a4,s4,8
ffffffffc0204770:	00c7c463          	blt	a5,a2,ffffffffc0204778 <vprintfmt+0x120>
ffffffffc0204774:	1a060263          	beqz	a2,ffffffffc0204918 <vprintfmt+0x2c0>
ffffffffc0204778:	000a3603          	ld	a2,0(s4)
ffffffffc020477c:	46c1                	li	a3,16
ffffffffc020477e:	8a3a                	mv	s4,a4
ffffffffc0204780:	000d879b          	sext.w	a5,s11
ffffffffc0204784:	8766                	mv	a4,s9
ffffffffc0204786:	85a6                	mv	a1,s1
ffffffffc0204788:	854a                	mv	a0,s2
ffffffffc020478a:	e61ff0ef          	jal	ra,ffffffffc02045ea <printnum>
ffffffffc020478e:	bdfd                	j	ffffffffc020468c <vprintfmt+0x34>
ffffffffc0204790:	000a2503          	lw	a0,0(s4)
ffffffffc0204794:	85a6                	mv	a1,s1
ffffffffc0204796:	0a21                	addi	s4,s4,8
ffffffffc0204798:	9902                	jalr	s2
ffffffffc020479a:	bdcd                	j	ffffffffc020468c <vprintfmt+0x34>
ffffffffc020479c:	4785                	li	a5,1
ffffffffc020479e:	008a0713          	addi	a4,s4,8
ffffffffc02047a2:	00c7c463          	blt	a5,a2,ffffffffc02047aa <vprintfmt+0x152>
ffffffffc02047a6:	16060463          	beqz	a2,ffffffffc020490e <vprintfmt+0x2b6>
ffffffffc02047aa:	000a3603          	ld	a2,0(s4)
ffffffffc02047ae:	46a9                	li	a3,10
ffffffffc02047b0:	8a3a                	mv	s4,a4
ffffffffc02047b2:	b7f9                	j	ffffffffc0204780 <vprintfmt+0x128>
ffffffffc02047b4:	03000513          	li	a0,48
ffffffffc02047b8:	85a6                	mv	a1,s1
ffffffffc02047ba:	9902                	jalr	s2
ffffffffc02047bc:	85a6                	mv	a1,s1
ffffffffc02047be:	07800513          	li	a0,120
ffffffffc02047c2:	9902                	jalr	s2
ffffffffc02047c4:	0a21                	addi	s4,s4,8
ffffffffc02047c6:	46c1                	li	a3,16
ffffffffc02047c8:	ff8a3603          	ld	a2,-8(s4)
ffffffffc02047cc:	bf55                	j	ffffffffc0204780 <vprintfmt+0x128>
ffffffffc02047ce:	85a6                	mv	a1,s1
ffffffffc02047d0:	02500513          	li	a0,37
ffffffffc02047d4:	9902                	jalr	s2
ffffffffc02047d6:	bd5d                	j	ffffffffc020468c <vprintfmt+0x34>
ffffffffc02047d8:	000a2d03          	lw	s10,0(s4)
ffffffffc02047dc:	8462                	mv	s0,s8
ffffffffc02047de:	0a21                	addi	s4,s4,8
ffffffffc02047e0:	bf95                	j	ffffffffc0204754 <vprintfmt+0xfc>
ffffffffc02047e2:	4785                	li	a5,1
ffffffffc02047e4:	008a0713          	addi	a4,s4,8
ffffffffc02047e8:	00c7c463          	blt	a5,a2,ffffffffc02047f0 <vprintfmt+0x198>
ffffffffc02047ec:	10060c63          	beqz	a2,ffffffffc0204904 <vprintfmt+0x2ac>
ffffffffc02047f0:	000a3603          	ld	a2,0(s4)
ffffffffc02047f4:	46a1                	li	a3,8
ffffffffc02047f6:	8a3a                	mv	s4,a4
ffffffffc02047f8:	b761                	j	ffffffffc0204780 <vprintfmt+0x128>
ffffffffc02047fa:	fffcc793          	not	a5,s9
ffffffffc02047fe:	97fd                	srai	a5,a5,0x3f
ffffffffc0204800:	00fcf7b3          	and	a5,s9,a5
ffffffffc0204804:	00078c9b          	sext.w	s9,a5
ffffffffc0204808:	8462                	mv	s0,s8
ffffffffc020480a:	b56d                	j	ffffffffc02046b4 <vprintfmt+0x5c>
ffffffffc020480c:	000a3403          	ld	s0,0(s4)
ffffffffc0204810:	008a0793          	addi	a5,s4,8
ffffffffc0204814:	e43e                	sd	a5,8(sp)
ffffffffc0204816:	12040163          	beqz	s0,ffffffffc0204938 <vprintfmt+0x2e0>
ffffffffc020481a:	0d905963          	blez	s9,ffffffffc02048ec <vprintfmt+0x294>
ffffffffc020481e:	02d00793          	li	a5,45
ffffffffc0204822:	00140a13          	addi	s4,s0,1
ffffffffc0204826:	12fd9863          	bne	s11,a5,ffffffffc0204956 <vprintfmt+0x2fe>
ffffffffc020482a:	00044783          	lbu	a5,0(s0)
ffffffffc020482e:	0007851b          	sext.w	a0,a5
ffffffffc0204832:	cb9d                	beqz	a5,ffffffffc0204868 <vprintfmt+0x210>
ffffffffc0204834:	547d                	li	s0,-1
ffffffffc0204836:	05e00d93          	li	s11,94
ffffffffc020483a:	000d4563          	bltz	s10,ffffffffc0204844 <vprintfmt+0x1ec>
ffffffffc020483e:	3d7d                	addiw	s10,s10,-1
ffffffffc0204840:	028d0263          	beq	s10,s0,ffffffffc0204864 <vprintfmt+0x20c>
ffffffffc0204844:	85a6                	mv	a1,s1
ffffffffc0204846:	0c0b8e63          	beqz	s7,ffffffffc0204922 <vprintfmt+0x2ca>
ffffffffc020484a:	3781                	addiw	a5,a5,-32
ffffffffc020484c:	0cfdfb63          	bgeu	s11,a5,ffffffffc0204922 <vprintfmt+0x2ca>
ffffffffc0204850:	03f00513          	li	a0,63
ffffffffc0204854:	9902                	jalr	s2
ffffffffc0204856:	000a4783          	lbu	a5,0(s4)
ffffffffc020485a:	3cfd                	addiw	s9,s9,-1
ffffffffc020485c:	0a05                	addi	s4,s4,1
ffffffffc020485e:	0007851b          	sext.w	a0,a5
ffffffffc0204862:	ffe1                	bnez	a5,ffffffffc020483a <vprintfmt+0x1e2>
ffffffffc0204864:	01905963          	blez	s9,ffffffffc0204876 <vprintfmt+0x21e>
ffffffffc0204868:	3cfd                	addiw	s9,s9,-1
ffffffffc020486a:	85a6                	mv	a1,s1
ffffffffc020486c:	02000513          	li	a0,32
ffffffffc0204870:	9902                	jalr	s2
ffffffffc0204872:	fe0c9be3          	bnez	s9,ffffffffc0204868 <vprintfmt+0x210>
ffffffffc0204876:	6a22                	ld	s4,8(sp)
ffffffffc0204878:	bd11                	j	ffffffffc020468c <vprintfmt+0x34>
ffffffffc020487a:	4785                	li	a5,1
ffffffffc020487c:	008a0b93          	addi	s7,s4,8
ffffffffc0204880:	00c7c363          	blt	a5,a2,ffffffffc0204886 <vprintfmt+0x22e>
ffffffffc0204884:	ce2d                	beqz	a2,ffffffffc02048fe <vprintfmt+0x2a6>
ffffffffc0204886:	000a3403          	ld	s0,0(s4)
ffffffffc020488a:	08044e63          	bltz	s0,ffffffffc0204926 <vprintfmt+0x2ce>
ffffffffc020488e:	8622                	mv	a2,s0
ffffffffc0204890:	8a5e                	mv	s4,s7
ffffffffc0204892:	46a9                	li	a3,10
ffffffffc0204894:	b5f5                	j	ffffffffc0204780 <vprintfmt+0x128>
ffffffffc0204896:	000a2783          	lw	a5,0(s4)
ffffffffc020489a:	4619                	li	a2,6
ffffffffc020489c:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc02048a0:	8fb9                	xor	a5,a5,a4
ffffffffc02048a2:	40e786bb          	subw	a3,a5,a4
ffffffffc02048a6:	02d64663          	blt	a2,a3,ffffffffc02048d2 <vprintfmt+0x27a>
ffffffffc02048aa:	00369713          	slli	a4,a3,0x3
ffffffffc02048ae:	00002797          	auipc	a5,0x2
ffffffffc02048b2:	28a78793          	addi	a5,a5,650 # ffffffffc0206b38 <error_string>
ffffffffc02048b6:	97ba                	add	a5,a5,a4
ffffffffc02048b8:	639c                	ld	a5,0(a5)
ffffffffc02048ba:	cf81                	beqz	a5,ffffffffc02048d2 <vprintfmt+0x27a>
ffffffffc02048bc:	86be                	mv	a3,a5
ffffffffc02048be:	00000617          	auipc	a2,0x0
ffffffffc02048c2:	22260613          	addi	a2,a2,546 # ffffffffc0204ae0 <etext+0x28>
ffffffffc02048c6:	85a6                	mv	a1,s1
ffffffffc02048c8:	854a                	mv	a0,s2
ffffffffc02048ca:	0ea000ef          	jal	ra,ffffffffc02049b4 <printfmt>
ffffffffc02048ce:	0a21                	addi	s4,s4,8
ffffffffc02048d0:	bb75                	j	ffffffffc020468c <vprintfmt+0x34>
ffffffffc02048d2:	00002617          	auipc	a2,0x2
ffffffffc02048d6:	07e60613          	addi	a2,a2,126 # ffffffffc0206950 <default_pmm_manager+0x1148>
ffffffffc02048da:	85a6                	mv	a1,s1
ffffffffc02048dc:	854a                	mv	a0,s2
ffffffffc02048de:	0d6000ef          	jal	ra,ffffffffc02049b4 <printfmt>
ffffffffc02048e2:	0a21                	addi	s4,s4,8
ffffffffc02048e4:	b365                	j	ffffffffc020468c <vprintfmt+0x34>
ffffffffc02048e6:	2605                	addiw	a2,a2,1
ffffffffc02048e8:	8462                	mv	s0,s8
ffffffffc02048ea:	b3e9                	j	ffffffffc02046b4 <vprintfmt+0x5c>
ffffffffc02048ec:	00044783          	lbu	a5,0(s0)
ffffffffc02048f0:	00140a13          	addi	s4,s0,1
ffffffffc02048f4:	0007851b          	sext.w	a0,a5
ffffffffc02048f8:	ff95                	bnez	a5,ffffffffc0204834 <vprintfmt+0x1dc>
ffffffffc02048fa:	6a22                	ld	s4,8(sp)
ffffffffc02048fc:	bb41                	j	ffffffffc020468c <vprintfmt+0x34>
ffffffffc02048fe:	000a2403          	lw	s0,0(s4)
ffffffffc0204902:	b761                	j	ffffffffc020488a <vprintfmt+0x232>
ffffffffc0204904:	000a6603          	lwu	a2,0(s4)
ffffffffc0204908:	46a1                	li	a3,8
ffffffffc020490a:	8a3a                	mv	s4,a4
ffffffffc020490c:	bd95                	j	ffffffffc0204780 <vprintfmt+0x128>
ffffffffc020490e:	000a6603          	lwu	a2,0(s4)
ffffffffc0204912:	46a9                	li	a3,10
ffffffffc0204914:	8a3a                	mv	s4,a4
ffffffffc0204916:	b5ad                	j	ffffffffc0204780 <vprintfmt+0x128>
ffffffffc0204918:	000a6603          	lwu	a2,0(s4)
ffffffffc020491c:	46c1                	li	a3,16
ffffffffc020491e:	8a3a                	mv	s4,a4
ffffffffc0204920:	b585                	j	ffffffffc0204780 <vprintfmt+0x128>
ffffffffc0204922:	9902                	jalr	s2
ffffffffc0204924:	bf0d                	j	ffffffffc0204856 <vprintfmt+0x1fe>
ffffffffc0204926:	85a6                	mv	a1,s1
ffffffffc0204928:	02d00513          	li	a0,45
ffffffffc020492c:	9902                	jalr	s2
ffffffffc020492e:	8a5e                	mv	s4,s7
ffffffffc0204930:	40800633          	neg	a2,s0
ffffffffc0204934:	46a9                	li	a3,10
ffffffffc0204936:	b5a9                	j	ffffffffc0204780 <vprintfmt+0x128>
ffffffffc0204938:	01905663          	blez	s9,ffffffffc0204944 <vprintfmt+0x2ec>
ffffffffc020493c:	02d00793          	li	a5,45
ffffffffc0204940:	04fd9263          	bne	s11,a5,ffffffffc0204984 <vprintfmt+0x32c>
ffffffffc0204944:	00002a17          	auipc	s4,0x2
ffffffffc0204948:	005a0a13          	addi	s4,s4,5 # ffffffffc0206949 <default_pmm_manager+0x1141>
ffffffffc020494c:	02800513          	li	a0,40
ffffffffc0204950:	02800793          	li	a5,40
ffffffffc0204954:	b5c5                	j	ffffffffc0204834 <vprintfmt+0x1dc>
ffffffffc0204956:	85ea                	mv	a1,s10
ffffffffc0204958:	8522                	mv	a0,s0
ffffffffc020495a:	094000ef          	jal	ra,ffffffffc02049ee <strnlen>
ffffffffc020495e:	40ac8cbb          	subw	s9,s9,a0
ffffffffc0204962:	01905963          	blez	s9,ffffffffc0204974 <vprintfmt+0x31c>
ffffffffc0204966:	2d81                	sext.w	s11,s11
ffffffffc0204968:	3cfd                	addiw	s9,s9,-1
ffffffffc020496a:	85a6                	mv	a1,s1
ffffffffc020496c:	856e                	mv	a0,s11
ffffffffc020496e:	9902                	jalr	s2
ffffffffc0204970:	fe0c9ce3          	bnez	s9,ffffffffc0204968 <vprintfmt+0x310>
ffffffffc0204974:	00044783          	lbu	a5,0(s0)
ffffffffc0204978:	0007851b          	sext.w	a0,a5
ffffffffc020497c:	ea079ce3          	bnez	a5,ffffffffc0204834 <vprintfmt+0x1dc>
ffffffffc0204980:	6a22                	ld	s4,8(sp)
ffffffffc0204982:	b329                	j	ffffffffc020468c <vprintfmt+0x34>
ffffffffc0204984:	85ea                	mv	a1,s10
ffffffffc0204986:	00002517          	auipc	a0,0x2
ffffffffc020498a:	fc250513          	addi	a0,a0,-62 # ffffffffc0206948 <default_pmm_manager+0x1140>
ffffffffc020498e:	060000ef          	jal	ra,ffffffffc02049ee <strnlen>
ffffffffc0204992:	40ac8cbb          	subw	s9,s9,a0
ffffffffc0204996:	00002a17          	auipc	s4,0x2
ffffffffc020499a:	fb3a0a13          	addi	s4,s4,-77 # ffffffffc0206949 <default_pmm_manager+0x1141>
ffffffffc020499e:	00002417          	auipc	s0,0x2
ffffffffc02049a2:	faa40413          	addi	s0,s0,-86 # ffffffffc0206948 <default_pmm_manager+0x1140>
ffffffffc02049a6:	02800513          	li	a0,40
ffffffffc02049aa:	02800793          	li	a5,40
ffffffffc02049ae:	fb904ce3          	bgtz	s9,ffffffffc0204966 <vprintfmt+0x30e>
ffffffffc02049b2:	b549                	j	ffffffffc0204834 <vprintfmt+0x1dc>

ffffffffc02049b4 <printfmt>:
ffffffffc02049b4:	715d                	addi	sp,sp,-80
ffffffffc02049b6:	02810313          	addi	t1,sp,40
ffffffffc02049ba:	f436                	sd	a3,40(sp)
ffffffffc02049bc:	869a                	mv	a3,t1
ffffffffc02049be:	ec06                	sd	ra,24(sp)
ffffffffc02049c0:	f83a                	sd	a4,48(sp)
ffffffffc02049c2:	fc3e                	sd	a5,56(sp)
ffffffffc02049c4:	e0c2                	sd	a6,64(sp)
ffffffffc02049c6:	e4c6                	sd	a7,72(sp)
ffffffffc02049c8:	e41a                	sd	t1,8(sp)
ffffffffc02049ca:	c8fff0ef          	jal	ra,ffffffffc0204658 <vprintfmt>
ffffffffc02049ce:	60e2                	ld	ra,24(sp)
ffffffffc02049d0:	6161                	addi	sp,sp,80
ffffffffc02049d2:	8082                	ret

ffffffffc02049d4 <strlen>:
ffffffffc02049d4:	00054783          	lbu	a5,0(a0)
ffffffffc02049d8:	872a                	mv	a4,a0
ffffffffc02049da:	4501                	li	a0,0
ffffffffc02049dc:	cb81                	beqz	a5,ffffffffc02049ec <strlen+0x18>
ffffffffc02049de:	0505                	addi	a0,a0,1
ffffffffc02049e0:	00a707b3          	add	a5,a4,a0
ffffffffc02049e4:	0007c783          	lbu	a5,0(a5)
ffffffffc02049e8:	fbfd                	bnez	a5,ffffffffc02049de <strlen+0xa>
ffffffffc02049ea:	8082                	ret
ffffffffc02049ec:	8082                	ret

ffffffffc02049ee <strnlen>:
ffffffffc02049ee:	4781                	li	a5,0
ffffffffc02049f0:	e589                	bnez	a1,ffffffffc02049fa <strnlen+0xc>
ffffffffc02049f2:	a811                	j	ffffffffc0204a06 <strnlen+0x18>
ffffffffc02049f4:	0785                	addi	a5,a5,1
ffffffffc02049f6:	00f58863          	beq	a1,a5,ffffffffc0204a06 <strnlen+0x18>
ffffffffc02049fa:	00f50733          	add	a4,a0,a5
ffffffffc02049fe:	00074703          	lbu	a4,0(a4)
ffffffffc0204a02:	fb6d                	bnez	a4,ffffffffc02049f4 <strnlen+0x6>
ffffffffc0204a04:	85be                	mv	a1,a5
ffffffffc0204a06:	852e                	mv	a0,a1
ffffffffc0204a08:	8082                	ret

ffffffffc0204a0a <strcpy>:
ffffffffc0204a0a:	87aa                	mv	a5,a0
ffffffffc0204a0c:	0005c703          	lbu	a4,0(a1)
ffffffffc0204a10:	0785                	addi	a5,a5,1
ffffffffc0204a12:	0585                	addi	a1,a1,1
ffffffffc0204a14:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204a18:	fb75                	bnez	a4,ffffffffc0204a0c <strcpy+0x2>
ffffffffc0204a1a:	8082                	ret

ffffffffc0204a1c <strcmp>:
ffffffffc0204a1c:	00054783          	lbu	a5,0(a0)
ffffffffc0204a20:	e791                	bnez	a5,ffffffffc0204a2c <strcmp+0x10>
ffffffffc0204a22:	a02d                	j	ffffffffc0204a4c <strcmp+0x30>
ffffffffc0204a24:	00054783          	lbu	a5,0(a0)
ffffffffc0204a28:	cf89                	beqz	a5,ffffffffc0204a42 <strcmp+0x26>
ffffffffc0204a2a:	85b6                	mv	a1,a3
ffffffffc0204a2c:	0005c703          	lbu	a4,0(a1)
ffffffffc0204a30:	0505                	addi	a0,a0,1
ffffffffc0204a32:	00158693          	addi	a3,a1,1
ffffffffc0204a36:	fef707e3          	beq	a4,a5,ffffffffc0204a24 <strcmp+0x8>
ffffffffc0204a3a:	0007851b          	sext.w	a0,a5
ffffffffc0204a3e:	9d19                	subw	a0,a0,a4
ffffffffc0204a40:	8082                	ret
ffffffffc0204a42:	0015c703          	lbu	a4,1(a1)
ffffffffc0204a46:	4501                	li	a0,0
ffffffffc0204a48:	9d19                	subw	a0,a0,a4
ffffffffc0204a4a:	8082                	ret
ffffffffc0204a4c:	0005c703          	lbu	a4,0(a1)
ffffffffc0204a50:	4501                	li	a0,0
ffffffffc0204a52:	b7f5                	j	ffffffffc0204a3e <strcmp+0x22>

ffffffffc0204a54 <strchr>:
ffffffffc0204a54:	00054783          	lbu	a5,0(a0)
ffffffffc0204a58:	c799                	beqz	a5,ffffffffc0204a66 <strchr+0x12>
ffffffffc0204a5a:	00f58763          	beq	a1,a5,ffffffffc0204a68 <strchr+0x14>
ffffffffc0204a5e:	00154783          	lbu	a5,1(a0)
ffffffffc0204a62:	0505                	addi	a0,a0,1
ffffffffc0204a64:	fbfd                	bnez	a5,ffffffffc0204a5a <strchr+0x6>
ffffffffc0204a66:	4501                	li	a0,0
ffffffffc0204a68:	8082                	ret

ffffffffc0204a6a <memset>:
ffffffffc0204a6a:	ca01                	beqz	a2,ffffffffc0204a7a <memset+0x10>
ffffffffc0204a6c:	962a                	add	a2,a2,a0
ffffffffc0204a6e:	87aa                	mv	a5,a0
ffffffffc0204a70:	0785                	addi	a5,a5,1
ffffffffc0204a72:	feb78fa3          	sb	a1,-1(a5)
ffffffffc0204a76:	fec79de3          	bne	a5,a2,ffffffffc0204a70 <memset+0x6>
ffffffffc0204a7a:	8082                	ret

ffffffffc0204a7c <memcpy>:
ffffffffc0204a7c:	ca19                	beqz	a2,ffffffffc0204a92 <memcpy+0x16>
ffffffffc0204a7e:	962e                	add	a2,a2,a1
ffffffffc0204a80:	87aa                	mv	a5,a0
ffffffffc0204a82:	0005c703          	lbu	a4,0(a1)
ffffffffc0204a86:	0585                	addi	a1,a1,1
ffffffffc0204a88:	0785                	addi	a5,a5,1
ffffffffc0204a8a:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204a8e:	fec59ae3          	bne	a1,a2,ffffffffc0204a82 <memcpy+0x6>
ffffffffc0204a92:	8082                	ret

ffffffffc0204a94 <memcmp>:
ffffffffc0204a94:	c205                	beqz	a2,ffffffffc0204ab4 <memcmp+0x20>
ffffffffc0204a96:	962e                	add	a2,a2,a1
ffffffffc0204a98:	a019                	j	ffffffffc0204a9e <memcmp+0xa>
ffffffffc0204a9a:	00c58d63          	beq	a1,a2,ffffffffc0204ab4 <memcmp+0x20>
ffffffffc0204a9e:	00054783          	lbu	a5,0(a0)
ffffffffc0204aa2:	0005c703          	lbu	a4,0(a1)
ffffffffc0204aa6:	0505                	addi	a0,a0,1
ffffffffc0204aa8:	0585                	addi	a1,a1,1
ffffffffc0204aaa:	fee788e3          	beq	a5,a4,ffffffffc0204a9a <memcmp+0x6>
ffffffffc0204aae:	40e7853b          	subw	a0,a5,a4
ffffffffc0204ab2:	8082                	ret
ffffffffc0204ab4:	4501                	li	a0,0
ffffffffc0204ab6:	8082                	ret
