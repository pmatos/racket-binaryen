#lang racket/base
;; ---------------------------------------------------------------------------------------------------

(require "private/binaryen-ffi.rkt"
         "private/types.rkt"
         "modules.rkt"
         "literals.rkt"
         "types.rkt"
         "indices.rkt"
         (for-syntax racket/base racket/syntax)
         racket/contract)

(provide expression?
         expression-ref
         if-expression?
         const-expression?
         binary-expression?
         unary-expression?
         localget-expression?
         localset-expression?
         localtee-expression?
         make-call
         make-if
         make-const
         make-localget
         make-localset
         make-localtee
         make-globalget
         make-globalset)

;; ---------------------------------------------------------------------------------------------------

; Capitalize helper
; n is the size of the prefix to capitalize
(define-for-syntax (upcase sym [n 1])
  (define pat (format "^~a" (make-string n #\.)))
  (regexp-replace (regexp pat) (symbol->string sym) string-upcase))

(define-for-syntax (downcase sym)
  (string-downcase (symbol->string sym)))

;; ---------------------------------------------------------------------------------------------------

(struct expression (ref))

(struct unary-expression expression ())

(define-syntax (define-unary-op stx)
  (syntax-case stx ()
    [(_ name (sfxs ...))
     #`(define-unary-op name (sfxs ...) #:binaryen-name #,(upcase (syntax->datum #'name)))]
    [(_ name (sfxs ...) #:binaryen-name bname)
     #`(define-unary-op name (sfxs ...)
         #:binaryen-name bname
         #:suffix-upcase 1)]
    [(_ name (sfxs ...) #:suffix-upcase n)
     #`(define-unary-op name (sfxs ...)
         #:binaryen-name #,(upcase (syntax->datum #'name))
         #:suffix-upcase n)]
    [(_ name (sfxs ...) #:binaryen-name bname #:suffix-upcase n)
     #`(begin
         #,@(for/list ([sfx (in-list (syntax->list #'(sfxs ...)))])
              (with-syntax ([fnname (format-id sfx "make-~a-~a"
                                               (syntax->datum #'name)
                                               (syntax->datum sfx))]
                            [binaryenop (format-id sfx "Binaryen~a~a"
                                                   (syntax->datum #'bname)
                                                   (upcase (syntax->datum sfx)
                                                           (syntax->datum #'n)))])
                #'(begin
                    (define/contract (fnname x #:module [mod (current-module)])
                      ((expression?) (#:module module?) . ->* . unary-expression?)
                      (unary-expression
                       (BinaryenUnary (module-ref mod) (binaryenop) (expression-ref x))))
                    (provide fnname)))))]))

(define-syntax (define-unary-op/raw stx)
  (syntax-case stx ()
    [(_ name (sfxs ...))
     #`(begin
         #,@(for/list ([sfx (in-list (syntax->list #'(sfxs ...)))])
              (with-syntax ([fnname (format-id sfx "make-~a-~a"
                                               (downcase (syntax->datum #'name))
                                               (downcase (syntax->datum sfx)))]
                            [binaryenop (format-id sfx "Binaryen~a~a"
                                                   (syntax->datum #'name)
                                                   (syntax->datum sfx))])
                #'(begin
                    (define/contract (fnname x #:module [mod (current-module)])
                      ((expression?) (#:module module?) . ->* . unary-expression?)
                      (unary-expression
                       (BinaryenUnary (module-ref mod) (binaryenop) (expression-ref x))))
                    (provide fnname)))))]))
                                          

; int
(define-unary-op clz (int32 int64))
(define-unary-op ctz (int32 int64))
(define-unary-op popcnt (int32 int64))

; float
(define-unary-op neg (float32 float64))
(define-unary-op abs (float32 float64))
(define-unary-op ceil (float32 float64))
(define-unary-op floor (float32 float64))
(define-unary-op nearest (float32 float64))
(define-unary-op sqrt (float32 float64))

; relational
(define-unary-op eqz (int32 int64)
  #:binaryen-name EqZ)

; conversions
(define-unary-op extend (sint32 uint32)
  #:suffix-upcase 2)
; i64 to i32
(define-unary-op wrap (int64))

; float to int
(define-unary-op/raw Trunc (SFloat32ToInt32
                            SFloat32ToInt64
                            UFloat32ToInt32
                            UFloat32ToInt64
                            SFloat64ToInt32
                            SFloat64ToInt64
                            UFloat64ToInt32
                            UFloat64ToInt64))

; reintepret bits to int
(define-unary-op reinterpret (float32 float64))

; int to float
(define-unary-op/raw Convert (SInt32ToFloat32
                              SInt32ToFloat64
                              UInt32ToFloat32
                              UInt32ToFloat64
                              SInt64ToFloat32
                              SInt64ToFloat64
                              UInt64ToFloat32
                              UInt64ToFloat64))

; f32 to f64
(define-unary-op promote (float32))

; f64 to f32
(define-unary-op demote (float64))

; reinterpret bits to float
(define-unary-op reinterpret (int32 int64))

; Extend signed subword-sized integer. This differs from e.g. ExtendSInt32
; because the input integer is in an i64 value insetad of an i32 value.
(define-unary-op/raw Extend (S8Int32
                             S16Int32
                             S8Int64
                             S16Int64
                             S32Int64))

; Saturating float-to-int
(define-unary-op/raw TruncSat (SFloat32ToInt32
                               UFloat32ToInt32
                               SFloat64ToInt32
                               UFloat64ToInt32
                               SFloat32ToInt64
                               UFloat32ToInt64
                               SFloat64ToInt64
                               UFloat64ToInt64))

; SIMD splats
(define-unary-op/raw Splat (VecI8x16
                            VecI16x8
                            VecI32x4
                            VecI64x2
                            VecF32x4
                            VecF64x2))

;; SIMD arithmetic
(define-unary-op not (vec128))
(define-unary-op/raw AnyTrue (Vec128))
(define-unary-op/raw Abs (VecI8x16 VecI16x8 VecI32x4 VecI64x2 VecF32x4 VecF64x2))
(define-unary-op/raw Neg (VecI8x16 VecI16x8 VecI32x4 VecI64x2 VecF32x4 VecF64x2))
(define-unary-op/raw AllTrue (VecI8x16 VecI16x8 VecI32x4 VecI64x2))
(define-unary-op/raw Bitmask (VecI8x16 VecI16x8 VecI32x4 VecI64x2))
(define-unary-op/raw Popcnt (VecI8x16))
(define-unary-op/raw Sqrt (VecF32x4 VecF64x2))
(define-unary-op/raw Ceil (VecF32x4 VecF64x2))
(define-unary-op/raw Floor (VecF32x4 VecF64x2))
(define-unary-op/raw Trunc (VecF32x4 VecF64x2))
(define-unary-op/raw Nearest (VecF32x4 VecF64x2))
(define-unary-op/raw ExtAddPairwise (SVecI8x16ToI16x8
                                     UVecI8x16ToI16x8
                                     SVecI16x8ToI32x4
                                     UVecI16x8ToI32x4))
 
;; SIMD conversions

(define-unary-op/raw TruncSat (SVecF32x4ToVecI32x4 UVecF32x4ToVecI32x4))
(define-unary-op/raw Convert (SVecI32x4ToVecF32x4 UVecI32x4ToVecF32x4))
(define-unary-op/raw ExtendLow (SVecI8x16ToVecI16x8
                                UVecI8x16ToVecI16x8
                                SVecI16x8ToVecI32x4
                                UVecI16x8ToVecI32x4
                                SVecI32x4ToVecI64x2
                                UVecI32x4ToVecI64x2))
(define-unary-op/raw ExtendHigh (SVecI8x16ToVecI16x8
                                 UVecI8x16ToVecI16x8
                                 SVecI16x8ToVecI32x4
                                 UVecI16x8ToVecI32x4
                                 SVecI32x4ToVecI64x2
                                 UVecI32x4ToVecI64x2))
(define-unary-op/raw ConvertLow (SVecI32x4ToVecF64x2 UVecI32x4ToVecF64x2))
(define-unary-op/raw TruncSatZero (SVecF64x2ToVecI32x4 UVecF64x2ToVecI32x4))
(define-unary-op/raw DemoteZero (VecF64x2ToVecF32x4))
(define-unary-op/raw PromoteLow (VecF32x4ToVecF64x2))

;; ---------------------------------------------------------------------------------------------------

(define-syntax (define-binary-op/raw stx)
  (syntax-case stx ()
    [(_ name (sfxs ...))
     #`(begin
         #,@(for/list ([sfx (in-list (syntax->list #'(sfxs ...)))])
              (with-syntax ([fnname (format-id sfx "make-~a-~a"
                                               (downcase (syntax->datum #'name))
                                               (downcase (syntax->datum sfx)))]
                            [binaryenop (format-id sfx "Binaryen~a~a"
                                                   (syntax->datum #'name)
                                                   (syntax->datum sfx))])
                #'(begin
                    (define/contract (fnname x y #:module [mod (current-module)])
                      ((expression? expression?) (#:module module?) . ->* . binary-expression?)
                      (binary-expression
                       (BinaryenBinary (module-ref mod) (binaryenop) (expression-ref x) (expression-ref y))))
                    (provide fnname)))))]))

(struct binary-expression expression ())

(define-binary-op/raw Add (Int32 Int64 Float32 Float64))
(define-binary-op/raw Sub (Int32 Int64 Float32 Float64))
(define-binary-op/raw Mul (Int32 Int64 Float32 Float64))

(define-binary-op/raw Div (SInt32 UInt32 SInt64 UInt64 Float32 Float64))
(define-binary-op/raw Rem (SInt32 UInt32 SInt64 UInt64))
(define-binary-op/raw And (Int32 Int64))
(define-binary-op/raw Or (Int32 Int64))
(define-binary-op/raw Xor (Int32 Int64))
(define-binary-op/raw Shl (Int32 Int64))

(define-binary-op/raw CopySign (Float32 Float64))
(define-binary-op/raw Min (Float32 Float64))
(define-binary-op/raw Max (Float32 Float64))

(define-binary-op/raw Shr (SInt32 UInt32 SInt64 UInt64))
(define-binary-op/raw RotL (Int32 Int64))
(define-binary-op/raw RotR (Int32 Int64))

(define-binary-op/raw Eq (Int32 Int64 Float32 Float64))
(define-binary-op/raw Ne (Int32 Int64 Float32 Float64))

(define-binary-op/raw Lt (SInt32 UInt32 SInt64 UInt64 Float32 Float64))
(define-binary-op/raw Le (SInt32 UInt32 SInt64 UInt64 Float32 Float64))
(define-binary-op/raw Gt (SInt32 UInt32 SInt64 UInt64 Float32 Float64))
(define-binary-op/raw Ge (SInt32 UInt32 SInt64 UInt64 Float32 Float64))

;; ---------------------------------------------------------------------------------------------------

(struct call-expression expression ())

(define/contract (make-call name operands return-type #:module [mod (current-module)])
  ((string? (listof expression?) type?) (#:module module?) . ->* . call-expression?)
  (call-expression
   (BinaryenCall (module-ref mod)
                 name
                 (map expression-ref operands)
                 (type-ref return-type))))

;; ---------------------------------------------------------------------------------------------------

(struct call-indirect-expression expression ())

(define/contract (make-call-indirect table target operands params results #:module [mod (current-module)])
  ((string? expression? (listof expression?) (listof type?) (listof type?)) (#:module module?) . ->* . call-indirect-expression?)
  (call-indirect-expression
   (BinaryenCallIndirect (module-ref mod)
                         name
                         (expression-ref target)
                         (map expression-ref operands)
                         (map type-ref params)
                         (map type-ref results))))

;; ---------------------------------------------------------------------------------------------------

(struct return-call-expression expression ())

(define/contract (make-return-call target operands return-type #:module [mod (current-module)])
  ((string? (listof expression?) type?) (#:module module?) . ->* . return-call-expression?)
  (return-call-expression
   (BinaryenReturnCall (module-ref mod)
                       name
                       (expression-ref target)
                       (map expression-ref operands)
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

(struct localset-expression expression ())

(define/contract (make-localset idx exp #:module [mod (current-module)])
  ((index? expression?) (#:module module?) . ->* . localset-expression?)
  (localtee-expression
   (BinaryenLocalSet (module-ref mod)
                     idx
                     (expression-ref exp))))

;; ---------------------------------------------------------------------------------------------------

(struct localtee-expression expression ())

(define/contract (make-localtee idx exp type #:module [mod (current-module)])
  ((index? expression? type?) (#:module module?) . ->* . localtee-expression?)
  (localtee-expression
   (BinaryenLocalTee (module-ref mod)
                     idx
                     (expression-ref exp)
                     (type-ref type))))

;; ---------------------------------------------------------------------------------------------------

(struct globalget-expression expression ())

(define/contract (make-globalget str type #:module [mod (current-module)])
  ((string? type?) (#:module module?) . ->* . globalget-expression?)
  (globalget-expression
   (BinaryenGlobalGet (module-ref mod)
                      str
                      (type-ref type))))

;; ---------------------------------------------------------------------------------------------------

(struct globalset-expression expression ())

(define/contract (make-globalset str exp #:module [mod (current-module)])
  ((string? expression?) (#:module module?) . ->* . globalset-expression?)
  (globalset-expression
   (BinaryenGlobalSet (module-ref mod)
                      str
                      (expression-ref exp))))

;; ---------------------------------------------------------------------------------------------------

(struct block-expression expression ())

(define/contract (make-block name exps type #:module [mod (current-module)])
  ((string? (listof expression?) type?) (#:module module?) . ->* . block-expression)
  (block-expression
   (BinaryenBlock (module-ref mod)
                  str
                  exps
                  type)))

(define/contract (block-name blk)
  (block-expression? . -> . string?)
  (BinaryenBlockGetName (block-expression-ref blk)))

(define/contract (set-block-name! blk name)
  (block-expression? string? . -> . void?)
  (BinaryenBlockSetName (block-expression-ref blk) name))

(define/contract (block-children-count blk)
  (block-expression? . -> . nonnegative-exact-integer?)
  (BinaryenBlockGetNumChildren (block-expression-ref blk)))

(define/contract (block-children-ref blk idx)
  (block-expression? nonnegative-exact-integer? . -> . expression?)
  (expression (BinaryenBlockGetChildAt (block-expression-ref blk) idx)))

(define/contract (block-children-append blk chd)
  (block-expression? expression? . -> . nonnegative-exact-integer?)
  (BinaryenBlockAppendChild (block-expression-ref blk) (expression-ref chd)))


;; ---------------------------------------------------------------------------------------------------

(module+ test

  (require rackunit)

  (test-case "pass"
    (check-true #true)))
