MEMORY
{
    RAM : org = 0x0000, len = 0x0800
    IO  : org = 0x8000, len = 0x2000
	VIA : org = 0xC000, len = 0x2000
    /* Code area: E000 to FFF9 (8186 bytes) */
    ROM : org = 0xE000, len = 0x1FFA
    /* Vector area: FFFA to FFFF (6 bytes) */
    VECT: org = 0xFFFA, len = 0x0006
}

SECTIONS
{
    .text: {
        *(.text)
        *(.rodata)
    } > ROM

    .data: {
        *(.data)
    } > RAM AT > ROM

    .bss: {
        *(.bss)
    } > RAM

    .vectors: {
        *(.vectors)
    } > VECT
}

