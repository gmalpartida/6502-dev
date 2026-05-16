	.section .text

	.global strcpy, memcpy, memset, memcmp, memchr

; copies a asciiz 
; --> R0, R1: address of source string
; --> R2, R3: address of destination string

strcpy:
	ldy #0            				; Y is the index for the string
strcpy_loop:
	lda (R0L), y   					; Load byte from ROM
	sta (R2L), y 					; Store to RAM at (DEST_PTR), Y
	beq strcpy_exit   				; If we hit the 0 terminator, this page is done
	iny
	bne strcpy_loop   				; Loop back for next character
strcpy_exit:
	rts


; copies a number of bytes from src to dest
; --> R0: address of src
; --> R2: address of dest
; --> R4: count of bytes to copy
memcpy:
        ldy #0
memcpy_loop:
        ; 16-bit check: is count (R4) == 0?
        lda R4
        ora R5
        beq memcpy_exit

        ; Copy one byte
        lda (R0L), y
        sta (R2L), y

        ; Increment pointers (16-bit)
        inc R0
        bne memcpy_skip1
        inc R1
memcpy_skip1:
		inc R2
        bne memcpy_skip2
        inc R3
memcpy_skip2:
        ; Decrement 16-bit count (R4)
        lda R4
        bne memcpy_skip3
        dec R5
memcpy_skip3:
		dec R4

        jmp memcpy_loop

memcpy_exit:
        rts

; memset: copies an unsigned character into each of the first count characters of the dest buffer
; --> R0, R1: address of destination buffer
; --> R2: character to be copied
; --> R4, R5: how many times to copy ( 16-bit )

memset:
    ldy #0
memset_loop:
	; 16-bit check: is count (R4) == 0?
	lda R4
	ora R5		
	beq memcpy_exit					; exit if both are zero

	; Copy one byte
	lda R2
	sta (R0L), y

	; Increment pointers (16-bit)
	inc R0
	bne memset_skip
	inc R1
	
memset_skip:
	; Decrement 16-bit count (R4)
	lda R4
	bne memset_skip2
	dec R5
memset_skip2:
	dec R4

	jmp memset_loop

memset_exit:
	rts

; compares the first n bytes of two buffers
; --> R0, R1: address of first buffer
; --> R2, R3: address of second buffer
; --> R4, R5: count of bytes to compare
; <-- A: 0 if equal, 0xff if first is less than second, 0x01 if first is greater than second

memcmp:
        ldy #0
memcmp_loop:
		lda	#$00
		sta R6
        ; 16-bit check: is count (R4) == 0?
        lda R4
        ora R5
        beq memcmp_exit						; exit if both are 00

        ; Compare one byte
        lda (R0L), y
		sta R7
        lda (R2L), y
		cmp R7
		beq memcmp_inc
		bmi memcmp_neg
		lda #$01
		sta R6
		jmp memcmp_exit
memcmp_neg:
		lda #$ff
		sta R6
		jmp memcmp_exit
		
memcmp_inc:
        ; Increment pointers (16-bit)
        inc R0
        bne memcmp_skip1
        inc R1
memcmp_skip1:
		inc R2
        bne memcmp_skip2
        inc R3
memcmp_skip2:
        ; Decrement 16-bit count (R4)
        lda R4
        bne memcmp_skip3
        dec R5
memcmp_skip3:
		dec R4

        jmp memcmp_loop

memcmp_exit:
		lda #$00
		clc
		adc R6
        rts

memchr:

	rts


