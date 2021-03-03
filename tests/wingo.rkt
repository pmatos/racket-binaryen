#lang racket/base
;; ---------------------------------------------------------------------------------------------------
(require binaryen
         racket/match)

;; ---------------------------------------------------------------------------------------------------
;
; It implements the Scheme to Wasm compiler presented by Andy Wingo at FOSDEM2021
; https://github.com/wingo/compiling-to-webassembly/blob/main/compile.scm

(define (compile port)
  ; Create module where our definitions will be places
  (parameterize ([current-module (module-create)])
  
    (let lp ()
      (let ([datum (read port)])
        (unless (eof-object? datum)
          (compile-def datum)
          (lp))))

    (unless (module-valid?)
      (error "internal error: validation failed"))
  
    (println "Compiled module:")
    (module-print)

    (module-optimize!)
    (println "Optimized module:")
    (module-print)))

(define (compile-def def)
  (match def
    [`(define (,f ,args ...) ,exp)
     (compile-func f args exp)]))

(define (compile-func name args body)
  (define name-str (symbol->string name))
  (define env
    (for/list ([arg (in-list args)]
               [i (in-naturals)])
      (cons arg i)))
      
  (define compiled-body
    (compile-exp env body))
  (module-add-function name-str
                       (map (lambda (x) type-int32) args)
                       (list type-int32)
                       '()
                       compiled-body)
  (module-export-function name-str name-str))

(define (compile-exp env texp)
  (match texp
    [(? symbol? v)
     (cond
       [(assq v env)
        => (lambda (p)
             (define idx (cdr p))
             (make-localget idx type-int32))]
       [else (error "no symbol ~a in environment" v)])]
    [(? exact-integer? n)
     (make-const (make-literal-int32 n))]
    [`(zero? ,exp)
     (make-eqz-int32 (compile-exp env exp))]
    [`(if ,tst ,thn ,els)
     (make-if (compile-exp env tst)
              (compile-exp env thn)
              (compile-exp env els))]
    [`(- ,a ,b)
     (make-sub-int32 (compile-exp env a)
                     (compile-exp env b))]
    [`(* ,a ,b) 
     (make-add-int32 (compile-exp env a)
                     (compile-exp env b))]
    [`(,f ,args ...)
     (make-call (symbol->string f)
                (map (lambda (arg) (compile-exp env arg)) args)
                type-int32)]))

    
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

