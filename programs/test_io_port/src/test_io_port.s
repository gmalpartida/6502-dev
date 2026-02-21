; --- Hardware Map ---
VIA_BASE  = $C000   ; Y6
UART_BASE = $A000   ; Y5
TICKS     = $00     ; RAM counter
VIA_PORTA = VIA_BASE + 1
VIA_DDRA = VIA_BASE + 3


; UART Register Offsets
RBR_THR   = UART_BASE + 0
DLL       = UART_BASE + 0
DLM       = UART_BASE + 1
LCR       = UART_BASE + 3
lsr       = UART_BASE + 5

.section .text
RESET:
    LDX #$FF
    TXS             ; Always init stack first!

    ; --- 1. Initialize VIA 
    LDA #$FF
    STA VIA_DDRA ; DDRA = Output
    
	lda #$aa
	sta VIA_PORTA
    ; --- 2. Initialize UART (9600 Baud @ 2.88MHz) ---
	jsr uart_init

uart_echo_loop:
	lda #'a'
	jsr uart_tx_char

	jsr uart_rx_char

	sta VIA_PORTA

	jmp uart_echo_loop

halt:
	jmp halt

uart_init:

    ; Disable Interrupts (since you are polling)
    LDA #$00
    STA $A001       ; IER

<<<<<<< HEAD
    ; Set Baud Rate (Requires DLAB=1)
    LDA #$80        ; Bit 7 = 1 (DLAB)
    STA $A003       ; LCR
    LDA #$13        ; Divisor Low (for 9600 @ 2.88MHz)
    STA $A000       ; DLL
    LDA #$00        ; Divisor High
    STA $A001       ; DLM
=======
    ;CLI              ; Enable Interrupts
    
IDLE:
    ;WAI              ; CPU sleeps until VIA fires
    jmp IDLE
>>>>>>> 931091e209a1f8644fcb14986d59cc933609819d

    ; Configure Format & CLOSE DLAB (Crucial!)
    LDA #$03        ; 8 bits, 1 stop bit, No parity, DLAB=0
    STA $A003       ; LCR - Receiver/Transmitter now accessible

    ; Assert Modem Handshakes
    ; Even if you aren't using them, the UART logic often needs these "Active"
    LDA #$03        ; Bit 0 (DTR) and Bit 1 (RTS) set to 1 (Active)
    STA $A004       ; MCR (Modem Control Register)

    RTS

; transmits one ascii character via the uart
; --> a: contains character to be sent
; <-- none
uart_tx_char:
	tax
uart_tx_char_wait:
    LDA lsr          	; Read Line Status Register
    AND #$20         	; Check THRE bit (Transmit Holding Reg Empty)
    BEQ uart_tx_char_wait	; Wait if busy
	nop				 	; slow it down a little bit
	txa
    STA RBR_THR      	; Send it!
	rts

; Usage: LDX #<msg_addr : LDY #>msg_addr : JSR print_str
uart_tx_asciz:
    stx $00         ; Use Zero Page $00/$01 as a pointer
    sty $01
    ldy #0
uart_tx_asciiz_loop:
    lda ($00), y    ; Get char
    beq done       ; Null terminator?
    jsr uart_tx_char
    iny
    bne uart_tx_asciiz_loop       ; Max 255 chars
done:
    rts

uart_rx_char:
	lda lsr
	and #$01
	beq uart_rx_char
	lda RBR_THR
	rts

uart_rx_asciiz:


uart_init:
    LDA #$80         ; Access Divisor Latches (DLAB=1)
    STA LCR
    LDA #$13         ; Divisor = 19 ($13)
    STA DLL
    LDA #$00
    STA DLM
    LDA #$03         ; 8 data bits, 1 stop, No parity (DLAB=0)
    STA LCR
	rts

print_hello_world:

	ldx #<hello_world_msg 
	ldy #>hello_world_msg
	jsr uart_tx_asciz
	rts

	.section .vectors
    .word $0000      ; NMI
    .word RESET      ; RESET
    .word $0000; IRQ at $FFFE


	.section .text

hello_world_msg: .asciiz "Hello, world!"


