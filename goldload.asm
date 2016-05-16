;
; Loader for Golden Axe
;
; Copyright (c) 2015 Vitaly Sinilin
;
; 27 Aug 2015
;

cpu 286

%macro far_ptr 2
.off		dw	%2
.seg		dw	%1
%endmacro

PSP_SZ		equ	100h

section .text

		org	100h

main:		mov	sp, stktop
		mov	bx, (PSP_SZ+stktop-main)/16 + 1	; new size in pars
		mov	ah, 4Ah				; resize memory block
		int	21h

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
		inc	byte [cs:intcnt]
		cmp	byte [cs:intcnt], 2
		jne	.legacy
		pusha
		push	ds
		push	es

		mov	byte [ds:4842h], 1	; skip prot. question
		mov	byte [ds:4845h], 0	; imitate correct answer

		call	uninstall	; restore original vector of int 21h

		pop	es
		pop	ds
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

intcnt		db	0
parmblk		dw	0				; environment seg
cmdtail		far_ptr	0, 0				; cmd tail
		dd	0				; first FCB address
		dd	0				; second FCB address

int21		far_ptr	0, 0
errmsg		db	"Unable to exec original "
exe		db	"gold.exe",0,"$"

stktop		equ	$+64
