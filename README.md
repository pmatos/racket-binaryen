[![](.github/badges/SponsoredbyIgalia.svg)](https://www.igalia.com)
[![CI](https://github.com/pmatos/racket-binaryen/workflows/Test/badge.svg?branch=main)](https://github.com/pmatos/racket-binaryen/actions)
[![Scribble](https://img.shields.io/badge/Docs-Scribble-blue.svg)](https://pmatos.github.io/racket-binaryen)

# racket-binaryen

[Binaryen](https://github.com/WebAssembly/binaryen) bindings for [Racket](https://www.racket-lang.org).

Currently, this work is experimental, there is no documentation and there are no wrappers to the bindings. The bindings are raw and unsafe.

Andy Wingo gave a ["Compiling to WebAssembly"](https://fosdem.org/2021/schedule/event/webassembly/) presentation at FOSDEM'21, and published his [artifacts](https://github.com/wingo/compiling-to-webassembly).

I implemented the same compiler in Racket using the binaryen bindings (see `tests/wingo-raw.rkt`). To run it on the same example Andy presented try:

```
$ racket test/wingo-raw.rkt test/wingo_fact.scm 
"Compiled module:"
(module
 (type $i32_=>_i32 (func (param i32) (result i32)))
 (export "fac" (func $fac))
 (func $fac (param $0 i32) (result i32)
  (if (result i32)
   (i32.eqz
    (local.get $0)
   )
   (i32.const 1)
   (i32.mul
    (local.get $0)
    (call $fac
     (i32.sub
      (local.get $0)
      (i32.const 1)
     )
    )
   )
  )
 )
)
"Optimized module:"
(module
 (type $i32_=>_i32 (func (param i32) (result i32)))
 (export "fac" (func $fac))
 (func $fac (; has Stack IR ;) (param $0 i32) (result i32)
  (if (result i32)
   (local.get $0)
   (i32.mul
    (call $fac
     (i32.sub
      (local.get $0)
      (i32.const 1)
     )
    )
    (local.get $0)
   )
   (i32.const 1)
  )
 )
)
```
