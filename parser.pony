use "ponytest"
use "collections"


// To do
// DONE genericise parser/lexer/token over id type
// DONE make test case parse work
// DONE use pony testing framework
// - tracing
// - full parse array
// - make AST
// - genericise over AST type
// - Ruby script to generate from parser.c


actor Main is TestList
  // let _env: Env

  new create(env: Env) => PonyTest(env, this)
    // _env = env
    // PonyTest(env, this)

  // new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestParseCap)
    test(_TestParseArray)


class iso _TestParseCap is UnitTest
  """
  XXX
  """
  // let _env: Env

  // new create(env: Env) =>
  //   _env = env

  fun name(): String => "Pony/parse.cap"

  fun apply(h: TestHelper) =>
    test(h, PARSEOK,   [Token[Id](TKISO)])
    test(h, PARSEFAIL, [Token[Id](TKLEXERROR)])


  fun test(h: TestHelper, result: Ast, ids: Array[Token[Id]]) =>
    let l: Lexer[Id] = IterToLexer(ids.values())
    let p: Parser[Id] = Parser[Id](l, TKEOF, TKLEXERROR) //, _env)
    let g: Grammar = Grammar
    h.assert_is[Ast](result, g.cap(p, "blerk"))
    // _env.out.print(g.cap(p, "blerk").string())


class iso _TestParseArray is UnitTest
  """
  XXX
  """
  // let _env: Env

  // new create(env: Env) =>
  //   _env = env

  fun name(): String => "Pony/parse.array"

  fun apply(h: TestHelper) =>
    test(h, PARSEOK,   [Token[Id](TKLSQUARE), Token[Id](TKISO)])
    test(h, PARSEFAIL, [Token[Id](TKISO)])
    test(h, PARSEFAIL, [Token[Id](TKLSQUARE), Token[Id](TKEOF)])
    test(h, PARSEFAIL, [Token[Id](TKLSQUARE), Token[Id](TKLSQUARE)])


  fun test(h: TestHelper, result: Ast, ids: Array[Token[Id]]) =>
    let l: Lexer[Id] = IterToLexer(ids.values())
    let p: Parser[Id] = Parser[Id](l, TKEOF, TKLEXERROR) //, _env)
    let g: Grammar = Grammar
    h.assert_is[Ast](result, g.array(p, "blerk"))
    // _env.out.print(g.cap(p, "blerk").string())






class IterToLexer is Lexer[Id]
  let _iter: Iterator[Token[Id]]

  new create(iter: Iterator[Token[Id]]) =>
    _iter = iter

  fun ref next(): Token[Id] => 
    try _iter.next() else Token[Id](TKEOF) end





/*
typedef struct rule_state_t
{
  const char* fn_name;  // Name of the current function, for tracing
  ast_t* ast;           // AST built for this rule
  ast_t* last_child;    // Last child added to current ast
  const char* desc;     // Rule description (set by parent)
  token_id* restart;    // Restart token set, NULL for none
  token_id deflt_id;    // ID of node to create when an optional token or rule
                        // is not found.
                        // TK_EOF = do not create a default
                        // TL_LEX_ERROR = rule is not optional
  bool matched;         // Has the rule matched yet
  bool scope;           // Is this rule a scope
  bool deferred;        // Do we have a deferred AST node
  token_id deferred_id; // ID of deferred AST node
  size_t line, pos;     // Location to claim deferred node is from
} rule_state_t;
*/

primitive TKLEXERROR is Equatable[Id]
primitive TKNONE is Equatable[Id]
primitive TKEOF is Equatable[Id]

primitive TKISO is Equatable[Id]
primitive TKTRN is Equatable[Id]
primitive TKREF is Equatable[Id]
primitive TKVAL is Equatable[Id]
primitive TKBOX is Equatable[Id]
primitive TKTAG is Equatable[Id]

primitive TKLSQUARE is Equatable[Id]
primitive TKLSQUARENEW is Equatable[Id]


type Id is (TKISO | TKTRN | TKREF | TKVAL | TKBOX | TKTAG | TKLSQUARE | TKLSQUARENEW | TKEOF | TKNONE | TKLEXERROR)


primitive PARSEOK is Stringable
  fun string(fmt: FormatSettings = FormatSettingsDefault): String iso^
  =>
    "PARSEOK".string(fmt)

primitive PARSEFAIL is Stringable
  fun string(fmt: FormatSettings = FormatSettingsDefault): String iso^
  =>
    "PARSEFAIL".string(fmt)

primitive PARSEERROR is Stringable
  fun string(fmt: FormatSettings = FormatSettingsDefault): String iso^
  =>
    "PARSEERROR".string(fmt)

primitive RULENOTFOUND is Stringable
  fun string(fmt: FormatSettings = FormatSettingsDefault): String iso^
  =>
    "RULENOTFOUND".string(fmt)


type Ast is (PARSEOK | PARSEFAIL | PARSEERROR | RULENOTFOUND)

type ParseResult is (Ast, Bool)


class RuleState[I: Any val]
  let _rule_name: String
  let _rule_desc: String
  let _default_id: I

  new create(rule_name: String,
            rule_desc: String,
            default_id: I) =>
    _rule_name = rule_name
    _rule_desc = rule_desc
    _default_id = default_id


class val Token[I: Any val]
  let _id: I

  new val create(myid: I) => _id = myid
  fun line_number(): U32 => 0
  fun id(): I => _id
  fun set_pos(other: Token[I]) => true


interface Lexer[I: Any val]
  fun ref next(): Token[I]


class Parser[I: Equatable[I] val]

  let _lexer: Lexer[I]
  let _eof: I
  let _lexerror: I
  // let _env: Env

  var _token: Token[I]
  var _last_token_line: U32 = 0
  var _last_matched: String = ""

  new create(lexer: Lexer[I], eof: I, lexerror: I
    // , env: Env
    ) =>
    _lexer = lexer
    _eof = eof
    _lexerror = lexerror
    // _env = env

    _token = lexer.next()


  fun current_token_id(): I => _token.id()

  fun propogate_error(state: RuleState[I]): ParseResult => (PARSEFAIL, false)

  fun ref next_lexer_token() =>
    let newt: Token[I] = _lexer.next() 
    let oldt: Token[I] = _token
    
    _last_token_line = oldt.line_number()
    if newt.id().eq(_eof) then
      newt.set_pos(oldt)
    end

    _token = newt


  fun ref parse_token_set(state: RuleState[I],
                      desc: (String | None),
                      terminating: (String | None),
                      id_set: Array[I],
                      make_ast: Bool): ParseResult => 

    let id: I = current_token_id()

    if id.eq(_lexerror) then return propogate_error(state) end

    for p in id_set.values() do

      if p.eq(id) then
        return if make_ast then
          handle_found(state, consume_token())
        else
          consume_token_no_ast()
          handle_found(state, PARSEFAIL)  // FIXME NULL
        end
      end
    end

    handle_not_found(state, desc, terminating)
  

// ast_t* parse_rule_set(parser_t* parser, rule_state_t* state, const char* desc,
//   const rule_t* rule_set, bool* out_found)
// {
//   assert(parser != NULL);
//   assert(state != NULL);
//   assert(desc != NULL);
//   assert(rule_set != NULL);

//   token_id id = current_token_id(parser);

//   if(id == TK_LEX_ERROR)
//     return propogate_error(parser, state);

//   if(trace_enable)
//   {
//     fprintf(stderr, "Rule %s: Looking for %s rule%s \"%s\"\n",
//       state->fn_name,
//       (state->deflt_id == TK_LEX_ERROR) ? "required" : "optional",
//       (rule_set[1] == NULL) ? "" : "s", desc);
//   }

//   for(const rule_t* p = rule_set; *p != NULL; p++)
//   {
//     builder_fn_t build_fn = default_builder;
//     ast_t* rule_ast = (*p)(parser, &build_fn, desc);

//     if(rule_ast == PARSE_ERROR)
//       return propogate_error(parser, state);

//     if(rule_ast != RULE_NOT_FOUND)
//     {
//       // Rule found
//       parser->last_matched = desc;
//       return handle_found(parser, state, rule_ast, build_fn, out_found);
//     }
//   }

//   // No rules in set can be matched
//   return handle_not_found(parser, state, desc, NULL, out_found);
// }

  fun ref parse_rule_set(state: RuleState[I], 
                         desc: String,
                         rule_set: Array[ { (Parser[I], String): Ast } box ]): ParseResult => 
    let id: I = current_token_id()

    if id.eq(_lexerror) then return propogate_error(state) end
    
    for r in rule_set.values() do
      let ast: Ast = r(this, desc)
      if (ast is PARSEERROR) then return propogate_error(state) end
      
      if (not (ast is RULENOTFOUND)) then
        _last_matched = desc
        return handle_found(state, PARSEFAIL)
      end
    end

    handle_not_found(state, desc, None)



  fun handle_found(state: RuleState[I], blerk: Ast): ParseResult => 
    (PARSEOK, true)

  fun handle_not_found(state: RuleState[I], 
                       desc:  (String | None), 
                       terminating: (String | None)): ParseResult =>
    (PARSEFAIL, false)

  fun consume_token(): Ast => PARSEOK


// static ast_t* consume_token(parser_t* parser)
// {
//   ast_t* ast = ast_token(parser->token);
//   ast_setflag(ast, parser->next_flags);
//   parser->next_flags = 0;
//   fetch_next_lexer_token(parser, false);
//   return ast;
// }

  fun ref consume_token_no_ast() => next_lexer_token()


  fun rule_complete(state: RuleState[I]): Ast => PARSEOK


// type Rule is {}


primitive Grammar

// CAP
// DEF(cap);
//   TOKEN("capability", TK_ISO, TK_TRN, TK_REF, TK_VAL, TK_BOX, TK_TAG);
//   DONE();

  // DEF(cap)
  fun cap(parser: Parser[Id], 
          // builder_fn_t *out_builder,
          rule_desc: String): Ast =>
//    (void)out_builder; \
    let state: RuleState[Id] = RuleState[Id]("cap", rule_desc, TKLEXERROR)

    //   TOKEN("capability", TK_ISO, TK_TRN, TK_REF, TK_VAL, TK_BOX, TK_TAG);
    let id_set: Array[Id] = [as Id: TKISO, TKTRN, TKREF, TKVAL, TKBOX, TKTAG]

    (let r: Ast, let found: Bool) = parser.parse_token_set(state, 
                                                          "capability", 
                                                          None, 
                                                          id_set, 
                                                          true)

    if (not (r is PARSEOK)) then return r end

    // DONE()
    parser.rule_complete(state)


// DEF(array);
//   PRINT_INLINE();
//   AST_NODE(TK_ARRAY);
//   SKIP(NULL, TK_LSQUARE, TK_LSQUARE_NEW);
//   OPT RULE("element type", arraytype);
//   RULE("array element", rawseq);
//   WHILE(TK_COMMA, RULE("array element", rawseq));
//   TERMINATE("array literal", TK_RSQUARE);
//   DONE();

  // DEF(array);
  fun array(parser: Parser[Id],
            rule_desc: String): Ast =>
    let state: RuleState[Id] = RuleState[Id]("array", rule_desc, TKLEXERROR)

//   PRINT_INLINE();
//   AST_NODE(TK_ARRAY);
//   SKIP(NULL, TK_LSQUARE, TK_LSQUARE_NEW);
    let id_set: Array[Id] = [as Id: TKLSQUARE, TKLSQUARENEW]

    (let r: Ast, let found: Bool) = parser.parse_token_set(state, 
                                                           None, 
                                                           None, 
                                                           id_set, 
                                                           false)
    
    if (not (r is PARSEOK)) then return r end


//   OPT RULE("element type", arraytype);
//   RULE("array element", rawseq);
    let rule_set = [as { (Parser[Id], String): Ast } box: this~cap()]

    (let rr: Ast, let ff: Bool) = parser.parse_rule_set(state,
                                                        "array element", 
                                                        rule_set)

    if (not (rr is PARSEOK)) then return r end


//   WHILE(TK_COMMA, RULE("array element", rawseq));
//   TERMINATE("array literal", TK_RSQUARE);

//   DONE();
    parser.rule_complete(state)


/// State of parsing current rule
// typedef struct rule_state_t
// {
//   const char* fn_name;  // Name of the current function, for tracing
//   ast_t* ast;           // AST built for this rule
//   ast_t* last_child;    // Last child added to current ast
//   const char* desc;     // Rule description (set by parent)
//   token_id* restart;    // Restart token set, NULL for none
//   token_id deflt_id;    // ID of node to create when an optional token or rule
//                         // is not found.
//                         // TK_EOF = do not create a default
//                         // TL_LEX_ERROR = rule is not optional
//   bool matched;         // Has the rule matched yet
//   bool scope;           // Is this rule a scope
//   bool deferred;        // Do we have a deferred AST node
//   token_id deferred_id; // ID of deferred AST node
//   size_t line, pos;     // Location to claim deferred node is from
// } rule_state_t;

//     rule_state_t state = {#rule, NULL, NULL, rule_desc, NULL, TK_LEX_ERROR, \
//       false, false, false, TK_NONE, 0, 0}

