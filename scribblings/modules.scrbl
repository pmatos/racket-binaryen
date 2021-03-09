#lang scribble/manual

@(require (for-label binaryen))

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

@defproc[(module-read [in bytes?]) module?]{
 Reads a module in binary format from bytes @racket[in] and returns a Wasm module.}

@defproc[(module-parse [s string?]) module?]{
 Reads a module from string @racket[s] and returns a Wasm module. }

@defproc[(module-write [mod module?] [textual? boolean?] [#:source-map sm (or/c string? #false) #false]) bytes?]{
 Writes module @racket[mod] to a byte string using source map @racket[sm], if provided. Returns the byte string. The module is read in text format if @racket[textual?] is true, and in binary format otherwise.}
