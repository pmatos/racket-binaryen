#lang scribble/manual

@(require (for-label binaryen))

@title{Functions}

A @deftech{function} is the representation of a @tech{WebAssembly} function.

@defproc[(module-add-function [name string?]
                              [arg-types (listof type?)]
                              [result-types (listof type?)]
                              [var-types (listof type?)]
                              [body expression?]
                              [#:module mod module? (current-module)]) function?]{
 Adds a function to module @racket[mod]. The function's name is @racket[name] and its argument types are given by the types in the list @racket[arg-types]. It returns as many results as there are elements in @racket[result-types], and its elements describe the type of each of the result values. The list @racket[var-types] contains the types of the local variables of the body of the function. The expression @racket[body] is the expression that computes the result of the function.
}
