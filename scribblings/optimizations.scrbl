#lang scribble/manual

@title{Optimizations}

Binaryen can optimize your webassembly program and many functions depends on the global optimization levels set. This API section describes which levels can be tuned and which facilities are provided to change the levels.

@defproc[(optimize-level? [x any/c]) boolean?]{
 Checks if the value @racket[x] is a valid optimize level.}

@defproc[(shrink-level? [x any/c]) boolean?]{
 Checks if the value @racket[x] is a valid shrink level.}

@defproc[(optimize-level) exact-nonnegative-integer?]{
 Returns the current global optimize level.}

@defproc[(shrink-level) exact-nonnegative-integer?]{
 Returns the current global shrink level.}

@defproc[(set-optimize-level! [n exact-nonnegative-integer?]) void?]{
 Sets the current optimize level to @racket[n]. Any positive value is positive but it only makes a different until @racket[4], inclusive. So @racket[0] stands for the usual @tt{-O0}, @racket[1] for @tt{-O1}, etc, until @racket[4] standing for @tt{-O4}.}

@defproc[(set-shrink-level! [n exact-nonnegative-integer?]) void?]{
 Sets the current shrink level to @racket[n]. Any positive value is positive but it only makes a different until @racket[2], inclusive. So @racket[0] stands for the usual @tt{-O0}, @racket[1] for @tt{-Os}, and @racket[2] for @tt{-Oz}.}

@defform[(with-optimize-level n body ...)]{
 Evaluates the @racket[body ...] forms in sequence with the optimize level set to @racket[n]. After the evaluation of all the forms or if the control jumps out of this form, the optimize level is reset to its old value.}

@defform[(with-shrink-level n body ...)]{
 Evaluates the @racket[body ...] forms in sequence with the shrink level set to @racket[n]. After the evaluation of all the forms or if the control jumps out of this form, the shrink level is reset to its old value.}


