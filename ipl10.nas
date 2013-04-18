; hello-os
; TAB=4
	CYLS	EQU	10	;�����������
	ORG	0x7c00		; ָ�������װ�ص�ַ

; ���µļ������ڱ�׼FAT12��ʽ����

	JMP	entry
	DB	0x90
	DB	"ThinkTom"	; �����������ƣ�8�ֽڣ�
	DW	512		; ÿ��������С
	DB	1		; �صĴ�С
	DW	1		; FAT����ʼλ��
	DB	2		; FAT�ĸ���
	DW	224		; ��Ŀ¼�Ĵ�С
	DW	2880		; �ô��̵Ĵ�С
	DB	0xf0		; ��������
	DW	9		; FAT�ĳ���
	DW	18		; 1���ŵ��м�������
	DW	2		; ��ͷ��
	DD	0		; ��ʹ�÷���
	DD	2880		; ���̴�С
	DB	0,0,0x29	
	DD	0xffffffff	
	DB	"ThinkTom   "	;��������
	DB	"FAT12   "	;���̸�ʽ����
	RESB	18		;�ճ�18�ֽ�

; �������

entry:
	MOV	AX,0		; �Ĵ�����0
	MOV	SS,AX
	MOV	SP,0x7c00
	MOV	DS,AX
	MOV	ES,AX

	MOV	AX,0x0820
	MOV	ES,AX
	MOV	CH,0		; ����0
	MOV	DH,0		; ��ͷ0
	MOV	CL,2		; ����2
readloop:
	MOV	SI,0		;��¼ʧ�ܴ���
retry:
	MOV	AH,0x02		; ����
	MOV	AL,1		; 1������
	MOV	BX,0
	MOV	DL,0x00		; A������
	INT	0x13		; ���ô���BIOS
	JNC	next		;δ��������next
	ADD	SI,1
	CMP	SI,5
	JAE	error
	MOV	AH,0x00
	MOV	DL,0x00
	INT	0x13		;����������
	JMP	retry
next:
	MOV	AX,ES
	ADD	AX,0x0020	;�ѵ�ַ�ڴ������0x200
	MOV	ES,AX
	ADD	CL,1		;����
	CMP	CL,18
	JBE	readloop	;С�ڵ���18������ʱ��ѭ��
	MOV	CL,1
	ADD	DH,1		;��ͷ
	CMP	DH,2
	JB	readloop
	MOV	DH,0
	ADD	CH,1		;����<CYLS
	CMP	CH,CYLS
	JB	readloop
fin:
	MOV	[0x0ff0],CH
	JMP	0xc200		;��ת��haribote ����
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