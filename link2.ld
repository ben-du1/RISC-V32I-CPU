ENTRY(_start)

SECTIONS
{
    .text 0x00000000 :
    {
        *(.text*)
    }

    .data 0x00000200 :
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

    _stack_top = 0x00000400;
}