#lang scribble/manual

@title{Types}

Types refer to WebAssembly types such as @tt{int32}, @tt{int64}, etc. There are basic types and ways to aggregate a type from these basic types.

@defproc[(type? [x any/c]) boolean?]{
 Predicate to check if value @racket[x] is a WebAssembly type.}

@defthing[type-none type?]{
 The type @tt{None}.}

@defthing[type-int32 type?]{
 The type @tt{Int32}.}

@defthing[type-int64 type?]{
 The type @tt{Int64}.}
