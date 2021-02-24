#lang racket/base
;; ---------------------------------------------------------------------------------------------------
(require "../binaryen/private/binaryen-ffi.rkt"
         racket/match)

;; ---------------------------------------------------------------------------------------------------
;
; This uses the raw binaryen API which is not recommended for normal use.
; It implements the Scheme to Wasm compiler presented by Andy Wingo at FOSDEM2021
; https://github.com/wingo/compiling-to-webassembly/blob/main/compile.scm

(define (compile port)
  ; Create module where our definitions will be places
  (define mod (BinaryenModuleCreate))
  
  (let lp ()
    (let ([datum (read port)])
      (unless (eof-object? datum)
        (compile-def mod datum)
        (lp))))

  (unless (BinaryenModuleValidate mod)
    (error "internal error: validation failed"))
  
  (println "Compiled module:")
  (BinaryenModulePrint mod)

  (BinaryenModuleOptimize mod)
  (println "Optimized module:")
  (BinaryenModulePrint mod))

(define (compile-def mod def)
  (match def
    [`(define (,f ,args ...) ,exp)
     (compile-func mod f args exp)]))

(define (compile-func mod name args body)
  (define name-str (symbol->string name))
  (define env
    (for/list ([arg (in-list args)]
               [i (in-naturals)])
      (cons arg i)))
      
  (define compiled-body
    (compile-exp mod env body))
  (BinaryenAddFunction mod
                       name-str
                       (BinaryenTypeCreate (map (lambda (x) (BinaryenTypeInt32)) args))
                       (BinaryenTypeInt32)
                       '()
                       compiled-body)
  (BinaryenAddFunctionExport mod name-str name-str))

(define (compile-exp mod env texp)
  (match texp
    [(? symbol? v)
     (cond
       [(assq v env)
        => (lambda (p)
             (define idx (cdr p))
             (BinaryenLocalGet mod idx (BinaryenTypeInt32)))]
       [else (error "no symbol ~a in environment" v)])]
    [(? exact-integer? n)
     (BinaryenConst mod (BinaryenLiteralInt32 n))]
    [`(zero? ,exp)
     (BinaryenUnary mod
                    (BinaryenEqZInt32)
                    (compile-exp mod env exp))]
    [`(if ,tst ,thn ,els)
     (BinaryenIf mod
                 (compile-exp mod env tst)
                 (compile-exp mod env thn)
                 (compile-exp mod env els))]
    [`(- ,a ,b)
     (BinaryenBinary mod
                     (BinaryenSubInt32)
                     (compile-exp mod env a)
                     (compile-exp mod env b))]
    [`(* ,a ,b) 
     (BinaryenBinary mod
                     (BinaryenMulInt32)
                     (compile-exp mod env a)
                     (compile-exp mod env b))]
    [`(,f ,args ...)
     (BinaryenCall mod
                   (symbol->string f)
                   (map (lambda (arg) (compile-exp mod env arg)) args)
                   (BinaryenTypeInt32))]))

    
;; ---------------------------------------------------------------------------------------------------

(module+ main

  (require racket/cmdline)

  (define file-to-compile
    (command-line
     #:program "compiler"
     #:args (filename) ; expect one command-line argument: <filename>
     ; return the argument as a filename to compile
     (unless (file-exists? filename)
       (error "file ~a not found" filename))
     filename))

  (call-with-input-file file-to-compile compile))
  
