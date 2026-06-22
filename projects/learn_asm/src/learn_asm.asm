	.section .text

reset_vector:
    sei             ; Disable interrupts
    cld             ; Clear decimal mode
    ldx #$ff        ; Initialize stack pointer to $01ff
    txs

	lda #$55
	sta $02
.loop:
	lda #$80
	sta $01

	lda #$00
	sta $00

	ldy #$00
	lda $02
	sta ($00), y

	lda #$80
	sta $01
	lda #$01
	sta $00

	ldy #$00
	lda $02
	sta ($00), y

	; invert the bits
	lda $02
	eor #$ff
	sta $02

	ldy #$ff
.delay:
	
	ldx #$ff
.delay1:
	dex
	cpx #$00
	bne .delay1
	dey
	cpy #$00
	bne .delay

	bra .loop

	jmp ($fffc)

nmi_vector:
    rti             ; Return from Non-Maskable Interrupt

irq_vector:
    rti             ; Return from Maskable Interrupt / BRK

	.section .rodata
little_brown_fox_txt: .asciiz "The quick brown fox jumps over the lazy dog."

	.section .vectors
	.word	nmi_vector		; nmi vector
	.word	reset_vector	;points to start of code
	.word	irq_vector		; irq vector

