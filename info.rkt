#lang info

(define version "0.1")

(define collection "binaryen")

(define scribblings
  '(("scribblings/binaryen.scrbl" (multi-page))))

(define deps
  (list "base"))

(define build-deps
  (list "reprovide-lang-lib"))

(define compile-omit-paths '("tests"))

(define test-omit-paths
  (list
   "info.rkt"
   "tests/"
   "private/"
   #rx"\\.scrbl$"))
