#lang racket/base
;; ---------------------------------------------------------------------------------------------------

(require "binaryen-ffi.rkt")

(provide
 (struct-out module)
 current-module
 module-parse)


;; ---------------------------------------------------------------------------------------------------

; Module is just an opaque type representing a module
(struct module (ref)
  #:constructor-name make-module)

(define current-module (make-parameter #false))

(define (module-parse s)
  (make-module (BinaryenModuleParse s)))
