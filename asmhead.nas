; haribote-os boot asm
; TAB=4

[INSTRSET "i486p"]

VBEMODE	EQU	0x103	; 1024 x  768 x 8bitｲﾊﾉｫ
;0x100 :  640 x  400 x 8bitｲﾊﾉｫ
;0x101 :  640 x  480 x 8bitｲﾊﾉｫ
;0x103 :  800 x  600 x 8bitｲﾊﾉｫ
;0x105 : 1024 x  768 x 8bitｲﾊﾉｫ
;0x107 : 1280 x 1024 x 8bitｲﾊﾉｫ

BOTPAK	EQU	0x00280000		; bootpackのロード先
DSKCAC	EQU	0x00100000		; ディスクキャッシュの場所
DSKCAC0	EQU	0x00008000		; ディスクキャッシュの場所（リアルモード）

; BOOT_INFO
CYLS	EQU	0x0ff0		;ﾉ雜ｨﾆ�ｶｯﾇ�
LEDS	EQU	0x0ff1
VMODE	EQU	0x0ff2		;ｹﾘﾓﾚﾑﾕﾉｫﾊ�ﾄｿｵﾄﾐﾅﾏ｢｣ｬﾑﾕﾉｫｵﾄﾎｻﾊ�
SCRNX	EQU	0x0ff4		;ﾆﾁﾄｻｷﾖｱ貭ﾊX
SCRNY	EQU	0x0ff6		;ﾆﾁﾄｻｷﾖｱ貭ﾊY
VRAM	EQU	0x0ff8		;ﾍｼﾏ�ｻｺｳ衂�ｵﾄｿｪﾊｼｵﾘﾖｷ

	ORG	0xc200		;ｳﾌﾐ�ﾗｰﾔﾘｵﾄｵﾘﾖｷ

;ﾈｷﾈﾏVBEﾊﾇｷ�ｴ贇ﾚ
	MOV	AX,0x9000
	MOV	ES,AX
	MOV	DI,0
	MOV	AX,0x4f00
	INT	0x10
	CMP	AX,0x004f
	JNE	scrn320

;ｼ�ｲ餬BEｵﾄｰ豎ｾ
	MOV	AX,[ES:DI+4]
	CMP	AX,0x0200
	JB	scrn320		; if (AX < 0x0200) goto scrn320

;ﾈ｡ｵﾃｻｭﾃ貽｣ﾊｽﾐﾅﾏ｢
	MOV	CX,VBEMODE
	MOV	AX,0x4f01
	INT	0x10
	CMP	AX,0x004f
	JNE	scrn320

;ｻｭﾃ貽｣ﾊｽﾐﾅﾏ｢ｵﾄﾈｷﾈﾏ
	CMP	BYTE [ES:DI+0x19],8
	JNE	scrn320
	CMP	BYTE [ES:DI+0x1b],4
	JNE	scrn320
	MOV	AX,[ES:DI+0x00]
	AND	AX,0x0080
	JZ	scrn320		;ﾄ｣ﾊｽﾊ�ﾐﾔｵﾄbit7ﾊﾇ0｣ｬﾋ�ﾒﾔｷﾅﾆ�

;ｻｭﾃ貽｣ﾊｽｵﾄﾇﾐｻｻ
	MOV	BX,VBEMODE+0x4000
	MOV	AX,0x4f02
	INT	0x10
	MOV	BYTE [VMODE],8
	MOV	AX,[ES:DI+0x12]
	MOV	[SCRNX],AX
	MOV	AX,[ES:DI+0x14]
	MOV	[SCRNY],AX
	MOV	EAX,[ES:DI+0x28]
	MOV	[VRAM],EAX
	JMP	keystatus

scrn320:			;ﾉ雜ｨｻｭﾃ貽｣ﾊｽ1
	MOV	AL,0x13		;VGA 320*200
	MOV	AH,0x00
	INT	0x10
	MOV	BYTE [VMODE],8
	MOV	WORD [SCRNX],320
	MOV	WORD [SCRNY],200
	MOV	DWORD [VRAM],0x000a0000

;ﾓﾃBIOSﾈ｡ｵﾃｼ�ﾅﾌﾉﾏｵﾄｸ�ﾖﾖLEDﾖｸﾊｾｵﾆｵﾄﾗｴﾌｬ
keystatus:
	MOV	AH,0x02
	INT	0x16 		; keyboard BIOS
	MOV	[LEDS],AL


;**********

; PICｹﾘｱﾕﾒｻﾇﾐﾖﾐｶﾏ
; ｸ�ｾﾝATｼ貶ﾝｻ�ｵﾄｹ貂�｣ｬﾈ郢�ﾒｪｳ�ﾊｼｻｯPIC｣ｬｱﾘﾐ�ﾔﾚCLI ﾖｮﾇｰｽ�ﾐﾐ｣ｬｷ�ﾔ�ﾓﾐﾊｱｻ盪ﾒﾆ�
; ﾋ貅�ｽ�ﾐﾐPICｵﾄｳ�ﾊｼｻｯ

	MOV	AL,0xff
	OUT	0x21,AL
	NOP			; ﾈ郢�ﾁｬﾐ�ﾖｴﾐﾐOUTﾖｸﾁ�｣ｬﾓﾐﾐｩｻ�ﾖﾖｻ睾ﾞｷｨﾕ�ｳ｣ﾔﾋﾐﾐ
	OUT	0xa1,AL
	CLI			; ｽ�ﾖｹCPUｼｶｱ�ｵﾄﾖﾐｶﾏ

; ﾎｪﾁﾋﾈﾃCPUﾄﾜｹｻｷﾃﾎﾊ1MBﾒﾔﾉﾏｵﾄﾄﾚｴ豼ﾕｼ茱ｬﾉ雜ｨA20GATE

	CALL	waitkbdout
	MOV	AL,0xd1
	OUT	0x64,AL
	CALL	waitkbdout
	MOV	AL,0xdf		; enable A20
	OUT	0x60,AL
	CALL	waitkbdout

; ﾇﾐｻｻｵｽｱ｣ｻ､ﾄ｣ﾊｽ

[INSTRSET "i486p"]

	LGDT	[GDTR0]		; ﾉ雜ｨﾁﾙﾊｱGDT
	MOV	EAX,CR0
	AND	EAX,0x7fffffff
	OR	EAX,0x00000001	; bit0ﾎｪ1｣ｬﾎｪﾁﾋﾇﾐｻｻｵｽｱ｣ｻ､ﾄ｣ﾊｽ
	MOV	CR0,EAX
	JMP	pipelineflush
pipelineflush:
	MOV	AX,1*8		;  ｿﾉｶﾁﾐｴｵﾄｶﾎ 32bit
	MOV	DS,AX
	MOV	ES,AX
	MOV	FS,AX
	MOV	GS,AX
	MOV	SS,AX

; bootpackｵﾄﾗｪﾋﾍ

	MOV	ESI,bootpack	; ﾗｪﾋﾍﾔｴ
	MOV	EDI,BOTPAK	; ﾗｪﾋﾍﾄｿｵﾄｵﾘ
	MOV	ECX,512*1024/4
	CALL	memcpy

; ｴﾅﾅﾌﾊ�ｾﾝﾗ�ﾖﾕﾗｪﾋﾍｵｽﾋ�ｱｾﾀｴｵﾄﾎｻﾖﾃﾈ･

; ﾊﾗﾏﾈｴﾓﾆ�ｶｯﾉﾈﾇ�ｿｪﾊｼ

	MOV	ESI,0x7c00	; ﾗｪﾋﾍﾔｴ
	MOV	EDI,DSKCAC	; ﾗｪﾋﾍﾄｿｵﾄｵﾘ
	MOV	ECX,512/4
	CALL	memcpy

; ﾋ�ﾓﾐﾊ｣ﾏﾂｵﾄ

	MOV	ESI,DSKCAC0+512	; ﾗｪﾋﾍﾔｴ
	MOV	EDI,DSKCAC+512	; ﾗｪﾋﾍﾄｿｵﾄｵﾘ
	MOV	ECX,0
	MOV	CL,BYTE [CYLS]
	IMUL	ECX,512*18*2/4	; ｴﾓﾖ�ﾃ賁�ｱ莉ｻﾎｪﾗﾖｽﾚﾊ�/4
	SUB	ECX,512/4	; ｼ�ﾈ･ IPL
	CALL	memcpy

; ｱﾘﾐ�ﾓﾉasmheadﾍ�ｳﾉｵﾄｹ､ﾗ�｣ｬﾖﾁｴﾋﾈｫｲｿﾍ�ｱﾏ
;	ﾒﾔｺ�ｾﾍｽｻﾓﾉbootpackﾀｴﾍ�ｳﾉ

; bootpackｵﾄﾆ�ｶｯ

	MOV	EBX,BOTPAK
	MOV	ECX,[EBX+16]
	ADD	ECX,3		; ECX += 3;
	SHR	ECX,2		; ECX /= 4;
	JZ	skip		; ﾃｻﾓﾐﾒｪﾗｪﾋﾍｵﾄｶｫﾎ�ﾊｱ
	MOV	ESI,[EBX+20]	; ﾗｪﾋﾍﾔｴ
	ADD	ESI,EBX
	MOV	EDI,[EBX+12]	; ﾗｪﾋﾍﾄｿｵﾄｵﾘ
	CALL	memcpy
skip:
	MOV	ESP,[EBX+12]	; ﾕｻｳ�ﾊｼﾖｵ
	JMP	DWORD 2*8:0x0000001b

waitkbdout:
	IN		AL,0x64
	AND		AL,0x02
	JNZ		waitkbdout		; ｲ簗ﾔ
	RET

memcpy:
	MOV	EAX,[ESI]
	ADD	ESI,4
	MOV	[EDI],EAX
	ADD	EDI,4
	SUB	ECX,1
	JNZ	memcpy
	RET
; memcpy ﾄﾚｴ賁�ｾﾝｴｫﾋﾍｳﾌﾐ�

	ALIGNB	16
GDT0:
	RESB	8				; NULL selector
	DW	0xffff,0x0000,0x9200,0x00cf	; ｿﾉﾒﾔｶﾁﾐｴｵﾄｶﾎ｣ｨsegment｣ｩ32bit
	DW	0xffff,0x0000,0x9a28,0x0047	; ｿﾉﾒﾔﾖｴﾐﾐｵﾄｶﾎ｣ｨsegment｣ｩ32bit｣ｨbootpack ﾊｹﾓﾃ｣ｩ

	DW	0
GDTR0:
	DW	8*3-1
	DD	GDT0

	ALIGNB	16
bootpack:
