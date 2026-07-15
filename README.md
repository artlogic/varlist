# VARLIST

Lists defined Applesoft variables.

## Building

Build with [Merlin 32](https://brutaldeluxe.fr/products/crossdevtools/merlin/): `merlin32 [path to macros] varlist.s`

You can then use [Cadius](https://brutaldeluxe.fr/products/crossdevtools/cadius/index.html) to add to an existing ProDOS disk image: `cadius addfile dev.po /DEV/ VARLIST\#060300`

## Using

You can either `BLOAD VARLIST` and `CALL 768` or `BRUN VARLIST`. Output consists of defined variables, so if you don't have any, there's no output. It should work from within a running program without disrupting the program execution.

The output looks like this:

```
A=1.23
A%=123
A$=HELLO WORLD
A()=FN
```

In the case of A()=FN, this is a `DEF FN`. This version does not display the function variable or body. A future version may support this.

This should work on any Apple II, but it's only been tested on a IIe.

## TODO

Support for arrays, potentially some UI improvements?

* Quotes around strings
* Clear screen and pause every screen full
* Display a message if no variables are present
