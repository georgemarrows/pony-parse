use "ponytest"

use rd = "../../rdparser"
use "../../ponyparser"



actor Main is TestList

  new create(env: Env) => 
    PonyTest(env, this)

  // new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestParseCap)
    test(_TestParseArray)


trait iso _TestParse is UnitTest
  
  fun test(expected: rd.Ast, 
           ids: Array[Id], 
           h: TestHelper, 
           rule: { (Parser, String): rd.Ast } box) =>
    let toks = Array[Token](ids.size())
    for id in ids.values() do
      toks.push(Token(id))
    end

    let trace = rd.Trace(h.env.out)
    trace.log("-----------")
    
    let l: rd.Lexer[Id, Token] = IterToLexer(toks.values())
    let p: Parser = Parser(l, TkEof, TkLexError, trace)
    let actual = rule(p, "blerk")
    h.assert_is[rd.Ast](expected, actual, 
                     "Expected " + expected.string() + 
                     " actual " + actual.string())  


class iso _TestParseCap is _TestParse
  """
  XXX
  """
  fun name(): String => "Pony/parse.cap"

  fun apply(h: TestHelper) =>
    let rule = Grammar~cap()
    test(rd.PARSEOK,    [as Id: TkIso], h, rule)
    test(rd.PARSEERROR, [as Id: TkLexError], h, rule)


class iso _TestParseArray is _TestParse
  """
  XXX
  """
  fun name(): String => "Pony/parse.array"

  fun apply(h: TestHelper) =>
    let rule = Grammar~array()
    test(rd.PARSEOK,    [as Id: TkLSquare, TkIso, TkComma, TkRef, TkRSquare], h, rule)
    test(rd.RULENOTFOUND, [as Id: TkIso], h, rule)
    test(rd.PARSEERROR, [as Id: TkLSquare, TkEof], h, rule)
    test(rd.PARSEERROR, [as Id: TkLSquare, TkLSquare], h, rule)
    test(rd.PARSEERROR, [as Id: TkLSquare, TkComma], h, rule)
    test(rd.PARSEERROR, [as Id: TkLSquare, TkComma, TkComma], h, rule)
    test(rd.PARSEERROR, [as Id: TkLSquare, TkIso, TkIso], h, rule)


  



class IterToLexer is rd.Lexer[Id, Token]
  let _iter: Iterator[Token]

  new create(iter: Iterator[Token]) =>
    _iter = iter

  fun ref next(): Token => 
    try _iter.next() else Token(TkEof) end
