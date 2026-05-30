
	.include "stddefs.inc"

	.global parser_cmd_line_init
	.global parser_cmd_line_next_token
	.global parser_cmd_line_set_test_command
	.global parser_cmd_line_get_buffer
	.global parser_cmd_line_reset

parser_cmd_line_init:
	lda #$00
	sta cmd_line_buffer_pos

	lda #<cmd_line_buffer
	sta R6
	lda #>cmd_line_buffer
	sta R7
	lda #$00
	sta R5
	lda #$00
	sta R2
	lda #$01
	sta R3
	jsr memset

	rts

parser_cmd_line_skip_blanks:

	ldy cmd_line_buffer_pos

.next_char:
	lda cmd_line_buffer, y
	beq .exit
	cmp #SPC
	bne .exit
	iny	
	bra .next_char
.exit:
	sty cmd_line_buffer_pos
	rts

parser_cmd_line_next_token:
	jsr parser_cmd_line_skip_blanks

	ldx cmd_line_buffer_pos
	ldy #$00
.next_char:
	lda cmd_line_buffer, x
	beq .exit
	cmp #SPC
	beq .exit
	sta (R6), y
	iny
	inx
	bra .next_char
.exit:
	cpy #$00
	beq .empty_buffer
	stx cmd_line_buffer_pos
	sec
	rts
.empty_buffer:
	clc
	rts

parser_cmd_line_get_buffer:
	lda #<cmd_line_buffer
	sta R6
	lda #>cmd_line_buffer
	sta R7

	rts

parser_cmd_line_reset:
	lda #$00
	sta cmd_line_buffer_pos
	rts

parser_cmd_line_set_test_command:

	lda #<cmd_line_buffer
	sta R4
	lda #>cmd_line_buffer
	sta R5
	jsr memcpy

	rts

;===============================================================================
	.section .bss
cmd_line_buffer:		.ds	256			; text entered by user at the command prompt
cmd_line_buffer_pos		.ds 1			; holds position of char being read


