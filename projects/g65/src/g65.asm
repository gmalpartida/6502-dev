	.include "stddefs.inc"

	.global uart_rx_isr

	.section	.text

reset_isr:
    sei             			; Disable interrupts
    cld             			; Clear decimal mode
    ldx #$ff        			; Initialize stack pointer to $01ff
    txs

	jsr init_regs				; initialize all registers to 00
	jsr uart_init
	jsr parser_cmd_line_init

	lda #$FF        ; Set all Port B pins to output
    sta VIA1_DDRB
	sta VIA1_DDRA

	cli

	jsr delay

	jsr print_logo
	jsr println

	jsr print_copyright

	jsr println
	jsr println
	
.cmd_prompt_loop:

	jsr print_cmd_prompt

	jsr process_user_input

	jmp .cmd_prompt_loop


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

nib2ahex:
	lda R7
    cmp #$0A        ; Check if it's a letter (A-F)
    bcc .is_digit
    clc             ; Always clear carry before the first ADC
    adc #$06        ; Offset for A-F (adds 6 + 1 carry = 7)
.is_digit:
    adc #$30        ; Add '0' offset ($30)
    rts

ahex2nib:
	lda R7
    cmp #$61
    bcc .upper
    sec
    sbc #$20
.upper:
    sec
    sbc #$30
    cmp #$0A
    bcc .exit
    sec
    sbc #$07
.exit:
    rts

print_hex_byte:
	lda R7
	pha
	lsr
	lsr
	lsr
	lsr
	jsr nib2ahex
	jsr uart_tx_char
	pla
	and #$0f
	jsr nib2ahex
	jsr uart_tx_char

	rts


read_hex_byte:
	jsr ahex2nib

	rts

read_hex_word:
	; read first hex char from command line
	; convert to binary
	; save to 
	; read second hex char from command line

	rts

print_hex_word:
	lda R5
	jsr print_hex_byte
	lda R4
	jsr print_hex_byte
	rts

print_cmd_prompt:
	lda #<cmd_prompt_msg
	sta R6
	lda #>cmd_prompt_msg
	sta R7
	jsr uart_tx_asciiz
	rts

get_cmd_line:
	jsr parser_cmd_line_get_buffer
	jsr uart_rx_asciiz
	rts

print_logo:

	lda #<g65_logo
	sta R4
	lda #>g65_logo
	sta R5
	ldy #$00

.next_char:
	lda (R4), y
	beq .exit
	jsr uart_tx_char
	iny
	bne .next_char
	inc R5
	bra .next_char
.exit:
	rts

print_copyright:
	lda #TAB
	jsr uart_tx_char
	jsr uart_tx_char
	jsr uart_tx_char
	jsr uart_tx_char
	lda #<copyright_txt
	sta R6
	lda #>copyright_txt
	sta R7
	jsr uart_tx_asciiz
	rts

get_cmd:
	lda #<cmd
	sta R6
	lda #>cmd
	sta R7
	jsr parser_cmd_line_next_token
	lda #NULL
	sta cmd, y
	rts

get_addr:
	lda #<addr
	sta R6
	lda #>addr
	sta R7
	jsr parser_cmd_line_next_token
	rts

process_user_input:
	jsr parser_cmd_line_reset
	jsr get_cmd_line
	jsr get_cmd
	lda #<cmd
	sta R6
	lda #>cmd
	sta R7
	jsr uart_tx_asciiz

	lda #<cmd
	sta R6
	lda #>cmd
	sta R7
	lda #<peek_cmd
	sta R4
	lda #>peek_cmd
	sta R5
	lda #$04
	sta R2
	lda #$00
	sta R3
	jsr memcmp
	bcs .error
	jsr process_peek_command
	bra .exit
.error:
	jsr print_unknown_cmd_msg
	rts
.exit

	rts

process_peek_command:
	lda #SPC
	jsr uart_tx_char
	jsr get_addr
	ldy #$04
	ldx #$00
.next_char:
	lda addr, x
	jsr uart_tx_char
	inx
	dey
	bne .next_char
	jsr println
.error:
	sec							; error
	rts
.exit
	clc							; no error
	rts

print_unknown_cmd_msg:
	lda #<unknown_cmd_msg
	sta R6
	lda #>unknown_cmd_msg
	sta R7
	jsr uart_tx_asciiz
	jsr println
	rts


;=========================================================================================================
nmi_isr:
    rti             			; Return from Non-Maskable Interrupt

	.section .rodata
cmd_prompt_msg:		.asciiz "g65> "
unknown_cmd_msg:	.asciiz "Unknown command."
peek_cmd:			.asciiz "peek"

	.section .vectors
		.word	nmi_isr			; nmi vector
		.word	reset_isr		;points to start of code
		.word	uart_rx_isr			; irq vector


	.section .bss
cmd:		.ds		$20
addr:		.ds		$04
byte_value:	.ds		$02
word_value:	.ds		$04


