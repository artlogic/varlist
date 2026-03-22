# VARLIST

Lists defined Applesoft variables.

## Building

Build with [Merlin 32](https://brutaldeluxe.fr/products/crossdevtools/merlin/): `merlin32 varlist.s`

You can then use [Cadius](https://github.com/mach-kernel/cadius) to add to an existing ProDOS disk image: `cadius addfile dev.po /DEV/ VARLIST\#060300`

Make sure you are using the latest versions of both Merlin32 and Cadius.

## Using

You can either `BLOAD VARLIST` and `CALL 768` or `BRUN VARLIST`. Output consists of defined variables, so if you don't have any, there's no output.

This does include some 65C02 specific instructions and so will only work in systems with that CPU.

## TODO

Support for arrays, potentially some UI improvements?

* Quotes around strings
* Clear screen and pause every screen full
* Display a message if no variables are present
