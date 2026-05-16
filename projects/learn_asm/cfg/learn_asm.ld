MEMORY
{
    RAM : org = 0x0000, len = 0x0800
    IO  : org = 0x8000, len = 0x0400
    ROM : org = 0xE000, len = 0x1ffa
	VECT: org = 0xfffa, len = 0x0006
}

SECTIONS
{
    /* Ensure no spaces between section name and colon */
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

    /* Pin vectors to the end of ROM ($FFFA) */
    .vectors: {
        *(.vectors)
    } > ROM AT > VECT 
}

