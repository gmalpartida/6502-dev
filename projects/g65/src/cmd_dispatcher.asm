	.include "cmd_dispatcher.inc"

DISPATCH_CMD_TABLE_LEN = $07
DISPATCH_CMD_REC_SIZE = $05

;===============================================================================
	.section .text

dispatch_cmd_table:
	reset_cmd:		CMD_REC $00, RESET_CMD,		process_reset_cmd
	clear_cmd:		CMD_REC $01, CLEAR_CMD,		process_clear_cmd
	peek_cmd:		CMD_REC $02, PEEK_CMD,		process_peek_cmd
	poke_cmd:		CMD_REC $03, POKE_CMD,		process_poke_cmd
	dump_cmd:		CMD_REC $04, DUMP_CMD,		process_dump_cmd
	load_cmd:		CMD_REC $05, LOAD_CMD,		process_load_cmd
	goto_cmd:		CMD_REC $06, GOTO_CMD,		process_goto_cmd
	unknown_cmd:	CMD_REC $07, $00,			process_unknown_cmd

; executes the function associated with the command name
; executes unknown command if not found.
; --> R7:R6		address of the command name to dispatch
; <-- none		
dispatch_cmd:
	jsr dispatch_is_cmd
	; x contains offset of cmd to dispatch

	lda dispatch_cmd_table + CMD_REC.cmd_addr, x
	sta R4
	lda dispatch_cmd_table + CMD_REC.cmd_addr + 1, x
	sta R5

	jmp (R4)
	
	rts

; loops through table to find a match for the command passed
; --> R7:R6		address of the command to look for
; <-- C			carry set if found, otherwise clear
; <-- X			offset of table entry found or unknown command handler
dispatch_is_cmd:
	ldx #$00
.loop:
	lda dispatch_cmd_table + CMD_REC.cmd_nme, x
	sta R4
	lda dispatch_cmd_table + CMD_REC.cmd_nme + 1, x
	sta R5
	ora R4
	beq .not_found

	jsr strcmp							; compare R7:R6 to R5:R4
	bcs .found
	; go to next record
	txa									; increase x by CMD_REC size
	clc
	adc #DISPATCH_CMD_REC_SIZE
	tax									
	bra .loop
.found:
	sec
	rts
.not_found:
	clc
	rts

;===============================================================================
	.section .rodata

RESET_CMD:		.asciiz		"reset"
CLEAR_CMD:		.asciiz		"clear"
PEEK_CMD:		.asciiz		"peek"
POKE_CMD:		.asciiz		"poke"
DUMP_CMD:		.asciiz		"dump"
LOAD_CMD:		.asciiz		"load"
GOTO_CMD:		.asciiz		"goto"
