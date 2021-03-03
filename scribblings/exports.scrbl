#lang scribble/manual
;; ---------------------------------------------------------------------------------------------------

@title{Exports}

An @deftech{export} represent a value that is exported from a WebAssembly @tech{module}.

@defproc[(export? [x any/c]) boolean?]{
 Checks if the value @racket[x] is a WebAssembly @tech{export}.}

@defproc[(module-export-function [in string?] [out string?] [#:module mod module? (current-module)]) export?]{
 Exports the function with internal name @racket[in] in module @racket[mod] as @racket[out], returning a reference to the export.}
