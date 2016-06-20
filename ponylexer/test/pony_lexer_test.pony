use "ponytest"

use "../../ponylexer"
use "../../ponyparser"
use rd = "../../rdparser"


actor Main is TestList

  new create(env: Env) => 
    PonyTest(env, this)

  // new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestCmpInPlace)
    test(_TestLexKeyword)
    test(_TestLexArray)


trait LexTest is UnitTest

  fun assert_lex(h: TestHelper,
                 expected: Array[rd.Tk],
                 input: String) =>
    let l = Lexer(input, h.env)
    for expected_id in expected.values() do
      let id = l.next()
      // h.env.out.print(try id.show() else "-blerk-" end)
      h.assert_is[rd.Tk](expected_id, id)
    end
    h.assert_is[rd.Tk](TkEof, l.next())


class iso _TestLexKeyword is LexTest
  """
  XXX
  """
  fun name(): String => "Pony/lex.keyword"

  fun apply(h: TestHelper) =>
    assert_lex(h, Array[rd.Tk], "   ")

    assert_lex(h, [as rd.Tk: TkIso], "iso")

    assert_lex(h, [as rd.Tk: TkIso, TkRef], "iso ref")


class iso _TestLexArray is LexTest
  """
  XXX
  """
  fun name(): String => "Pony/lex.array"

  fun apply(h: TestHelper) =>
    let l1 = Lexer("[iso, ref]", h.env)
    assert_lex(h,
               [as rd.Tk: TkLSquare, TkIso, TkComma, TkRef, TkRSquare],
               "[iso, ref]")



class iso _TestCmpInPlace is UnitTest
  """
  XXX
  """
  fun name(): String => "Pony/cmp.in.place"

  fun apply(h: TestHelper) =>
    let l = Lexer("xxx", h.env)
    h.assert_true(l.cmp_in_place("", "", 0))
    h.assert_true(l.cmp_in_place("abc", "abc", 0))
    h.assert_true(l.cmp_in_place("abc", "abcd", 0))

    h.assert_true(l.cmp_in_place("",    "x", 1))
    h.assert_true(l.cmp_in_place("abc", "xabc", 1))
    h.assert_true(l.cmp_in_place("abc", "xabcd", 1))

    h.assert_false(l.cmp_in_place("abc", "xabc", 0))
    h.assert_false(l.cmp_in_place("abc", "xabcd", 0))
