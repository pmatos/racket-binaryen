#lang scribble/manual

@title{Features}

Features refer to WebAssembly features that are enabled in a module and generally refer to which WebAssembly proposals have been implemented in Binaryen.

@defproc[(feature? [x any/c]) boolean?]{
 Predicate to check if value @racket[x] is a feature.}

@defthing[feature-mvp feature?]{
 This feature refers to the language implemented in the @hyperlink["https://webassembly.github.io/spec/core/"]{WebAssembly MVP}.}

@defthing[feature-atomics feature?]{
 This feature refers to the @hyperlink["https://github.com/WebAssembly/threads"]{Threads and Atomics WebAssembly} proposal.}

@defthing[feature-bulk-memory feature?]{
 This feature refers to the @hyperlink["https://github.com/WebAssembly/bulk-memory-operations"]{Bulk Memory proposal}.}

@defthing[feature-mutable-globals feature?]{
 This feature refers to the @hyperlink["https://github.com/WebAssembly/mutable-global"]{Import and Export of mutable globals proposal}.}

@defthing[feature-nontrapping-fptoint feature?]{
 This feature refers to the @hyperlink["https://github.com/WebAssembly/nontrapping-float-to-int-conversions"]{Non-trapping float-to-int conversions proposal}.}

@defthing[feature-sign-extension feature?]{
 This feature refers to the @hyperlink["https://github.com/WebAssembly/sign-extension-ops"]{Sign extension proposal}.}

@defthing[feature-simd128 feature?]{
 This feature refers to the @hyperlink["https://github.com/webassembly/simd"]{SIMD proposal}.}

@defthing[feature-exception-handling feature?]{
 This feature refers to the @hyperlink["https://github.com/WebAssembly/exception-handling"]{Exception Handling proposal}.}

@defthing[feature-tail-call feature?]{
 This feature refers to the @hyperlink["https://github.com/WebAssembly/tail-call"]{Tail calls proposal}.}

@defthing[feature-reference-types feature?]{
 This feature refers to the @hyperlink["https://github.com/WebAssembly/reference-types"]{Reference Types proposal}.}

@defthing[feature-multivalue feature?]{
 This feature refers to the @hyperlink["https://github.com/WebAssembly/multi-value"]{Multivalue proposal}.}

@defthing[feature-gc feature?]{
 This feature refers to the @hyperlink["https://github.com/WebAssembly/gc/"]{Garbage Collection proposal}.}

@defthing[feature-memory64 feature?]{
 This feature refers to the @hyperlink["https://github.com/WebAssembly/memory64"]{Memory with 64bit indexes proposal}.}

@defthing[feature-typed-function-references feature?]{
 This feature refers to the @hyperlink["https://github.com/WebAssembly/function-references"]{Typed Function References proposal}.}

@defthing[feature-all (listof feature?)]{
 List containing all supported features.}

@defproc[(module-features [mod module? (current-module)]) (listof feature?)]{
 Returns the list of WebAssembly features required by module @racket[mod].}

@defproc[(set-module-features! [features (listof feature?)] [#:module mod module? (current-module)]) void?]{
 Sets the required features by module @racket[mod] to be @racket[features].}
