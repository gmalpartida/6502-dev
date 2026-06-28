; configuration
CONFIG_10A := 1

CONFIG_DATAFLG := 1
CONFIG_NULL := 1
CONFIG_PRINT_CR := 1 ; print CR when line end reached
CONFIG_SCRTCH_ORDER := 3
CONFIG_SMALL := 1

; zero page
ZP_START1 = $20
ZP_START2 = $2D
ZP_START3 = $7B
ZP_START4 = $85

;extra ZP variables
USR             := $002A

; constants
STACK_TOP		:= $FC
SPACE_FOR_GOSUB := $33
NULL_MAX		:= $0A
WIDTH			:= 72
WIDTH2			:= 56

; memory layout
RAMSTART2		:= $0500

; magic memory locations
L0200           := $0200

; monitor functions
MONRDKEY        := $FF03
MONCOUT         := $FF06
MONISCNTC       := $FFF1
LOAD            := $FFF4
SAVE            := $FFF7


.segment "CODE"     ; Directs the compiler to put these bytes into your BASRAM space
ISCNTC:
    clc             ; Clear carry flag (No Control+C pressed)
    rts             ; Return to interpreter

