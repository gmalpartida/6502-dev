.section.text

	.global R0
	.global R4

reset_isr:
    sei             			; Disable interrupts
    cld             			; Clear decimal mode
    ldx #$ff        			; Initialize stack pointer to $01ff
    txs

	jsr init_regs				; initialize all registers to 00
	jsr uart_init

	lda #$FF        ; Set all Port B pins to output
    sta VIA1_DDRB
	sta VIA1_DDRA


	lda #<quick_brown_fox_txt
	sta R6
	lda #>quick_brown_fox_txt
	sta R7
	jsr uart_tx_asciiz
	jsr println
	
	lda #<$1000
	sta R4
	lda #>$1000
	sta R5
	lda #44
	sta R3

test_ram_loop:

	lda R5
	cmp #$80
	bpl halt
	jsr print_testing_mem_address_msg
	lda #' '
	jsr uart_tx_char

	; print destination address R5:R4
	jsr print_hex_word
	jsr println

	lda R5
	adc #$10
	sta R5

	jsr memcpy

	jsr memcmp

	bcc test_ram_failed
	jmp test_ram_passed


test_ram_failed:
	lda #'$'
	lda #<test_ram_failed_msg
	sta R6
	lda #>test_ram_failed_msg
	sta R7
	jsr uart_tx_asciiz
	jsr println
	jmp test_via
test_ram_passed:
	lda #'$'
	lda #<test_ram_passed_msg
	sta R6
	lda #>test_ram_passed_msg
	sta R7
	jsr uart_tx_asciiz
	jsr println
test_via:
	lda #$55
	sta VIA1_DRA
    lda #$AA        ; Pattern 10101010
    sta VIA1_DRB
	jsr delay
	lda #$aa
	sta VIA1_DRA
    lda #$55        ; Pattern 01010101
    sta VIA1_DRB
	jsr delay
    jmp test_ram_loop

halt:
	jmp halt          				; End of program

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

; Simple delay loop (approx. 0.5s at 1MHz)
delay:
	ldy #$FF
d1:
	ldx #$FF
d2:
	dex
	bne d2
	dey
	bne d1
	rts


println:
	lda #$0d
	jsr uart_tx_char
	lda #$0a
	jsr uart_tx_char
	rts

nmi_isr:
    rti             			; Return from Non-Maskable Interrupt

irq_isr:
    rti             			; Return from Maskable Interrupt / BRK

; copy the first count of bytes from one memory block to another
; --> R7, R6: source address
; --> R5, R4: destination address
; --> R3: count of bytes to copy
; <-- none
memcpy:
	ldy #0
	;if length is 0, nothing to do
	lda R3
	beq .memcpy_exit
.memcpy_loop:
	lda (R6), y
	sta (R4), y
	iny
	cpy R3
	bne .memcpy_loop
.memcpy_exit:
	rts

; compare the first count of bytes from one memory block with another
; --> R7, R6: source address
; --> R5, R4: destination address
; --> R3: count of bytes to compare
; <-- carry set if success, otherwise carry cleared
memcmp:
	ldy #0
	beq .memcmp_success
.memcmp_loop:
	lda (R6), y
	cmp (R4), y
	bne .memcmp_fail
	iny
	cpy R3
	bne .memcmp_loop
.memcmp_success:
	sec
	rts
.memcmp_fail:
	clc
	rts

asc_bin2hex:
	lda R7
    and #$0F        ; Mask to ensure we only have one nibble (0-F)
    cmp #$0A        ; Check if it's a letter (A-F)
    bcc .is_digit
    clc             ; Always clear carry before the first ADC
    adc #$06        ; Offset for A-F (adds 6 + 1 carry = 7)
.is_digit:
    adc #$30        ; Add '0' offset ($30)
    rts

print_testing_mem_address_msg:
	; save address
	lda R7
	pha
	lda R6
	pha

	lda #<testing_mem_address_msg
	sta R6
	lda #>testing_mem_address_msg
	sta R7
	jsr uart_tx_asciiz
	
	;restore address
	pla
	sta R6
	pla
	sta R7

	rts

print_hex_byte:

	; save address
	lda R6
	pha
	lda R7
	pha

	pha
	lsr
	lsr
	lsr
	lsr
	sta R7
	jsr asc_bin2hex
	jsr uart_tx_char
	pla
	sta R7
	jsr asc_bin2hex
	jsr uart_tx_char

	; restore address
	pla
	sta R7
	pla
	sta R6
	rts

print_hex_word:
	lda R5
	jsr print_hex_byte
	lda R4
	jsr print_hex_byte
	jsr println
	rts

	.section .rodata
quick_brown_fox_txt: .asciiz "The quick brown fox jumps over the lazy dog."
test_ram_passed_msg: .asciiz "Ram test passed."
test_ram_failed_msg: .asciiz "Ram test failed."
testing_mem_address_msg: .asciiz "Testing memory address..."
quick_brown_fox_txt2: .asciiz "The quick brown fox jumps over the lazy dog."

	.section .vectors
		.word	nmi_isr			; nmi vector
		.word	reset_isr		;points to start of code
		.word	irq_isr			; irq vector

