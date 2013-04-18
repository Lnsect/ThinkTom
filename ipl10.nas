; hello-os
; TAB=4
	CYLS	EQU	10	;读入的柱面数
	ORG	0x7c00		; 指明程序的装载地址

; 以下的记述用于标准FAT12格式软盘

	JMP	entry
	DB	0x90
	DB	"ThinkTom"	; 启动区的名称（8字节）
	DW	512		; 每个扇区大小
	DB	1		; 簇的大小
	DW	1		; FAT的起始位置
	DB	2		; FAT的个数
	DW	224		; 根目录的大小
	DW	2880		; 该磁盘的大小
	DB	0xf0		; 磁盘种类
	DW	9		; FAT的长度
	DW	18		; 1个磁道有几个扇区
	DW	2		; 磁头数
	DD	0		; 不使用分区
	DD	2880		; 磁盘大小
	DB	0,0,0x29	
	DD	0xffffffff	
	DB	"ThinkTom   "	;磁盘名称
	DB	"FAT12   "	;磁盘格式名称
	RESB	18		;空出18字节

; 程序核心

entry:
	MOV	AX,0		; 寄存器清0
	MOV	SS,AX
	MOV	SP,0x7c00
	MOV	DS,AX
	MOV	ES,AX

	MOV	AX,0x0820
	MOV	ES,AX
	MOV	CH,0		; 柱面0
	MOV	DH,0		; 磁头0
	MOV	CL,2		; 扇区2
readloop:
	MOV	SI,0		;记录失败次数
retry:
	MOV	AH,0x02		; 读盘
	MOV	AL,1		; 1个扇区
	MOV	BX,0
	MOV	DL,0x00		; A驱动器
	INT	0x13		; 调用磁盘BIOS
	JNC	next		;未出错跳至next
	ADD	SI,1
	CMP	SI,5
	JAE	error
	MOV	AH,0x00
	MOV	DL,0x00
	INT	0x13		;重置驱动器
	JMP	retry
next:
	MOV	AX,ES
	ADD	AX,0x0020	;把地址内存向后移0x200
	MOV	ES,AX
	ADD	CL,1		;扇区
	CMP	CL,18
	JBE	readloop	;小于等于18扇区的时候循环
	MOV	CL,1
	ADD	DH,1		;磁头
	CMP	DH,2
	JB	readloop
	MOV	DH,0
	ADD	CH,1		;柱面<CYLS
	CMP	CH,CYLS
	JB	readloop
fin:
	MOV	[0x0ff0],CH
	JMP	0xc200		;跳转到haribote 程序
	JMP	fin

error:
	MOV	SI,msg
putloop:
	MOV	AL,[SI]
	ADD	SI,1
	CMP	AL,0
	JE	fin
	MOV	AH,0x0e
	MOV	BX,15
	INT	0x10
	JMP	putloop
msg:
	DB	0x0a, 0x0a
	DB	"load error"
	DB	0x0a
	DB	0

	RESB	0x7dfe-$

	DB	0x55, 0xaa