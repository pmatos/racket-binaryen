#lang racket/base
;; ---------------------------------------------------------------------------------------------------

(require "binaryen-ffi.rkt"
         racket/contract)

(provide
 (struct-out type)
 type-create
 type-expand)

;; ---------------------------------------------------------------------------------------------------

(struct type (ref))

(define/contract (type-create types)
  ((listof type?) . -> . type?)
  (type (BinaryenTypeCreate (map type-ref types))))

(define/contract (type-expand ty)
  (type? . -> . (listof type?))
  (BinaryenTypeExpand (type-ref ty)))

;; ---------------------------------------------------------------------------------------------------

(module+ test

  (require rackunit)

  (test-case "pass"
    (check-true #true)))

