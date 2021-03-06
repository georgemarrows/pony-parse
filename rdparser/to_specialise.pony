"""
Traits and interfaces that need specialising to be able to 
use rdparser.
"""

trait val Token[I: Any val]
  fun line_number(): U32 => 0
  fun id(): I
  fun set_pos(other: Token[I]) => true
  
  fun is_lex_error(): Bool
  fun is_eof(): Bool

  fun is_id(id': I): Bool

  fun show(): String
    

interface Lexer[I: Any val, T: Token[I] val]
  fun ref next(): T

