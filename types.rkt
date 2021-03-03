#lang racket/base
;; ---------------------------------------------------------------------------------------------------

(require "private/binaryen-ffi.rkt"
         racket/contract)

(provide
 type?
 type-ref
 type-none
 type-int32
 type-int64
 type-create)

;; ---------------------------------------------------------------------------------------------------

(struct type (ref))

(define type-none (type (BinaryenTypeNone)))
(define type-int32 (type (BinaryenTypeInt32)))
(define type-int64 (type (BinaryenTypeInt64)))

(define/contract (type-create types)
  ((listof type?) . -> . type?)
  (type (BinaryenTypeCreate (map type-ref types))))

;; ---------------------------------------------------------------------------------------------------

(module+ test

  (require rackunit)

  (test-case "pass"
    (check-true #true)))

