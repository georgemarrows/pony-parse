use "ponytest"
use "collections"


// To do
// DONE genericise parser/lexer/token over id type
// DONE make test case parse work
// DONE use pony testing framework
// DONE tracing
// DONE full parse array
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


class iso _TestParseCap is UnitTest
  """
  XXX
  """
  fun name(): String => "Pony/parse.cap"

  fun apply(h: TestHelper) =>
    test(h, PARSEOK,   [Token[Id](TkIso)])
    test(h, PARSEERROR, [Token[Id](TkLexError)])


  fun test(h: TestHelper, result: Ast, ids: Array[Token[Id]]) =>
    let trace = Trace(h.env.out)
    trace.log("-----------")
    let l: Lexer[Id] = IterToLexer(ids.values())
    let p: Parser[Id] = Parser[Id](l, TkEof, TkLexError, trace)
    let g: Grammar = Grammar
    h.assert_is[Ast](result, g.cap(p, "blerk"))


class iso _TestParseArray is UnitTest
  """
  XXX
  """
  fun name(): String => "Pony/parse.array"

  fun apply(h: TestHelper) =>
    test(h, PARSEOK,    [as Id: TkLSquare, TkIso, TkComma, TkRef, TkRSquare])
    
    test(h, RULENOTFOUND, [as Id: TkIso])

    test(h, PARSEERROR, [as Id: TkLSquare, TkEof])
    test(h, PARSEERROR, [as Id: TkLSquare, TkLSquare])
    test(h, PARSEERROR, [as Id: TkLSquare, TkComma])
    test(h, PARSEERROR, [as Id: TkLSquare, TkComma, TkComma]) 
    test(h, PARSEERROR, [as Id: TkLSquare, TkIso, TkIso])


  fun test(h: TestHelper, expected: Ast, ids: Array[Id]) =>
    let toks = Array[Token[Id]](ids.size())
    for id in ids.values() do
      toks.push(Token[Id](id))
    end
    let trace = Trace(h.env.out)
    trace.log("-----------")
    let l: Lexer[Id] = IterToLexer(toks.values())
    let p: Parser[Id] = Parser[Id](l, TkEof, TkLexError, trace)
    let g: Grammar = Grammar
    let actual = g.array(p, "blerk")
    h.assert_is[Ast](expected, actual, 
                     "Expected " + expected.string() + 
                     " actual " + actual.string())



class IterToLexer is Lexer[Id]
  let _iter: Iterator[Token[Id]]

  new create(iter: Iterator[Token[Id]]) =>
    _iter = iter

  fun ref next(): Token[Id] => 
    try _iter.next() else Token[Id](TkEof) end





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


primitive PARSEOK is Stringable
  fun string(fmt: FormatSettings = FormatSettingsDefault): String iso^
  =>
    "PARSEOK".string(fmt)

primitive PARSEERROR is Stringable
  fun string(fmt: FormatSettings = FormatSettingsDefault): String iso^
  =>
    "PARSEERROR".string(fmt)

primitive RULENOTFOUND is Stringable
  fun string(fmt: FormatSettings = FormatSettingsDefault): String iso^
  =>
    "RULENOTFOUND".string(fmt)


type Ast is (PARSEOK | PARSEERROR | RULENOTFOUND)

type ParseResult is (Ast, Bool)


class RuleState[I: Any val]
  let rule_name: String
  let _rule_desc: String
  var default_id: I
  var matched: Bool

  new create(rule_name': String,
            rule_desc: String,
            default_id': I) =>
    rule_name = rule_name'
    _rule_desc = rule_desc
    default_id = default_id'
    matched = false


class val Token[I: Any val]
  let _id: I

  new val create(myid: I) => _id = myid
  fun line_number(): U32 => 0
  fun id(): I => _id
  fun set_pos(other: Token[I]) => true


interface Lexer[I: Any val]
  fun ref next(): Token[I]


actor Trace
  let _out: StdStream
  new create(out: StdStream) => _out = out
  be log(s: String) => _out.print(s)


class Parser[I: Tk val]
  let _lexer: Lexer[I]
  let _eof: I
  let lexerror: I
  let _trace: Trace tag

  var _token: Token[I]
  var _last_token_line: U32 = 0
  var _last_matched: String = ""

  new create(lexer: Lexer[I], eof: I, lexerror': I
    , trace: Trace tag
    ) =>
    _lexer = lexer
    _eof = eof
    lexerror = lexerror'
    _trace = trace

    _token = lexer.next()


  fun ref next_lexer_token() =>
    let newt: Token[I] = _lexer.next() 
    let oldt: Token[I] = _token
    
    _last_token_line = oldt.line_number()
    if newt.id().eq(_eof) then
      newt.set_pos(oldt)
    end

    _token = newt

// ast_t* parse_token_set(parser_t* parser, rule_state_t* state, const char* desc,
//   const char* terminating, const token_id* id_set, bool make_ast,
//   bool* out_found)
// {
//   assert(parser != NULL);
//   assert(state != NULL);
//   assert(id_set != NULL);

//   token_id id = current_token_id(parser);

//   if(id == TK_LEX_ERROR)
//     return propogate_error(parser, state);

//   if(desc == NULL)
//     desc = token_id_desc(id_set[0]);

//   if(trace_enable)
//   {
//     fprintf(stderr, "Rule %s: Looking for %s token%s %s. Found %s. ",
//       state->fn_name,
//       (state->deflt_id == TK_LEX_ERROR) ? "required" : "optional",
//       (id_set[1] == TK_NONE) ? "" : "s", desc,
//       token_print(parser->token));
//   }

//   for(const token_id* p = id_set; *p != TK_NONE; p++)
//   {
//     // Match new line if the next token is the first on a line
//     if(*p == TK_NEWLINE)
//     {
//       assert(parser->token != NULL);
//       size_t last_token_line = parser->last_token_line;
//       size_t next_token_line = token_line_number(parser->token);
//       bool is_newline = (next_token_line != last_token_line);

//       if(out_found != NULL)
//         *out_found = is_newline;

//       if(trace_enable)
//         fprintf(stderr, "\\n %smatched\n", is_newline ? "" : "not ");

//       state->deflt_id = TK_LEX_ERROR;
//       return PARSE_OK;
//     }

//     if(id == *p)
//     {
//       // Current token matches one in set
//       if(trace_enable)
//         fprintf(stderr, "Compatible\n");

//       parser->last_matched = token_print(parser->token);

//       if(make_ast)
//         return handle_found(parser, state, consume_token(parser),
//           default_builder, out_found);

//       // AST not needed, discard token
//       consume_token_no_ast(parser);
//       return handle_found(parser, state, NULL, NULL, out_found);
//     }
//   }

//   // Current token does not match any in current set
//   if(trace_enable)
//     fprintf(stderr, "Not compatible\n");

//   return handle_not_found(parser, state, desc, terminating, out_found);
// }



  fun ref parse_token_set(state: RuleState[I],
                      desc: (String | None),
                      cmd_name: String,
                      terminating: (String | None),
                      id_set: Array[I],
                      make_ast: Bool): ParseResult => 

    let id: I = current_token_id()

    if id.eq(lexerror) then return propogate_error(state) end

    // FIXME optional vs required in logging
    _trace.log("Rule " + state.rule_name + 
                 " " + cmd_name + " looking for tokens '" +
                 try desc as String else "" end + 
                 "'. Found " +
                 try id.show() else "XXX" end)

    for p in id_set.values() do

      if p.eq(id) then
        _trace.log("  Compatible")
        return if make_ast then
          handle_found(state, consume_token())
        else
          consume_token_no_ast()
          handle_found(state, PARSEERROR)  // FIXME NULL
        end
      end
    end

    let ret = handle_not_found(state, desc, terminating)
    _trace.log("  Not compatible " + ret._1.string())
    ret

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
                         cmd_name: String,
                         rule_set: Array[ { (Parser[I], String): Ast } box ]): ParseResult => 
    let id: I = current_token_id()

    if id.eq(lexerror) then return propogate_error(state) end
    
    let rule = "Rule " + state.rule_name + " " + cmd_name

    // FIXME optional vs required rules
    _trace.log(rule + " looking for rule '" + desc + "'")

    for r in rule_set.values() do
      let ast: Ast = r(this, desc)
      if (ast is PARSEERROR) then 
        let ret = propogate_error(state) 
        _trace.log(rule + " returning " + ret._1.string())
        return ret
      end
      
      if (not (ast is RULENOTFOUND)) then
        _last_matched = desc
        _trace.log(rule + "  matched")
        return handle_found(state, PARSEERROR)
      end
    end

    _trace.log(rule + " not matched")
    handle_not_found(state, desc, None)



  fun current_token_id(): I => _token.id()

  fun propogate_error(state: RuleState[I]): ParseResult => (PARSEERROR, false)


  fun handle_found(state: RuleState[I], blerk: Ast): ParseResult => 
    if not state.matched then
      _trace.log("Rule " + state.rule_name + ": Matched")
      state.matched = true
    end
    (PARSEOK, true)


  fun handle_not_found(state: RuleState[I], 
                       desc:  (String | None), 
                       terminating: (String | None)): ParseResult =>

    if not state.default_id.eq(lexerror) then
      // FIXME deferrable_ast
      state.default_id = lexerror
      return (PARSEOK, false)
    end

    if not state.matched then
      _trace.log("Rule " + state.rule_name + ": Not matched")
      return (RULENOTFOUND, false)
    end

    // if state.restart is None then
    //   return (PARSE_ERROR, false)
    // end

    (PARSEERROR, false)


  fun ref consume_token(): Ast => 
    next_lexer_token()
    PARSEOK

  fun ref consume_token_no_ast() => next_lexer_token()


  fun rule_complete(state: RuleState[I]): Ast => PARSEOK



primitive Grammar

// DEF(cap);
//   TOKEN("capability", TK_ISO, TK_TRN, TK_REF, TK_VAL, TK_BOX, TK_TAG);
//   DONE();

  // DEF(cap)
  fun cap(parser: Parser[Id], 
          // builder_fn_t *out_builder,
          rule_desc: String): Ast =>
    let state: RuleState[Id] = RuleState[Id]("cap", rule_desc, parser.lexerror)

    //   TOKEN("capability", TK_ISO, TK_TRN, TK_REF, TK_VAL, TK_BOX, TK_TAG);
    let id_set: Array[Id] = [as Id: TkIso, TkTrn, TkRef, TkVal, TkBox, TkTag]

    (let r: Ast, let found: Bool) = parser.parse_token_set(state, 
                                                          "capability",
                                                          "TOKEN",
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
    let state: RuleState[Id] = RuleState[Id]("array", rule_desc, 
                                             parser.lexerror)

//   PRINT_INLINE();
//   AST_NODE(TK_ARRAY);
//   SKIP(NULL, TK_LSQUARE, TK_LSQUARE_NEW);
    let id_set: Array[Id] = [as Id: TkLSquare, TkLSquareNew]

    (let r: Ast, let found: Bool) = parser.parse_token_set(state, 
                                                           "square bracket",
                                                           "SKIP",
                                                           None, 
                                                           id_set, 
                                                           false)
    
    if (not (r is PARSEOK)) then return r end


//   OPT RULE("element type", arraytype);
//   RULE("array element", rawseq);
    let rule_set = [as { (Parser[Id], String): Ast } box: this~cap()]

    (let rr: Ast, let ff: Bool) = parser.parse_rule_set(state,
                                                        "array element",
                                                        "RULE",
                                                        rule_set)

    if (not (rr is PARSEOK)) then return rr end


//   WHILE(TK_COMMA, RULE("array element", rawseq));
    let id_set2 = [as Id: TkComma]
    while true do
      state.default_id = TkEof // FIXME parser.eof
      (let r3: Ast, let f3: Bool) = parser.parse_token_set(state,
                                                           TkComma.show(),
                                                           "WHILE",
                                                           None,
                                                           id_set2,
                                                           false)
      if not (r3 is PARSEOK) then return r3 end
      if not f3 then break end

      let rule_set2 = [as { (Parser[Id], String): Ast } box: this~cap()]

      (let r4: Ast, let f4: Bool) = parser.parse_rule_set(state,
                                                        "array element",
                                                        "RULE",
                                                        rule_set2)

       if not (r4 is PARSEOK) then return r4 end
    end


//   TERMINATE("array literal", TK_RSQUARE);
    let id_set5: Array[Id] = [as Id: TkRSquare]

    (let r5: Ast, let f5: Bool) = parser.parse_token_set(state, 
                                                         None,
                                                         "TERMINATE",
                                                         "array literal", 
                                                         id_set5, 
                                                         false)
    
    if not (r5 is PARSEOK) then return r5 end

//   DONE();
    parser.rule_complete(state)

