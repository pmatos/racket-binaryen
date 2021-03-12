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

@defthing[type-float32 type?]{
 The type @tt{Float32}.}

@defthing[type-float64 type?]{
 The type @tt{Float64}.}

@defthing[type-vec128 type?]{
 The type @tt{Vec128}.}

@defthing[type-funcref type?]{
 The type @tt{Funcref}.}

@defthing[type-externref type?]{
 The type @tt{Externref}.}

@defthing[type-anyref type?]{
 The type @tt{Anyref}.}

@defthing[type-eqref type?]{
 The type @tt{Eqref}.}

@defthing[type-i31ref type?]{
 The type @tt{I31ref}.}

@defthing[type-dataref type?]{
 The type @tt{Dataref}.}

@defthing[type-unreachable type?]{
 The type @tt{Unreachable}.}

@defthing[type-auto type?]{
 The type @tt{Auto}.}

