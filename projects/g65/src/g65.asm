	.include "stddefs.inc"

	.global reset_isr

	.section	.text

reset_isr:
    sei             			; Disable interrupts
    cld             			; Clear decimal mode
    ldx #$ff        			; Initialize stack pointer to $01ff
    txs

	jsr sys_init
	
.cmd_prompt_loop:

	jsr print_cmd_prompt

	jsr parser_cmd_line_reset

	jsr get_cmd_line

	jsr get_cmd

	cpy #$00	
	beq .cmd_prompt_loop

	jsr get_cmd_address

	jsr dispatch_cmd

	jmp .cmd_prompt_loop

halt:
	jmp halt          				; End of program

print_cmd_prompt:
	lda #<cmd_prompt_msg
	sta R6
	lda #>cmd_prompt_msg
	sta R7
	jsr sys_puts
	rts

;=========================================================================================================

	.section .rodata
cmd_prompt_msg:		.asciiz "g65> "
