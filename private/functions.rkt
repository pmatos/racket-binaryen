#lang racket/base
;; ---------------------------------------------------------------------------------------------------

(require "binaryen-ffi.rkt")

(provide
 function
 function-ref
 function?)

;; ---------------------------------------------------------------------------------------------------

(struct function (ref))

;; ---------------------------------------------------------------------------------------------------

(module+ test

  (require rackunit
           racket/port)
  
  (test-case "pass"
    (check-true #true)))
