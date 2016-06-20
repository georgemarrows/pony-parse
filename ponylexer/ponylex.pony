use rd = "../rdparser"
use "../ponyparser"
use "collections"


class Lexer

  let _input: String
  let _env: Env

  var loc: USize = 0

  let keywords: Map[String val, rd.Tk] val = recover val
    let k = Map[String val, rd.Tk]
    k("iso") = TkIso
    k("ref") = TkRef
    k
  end

  new create(input: String, env: Env) =>
    _input = input
    _env = env

  fun ref next(): rd.Tk =>
    let c: U8 = try _input(loc) else return TkEof end
    if c == ' ' then readWhitespace() end

    let c': U8 = try _input(loc) else return TkEof end
    if ('a' <= c') and (c' <= 'z') then
      return readKeywordOrId()
    elseif c' == '[' then
      loc = loc + 1
      return TkLSquare 
    elseif c' == ']' then
      loc = loc + 1
      return TkRSquare
    elseif c' == ',' then
      loc = loc + 1
      return TkComma
    else
      return TkLexError
    end

  fun ref readWhitespace() =>    
    repeat
      loc = loc + 1
    until ' ' != try _input(loc) else return end end


  fun ref readKeywordOrId(): rd.Tk =>
    for (str, keyword) in keywords.pairs() do
      if cmp_in_place(str, _input, loc) then
        loc = loc + str.size()
        return keyword
      end
    end
    TkLexError

  fun tag cmp_in_place(s1: String, s2: String, start2: USize): Bool =>
    var i: USize = 0
    while true do
      let c = try s1(i) else return true end
      let c' = try s2(start2 + i) else return false end
      if c != c' then return false end
      i = i + 1
    end
    true
 