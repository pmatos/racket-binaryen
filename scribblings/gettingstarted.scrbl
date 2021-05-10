#lang scribble/manual

@(require (for-label binaryen)
          racket/sandbox
          scribble/example)

@(define binaryen-eval
   (parameterize ([sandbox-output 'string]
                  [sandbox-error-output 'string]
                  [sandbox-memory-limit 50])
     (make-evaluator 'racket/base)))

@title{Getting Started}

You are interested in Racket and WebAssembly and somehow found this package? However, you have no idea where to start... well, you came to the right place!

This package is a set of (experimental) safe high level bindings for @link["https://github.com/WebAssembly/binaryen"]{binaryen}. Binaryen itself is a library written in C++ with a C API, that aims to make compiling to WebAssembly easy, fast, and effective. It is very versatile allowing you to read wasm files, do some transformation and spit it out again, or create your own WebAssembly module from scratch. @margin-note{There will be times when a binaryen function is not available yet in this package. I add more support on a regular basis but might have not done so for the functions you need. In that case, @link["https://github.com/pmatos/racket-binaryen/issues/new"]{open an issue} and I will prioritize your requirements.} 

@section{Reading WebAssembly}

Consider the following Wasm module in text format:

@codeblock|{
  (module
    (func $double (export "wasm_double")
          (param $x i32) (result i32)
      (i32.mul (i32.const 2) (local.get $x)))
    (func $collatz_iteration (export "wasm_col_iter")
          (param $x i32) (result i32)
      (i32.add (i32.const 1)
               (i32.mul (i32.const 3) (local.get $x)))))
}|

This example defines two functions that are exported from the module: @tt{double} and @tt{collatz_iteration}. The function @tt{double} is exported with the name @tt{wasm_double} and the function @tt{collatz_iteration} is exported with the name @tt{wasm_col_iter}.

To parse a module from a string, use the function @racket[module-parse].

@examples[#:eval binaryen-eval
(require binaryen
         racket/port)

(define wasm-mod
  '(module
     (func $double (export "wasm_double")
           (param $x i32) (result i32)
       (i32.mul (i32.const 2) (local.get $x)))
     (func $collatz_iteration (export "wasm_col_iter")
           (param $x i32) (result i32)
       (i32.add (i32.const 1)
                (i32.mul (i32.const 3) (local.get $x))))))

(define mod (module-parse (with-output-to-string
                             (lambda () (write wasm-mod)))))

(module-valid? mod)]

We have read the module in, and checked it's valid. We can perform a
number of queries on the module.

@examples[#:eval binaryen-eval
(module-function-count mod)
]

You can see how it is printed to standard output.

@examples[#:eval binaryen-eval
(module-print mod)
(printf "hello")
]

@section{Writing WebAssembly}

@section{Optimization}

@section{A Longer Example}
