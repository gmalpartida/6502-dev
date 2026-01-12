reset_isr:	
	lda $40
	sta $41
	brk

nmi_isr:

irq_isr:

.segment "VECTORS"
.word nmi_isr    ; $FFFA - Non-maskable interrupt
.word reset_isr  ; $FFFC - Reset vector (where code starts)
.word irq_isr    ; $FFFE - Maskable interrupt / BRK


