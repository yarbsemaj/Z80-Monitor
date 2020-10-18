# Z80-Monitor
A simple BIOS, Monitor and integrated iHEX loader for an RC2014 Compatible Z80 based SBC

### How to use
`R nn` Dumps out `0xFF` bites of memory starting at address `0xnn00`.
`W nnnn xx` Write byte `xx` to address `0xnnnn`.
`E nnnn` Runs a program starting at address `0xnnnn`.

#### Start Basic
Basic is in memory at address `0x0100`, typing E 0100 in the monitor will start it.

#### Load iHEX
iHEX files can be loaded directly from the monitor terminal.

### Compile
`zmac monitor.asm`

### Try it out
https://z80.yarbsemaj.com
