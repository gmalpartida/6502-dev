.segment "CODE"
reset_isr:
    sei             ; Disable interrupts
    cld             ; Clear decimal mode
    ldx #$ff        ; Initialize stack pointer to $01ff
    txs

    ; Your code starts here
    lda #$40
    sta $41
    brk             ; Force a software interrupt (triggers irq_isr)

nmi_isr:
    rti             ; Return from Non-Maskable Interrupt

irq_isr:
    rti             ; Return from Maskable Interrupt / BRK

.segment "VECTORS"
.word nmi_isr    ; $FFFA
.word reset_isr  ; $FFFC
.word irq_isr    ; $FFFE

