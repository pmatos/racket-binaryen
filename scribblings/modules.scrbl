#lang scribble/manual
;; ---------------------------------------------------------------------------------------------------

@(require (for-label binaryen))

;; ---------------------------------------------------------------------------------------------------

@title{Modules}

A @deftech{module} is the representation of a @tech{WebAssembly} module into which you add functions, etc.

@defproc[(module? [x any/c]) boolean?]{
 Checks if the value @racket[x] is a WebAssembly module.}

@defparam[current-module module module?
          #:value #false]{
 A parameter that defines the current module to use.}

@defproc[(module-create) void?]{
 Creates an empty WebAssembly module.}

@defproc[(module-valid? [mod module? (current-module)]) boolean?]{
 Validates the Wasm module @racket[mod], returning @racket[#true] if it is a valid module and @racket[#false] otherwise.}

@defproc[(module-print [mod module? (current-module)]) void?]{
 Prints the Wasm module @racket[mod] to standard output.}

@defproc[(module-optimize! [mod module? (current-module)]) void?]{
 Optimizes the Wasm module @racket[mod] in-place.}

