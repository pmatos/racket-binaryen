#lang racket/base
;; ---------------------------------------------------------------------------------------------------

(require ffi/unsafe
         ffi/unsafe/define
         ffi/unsafe/alloc
         setup/dirs
         (for-syntax racket/base
                     racket/syntax
                     racket/list))

;; ---------------------------------------------------------------------------------------------------

; !DO NOT REMOVE OR EDIT THE FOLLOWING LINES!
; Based on binaryen-c.h with sha:
;==;3339a88dc93d294bed730832c6c956f88c082a33

;; WARNING: Does not include deprecated bindings!

(define (get-lib-search-dirs/local)
  (cons (string->path "/home/pmatos/dev/binaryen/lib")
        (get-lib-search-dirs)))

(define libbinaryen (ffi-lib "libbinaryen"
                             #:get-lib-dirs get-lib-search-dirs/local))


(define-ffi-definer define-binaryen libbinaryen)

(define-syntax defbinaryen
  (syntax-rules (:)
    [(_ name : type ...)
     (define name
       (get-ffi-obj 'name libbinaryen (_fun type ...)))]))

(define-syntax defbinaryen* 
  (syntax-rules (:)
    [(_ name : type ...)
     (begin
       (provide name)
       (defbinaryen name : type ...))]))


; Module creation

(define BinaryenIndex _uint32)
(define BinaryenType _uintptr)

(defbinaryen* BinaryenTypeNone        : -> BinaryenType)
(defbinaryen* BinaryenTypeInt32       : -> BinaryenType)
(defbinaryen* BinaryenTypeInt64       : -> BinaryenType)
(defbinaryen* BinaryenTypeFloat32     : -> BinaryenType)
(defbinaryen* BinaryenTypeFloat64     : -> BinaryenType)
(defbinaryen* BinaryenTypeVec128      : -> BinaryenType)
(defbinaryen* BinaryenTypeFuncref     : -> BinaryenType)
(defbinaryen* BinaryenTypeExternref   : -> BinaryenType)
(defbinaryen* BinaryenTypeAnyref      : -> BinaryenType)
(defbinaryen* BinaryenTypeEqref       : -> BinaryenType)
(defbinaryen* BinaryenTypeI31ref      : -> BinaryenType)
(defbinaryen* BinaryenTypeDataref     : -> BinaryenType)
(defbinaryen* BinaryenTypeUnreachable : -> BinaryenType)
                      
(defbinaryen* BinaryenTypeAuto   : -> BinaryenType)
(defbinaryen* BinaryenTypeCreate :
  [vec : (_list i BinaryenType)] [_int = (length vec)]
  -> BinaryenType)
(defbinaryen* BinaryenTypeArity : BinaryenType -> _uint32)
(defbinaryen* BinaryenTypeExpand :
  [t : BinaryenType] [vec : (_list o BinaryenType (BinaryenTypeArity t))]
  -> _void
  -> vec)

(define BinaryenExpressionId _uint32)

(defbinaryen BinaryenInvalidId : -> BinaryenExpressionId)

(define BinaryenExternalKind _uint32)

(defbinaryen* BinaryenExternalFunction : -> BinaryenExternalKind)
(defbinaryen* BinaryenExternalTable    : -> BinaryenExternalKind)
(defbinaryen* BinaryenExternalMemory   : -> BinaryenExternalKind)
(defbinaryen* BinaryenExternalGlobal   : -> BinaryenExternalKind)
(defbinaryen* BinaryenExternalEvent    : -> BinaryenExternalKind)

(define BinaryenFeatures _uint32)

(defbinaryen* BinaryenFeatureMVP                : -> BinaryenFeatures)
(defbinaryen* BinaryenFeatureAtomics            : -> BinaryenFeatures)
(defbinaryen* BinaryenFeatureBulkMemory         : -> BinaryenFeatures)
(defbinaryen* BinaryenFeatureMutableGlobals     : -> BinaryenFeatures)
(defbinaryen* BinaryenFeatureNontrappingFPToInt : -> BinaryenFeatures)
(defbinaryen* BinaryenFeatureSignExt            : -> BinaryenFeatures)
(defbinaryen* BinaryenFeatureSIMD128            : -> BinaryenFeatures)
(defbinaryen* BinaryenFeatureExceptionHandling  : -> BinaryenFeatures)
(defbinaryen* BinaryenFeatureTailCall           : -> BinaryenFeatures)
(defbinaryen* BinaryenFeatureReferenceTypes     : -> BinaryenFeatures)
(defbinaryen* BinaryenFeatureMultivalue         : -> BinaryenFeatures)
(defbinaryen* BinaryenFeatureGC                 : -> BinaryenFeatures)
(defbinaryen* BinaryenFeatureMemory64           : -> BinaryenFeatures)
(defbinaryen* BinaryenFeatureAll                : -> BinaryenFeatures)

(define BinaryenModuleRef (_cpointer 'BinaryenModuleRef))

; using definer explicitly to allow wrappers
(provide BinaryenModuleDispose)
(define-binaryen BinaryenModuleDispose
  (_fun BinaryenModuleRef -> _void)
  #:wrap (deallocator))

(provide BinaryenModuleCreate)
(define-binaryen BinaryenModuleCreate
  (_fun -> BinaryenModuleRef)
  #:wrap (allocator BinaryenModuleDispose))

; Literals

(define _litunion
  (make-union-type
   _int32
   _int64
   _float
   _double
   (_array _uint8 16)
   _string))

(define-cstruct _BinaryenLiteral
  ([type _uintptr]
   [lit-rest _litunion]))

(defbinaryen* BinaryenLiteralInt32 : _int32 -> _BinaryenLiteral)
(defbinaryen* BinaryenLiteralInt64 : _int64 -> _BinaryenLiteral)
(defbinaryen* BinaryenLiteralFloat32 : _float -> _BinaryenLiteral)
(defbinaryen* BinaryenLiteralFloat64 : _double -> _BinaryenLiteral)
(defbinaryen* BinaryenLiteralVec128 : (_array _uint8 16) -> _BinaryenLiteral)
(defbinaryen* BinaryenLiteralFloat32Bits : _int32 -> _BinaryenLiteral)
(defbinaryen* BinaryenLiteralFloat64Bits : _int64 -> _BinaryenLiteral)

; Expressions

(define BinaryenOp _int32)

(define-syntax (define-binaryops stx)
  (syntax-case stx ()
      [(_ name ...)
       #`(begin
           #,@(for/list ([n (in-list (syntax->list #'(name ...)))])
                (with-syntax ([fullname (format-id n "Binaryen~a" (syntax->datum n))])
                  #'(defbinaryen* fullname : -> BinaryenOp))))]))

(define-binaryops
  ClzInt32
  CtzInt32
  PopcntInt32
  NegFloat32
  AbsFloat32
  CeilFloat32
  FloorFloat32
  TruncFloat32
  NearestFloat32
  SqrtFloat32
  EqZInt32
  ClzInt64
  CtzInt64
  PopcntInt64
  NegFloat64
  AbsFloat64
  CeilFloat64
  FloorFloat64
  TruncFloat64
  NearestFloat64
  SqrtFloat64
  EqZInt64
  ExtendSInt32
  ExtendUInt32
  WrapInt64
  TruncSFloat32ToInt32
  TruncSFloat32ToInt64
  TruncUFloat32ToInt32
  TruncUFloat32ToInt64
  TruncSFloat64ToInt32
  TruncSFloat64ToInt64
  TruncUFloat64ToInt32
  TruncUFloat64ToInt64
  ReinterpretFloat32
  ReinterpretFloat64
  ConvertSInt32ToFloat32
  ConvertSInt32ToFloat64
  ConvertUInt32ToFloat32
  ConvertUInt32ToFloat64
  ConvertSInt64ToFloat32
  ConvertSInt64ToFloat64
  ConvertUInt64ToFloat32
  ConvertUInt64ToFloat64
  PromoteFloat32
  DemoteFloat64
  ReinterpretInt32
  ReinterpretInt64
  ExtendS8Int32
  ExtendS16Int32
  ExtendS8Int64
  ExtendS16Int64
  ExtendS32Int64
  AddInt32
  SubInt32
  MulInt32
  DivSInt32
  DivUInt32
  RemSInt32
  RemUInt32
  AndInt32
  OrInt32
  XorInt32
  ShlInt32
  ShrUInt32
  ShrSInt32
  RotLInt32
  RotRInt32
  EqInt32
  NeInt32
  LtSInt32
  LtUInt32
  LeSInt32
  LeUInt32
  GtSInt32
  GtUInt32
  GeSInt32
  GeUInt32
  AddInt64
  SubInt64
  MulInt64
  DivSInt64
  DivUInt64
  RemSInt64
  RemUInt64
  AndInt64
  OrInt64
  XorInt64
  ShlInt64
  ShrUInt64
  ShrSInt64
  RotLInt64
  RotRInt64
  EqInt64
  NeInt64
  LtSInt64
  LtUInt64
  LeSInt64
  LeUInt64
  GtSInt64
  GtUInt64
  GeSInt64
  GeUInt64
  AddFloat32
  SubFloat32
  MulFloat32
  DivFloat32
  CopySignFloat32
  MinFloat32
  MaxFloat32
  EqFloat32
  NeFloat32
  LtFloat32
  LeFloat32
  GtFloat32
  GeFloat32
  AddFloat64
  SubFloat64
  MulFloat64
  DivFloat64
  CopySignFloat64
  MinFloat64
  MaxFloat64
  EqFloat64
  NeFloat64
  LtFloat64
  LeFloat64
  GtFloat64
  GeFloat64
  AtomicRMWAdd
  AtomicRMWSub
  AtomicRMWAnd
  AtomicRMWOr
  AtomicRMWXor
  AtomicRMWXchg
  TruncSatSFloat32ToInt32
  TruncSatSFloat32ToInt64
  TruncSatUFloat32ToInt32
  TruncSatUFloat32ToInt64
  TruncSatSFloat64ToInt32
  TruncSatSFloat64ToInt64
  TruncSatUFloat64ToInt32
  TruncSatUFloat64ToInt64
  SplatVecI8x16
  ExtractLaneSVecI8x16
  ExtractLaneUVecI8x16
  ReplaceLaneVecI8x16
  SplatVecI16x8
  ExtractLaneSVecI16x8
  ExtractLaneUVecI16x8
  ReplaceLaneVecI16x8
  SplatVecI32x4
  ExtractLaneVecI32x4
  ReplaceLaneVecI32x4
  SplatVecI64x2
  ExtractLaneVecI64x2
  ReplaceLaneVecI64x2
  SplatVecF32x4
  ExtractLaneVecF32x4
  ReplaceLaneVecF32x4
  SplatVecF64x2
  ExtractLaneVecF64x2
  ReplaceLaneVecF64x2
  EqVecI8x16
  NeVecI8x16
  LtSVecI8x16
  LtUVecI8x16
  GtSVecI8x16
  GtUVecI8x16
  LeSVecI8x16
  LeUVecI8x16
  GeSVecI8x16
  GeUVecI8x16
  EqVecI16x8
  NeVecI16x8
  LtSVecI16x8
  LtUVecI16x8
  GtSVecI16x8
  GtUVecI16x8
  LeSVecI16x8
  LeUVecI16x8
  GeSVecI16x8
  GeUVecI16x8
  EqVecI32x4
  NeVecI32x4
  LtSVecI32x4
  LtUVecI32x4
  GtSVecI32x4
  GtUVecI32x4
  LeSVecI32x4
  LeUVecI32x4
  GeSVecI32x4
  GeUVecI32x4
  EqVecF32x4
  NeVecF32x4
  LtVecF32x4
  GtVecF32x4
  LeVecF32x4
  GeVecF32x4
  EqVecF64x2
  NeVecF64x2
  LtVecF64x2
  GtVecF64x2
  LeVecF64x2
  GeVecF64x2
  NotVec128
  AndVec128
  OrVec128
  XorVec128
  AndNotVec128
  BitselectVec128
  AbsVecI8x16
  NegVecI8x16
  AnyTrueVecI8x16
  AllTrueVecI8x16
  BitmaskVecI8x16
  ShlVecI8x16
  ShrSVecI8x16
  ShrUVecI8x16
  AddVecI8x16
  AddSatSVecI8x16
  AddSatUVecI8x16
  SubVecI8x16
  SubSatSVecI8x16
  SubSatUVecI8x16
  MulVecI8x16
  MinSVecI8x16
  MinUVecI8x16
  MaxSVecI8x16
  MaxUVecI8x16
  AvgrUVecI8x16
  AbsVecI16x8
  NegVecI16x8
  AnyTrueVecI16x8
  AllTrueVecI16x8
  BitmaskVecI16x8
  ShlVecI16x8
  ShrSVecI16x8
  ShrUVecI16x8
  AddVecI16x8
  AddSatSVecI16x8
  AddSatUVecI16x8
  SubVecI16x8
  SubSatSVecI16x8
  SubSatUVecI16x8
  MulVecI16x8
  MinSVecI16x8
  MinUVecI16x8
  MaxSVecI16x8
  MaxUVecI16x8
  AvgrUVecI16x8
  AbsVecI32x4
  NegVecI32x4
  AnyTrueVecI32x4
  AllTrueVecI32x4
  BitmaskVecI32x4
  ShlVecI32x4
  ShrSVecI32x4
  ShrUVecI32x4
  AddVecI32x4
  SubVecI32x4
  MulVecI32x4
  MinSVecI32x4
  MinUVecI32x4
  MaxSVecI32x4
  MaxUVecI32x4
  DotSVecI16x8ToVecI32x4
  NegVecI64x2
  ShlVecI64x2
  ShrSVecI64x2
  ShrUVecI64x2
  AddVecI64x2
  SubVecI64x2
  MulVecI64x2
  AbsVecF32x4
  NegVecF32x4
  SqrtVecF32x4
  QFMAVecF32x4
  QFMSVecF32x4
  AddVecF32x4
  SubVecF32x4
  MulVecF32x4
  DivVecF32x4
  MinVecF32x4
  MaxVecF32x4
  PMinVecF32x4
  PMaxVecF32x4
  CeilVecF32x4
  FloorVecF32x4
  TruncVecF32x4
  NearestVecF32x4
  AbsVecF64x2
  NegVecF64x2
  SqrtVecF64x2
  QFMAVecF64x2
  QFMSVecF64x2
  AddVecF64x2
  SubVecF64x2
  MulVecF64x2
  DivVecF64x2
  MinVecF64x2
  MaxVecF64x2
  PMinVecF64x2
  PMaxVecF64x2
  CeilVecF64x2
  FloorVecF64x2
  TruncVecF64x2
  NearestVecF64x2
  TruncSatSVecF32x4ToVecI32x4
  TruncSatUVecF32x4ToVecI32x4
  TruncSatSVecF64x2ToVecI64x2
  TruncSatUVecF64x2ToVecI64x2
  ConvertSVecI32x4ToVecF32x4
  ConvertUVecI32x4ToVecF32x4
  ConvertSVecI64x2ToVecF64x2
  ConvertUVecI64x2ToVecF64x2
  LoadSplatVec8x16
  LoadSplatVec16x8
  LoadSplatVec32x4
  LoadSplatVec64x2
  LoadExtSVec8x8ToVecI16x8
  LoadExtUVec8x8ToVecI16x8
  LoadExtSVec16x4ToVecI32x4
  LoadExtUVec16x4ToVecI32x4
  LoadExtSVec32x2ToVecI64x2
  LoadExtUVec32x2ToVecI64x2
  NarrowSVecI16x8ToVecI8x16
  NarrowUVecI16x8ToVecI8x16
  NarrowSVecI32x4ToVecI16x8
  NarrowUVecI32x4ToVecI16x8
  WidenLowSVecI8x16ToVecI16x8
  WidenHighSVecI8x16ToVecI16x8
  WidenLowUVecI8x16ToVecI16x8
  WidenHighUVecI8x16ToVecI16x8
  WidenLowSVecI16x8ToVecI32x4
  WidenHighSVecI16x8ToVecI32x4
  WidenLowUVecI16x8ToVecI32x4
  WidenHighUVecI16x8ToVecI32x4
  SwizzleVec8x16
  RefIsNull
  RefIsFunc
  RefIsData
  RefIsI31)

;;
;; Many of the operations have a well-defined name and define a setter and getter for it.
;; This macros hopefully make it easier to create the ffi bindings.
;;
(define-syntax (defbinaryen*-get stx)
  (syntax-case stx (:)
    [(_ struct field [ extra-args ... ] field-type)
     (with-syntax ([getter (format-id #'field "Binaryen~aGet~a"
                                      (syntax->datum #'struct) (syntax->datum #'field))])
       #'(defbinaryen* getter : BinaryenExpressionRef extra-args ... -> field-type))]
    [(_ struct field field-type)
     #'(defbinaryen*-get struct field [] field-type)]))
    
(define-syntax (defbinaryen*-get/set stx)
  (syntax-case stx (:)
    [(_ struct field [ extra-args ... ] field-type)
     (with-syntax ([getter (format-id #'field "Binaryen~aGet~a"
                                      (syntax->datum #'struct) (syntax->datum #'field))]
                   [setter (format-id #'field "Binaryen~aSet~a"
                                      (syntax->datum #'struct) (syntax->datum #'field))])
       #'(begin
           (defbinaryen* getter : BinaryenExpressionRef extra-args ... -> field-type)
           (defbinaryen* setter : BinaryenExpressionRef extra-args ... field-type -> _void)))]
    [(_ struct field field-type)
     #'(defbinaryen*-get/set struct field [] field-type)]))
         
(define-syntax (defbinaryen*-get/set-fields stx)
  (syntax-case stx ()
    [(_ struct fields/types ...)
     #`(begin
         #,@(for/list ([ft (in-list (syntax->list #'(fields/types ...)))])
              (cond
                [(= (length (syntax->datum ft)) 2)
                 #`(defbinaryen*-get/set struct
                     #,(first (syntax->datum ft))
                     #,(second (syntax->datum ft)))]
                [(= (length (syntax->datum ft)) 3)
                 #`(defbinaryen*-get/set struct
                     #,(first (syntax->datum ft))
                     #,(second (syntax->datum ft))
                     #,(third (syntax->datum ft)))]
                [else
                 (raise-syntax-error "unknown number of fields in fields/types list")])))]))
         

(define BinaryenExpressionRef (_cpointer/null 'BinaryenExpressionRef))

(defbinaryen* BinaryenBlock :
  BinaryenModuleRef _string [children : (_list i BinaryenExpressionRef)] [BinaryenIndex = (length children)] BinaryenType
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenIf :
  BinaryenModuleRef BinaryenExpressionRef BinaryenExpressionRef BinaryenExpressionRef
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenLoop :
  BinaryenModuleRef _string BinaryenExpressionRef
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenBreak :
  BinaryenModuleRef _string BinaryenExpressionRef BinaryenExpressionRef
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenSwitch :
  BinaryenModuleRef [names : (_list i _string)] [BinaryenIndex = (length names)] _string BinaryenExpressionRef BinaryenExpressionRef
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenCall :
  BinaryenModuleRef _string [operands : (_list i BinaryenExpressionRef)] [BinaryenIndex = (length operands)] BinaryenType
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenCallIndirect :
  BinaryenModuleRef _string BinaryenExpressionRef [operands : (_list i BinaryenExpressionRef)] [BinaryenIndex = (length operands)] BinaryenType BinaryenType
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenReturnCall :
  BinaryenModuleRef _string [operands : (_list i BinaryenExpressionRef)] [BinaryenIndex = (length operands)] BinaryenType
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenReturnCallIndirect :
  BinaryenModuleRef _string BinaryenExpressionRef [operands : (_list i BinaryenExpressionRef)] [BinaryenIndex = (length operands)] BinaryenType BinaryenType
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenLocalGet :
  BinaryenModuleRef BinaryenIndex BinaryenType
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenLocalSet :
  BinaryenModuleRef BinaryenIndex BinaryenExpressionRef
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenLocalTee :
  BinaryenModuleRef BinaryenIndex BinaryenExpressionRef BinaryenType
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenGlobalGet :
  BinaryenModuleRef _string BinaryenType
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenGlobalSet :
  BinaryenModuleRef _string BinaryenExpressionRef
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenLoad :
  BinaryenModuleRef _int32 _int8 _int32 _int32 BinaryenType BinaryenExpressionRef
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenStore :
  BinaryenModuleRef _int32 _int32 _int32 BinaryenExpressionRef BinaryenExpressionRef BinaryenType
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenConst :
  BinaryenModuleRef _BinaryenLiteral
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenUnary :
  BinaryenModuleRef BinaryenOp BinaryenExpressionRef
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenBinary :
  BinaryenModuleRef BinaryenOp BinaryenExpressionRef BinaryenExpressionRef
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenSelect :
  BinaryenModuleRef BinaryenExpressionRef BinaryenExpressionRef BinaryenExpressionRef BinaryenType
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenDrop :
  BinaryenModuleRef BinaryenExpressionRef
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenReturn :
  BinaryenModuleRef BinaryenExpressionRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenMemorySize : BinaryenModuleRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenMemoryGrow : BinaryenModuleRef BinaryenExpressionRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenNop : BinaryenModuleRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenUnreachable : BinaryenModuleRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenAtomicLoad :
  BinaryenModuleRef _uint32 _uint32 BinaryenType BinaryenExpressionRef
  -> BinaryenExpressionRef)
  
(defbinaryen* BinaryenAtomicStore :
  BinaryenModuleRef _uint32 _uint32 BinaryenExpressionRef BinaryenExpressionRef BinaryenType
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenAtomicRMW :
  BinaryenModuleRef BinaryenOp BinaryenIndex BinaryenIndex BinaryenExpressionRef BinaryenExpressionRef BinaryenType
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenAtomicCmpxchg :
  BinaryenModuleRef BinaryenIndex BinaryenIndex BinaryenExpressionRef BinaryenExpressionRef BinaryenExpressionRef BinaryenType
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenAtomicWait :
  BinaryenModuleRef BinaryenExpressionRef BinaryenExpressionRef BinaryenExpressionRef BinaryenType
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenAtomicNotify :
  BinaryenModuleRef BinaryenExpressionRef BinaryenExpressionRef
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenAtomicFence : BinaryenModuleRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenSIMDExtract : BinaryenModuleRef BinaryenOp BinaryenExpressionRef _uint8 -> BinaryenExpressionRef)

(defbinaryen* BinaryenSIMDReplace : BinaryenModuleRef BinaryenOp BinaryenExpressionRef _uint8 BinaryenExpressionRef
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenSIMDShuffle :
  BinaryenModuleRef BinaryenExpressionRef BinaryenExpressionRef (_array _uint8 16)
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenSIMDShift :
  BinaryenModuleRef BinaryenOp BinaryenExpressionRef BinaryenExpressionRef
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenSIMDLoad :
  BinaryenModuleRef BinaryenOp _uint32 _uint32 BinaryenExpressionRef
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenMemoryInit :
  BinaryenModuleRef _uint32 BinaryenExpressionRef BinaryenExpressionRef BinaryenExpressionRef
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenDataDrop :
  BinaryenModuleRef _uint32
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenMemoryCopy :
  BinaryenModuleRef BinaryenExpressionRef BinaryenExpressionRef BinaryenExpressionRef
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenMemoryFill :
  BinaryenModuleRef BinaryenExpressionRef BinaryenExpressionRef BinaryenExpressionRef
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenRefNull :
  BinaryenModuleRef BinaryenType
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenRefIs :
  BinaryenModuleRef BinaryenOp BinaryenExpressionRef
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenRefFunc :
  BinaryenModuleRef _string BinaryenType
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenRefEq :
  BinaryenModuleRef BinaryenExpressionRef BinaryenExpressionRef
  -> BinaryenExpressionRef)

; TODO
; Try: name can be NULL. delegateTarget should be NULL in try-catch.
(defbinaryen* BinaryenTry :
  BinaryenModuleRef
  [name : _string]
  BinaryenExpressionRef
  [catchEvents : (_list i _string)] [BinaryenIndex = (length catchEvents)]
  [catchBodies : (_list i BinaryenExpressionRef)] [BinaryenIndex = (length catchBodies)]
  [delegateTarget : _string]
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenThrow :
  BinaryenModuleRef _string [operands : (_list i BinaryenExpressionRef)] [BinaryenIndex = (length operands)]
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenRethrow :
  BinaryenModuleRef _string -> BinaryenExpressionRef)

(defbinaryen* BinaryenTupleMake :
  BinaryenModuleRef [operands : (_list i BinaryenExpressionRef)] [BinaryenIndex = (length operands)]
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenTupleExtract :
  BinaryenModuleRef BinaryenExpressionRef BinaryenIndex
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenPop :
  BinaryenModuleRef BinaryenType
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenI31New :
  BinaryenModuleRef BinaryenExpressionRef
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenI31Get :
  BinaryenModuleRef BinaryenExpressionRef _int
  -> BinaryenExpressionRef)

(defbinaryen* BinaryenExpressionGetId :
  BinaryenExpressionRef -> BinaryenExpressionId)

(defbinaryen* BinaryenExpressionGetType :
  BinaryenExpressionRef -> BinaryenType)

(defbinaryen* BinaryenExpressionSetType :
  BinaryenExpressionRef BinaryenType -> _void)

(defbinaryen* BinaryenExpressionPrint : BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenExpressionFinalize : BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenExpressionCopy : BinaryenExpressionRef BinaryenModuleRef
  -> BinaryenExpressionRef)


;; BinaryenBlock

(defbinaryen*-get/set-fields Block
  (Name _string)
  (ChildAt [BinaryenIndex] BinaryenExpressionRef))

(defbinaryen* BinaryenBlockGetNumChildren : BinaryenExpressionRef -> BinaryenIndex)

(defbinaryen* BinaryenBlockAppendChild : BinaryenExpressionRef BinaryenExpressionRef -> BinaryenIndex)

(defbinaryen* BinaryenBlockInsertChildAt : BinaryenExpressionRef BinaryenIndex BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenBlockRemoveChildAt : BinaryenExpressionRef BinaryenIndex -> BinaryenExpressionRef)


; If 
(defbinaryen* BinaryenIfGetCondition : BinaryenExpressionRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenIfSetCondition : BinaryenExpressionRef BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenIfGetIfTrue : BinaryenExpressionRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenIfSetIfTrue : BinaryenExpressionRef BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenIfGetIfFalse : BinaryenExpressionRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenIfSetIfFalse : BinaryenExpressionRef BinaryenExpressionRef -> _void)

; Loop
(defbinaryen* BinaryenLoopGetName : BinaryenExpressionRef -> _string)

(defbinaryen* BinaryenLoopSetName : BinaryenExpressionRef _string -> _void)

(defbinaryen* BinaryenLoopGetBody : BinaryenExpressionRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenLoopSetBody : BinaryenExpressionRef BinaryenExpressionRef -> _void)

; Break
(defbinaryen* BinaryenBreakGetName : BinaryenExpressionRef -> _string)

(defbinaryen* BinaryenBreakSetName : BinaryenExpressionRef _string -> _void)

(defbinaryen* BinaryenBreakGetCondition : BinaryenExpressionRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenBreakSetCondition : BinaryenExpressionRef BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenBreakGetValue : BinaryenExpressionRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenBreakSetValue : BinaryenExpressionRef BinaryenExpressionRef -> _void)

; Switch

(defbinaryen* BinaryenSwitchGetNumNames : BinaryenExpressionRef -> BinaryenIndex)

(defbinaryen* BinaryenSwitchGetNameAt :
  BinaryenExpressionRef BinaryenIndex -> _string)

(defbinaryen* BinaryenSwitchSetNameAt :
  BinaryenExpressionRef BinaryenIndex _string -> _void)

(defbinaryen* BinaryenSwitchAppendName :
  BinaryenExpressionRef _string -> BinaryenIndex)

(defbinaryen* BinaryenSwitchInsertNameAt :
  BinaryenExpressionRef BinaryenIndex _string -> _void)

(defbinaryen* BinaryenSwitchRemoveNameAt :
  BinaryenExpressionRef BinaryenIndex -> _void)

(defbinaryen* BinaryenSwitchGetDefaultName :
  BinaryenExpressionRef -> _string)

(defbinaryen* BinaryenSwitchSetDefaultName :
  BinaryenExpressionRef _string -> _void)

(defbinaryen* BinaryenSwitchGetCondition :
  BinaryenExpressionRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenSwitchSetCondition :
  BinaryenExpressionRef BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenSwitchGetValue :
  BinaryenExpressionRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenSwitchSetValue : BinaryenExpressionRef BinaryenExpressionRef -> _void)


; Call

(defbinaryen* BinaryenCallGetTarget : BinaryenExpressionRef -> _string)

(defbinaryen* BinaryenCallSetTarget : BinaryenExpressionRef _string -> _void)

(defbinaryen* BinaryenCallGetNumOperands : BinaryenExpressionRef -> BinaryenIndex)

(defbinaryen* BinaryenCallGetOperandAt : BinaryenExpressionRef BinaryenIndex -> BinaryenExpressionRef)

(defbinaryen* BinaryenCallSetOperandAt : BinaryenExpressionRef BinaryenIndex BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenCallAppendOperand : BinaryenExpressionRef BinaryenExpressionRef -> BinaryenIndex)
  
(defbinaryen* BinaryenCallInsertOperandAt : BinaryenExpressionRef BinaryenIndex BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenCallRemoveOperandAt : BinaryenExpressionRef BinaryenIndex -> BinaryenExpressionRef)

(defbinaryen* BinaryenCallIsReturn : BinaryenExpressionRef -> _bool)

(defbinaryen* BinaryenCallSetReturn : BinaryenExpressionRef _bool -> _void)

; Call indirect

(defbinaryen* BinaryenCallIndirectGetTarget : BinaryenExpressionRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenCallIndirectSetTarget : BinaryenExpressionRef BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenCallIndirectGetTable : BinaryenExpressionRef -> _string)

(defbinaryen* BinaryenCallIndirectSetTable : BinaryenExpressionRef _string -> _void)

(defbinaryen* BinaryenCallIndirectGetNumOperands : BinaryenExpressionRef -> BinaryenIndex)

(defbinaryen* BinaryenCallIndirectGetOperandAt : BinaryenExpressionRef BinaryenIndex -> BinaryenExpressionRef)

(defbinaryen* BinaryenCallIndirectSetOperandAt : BinaryenExpressionRef BinaryenIndex BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenCallIndirectAppendOperand : BinaryenExpressionRef BinaryenExpressionRef -> BinaryenIndex)

(defbinaryen* BinaryenCallIndirectInsertOperandAt : BinaryenExpressionRef BinaryenIndex BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenCallIndirectRemoveOperandAt : BinaryenExpressionRef BinaryenIndex -> BinaryenExpressionRef)

(defbinaryen* BinaryenCallIndirectIsReturn : BinaryenExpressionRef -> _bool)

(defbinaryen* BinaryenCallIndirectSetReturn : BinaryenExpressionRef _bool -> _void)

(defbinaryen* BinaryenCallIndirectGetParams : BinaryenExpressionRef -> BinaryenType)

(defbinaryen* BinaryenCallIndirectSetParams : BinaryenExpressionRef BinaryenType -> _void)

(defbinaryen* BinaryenCallIndirectGetResults : BinaryenExpressionRef -> BinaryenType)

(defbinaryen* BinaryenCallIndirectSetResults : BinaryenExpressionRef BinaryenType -> _void)

; LocalGet

(defbinaryen* BinaryenLocalGetGetIndex : BinaryenExpressionRef -> BinaryenIndex)

(defbinaryen* BinaryenLocalGetSetIndex : BinaryenExpressionRef BinaryenIndex -> _void)

; LocalSet

(defbinaryen* BinaryenLocalSetIsTee : BinaryenExpressionRef -> _bool)

(defbinaryen* BinaryenLocalSetGetIndex : BinaryenExpressionRef -> BinaryenIndex)

(defbinaryen* BinaryenLocalSetSetIndex : BinaryenExpressionRef BinaryenIndex -> _void)

(defbinaryen* BinaryenLocalSetGetValue : BinaryenExpressionRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenLocalSetSetValue : BinaryenExpressionRef BinaryenExpressionRef -> _void)

; GlobalGet

(defbinaryen* BinaryenGlobalGetGetName : BinaryenExpressionRef -> _string)

(defbinaryen* BinaryenGlobalGetSetName : BinaryenExpressionRef _string -> _void)

; GlobalSet

(defbinaryen* BinaryenGlobalSetGetName : BinaryenExpressionRef -> _string)

(defbinaryen* BinaryenGlobalSetSetName : BinaryenExpressionRef _string -> _void)

(defbinaryen* BinaryenGlobalSetGetValue : BinaryenExpressionRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenGlobalSetSetValue : BinaryenExpressionRef BinaryenExpressionRef -> _void)

; MemoryGrow

(defbinaryen* BinaryenMemoryGrowGetDelta : BinaryenExpressionRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenMemoryGrowSetDelta : BinaryenExpressionRef BinaryenExpressionRef -> _void)

; Load

(defbinaryen* BinaryenLoadIsAtomic : BinaryenExpressionRef -> _bool)

(defbinaryen* BinaryenLoadSetAtomic : BinaryenExpressionRef _bool -> _void)

(defbinaryen* BinaryenLoadIsSigned : BinaryenExpressionRef -> _bool)

(defbinaryen* BinaryenLoadSetSigned : BinaryenExpressionRef _bool -> _void)

(defbinaryen* BinaryenLoadGetOffset : BinaryenExpressionRef -> _uint32)

(defbinaryen* BinaryenLoadSetOffset : BinaryenExpressionRef _uint32 -> _void)

(defbinaryen* BinaryenLoadGetBytes : BinaryenExpressionRef -> _uint32)

(defbinaryen* BinaryenLoadSetBytes : BinaryenExpressionRef _uint32 -> _void)

(defbinaryen* BinaryenLoadGetAlign : BinaryenExpressionRef -> _uint32)

(defbinaryen* BinaryenLoadSetAlign : BinaryenExpressionRef _uint32 -> _void)

(defbinaryen* BinaryenLoadGetPtr : BinaryenExpressionRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenLoadSetPtr : BinaryenExpressionRef BinaryenExpressionRef -> _void)

; Store

(defbinaryen* BinaryenStoreIsAtomic : BinaryenExpressionRef -> _bool)

(defbinaryen* BinaryenStoreSetAtomic : BinaryenExpressionRef _bool -> _void)

(defbinaryen* BinaryenStoreGetBytes : BinaryenExpressionRef -> _uint32)

(defbinaryen* BinaryenStoreSetBytes : BinaryenExpressionRef _uint32 -> _void)

(defbinaryen* BinaryenStoreGetOffset : BinaryenExpressionRef -> _uint32)

(defbinaryen* BinaryenStoreSetOffset : BinaryenExpressionRef _uint32 -> _void)

(defbinaryen* BinaryenStoreGetAlign : BinaryenExpressionRef -> _uint32)

(defbinaryen* BinaryenStoreSetAlign : BinaryenExpressionRef _uint32 -> _void)

(defbinaryen* BinaryenStoreGetPtr : BinaryenExpressionRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenStoreSetPtr : BinaryenExpressionRef BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenStoreGetValue : BinaryenExpressionRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenStoreSetValue : BinaryenExpressionRef BinaryenExpressionRef -> _void)

; Const

(defbinaryen* BinaryenConstGetValueI32 : BinaryenExpressionRef -> _int32)
(defbinaryen* BinaryenConstSetValueI32 : BinaryenExpressionRef _int32 -> _void)

(defbinaryen* BinaryenConstGetValueI64 : BinaryenExpressionRef -> _int64)
(defbinaryen* BinaryenConstSetValueI64 : BinaryenExpressionRef _int64 -> _void)

(defbinaryen* BinaryenConstGetValueI64Low : BinaryenExpressionRef -> _int32)
(defbinaryen* BinaryenConstSetValueI64Low : BinaryenExpressionRef _int32 -> _void)

(defbinaryen* BinaryenConstGetValueI64High : BinaryenExpressionRef -> _int32)
(defbinaryen* BinaryenConstSetValueI64High : BinaryenExpressionRef _int32 -> _void)

(defbinaryen* BinaryenConstGetValueF32 : BinaryenExpressionRef -> _float)
(defbinaryen* BinaryenConstSetValueF32 : BinaryenExpressionRef _float -> _void)

(defbinaryen* BinaryenConstGetValueF64 : BinaryenExpressionRef -> _double)
(defbinaryen* BinaryenConstSetValueF64 : BinaryenExpressionRef _double -> _void)

(defbinaryen* BinaryenConstGetValueV128 : BinaryenExpressionRef -> (_array _uint8 16))
(defbinaryen* BinaryenConstSetValueV128 : BinaryenExpressionRef (_array _uint8 16) -> _void)

; Unary

(defbinaryen* BinaryenUnaryGetOp : BinaryenExpressionRef -> BinaryenOp)
(defbinaryen* BinaryenUnarySetOp : BinaryenExpressionRef BinaryenOp -> _void)

(defbinaryen* BinaryenUnaryGetValue : BinaryenExpressionRef -> BinaryenExpressionRef)
(defbinaryen* BinaryenUnarySetValue : BinaryenExpressionRef BinaryenExpressionRef -> _void)

; Binary

(defbinaryen* BinaryenBinaryGetOp : BinaryenExpressionRef -> BinaryenOp)
(defbinaryen* BinaryenBinarySetOp : BinaryenExpressionRef BinaryenOp -> _void)

(defbinaryen* BinaryenBinaryGetLeft : BinaryenExpressionRef -> BinaryenExpressionRef)
(defbinaryen* BinaryenBinarySetLeft : BinaryenExpressionRef BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenBinaryGetRight : BinaryenExpressionRef -> BinaryenExpressionRef)
(defbinaryen* BinaryenBinarySetRight : BinaryenExpressionRef BinaryenExpressionRef -> _void)

; Select

(defbinaryen* BinaryenSelectGetIfTrue : BinaryenExpressionRef -> BinaryenExpressionRef)
(defbinaryen* BinaryenSelectSetIfTrue : BinaryenExpressionRef BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenSelectGetIfFalse : BinaryenExpressionRef -> BinaryenExpressionRef)
(defbinaryen* BinaryenSelectSetIfFalse : BinaryenExpressionRef BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenSelectGetCondition : BinaryenExpressionRef -> BinaryenExpressionRef)
(defbinaryen* BinaryenSelectSetCondition : BinaryenExpressionRef BinaryenExpressionRef -> _void)

; Drop

(defbinaryen* BinaryenDropGetValue : BinaryenExpressionRef -> BinaryenExpressionRef)
(defbinaryen* BinaryenDropSetValue : BinaryenExpressionRef BinaryenExpressionRef -> _void)

; Return

(defbinaryen* BinaryenReturnGetValue : BinaryenExpressionRef -> BinaryenExpressionRef)
(defbinaryen* BinaryenReturnSetValue : BinaryenExpressionRef BinaryenExpressionRef -> _void)

; AtomicRMW

(defbinaryen*-get/set-fields AtomicRMW
  (Op BinaryenOp)
  (Bytes _uint32)
  (Offset _uint32)
  (Ptr BinaryenExpressionRef)
  (Value BinaryenExpressionRef))

; AtomicCmpxchg

(defbinaryen*-get/set-fields AtomicCmpxchg
  (Bytes _uint32)
  (Offset _uint32)
  (Ptr BinaryenExpressionRef)
  (Expected BinaryenExpressionRef)
  (Replacement BinaryenExpressionRef))

; AtomicWait

(defbinaryen*-get/set-fields AtomicWait
  (Ptr BinaryenExpressionRef)
  (Expected BinaryenExpressionRef)
  (Timeout BinaryenExpressionRef)
  (ExpectedType BinaryenType))

; AtomicNotify

(defbinaryen*-get/set-fields AtomicNotify
  (Ptr BinaryenExpressionRef)
  (NotifyCount BinaryenExpressionRef))

; AtomicFence

(defbinaryen*-get/set AtomicFence Order _uint8)

; SIMDExtract

(defbinaryen*-get/set-fields SIMDExtract
  (Op BinaryenExpressionRef)
  (Vec BinaryenExpressionRef)
  (Index _uint8))

; SIMDReplace

(defbinaryen*-get/set-fields SIMDReplace
  (Op BinaryenExpressionRef)
  (Vec BinaryenExpressionRef)
  (Index _uint8)
  (Value BinaryenExpressionRef))

; SIMDShuffle

(defbinaryen*-get/set-fields SIMDShuffle
  (Left BinaryenExpressionRef)
  (Right BinaryenExpressionRef))

(defbinaryen* BinaryenSIMDShuffleGetMask :
  BinaryenExpressionRef (_list o _uint8 16) -> _void)
(defbinaryen* BinaryenSIMDShuffleSetMask :
  BinaryenExpressionRef -> (_array _uint8 16))

; SIMDTernary

(defbinaryen*-get/set-fields SIMDTernary
  (Op BinaryenExpressionRef)
  (A BinaryenExpressionRef)
  (B BinaryenExpressionRef)
  (C BinaryenExpressionRef))

; SIMDShift

(defbinaryen*-get/set-fields SIMDShift
  (Op BinaryenExpressionRef)
  (Vec BinaryenExpressionRef)
  (Shift BinaryenExpressionRef))

; SIMDLoad

(defbinaryen*-get/set-fields SIMDLoad
  (Op BinaryenExpressionRef)
  (Offset _uint32)
  (Align _uint32)
  (Ptr BinaryenExpressionRef))

; MemoryInit

(defbinaryen*-get/set-fields MemoryInit
  (Segment _uint32)
  (Dest BinaryenExpressionRef)
  (Offset BinaryenExpressionRef)
  (Size BinaryenExpressionRef))

; DataDrop

(defbinaryen*-get/set DataDrop Segment _uint32)

; MemoryCopy

(defbinaryen*-get/set-fields MemoryCopy
  (Dest BinaryenExpressionRef)
  (Source BinaryenExpressionRef)
  (Size BinaryenExpressionRef))

; MemoryFill

(defbinaryen*-get/set-fields MemoryFill
  (Dest BinaryenExpressionRef)
  (Value BinaryenExpressionRef)
  (Size BinaryenExpressionRef))

; RefIsNull

(defbinaryen*-get/set-fields RefIs
  (Value BinaryenExpressionRef))

; RefFunc

(defbinaryen*-get/set-fields RefFunc
  (Func _string))

; RefEq

(defbinaryen*-get/set-fields RefEq
  (Left BinaryenExpressionRef)
  (Right BinaryenExpressionRef))

; Try

(defbinaryen*-get/set-fields Try
  (Name _string)
  (Body BinaryenExpressionRef)
  (DelegateTarget _string))

(defbinaryen* BinaryenTryGetNumCatchEvents : BinaryenExpressionRef ->  BinaryenIndex)
(defbinaryen* BinaryenTryGetNumCatchBodies : BinaryenExpressionRef -> BinaryenIndex)

(defbinaryen* BinaryenTryGetCatchEventAt : BinaryenExpressionRef BinaryenIndex -> _string)
(defbinaryen* BinaryenTrySetCatchEventAt : BinaryenExpressionRef BinaryenIndex _string -> _void)

(defbinaryen* BinaryenTryAppendCatchEvent : BinaryenExpressionRef _string -> BinaryenIndex)

(defbinaryen* BinaryenTryInsertCatchEventAt : BinaryenExpressionRef BinaryenIndex _string -> _void)

(defbinaryen* BinaryenTryRemoveCatchEventAt : BinaryenExpressionRef BinaryenIndex -> _string)

(defbinaryen* BinaryenTryGetCatchBodyAt : BinaryenExpressionRef BinaryenIndex -> BinaryenExpressionRef)
(defbinaryen* BinaryenTrySetCatchBodyAt : BinaryenExpressionRef BinaryenIndex BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenTryAppendCatchBody : BinaryenExpressionRef BinaryenExpressionRef -> BinaryenIndex)

(defbinaryen* BinaryenTryInsertCatchBodyAt : BinaryenExpressionRef BinaryenIndex BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenTryRemoveCatchBodyAt : BinaryenExpressionRef BinaryenIndex -> BinaryenExpressionRef)

(defbinaryen* BinaryenTryHasCatchAll : BinaryenExpressionRef -> _int)

(defbinaryen* BinaryenTryIsDelegate : BinaryenExpressionRef -> _int)

; Throw

(defbinaryen*-get/set-fields Throw
  (Event _string))

(defbinaryen* BinaryenThrowGetNumOperands : BinaryenExpressionRef -> BinaryenIndex)

(defbinaryen* BinaryenThrowGetOperandAt :
  BinaryenExpressionRef BinaryenIndex -> BinaryenExpressionRef)
(defbinaryen* BinaryenThrowSetOperandAt :
  BinaryenExpressionRef BinaryenIndex BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenThrowAppendOperand :
  BinaryenExpressionRef BinaryenExpressionRef -> BinaryenIndex)

(defbinaryen* BinaryenThrowInsertOperandAt : BinaryenExpressionRef BinaryenIndex BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenThrowRemoveOperandAt : BinaryenExpressionRef BinaryenIndex -> BinaryenExpressionRef)

; Rethrow

(defbinaryen*-get/set-fields Rethrow
  (Target _string))

; TupleMake

(defbinaryen*-get TupleMake NumOperands BinaryenIndex)

(defbinaryen*-get/set TupleMake OperandAt [BinaryenIndex] BinaryenExpressionRef)

(defbinaryen* BinaryenTupleMakeAppendOperand :
  BinaryenExpressionRef BinaryenExpressionRef -> BinaryenIndex)

(defbinaryen* BinaryenTupleMakeInsertOperandAt :
  BinaryenExpressionRef BinaryenIndex BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenTupleMakeRemoveOperandAt :
  BinaryenExpressionRef BinaryenIndex -> BinaryenExpressionRef)

; TupleExtract

(defbinaryen*-get/set-fields TupleExtract
  (Tuple BinaryenExpressionRef)
  (Index BinaryenIndex))

; I31New

(defbinaryen*-get/set-fields I31New
  (Value BinaryenExpressionRef))

; I31Get

(defbinaryen*-get/set-fields I31Get
  (I31 BinaryenExpressionRef))

;; We use I31 only here due to binaryen #3613
(defbinaryen*-get I31 IsSigned _bool)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; FUNCTIONS
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define BinaryenFunctionRef (_cpointer 'BinaryenFunction))

(defbinaryen* BinaryenAddFunction :
  BinaryenModuleRef
  _string
  BinaryenType
  BinaryenType
  [varTypes : (_list i BinaryenType)]
  [BinaryenIndex = (length varTypes)]
  BinaryenExpressionRef
  -> BinaryenFunctionRef)

(defbinaryen* BinaryenGetFunction :
  BinaryenModuleRef _string -> BinaryenFunctionRef)

(defbinaryen* BinaryenGetNumFunctions :
  BinaryenModuleRef -> BinaryenIndex)

(defbinaryen* BinaryenGetFunctionByIndex :
  BinaryenModuleRef BinaryenIndex -> BinaryenFunctionRef)

(defbinaryen* BinaryenAddFunctionImport :
  BinaryenModuleRef _string _string _string BinaryenType BinaryenType -> _void)

(defbinaryen* BinaryenAddTableImport :
  BinaryenModuleRef _string _string _string -> _void)

(defbinaryen* BinaryenAddMemoryImport :
  BinaryenModuleRef _string _string _string _uint8 -> _void)

(defbinaryen* BinaryenAddGlobalImport :
  BinaryenModuleRef _string _string _string BinaryenType _bool -> _void)

(defbinaryen* BinaryenAddEventImport :
  BinaryenModuleRef _string _string _string _uint32 BinaryenType BinaryenType -> _void)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; EXPORTS
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define BinaryenExportRef (_cpointer 'BinaryenExportRef))

(defbinaryen* BinaryenAddFunctionExport :
  BinaryenModuleRef _string _string -> BinaryenExportRef)

(defbinaryen* BinaryenAddTableExport :
  BinaryenModuleRef _string _string -> BinaryenExportRef)

(defbinaryen* BinaryenAddMemoryExport :
  BinaryenModuleRef _string _string -> BinaryenExportRef)

(defbinaryen* BinaryenAddGlobalExport :
  BinaryenModuleRef _string _string -> BinaryenExportRef)

(defbinaryen* BinaryenAddEventExport :
  BinaryenModuleRef _string _string -> BinaryenExportRef)

(defbinaryen* BinaryenGetExport :
  BinaryenModuleRef _string -> BinaryenExportRef)

(defbinaryen* BinaryenRemoveExport :
  BinaryenModuleRef _string -> _void)

(defbinaryen* BinaryenGetNumExports :
  BinaryenModuleRef -> BinaryenIndex)

(defbinaryen* BinaryenGetExportByIndex :
  BinaryenModuleRef BinaryenIndex -> BinaryenExportRef)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GLOBALS
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define BinaryenGlobalRef (_cpointer 'BinaryenGlobalRef))


(defbinaryen* BinaryenAddGlobal :
  BinaryenModuleRef _string BinaryenType _bool BinaryenExpressionRef -> BinaryenGlobalRef)

(defbinaryen* BinaryenGetGlobal :
  BinaryenModuleRef _string -> BinaryenGlobalRef)

(defbinaryen* BinaryenRemoveGlobal :
  BinaryenModuleRef _string -> _void)

(defbinaryen* BinaryenGetNumGlobals : BinaryenModuleRef -> BinaryenIndex)

(defbinaryen* BinaryenGetGlobalByIndex :
  BinaryenModuleRef BinaryenIndex -> BinaryenGlobalRef)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; EVENTS
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define BinaryenEventRef (_cpointer 'BinaryenEvent))

(defbinaryen* BinaryenAddEvent :
  BinaryenModuleRef _string _uint32 BinaryenType BinaryenType -> BinaryenEventRef)

(defbinaryen* BinaryenGetEvent :
  BinaryenModuleRef _string -> BinaryenEventRef)

(defbinaryen* BinaryenRemoveEvent :
  BinaryenModuleRef _string -> _void)

;; Function table - one per module

(defbinaryen* BinaryenSetFunctionTable :
  BinaryenModuleRef BinaryenIndex BinaryenIndex [funcNames : (_list i _string)] [BinaryenIndex = (length funcNames)] BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenIsFunctionTableImported : BinaryenModuleRef -> _bool)

(defbinaryen* BinaryenGetNumFunctionTableSegments :
  BinaryenModuleRef -> BinaryenIndex)

(defbinaryen* BinaryenGetFunctionTableSegmentOffset :
  BinaryenModuleRef BinaryenIndex -> BinaryenExpressionRef)

(defbinaryen* BinaryenGetFunctionTableSegmentLength :
  BinaryenModuleRef BinaryenIndex -> BinaryenIndex)

(defbinaryen* BinaryenGetFunctionTableSegmentData :
  BinaryenModuleRef BinaryenIndex BinaryenIndex -> _string)

;; Table
(define BinaryenTableRef (_cpointer 'BinaryenTable))

(defbinaryen* BinaryenAddTable :
  BinaryenModuleRef _string BinaryenIndex BinaryenIndex [funcNames : (_list i _string)] [BinaryenIndex = (length funcNames)] BinaryenExpressionRef -> BinaryenTableRef)

(defbinaryen* BinaryenRemoveTable :
  BinaryenModuleRef _string -> _void)

(defbinaryen* BinaryenGetNumTables :
  BinaryenModuleRef -> BinaryenIndex)

(defbinaryen* BinaryenGetTable : BinaryenModuleRef _string -> BinaryenTableRef)

(defbinaryen* BinaryenGetTableByIndex : BinaryenModuleRef BinaryenIndex -> BinaryenTableRef)

;; Memory - one per module

(defbinaryen* BinaryenSetMemory :
  BinaryenModuleRef BinaryenIndex BinaryenIndex _string
  [segments : (_list i _string)]
  [segmentPassing : (_list i _int8)]
  [segmentOffsets : (_list i BinaryenExpressionRef)]
  [segmentSizes : (_list i BinaryenIndex)]
  [BinaryenIndex = (length segments)] ; all lists here need to have the same length
  _uint8 -> _void) ;FIXME should probably be _bool

(defbinaryen* BinaryenGetNumMemorySegments :
  BinaryenModuleRef -> _uint32)

(defbinaryen* BinaryenGetMemorySegmentByteOffset :
  BinaryenModuleRef BinaryenIndex -> _uint32)

(defbinaryen* BinaryenGetMemorySegmentByteLength :
  BinaryenModuleRef BinaryenIndex -> _size)

(defbinaryen* BinaryenGetMemorySegmentPassive :
  BinaryenModuleRef BinaryenIndex -> _bool)

(defbinaryen* BinaryenCopyMemorySegmentData :
  BinaryenModuleRef BinaryenIndex _string -> _void)

; Start function - one per module

(defbinaryen* BinaryenSetStart :
  BinaryenModuleRef BinaryenFunctionRef -> _void)

; Features

(defbinaryen* BinaryenModuleGetFeatures : BinaryenModuleRef -> BinaryenFeatures)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; MODULE OPERATIONS
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defbinaryen* BinaryenModuleParse : _string -> BinaryenModuleRef)

(defbinaryen* BinaryenModulePrint : BinaryenModuleRef -> _void)

(defbinaryen* BinaryenModulePrintAsmjs : BinaryenModuleRef -> _void)

(defbinaryen* BinaryenModuleValidate : BinaryenModuleRef -> _bool)

(defbinaryen* BinaryenModuleOptimize : BinaryenModuleRef -> _void)

(defbinaryen* BinaryenGetOptimizeLevel : -> _int)

(defbinaryen* BinaryenSetOptimizeLevel : _int -> _void)

(defbinaryen* BinaryenGetShrinkLevel : -> _int)

(defbinaryen* BinaryenSetShrinkLevel : _int -> _void)

(defbinaryen* BinaryenGetDebugInfo : -> _bool)

(defbinaryen* BinaryenSetDebugInfo : _bool -> _void)

(defbinaryen* BinaryenGetLowMemoryUnused : -> _bool)

(defbinaryen* BinaryenSetLowMemoryUnused : _bool -> _void)

(defbinaryen* BinaryenGetFastMath : -> _bool)

(defbinaryen* BinaryenSetFastMath : _int -> _void)

(defbinaryen* BinaryenGetPassArgument : _string -> _string)

(defbinaryen* BinaryenSetPassArgument : _string _string -> _void)

(defbinaryen* BinaryenClearPassArguments : -> _void)

(defbinaryen* BinaryenGetAlwaysInlineMaxSize : -> BinaryenIndex)

(defbinaryen* BinaryenSetAlwaysInlineMaxSize : BinaryenIndex -> _void)

(defbinaryen* BinaryenGetFlexibleInlineMaxSize : -> BinaryenIndex)

(defbinaryen* BinaryenSetFlexibleInlineMaxSize : BinaryenIndex -> _void)

(defbinaryen* BinaryenGetOneCallerInlineMaxSize : -> BinaryenIndex)

(defbinaryen* BinaryenSetOneCallerInlineMaxSize : BinaryenIndex -> _void)

(defbinaryen* BinaryenGetAllowInliningFunctionsWithLoops : -> _bool)

(defbinaryen* BinaryenSetAllowInliningFunctionsWithLoops : _bool -> _void)

(defbinaryen* BinaryenModuleRunPasses :
  BinaryenModuleRef [passes : (_list i _string)] [BinaryenIndex = (length passes)] -> _void)

(defbinaryen* BinaryenModuleAutoDrop : BinaryenModuleRef -> _void)

(defbinaryen* BinaryenModuleWrite : BinaryenModuleRef [output : _bytes] [_size = (length output)] -> _size)

(defbinaryen* BinaryenModuleWriteText :
  BinaryenModuleRef [output : _bytes] [_size = (length output)] -> _size)

(define-cstruct _BinaryenBufferSizes
  ([outputBytes _size]
   [sourceMapBytes _size]))

(defbinaryen* BinaryenModuleWriteWithSourceMap :
  BinaryenModuleRef _string
  [output : (_bytes o outputSize)]
  [outputSize : _size]
  [sourceMap : (_bytes o sourceMapSize)]
  [sourceMapSize : _size]
  -> [res : _BinaryenBufferSizes]
  -> (values res output sourceMap))

(define-cstruct _BinaryenModuleAllocateAndWriteResult
  ([binary _pointer]
   [binaryBytes _size]
   [sourceMp _bytes])) ; need to explicit free buffers
; TODO can we move the returned buffers into gc?

(defbinaryen* BinaryenModuleAllocateAndWrite :
  BinaryenModuleRef _string -> _BinaryenModuleAllocateAndWriteResult)

(defbinaryen* BinaryenModuleAllocateAndWriteText :
  BinaryenModuleRef -> _string) ; need to explicitly free buffers
; TODO can we more the return _string into gc?

(defbinaryen* BinaryenModuleRead :
  [input : _bytes]
  [inputSize : _size = (bytes-length input)] -> BinaryenModuleRef)

(defbinaryen* BinaryenModuleInterpret :
  BinaryenModuleRef -> _void)

(defbinaryen* BinaryenModuleAddDebugInfoFileName :
  BinaryenModuleRef _path -> BinaryenIndex)

(defbinaryen* BinaryenModuleGetDebugInfoFileName :
  BinaryenModuleRef BinaryenIndex -> _path)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; FUNCTION OPERATIONS
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defbinaryen* BinaryenFunctionGetName :
  BinaryenFunctionRef -> _string)

(defbinaryen* BinaryenFunctionGetParams : BinaryenFunctionRef -> BinaryenType)

(defbinaryen* BinaryenFunctionGetResults : BinaryenFunctionRef -> BinaryenType)

(defbinaryen* BinaryenFunctionGetNumVars : BinaryenFunctionRef -> BinaryenIndex)

(defbinaryen* BinaryenFunctionGetVar : BinaryenFunctionRef BinaryenIndex -> BinaryenType)

(defbinaryen* BinaryenFunctionGetNumLocals : BinaryenFunctionRef -> BinaryenIndex)

(defbinaryen* BinaryenFunctionHasLocalName : BinaryenFunctionRef BinaryenIndex -> _bool)

(defbinaryen* BinaryenFunctionGetLocalName : BinaryenFunctionRef BinaryenIndex -> _string)

(defbinaryen* BinaryenFunctionSetLocalName : BinaryenFunctionRef BinaryenIndex _string -> _void)

(defbinaryen* BinaryenFunctionGetBody : BinaryenFunctionRef -> BinaryenExpressionRef)

(defbinaryen* BinaryenFunctionSetBody : BinaryenFunctionRef BinaryenExpressionRef -> _void)

(defbinaryen* BinaryenFunctionOptimize : BinaryenFunctionRef BinaryenModuleRef -> _void)

(defbinaryen* BinaryenFunctionRunPasses : BinaryenFunctionRef BinaryenModuleRef [passes : (_list i _string)] [BinaryenIndex = (length passes)] -> _void)

(defbinaryen* BinaryenFunctionSetDebugLocation :
  BinaryenFunctionRef
  BinaryenExpressionRef
  BinaryenIndex
  BinaryenIndex
  BinaryenIndex
  -> _void)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; TABLE OPERATIONS
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defbinaryen* BinaryenTableGetName : BinaryenTableRef -> _string)

(defbinaryen* BinaryenTableGetInitial : BinaryenTableRef -> _int)

(defbinaryen* BinaryenTableHasMax : BinaryenTableRef -> _bool)

(defbinaryen* BinaryenTableGetMax : BinaryenTableRef -> _int)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GLOBAL OPERATIONS
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defbinaryen* BinaryenGlobalGetName : BinaryenGlobalRef -> _string)

(defbinaryen* BinaryenGlobalGetType : BinaryenGlobalRef -> BinaryenType)

(defbinaryen* BinaryenGlobalIsMutable : BinaryenGlobalRef -> _bool)

(defbinaryen* BinaryenGlobalGetInitExpr : BinaryenGlobalRef -> BinaryenExpressionRef)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; EVENT OPERATIONS
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defbinaryen* BinaryenEventGetName : BinaryenEventRef -> _string)

(defbinaryen* BinaryenEventGetAttribute : BinaryenEventRef -> _int)

(defbinaryen* BinaryenEventGetParams : BinaryenEventRef -> BinaryenType)

(defbinaryen* BinaryenEventGetResults : BinaryenEventRef -> BinaryenType)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; IMPORT OPERATIONS
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defbinaryen* BinaryenFunctionImportGetModule : BinaryenFunctionRef -> _string)

(defbinaryen* BinaryenTableImportGetModule : BinaryenTableRef -> _string)

(defbinaryen* BinaryenGlobalImportGetModule : BinaryenGlobalRef -> _string)

(defbinaryen* BinaryenEventImportGetModule : BinaryenEventRef -> _string)

(defbinaryen* BinaryenFunctionImportGetBase : BinaryenFunctionRef -> _string)

(defbinaryen* BinaryenTableImportGetBase : BinaryenTableRef -> _string)

(defbinaryen* BinaryenGlobalImportGetBase : BinaryenGlobalRef -> _string)

(defbinaryen* BinaryenEventImportGetBase : BinaryenEventRef -> _string)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; EXPORT OPERATIONS
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defbinaryen* BinaryenExportGetKind : BinaryenExportRef -> BinaryenExternalKind)

(defbinaryen* BinaryenExportGetName : BinaryenExportRef -> _string)

(defbinaryen* BinaryenExportGetValue : BinaryenExportRef -> _string)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; CUSTOM SECTIONS
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defbinaryen* BinaryenAddCustomSection :
  BinaryenModuleRef _string
  [contents : _bytes]
  [contentsSize : BinaryenIndex = (bytes-length contents)] -> _void)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; EFFECT ANALYZER
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define BinaryenSideEffects _uint32)

(defbinaryen* BinaryenSideEffectNone : -> BinaryenSideEffects)
(defbinaryen* BinaryenSideEffectBranches : -> BinaryenSideEffects)
(defbinaryen* BinaryenSideEffectCalls : -> BinaryenSideEffects)
(defbinaryen* BinaryenSideEffectReadsLocal : -> BinaryenSideEffects)
(defbinaryen* BinaryenSideEffectWritesLocal : -> BinaryenSideEffects)
(defbinaryen* BinaryenSideEffectReadsGlobal : -> BinaryenSideEffects)
(defbinaryen* BinaryenSideEffectWritesGlobal : -> BinaryenSideEffects)
(defbinaryen* BinaryenSideEffectReadsMemory : -> BinaryenSideEffects)
(defbinaryen* BinaryenSideEffectWritesMemory : -> BinaryenSideEffects)
(defbinaryen* BinaryenSideEffectImplicitTrap : -> BinaryenSideEffects)
(defbinaryen* BinaryenSideEffectIsAtomic : -> BinaryenSideEffects)
(defbinaryen* BinaryenSideEffectThrows : -> BinaryenSideEffects)
(defbinaryen* BinaryenSideEffectDanglingPop : -> BinaryenSideEffects)
(defbinaryen* BinaryenSideEffectAny : -> BinaryenSideEffects)

(defbinaryen* BinaryenExpressionGetSideEffects : BinaryenExpressionRef BinaryenFeatures -> BinaryenSideEffects)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; CFG / Relooper
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define RelooperRef (_cpointer 'Relooper))
(define RelooperBlockRef (_cpointer 'RelooperBlock))

(defbinaryen* RelooperCreate : BinaryenModuleRef -> RelooperRef)

(defbinaryen* RelooperAddBlock : RelooperRef BinaryenExpressionRef -> RelooperBlockRef)

(defbinaryen* RelooperAddBranch : RelooperBlockRef RelooperBlockRef BinaryenExpressionRef BinaryenExpressionRef -> _void)

(defbinaryen* RelooperAddBlockWithSwitch :
  RelooperRef BinaryenExpressionRef BinaryenExpressionRef -> _void)

(defbinaryen* RelooperAddBranchForSwitch :
  RelooperBlockRef RelooperBlockRef
  [indexes : (_list i BinaryenIndex)] [BinaryenIndex = (length indexes)] BinaryenExpressionRef -> _void)

(defbinaryen* RelooperRenderAndDispose :
  RelooperRef RelooperBlockRef BinaryenIndex -> BinaryenExpressionRef)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Expression Runner
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define ExpressionRunnerRef (_cpointer 'CEExpressionRunner))
(define ExpressionRunnerFlags _uint32)

(defbinaryen* ExpressionRunnerFlagsDefault : -> ExpressionRunnerFlags)

(defbinaryen* ExpressionRunnerFlagsPreserveSideeffects : -> ExpressionRunnerFlags)

(defbinaryen* ExpressionRunnerFlagsTraverseCalls : -> ExpressionRunnerFlags)

(defbinaryen* ExpressionRunnerCreate : BinaryenModuleRef ExpressionRunnerFlags BinaryenIndex BinaryenIndex -> ExpressionRunnerRef)

(defbinaryen* ExpressionRunnerSetLocalValue : ExpressionRunnerRef BinaryenIndex BinaryenExpressionRef -> _bool)

(defbinaryen* ExpressionRunnerSetGlobalValue : ExpressionRunnerRef _string BinaryenExpressionRef -> _bool)

(defbinaryen* ExpressionRunnerRunAndDispose : ExpressionRunnerRef BinaryenExpressionRef -> BinaryenExpressionRef)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Utilities
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defbinaryen* BinaryenSetColorsEnabled : _bool -> _void)

(defbinaryen* BinaryenAreColorsEnabled : -> _bool)
