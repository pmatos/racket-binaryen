#lang racket/base
;; ---------------------------------------------------------------------------------------------------

(require racket/contract
         "common.rkt")

(provide index?)

;; ---------------------------------------------------------------------------------------------------

(define/contract (index? v)
  (any/c . -> . boolean?)
  (and (exact-integer? v) (fits-uint? v 32)))
