#lang scribble/manual

@(require (for-label binaryen))

@title{Racket binaryen bindings}
@defmodule[binaryen]

This is a wrapper for the Binaryen suite of WebAssembly tools. @deftech{WebAssembly} (or @deftech{Wasm}) is a binary instruction format for a stack-based virtual machine. More information can be found in its @link["https://webassembly.org/"]{webpage}.

@table-of-contents[]

@include-section[(lib "binaryen/scribblings/types.scrbl")]
@include-section[(lib "binaryen/scribblings/literals.scrbl")]
@include-section[(lib "binaryen/scribblings/modules.scrbl")]
@include-section[(lib "binaryen/scribblings/functions.scrbl")]
@include-section[(lib "binaryen/scribblings/exports.scrbl")]
@include-section[(lib "binaryen/scribblings/expressions.scrbl")]
