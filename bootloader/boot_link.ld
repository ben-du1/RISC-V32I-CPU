ENTRY(_start)

SECTIONS
{
    .text 0x00000000 : 
    {
        *(.text*)
        *(.rodata*)
    }

    .data ALIGN(4) :
    {
        *(.data*)
        *(.sdata*)
    }

    .bss ALIGN(4) :
    {
        _bss_start = .;
        *(.bss*)
        *(.sbss*)
        *(COMMON)
        _bss_end = .;
    }

    . = ALIGN(4);
    _stack_top = 0x00000FFC;
}