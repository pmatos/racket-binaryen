#lang racket/base
;; ---------------------------------------------------------------------------------------------------

(require "private/binaryen-ffi.rkt"
         "private/features.rkt"
         "private/modules.rkt"
         racket/contract)

(provide
 feature-mvp
 feature-atomics
 feature-bulk-memory
 feature-mutable-globals
 feature-nontrapping-fptoint
 feature-sign-extension
 feature-simd128
 feature-exception-handling
 feature-tail-call
 feature-reference-types
 feature-multivalue
 feature-gc
 feature-memory64
 feature-typed-function-references
 feature-all

 module-features
 set-module-features!

 feature?
 )
 
;; ---------------------------------------------------------------------------------------------------

(define feature-mvp (feature (BinaryenFeatureMVP)))
(define feature-atomics (feature (BinaryenFeatureAtomics)))
(define feature-bulk-memory (feature (BinaryenFeatureBulkMemory)))
(define feature-mutable-globals (feature (BinaryenFeatureMutableGlobals)))
(define feature-nontrapping-fptoint (feature (BinaryenFeatureNontrappingFPToInt)))
(define feature-sign-extension (feature (BinaryenFeatureSignExt)))
(define feature-simd128 (feature (BinaryenFeatureSIMD128)))
(define feature-exception-handling (feature (BinaryenFeatureExceptionHandling)))
(define feature-tail-call (feature (BinaryenFeatureTailCall)))
(define feature-reference-types (feature (BinaryenFeatureReferenceTypes)))
(define feature-multivalue (feature (BinaryenFeatureMultivalue)))
(define feature-gc (feature (BinaryenFeatureGC)))
(define feature-memory64 (feature (BinaryenFeatureMemory64)))
(define feature-typed-function-references (feature (BinaryenFeatureTypedFunctionReferences)))

(define feature-all (list feature-mvp
                          feature-atomics
                          feature-bulk-memory
                          feature-mutate-globals
                          feature-nontrapping-fptoint
                          feature-sign-extension
                          feature-simd128
                          feature-exception-handling
                          feature-tail-call
                          feature-reference-types
                          feature-multivalue
                          feature-gc
                          feature-memory64
                          feature-typed-function-references))

(define (features-contains? features f)
  (not (= (bitwise-and (feature-ref features) (feature-ref f)) 0)))

(define (features->mask features)
  (for/fold ([mask 0])
            ([f (in-list features)])
    (bitwise-ior mask (feature-ref f))))

(define (mask->features mask)
  (filter (lambda (f) (= (feature-ref f)
                         (bitwise-and (feature-ref f) mask)))
          feature-all))

(define/contract (module-features [mod (current-module)])
  (() (module?) . ->* . (listof feature?))
  (mask->features
   (BinaryenModuleGetFeatures (module-ref mod))))

(define/contract (set-module-features! features #:module [mod (current-module)])
  (((listof feature?)) (#:module module?) . ->* . void?)
  (BinaryenModuleSetFeatures (module-ref mod) (features->mask features)))

;; ---------------------------------------------------------------------------------------------------

(module+ test

  (require rackunit)
  
  (test-case "pass"
    (check-true #true)))
