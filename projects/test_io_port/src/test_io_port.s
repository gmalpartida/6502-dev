; ==============================================================================
; POSITION-INDEPENDENT RAM & STRESS TEST PAYLOAD (SINGLE-STRING HOPS)
; Size: ~1,500 Bytes (Generates >3.5KB IHEX stream)
; Target: Safe for any load address. Uses relative branches only.
; Hardware: VIA Data registers at $8000 (Port B) and $8001 (Port A)
; ==============================================================================

.section .text

start_entry:
    sei                         ; Housekeeping
    cld

    ; 1. Initialize VIA Ports for Output Visuals
    lda #$ff
    sta $8002                   ; DDRB = Outputs
    sta $8003                   ; DDRA = Outputs

    ; 2. Initialize Zero-Page RAM Scan Pointers ($2000 to $7FFF)
    lda #$00
    sta $00                     
    lda #$60
    sta $01                     

.main_test_loop:
    inc $8000                   ; Toggle LEDs to show active testing progress
    dec $8001

    lda $01                     ; Create a rolling math pattern 
    eor #$5a                    
    adc #$1f                    
    
    ldy #$00
.write_page_loop:
    sta ($00), y                
    clc
    adc #$07                    
    iny
    bne .write_page_loop        

    inc $01                     ; Move to next page of RAM
    lda $01
    cmp #$80                    
    bcc .main_test_loop         

    ; 3. Verification Phase: Reset Pointer and Validate Data
    lda #$60
    sta $01                     

.verify_loop:
    lda $01                     
    eor #$5a                    
    adc #$1f                    
    
    ldy #$00
.verify_page_loop:
    tax                         
    lda ($00), y                
    stx $02                     
    cmp $02                     
    bne .memory_error           
    
    txa                         
    clc
    adc #$07
    iny
    bne .verify_page_loop

    inc $01                     
    lda $01
    cmp #$80
    bcc .verify_loop

    ; Success Indicator: Blink LEDs rapidly, then jump to the padding segment
    lda #$55
    sta $8000
    sta $8001
    bra .end_of_padding		; Start the tight single-string relative hops

.memory_error:
    lda #$ff
    sta $8000
    sta $8001
.deadlock:
    bra .deadlock               

.mid_point:
	bra start_entry

; ==============================================================================
; DELAY WINDOW AND RESET
; ==============================================================================
.end_of_padding:
    ldy #$10
.loop_delay:
    ldx #$ff
.inner_delay:
    dex
    bne .inner_delay
    dey
    bne .loop_delay

    bra .mid_point             ; Relative hop back to top

	.section .rodata

; ==============================================================================
; DATA BLOCKS SEPARATED BY INDIVIDUAL HOPS (<75 BYTES EACH)
; ==============================================================================
pad1: .asciiz "STRESS_TEST_PADDING_A_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"
pad2: .asciiz "STRESS_TEST_PADDING_B_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"
pad3: .asciiz "STRESS_TEST_PADDING_C_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"
pad4: .asciiz "STRESS_TEST_PADDING_D_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"
pad5: .asciiz "STRESS_TEST_PADDING_E_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"
pad6: .asciiz "STRESS_TEST_PADDING_F_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"
pad7: .asciiz "STRESS_TEST_PADDING_G_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"
pad8: .asciiz "STRESS_TEST_PADDING_H_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"
pad9: .asciiz "STRESS_TEST_PADDING_I_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"
pad10: .asciiz "STRESS_TEST_PADDING_J_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"
pad11: .asciiz "STRESS_TEST_PADDING_K_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"
pad12: .asciiz "STRESS_TEST_PADDING_L_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"
pad13: .asciiz "STRESS_TEST_PADDING_M_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"
pad14: .asciiz "STRESS_TEST_PADDING_N_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"
pad15: .asciiz "STRESS_TEST_PADDING_O_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"
pad16: .asciiz "STRESS_TEST_PADDING_P_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"
pad17: .asciiz "STRESS_TEST_PADDING_Q_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"
pad18: .asciiz "STRESS_TEST_PADDING_R_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"
pad19: .asciiz "STRESS_TEST_PADDING_S_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"
pad20: .asciiz "STRESS_TEST_PADDING_T_THE_QUICK_BROWN_FOX_JUMPS_OVER_THE_LAZY_DOG!"

