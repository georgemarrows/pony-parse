use ast = "../../pony-ast/ast"

// Token IDs not in pony-ast
primitive TkEof      is ast.Tk fun show(): String => "** eof **"
primitive TkLexError is ast.Tk fun show(): String => "** lex error **"

// Aliases for pony-ast token IDs to avoid importing pony-ast everywhere
type TkDontCare         is ast.TkDontCare
type TkCompileIntrinsic is ast.TkCompileIntrinsic
type TkUse              is ast.TkUse
type TkType             is ast.TkType
type TkInterface        is ast.TkInterface
type TkTrait            is ast.TkTrait
type TkPrimitive        is ast.TkPrimitive
type TkStruct           is ast.TkStruct
type TkClass            is ast.TkClass
type TkActor            is ast.TkActor
type TkObject           is ast.TkObject
type TkLambda           is ast.TkLambda
type TkDelegate         is ast.TkDelegate
type TkAs               is ast.TkAs
type TkIs               is ast.TkIs
type TkIsnt             is ast.TkIsnt
type TkVar              is ast.TkVar
type TkLet              is ast.TkLet
type TkEmbed            is ast.TkEmbed
type TkNew              is ast.TkNew
type TkFun              is ast.TkFun
type TkBe               is ast.TkBe
type TkIso              is ast.TkIso
type TkTrn              is ast.TkTrn
type TkRef              is ast.TkRef
type TkVal              is ast.TkVal
type TkBox              is ast.TkBox
type TkTag              is ast.TkTag
type TkThis             is ast.TkThis
type TkReturn           is ast.TkReturn
type TkBreak            is ast.TkBreak
type TkContinue         is ast.TkContinue
type TkConsume          is ast.TkConsume
type TkRecover          is ast.TkRecover
type TkIf               is ast.TkIf
type TkIfdef            is ast.TkIfdef
type TkThen             is ast.TkThen
type TkElse             is ast.TkElse
type TkElseIf           is ast.TkElseIf
type TkEnd              is ast.TkEnd
type TkFor              is ast.TkFor
type TkIn               is ast.TkIn
type TkWhile            is ast.TkWhile
type TkDo               is ast.TkDo
type TkRepeat           is ast.TkRepeat
type TkUntil            is ast.TkUntil
type TkMatch            is ast.TkMatch
type TkWhere            is ast.TkWhere
type TkTry              is ast.TkTry
type TkWith             is ast.TkWith
type TkError            is ast.TkError
type TkCompileError     is ast.TkCompileError
type TkNot              is ast.TkNot
type TkAnd              is ast.TkAnd
type TkOr               is ast.TkOr
type TkXor              is ast.TkXor
type TkIdentityOf       is ast.TkIdentityOf
type TkAddress          is ast.TkAddress
type TkLocation         is ast.TkLocation
type TkTrue             is ast.TkTrue
type TkFalse            is ast.TkFalse
type TkCapRead          is ast.TkCapRead
type TkCapSend          is ast.TkCapSend
type TkCapShare         is ast.TkCapShare
type TkCapAny           is ast.TkCapAny
type TkTestNoSeq        is ast.TkTestNoSeq
type TkTestSeqScope     is ast.TkTestSeqScope
type TkTestTryNoCheck   is ast.TkTestTryNoCheck
type TkTestBorrowed     is ast.TkTestBorrowed
type TkTestUpdateArg    is ast.TkTestUpdateArg
type TkTestExtra        is ast.TkTestExtra
type TkIfdefAnd         is ast.TkIfdefAnd
type TkIfdefOr          is ast.TkIfdefOr
type TkIfdefNot         is ast.TkIfdefNot
type TkIfdefFlag        is ast.TkIfdefFlag
type TkMatchCapture     is ast.TkMatchCapture
type TkEllipsis         is ast.TkEllipsis
type TkArrow            is ast.TkArrow
type TkDoubleArrow      is ast.TkDoubleArrow
type TkLShift           is ast.TkLShift
type TkRShift           is ast.TkRShift
type TkEq               is ast.TkEq
type TkNe               is ast.TkNe
type TkLe               is ast.TkLe
type TkGe               is ast.TkGe
type TkLBrace           is ast.TkLBrace
type TkRBrace           is ast.TkRBrace
type TkLParen           is ast.TkLParen
type TkRParen           is ast.TkRParen
type TkLSquare          is ast.TkLSquare
type TkRSquare          is ast.TkRSquare
type TkComma            is ast.TkComma
type TkDot              is ast.TkDot
type TkTilde            is ast.TkTilde
type TkColon            is ast.TkColon
type TkSemi             is ast.TkSemi
type TkAssign           is ast.TkAssign
type TkPlus             is ast.TkPlus
type TkMinus            is ast.TkMinus
type TkMultiply         is ast.TkMultiply
type TkDivide           is ast.TkDivide
type TkMod              is ast.TkMod
type TkAt               is ast.TkAt
type TkLt               is ast.TkLt
type TkGt               is ast.TkGt
type TkPipe             is ast.TkPipe
type TkIntersectType    is ast.TkIntersectType
type TkEphemeral        is ast.TkEphemeral
type TkBorrowed         is ast.TkBorrowed
type TkQuestion         is ast.TkQuestion
type TkUnaryMinus       is ast.TkUnaryMinus
type TkConstant         is ast.TkConstant
type TkLParenNew        is ast.TkLParenNew
type TkLSquareNew       is ast.TkLSquareNew
type TkMinusNew         is ast.TkMinusNew
type TkId               is ast.TkId
type TkString           is ast.TkString
type TkFloat            is ast.TkFloat
type TkInt              is ast.TkInt
type TkNone             is ast.TkNone


type Id is ( TkEof
           | TkLexError
           | TkDontCare
           | TkCompileIntrinsic
           | TkUse
           | TkType
           | TkInterface
           | TkTrait
           | TkPrimitive
           | TkStruct
           | TkClass
           | TkActor
           | TkObject
           | TkLambda
           | TkDelegate
           | TkAs
           | TkIs
           | TkIsnt
           | TkVar
           | TkLet
           | TkEmbed
           | TkNew
           | TkFun
           | TkBe
           | TkIso
           | TkTrn
           | TkRef
           | TkVal
           | TkBox
           | TkTag
           | TkThis
           | TkReturn
           | TkBreak
           | TkContinue
           | TkConsume
           | TkRecover
           | TkIf
           | TkIfdef
           | TkThen
           | TkElse
           | TkElseIf
           | TkEnd
           | TkFor
           | TkIn
           | TkWhile
           | TkDo
           | TkRepeat
           | TkUntil
           | TkMatch
           | TkWhere
           | TkTry
           | TkWith
           | TkError
           | TkCompileError
           | TkNot
           | TkAnd
           | TkOr
           | TkXor
           | TkIdentityOf
           | TkAddress
           | TkLocation
           | TkTrue
           | TkFalse
           | TkCapRead
           | TkCapSend
           | TkCapShare
           | TkCapAny
           | TkTestNoSeq
           | TkTestSeqScope
           | TkTestTryNoCheck
           | TkTestBorrowed
           | TkTestUpdateArg
           | TkTestExtra
           | TkIfdefAnd
           | TkIfdefOr
           | TkIfdefNot
           | TkIfdefFlag
           | TkMatchCapture
           | TkEllipsis
           | TkArrow
           | TkDoubleArrow
           | TkLShift
           | TkRShift
           | TkEq
           | TkNe
           | TkLe
           | TkGe
           | TkLBrace
           | TkRBrace
           | TkLParen
           | TkRParen
           | TkLSquare
           | TkRSquare
           | TkComma
           | TkDot
           | TkTilde
           | TkColon
           | TkSemi
           | TkAssign
           | TkPlus
           | TkMinus
           | TkMultiply
           | TkDivide
           | TkMod
           | TkAt
           | TkLt
           | TkGt
           | TkPipe
           | TkIntersectType
           | TkEphemeral
           | TkBorrowed
           | TkQuestion
           | TkUnaryMinus
           | TkConstant
           | TkLParenNew
           | TkLSquareNew
           | TkMinusNew
           | TkId
           | TkString
           | TkFloat
           | TkInt
           | TkNone )