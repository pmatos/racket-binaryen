#lang racket/base
;; ---------------------------------------------------------------------------------------------------

(require "private/modules.rkt"
         racket/port)

(provide with-test-mod)

;; ---------------------------------------------------------------------------------------------------

(define-syntax-rule (with-test-mod wasm body ...)
  (let ([mod (module-parse
              (with-output-to-string (lambda () (write wasm))))])
    (parameterize ([current-module mod])
      body ...)))
