; --- hardware address ---
port = $6000

	.include "stddefs.inc"
	.section .text

reset:
	jsr walking_bit
	jmp reset

walking_bit:
    ldx #$01        ; start with bit 0 (0000 0001)

loop:
    stx port        ; write pattern to the 74hc373
    
    ; --- human-visible delay ---
    ; at 1.44mhz, we need a "nested" loop to slow it down
    ldy #$00        ; outer loop
delay_out:
    lda #$80        ; inner loop (adjust this value to speed/slow)
delay_in:
    dea				; decrement a
    bne delay_in    ; loop inner
    dey             ; decrement y
    bne delay_out   ; loop outer

    ; --- shift the bit ---
    txa             ; move x to accumulator
    asl             ; shift left (bit 0 -> bit 1, etc.)
    tax             ; move back to x
    
    bne loop        ; if we haven't shifted the bit out, keep walking
	rts

    ;beq reset       ; if x became 0, start over at bit 0

; --- 65c02 vectors (must be at the very end of rom) ---
	.section .vectors
    .word reset     ; reset vector (points to $e000)
    .byte $00, $00     ; irq vector (not used)
