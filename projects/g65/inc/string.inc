
	.include "stddefs.inc"

	.global memcpy, memset, memcmp
	
; compares two null-terminated strings.
; preserves the pointers
; -->	R7:R6		pointer of first string
; -->	R5:R4		pointer of second string
; <--	C			set if matched, otherwise clear
	.global strcmp
