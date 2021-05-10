#lang scribble/manual

@(require (for-label binaryen))

@title{Racket binaryen bindings}
@defmodule[binaryen]

This is a wrapper for the Binaryen suite of WebAssembly tools. @deftech{WebAssembly} (or @deftech{Wasm}) is a binary instruction format for a stack-based virtual machine. More information can be found in its @link["https://webassembly.org/"]{webpage}.

@table-of-contents[]

@include-section[(lib "binaryen/scribblings/gettingstarted.scrbl")]
@include-section[(lib "binaryen/scribblings/api.scrbl")]
