; --- hardware map ---
via_base  = $c000   ; y6
uart_base = $a000   ; y5
ticks     = $00     ; ram counter
via_porta = via_base + 1
via_ddra = via_base + 3

; Baud Rate Divisors for 1.8432 MHz Crystal
; Divisor = 1,843,200 / (16 * 9600) = 12 ($000C)
BAUD_LOW  = $19
BAUD_HIGH = $00

; uart register offsets
uart_rbr_thr	= uart_base + 0
uart_dll       	= uart_base + 0
uart_dlm       	= uart_base + 1
uart_ier		= uart_base + 1
uart_lcr       	= uart_base + 3
uart_mcr 		= uart_base + 4
uart_lsr       	= uart_base + 5

.section .text
reset:
    ldx #$ff
    txs             ; always init stack first!

    ; --- 1. initialize via 
    lda #$ff
    sta via_ddra ; ddra = output
    
	lda #$aa
	sta via_porta
    ; --- 2. initialize uart (9600 baud @ 2.88mhz) ---
	jsr uart_init

	jsr print_hello_world

	jsr print_newln

uart_echo_loop:
	jsr uart_rx_char

	jsr uart_tx_char

	sta via_porta

	jmp uart_echo_loop

halt:
	jmp halt
    
; transmits one ascii character via the uart
; --> a: contains character to be sent
; <-- none
uart_tx_char:
	tax
uart_tx_char_wait:
    lda uart_lsr          	; read line status register
    and #$20         	; check thre bit (transmit holding reg empty)
    beq uart_tx_char_wait	; wait if busy
	nop				 	; slow it down a little bit
	txa
    sta uart_rbr_thr      	; send it!
	rts

; usage: ldx #<msg_addr : ldy #>msg_addr : jsr print_str
uart_tx_asciz:
    stx $00         ; use zero page $00/$01 as a pointer
    sty $01
    ldy #0
uart_tx_asciiz_loop:
    lda ($00), y    ; get char
    beq done       ; null terminator?
    jsr uart_tx_char
    iny
    bne uart_tx_asciiz_loop       ; max 255 chars
done:
    rts

uart_init:
    ; 1. Enable DLAB (Bit 7) to access divisor latches
    lda #$80
    sta uart_lcr

    ; 2. Set Baud Rate (9600)
    lda #BAUD_LOW
    sta uart_dll       ; DLL (same address as RBR/THR when DLAB=1)
    lda #BAUD_HIGH
    sta uart_dlm       ; DLM (same address as IER when DLAB=1)

    ; 3. Set Data Format: 8 Bits, No Parity, 1 Stop Bit ($03)
    ; This also clears DLAB (Bit 7 = 0)
    lda #$03
    sta uart_lcr

    ; 4. (Optional) Initialize Modem Control (Set DTR and RTS High)
    lda #$03
    sta uart_mcr

    ; 5. Disable all interrupts for simple polling mode
    lda #$00
    sta uart_ier
    rts

uart_rx_char:
	lda uart_lsr
	and #$01
	beq uart_rx_char
	lda uart_rbr_thr
	rts

print_hello_world:

	ldx #<hello_world_msg 
	ldy #>hello_world_msg
	jsr uart_tx_asciz
	rts

print_newln:
	lda #$0a
	jsr uart_tx_char
	lda #$0d
	jsr uart_tx_char
	rts

	.section .vectors
    .word $0000     ; nmi
    .word reset     ; reset
    .word $0000		; irq at $fffe


	.section .text

hello_world_msg: .asciiz "hello, world!"


