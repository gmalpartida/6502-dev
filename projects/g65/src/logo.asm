	.include "logo.inc"

	.section .rodata

g65_logo:
	.db		TAB, "_____/\\\\\\\\\\\\____________/\\\\\___/\\\\\\\\\\\\\\\_         ", CR, LF 
	.db		TAB, " ___/\\\//////////_________/\\\\////___\/\\\///////////__        ", CR, LF
	.db		TAB, "  __/\\\_________________/\\\///________\/\\\_____________       ", CR, LF
	.db		TAB, "   _\/\\\____/\\\\\\\___/\\\\\\\\\\\_____\/\\\\\\\\\\\\_____     ", CR, LF
	.db		TAB, "    _\/\\\___\/////\\\__/\\\\///////\\\___\////////////\\\___    ", CR, LF
	.db		TAB, "     _\/\\\_______\/\\\_\/\\\______\//\\\_____________\//\\\__   ", CR, LF
	.db		TAB, "      _\/\\\_______\/\\\_\//\\\______/\\\___/\\\________\/\\\__  ", CR, LF
	.db		TAB, "       _\//\\\\\\\\\\\\/___\///\\\\\\\\\/___\//\\\\\\\\\\\\\/___ ", CR, LF
	.db		TAB, "        __\////////////_______\/////////______\/////////////_____", CR, LF, NULL

copyright_txt:	.asciiz	"Copyright Gino Malpartida 2026"

	.section .text

print_logo:

	lda #<g65_logo
	sta R4
	lda #>g65_logo
	sta R5
	ldy #$00

.next_char:
	lda (R4), y
	beq .exit
	jsr sys_putc
	iny
	bne .next_char
	inc R5
	bra .next_char
.exit:
	rts

print_copyright:
	lda #TAB
	jsr sys_putc
	jsr sys_putc
	jsr sys_putc
	lda #<copyright_txt
	sta R6
	lda #>copyright_txt
	sta R7
	jsr sys_puts
	rts

