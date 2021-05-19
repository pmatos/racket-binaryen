#lang racket/base
;; ---------------------------------------------------------------------------------------------------

(require racket/contract
         "private/binaryen-ffi.rkt")

(provide optimize-level?
         shrink-level?
         optimize-level
         shrink-level
         set-optimize-level!
         set-shrink-level!
         with-optimize-level
         with-shrink-level)

;; ---------------------------------------------------------------------------------------------------

(define optimize-level? exact-nonnegative-integer?)
(define shrink-level? exact-nonnegative-integer?)

(define/contract (optimize-level)
  (-> exact-nonnegative-integer?)
  (BinaryenGetOptimizeLevel))

(define/contract (set-optimize-level! n)
  (exact-nonnegative-integer? . -> . void?)
  (BinaryenSetOptimizeLevel n))

(define/contract (shrink-level)
  (-> exact-nonnegative-integer?)
  (BinaryenGetShrinkLevel))

(define/contract (set-shrink-level! n)
  (exact-nonnegative-integer? . -> . void?)
  (BinaryenSetShrinkLevel n))

(define-syntax-rule (with-optimize-level n body ...)
  (let ([current-optimize-level (optimize-level)])
    (dynamic-wind
      (lambda () (void))
      (lambda ()
        (set-optimize-level! n)
        (begin body ...))
      (lambda ()
        (set-optimize-level! current-optimize-level)))))
  
(define-syntax-rule (with-shrink-level n body ...)
  (let ([current-shrink-level (shrink-level)])
    (dynamic-wind
      (lambda () (void))
      (lambda ()
        (set-shrink-level! n)
        (begin body ...))
      (lambda ()
        (set-shrink-level! current-shrink-level)))))

;; ---------------------------------------------------------------------------------------------------

(module+ test

  (require rackunit)

  (test-case "default level"
    (check = 2 (optimize-level))
    (check = 1 (shrink-level)))

  (test-case "with-optimize-level"
    (set-optimize-level! 1)
    (with-optimize-level 3
      (check = 3 (optimize-level)))
    (check = 1 (optimize-level)))
  
  (test-case "with-shrink-level"
    (set-shrink-level! 3)
    (with-shrink-level 0
      (check = 0 (shrink-level)))
    (check = 3 (shrink-level)))
    
  (test-case "pass"
    (check-true #true)))
