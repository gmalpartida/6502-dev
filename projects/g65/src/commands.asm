	.include "commands.inc"

	.section .text

process_poke_cmd:
	jsr get_addr
	bcc .error
	lda #<addr
	sta R6
	lda #>addr
	sta R7
	jsr ahex2byte
	sta R1

	jsr inc_addr

	jsr ahex2byte
	sta R0

	jsr get_value
	bcc .error
	lda #<value
	sta R6
	lda #>value
	sta R7
	jsr ahex2byte

	ldy #$00
	sta (R0), y

	lda #<addr
	sta R6
	lda #>addr
	sta R7
	ldy #$00
.next_char:
	lda (R6), y
	jsr sys_putc
	iny
	cpy #$04
	bne .next_char

	lda #':'
	jsr sys_putc

	ldy #$00
	lda (R0), y
	jsr sys_print_hex_byte	

	jsr sys_println
.error:

.exit
	rts

process_peek_cmd:
	jsr get_addr
	bcc .error	
	lda #<addr
	sta R6
	lda #>addr
	sta R7
	jsr ahex2byte
	sta R1

	jsr inc_addr

	jsr ahex2byte
	sta R0

	lda #<addr
	sta R6
	lda #>addr
	sta R7
	ldy #$00
.next_char:	
	lda (R6), y
	jsr sys_putc
	iny
	cpy #$04
	bne .next_char

	lda #':'
	jsr sys_putc

	ldy #$00
	lda (R0), y
	jsr sys_print_hex_byte	

	jsr sys_println
.error:

.exit
	rts

process_reset_cmd:

	jmp ($fffc)

	rts

get_cmd_line:
	jsr parser_cmd_line_get_buffer
	jsr sys_gets
	rts

get_cmd:
	jsr get_cmd_address
	jsr parser_cmd_line_next_token
	; add NULL character to turn it into an asciiz
	lda #NULL
	sta cmd, y
	rts

get_cmd_address:
	lda #<cmd
	sta R6
	lda #>cmd
	sta R7
	rts

get_addr:
	lda #<addr
	sta R6
	lda #>addr
	sta R7
	jsr parser_cmd_line_next_token
	rts

get_value:
	lda #<value
	sta R6
	lda #>value
	sta R7
	jsr parser_cmd_line_next_token
	rts

inc_addr:
	clc             ; Clear carry for addition
    lda R6          ; Load low byte
    adc #2          ; Add 2 (moves past 2 ASCII hex chars)
    sta R6          ; Save low byte
    lda R7          ; Load high byte
    adc #0          ; Add carry if low byte overflowed
    sta R7          ; Save high byte
	rts

print_addr:
	ldy #$00
.next_byte:
	lda addr, y			
	jsr sys_putc
	iny
	cpy #$04
	beq .exit
	bra .next_byte
.exit:
	rts

print_cmd:
	lda #<cmd
	sta R6
	lda #>cmd
	sta R7
	jsr sys_puts
	rts


addr2bin:
	; convert ascii address to binary
	lda #<addr
	sta R6
	lda #>addr
	sta R7
	jsr ahex2byte
	sta R1
	lda #<(addr+2)
	sta R6
	lda #>(addr+2)
	sta R7
	jsr ahex2byte
	sta R0
	rts

process_clear_cmd:
	jsr  vt102_clrscrn
	rts

process_unknown_cmd:
	lda #<unknown_cmd_msg
	sta R6
	lda #>unknown_cmd_msg
	sta R7
	jsr sys_puts
	jsr sys_println
	rts

print_dump_col_headers:
	ldy #$00
.next_col:
	tya
	jsr byte2ahex
	lda R7
	jsr sys_putc
	lda R6
	jsr sys_putc
	lda #SPC
	jsr sys_putc
	jsr sys_putc
	iny
	tya
	and #$0f
	beq .exit
	bra .next_col
.exit:
	rts

process_dump_cmd:
	jsr get_addr							; retrieve address as 4 hex ascii chars	
	jsr sys_printtab
	
	jsr print_dump_col_headers
	jsr sys_println

	jsr addr2bin							; convert address to binary, saved to R1:R0

	ldy #$00								; y keeps count of columns
	ldx #$10								; x keeps count of rows

.next_line:
	; R1:R0 contain address to be printed

	;print address high byte in R1
	lda R1
	jsr byte2ahex
	lda R7
	jsr sys_putc
	lda R6
	jsr sys_putc
	
	;print address low byte in R0
	lda R0
	jsr byte2ahex
	lda R7
	jsr sys_putc
	lda R6
	jsr sys_putc

	lda #TAB
	jsr sys_putc
	
	ldy #$00					; init column count
.next_column:
	lda (R0), y					; read byte value at address R1:R0, offset y
	jsr byte2ahex				; convert byte to 2 hex ascii chars
	lda R7
	jsr sys_putc
	lda R6
	jsr sys_putc
	lda #SPC
	jsr sys_putc
	jsr sys_putc
	iny
	cpy #$10				; have 16 columns been printed
	bne .next_column		; go to next column
	jsr sys_println				; end of line
	tya						; increment address
	clc
	adc R0
	sta R0
	bcc .nocarry
	inc R1

.nocarry
	ldy #$00				; init column count
	dex 
	bne .next_line			; go to next line
.exit:
	rts

process_load_cmd:
	jsr get_addr							; retrieve address as 4 hex ascii chars	
	
	jsr addr2bin							; convert address to binary, saved to R1:R0

	; R1:R0 contain address to which data will be stored
	lda #$20
	sta ihex_row_count						; keeps row count for checksum validation
.next_record:
	; read record marker
	jsr uart_rx_char				; read next char from buffer
	cmp #':'
	bne .next_record				; keep looping till marker is received

	jsr sys_read_hex_byte				; record length
	sta ihex_rec_len				; store record length

	jsr sys_read_hex_byte				; read upper byte of address, ignore
	sta ihex_address + 1
	jsr sys_read_hex_byte				; read lower byte of address, ignore
	sta ihex_address

	jsr sys_read_hex_byte				; read record type
	sta ihex_rec_type				; store record type

	lda ihex_rec_len						; initialize checksum with record length
	sta ihex_checksum
.next_byte:
	ldx ihex_rec_len				; have we read all bytes?
	cpx #$00
	beq .checksum
	dex
	stx ihex_rec_len
	jsr sys_read_hex_byte				; process data byte
	ldy #$00
	sta (R0), y
	clc
	adc ihex_checksum
	sta ihex_checksum
.inc_addr:
	inc R0							; increment address
	bne .nocarry
	inc R1

.nocarry:
	bra .next_byte

.checksum:
	jsr sys_read_hex_byte			; read received checksum
	pha								; save for later
	lda ihex_rec_type
	cmp #$00						; if data record, then go read next record, otherwise exit
	beq .continue
	pla
	bra .exit
.continue:
	jsr sys_printspc
	pla
	pha
	jsr calc_checksum				; ihex_checksum = record checksum
	pha
	pla
	pla
	clc
	adc ihex_checksum				;  add calculated checksum, sum should be 0
	jsr print_checksum_validation
	;jsr sys_println
	bra .next_record
.exit:
	jsr sys_println
	rts

print_checksum_validation:
	beq .checksum_valid
	lda #'x'
	jsr sys_putc
	bra .exit
.checksum_valid:
	lda #'.'
	jsr sys_putc
.exit:
	lda ihex_row_count
	dec 
	beq .new_line
	sta ihex_row_count
	rts
.new_line:
	lda #$20
	sta ihex_row_count						; reset row count
	jsr sys_println						; start a new line every 32 rows
	rts

calc_checksum:
	lda ihex_checksum
	clc
	;adc ihex_rec_len						; record length was added at the beginning
	adc ihex_rec_type
	clc
	adc ihex_address
	clc
	adc ihex_address + 1
	sta ihex_checksum
	rts

process_goto_cmd:
	jsr get_addr
	jsr addr2bin								; R1:R0 = address
	
	sec
	lda R0
	sbc #$01
	sta R0
	lda R1
	sbc #$00
	sta R1
	lda R1
	pha
	lda R0
	pha
	rts

	rts


	.section .rodata

unknown_cmd_msg:		.asciiz		"unknown"

	.section .bss
cmd:			.ds		$20
addr:			.ds		$04
value:			.ds		$02
ihex_rec_len	.ds		$01
ihex_rec_type	.ds		$01
ihex_checksum	.ds		$01
ihex_address	.ds		$02
ihex_row_count	.ds		$01
