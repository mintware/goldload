;
; Loader for Golden Axe
;
; Copyright (c) 2015 Vitaly Sinilin
;
; 27 Aug 2015
;

cpu 286

%macro res_fptr 0
.off		resw	1
.seg		resw	1
%endmacro

PSP_SZ		equ	100h
STACK_SZ	equ	32

section code

main:
..start:	mov	bx, PSP_SZ + __stktop		; new size in pars
		shr	bx, 4
		mov	ah, 4Ah				; resize memory block
		int	21h

		push	cs				; init bss
		pop	es				;
		mov	al, 0				;
		mov	di, __bss			;
		mov	cx, __bssend - __bss		;
		cld
		rep stosb				;

		push	cs				; setup data segment
		pop	ds

		mov	ax, 3521h			; read int 21h vector
		int	21h				; es:bx <- cur handler
		mov	[int21.seg], es			; save original
		mov	[int21.off], bx			; int 21h vector

		mov	dx, int_handler			; setup our own
		mov	ax, 2521h			; handler for int 21h
		int	21h				; ds:dx -> new handler

		mov	[cmdtail.seg], cs		; pass cmd tail from
		mov	word [cmdtail.off], 80h		; our PSP
		mov	dx, exe
		mov	bx, parmblk
		mov	ax, 4B00h			; exec
		int	21h

		jnc	.exit
		call	uninstall
		mov	dx, errmsg
		mov	ah, 9
		int	21h

.exit:		mov	ah, 4Dh				; read errorlevel
		int	21h				; errorlevel => AL
		mov	ah, 4Ch				; exit
		int	21h

;------------------------------------------------------------------------------

int_handler:
		cmp	ah, 4Ah
		jne	.legacy
		dec	byte [cs:intcnt]
		jnz	.legacy
		pusha

		mov	byte [ds:4842h], 1	; skip prot. question
		mov	byte [ds:4845h], 0	; imitate correct answer

		call	uninstall	; restore original vector of int 21h

		popa
.legacy:	jmp	far [cs:int21]

;------------------------------------------------------------------------------

uninstall:
		push	ds
		mov	ds, [cs:int21.seg]
		mov	dx, [cs:int21.off]
		mov	ax, 2521h
		int	21h
		pop	ds
		ret

;------------------------------------------------------------------------------

intcnt		db	2
errmsg		db	"Unable to exec original "
exe		db	"gold.exe",0,"$"

section bss

__bss		equ	$
parmblk		resw	1				; environment seg
cmdtail		res_fptr				; cmd tail
		resd	1				; first FCB address
		resd	1				; second FCB address

int21		res_fptr
__bssend	equ	$

section stack stack align=16

		resb	STACK_SZ
__stktop	equ	$

group all code bss stack
