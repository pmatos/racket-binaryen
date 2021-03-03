#lang typed/racket/base
;; ---------------------------------------------------------------------------------------------------

(provide fits-int? fits-uint?)

;; ---------------------------------------------------------------------------------------------------

(: fits-int? (-> Integer Integer Boolean))
(define (fits-int? n bits)
  (<= (expt 2 (- bits 1))
      n
      (- (expt 2 (- bits 1)) 1)))

(: fits-uint? (-> Integer Integer Boolean))
(define (fits-uint? n bits)
  (<= 0
      n
      (- (expt 2 bits) 1)))
