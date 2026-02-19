; --- Hardware Map ---
VIA_BASE  = $C000   ; Y6
UART_BASE = $A000   ; Y5
TICKS     = $00     ; RAM counter

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

    ; --- 1. Initialize VIA (Walking Bit) ---
    LDA #$FF
    STA VIA_BASE + 3 ; DDRA = Output
    LDA #$01
    STA VIA_BASE + 1 ; Initial LED (Port A)
    
    LDA #20          ; Soft-divider for 5Hz
    STA TICKS

    ; --- 2. Initialize UART (9600 Baud @ 2.88MHz) ---
    LDA #$80         ; Access Divisor Latches (DLAB=1)
    STA LCR
    LDA #$13         ; Divisor = 19 ($13)
    STA DLL
    LDA #$00
    STA DLM
    LDA #$03         ; 8 data bits, 1 stop, No parity (DLAB=0)
    STA LCR

    ; --- 3. Test Transmission (Send "!" to PC) ---
    ; Calling test_tx here confirms the 5.76MHz bus can write to UART
	;LDX #<hello_world_msg 
	;LDY #>hello_world_msg
	;JSR uart_tx_asciz
uart_echo_loop:
	jsr uart_rx_char
	nop
	nop
	nop
	nop
	nop
	jsr uart_tx_char 
	jmp uart_echo_loop

    ; --- 4. Configure VIA Timer 1 (Interrupts) ---
    ; 5.76MHz / 100Hz = 57,600 ($E100)
    LDA #$00
    STA VIA_BASE + 4 ; T1C-L
    LDA #$E1
    STA VIA_BASE + 5 ; T1C-H (Starts Timer)
    
    LDA #%01000000   ; Continuous interrupts
    STA VIA_BASE + $B ; ACR
    LDA #%11000000   ; Enable T1 IRQ
    STA VIA_BASE + $E ; IER

    ;CLI              ; Enable Interrupts
    
IDLE:
    WAI              ; CPU sleeps until VIA fires
    BRA IDLE

; --- Interrupt Service Routine ---
ISR:
    PHA
    BIT VIA_BASE + 4 ; Clear VIA flag
    
    DEC TICKS
    BNE EXIT
    
    LDA #20          ; Reset divider
    STA TICKS
    
    ; Walk bit on Port A
    LDA VIA_BASE + 1
    ASL
    BNE store
    LDA #$01
store:
    STA VIA_BASE + 1

EXIT:
    PLA
    RTI

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
	nop
	nop
	nop
	nop
	nop
	lda RBR_THR
	rts

uart_rx_asciiz:


	rts

	.section .vectors
    .word $0000      ; NMI
    .word RESET      ; RESET
    .word ISR        ; IRQ at $FFFE

	.section .text

hello_world_msg: .asciiz "Hello, world!"


