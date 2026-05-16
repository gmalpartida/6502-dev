MEMORY 
{
	ZP	: org = 0x0000, len = 0x0100
    RAM : org = 0x0100, len = 0x7f00
    
    /* 8KB total I/O space ($8000 - $9FFF) divided into 1KB blocks */
    VIA1: org = 0x8000, len = 0x0400  /* Renamed from VIA to maintain consistency */
    UART: org = 0x8400, len = 0x0400
    VIA2: org = 0x8800, len = 0x0400  /* This block now hosts your second VIA */
    IO3 : org = 0x8C00, len = 0x0400
    IO4 : org = 0x9000, len = 0x0400
    IO5 : org = 0x9400, len = 0x0400
    IO6 : org = 0x9800, len = 0x0400
    IO7 : org = 0x9C00, len = 0x0400
    
    ROM : org = 0xE000, len = 0x1ffa
    VECT: org = 0xfffa, len = 0x0006
}

SECTIONS 
{
    .text:    { *(.text) *(.rodata) } > ROM
    .data:    { *(.data) }             > RAM AT> ROM
    .bss(NOLOAD):     { *(.bss) }              > RAM
    .vectors: { *(.vectors) }          > VECT

    /* Assign assembly segments to their physical hardware locations */
    .via1_regs(NOLOAD): { *(via1_regs) } > VIA1
    .uart_regs(NOLOAD): { *(uart_regs) } > UART
    .via2_regs(NOLOAD): { *(via2_regs) } > VIA2 /* Added for the second chip */

	.zp(NOLOAD): { *(.zp) } > ZP
}

