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
 Adds a function to module @racket[mod]. The function's name is @racket[name] and its argument types are given by the types in the list @racket[arg-types]. It returns as many results as there are elements in @racket[result-types], and its elements describe the type of each of the result values. The expression @racket[body] is the expression that computes the result of the function. The list @racket[var-types] contains the types of the local variables of the body of the function. It might seem strange that @racket[var-types] is required at this point but take into consideration that in WebAssembly variables share an index space with arguments. So the locals in the function are arguments whose index starts at 0, followed by the the variables whose index starts at @racket[(length arg-types)]. To setup this index space, we need to know the variable types at the point the function is created.
}
