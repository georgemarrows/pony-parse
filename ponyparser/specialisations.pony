use rd = "../rdparser"

// Specialisations of rdparser types for ones we use in ponyparser

type Parser is rd.Parser[Id, Token]

type Ast is rd.Ast

type PARSEOK is rd.PARSEOK


type RuleState[I: Any val] is rd.RuleState[I]

class val Token is rd.Token[Id]
  let _id': Id

  new val create(id'': Id) => _id' = id''
  fun id(): Id => _id'

  fun is_lex_error(): Bool => _id' is TkLexError

  fun is_eof(): Bool => _id' is TkEof

  fun is_id(id'': Id): Bool => _id' is id''

  fun show(): String => try _id'.show() else "** show error **" end
