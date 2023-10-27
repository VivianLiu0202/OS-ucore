
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
ffffffffc0200036:	00e50513          	addi	a0,a0,14 # ffffffffc020a040 <ide>
ffffffffc020003a:	00011617          	auipc	a2,0x11
ffffffffc020003e:	53e60613          	addi	a2,a2,1342 # ffffffffc0211578 <end>
ffffffffc0200042:	1141                	addi	sp,sp,-16
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
ffffffffc0200048:	e406                	sd	ra,8(sp)
ffffffffc020004a:	41a040ef          	jal	ra,ffffffffc0204464 <memset>
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	44258593          	addi	a1,a1,1090 # ffffffffc0204490 <etext+0x2>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	45a50513          	addi	a0,a0,1114 # ffffffffc02044b0 <etext+0x22>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200062:	0a0000ef          	jal	ra,ffffffffc0200102 <print_kerninfo>
ffffffffc0200066:	273010ef          	jal	ra,ffffffffc0201ad8 <pmm_init>
ffffffffc020006a:	4e8000ef          	jal	ra,ffffffffc0200552 <idt_init>
ffffffffc020006e:	65c030ef          	jal	ra,ffffffffc02036ca <vmm_init>
ffffffffc0200072:	40e000ef          	jal	ra,ffffffffc0200480 <ide_init>
ffffffffc0200076:	0bf020ef          	jal	ra,ffffffffc0202934 <swap_init>
ffffffffc020007a:	344000ef          	jal	ra,ffffffffc02003be <clock_init>
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <cputch>:
ffffffffc0200080:	1141                	addi	sp,sp,-16
ffffffffc0200082:	e022                	sd	s0,0(sp)
ffffffffc0200084:	e406                	sd	ra,8(sp)
ffffffffc0200086:	842e                	mv	s0,a1
ffffffffc0200088:	388000ef          	jal	ra,ffffffffc0200410 <cons_putc>
ffffffffc020008c:	401c                	lw	a5,0(s0)
ffffffffc020008e:	60a2                	ld	ra,8(sp)
ffffffffc0200090:	2785                	addiw	a5,a5,1
ffffffffc0200092:	c01c                	sw	a5,0(s0)
ffffffffc0200094:	6402                	ld	s0,0(sp)
ffffffffc0200096:	0141                	addi	sp,sp,16
ffffffffc0200098:	8082                	ret

ffffffffc020009a <vcprintf>:
ffffffffc020009a:	1101                	addi	sp,sp,-32
ffffffffc020009c:	862a                	mv	a2,a0
ffffffffc020009e:	86ae                	mv	a3,a1
ffffffffc02000a0:	00000517          	auipc	a0,0x0
ffffffffc02000a4:	fe050513          	addi	a0,a0,-32 # ffffffffc0200080 <cputch>
ffffffffc02000a8:	006c                	addi	a1,sp,12
ffffffffc02000aa:	ec06                	sd	ra,24(sp)
ffffffffc02000ac:	c602                	sw	zero,12(sp)
ffffffffc02000ae:	6e7030ef          	jal	ra,ffffffffc0203f94 <vprintfmt>
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
ffffffffc02000b4:	4532                	lw	a0,12(sp)
ffffffffc02000b6:	6105                	addi	sp,sp,32
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <cprintf>:
ffffffffc02000ba:	711d                	addi	sp,sp,-96
ffffffffc02000bc:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
ffffffffc02000c0:	8e2a                	mv	t3,a0
ffffffffc02000c2:	f42e                	sd	a1,40(sp)
ffffffffc02000c4:	f832                	sd	a2,48(sp)
ffffffffc02000c6:	fc36                	sd	a3,56(sp)
ffffffffc02000c8:	00000517          	auipc	a0,0x0
ffffffffc02000cc:	fb850513          	addi	a0,a0,-72 # ffffffffc0200080 <cputch>
ffffffffc02000d0:	004c                	addi	a1,sp,4
ffffffffc02000d2:	869a                	mv	a3,t1
ffffffffc02000d4:	8672                	mv	a2,t3
ffffffffc02000d6:	ec06                	sd	ra,24(sp)
ffffffffc02000d8:	e0ba                	sd	a4,64(sp)
ffffffffc02000da:	e4be                	sd	a5,72(sp)
ffffffffc02000dc:	e8c2                	sd	a6,80(sp)
ffffffffc02000de:	ecc6                	sd	a7,88(sp)
ffffffffc02000e0:	e41a                	sd	t1,8(sp)
ffffffffc02000e2:	c202                	sw	zero,4(sp)
ffffffffc02000e4:	6b1030ef          	jal	ra,ffffffffc0203f94 <vprintfmt>
ffffffffc02000e8:	60e2                	ld	ra,24(sp)
ffffffffc02000ea:	4512                	lw	a0,4(sp)
ffffffffc02000ec:	6125                	addi	sp,sp,96
ffffffffc02000ee:	8082                	ret

ffffffffc02000f0 <cputchar>:
ffffffffc02000f0:	a605                	j	ffffffffc0200410 <cons_putc>

ffffffffc02000f2 <getchar>:
ffffffffc02000f2:	1141                	addi	sp,sp,-16
ffffffffc02000f4:	e406                	sd	ra,8(sp)
ffffffffc02000f6:	34e000ef          	jal	ra,ffffffffc0200444 <cons_getc>
ffffffffc02000fa:	dd75                	beqz	a0,ffffffffc02000f6 <getchar+0x4>
ffffffffc02000fc:	60a2                	ld	ra,8(sp)
ffffffffc02000fe:	0141                	addi	sp,sp,16
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <print_kerninfo>:
ffffffffc0200102:	1141                	addi	sp,sp,-16
ffffffffc0200104:	00004517          	auipc	a0,0x4
ffffffffc0200108:	3b450513          	addi	a0,a0,948 # ffffffffc02044b8 <etext+0x2a>
ffffffffc020010c:	e406                	sd	ra,8(sp)
ffffffffc020010e:	fadff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200112:	00000597          	auipc	a1,0x0
ffffffffc0200116:	f2058593          	addi	a1,a1,-224 # ffffffffc0200032 <kern_init>
ffffffffc020011a:	00004517          	auipc	a0,0x4
ffffffffc020011e:	3be50513          	addi	a0,a0,958 # ffffffffc02044d8 <etext+0x4a>
ffffffffc0200122:	f99ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200126:	00004597          	auipc	a1,0x4
ffffffffc020012a:	36858593          	addi	a1,a1,872 # ffffffffc020448e <etext>
ffffffffc020012e:	00004517          	auipc	a0,0x4
ffffffffc0200132:	3ca50513          	addi	a0,a0,970 # ffffffffc02044f8 <etext+0x6a>
ffffffffc0200136:	f85ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020013a:	0000a597          	auipc	a1,0xa
ffffffffc020013e:	f0658593          	addi	a1,a1,-250 # ffffffffc020a040 <ide>
ffffffffc0200142:	00004517          	auipc	a0,0x4
ffffffffc0200146:	3d650513          	addi	a0,a0,982 # ffffffffc0204518 <etext+0x8a>
ffffffffc020014a:	f71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020014e:	00011597          	auipc	a1,0x11
ffffffffc0200152:	42a58593          	addi	a1,a1,1066 # ffffffffc0211578 <end>
ffffffffc0200156:	00004517          	auipc	a0,0x4
ffffffffc020015a:	3e250513          	addi	a0,a0,994 # ffffffffc0204538 <etext+0xaa>
ffffffffc020015e:	f5dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200162:	00012797          	auipc	a5,0x12
ffffffffc0200166:	81578793          	addi	a5,a5,-2027 # ffffffffc0211977 <end+0x3ff>
ffffffffc020016a:	00000717          	auipc	a4,0x0
ffffffffc020016e:	ec870713          	addi	a4,a4,-312 # ffffffffc0200032 <kern_init>
ffffffffc0200172:	8f99                	sub	a5,a5,a4
ffffffffc0200174:	43f7d593          	srai	a1,a5,0x3f
ffffffffc0200178:	60a2                	ld	ra,8(sp)
ffffffffc020017a:	3ff5f593          	andi	a1,a1,1023
ffffffffc020017e:	95be                	add	a1,a1,a5
ffffffffc0200180:	85a9                	srai	a1,a1,0xa
ffffffffc0200182:	00004517          	auipc	a0,0x4
ffffffffc0200186:	3d650513          	addi	a0,a0,982 # ffffffffc0204558 <etext+0xca>
ffffffffc020018a:	0141                	addi	sp,sp,16
ffffffffc020018c:	b73d                	j	ffffffffc02000ba <cprintf>

ffffffffc020018e <print_stackframe>:
ffffffffc020018e:	1141                	addi	sp,sp,-16
ffffffffc0200190:	00004617          	auipc	a2,0x4
ffffffffc0200194:	3f860613          	addi	a2,a2,1016 # ffffffffc0204588 <etext+0xfa>
ffffffffc0200198:	04e00593          	li	a1,78
ffffffffc020019c:	00004517          	auipc	a0,0x4
ffffffffc02001a0:	40450513          	addi	a0,a0,1028 # ffffffffc02045a0 <etext+0x112>
ffffffffc02001a4:	e406                	sd	ra,8(sp)
ffffffffc02001a6:	1bc000ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc02001aa <mon_help>:
ffffffffc02001aa:	1141                	addi	sp,sp,-16
ffffffffc02001ac:	00004617          	auipc	a2,0x4
ffffffffc02001b0:	40c60613          	addi	a2,a2,1036 # ffffffffc02045b8 <etext+0x12a>
ffffffffc02001b4:	00004597          	auipc	a1,0x4
ffffffffc02001b8:	42458593          	addi	a1,a1,1060 # ffffffffc02045d8 <etext+0x14a>
ffffffffc02001bc:	00004517          	auipc	a0,0x4
ffffffffc02001c0:	42450513          	addi	a0,a0,1060 # ffffffffc02045e0 <etext+0x152>
ffffffffc02001c4:	e406                	sd	ra,8(sp)
ffffffffc02001c6:	ef5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001ca:	00004617          	auipc	a2,0x4
ffffffffc02001ce:	42660613          	addi	a2,a2,1062 # ffffffffc02045f0 <etext+0x162>
ffffffffc02001d2:	00004597          	auipc	a1,0x4
ffffffffc02001d6:	44658593          	addi	a1,a1,1094 # ffffffffc0204618 <etext+0x18a>
ffffffffc02001da:	00004517          	auipc	a0,0x4
ffffffffc02001de:	40650513          	addi	a0,a0,1030 # ffffffffc02045e0 <etext+0x152>
ffffffffc02001e2:	ed9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001e6:	00004617          	auipc	a2,0x4
ffffffffc02001ea:	44260613          	addi	a2,a2,1090 # ffffffffc0204628 <etext+0x19a>
ffffffffc02001ee:	00004597          	auipc	a1,0x4
ffffffffc02001f2:	45a58593          	addi	a1,a1,1114 # ffffffffc0204648 <etext+0x1ba>
ffffffffc02001f6:	00004517          	auipc	a0,0x4
ffffffffc02001fa:	3ea50513          	addi	a0,a0,1002 # ffffffffc02045e0 <etext+0x152>
ffffffffc02001fe:	ebdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200202:	60a2                	ld	ra,8(sp)
ffffffffc0200204:	4501                	li	a0,0
ffffffffc0200206:	0141                	addi	sp,sp,16
ffffffffc0200208:	8082                	ret

ffffffffc020020a <mon_kerninfo>:
ffffffffc020020a:	1141                	addi	sp,sp,-16
ffffffffc020020c:	e406                	sd	ra,8(sp)
ffffffffc020020e:	ef5ff0ef          	jal	ra,ffffffffc0200102 <print_kerninfo>
ffffffffc0200212:	60a2                	ld	ra,8(sp)
ffffffffc0200214:	4501                	li	a0,0
ffffffffc0200216:	0141                	addi	sp,sp,16
ffffffffc0200218:	8082                	ret

ffffffffc020021a <mon_backtrace>:
ffffffffc020021a:	1141                	addi	sp,sp,-16
ffffffffc020021c:	e406                	sd	ra,8(sp)
ffffffffc020021e:	f71ff0ef          	jal	ra,ffffffffc020018e <print_stackframe>
ffffffffc0200222:	60a2                	ld	ra,8(sp)
ffffffffc0200224:	4501                	li	a0,0
ffffffffc0200226:	0141                	addi	sp,sp,16
ffffffffc0200228:	8082                	ret

ffffffffc020022a <kmonitor>:
ffffffffc020022a:	7115                	addi	sp,sp,-224
ffffffffc020022c:	f15a                	sd	s6,160(sp)
ffffffffc020022e:	8b2a                	mv	s6,a0
ffffffffc0200230:	00004517          	auipc	a0,0x4
ffffffffc0200234:	42850513          	addi	a0,a0,1064 # ffffffffc0204658 <etext+0x1ca>
ffffffffc0200238:	ed86                	sd	ra,216(sp)
ffffffffc020023a:	e9a2                	sd	s0,208(sp)
ffffffffc020023c:	e5a6                	sd	s1,200(sp)
ffffffffc020023e:	e1ca                	sd	s2,192(sp)
ffffffffc0200240:	fd4e                	sd	s3,184(sp)
ffffffffc0200242:	f952                	sd	s4,176(sp)
ffffffffc0200244:	f556                	sd	s5,168(sp)
ffffffffc0200246:	ed5e                	sd	s7,152(sp)
ffffffffc0200248:	e962                	sd	s8,144(sp)
ffffffffc020024a:	e566                	sd	s9,136(sp)
ffffffffc020024c:	e16a                	sd	s10,128(sp)
ffffffffc020024e:	e6dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200252:	00004517          	auipc	a0,0x4
ffffffffc0200256:	42e50513          	addi	a0,a0,1070 # ffffffffc0204680 <etext+0x1f2>
ffffffffc020025a:	e61ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020025e:	000b0563          	beqz	s6,ffffffffc0200268 <kmonitor+0x3e>
ffffffffc0200262:	855a                	mv	a0,s6
ffffffffc0200264:	4d8000ef          	jal	ra,ffffffffc020073c <print_trapframe>
ffffffffc0200268:	00004c17          	auipc	s8,0x4
ffffffffc020026c:	480c0c13          	addi	s8,s8,1152 # ffffffffc02046e8 <commands>
ffffffffc0200270:	00006917          	auipc	s2,0x6
ffffffffc0200274:	90090913          	addi	s2,s2,-1792 # ffffffffc0205b70 <default_pmm_manager+0x9a0>
ffffffffc0200278:	00004497          	auipc	s1,0x4
ffffffffc020027c:	43048493          	addi	s1,s1,1072 # ffffffffc02046a8 <etext+0x21a>
ffffffffc0200280:	49bd                	li	s3,15
ffffffffc0200282:	00004a97          	auipc	s5,0x4
ffffffffc0200286:	42ea8a93          	addi	s5,s5,1070 # ffffffffc02046b0 <etext+0x222>
ffffffffc020028a:	4a0d                	li	s4,3
ffffffffc020028c:	00004b97          	auipc	s7,0x4
ffffffffc0200290:	444b8b93          	addi	s7,s7,1092 # ffffffffc02046d0 <etext+0x242>
ffffffffc0200294:	854a                	mv	a0,s2
ffffffffc0200296:	07a040ef          	jal	ra,ffffffffc0204310 <readline>
ffffffffc020029a:	842a                	mv	s0,a0
ffffffffc020029c:	dd65                	beqz	a0,ffffffffc0200294 <kmonitor+0x6a>
ffffffffc020029e:	00054583          	lbu	a1,0(a0)
ffffffffc02002a2:	4c81                	li	s9,0
ffffffffc02002a4:	e59d                	bnez	a1,ffffffffc02002d2 <kmonitor+0xa8>
ffffffffc02002a6:	fe0c87e3          	beqz	s9,ffffffffc0200294 <kmonitor+0x6a>
ffffffffc02002aa:	00004d17          	auipc	s10,0x4
ffffffffc02002ae:	43ed0d13          	addi	s10,s10,1086 # ffffffffc02046e8 <commands>
ffffffffc02002b2:	4401                	li	s0,0
ffffffffc02002b4:	000d3503          	ld	a0,0(s10)
ffffffffc02002b8:	6582                	ld	a1,0(sp)
ffffffffc02002ba:	0d61                	addi	s10,s10,24
ffffffffc02002bc:	15a040ef          	jal	ra,ffffffffc0204416 <strcmp>
ffffffffc02002c0:	c535                	beqz	a0,ffffffffc020032c <kmonitor+0x102>
ffffffffc02002c2:	2405                	addiw	s0,s0,1
ffffffffc02002c4:	ff4418e3          	bne	s0,s4,ffffffffc02002b4 <kmonitor+0x8a>
ffffffffc02002c8:	6582                	ld	a1,0(sp)
ffffffffc02002ca:	855e                	mv	a0,s7
ffffffffc02002cc:	defff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02002d0:	b7d1                	j	ffffffffc0200294 <kmonitor+0x6a>
ffffffffc02002d2:	8526                	mv	a0,s1
ffffffffc02002d4:	17a040ef          	jal	ra,ffffffffc020444e <strchr>
ffffffffc02002d8:	c901                	beqz	a0,ffffffffc02002e8 <kmonitor+0xbe>
ffffffffc02002da:	00144583          	lbu	a1,1(s0)
ffffffffc02002de:	00040023          	sb	zero,0(s0)
ffffffffc02002e2:	0405                	addi	s0,s0,1
ffffffffc02002e4:	d1e9                	beqz	a1,ffffffffc02002a6 <kmonitor+0x7c>
ffffffffc02002e6:	b7f5                	j	ffffffffc02002d2 <kmonitor+0xa8>
ffffffffc02002e8:	00044783          	lbu	a5,0(s0)
ffffffffc02002ec:	dfcd                	beqz	a5,ffffffffc02002a6 <kmonitor+0x7c>
ffffffffc02002ee:	033c8a63          	beq	s9,s3,ffffffffc0200322 <kmonitor+0xf8>
ffffffffc02002f2:	003c9793          	slli	a5,s9,0x3
ffffffffc02002f6:	08078793          	addi	a5,a5,128
ffffffffc02002fa:	978a                	add	a5,a5,sp
ffffffffc02002fc:	f887b023          	sd	s0,-128(a5)
ffffffffc0200300:	00044583          	lbu	a1,0(s0)
ffffffffc0200304:	2c85                	addiw	s9,s9,1
ffffffffc0200306:	e591                	bnez	a1,ffffffffc0200312 <kmonitor+0xe8>
ffffffffc0200308:	b74d                	j	ffffffffc02002aa <kmonitor+0x80>
ffffffffc020030a:	00144583          	lbu	a1,1(s0)
ffffffffc020030e:	0405                	addi	s0,s0,1
ffffffffc0200310:	d9d9                	beqz	a1,ffffffffc02002a6 <kmonitor+0x7c>
ffffffffc0200312:	8526                	mv	a0,s1
ffffffffc0200314:	13a040ef          	jal	ra,ffffffffc020444e <strchr>
ffffffffc0200318:	d96d                	beqz	a0,ffffffffc020030a <kmonitor+0xe0>
ffffffffc020031a:	00044583          	lbu	a1,0(s0)
ffffffffc020031e:	d5c1                	beqz	a1,ffffffffc02002a6 <kmonitor+0x7c>
ffffffffc0200320:	bf4d                	j	ffffffffc02002d2 <kmonitor+0xa8>
ffffffffc0200322:	45c1                	li	a1,16
ffffffffc0200324:	8556                	mv	a0,s5
ffffffffc0200326:	d95ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020032a:	b7e1                	j	ffffffffc02002f2 <kmonitor+0xc8>
ffffffffc020032c:	00141793          	slli	a5,s0,0x1
ffffffffc0200330:	97a2                	add	a5,a5,s0
ffffffffc0200332:	078e                	slli	a5,a5,0x3
ffffffffc0200334:	97e2                	add	a5,a5,s8
ffffffffc0200336:	6b9c                	ld	a5,16(a5)
ffffffffc0200338:	865a                	mv	a2,s6
ffffffffc020033a:	002c                	addi	a1,sp,8
ffffffffc020033c:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200340:	9782                	jalr	a5
ffffffffc0200342:	f40559e3          	bgez	a0,ffffffffc0200294 <kmonitor+0x6a>
ffffffffc0200346:	60ee                	ld	ra,216(sp)
ffffffffc0200348:	644e                	ld	s0,208(sp)
ffffffffc020034a:	64ae                	ld	s1,200(sp)
ffffffffc020034c:	690e                	ld	s2,192(sp)
ffffffffc020034e:	79ea                	ld	s3,184(sp)
ffffffffc0200350:	7a4a                	ld	s4,176(sp)
ffffffffc0200352:	7aaa                	ld	s5,168(sp)
ffffffffc0200354:	7b0a                	ld	s6,160(sp)
ffffffffc0200356:	6bea                	ld	s7,152(sp)
ffffffffc0200358:	6c4a                	ld	s8,144(sp)
ffffffffc020035a:	6caa                	ld	s9,136(sp)
ffffffffc020035c:	6d0a                	ld	s10,128(sp)
ffffffffc020035e:	612d                	addi	sp,sp,224
ffffffffc0200360:	8082                	ret

ffffffffc0200362 <__panic>:
ffffffffc0200362:	00011317          	auipc	t1,0x11
ffffffffc0200366:	19630313          	addi	t1,t1,406 # ffffffffc02114f8 <is_panic>
ffffffffc020036a:	00032e03          	lw	t3,0(t1)
ffffffffc020036e:	715d                	addi	sp,sp,-80
ffffffffc0200370:	ec06                	sd	ra,24(sp)
ffffffffc0200372:	e822                	sd	s0,16(sp)
ffffffffc0200374:	f436                	sd	a3,40(sp)
ffffffffc0200376:	f83a                	sd	a4,48(sp)
ffffffffc0200378:	fc3e                	sd	a5,56(sp)
ffffffffc020037a:	e0c2                	sd	a6,64(sp)
ffffffffc020037c:	e4c6                	sd	a7,72(sp)
ffffffffc020037e:	020e1a63          	bnez	t3,ffffffffc02003b2 <__panic+0x50>
ffffffffc0200382:	4785                	li	a5,1
ffffffffc0200384:	00f32023          	sw	a5,0(t1)
ffffffffc0200388:	8432                	mv	s0,a2
ffffffffc020038a:	103c                	addi	a5,sp,40
ffffffffc020038c:	862e                	mv	a2,a1
ffffffffc020038e:	85aa                	mv	a1,a0
ffffffffc0200390:	00004517          	auipc	a0,0x4
ffffffffc0200394:	3a050513          	addi	a0,a0,928 # ffffffffc0204730 <commands+0x48>
ffffffffc0200398:	e43e                	sd	a5,8(sp)
ffffffffc020039a:	d21ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020039e:	65a2                	ld	a1,8(sp)
ffffffffc02003a0:	8522                	mv	a0,s0
ffffffffc02003a2:	cf9ff0ef          	jal	ra,ffffffffc020009a <vcprintf>
ffffffffc02003a6:	00005517          	auipc	a0,0x5
ffffffffc02003aa:	2da50513          	addi	a0,a0,730 # ffffffffc0205680 <default_pmm_manager+0x4b0>
ffffffffc02003ae:	d0dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02003b2:	12a000ef          	jal	ra,ffffffffc02004dc <intr_disable>
ffffffffc02003b6:	4501                	li	a0,0
ffffffffc02003b8:	e73ff0ef          	jal	ra,ffffffffc020022a <kmonitor>
ffffffffc02003bc:	bfed                	j	ffffffffc02003b6 <__panic+0x54>

ffffffffc02003be <clock_init>:
ffffffffc02003be:	67e1                	lui	a5,0x18
ffffffffc02003c0:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02003c4:	00011717          	auipc	a4,0x11
ffffffffc02003c8:	12f73e23          	sd	a5,316(a4) # ffffffffc0211500 <timebase>
ffffffffc02003cc:	c0102573          	rdtime	a0
ffffffffc02003d0:	4581                	li	a1,0
ffffffffc02003d2:	953e                	add	a0,a0,a5
ffffffffc02003d4:	4601                	li	a2,0
ffffffffc02003d6:	4881                	li	a7,0
ffffffffc02003d8:	00000073          	ecall
ffffffffc02003dc:	02000793          	li	a5,32
ffffffffc02003e0:	1047a7f3          	csrrs	a5,sie,a5
ffffffffc02003e4:	00004517          	auipc	a0,0x4
ffffffffc02003e8:	36c50513          	addi	a0,a0,876 # ffffffffc0204750 <commands+0x68>
ffffffffc02003ec:	00011797          	auipc	a5,0x11
ffffffffc02003f0:	1007be23          	sd	zero,284(a5) # ffffffffc0211508 <ticks>
ffffffffc02003f4:	b1d9                	j	ffffffffc02000ba <cprintf>

ffffffffc02003f6 <clock_set_next_event>:
ffffffffc02003f6:	c0102573          	rdtime	a0
ffffffffc02003fa:	00011797          	auipc	a5,0x11
ffffffffc02003fe:	1067b783          	ld	a5,262(a5) # ffffffffc0211500 <timebase>
ffffffffc0200402:	953e                	add	a0,a0,a5
ffffffffc0200404:	4581                	li	a1,0
ffffffffc0200406:	4601                	li	a2,0
ffffffffc0200408:	4881                	li	a7,0
ffffffffc020040a:	00000073          	ecall
ffffffffc020040e:	8082                	ret

ffffffffc0200410 <cons_putc>:
ffffffffc0200410:	100027f3          	csrr	a5,sstatus
ffffffffc0200414:	8b89                	andi	a5,a5,2
ffffffffc0200416:	0ff57513          	andi	a0,a0,255
ffffffffc020041a:	e799                	bnez	a5,ffffffffc0200428 <cons_putc+0x18>
ffffffffc020041c:	4581                	li	a1,0
ffffffffc020041e:	4601                	li	a2,0
ffffffffc0200420:	4885                	li	a7,1
ffffffffc0200422:	00000073          	ecall
ffffffffc0200426:	8082                	ret
ffffffffc0200428:	1101                	addi	sp,sp,-32
ffffffffc020042a:	ec06                	sd	ra,24(sp)
ffffffffc020042c:	e42a                	sd	a0,8(sp)
ffffffffc020042e:	0ae000ef          	jal	ra,ffffffffc02004dc <intr_disable>
ffffffffc0200432:	6522                	ld	a0,8(sp)
ffffffffc0200434:	4581                	li	a1,0
ffffffffc0200436:	4601                	li	a2,0
ffffffffc0200438:	4885                	li	a7,1
ffffffffc020043a:	00000073          	ecall
ffffffffc020043e:	60e2                	ld	ra,24(sp)
ffffffffc0200440:	6105                	addi	sp,sp,32
ffffffffc0200442:	a851                	j	ffffffffc02004d6 <intr_enable>

ffffffffc0200444 <cons_getc>:
ffffffffc0200444:	100027f3          	csrr	a5,sstatus
ffffffffc0200448:	8b89                	andi	a5,a5,2
ffffffffc020044a:	eb89                	bnez	a5,ffffffffc020045c <cons_getc+0x18>
ffffffffc020044c:	4501                	li	a0,0
ffffffffc020044e:	4581                	li	a1,0
ffffffffc0200450:	4601                	li	a2,0
ffffffffc0200452:	4889                	li	a7,2
ffffffffc0200454:	00000073          	ecall
ffffffffc0200458:	2501                	sext.w	a0,a0
ffffffffc020045a:	8082                	ret
ffffffffc020045c:	1101                	addi	sp,sp,-32
ffffffffc020045e:	ec06                	sd	ra,24(sp)
ffffffffc0200460:	07c000ef          	jal	ra,ffffffffc02004dc <intr_disable>
ffffffffc0200464:	4501                	li	a0,0
ffffffffc0200466:	4581                	li	a1,0
ffffffffc0200468:	4601                	li	a2,0
ffffffffc020046a:	4889                	li	a7,2
ffffffffc020046c:	00000073          	ecall
ffffffffc0200470:	2501                	sext.w	a0,a0
ffffffffc0200472:	e42a                	sd	a0,8(sp)
ffffffffc0200474:	062000ef          	jal	ra,ffffffffc02004d6 <intr_enable>
ffffffffc0200478:	60e2                	ld	ra,24(sp)
ffffffffc020047a:	6522                	ld	a0,8(sp)
ffffffffc020047c:	6105                	addi	sp,sp,32
ffffffffc020047e:	8082                	ret

ffffffffc0200480 <ide_init>:
ffffffffc0200480:	8082                	ret

ffffffffc0200482 <ide_device_valid>:
ffffffffc0200482:	00253513          	sltiu	a0,a0,2
ffffffffc0200486:	8082                	ret

ffffffffc0200488 <ide_device_size>:
ffffffffc0200488:	03800513          	li	a0,56
ffffffffc020048c:	8082                	ret

ffffffffc020048e <ide_read_secs>:
ffffffffc020048e:	0000a797          	auipc	a5,0xa
ffffffffc0200492:	bb278793          	addi	a5,a5,-1102 # ffffffffc020a040 <ide>
ffffffffc0200496:	0095959b          	slliw	a1,a1,0x9
ffffffffc020049a:	1141                	addi	sp,sp,-16
ffffffffc020049c:	8532                	mv	a0,a2
ffffffffc020049e:	95be                	add	a1,a1,a5
ffffffffc02004a0:	00969613          	slli	a2,a3,0x9
ffffffffc02004a4:	e406                	sd	ra,8(sp)
ffffffffc02004a6:	7d1030ef          	jal	ra,ffffffffc0204476 <memcpy>
ffffffffc02004aa:	60a2                	ld	ra,8(sp)
ffffffffc02004ac:	4501                	li	a0,0
ffffffffc02004ae:	0141                	addi	sp,sp,16
ffffffffc02004b0:	8082                	ret

ffffffffc02004b2 <ide_write_secs>:
ffffffffc02004b2:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004b6:	0000a517          	auipc	a0,0xa
ffffffffc02004ba:	b8a50513          	addi	a0,a0,-1142 # ffffffffc020a040 <ide>
ffffffffc02004be:	1141                	addi	sp,sp,-16
ffffffffc02004c0:	85b2                	mv	a1,a2
ffffffffc02004c2:	953e                	add	a0,a0,a5
ffffffffc02004c4:	00969613          	slli	a2,a3,0x9
ffffffffc02004c8:	e406                	sd	ra,8(sp)
ffffffffc02004ca:	7ad030ef          	jal	ra,ffffffffc0204476 <memcpy>
ffffffffc02004ce:	60a2                	ld	ra,8(sp)
ffffffffc02004d0:	4501                	li	a0,0
ffffffffc02004d2:	0141                	addi	sp,sp,16
ffffffffc02004d4:	8082                	ret

ffffffffc02004d6 <intr_enable>:
ffffffffc02004d6:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004da:	8082                	ret

ffffffffc02004dc <intr_disable>:
ffffffffc02004dc:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004e0:	8082                	ret

ffffffffc02004e2 <pgfault_handler>:
ffffffffc02004e2:	10053783          	ld	a5,256(a0)
ffffffffc02004e6:	1141                	addi	sp,sp,-16
ffffffffc02004e8:	e022                	sd	s0,0(sp)
ffffffffc02004ea:	e406                	sd	ra,8(sp)
ffffffffc02004ec:	1007f793          	andi	a5,a5,256
ffffffffc02004f0:	11053583          	ld	a1,272(a0)
ffffffffc02004f4:	842a                	mv	s0,a0
ffffffffc02004f6:	04b00613          	li	a2,75
ffffffffc02004fa:	e399                	bnez	a5,ffffffffc0200500 <pgfault_handler+0x1e>
ffffffffc02004fc:	05500613          	li	a2,85
ffffffffc0200500:	11843703          	ld	a4,280(s0)
ffffffffc0200504:	47bd                	li	a5,15
ffffffffc0200506:	05200693          	li	a3,82
ffffffffc020050a:	00f71463          	bne	a4,a5,ffffffffc0200512 <pgfault_handler+0x30>
ffffffffc020050e:	05700693          	li	a3,87
ffffffffc0200512:	00004517          	auipc	a0,0x4
ffffffffc0200516:	25e50513          	addi	a0,a0,606 # ffffffffc0204770 <commands+0x88>
ffffffffc020051a:	ba1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020051e:	00011517          	auipc	a0,0x11
ffffffffc0200522:	05253503          	ld	a0,82(a0) # ffffffffc0211570 <check_mm_struct>
ffffffffc0200526:	c911                	beqz	a0,ffffffffc020053a <pgfault_handler+0x58>
ffffffffc0200528:	11043603          	ld	a2,272(s0)
ffffffffc020052c:	11843583          	ld	a1,280(s0)
ffffffffc0200530:	6402                	ld	s0,0(sp)
ffffffffc0200532:	60a2                	ld	ra,8(sp)
ffffffffc0200534:	0141                	addi	sp,sp,16
ffffffffc0200536:	7840306f          	j	ffffffffc0203cba <do_pgfault>
ffffffffc020053a:	00004617          	auipc	a2,0x4
ffffffffc020053e:	25660613          	addi	a2,a2,598 # ffffffffc0204790 <commands+0xa8>
ffffffffc0200542:	08100593          	li	a1,129
ffffffffc0200546:	00004517          	auipc	a0,0x4
ffffffffc020054a:	26250513          	addi	a0,a0,610 # ffffffffc02047a8 <commands+0xc0>
ffffffffc020054e:	e15ff0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc0200552 <idt_init>:
ffffffffc0200552:	14005073          	csrwi	sscratch,0
ffffffffc0200556:	00000797          	auipc	a5,0x0
ffffffffc020055a:	4aa78793          	addi	a5,a5,1194 # ffffffffc0200a00 <__alltraps>
ffffffffc020055e:	10579073          	csrw	stvec,a5
ffffffffc0200562:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200566:	000407b7          	lui	a5,0x40
ffffffffc020056a:	1007a7f3          	csrrs	a5,sstatus,a5
ffffffffc020056e:	8082                	ret

ffffffffc0200570 <print_regs>:
ffffffffc0200570:	610c                	ld	a1,0(a0)
ffffffffc0200572:	1141                	addi	sp,sp,-16
ffffffffc0200574:	e022                	sd	s0,0(sp)
ffffffffc0200576:	842a                	mv	s0,a0
ffffffffc0200578:	00004517          	auipc	a0,0x4
ffffffffc020057c:	24850513          	addi	a0,a0,584 # ffffffffc02047c0 <commands+0xd8>
ffffffffc0200580:	e406                	sd	ra,8(sp)
ffffffffc0200582:	b39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200586:	640c                	ld	a1,8(s0)
ffffffffc0200588:	00004517          	auipc	a0,0x4
ffffffffc020058c:	25050513          	addi	a0,a0,592 # ffffffffc02047d8 <commands+0xf0>
ffffffffc0200590:	b2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200594:	680c                	ld	a1,16(s0)
ffffffffc0200596:	00004517          	auipc	a0,0x4
ffffffffc020059a:	25a50513          	addi	a0,a0,602 # ffffffffc02047f0 <commands+0x108>
ffffffffc020059e:	b1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02005a2:	6c0c                	ld	a1,24(s0)
ffffffffc02005a4:	00004517          	auipc	a0,0x4
ffffffffc02005a8:	26450513          	addi	a0,a0,612 # ffffffffc0204808 <commands+0x120>
ffffffffc02005ac:	b0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02005b0:	700c                	ld	a1,32(s0)
ffffffffc02005b2:	00004517          	auipc	a0,0x4
ffffffffc02005b6:	26e50513          	addi	a0,a0,622 # ffffffffc0204820 <commands+0x138>
ffffffffc02005ba:	b01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02005be:	740c                	ld	a1,40(s0)
ffffffffc02005c0:	00004517          	auipc	a0,0x4
ffffffffc02005c4:	27850513          	addi	a0,a0,632 # ffffffffc0204838 <commands+0x150>
ffffffffc02005c8:	af3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02005cc:	780c                	ld	a1,48(s0)
ffffffffc02005ce:	00004517          	auipc	a0,0x4
ffffffffc02005d2:	28250513          	addi	a0,a0,642 # ffffffffc0204850 <commands+0x168>
ffffffffc02005d6:	ae5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02005da:	7c0c                	ld	a1,56(s0)
ffffffffc02005dc:	00004517          	auipc	a0,0x4
ffffffffc02005e0:	28c50513          	addi	a0,a0,652 # ffffffffc0204868 <commands+0x180>
ffffffffc02005e4:	ad7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02005e8:	602c                	ld	a1,64(s0)
ffffffffc02005ea:	00004517          	auipc	a0,0x4
ffffffffc02005ee:	29650513          	addi	a0,a0,662 # ffffffffc0204880 <commands+0x198>
ffffffffc02005f2:	ac9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02005f6:	642c                	ld	a1,72(s0)
ffffffffc02005f8:	00004517          	auipc	a0,0x4
ffffffffc02005fc:	2a050513          	addi	a0,a0,672 # ffffffffc0204898 <commands+0x1b0>
ffffffffc0200600:	abbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200604:	682c                	ld	a1,80(s0)
ffffffffc0200606:	00004517          	auipc	a0,0x4
ffffffffc020060a:	2aa50513          	addi	a0,a0,682 # ffffffffc02048b0 <commands+0x1c8>
ffffffffc020060e:	aadff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200612:	6c2c                	ld	a1,88(s0)
ffffffffc0200614:	00004517          	auipc	a0,0x4
ffffffffc0200618:	2b450513          	addi	a0,a0,692 # ffffffffc02048c8 <commands+0x1e0>
ffffffffc020061c:	a9fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200620:	702c                	ld	a1,96(s0)
ffffffffc0200622:	00004517          	auipc	a0,0x4
ffffffffc0200626:	2be50513          	addi	a0,a0,702 # ffffffffc02048e0 <commands+0x1f8>
ffffffffc020062a:	a91ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020062e:	742c                	ld	a1,104(s0)
ffffffffc0200630:	00004517          	auipc	a0,0x4
ffffffffc0200634:	2c850513          	addi	a0,a0,712 # ffffffffc02048f8 <commands+0x210>
ffffffffc0200638:	a83ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020063c:	782c                	ld	a1,112(s0)
ffffffffc020063e:	00004517          	auipc	a0,0x4
ffffffffc0200642:	2d250513          	addi	a0,a0,722 # ffffffffc0204910 <commands+0x228>
ffffffffc0200646:	a75ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020064a:	7c2c                	ld	a1,120(s0)
ffffffffc020064c:	00004517          	auipc	a0,0x4
ffffffffc0200650:	2dc50513          	addi	a0,a0,732 # ffffffffc0204928 <commands+0x240>
ffffffffc0200654:	a67ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200658:	604c                	ld	a1,128(s0)
ffffffffc020065a:	00004517          	auipc	a0,0x4
ffffffffc020065e:	2e650513          	addi	a0,a0,742 # ffffffffc0204940 <commands+0x258>
ffffffffc0200662:	a59ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200666:	644c                	ld	a1,136(s0)
ffffffffc0200668:	00004517          	auipc	a0,0x4
ffffffffc020066c:	2f050513          	addi	a0,a0,752 # ffffffffc0204958 <commands+0x270>
ffffffffc0200670:	a4bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200674:	684c                	ld	a1,144(s0)
ffffffffc0200676:	00004517          	auipc	a0,0x4
ffffffffc020067a:	2fa50513          	addi	a0,a0,762 # ffffffffc0204970 <commands+0x288>
ffffffffc020067e:	a3dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200682:	6c4c                	ld	a1,152(s0)
ffffffffc0200684:	00004517          	auipc	a0,0x4
ffffffffc0200688:	30450513          	addi	a0,a0,772 # ffffffffc0204988 <commands+0x2a0>
ffffffffc020068c:	a2fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200690:	704c                	ld	a1,160(s0)
ffffffffc0200692:	00004517          	auipc	a0,0x4
ffffffffc0200696:	30e50513          	addi	a0,a0,782 # ffffffffc02049a0 <commands+0x2b8>
ffffffffc020069a:	a21ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020069e:	744c                	ld	a1,168(s0)
ffffffffc02006a0:	00004517          	auipc	a0,0x4
ffffffffc02006a4:	31850513          	addi	a0,a0,792 # ffffffffc02049b8 <commands+0x2d0>
ffffffffc02006a8:	a13ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02006ac:	784c                	ld	a1,176(s0)
ffffffffc02006ae:	00004517          	auipc	a0,0x4
ffffffffc02006b2:	32250513          	addi	a0,a0,802 # ffffffffc02049d0 <commands+0x2e8>
ffffffffc02006b6:	a05ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02006ba:	7c4c                	ld	a1,184(s0)
ffffffffc02006bc:	00004517          	auipc	a0,0x4
ffffffffc02006c0:	32c50513          	addi	a0,a0,812 # ffffffffc02049e8 <commands+0x300>
ffffffffc02006c4:	9f7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02006c8:	606c                	ld	a1,192(s0)
ffffffffc02006ca:	00004517          	auipc	a0,0x4
ffffffffc02006ce:	33650513          	addi	a0,a0,822 # ffffffffc0204a00 <commands+0x318>
ffffffffc02006d2:	9e9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02006d6:	646c                	ld	a1,200(s0)
ffffffffc02006d8:	00004517          	auipc	a0,0x4
ffffffffc02006dc:	34050513          	addi	a0,a0,832 # ffffffffc0204a18 <commands+0x330>
ffffffffc02006e0:	9dbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02006e4:	686c                	ld	a1,208(s0)
ffffffffc02006e6:	00004517          	auipc	a0,0x4
ffffffffc02006ea:	34a50513          	addi	a0,a0,842 # ffffffffc0204a30 <commands+0x348>
ffffffffc02006ee:	9cdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02006f2:	6c6c                	ld	a1,216(s0)
ffffffffc02006f4:	00004517          	auipc	a0,0x4
ffffffffc02006f8:	35450513          	addi	a0,a0,852 # ffffffffc0204a48 <commands+0x360>
ffffffffc02006fc:	9bfff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200700:	706c                	ld	a1,224(s0)
ffffffffc0200702:	00004517          	auipc	a0,0x4
ffffffffc0200706:	35e50513          	addi	a0,a0,862 # ffffffffc0204a60 <commands+0x378>
ffffffffc020070a:	9b1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020070e:	746c                	ld	a1,232(s0)
ffffffffc0200710:	00004517          	auipc	a0,0x4
ffffffffc0200714:	36850513          	addi	a0,a0,872 # ffffffffc0204a78 <commands+0x390>
ffffffffc0200718:	9a3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020071c:	786c                	ld	a1,240(s0)
ffffffffc020071e:	00004517          	auipc	a0,0x4
ffffffffc0200722:	37250513          	addi	a0,a0,882 # ffffffffc0204a90 <commands+0x3a8>
ffffffffc0200726:	995ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020072a:	7c6c                	ld	a1,248(s0)
ffffffffc020072c:	6402                	ld	s0,0(sp)
ffffffffc020072e:	60a2                	ld	ra,8(sp)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	37850513          	addi	a0,a0,888 # ffffffffc0204aa8 <commands+0x3c0>
ffffffffc0200738:	0141                	addi	sp,sp,16
ffffffffc020073a:	b241                	j	ffffffffc02000ba <cprintf>

ffffffffc020073c <print_trapframe>:
ffffffffc020073c:	1141                	addi	sp,sp,-16
ffffffffc020073e:	e022                	sd	s0,0(sp)
ffffffffc0200740:	85aa                	mv	a1,a0
ffffffffc0200742:	842a                	mv	s0,a0
ffffffffc0200744:	00004517          	auipc	a0,0x4
ffffffffc0200748:	37c50513          	addi	a0,a0,892 # ffffffffc0204ac0 <commands+0x3d8>
ffffffffc020074c:	e406                	sd	ra,8(sp)
ffffffffc020074e:	96dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200752:	8522                	mv	a0,s0
ffffffffc0200754:	e1dff0ef          	jal	ra,ffffffffc0200570 <print_regs>
ffffffffc0200758:	10043583          	ld	a1,256(s0)
ffffffffc020075c:	00004517          	auipc	a0,0x4
ffffffffc0200760:	37c50513          	addi	a0,a0,892 # ffffffffc0204ad8 <commands+0x3f0>
ffffffffc0200764:	957ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200768:	10843583          	ld	a1,264(s0)
ffffffffc020076c:	00004517          	auipc	a0,0x4
ffffffffc0200770:	38450513          	addi	a0,a0,900 # ffffffffc0204af0 <commands+0x408>
ffffffffc0200774:	947ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200778:	11043583          	ld	a1,272(s0)
ffffffffc020077c:	00004517          	auipc	a0,0x4
ffffffffc0200780:	38c50513          	addi	a0,a0,908 # ffffffffc0204b08 <commands+0x420>
ffffffffc0200784:	937ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200788:	11843583          	ld	a1,280(s0)
ffffffffc020078c:	6402                	ld	s0,0(sp)
ffffffffc020078e:	60a2                	ld	ra,8(sp)
ffffffffc0200790:	00004517          	auipc	a0,0x4
ffffffffc0200794:	39050513          	addi	a0,a0,912 # ffffffffc0204b20 <commands+0x438>
ffffffffc0200798:	0141                	addi	sp,sp,16
ffffffffc020079a:	921ff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc020079e <interrupt_handler>:
ffffffffc020079e:	11853783          	ld	a5,280(a0)
ffffffffc02007a2:	472d                	li	a4,11
ffffffffc02007a4:	0786                	slli	a5,a5,0x1
ffffffffc02007a6:	8385                	srli	a5,a5,0x1
ffffffffc02007a8:	06f76c63          	bltu	a4,a5,ffffffffc0200820 <interrupt_handler+0x82>
ffffffffc02007ac:	00004717          	auipc	a4,0x4
ffffffffc02007b0:	43c70713          	addi	a4,a4,1084 # ffffffffc0204be8 <commands+0x500>
ffffffffc02007b4:	078a                	slli	a5,a5,0x2
ffffffffc02007b6:	97ba                	add	a5,a5,a4
ffffffffc02007b8:	439c                	lw	a5,0(a5)
ffffffffc02007ba:	97ba                	add	a5,a5,a4
ffffffffc02007bc:	8782                	jr	a5
ffffffffc02007be:	00004517          	auipc	a0,0x4
ffffffffc02007c2:	3da50513          	addi	a0,a0,986 # ffffffffc0204b98 <commands+0x4b0>
ffffffffc02007c6:	8f5ff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02007ca:	00004517          	auipc	a0,0x4
ffffffffc02007ce:	3ae50513          	addi	a0,a0,942 # ffffffffc0204b78 <commands+0x490>
ffffffffc02007d2:	8e9ff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02007d6:	00004517          	auipc	a0,0x4
ffffffffc02007da:	36250513          	addi	a0,a0,866 # ffffffffc0204b38 <commands+0x450>
ffffffffc02007de:	8ddff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	37650513          	addi	a0,a0,886 # ffffffffc0204b58 <commands+0x470>
ffffffffc02007ea:	8d1ff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02007ee:	1141                	addi	sp,sp,-16
ffffffffc02007f0:	e406                	sd	ra,8(sp)
ffffffffc02007f2:	c05ff0ef          	jal	ra,ffffffffc02003f6 <clock_set_next_event>
ffffffffc02007f6:	00011797          	auipc	a5,0x11
ffffffffc02007fa:	d1278793          	addi	a5,a5,-750 # ffffffffc0211508 <ticks>
ffffffffc02007fe:	6398                	ld	a4,0(a5)
ffffffffc0200800:	06400693          	li	a3,100
ffffffffc0200804:	0705                	addi	a4,a4,1
ffffffffc0200806:	e398                	sd	a4,0(a5)
ffffffffc0200808:	639c                	ld	a5,0(a5)
ffffffffc020080a:	00d78c63          	beq	a5,a3,ffffffffc0200822 <interrupt_handler+0x84>
ffffffffc020080e:	60a2                	ld	ra,8(sp)
ffffffffc0200810:	0141                	addi	sp,sp,16
ffffffffc0200812:	8082                	ret
ffffffffc0200814:	00004517          	auipc	a0,0x4
ffffffffc0200818:	3b450513          	addi	a0,a0,948 # ffffffffc0204bc8 <commands+0x4e0>
ffffffffc020081c:	89fff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc0200820:	bf31                	j	ffffffffc020073c <print_trapframe>
ffffffffc0200822:	06400593          	li	a1,100
ffffffffc0200826:	00004517          	auipc	a0,0x4
ffffffffc020082a:	39250513          	addi	a0,a0,914 # ffffffffc0204bb8 <commands+0x4d0>
ffffffffc020082e:	00011797          	auipc	a5,0x11
ffffffffc0200832:	cc07bd23          	sd	zero,-806(a5) # ffffffffc0211508 <ticks>
ffffffffc0200836:	885ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020083a:	00011797          	auipc	a5,0x11
ffffffffc020083e:	cd678793          	addi	a5,a5,-810 # ffffffffc0211510 <num>
ffffffffc0200842:	6394                	ld	a3,0(a5)
ffffffffc0200844:	4729                	li	a4,10
ffffffffc0200846:	00e69863          	bne	a3,a4,ffffffffc0200856 <interrupt_handler+0xb8>
ffffffffc020084a:	4501                	li	a0,0
ffffffffc020084c:	4581                	li	a1,0
ffffffffc020084e:	4601                	li	a2,0
ffffffffc0200850:	48a1                	li	a7,8
ffffffffc0200852:	00000073          	ecall
ffffffffc0200856:	6398                	ld	a4,0(a5)
ffffffffc0200858:	0705                	addi	a4,a4,1
ffffffffc020085a:	e398                	sd	a4,0(a5)
ffffffffc020085c:	bf4d                	j	ffffffffc020080e <interrupt_handler+0x70>

ffffffffc020085e <exception_handler>:
ffffffffc020085e:	11853783          	ld	a5,280(a0)
ffffffffc0200862:	1101                	addi	sp,sp,-32
ffffffffc0200864:	e822                	sd	s0,16(sp)
ffffffffc0200866:	ec06                	sd	ra,24(sp)
ffffffffc0200868:	e426                	sd	s1,8(sp)
ffffffffc020086a:	473d                	li	a4,15
ffffffffc020086c:	842a                	mv	s0,a0
ffffffffc020086e:	14f76a63          	bltu	a4,a5,ffffffffc02009c2 <exception_handler+0x164>
ffffffffc0200872:	00004717          	auipc	a4,0x4
ffffffffc0200876:	55e70713          	addi	a4,a4,1374 # ffffffffc0204dd0 <commands+0x6e8>
ffffffffc020087a:	078a                	slli	a5,a5,0x2
ffffffffc020087c:	97ba                	add	a5,a5,a4
ffffffffc020087e:	439c                	lw	a5,0(a5)
ffffffffc0200880:	97ba                	add	a5,a5,a4
ffffffffc0200882:	8782                	jr	a5
ffffffffc0200884:	00004517          	auipc	a0,0x4
ffffffffc0200888:	53450513          	addi	a0,a0,1332 # ffffffffc0204db8 <commands+0x6d0>
ffffffffc020088c:	82fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200890:	8522                	mv	a0,s0
ffffffffc0200892:	c51ff0ef          	jal	ra,ffffffffc02004e2 <pgfault_handler>
ffffffffc0200896:	84aa                	mv	s1,a0
ffffffffc0200898:	12051b63          	bnez	a0,ffffffffc02009ce <exception_handler+0x170>
ffffffffc020089c:	60e2                	ld	ra,24(sp)
ffffffffc020089e:	6442                	ld	s0,16(sp)
ffffffffc02008a0:	64a2                	ld	s1,8(sp)
ffffffffc02008a2:	6105                	addi	sp,sp,32
ffffffffc02008a4:	8082                	ret
ffffffffc02008a6:	00004517          	auipc	a0,0x4
ffffffffc02008aa:	37250513          	addi	a0,a0,882 # ffffffffc0204c18 <commands+0x530>
ffffffffc02008ae:	6442                	ld	s0,16(sp)
ffffffffc02008b0:	60e2                	ld	ra,24(sp)
ffffffffc02008b2:	64a2                	ld	s1,8(sp)
ffffffffc02008b4:	6105                	addi	sp,sp,32
ffffffffc02008b6:	805ff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008ba:	00004517          	auipc	a0,0x4
ffffffffc02008be:	37e50513          	addi	a0,a0,894 # ffffffffc0204c38 <commands+0x550>
ffffffffc02008c2:	b7f5                	j	ffffffffc02008ae <exception_handler+0x50>
ffffffffc02008c4:	00004517          	auipc	a0,0x4
ffffffffc02008c8:	39450513          	addi	a0,a0,916 # ffffffffc0204c58 <commands+0x570>
ffffffffc02008cc:	b7cd                	j	ffffffffc02008ae <exception_handler+0x50>
ffffffffc02008ce:	00004517          	auipc	a0,0x4
ffffffffc02008d2:	3a250513          	addi	a0,a0,930 # ffffffffc0204c70 <commands+0x588>
ffffffffc02008d6:	bfe1                	j	ffffffffc02008ae <exception_handler+0x50>
ffffffffc02008d8:	00004517          	auipc	a0,0x4
ffffffffc02008dc:	3a850513          	addi	a0,a0,936 # ffffffffc0204c80 <commands+0x598>
ffffffffc02008e0:	b7f9                	j	ffffffffc02008ae <exception_handler+0x50>
ffffffffc02008e2:	00004517          	auipc	a0,0x4
ffffffffc02008e6:	3be50513          	addi	a0,a0,958 # ffffffffc0204ca0 <commands+0x5b8>
ffffffffc02008ea:	fd0ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02008ee:	8522                	mv	a0,s0
ffffffffc02008f0:	bf3ff0ef          	jal	ra,ffffffffc02004e2 <pgfault_handler>
ffffffffc02008f4:	84aa                	mv	s1,a0
ffffffffc02008f6:	d15d                	beqz	a0,ffffffffc020089c <exception_handler+0x3e>
ffffffffc02008f8:	8522                	mv	a0,s0
ffffffffc02008fa:	e43ff0ef          	jal	ra,ffffffffc020073c <print_trapframe>
ffffffffc02008fe:	86a6                	mv	a3,s1
ffffffffc0200900:	00004617          	auipc	a2,0x4
ffffffffc0200904:	3b860613          	addi	a2,a2,952 # ffffffffc0204cb8 <commands+0x5d0>
ffffffffc0200908:	0e500593          	li	a1,229
ffffffffc020090c:	00004517          	auipc	a0,0x4
ffffffffc0200910:	e9c50513          	addi	a0,a0,-356 # ffffffffc02047a8 <commands+0xc0>
ffffffffc0200914:	a4fff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0200918:	00004517          	auipc	a0,0x4
ffffffffc020091c:	3c050513          	addi	a0,a0,960 # ffffffffc0204cd8 <commands+0x5f0>
ffffffffc0200920:	b779                	j	ffffffffc02008ae <exception_handler+0x50>
ffffffffc0200922:	00004517          	auipc	a0,0x4
ffffffffc0200926:	3ce50513          	addi	a0,a0,974 # ffffffffc0204cf0 <commands+0x608>
ffffffffc020092a:	f90ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020092e:	8522                	mv	a0,s0
ffffffffc0200930:	bb3ff0ef          	jal	ra,ffffffffc02004e2 <pgfault_handler>
ffffffffc0200934:	84aa                	mv	s1,a0
ffffffffc0200936:	d13d                	beqz	a0,ffffffffc020089c <exception_handler+0x3e>
ffffffffc0200938:	8522                	mv	a0,s0
ffffffffc020093a:	e03ff0ef          	jal	ra,ffffffffc020073c <print_trapframe>
ffffffffc020093e:	86a6                	mv	a3,s1
ffffffffc0200940:	00004617          	auipc	a2,0x4
ffffffffc0200944:	37860613          	addi	a2,a2,888 # ffffffffc0204cb8 <commands+0x5d0>
ffffffffc0200948:	0f000593          	li	a1,240
ffffffffc020094c:	00004517          	auipc	a0,0x4
ffffffffc0200950:	e5c50513          	addi	a0,a0,-420 # ffffffffc02047a8 <commands+0xc0>
ffffffffc0200954:	a0fff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0200958:	00004517          	auipc	a0,0x4
ffffffffc020095c:	3b050513          	addi	a0,a0,944 # ffffffffc0204d08 <commands+0x620>
ffffffffc0200960:	b7b9                	j	ffffffffc02008ae <exception_handler+0x50>
ffffffffc0200962:	00004517          	auipc	a0,0x4
ffffffffc0200966:	3c650513          	addi	a0,a0,966 # ffffffffc0204d28 <commands+0x640>
ffffffffc020096a:	b791                	j	ffffffffc02008ae <exception_handler+0x50>
ffffffffc020096c:	00004517          	auipc	a0,0x4
ffffffffc0200970:	3dc50513          	addi	a0,a0,988 # ffffffffc0204d48 <commands+0x660>
ffffffffc0200974:	bf2d                	j	ffffffffc02008ae <exception_handler+0x50>
ffffffffc0200976:	00004517          	auipc	a0,0x4
ffffffffc020097a:	3f250513          	addi	a0,a0,1010 # ffffffffc0204d68 <commands+0x680>
ffffffffc020097e:	bf05                	j	ffffffffc02008ae <exception_handler+0x50>
ffffffffc0200980:	00004517          	auipc	a0,0x4
ffffffffc0200984:	40850513          	addi	a0,a0,1032 # ffffffffc0204d88 <commands+0x6a0>
ffffffffc0200988:	b71d                	j	ffffffffc02008ae <exception_handler+0x50>
ffffffffc020098a:	00004517          	auipc	a0,0x4
ffffffffc020098e:	41650513          	addi	a0,a0,1046 # ffffffffc0204da0 <commands+0x6b8>
ffffffffc0200992:	f28ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200996:	8522                	mv	a0,s0
ffffffffc0200998:	b4bff0ef          	jal	ra,ffffffffc02004e2 <pgfault_handler>
ffffffffc020099c:	84aa                	mv	s1,a0
ffffffffc020099e:	ee050fe3          	beqz	a0,ffffffffc020089c <exception_handler+0x3e>
ffffffffc02009a2:	8522                	mv	a0,s0
ffffffffc02009a4:	d99ff0ef          	jal	ra,ffffffffc020073c <print_trapframe>
ffffffffc02009a8:	86a6                	mv	a3,s1
ffffffffc02009aa:	00004617          	auipc	a2,0x4
ffffffffc02009ae:	30e60613          	addi	a2,a2,782 # ffffffffc0204cb8 <commands+0x5d0>
ffffffffc02009b2:	10700593          	li	a1,263
ffffffffc02009b6:	00004517          	auipc	a0,0x4
ffffffffc02009ba:	df250513          	addi	a0,a0,-526 # ffffffffc02047a8 <commands+0xc0>
ffffffffc02009be:	9a5ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02009c2:	8522                	mv	a0,s0
ffffffffc02009c4:	6442                	ld	s0,16(sp)
ffffffffc02009c6:	60e2                	ld	ra,24(sp)
ffffffffc02009c8:	64a2                	ld	s1,8(sp)
ffffffffc02009ca:	6105                	addi	sp,sp,32
ffffffffc02009cc:	bb85                	j	ffffffffc020073c <print_trapframe>
ffffffffc02009ce:	8522                	mv	a0,s0
ffffffffc02009d0:	d6dff0ef          	jal	ra,ffffffffc020073c <print_trapframe>
ffffffffc02009d4:	86a6                	mv	a3,s1
ffffffffc02009d6:	00004617          	auipc	a2,0x4
ffffffffc02009da:	2e260613          	addi	a2,a2,738 # ffffffffc0204cb8 <commands+0x5d0>
ffffffffc02009de:	10f00593          	li	a1,271
ffffffffc02009e2:	00004517          	auipc	a0,0x4
ffffffffc02009e6:	dc650513          	addi	a0,a0,-570 # ffffffffc02047a8 <commands+0xc0>
ffffffffc02009ea:	979ff0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc02009ee <trap>:
ffffffffc02009ee:	11853783          	ld	a5,280(a0)
ffffffffc02009f2:	0007c363          	bltz	a5,ffffffffc02009f8 <trap+0xa>
ffffffffc02009f6:	b5a5                	j	ffffffffc020085e <exception_handler>
ffffffffc02009f8:	b35d                	j	ffffffffc020079e <interrupt_handler>
ffffffffc02009fa:	0000                	unimp
ffffffffc02009fc:	0000                	unimp
	...

ffffffffc0200a00 <__alltraps>:
ffffffffc0200a00:	14011073          	csrw	sscratch,sp
ffffffffc0200a04:	712d                	addi	sp,sp,-288
ffffffffc0200a06:	e406                	sd	ra,8(sp)
ffffffffc0200a08:	ec0e                	sd	gp,24(sp)
ffffffffc0200a0a:	f012                	sd	tp,32(sp)
ffffffffc0200a0c:	f416                	sd	t0,40(sp)
ffffffffc0200a0e:	f81a                	sd	t1,48(sp)
ffffffffc0200a10:	fc1e                	sd	t2,56(sp)
ffffffffc0200a12:	e0a2                	sd	s0,64(sp)
ffffffffc0200a14:	e4a6                	sd	s1,72(sp)
ffffffffc0200a16:	e8aa                	sd	a0,80(sp)
ffffffffc0200a18:	ecae                	sd	a1,88(sp)
ffffffffc0200a1a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a1c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a1e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a20:	fcbe                	sd	a5,120(sp)
ffffffffc0200a22:	e142                	sd	a6,128(sp)
ffffffffc0200a24:	e546                	sd	a7,136(sp)
ffffffffc0200a26:	e94a                	sd	s2,144(sp)
ffffffffc0200a28:	ed4e                	sd	s3,152(sp)
ffffffffc0200a2a:	f152                	sd	s4,160(sp)
ffffffffc0200a2c:	f556                	sd	s5,168(sp)
ffffffffc0200a2e:	f95a                	sd	s6,176(sp)
ffffffffc0200a30:	fd5e                	sd	s7,184(sp)
ffffffffc0200a32:	e1e2                	sd	s8,192(sp)
ffffffffc0200a34:	e5e6                	sd	s9,200(sp)
ffffffffc0200a36:	e9ea                	sd	s10,208(sp)
ffffffffc0200a38:	edee                	sd	s11,216(sp)
ffffffffc0200a3a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a3c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a3e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a40:	fdfe                	sd	t6,248(sp)
ffffffffc0200a42:	14002473          	csrr	s0,sscratch
ffffffffc0200a46:	100024f3          	csrr	s1,sstatus
ffffffffc0200a4a:	14102973          	csrr	s2,sepc
ffffffffc0200a4e:	143029f3          	csrr	s3,stval
ffffffffc0200a52:	14202a73          	csrr	s4,scause
ffffffffc0200a56:	e822                	sd	s0,16(sp)
ffffffffc0200a58:	e226                	sd	s1,256(sp)
ffffffffc0200a5a:	e64a                	sd	s2,264(sp)
ffffffffc0200a5c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a5e:	ee52                	sd	s4,280(sp)
ffffffffc0200a60:	850a                	mv	a0,sp
ffffffffc0200a62:	f8dff0ef          	jal	ra,ffffffffc02009ee <trap>

ffffffffc0200a66 <__trapret>:
ffffffffc0200a66:	6492                	ld	s1,256(sp)
ffffffffc0200a68:	6932                	ld	s2,264(sp)
ffffffffc0200a6a:	10049073          	csrw	sstatus,s1
ffffffffc0200a6e:	14191073          	csrw	sepc,s2
ffffffffc0200a72:	60a2                	ld	ra,8(sp)
ffffffffc0200a74:	61e2                	ld	gp,24(sp)
ffffffffc0200a76:	7202                	ld	tp,32(sp)
ffffffffc0200a78:	72a2                	ld	t0,40(sp)
ffffffffc0200a7a:	7342                	ld	t1,48(sp)
ffffffffc0200a7c:	73e2                	ld	t2,56(sp)
ffffffffc0200a7e:	6406                	ld	s0,64(sp)
ffffffffc0200a80:	64a6                	ld	s1,72(sp)
ffffffffc0200a82:	6546                	ld	a0,80(sp)
ffffffffc0200a84:	65e6                	ld	a1,88(sp)
ffffffffc0200a86:	7606                	ld	a2,96(sp)
ffffffffc0200a88:	76a6                	ld	a3,104(sp)
ffffffffc0200a8a:	7746                	ld	a4,112(sp)
ffffffffc0200a8c:	77e6                	ld	a5,120(sp)
ffffffffc0200a8e:	680a                	ld	a6,128(sp)
ffffffffc0200a90:	68aa                	ld	a7,136(sp)
ffffffffc0200a92:	694a                	ld	s2,144(sp)
ffffffffc0200a94:	69ea                	ld	s3,152(sp)
ffffffffc0200a96:	7a0a                	ld	s4,160(sp)
ffffffffc0200a98:	7aaa                	ld	s5,168(sp)
ffffffffc0200a9a:	7b4a                	ld	s6,176(sp)
ffffffffc0200a9c:	7bea                	ld	s7,184(sp)
ffffffffc0200a9e:	6c0e                	ld	s8,192(sp)
ffffffffc0200aa0:	6cae                	ld	s9,200(sp)
ffffffffc0200aa2:	6d4e                	ld	s10,208(sp)
ffffffffc0200aa4:	6dee                	ld	s11,216(sp)
ffffffffc0200aa6:	7e0e                	ld	t3,224(sp)
ffffffffc0200aa8:	7eae                	ld	t4,232(sp)
ffffffffc0200aaa:	7f4e                	ld	t5,240(sp)
ffffffffc0200aac:	7fee                	ld	t6,248(sp)
ffffffffc0200aae:	6142                	ld	sp,16(sp)
ffffffffc0200ab0:	10200073          	sret
	...

ffffffffc0200ac0 <default_init>:
ffffffffc0200ac0:	00010797          	auipc	a5,0x10
ffffffffc0200ac4:	58078793          	addi	a5,a5,1408 # ffffffffc0211040 <free_area>
ffffffffc0200ac8:	e79c                	sd	a5,8(a5)
ffffffffc0200aca:	e39c                	sd	a5,0(a5)
ffffffffc0200acc:	0007a823          	sw	zero,16(a5)
ffffffffc0200ad0:	8082                	ret

ffffffffc0200ad2 <default_nr_free_pages>:
ffffffffc0200ad2:	00010517          	auipc	a0,0x10
ffffffffc0200ad6:	57e56503          	lwu	a0,1406(a0) # ffffffffc0211050 <free_area+0x10>
ffffffffc0200ada:	8082                	ret

ffffffffc0200adc <default_check>:
ffffffffc0200adc:	715d                	addi	sp,sp,-80
ffffffffc0200ade:	e0a2                	sd	s0,64(sp)
ffffffffc0200ae0:	00010417          	auipc	s0,0x10
ffffffffc0200ae4:	56040413          	addi	s0,s0,1376 # ffffffffc0211040 <free_area>
ffffffffc0200ae8:	641c                	ld	a5,8(s0)
ffffffffc0200aea:	e486                	sd	ra,72(sp)
ffffffffc0200aec:	fc26                	sd	s1,56(sp)
ffffffffc0200aee:	f84a                	sd	s2,48(sp)
ffffffffc0200af0:	f44e                	sd	s3,40(sp)
ffffffffc0200af2:	f052                	sd	s4,32(sp)
ffffffffc0200af4:	ec56                	sd	s5,24(sp)
ffffffffc0200af6:	e85a                	sd	s6,16(sp)
ffffffffc0200af8:	e45e                	sd	s7,8(sp)
ffffffffc0200afa:	e062                	sd	s8,0(sp)
ffffffffc0200afc:	2c878763          	beq	a5,s0,ffffffffc0200dca <default_check+0x2ee>
ffffffffc0200b00:	4481                	li	s1,0
ffffffffc0200b02:	4901                	li	s2,0
ffffffffc0200b04:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200b08:	8b09                	andi	a4,a4,2
ffffffffc0200b0a:	2c070463          	beqz	a4,ffffffffc0200dd2 <default_check+0x2f6>
ffffffffc0200b0e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b12:	679c                	ld	a5,8(a5)
ffffffffc0200b14:	2905                	addiw	s2,s2,1
ffffffffc0200b16:	9cb9                	addw	s1,s1,a4
ffffffffc0200b18:	fe8796e3          	bne	a5,s0,ffffffffc0200b04 <default_check+0x28>
ffffffffc0200b1c:	89a6                	mv	s3,s1
ffffffffc0200b1e:	39b000ef          	jal	ra,ffffffffc02016b8 <nr_free_pages>
ffffffffc0200b22:	71351863          	bne	a0,s3,ffffffffc0201232 <default_check+0x756>
ffffffffc0200b26:	4505                	li	a0,1
ffffffffc0200b28:	2a9000ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0200b2c:	8a2a                	mv	s4,a0
ffffffffc0200b2e:	44050263          	beqz	a0,ffffffffc0200f72 <default_check+0x496>
ffffffffc0200b32:	4505                	li	a0,1
ffffffffc0200b34:	29d000ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0200b38:	89aa                	mv	s3,a0
ffffffffc0200b3a:	70050c63          	beqz	a0,ffffffffc0201252 <default_check+0x776>
ffffffffc0200b3e:	4505                	li	a0,1
ffffffffc0200b40:	291000ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0200b44:	8aaa                	mv	s5,a0
ffffffffc0200b46:	4a050663          	beqz	a0,ffffffffc0200ff2 <default_check+0x516>
ffffffffc0200b4a:	2b3a0463          	beq	s4,s3,ffffffffc0200df2 <default_check+0x316>
ffffffffc0200b4e:	2aaa0263          	beq	s4,a0,ffffffffc0200df2 <default_check+0x316>
ffffffffc0200b52:	2aa98063          	beq	s3,a0,ffffffffc0200df2 <default_check+0x316>
ffffffffc0200b56:	000a2783          	lw	a5,0(s4)
ffffffffc0200b5a:	2a079c63          	bnez	a5,ffffffffc0200e12 <default_check+0x336>
ffffffffc0200b5e:	0009a783          	lw	a5,0(s3)
ffffffffc0200b62:	2a079863          	bnez	a5,ffffffffc0200e12 <default_check+0x336>
ffffffffc0200b66:	411c                	lw	a5,0(a0)
ffffffffc0200b68:	2a079563          	bnez	a5,ffffffffc0200e12 <default_check+0x336>
ffffffffc0200b6c:	00011797          	auipc	a5,0x11
ffffffffc0200b70:	9d47b783          	ld	a5,-1580(a5) # ffffffffc0211540 <pages>
ffffffffc0200b74:	40fa0733          	sub	a4,s4,a5
ffffffffc0200b78:	870d                	srai	a4,a4,0x3
ffffffffc0200b7a:	00005597          	auipc	a1,0x5
ffffffffc0200b7e:	7ce5b583          	ld	a1,1998(a1) # ffffffffc0206348 <error_string+0x38>
ffffffffc0200b82:	02b70733          	mul	a4,a4,a1
ffffffffc0200b86:	00005617          	auipc	a2,0x5
ffffffffc0200b8a:	7ca63603          	ld	a2,1994(a2) # ffffffffc0206350 <nbase>
ffffffffc0200b8e:	00011697          	auipc	a3,0x11
ffffffffc0200b92:	9aa6b683          	ld	a3,-1622(a3) # ffffffffc0211538 <npage>
ffffffffc0200b96:	06b2                	slli	a3,a3,0xc
ffffffffc0200b98:	9732                	add	a4,a4,a2
ffffffffc0200b9a:	0732                	slli	a4,a4,0xc
ffffffffc0200b9c:	28d77b63          	bgeu	a4,a3,ffffffffc0200e32 <default_check+0x356>
ffffffffc0200ba0:	40f98733          	sub	a4,s3,a5
ffffffffc0200ba4:	870d                	srai	a4,a4,0x3
ffffffffc0200ba6:	02b70733          	mul	a4,a4,a1
ffffffffc0200baa:	9732                	add	a4,a4,a2
ffffffffc0200bac:	0732                	slli	a4,a4,0xc
ffffffffc0200bae:	4cd77263          	bgeu	a4,a3,ffffffffc0201072 <default_check+0x596>
ffffffffc0200bb2:	40f507b3          	sub	a5,a0,a5
ffffffffc0200bb6:	878d                	srai	a5,a5,0x3
ffffffffc0200bb8:	02b787b3          	mul	a5,a5,a1
ffffffffc0200bbc:	97b2                	add	a5,a5,a2
ffffffffc0200bbe:	07b2                	slli	a5,a5,0xc
ffffffffc0200bc0:	30d7f963          	bgeu	a5,a3,ffffffffc0200ed2 <default_check+0x3f6>
ffffffffc0200bc4:	4505                	li	a0,1
ffffffffc0200bc6:	00043c03          	ld	s8,0(s0)
ffffffffc0200bca:	00843b83          	ld	s7,8(s0)
ffffffffc0200bce:	01042b03          	lw	s6,16(s0)
ffffffffc0200bd2:	e400                	sd	s0,8(s0)
ffffffffc0200bd4:	e000                	sd	s0,0(s0)
ffffffffc0200bd6:	00010797          	auipc	a5,0x10
ffffffffc0200bda:	4607ad23          	sw	zero,1146(a5) # ffffffffc0211050 <free_area+0x10>
ffffffffc0200bde:	1f3000ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0200be2:	2c051863          	bnez	a0,ffffffffc0200eb2 <default_check+0x3d6>
ffffffffc0200be6:	4585                	li	a1,1
ffffffffc0200be8:	8552                	mv	a0,s4
ffffffffc0200bea:	28f000ef          	jal	ra,ffffffffc0201678 <free_pages>
ffffffffc0200bee:	4585                	li	a1,1
ffffffffc0200bf0:	854e                	mv	a0,s3
ffffffffc0200bf2:	287000ef          	jal	ra,ffffffffc0201678 <free_pages>
ffffffffc0200bf6:	4585                	li	a1,1
ffffffffc0200bf8:	8556                	mv	a0,s5
ffffffffc0200bfa:	27f000ef          	jal	ra,ffffffffc0201678 <free_pages>
ffffffffc0200bfe:	4818                	lw	a4,16(s0)
ffffffffc0200c00:	478d                	li	a5,3
ffffffffc0200c02:	28f71863          	bne	a4,a5,ffffffffc0200e92 <default_check+0x3b6>
ffffffffc0200c06:	4505                	li	a0,1
ffffffffc0200c08:	1c9000ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0200c0c:	89aa                	mv	s3,a0
ffffffffc0200c0e:	26050263          	beqz	a0,ffffffffc0200e72 <default_check+0x396>
ffffffffc0200c12:	4505                	li	a0,1
ffffffffc0200c14:	1bd000ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0200c18:	8aaa                	mv	s5,a0
ffffffffc0200c1a:	3a050c63          	beqz	a0,ffffffffc0200fd2 <default_check+0x4f6>
ffffffffc0200c1e:	4505                	li	a0,1
ffffffffc0200c20:	1b1000ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0200c24:	8a2a                	mv	s4,a0
ffffffffc0200c26:	38050663          	beqz	a0,ffffffffc0200fb2 <default_check+0x4d6>
ffffffffc0200c2a:	4505                	li	a0,1
ffffffffc0200c2c:	1a5000ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0200c30:	36051163          	bnez	a0,ffffffffc0200f92 <default_check+0x4b6>
ffffffffc0200c34:	4585                	li	a1,1
ffffffffc0200c36:	854e                	mv	a0,s3
ffffffffc0200c38:	241000ef          	jal	ra,ffffffffc0201678 <free_pages>
ffffffffc0200c3c:	641c                	ld	a5,8(s0)
ffffffffc0200c3e:	20878a63          	beq	a5,s0,ffffffffc0200e52 <default_check+0x376>
ffffffffc0200c42:	4505                	li	a0,1
ffffffffc0200c44:	18d000ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0200c48:	30a99563          	bne	s3,a0,ffffffffc0200f52 <default_check+0x476>
ffffffffc0200c4c:	4505                	li	a0,1
ffffffffc0200c4e:	183000ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0200c52:	2e051063          	bnez	a0,ffffffffc0200f32 <default_check+0x456>
ffffffffc0200c56:	481c                	lw	a5,16(s0)
ffffffffc0200c58:	2a079d63          	bnez	a5,ffffffffc0200f12 <default_check+0x436>
ffffffffc0200c5c:	854e                	mv	a0,s3
ffffffffc0200c5e:	4585                	li	a1,1
ffffffffc0200c60:	01843023          	sd	s8,0(s0)
ffffffffc0200c64:	01743423          	sd	s7,8(s0)
ffffffffc0200c68:	01642823          	sw	s6,16(s0)
ffffffffc0200c6c:	20d000ef          	jal	ra,ffffffffc0201678 <free_pages>
ffffffffc0200c70:	4585                	li	a1,1
ffffffffc0200c72:	8556                	mv	a0,s5
ffffffffc0200c74:	205000ef          	jal	ra,ffffffffc0201678 <free_pages>
ffffffffc0200c78:	4585                	li	a1,1
ffffffffc0200c7a:	8552                	mv	a0,s4
ffffffffc0200c7c:	1fd000ef          	jal	ra,ffffffffc0201678 <free_pages>
ffffffffc0200c80:	4515                	li	a0,5
ffffffffc0200c82:	14f000ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0200c86:	89aa                	mv	s3,a0
ffffffffc0200c88:	26050563          	beqz	a0,ffffffffc0200ef2 <default_check+0x416>
ffffffffc0200c8c:	651c                	ld	a5,8(a0)
ffffffffc0200c8e:	8385                	srli	a5,a5,0x1
ffffffffc0200c90:	8b85                	andi	a5,a5,1
ffffffffc0200c92:	54079063          	bnez	a5,ffffffffc02011d2 <default_check+0x6f6>
ffffffffc0200c96:	4505                	li	a0,1
ffffffffc0200c98:	00043b03          	ld	s6,0(s0)
ffffffffc0200c9c:	00843a83          	ld	s5,8(s0)
ffffffffc0200ca0:	e000                	sd	s0,0(s0)
ffffffffc0200ca2:	e400                	sd	s0,8(s0)
ffffffffc0200ca4:	12d000ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0200ca8:	50051563          	bnez	a0,ffffffffc02011b2 <default_check+0x6d6>
ffffffffc0200cac:	09098a13          	addi	s4,s3,144
ffffffffc0200cb0:	8552                	mv	a0,s4
ffffffffc0200cb2:	458d                	li	a1,3
ffffffffc0200cb4:	01042b83          	lw	s7,16(s0)
ffffffffc0200cb8:	00010797          	auipc	a5,0x10
ffffffffc0200cbc:	3807ac23          	sw	zero,920(a5) # ffffffffc0211050 <free_area+0x10>
ffffffffc0200cc0:	1b9000ef          	jal	ra,ffffffffc0201678 <free_pages>
ffffffffc0200cc4:	4511                	li	a0,4
ffffffffc0200cc6:	10b000ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0200cca:	4c051463          	bnez	a0,ffffffffc0201192 <default_check+0x6b6>
ffffffffc0200cce:	0989b783          	ld	a5,152(s3)
ffffffffc0200cd2:	8385                	srli	a5,a5,0x1
ffffffffc0200cd4:	8b85                	andi	a5,a5,1
ffffffffc0200cd6:	48078e63          	beqz	a5,ffffffffc0201172 <default_check+0x696>
ffffffffc0200cda:	0a89a703          	lw	a4,168(s3)
ffffffffc0200cde:	478d                	li	a5,3
ffffffffc0200ce0:	48f71963          	bne	a4,a5,ffffffffc0201172 <default_check+0x696>
ffffffffc0200ce4:	450d                	li	a0,3
ffffffffc0200ce6:	0eb000ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0200cea:	8c2a                	mv	s8,a0
ffffffffc0200cec:	46050363          	beqz	a0,ffffffffc0201152 <default_check+0x676>
ffffffffc0200cf0:	4505                	li	a0,1
ffffffffc0200cf2:	0df000ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0200cf6:	42051e63          	bnez	a0,ffffffffc0201132 <default_check+0x656>
ffffffffc0200cfa:	418a1c63          	bne	s4,s8,ffffffffc0201112 <default_check+0x636>
ffffffffc0200cfe:	4585                	li	a1,1
ffffffffc0200d00:	854e                	mv	a0,s3
ffffffffc0200d02:	177000ef          	jal	ra,ffffffffc0201678 <free_pages>
ffffffffc0200d06:	458d                	li	a1,3
ffffffffc0200d08:	8552                	mv	a0,s4
ffffffffc0200d0a:	16f000ef          	jal	ra,ffffffffc0201678 <free_pages>
ffffffffc0200d0e:	0089b783          	ld	a5,8(s3)
ffffffffc0200d12:	04898c13          	addi	s8,s3,72
ffffffffc0200d16:	8385                	srli	a5,a5,0x1
ffffffffc0200d18:	8b85                	andi	a5,a5,1
ffffffffc0200d1a:	3c078c63          	beqz	a5,ffffffffc02010f2 <default_check+0x616>
ffffffffc0200d1e:	0189a703          	lw	a4,24(s3)
ffffffffc0200d22:	4785                	li	a5,1
ffffffffc0200d24:	3cf71763          	bne	a4,a5,ffffffffc02010f2 <default_check+0x616>
ffffffffc0200d28:	008a3783          	ld	a5,8(s4)
ffffffffc0200d2c:	8385                	srli	a5,a5,0x1
ffffffffc0200d2e:	8b85                	andi	a5,a5,1
ffffffffc0200d30:	3a078163          	beqz	a5,ffffffffc02010d2 <default_check+0x5f6>
ffffffffc0200d34:	018a2703          	lw	a4,24(s4)
ffffffffc0200d38:	478d                	li	a5,3
ffffffffc0200d3a:	38f71c63          	bne	a4,a5,ffffffffc02010d2 <default_check+0x5f6>
ffffffffc0200d3e:	4505                	li	a0,1
ffffffffc0200d40:	091000ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0200d44:	36a99763          	bne	s3,a0,ffffffffc02010b2 <default_check+0x5d6>
ffffffffc0200d48:	4585                	li	a1,1
ffffffffc0200d4a:	12f000ef          	jal	ra,ffffffffc0201678 <free_pages>
ffffffffc0200d4e:	4509                	li	a0,2
ffffffffc0200d50:	081000ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0200d54:	32aa1f63          	bne	s4,a0,ffffffffc0201092 <default_check+0x5b6>
ffffffffc0200d58:	4589                	li	a1,2
ffffffffc0200d5a:	11f000ef          	jal	ra,ffffffffc0201678 <free_pages>
ffffffffc0200d5e:	4585                	li	a1,1
ffffffffc0200d60:	8562                	mv	a0,s8
ffffffffc0200d62:	117000ef          	jal	ra,ffffffffc0201678 <free_pages>
ffffffffc0200d66:	4515                	li	a0,5
ffffffffc0200d68:	069000ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0200d6c:	89aa                	mv	s3,a0
ffffffffc0200d6e:	48050263          	beqz	a0,ffffffffc02011f2 <default_check+0x716>
ffffffffc0200d72:	4505                	li	a0,1
ffffffffc0200d74:	05d000ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0200d78:	2c051d63          	bnez	a0,ffffffffc0201052 <default_check+0x576>
ffffffffc0200d7c:	481c                	lw	a5,16(s0)
ffffffffc0200d7e:	2a079a63          	bnez	a5,ffffffffc0201032 <default_check+0x556>
ffffffffc0200d82:	4595                	li	a1,5
ffffffffc0200d84:	854e                	mv	a0,s3
ffffffffc0200d86:	01742823          	sw	s7,16(s0)
ffffffffc0200d8a:	01643023          	sd	s6,0(s0)
ffffffffc0200d8e:	01543423          	sd	s5,8(s0)
ffffffffc0200d92:	0e7000ef          	jal	ra,ffffffffc0201678 <free_pages>
ffffffffc0200d96:	641c                	ld	a5,8(s0)
ffffffffc0200d98:	00878963          	beq	a5,s0,ffffffffc0200daa <default_check+0x2ce>
ffffffffc0200d9c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200da0:	679c                	ld	a5,8(a5)
ffffffffc0200da2:	397d                	addiw	s2,s2,-1
ffffffffc0200da4:	9c99                	subw	s1,s1,a4
ffffffffc0200da6:	fe879be3          	bne	a5,s0,ffffffffc0200d9c <default_check+0x2c0>
ffffffffc0200daa:	26091463          	bnez	s2,ffffffffc0201012 <default_check+0x536>
ffffffffc0200dae:	46049263          	bnez	s1,ffffffffc0201212 <default_check+0x736>
ffffffffc0200db2:	60a6                	ld	ra,72(sp)
ffffffffc0200db4:	6406                	ld	s0,64(sp)
ffffffffc0200db6:	74e2                	ld	s1,56(sp)
ffffffffc0200db8:	7942                	ld	s2,48(sp)
ffffffffc0200dba:	79a2                	ld	s3,40(sp)
ffffffffc0200dbc:	7a02                	ld	s4,32(sp)
ffffffffc0200dbe:	6ae2                	ld	s5,24(sp)
ffffffffc0200dc0:	6b42                	ld	s6,16(sp)
ffffffffc0200dc2:	6ba2                	ld	s7,8(sp)
ffffffffc0200dc4:	6c02                	ld	s8,0(sp)
ffffffffc0200dc6:	6161                	addi	sp,sp,80
ffffffffc0200dc8:	8082                	ret
ffffffffc0200dca:	4981                	li	s3,0
ffffffffc0200dcc:	4481                	li	s1,0
ffffffffc0200dce:	4901                	li	s2,0
ffffffffc0200dd0:	b3b9                	j	ffffffffc0200b1e <default_check+0x42>
ffffffffc0200dd2:	00004697          	auipc	a3,0x4
ffffffffc0200dd6:	03e68693          	addi	a3,a3,62 # ffffffffc0204e10 <commands+0x728>
ffffffffc0200dda:	00004617          	auipc	a2,0x4
ffffffffc0200dde:	04660613          	addi	a2,a2,70 # ffffffffc0204e20 <commands+0x738>
ffffffffc0200de2:	0f000593          	li	a1,240
ffffffffc0200de6:	00004517          	auipc	a0,0x4
ffffffffc0200dea:	05250513          	addi	a0,a0,82 # ffffffffc0204e38 <commands+0x750>
ffffffffc0200dee:	d74ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0200df2:	00004697          	auipc	a3,0x4
ffffffffc0200df6:	0de68693          	addi	a3,a3,222 # ffffffffc0204ed0 <commands+0x7e8>
ffffffffc0200dfa:	00004617          	auipc	a2,0x4
ffffffffc0200dfe:	02660613          	addi	a2,a2,38 # ffffffffc0204e20 <commands+0x738>
ffffffffc0200e02:	0bd00593          	li	a1,189
ffffffffc0200e06:	00004517          	auipc	a0,0x4
ffffffffc0200e0a:	03250513          	addi	a0,a0,50 # ffffffffc0204e38 <commands+0x750>
ffffffffc0200e0e:	d54ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0200e12:	00004697          	auipc	a3,0x4
ffffffffc0200e16:	0e668693          	addi	a3,a3,230 # ffffffffc0204ef8 <commands+0x810>
ffffffffc0200e1a:	00004617          	auipc	a2,0x4
ffffffffc0200e1e:	00660613          	addi	a2,a2,6 # ffffffffc0204e20 <commands+0x738>
ffffffffc0200e22:	0be00593          	li	a1,190
ffffffffc0200e26:	00004517          	auipc	a0,0x4
ffffffffc0200e2a:	01250513          	addi	a0,a0,18 # ffffffffc0204e38 <commands+0x750>
ffffffffc0200e2e:	d34ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0200e32:	00004697          	auipc	a3,0x4
ffffffffc0200e36:	10668693          	addi	a3,a3,262 # ffffffffc0204f38 <commands+0x850>
ffffffffc0200e3a:	00004617          	auipc	a2,0x4
ffffffffc0200e3e:	fe660613          	addi	a2,a2,-26 # ffffffffc0204e20 <commands+0x738>
ffffffffc0200e42:	0c000593          	li	a1,192
ffffffffc0200e46:	00004517          	auipc	a0,0x4
ffffffffc0200e4a:	ff250513          	addi	a0,a0,-14 # ffffffffc0204e38 <commands+0x750>
ffffffffc0200e4e:	d14ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0200e52:	00004697          	auipc	a3,0x4
ffffffffc0200e56:	16e68693          	addi	a3,a3,366 # ffffffffc0204fc0 <commands+0x8d8>
ffffffffc0200e5a:	00004617          	auipc	a2,0x4
ffffffffc0200e5e:	fc660613          	addi	a2,a2,-58 # ffffffffc0204e20 <commands+0x738>
ffffffffc0200e62:	0d900593          	li	a1,217
ffffffffc0200e66:	00004517          	auipc	a0,0x4
ffffffffc0200e6a:	fd250513          	addi	a0,a0,-46 # ffffffffc0204e38 <commands+0x750>
ffffffffc0200e6e:	cf4ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0200e72:	00004697          	auipc	a3,0x4
ffffffffc0200e76:	ffe68693          	addi	a3,a3,-2 # ffffffffc0204e70 <commands+0x788>
ffffffffc0200e7a:	00004617          	auipc	a2,0x4
ffffffffc0200e7e:	fa660613          	addi	a2,a2,-90 # ffffffffc0204e20 <commands+0x738>
ffffffffc0200e82:	0d200593          	li	a1,210
ffffffffc0200e86:	00004517          	auipc	a0,0x4
ffffffffc0200e8a:	fb250513          	addi	a0,a0,-78 # ffffffffc0204e38 <commands+0x750>
ffffffffc0200e8e:	cd4ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0200e92:	00004697          	auipc	a3,0x4
ffffffffc0200e96:	11e68693          	addi	a3,a3,286 # ffffffffc0204fb0 <commands+0x8c8>
ffffffffc0200e9a:	00004617          	auipc	a2,0x4
ffffffffc0200e9e:	f8660613          	addi	a2,a2,-122 # ffffffffc0204e20 <commands+0x738>
ffffffffc0200ea2:	0d000593          	li	a1,208
ffffffffc0200ea6:	00004517          	auipc	a0,0x4
ffffffffc0200eaa:	f9250513          	addi	a0,a0,-110 # ffffffffc0204e38 <commands+0x750>
ffffffffc0200eae:	cb4ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0200eb2:	00004697          	auipc	a3,0x4
ffffffffc0200eb6:	0e668693          	addi	a3,a3,230 # ffffffffc0204f98 <commands+0x8b0>
ffffffffc0200eba:	00004617          	auipc	a2,0x4
ffffffffc0200ebe:	f6660613          	addi	a2,a2,-154 # ffffffffc0204e20 <commands+0x738>
ffffffffc0200ec2:	0cb00593          	li	a1,203
ffffffffc0200ec6:	00004517          	auipc	a0,0x4
ffffffffc0200eca:	f7250513          	addi	a0,a0,-142 # ffffffffc0204e38 <commands+0x750>
ffffffffc0200ece:	c94ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0200ed2:	00004697          	auipc	a3,0x4
ffffffffc0200ed6:	0a668693          	addi	a3,a3,166 # ffffffffc0204f78 <commands+0x890>
ffffffffc0200eda:	00004617          	auipc	a2,0x4
ffffffffc0200ede:	f4660613          	addi	a2,a2,-186 # ffffffffc0204e20 <commands+0x738>
ffffffffc0200ee2:	0c200593          	li	a1,194
ffffffffc0200ee6:	00004517          	auipc	a0,0x4
ffffffffc0200eea:	f5250513          	addi	a0,a0,-174 # ffffffffc0204e38 <commands+0x750>
ffffffffc0200eee:	c74ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0200ef2:	00004697          	auipc	a3,0x4
ffffffffc0200ef6:	11668693          	addi	a3,a3,278 # ffffffffc0205008 <commands+0x920>
ffffffffc0200efa:	00004617          	auipc	a2,0x4
ffffffffc0200efe:	f2660613          	addi	a2,a2,-218 # ffffffffc0204e20 <commands+0x738>
ffffffffc0200f02:	0f800593          	li	a1,248
ffffffffc0200f06:	00004517          	auipc	a0,0x4
ffffffffc0200f0a:	f3250513          	addi	a0,a0,-206 # ffffffffc0204e38 <commands+0x750>
ffffffffc0200f0e:	c54ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0200f12:	00004697          	auipc	a3,0x4
ffffffffc0200f16:	0e668693          	addi	a3,a3,230 # ffffffffc0204ff8 <commands+0x910>
ffffffffc0200f1a:	00004617          	auipc	a2,0x4
ffffffffc0200f1e:	f0660613          	addi	a2,a2,-250 # ffffffffc0204e20 <commands+0x738>
ffffffffc0200f22:	0df00593          	li	a1,223
ffffffffc0200f26:	00004517          	auipc	a0,0x4
ffffffffc0200f2a:	f1250513          	addi	a0,a0,-238 # ffffffffc0204e38 <commands+0x750>
ffffffffc0200f2e:	c34ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0200f32:	00004697          	auipc	a3,0x4
ffffffffc0200f36:	06668693          	addi	a3,a3,102 # ffffffffc0204f98 <commands+0x8b0>
ffffffffc0200f3a:	00004617          	auipc	a2,0x4
ffffffffc0200f3e:	ee660613          	addi	a2,a2,-282 # ffffffffc0204e20 <commands+0x738>
ffffffffc0200f42:	0dd00593          	li	a1,221
ffffffffc0200f46:	00004517          	auipc	a0,0x4
ffffffffc0200f4a:	ef250513          	addi	a0,a0,-270 # ffffffffc0204e38 <commands+0x750>
ffffffffc0200f4e:	c14ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0200f52:	00004697          	auipc	a3,0x4
ffffffffc0200f56:	08668693          	addi	a3,a3,134 # ffffffffc0204fd8 <commands+0x8f0>
ffffffffc0200f5a:	00004617          	auipc	a2,0x4
ffffffffc0200f5e:	ec660613          	addi	a2,a2,-314 # ffffffffc0204e20 <commands+0x738>
ffffffffc0200f62:	0dc00593          	li	a1,220
ffffffffc0200f66:	00004517          	auipc	a0,0x4
ffffffffc0200f6a:	ed250513          	addi	a0,a0,-302 # ffffffffc0204e38 <commands+0x750>
ffffffffc0200f6e:	bf4ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0200f72:	00004697          	auipc	a3,0x4
ffffffffc0200f76:	efe68693          	addi	a3,a3,-258 # ffffffffc0204e70 <commands+0x788>
ffffffffc0200f7a:	00004617          	auipc	a2,0x4
ffffffffc0200f7e:	ea660613          	addi	a2,a2,-346 # ffffffffc0204e20 <commands+0x738>
ffffffffc0200f82:	0b900593          	li	a1,185
ffffffffc0200f86:	00004517          	auipc	a0,0x4
ffffffffc0200f8a:	eb250513          	addi	a0,a0,-334 # ffffffffc0204e38 <commands+0x750>
ffffffffc0200f8e:	bd4ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0200f92:	00004697          	auipc	a3,0x4
ffffffffc0200f96:	00668693          	addi	a3,a3,6 # ffffffffc0204f98 <commands+0x8b0>
ffffffffc0200f9a:	00004617          	auipc	a2,0x4
ffffffffc0200f9e:	e8660613          	addi	a2,a2,-378 # ffffffffc0204e20 <commands+0x738>
ffffffffc0200fa2:	0d600593          	li	a1,214
ffffffffc0200fa6:	00004517          	auipc	a0,0x4
ffffffffc0200faa:	e9250513          	addi	a0,a0,-366 # ffffffffc0204e38 <commands+0x750>
ffffffffc0200fae:	bb4ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0200fb2:	00004697          	auipc	a3,0x4
ffffffffc0200fb6:	efe68693          	addi	a3,a3,-258 # ffffffffc0204eb0 <commands+0x7c8>
ffffffffc0200fba:	00004617          	auipc	a2,0x4
ffffffffc0200fbe:	e6660613          	addi	a2,a2,-410 # ffffffffc0204e20 <commands+0x738>
ffffffffc0200fc2:	0d400593          	li	a1,212
ffffffffc0200fc6:	00004517          	auipc	a0,0x4
ffffffffc0200fca:	e7250513          	addi	a0,a0,-398 # ffffffffc0204e38 <commands+0x750>
ffffffffc0200fce:	b94ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0200fd2:	00004697          	auipc	a3,0x4
ffffffffc0200fd6:	ebe68693          	addi	a3,a3,-322 # ffffffffc0204e90 <commands+0x7a8>
ffffffffc0200fda:	00004617          	auipc	a2,0x4
ffffffffc0200fde:	e4660613          	addi	a2,a2,-442 # ffffffffc0204e20 <commands+0x738>
ffffffffc0200fe2:	0d300593          	li	a1,211
ffffffffc0200fe6:	00004517          	auipc	a0,0x4
ffffffffc0200fea:	e5250513          	addi	a0,a0,-430 # ffffffffc0204e38 <commands+0x750>
ffffffffc0200fee:	b74ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0200ff2:	00004697          	auipc	a3,0x4
ffffffffc0200ff6:	ebe68693          	addi	a3,a3,-322 # ffffffffc0204eb0 <commands+0x7c8>
ffffffffc0200ffa:	00004617          	auipc	a2,0x4
ffffffffc0200ffe:	e2660613          	addi	a2,a2,-474 # ffffffffc0204e20 <commands+0x738>
ffffffffc0201002:	0bb00593          	li	a1,187
ffffffffc0201006:	00004517          	auipc	a0,0x4
ffffffffc020100a:	e3250513          	addi	a0,a0,-462 # ffffffffc0204e38 <commands+0x750>
ffffffffc020100e:	b54ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0201012:	00004697          	auipc	a3,0x4
ffffffffc0201016:	14668693          	addi	a3,a3,326 # ffffffffc0205158 <commands+0xa70>
ffffffffc020101a:	00004617          	auipc	a2,0x4
ffffffffc020101e:	e0660613          	addi	a2,a2,-506 # ffffffffc0204e20 <commands+0x738>
ffffffffc0201022:	12500593          	li	a1,293
ffffffffc0201026:	00004517          	auipc	a0,0x4
ffffffffc020102a:	e1250513          	addi	a0,a0,-494 # ffffffffc0204e38 <commands+0x750>
ffffffffc020102e:	b34ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0201032:	00004697          	auipc	a3,0x4
ffffffffc0201036:	fc668693          	addi	a3,a3,-58 # ffffffffc0204ff8 <commands+0x910>
ffffffffc020103a:	00004617          	auipc	a2,0x4
ffffffffc020103e:	de660613          	addi	a2,a2,-538 # ffffffffc0204e20 <commands+0x738>
ffffffffc0201042:	11a00593          	li	a1,282
ffffffffc0201046:	00004517          	auipc	a0,0x4
ffffffffc020104a:	df250513          	addi	a0,a0,-526 # ffffffffc0204e38 <commands+0x750>
ffffffffc020104e:	b14ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0201052:	00004697          	auipc	a3,0x4
ffffffffc0201056:	f4668693          	addi	a3,a3,-186 # ffffffffc0204f98 <commands+0x8b0>
ffffffffc020105a:	00004617          	auipc	a2,0x4
ffffffffc020105e:	dc660613          	addi	a2,a2,-570 # ffffffffc0204e20 <commands+0x738>
ffffffffc0201062:	11800593          	li	a1,280
ffffffffc0201066:	00004517          	auipc	a0,0x4
ffffffffc020106a:	dd250513          	addi	a0,a0,-558 # ffffffffc0204e38 <commands+0x750>
ffffffffc020106e:	af4ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0201072:	00004697          	auipc	a3,0x4
ffffffffc0201076:	ee668693          	addi	a3,a3,-282 # ffffffffc0204f58 <commands+0x870>
ffffffffc020107a:	00004617          	auipc	a2,0x4
ffffffffc020107e:	da660613          	addi	a2,a2,-602 # ffffffffc0204e20 <commands+0x738>
ffffffffc0201082:	0c100593          	li	a1,193
ffffffffc0201086:	00004517          	auipc	a0,0x4
ffffffffc020108a:	db250513          	addi	a0,a0,-590 # ffffffffc0204e38 <commands+0x750>
ffffffffc020108e:	ad4ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0201092:	00004697          	auipc	a3,0x4
ffffffffc0201096:	08668693          	addi	a3,a3,134 # ffffffffc0205118 <commands+0xa30>
ffffffffc020109a:	00004617          	auipc	a2,0x4
ffffffffc020109e:	d8660613          	addi	a2,a2,-634 # ffffffffc0204e20 <commands+0x738>
ffffffffc02010a2:	11200593          	li	a1,274
ffffffffc02010a6:	00004517          	auipc	a0,0x4
ffffffffc02010aa:	d9250513          	addi	a0,a0,-622 # ffffffffc0204e38 <commands+0x750>
ffffffffc02010ae:	ab4ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02010b2:	00004697          	auipc	a3,0x4
ffffffffc02010b6:	04668693          	addi	a3,a3,70 # ffffffffc02050f8 <commands+0xa10>
ffffffffc02010ba:	00004617          	auipc	a2,0x4
ffffffffc02010be:	d6660613          	addi	a2,a2,-666 # ffffffffc0204e20 <commands+0x738>
ffffffffc02010c2:	11000593          	li	a1,272
ffffffffc02010c6:	00004517          	auipc	a0,0x4
ffffffffc02010ca:	d7250513          	addi	a0,a0,-654 # ffffffffc0204e38 <commands+0x750>
ffffffffc02010ce:	a94ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02010d2:	00004697          	auipc	a3,0x4
ffffffffc02010d6:	ffe68693          	addi	a3,a3,-2 # ffffffffc02050d0 <commands+0x9e8>
ffffffffc02010da:	00004617          	auipc	a2,0x4
ffffffffc02010de:	d4660613          	addi	a2,a2,-698 # ffffffffc0204e20 <commands+0x738>
ffffffffc02010e2:	10e00593          	li	a1,270
ffffffffc02010e6:	00004517          	auipc	a0,0x4
ffffffffc02010ea:	d5250513          	addi	a0,a0,-686 # ffffffffc0204e38 <commands+0x750>
ffffffffc02010ee:	a74ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02010f2:	00004697          	auipc	a3,0x4
ffffffffc02010f6:	fb668693          	addi	a3,a3,-74 # ffffffffc02050a8 <commands+0x9c0>
ffffffffc02010fa:	00004617          	auipc	a2,0x4
ffffffffc02010fe:	d2660613          	addi	a2,a2,-730 # ffffffffc0204e20 <commands+0x738>
ffffffffc0201102:	10d00593          	li	a1,269
ffffffffc0201106:	00004517          	auipc	a0,0x4
ffffffffc020110a:	d3250513          	addi	a0,a0,-718 # ffffffffc0204e38 <commands+0x750>
ffffffffc020110e:	a54ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0201112:	00004697          	auipc	a3,0x4
ffffffffc0201116:	f8668693          	addi	a3,a3,-122 # ffffffffc0205098 <commands+0x9b0>
ffffffffc020111a:	00004617          	auipc	a2,0x4
ffffffffc020111e:	d0660613          	addi	a2,a2,-762 # ffffffffc0204e20 <commands+0x738>
ffffffffc0201122:	10800593          	li	a1,264
ffffffffc0201126:	00004517          	auipc	a0,0x4
ffffffffc020112a:	d1250513          	addi	a0,a0,-750 # ffffffffc0204e38 <commands+0x750>
ffffffffc020112e:	a34ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0201132:	00004697          	auipc	a3,0x4
ffffffffc0201136:	e6668693          	addi	a3,a3,-410 # ffffffffc0204f98 <commands+0x8b0>
ffffffffc020113a:	00004617          	auipc	a2,0x4
ffffffffc020113e:	ce660613          	addi	a2,a2,-794 # ffffffffc0204e20 <commands+0x738>
ffffffffc0201142:	10700593          	li	a1,263
ffffffffc0201146:	00004517          	auipc	a0,0x4
ffffffffc020114a:	cf250513          	addi	a0,a0,-782 # ffffffffc0204e38 <commands+0x750>
ffffffffc020114e:	a14ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0201152:	00004697          	auipc	a3,0x4
ffffffffc0201156:	f2668693          	addi	a3,a3,-218 # ffffffffc0205078 <commands+0x990>
ffffffffc020115a:	00004617          	auipc	a2,0x4
ffffffffc020115e:	cc660613          	addi	a2,a2,-826 # ffffffffc0204e20 <commands+0x738>
ffffffffc0201162:	10600593          	li	a1,262
ffffffffc0201166:	00004517          	auipc	a0,0x4
ffffffffc020116a:	cd250513          	addi	a0,a0,-814 # ffffffffc0204e38 <commands+0x750>
ffffffffc020116e:	9f4ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0201172:	00004697          	auipc	a3,0x4
ffffffffc0201176:	ed668693          	addi	a3,a3,-298 # ffffffffc0205048 <commands+0x960>
ffffffffc020117a:	00004617          	auipc	a2,0x4
ffffffffc020117e:	ca660613          	addi	a2,a2,-858 # ffffffffc0204e20 <commands+0x738>
ffffffffc0201182:	10500593          	li	a1,261
ffffffffc0201186:	00004517          	auipc	a0,0x4
ffffffffc020118a:	cb250513          	addi	a0,a0,-846 # ffffffffc0204e38 <commands+0x750>
ffffffffc020118e:	9d4ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0201192:	00004697          	auipc	a3,0x4
ffffffffc0201196:	e9e68693          	addi	a3,a3,-354 # ffffffffc0205030 <commands+0x948>
ffffffffc020119a:	00004617          	auipc	a2,0x4
ffffffffc020119e:	c8660613          	addi	a2,a2,-890 # ffffffffc0204e20 <commands+0x738>
ffffffffc02011a2:	10400593          	li	a1,260
ffffffffc02011a6:	00004517          	auipc	a0,0x4
ffffffffc02011aa:	c9250513          	addi	a0,a0,-878 # ffffffffc0204e38 <commands+0x750>
ffffffffc02011ae:	9b4ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02011b2:	00004697          	auipc	a3,0x4
ffffffffc02011b6:	de668693          	addi	a3,a3,-538 # ffffffffc0204f98 <commands+0x8b0>
ffffffffc02011ba:	00004617          	auipc	a2,0x4
ffffffffc02011be:	c6660613          	addi	a2,a2,-922 # ffffffffc0204e20 <commands+0x738>
ffffffffc02011c2:	0fe00593          	li	a1,254
ffffffffc02011c6:	00004517          	auipc	a0,0x4
ffffffffc02011ca:	c7250513          	addi	a0,a0,-910 # ffffffffc0204e38 <commands+0x750>
ffffffffc02011ce:	994ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02011d2:	00004697          	auipc	a3,0x4
ffffffffc02011d6:	e4668693          	addi	a3,a3,-442 # ffffffffc0205018 <commands+0x930>
ffffffffc02011da:	00004617          	auipc	a2,0x4
ffffffffc02011de:	c4660613          	addi	a2,a2,-954 # ffffffffc0204e20 <commands+0x738>
ffffffffc02011e2:	0f900593          	li	a1,249
ffffffffc02011e6:	00004517          	auipc	a0,0x4
ffffffffc02011ea:	c5250513          	addi	a0,a0,-942 # ffffffffc0204e38 <commands+0x750>
ffffffffc02011ee:	974ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02011f2:	00004697          	auipc	a3,0x4
ffffffffc02011f6:	f4668693          	addi	a3,a3,-186 # ffffffffc0205138 <commands+0xa50>
ffffffffc02011fa:	00004617          	auipc	a2,0x4
ffffffffc02011fe:	c2660613          	addi	a2,a2,-986 # ffffffffc0204e20 <commands+0x738>
ffffffffc0201202:	11700593          	li	a1,279
ffffffffc0201206:	00004517          	auipc	a0,0x4
ffffffffc020120a:	c3250513          	addi	a0,a0,-974 # ffffffffc0204e38 <commands+0x750>
ffffffffc020120e:	954ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0201212:	00004697          	auipc	a3,0x4
ffffffffc0201216:	f5668693          	addi	a3,a3,-170 # ffffffffc0205168 <commands+0xa80>
ffffffffc020121a:	00004617          	auipc	a2,0x4
ffffffffc020121e:	c0660613          	addi	a2,a2,-1018 # ffffffffc0204e20 <commands+0x738>
ffffffffc0201222:	12600593          	li	a1,294
ffffffffc0201226:	00004517          	auipc	a0,0x4
ffffffffc020122a:	c1250513          	addi	a0,a0,-1006 # ffffffffc0204e38 <commands+0x750>
ffffffffc020122e:	934ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0201232:	00004697          	auipc	a3,0x4
ffffffffc0201236:	c1e68693          	addi	a3,a3,-994 # ffffffffc0204e50 <commands+0x768>
ffffffffc020123a:	00004617          	auipc	a2,0x4
ffffffffc020123e:	be660613          	addi	a2,a2,-1050 # ffffffffc0204e20 <commands+0x738>
ffffffffc0201242:	0f300593          	li	a1,243
ffffffffc0201246:	00004517          	auipc	a0,0x4
ffffffffc020124a:	bf250513          	addi	a0,a0,-1038 # ffffffffc0204e38 <commands+0x750>
ffffffffc020124e:	914ff0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0201252:	00004697          	auipc	a3,0x4
ffffffffc0201256:	c3e68693          	addi	a3,a3,-962 # ffffffffc0204e90 <commands+0x7a8>
ffffffffc020125a:	00004617          	auipc	a2,0x4
ffffffffc020125e:	bc660613          	addi	a2,a2,-1082 # ffffffffc0204e20 <commands+0x738>
ffffffffc0201262:	0ba00593          	li	a1,186
ffffffffc0201266:	00004517          	auipc	a0,0x4
ffffffffc020126a:	bd250513          	addi	a0,a0,-1070 # ffffffffc0204e38 <commands+0x750>
ffffffffc020126e:	8f4ff0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc0201272 <default_free_pages>:
ffffffffc0201272:	1141                	addi	sp,sp,-16
ffffffffc0201274:	e406                	sd	ra,8(sp)
ffffffffc0201276:	14058a63          	beqz	a1,ffffffffc02013ca <default_free_pages+0x158>
ffffffffc020127a:	00359713          	slli	a4,a1,0x3
ffffffffc020127e:	972e                	add	a4,a4,a1
ffffffffc0201280:	070e                	slli	a4,a4,0x3
ffffffffc0201282:	00e506b3          	add	a3,a0,a4
ffffffffc0201286:	87aa                	mv	a5,a0
ffffffffc0201288:	c30d                	beqz	a4,ffffffffc02012aa <default_free_pages+0x38>
ffffffffc020128a:	6798                	ld	a4,8(a5)
ffffffffc020128c:	8b05                	andi	a4,a4,1
ffffffffc020128e:	10071e63          	bnez	a4,ffffffffc02013aa <default_free_pages+0x138>
ffffffffc0201292:	6798                	ld	a4,8(a5)
ffffffffc0201294:	8b09                	andi	a4,a4,2
ffffffffc0201296:	10071a63          	bnez	a4,ffffffffc02013aa <default_free_pages+0x138>
ffffffffc020129a:	0007b423          	sd	zero,8(a5)
ffffffffc020129e:	0007a023          	sw	zero,0(a5)
ffffffffc02012a2:	04878793          	addi	a5,a5,72
ffffffffc02012a6:	fed792e3          	bne	a5,a3,ffffffffc020128a <default_free_pages+0x18>
ffffffffc02012aa:	2581                	sext.w	a1,a1
ffffffffc02012ac:	cd0c                	sw	a1,24(a0)
ffffffffc02012ae:	00850893          	addi	a7,a0,8
ffffffffc02012b2:	4789                	li	a5,2
ffffffffc02012b4:	40f8b02f          	amoor.d	zero,a5,(a7)
ffffffffc02012b8:	00010697          	auipc	a3,0x10
ffffffffc02012bc:	d8868693          	addi	a3,a3,-632 # ffffffffc0211040 <free_area>
ffffffffc02012c0:	4a98                	lw	a4,16(a3)
ffffffffc02012c2:	669c                	ld	a5,8(a3)
ffffffffc02012c4:	9f2d                	addw	a4,a4,a1
ffffffffc02012c6:	ca98                	sw	a4,16(a3)
ffffffffc02012c8:	0ad78563          	beq	a5,a3,ffffffffc0201372 <default_free_pages+0x100>
ffffffffc02012cc:	fe078713          	addi	a4,a5,-32
ffffffffc02012d0:	4581                	li	a1,0
ffffffffc02012d2:	02050613          	addi	a2,a0,32
ffffffffc02012d6:	00e56a63          	bltu	a0,a4,ffffffffc02012ea <default_free_pages+0x78>
ffffffffc02012da:	6798                	ld	a4,8(a5)
ffffffffc02012dc:	06d70263          	beq	a4,a3,ffffffffc0201340 <default_free_pages+0xce>
ffffffffc02012e0:	87ba                	mv	a5,a4
ffffffffc02012e2:	fe078713          	addi	a4,a5,-32
ffffffffc02012e6:	fee57ae3          	bgeu	a0,a4,ffffffffc02012da <default_free_pages+0x68>
ffffffffc02012ea:	c199                	beqz	a1,ffffffffc02012f0 <default_free_pages+0x7e>
ffffffffc02012ec:	0106b023          	sd	a6,0(a3)
ffffffffc02012f0:	6398                	ld	a4,0(a5)
ffffffffc02012f2:	e390                	sd	a2,0(a5)
ffffffffc02012f4:	e710                	sd	a2,8(a4)
ffffffffc02012f6:	f51c                	sd	a5,40(a0)
ffffffffc02012f8:	f118                	sd	a4,32(a0)
ffffffffc02012fa:	02d70063          	beq	a4,a3,ffffffffc020131a <default_free_pages+0xa8>
ffffffffc02012fe:	ff872803          	lw	a6,-8(a4)
ffffffffc0201302:	fe070593          	addi	a1,a4,-32
ffffffffc0201306:	02081613          	slli	a2,a6,0x20
ffffffffc020130a:	9201                	srli	a2,a2,0x20
ffffffffc020130c:	00361793          	slli	a5,a2,0x3
ffffffffc0201310:	97b2                	add	a5,a5,a2
ffffffffc0201312:	078e                	slli	a5,a5,0x3
ffffffffc0201314:	97ae                	add	a5,a5,a1
ffffffffc0201316:	02f50f63          	beq	a0,a5,ffffffffc0201354 <default_free_pages+0xe2>
ffffffffc020131a:	7518                	ld	a4,40(a0)
ffffffffc020131c:	00d70f63          	beq	a4,a3,ffffffffc020133a <default_free_pages+0xc8>
ffffffffc0201320:	4d0c                	lw	a1,24(a0)
ffffffffc0201322:	fe070693          	addi	a3,a4,-32
ffffffffc0201326:	02059613          	slli	a2,a1,0x20
ffffffffc020132a:	9201                	srli	a2,a2,0x20
ffffffffc020132c:	00361793          	slli	a5,a2,0x3
ffffffffc0201330:	97b2                	add	a5,a5,a2
ffffffffc0201332:	078e                	slli	a5,a5,0x3
ffffffffc0201334:	97aa                	add	a5,a5,a0
ffffffffc0201336:	04f68a63          	beq	a3,a5,ffffffffc020138a <default_free_pages+0x118>
ffffffffc020133a:	60a2                	ld	ra,8(sp)
ffffffffc020133c:	0141                	addi	sp,sp,16
ffffffffc020133e:	8082                	ret
ffffffffc0201340:	e790                	sd	a2,8(a5)
ffffffffc0201342:	f514                	sd	a3,40(a0)
ffffffffc0201344:	6798                	ld	a4,8(a5)
ffffffffc0201346:	f11c                	sd	a5,32(a0)
ffffffffc0201348:	8832                	mv	a6,a2
ffffffffc020134a:	02d70d63          	beq	a4,a3,ffffffffc0201384 <default_free_pages+0x112>
ffffffffc020134e:	4585                	li	a1,1
ffffffffc0201350:	87ba                	mv	a5,a4
ffffffffc0201352:	bf41                	j	ffffffffc02012e2 <default_free_pages+0x70>
ffffffffc0201354:	4d1c                	lw	a5,24(a0)
ffffffffc0201356:	010787bb          	addw	a5,a5,a6
ffffffffc020135a:	fef72c23          	sw	a5,-8(a4)
ffffffffc020135e:	57f5                	li	a5,-3
ffffffffc0201360:	60f8b02f          	amoand.d	zero,a5,(a7)
ffffffffc0201364:	7110                	ld	a2,32(a0)
ffffffffc0201366:	751c                	ld	a5,40(a0)
ffffffffc0201368:	852e                	mv	a0,a1
ffffffffc020136a:	e61c                	sd	a5,8(a2)
ffffffffc020136c:	6718                	ld	a4,8(a4)
ffffffffc020136e:	e390                	sd	a2,0(a5)
ffffffffc0201370:	b775                	j	ffffffffc020131c <default_free_pages+0xaa>
ffffffffc0201372:	60a2                	ld	ra,8(sp)
ffffffffc0201374:	02050713          	addi	a4,a0,32
ffffffffc0201378:	e398                	sd	a4,0(a5)
ffffffffc020137a:	e798                	sd	a4,8(a5)
ffffffffc020137c:	f51c                	sd	a5,40(a0)
ffffffffc020137e:	f11c                	sd	a5,32(a0)
ffffffffc0201380:	0141                	addi	sp,sp,16
ffffffffc0201382:	8082                	ret
ffffffffc0201384:	e290                	sd	a2,0(a3)
ffffffffc0201386:	873e                	mv	a4,a5
ffffffffc0201388:	bf8d                	j	ffffffffc02012fa <default_free_pages+0x88>
ffffffffc020138a:	ff872783          	lw	a5,-8(a4)
ffffffffc020138e:	fe870693          	addi	a3,a4,-24
ffffffffc0201392:	9fad                	addw	a5,a5,a1
ffffffffc0201394:	cd1c                	sw	a5,24(a0)
ffffffffc0201396:	57f5                	li	a5,-3
ffffffffc0201398:	60f6b02f          	amoand.d	zero,a5,(a3)
ffffffffc020139c:	6314                	ld	a3,0(a4)
ffffffffc020139e:	671c                	ld	a5,8(a4)
ffffffffc02013a0:	60a2                	ld	ra,8(sp)
ffffffffc02013a2:	e69c                	sd	a5,8(a3)
ffffffffc02013a4:	e394                	sd	a3,0(a5)
ffffffffc02013a6:	0141                	addi	sp,sp,16
ffffffffc02013a8:	8082                	ret
ffffffffc02013aa:	00004697          	auipc	a3,0x4
ffffffffc02013ae:	dd668693          	addi	a3,a3,-554 # ffffffffc0205180 <commands+0xa98>
ffffffffc02013b2:	00004617          	auipc	a2,0x4
ffffffffc02013b6:	a6e60613          	addi	a2,a2,-1426 # ffffffffc0204e20 <commands+0x738>
ffffffffc02013ba:	08300593          	li	a1,131
ffffffffc02013be:	00004517          	auipc	a0,0x4
ffffffffc02013c2:	a7a50513          	addi	a0,a0,-1414 # ffffffffc0204e38 <commands+0x750>
ffffffffc02013c6:	f9dfe0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02013ca:	00004697          	auipc	a3,0x4
ffffffffc02013ce:	dae68693          	addi	a3,a3,-594 # ffffffffc0205178 <commands+0xa90>
ffffffffc02013d2:	00004617          	auipc	a2,0x4
ffffffffc02013d6:	a4e60613          	addi	a2,a2,-1458 # ffffffffc0204e20 <commands+0x738>
ffffffffc02013da:	08000593          	li	a1,128
ffffffffc02013de:	00004517          	auipc	a0,0x4
ffffffffc02013e2:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0204e38 <commands+0x750>
ffffffffc02013e6:	f7dfe0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc02013ea <default_alloc_pages>:
ffffffffc02013ea:	c959                	beqz	a0,ffffffffc0201480 <default_alloc_pages+0x96>
ffffffffc02013ec:	00010617          	auipc	a2,0x10
ffffffffc02013f0:	c5460613          	addi	a2,a2,-940 # ffffffffc0211040 <free_area>
ffffffffc02013f4:	4a0c                	lw	a1,16(a2)
ffffffffc02013f6:	86aa                	mv	a3,a0
ffffffffc02013f8:	02059793          	slli	a5,a1,0x20
ffffffffc02013fc:	9381                	srli	a5,a5,0x20
ffffffffc02013fe:	00a7eb63          	bltu	a5,a0,ffffffffc0201414 <default_alloc_pages+0x2a>
ffffffffc0201402:	87b2                	mv	a5,a2
ffffffffc0201404:	a029                	j	ffffffffc020140e <default_alloc_pages+0x24>
ffffffffc0201406:	ff87e703          	lwu	a4,-8(a5)
ffffffffc020140a:	00d77763          	bgeu	a4,a3,ffffffffc0201418 <default_alloc_pages+0x2e>
ffffffffc020140e:	679c                	ld	a5,8(a5)
ffffffffc0201410:	fec79be3          	bne	a5,a2,ffffffffc0201406 <default_alloc_pages+0x1c>
ffffffffc0201414:	4501                	li	a0,0
ffffffffc0201416:	8082                	ret
ffffffffc0201418:	6798                	ld	a4,8(a5)
ffffffffc020141a:	0007b803          	ld	a6,0(a5)
ffffffffc020141e:	ff87a883          	lw	a7,-8(a5)
ffffffffc0201422:	fe078513          	addi	a0,a5,-32
ffffffffc0201426:	00e83423          	sd	a4,8(a6)
ffffffffc020142a:	01073023          	sd	a6,0(a4)
ffffffffc020142e:	02089713          	slli	a4,a7,0x20
ffffffffc0201432:	9301                	srli	a4,a4,0x20
ffffffffc0201434:	0006831b          	sext.w	t1,a3
ffffffffc0201438:	02e6fc63          	bgeu	a3,a4,ffffffffc0201470 <default_alloc_pages+0x86>
ffffffffc020143c:	00369713          	slli	a4,a3,0x3
ffffffffc0201440:	9736                	add	a4,a4,a3
ffffffffc0201442:	070e                	slli	a4,a4,0x3
ffffffffc0201444:	972a                	add	a4,a4,a0
ffffffffc0201446:	406888bb          	subw	a7,a7,t1
ffffffffc020144a:	01172c23          	sw	a7,24(a4)
ffffffffc020144e:	4689                	li	a3,2
ffffffffc0201450:	00870593          	addi	a1,a4,8
ffffffffc0201454:	40d5b02f          	amoor.d	zero,a3,(a1)
ffffffffc0201458:	00883683          	ld	a3,8(a6)
ffffffffc020145c:	02070893          	addi	a7,a4,32
ffffffffc0201460:	4a0c                	lw	a1,16(a2)
ffffffffc0201462:	0116b023          	sd	a7,0(a3)
ffffffffc0201466:	01183423          	sd	a7,8(a6)
ffffffffc020146a:	f714                	sd	a3,40(a4)
ffffffffc020146c:	03073023          	sd	a6,32(a4)
ffffffffc0201470:	406585bb          	subw	a1,a1,t1
ffffffffc0201474:	ca0c                	sw	a1,16(a2)
ffffffffc0201476:	5775                	li	a4,-3
ffffffffc0201478:	17a1                	addi	a5,a5,-24
ffffffffc020147a:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc020147e:	8082                	ret
ffffffffc0201480:	1141                	addi	sp,sp,-16
ffffffffc0201482:	00004697          	auipc	a3,0x4
ffffffffc0201486:	cf668693          	addi	a3,a3,-778 # ffffffffc0205178 <commands+0xa90>
ffffffffc020148a:	00004617          	auipc	a2,0x4
ffffffffc020148e:	99660613          	addi	a2,a2,-1642 # ffffffffc0204e20 <commands+0x738>
ffffffffc0201492:	06200593          	li	a1,98
ffffffffc0201496:	00004517          	auipc	a0,0x4
ffffffffc020149a:	9a250513          	addi	a0,a0,-1630 # ffffffffc0204e38 <commands+0x750>
ffffffffc020149e:	e406                	sd	ra,8(sp)
ffffffffc02014a0:	ec3fe0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc02014a4 <default_init_memmap>:
ffffffffc02014a4:	1141                	addi	sp,sp,-16
ffffffffc02014a6:	e406                	sd	ra,8(sp)
ffffffffc02014a8:	c9e1                	beqz	a1,ffffffffc0201578 <default_init_memmap+0xd4>
ffffffffc02014aa:	00359713          	slli	a4,a1,0x3
ffffffffc02014ae:	972e                	add	a4,a4,a1
ffffffffc02014b0:	070e                	slli	a4,a4,0x3
ffffffffc02014b2:	00e506b3          	add	a3,a0,a4
ffffffffc02014b6:	87aa                	mv	a5,a0
ffffffffc02014b8:	cf11                	beqz	a4,ffffffffc02014d4 <default_init_memmap+0x30>
ffffffffc02014ba:	6798                	ld	a4,8(a5)
ffffffffc02014bc:	8b05                	andi	a4,a4,1
ffffffffc02014be:	cf49                	beqz	a4,ffffffffc0201558 <default_init_memmap+0xb4>
ffffffffc02014c0:	0007ac23          	sw	zero,24(a5)
ffffffffc02014c4:	0007b423          	sd	zero,8(a5)
ffffffffc02014c8:	0007a023          	sw	zero,0(a5)
ffffffffc02014cc:	04878793          	addi	a5,a5,72
ffffffffc02014d0:	fed795e3          	bne	a5,a3,ffffffffc02014ba <default_init_memmap+0x16>
ffffffffc02014d4:	2581                	sext.w	a1,a1
ffffffffc02014d6:	cd0c                	sw	a1,24(a0)
ffffffffc02014d8:	4789                	li	a5,2
ffffffffc02014da:	00850713          	addi	a4,a0,8
ffffffffc02014de:	40f7302f          	amoor.d	zero,a5,(a4)
ffffffffc02014e2:	00010697          	auipc	a3,0x10
ffffffffc02014e6:	b5e68693          	addi	a3,a3,-1186 # ffffffffc0211040 <free_area>
ffffffffc02014ea:	4a98                	lw	a4,16(a3)
ffffffffc02014ec:	669c                	ld	a5,8(a3)
ffffffffc02014ee:	9f2d                	addw	a4,a4,a1
ffffffffc02014f0:	ca98                	sw	a4,16(a3)
ffffffffc02014f2:	04d78663          	beq	a5,a3,ffffffffc020153e <default_init_memmap+0x9a>
ffffffffc02014f6:	fe078713          	addi	a4,a5,-32
ffffffffc02014fa:	4581                	li	a1,0
ffffffffc02014fc:	02050613          	addi	a2,a0,32
ffffffffc0201500:	00e56a63          	bltu	a0,a4,ffffffffc0201514 <default_init_memmap+0x70>
ffffffffc0201504:	6798                	ld	a4,8(a5)
ffffffffc0201506:	02d70263          	beq	a4,a3,ffffffffc020152a <default_init_memmap+0x86>
ffffffffc020150a:	87ba                	mv	a5,a4
ffffffffc020150c:	fe078713          	addi	a4,a5,-32
ffffffffc0201510:	fee57ae3          	bgeu	a0,a4,ffffffffc0201504 <default_init_memmap+0x60>
ffffffffc0201514:	c199                	beqz	a1,ffffffffc020151a <default_init_memmap+0x76>
ffffffffc0201516:	0106b023          	sd	a6,0(a3)
ffffffffc020151a:	6398                	ld	a4,0(a5)
ffffffffc020151c:	60a2                	ld	ra,8(sp)
ffffffffc020151e:	e390                	sd	a2,0(a5)
ffffffffc0201520:	e710                	sd	a2,8(a4)
ffffffffc0201522:	f51c                	sd	a5,40(a0)
ffffffffc0201524:	f118                	sd	a4,32(a0)
ffffffffc0201526:	0141                	addi	sp,sp,16
ffffffffc0201528:	8082                	ret
ffffffffc020152a:	e790                	sd	a2,8(a5)
ffffffffc020152c:	f514                	sd	a3,40(a0)
ffffffffc020152e:	6798                	ld	a4,8(a5)
ffffffffc0201530:	f11c                	sd	a5,32(a0)
ffffffffc0201532:	8832                	mv	a6,a2
ffffffffc0201534:	00d70e63          	beq	a4,a3,ffffffffc0201550 <default_init_memmap+0xac>
ffffffffc0201538:	4585                	li	a1,1
ffffffffc020153a:	87ba                	mv	a5,a4
ffffffffc020153c:	bfc1                	j	ffffffffc020150c <default_init_memmap+0x68>
ffffffffc020153e:	60a2                	ld	ra,8(sp)
ffffffffc0201540:	02050713          	addi	a4,a0,32
ffffffffc0201544:	e398                	sd	a4,0(a5)
ffffffffc0201546:	e798                	sd	a4,8(a5)
ffffffffc0201548:	f51c                	sd	a5,40(a0)
ffffffffc020154a:	f11c                	sd	a5,32(a0)
ffffffffc020154c:	0141                	addi	sp,sp,16
ffffffffc020154e:	8082                	ret
ffffffffc0201550:	60a2                	ld	ra,8(sp)
ffffffffc0201552:	e290                	sd	a2,0(a3)
ffffffffc0201554:	0141                	addi	sp,sp,16
ffffffffc0201556:	8082                	ret
ffffffffc0201558:	00004697          	auipc	a3,0x4
ffffffffc020155c:	c5068693          	addi	a3,a3,-944 # ffffffffc02051a8 <commands+0xac0>
ffffffffc0201560:	00004617          	auipc	a2,0x4
ffffffffc0201564:	8c060613          	addi	a2,a2,-1856 # ffffffffc0204e20 <commands+0x738>
ffffffffc0201568:	04900593          	li	a1,73
ffffffffc020156c:	00004517          	auipc	a0,0x4
ffffffffc0201570:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0204e38 <commands+0x750>
ffffffffc0201574:	deffe0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0201578:	00004697          	auipc	a3,0x4
ffffffffc020157c:	c0068693          	addi	a3,a3,-1024 # ffffffffc0205178 <commands+0xa90>
ffffffffc0201580:	00004617          	auipc	a2,0x4
ffffffffc0201584:	8a060613          	addi	a2,a2,-1888 # ffffffffc0204e20 <commands+0x738>
ffffffffc0201588:	04600593          	li	a1,70
ffffffffc020158c:	00004517          	auipc	a0,0x4
ffffffffc0201590:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0204e38 <commands+0x750>
ffffffffc0201594:	dcffe0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc0201598 <pa2page.part.0>:
ffffffffc0201598:	1141                	addi	sp,sp,-16
ffffffffc020159a:	00004617          	auipc	a2,0x4
ffffffffc020159e:	c6e60613          	addi	a2,a2,-914 # ffffffffc0205208 <default_pmm_manager+0x38>
ffffffffc02015a2:	06500593          	li	a1,101
ffffffffc02015a6:	00004517          	auipc	a0,0x4
ffffffffc02015aa:	c8250513          	addi	a0,a0,-894 # ffffffffc0205228 <default_pmm_manager+0x58>
ffffffffc02015ae:	e406                	sd	ra,8(sp)
ffffffffc02015b0:	db3fe0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc02015b4 <pte2page.part.0>:
ffffffffc02015b4:	1141                	addi	sp,sp,-16
ffffffffc02015b6:	00004617          	auipc	a2,0x4
ffffffffc02015ba:	c8260613          	addi	a2,a2,-894 # ffffffffc0205238 <default_pmm_manager+0x68>
ffffffffc02015be:	07000593          	li	a1,112
ffffffffc02015c2:	00004517          	auipc	a0,0x4
ffffffffc02015c6:	c6650513          	addi	a0,a0,-922 # ffffffffc0205228 <default_pmm_manager+0x58>
ffffffffc02015ca:	e406                	sd	ra,8(sp)
ffffffffc02015cc:	d97fe0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc02015d0 <alloc_pages>:
ffffffffc02015d0:	715d                	addi	sp,sp,-80
ffffffffc02015d2:	fc26                	sd	s1,56(sp)
ffffffffc02015d4:	f84a                	sd	s2,48(sp)
ffffffffc02015d6:	f44e                	sd	s3,40(sp)
ffffffffc02015d8:	f052                	sd	s4,32(sp)
ffffffffc02015da:	ec56                	sd	s5,24(sp)
ffffffffc02015dc:	e85a                	sd	s6,16(sp)
ffffffffc02015de:	e45e                	sd	s7,8(sp)
ffffffffc02015e0:	e486                	sd	ra,72(sp)
ffffffffc02015e2:	e0a2                	sd	s0,64(sp)
ffffffffc02015e4:	84aa                	mv	s1,a0
ffffffffc02015e6:	00010917          	auipc	s2,0x10
ffffffffc02015ea:	f3290913          	addi	s2,s2,-206 # ffffffffc0211518 <pmm_manager>
ffffffffc02015ee:	4a05                	li	s4,1
ffffffffc02015f0:	00010a97          	auipc	s5,0x10
ffffffffc02015f4:	f58a8a93          	addi	s5,s5,-168 # ffffffffc0211548 <swap_init_ok>
ffffffffc02015f8:	00004997          	auipc	s3,0x4
ffffffffc02015fc:	c6898993          	addi	s3,s3,-920 # ffffffffc0205260 <default_pmm_manager+0x90>
ffffffffc0201600:	00050b9b          	sext.w	s7,a0
ffffffffc0201604:	00010b17          	auipc	s6,0x10
ffffffffc0201608:	f6cb0b13          	addi	s6,s6,-148 # ffffffffc0211570 <check_mm_struct>
ffffffffc020160c:	a03d                	j	ffffffffc020163a <alloc_pages+0x6a>
ffffffffc020160e:	00093783          	ld	a5,0(s2)
ffffffffc0201612:	6f9c                	ld	a5,24(a5)
ffffffffc0201614:	9782                	jalr	a5
ffffffffc0201616:	842a                	mv	s0,a0
ffffffffc0201618:	8626                	mv	a2,s1
ffffffffc020161a:	4581                	li	a1,0
ffffffffc020161c:	854e                	mv	a0,s3
ffffffffc020161e:	e029                	bnez	s0,ffffffffc0201660 <alloc_pages+0x90>
ffffffffc0201620:	049a6063          	bltu	s4,s1,ffffffffc0201660 <alloc_pages+0x90>
ffffffffc0201624:	000aa783          	lw	a5,0(s5)
ffffffffc0201628:	cf85                	beqz	a5,ffffffffc0201660 <alloc_pages+0x90>
ffffffffc020162a:	a91fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020162e:	000b3503          	ld	a0,0(s6)
ffffffffc0201632:	4601                	li	a2,0
ffffffffc0201634:	85de                	mv	a1,s7
ffffffffc0201636:	19f010ef          	jal	ra,ffffffffc0202fd4 <swap_out>
ffffffffc020163a:	100027f3          	csrr	a5,sstatus
ffffffffc020163e:	8b89                	andi	a5,a5,2
ffffffffc0201640:	8526                	mv	a0,s1
ffffffffc0201642:	d7f1                	beqz	a5,ffffffffc020160e <alloc_pages+0x3e>
ffffffffc0201644:	e99fe0ef          	jal	ra,ffffffffc02004dc <intr_disable>
ffffffffc0201648:	00093783          	ld	a5,0(s2)
ffffffffc020164c:	8526                	mv	a0,s1
ffffffffc020164e:	6f9c                	ld	a5,24(a5)
ffffffffc0201650:	9782                	jalr	a5
ffffffffc0201652:	842a                	mv	s0,a0
ffffffffc0201654:	e83fe0ef          	jal	ra,ffffffffc02004d6 <intr_enable>
ffffffffc0201658:	8626                	mv	a2,s1
ffffffffc020165a:	4581                	li	a1,0
ffffffffc020165c:	854e                	mv	a0,s3
ffffffffc020165e:	d069                	beqz	s0,ffffffffc0201620 <alloc_pages+0x50>
ffffffffc0201660:	60a6                	ld	ra,72(sp)
ffffffffc0201662:	8522                	mv	a0,s0
ffffffffc0201664:	6406                	ld	s0,64(sp)
ffffffffc0201666:	74e2                	ld	s1,56(sp)
ffffffffc0201668:	7942                	ld	s2,48(sp)
ffffffffc020166a:	79a2                	ld	s3,40(sp)
ffffffffc020166c:	7a02                	ld	s4,32(sp)
ffffffffc020166e:	6ae2                	ld	s5,24(sp)
ffffffffc0201670:	6b42                	ld	s6,16(sp)
ffffffffc0201672:	6ba2                	ld	s7,8(sp)
ffffffffc0201674:	6161                	addi	sp,sp,80
ffffffffc0201676:	8082                	ret

ffffffffc0201678 <free_pages>:
ffffffffc0201678:	100027f3          	csrr	a5,sstatus
ffffffffc020167c:	8b89                	andi	a5,a5,2
ffffffffc020167e:	e799                	bnez	a5,ffffffffc020168c <free_pages+0x14>
ffffffffc0201680:	00010797          	auipc	a5,0x10
ffffffffc0201684:	e987b783          	ld	a5,-360(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc0201688:	739c                	ld	a5,32(a5)
ffffffffc020168a:	8782                	jr	a5
ffffffffc020168c:	1101                	addi	sp,sp,-32
ffffffffc020168e:	ec06                	sd	ra,24(sp)
ffffffffc0201690:	e822                	sd	s0,16(sp)
ffffffffc0201692:	e426                	sd	s1,8(sp)
ffffffffc0201694:	842a                	mv	s0,a0
ffffffffc0201696:	84ae                	mv	s1,a1
ffffffffc0201698:	e45fe0ef          	jal	ra,ffffffffc02004dc <intr_disable>
ffffffffc020169c:	00010797          	auipc	a5,0x10
ffffffffc02016a0:	e7c7b783          	ld	a5,-388(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc02016a4:	739c                	ld	a5,32(a5)
ffffffffc02016a6:	85a6                	mv	a1,s1
ffffffffc02016a8:	8522                	mv	a0,s0
ffffffffc02016aa:	9782                	jalr	a5
ffffffffc02016ac:	6442                	ld	s0,16(sp)
ffffffffc02016ae:	60e2                	ld	ra,24(sp)
ffffffffc02016b0:	64a2                	ld	s1,8(sp)
ffffffffc02016b2:	6105                	addi	sp,sp,32
ffffffffc02016b4:	e23fe06f          	j	ffffffffc02004d6 <intr_enable>

ffffffffc02016b8 <nr_free_pages>:
ffffffffc02016b8:	100027f3          	csrr	a5,sstatus
ffffffffc02016bc:	8b89                	andi	a5,a5,2
ffffffffc02016be:	e799                	bnez	a5,ffffffffc02016cc <nr_free_pages+0x14>
ffffffffc02016c0:	00010797          	auipc	a5,0x10
ffffffffc02016c4:	e587b783          	ld	a5,-424(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc02016c8:	779c                	ld	a5,40(a5)
ffffffffc02016ca:	8782                	jr	a5
ffffffffc02016cc:	1141                	addi	sp,sp,-16
ffffffffc02016ce:	e406                	sd	ra,8(sp)
ffffffffc02016d0:	e022                	sd	s0,0(sp)
ffffffffc02016d2:	e0bfe0ef          	jal	ra,ffffffffc02004dc <intr_disable>
ffffffffc02016d6:	00010797          	auipc	a5,0x10
ffffffffc02016da:	e427b783          	ld	a5,-446(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc02016de:	779c                	ld	a5,40(a5)
ffffffffc02016e0:	9782                	jalr	a5
ffffffffc02016e2:	842a                	mv	s0,a0
ffffffffc02016e4:	df3fe0ef          	jal	ra,ffffffffc02004d6 <intr_enable>
ffffffffc02016e8:	60a2                	ld	ra,8(sp)
ffffffffc02016ea:	8522                	mv	a0,s0
ffffffffc02016ec:	6402                	ld	s0,0(sp)
ffffffffc02016ee:	0141                	addi	sp,sp,16
ffffffffc02016f0:	8082                	ret

ffffffffc02016f2 <get_pte>:
ffffffffc02016f2:	01e5d793          	srli	a5,a1,0x1e
ffffffffc02016f6:	1ff7f793          	andi	a5,a5,511
ffffffffc02016fa:	715d                	addi	sp,sp,-80
ffffffffc02016fc:	078e                	slli	a5,a5,0x3
ffffffffc02016fe:	fc26                	sd	s1,56(sp)
ffffffffc0201700:	00f504b3          	add	s1,a0,a5
ffffffffc0201704:	6094                	ld	a3,0(s1)
ffffffffc0201706:	f84a                	sd	s2,48(sp)
ffffffffc0201708:	f44e                	sd	s3,40(sp)
ffffffffc020170a:	f052                	sd	s4,32(sp)
ffffffffc020170c:	e486                	sd	ra,72(sp)
ffffffffc020170e:	e0a2                	sd	s0,64(sp)
ffffffffc0201710:	ec56                	sd	s5,24(sp)
ffffffffc0201712:	e85a                	sd	s6,16(sp)
ffffffffc0201714:	e45e                	sd	s7,8(sp)
ffffffffc0201716:	0016f793          	andi	a5,a3,1
ffffffffc020171a:	892e                	mv	s2,a1
ffffffffc020171c:	8a32                	mv	s4,a2
ffffffffc020171e:	00010997          	auipc	s3,0x10
ffffffffc0201722:	e1a98993          	addi	s3,s3,-486 # ffffffffc0211538 <npage>
ffffffffc0201726:	efb5                	bnez	a5,ffffffffc02017a2 <get_pte+0xb0>
ffffffffc0201728:	14060c63          	beqz	a2,ffffffffc0201880 <get_pte+0x18e>
ffffffffc020172c:	4505                	li	a0,1
ffffffffc020172e:	ea3ff0ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0201732:	842a                	mv	s0,a0
ffffffffc0201734:	14050663          	beqz	a0,ffffffffc0201880 <get_pte+0x18e>
ffffffffc0201738:	00010b97          	auipc	s7,0x10
ffffffffc020173c:	e08b8b93          	addi	s7,s7,-504 # ffffffffc0211540 <pages>
ffffffffc0201740:	000bb503          	ld	a0,0(s7)
ffffffffc0201744:	00005b17          	auipc	s6,0x5
ffffffffc0201748:	c04b3b03          	ld	s6,-1020(s6) # ffffffffc0206348 <error_string+0x38>
ffffffffc020174c:	00080ab7          	lui	s5,0x80
ffffffffc0201750:	40a40533          	sub	a0,s0,a0
ffffffffc0201754:	850d                	srai	a0,a0,0x3
ffffffffc0201756:	03650533          	mul	a0,a0,s6
ffffffffc020175a:	00010997          	auipc	s3,0x10
ffffffffc020175e:	dde98993          	addi	s3,s3,-546 # ffffffffc0211538 <npage>
ffffffffc0201762:	4785                	li	a5,1
ffffffffc0201764:	0009b703          	ld	a4,0(s3)
ffffffffc0201768:	c01c                	sw	a5,0(s0)
ffffffffc020176a:	9556                	add	a0,a0,s5
ffffffffc020176c:	00c51793          	slli	a5,a0,0xc
ffffffffc0201770:	83b1                	srli	a5,a5,0xc
ffffffffc0201772:	0532                	slli	a0,a0,0xc
ffffffffc0201774:	14e7fc63          	bgeu	a5,a4,ffffffffc02018cc <get_pte+0x1da>
ffffffffc0201778:	00010797          	auipc	a5,0x10
ffffffffc020177c:	db87b783          	ld	a5,-584(a5) # ffffffffc0211530 <va_pa_offset>
ffffffffc0201780:	953e                	add	a0,a0,a5
ffffffffc0201782:	6605                	lui	a2,0x1
ffffffffc0201784:	4581                	li	a1,0
ffffffffc0201786:	4df020ef          	jal	ra,ffffffffc0204464 <memset>
ffffffffc020178a:	000bb783          	ld	a5,0(s7)
ffffffffc020178e:	40f406b3          	sub	a3,s0,a5
ffffffffc0201792:	868d                	srai	a3,a3,0x3
ffffffffc0201794:	036686b3          	mul	a3,a3,s6
ffffffffc0201798:	96d6                	add	a3,a3,s5
ffffffffc020179a:	06aa                	slli	a3,a3,0xa
ffffffffc020179c:	0116e693          	ori	a3,a3,17
ffffffffc02017a0:	e094                	sd	a3,0(s1)
ffffffffc02017a2:	77fd                	lui	a5,0xfffff
ffffffffc02017a4:	068a                	slli	a3,a3,0x2
ffffffffc02017a6:	0009b703          	ld	a4,0(s3)
ffffffffc02017aa:	8efd                	and	a3,a3,a5
ffffffffc02017ac:	00c6d793          	srli	a5,a3,0xc
ffffffffc02017b0:	0ce7fa63          	bgeu	a5,a4,ffffffffc0201884 <get_pte+0x192>
ffffffffc02017b4:	00010a97          	auipc	s5,0x10
ffffffffc02017b8:	d7ca8a93          	addi	s5,s5,-644 # ffffffffc0211530 <va_pa_offset>
ffffffffc02017bc:	000ab603          	ld	a2,0(s5)
ffffffffc02017c0:	01595793          	srli	a5,s2,0x15
ffffffffc02017c4:	1ff7f793          	andi	a5,a5,511
ffffffffc02017c8:	96b2                	add	a3,a3,a2
ffffffffc02017ca:	078e                	slli	a5,a5,0x3
ffffffffc02017cc:	00f68433          	add	s0,a3,a5
ffffffffc02017d0:	6014                	ld	a3,0(s0)
ffffffffc02017d2:	0016f793          	andi	a5,a3,1
ffffffffc02017d6:	ebad                	bnez	a5,ffffffffc0201848 <get_pte+0x156>
ffffffffc02017d8:	0a0a0463          	beqz	s4,ffffffffc0201880 <get_pte+0x18e>
ffffffffc02017dc:	4505                	li	a0,1
ffffffffc02017de:	df3ff0ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc02017e2:	84aa                	mv	s1,a0
ffffffffc02017e4:	cd51                	beqz	a0,ffffffffc0201880 <get_pte+0x18e>
ffffffffc02017e6:	00010b97          	auipc	s7,0x10
ffffffffc02017ea:	d5ab8b93          	addi	s7,s7,-678 # ffffffffc0211540 <pages>
ffffffffc02017ee:	000bb683          	ld	a3,0(s7)
ffffffffc02017f2:	00005b17          	auipc	s6,0x5
ffffffffc02017f6:	b56b3b03          	ld	s6,-1194(s6) # ffffffffc0206348 <error_string+0x38>
ffffffffc02017fa:	00080a37          	lui	s4,0x80
ffffffffc02017fe:	40d506b3          	sub	a3,a0,a3
ffffffffc0201802:	868d                	srai	a3,a3,0x3
ffffffffc0201804:	036686b3          	mul	a3,a3,s6
ffffffffc0201808:	4785                	li	a5,1
ffffffffc020180a:	0009b703          	ld	a4,0(s3)
ffffffffc020180e:	c11c                	sw	a5,0(a0)
ffffffffc0201810:	96d2                	add	a3,a3,s4
ffffffffc0201812:	00c69793          	slli	a5,a3,0xc
ffffffffc0201816:	83b1                	srli	a5,a5,0xc
ffffffffc0201818:	06b2                	slli	a3,a3,0xc
ffffffffc020181a:	08e7fd63          	bgeu	a5,a4,ffffffffc02018b4 <get_pte+0x1c2>
ffffffffc020181e:	000ab503          	ld	a0,0(s5)
ffffffffc0201822:	6605                	lui	a2,0x1
ffffffffc0201824:	4581                	li	a1,0
ffffffffc0201826:	9536                	add	a0,a0,a3
ffffffffc0201828:	43d020ef          	jal	ra,ffffffffc0204464 <memset>
ffffffffc020182c:	000bb783          	ld	a5,0(s7)
ffffffffc0201830:	40f486b3          	sub	a3,s1,a5
ffffffffc0201834:	868d                	srai	a3,a3,0x3
ffffffffc0201836:	036686b3          	mul	a3,a3,s6
ffffffffc020183a:	96d2                	add	a3,a3,s4
ffffffffc020183c:	06aa                	slli	a3,a3,0xa
ffffffffc020183e:	0116e693          	ori	a3,a3,17
ffffffffc0201842:	e014                	sd	a3,0(s0)
ffffffffc0201844:	0009b703          	ld	a4,0(s3)
ffffffffc0201848:	77fd                	lui	a5,0xfffff
ffffffffc020184a:	068a                	slli	a3,a3,0x2
ffffffffc020184c:	8efd                	and	a3,a3,a5
ffffffffc020184e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201852:	04e7f563          	bgeu	a5,a4,ffffffffc020189c <get_pte+0x1aa>
ffffffffc0201856:	000ab783          	ld	a5,0(s5)
ffffffffc020185a:	00c95913          	srli	s2,s2,0xc
ffffffffc020185e:	1ff97913          	andi	s2,s2,511
ffffffffc0201862:	96be                	add	a3,a3,a5
ffffffffc0201864:	090e                	slli	s2,s2,0x3
ffffffffc0201866:	01268533          	add	a0,a3,s2
ffffffffc020186a:	60a6                	ld	ra,72(sp)
ffffffffc020186c:	6406                	ld	s0,64(sp)
ffffffffc020186e:	74e2                	ld	s1,56(sp)
ffffffffc0201870:	7942                	ld	s2,48(sp)
ffffffffc0201872:	79a2                	ld	s3,40(sp)
ffffffffc0201874:	7a02                	ld	s4,32(sp)
ffffffffc0201876:	6ae2                	ld	s5,24(sp)
ffffffffc0201878:	6b42                	ld	s6,16(sp)
ffffffffc020187a:	6ba2                	ld	s7,8(sp)
ffffffffc020187c:	6161                	addi	sp,sp,80
ffffffffc020187e:	8082                	ret
ffffffffc0201880:	4501                	li	a0,0
ffffffffc0201882:	b7e5                	j	ffffffffc020186a <get_pte+0x178>
ffffffffc0201884:	00004617          	auipc	a2,0x4
ffffffffc0201888:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0205290 <default_pmm_manager+0xc0>
ffffffffc020188c:	11f00593          	li	a1,287
ffffffffc0201890:	00004517          	auipc	a0,0x4
ffffffffc0201894:	a2850513          	addi	a0,a0,-1496 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0201898:	acbfe0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc020189c:	00004617          	auipc	a2,0x4
ffffffffc02018a0:	9f460613          	addi	a2,a2,-1548 # ffffffffc0205290 <default_pmm_manager+0xc0>
ffffffffc02018a4:	12e00593          	li	a1,302
ffffffffc02018a8:	00004517          	auipc	a0,0x4
ffffffffc02018ac:	a1050513          	addi	a0,a0,-1520 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc02018b0:	ab3fe0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02018b4:	00004617          	auipc	a2,0x4
ffffffffc02018b8:	9dc60613          	addi	a2,a2,-1572 # ffffffffc0205290 <default_pmm_manager+0xc0>
ffffffffc02018bc:	12a00593          	li	a1,298
ffffffffc02018c0:	00004517          	auipc	a0,0x4
ffffffffc02018c4:	9f850513          	addi	a0,a0,-1544 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc02018c8:	a9bfe0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02018cc:	86aa                	mv	a3,a0
ffffffffc02018ce:	00004617          	auipc	a2,0x4
ffffffffc02018d2:	9c260613          	addi	a2,a2,-1598 # ffffffffc0205290 <default_pmm_manager+0xc0>
ffffffffc02018d6:	11c00593          	li	a1,284
ffffffffc02018da:	00004517          	auipc	a0,0x4
ffffffffc02018de:	9de50513          	addi	a0,a0,-1570 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc02018e2:	a81fe0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc02018e6 <get_page>:
ffffffffc02018e6:	1141                	addi	sp,sp,-16
ffffffffc02018e8:	e022                	sd	s0,0(sp)
ffffffffc02018ea:	8432                	mv	s0,a2
ffffffffc02018ec:	4601                	li	a2,0
ffffffffc02018ee:	e406                	sd	ra,8(sp)
ffffffffc02018f0:	e03ff0ef          	jal	ra,ffffffffc02016f2 <get_pte>
ffffffffc02018f4:	c011                	beqz	s0,ffffffffc02018f8 <get_page+0x12>
ffffffffc02018f6:	e008                	sd	a0,0(s0)
ffffffffc02018f8:	c511                	beqz	a0,ffffffffc0201904 <get_page+0x1e>
ffffffffc02018fa:	611c                	ld	a5,0(a0)
ffffffffc02018fc:	4501                	li	a0,0
ffffffffc02018fe:	0017f713          	andi	a4,a5,1
ffffffffc0201902:	e709                	bnez	a4,ffffffffc020190c <get_page+0x26>
ffffffffc0201904:	60a2                	ld	ra,8(sp)
ffffffffc0201906:	6402                	ld	s0,0(sp)
ffffffffc0201908:	0141                	addi	sp,sp,16
ffffffffc020190a:	8082                	ret
ffffffffc020190c:	078a                	slli	a5,a5,0x2
ffffffffc020190e:	83b1                	srli	a5,a5,0xc
ffffffffc0201910:	00010717          	auipc	a4,0x10
ffffffffc0201914:	c2873703          	ld	a4,-984(a4) # ffffffffc0211538 <npage>
ffffffffc0201918:	02e7f263          	bgeu	a5,a4,ffffffffc020193c <get_page+0x56>
ffffffffc020191c:	fff80737          	lui	a4,0xfff80
ffffffffc0201920:	97ba                	add	a5,a5,a4
ffffffffc0201922:	60a2                	ld	ra,8(sp)
ffffffffc0201924:	6402                	ld	s0,0(sp)
ffffffffc0201926:	00379713          	slli	a4,a5,0x3
ffffffffc020192a:	97ba                	add	a5,a5,a4
ffffffffc020192c:	00010517          	auipc	a0,0x10
ffffffffc0201930:	c1453503          	ld	a0,-1004(a0) # ffffffffc0211540 <pages>
ffffffffc0201934:	078e                	slli	a5,a5,0x3
ffffffffc0201936:	953e                	add	a0,a0,a5
ffffffffc0201938:	0141                	addi	sp,sp,16
ffffffffc020193a:	8082                	ret
ffffffffc020193c:	c5dff0ef          	jal	ra,ffffffffc0201598 <pa2page.part.0>

ffffffffc0201940 <page_remove>:
ffffffffc0201940:	1101                	addi	sp,sp,-32
ffffffffc0201942:	4601                	li	a2,0
ffffffffc0201944:	ec06                	sd	ra,24(sp)
ffffffffc0201946:	e822                	sd	s0,16(sp)
ffffffffc0201948:	dabff0ef          	jal	ra,ffffffffc02016f2 <get_pte>
ffffffffc020194c:	c511                	beqz	a0,ffffffffc0201958 <page_remove+0x18>
ffffffffc020194e:	611c                	ld	a5,0(a0)
ffffffffc0201950:	842a                	mv	s0,a0
ffffffffc0201952:	0017f713          	andi	a4,a5,1
ffffffffc0201956:	e709                	bnez	a4,ffffffffc0201960 <page_remove+0x20>
ffffffffc0201958:	60e2                	ld	ra,24(sp)
ffffffffc020195a:	6442                	ld	s0,16(sp)
ffffffffc020195c:	6105                	addi	sp,sp,32
ffffffffc020195e:	8082                	ret
ffffffffc0201960:	078a                	slli	a5,a5,0x2
ffffffffc0201962:	83b1                	srli	a5,a5,0xc
ffffffffc0201964:	00010717          	auipc	a4,0x10
ffffffffc0201968:	bd473703          	ld	a4,-1068(a4) # ffffffffc0211538 <npage>
ffffffffc020196c:	06e7f563          	bgeu	a5,a4,ffffffffc02019d6 <page_remove+0x96>
ffffffffc0201970:	fff80737          	lui	a4,0xfff80
ffffffffc0201974:	97ba                	add	a5,a5,a4
ffffffffc0201976:	00379713          	slli	a4,a5,0x3
ffffffffc020197a:	97ba                	add	a5,a5,a4
ffffffffc020197c:	078e                	slli	a5,a5,0x3
ffffffffc020197e:	00010517          	auipc	a0,0x10
ffffffffc0201982:	bc253503          	ld	a0,-1086(a0) # ffffffffc0211540 <pages>
ffffffffc0201986:	953e                	add	a0,a0,a5
ffffffffc0201988:	411c                	lw	a5,0(a0)
ffffffffc020198a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020198e:	c118                	sw	a4,0(a0)
ffffffffc0201990:	cb09                	beqz	a4,ffffffffc02019a2 <page_remove+0x62>
ffffffffc0201992:	00043023          	sd	zero,0(s0)
ffffffffc0201996:	12000073          	sfence.vma
ffffffffc020199a:	60e2                	ld	ra,24(sp)
ffffffffc020199c:	6442                	ld	s0,16(sp)
ffffffffc020199e:	6105                	addi	sp,sp,32
ffffffffc02019a0:	8082                	ret
ffffffffc02019a2:	100027f3          	csrr	a5,sstatus
ffffffffc02019a6:	8b89                	andi	a5,a5,2
ffffffffc02019a8:	eb89                	bnez	a5,ffffffffc02019ba <page_remove+0x7a>
ffffffffc02019aa:	00010797          	auipc	a5,0x10
ffffffffc02019ae:	b6e7b783          	ld	a5,-1170(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc02019b2:	739c                	ld	a5,32(a5)
ffffffffc02019b4:	4585                	li	a1,1
ffffffffc02019b6:	9782                	jalr	a5
ffffffffc02019b8:	bfe9                	j	ffffffffc0201992 <page_remove+0x52>
ffffffffc02019ba:	e42a                	sd	a0,8(sp)
ffffffffc02019bc:	b21fe0ef          	jal	ra,ffffffffc02004dc <intr_disable>
ffffffffc02019c0:	00010797          	auipc	a5,0x10
ffffffffc02019c4:	b587b783          	ld	a5,-1192(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc02019c8:	739c                	ld	a5,32(a5)
ffffffffc02019ca:	6522                	ld	a0,8(sp)
ffffffffc02019cc:	4585                	li	a1,1
ffffffffc02019ce:	9782                	jalr	a5
ffffffffc02019d0:	b07fe0ef          	jal	ra,ffffffffc02004d6 <intr_enable>
ffffffffc02019d4:	bf7d                	j	ffffffffc0201992 <page_remove+0x52>
ffffffffc02019d6:	bc3ff0ef          	jal	ra,ffffffffc0201598 <pa2page.part.0>

ffffffffc02019da <page_insert>:
ffffffffc02019da:	7179                	addi	sp,sp,-48
ffffffffc02019dc:	87b2                	mv	a5,a2
ffffffffc02019de:	f022                	sd	s0,32(sp)
ffffffffc02019e0:	4605                	li	a2,1
ffffffffc02019e2:	842e                	mv	s0,a1
ffffffffc02019e4:	85be                	mv	a1,a5
ffffffffc02019e6:	ec26                	sd	s1,24(sp)
ffffffffc02019e8:	f406                	sd	ra,40(sp)
ffffffffc02019ea:	e84a                	sd	s2,16(sp)
ffffffffc02019ec:	e44e                	sd	s3,8(sp)
ffffffffc02019ee:	e052                	sd	s4,0(sp)
ffffffffc02019f0:	84b6                	mv	s1,a3
ffffffffc02019f2:	d01ff0ef          	jal	ra,ffffffffc02016f2 <get_pte>
ffffffffc02019f6:	cd69                	beqz	a0,ffffffffc0201ad0 <page_insert+0xf6>
ffffffffc02019f8:	4014                	lw	a3,0(s0)
ffffffffc02019fa:	611c                	ld	a5,0(a0)
ffffffffc02019fc:	89aa                	mv	s3,a0
ffffffffc02019fe:	0016871b          	addiw	a4,a3,1
ffffffffc0201a02:	c018                	sw	a4,0(s0)
ffffffffc0201a04:	0017f713          	andi	a4,a5,1
ffffffffc0201a08:	e331                	bnez	a4,ffffffffc0201a4c <page_insert+0x72>
ffffffffc0201a0a:	00010717          	auipc	a4,0x10
ffffffffc0201a0e:	b3673703          	ld	a4,-1226(a4) # ffffffffc0211540 <pages>
ffffffffc0201a12:	40e407b3          	sub	a5,s0,a4
ffffffffc0201a16:	878d                	srai	a5,a5,0x3
ffffffffc0201a18:	00005717          	auipc	a4,0x5
ffffffffc0201a1c:	93073703          	ld	a4,-1744(a4) # ffffffffc0206348 <error_string+0x38>
ffffffffc0201a20:	02e787b3          	mul	a5,a5,a4
ffffffffc0201a24:	00080737          	lui	a4,0x80
ffffffffc0201a28:	97ba                	add	a5,a5,a4
ffffffffc0201a2a:	07aa                	slli	a5,a5,0xa
ffffffffc0201a2c:	8cdd                	or	s1,s1,a5
ffffffffc0201a2e:	0014e493          	ori	s1,s1,1
ffffffffc0201a32:	0099b023          	sd	s1,0(s3)
ffffffffc0201a36:	12000073          	sfence.vma
ffffffffc0201a3a:	4501                	li	a0,0
ffffffffc0201a3c:	70a2                	ld	ra,40(sp)
ffffffffc0201a3e:	7402                	ld	s0,32(sp)
ffffffffc0201a40:	64e2                	ld	s1,24(sp)
ffffffffc0201a42:	6942                	ld	s2,16(sp)
ffffffffc0201a44:	69a2                	ld	s3,8(sp)
ffffffffc0201a46:	6a02                	ld	s4,0(sp)
ffffffffc0201a48:	6145                	addi	sp,sp,48
ffffffffc0201a4a:	8082                	ret
ffffffffc0201a4c:	078a                	slli	a5,a5,0x2
ffffffffc0201a4e:	83b1                	srli	a5,a5,0xc
ffffffffc0201a50:	00010717          	auipc	a4,0x10
ffffffffc0201a54:	ae873703          	ld	a4,-1304(a4) # ffffffffc0211538 <npage>
ffffffffc0201a58:	06e7fe63          	bgeu	a5,a4,ffffffffc0201ad4 <page_insert+0xfa>
ffffffffc0201a5c:	fff80737          	lui	a4,0xfff80
ffffffffc0201a60:	97ba                	add	a5,a5,a4
ffffffffc0201a62:	00010a17          	auipc	s4,0x10
ffffffffc0201a66:	adea0a13          	addi	s4,s4,-1314 # ffffffffc0211540 <pages>
ffffffffc0201a6a:	000a3703          	ld	a4,0(s4)
ffffffffc0201a6e:	00379913          	slli	s2,a5,0x3
ffffffffc0201a72:	993e                	add	s2,s2,a5
ffffffffc0201a74:	090e                	slli	s2,s2,0x3
ffffffffc0201a76:	993a                	add	s2,s2,a4
ffffffffc0201a78:	03240063          	beq	s0,s2,ffffffffc0201a98 <page_insert+0xbe>
ffffffffc0201a7c:	00092783          	lw	a5,0(s2)
ffffffffc0201a80:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a84:	00e92023          	sw	a4,0(s2)
ffffffffc0201a88:	cb11                	beqz	a4,ffffffffc0201a9c <page_insert+0xc2>
ffffffffc0201a8a:	0009b023          	sd	zero,0(s3)
ffffffffc0201a8e:	12000073          	sfence.vma
ffffffffc0201a92:	000a3703          	ld	a4,0(s4)
ffffffffc0201a96:	bfb5                	j	ffffffffc0201a12 <page_insert+0x38>
ffffffffc0201a98:	c014                	sw	a3,0(s0)
ffffffffc0201a9a:	bfa5                	j	ffffffffc0201a12 <page_insert+0x38>
ffffffffc0201a9c:	100027f3          	csrr	a5,sstatus
ffffffffc0201aa0:	8b89                	andi	a5,a5,2
ffffffffc0201aa2:	eb91                	bnez	a5,ffffffffc0201ab6 <page_insert+0xdc>
ffffffffc0201aa4:	00010797          	auipc	a5,0x10
ffffffffc0201aa8:	a747b783          	ld	a5,-1420(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc0201aac:	739c                	ld	a5,32(a5)
ffffffffc0201aae:	4585                	li	a1,1
ffffffffc0201ab0:	854a                	mv	a0,s2
ffffffffc0201ab2:	9782                	jalr	a5
ffffffffc0201ab4:	bfd9                	j	ffffffffc0201a8a <page_insert+0xb0>
ffffffffc0201ab6:	a27fe0ef          	jal	ra,ffffffffc02004dc <intr_disable>
ffffffffc0201aba:	00010797          	auipc	a5,0x10
ffffffffc0201abe:	a5e7b783          	ld	a5,-1442(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc0201ac2:	739c                	ld	a5,32(a5)
ffffffffc0201ac4:	4585                	li	a1,1
ffffffffc0201ac6:	854a                	mv	a0,s2
ffffffffc0201ac8:	9782                	jalr	a5
ffffffffc0201aca:	a0dfe0ef          	jal	ra,ffffffffc02004d6 <intr_enable>
ffffffffc0201ace:	bf75                	j	ffffffffc0201a8a <page_insert+0xb0>
ffffffffc0201ad0:	5571                	li	a0,-4
ffffffffc0201ad2:	b7ad                	j	ffffffffc0201a3c <page_insert+0x62>
ffffffffc0201ad4:	ac5ff0ef          	jal	ra,ffffffffc0201598 <pa2page.part.0>

ffffffffc0201ad8 <pmm_init>:
ffffffffc0201ad8:	00003797          	auipc	a5,0x3
ffffffffc0201adc:	6f878793          	addi	a5,a5,1784 # ffffffffc02051d0 <default_pmm_manager>
ffffffffc0201ae0:	638c                	ld	a1,0(a5)
ffffffffc0201ae2:	7159                	addi	sp,sp,-112
ffffffffc0201ae4:	f486                	sd	ra,104(sp)
ffffffffc0201ae6:	f0a2                	sd	s0,96(sp)
ffffffffc0201ae8:	eca6                	sd	s1,88(sp)
ffffffffc0201aea:	e8ca                	sd	s2,80(sp)
ffffffffc0201aec:	e4ce                	sd	s3,72(sp)
ffffffffc0201aee:	f85a                	sd	s6,48(sp)
ffffffffc0201af0:	f45e                	sd	s7,40(sp)
ffffffffc0201af2:	e0d2                	sd	s4,64(sp)
ffffffffc0201af4:	fc56                	sd	s5,56(sp)
ffffffffc0201af6:	f062                	sd	s8,32(sp)
ffffffffc0201af8:	ec66                	sd	s9,24(sp)
ffffffffc0201afa:	00010b97          	auipc	s7,0x10
ffffffffc0201afe:	a1eb8b93          	addi	s7,s7,-1506 # ffffffffc0211518 <pmm_manager>
ffffffffc0201b02:	00003517          	auipc	a0,0x3
ffffffffc0201b06:	7c650513          	addi	a0,a0,1990 # ffffffffc02052c8 <default_pmm_manager+0xf8>
ffffffffc0201b0a:	00fbb023          	sd	a5,0(s7)
ffffffffc0201b0e:	dacfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0201b12:	000bb783          	ld	a5,0(s7)
ffffffffc0201b16:	4445                	li	s0,17
ffffffffc0201b18:	40100913          	li	s2,1025
ffffffffc0201b1c:	679c                	ld	a5,8(a5)
ffffffffc0201b1e:	00010997          	auipc	s3,0x10
ffffffffc0201b22:	a1298993          	addi	s3,s3,-1518 # ffffffffc0211530 <va_pa_offset>
ffffffffc0201b26:	00010497          	auipc	s1,0x10
ffffffffc0201b2a:	a1248493          	addi	s1,s1,-1518 # ffffffffc0211538 <npage>
ffffffffc0201b2e:	9782                	jalr	a5
ffffffffc0201b30:	57f5                	li	a5,-3
ffffffffc0201b32:	07fa                	slli	a5,a5,0x1e
ffffffffc0201b34:	01b41613          	slli	a2,s0,0x1b
ffffffffc0201b38:	01591593          	slli	a1,s2,0x15
ffffffffc0201b3c:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b40:	00003517          	auipc	a0,0x3
ffffffffc0201b44:	7a050513          	addi	a0,a0,1952 # ffffffffc02052e0 <default_pmm_manager+0x110>
ffffffffc0201b48:	00f9b023          	sd	a5,0(s3)
ffffffffc0201b4c:	d6efe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0201b50:	00003517          	auipc	a0,0x3
ffffffffc0201b54:	7c050513          	addi	a0,a0,1984 # ffffffffc0205310 <default_pmm_manager+0x140>
ffffffffc0201b58:	d62fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0201b5c:	01b41693          	slli	a3,s0,0x1b
ffffffffc0201b60:	16fd                	addi	a3,a3,-1
ffffffffc0201b62:	01591613          	slli	a2,s2,0x15
ffffffffc0201b66:	07e005b7          	lui	a1,0x7e00
ffffffffc0201b6a:	00003517          	auipc	a0,0x3
ffffffffc0201b6e:	7be50513          	addi	a0,a0,1982 # ffffffffc0205328 <default_pmm_manager+0x158>
ffffffffc0201b72:	d48fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0201b76:	777d                	lui	a4,0xfffff
ffffffffc0201b78:	00011797          	auipc	a5,0x11
ffffffffc0201b7c:	9ff78793          	addi	a5,a5,-1537 # ffffffffc0212577 <end+0xfff>
ffffffffc0201b80:	8ff9                	and	a5,a5,a4
ffffffffc0201b82:	00010b17          	auipc	s6,0x10
ffffffffc0201b86:	9beb0b13          	addi	s6,s6,-1602 # ffffffffc0211540 <pages>
ffffffffc0201b8a:	00088737          	lui	a4,0x88
ffffffffc0201b8e:	e098                	sd	a4,0(s1)
ffffffffc0201b90:	00fb3023          	sd	a5,0(s6)
ffffffffc0201b94:	4705                	li	a4,1
ffffffffc0201b96:	07a1                	addi	a5,a5,8
ffffffffc0201b98:	40e7b02f          	amoor.d	zero,a4,(a5)
ffffffffc0201b9c:	04800693          	li	a3,72
ffffffffc0201ba0:	4505                	li	a0,1
ffffffffc0201ba2:	fff805b7          	lui	a1,0xfff80
ffffffffc0201ba6:	000b3783          	ld	a5,0(s6)
ffffffffc0201baa:	97b6                	add	a5,a5,a3
ffffffffc0201bac:	07a1                	addi	a5,a5,8
ffffffffc0201bae:	40a7b02f          	amoor.d	zero,a0,(a5)
ffffffffc0201bb2:	609c                	ld	a5,0(s1)
ffffffffc0201bb4:	0705                	addi	a4,a4,1
ffffffffc0201bb6:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc0201bba:	00b78633          	add	a2,a5,a1
ffffffffc0201bbe:	fec764e3          	bltu	a4,a2,ffffffffc0201ba6 <pmm_init+0xce>
ffffffffc0201bc2:	000b3503          	ld	a0,0(s6)
ffffffffc0201bc6:	00379693          	slli	a3,a5,0x3
ffffffffc0201bca:	96be                	add	a3,a3,a5
ffffffffc0201bcc:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201bd0:	972a                	add	a4,a4,a0
ffffffffc0201bd2:	068e                	slli	a3,a3,0x3
ffffffffc0201bd4:	96ba                	add	a3,a3,a4
ffffffffc0201bd6:	c0200737          	lui	a4,0xc0200
ffffffffc0201bda:	62e6ee63          	bltu	a3,a4,ffffffffc0202216 <pmm_init+0x73e>
ffffffffc0201bde:	0009b703          	ld	a4,0(s3)
ffffffffc0201be2:	4645                	li	a2,17
ffffffffc0201be4:	066e                	slli	a2,a2,0x1b
ffffffffc0201be6:	8e99                	sub	a3,a3,a4
ffffffffc0201be8:	4cc6ec63          	bltu	a3,a2,ffffffffc02020c0 <pmm_init+0x5e8>
ffffffffc0201bec:	000bb783          	ld	a5,0(s7)
ffffffffc0201bf0:	00010917          	auipc	s2,0x10
ffffffffc0201bf4:	93890913          	addi	s2,s2,-1736 # ffffffffc0211528 <boot_pgdir>
ffffffffc0201bf8:	7b9c                	ld	a5,48(a5)
ffffffffc0201bfa:	9782                	jalr	a5
ffffffffc0201bfc:	00003517          	auipc	a0,0x3
ffffffffc0201c00:	77c50513          	addi	a0,a0,1916 # ffffffffc0205378 <default_pmm_manager+0x1a8>
ffffffffc0201c04:	cb6fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0201c08:	00007697          	auipc	a3,0x7
ffffffffc0201c0c:	3f868693          	addi	a3,a3,1016 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201c10:	00d93023          	sd	a3,0(s2)
ffffffffc0201c14:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c18:	60f6eb63          	bltu	a3,a5,ffffffffc020222e <pmm_init+0x756>
ffffffffc0201c1c:	0009b783          	ld	a5,0(s3)
ffffffffc0201c20:	8e9d                	sub	a3,a3,a5
ffffffffc0201c22:	00010797          	auipc	a5,0x10
ffffffffc0201c26:	8ed7bf23          	sd	a3,-1794(a5) # ffffffffc0211520 <boot_cr3>
ffffffffc0201c2a:	100027f3          	csrr	a5,sstatus
ffffffffc0201c2e:	8b89                	andi	a5,a5,2
ffffffffc0201c30:	4c079163          	bnez	a5,ffffffffc02020f2 <pmm_init+0x61a>
ffffffffc0201c34:	000bb783          	ld	a5,0(s7)
ffffffffc0201c38:	779c                	ld	a5,40(a5)
ffffffffc0201c3a:	9782                	jalr	a5
ffffffffc0201c3c:	842a                	mv	s0,a0
ffffffffc0201c3e:	6098                	ld	a4,0(s1)
ffffffffc0201c40:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c44:	83b1                	srli	a5,a5,0xc
ffffffffc0201c46:	62e7e063          	bltu	a5,a4,ffffffffc0202266 <pmm_init+0x78e>
ffffffffc0201c4a:	00093503          	ld	a0,0(s2)
ffffffffc0201c4e:	5e050c63          	beqz	a0,ffffffffc0202246 <pmm_init+0x76e>
ffffffffc0201c52:	03451793          	slli	a5,a0,0x34
ffffffffc0201c56:	5e079863          	bnez	a5,ffffffffc0202246 <pmm_init+0x76e>
ffffffffc0201c5a:	4601                	li	a2,0
ffffffffc0201c5c:	4581                	li	a1,0
ffffffffc0201c5e:	c89ff0ef          	jal	ra,ffffffffc02018e6 <get_page>
ffffffffc0201c62:	66051463          	bnez	a0,ffffffffc02022ca <pmm_init+0x7f2>
ffffffffc0201c66:	4505                	li	a0,1
ffffffffc0201c68:	969ff0ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0201c6c:	8a2a                	mv	s4,a0
ffffffffc0201c6e:	00093503          	ld	a0,0(s2)
ffffffffc0201c72:	4681                	li	a3,0
ffffffffc0201c74:	4601                	li	a2,0
ffffffffc0201c76:	85d2                	mv	a1,s4
ffffffffc0201c78:	d63ff0ef          	jal	ra,ffffffffc02019da <page_insert>
ffffffffc0201c7c:	62051763          	bnez	a0,ffffffffc02022aa <pmm_init+0x7d2>
ffffffffc0201c80:	00093503          	ld	a0,0(s2)
ffffffffc0201c84:	4601                	li	a2,0
ffffffffc0201c86:	4581                	li	a1,0
ffffffffc0201c88:	a6bff0ef          	jal	ra,ffffffffc02016f2 <get_pte>
ffffffffc0201c8c:	5e050f63          	beqz	a0,ffffffffc020228a <pmm_init+0x7b2>
ffffffffc0201c90:	611c                	ld	a5,0(a0)
ffffffffc0201c92:	0017f713          	andi	a4,a5,1
ffffffffc0201c96:	5e070863          	beqz	a4,ffffffffc0202286 <pmm_init+0x7ae>
ffffffffc0201c9a:	6090                	ld	a2,0(s1)
ffffffffc0201c9c:	078a                	slli	a5,a5,0x2
ffffffffc0201c9e:	83b1                	srli	a5,a5,0xc
ffffffffc0201ca0:	56c7f963          	bgeu	a5,a2,ffffffffc0202212 <pmm_init+0x73a>
ffffffffc0201ca4:	fff80737          	lui	a4,0xfff80
ffffffffc0201ca8:	97ba                	add	a5,a5,a4
ffffffffc0201caa:	000b3683          	ld	a3,0(s6)
ffffffffc0201cae:	00379713          	slli	a4,a5,0x3
ffffffffc0201cb2:	97ba                	add	a5,a5,a4
ffffffffc0201cb4:	078e                	slli	a5,a5,0x3
ffffffffc0201cb6:	97b6                	add	a5,a5,a3
ffffffffc0201cb8:	14fa12e3          	bne	s4,a5,ffffffffc02025fc <pmm_init+0xb24>
ffffffffc0201cbc:	000a2703          	lw	a4,0(s4)
ffffffffc0201cc0:	4785                	li	a5,1
ffffffffc0201cc2:	16f719e3          	bne	a4,a5,ffffffffc0202634 <pmm_init+0xb5c>
ffffffffc0201cc6:	00093503          	ld	a0,0(s2)
ffffffffc0201cca:	77fd                	lui	a5,0xfffff
ffffffffc0201ccc:	6114                	ld	a3,0(a0)
ffffffffc0201cce:	068a                	slli	a3,a3,0x2
ffffffffc0201cd0:	8efd                	and	a3,a3,a5
ffffffffc0201cd2:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201cd6:	14c773e3          	bgeu	a4,a2,ffffffffc020261c <pmm_init+0xb44>
ffffffffc0201cda:	0009bc03          	ld	s8,0(s3)
ffffffffc0201cde:	96e2                	add	a3,a3,s8
ffffffffc0201ce0:	0006ba83          	ld	s5,0(a3)
ffffffffc0201ce4:	0a8a                	slli	s5,s5,0x2
ffffffffc0201ce6:	00fafab3          	and	s5,s5,a5
ffffffffc0201cea:	00cad793          	srli	a5,s5,0xc
ffffffffc0201cee:	64c7fe63          	bgeu	a5,a2,ffffffffc020234a <pmm_init+0x872>
ffffffffc0201cf2:	4601                	li	a2,0
ffffffffc0201cf4:	6585                	lui	a1,0x1
ffffffffc0201cf6:	9c56                	add	s8,s8,s5
ffffffffc0201cf8:	9fbff0ef          	jal	ra,ffffffffc02016f2 <get_pte>
ffffffffc0201cfc:	0c21                	addi	s8,s8,8
ffffffffc0201cfe:	63851663          	bne	a0,s8,ffffffffc020232a <pmm_init+0x852>
ffffffffc0201d02:	4505                	li	a0,1
ffffffffc0201d04:	8cdff0ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0201d08:	8aaa                	mv	s5,a0
ffffffffc0201d0a:	00093503          	ld	a0,0(s2)
ffffffffc0201d0e:	46d1                	li	a3,20
ffffffffc0201d10:	6605                	lui	a2,0x1
ffffffffc0201d12:	85d6                	mv	a1,s5
ffffffffc0201d14:	cc7ff0ef          	jal	ra,ffffffffc02019da <page_insert>
ffffffffc0201d18:	5c051963          	bnez	a0,ffffffffc02022ea <pmm_init+0x812>
ffffffffc0201d1c:	00093503          	ld	a0,0(s2)
ffffffffc0201d20:	4601                	li	a2,0
ffffffffc0201d22:	6585                	lui	a1,0x1
ffffffffc0201d24:	9cfff0ef          	jal	ra,ffffffffc02016f2 <get_pte>
ffffffffc0201d28:	120506e3          	beqz	a0,ffffffffc0202654 <pmm_init+0xb7c>
ffffffffc0201d2c:	611c                	ld	a5,0(a0)
ffffffffc0201d2e:	0107f713          	andi	a4,a5,16
ffffffffc0201d32:	72070963          	beqz	a4,ffffffffc0202464 <pmm_init+0x98c>
ffffffffc0201d36:	8b91                	andi	a5,a5,4
ffffffffc0201d38:	6e078663          	beqz	a5,ffffffffc0202424 <pmm_init+0x94c>
ffffffffc0201d3c:	00093503          	ld	a0,0(s2)
ffffffffc0201d40:	611c                	ld	a5,0(a0)
ffffffffc0201d42:	8bc1                	andi	a5,a5,16
ffffffffc0201d44:	6c078063          	beqz	a5,ffffffffc0202404 <pmm_init+0x92c>
ffffffffc0201d48:	000aa703          	lw	a4,0(s5)
ffffffffc0201d4c:	4785                	li	a5,1
ffffffffc0201d4e:	5af71e63          	bne	a4,a5,ffffffffc020230a <pmm_init+0x832>
ffffffffc0201d52:	4681                	li	a3,0
ffffffffc0201d54:	6605                	lui	a2,0x1
ffffffffc0201d56:	85d2                	mv	a1,s4
ffffffffc0201d58:	c83ff0ef          	jal	ra,ffffffffc02019da <page_insert>
ffffffffc0201d5c:	66051463          	bnez	a0,ffffffffc02023c4 <pmm_init+0x8ec>
ffffffffc0201d60:	000a2703          	lw	a4,0(s4)
ffffffffc0201d64:	4789                	li	a5,2
ffffffffc0201d66:	62f71f63          	bne	a4,a5,ffffffffc02023a4 <pmm_init+0x8cc>
ffffffffc0201d6a:	000aa783          	lw	a5,0(s5)
ffffffffc0201d6e:	60079b63          	bnez	a5,ffffffffc0202384 <pmm_init+0x8ac>
ffffffffc0201d72:	00093503          	ld	a0,0(s2)
ffffffffc0201d76:	4601                	li	a2,0
ffffffffc0201d78:	6585                	lui	a1,0x1
ffffffffc0201d7a:	979ff0ef          	jal	ra,ffffffffc02016f2 <get_pte>
ffffffffc0201d7e:	5e050363          	beqz	a0,ffffffffc0202364 <pmm_init+0x88c>
ffffffffc0201d82:	6118                	ld	a4,0(a0)
ffffffffc0201d84:	00177793          	andi	a5,a4,1
ffffffffc0201d88:	4e078f63          	beqz	a5,ffffffffc0202286 <pmm_init+0x7ae>
ffffffffc0201d8c:	6094                	ld	a3,0(s1)
ffffffffc0201d8e:	00271793          	slli	a5,a4,0x2
ffffffffc0201d92:	83b1                	srli	a5,a5,0xc
ffffffffc0201d94:	46d7ff63          	bgeu	a5,a3,ffffffffc0202212 <pmm_init+0x73a>
ffffffffc0201d98:	fff806b7          	lui	a3,0xfff80
ffffffffc0201d9c:	97b6                	add	a5,a5,a3
ffffffffc0201d9e:	000b3603          	ld	a2,0(s6)
ffffffffc0201da2:	00379693          	slli	a3,a5,0x3
ffffffffc0201da6:	97b6                	add	a5,a5,a3
ffffffffc0201da8:	078e                	slli	a5,a5,0x3
ffffffffc0201daa:	97b2                	add	a5,a5,a2
ffffffffc0201dac:	70fa1c63          	bne	s4,a5,ffffffffc02024c4 <pmm_init+0x9ec>
ffffffffc0201db0:	8b41                	andi	a4,a4,16
ffffffffc0201db2:	6e071963          	bnez	a4,ffffffffc02024a4 <pmm_init+0x9cc>
ffffffffc0201db6:	00093503          	ld	a0,0(s2)
ffffffffc0201dba:	4581                	li	a1,0
ffffffffc0201dbc:	b85ff0ef          	jal	ra,ffffffffc0201940 <page_remove>
ffffffffc0201dc0:	000a2703          	lw	a4,0(s4)
ffffffffc0201dc4:	4785                	li	a5,1
ffffffffc0201dc6:	6af71f63          	bne	a4,a5,ffffffffc0202484 <pmm_init+0x9ac>
ffffffffc0201dca:	000aa783          	lw	a5,0(s5)
ffffffffc0201dce:	78079763          	bnez	a5,ffffffffc020255c <pmm_init+0xa84>
ffffffffc0201dd2:	00093503          	ld	a0,0(s2)
ffffffffc0201dd6:	6585                	lui	a1,0x1
ffffffffc0201dd8:	b69ff0ef          	jal	ra,ffffffffc0201940 <page_remove>
ffffffffc0201ddc:	000a2783          	lw	a5,0(s4)
ffffffffc0201de0:	74079e63          	bnez	a5,ffffffffc020253c <pmm_init+0xa64>
ffffffffc0201de4:	000aa783          	lw	a5,0(s5)
ffffffffc0201de8:	72079a63          	bnez	a5,ffffffffc020251c <pmm_init+0xa44>
ffffffffc0201dec:	00093a03          	ld	s4,0(s2)
ffffffffc0201df0:	6090                	ld	a2,0(s1)
ffffffffc0201df2:	000a3703          	ld	a4,0(s4)
ffffffffc0201df6:	070a                	slli	a4,a4,0x2
ffffffffc0201df8:	8331                	srli	a4,a4,0xc
ffffffffc0201dfa:	40c77c63          	bgeu	a4,a2,ffffffffc0202212 <pmm_init+0x73a>
ffffffffc0201dfe:	fff807b7          	lui	a5,0xfff80
ffffffffc0201e02:	973e                	add	a4,a4,a5
ffffffffc0201e04:	00371793          	slli	a5,a4,0x3
ffffffffc0201e08:	000b3503          	ld	a0,0(s6)
ffffffffc0201e0c:	97ba                	add	a5,a5,a4
ffffffffc0201e0e:	078e                	slli	a5,a5,0x3
ffffffffc0201e10:	00f50733          	add	a4,a0,a5
ffffffffc0201e14:	4314                	lw	a3,0(a4)
ffffffffc0201e16:	4705                	li	a4,1
ffffffffc0201e18:	6ee69263          	bne	a3,a4,ffffffffc02024fc <pmm_init+0xa24>
ffffffffc0201e1c:	878d                	srai	a5,a5,0x3
ffffffffc0201e1e:	00004c97          	auipc	s9,0x4
ffffffffc0201e22:	52acbc83          	ld	s9,1322(s9) # ffffffffc0206348 <error_string+0x38>
ffffffffc0201e26:	039787b3          	mul	a5,a5,s9
ffffffffc0201e2a:	00080737          	lui	a4,0x80
ffffffffc0201e2e:	97ba                	add	a5,a5,a4
ffffffffc0201e30:	00c79693          	slli	a3,a5,0xc
ffffffffc0201e34:	6ac7f863          	bgeu	a5,a2,ffffffffc02024e4 <pmm_init+0xa0c>
ffffffffc0201e38:	0009b783          	ld	a5,0(s3)
ffffffffc0201e3c:	97b6                	add	a5,a5,a3
ffffffffc0201e3e:	639c                	ld	a5,0(a5)
ffffffffc0201e40:	078a                	slli	a5,a5,0x2
ffffffffc0201e42:	83b1                	srli	a5,a5,0xc
ffffffffc0201e44:	3cc7f763          	bgeu	a5,a2,ffffffffc0202212 <pmm_init+0x73a>
ffffffffc0201e48:	8f99                	sub	a5,a5,a4
ffffffffc0201e4a:	00379713          	slli	a4,a5,0x3
ffffffffc0201e4e:	97ba                	add	a5,a5,a4
ffffffffc0201e50:	078e                	slli	a5,a5,0x3
ffffffffc0201e52:	953e                	add	a0,a0,a5
ffffffffc0201e54:	100027f3          	csrr	a5,sstatus
ffffffffc0201e58:	8b89                	andi	a5,a5,2
ffffffffc0201e5a:	2e079663          	bnez	a5,ffffffffc0202146 <pmm_init+0x66e>
ffffffffc0201e5e:	000bb783          	ld	a5,0(s7)
ffffffffc0201e62:	4585                	li	a1,1
ffffffffc0201e64:	739c                	ld	a5,32(a5)
ffffffffc0201e66:	9782                	jalr	a5
ffffffffc0201e68:	000a3783          	ld	a5,0(s4)
ffffffffc0201e6c:	6098                	ld	a4,0(s1)
ffffffffc0201e6e:	078a                	slli	a5,a5,0x2
ffffffffc0201e70:	83b1                	srli	a5,a5,0xc
ffffffffc0201e72:	3ae7f063          	bgeu	a5,a4,ffffffffc0202212 <pmm_init+0x73a>
ffffffffc0201e76:	fff80737          	lui	a4,0xfff80
ffffffffc0201e7a:	97ba                	add	a5,a5,a4
ffffffffc0201e7c:	000b3503          	ld	a0,0(s6)
ffffffffc0201e80:	00379713          	slli	a4,a5,0x3
ffffffffc0201e84:	97ba                	add	a5,a5,a4
ffffffffc0201e86:	078e                	slli	a5,a5,0x3
ffffffffc0201e88:	953e                	add	a0,a0,a5
ffffffffc0201e8a:	100027f3          	csrr	a5,sstatus
ffffffffc0201e8e:	8b89                	andi	a5,a5,2
ffffffffc0201e90:	28079f63          	bnez	a5,ffffffffc020212e <pmm_init+0x656>
ffffffffc0201e94:	000bb783          	ld	a5,0(s7)
ffffffffc0201e98:	4585                	li	a1,1
ffffffffc0201e9a:	739c                	ld	a5,32(a5)
ffffffffc0201e9c:	9782                	jalr	a5
ffffffffc0201e9e:	00093783          	ld	a5,0(s2)
ffffffffc0201ea2:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fd6ea88>
ffffffffc0201ea6:	100027f3          	csrr	a5,sstatus
ffffffffc0201eaa:	8b89                	andi	a5,a5,2
ffffffffc0201eac:	26079763          	bnez	a5,ffffffffc020211a <pmm_init+0x642>
ffffffffc0201eb0:	000bb783          	ld	a5,0(s7)
ffffffffc0201eb4:	779c                	ld	a5,40(a5)
ffffffffc0201eb6:	9782                	jalr	a5
ffffffffc0201eb8:	8a2a                	mv	s4,a0
ffffffffc0201eba:	73441163          	bne	s0,s4,ffffffffc02025dc <pmm_init+0xb04>
ffffffffc0201ebe:	00003517          	auipc	a0,0x3
ffffffffc0201ec2:	7aa50513          	addi	a0,a0,1962 # ffffffffc0205668 <default_pmm_manager+0x498>
ffffffffc0201ec6:	9f4fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0201eca:	100027f3          	csrr	a5,sstatus
ffffffffc0201ece:	8b89                	andi	a5,a5,2
ffffffffc0201ed0:	22079b63          	bnez	a5,ffffffffc0202106 <pmm_init+0x62e>
ffffffffc0201ed4:	000bb783          	ld	a5,0(s7)
ffffffffc0201ed8:	779c                	ld	a5,40(a5)
ffffffffc0201eda:	9782                	jalr	a5
ffffffffc0201edc:	8c2a                	mv	s8,a0
ffffffffc0201ede:	6098                	ld	a4,0(s1)
ffffffffc0201ee0:	c0200437          	lui	s0,0xc0200
ffffffffc0201ee4:	7afd                	lui	s5,0xfffff
ffffffffc0201ee6:	00c71793          	slli	a5,a4,0xc
ffffffffc0201eea:	6a05                	lui	s4,0x1
ffffffffc0201eec:	02f47c63          	bgeu	s0,a5,ffffffffc0201f24 <pmm_init+0x44c>
ffffffffc0201ef0:	00c45793          	srli	a5,s0,0xc
ffffffffc0201ef4:	00093503          	ld	a0,0(s2)
ffffffffc0201ef8:	30e7f063          	bgeu	a5,a4,ffffffffc02021f8 <pmm_init+0x720>
ffffffffc0201efc:	0009b583          	ld	a1,0(s3)
ffffffffc0201f00:	4601                	li	a2,0
ffffffffc0201f02:	95a2                	add	a1,a1,s0
ffffffffc0201f04:	feeff0ef          	jal	ra,ffffffffc02016f2 <get_pte>
ffffffffc0201f08:	2c050863          	beqz	a0,ffffffffc02021d8 <pmm_init+0x700>
ffffffffc0201f0c:	611c                	ld	a5,0(a0)
ffffffffc0201f0e:	078a                	slli	a5,a5,0x2
ffffffffc0201f10:	0157f7b3          	and	a5,a5,s5
ffffffffc0201f14:	2a879263          	bne	a5,s0,ffffffffc02021b8 <pmm_init+0x6e0>
ffffffffc0201f18:	6098                	ld	a4,0(s1)
ffffffffc0201f1a:	9452                	add	s0,s0,s4
ffffffffc0201f1c:	00c71793          	slli	a5,a4,0xc
ffffffffc0201f20:	fcf468e3          	bltu	s0,a5,ffffffffc0201ef0 <pmm_init+0x418>
ffffffffc0201f24:	00093783          	ld	a5,0(s2)
ffffffffc0201f28:	639c                	ld	a5,0(a5)
ffffffffc0201f2a:	68079963          	bnez	a5,ffffffffc02025bc <pmm_init+0xae4>
ffffffffc0201f2e:	4505                	li	a0,1
ffffffffc0201f30:	ea0ff0ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0201f34:	842a                	mv	s0,a0
ffffffffc0201f36:	00093503          	ld	a0,0(s2)
ffffffffc0201f3a:	4699                	li	a3,6
ffffffffc0201f3c:	10000613          	li	a2,256
ffffffffc0201f40:	85a2                	mv	a1,s0
ffffffffc0201f42:	a99ff0ef          	jal	ra,ffffffffc02019da <page_insert>
ffffffffc0201f46:	64051b63          	bnez	a0,ffffffffc020259c <pmm_init+0xac4>
ffffffffc0201f4a:	4018                	lw	a4,0(s0)
ffffffffc0201f4c:	4785                	li	a5,1
ffffffffc0201f4e:	62f71763          	bne	a4,a5,ffffffffc020257c <pmm_init+0xaa4>
ffffffffc0201f52:	00093503          	ld	a0,0(s2)
ffffffffc0201f56:	6a05                	lui	s4,0x1
ffffffffc0201f58:	4699                	li	a3,6
ffffffffc0201f5a:	100a0613          	addi	a2,s4,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0201f5e:	85a2                	mv	a1,s0
ffffffffc0201f60:	a7bff0ef          	jal	ra,ffffffffc02019da <page_insert>
ffffffffc0201f64:	48051063          	bnez	a0,ffffffffc02023e4 <pmm_init+0x90c>
ffffffffc0201f68:	4018                	lw	a4,0(s0)
ffffffffc0201f6a:	4789                	li	a5,2
ffffffffc0201f6c:	74f71463          	bne	a4,a5,ffffffffc02026b4 <pmm_init+0xbdc>
ffffffffc0201f70:	00004597          	auipc	a1,0x4
ffffffffc0201f74:	83058593          	addi	a1,a1,-2000 # ffffffffc02057a0 <default_pmm_manager+0x5d0>
ffffffffc0201f78:	10000513          	li	a0,256
ffffffffc0201f7c:	488020ef          	jal	ra,ffffffffc0204404 <strcpy>
ffffffffc0201f80:	100a0593          	addi	a1,s4,256
ffffffffc0201f84:	10000513          	li	a0,256
ffffffffc0201f88:	48e020ef          	jal	ra,ffffffffc0204416 <strcmp>
ffffffffc0201f8c:	70051463          	bnez	a0,ffffffffc0202694 <pmm_init+0xbbc>
ffffffffc0201f90:	000b3683          	ld	a3,0(s6)
ffffffffc0201f94:	00080ab7          	lui	s5,0x80
ffffffffc0201f98:	6098                	ld	a4,0(s1)
ffffffffc0201f9a:	40d406b3          	sub	a3,s0,a3
ffffffffc0201f9e:	868d                	srai	a3,a3,0x3
ffffffffc0201fa0:	039686b3          	mul	a3,a3,s9
ffffffffc0201fa4:	96d6                	add	a3,a3,s5
ffffffffc0201fa6:	00c69793          	slli	a5,a3,0xc
ffffffffc0201faa:	83b1                	srli	a5,a5,0xc
ffffffffc0201fac:	06b2                	slli	a3,a3,0xc
ffffffffc0201fae:	52e7fb63          	bgeu	a5,a4,ffffffffc02024e4 <pmm_init+0xa0c>
ffffffffc0201fb2:	0009b783          	ld	a5,0(s3)
ffffffffc0201fb6:	10000513          	li	a0,256
ffffffffc0201fba:	97b6                	add	a5,a5,a3
ffffffffc0201fbc:	10078023          	sb	zero,256(a5)
ffffffffc0201fc0:	40e020ef          	jal	ra,ffffffffc02043ce <strlen>
ffffffffc0201fc4:	6a051863          	bnez	a0,ffffffffc0202674 <pmm_init+0xb9c>
ffffffffc0201fc8:	00093a03          	ld	s4,0(s2)
ffffffffc0201fcc:	6090                	ld	a2,0(s1)
ffffffffc0201fce:	000a3783          	ld	a5,0(s4)
ffffffffc0201fd2:	078a                	slli	a5,a5,0x2
ffffffffc0201fd4:	83b1                	srli	a5,a5,0xc
ffffffffc0201fd6:	22c7fe63          	bgeu	a5,a2,ffffffffc0202212 <pmm_init+0x73a>
ffffffffc0201fda:	415787b3          	sub	a5,a5,s5
ffffffffc0201fde:	00379713          	slli	a4,a5,0x3
ffffffffc0201fe2:	97ba                	add	a5,a5,a4
ffffffffc0201fe4:	039787b3          	mul	a5,a5,s9
ffffffffc0201fe8:	97d6                	add	a5,a5,s5
ffffffffc0201fea:	00c79693          	slli	a3,a5,0xc
ffffffffc0201fee:	4ec7fb63          	bgeu	a5,a2,ffffffffc02024e4 <pmm_init+0xa0c>
ffffffffc0201ff2:	0009b783          	ld	a5,0(s3)
ffffffffc0201ff6:	00f689b3          	add	s3,a3,a5
ffffffffc0201ffa:	100027f3          	csrr	a5,sstatus
ffffffffc0201ffe:	8b89                	andi	a5,a5,2
ffffffffc0202000:	1a079163          	bnez	a5,ffffffffc02021a2 <pmm_init+0x6ca>
ffffffffc0202004:	000bb783          	ld	a5,0(s7)
ffffffffc0202008:	4585                	li	a1,1
ffffffffc020200a:	8522                	mv	a0,s0
ffffffffc020200c:	739c                	ld	a5,32(a5)
ffffffffc020200e:	9782                	jalr	a5
ffffffffc0202010:	0009b783          	ld	a5,0(s3)
ffffffffc0202014:	6098                	ld	a4,0(s1)
ffffffffc0202016:	078a                	slli	a5,a5,0x2
ffffffffc0202018:	83b1                	srli	a5,a5,0xc
ffffffffc020201a:	1ee7fc63          	bgeu	a5,a4,ffffffffc0202212 <pmm_init+0x73a>
ffffffffc020201e:	fff80737          	lui	a4,0xfff80
ffffffffc0202022:	97ba                	add	a5,a5,a4
ffffffffc0202024:	000b3503          	ld	a0,0(s6)
ffffffffc0202028:	00379713          	slli	a4,a5,0x3
ffffffffc020202c:	97ba                	add	a5,a5,a4
ffffffffc020202e:	078e                	slli	a5,a5,0x3
ffffffffc0202030:	953e                	add	a0,a0,a5
ffffffffc0202032:	100027f3          	csrr	a5,sstatus
ffffffffc0202036:	8b89                	andi	a5,a5,2
ffffffffc0202038:	14079963          	bnez	a5,ffffffffc020218a <pmm_init+0x6b2>
ffffffffc020203c:	000bb783          	ld	a5,0(s7)
ffffffffc0202040:	4585                	li	a1,1
ffffffffc0202042:	739c                	ld	a5,32(a5)
ffffffffc0202044:	9782                	jalr	a5
ffffffffc0202046:	000a3783          	ld	a5,0(s4)
ffffffffc020204a:	6098                	ld	a4,0(s1)
ffffffffc020204c:	078a                	slli	a5,a5,0x2
ffffffffc020204e:	83b1                	srli	a5,a5,0xc
ffffffffc0202050:	1ce7f163          	bgeu	a5,a4,ffffffffc0202212 <pmm_init+0x73a>
ffffffffc0202054:	fff80737          	lui	a4,0xfff80
ffffffffc0202058:	97ba                	add	a5,a5,a4
ffffffffc020205a:	000b3503          	ld	a0,0(s6)
ffffffffc020205e:	00379713          	slli	a4,a5,0x3
ffffffffc0202062:	97ba                	add	a5,a5,a4
ffffffffc0202064:	078e                	slli	a5,a5,0x3
ffffffffc0202066:	953e                	add	a0,a0,a5
ffffffffc0202068:	100027f3          	csrr	a5,sstatus
ffffffffc020206c:	8b89                	andi	a5,a5,2
ffffffffc020206e:	10079263          	bnez	a5,ffffffffc0202172 <pmm_init+0x69a>
ffffffffc0202072:	000bb783          	ld	a5,0(s7)
ffffffffc0202076:	4585                	li	a1,1
ffffffffc0202078:	739c                	ld	a5,32(a5)
ffffffffc020207a:	9782                	jalr	a5
ffffffffc020207c:	00093783          	ld	a5,0(s2)
ffffffffc0202080:	0007b023          	sd	zero,0(a5)
ffffffffc0202084:	100027f3          	csrr	a5,sstatus
ffffffffc0202088:	8b89                	andi	a5,a5,2
ffffffffc020208a:	0c079a63          	bnez	a5,ffffffffc020215e <pmm_init+0x686>
ffffffffc020208e:	000bb783          	ld	a5,0(s7)
ffffffffc0202092:	779c                	ld	a5,40(a5)
ffffffffc0202094:	9782                	jalr	a5
ffffffffc0202096:	842a                	mv	s0,a0
ffffffffc0202098:	3a8c1663          	bne	s8,s0,ffffffffc0202444 <pmm_init+0x96c>
ffffffffc020209c:	7406                	ld	s0,96(sp)
ffffffffc020209e:	70a6                	ld	ra,104(sp)
ffffffffc02020a0:	64e6                	ld	s1,88(sp)
ffffffffc02020a2:	6946                	ld	s2,80(sp)
ffffffffc02020a4:	69a6                	ld	s3,72(sp)
ffffffffc02020a6:	6a06                	ld	s4,64(sp)
ffffffffc02020a8:	7ae2                	ld	s5,56(sp)
ffffffffc02020aa:	7b42                	ld	s6,48(sp)
ffffffffc02020ac:	7ba2                	ld	s7,40(sp)
ffffffffc02020ae:	7c02                	ld	s8,32(sp)
ffffffffc02020b0:	6ce2                	ld	s9,24(sp)
ffffffffc02020b2:	00003517          	auipc	a0,0x3
ffffffffc02020b6:	76650513          	addi	a0,a0,1894 # ffffffffc0205818 <default_pmm_manager+0x648>
ffffffffc02020ba:	6165                	addi	sp,sp,112
ffffffffc02020bc:	ffffd06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02020c0:	6705                	lui	a4,0x1
ffffffffc02020c2:	177d                	addi	a4,a4,-1
ffffffffc02020c4:	96ba                	add	a3,a3,a4
ffffffffc02020c6:	777d                	lui	a4,0xfffff
ffffffffc02020c8:	8f75                	and	a4,a4,a3
ffffffffc02020ca:	00c75693          	srli	a3,a4,0xc
ffffffffc02020ce:	14f6f263          	bgeu	a3,a5,ffffffffc0202212 <pmm_init+0x73a>
ffffffffc02020d2:	000bb583          	ld	a1,0(s7)
ffffffffc02020d6:	fff807b7          	lui	a5,0xfff80
ffffffffc02020da:	96be                	add	a3,a3,a5
ffffffffc02020dc:	00369793          	slli	a5,a3,0x3
ffffffffc02020e0:	97b6                	add	a5,a5,a3
ffffffffc02020e2:	6994                	ld	a3,16(a1)
ffffffffc02020e4:	8e19                	sub	a2,a2,a4
ffffffffc02020e6:	078e                	slli	a5,a5,0x3
ffffffffc02020e8:	00c65593          	srli	a1,a2,0xc
ffffffffc02020ec:	953e                	add	a0,a0,a5
ffffffffc02020ee:	9682                	jalr	a3
ffffffffc02020f0:	bcf5                	j	ffffffffc0201bec <pmm_init+0x114>
ffffffffc02020f2:	beafe0ef          	jal	ra,ffffffffc02004dc <intr_disable>
ffffffffc02020f6:	000bb783          	ld	a5,0(s7)
ffffffffc02020fa:	779c                	ld	a5,40(a5)
ffffffffc02020fc:	9782                	jalr	a5
ffffffffc02020fe:	842a                	mv	s0,a0
ffffffffc0202100:	bd6fe0ef          	jal	ra,ffffffffc02004d6 <intr_enable>
ffffffffc0202104:	be2d                	j	ffffffffc0201c3e <pmm_init+0x166>
ffffffffc0202106:	bd6fe0ef          	jal	ra,ffffffffc02004dc <intr_disable>
ffffffffc020210a:	000bb783          	ld	a5,0(s7)
ffffffffc020210e:	779c                	ld	a5,40(a5)
ffffffffc0202110:	9782                	jalr	a5
ffffffffc0202112:	8c2a                	mv	s8,a0
ffffffffc0202114:	bc2fe0ef          	jal	ra,ffffffffc02004d6 <intr_enable>
ffffffffc0202118:	b3d9                	j	ffffffffc0201ede <pmm_init+0x406>
ffffffffc020211a:	bc2fe0ef          	jal	ra,ffffffffc02004dc <intr_disable>
ffffffffc020211e:	000bb783          	ld	a5,0(s7)
ffffffffc0202122:	779c                	ld	a5,40(a5)
ffffffffc0202124:	9782                	jalr	a5
ffffffffc0202126:	8a2a                	mv	s4,a0
ffffffffc0202128:	baefe0ef          	jal	ra,ffffffffc02004d6 <intr_enable>
ffffffffc020212c:	b379                	j	ffffffffc0201eba <pmm_init+0x3e2>
ffffffffc020212e:	e42a                	sd	a0,8(sp)
ffffffffc0202130:	bacfe0ef          	jal	ra,ffffffffc02004dc <intr_disable>
ffffffffc0202134:	000bb783          	ld	a5,0(s7)
ffffffffc0202138:	6522                	ld	a0,8(sp)
ffffffffc020213a:	4585                	li	a1,1
ffffffffc020213c:	739c                	ld	a5,32(a5)
ffffffffc020213e:	9782                	jalr	a5
ffffffffc0202140:	b96fe0ef          	jal	ra,ffffffffc02004d6 <intr_enable>
ffffffffc0202144:	bba9                	j	ffffffffc0201e9e <pmm_init+0x3c6>
ffffffffc0202146:	e42a                	sd	a0,8(sp)
ffffffffc0202148:	b94fe0ef          	jal	ra,ffffffffc02004dc <intr_disable>
ffffffffc020214c:	000bb783          	ld	a5,0(s7)
ffffffffc0202150:	6522                	ld	a0,8(sp)
ffffffffc0202152:	4585                	li	a1,1
ffffffffc0202154:	739c                	ld	a5,32(a5)
ffffffffc0202156:	9782                	jalr	a5
ffffffffc0202158:	b7efe0ef          	jal	ra,ffffffffc02004d6 <intr_enable>
ffffffffc020215c:	b331                	j	ffffffffc0201e68 <pmm_init+0x390>
ffffffffc020215e:	b7efe0ef          	jal	ra,ffffffffc02004dc <intr_disable>
ffffffffc0202162:	000bb783          	ld	a5,0(s7)
ffffffffc0202166:	779c                	ld	a5,40(a5)
ffffffffc0202168:	9782                	jalr	a5
ffffffffc020216a:	842a                	mv	s0,a0
ffffffffc020216c:	b6afe0ef          	jal	ra,ffffffffc02004d6 <intr_enable>
ffffffffc0202170:	b725                	j	ffffffffc0202098 <pmm_init+0x5c0>
ffffffffc0202172:	e42a                	sd	a0,8(sp)
ffffffffc0202174:	b68fe0ef          	jal	ra,ffffffffc02004dc <intr_disable>
ffffffffc0202178:	000bb783          	ld	a5,0(s7)
ffffffffc020217c:	6522                	ld	a0,8(sp)
ffffffffc020217e:	4585                	li	a1,1
ffffffffc0202180:	739c                	ld	a5,32(a5)
ffffffffc0202182:	9782                	jalr	a5
ffffffffc0202184:	b52fe0ef          	jal	ra,ffffffffc02004d6 <intr_enable>
ffffffffc0202188:	bdd5                	j	ffffffffc020207c <pmm_init+0x5a4>
ffffffffc020218a:	e42a                	sd	a0,8(sp)
ffffffffc020218c:	b50fe0ef          	jal	ra,ffffffffc02004dc <intr_disable>
ffffffffc0202190:	000bb783          	ld	a5,0(s7)
ffffffffc0202194:	6522                	ld	a0,8(sp)
ffffffffc0202196:	4585                	li	a1,1
ffffffffc0202198:	739c                	ld	a5,32(a5)
ffffffffc020219a:	9782                	jalr	a5
ffffffffc020219c:	b3afe0ef          	jal	ra,ffffffffc02004d6 <intr_enable>
ffffffffc02021a0:	b55d                	j	ffffffffc0202046 <pmm_init+0x56e>
ffffffffc02021a2:	b3afe0ef          	jal	ra,ffffffffc02004dc <intr_disable>
ffffffffc02021a6:	000bb783          	ld	a5,0(s7)
ffffffffc02021aa:	4585                	li	a1,1
ffffffffc02021ac:	8522                	mv	a0,s0
ffffffffc02021ae:	739c                	ld	a5,32(a5)
ffffffffc02021b0:	9782                	jalr	a5
ffffffffc02021b2:	b24fe0ef          	jal	ra,ffffffffc02004d6 <intr_enable>
ffffffffc02021b6:	bda9                	j	ffffffffc0202010 <pmm_init+0x538>
ffffffffc02021b8:	00003697          	auipc	a3,0x3
ffffffffc02021bc:	51068693          	addi	a3,a3,1296 # ffffffffc02056c8 <default_pmm_manager+0x4f8>
ffffffffc02021c0:	00003617          	auipc	a2,0x3
ffffffffc02021c4:	c6060613          	addi	a2,a2,-928 # ffffffffc0204e20 <commands+0x738>
ffffffffc02021c8:	20300593          	li	a1,515
ffffffffc02021cc:	00003517          	auipc	a0,0x3
ffffffffc02021d0:	0ec50513          	addi	a0,a0,236 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc02021d4:	98efe0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02021d8:	00003697          	auipc	a3,0x3
ffffffffc02021dc:	4b068693          	addi	a3,a3,1200 # ffffffffc0205688 <default_pmm_manager+0x4b8>
ffffffffc02021e0:	00003617          	auipc	a2,0x3
ffffffffc02021e4:	c4060613          	addi	a2,a2,-960 # ffffffffc0204e20 <commands+0x738>
ffffffffc02021e8:	20200593          	li	a1,514
ffffffffc02021ec:	00003517          	auipc	a0,0x3
ffffffffc02021f0:	0cc50513          	addi	a0,a0,204 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc02021f4:	96efe0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02021f8:	86a2                	mv	a3,s0
ffffffffc02021fa:	00003617          	auipc	a2,0x3
ffffffffc02021fe:	09660613          	addi	a2,a2,150 # ffffffffc0205290 <default_pmm_manager+0xc0>
ffffffffc0202202:	20200593          	li	a1,514
ffffffffc0202206:	00003517          	auipc	a0,0x3
ffffffffc020220a:	0b250513          	addi	a0,a0,178 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc020220e:	954fe0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202212:	b86ff0ef          	jal	ra,ffffffffc0201598 <pa2page.part.0>
ffffffffc0202216:	00003617          	auipc	a2,0x3
ffffffffc020221a:	13a60613          	addi	a2,a2,314 # ffffffffc0205350 <default_pmm_manager+0x180>
ffffffffc020221e:	08600593          	li	a1,134
ffffffffc0202222:	00003517          	auipc	a0,0x3
ffffffffc0202226:	09650513          	addi	a0,a0,150 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc020222a:	938fe0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc020222e:	00003617          	auipc	a2,0x3
ffffffffc0202232:	12260613          	addi	a2,a2,290 # ffffffffc0205350 <default_pmm_manager+0x180>
ffffffffc0202236:	0d300593          	li	a1,211
ffffffffc020223a:	00003517          	auipc	a0,0x3
ffffffffc020223e:	07e50513          	addi	a0,a0,126 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202242:	920fe0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202246:	00003697          	auipc	a3,0x3
ffffffffc020224a:	17268693          	addi	a3,a3,370 # ffffffffc02053b8 <default_pmm_manager+0x1e8>
ffffffffc020224e:	00003617          	auipc	a2,0x3
ffffffffc0202252:	bd260613          	addi	a2,a2,-1070 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202256:	1c600593          	li	a1,454
ffffffffc020225a:	00003517          	auipc	a0,0x3
ffffffffc020225e:	05e50513          	addi	a0,a0,94 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202262:	900fe0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202266:	00003697          	auipc	a3,0x3
ffffffffc020226a:	13268693          	addi	a3,a3,306 # ffffffffc0205398 <default_pmm_manager+0x1c8>
ffffffffc020226e:	00003617          	auipc	a2,0x3
ffffffffc0202272:	bb260613          	addi	a2,a2,-1102 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202276:	1c500593          	li	a1,453
ffffffffc020227a:	00003517          	auipc	a0,0x3
ffffffffc020227e:	03e50513          	addi	a0,a0,62 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202282:	8e0fe0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202286:	b2eff0ef          	jal	ra,ffffffffc02015b4 <pte2page.part.0>
ffffffffc020228a:	00003697          	auipc	a3,0x3
ffffffffc020228e:	1be68693          	addi	a3,a3,446 # ffffffffc0205448 <default_pmm_manager+0x278>
ffffffffc0202292:	00003617          	auipc	a2,0x3
ffffffffc0202296:	b8e60613          	addi	a2,a2,-1138 # ffffffffc0204e20 <commands+0x738>
ffffffffc020229a:	1cd00593          	li	a1,461
ffffffffc020229e:	00003517          	auipc	a0,0x3
ffffffffc02022a2:	01a50513          	addi	a0,a0,26 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc02022a6:	8bcfe0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02022aa:	00003697          	auipc	a3,0x3
ffffffffc02022ae:	16e68693          	addi	a3,a3,366 # ffffffffc0205418 <default_pmm_manager+0x248>
ffffffffc02022b2:	00003617          	auipc	a2,0x3
ffffffffc02022b6:	b6e60613          	addi	a2,a2,-1170 # ffffffffc0204e20 <commands+0x738>
ffffffffc02022ba:	1cb00593          	li	a1,459
ffffffffc02022be:	00003517          	auipc	a0,0x3
ffffffffc02022c2:	ffa50513          	addi	a0,a0,-6 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc02022c6:	89cfe0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02022ca:	00003697          	auipc	a3,0x3
ffffffffc02022ce:	12668693          	addi	a3,a3,294 # ffffffffc02053f0 <default_pmm_manager+0x220>
ffffffffc02022d2:	00003617          	auipc	a2,0x3
ffffffffc02022d6:	b4e60613          	addi	a2,a2,-1202 # ffffffffc0204e20 <commands+0x738>
ffffffffc02022da:	1c700593          	li	a1,455
ffffffffc02022de:	00003517          	auipc	a0,0x3
ffffffffc02022e2:	fda50513          	addi	a0,a0,-38 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc02022e6:	87cfe0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02022ea:	00003697          	auipc	a3,0x3
ffffffffc02022ee:	1e668693          	addi	a3,a3,486 # ffffffffc02054d0 <default_pmm_manager+0x300>
ffffffffc02022f2:	00003617          	auipc	a2,0x3
ffffffffc02022f6:	b2e60613          	addi	a2,a2,-1234 # ffffffffc0204e20 <commands+0x738>
ffffffffc02022fa:	1d600593          	li	a1,470
ffffffffc02022fe:	00003517          	auipc	a0,0x3
ffffffffc0202302:	fba50513          	addi	a0,a0,-70 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202306:	85cfe0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc020230a:	00003697          	auipc	a3,0x3
ffffffffc020230e:	26668693          	addi	a3,a3,614 # ffffffffc0205570 <default_pmm_manager+0x3a0>
ffffffffc0202312:	00003617          	auipc	a2,0x3
ffffffffc0202316:	b0e60613          	addi	a2,a2,-1266 # ffffffffc0204e20 <commands+0x738>
ffffffffc020231a:	1db00593          	li	a1,475
ffffffffc020231e:	00003517          	auipc	a0,0x3
ffffffffc0202322:	f9a50513          	addi	a0,a0,-102 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202326:	83cfe0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc020232a:	00003697          	auipc	a3,0x3
ffffffffc020232e:	17e68693          	addi	a3,a3,382 # ffffffffc02054a8 <default_pmm_manager+0x2d8>
ffffffffc0202332:	00003617          	auipc	a2,0x3
ffffffffc0202336:	aee60613          	addi	a2,a2,-1298 # ffffffffc0204e20 <commands+0x738>
ffffffffc020233a:	1d300593          	li	a1,467
ffffffffc020233e:	00003517          	auipc	a0,0x3
ffffffffc0202342:	f7a50513          	addi	a0,a0,-134 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202346:	81cfe0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc020234a:	86d6                	mv	a3,s5
ffffffffc020234c:	00003617          	auipc	a2,0x3
ffffffffc0202350:	f4460613          	addi	a2,a2,-188 # ffffffffc0205290 <default_pmm_manager+0xc0>
ffffffffc0202354:	1d200593          	li	a1,466
ffffffffc0202358:	00003517          	auipc	a0,0x3
ffffffffc020235c:	f6050513          	addi	a0,a0,-160 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202360:	802fe0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202364:	00003697          	auipc	a3,0x3
ffffffffc0202368:	1a468693          	addi	a3,a3,420 # ffffffffc0205508 <default_pmm_manager+0x338>
ffffffffc020236c:	00003617          	auipc	a2,0x3
ffffffffc0202370:	ab460613          	addi	a2,a2,-1356 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202374:	1e000593          	li	a1,480
ffffffffc0202378:	00003517          	auipc	a0,0x3
ffffffffc020237c:	f4050513          	addi	a0,a0,-192 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202380:	fe3fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202384:	00003697          	auipc	a3,0x3
ffffffffc0202388:	24c68693          	addi	a3,a3,588 # ffffffffc02055d0 <default_pmm_manager+0x400>
ffffffffc020238c:	00003617          	auipc	a2,0x3
ffffffffc0202390:	a9460613          	addi	a2,a2,-1388 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202394:	1df00593          	li	a1,479
ffffffffc0202398:	00003517          	auipc	a0,0x3
ffffffffc020239c:	f2050513          	addi	a0,a0,-224 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc02023a0:	fc3fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02023a4:	00003697          	auipc	a3,0x3
ffffffffc02023a8:	21468693          	addi	a3,a3,532 # ffffffffc02055b8 <default_pmm_manager+0x3e8>
ffffffffc02023ac:	00003617          	auipc	a2,0x3
ffffffffc02023b0:	a7460613          	addi	a2,a2,-1420 # ffffffffc0204e20 <commands+0x738>
ffffffffc02023b4:	1de00593          	li	a1,478
ffffffffc02023b8:	00003517          	auipc	a0,0x3
ffffffffc02023bc:	f0050513          	addi	a0,a0,-256 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc02023c0:	fa3fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02023c4:	00003697          	auipc	a3,0x3
ffffffffc02023c8:	1c468693          	addi	a3,a3,452 # ffffffffc0205588 <default_pmm_manager+0x3b8>
ffffffffc02023cc:	00003617          	auipc	a2,0x3
ffffffffc02023d0:	a5460613          	addi	a2,a2,-1452 # ffffffffc0204e20 <commands+0x738>
ffffffffc02023d4:	1dd00593          	li	a1,477
ffffffffc02023d8:	00003517          	auipc	a0,0x3
ffffffffc02023dc:	ee050513          	addi	a0,a0,-288 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc02023e0:	f83fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02023e4:	00003697          	auipc	a3,0x3
ffffffffc02023e8:	36468693          	addi	a3,a3,868 # ffffffffc0205748 <default_pmm_manager+0x578>
ffffffffc02023ec:	00003617          	auipc	a2,0x3
ffffffffc02023f0:	a3460613          	addi	a2,a2,-1484 # ffffffffc0204e20 <commands+0x738>
ffffffffc02023f4:	20c00593          	li	a1,524
ffffffffc02023f8:	00003517          	auipc	a0,0x3
ffffffffc02023fc:	ec050513          	addi	a0,a0,-320 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202400:	f63fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202404:	00003697          	auipc	a3,0x3
ffffffffc0202408:	15468693          	addi	a3,a3,340 # ffffffffc0205558 <default_pmm_manager+0x388>
ffffffffc020240c:	00003617          	auipc	a2,0x3
ffffffffc0202410:	a1460613          	addi	a2,a2,-1516 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202414:	1da00593          	li	a1,474
ffffffffc0202418:	00003517          	auipc	a0,0x3
ffffffffc020241c:	ea050513          	addi	a0,a0,-352 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202420:	f43fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202424:	00003697          	auipc	a3,0x3
ffffffffc0202428:	12468693          	addi	a3,a3,292 # ffffffffc0205548 <default_pmm_manager+0x378>
ffffffffc020242c:	00003617          	auipc	a2,0x3
ffffffffc0202430:	9f460613          	addi	a2,a2,-1548 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202434:	1d900593          	li	a1,473
ffffffffc0202438:	00003517          	auipc	a0,0x3
ffffffffc020243c:	e8050513          	addi	a0,a0,-384 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202440:	f23fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202444:	00003697          	auipc	a3,0x3
ffffffffc0202448:	1fc68693          	addi	a3,a3,508 # ffffffffc0205640 <default_pmm_manager+0x470>
ffffffffc020244c:	00003617          	auipc	a2,0x3
ffffffffc0202450:	9d460613          	addi	a2,a2,-1580 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202454:	21c00593          	li	a1,540
ffffffffc0202458:	00003517          	auipc	a0,0x3
ffffffffc020245c:	e6050513          	addi	a0,a0,-416 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202460:	f03fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202464:	00003697          	auipc	a3,0x3
ffffffffc0202468:	0d468693          	addi	a3,a3,212 # ffffffffc0205538 <default_pmm_manager+0x368>
ffffffffc020246c:	00003617          	auipc	a2,0x3
ffffffffc0202470:	9b460613          	addi	a2,a2,-1612 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202474:	1d800593          	li	a1,472
ffffffffc0202478:	00003517          	auipc	a0,0x3
ffffffffc020247c:	e4050513          	addi	a0,a0,-448 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202480:	ee3fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202484:	00003697          	auipc	a3,0x3
ffffffffc0202488:	00c68693          	addi	a3,a3,12 # ffffffffc0205490 <default_pmm_manager+0x2c0>
ffffffffc020248c:	00003617          	auipc	a2,0x3
ffffffffc0202490:	99460613          	addi	a2,a2,-1644 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202494:	1e500593          	li	a1,485
ffffffffc0202498:	00003517          	auipc	a0,0x3
ffffffffc020249c:	e2050513          	addi	a0,a0,-480 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc02024a0:	ec3fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02024a4:	00003697          	auipc	a3,0x3
ffffffffc02024a8:	14468693          	addi	a3,a3,324 # ffffffffc02055e8 <default_pmm_manager+0x418>
ffffffffc02024ac:	00003617          	auipc	a2,0x3
ffffffffc02024b0:	97460613          	addi	a2,a2,-1676 # ffffffffc0204e20 <commands+0x738>
ffffffffc02024b4:	1e200593          	li	a1,482
ffffffffc02024b8:	00003517          	auipc	a0,0x3
ffffffffc02024bc:	e0050513          	addi	a0,a0,-512 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc02024c0:	ea3fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02024c4:	00003697          	auipc	a3,0x3
ffffffffc02024c8:	fb468693          	addi	a3,a3,-76 # ffffffffc0205478 <default_pmm_manager+0x2a8>
ffffffffc02024cc:	00003617          	auipc	a2,0x3
ffffffffc02024d0:	95460613          	addi	a2,a2,-1708 # ffffffffc0204e20 <commands+0x738>
ffffffffc02024d4:	1e100593          	li	a1,481
ffffffffc02024d8:	00003517          	auipc	a0,0x3
ffffffffc02024dc:	de050513          	addi	a0,a0,-544 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc02024e0:	e83fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02024e4:	00003617          	auipc	a2,0x3
ffffffffc02024e8:	dac60613          	addi	a2,a2,-596 # ffffffffc0205290 <default_pmm_manager+0xc0>
ffffffffc02024ec:	06a00593          	li	a1,106
ffffffffc02024f0:	00003517          	auipc	a0,0x3
ffffffffc02024f4:	d3850513          	addi	a0,a0,-712 # ffffffffc0205228 <default_pmm_manager+0x58>
ffffffffc02024f8:	e6bfd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02024fc:	00003697          	auipc	a3,0x3
ffffffffc0202500:	11c68693          	addi	a3,a3,284 # ffffffffc0205618 <default_pmm_manager+0x448>
ffffffffc0202504:	00003617          	auipc	a2,0x3
ffffffffc0202508:	91c60613          	addi	a2,a2,-1764 # ffffffffc0204e20 <commands+0x738>
ffffffffc020250c:	1ec00593          	li	a1,492
ffffffffc0202510:	00003517          	auipc	a0,0x3
ffffffffc0202514:	da850513          	addi	a0,a0,-600 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202518:	e4bfd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc020251c:	00003697          	auipc	a3,0x3
ffffffffc0202520:	0b468693          	addi	a3,a3,180 # ffffffffc02055d0 <default_pmm_manager+0x400>
ffffffffc0202524:	00003617          	auipc	a2,0x3
ffffffffc0202528:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0204e20 <commands+0x738>
ffffffffc020252c:	1ea00593          	li	a1,490
ffffffffc0202530:	00003517          	auipc	a0,0x3
ffffffffc0202534:	d8850513          	addi	a0,a0,-632 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202538:	e2bfd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc020253c:	00003697          	auipc	a3,0x3
ffffffffc0202540:	0c468693          	addi	a3,a3,196 # ffffffffc0205600 <default_pmm_manager+0x430>
ffffffffc0202544:	00003617          	auipc	a2,0x3
ffffffffc0202548:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0204e20 <commands+0x738>
ffffffffc020254c:	1e900593          	li	a1,489
ffffffffc0202550:	00003517          	auipc	a0,0x3
ffffffffc0202554:	d6850513          	addi	a0,a0,-664 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202558:	e0bfd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc020255c:	00003697          	auipc	a3,0x3
ffffffffc0202560:	07468693          	addi	a3,a3,116 # ffffffffc02055d0 <default_pmm_manager+0x400>
ffffffffc0202564:	00003617          	auipc	a2,0x3
ffffffffc0202568:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0204e20 <commands+0x738>
ffffffffc020256c:	1e600593          	li	a1,486
ffffffffc0202570:	00003517          	auipc	a0,0x3
ffffffffc0202574:	d4850513          	addi	a0,a0,-696 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202578:	debfd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc020257c:	00003697          	auipc	a3,0x3
ffffffffc0202580:	1b468693          	addi	a3,a3,436 # ffffffffc0205730 <default_pmm_manager+0x560>
ffffffffc0202584:	00003617          	auipc	a2,0x3
ffffffffc0202588:	89c60613          	addi	a2,a2,-1892 # ffffffffc0204e20 <commands+0x738>
ffffffffc020258c:	20b00593          	li	a1,523
ffffffffc0202590:	00003517          	auipc	a0,0x3
ffffffffc0202594:	d2850513          	addi	a0,a0,-728 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202598:	dcbfd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc020259c:	00003697          	auipc	a3,0x3
ffffffffc02025a0:	15c68693          	addi	a3,a3,348 # ffffffffc02056f8 <default_pmm_manager+0x528>
ffffffffc02025a4:	00003617          	auipc	a2,0x3
ffffffffc02025a8:	87c60613          	addi	a2,a2,-1924 # ffffffffc0204e20 <commands+0x738>
ffffffffc02025ac:	20a00593          	li	a1,522
ffffffffc02025b0:	00003517          	auipc	a0,0x3
ffffffffc02025b4:	d0850513          	addi	a0,a0,-760 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc02025b8:	dabfd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02025bc:	00003697          	auipc	a3,0x3
ffffffffc02025c0:	12468693          	addi	a3,a3,292 # ffffffffc02056e0 <default_pmm_manager+0x510>
ffffffffc02025c4:	00003617          	auipc	a2,0x3
ffffffffc02025c8:	85c60613          	addi	a2,a2,-1956 # ffffffffc0204e20 <commands+0x738>
ffffffffc02025cc:	20600593          	li	a1,518
ffffffffc02025d0:	00003517          	auipc	a0,0x3
ffffffffc02025d4:	ce850513          	addi	a0,a0,-792 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc02025d8:	d8bfd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02025dc:	00003697          	auipc	a3,0x3
ffffffffc02025e0:	06468693          	addi	a3,a3,100 # ffffffffc0205640 <default_pmm_manager+0x470>
ffffffffc02025e4:	00003617          	auipc	a2,0x3
ffffffffc02025e8:	83c60613          	addi	a2,a2,-1988 # ffffffffc0204e20 <commands+0x738>
ffffffffc02025ec:	1f300593          	li	a1,499
ffffffffc02025f0:	00003517          	auipc	a0,0x3
ffffffffc02025f4:	cc850513          	addi	a0,a0,-824 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc02025f8:	d6bfd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02025fc:	00003697          	auipc	a3,0x3
ffffffffc0202600:	e7c68693          	addi	a3,a3,-388 # ffffffffc0205478 <default_pmm_manager+0x2a8>
ffffffffc0202604:	00003617          	auipc	a2,0x3
ffffffffc0202608:	81c60613          	addi	a2,a2,-2020 # ffffffffc0204e20 <commands+0x738>
ffffffffc020260c:	1ce00593          	li	a1,462
ffffffffc0202610:	00003517          	auipc	a0,0x3
ffffffffc0202614:	ca850513          	addi	a0,a0,-856 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202618:	d4bfd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc020261c:	00003617          	auipc	a2,0x3
ffffffffc0202620:	c7460613          	addi	a2,a2,-908 # ffffffffc0205290 <default_pmm_manager+0xc0>
ffffffffc0202624:	1d100593          	li	a1,465
ffffffffc0202628:	00003517          	auipc	a0,0x3
ffffffffc020262c:	c9050513          	addi	a0,a0,-880 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202630:	d33fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202634:	00003697          	auipc	a3,0x3
ffffffffc0202638:	e5c68693          	addi	a3,a3,-420 # ffffffffc0205490 <default_pmm_manager+0x2c0>
ffffffffc020263c:	00002617          	auipc	a2,0x2
ffffffffc0202640:	7e460613          	addi	a2,a2,2020 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202644:	1cf00593          	li	a1,463
ffffffffc0202648:	00003517          	auipc	a0,0x3
ffffffffc020264c:	c7050513          	addi	a0,a0,-912 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202650:	d13fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202654:	00003697          	auipc	a3,0x3
ffffffffc0202658:	eb468693          	addi	a3,a3,-332 # ffffffffc0205508 <default_pmm_manager+0x338>
ffffffffc020265c:	00002617          	auipc	a2,0x2
ffffffffc0202660:	7c460613          	addi	a2,a2,1988 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202664:	1d700593          	li	a1,471
ffffffffc0202668:	00003517          	auipc	a0,0x3
ffffffffc020266c:	c5050513          	addi	a0,a0,-944 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202670:	cf3fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202674:	00003697          	auipc	a3,0x3
ffffffffc0202678:	17c68693          	addi	a3,a3,380 # ffffffffc02057f0 <default_pmm_manager+0x620>
ffffffffc020267c:	00002617          	auipc	a2,0x2
ffffffffc0202680:	7a460613          	addi	a2,a2,1956 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202684:	21400593          	li	a1,532
ffffffffc0202688:	00003517          	auipc	a0,0x3
ffffffffc020268c:	c3050513          	addi	a0,a0,-976 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202690:	cd3fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202694:	00003697          	auipc	a3,0x3
ffffffffc0202698:	12468693          	addi	a3,a3,292 # ffffffffc02057b8 <default_pmm_manager+0x5e8>
ffffffffc020269c:	00002617          	auipc	a2,0x2
ffffffffc02026a0:	78460613          	addi	a2,a2,1924 # ffffffffc0204e20 <commands+0x738>
ffffffffc02026a4:	21100593          	li	a1,529
ffffffffc02026a8:	00003517          	auipc	a0,0x3
ffffffffc02026ac:	c1050513          	addi	a0,a0,-1008 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc02026b0:	cb3fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02026b4:	00003697          	auipc	a3,0x3
ffffffffc02026b8:	0d468693          	addi	a3,a3,212 # ffffffffc0205788 <default_pmm_manager+0x5b8>
ffffffffc02026bc:	00002617          	auipc	a2,0x2
ffffffffc02026c0:	76460613          	addi	a2,a2,1892 # ffffffffc0204e20 <commands+0x738>
ffffffffc02026c4:	20d00593          	li	a1,525
ffffffffc02026c8:	00003517          	auipc	a0,0x3
ffffffffc02026cc:	bf050513          	addi	a0,a0,-1040 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc02026d0:	c93fd0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc02026d4 <tlb_invalidate>:
ffffffffc02026d4:	12000073          	sfence.vma
ffffffffc02026d8:	8082                	ret

ffffffffc02026da <pgdir_alloc_page>:
ffffffffc02026da:	7179                	addi	sp,sp,-48
ffffffffc02026dc:	e84a                	sd	s2,16(sp)
ffffffffc02026de:	892a                	mv	s2,a0
ffffffffc02026e0:	4505                	li	a0,1
ffffffffc02026e2:	ec26                	sd	s1,24(sp)
ffffffffc02026e4:	e44e                	sd	s3,8(sp)
ffffffffc02026e6:	f406                	sd	ra,40(sp)
ffffffffc02026e8:	f022                	sd	s0,32(sp)
ffffffffc02026ea:	84ae                	mv	s1,a1
ffffffffc02026ec:	89b2                	mv	s3,a2
ffffffffc02026ee:	ee3fe0ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc02026f2:	c131                	beqz	a0,ffffffffc0202736 <pgdir_alloc_page+0x5c>
ffffffffc02026f4:	842a                	mv	s0,a0
ffffffffc02026f6:	85aa                	mv	a1,a0
ffffffffc02026f8:	86ce                	mv	a3,s3
ffffffffc02026fa:	8626                	mv	a2,s1
ffffffffc02026fc:	854a                	mv	a0,s2
ffffffffc02026fe:	adcff0ef          	jal	ra,ffffffffc02019da <page_insert>
ffffffffc0202702:	ed11                	bnez	a0,ffffffffc020271e <pgdir_alloc_page+0x44>
ffffffffc0202704:	0000f797          	auipc	a5,0xf
ffffffffc0202708:	e447a783          	lw	a5,-444(a5) # ffffffffc0211548 <swap_init_ok>
ffffffffc020270c:	e79d                	bnez	a5,ffffffffc020273a <pgdir_alloc_page+0x60>
ffffffffc020270e:	70a2                	ld	ra,40(sp)
ffffffffc0202710:	8522                	mv	a0,s0
ffffffffc0202712:	7402                	ld	s0,32(sp)
ffffffffc0202714:	64e2                	ld	s1,24(sp)
ffffffffc0202716:	6942                	ld	s2,16(sp)
ffffffffc0202718:	69a2                	ld	s3,8(sp)
ffffffffc020271a:	6145                	addi	sp,sp,48
ffffffffc020271c:	8082                	ret
ffffffffc020271e:	100027f3          	csrr	a5,sstatus
ffffffffc0202722:	8b89                	andi	a5,a5,2
ffffffffc0202724:	eba9                	bnez	a5,ffffffffc0202776 <pgdir_alloc_page+0x9c>
ffffffffc0202726:	0000f797          	auipc	a5,0xf
ffffffffc020272a:	df27b783          	ld	a5,-526(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc020272e:	739c                	ld	a5,32(a5)
ffffffffc0202730:	4585                	li	a1,1
ffffffffc0202732:	8522                	mv	a0,s0
ffffffffc0202734:	9782                	jalr	a5
ffffffffc0202736:	4401                	li	s0,0
ffffffffc0202738:	bfd9                	j	ffffffffc020270e <pgdir_alloc_page+0x34>
ffffffffc020273a:	4681                	li	a3,0
ffffffffc020273c:	8622                	mv	a2,s0
ffffffffc020273e:	85a6                	mv	a1,s1
ffffffffc0202740:	0000f517          	auipc	a0,0xf
ffffffffc0202744:	e3053503          	ld	a0,-464(a0) # ffffffffc0211570 <check_mm_struct>
ffffffffc0202748:	081000ef          	jal	ra,ffffffffc0202fc8 <swap_map_swappable>
ffffffffc020274c:	4018                	lw	a4,0(s0)
ffffffffc020274e:	e024                	sd	s1,64(s0)
ffffffffc0202750:	4785                	li	a5,1
ffffffffc0202752:	faf70ee3          	beq	a4,a5,ffffffffc020270e <pgdir_alloc_page+0x34>
ffffffffc0202756:	00003697          	auipc	a3,0x3
ffffffffc020275a:	0e268693          	addi	a3,a3,226 # ffffffffc0205838 <default_pmm_manager+0x668>
ffffffffc020275e:	00002617          	auipc	a2,0x2
ffffffffc0202762:	6c260613          	addi	a2,a2,1730 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202766:	1ab00593          	li	a1,427
ffffffffc020276a:	00003517          	auipc	a0,0x3
ffffffffc020276e:	b4e50513          	addi	a0,a0,-1202 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202772:	bf1fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202776:	d67fd0ef          	jal	ra,ffffffffc02004dc <intr_disable>
ffffffffc020277a:	0000f797          	auipc	a5,0xf
ffffffffc020277e:	d9e7b783          	ld	a5,-610(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc0202782:	739c                	ld	a5,32(a5)
ffffffffc0202784:	8522                	mv	a0,s0
ffffffffc0202786:	4585                	li	a1,1
ffffffffc0202788:	9782                	jalr	a5
ffffffffc020278a:	4401                	li	s0,0
ffffffffc020278c:	d4bfd0ef          	jal	ra,ffffffffc02004d6 <intr_enable>
ffffffffc0202790:	bfbd                	j	ffffffffc020270e <pgdir_alloc_page+0x34>

ffffffffc0202792 <kmalloc>:
ffffffffc0202792:	1141                	addi	sp,sp,-16
ffffffffc0202794:	67d5                	lui	a5,0x15
ffffffffc0202796:	e406                	sd	ra,8(sp)
ffffffffc0202798:	fff50713          	addi	a4,a0,-1
ffffffffc020279c:	17f9                	addi	a5,a5,-2
ffffffffc020279e:	04e7ea63          	bltu	a5,a4,ffffffffc02027f2 <kmalloc+0x60>
ffffffffc02027a2:	6785                	lui	a5,0x1
ffffffffc02027a4:	17fd                	addi	a5,a5,-1
ffffffffc02027a6:	953e                	add	a0,a0,a5
ffffffffc02027a8:	8131                	srli	a0,a0,0xc
ffffffffc02027aa:	e27fe0ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc02027ae:	cd3d                	beqz	a0,ffffffffc020282c <kmalloc+0x9a>
ffffffffc02027b0:	0000f797          	auipc	a5,0xf
ffffffffc02027b4:	d907b783          	ld	a5,-624(a5) # ffffffffc0211540 <pages>
ffffffffc02027b8:	8d1d                	sub	a0,a0,a5
ffffffffc02027ba:	850d                	srai	a0,a0,0x3
ffffffffc02027bc:	00004797          	auipc	a5,0x4
ffffffffc02027c0:	b8c7b783          	ld	a5,-1140(a5) # ffffffffc0206348 <error_string+0x38>
ffffffffc02027c4:	02f50533          	mul	a0,a0,a5
ffffffffc02027c8:	000807b7          	lui	a5,0x80
ffffffffc02027cc:	0000f717          	auipc	a4,0xf
ffffffffc02027d0:	d6c73703          	ld	a4,-660(a4) # ffffffffc0211538 <npage>
ffffffffc02027d4:	953e                	add	a0,a0,a5
ffffffffc02027d6:	00c51793          	slli	a5,a0,0xc
ffffffffc02027da:	83b1                	srli	a5,a5,0xc
ffffffffc02027dc:	0532                	slli	a0,a0,0xc
ffffffffc02027de:	02e7fa63          	bgeu	a5,a4,ffffffffc0202812 <kmalloc+0x80>
ffffffffc02027e2:	60a2                	ld	ra,8(sp)
ffffffffc02027e4:	0000f797          	auipc	a5,0xf
ffffffffc02027e8:	d4c7b783          	ld	a5,-692(a5) # ffffffffc0211530 <va_pa_offset>
ffffffffc02027ec:	953e                	add	a0,a0,a5
ffffffffc02027ee:	0141                	addi	sp,sp,16
ffffffffc02027f0:	8082                	ret
ffffffffc02027f2:	00003697          	auipc	a3,0x3
ffffffffc02027f6:	05e68693          	addi	a3,a3,94 # ffffffffc0205850 <default_pmm_manager+0x680>
ffffffffc02027fa:	00002617          	auipc	a2,0x2
ffffffffc02027fe:	62660613          	addi	a2,a2,1574 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202802:	22500593          	li	a1,549
ffffffffc0202806:	00003517          	auipc	a0,0x3
ffffffffc020280a:	ab250513          	addi	a0,a0,-1358 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc020280e:	b55fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202812:	86aa                	mv	a3,a0
ffffffffc0202814:	00003617          	auipc	a2,0x3
ffffffffc0202818:	a7c60613          	addi	a2,a2,-1412 # ffffffffc0205290 <default_pmm_manager+0xc0>
ffffffffc020281c:	06a00593          	li	a1,106
ffffffffc0202820:	00003517          	auipc	a0,0x3
ffffffffc0202824:	a0850513          	addi	a0,a0,-1528 # ffffffffc0205228 <default_pmm_manager+0x58>
ffffffffc0202828:	b3bfd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc020282c:	00003697          	auipc	a3,0x3
ffffffffc0202830:	04468693          	addi	a3,a3,68 # ffffffffc0205870 <default_pmm_manager+0x6a0>
ffffffffc0202834:	00002617          	auipc	a2,0x2
ffffffffc0202838:	5ec60613          	addi	a2,a2,1516 # ffffffffc0204e20 <commands+0x738>
ffffffffc020283c:	22800593          	li	a1,552
ffffffffc0202840:	00003517          	auipc	a0,0x3
ffffffffc0202844:	a7850513          	addi	a0,a0,-1416 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202848:	b1bfd0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc020284c <kfree>:
ffffffffc020284c:	1101                	addi	sp,sp,-32
ffffffffc020284e:	67d5                	lui	a5,0x15
ffffffffc0202850:	ec06                	sd	ra,24(sp)
ffffffffc0202852:	fff58713          	addi	a4,a1,-1
ffffffffc0202856:	17f9                	addi	a5,a5,-2
ffffffffc0202858:	0ae7ee63          	bltu	a5,a4,ffffffffc0202914 <kfree+0xc8>
ffffffffc020285c:	cd41                	beqz	a0,ffffffffc02028f4 <kfree+0xa8>
ffffffffc020285e:	6785                	lui	a5,0x1
ffffffffc0202860:	17fd                	addi	a5,a5,-1
ffffffffc0202862:	95be                	add	a1,a1,a5
ffffffffc0202864:	c02007b7          	lui	a5,0xc0200
ffffffffc0202868:	81b1                	srli	a1,a1,0xc
ffffffffc020286a:	06f56863          	bltu	a0,a5,ffffffffc02028da <kfree+0x8e>
ffffffffc020286e:	0000f797          	auipc	a5,0xf
ffffffffc0202872:	cc27b783          	ld	a5,-830(a5) # ffffffffc0211530 <va_pa_offset>
ffffffffc0202876:	8d1d                	sub	a0,a0,a5
ffffffffc0202878:	8131                	srli	a0,a0,0xc
ffffffffc020287a:	0000f797          	auipc	a5,0xf
ffffffffc020287e:	cbe7b783          	ld	a5,-834(a5) # ffffffffc0211538 <npage>
ffffffffc0202882:	04f57a63          	bgeu	a0,a5,ffffffffc02028d6 <kfree+0x8a>
ffffffffc0202886:	fff807b7          	lui	a5,0xfff80
ffffffffc020288a:	953e                	add	a0,a0,a5
ffffffffc020288c:	00351793          	slli	a5,a0,0x3
ffffffffc0202890:	97aa                	add	a5,a5,a0
ffffffffc0202892:	078e                	slli	a5,a5,0x3
ffffffffc0202894:	0000f517          	auipc	a0,0xf
ffffffffc0202898:	cac53503          	ld	a0,-852(a0) # ffffffffc0211540 <pages>
ffffffffc020289c:	953e                	add	a0,a0,a5
ffffffffc020289e:	100027f3          	csrr	a5,sstatus
ffffffffc02028a2:	8b89                	andi	a5,a5,2
ffffffffc02028a4:	eb89                	bnez	a5,ffffffffc02028b6 <kfree+0x6a>
ffffffffc02028a6:	0000f797          	auipc	a5,0xf
ffffffffc02028aa:	c727b783          	ld	a5,-910(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc02028ae:	60e2                	ld	ra,24(sp)
ffffffffc02028b0:	739c                	ld	a5,32(a5)
ffffffffc02028b2:	6105                	addi	sp,sp,32
ffffffffc02028b4:	8782                	jr	a5
ffffffffc02028b6:	e42a                	sd	a0,8(sp)
ffffffffc02028b8:	e02e                	sd	a1,0(sp)
ffffffffc02028ba:	c23fd0ef          	jal	ra,ffffffffc02004dc <intr_disable>
ffffffffc02028be:	0000f797          	auipc	a5,0xf
ffffffffc02028c2:	c5a7b783          	ld	a5,-934(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc02028c6:	6582                	ld	a1,0(sp)
ffffffffc02028c8:	6522                	ld	a0,8(sp)
ffffffffc02028ca:	739c                	ld	a5,32(a5)
ffffffffc02028cc:	9782                	jalr	a5
ffffffffc02028ce:	60e2                	ld	ra,24(sp)
ffffffffc02028d0:	6105                	addi	sp,sp,32
ffffffffc02028d2:	c05fd06f          	j	ffffffffc02004d6 <intr_enable>
ffffffffc02028d6:	cc3fe0ef          	jal	ra,ffffffffc0201598 <pa2page.part.0>
ffffffffc02028da:	86aa                	mv	a3,a0
ffffffffc02028dc:	00003617          	auipc	a2,0x3
ffffffffc02028e0:	a7460613          	addi	a2,a2,-1420 # ffffffffc0205350 <default_pmm_manager+0x180>
ffffffffc02028e4:	06c00593          	li	a1,108
ffffffffc02028e8:	00003517          	auipc	a0,0x3
ffffffffc02028ec:	94050513          	addi	a0,a0,-1728 # ffffffffc0205228 <default_pmm_manager+0x58>
ffffffffc02028f0:	a73fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02028f4:	00003697          	auipc	a3,0x3
ffffffffc02028f8:	f8c68693          	addi	a3,a3,-116 # ffffffffc0205880 <default_pmm_manager+0x6b0>
ffffffffc02028fc:	00002617          	auipc	a2,0x2
ffffffffc0202900:	52460613          	addi	a2,a2,1316 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202904:	23000593          	li	a1,560
ffffffffc0202908:	00003517          	auipc	a0,0x3
ffffffffc020290c:	9b050513          	addi	a0,a0,-1616 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202910:	a53fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202914:	00003697          	auipc	a3,0x3
ffffffffc0202918:	f3c68693          	addi	a3,a3,-196 # ffffffffc0205850 <default_pmm_manager+0x680>
ffffffffc020291c:	00002617          	auipc	a2,0x2
ffffffffc0202920:	50460613          	addi	a2,a2,1284 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202924:	22f00593          	li	a1,559
ffffffffc0202928:	00003517          	auipc	a0,0x3
ffffffffc020292c:	99050513          	addi	a0,a0,-1648 # ffffffffc02052b8 <default_pmm_manager+0xe8>
ffffffffc0202930:	a33fd0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc0202934 <swap_init>:
ffffffffc0202934:	7171                	addi	sp,sp,-176
ffffffffc0202936:	f506                	sd	ra,168(sp)
ffffffffc0202938:	f122                	sd	s0,160(sp)
ffffffffc020293a:	ed26                	sd	s1,152(sp)
ffffffffc020293c:	e94a                	sd	s2,144(sp)
ffffffffc020293e:	e54e                	sd	s3,136(sp)
ffffffffc0202940:	e152                	sd	s4,128(sp)
ffffffffc0202942:	fcd6                	sd	s5,120(sp)
ffffffffc0202944:	f8da                	sd	s6,112(sp)
ffffffffc0202946:	f4de                	sd	s7,104(sp)
ffffffffc0202948:	f0e2                	sd	s8,96(sp)
ffffffffc020294a:	ece6                	sd	s9,88(sp)
ffffffffc020294c:	e8ea                	sd	s10,80(sp)
ffffffffc020294e:	e4ee                	sd	s11,72(sp)
ffffffffc0202950:	46a010ef          	jal	ra,ffffffffc0203dba <swapfs_init>
ffffffffc0202954:	0000f697          	auipc	a3,0xf
ffffffffc0202958:	bfc6b683          	ld	a3,-1028(a3) # ffffffffc0211550 <max_swap_offset>
ffffffffc020295c:	010007b7          	lui	a5,0x1000
ffffffffc0202960:	ff968713          	addi	a4,a3,-7
ffffffffc0202964:	17e1                	addi	a5,a5,-8
ffffffffc0202966:	3ee7ef63          	bltu	a5,a4,ffffffffc0202d64 <swap_init+0x430>
ffffffffc020296a:	00007797          	auipc	a5,0x7
ffffffffc020296e:	69678793          	addi	a5,a5,1686 # ffffffffc020a000 <swap_manager_clock>
ffffffffc0202972:	6798                	ld	a4,8(a5)
ffffffffc0202974:	0000fb17          	auipc	s6,0xf
ffffffffc0202978:	be4b0b13          	addi	s6,s6,-1052 # ffffffffc0211558 <sm>
ffffffffc020297c:	00fb3023          	sd	a5,0(s6)
ffffffffc0202980:	9702                	jalr	a4
ffffffffc0202982:	892a                	mv	s2,a0
ffffffffc0202984:	c10d                	beqz	a0,ffffffffc02029a6 <swap_init+0x72>
ffffffffc0202986:	70aa                	ld	ra,168(sp)
ffffffffc0202988:	740a                	ld	s0,160(sp)
ffffffffc020298a:	64ea                	ld	s1,152(sp)
ffffffffc020298c:	69aa                	ld	s3,136(sp)
ffffffffc020298e:	6a0a                	ld	s4,128(sp)
ffffffffc0202990:	7ae6                	ld	s5,120(sp)
ffffffffc0202992:	7b46                	ld	s6,112(sp)
ffffffffc0202994:	7ba6                	ld	s7,104(sp)
ffffffffc0202996:	7c06                	ld	s8,96(sp)
ffffffffc0202998:	6ce6                	ld	s9,88(sp)
ffffffffc020299a:	6d46                	ld	s10,80(sp)
ffffffffc020299c:	6da6                	ld	s11,72(sp)
ffffffffc020299e:	854a                	mv	a0,s2
ffffffffc02029a0:	694a                	ld	s2,144(sp)
ffffffffc02029a2:	614d                	addi	sp,sp,176
ffffffffc02029a4:	8082                	ret
ffffffffc02029a6:	000b3783          	ld	a5,0(s6)
ffffffffc02029aa:	00003517          	auipc	a0,0x3
ffffffffc02029ae:	f1650513          	addi	a0,a0,-234 # ffffffffc02058c0 <default_pmm_manager+0x6f0>
ffffffffc02029b2:	0000e417          	auipc	s0,0xe
ffffffffc02029b6:	68e40413          	addi	s0,s0,1678 # ffffffffc0211040 <free_area>
ffffffffc02029ba:	638c                	ld	a1,0(a5)
ffffffffc02029bc:	4785                	li	a5,1
ffffffffc02029be:	0000f717          	auipc	a4,0xf
ffffffffc02029c2:	b8f72523          	sw	a5,-1142(a4) # ffffffffc0211548 <swap_init_ok>
ffffffffc02029c6:	ef4fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02029ca:	641c                	ld	a5,8(s0)
ffffffffc02029cc:	4d81                	li	s11,0
ffffffffc02029ce:	4d01                	li	s10,0
ffffffffc02029d0:	2e878063          	beq	a5,s0,ffffffffc0202cb0 <swap_init+0x37c>
ffffffffc02029d4:	fe87b703          	ld	a4,-24(a5)
ffffffffc02029d8:	8b09                	andi	a4,a4,2
ffffffffc02029da:	2c070d63          	beqz	a4,ffffffffc0202cb4 <swap_init+0x380>
ffffffffc02029de:	ff87a703          	lw	a4,-8(a5)
ffffffffc02029e2:	679c                	ld	a5,8(a5)
ffffffffc02029e4:	2d05                	addiw	s10,s10,1
ffffffffc02029e6:	01b70dbb          	addw	s11,a4,s11
ffffffffc02029ea:	fe8795e3          	bne	a5,s0,ffffffffc02029d4 <swap_init+0xa0>
ffffffffc02029ee:	84ee                	mv	s1,s11
ffffffffc02029f0:	cc9fe0ef          	jal	ra,ffffffffc02016b8 <nr_free_pages>
ffffffffc02029f4:	48951463          	bne	a0,s1,ffffffffc0202e7c <swap_init+0x548>
ffffffffc02029f8:	866e                	mv	a2,s11
ffffffffc02029fa:	85ea                	mv	a1,s10
ffffffffc02029fc:	00003517          	auipc	a0,0x3
ffffffffc0202a00:	edc50513          	addi	a0,a0,-292 # ffffffffc02058d8 <default_pmm_manager+0x708>
ffffffffc0202a04:	eb6fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0202a08:	307000ef          	jal	ra,ffffffffc020350e <mm_create>
ffffffffc0202a0c:	f42a                	sd	a0,40(sp)
ffffffffc0202a0e:	54050763          	beqz	a0,ffffffffc0202f5c <swap_init+0x628>
ffffffffc0202a12:	0000f797          	auipc	a5,0xf
ffffffffc0202a16:	b5e78793          	addi	a5,a5,-1186 # ffffffffc0211570 <check_mm_struct>
ffffffffc0202a1a:	6398                	ld	a4,0(a5)
ffffffffc0202a1c:	56071063          	bnez	a4,ffffffffc0202f7c <swap_init+0x648>
ffffffffc0202a20:	0000f697          	auipc	a3,0xf
ffffffffc0202a24:	b086b683          	ld	a3,-1272(a3) # ffffffffc0211528 <boot_pgdir>
ffffffffc0202a28:	7622                	ld	a2,40(sp)
ffffffffc0202a2a:	6298                	ld	a4,0(a3)
ffffffffc0202a2c:	f036                	sd	a3,32(sp)
ffffffffc0202a2e:	e390                	sd	a2,0(a5)
ffffffffc0202a30:	ee14                	sd	a3,24(a2)
ffffffffc0202a32:	3e071563          	bnez	a4,ffffffffc0202e1c <swap_init+0x4e8>
ffffffffc0202a36:	6599                	lui	a1,0x6
ffffffffc0202a38:	460d                	li	a2,3
ffffffffc0202a3a:	6505                	lui	a0,0x1
ffffffffc0202a3c:	31b000ef          	jal	ra,ffffffffc0203556 <vma_create>
ffffffffc0202a40:	85aa                	mv	a1,a0
ffffffffc0202a42:	3e050d63          	beqz	a0,ffffffffc0202e3c <swap_init+0x508>
ffffffffc0202a46:	74a2                	ld	s1,40(sp)
ffffffffc0202a48:	8526                	mv	a0,s1
ffffffffc0202a4a:	37b000ef          	jal	ra,ffffffffc02035c4 <insert_vma_struct>
ffffffffc0202a4e:	00003517          	auipc	a0,0x3
ffffffffc0202a52:	efa50513          	addi	a0,a0,-262 # ffffffffc0205948 <default_pmm_manager+0x778>
ffffffffc0202a56:	e64fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0202a5a:	6c88                	ld	a0,24(s1)
ffffffffc0202a5c:	4605                	li	a2,1
ffffffffc0202a5e:	6585                	lui	a1,0x1
ffffffffc0202a60:	c93fe0ef          	jal	ra,ffffffffc02016f2 <get_pte>
ffffffffc0202a64:	3e050c63          	beqz	a0,ffffffffc0202e5c <swap_init+0x528>
ffffffffc0202a68:	00003517          	auipc	a0,0x3
ffffffffc0202a6c:	f3050513          	addi	a0,a0,-208 # ffffffffc0205998 <default_pmm_manager+0x7c8>
ffffffffc0202a70:	0000e497          	auipc	s1,0xe
ffffffffc0202a74:	60848493          	addi	s1,s1,1544 # ffffffffc0211078 <check_rp>
ffffffffc0202a78:	e42fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0202a7c:	0000e997          	auipc	s3,0xe
ffffffffc0202a80:	61c98993          	addi	s3,s3,1564 # ffffffffc0211098 <swap_out_seq_no>
ffffffffc0202a84:	8aa6                	mv	s5,s1
ffffffffc0202a86:	4505                	li	a0,1
ffffffffc0202a88:	b49fe0ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0202a8c:	00aab023          	sd	a0,0(s5) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0202a90:	2a050a63          	beqz	a0,ffffffffc0202d44 <swap_init+0x410>
ffffffffc0202a94:	651c                	ld	a5,8(a0)
ffffffffc0202a96:	8b89                	andi	a5,a5,2
ffffffffc0202a98:	28079663          	bnez	a5,ffffffffc0202d24 <swap_init+0x3f0>
ffffffffc0202a9c:	0aa1                	addi	s5,s5,8
ffffffffc0202a9e:	ff3a94e3          	bne	s5,s3,ffffffffc0202a86 <swap_init+0x152>
ffffffffc0202aa2:	601c                	ld	a5,0(s0)
ffffffffc0202aa4:	00843c83          	ld	s9,8(s0)
ffffffffc0202aa8:	e000                	sd	s0,0(s0)
ffffffffc0202aaa:	f83e                	sd	a5,48(sp)
ffffffffc0202aac:	481c                	lw	a5,16(s0)
ffffffffc0202aae:	e400                	sd	s0,8(s0)
ffffffffc0202ab0:	0000ea97          	auipc	s5,0xe
ffffffffc0202ab4:	5c8a8a93          	addi	s5,s5,1480 # ffffffffc0211078 <check_rp>
ffffffffc0202ab8:	fc3e                	sd	a5,56(sp)
ffffffffc0202aba:	0000e797          	auipc	a5,0xe
ffffffffc0202abe:	5807ab23          	sw	zero,1430(a5) # ffffffffc0211050 <free_area+0x10>
ffffffffc0202ac2:	000ab503          	ld	a0,0(s5)
ffffffffc0202ac6:	4585                	li	a1,1
ffffffffc0202ac8:	0aa1                	addi	s5,s5,8
ffffffffc0202aca:	baffe0ef          	jal	ra,ffffffffc0201678 <free_pages>
ffffffffc0202ace:	ff3a9ae3          	bne	s5,s3,ffffffffc0202ac2 <swap_init+0x18e>
ffffffffc0202ad2:	01042c03          	lw	s8,16(s0)
ffffffffc0202ad6:	4791                	li	a5,4
ffffffffc0202ad8:	4cfc1263          	bne	s8,a5,ffffffffc0202f9c <swap_init+0x668>
ffffffffc0202adc:	00003517          	auipc	a0,0x3
ffffffffc0202ae0:	f4450513          	addi	a0,a0,-188 # ffffffffc0205a20 <default_pmm_manager+0x850>
ffffffffc0202ae4:	dd6fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0202ae8:	6605                	lui	a2,0x1
ffffffffc0202aea:	0000f797          	auipc	a5,0xf
ffffffffc0202aee:	a607af23          	sw	zero,-1410(a5) # ffffffffc0211568 <pgfault_num>
ffffffffc0202af2:	45a9                	li	a1,10
ffffffffc0202af4:	00b60023          	sb	a1,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0202af8:	0000f797          	auipc	a5,0xf
ffffffffc0202afc:	a707a783          	lw	a5,-1424(a5) # ffffffffc0211568 <pgfault_num>
ffffffffc0202b00:	4505                	li	a0,1
ffffffffc0202b02:	0000fa97          	auipc	s5,0xf
ffffffffc0202b06:	a66a8a93          	addi	s5,s5,-1434 # ffffffffc0211568 <pgfault_num>
ffffffffc0202b0a:	40a79963          	bne	a5,a0,ffffffffc0202f1c <swap_init+0x5e8>
ffffffffc0202b0e:	00b60823          	sb	a1,16(a2)
ffffffffc0202b12:	000aa603          	lw	a2,0(s5)
ffffffffc0202b16:	42f61363          	bne	a2,a5,ffffffffc0202f3c <swap_init+0x608>
ffffffffc0202b1a:	6789                	lui	a5,0x2
ffffffffc0202b1c:	462d                	li	a2,11
ffffffffc0202b1e:	00c78023          	sb	a2,0(a5) # 2000 <kern_entry-0xffffffffc01fe000>
ffffffffc0202b22:	000aa583          	lw	a1,0(s5)
ffffffffc0202b26:	4889                	li	a7,2
ffffffffc0202b28:	0005851b          	sext.w	a0,a1
ffffffffc0202b2c:	37159863          	bne	a1,a7,ffffffffc0202e9c <swap_init+0x568>
ffffffffc0202b30:	00c78823          	sb	a2,16(a5)
ffffffffc0202b34:	000aa783          	lw	a5,0(s5)
ffffffffc0202b38:	38a79263          	bne	a5,a0,ffffffffc0202ebc <swap_init+0x588>
ffffffffc0202b3c:	678d                	lui	a5,0x3
ffffffffc0202b3e:	4631                	li	a2,12
ffffffffc0202b40:	00c78023          	sb	a2,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
ffffffffc0202b44:	000aa583          	lw	a1,0(s5)
ffffffffc0202b48:	488d                	li	a7,3
ffffffffc0202b4a:	0005851b          	sext.w	a0,a1
ffffffffc0202b4e:	39159763          	bne	a1,a7,ffffffffc0202edc <swap_init+0x5a8>
ffffffffc0202b52:	00c78823          	sb	a2,16(a5)
ffffffffc0202b56:	000aa783          	lw	a5,0(s5)
ffffffffc0202b5a:	3aa79163          	bne	a5,a0,ffffffffc0202efc <swap_init+0x5c8>
ffffffffc0202b5e:	6791                	lui	a5,0x4
ffffffffc0202b60:	4635                	li	a2,13
ffffffffc0202b62:	00c78023          	sb	a2,0(a5) # 4000 <kern_entry-0xffffffffc01fc000>
ffffffffc0202b66:	000aa583          	lw	a1,0(s5)
ffffffffc0202b6a:	0005851b          	sext.w	a0,a1
ffffffffc0202b6e:	23859763          	bne	a1,s8,ffffffffc0202d9c <swap_init+0x468>
ffffffffc0202b72:	00c78823          	sb	a2,16(a5)
ffffffffc0202b76:	000aa783          	lw	a5,0(s5)
ffffffffc0202b7a:	24a79163          	bne	a5,a0,ffffffffc0202dbc <swap_init+0x488>
ffffffffc0202b7e:	481c                	lw	a5,16(s0)
ffffffffc0202b80:	24079e63          	bnez	a5,ffffffffc0202ddc <swap_init+0x4a8>
ffffffffc0202b84:	0000e797          	auipc	a5,0xe
ffffffffc0202b88:	53c78793          	addi	a5,a5,1340 # ffffffffc02110c0 <swap_in_seq_no>
ffffffffc0202b8c:	0000e617          	auipc	a2,0xe
ffffffffc0202b90:	50c60613          	addi	a2,a2,1292 # ffffffffc0211098 <swap_out_seq_no>
ffffffffc0202b94:	0000e517          	auipc	a0,0xe
ffffffffc0202b98:	55450513          	addi	a0,a0,1364 # ffffffffc02110e8 <pra_list_head>
ffffffffc0202b9c:	55fd                	li	a1,-1
ffffffffc0202b9e:	c38c                	sw	a1,0(a5)
ffffffffc0202ba0:	c20c                	sw	a1,0(a2)
ffffffffc0202ba2:	0791                	addi	a5,a5,4
ffffffffc0202ba4:	0611                	addi	a2,a2,4
ffffffffc0202ba6:	fea79ce3          	bne	a5,a0,ffffffffc0202b9e <swap_init+0x26a>
ffffffffc0202baa:	0000e897          	auipc	a7,0xe
ffffffffc0202bae:	4ae88893          	addi	a7,a7,1198 # ffffffffc0211058 <check_ptep>
ffffffffc0202bb2:	0000e317          	auipc	t1,0xe
ffffffffc0202bb6:	4c630313          	addi	t1,t1,1222 # ffffffffc0211078 <check_rp>
ffffffffc0202bba:	6585                	lui	a1,0x1
ffffffffc0202bbc:	0000fa17          	auipc	s4,0xf
ffffffffc0202bc0:	97ca0a13          	addi	s4,s4,-1668 # ffffffffc0211538 <npage>
ffffffffc0202bc4:	0000fb97          	auipc	s7,0xf
ffffffffc0202bc8:	97cb8b93          	addi	s7,s7,-1668 # ffffffffc0211540 <pages>
ffffffffc0202bcc:	00003c17          	auipc	s8,0x3
ffffffffc0202bd0:	784c0c13          	addi	s8,s8,1924 # ffffffffc0206350 <nbase>
ffffffffc0202bd4:	7502                	ld	a0,32(sp)
ffffffffc0202bd6:	0008b023          	sd	zero,0(a7)
ffffffffc0202bda:	4601                	li	a2,0
ffffffffc0202bdc:	ec1a                	sd	t1,24(sp)
ffffffffc0202bde:	e82e                	sd	a1,16(sp)
ffffffffc0202be0:	e446                	sd	a7,8(sp)
ffffffffc0202be2:	b11fe0ef          	jal	ra,ffffffffc02016f2 <get_pte>
ffffffffc0202be6:	68a2                	ld	a7,8(sp)
ffffffffc0202be8:	65c2                	ld	a1,16(sp)
ffffffffc0202bea:	6362                	ld	t1,24(sp)
ffffffffc0202bec:	00a8b023          	sd	a0,0(a7)
ffffffffc0202bf0:	18050663          	beqz	a0,ffffffffc0202d7c <swap_init+0x448>
ffffffffc0202bf4:	611c                	ld	a5,0(a0)
ffffffffc0202bf6:	0017f613          	andi	a2,a5,1
ffffffffc0202bfa:	0e060d63          	beqz	a2,ffffffffc0202cf4 <swap_init+0x3c0>
ffffffffc0202bfe:	000a3603          	ld	a2,0(s4)
ffffffffc0202c02:	078a                	slli	a5,a5,0x2
ffffffffc0202c04:	83b1                	srli	a5,a5,0xc
ffffffffc0202c06:	10c7f363          	bgeu	a5,a2,ffffffffc0202d0c <swap_init+0x3d8>
ffffffffc0202c0a:	000c3603          	ld	a2,0(s8)
ffffffffc0202c0e:	000bbf83          	ld	t6,0(s7)
ffffffffc0202c12:	00033503          	ld	a0,0(t1)
ffffffffc0202c16:	8f91                	sub	a5,a5,a2
ffffffffc0202c18:	00379613          	slli	a2,a5,0x3
ffffffffc0202c1c:	97b2                	add	a5,a5,a2
ffffffffc0202c1e:	078e                	slli	a5,a5,0x3
ffffffffc0202c20:	6705                	lui	a4,0x1
ffffffffc0202c22:	97fe                	add	a5,a5,t6
ffffffffc0202c24:	0321                	addi	t1,t1,8
ffffffffc0202c26:	08a1                	addi	a7,a7,8
ffffffffc0202c28:	95ba                	add	a1,a1,a4
ffffffffc0202c2a:	0af51563          	bne	a0,a5,ffffffffc0202cd4 <swap_init+0x3a0>
ffffffffc0202c2e:	6795                	lui	a5,0x5
ffffffffc0202c30:	faf592e3          	bne	a1,a5,ffffffffc0202bd4 <swap_init+0x2a0>
ffffffffc0202c34:	00003517          	auipc	a0,0x3
ffffffffc0202c38:	eb450513          	addi	a0,a0,-332 # ffffffffc0205ae8 <default_pmm_manager+0x918>
ffffffffc0202c3c:	c7efd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0202c40:	000aa583          	lw	a1,0(s5)
ffffffffc0202c44:	00003517          	auipc	a0,0x3
ffffffffc0202c48:	ecc50513          	addi	a0,a0,-308 # ffffffffc0205b10 <default_pmm_manager+0x940>
ffffffffc0202c4c:	c6efd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0202c50:	000b3783          	ld	a5,0(s6)
ffffffffc0202c54:	7f9c                	ld	a5,56(a5)
ffffffffc0202c56:	9782                	jalr	a5
ffffffffc0202c58:	1a051263          	bnez	a0,ffffffffc0202dfc <swap_init+0x4c8>
ffffffffc0202c5c:	6088                	ld	a0,0(s1)
ffffffffc0202c5e:	4585                	li	a1,1
ffffffffc0202c60:	04a1                	addi	s1,s1,8
ffffffffc0202c62:	a17fe0ef          	jal	ra,ffffffffc0201678 <free_pages>
ffffffffc0202c66:	ff349be3          	bne	s1,s3,ffffffffc0202c5c <swap_init+0x328>
ffffffffc0202c6a:	7522                	ld	a0,40(sp)
ffffffffc0202c6c:	229000ef          	jal	ra,ffffffffc0203694 <mm_destroy>
ffffffffc0202c70:	77e2                	ld	a5,56(sp)
ffffffffc0202c72:	01943423          	sd	s9,8(s0)
ffffffffc0202c76:	c81c                	sw	a5,16(s0)
ffffffffc0202c78:	77c2                	ld	a5,48(sp)
ffffffffc0202c7a:	e01c                	sd	a5,0(s0)
ffffffffc0202c7c:	008c8b63          	beq	s9,s0,ffffffffc0202c92 <swap_init+0x35e>
ffffffffc0202c80:	ff8ca783          	lw	a5,-8(s9)
ffffffffc0202c84:	008cbc83          	ld	s9,8(s9)
ffffffffc0202c88:	3d7d                	addiw	s10,s10,-1
ffffffffc0202c8a:	40fd8dbb          	subw	s11,s11,a5
ffffffffc0202c8e:	fe8c99e3          	bne	s9,s0,ffffffffc0202c80 <swap_init+0x34c>
ffffffffc0202c92:	866e                	mv	a2,s11
ffffffffc0202c94:	85ea                	mv	a1,s10
ffffffffc0202c96:	00003517          	auipc	a0,0x3
ffffffffc0202c9a:	ea250513          	addi	a0,a0,-350 # ffffffffc0205b38 <default_pmm_manager+0x968>
ffffffffc0202c9e:	c1cfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0202ca2:	00003517          	auipc	a0,0x3
ffffffffc0202ca6:	eb650513          	addi	a0,a0,-330 # ffffffffc0205b58 <default_pmm_manager+0x988>
ffffffffc0202caa:	c10fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0202cae:	b9e1                	j	ffffffffc0202986 <swap_init+0x52>
ffffffffc0202cb0:	4481                	li	s1,0
ffffffffc0202cb2:	bb3d                	j	ffffffffc02029f0 <swap_init+0xbc>
ffffffffc0202cb4:	00002697          	auipc	a3,0x2
ffffffffc0202cb8:	15c68693          	addi	a3,a3,348 # ffffffffc0204e10 <commands+0x728>
ffffffffc0202cbc:	00002617          	auipc	a2,0x2
ffffffffc0202cc0:	16460613          	addi	a2,a2,356 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202cc4:	0b900593          	li	a1,185
ffffffffc0202cc8:	00003517          	auipc	a0,0x3
ffffffffc0202ccc:	be850513          	addi	a0,a0,-1048 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202cd0:	e92fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202cd4:	00003697          	auipc	a3,0x3
ffffffffc0202cd8:	dec68693          	addi	a3,a3,-532 # ffffffffc0205ac0 <default_pmm_manager+0x8f0>
ffffffffc0202cdc:	00002617          	auipc	a2,0x2
ffffffffc0202ce0:	14460613          	addi	a2,a2,324 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202ce4:	0fb00593          	li	a1,251
ffffffffc0202ce8:	00003517          	auipc	a0,0x3
ffffffffc0202cec:	bc850513          	addi	a0,a0,-1080 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202cf0:	e72fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202cf4:	00002617          	auipc	a2,0x2
ffffffffc0202cf8:	54460613          	addi	a2,a2,1348 # ffffffffc0205238 <default_pmm_manager+0x68>
ffffffffc0202cfc:	07000593          	li	a1,112
ffffffffc0202d00:	00002517          	auipc	a0,0x2
ffffffffc0202d04:	52850513          	addi	a0,a0,1320 # ffffffffc0205228 <default_pmm_manager+0x58>
ffffffffc0202d08:	e5afd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202d0c:	00002617          	auipc	a2,0x2
ffffffffc0202d10:	4fc60613          	addi	a2,a2,1276 # ffffffffc0205208 <default_pmm_manager+0x38>
ffffffffc0202d14:	06500593          	li	a1,101
ffffffffc0202d18:	00002517          	auipc	a0,0x2
ffffffffc0202d1c:	51050513          	addi	a0,a0,1296 # ffffffffc0205228 <default_pmm_manager+0x58>
ffffffffc0202d20:	e42fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202d24:	00003697          	auipc	a3,0x3
ffffffffc0202d28:	cb468693          	addi	a3,a3,-844 # ffffffffc02059d8 <default_pmm_manager+0x808>
ffffffffc0202d2c:	00002617          	auipc	a2,0x2
ffffffffc0202d30:	0f460613          	addi	a2,a2,244 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202d34:	0db00593          	li	a1,219
ffffffffc0202d38:	00003517          	auipc	a0,0x3
ffffffffc0202d3c:	b7850513          	addi	a0,a0,-1160 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202d40:	e22fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202d44:	00003697          	auipc	a3,0x3
ffffffffc0202d48:	c7c68693          	addi	a3,a3,-900 # ffffffffc02059c0 <default_pmm_manager+0x7f0>
ffffffffc0202d4c:	00002617          	auipc	a2,0x2
ffffffffc0202d50:	0d460613          	addi	a2,a2,212 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202d54:	0da00593          	li	a1,218
ffffffffc0202d58:	00003517          	auipc	a0,0x3
ffffffffc0202d5c:	b5850513          	addi	a0,a0,-1192 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202d60:	e02fd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202d64:	00003617          	auipc	a2,0x3
ffffffffc0202d68:	b2c60613          	addi	a2,a2,-1236 # ffffffffc0205890 <default_pmm_manager+0x6c0>
ffffffffc0202d6c:	02700593          	li	a1,39
ffffffffc0202d70:	00003517          	auipc	a0,0x3
ffffffffc0202d74:	b4050513          	addi	a0,a0,-1216 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202d78:	deafd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202d7c:	00003697          	auipc	a3,0x3
ffffffffc0202d80:	d2c68693          	addi	a3,a3,-724 # ffffffffc0205aa8 <default_pmm_manager+0x8d8>
ffffffffc0202d84:	00002617          	auipc	a2,0x2
ffffffffc0202d88:	09c60613          	addi	a2,a2,156 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202d8c:	0fa00593          	li	a1,250
ffffffffc0202d90:	00003517          	auipc	a0,0x3
ffffffffc0202d94:	b2050513          	addi	a0,a0,-1248 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202d98:	dcafd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202d9c:	00003697          	auipc	a3,0x3
ffffffffc0202da0:	cf468693          	addi	a3,a3,-780 # ffffffffc0205a90 <default_pmm_manager+0x8c0>
ffffffffc0202da4:	00002617          	auipc	a2,0x2
ffffffffc0202da8:	07c60613          	addi	a2,a2,124 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202dac:	09b00593          	li	a1,155
ffffffffc0202db0:	00003517          	auipc	a0,0x3
ffffffffc0202db4:	b0050513          	addi	a0,a0,-1280 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202db8:	daafd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202dbc:	00003697          	auipc	a3,0x3
ffffffffc0202dc0:	cd468693          	addi	a3,a3,-812 # ffffffffc0205a90 <default_pmm_manager+0x8c0>
ffffffffc0202dc4:	00002617          	auipc	a2,0x2
ffffffffc0202dc8:	05c60613          	addi	a2,a2,92 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202dcc:	09d00593          	li	a1,157
ffffffffc0202dd0:	00003517          	auipc	a0,0x3
ffffffffc0202dd4:	ae050513          	addi	a0,a0,-1312 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202dd8:	d8afd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202ddc:	00002697          	auipc	a3,0x2
ffffffffc0202de0:	21c68693          	addi	a3,a3,540 # ffffffffc0204ff8 <commands+0x910>
ffffffffc0202de4:	00002617          	auipc	a2,0x2
ffffffffc0202de8:	03c60613          	addi	a2,a2,60 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202dec:	0f100593          	li	a1,241
ffffffffc0202df0:	00003517          	auipc	a0,0x3
ffffffffc0202df4:	ac050513          	addi	a0,a0,-1344 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202df8:	d6afd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202dfc:	00003697          	auipc	a3,0x3
ffffffffc0202e00:	d2c68693          	addi	a3,a3,-724 # ffffffffc0205b28 <default_pmm_manager+0x958>
ffffffffc0202e04:	00002617          	auipc	a2,0x2
ffffffffc0202e08:	01c60613          	addi	a2,a2,28 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202e0c:	10300593          	li	a1,259
ffffffffc0202e10:	00003517          	auipc	a0,0x3
ffffffffc0202e14:	aa050513          	addi	a0,a0,-1376 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202e18:	d4afd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202e1c:	00003697          	auipc	a3,0x3
ffffffffc0202e20:	b0c68693          	addi	a3,a3,-1268 # ffffffffc0205928 <default_pmm_manager+0x758>
ffffffffc0202e24:	00002617          	auipc	a2,0x2
ffffffffc0202e28:	ffc60613          	addi	a2,a2,-4 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202e2c:	0c900593          	li	a1,201
ffffffffc0202e30:	00003517          	auipc	a0,0x3
ffffffffc0202e34:	a8050513          	addi	a0,a0,-1408 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202e38:	d2afd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202e3c:	00003697          	auipc	a3,0x3
ffffffffc0202e40:	afc68693          	addi	a3,a3,-1284 # ffffffffc0205938 <default_pmm_manager+0x768>
ffffffffc0202e44:	00002617          	auipc	a2,0x2
ffffffffc0202e48:	fdc60613          	addi	a2,a2,-36 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202e4c:	0cc00593          	li	a1,204
ffffffffc0202e50:	00003517          	auipc	a0,0x3
ffffffffc0202e54:	a6050513          	addi	a0,a0,-1440 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202e58:	d0afd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202e5c:	00003697          	auipc	a3,0x3
ffffffffc0202e60:	b2468693          	addi	a3,a3,-1244 # ffffffffc0205980 <default_pmm_manager+0x7b0>
ffffffffc0202e64:	00002617          	auipc	a2,0x2
ffffffffc0202e68:	fbc60613          	addi	a2,a2,-68 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202e6c:	0d400593          	li	a1,212
ffffffffc0202e70:	00003517          	auipc	a0,0x3
ffffffffc0202e74:	a4050513          	addi	a0,a0,-1472 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202e78:	ceafd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202e7c:	00002697          	auipc	a3,0x2
ffffffffc0202e80:	fd468693          	addi	a3,a3,-44 # ffffffffc0204e50 <commands+0x768>
ffffffffc0202e84:	00002617          	auipc	a2,0x2
ffffffffc0202e88:	f9c60613          	addi	a2,a2,-100 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202e8c:	0bc00593          	li	a1,188
ffffffffc0202e90:	00003517          	auipc	a0,0x3
ffffffffc0202e94:	a2050513          	addi	a0,a0,-1504 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202e98:	ccafd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202e9c:	00003697          	auipc	a3,0x3
ffffffffc0202ea0:	bc468693          	addi	a3,a3,-1084 # ffffffffc0205a60 <default_pmm_manager+0x890>
ffffffffc0202ea4:	00002617          	auipc	a2,0x2
ffffffffc0202ea8:	f7c60613          	addi	a2,a2,-132 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202eac:	09300593          	li	a1,147
ffffffffc0202eb0:	00003517          	auipc	a0,0x3
ffffffffc0202eb4:	a0050513          	addi	a0,a0,-1536 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202eb8:	caafd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202ebc:	00003697          	auipc	a3,0x3
ffffffffc0202ec0:	ba468693          	addi	a3,a3,-1116 # ffffffffc0205a60 <default_pmm_manager+0x890>
ffffffffc0202ec4:	00002617          	auipc	a2,0x2
ffffffffc0202ec8:	f5c60613          	addi	a2,a2,-164 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202ecc:	09500593          	li	a1,149
ffffffffc0202ed0:	00003517          	auipc	a0,0x3
ffffffffc0202ed4:	9e050513          	addi	a0,a0,-1568 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202ed8:	c8afd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202edc:	00003697          	auipc	a3,0x3
ffffffffc0202ee0:	b9c68693          	addi	a3,a3,-1124 # ffffffffc0205a78 <default_pmm_manager+0x8a8>
ffffffffc0202ee4:	00002617          	auipc	a2,0x2
ffffffffc0202ee8:	f3c60613          	addi	a2,a2,-196 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202eec:	09700593          	li	a1,151
ffffffffc0202ef0:	00003517          	auipc	a0,0x3
ffffffffc0202ef4:	9c050513          	addi	a0,a0,-1600 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202ef8:	c6afd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202efc:	00003697          	auipc	a3,0x3
ffffffffc0202f00:	b7c68693          	addi	a3,a3,-1156 # ffffffffc0205a78 <default_pmm_manager+0x8a8>
ffffffffc0202f04:	00002617          	auipc	a2,0x2
ffffffffc0202f08:	f1c60613          	addi	a2,a2,-228 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202f0c:	09900593          	li	a1,153
ffffffffc0202f10:	00003517          	auipc	a0,0x3
ffffffffc0202f14:	9a050513          	addi	a0,a0,-1632 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202f18:	c4afd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202f1c:	00003697          	auipc	a3,0x3
ffffffffc0202f20:	b2c68693          	addi	a3,a3,-1236 # ffffffffc0205a48 <default_pmm_manager+0x878>
ffffffffc0202f24:	00002617          	auipc	a2,0x2
ffffffffc0202f28:	efc60613          	addi	a2,a2,-260 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202f2c:	08f00593          	li	a1,143
ffffffffc0202f30:	00003517          	auipc	a0,0x3
ffffffffc0202f34:	98050513          	addi	a0,a0,-1664 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202f38:	c2afd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202f3c:	00003697          	auipc	a3,0x3
ffffffffc0202f40:	b0c68693          	addi	a3,a3,-1268 # ffffffffc0205a48 <default_pmm_manager+0x878>
ffffffffc0202f44:	00002617          	auipc	a2,0x2
ffffffffc0202f48:	edc60613          	addi	a2,a2,-292 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202f4c:	09100593          	li	a1,145
ffffffffc0202f50:	00003517          	auipc	a0,0x3
ffffffffc0202f54:	96050513          	addi	a0,a0,-1696 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202f58:	c0afd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202f5c:	00003697          	auipc	a3,0x3
ffffffffc0202f60:	9a468693          	addi	a3,a3,-1628 # ffffffffc0205900 <default_pmm_manager+0x730>
ffffffffc0202f64:	00002617          	auipc	a2,0x2
ffffffffc0202f68:	ebc60613          	addi	a2,a2,-324 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202f6c:	0c100593          	li	a1,193
ffffffffc0202f70:	00003517          	auipc	a0,0x3
ffffffffc0202f74:	94050513          	addi	a0,a0,-1728 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202f78:	beafd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202f7c:	00003697          	auipc	a3,0x3
ffffffffc0202f80:	99468693          	addi	a3,a3,-1644 # ffffffffc0205910 <default_pmm_manager+0x740>
ffffffffc0202f84:	00002617          	auipc	a2,0x2
ffffffffc0202f88:	e9c60613          	addi	a2,a2,-356 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202f8c:	0c400593          	li	a1,196
ffffffffc0202f90:	00003517          	auipc	a0,0x3
ffffffffc0202f94:	92050513          	addi	a0,a0,-1760 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202f98:	bcafd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0202f9c:	00003697          	auipc	a3,0x3
ffffffffc0202fa0:	a5c68693          	addi	a3,a3,-1444 # ffffffffc02059f8 <default_pmm_manager+0x828>
ffffffffc0202fa4:	00002617          	auipc	a2,0x2
ffffffffc0202fa8:	e7c60613          	addi	a2,a2,-388 # ffffffffc0204e20 <commands+0x738>
ffffffffc0202fac:	0e900593          	li	a1,233
ffffffffc0202fb0:	00003517          	auipc	a0,0x3
ffffffffc0202fb4:	90050513          	addi	a0,a0,-1792 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc0202fb8:	baafd0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc0202fbc <swap_init_mm>:
ffffffffc0202fbc:	0000e797          	auipc	a5,0xe
ffffffffc0202fc0:	59c7b783          	ld	a5,1436(a5) # ffffffffc0211558 <sm>
ffffffffc0202fc4:	6b9c                	ld	a5,16(a5)
ffffffffc0202fc6:	8782                	jr	a5

ffffffffc0202fc8 <swap_map_swappable>:
ffffffffc0202fc8:	0000e797          	auipc	a5,0xe
ffffffffc0202fcc:	5907b783          	ld	a5,1424(a5) # ffffffffc0211558 <sm>
ffffffffc0202fd0:	739c                	ld	a5,32(a5)
ffffffffc0202fd2:	8782                	jr	a5

ffffffffc0202fd4 <swap_out>:
ffffffffc0202fd4:	711d                	addi	sp,sp,-96
ffffffffc0202fd6:	ec86                	sd	ra,88(sp)
ffffffffc0202fd8:	e8a2                	sd	s0,80(sp)
ffffffffc0202fda:	e4a6                	sd	s1,72(sp)
ffffffffc0202fdc:	e0ca                	sd	s2,64(sp)
ffffffffc0202fde:	fc4e                	sd	s3,56(sp)
ffffffffc0202fe0:	f852                	sd	s4,48(sp)
ffffffffc0202fe2:	f456                	sd	s5,40(sp)
ffffffffc0202fe4:	f05a                	sd	s6,32(sp)
ffffffffc0202fe6:	ec5e                	sd	s7,24(sp)
ffffffffc0202fe8:	e862                	sd	s8,16(sp)
ffffffffc0202fea:	cde9                	beqz	a1,ffffffffc02030c4 <swap_out+0xf0>
ffffffffc0202fec:	8a2e                	mv	s4,a1
ffffffffc0202fee:	892a                	mv	s2,a0
ffffffffc0202ff0:	8ab2                	mv	s5,a2
ffffffffc0202ff2:	4401                	li	s0,0
ffffffffc0202ff4:	0000e997          	auipc	s3,0xe
ffffffffc0202ff8:	56498993          	addi	s3,s3,1380 # ffffffffc0211558 <sm>
ffffffffc0202ffc:	00003b17          	auipc	s6,0x3
ffffffffc0203000:	bdcb0b13          	addi	s6,s6,-1060 # ffffffffc0205bd8 <default_pmm_manager+0xa08>
ffffffffc0203004:	00003b97          	auipc	s7,0x3
ffffffffc0203008:	bbcb8b93          	addi	s7,s7,-1092 # ffffffffc0205bc0 <default_pmm_manager+0x9f0>
ffffffffc020300c:	a825                	j	ffffffffc0203044 <swap_out+0x70>
ffffffffc020300e:	67a2                	ld	a5,8(sp)
ffffffffc0203010:	8626                	mv	a2,s1
ffffffffc0203012:	85a2                	mv	a1,s0
ffffffffc0203014:	63b4                	ld	a3,64(a5)
ffffffffc0203016:	855a                	mv	a0,s6
ffffffffc0203018:	2405                	addiw	s0,s0,1
ffffffffc020301a:	82b1                	srli	a3,a3,0xc
ffffffffc020301c:	0685                	addi	a3,a3,1
ffffffffc020301e:	89cfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203022:	6522                	ld	a0,8(sp)
ffffffffc0203024:	4585                	li	a1,1
ffffffffc0203026:	613c                	ld	a5,64(a0)
ffffffffc0203028:	83b1                	srli	a5,a5,0xc
ffffffffc020302a:	0785                	addi	a5,a5,1
ffffffffc020302c:	07a2                	slli	a5,a5,0x8
ffffffffc020302e:	00fc3023          	sd	a5,0(s8)
ffffffffc0203032:	e46fe0ef          	jal	ra,ffffffffc0201678 <free_pages>
ffffffffc0203036:	01893503          	ld	a0,24(s2)
ffffffffc020303a:	85a6                	mv	a1,s1
ffffffffc020303c:	e98ff0ef          	jal	ra,ffffffffc02026d4 <tlb_invalidate>
ffffffffc0203040:	048a0d63          	beq	s4,s0,ffffffffc020309a <swap_out+0xc6>
ffffffffc0203044:	0009b783          	ld	a5,0(s3)
ffffffffc0203048:	8656                	mv	a2,s5
ffffffffc020304a:	002c                	addi	a1,sp,8
ffffffffc020304c:	7b9c                	ld	a5,48(a5)
ffffffffc020304e:	854a                	mv	a0,s2
ffffffffc0203050:	9782                	jalr	a5
ffffffffc0203052:	e12d                	bnez	a0,ffffffffc02030b4 <swap_out+0xe0>
ffffffffc0203054:	67a2                	ld	a5,8(sp)
ffffffffc0203056:	01893503          	ld	a0,24(s2)
ffffffffc020305a:	4601                	li	a2,0
ffffffffc020305c:	63a4                	ld	s1,64(a5)
ffffffffc020305e:	85a6                	mv	a1,s1
ffffffffc0203060:	e92fe0ef          	jal	ra,ffffffffc02016f2 <get_pte>
ffffffffc0203064:	611c                	ld	a5,0(a0)
ffffffffc0203066:	8c2a                	mv	s8,a0
ffffffffc0203068:	8b85                	andi	a5,a5,1
ffffffffc020306a:	cfb9                	beqz	a5,ffffffffc02030c8 <swap_out+0xf4>
ffffffffc020306c:	65a2                	ld	a1,8(sp)
ffffffffc020306e:	61bc                	ld	a5,64(a1)
ffffffffc0203070:	83b1                	srli	a5,a5,0xc
ffffffffc0203072:	0785                	addi	a5,a5,1
ffffffffc0203074:	00879513          	slli	a0,a5,0x8
ffffffffc0203078:	615000ef          	jal	ra,ffffffffc0203e8c <swapfs_write>
ffffffffc020307c:	d949                	beqz	a0,ffffffffc020300e <swap_out+0x3a>
ffffffffc020307e:	855e                	mv	a0,s7
ffffffffc0203080:	83afd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203084:	0009b783          	ld	a5,0(s3)
ffffffffc0203088:	6622                	ld	a2,8(sp)
ffffffffc020308a:	4681                	li	a3,0
ffffffffc020308c:	739c                	ld	a5,32(a5)
ffffffffc020308e:	85a6                	mv	a1,s1
ffffffffc0203090:	854a                	mv	a0,s2
ffffffffc0203092:	2405                	addiw	s0,s0,1
ffffffffc0203094:	9782                	jalr	a5
ffffffffc0203096:	fa8a17e3          	bne	s4,s0,ffffffffc0203044 <swap_out+0x70>
ffffffffc020309a:	60e6                	ld	ra,88(sp)
ffffffffc020309c:	8522                	mv	a0,s0
ffffffffc020309e:	6446                	ld	s0,80(sp)
ffffffffc02030a0:	64a6                	ld	s1,72(sp)
ffffffffc02030a2:	6906                	ld	s2,64(sp)
ffffffffc02030a4:	79e2                	ld	s3,56(sp)
ffffffffc02030a6:	7a42                	ld	s4,48(sp)
ffffffffc02030a8:	7aa2                	ld	s5,40(sp)
ffffffffc02030aa:	7b02                	ld	s6,32(sp)
ffffffffc02030ac:	6be2                	ld	s7,24(sp)
ffffffffc02030ae:	6c42                	ld	s8,16(sp)
ffffffffc02030b0:	6125                	addi	sp,sp,96
ffffffffc02030b2:	8082                	ret
ffffffffc02030b4:	85a2                	mv	a1,s0
ffffffffc02030b6:	00003517          	auipc	a0,0x3
ffffffffc02030ba:	ac250513          	addi	a0,a0,-1342 # ffffffffc0205b78 <default_pmm_manager+0x9a8>
ffffffffc02030be:	ffdfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02030c2:	bfe1                	j	ffffffffc020309a <swap_out+0xc6>
ffffffffc02030c4:	4401                	li	s0,0
ffffffffc02030c6:	bfd1                	j	ffffffffc020309a <swap_out+0xc6>
ffffffffc02030c8:	00003697          	auipc	a3,0x3
ffffffffc02030cc:	ae068693          	addi	a3,a3,-1312 # ffffffffc0205ba8 <default_pmm_manager+0x9d8>
ffffffffc02030d0:	00002617          	auipc	a2,0x2
ffffffffc02030d4:	d5060613          	addi	a2,a2,-688 # ffffffffc0204e20 <commands+0x738>
ffffffffc02030d8:	06300593          	li	a1,99
ffffffffc02030dc:	00002517          	auipc	a0,0x2
ffffffffc02030e0:	7d450513          	addi	a0,a0,2004 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc02030e4:	a7efd0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc02030e8 <swap_in>:
ffffffffc02030e8:	7179                	addi	sp,sp,-48
ffffffffc02030ea:	e84a                	sd	s2,16(sp)
ffffffffc02030ec:	892a                	mv	s2,a0
ffffffffc02030ee:	4505                	li	a0,1
ffffffffc02030f0:	ec26                	sd	s1,24(sp)
ffffffffc02030f2:	e44e                	sd	s3,8(sp)
ffffffffc02030f4:	f406                	sd	ra,40(sp)
ffffffffc02030f6:	f022                	sd	s0,32(sp)
ffffffffc02030f8:	84ae                	mv	s1,a1
ffffffffc02030fa:	89b2                	mv	s3,a2
ffffffffc02030fc:	cd4fe0ef          	jal	ra,ffffffffc02015d0 <alloc_pages>
ffffffffc0203100:	c129                	beqz	a0,ffffffffc0203142 <swap_in+0x5a>
ffffffffc0203102:	842a                	mv	s0,a0
ffffffffc0203104:	01893503          	ld	a0,24(s2)
ffffffffc0203108:	4601                	li	a2,0
ffffffffc020310a:	85a6                	mv	a1,s1
ffffffffc020310c:	de6fe0ef          	jal	ra,ffffffffc02016f2 <get_pte>
ffffffffc0203110:	892a                	mv	s2,a0
ffffffffc0203112:	6108                	ld	a0,0(a0)
ffffffffc0203114:	85a2                	mv	a1,s0
ffffffffc0203116:	4dd000ef          	jal	ra,ffffffffc0203df2 <swapfs_read>
ffffffffc020311a:	00093583          	ld	a1,0(s2)
ffffffffc020311e:	8626                	mv	a2,s1
ffffffffc0203120:	00003517          	auipc	a0,0x3
ffffffffc0203124:	b0850513          	addi	a0,a0,-1272 # ffffffffc0205c28 <default_pmm_manager+0xa58>
ffffffffc0203128:	81a1                	srli	a1,a1,0x8
ffffffffc020312a:	f91fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020312e:	70a2                	ld	ra,40(sp)
ffffffffc0203130:	0089b023          	sd	s0,0(s3)
ffffffffc0203134:	7402                	ld	s0,32(sp)
ffffffffc0203136:	64e2                	ld	s1,24(sp)
ffffffffc0203138:	6942                	ld	s2,16(sp)
ffffffffc020313a:	69a2                	ld	s3,8(sp)
ffffffffc020313c:	4501                	li	a0,0
ffffffffc020313e:	6145                	addi	sp,sp,48
ffffffffc0203140:	8082                	ret
ffffffffc0203142:	00003697          	auipc	a3,0x3
ffffffffc0203146:	ad668693          	addi	a3,a3,-1322 # ffffffffc0205c18 <default_pmm_manager+0xa48>
ffffffffc020314a:	00002617          	auipc	a2,0x2
ffffffffc020314e:	cd660613          	addi	a2,a2,-810 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203152:	07c00593          	li	a1,124
ffffffffc0203156:	00002517          	auipc	a0,0x2
ffffffffc020315a:	75a50513          	addi	a0,a0,1882 # ffffffffc02058b0 <default_pmm_manager+0x6e0>
ffffffffc020315e:	a04fd0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc0203162 <_clock_init_mm>:
ffffffffc0203162:	0000e797          	auipc	a5,0xe
ffffffffc0203166:	f8678793          	addi	a5,a5,-122 # ffffffffc02110e8 <pra_list_head>
ffffffffc020316a:	f51c                	sd	a5,40(a0)
ffffffffc020316c:	e79c                	sd	a5,8(a5)
ffffffffc020316e:	e39c                	sd	a5,0(a5)
ffffffffc0203170:	0000e717          	auipc	a4,0xe
ffffffffc0203174:	3ef73823          	sd	a5,1008(a4) # ffffffffc0211560 <curr_ptr>
ffffffffc0203178:	4501                	li	a0,0
ffffffffc020317a:	8082                	ret

ffffffffc020317c <_clock_init>:
ffffffffc020317c:	4501                	li	a0,0
ffffffffc020317e:	8082                	ret

ffffffffc0203180 <_clock_set_unswappable>:
ffffffffc0203180:	4501                	li	a0,0
ffffffffc0203182:	8082                	ret

ffffffffc0203184 <_clock_tick_event>:
ffffffffc0203184:	4501                	li	a0,0
ffffffffc0203186:	8082                	ret

ffffffffc0203188 <_clock_check_swap>:
ffffffffc0203188:	1141                	addi	sp,sp,-16
ffffffffc020318a:	4731                	li	a4,12
ffffffffc020318c:	e406                	sd	ra,8(sp)
ffffffffc020318e:	678d                	lui	a5,0x3
ffffffffc0203190:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
ffffffffc0203194:	0000e717          	auipc	a4,0xe
ffffffffc0203198:	3d472703          	lw	a4,980(a4) # ffffffffc0211568 <pgfault_num>
ffffffffc020319c:	4691                	li	a3,4
ffffffffc020319e:	0ad71663          	bne	a4,a3,ffffffffc020324a <_clock_check_swap+0xc2>
ffffffffc02031a2:	6685                	lui	a3,0x1
ffffffffc02031a4:	4629                	li	a2,10
ffffffffc02031a6:	00c68023          	sb	a2,0(a3) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02031aa:	0000e797          	auipc	a5,0xe
ffffffffc02031ae:	3be78793          	addi	a5,a5,958 # ffffffffc0211568 <pgfault_num>
ffffffffc02031b2:	4394                	lw	a3,0(a5)
ffffffffc02031b4:	0006861b          	sext.w	a2,a3
ffffffffc02031b8:	20e69963          	bne	a3,a4,ffffffffc02033ca <_clock_check_swap+0x242>
ffffffffc02031bc:	6711                	lui	a4,0x4
ffffffffc02031be:	46b5                	li	a3,13
ffffffffc02031c0:	00d70023          	sb	a3,0(a4) # 4000 <kern_entry-0xffffffffc01fc000>
ffffffffc02031c4:	4398                	lw	a4,0(a5)
ffffffffc02031c6:	0007069b          	sext.w	a3,a4
ffffffffc02031ca:	1ec71063          	bne	a4,a2,ffffffffc02033aa <_clock_check_swap+0x222>
ffffffffc02031ce:	6709                	lui	a4,0x2
ffffffffc02031d0:	462d                	li	a2,11
ffffffffc02031d2:	00c70023          	sb	a2,0(a4) # 2000 <kern_entry-0xffffffffc01fe000>
ffffffffc02031d6:	4398                	lw	a4,0(a5)
ffffffffc02031d8:	1ad71963          	bne	a4,a3,ffffffffc020338a <_clock_check_swap+0x202>
ffffffffc02031dc:	6715                	lui	a4,0x5
ffffffffc02031de:	46b9                	li	a3,14
ffffffffc02031e0:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
ffffffffc02031e4:	4398                	lw	a4,0(a5)
ffffffffc02031e6:	4615                	li	a2,5
ffffffffc02031e8:	0007069b          	sext.w	a3,a4
ffffffffc02031ec:	16c71f63          	bne	a4,a2,ffffffffc020336a <_clock_check_swap+0x1e2>
ffffffffc02031f0:	4398                	lw	a4,0(a5)
ffffffffc02031f2:	0007061b          	sext.w	a2,a4
ffffffffc02031f6:	14d71a63          	bne	a4,a3,ffffffffc020334a <_clock_check_swap+0x1c2>
ffffffffc02031fa:	4398                	lw	a4,0(a5)
ffffffffc02031fc:	0007069b          	sext.w	a3,a4
ffffffffc0203200:	12c71563          	bne	a4,a2,ffffffffc020332a <_clock_check_swap+0x1a2>
ffffffffc0203204:	4398                	lw	a4,0(a5)
ffffffffc0203206:	0007061b          	sext.w	a2,a4
ffffffffc020320a:	10d71063          	bne	a4,a3,ffffffffc020330a <_clock_check_swap+0x182>
ffffffffc020320e:	4398                	lw	a4,0(a5)
ffffffffc0203210:	0007069b          	sext.w	a3,a4
ffffffffc0203214:	0cc71b63          	bne	a4,a2,ffffffffc02032ea <_clock_check_swap+0x162>
ffffffffc0203218:	4398                	lw	a4,0(a5)
ffffffffc020321a:	0ad71863          	bne	a4,a3,ffffffffc02032ca <_clock_check_swap+0x142>
ffffffffc020321e:	6715                	lui	a4,0x5
ffffffffc0203220:	46b9                	li	a3,14
ffffffffc0203222:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
ffffffffc0203226:	4394                	lw	a3,0(a5)
ffffffffc0203228:	4715                	li	a4,5
ffffffffc020322a:	08e69063          	bne	a3,a4,ffffffffc02032aa <_clock_check_swap+0x122>
ffffffffc020322e:	6705                	lui	a4,0x1
ffffffffc0203230:	00074683          	lbu	a3,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0203234:	4729                	li	a4,10
ffffffffc0203236:	04e69a63          	bne	a3,a4,ffffffffc020328a <_clock_check_swap+0x102>
ffffffffc020323a:	4398                	lw	a4,0(a5)
ffffffffc020323c:	4799                	li	a5,6
ffffffffc020323e:	02f71663          	bne	a4,a5,ffffffffc020326a <_clock_check_swap+0xe2>
ffffffffc0203242:	60a2                	ld	ra,8(sp)
ffffffffc0203244:	4501                	li	a0,0
ffffffffc0203246:	0141                	addi	sp,sp,16
ffffffffc0203248:	8082                	ret
ffffffffc020324a:	00003697          	auipc	a3,0x3
ffffffffc020324e:	84668693          	addi	a3,a3,-1978 # ffffffffc0205a90 <default_pmm_manager+0x8c0>
ffffffffc0203252:	00002617          	auipc	a2,0x2
ffffffffc0203256:	bce60613          	addi	a2,a2,-1074 # ffffffffc0204e20 <commands+0x738>
ffffffffc020325a:	0a400593          	li	a1,164
ffffffffc020325e:	00003517          	auipc	a0,0x3
ffffffffc0203262:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0205c68 <default_pmm_manager+0xa98>
ffffffffc0203266:	8fcfd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc020326a:	00003697          	auipc	a3,0x3
ffffffffc020326e:	a5668693          	addi	a3,a3,-1450 # ffffffffc0205cc0 <default_pmm_manager+0xaf0>
ffffffffc0203272:	00002617          	auipc	a2,0x2
ffffffffc0203276:	bae60613          	addi	a2,a2,-1106 # ffffffffc0204e20 <commands+0x738>
ffffffffc020327a:	0bb00593          	li	a1,187
ffffffffc020327e:	00003517          	auipc	a0,0x3
ffffffffc0203282:	9ea50513          	addi	a0,a0,-1558 # ffffffffc0205c68 <default_pmm_manager+0xa98>
ffffffffc0203286:	8dcfd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc020328a:	00003697          	auipc	a3,0x3
ffffffffc020328e:	a0e68693          	addi	a3,a3,-1522 # ffffffffc0205c98 <default_pmm_manager+0xac8>
ffffffffc0203292:	00002617          	auipc	a2,0x2
ffffffffc0203296:	b8e60613          	addi	a2,a2,-1138 # ffffffffc0204e20 <commands+0x738>
ffffffffc020329a:	0b900593          	li	a1,185
ffffffffc020329e:	00003517          	auipc	a0,0x3
ffffffffc02032a2:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0205c68 <default_pmm_manager+0xa98>
ffffffffc02032a6:	8bcfd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02032aa:	00003697          	auipc	a3,0x3
ffffffffc02032ae:	9d668693          	addi	a3,a3,-1578 # ffffffffc0205c80 <default_pmm_manager+0xab0>
ffffffffc02032b2:	00002617          	auipc	a2,0x2
ffffffffc02032b6:	b6e60613          	addi	a2,a2,-1170 # ffffffffc0204e20 <commands+0x738>
ffffffffc02032ba:	0b800593          	li	a1,184
ffffffffc02032be:	00003517          	auipc	a0,0x3
ffffffffc02032c2:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0205c68 <default_pmm_manager+0xa98>
ffffffffc02032c6:	89cfd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02032ca:	00003697          	auipc	a3,0x3
ffffffffc02032ce:	9b668693          	addi	a3,a3,-1610 # ffffffffc0205c80 <default_pmm_manager+0xab0>
ffffffffc02032d2:	00002617          	auipc	a2,0x2
ffffffffc02032d6:	b4e60613          	addi	a2,a2,-1202 # ffffffffc0204e20 <commands+0x738>
ffffffffc02032da:	0b600593          	li	a1,182
ffffffffc02032de:	00003517          	auipc	a0,0x3
ffffffffc02032e2:	98a50513          	addi	a0,a0,-1654 # ffffffffc0205c68 <default_pmm_manager+0xa98>
ffffffffc02032e6:	87cfd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02032ea:	00003697          	auipc	a3,0x3
ffffffffc02032ee:	99668693          	addi	a3,a3,-1642 # ffffffffc0205c80 <default_pmm_manager+0xab0>
ffffffffc02032f2:	00002617          	auipc	a2,0x2
ffffffffc02032f6:	b2e60613          	addi	a2,a2,-1234 # ffffffffc0204e20 <commands+0x738>
ffffffffc02032fa:	0b400593          	li	a1,180
ffffffffc02032fe:	00003517          	auipc	a0,0x3
ffffffffc0203302:	96a50513          	addi	a0,a0,-1686 # ffffffffc0205c68 <default_pmm_manager+0xa98>
ffffffffc0203306:	85cfd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc020330a:	00003697          	auipc	a3,0x3
ffffffffc020330e:	97668693          	addi	a3,a3,-1674 # ffffffffc0205c80 <default_pmm_manager+0xab0>
ffffffffc0203312:	00002617          	auipc	a2,0x2
ffffffffc0203316:	b0e60613          	addi	a2,a2,-1266 # ffffffffc0204e20 <commands+0x738>
ffffffffc020331a:	0b200593          	li	a1,178
ffffffffc020331e:	00003517          	auipc	a0,0x3
ffffffffc0203322:	94a50513          	addi	a0,a0,-1718 # ffffffffc0205c68 <default_pmm_manager+0xa98>
ffffffffc0203326:	83cfd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc020332a:	00003697          	auipc	a3,0x3
ffffffffc020332e:	95668693          	addi	a3,a3,-1706 # ffffffffc0205c80 <default_pmm_manager+0xab0>
ffffffffc0203332:	00002617          	auipc	a2,0x2
ffffffffc0203336:	aee60613          	addi	a2,a2,-1298 # ffffffffc0204e20 <commands+0x738>
ffffffffc020333a:	0b000593          	li	a1,176
ffffffffc020333e:	00003517          	auipc	a0,0x3
ffffffffc0203342:	92a50513          	addi	a0,a0,-1750 # ffffffffc0205c68 <default_pmm_manager+0xa98>
ffffffffc0203346:	81cfd0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc020334a:	00003697          	auipc	a3,0x3
ffffffffc020334e:	93668693          	addi	a3,a3,-1738 # ffffffffc0205c80 <default_pmm_manager+0xab0>
ffffffffc0203352:	00002617          	auipc	a2,0x2
ffffffffc0203356:	ace60613          	addi	a2,a2,-1330 # ffffffffc0204e20 <commands+0x738>
ffffffffc020335a:	0ae00593          	li	a1,174
ffffffffc020335e:	00003517          	auipc	a0,0x3
ffffffffc0203362:	90a50513          	addi	a0,a0,-1782 # ffffffffc0205c68 <default_pmm_manager+0xa98>
ffffffffc0203366:	ffdfc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc020336a:	00003697          	auipc	a3,0x3
ffffffffc020336e:	91668693          	addi	a3,a3,-1770 # ffffffffc0205c80 <default_pmm_manager+0xab0>
ffffffffc0203372:	00002617          	auipc	a2,0x2
ffffffffc0203376:	aae60613          	addi	a2,a2,-1362 # ffffffffc0204e20 <commands+0x738>
ffffffffc020337a:	0ac00593          	li	a1,172
ffffffffc020337e:	00003517          	auipc	a0,0x3
ffffffffc0203382:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0205c68 <default_pmm_manager+0xa98>
ffffffffc0203386:	fddfc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc020338a:	00002697          	auipc	a3,0x2
ffffffffc020338e:	70668693          	addi	a3,a3,1798 # ffffffffc0205a90 <default_pmm_manager+0x8c0>
ffffffffc0203392:	00002617          	auipc	a2,0x2
ffffffffc0203396:	a8e60613          	addi	a2,a2,-1394 # ffffffffc0204e20 <commands+0x738>
ffffffffc020339a:	0aa00593          	li	a1,170
ffffffffc020339e:	00003517          	auipc	a0,0x3
ffffffffc02033a2:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0205c68 <default_pmm_manager+0xa98>
ffffffffc02033a6:	fbdfc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02033aa:	00002697          	auipc	a3,0x2
ffffffffc02033ae:	6e668693          	addi	a3,a3,1766 # ffffffffc0205a90 <default_pmm_manager+0x8c0>
ffffffffc02033b2:	00002617          	auipc	a2,0x2
ffffffffc02033b6:	a6e60613          	addi	a2,a2,-1426 # ffffffffc0204e20 <commands+0x738>
ffffffffc02033ba:	0a800593          	li	a1,168
ffffffffc02033be:	00003517          	auipc	a0,0x3
ffffffffc02033c2:	8aa50513          	addi	a0,a0,-1878 # ffffffffc0205c68 <default_pmm_manager+0xa98>
ffffffffc02033c6:	f9dfc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02033ca:	00002697          	auipc	a3,0x2
ffffffffc02033ce:	6c668693          	addi	a3,a3,1734 # ffffffffc0205a90 <default_pmm_manager+0x8c0>
ffffffffc02033d2:	00002617          	auipc	a2,0x2
ffffffffc02033d6:	a4e60613          	addi	a2,a2,-1458 # ffffffffc0204e20 <commands+0x738>
ffffffffc02033da:	0a600593          	li	a1,166
ffffffffc02033de:	00003517          	auipc	a0,0x3
ffffffffc02033e2:	88a50513          	addi	a0,a0,-1910 # ffffffffc0205c68 <default_pmm_manager+0xa98>
ffffffffc02033e6:	f7dfc0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc02033ea <_clock_map_swappable>:
ffffffffc02033ea:	0000e797          	auipc	a5,0xe
ffffffffc02033ee:	1767b783          	ld	a5,374(a5) # ffffffffc0211560 <curr_ptr>
ffffffffc02033f2:	c385                	beqz	a5,ffffffffc0203412 <_clock_map_swappable+0x28>
ffffffffc02033f4:	0000e797          	auipc	a5,0xe
ffffffffc02033f8:	cf478793          	addi	a5,a5,-780 # ffffffffc02110e8 <pra_list_head>
ffffffffc02033fc:	6394                	ld	a3,0(a5)
ffffffffc02033fe:	03060713          	addi	a4,a2,48
ffffffffc0203402:	e398                	sd	a4,0(a5)
ffffffffc0203404:	e698                	sd	a4,8(a3)
ffffffffc0203406:	fe1c                	sd	a5,56(a2)
ffffffffc0203408:	4785                	li	a5,1
ffffffffc020340a:	fa14                	sd	a3,48(a2)
ffffffffc020340c:	ea1c                	sd	a5,16(a2)
ffffffffc020340e:	4501                	li	a0,0
ffffffffc0203410:	8082                	ret
ffffffffc0203412:	1141                	addi	sp,sp,-16
ffffffffc0203414:	00003697          	auipc	a3,0x3
ffffffffc0203418:	8c468693          	addi	a3,a3,-1852 # ffffffffc0205cd8 <default_pmm_manager+0xb08>
ffffffffc020341c:	00002617          	auipc	a2,0x2
ffffffffc0203420:	a0460613          	addi	a2,a2,-1532 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203424:	03a00593          	li	a1,58
ffffffffc0203428:	00003517          	auipc	a0,0x3
ffffffffc020342c:	84050513          	addi	a0,a0,-1984 # ffffffffc0205c68 <default_pmm_manager+0xa98>
ffffffffc0203430:	e406                	sd	ra,8(sp)
ffffffffc0203432:	f31fc0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc0203436 <_clock_swap_out_victim>:
ffffffffc0203436:	751c                	ld	a5,40(a0)
ffffffffc0203438:	1101                	addi	sp,sp,-32
ffffffffc020343a:	ec06                	sd	ra,24(sp)
ffffffffc020343c:	e822                	sd	s0,16(sp)
ffffffffc020343e:	e426                	sd	s1,8(sp)
ffffffffc0203440:	e04a                	sd	s2,0(sp)
ffffffffc0203442:	c7a5                	beqz	a5,ffffffffc02034aa <_clock_swap_out_victim+0x74>
ffffffffc0203444:	e259                	bnez	a2,ffffffffc02034ca <_clock_swap_out_victim+0x94>
ffffffffc0203446:	0000e917          	auipc	s2,0xe
ffffffffc020344a:	11a90913          	addi	s2,s2,282 # ffffffffc0211560 <curr_ptr>
ffffffffc020344e:	0000e717          	auipc	a4,0xe
ffffffffc0203452:	c9a70713          	addi	a4,a4,-870 # ffffffffc02110e8 <pra_list_head>
ffffffffc0203456:	00093403          	ld	s0,0(s2)
ffffffffc020345a:	6714                	ld	a3,8(a4)
ffffffffc020345c:	84ae                	mv	s1,a1
ffffffffc020345e:	a031                	j	ffffffffc020346a <_clock_swap_out_victim+0x34>
ffffffffc0203460:	fe043783          	ld	a5,-32(s0)
ffffffffc0203464:	cb91                	beqz	a5,ffffffffc0203478 <_clock_swap_out_victim+0x42>
ffffffffc0203466:	fe043023          	sd	zero,-32(s0)
ffffffffc020346a:	6400                	ld	s0,8(s0)
ffffffffc020346c:	fee41ae3          	bne	s0,a4,ffffffffc0203460 <_clock_swap_out_victim+0x2a>
ffffffffc0203470:	8436                	mv	s0,a3
ffffffffc0203472:	fe043783          	ld	a5,-32(s0)
ffffffffc0203476:	fbe5                	bnez	a5,ffffffffc0203466 <_clock_swap_out_victim+0x30>
ffffffffc0203478:	85a2                	mv	a1,s0
ffffffffc020347a:	00003517          	auipc	a0,0x3
ffffffffc020347e:	8a650513          	addi	a0,a0,-1882 # ffffffffc0205d20 <default_pmm_manager+0xb50>
ffffffffc0203482:	00893023          	sd	s0,0(s2)
ffffffffc0203486:	c35fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020348a:	00093783          	ld	a5,0(s2)
ffffffffc020348e:	fd040413          	addi	s0,s0,-48
ffffffffc0203492:	60e2                	ld	ra,24(sp)
ffffffffc0203494:	6398                	ld	a4,0(a5)
ffffffffc0203496:	679c                	ld	a5,8(a5)
ffffffffc0203498:	6902                	ld	s2,0(sp)
ffffffffc020349a:	4501                	li	a0,0
ffffffffc020349c:	e71c                	sd	a5,8(a4)
ffffffffc020349e:	e398                	sd	a4,0(a5)
ffffffffc02034a0:	e080                	sd	s0,0(s1)
ffffffffc02034a2:	6442                	ld	s0,16(sp)
ffffffffc02034a4:	64a2                	ld	s1,8(sp)
ffffffffc02034a6:	6105                	addi	sp,sp,32
ffffffffc02034a8:	8082                	ret
ffffffffc02034aa:	00003697          	auipc	a3,0x3
ffffffffc02034ae:	85668693          	addi	a3,a3,-1962 # ffffffffc0205d00 <default_pmm_manager+0xb30>
ffffffffc02034b2:	00002617          	auipc	a2,0x2
ffffffffc02034b6:	96e60613          	addi	a2,a2,-1682 # ffffffffc0204e20 <commands+0x738>
ffffffffc02034ba:	04f00593          	li	a1,79
ffffffffc02034be:	00002517          	auipc	a0,0x2
ffffffffc02034c2:	7aa50513          	addi	a0,a0,1962 # ffffffffc0205c68 <default_pmm_manager+0xa98>
ffffffffc02034c6:	e9dfc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc02034ca:	00003697          	auipc	a3,0x3
ffffffffc02034ce:	84668693          	addi	a3,a3,-1978 # ffffffffc0205d10 <default_pmm_manager+0xb40>
ffffffffc02034d2:	00002617          	auipc	a2,0x2
ffffffffc02034d6:	94e60613          	addi	a2,a2,-1714 # ffffffffc0204e20 <commands+0x738>
ffffffffc02034da:	05000593          	li	a1,80
ffffffffc02034de:	00002517          	auipc	a0,0x2
ffffffffc02034e2:	78a50513          	addi	a0,a0,1930 # ffffffffc0205c68 <default_pmm_manager+0xa98>
ffffffffc02034e6:	e7dfc0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc02034ea <check_vma_overlap.part.0>:
ffffffffc02034ea:	1141                	addi	sp,sp,-16
ffffffffc02034ec:	00003697          	auipc	a3,0x3
ffffffffc02034f0:	85c68693          	addi	a3,a3,-1956 # ffffffffc0205d48 <default_pmm_manager+0xb78>
ffffffffc02034f4:	00002617          	auipc	a2,0x2
ffffffffc02034f8:	92c60613          	addi	a2,a2,-1748 # ffffffffc0204e20 <commands+0x738>
ffffffffc02034fc:	08f00593          	li	a1,143
ffffffffc0203500:	00003517          	auipc	a0,0x3
ffffffffc0203504:	86850513          	addi	a0,a0,-1944 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203508:	e406                	sd	ra,8(sp)
ffffffffc020350a:	e59fc0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc020350e <mm_create>:
ffffffffc020350e:	1141                	addi	sp,sp,-16
ffffffffc0203510:	03000513          	li	a0,48
ffffffffc0203514:	e022                	sd	s0,0(sp)
ffffffffc0203516:	e406                	sd	ra,8(sp)
ffffffffc0203518:	a7aff0ef          	jal	ra,ffffffffc0202792 <kmalloc>
ffffffffc020351c:	842a                	mv	s0,a0
ffffffffc020351e:	c105                	beqz	a0,ffffffffc020353e <mm_create+0x30>
ffffffffc0203520:	e408                	sd	a0,8(s0)
ffffffffc0203522:	e008                	sd	a0,0(s0)
ffffffffc0203524:	00053823          	sd	zero,16(a0)
ffffffffc0203528:	00053c23          	sd	zero,24(a0)
ffffffffc020352c:	02052023          	sw	zero,32(a0)
ffffffffc0203530:	0000e797          	auipc	a5,0xe
ffffffffc0203534:	0187a783          	lw	a5,24(a5) # ffffffffc0211548 <swap_init_ok>
ffffffffc0203538:	eb81                	bnez	a5,ffffffffc0203548 <mm_create+0x3a>
ffffffffc020353a:	02053423          	sd	zero,40(a0)
ffffffffc020353e:	60a2                	ld	ra,8(sp)
ffffffffc0203540:	8522                	mv	a0,s0
ffffffffc0203542:	6402                	ld	s0,0(sp)
ffffffffc0203544:	0141                	addi	sp,sp,16
ffffffffc0203546:	8082                	ret
ffffffffc0203548:	a75ff0ef          	jal	ra,ffffffffc0202fbc <swap_init_mm>
ffffffffc020354c:	60a2                	ld	ra,8(sp)
ffffffffc020354e:	8522                	mv	a0,s0
ffffffffc0203550:	6402                	ld	s0,0(sp)
ffffffffc0203552:	0141                	addi	sp,sp,16
ffffffffc0203554:	8082                	ret

ffffffffc0203556 <vma_create>:
ffffffffc0203556:	1101                	addi	sp,sp,-32
ffffffffc0203558:	e04a                	sd	s2,0(sp)
ffffffffc020355a:	892a                	mv	s2,a0
ffffffffc020355c:	03000513          	li	a0,48
ffffffffc0203560:	e822                	sd	s0,16(sp)
ffffffffc0203562:	e426                	sd	s1,8(sp)
ffffffffc0203564:	ec06                	sd	ra,24(sp)
ffffffffc0203566:	84ae                	mv	s1,a1
ffffffffc0203568:	8432                	mv	s0,a2
ffffffffc020356a:	a28ff0ef          	jal	ra,ffffffffc0202792 <kmalloc>
ffffffffc020356e:	c509                	beqz	a0,ffffffffc0203578 <vma_create+0x22>
ffffffffc0203570:	01253423          	sd	s2,8(a0)
ffffffffc0203574:	e904                	sd	s1,16(a0)
ffffffffc0203576:	ed00                	sd	s0,24(a0)
ffffffffc0203578:	60e2                	ld	ra,24(sp)
ffffffffc020357a:	6442                	ld	s0,16(sp)
ffffffffc020357c:	64a2                	ld	s1,8(sp)
ffffffffc020357e:	6902                	ld	s2,0(sp)
ffffffffc0203580:	6105                	addi	sp,sp,32
ffffffffc0203582:	8082                	ret

ffffffffc0203584 <find_vma>:
ffffffffc0203584:	86aa                	mv	a3,a0
ffffffffc0203586:	c505                	beqz	a0,ffffffffc02035ae <find_vma+0x2a>
ffffffffc0203588:	6908                	ld	a0,16(a0)
ffffffffc020358a:	c501                	beqz	a0,ffffffffc0203592 <find_vma+0xe>
ffffffffc020358c:	651c                	ld	a5,8(a0)
ffffffffc020358e:	02f5f663          	bgeu	a1,a5,ffffffffc02035ba <find_vma+0x36>
ffffffffc0203592:	669c                	ld	a5,8(a3)
ffffffffc0203594:	00f68d63          	beq	a3,a5,ffffffffc02035ae <find_vma+0x2a>
ffffffffc0203598:	fe87b703          	ld	a4,-24(a5)
ffffffffc020359c:	00e5e663          	bltu	a1,a4,ffffffffc02035a8 <find_vma+0x24>
ffffffffc02035a0:	ff07b703          	ld	a4,-16(a5)
ffffffffc02035a4:	00e5e763          	bltu	a1,a4,ffffffffc02035b2 <find_vma+0x2e>
ffffffffc02035a8:	679c                	ld	a5,8(a5)
ffffffffc02035aa:	fef697e3          	bne	a3,a5,ffffffffc0203598 <find_vma+0x14>
ffffffffc02035ae:	4501                	li	a0,0
ffffffffc02035b0:	8082                	ret
ffffffffc02035b2:	fe078513          	addi	a0,a5,-32
ffffffffc02035b6:	ea88                	sd	a0,16(a3)
ffffffffc02035b8:	8082                	ret
ffffffffc02035ba:	691c                	ld	a5,16(a0)
ffffffffc02035bc:	fcf5fbe3          	bgeu	a1,a5,ffffffffc0203592 <find_vma+0xe>
ffffffffc02035c0:	ea88                	sd	a0,16(a3)
ffffffffc02035c2:	8082                	ret

ffffffffc02035c4 <insert_vma_struct>:
ffffffffc02035c4:	6590                	ld	a2,8(a1)
ffffffffc02035c6:	0105b803          	ld	a6,16(a1) # 1010 <kern_entry-0xffffffffc01feff0>
ffffffffc02035ca:	1141                	addi	sp,sp,-16
ffffffffc02035cc:	e406                	sd	ra,8(sp)
ffffffffc02035ce:	87aa                	mv	a5,a0
ffffffffc02035d0:	01066763          	bltu	a2,a6,ffffffffc02035de <insert_vma_struct+0x1a>
ffffffffc02035d4:	a085                	j	ffffffffc0203634 <insert_vma_struct+0x70>
ffffffffc02035d6:	fe87b703          	ld	a4,-24(a5)
ffffffffc02035da:	04e66863          	bltu	a2,a4,ffffffffc020362a <insert_vma_struct+0x66>
ffffffffc02035de:	86be                	mv	a3,a5
ffffffffc02035e0:	679c                	ld	a5,8(a5)
ffffffffc02035e2:	fef51ae3          	bne	a0,a5,ffffffffc02035d6 <insert_vma_struct+0x12>
ffffffffc02035e6:	02a68463          	beq	a3,a0,ffffffffc020360e <insert_vma_struct+0x4a>
ffffffffc02035ea:	ff06b703          	ld	a4,-16(a3)
ffffffffc02035ee:	fe86b883          	ld	a7,-24(a3)
ffffffffc02035f2:	08e8f163          	bgeu	a7,a4,ffffffffc0203674 <insert_vma_struct+0xb0>
ffffffffc02035f6:	04e66f63          	bltu	a2,a4,ffffffffc0203654 <insert_vma_struct+0x90>
ffffffffc02035fa:	00f50a63          	beq	a0,a5,ffffffffc020360e <insert_vma_struct+0x4a>
ffffffffc02035fe:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203602:	05076963          	bltu	a4,a6,ffffffffc0203654 <insert_vma_struct+0x90>
ffffffffc0203606:	ff07b603          	ld	a2,-16(a5)
ffffffffc020360a:	02c77363          	bgeu	a4,a2,ffffffffc0203630 <insert_vma_struct+0x6c>
ffffffffc020360e:	5118                	lw	a4,32(a0)
ffffffffc0203610:	e188                	sd	a0,0(a1)
ffffffffc0203612:	02058613          	addi	a2,a1,32
ffffffffc0203616:	e390                	sd	a2,0(a5)
ffffffffc0203618:	e690                	sd	a2,8(a3)
ffffffffc020361a:	60a2                	ld	ra,8(sp)
ffffffffc020361c:	f59c                	sd	a5,40(a1)
ffffffffc020361e:	f194                	sd	a3,32(a1)
ffffffffc0203620:	0017079b          	addiw	a5,a4,1
ffffffffc0203624:	d11c                	sw	a5,32(a0)
ffffffffc0203626:	0141                	addi	sp,sp,16
ffffffffc0203628:	8082                	ret
ffffffffc020362a:	fca690e3          	bne	a3,a0,ffffffffc02035ea <insert_vma_struct+0x26>
ffffffffc020362e:	bfd1                	j	ffffffffc0203602 <insert_vma_struct+0x3e>
ffffffffc0203630:	ebbff0ef          	jal	ra,ffffffffc02034ea <check_vma_overlap.part.0>
ffffffffc0203634:	00002697          	auipc	a3,0x2
ffffffffc0203638:	74468693          	addi	a3,a3,1860 # ffffffffc0205d78 <default_pmm_manager+0xba8>
ffffffffc020363c:	00001617          	auipc	a2,0x1
ffffffffc0203640:	7e460613          	addi	a2,a2,2020 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203644:	09500593          	li	a1,149
ffffffffc0203648:	00002517          	auipc	a0,0x2
ffffffffc020364c:	72050513          	addi	a0,a0,1824 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203650:	d13fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203654:	00002697          	auipc	a3,0x2
ffffffffc0203658:	76468693          	addi	a3,a3,1892 # ffffffffc0205db8 <default_pmm_manager+0xbe8>
ffffffffc020365c:	00001617          	auipc	a2,0x1
ffffffffc0203660:	7c460613          	addi	a2,a2,1988 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203664:	08e00593          	li	a1,142
ffffffffc0203668:	00002517          	auipc	a0,0x2
ffffffffc020366c:	70050513          	addi	a0,a0,1792 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203670:	cf3fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203674:	00002697          	auipc	a3,0x2
ffffffffc0203678:	72468693          	addi	a3,a3,1828 # ffffffffc0205d98 <default_pmm_manager+0xbc8>
ffffffffc020367c:	00001617          	auipc	a2,0x1
ffffffffc0203680:	7a460613          	addi	a2,a2,1956 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203684:	08d00593          	li	a1,141
ffffffffc0203688:	00002517          	auipc	a0,0x2
ffffffffc020368c:	6e050513          	addi	a0,a0,1760 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203690:	cd3fc0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc0203694 <mm_destroy>:
ffffffffc0203694:	1141                	addi	sp,sp,-16
ffffffffc0203696:	e022                	sd	s0,0(sp)
ffffffffc0203698:	842a                	mv	s0,a0
ffffffffc020369a:	6508                	ld	a0,8(a0)
ffffffffc020369c:	e406                	sd	ra,8(sp)
ffffffffc020369e:	00a40e63          	beq	s0,a0,ffffffffc02036ba <mm_destroy+0x26>
ffffffffc02036a2:	6118                	ld	a4,0(a0)
ffffffffc02036a4:	651c                	ld	a5,8(a0)
ffffffffc02036a6:	03000593          	li	a1,48
ffffffffc02036aa:	1501                	addi	a0,a0,-32
ffffffffc02036ac:	e71c                	sd	a5,8(a4)
ffffffffc02036ae:	e398                	sd	a4,0(a5)
ffffffffc02036b0:	99cff0ef          	jal	ra,ffffffffc020284c <kfree>
ffffffffc02036b4:	6408                	ld	a0,8(s0)
ffffffffc02036b6:	fea416e3          	bne	s0,a0,ffffffffc02036a2 <mm_destroy+0xe>
ffffffffc02036ba:	8522                	mv	a0,s0
ffffffffc02036bc:	6402                	ld	s0,0(sp)
ffffffffc02036be:	60a2                	ld	ra,8(sp)
ffffffffc02036c0:	03000593          	li	a1,48
ffffffffc02036c4:	0141                	addi	sp,sp,16
ffffffffc02036c6:	986ff06f          	j	ffffffffc020284c <kfree>

ffffffffc02036ca <vmm_init>:
ffffffffc02036ca:	715d                	addi	sp,sp,-80
ffffffffc02036cc:	e486                	sd	ra,72(sp)
ffffffffc02036ce:	f84a                	sd	s2,48(sp)
ffffffffc02036d0:	f44e                	sd	s3,40(sp)
ffffffffc02036d2:	e0a2                	sd	s0,64(sp)
ffffffffc02036d4:	fc26                	sd	s1,56(sp)
ffffffffc02036d6:	f052                	sd	s4,32(sp)
ffffffffc02036d8:	ec56                	sd	s5,24(sp)
ffffffffc02036da:	e85a                	sd	s6,16(sp)
ffffffffc02036dc:	e45e                	sd	s7,8(sp)
ffffffffc02036de:	e062                	sd	s8,0(sp)
ffffffffc02036e0:	fd9fd0ef          	jal	ra,ffffffffc02016b8 <nr_free_pages>
ffffffffc02036e4:	892a                	mv	s2,a0
ffffffffc02036e6:	fd3fd0ef          	jal	ra,ffffffffc02016b8 <nr_free_pages>
ffffffffc02036ea:	89aa                	mv	s3,a0
ffffffffc02036ec:	03000513          	li	a0,48
ffffffffc02036f0:	8a2ff0ef          	jal	ra,ffffffffc0202792 <kmalloc>
ffffffffc02036f4:	30050663          	beqz	a0,ffffffffc0203a00 <vmm_init+0x336>
ffffffffc02036f8:	e508                	sd	a0,8(a0)
ffffffffc02036fa:	e108                	sd	a0,0(a0)
ffffffffc02036fc:	00053823          	sd	zero,16(a0)
ffffffffc0203700:	00053c23          	sd	zero,24(a0)
ffffffffc0203704:	02052023          	sw	zero,32(a0)
ffffffffc0203708:	0000e797          	auipc	a5,0xe
ffffffffc020370c:	e407a783          	lw	a5,-448(a5) # ffffffffc0211548 <swap_init_ok>
ffffffffc0203710:	842a                	mv	s0,a0
ffffffffc0203712:	2c079463          	bnez	a5,ffffffffc02039da <vmm_init+0x310>
ffffffffc0203716:	02053423          	sd	zero,40(a0)
ffffffffc020371a:	03200493          	li	s1,50
ffffffffc020371e:	03000513          	li	a0,48
ffffffffc0203722:	870ff0ef          	jal	ra,ffffffffc0202792 <kmalloc>
ffffffffc0203726:	85aa                	mv	a1,a0
ffffffffc0203728:	00248793          	addi	a5,s1,2
ffffffffc020372c:	2a050a63          	beqz	a0,ffffffffc02039e0 <vmm_init+0x316>
ffffffffc0203730:	e504                	sd	s1,8(a0)
ffffffffc0203732:	e91c                	sd	a5,16(a0)
ffffffffc0203734:	00053c23          	sd	zero,24(a0)
ffffffffc0203738:	14ed                	addi	s1,s1,-5
ffffffffc020373a:	8522                	mv	a0,s0
ffffffffc020373c:	e89ff0ef          	jal	ra,ffffffffc02035c4 <insert_vma_struct>
ffffffffc0203740:	fcf9                	bnez	s1,ffffffffc020371e <vmm_init+0x54>
ffffffffc0203742:	03700493          	li	s1,55
ffffffffc0203746:	1f900a13          	li	s4,505
ffffffffc020374a:	03000513          	li	a0,48
ffffffffc020374e:	844ff0ef          	jal	ra,ffffffffc0202792 <kmalloc>
ffffffffc0203752:	85aa                	mv	a1,a0
ffffffffc0203754:	2c050663          	beqz	a0,ffffffffc0203a20 <vmm_init+0x356>
ffffffffc0203758:	00248793          	addi	a5,s1,2
ffffffffc020375c:	e504                	sd	s1,8(a0)
ffffffffc020375e:	e91c                	sd	a5,16(a0)
ffffffffc0203760:	00053c23          	sd	zero,24(a0)
ffffffffc0203764:	0495                	addi	s1,s1,5
ffffffffc0203766:	8522                	mv	a0,s0
ffffffffc0203768:	e5dff0ef          	jal	ra,ffffffffc02035c4 <insert_vma_struct>
ffffffffc020376c:	fd449fe3          	bne	s1,s4,ffffffffc020374a <vmm_init+0x80>
ffffffffc0203770:	00843b03          	ld	s6,8(s0)
ffffffffc0203774:	3c8b0d63          	beq	s6,s0,ffffffffc0203b4e <vmm_init+0x484>
ffffffffc0203778:	87da                	mv	a5,s6
ffffffffc020377a:	4715                	li	a4,5
ffffffffc020377c:	1f400593          	li	a1,500
ffffffffc0203780:	a021                	j	ffffffffc0203788 <vmm_init+0xbe>
ffffffffc0203782:	0715                	addi	a4,a4,5
ffffffffc0203784:	3c878563          	beq	a5,s0,ffffffffc0203b4e <vmm_init+0x484>
ffffffffc0203788:	fe87b683          	ld	a3,-24(a5)
ffffffffc020378c:	34e69163          	bne	a3,a4,ffffffffc0203ace <vmm_init+0x404>
ffffffffc0203790:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203794:	00270693          	addi	a3,a4,2
ffffffffc0203798:	32d61b63          	bne	a2,a3,ffffffffc0203ace <vmm_init+0x404>
ffffffffc020379c:	679c                	ld	a5,8(a5)
ffffffffc020379e:	feb712e3          	bne	a4,a1,ffffffffc0203782 <vmm_init+0xb8>
ffffffffc02037a2:	4b9d                	li	s7,7
ffffffffc02037a4:	4495                	li	s1,5
ffffffffc02037a6:	1f900c13          	li	s8,505
ffffffffc02037aa:	85a6                	mv	a1,s1
ffffffffc02037ac:	8522                	mv	a0,s0
ffffffffc02037ae:	dd7ff0ef          	jal	ra,ffffffffc0203584 <find_vma>
ffffffffc02037b2:	8aaa                	mv	s5,a0
ffffffffc02037b4:	3c050d63          	beqz	a0,ffffffffc0203b8e <vmm_init+0x4c4>
ffffffffc02037b8:	00148593          	addi	a1,s1,1
ffffffffc02037bc:	8522                	mv	a0,s0
ffffffffc02037be:	dc7ff0ef          	jal	ra,ffffffffc0203584 <find_vma>
ffffffffc02037c2:	8a2a                	mv	s4,a0
ffffffffc02037c4:	3a050563          	beqz	a0,ffffffffc0203b6e <vmm_init+0x4a4>
ffffffffc02037c8:	85de                	mv	a1,s7
ffffffffc02037ca:	8522                	mv	a0,s0
ffffffffc02037cc:	db9ff0ef          	jal	ra,ffffffffc0203584 <find_vma>
ffffffffc02037d0:	32051f63          	bnez	a0,ffffffffc0203b0e <vmm_init+0x444>
ffffffffc02037d4:	00348593          	addi	a1,s1,3
ffffffffc02037d8:	8522                	mv	a0,s0
ffffffffc02037da:	dabff0ef          	jal	ra,ffffffffc0203584 <find_vma>
ffffffffc02037de:	30051863          	bnez	a0,ffffffffc0203aee <vmm_init+0x424>
ffffffffc02037e2:	00448593          	addi	a1,s1,4
ffffffffc02037e6:	8522                	mv	a0,s0
ffffffffc02037e8:	d9dff0ef          	jal	ra,ffffffffc0203584 <find_vma>
ffffffffc02037ec:	34051163          	bnez	a0,ffffffffc0203b2e <vmm_init+0x464>
ffffffffc02037f0:	008ab783          	ld	a5,8(s5)
ffffffffc02037f4:	2af49d63          	bne	s1,a5,ffffffffc0203aae <vmm_init+0x3e4>
ffffffffc02037f8:	010ab783          	ld	a5,16(s5)
ffffffffc02037fc:	2afb9963          	bne	s7,a5,ffffffffc0203aae <vmm_init+0x3e4>
ffffffffc0203800:	008a3783          	ld	a5,8(s4)
ffffffffc0203804:	28f49563          	bne	s1,a5,ffffffffc0203a8e <vmm_init+0x3c4>
ffffffffc0203808:	010a3783          	ld	a5,16(s4)
ffffffffc020380c:	28fb9163          	bne	s7,a5,ffffffffc0203a8e <vmm_init+0x3c4>
ffffffffc0203810:	0495                	addi	s1,s1,5
ffffffffc0203812:	0b95                	addi	s7,s7,5
ffffffffc0203814:	f9849be3          	bne	s1,s8,ffffffffc02037aa <vmm_init+0xe0>
ffffffffc0203818:	4491                	li	s1,4
ffffffffc020381a:	5a7d                	li	s4,-1
ffffffffc020381c:	85a6                	mv	a1,s1
ffffffffc020381e:	8522                	mv	a0,s0
ffffffffc0203820:	d65ff0ef          	jal	ra,ffffffffc0203584 <find_vma>
ffffffffc0203824:	3a051563          	bnez	a0,ffffffffc0203bce <vmm_init+0x504>
ffffffffc0203828:	14fd                	addi	s1,s1,-1
ffffffffc020382a:	ff4499e3          	bne	s1,s4,ffffffffc020381c <vmm_init+0x152>
ffffffffc020382e:	000b3703          	ld	a4,0(s6)
ffffffffc0203832:	008b3783          	ld	a5,8(s6)
ffffffffc0203836:	fe0b0513          	addi	a0,s6,-32
ffffffffc020383a:	03000593          	li	a1,48
ffffffffc020383e:	e71c                	sd	a5,8(a4)
ffffffffc0203840:	e398                	sd	a4,0(a5)
ffffffffc0203842:	80aff0ef          	jal	ra,ffffffffc020284c <kfree>
ffffffffc0203846:	00843b03          	ld	s6,8(s0)
ffffffffc020384a:	ff6412e3          	bne	s0,s6,ffffffffc020382e <vmm_init+0x164>
ffffffffc020384e:	03000593          	li	a1,48
ffffffffc0203852:	8522                	mv	a0,s0
ffffffffc0203854:	ff9fe0ef          	jal	ra,ffffffffc020284c <kfree>
ffffffffc0203858:	e61fd0ef          	jal	ra,ffffffffc02016b8 <nr_free_pages>
ffffffffc020385c:	3ca99363          	bne	s3,a0,ffffffffc0203c22 <vmm_init+0x558>
ffffffffc0203860:	00002517          	auipc	a0,0x2
ffffffffc0203864:	6e050513          	addi	a0,a0,1760 # ffffffffc0205f40 <default_pmm_manager+0xd70>
ffffffffc0203868:	853fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020386c:	e4dfd0ef          	jal	ra,ffffffffc02016b8 <nr_free_pages>
ffffffffc0203870:	84aa                	mv	s1,a0
ffffffffc0203872:	03000513          	li	a0,48
ffffffffc0203876:	f1dfe0ef          	jal	ra,ffffffffc0202792 <kmalloc>
ffffffffc020387a:	842a                	mv	s0,a0
ffffffffc020387c:	1e050263          	beqz	a0,ffffffffc0203a60 <vmm_init+0x396>
ffffffffc0203880:	0000e797          	auipc	a5,0xe
ffffffffc0203884:	cc87a783          	lw	a5,-824(a5) # ffffffffc0211548 <swap_init_ok>
ffffffffc0203888:	e508                	sd	a0,8(a0)
ffffffffc020388a:	e108                	sd	a0,0(a0)
ffffffffc020388c:	00053823          	sd	zero,16(a0)
ffffffffc0203890:	00053c23          	sd	zero,24(a0)
ffffffffc0203894:	02052023          	sw	zero,32(a0)
ffffffffc0203898:	1e079863          	bnez	a5,ffffffffc0203a88 <vmm_init+0x3be>
ffffffffc020389c:	02053423          	sd	zero,40(a0)
ffffffffc02038a0:	0000e997          	auipc	s3,0xe
ffffffffc02038a4:	c889b983          	ld	s3,-888(s3) # ffffffffc0211528 <boot_pgdir>
ffffffffc02038a8:	0009b783          	ld	a5,0(s3)
ffffffffc02038ac:	0000e717          	auipc	a4,0xe
ffffffffc02038b0:	cc873223          	sd	s0,-828(a4) # ffffffffc0211570 <check_mm_struct>
ffffffffc02038b4:	01343c23          	sd	s3,24(s0)
ffffffffc02038b8:	2e079b63          	bnez	a5,ffffffffc0203bae <vmm_init+0x4e4>
ffffffffc02038bc:	03000513          	li	a0,48
ffffffffc02038c0:	ed3fe0ef          	jal	ra,ffffffffc0202792 <kmalloc>
ffffffffc02038c4:	8a2a                	mv	s4,a0
ffffffffc02038c6:	16050d63          	beqz	a0,ffffffffc0203a40 <vmm_init+0x376>
ffffffffc02038ca:	002007b7          	lui	a5,0x200
ffffffffc02038ce:	00fa3823          	sd	a5,16(s4)
ffffffffc02038d2:	4789                	li	a5,2
ffffffffc02038d4:	85aa                	mv	a1,a0
ffffffffc02038d6:	00fa3c23          	sd	a5,24(s4)
ffffffffc02038da:	8522                	mv	a0,s0
ffffffffc02038dc:	000a3423          	sd	zero,8(s4)
ffffffffc02038e0:	ce5ff0ef          	jal	ra,ffffffffc02035c4 <insert_vma_struct>
ffffffffc02038e4:	10000593          	li	a1,256
ffffffffc02038e8:	8522                	mv	a0,s0
ffffffffc02038ea:	c9bff0ef          	jal	ra,ffffffffc0203584 <find_vma>
ffffffffc02038ee:	10000793          	li	a5,256
ffffffffc02038f2:	16400713          	li	a4,356
ffffffffc02038f6:	30aa1663          	bne	s4,a0,ffffffffc0203c02 <vmm_init+0x538>
ffffffffc02038fa:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
ffffffffc02038fe:	0785                	addi	a5,a5,1
ffffffffc0203900:	fee79de3          	bne	a5,a4,ffffffffc02038fa <vmm_init+0x230>
ffffffffc0203904:	6705                	lui	a4,0x1
ffffffffc0203906:	10000793          	li	a5,256
ffffffffc020390a:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
ffffffffc020390e:	16400613          	li	a2,356
ffffffffc0203912:	0007c683          	lbu	a3,0(a5)
ffffffffc0203916:	0785                	addi	a5,a5,1
ffffffffc0203918:	9f15                	subw	a4,a4,a3
ffffffffc020391a:	fec79ce3          	bne	a5,a2,ffffffffc0203912 <vmm_init+0x248>
ffffffffc020391e:	32071e63          	bnez	a4,ffffffffc0203c5a <vmm_init+0x590>
ffffffffc0203922:	4581                	li	a1,0
ffffffffc0203924:	854e                	mv	a0,s3
ffffffffc0203926:	81afe0ef          	jal	ra,ffffffffc0201940 <page_remove>
ffffffffc020392a:	0009b783          	ld	a5,0(s3)
ffffffffc020392e:	0000e717          	auipc	a4,0xe
ffffffffc0203932:	c0a73703          	ld	a4,-1014(a4) # ffffffffc0211538 <npage>
ffffffffc0203936:	078a                	slli	a5,a5,0x2
ffffffffc0203938:	83b1                	srli	a5,a5,0xc
ffffffffc020393a:	30e7f463          	bgeu	a5,a4,ffffffffc0203c42 <vmm_init+0x578>
ffffffffc020393e:	00003717          	auipc	a4,0x3
ffffffffc0203942:	a1273703          	ld	a4,-1518(a4) # ffffffffc0206350 <nbase>
ffffffffc0203946:	8f99                	sub	a5,a5,a4
ffffffffc0203948:	00379713          	slli	a4,a5,0x3
ffffffffc020394c:	97ba                	add	a5,a5,a4
ffffffffc020394e:	078e                	slli	a5,a5,0x3
ffffffffc0203950:	0000e517          	auipc	a0,0xe
ffffffffc0203954:	bf053503          	ld	a0,-1040(a0) # ffffffffc0211540 <pages>
ffffffffc0203958:	953e                	add	a0,a0,a5
ffffffffc020395a:	4585                	li	a1,1
ffffffffc020395c:	d1dfd0ef          	jal	ra,ffffffffc0201678 <free_pages>
ffffffffc0203960:	6408                	ld	a0,8(s0)
ffffffffc0203962:	0009b023          	sd	zero,0(s3)
ffffffffc0203966:	00043c23          	sd	zero,24(s0)
ffffffffc020396a:	00850e63          	beq	a0,s0,ffffffffc0203986 <vmm_init+0x2bc>
ffffffffc020396e:	6118                	ld	a4,0(a0)
ffffffffc0203970:	651c                	ld	a5,8(a0)
ffffffffc0203972:	03000593          	li	a1,48
ffffffffc0203976:	1501                	addi	a0,a0,-32
ffffffffc0203978:	e71c                	sd	a5,8(a4)
ffffffffc020397a:	e398                	sd	a4,0(a5)
ffffffffc020397c:	ed1fe0ef          	jal	ra,ffffffffc020284c <kfree>
ffffffffc0203980:	6408                	ld	a0,8(s0)
ffffffffc0203982:	fea416e3          	bne	s0,a0,ffffffffc020396e <vmm_init+0x2a4>
ffffffffc0203986:	03000593          	li	a1,48
ffffffffc020398a:	8522                	mv	a0,s0
ffffffffc020398c:	ec1fe0ef          	jal	ra,ffffffffc020284c <kfree>
ffffffffc0203990:	14fd                	addi	s1,s1,-1
ffffffffc0203992:	0000e797          	auipc	a5,0xe
ffffffffc0203996:	bc07bf23          	sd	zero,-1058(a5) # ffffffffc0211570 <check_mm_struct>
ffffffffc020399a:	d1ffd0ef          	jal	ra,ffffffffc02016b8 <nr_free_pages>
ffffffffc020399e:	2ea49e63          	bne	s1,a0,ffffffffc0203c9a <vmm_init+0x5d0>
ffffffffc02039a2:	00002517          	auipc	a0,0x2
ffffffffc02039a6:	60650513          	addi	a0,a0,1542 # ffffffffc0205fa8 <default_pmm_manager+0xdd8>
ffffffffc02039aa:	f10fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02039ae:	d0bfd0ef          	jal	ra,ffffffffc02016b8 <nr_free_pages>
ffffffffc02039b2:	197d                	addi	s2,s2,-1
ffffffffc02039b4:	2ca91363          	bne	s2,a0,ffffffffc0203c7a <vmm_init+0x5b0>
ffffffffc02039b8:	6406                	ld	s0,64(sp)
ffffffffc02039ba:	60a6                	ld	ra,72(sp)
ffffffffc02039bc:	74e2                	ld	s1,56(sp)
ffffffffc02039be:	7942                	ld	s2,48(sp)
ffffffffc02039c0:	79a2                	ld	s3,40(sp)
ffffffffc02039c2:	7a02                	ld	s4,32(sp)
ffffffffc02039c4:	6ae2                	ld	s5,24(sp)
ffffffffc02039c6:	6b42                	ld	s6,16(sp)
ffffffffc02039c8:	6ba2                	ld	s7,8(sp)
ffffffffc02039ca:	6c02                	ld	s8,0(sp)
ffffffffc02039cc:	00002517          	auipc	a0,0x2
ffffffffc02039d0:	5fc50513          	addi	a0,a0,1532 # ffffffffc0205fc8 <default_pmm_manager+0xdf8>
ffffffffc02039d4:	6161                	addi	sp,sp,80
ffffffffc02039d6:	ee4fc06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02039da:	de2ff0ef          	jal	ra,ffffffffc0202fbc <swap_init_mm>
ffffffffc02039de:	bb35                	j	ffffffffc020371a <vmm_init+0x50>
ffffffffc02039e0:	00002697          	auipc	a3,0x2
ffffffffc02039e4:	f5868693          	addi	a3,a3,-168 # ffffffffc0205938 <default_pmm_manager+0x768>
ffffffffc02039e8:	00001617          	auipc	a2,0x1
ffffffffc02039ec:	43860613          	addi	a2,a2,1080 # ffffffffc0204e20 <commands+0x738>
ffffffffc02039f0:	0e700593          	li	a1,231
ffffffffc02039f4:	00002517          	auipc	a0,0x2
ffffffffc02039f8:	37450513          	addi	a0,a0,884 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc02039fc:	967fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203a00:	00002697          	auipc	a3,0x2
ffffffffc0203a04:	f0068693          	addi	a3,a3,-256 # ffffffffc0205900 <default_pmm_manager+0x730>
ffffffffc0203a08:	00001617          	auipc	a2,0x1
ffffffffc0203a0c:	41860613          	addi	a2,a2,1048 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203a10:	0df00593          	li	a1,223
ffffffffc0203a14:	00002517          	auipc	a0,0x2
ffffffffc0203a18:	35450513          	addi	a0,a0,852 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203a1c:	947fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203a20:	00002697          	auipc	a3,0x2
ffffffffc0203a24:	f1868693          	addi	a3,a3,-232 # ffffffffc0205938 <default_pmm_manager+0x768>
ffffffffc0203a28:	00001617          	auipc	a2,0x1
ffffffffc0203a2c:	3f860613          	addi	a2,a2,1016 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203a30:	0ee00593          	li	a1,238
ffffffffc0203a34:	00002517          	auipc	a0,0x2
ffffffffc0203a38:	33450513          	addi	a0,a0,820 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203a3c:	927fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203a40:	00002697          	auipc	a3,0x2
ffffffffc0203a44:	ef868693          	addi	a3,a3,-264 # ffffffffc0205938 <default_pmm_manager+0x768>
ffffffffc0203a48:	00001617          	auipc	a2,0x1
ffffffffc0203a4c:	3d860613          	addi	a2,a2,984 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203a50:	13000593          	li	a1,304
ffffffffc0203a54:	00002517          	auipc	a0,0x2
ffffffffc0203a58:	31450513          	addi	a0,a0,788 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203a5c:	907fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203a60:	00002697          	auipc	a3,0x2
ffffffffc0203a64:	50068693          	addi	a3,a3,1280 # ffffffffc0205f60 <default_pmm_manager+0xd90>
ffffffffc0203a68:	00001617          	auipc	a2,0x1
ffffffffc0203a6c:	3b860613          	addi	a2,a2,952 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203a70:	12900593          	li	a1,297
ffffffffc0203a74:	00002517          	auipc	a0,0x2
ffffffffc0203a78:	2f450513          	addi	a0,a0,756 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203a7c:	0000e797          	auipc	a5,0xe
ffffffffc0203a80:	ae07ba23          	sd	zero,-1292(a5) # ffffffffc0211570 <check_mm_struct>
ffffffffc0203a84:	8dffc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203a88:	d34ff0ef          	jal	ra,ffffffffc0202fbc <swap_init_mm>
ffffffffc0203a8c:	bd11                	j	ffffffffc02038a0 <vmm_init+0x1d6>
ffffffffc0203a8e:	00002697          	auipc	a3,0x2
ffffffffc0203a92:	41a68693          	addi	a3,a3,1050 # ffffffffc0205ea8 <default_pmm_manager+0xcd8>
ffffffffc0203a96:	00001617          	auipc	a2,0x1
ffffffffc0203a9a:	38a60613          	addi	a2,a2,906 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203a9e:	10a00593          	li	a1,266
ffffffffc0203aa2:	00002517          	auipc	a0,0x2
ffffffffc0203aa6:	2c650513          	addi	a0,a0,710 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203aaa:	8b9fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203aae:	00002697          	auipc	a3,0x2
ffffffffc0203ab2:	3ca68693          	addi	a3,a3,970 # ffffffffc0205e78 <default_pmm_manager+0xca8>
ffffffffc0203ab6:	00001617          	auipc	a2,0x1
ffffffffc0203aba:	36a60613          	addi	a2,a2,874 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203abe:	10900593          	li	a1,265
ffffffffc0203ac2:	00002517          	auipc	a0,0x2
ffffffffc0203ac6:	2a650513          	addi	a0,a0,678 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203aca:	899fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203ace:	00002697          	auipc	a3,0x2
ffffffffc0203ad2:	32268693          	addi	a3,a3,802 # ffffffffc0205df0 <default_pmm_manager+0xc20>
ffffffffc0203ad6:	00001617          	auipc	a2,0x1
ffffffffc0203ada:	34a60613          	addi	a2,a2,842 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203ade:	0f800593          	li	a1,248
ffffffffc0203ae2:	00002517          	auipc	a0,0x2
ffffffffc0203ae6:	28650513          	addi	a0,a0,646 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203aea:	879fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203aee:	00002697          	auipc	a3,0x2
ffffffffc0203af2:	36a68693          	addi	a3,a3,874 # ffffffffc0205e58 <default_pmm_manager+0xc88>
ffffffffc0203af6:	00001617          	auipc	a2,0x1
ffffffffc0203afa:	32a60613          	addi	a2,a2,810 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203afe:	10500593          	li	a1,261
ffffffffc0203b02:	00002517          	auipc	a0,0x2
ffffffffc0203b06:	26650513          	addi	a0,a0,614 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203b0a:	859fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203b0e:	00002697          	auipc	a3,0x2
ffffffffc0203b12:	33a68693          	addi	a3,a3,826 # ffffffffc0205e48 <default_pmm_manager+0xc78>
ffffffffc0203b16:	00001617          	auipc	a2,0x1
ffffffffc0203b1a:	30a60613          	addi	a2,a2,778 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203b1e:	10300593          	li	a1,259
ffffffffc0203b22:	00002517          	auipc	a0,0x2
ffffffffc0203b26:	24650513          	addi	a0,a0,582 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203b2a:	839fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203b2e:	00002697          	auipc	a3,0x2
ffffffffc0203b32:	33a68693          	addi	a3,a3,826 # ffffffffc0205e68 <default_pmm_manager+0xc98>
ffffffffc0203b36:	00001617          	auipc	a2,0x1
ffffffffc0203b3a:	2ea60613          	addi	a2,a2,746 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203b3e:	10700593          	li	a1,263
ffffffffc0203b42:	00002517          	auipc	a0,0x2
ffffffffc0203b46:	22650513          	addi	a0,a0,550 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203b4a:	819fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203b4e:	00002697          	auipc	a3,0x2
ffffffffc0203b52:	28a68693          	addi	a3,a3,650 # ffffffffc0205dd8 <default_pmm_manager+0xc08>
ffffffffc0203b56:	00001617          	auipc	a2,0x1
ffffffffc0203b5a:	2ca60613          	addi	a2,a2,714 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203b5e:	0f600593          	li	a1,246
ffffffffc0203b62:	00002517          	auipc	a0,0x2
ffffffffc0203b66:	20650513          	addi	a0,a0,518 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203b6a:	ff8fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203b6e:	00002697          	auipc	a3,0x2
ffffffffc0203b72:	2ca68693          	addi	a3,a3,714 # ffffffffc0205e38 <default_pmm_manager+0xc68>
ffffffffc0203b76:	00001617          	auipc	a2,0x1
ffffffffc0203b7a:	2aa60613          	addi	a2,a2,682 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203b7e:	10100593          	li	a1,257
ffffffffc0203b82:	00002517          	auipc	a0,0x2
ffffffffc0203b86:	1e650513          	addi	a0,a0,486 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203b8a:	fd8fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203b8e:	00002697          	auipc	a3,0x2
ffffffffc0203b92:	29a68693          	addi	a3,a3,666 # ffffffffc0205e28 <default_pmm_manager+0xc58>
ffffffffc0203b96:	00001617          	auipc	a2,0x1
ffffffffc0203b9a:	28a60613          	addi	a2,a2,650 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203b9e:	0ff00593          	li	a1,255
ffffffffc0203ba2:	00002517          	auipc	a0,0x2
ffffffffc0203ba6:	1c650513          	addi	a0,a0,454 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203baa:	fb8fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203bae:	00002697          	auipc	a3,0x2
ffffffffc0203bb2:	d7a68693          	addi	a3,a3,-646 # ffffffffc0205928 <default_pmm_manager+0x758>
ffffffffc0203bb6:	00001617          	auipc	a2,0x1
ffffffffc0203bba:	26a60613          	addi	a2,a2,618 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203bbe:	12c00593          	li	a1,300
ffffffffc0203bc2:	00002517          	auipc	a0,0x2
ffffffffc0203bc6:	1a650513          	addi	a0,a0,422 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203bca:	f98fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203bce:	6914                	ld	a3,16(a0)
ffffffffc0203bd0:	6510                	ld	a2,8(a0)
ffffffffc0203bd2:	0004859b          	sext.w	a1,s1
ffffffffc0203bd6:	00002517          	auipc	a0,0x2
ffffffffc0203bda:	30250513          	addi	a0,a0,770 # ffffffffc0205ed8 <default_pmm_manager+0xd08>
ffffffffc0203bde:	cdcfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203be2:	00002697          	auipc	a3,0x2
ffffffffc0203be6:	31e68693          	addi	a3,a3,798 # ffffffffc0205f00 <default_pmm_manager+0xd30>
ffffffffc0203bea:	00001617          	auipc	a2,0x1
ffffffffc0203bee:	23660613          	addi	a2,a2,566 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203bf2:	11400593          	li	a1,276
ffffffffc0203bf6:	00002517          	auipc	a0,0x2
ffffffffc0203bfa:	17250513          	addi	a0,a0,370 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203bfe:	f64fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203c02:	00002697          	auipc	a3,0x2
ffffffffc0203c06:	37668693          	addi	a3,a3,886 # ffffffffc0205f78 <default_pmm_manager+0xda8>
ffffffffc0203c0a:	00001617          	auipc	a2,0x1
ffffffffc0203c0e:	21660613          	addi	a2,a2,534 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203c12:	13600593          	li	a1,310
ffffffffc0203c16:	00002517          	auipc	a0,0x2
ffffffffc0203c1a:	15250513          	addi	a0,a0,338 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203c1e:	f44fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203c22:	00002697          	auipc	a3,0x2
ffffffffc0203c26:	2f668693          	addi	a3,a3,758 # ffffffffc0205f18 <default_pmm_manager+0xd48>
ffffffffc0203c2a:	00001617          	auipc	a2,0x1
ffffffffc0203c2e:	1f660613          	addi	a2,a2,502 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203c32:	11900593          	li	a1,281
ffffffffc0203c36:	00002517          	auipc	a0,0x2
ffffffffc0203c3a:	13250513          	addi	a0,a0,306 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203c3e:	f24fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203c42:	00001617          	auipc	a2,0x1
ffffffffc0203c46:	5c660613          	addi	a2,a2,1478 # ffffffffc0205208 <default_pmm_manager+0x38>
ffffffffc0203c4a:	06500593          	li	a1,101
ffffffffc0203c4e:	00001517          	auipc	a0,0x1
ffffffffc0203c52:	5da50513          	addi	a0,a0,1498 # ffffffffc0205228 <default_pmm_manager+0x58>
ffffffffc0203c56:	f0cfc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203c5a:	00002697          	auipc	a3,0x2
ffffffffc0203c5e:	33e68693          	addi	a3,a3,830 # ffffffffc0205f98 <default_pmm_manager+0xdc8>
ffffffffc0203c62:	00001617          	auipc	a2,0x1
ffffffffc0203c66:	1be60613          	addi	a2,a2,446 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203c6a:	14200593          	li	a1,322
ffffffffc0203c6e:	00002517          	auipc	a0,0x2
ffffffffc0203c72:	0fa50513          	addi	a0,a0,250 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203c76:	eecfc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203c7a:	00002697          	auipc	a3,0x2
ffffffffc0203c7e:	29e68693          	addi	a3,a3,670 # ffffffffc0205f18 <default_pmm_manager+0xd48>
ffffffffc0203c82:	00001617          	auipc	a2,0x1
ffffffffc0203c86:	19e60613          	addi	a2,a2,414 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203c8a:	0d400593          	li	a1,212
ffffffffc0203c8e:	00002517          	auipc	a0,0x2
ffffffffc0203c92:	0da50513          	addi	a0,a0,218 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203c96:	eccfc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203c9a:	00002697          	auipc	a3,0x2
ffffffffc0203c9e:	27e68693          	addi	a3,a3,638 # ffffffffc0205f18 <default_pmm_manager+0xd48>
ffffffffc0203ca2:	00001617          	auipc	a2,0x1
ffffffffc0203ca6:	17e60613          	addi	a2,a2,382 # ffffffffc0204e20 <commands+0x738>
ffffffffc0203caa:	15400593          	li	a1,340
ffffffffc0203cae:	00002517          	auipc	a0,0x2
ffffffffc0203cb2:	0ba50513          	addi	a0,a0,186 # ffffffffc0205d68 <default_pmm_manager+0xb98>
ffffffffc0203cb6:	eacfc0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc0203cba <do_pgfault>:
ffffffffc0203cba:	7179                	addi	sp,sp,-48
ffffffffc0203cbc:	85b2                	mv	a1,a2
ffffffffc0203cbe:	f022                	sd	s0,32(sp)
ffffffffc0203cc0:	ec26                	sd	s1,24(sp)
ffffffffc0203cc2:	f406                	sd	ra,40(sp)
ffffffffc0203cc4:	e84a                	sd	s2,16(sp)
ffffffffc0203cc6:	8432                	mv	s0,a2
ffffffffc0203cc8:	84aa                	mv	s1,a0
ffffffffc0203cca:	8bbff0ef          	jal	ra,ffffffffc0203584 <find_vma>
ffffffffc0203cce:	0000e797          	auipc	a5,0xe
ffffffffc0203cd2:	89a7a783          	lw	a5,-1894(a5) # ffffffffc0211568 <pgfault_num>
ffffffffc0203cd6:	2785                	addiw	a5,a5,1
ffffffffc0203cd8:	0000e717          	auipc	a4,0xe
ffffffffc0203cdc:	88f72823          	sw	a5,-1904(a4) # ffffffffc0211568 <pgfault_num>
ffffffffc0203ce0:	c541                	beqz	a0,ffffffffc0203d68 <do_pgfault+0xae>
ffffffffc0203ce2:	651c                	ld	a5,8(a0)
ffffffffc0203ce4:	08f46263          	bltu	s0,a5,ffffffffc0203d68 <do_pgfault+0xae>
ffffffffc0203ce8:	6d1c                	ld	a5,24(a0)
ffffffffc0203cea:	4959                	li	s2,22
ffffffffc0203cec:	8b89                	andi	a5,a5,2
ffffffffc0203cee:	cfa9                	beqz	a5,ffffffffc0203d48 <do_pgfault+0x8e>
ffffffffc0203cf0:	77fd                	lui	a5,0xfffff
ffffffffc0203cf2:	6c88                	ld	a0,24(s1)
ffffffffc0203cf4:	8c7d                	and	s0,s0,a5
ffffffffc0203cf6:	85a2                	mv	a1,s0
ffffffffc0203cf8:	4605                	li	a2,1
ffffffffc0203cfa:	9f9fd0ef          	jal	ra,ffffffffc02016f2 <get_pte>
ffffffffc0203cfe:	610c                	ld	a1,0(a0)
ffffffffc0203d00:	c5b1                	beqz	a1,ffffffffc0203d4c <do_pgfault+0x92>
ffffffffc0203d02:	0000e797          	auipc	a5,0xe
ffffffffc0203d06:	8467a783          	lw	a5,-1978(a5) # ffffffffc0211548 <swap_init_ok>
ffffffffc0203d0a:	cba5                	beqz	a5,ffffffffc0203d7a <do_pgfault+0xc0>
ffffffffc0203d0c:	0030                	addi	a2,sp,8
ffffffffc0203d0e:	85a2                	mv	a1,s0
ffffffffc0203d10:	8526                	mv	a0,s1
ffffffffc0203d12:	e402                	sd	zero,8(sp)
ffffffffc0203d14:	bd4ff0ef          	jal	ra,ffffffffc02030e8 <swap_in>
ffffffffc0203d18:	e92d                	bnez	a0,ffffffffc0203d8a <do_pgfault+0xd0>
ffffffffc0203d1a:	65a2                	ld	a1,8(sp)
ffffffffc0203d1c:	6c88                	ld	a0,24(s1)
ffffffffc0203d1e:	86ca                	mv	a3,s2
ffffffffc0203d20:	8622                	mv	a2,s0
ffffffffc0203d22:	cb9fd0ef          	jal	ra,ffffffffc02019da <page_insert>
ffffffffc0203d26:	e935                	bnez	a0,ffffffffc0203d9a <do_pgfault+0xe0>
ffffffffc0203d28:	6622                	ld	a2,8(sp)
ffffffffc0203d2a:	4685                	li	a3,1
ffffffffc0203d2c:	85a2                	mv	a1,s0
ffffffffc0203d2e:	8526                	mv	a0,s1
ffffffffc0203d30:	a98ff0ef          	jal	ra,ffffffffc0202fc8 <swap_map_swappable>
ffffffffc0203d34:	e93d                	bnez	a0,ffffffffc0203daa <do_pgfault+0xf0>
ffffffffc0203d36:	67a2                	ld	a5,8(sp)
ffffffffc0203d38:	e3a0                	sd	s0,64(a5)
ffffffffc0203d3a:	4501                	li	a0,0
ffffffffc0203d3c:	70a2                	ld	ra,40(sp)
ffffffffc0203d3e:	7402                	ld	s0,32(sp)
ffffffffc0203d40:	64e2                	ld	s1,24(sp)
ffffffffc0203d42:	6942                	ld	s2,16(sp)
ffffffffc0203d44:	6145                	addi	sp,sp,48
ffffffffc0203d46:	8082                	ret
ffffffffc0203d48:	4941                	li	s2,16
ffffffffc0203d4a:	b75d                	j	ffffffffc0203cf0 <do_pgfault+0x36>
ffffffffc0203d4c:	6c88                	ld	a0,24(s1)
ffffffffc0203d4e:	864a                	mv	a2,s2
ffffffffc0203d50:	85a2                	mv	a1,s0
ffffffffc0203d52:	989fe0ef          	jal	ra,ffffffffc02026da <pgdir_alloc_page>
ffffffffc0203d56:	f175                	bnez	a0,ffffffffc0203d3a <do_pgfault+0x80>
ffffffffc0203d58:	00002517          	auipc	a0,0x2
ffffffffc0203d5c:	2b850513          	addi	a0,a0,696 # ffffffffc0206010 <default_pmm_manager+0xe40>
ffffffffc0203d60:	b5afc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203d64:	5571                	li	a0,-4
ffffffffc0203d66:	bfd9                	j	ffffffffc0203d3c <do_pgfault+0x82>
ffffffffc0203d68:	85a2                	mv	a1,s0
ffffffffc0203d6a:	00002517          	auipc	a0,0x2
ffffffffc0203d6e:	27650513          	addi	a0,a0,630 # ffffffffc0205fe0 <default_pmm_manager+0xe10>
ffffffffc0203d72:	b48fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203d76:	5575                	li	a0,-3
ffffffffc0203d78:	b7d1                	j	ffffffffc0203d3c <do_pgfault+0x82>
ffffffffc0203d7a:	00002517          	auipc	a0,0x2
ffffffffc0203d7e:	30650513          	addi	a0,a0,774 # ffffffffc0206080 <default_pmm_manager+0xeb0>
ffffffffc0203d82:	b38fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203d86:	5571                	li	a0,-4
ffffffffc0203d88:	bf55                	j	ffffffffc0203d3c <do_pgfault+0x82>
ffffffffc0203d8a:	00002517          	auipc	a0,0x2
ffffffffc0203d8e:	2ae50513          	addi	a0,a0,686 # ffffffffc0206038 <default_pmm_manager+0xe68>
ffffffffc0203d92:	b28fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203d96:	5571                	li	a0,-4
ffffffffc0203d98:	b755                	j	ffffffffc0203d3c <do_pgfault+0x82>
ffffffffc0203d9a:	00002517          	auipc	a0,0x2
ffffffffc0203d9e:	2ae50513          	addi	a0,a0,686 # ffffffffc0206048 <default_pmm_manager+0xe78>
ffffffffc0203da2:	b18fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203da6:	5571                	li	a0,-4
ffffffffc0203da8:	bf51                	j	ffffffffc0203d3c <do_pgfault+0x82>
ffffffffc0203daa:	00002517          	auipc	a0,0x2
ffffffffc0203dae:	2b650513          	addi	a0,a0,694 # ffffffffc0206060 <default_pmm_manager+0xe90>
ffffffffc0203db2:	b08fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203db6:	5571                	li	a0,-4
ffffffffc0203db8:	b751                	j	ffffffffc0203d3c <do_pgfault+0x82>

ffffffffc0203dba <swapfs_init>:
ffffffffc0203dba:	1141                	addi	sp,sp,-16
ffffffffc0203dbc:	4505                	li	a0,1
ffffffffc0203dbe:	e406                	sd	ra,8(sp)
ffffffffc0203dc0:	ec2fc0ef          	jal	ra,ffffffffc0200482 <ide_device_valid>
ffffffffc0203dc4:	cd01                	beqz	a0,ffffffffc0203ddc <swapfs_init+0x22>
ffffffffc0203dc6:	4505                	li	a0,1
ffffffffc0203dc8:	ec0fc0ef          	jal	ra,ffffffffc0200488 <ide_device_size>
ffffffffc0203dcc:	60a2                	ld	ra,8(sp)
ffffffffc0203dce:	810d                	srli	a0,a0,0x3
ffffffffc0203dd0:	0000d797          	auipc	a5,0xd
ffffffffc0203dd4:	78a7b023          	sd	a0,1920(a5) # ffffffffc0211550 <max_swap_offset>
ffffffffc0203dd8:	0141                	addi	sp,sp,16
ffffffffc0203dda:	8082                	ret
ffffffffc0203ddc:	00002617          	auipc	a2,0x2
ffffffffc0203de0:	2cc60613          	addi	a2,a2,716 # ffffffffc02060a8 <default_pmm_manager+0xed8>
ffffffffc0203de4:	45b5                	li	a1,13
ffffffffc0203de6:	00002517          	auipc	a0,0x2
ffffffffc0203dea:	2e250513          	addi	a0,a0,738 # ffffffffc02060c8 <default_pmm_manager+0xef8>
ffffffffc0203dee:	d74fc0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc0203df2 <swapfs_read>:
ffffffffc0203df2:	1141                	addi	sp,sp,-16
ffffffffc0203df4:	e406                	sd	ra,8(sp)
ffffffffc0203df6:	00855793          	srli	a5,a0,0x8
ffffffffc0203dfa:	c3a5                	beqz	a5,ffffffffc0203e5a <swapfs_read+0x68>
ffffffffc0203dfc:	0000d717          	auipc	a4,0xd
ffffffffc0203e00:	75473703          	ld	a4,1876(a4) # ffffffffc0211550 <max_swap_offset>
ffffffffc0203e04:	04e7fb63          	bgeu	a5,a4,ffffffffc0203e5a <swapfs_read+0x68>
ffffffffc0203e08:	0000d717          	auipc	a4,0xd
ffffffffc0203e0c:	73873703          	ld	a4,1848(a4) # ffffffffc0211540 <pages>
ffffffffc0203e10:	8d99                	sub	a1,a1,a4
ffffffffc0203e12:	4035d613          	srai	a2,a1,0x3
ffffffffc0203e16:	00002717          	auipc	a4,0x2
ffffffffc0203e1a:	53273703          	ld	a4,1330(a4) # ffffffffc0206348 <error_string+0x38>
ffffffffc0203e1e:	02e60633          	mul	a2,a2,a4
ffffffffc0203e22:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203e26:	00002797          	auipc	a5,0x2
ffffffffc0203e2a:	52a7b783          	ld	a5,1322(a5) # ffffffffc0206350 <nbase>
ffffffffc0203e2e:	0000d717          	auipc	a4,0xd
ffffffffc0203e32:	70a73703          	ld	a4,1802(a4) # ffffffffc0211538 <npage>
ffffffffc0203e36:	963e                	add	a2,a2,a5
ffffffffc0203e38:	00c61793          	slli	a5,a2,0xc
ffffffffc0203e3c:	83b1                	srli	a5,a5,0xc
ffffffffc0203e3e:	0632                	slli	a2,a2,0xc
ffffffffc0203e40:	02e7f963          	bgeu	a5,a4,ffffffffc0203e72 <swapfs_read+0x80>
ffffffffc0203e44:	60a2                	ld	ra,8(sp)
ffffffffc0203e46:	0000d797          	auipc	a5,0xd
ffffffffc0203e4a:	6ea7b783          	ld	a5,1770(a5) # ffffffffc0211530 <va_pa_offset>
ffffffffc0203e4e:	46a1                	li	a3,8
ffffffffc0203e50:	963e                	add	a2,a2,a5
ffffffffc0203e52:	4505                	li	a0,1
ffffffffc0203e54:	0141                	addi	sp,sp,16
ffffffffc0203e56:	e38fc06f          	j	ffffffffc020048e <ide_read_secs>
ffffffffc0203e5a:	86aa                	mv	a3,a0
ffffffffc0203e5c:	00002617          	auipc	a2,0x2
ffffffffc0203e60:	28460613          	addi	a2,a2,644 # ffffffffc02060e0 <default_pmm_manager+0xf10>
ffffffffc0203e64:	45d1                	li	a1,20
ffffffffc0203e66:	00002517          	auipc	a0,0x2
ffffffffc0203e6a:	26250513          	addi	a0,a0,610 # ffffffffc02060c8 <default_pmm_manager+0xef8>
ffffffffc0203e6e:	cf4fc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203e72:	86b2                	mv	a3,a2
ffffffffc0203e74:	06a00593          	li	a1,106
ffffffffc0203e78:	00001617          	auipc	a2,0x1
ffffffffc0203e7c:	41860613          	addi	a2,a2,1048 # ffffffffc0205290 <default_pmm_manager+0xc0>
ffffffffc0203e80:	00001517          	auipc	a0,0x1
ffffffffc0203e84:	3a850513          	addi	a0,a0,936 # ffffffffc0205228 <default_pmm_manager+0x58>
ffffffffc0203e88:	cdafc0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc0203e8c <swapfs_write>:
ffffffffc0203e8c:	1141                	addi	sp,sp,-16
ffffffffc0203e8e:	e406                	sd	ra,8(sp)
ffffffffc0203e90:	00855793          	srli	a5,a0,0x8
ffffffffc0203e94:	c3a5                	beqz	a5,ffffffffc0203ef4 <swapfs_write+0x68>
ffffffffc0203e96:	0000d717          	auipc	a4,0xd
ffffffffc0203e9a:	6ba73703          	ld	a4,1722(a4) # ffffffffc0211550 <max_swap_offset>
ffffffffc0203e9e:	04e7fb63          	bgeu	a5,a4,ffffffffc0203ef4 <swapfs_write+0x68>
ffffffffc0203ea2:	0000d717          	auipc	a4,0xd
ffffffffc0203ea6:	69e73703          	ld	a4,1694(a4) # ffffffffc0211540 <pages>
ffffffffc0203eaa:	8d99                	sub	a1,a1,a4
ffffffffc0203eac:	4035d613          	srai	a2,a1,0x3
ffffffffc0203eb0:	00002717          	auipc	a4,0x2
ffffffffc0203eb4:	49873703          	ld	a4,1176(a4) # ffffffffc0206348 <error_string+0x38>
ffffffffc0203eb8:	02e60633          	mul	a2,a2,a4
ffffffffc0203ebc:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203ec0:	00002797          	auipc	a5,0x2
ffffffffc0203ec4:	4907b783          	ld	a5,1168(a5) # ffffffffc0206350 <nbase>
ffffffffc0203ec8:	0000d717          	auipc	a4,0xd
ffffffffc0203ecc:	67073703          	ld	a4,1648(a4) # ffffffffc0211538 <npage>
ffffffffc0203ed0:	963e                	add	a2,a2,a5
ffffffffc0203ed2:	00c61793          	slli	a5,a2,0xc
ffffffffc0203ed6:	83b1                	srli	a5,a5,0xc
ffffffffc0203ed8:	0632                	slli	a2,a2,0xc
ffffffffc0203eda:	02e7f963          	bgeu	a5,a4,ffffffffc0203f0c <swapfs_write+0x80>
ffffffffc0203ede:	60a2                	ld	ra,8(sp)
ffffffffc0203ee0:	0000d797          	auipc	a5,0xd
ffffffffc0203ee4:	6507b783          	ld	a5,1616(a5) # ffffffffc0211530 <va_pa_offset>
ffffffffc0203ee8:	46a1                	li	a3,8
ffffffffc0203eea:	963e                	add	a2,a2,a5
ffffffffc0203eec:	4505                	li	a0,1
ffffffffc0203eee:	0141                	addi	sp,sp,16
ffffffffc0203ef0:	dc2fc06f          	j	ffffffffc02004b2 <ide_write_secs>
ffffffffc0203ef4:	86aa                	mv	a3,a0
ffffffffc0203ef6:	00002617          	auipc	a2,0x2
ffffffffc0203efa:	1ea60613          	addi	a2,a2,490 # ffffffffc02060e0 <default_pmm_manager+0xf10>
ffffffffc0203efe:	45e5                	li	a1,25
ffffffffc0203f00:	00002517          	auipc	a0,0x2
ffffffffc0203f04:	1c850513          	addi	a0,a0,456 # ffffffffc02060c8 <default_pmm_manager+0xef8>
ffffffffc0203f08:	c5afc0ef          	jal	ra,ffffffffc0200362 <__panic>
ffffffffc0203f0c:	86b2                	mv	a3,a2
ffffffffc0203f0e:	06a00593          	li	a1,106
ffffffffc0203f12:	00001617          	auipc	a2,0x1
ffffffffc0203f16:	37e60613          	addi	a2,a2,894 # ffffffffc0205290 <default_pmm_manager+0xc0>
ffffffffc0203f1a:	00001517          	auipc	a0,0x1
ffffffffc0203f1e:	30e50513          	addi	a0,a0,782 # ffffffffc0205228 <default_pmm_manager+0x58>
ffffffffc0203f22:	c40fc0ef          	jal	ra,ffffffffc0200362 <__panic>

ffffffffc0203f26 <printnum>:
ffffffffc0203f26:	02069813          	slli	a6,a3,0x20
ffffffffc0203f2a:	7179                	addi	sp,sp,-48
ffffffffc0203f2c:	02085813          	srli	a6,a6,0x20
ffffffffc0203f30:	e052                	sd	s4,0(sp)
ffffffffc0203f32:	03067a33          	remu	s4,a2,a6
ffffffffc0203f36:	f022                	sd	s0,32(sp)
ffffffffc0203f38:	ec26                	sd	s1,24(sp)
ffffffffc0203f3a:	e84a                	sd	s2,16(sp)
ffffffffc0203f3c:	f406                	sd	ra,40(sp)
ffffffffc0203f3e:	e44e                	sd	s3,8(sp)
ffffffffc0203f40:	84aa                	mv	s1,a0
ffffffffc0203f42:	892e                	mv	s2,a1
ffffffffc0203f44:	fff7041b          	addiw	s0,a4,-1
ffffffffc0203f48:	2a01                	sext.w	s4,s4
ffffffffc0203f4a:	03067f63          	bgeu	a2,a6,ffffffffc0203f88 <printnum+0x62>
ffffffffc0203f4e:	89be                	mv	s3,a5
ffffffffc0203f50:	4785                	li	a5,1
ffffffffc0203f52:	00e7d763          	bge	a5,a4,ffffffffc0203f60 <printnum+0x3a>
ffffffffc0203f56:	347d                	addiw	s0,s0,-1
ffffffffc0203f58:	85ca                	mv	a1,s2
ffffffffc0203f5a:	854e                	mv	a0,s3
ffffffffc0203f5c:	9482                	jalr	s1
ffffffffc0203f5e:	fc65                	bnez	s0,ffffffffc0203f56 <printnum+0x30>
ffffffffc0203f60:	1a02                	slli	s4,s4,0x20
ffffffffc0203f62:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203f66:	00002797          	auipc	a5,0x2
ffffffffc0203f6a:	19a78793          	addi	a5,a5,410 # ffffffffc0206100 <default_pmm_manager+0xf30>
ffffffffc0203f6e:	97d2                	add	a5,a5,s4
ffffffffc0203f70:	7402                	ld	s0,32(sp)
ffffffffc0203f72:	0007c503          	lbu	a0,0(a5)
ffffffffc0203f76:	70a2                	ld	ra,40(sp)
ffffffffc0203f78:	69a2                	ld	s3,8(sp)
ffffffffc0203f7a:	6a02                	ld	s4,0(sp)
ffffffffc0203f7c:	85ca                	mv	a1,s2
ffffffffc0203f7e:	87a6                	mv	a5,s1
ffffffffc0203f80:	6942                	ld	s2,16(sp)
ffffffffc0203f82:	64e2                	ld	s1,24(sp)
ffffffffc0203f84:	6145                	addi	sp,sp,48
ffffffffc0203f86:	8782                	jr	a5
ffffffffc0203f88:	03065633          	divu	a2,a2,a6
ffffffffc0203f8c:	8722                	mv	a4,s0
ffffffffc0203f8e:	f99ff0ef          	jal	ra,ffffffffc0203f26 <printnum>
ffffffffc0203f92:	b7f9                	j	ffffffffc0203f60 <printnum+0x3a>

ffffffffc0203f94 <vprintfmt>:
ffffffffc0203f94:	7119                	addi	sp,sp,-128
ffffffffc0203f96:	f4a6                	sd	s1,104(sp)
ffffffffc0203f98:	f0ca                	sd	s2,96(sp)
ffffffffc0203f9a:	ecce                	sd	s3,88(sp)
ffffffffc0203f9c:	e8d2                	sd	s4,80(sp)
ffffffffc0203f9e:	e4d6                	sd	s5,72(sp)
ffffffffc0203fa0:	e0da                	sd	s6,64(sp)
ffffffffc0203fa2:	f862                	sd	s8,48(sp)
ffffffffc0203fa4:	fc86                	sd	ra,120(sp)
ffffffffc0203fa6:	f8a2                	sd	s0,112(sp)
ffffffffc0203fa8:	fc5e                	sd	s7,56(sp)
ffffffffc0203faa:	f466                	sd	s9,40(sp)
ffffffffc0203fac:	f06a                	sd	s10,32(sp)
ffffffffc0203fae:	ec6e                	sd	s11,24(sp)
ffffffffc0203fb0:	892a                	mv	s2,a0
ffffffffc0203fb2:	84ae                	mv	s1,a1
ffffffffc0203fb4:	8c32                	mv	s8,a2
ffffffffc0203fb6:	8a36                	mv	s4,a3
ffffffffc0203fb8:	02500993          	li	s3,37
ffffffffc0203fbc:	05500b13          	li	s6,85
ffffffffc0203fc0:	00002a97          	auipc	s5,0x2
ffffffffc0203fc4:	174a8a93          	addi	s5,s5,372 # ffffffffc0206134 <default_pmm_manager+0xf64>
ffffffffc0203fc8:	000c4503          	lbu	a0,0(s8)
ffffffffc0203fcc:	001c0413          	addi	s0,s8,1
ffffffffc0203fd0:	01350a63          	beq	a0,s3,ffffffffc0203fe4 <vprintfmt+0x50>
ffffffffc0203fd4:	cd0d                	beqz	a0,ffffffffc020400e <vprintfmt+0x7a>
ffffffffc0203fd6:	85a6                	mv	a1,s1
ffffffffc0203fd8:	0405                	addi	s0,s0,1
ffffffffc0203fda:	9902                	jalr	s2
ffffffffc0203fdc:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203fe0:	ff351ae3          	bne	a0,s3,ffffffffc0203fd4 <vprintfmt+0x40>
ffffffffc0203fe4:	02000d93          	li	s11,32
ffffffffc0203fe8:	4b81                	li	s7,0
ffffffffc0203fea:	4601                	li	a2,0
ffffffffc0203fec:	5d7d                	li	s10,-1
ffffffffc0203fee:	5cfd                	li	s9,-1
ffffffffc0203ff0:	00044683          	lbu	a3,0(s0)
ffffffffc0203ff4:	00140c13          	addi	s8,s0,1
ffffffffc0203ff8:	fdd6859b          	addiw	a1,a3,-35
ffffffffc0203ffc:	0ff5f593          	andi	a1,a1,255
ffffffffc0204000:	02bb6663          	bltu	s6,a1,ffffffffc020402c <vprintfmt+0x98>
ffffffffc0204004:	058a                	slli	a1,a1,0x2
ffffffffc0204006:	95d6                	add	a1,a1,s5
ffffffffc0204008:	4198                	lw	a4,0(a1)
ffffffffc020400a:	9756                	add	a4,a4,s5
ffffffffc020400c:	8702                	jr	a4
ffffffffc020400e:	70e6                	ld	ra,120(sp)
ffffffffc0204010:	7446                	ld	s0,112(sp)
ffffffffc0204012:	74a6                	ld	s1,104(sp)
ffffffffc0204014:	7906                	ld	s2,96(sp)
ffffffffc0204016:	69e6                	ld	s3,88(sp)
ffffffffc0204018:	6a46                	ld	s4,80(sp)
ffffffffc020401a:	6aa6                	ld	s5,72(sp)
ffffffffc020401c:	6b06                	ld	s6,64(sp)
ffffffffc020401e:	7be2                	ld	s7,56(sp)
ffffffffc0204020:	7c42                	ld	s8,48(sp)
ffffffffc0204022:	7ca2                	ld	s9,40(sp)
ffffffffc0204024:	7d02                	ld	s10,32(sp)
ffffffffc0204026:	6de2                	ld	s11,24(sp)
ffffffffc0204028:	6109                	addi	sp,sp,128
ffffffffc020402a:	8082                	ret
ffffffffc020402c:	85a6                	mv	a1,s1
ffffffffc020402e:	02500513          	li	a0,37
ffffffffc0204032:	9902                	jalr	s2
ffffffffc0204034:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204038:	02500793          	li	a5,37
ffffffffc020403c:	8c22                	mv	s8,s0
ffffffffc020403e:	f8f705e3          	beq	a4,a5,ffffffffc0203fc8 <vprintfmt+0x34>
ffffffffc0204042:	02500713          	li	a4,37
ffffffffc0204046:	ffec4783          	lbu	a5,-2(s8)
ffffffffc020404a:	1c7d                	addi	s8,s8,-1
ffffffffc020404c:	fee79de3          	bne	a5,a4,ffffffffc0204046 <vprintfmt+0xb2>
ffffffffc0204050:	bfa5                	j	ffffffffc0203fc8 <vprintfmt+0x34>
ffffffffc0204052:	00144783          	lbu	a5,1(s0)
ffffffffc0204056:	4725                	li	a4,9
ffffffffc0204058:	fd068d1b          	addiw	s10,a3,-48
ffffffffc020405c:	fd07859b          	addiw	a1,a5,-48
ffffffffc0204060:	0007869b          	sext.w	a3,a5
ffffffffc0204064:	8462                	mv	s0,s8
ffffffffc0204066:	02b76563          	bltu	a4,a1,ffffffffc0204090 <vprintfmt+0xfc>
ffffffffc020406a:	4525                	li	a0,9
ffffffffc020406c:	00144783          	lbu	a5,1(s0)
ffffffffc0204070:	002d171b          	slliw	a4,s10,0x2
ffffffffc0204074:	01a7073b          	addw	a4,a4,s10
ffffffffc0204078:	0017171b          	slliw	a4,a4,0x1
ffffffffc020407c:	9f35                	addw	a4,a4,a3
ffffffffc020407e:	fd07859b          	addiw	a1,a5,-48
ffffffffc0204082:	0405                	addi	s0,s0,1
ffffffffc0204084:	fd070d1b          	addiw	s10,a4,-48
ffffffffc0204088:	0007869b          	sext.w	a3,a5
ffffffffc020408c:	feb570e3          	bgeu	a0,a1,ffffffffc020406c <vprintfmt+0xd8>
ffffffffc0204090:	f60cd0e3          	bgez	s9,ffffffffc0203ff0 <vprintfmt+0x5c>
ffffffffc0204094:	8cea                	mv	s9,s10
ffffffffc0204096:	5d7d                	li	s10,-1
ffffffffc0204098:	bfa1                	j	ffffffffc0203ff0 <vprintfmt+0x5c>
ffffffffc020409a:	8db6                	mv	s11,a3
ffffffffc020409c:	8462                	mv	s0,s8
ffffffffc020409e:	bf89                	j	ffffffffc0203ff0 <vprintfmt+0x5c>
ffffffffc02040a0:	8462                	mv	s0,s8
ffffffffc02040a2:	4b85                	li	s7,1
ffffffffc02040a4:	b7b1                	j	ffffffffc0203ff0 <vprintfmt+0x5c>
ffffffffc02040a6:	4785                	li	a5,1
ffffffffc02040a8:	008a0713          	addi	a4,s4,8
ffffffffc02040ac:	00c7c463          	blt	a5,a2,ffffffffc02040b4 <vprintfmt+0x120>
ffffffffc02040b0:	1a060263          	beqz	a2,ffffffffc0204254 <vprintfmt+0x2c0>
ffffffffc02040b4:	000a3603          	ld	a2,0(s4)
ffffffffc02040b8:	46c1                	li	a3,16
ffffffffc02040ba:	8a3a                	mv	s4,a4
ffffffffc02040bc:	000d879b          	sext.w	a5,s11
ffffffffc02040c0:	8766                	mv	a4,s9
ffffffffc02040c2:	85a6                	mv	a1,s1
ffffffffc02040c4:	854a                	mv	a0,s2
ffffffffc02040c6:	e61ff0ef          	jal	ra,ffffffffc0203f26 <printnum>
ffffffffc02040ca:	bdfd                	j	ffffffffc0203fc8 <vprintfmt+0x34>
ffffffffc02040cc:	000a2503          	lw	a0,0(s4)
ffffffffc02040d0:	85a6                	mv	a1,s1
ffffffffc02040d2:	0a21                	addi	s4,s4,8
ffffffffc02040d4:	9902                	jalr	s2
ffffffffc02040d6:	bdcd                	j	ffffffffc0203fc8 <vprintfmt+0x34>
ffffffffc02040d8:	4785                	li	a5,1
ffffffffc02040da:	008a0713          	addi	a4,s4,8
ffffffffc02040de:	00c7c463          	blt	a5,a2,ffffffffc02040e6 <vprintfmt+0x152>
ffffffffc02040e2:	16060463          	beqz	a2,ffffffffc020424a <vprintfmt+0x2b6>
ffffffffc02040e6:	000a3603          	ld	a2,0(s4)
ffffffffc02040ea:	46a9                	li	a3,10
ffffffffc02040ec:	8a3a                	mv	s4,a4
ffffffffc02040ee:	b7f9                	j	ffffffffc02040bc <vprintfmt+0x128>
ffffffffc02040f0:	03000513          	li	a0,48
ffffffffc02040f4:	85a6                	mv	a1,s1
ffffffffc02040f6:	9902                	jalr	s2
ffffffffc02040f8:	85a6                	mv	a1,s1
ffffffffc02040fa:	07800513          	li	a0,120
ffffffffc02040fe:	9902                	jalr	s2
ffffffffc0204100:	0a21                	addi	s4,s4,8
ffffffffc0204102:	46c1                	li	a3,16
ffffffffc0204104:	ff8a3603          	ld	a2,-8(s4)
ffffffffc0204108:	bf55                	j	ffffffffc02040bc <vprintfmt+0x128>
ffffffffc020410a:	85a6                	mv	a1,s1
ffffffffc020410c:	02500513          	li	a0,37
ffffffffc0204110:	9902                	jalr	s2
ffffffffc0204112:	bd5d                	j	ffffffffc0203fc8 <vprintfmt+0x34>
ffffffffc0204114:	000a2d03          	lw	s10,0(s4)
ffffffffc0204118:	8462                	mv	s0,s8
ffffffffc020411a:	0a21                	addi	s4,s4,8
ffffffffc020411c:	bf95                	j	ffffffffc0204090 <vprintfmt+0xfc>
ffffffffc020411e:	4785                	li	a5,1
ffffffffc0204120:	008a0713          	addi	a4,s4,8
ffffffffc0204124:	00c7c463          	blt	a5,a2,ffffffffc020412c <vprintfmt+0x198>
ffffffffc0204128:	10060c63          	beqz	a2,ffffffffc0204240 <vprintfmt+0x2ac>
ffffffffc020412c:	000a3603          	ld	a2,0(s4)
ffffffffc0204130:	46a1                	li	a3,8
ffffffffc0204132:	8a3a                	mv	s4,a4
ffffffffc0204134:	b761                	j	ffffffffc02040bc <vprintfmt+0x128>
ffffffffc0204136:	fffcc793          	not	a5,s9
ffffffffc020413a:	97fd                	srai	a5,a5,0x3f
ffffffffc020413c:	00fcf7b3          	and	a5,s9,a5
ffffffffc0204140:	00078c9b          	sext.w	s9,a5
ffffffffc0204144:	8462                	mv	s0,s8
ffffffffc0204146:	b56d                	j	ffffffffc0203ff0 <vprintfmt+0x5c>
ffffffffc0204148:	000a3403          	ld	s0,0(s4)
ffffffffc020414c:	008a0793          	addi	a5,s4,8
ffffffffc0204150:	e43e                	sd	a5,8(sp)
ffffffffc0204152:	12040163          	beqz	s0,ffffffffc0204274 <vprintfmt+0x2e0>
ffffffffc0204156:	0d905963          	blez	s9,ffffffffc0204228 <vprintfmt+0x294>
ffffffffc020415a:	02d00793          	li	a5,45
ffffffffc020415e:	00140a13          	addi	s4,s0,1
ffffffffc0204162:	12fd9863          	bne	s11,a5,ffffffffc0204292 <vprintfmt+0x2fe>
ffffffffc0204166:	00044783          	lbu	a5,0(s0)
ffffffffc020416a:	0007851b          	sext.w	a0,a5
ffffffffc020416e:	cb9d                	beqz	a5,ffffffffc02041a4 <vprintfmt+0x210>
ffffffffc0204170:	547d                	li	s0,-1
ffffffffc0204172:	05e00d93          	li	s11,94
ffffffffc0204176:	000d4563          	bltz	s10,ffffffffc0204180 <vprintfmt+0x1ec>
ffffffffc020417a:	3d7d                	addiw	s10,s10,-1
ffffffffc020417c:	028d0263          	beq	s10,s0,ffffffffc02041a0 <vprintfmt+0x20c>
ffffffffc0204180:	85a6                	mv	a1,s1
ffffffffc0204182:	0c0b8e63          	beqz	s7,ffffffffc020425e <vprintfmt+0x2ca>
ffffffffc0204186:	3781                	addiw	a5,a5,-32
ffffffffc0204188:	0cfdfb63          	bgeu	s11,a5,ffffffffc020425e <vprintfmt+0x2ca>
ffffffffc020418c:	03f00513          	li	a0,63
ffffffffc0204190:	9902                	jalr	s2
ffffffffc0204192:	000a4783          	lbu	a5,0(s4)
ffffffffc0204196:	3cfd                	addiw	s9,s9,-1
ffffffffc0204198:	0a05                	addi	s4,s4,1
ffffffffc020419a:	0007851b          	sext.w	a0,a5
ffffffffc020419e:	ffe1                	bnez	a5,ffffffffc0204176 <vprintfmt+0x1e2>
ffffffffc02041a0:	01905963          	blez	s9,ffffffffc02041b2 <vprintfmt+0x21e>
ffffffffc02041a4:	3cfd                	addiw	s9,s9,-1
ffffffffc02041a6:	85a6                	mv	a1,s1
ffffffffc02041a8:	02000513          	li	a0,32
ffffffffc02041ac:	9902                	jalr	s2
ffffffffc02041ae:	fe0c9be3          	bnez	s9,ffffffffc02041a4 <vprintfmt+0x210>
ffffffffc02041b2:	6a22                	ld	s4,8(sp)
ffffffffc02041b4:	bd11                	j	ffffffffc0203fc8 <vprintfmt+0x34>
ffffffffc02041b6:	4785                	li	a5,1
ffffffffc02041b8:	008a0b93          	addi	s7,s4,8
ffffffffc02041bc:	00c7c363          	blt	a5,a2,ffffffffc02041c2 <vprintfmt+0x22e>
ffffffffc02041c0:	ce2d                	beqz	a2,ffffffffc020423a <vprintfmt+0x2a6>
ffffffffc02041c2:	000a3403          	ld	s0,0(s4)
ffffffffc02041c6:	08044e63          	bltz	s0,ffffffffc0204262 <vprintfmt+0x2ce>
ffffffffc02041ca:	8622                	mv	a2,s0
ffffffffc02041cc:	8a5e                	mv	s4,s7
ffffffffc02041ce:	46a9                	li	a3,10
ffffffffc02041d0:	b5f5                	j	ffffffffc02040bc <vprintfmt+0x128>
ffffffffc02041d2:	000a2783          	lw	a5,0(s4)
ffffffffc02041d6:	4619                	li	a2,6
ffffffffc02041d8:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc02041dc:	8fb9                	xor	a5,a5,a4
ffffffffc02041de:	40e786bb          	subw	a3,a5,a4
ffffffffc02041e2:	02d64663          	blt	a2,a3,ffffffffc020420e <vprintfmt+0x27a>
ffffffffc02041e6:	00369713          	slli	a4,a3,0x3
ffffffffc02041ea:	00002797          	auipc	a5,0x2
ffffffffc02041ee:	12678793          	addi	a5,a5,294 # ffffffffc0206310 <error_string>
ffffffffc02041f2:	97ba                	add	a5,a5,a4
ffffffffc02041f4:	639c                	ld	a5,0(a5)
ffffffffc02041f6:	cf81                	beqz	a5,ffffffffc020420e <vprintfmt+0x27a>
ffffffffc02041f8:	86be                	mv	a3,a5
ffffffffc02041fa:	00002617          	auipc	a2,0x2
ffffffffc02041fe:	f3660613          	addi	a2,a2,-202 # ffffffffc0206130 <default_pmm_manager+0xf60>
ffffffffc0204202:	85a6                	mv	a1,s1
ffffffffc0204204:	854a                	mv	a0,s2
ffffffffc0204206:	0ea000ef          	jal	ra,ffffffffc02042f0 <printfmt>
ffffffffc020420a:	0a21                	addi	s4,s4,8
ffffffffc020420c:	bb75                	j	ffffffffc0203fc8 <vprintfmt+0x34>
ffffffffc020420e:	00002617          	auipc	a2,0x2
ffffffffc0204212:	f1260613          	addi	a2,a2,-238 # ffffffffc0206120 <default_pmm_manager+0xf50>
ffffffffc0204216:	85a6                	mv	a1,s1
ffffffffc0204218:	854a                	mv	a0,s2
ffffffffc020421a:	0d6000ef          	jal	ra,ffffffffc02042f0 <printfmt>
ffffffffc020421e:	0a21                	addi	s4,s4,8
ffffffffc0204220:	b365                	j	ffffffffc0203fc8 <vprintfmt+0x34>
ffffffffc0204222:	2605                	addiw	a2,a2,1
ffffffffc0204224:	8462                	mv	s0,s8
ffffffffc0204226:	b3e9                	j	ffffffffc0203ff0 <vprintfmt+0x5c>
ffffffffc0204228:	00044783          	lbu	a5,0(s0)
ffffffffc020422c:	00140a13          	addi	s4,s0,1
ffffffffc0204230:	0007851b          	sext.w	a0,a5
ffffffffc0204234:	ff95                	bnez	a5,ffffffffc0204170 <vprintfmt+0x1dc>
ffffffffc0204236:	6a22                	ld	s4,8(sp)
ffffffffc0204238:	bb41                	j	ffffffffc0203fc8 <vprintfmt+0x34>
ffffffffc020423a:	000a2403          	lw	s0,0(s4)
ffffffffc020423e:	b761                	j	ffffffffc02041c6 <vprintfmt+0x232>
ffffffffc0204240:	000a6603          	lwu	a2,0(s4)
ffffffffc0204244:	46a1                	li	a3,8
ffffffffc0204246:	8a3a                	mv	s4,a4
ffffffffc0204248:	bd95                	j	ffffffffc02040bc <vprintfmt+0x128>
ffffffffc020424a:	000a6603          	lwu	a2,0(s4)
ffffffffc020424e:	46a9                	li	a3,10
ffffffffc0204250:	8a3a                	mv	s4,a4
ffffffffc0204252:	b5ad                	j	ffffffffc02040bc <vprintfmt+0x128>
ffffffffc0204254:	000a6603          	lwu	a2,0(s4)
ffffffffc0204258:	46c1                	li	a3,16
ffffffffc020425a:	8a3a                	mv	s4,a4
ffffffffc020425c:	b585                	j	ffffffffc02040bc <vprintfmt+0x128>
ffffffffc020425e:	9902                	jalr	s2
ffffffffc0204260:	bf0d                	j	ffffffffc0204192 <vprintfmt+0x1fe>
ffffffffc0204262:	85a6                	mv	a1,s1
ffffffffc0204264:	02d00513          	li	a0,45
ffffffffc0204268:	9902                	jalr	s2
ffffffffc020426a:	8a5e                	mv	s4,s7
ffffffffc020426c:	40800633          	neg	a2,s0
ffffffffc0204270:	46a9                	li	a3,10
ffffffffc0204272:	b5a9                	j	ffffffffc02040bc <vprintfmt+0x128>
ffffffffc0204274:	01905663          	blez	s9,ffffffffc0204280 <vprintfmt+0x2ec>
ffffffffc0204278:	02d00793          	li	a5,45
ffffffffc020427c:	04fd9263          	bne	s11,a5,ffffffffc02042c0 <vprintfmt+0x32c>
ffffffffc0204280:	00002a17          	auipc	s4,0x2
ffffffffc0204284:	e99a0a13          	addi	s4,s4,-359 # ffffffffc0206119 <default_pmm_manager+0xf49>
ffffffffc0204288:	02800513          	li	a0,40
ffffffffc020428c:	02800793          	li	a5,40
ffffffffc0204290:	b5c5                	j	ffffffffc0204170 <vprintfmt+0x1dc>
ffffffffc0204292:	85ea                	mv	a1,s10
ffffffffc0204294:	8522                	mv	a0,s0
ffffffffc0204296:	152000ef          	jal	ra,ffffffffc02043e8 <strnlen>
ffffffffc020429a:	40ac8cbb          	subw	s9,s9,a0
ffffffffc020429e:	01905963          	blez	s9,ffffffffc02042b0 <vprintfmt+0x31c>
ffffffffc02042a2:	2d81                	sext.w	s11,s11
ffffffffc02042a4:	3cfd                	addiw	s9,s9,-1
ffffffffc02042a6:	85a6                	mv	a1,s1
ffffffffc02042a8:	856e                	mv	a0,s11
ffffffffc02042aa:	9902                	jalr	s2
ffffffffc02042ac:	fe0c9ce3          	bnez	s9,ffffffffc02042a4 <vprintfmt+0x310>
ffffffffc02042b0:	00044783          	lbu	a5,0(s0)
ffffffffc02042b4:	0007851b          	sext.w	a0,a5
ffffffffc02042b8:	ea079ce3          	bnez	a5,ffffffffc0204170 <vprintfmt+0x1dc>
ffffffffc02042bc:	6a22                	ld	s4,8(sp)
ffffffffc02042be:	b329                	j	ffffffffc0203fc8 <vprintfmt+0x34>
ffffffffc02042c0:	85ea                	mv	a1,s10
ffffffffc02042c2:	00002517          	auipc	a0,0x2
ffffffffc02042c6:	e5650513          	addi	a0,a0,-426 # ffffffffc0206118 <default_pmm_manager+0xf48>
ffffffffc02042ca:	11e000ef          	jal	ra,ffffffffc02043e8 <strnlen>
ffffffffc02042ce:	40ac8cbb          	subw	s9,s9,a0
ffffffffc02042d2:	00002a17          	auipc	s4,0x2
ffffffffc02042d6:	e47a0a13          	addi	s4,s4,-441 # ffffffffc0206119 <default_pmm_manager+0xf49>
ffffffffc02042da:	00002417          	auipc	s0,0x2
ffffffffc02042de:	e3e40413          	addi	s0,s0,-450 # ffffffffc0206118 <default_pmm_manager+0xf48>
ffffffffc02042e2:	02800513          	li	a0,40
ffffffffc02042e6:	02800793          	li	a5,40
ffffffffc02042ea:	fb904ce3          	bgtz	s9,ffffffffc02042a2 <vprintfmt+0x30e>
ffffffffc02042ee:	b549                	j	ffffffffc0204170 <vprintfmt+0x1dc>

ffffffffc02042f0 <printfmt>:
ffffffffc02042f0:	715d                	addi	sp,sp,-80
ffffffffc02042f2:	02810313          	addi	t1,sp,40
ffffffffc02042f6:	f436                	sd	a3,40(sp)
ffffffffc02042f8:	869a                	mv	a3,t1
ffffffffc02042fa:	ec06                	sd	ra,24(sp)
ffffffffc02042fc:	f83a                	sd	a4,48(sp)
ffffffffc02042fe:	fc3e                	sd	a5,56(sp)
ffffffffc0204300:	e0c2                	sd	a6,64(sp)
ffffffffc0204302:	e4c6                	sd	a7,72(sp)
ffffffffc0204304:	e41a                	sd	t1,8(sp)
ffffffffc0204306:	c8fff0ef          	jal	ra,ffffffffc0203f94 <vprintfmt>
ffffffffc020430a:	60e2                	ld	ra,24(sp)
ffffffffc020430c:	6161                	addi	sp,sp,80
ffffffffc020430e:	8082                	ret

ffffffffc0204310 <readline>:
ffffffffc0204310:	715d                	addi	sp,sp,-80
ffffffffc0204312:	e486                	sd	ra,72(sp)
ffffffffc0204314:	e0a2                	sd	s0,64(sp)
ffffffffc0204316:	fc26                	sd	s1,56(sp)
ffffffffc0204318:	f84a                	sd	s2,48(sp)
ffffffffc020431a:	f44e                	sd	s3,40(sp)
ffffffffc020431c:	f052                	sd	s4,32(sp)
ffffffffc020431e:	ec56                	sd	s5,24(sp)
ffffffffc0204320:	e85a                	sd	s6,16(sp)
ffffffffc0204322:	e45e                	sd	s7,8(sp)
ffffffffc0204324:	c901                	beqz	a0,ffffffffc0204334 <readline+0x24>
ffffffffc0204326:	85aa                	mv	a1,a0
ffffffffc0204328:	00002517          	auipc	a0,0x2
ffffffffc020432c:	e0850513          	addi	a0,a0,-504 # ffffffffc0206130 <default_pmm_manager+0xf60>
ffffffffc0204330:	d8bfb0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0204334:	4481                	li	s1,0
ffffffffc0204336:	497d                	li	s2,31
ffffffffc0204338:	4a21                	li	s4,8
ffffffffc020433a:	4aa9                	li	s5,10
ffffffffc020433c:	4b35                	li	s6,13
ffffffffc020433e:	0000db97          	auipc	s7,0xd
ffffffffc0204342:	dbab8b93          	addi	s7,s7,-582 # ffffffffc02110f8 <buf>
ffffffffc0204346:	3fe00993          	li	s3,1022
ffffffffc020434a:	da9fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
ffffffffc020434e:	842a                	mv	s0,a0
ffffffffc0204350:	02054363          	bltz	a0,ffffffffc0204376 <readline+0x66>
ffffffffc0204354:	02a95363          	bge	s2,a0,ffffffffc020437a <readline+0x6a>
ffffffffc0204358:	fe99c9e3          	blt	s3,s1,ffffffffc020434a <readline+0x3a>
ffffffffc020435c:	8522                	mv	a0,s0
ffffffffc020435e:	d93fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
ffffffffc0204362:	009b87b3          	add	a5,s7,s1
ffffffffc0204366:	00878023          	sb	s0,0(a5)
ffffffffc020436a:	d89fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
ffffffffc020436e:	2485                	addiw	s1,s1,1
ffffffffc0204370:	842a                	mv	s0,a0
ffffffffc0204372:	fe0551e3          	bgez	a0,ffffffffc0204354 <readline+0x44>
ffffffffc0204376:	4501                	li	a0,0
ffffffffc0204378:	a081                	j	ffffffffc02043b8 <readline+0xa8>
ffffffffc020437a:	03451163          	bne	a0,s4,ffffffffc020439c <readline+0x8c>
ffffffffc020437e:	c489                	beqz	s1,ffffffffc0204388 <readline+0x78>
ffffffffc0204380:	d71fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
ffffffffc0204384:	34fd                	addiw	s1,s1,-1
ffffffffc0204386:	b7d1                	j	ffffffffc020434a <readline+0x3a>
ffffffffc0204388:	d6bfb0ef          	jal	ra,ffffffffc02000f2 <getchar>
ffffffffc020438c:	842a                	mv	s0,a0
ffffffffc020438e:	47a1                	li	a5,8
ffffffffc0204390:	fe0543e3          	bltz	a0,ffffffffc0204376 <readline+0x66>
ffffffffc0204394:	fca944e3          	blt	s2,a0,ffffffffc020435c <readline+0x4c>
ffffffffc0204398:	fef508e3          	beq	a0,a5,ffffffffc0204388 <readline+0x78>
ffffffffc020439c:	01540463          	beq	s0,s5,ffffffffc02043a4 <readline+0x94>
ffffffffc02043a0:	fb6415e3          	bne	s0,s6,ffffffffc020434a <readline+0x3a>
ffffffffc02043a4:	8522                	mv	a0,s0
ffffffffc02043a6:	d4bfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
ffffffffc02043aa:	0000d517          	auipc	a0,0xd
ffffffffc02043ae:	d4e50513          	addi	a0,a0,-690 # ffffffffc02110f8 <buf>
ffffffffc02043b2:	94aa                	add	s1,s1,a0
ffffffffc02043b4:	00048023          	sb	zero,0(s1)
ffffffffc02043b8:	60a6                	ld	ra,72(sp)
ffffffffc02043ba:	6406                	ld	s0,64(sp)
ffffffffc02043bc:	74e2                	ld	s1,56(sp)
ffffffffc02043be:	7942                	ld	s2,48(sp)
ffffffffc02043c0:	79a2                	ld	s3,40(sp)
ffffffffc02043c2:	7a02                	ld	s4,32(sp)
ffffffffc02043c4:	6ae2                	ld	s5,24(sp)
ffffffffc02043c6:	6b42                	ld	s6,16(sp)
ffffffffc02043c8:	6ba2                	ld	s7,8(sp)
ffffffffc02043ca:	6161                	addi	sp,sp,80
ffffffffc02043cc:	8082                	ret

ffffffffc02043ce <strlen>:
ffffffffc02043ce:	00054783          	lbu	a5,0(a0)
ffffffffc02043d2:	872a                	mv	a4,a0
ffffffffc02043d4:	4501                	li	a0,0
ffffffffc02043d6:	cb81                	beqz	a5,ffffffffc02043e6 <strlen+0x18>
ffffffffc02043d8:	0505                	addi	a0,a0,1
ffffffffc02043da:	00a707b3          	add	a5,a4,a0
ffffffffc02043de:	0007c783          	lbu	a5,0(a5)
ffffffffc02043e2:	fbfd                	bnez	a5,ffffffffc02043d8 <strlen+0xa>
ffffffffc02043e4:	8082                	ret
ffffffffc02043e6:	8082                	ret

ffffffffc02043e8 <strnlen>:
ffffffffc02043e8:	4781                	li	a5,0
ffffffffc02043ea:	e589                	bnez	a1,ffffffffc02043f4 <strnlen+0xc>
ffffffffc02043ec:	a811                	j	ffffffffc0204400 <strnlen+0x18>
ffffffffc02043ee:	0785                	addi	a5,a5,1
ffffffffc02043f0:	00f58863          	beq	a1,a5,ffffffffc0204400 <strnlen+0x18>
ffffffffc02043f4:	00f50733          	add	a4,a0,a5
ffffffffc02043f8:	00074703          	lbu	a4,0(a4)
ffffffffc02043fc:	fb6d                	bnez	a4,ffffffffc02043ee <strnlen+0x6>
ffffffffc02043fe:	85be                	mv	a1,a5
ffffffffc0204400:	852e                	mv	a0,a1
ffffffffc0204402:	8082                	ret

ffffffffc0204404 <strcpy>:
ffffffffc0204404:	87aa                	mv	a5,a0
ffffffffc0204406:	0005c703          	lbu	a4,0(a1)
ffffffffc020440a:	0785                	addi	a5,a5,1
ffffffffc020440c:	0585                	addi	a1,a1,1
ffffffffc020440e:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204412:	fb75                	bnez	a4,ffffffffc0204406 <strcpy+0x2>
ffffffffc0204414:	8082                	ret

ffffffffc0204416 <strcmp>:
ffffffffc0204416:	00054783          	lbu	a5,0(a0)
ffffffffc020441a:	e791                	bnez	a5,ffffffffc0204426 <strcmp+0x10>
ffffffffc020441c:	a02d                	j	ffffffffc0204446 <strcmp+0x30>
ffffffffc020441e:	00054783          	lbu	a5,0(a0)
ffffffffc0204422:	cf89                	beqz	a5,ffffffffc020443c <strcmp+0x26>
ffffffffc0204424:	85b6                	mv	a1,a3
ffffffffc0204426:	0005c703          	lbu	a4,0(a1)
ffffffffc020442a:	0505                	addi	a0,a0,1
ffffffffc020442c:	00158693          	addi	a3,a1,1
ffffffffc0204430:	fef707e3          	beq	a4,a5,ffffffffc020441e <strcmp+0x8>
ffffffffc0204434:	0007851b          	sext.w	a0,a5
ffffffffc0204438:	9d19                	subw	a0,a0,a4
ffffffffc020443a:	8082                	ret
ffffffffc020443c:	0015c703          	lbu	a4,1(a1)
ffffffffc0204440:	4501                	li	a0,0
ffffffffc0204442:	9d19                	subw	a0,a0,a4
ffffffffc0204444:	8082                	ret
ffffffffc0204446:	0005c703          	lbu	a4,0(a1)
ffffffffc020444a:	4501                	li	a0,0
ffffffffc020444c:	b7f5                	j	ffffffffc0204438 <strcmp+0x22>

ffffffffc020444e <strchr>:
ffffffffc020444e:	00054783          	lbu	a5,0(a0)
ffffffffc0204452:	c799                	beqz	a5,ffffffffc0204460 <strchr+0x12>
ffffffffc0204454:	00f58763          	beq	a1,a5,ffffffffc0204462 <strchr+0x14>
ffffffffc0204458:	00154783          	lbu	a5,1(a0)
ffffffffc020445c:	0505                	addi	a0,a0,1
ffffffffc020445e:	fbfd                	bnez	a5,ffffffffc0204454 <strchr+0x6>
ffffffffc0204460:	4501                	li	a0,0
ffffffffc0204462:	8082                	ret

ffffffffc0204464 <memset>:
ffffffffc0204464:	ca01                	beqz	a2,ffffffffc0204474 <memset+0x10>
ffffffffc0204466:	962a                	add	a2,a2,a0
ffffffffc0204468:	87aa                	mv	a5,a0
ffffffffc020446a:	0785                	addi	a5,a5,1
ffffffffc020446c:	feb78fa3          	sb	a1,-1(a5)
ffffffffc0204470:	fec79de3          	bne	a5,a2,ffffffffc020446a <memset+0x6>
ffffffffc0204474:	8082                	ret

ffffffffc0204476 <memcpy>:
ffffffffc0204476:	ca19                	beqz	a2,ffffffffc020448c <memcpy+0x16>
ffffffffc0204478:	962e                	add	a2,a2,a1
ffffffffc020447a:	87aa                	mv	a5,a0
ffffffffc020447c:	0005c703          	lbu	a4,0(a1)
ffffffffc0204480:	0585                	addi	a1,a1,1
ffffffffc0204482:	0785                	addi	a5,a5,1
ffffffffc0204484:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204488:	fec59ae3          	bne	a1,a2,ffffffffc020447c <memcpy+0x6>
ffffffffc020448c:	8082                	ret
