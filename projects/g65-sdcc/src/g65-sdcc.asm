	.area text (ABS, OVR)
	.org 0xe000

reset_isr:
    sei             ; Disable interrupts
    cld             ; Clear decimal mode
    ldx #0hff        ; Initialize stack pointer to $01ff
    txs

    ; Your code starts here
    lda #0h40
    sta 0h41
    brk             ; Force a software interrupt (triggers irq_isr)

nmi_isr:
    rti             ; Return from Non-Maskable Interrupt

irq_isr:
    rti             ; Return from Maskable Interrupt / BRK

	.org 0xfffa
	.word	nmi_isr		; nmi vector
	.word	reset_isr	;points to start of code
	.word	irq_isr		; irq vector
