#lang racket/base
;; ---------------------------------------------------------------------------------------------------

(require "private/binaryen-ffi.rkt"
         "private/types.rkt"
         "modules.rkt"
         "literals.rkt"
         "types.rkt"
         "indices.rkt"
         racket/contract)

(provide expression?
         expression-ref
         if-expression?
         const-expression?
         binary-expression?
         unary-expression?
         localget-expression?
         make-add-int32
         make-sub-int32
         make-mul-int32
         make-eqz-int32
         make-call
         make-if
         make-const
         make-localget)

;; ---------------------------------------------------------------------------------------------------

(struct expression (ref))

(struct unary-expression expression ())

;; int

(define-syntax (define-unary-op stx)
  (syntax-case stx ()
    [(_ binaryenop name arg-types)
     #`(begin
         #,@(for/list ([arg-type (in-list arg-types)])
              (with-syntax ([fnname (format-id arg-type "make-~a-~a" (syntax->datum name) arg-type)])
                #`(define/contact (fnname x #:module [mod (current-module)])
                    ((expression?) (#:module module?) . ->* . unary-expression?)
                    (unary-expression
                     (BinaryenUnary (module-ref mod) (binaryenop) (expression-ref x)))))))]))

(define-unary-op clz '(int32 int64))
(define-unary-op ctz '(int32 int64))
(define-unary-op popcnt '(int32 int64))
(define-unary-op neg

(define/contract (make-clz-int32 x #:module [mod (current-module)])
  ((expression?) (#:module module?) . ->* . unary-expression?)
  (unary-expression
   (BinaryenUnary (module-ref mod) (BinaryenClzInt32) (expression-ref x))))

(define/contract (make-clz-int64 x #:module [mod (current-module)])
  ((expression?) (#:module module?) . ->* . unary-expression?)
  (unary-expression
   (BinaryenUnary (module-ref mod) (BinaryenClzInt64) (expression-ref x))))

(define/contract (make-ctz-int32 x #:module [mod (current-module)])
  ((expression?) (#:module module?) . ->* . unary-expression?)
  (unary-expression
   (BinaryenUnary (module-ref mod) (BinaryenCtzInt32) (expression-ref x))))

(define/contract (make-ctz-int64 x #:module [mod (current-module)])
  ((expression?) (#:module module?) . ->* . unary-expression?)
  (unary-expression
   (BinaryenUnary (module-ref mod) (BinaryenCtzInt64) (expression-ref x))))

(define/contract (make-popcnt-int32 x #:module [mod (current-module)])
  ((expression?) (#:module module?) . ->* . unary-expression?)
  (unary-expression
   (BinaryenUnary (module-ref mod) (BinaryenPopcntInt32) (expression-ref x))))

(define/contract (make-popcnt-int64 x #:module [mod (current-module)])
  ((expression?) (#:module module?) . ->* . unary-expression?)
  (unary-expression
   (BinaryenUnary (module-ref mod) (BinaryenPopcntInt64) (expression-ref x))))

;; float

;; relational

(define/contract (make-eqz-int32 x #:module [mod (current-module)])
  ((expression?) (#:module module?) . ->* . unary-expression?)
  (unary-expression
   (BinaryenUnary (module-ref mod) (BinaryenEqZInt32) (expression-ref x))))

(define/contract (make-eqz-int64 x #:module [mod (current-module)])
  ((expression?) (#:module module?) . ->* . unary-expression?)
  (unary-expression
   (BinaryenUnary (module-ref mod) (BinaryenEqZInt64) (expression-ref x))))

(struct binary-expression expression ())

(define/contract (make-add-int32 a b #:module [mod (current-module)])
  ((expression? expression?) (#:module module?) . ->* . binary-expression?)
  (binary-expression
   (BinaryenBinary (module-ref mod)
                   (BinaryenAddInt32)
                   (expression-ref a)
                   (expression-ref b))))

(define/contract (make-sub-int32 a b #:module [mod (current-module)])
  ((expression? expression?) (#:module module?) . ->* . binary-expression?)
  (binary-expression
   (BinaryenBinary (module-ref mod)
                   (BinaryenSubInt32)
                   (expression-ref a)
                   (expression-ref b))))

(define/contract (make-mul-int32 a b #:module [mod (current-module)])
  ((expression? expression?) (#:module module?) . ->* . binary-expression?)
  (binary-expression
   (BinaryenBinary (module-ref mod)
                   (BinaryenMulInt32)
                   (expression-ref a)
                   (expression-ref b))))
   
(struct call-expression expression ())

(define/contract (make-call name args return-type #:module [mod (current-module)])
  ((string? (listof expression?) type?) (#:module module?) . ->* . call-expression?)
  (call-expression
   (BinaryenCall (module-ref mod)
                 name
                 (map expression-ref args)
                 (type-ref return-type))))

;; ---------------------------------------------------------------------------------------------------

(struct if-expression expression ())

(define/contract (make-if cnd thn els #:module [mod (current-module)])
  ((expression? expression? expression?) (#:module module?) . ->* . if-expression?)
  (if-expression
   (BinaryenIf (module-ref mod)
               (expression-ref cnd)
               (expression-ref thn)
               (expression-ref els))))

;; ---------------------------------------------------------------------------------------------------

(struct const-expression expression ())

(define/contract (make-const literal #:module [mod (current-module)])
  ((literal?) (#:module module?) . ->* . const-expression?)
  (const-expression
   (BinaryenConst (module-ref mod) (literal-ref literal))))

;; ---------------------------------------------------------------------------------------------------

(struct localget-expression expression ())

(define/contract (make-localget idx type #:module [mod (current-module)])
  ((index? type?) (#:module module?) . ->* . localget-expression?)
  (localget-expression
   (BinaryenLocalGet (module-ref mod)
                     idx
                     (type-ref type))))

;; ---------------------------------------------------------------------------------------------------

(module+ test

  (require rackunit)

  (test-case "pass"
    (check-true #true)))
