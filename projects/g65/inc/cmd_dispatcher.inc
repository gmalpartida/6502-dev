	.include "stddefs.inc"

	.struct CMD_REC
		cmd_id:		.db	$00
		cmd_nme:	.dw	$00
		cmd_addr:	.dw $00
	.endstruct

; executes the function associated with the command name
; executes unknown command if not found.
; --> R7:R6		address of the command name to dispatch
; <-- none		
	.global dispatch_cmd

; loops through table to find a match for the command passed
; --> R7:R6		address of the command to look for
; <-- C			carry set if found, otherwise clear
; <-- X			offset of table entry found or unknown
	.global dispatch_is_cmd

