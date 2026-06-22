	.include "uart_16x450.inc"

	.section .uart_regs 

UART_BASE = $8400
XON		=	$11
XOFF	=	$13

; Define the internal structure layout
;	.struct UART_REGS
;RBR		db 0
;THR     = RBR
;DLL     = RBR
;IER		db 0 
;DLM     = IER
;IIR     db 0
;LCR		db 0
;MCR		db 0
;LSR		db 0
;MSR		db 0
;SCR		db 0
;	.endstruct

RBR_THR	= UART_BASE + $00		; Receiver / Transmitter Holding
IER		= UART_BASE + $01		; Interrupt Enable
IIR		= UART_BASE + $02		; Interrupt Idenfitifer Register
LCR		= UART_BASE + $03		; Line Control (DLAB is Bit 7)
MCR		= UART_BASE + $04		; Modem Control
LSR		= UART_BASE + $05		; Line Status
MSR		= UART_BASE + $06		; Modem Status Register
SCR		= UART_BASE + $07		; Scratch Register

	.section .text
	
;============================================================================
; initializes the uart to:
;				8 bits, 1 stop bit, no parity bit, 57600 bps
;--> none
;<-- none
;Modifies:	a, 
;============================================================================
uart_init:
	lda #$00			; disable interrupts
	sta IER

    lda #$83          ; 1000 0011 -> DLAB=1, 8 bits, 1 stop, no parity
    sta LCR
    ;LDA #$01          ; Divisor Low = 1 (for 115,200 baud @ ~1.8MHz)
	;lda #$0c		; divisor low = 12 for 9600bps @ 1.8mhz
	lda #$02			; divisor low = 2 for 57600 baud at 1.8mhz
	;lda #$01			; divisor low = 1 for 115200 bps at 1.8mhz
    sta RBR_THR       ; (This is DLL when DLAB=1)
    
    lda #$00          ; Divisor High = 0
    sta IER           ; (This is DLM when DLAB=1)
    
    lda #$03          ; 0000 0011 -> DLAB=0, Lock baud rate
	sta LCR
    
	lda RBR_THR
	lda LSR

    lda #$01          ; enable receive data interrupt
    sta IER
    
    lda #$0f          ; RTS/DTR normal (MCR Bit 3 must be 1 later for IRQ)
    sta MCR
	
	lda #$00
	sta uart_rx_q_head		; buffer head
	sta uart_rx_q_tail		; buffer tail
	sta uart_xoff_sent		; init flow state to inactive

	rts

;=====================================================================
;reads a character from the uart input buffer
;--> none
;<-- a: character read
;Modifies: a, x
;=====================================================================
uart_rx_char:
	sei								; prevent interrupts from happening between the next two instructions
	lda uart_rx_q_tail
	cmp uart_rx_q_head
	cli								; re-enable interrupts
	beq uart_rx_char				; exit if no char received.

	ldx uart_rx_q_head				; process character
	lda uart_rx_q, x
	;tay							; save character in y
	pha
	inx								; increment head
	stx uart_rx_q_head

	lda uart_xoff_sent				; check if XOFF has been sent
	bne .flow_control
	bra .exit
.flow_control:						; deactivate flow control
	sei
	lda uart_rx_q_tail
	sec
	sbc uart_rx_q_head
	cli
	cmp #64							; check if flow control can be deactivated
	bcs .exit						; no, just exit
	lda #XON
	jsr uart_tx_char
	lda #$00						; deactivate flow control
	sta uart_xoff_sent

.exit:
	pla
	rts

; ---------------------------------------------------------------------
; uart_rx_asciiz
; Input:   R6/R7 (2 bytes in Zero Page) must point to the destination RAM buffer.
; Output:  Buffer filled with ASCIIZ string.
; Modifies: A, Y
; ---------------------------------------------------------------------
uart_rx_asciiz:
    ldy #$00            ; Initialize buffer index to 0

rx_line_loop:
    jsr uart_rx_char    ; Get character from UART (returns in A)
    
    ; Check for line endings
    cmp #CR
    beq rx_line_done
    cmp #LF
    beq rx_line_done
    
    ; Check for Backspace or Delete
    cmp #BS
    beq handle_backspace
    cmp #DEL
    beq handle_backspace
    
    ; --- Optional Buffer Overflow Guard ---
    ; cpy #$FF          ; Check if buffer is full (max 255 bytes for Y index)
    ; beq rx_line_loop  ; If full, ignore character and wait for CR/LF

    ; Store the character in RAM via indirect indexing
    sta (R6), y
    
    ; Echo the character back to the user
    jsr uart_tx_char    
    
    iny                 ; Move to next buffer position
    bne rx_line_loop    ; Loop back (prevents Y roll-over wrap)
    beq rx_line_done    ; Force finish if index reaches 256

handle_backspace:
    cpy #$00            ; Is the buffer empty?
    beq rx_line_loop    ; Yes, nothing to erase. Ignore backspace.
    
    dey                 ; Decrement index to remove last character
    
    ; Erase character from user's screen (Backspace, Space, Backspace)
    lda #BS
    jsr uart_tx_char
    lda #' '
    jsr uart_tx_char
    lda #BS
    jsr uart_tx_char
    
    jmp rx_line_loop    ; Wait for next character

rx_line_done:
    ; Terminate the string with a null byte
    lda #NULL
    sta (R6), y
    
    ; Echo a clean newline sequence so monitor prompt moves down
    lda #CR
    jsr uart_tx_char
    lda #LF
    jsr uart_tx_char
    
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
    sta RBR_THR       			; Send it!
    rts

uart_rx_isr:
    pha                 ; Save CPU context
    phx

	lda IIR				; Read Interrupt Identification Register
    and #$07            ; Mask out bits 3-7
    cmp #$04            ; Is it "Received Data Available"? (Bit 2=1, 1=0, 0=0)
    bne .not_rx_data    ; If not RX data (e.g., error or modem status), skip enqueue

    lda RBR_THR         ; Read incoming byte (Clears RX interrupt)
    ldx uart_rx_q_tail  ; Get current TAIL pointer
    sta uart_rx_q,x     ; Enqueue the byte
    inx                 ; Advance tail pointer (auto-wraps at 256)
    stx uart_rx_q_tail  ; Save updated pointer

	lda uart_xoff_sent	; exit if XOFF has already been sent
	bne .exit			; yes, so exit
	txa
	sec
	sbc uart_rx_q_head	; calculate buffer fill
	cmp #192			; about 75% full
	bcc .exit			; no, so exit
	lda #XOFF
	jsr uart_tx_char	; send XOFF
	lda #$01
	sta uart_xoff_sent	; keep track that XOFF was sent

    jmp .exit

.not_rx_data:

    ; If it was a line status error interrupt, we must read LSR to clear it.
    ; If you don't care about the error, just reading RBR or LSR clears it.
	cmp #$06			; is it Line Status Error?
	bne .exit
	lda LSR				; clear error
    ;lda RBR_THR        ; Flush RBR to clear stuck interrupt state

.exit:
    plx                 ; Restore CPU context
    pla     
    rti                 ; Return from interrupt

	.section .bss

uart_rx_q:			.ds $100
uart_rx_q_head:		.ds 1		
uart_rx_q_tail:		.ds 1	
uart_xoff_sent:		.ds	1

