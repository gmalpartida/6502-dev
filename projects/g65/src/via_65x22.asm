
	.include "via_65x22.inc"

VIA1_BASE	= $8000
VIA1_DDRB	= VIA1_BASE + 2
VIA1_DRB	= VIA1_BASE + 0
VIA1_DRA	= VIA1_BASE + 1
VIA1_DDRA	= VIA1_BASE + 3

via6522_porta_config:

    sta VIA1_DDRA
	rts

via6522_portb_config:

	sta VIA1_DDRB

	rts
