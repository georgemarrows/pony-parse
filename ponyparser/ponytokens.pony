trait val Tk is Equatable[Tk]
  fun show(): String ?

primitive TkIso              is Tk fun show(): String => "iso"
primitive TkTrn              is Tk fun show(): String => "trn"
primitive TkRef              is Tk fun show(): String => "ref"
primitive TkVal              is Tk fun show(): String => "val"
primitive TkBox              is Tk fun show(): String => "box"
primitive TkTag              is Tk fun show(): String => "tag"
primitive TkLSquare          is Tk fun show(): String => "["
primitive TkLSquareNew       is Tk fun show(): String => "["
primitive TkRSquare          is Tk fun show(): String => "]"
primitive TkComma            is Tk fun show(): String => ","
primitive TkLexError         is Tk fun show(): String => "** lex error **"
primitive TkNone             is Tk fun show(): String => "** none **"
primitive TkEof              is Tk fun show(): String => "** eof **"


type Id is (TkIso | TkTrn | TkRef | TkVal | TkBox | TkTag | 
            TkLSquare | TkLSquareNew | TkRSquare | TkComma | 
            TkEof | TkNone | TkLexError)
