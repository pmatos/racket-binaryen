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

@defproc[(module-function-count [#:module mod module? (current-module)]) exact-positive-integer?]{
 Takes a module as an argument and it returns the number of functions in the module.}

@defproc[(module-function [idx exact-nonnegative-integer?] [#:module mod module? (current-module)]) function?]{
 Returns the @tech[function] in @racket[mod] indexed by @racket[idx], where @racket[idx < (module-function-count mod)].}

@defproc[(function-name [f function?]) string?]{
 Returns the name of function @racket[f].}

@defproc[(function-parameter-types [f function?]) (listof type?)]{
 Returns the list of types corresponding to the parameters of function @racket[f].}

@defproc[(function-result-types [f function?]) (listof type?)]{
 Returns the list of types corresponding to the results of function @racket[f].}

@defproc[(function-variable-count [f function?]) exact-positive-integer?]{
 Returns the number of variables in function @racket[f].}

@defproc[(function-variable-type [f function?] [n exact-positive-integer?]) type?]{
 Returns the type of the variable with index @racket[n - 1] of function @racket[f].}
