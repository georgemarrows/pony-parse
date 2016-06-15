use "ponytest"

use "../../rdparser"
use "../../ponyparser"


// To do
// DONE genericise parser/lexer/token over id type
// DONE make test case parse work
// DONE use pony testing framework
// DONE tracing
// DONE full parse array
// - README.md
// - rename Tk in rdparser
// - make AST
// - genericise over AST type
// - Ruby script to generate from parser.c



actor Main is TestList

  new create(env: Env) => 
    PonyTest(env, this)

  // new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestParseCap)
    test(_TestParseArray)


trait iso _TestParse is UnitTest
  
  fun test(expected: Ast, 
           ids: Array[Id], 
           h: TestHelper, 
           rule: { (Parser[Id], String): Ast } box) =>
    let toks = Array[Token[Id]](ids.size())
    for id in ids.values() do
      toks.push(Token[Id](id))
    end

    let trace = Trace(h.env.out)
    trace.log("-----------")
    
    let l: Lexer[Id] = IterToLexer(toks.values())
    let p: Parser[Id] = Parser[Id](l, TkEof, TkLexError, trace)
    let actual = rule(p, "blerk")
    h.assert_is[Ast](expected, actual, 
                     "Expected " + expected.string() + 
                     " actual " + actual.string())  


class iso _TestParseCap is _TestParse
  """
  XXX
  """
  fun name(): String => "Pony/parse.cap"

  fun apply(h: TestHelper) =>
    let rule = Grammar~cap()
    test(PARSEOK,    [as Id: TkIso], h, rule)
    test(PARSEERROR, [as Id: TkLexError], h, rule)


class iso _TestParseArray is _TestParse
  """
  XXX
  """
  fun name(): String => "Pony/parse.array"

  fun apply(h: TestHelper) =>
    let rule = Grammar~array()
    test(PARSEOK,    [as Id: TkLSquare, TkIso, TkComma, TkRef, TkRSquare], h, rule)
    test(RULENOTFOUND, [as Id: TkIso], h, rule)
    test(PARSEERROR, [as Id: TkLSquare, TkEof], h, rule)
    test(PARSEERROR, [as Id: TkLSquare, TkLSquare], h, rule)
    test(PARSEERROR, [as Id: TkLSquare, TkComma], h, rule)
    test(PARSEERROR, [as Id: TkLSquare, TkComma, TkComma], h, rule)
    test(PARSEERROR, [as Id: TkLSquare, TkIso, TkIso], h, rule)


  



class IterToLexer is Lexer[Id]
  let _iter: Iterator[Token[Id]]

  new create(iter: Iterator[Token[Id]]) =>
    _iter = iter

  fun ref next(): Token[Id] => 
    try _iter.next() else Token[Id](TkEof) end
