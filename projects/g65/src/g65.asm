	.include "stddefs.inc"

	.global reset_isr

	.section	.text

reset_isr:
	jsr sys_init
	
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

print_hex_word:
	lda R5
	jsr sys_print_hex_byte
	lda R4
	jsr sys_print_hex_byte
	rts

print_cmd_prompt:
	lda #<cmd_prompt_msg
	sta R6
	lda #>cmd_prompt_msg
	sta R7
	jsr sys_puts
	rts

process_user_input:
	jsr parser_cmd_line_reset

	jsr get_cmd_line

	jsr get_cmd

	cpy #$00
	beq .exit
	jsr is_peek_cmd
	bcs .is_poke
	jsr process_peek_cmd
	bra .exit
.is_poke:
	jsr is_poke_cmd
	bcs .is_reset
	jsr process_poke_cmd
	bra .exit
.is_reset:
	jsr is_reset_cmd
	bcs .is_clear
	jsr process_reset_cmd
	bra .exit
.is_clear:
	jsr is_clear_cmd
	bcs .is_dump
	jsr process_clear_cmd
	bra .exit
.is_dump:
	jsr is_dump_cmd
	bcs .is_load
	jsr process_dump_cmd
	bra .exit
.is_load:
	jsr is_load_cmd
	bcs .is_goto
	jsr process_load_cmd
	bra .exit
.is_goto:
	jsr is_goto_cmd
	bcs .error
	jsr process_goto_cmd
	bra .exit
.error:
	jsr process_unknown_cmd
.exit

	rts

;=========================================================================================================

	.section .rodata
cmd_prompt_msg:		.asciiz "g65> "
