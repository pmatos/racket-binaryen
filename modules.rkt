#lang racket/base
;; ---------------------------------------------------------------------------------------------------

(require "private/binaryen-ffi.rkt"
         "private/modules.rkt"
         racket/contract)

(provide
 module?
 module-ref
 module-create
 module-valid?
 module-print
 module-optimize!
 module-read
 (contract-out
  [module-parse (string? . -> . module?)]
  [current-module (parameter/c (or/c #false module?))])
 module-write)

;; ---------------------------------------------------------------------------------------------------

(define/contract (module-create)
  (-> module?)
  (make-module (BinaryenModuleCreate)))

(define/contract (module-valid? [mod (current-module)])
  (() (module?) . ->* . boolean?)
  (BinaryenModuleValidate (module-ref mod)))

(define/contract (module-print [mod (current-module)])
  (() (module?) . ->* . void?)
  ;; This should be using BinaryenModulePrint, but it doesn't because there's no
  ;; straightforward way in racket to redirect the stdout to current-output-port.
  ;; See: https://groups.google.com/g/racket-users/c/c3RaYvSD4nE
  ;; We use BinaryenModuleAllocateAndWriteText
  ;; This is not the same as BinaryenModulePrint because this function uses
  ;; syntax highlighting that's lost when you use BinaryenModuleAllocateAndWriteText
  ;; FIXME In the future, it might be useful to revisit this issue.
  (fprintf (current-output-port) "~a"
           (bytes->string/utf-8 (module-write mod #true))))
     
(define/contract (module-optimize! [mod (current-module)])
  (() (module?) . ->* . void?)
  (BinaryenModuleOptimize (module-ref mod)))

(define/contract (module-read in)
  (bytes? . -> . module?)
  (make-module (BinaryenModuleRead in)))

(define/contract (module-write mod textual? #:sourcemap [sm #false])
  ((module? boolean?) (#:sourcemap (or/c string? #false)) . ->* . bytes?)
  (if textual?
      (string->bytes/utf-8 (BinaryenModuleAllocateAndWriteText (module-ref mod)))
      (BinaryenModuleAllocateAndWriteResult-binary (BinaryenModuleAllocateAndWrite (module-ref mod) sm))))
  
;; ---------------------------------------------------------------------------------------------------

(module+ test

  (require rackunit
           "test-utils.rkt"
           racket/port)

  (test-case "Module creation"
    (void
     (for/list ([i (in-range 1000)])
       (module-create))))

  (test-case "Module Parsing"
    (with-test-mod
      '(module
           (func (export "this_is_zero") (result i32)
                 (i32.const 0)))
      
      (check-true (module-valid?))))

  (test-case "Module Printing"
    (with-test-mod
      '(module
           (func (export "this_is_zero") (result i32)
                 (i32.const 0)))

      (check-true (> (string-length (with-output-to-string
                                      (lambda () (module-print))))
                     0))))
  
  (test-case "pass"
    (check-true #true)))
