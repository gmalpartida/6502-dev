	.include "bios.inc"

	.section .bios

sys_init:			jmp bios_init		; Initialize UART, VIA, Queues, Variables
sys_getc:			jmp uart_rx_char	; Non-blocking: Get character (Carry set = success)
sys_putc:			jmp uart_tx_char	; Blocking: Transmit character in A
sys_puts:			jmp uart_tx_asciiz	; Print null-terminated string at R1:R0
sys_gets:			jmp uart_rx_asciiz	; rean null-terminated string
sys_println:		jmp println			; Send CR/LF
sys_printtab:		jmp printtab		; prints tab
sys_printspc:		jmp printspc		; prints a space
sys_print_hex_byte:	jmp print_hex_byte	; Print A as two hex ASCII characters
sys_read_hex_byte:	jmp read_hex_byte	; get hex byte
sys_print_logo:		jmp print_logo		; prints the system's logo
sys_print_copyright jmp print_copyright	; prints copyright statement
sys_clrscrn:		jmp vt102_clrscrn	; clears screen

bios_init:

	jsr init_regs				; initialize all registers to 00
	jsr uart_init
	jsr parser_cmd_line_init

	lda #$FF        ; configure ports a and b for output
	jsr via6522_porta_config
	jsr via6522_portb_config

	cli							; enable interrupts

	jsr sys_clrscrn

	jsr print_logo
	jsr sys_println

	jsr print_copyright

	jsr sys_println
	jsr sys_println
	rts

printspc:
	lda #SPC
	jsr uart_tx_char
	rts

printtab:
	lda #TAB
	jsr uart_tx_char
	rts

println:
	lda #CR
	jsr uart_tx_char
	lda #LF
	jsr uart_tx_char
	rts

;==============================================================================
; prints an hex value as two ascii characters
; --> a: byte to be printed
; <-- none
; Modifies: a
;==============================================================================
print_hex_byte:
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

;==============================================================================
; reads two ascii hex characters from input buffer and converts them to a byte
;--> none
;<-- a: byte equivalent of two hex characters read.
; Modifies: a, R5
;==============================================================================
read_hex_byte:
	jsr uart_rx_char
	jsr ahex2nib
	asl
	asl
	asl
	asl
	sta R5
.read_char:
	jsr uart_rx_char
	jsr ahex2nib
	ora R5

	rts

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



