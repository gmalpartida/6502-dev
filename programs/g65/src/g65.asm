
; --- Hardware Map ---
VIA_BASE  = $C000   ; Y6
UART_BASE = $A000   ; Y5
TICKS     = $00     ; RAM counter

; UART Register Offsets
RBR_THR   = UART_BASE + 0
DLL       = UART_BASE + 0
DLM       = UART_BASE + 1
LCR       = UART_BASE + 3
LSR       = UART_BASE + 5

	.include "stddefs.inc"
	.section .text

reset_isr:
    sei             			; Disable interrupts
    cld             			; Clear decimal mode
    ldx #$ff        			; Initialize stack pointer to $01ff
    txs

	jsr init_regs				; initialize all registers to 00

test_memset:
	lda #$00					; destination buffer
	sta R0L
	lda #$02
	sta R0H
	
	lda #$ff					; character to copy
	sta R2

	lda #$00					; count of bytes to copy
	sta R4L
	lda #$06
	sta R4H

	jsr memset

	ldx #$2
test_memcpy:
	
	; load source adddress
	lda #<little_brown_fox_txt
	sta R0L
	lda #>little_brown_fox_txt
	sta R0H

	; load destination address
	lda #$00
	sta R2L
	txa
	sta R2H

	; load count of bytes to copy
	lda #$2C
	sta R4L
	lda #$00
	sta R4H
	stx R2H

	jsr memcpy
	inx
	cpx #8
	bne test_memcpy
        
	ldx #$02
test_memcmp:

	; load source adddress
	lda #<little_brown_fox_txt
	sta R0L
	lda #>little_brown_fox_txt
	sta R0H

	; load destination address
	lda #$00
	sta R2L
	txa
	sta R2H

	; load count of bytes to copy
	lda #$2C
	sta R4L
	lda #$00
	sta R4H
	stx R2H

	jsr memcmp
	cmp #$00
	bmi halt
	bpl halt

	inx
	cpx #8
	bne test_memcmp

halt:   
	jmp halt          				; End of program

; transmits one ascii character via the uart
; --> a: contains character to be sent
; <-- none
uart_tx_char:
    LDA LSR          	; Read Line Status Register
    AND #$20         	; Check THRE bit (Transmit Holding Reg Empty)
    BEQ uart_tx_char	; Wait if busy
	nop				 	; slow it down a little bit
    STA RBR_THR      	; Send it!
	rts

uart_init:
    LDA #$80         ; Access Divisor Latches (DLAB=1)
    STA LCR
    LDA #$13         ; Divisor = 19 ($13)
    STA DLL
    LDA #$00
    STA DLM
    LDA #$03         ; 8 data bits, 1 stop, No parity (DLAB=0)
    STA LCR
	rts

init_regs:
	lda #$00
	sta R0
	sta R1
	sta R2
	sta R3
	sta R4
	sta R5
	sta R6
	sta R7
	
	rts

nmi_isr:
    rti             				; Return from Non-Maskable Interrupt

irq_isr:
    rti             				; Return from Maskable Interrupt / BRK

	.section .rodata
		little_brown_fox_txt: .asciiz "The quick brown fox jumps over the lazy dog."

	.section .vectors
		.word	nmi_isr				; nmi vector
		.word	reset_isr			;points to start of code
		.word	irq_isr				; irq vector

