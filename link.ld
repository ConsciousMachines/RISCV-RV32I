ENTRY(_start)

SECTIONS
{
  . = 0x4;
  .text : { *(.text*) }
  .data : { *(.data*) }
  .bss  : { *(.bss*) }

  . = 0x2000;
  _stack_top = .;
}