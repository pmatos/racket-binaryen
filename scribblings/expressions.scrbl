#lang scribble/manual

@title{Expressions}

An @deftech{expression} is a way to transform @tech{Wasm} values through computation.

@defproc[(expression? [x any/c]) boolean?]{
 Checks if the value @racket[x] is an expression.}

@section{Unary expressions}

A @deftech{unary expression} is an @tech{expression} that operates on one value.
Constructors for unary operations will take the form @tt{make-<name>-<type>},
where @tt{<name>} is the operation name, and @tt{<type>} is the type of the value
expected by the operation. Value types are not checked at the compile time, therefore
it is possible to create invalid WebAssembly modules. Use @racket[module-valid?] to
validate your modules.

@section{Binary Expressions}

A @deftech{binary expression} is an @tech{expression} that operates on two values.

@defproc[(binary-expression? [x any/c]) boolean?]{
 Checks if the value @racket[x] is a binary expression.}

@defproc[(make-add-int32 [a expression?] [b expression?] [#:module mod module? (current-module)]) binary-expression?]{
 Creates a @tech{binary expression} that represents the addition of @racket[a] to @racket[b], both of which must have type @racket[type-int32].}

@defproc[(make-sub-int32 [a expression?] [b expression?] [#:module mod module? (current-module)]) binary-expression?]{
 Creates a @tech{binary expression} that represents the subtraction of @racket[b] from @racket[a], both of which must have type @racket[type-int32].}

@defproc[(make-mult-int32 [a expression?] [b expression?] [#:module mod module? (current-module)]) binary-expression?]{
 Creates a @tech{binary expression} that represents the multiplication between @racket[a] and @racket[b], both of which must have type @racket[type-int32].}


