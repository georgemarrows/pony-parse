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
