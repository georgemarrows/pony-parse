use rd = "../rdparser"

primitive TkIso              is rd.Tk fun show(): String => "iso"
primitive TkTrn              is rd.Tk fun show(): String => "trn"
primitive TkRef              is rd.Tk fun show(): String => "ref"
primitive TkVal              is rd.Tk fun show(): String => "val"
primitive TkBox              is rd.Tk fun show(): String => "box"
primitive TkTag              is rd.Tk fun show(): String => "tag"

primitive TkLSquare          is rd.Tk fun show(): String => "["
primitive TkLSquareNew       is rd.Tk fun show(): String => "["
primitive TkRSquare          is rd.Tk fun show(): String => "]"
primitive TkComma            is rd.Tk fun show(): String => ","

primitive TkLexError         is rd.Tk fun show(): String => "** lex error **"
primitive TkNone             is rd.Tk fun show(): String => "** none **"
primitive TkEof              is rd.Tk fun show(): String => "** eof **"


type Id is (TkIso | TkTrn | TkRef | TkVal | TkBox | TkTag | 
            TkLSquare | TkLSquareNew | TkRSquare | TkComma | 
            TkEof | TkNone | TkLexError)
