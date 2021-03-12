#lang racket/base
;; ---------------------------------------------------------------------------------------------------

(require "private/binaryen-ffi.rkt"
         "private/types.rkt"
         racket/contract)

(provide
 type-none
 type-int32
 type-int64
 type-float32
 type-float64
 type-vec128
 type-funcref
 type-externref
 type-anyref
 type-eqref
 type-i31ref
 type-dataref
 type-unreachable
 type-auto)

;; ---------------------------------------------------------------------------------------------------

(define type-none (type (BinaryenTypeNone)))
(define type-int32 (type (BinaryenTypeInt32)))
(define type-int64 (type (BinaryenTypeInt64)))
(define type-float32 (type (BinaryenTypeFloat32)))
(define type-float64 (type (BinaryenTypeFloat64)))
(define type-vec128 (type (BinaryenTypeVec128)))
(define type-funcref (type (BinaryenTypeFuncref)))
(define type-externref (type (BinaryenTypeExternref)))
(define type-anyref (type (BinaryenTypeAnyref)))
(define type-eqref (type (BinaryenTypeEqref)))
(define type-i31ref (type (BinaryenTypeI31ref)))
(define type-dataref (type (BinaryenTypeDataref)))
(define type-unreachable (type (BinaryenTypeUnreachable)))
(define type-auto (type (BinaryenTypeAuto)))

;; ---------------------------------------------------------------------------------------------------

(module+ test

  (require rackunit)

  (test-case "pass"
    (check-true #true)))

