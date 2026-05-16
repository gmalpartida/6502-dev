	.section .text

; Register Offsets for NS16C450
	.global UART_BASE
	.global RHR_THR
	.global IER
	.global LCR
	.global MCR
	.global LSR
	.global uart_init
	.global uart_tx_char
	.global uart_rx_char
	.global uart_tx_asciiz
	.global UART_REGS

; Define the internal structure layout
	.struct UART_REGS
RBR		db 0
THR     = RBR
DLL     = RBR
IER		db 0 
DLM     = IER
IIR     db 0
LCR		db 0
MCR		db 0
LSR		db 0
MSR		db 0
SCR		db 0
	.endstruct

UART_BASE = $8400
RHR_THR   = UART_BASE + 0  ; Receiver / Transmitter Holding
IER       = UART_BASE + 1  ; Interrupt Enable
LCR       = UART_BASE + 3  ; Line Control (DLAB is Bit 7)
MCR       = UART_BASE + 4  ; Modem Control
LSR       = UART_BASE + 5  ; Line Status

uart_init:
    lda #$83          ; 1000 0011 -> DLAB=1, 8 bits, 1 stop, no parity
    sta LCR
    
    ;LDA #$01          ; Divisor Low = 1 (for 115,200 baud @ ~1.8MHz)
	;lda #$0c		; divisor low = 12 for 9600bps @ 1.8mhz
	lda #$02			; divisor low = 2 for 57600 baud at 1.8mhz
	;lda #$01			; divisor low = 1 for 115200 bps at 1.8mhz
    sta RHR_THR       ; (This is DLL when DLAB=1)
    
    lda #$00          ; Divisor High = 0
    sta IER           ; (This is DLM when DLAB=1)
    
    lda #$03          ; 0000 0011 -> DLAB=0, Lock baud rate
   sta LCR
    
    lda #$00          ; Disable all interrupts for now
    sta IER
    
    lda #$03          ; RTS/DTR normal (MCR Bit 3 must be 1 later for IRQ)
    sta MCR
	rts

uart_rx_char:

.uart_rx_char_loop:
    lda LSR						; Check Line Status
    and #$01      				; Data Ready?
    beq .uart_rx_char_loop	 	; Wait if not
    lda RHR_THR    				; Read the char

	rts

uart_tx_asciiz:

    ldy #0              		; Initialize index
.uart_tx_asciiz_loop:
    lda (R6),y  				; Get byte from the pointer + Y index
    beq .uart_tx_asciiz_done	; If we hit 00, we're finished
    jsr uart_tx_char       		; Call your working TX routine
    iny                 		; Next character
    bne .uart_tx_asciiz_loop    ; If Y rolls over (255 chars), stop or handle it
.uart_tx_asciiz_done:
    rts

uart_tx_char:
    pha               			; Save the character
.uart_tx_char_loop:
    lda LSR           			; Load Line Status
    and #$20          			; Check Bit 5 (THRE - Transmitter Holding Reg Empty)
    beq .uart_tx_char_loop      ; If 0, UART is still busy
    pla               			; Get character back
    sta RHR_THR       			; Send it!
    rts

	.section .bss
	.align 8

uart_rx_q:		.ds $100
uart_rx_q_head:	.ds $01
uart_rx_q_tail:	.ds $01

