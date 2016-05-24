actor Main
  new create(env: Env) =>
    let t: Token[Id] val = recover Token[Id](TKISO) end
    let l: Lexer[Id] = [t].values()
    let p: Parser = Parser(l)
    let g: Grammar = Grammar
    g.cap(p, "blerk")


// To do
// - genericise parser/lexer/token over id type
// - make test case parse work
// - add seq


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

primitive TKLEXERROR

primitive TKISO
primitive TKTRN
primitive TKREF
primitive TKVAL
primitive TKBOX
primitive TKTAG

primitive TKNONE
primitive TKEOF

type Id is (TKLEXERROR | TKISO | TKTRN | TKREF | TKVAL | TKBOX | TKTAG | TKNONE | TKEOF)


primitive PARSEOK
primitive PARSEFAIL

type Ast is (PARSEOK | PARSEFAIL)

type ParseResult is (Ast, Bool)


class RuleState
  let _rule_name: String
  let _rule_desc: String
  let _default_id: Id

  new create(rule_name: String,
            rule_desc: String,
            default_id: Id) =>
    _rule_name = rule_name
    _rule_desc = rule_desc
    _default_id = default_id


class val Token[I: Any val]
  let _id: I

  new create(myid: I) => _id = myid
  fun line_number(): U32 => 0
  fun id(): I => _id
  fun set_pos(other: Token[I]) => true


interface Lexer[I: Any val] is Iterator[Token[I]]


class Parser

  var _token: (Token[Id] | None) = None
  var _last_token_line: U32 = 0

  let _lexer: Lexer[Id]


  new create(lexer: Lexer[Id]) =>
    _lexer = lexer

  fun current_token_id(): (Id | None) => 
    try
      (_token as Token[Id]).id()
    else
      None
    end

  fun propogate_error(state: RuleState): ParseResult => (PARSEFAIL, false)


  fun ref next_lexer_token() =>
    // FIXME make iterator type for which next doesn't fail
    let newt: Token[Id] = try 
      _lexer.next() 
    else 
      recover Token[Id](TKEOF) end 
    end  


    match _token
    | let oldt: Token[Id] => 
        _last_token_line = oldt.line_number()
        if newt.id() is TKEOF then
          newt.set_pos(oldt)
        end
    end

    _token = newt


  fun parse_token_set(state: RuleState,
                      desc: String,
                      terminating: (String | None),
                      id_set: Array[Id],
                      make_ast: Bool): ParseResult => 

// ast_t* parse_token_set(parser_t* parser, rule_state_t* state, const char* desc,
//   const char* terminating, const token_id* id_set, bool make_ast,
//   bool* out_found)
// {
  // assert(parser != NULL);
  // assert(state != NULL);
  // assert(id_set != NULL);

    let id: Id = try 
      current_token_id() as Id
    else 
      return (PARSEFAIL, false)  // Shouldn't happen
    end


    if id is TKLEXERROR then return propogate_error(state) end

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

  // for(const token_id* p = id_set; *p != TK_NONE; p++)
  // {
    for p in id_set.values() do
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

      if p is id then
//       // Current token matches one in set
//       if(trace_enable)
//         fprintf(stderr, "Compatible\n");

//       parser->last_matched = token_print(parser->token);
        return if make_ast then
          handle_found(state, consume_token())
        else
          consume_token_no_ast()
          handle_found(state, PARSEFAIL)  // FIXME NULL
//       if(make_ast)
//         return handle_found(parser, state, consume_token(parser),
//           default_builder, out_found);

//       // AST not needed, discard token
//       consume_token_no_ast(parser);
//       return handle_found(parser, state, NULL, NULL, out_found);
        end
      end
    end


//   // Current token does not match any in current set
//   if(trace_enable)
//     fprintf(stderr, "Not compatible\n");

    handle_not_found(state, desc, terminating)
// }
  
  fun handle_found(state: RuleState, blerk: Ast): ParseResult => 
    (PARSEOK, true)

  fun handle_not_found(state: RuleState, 
                       desc: String, 
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

  fun consume_token_no_ast(): Ast => PARSEOK
// static void consume_token_no_ast(parser_t* parser)
// {
//   fetch_next_lexer_token(parser, true);
// }

  fun rule_complete(state: RuleState): Ast => PARSEOK

class Grammar

// CAP
// DEF(cap);
//   TOKEN("capability", TK_ISO, TK_TRN, TK_REF, TK_VAL, TK_BOX, TK_TAG);
//   DONE();

  // DEF(cap)
  fun cap(parser: Parser, 
          // builder_fn_t *out_builder,
          rule_desc: String): Ast =>
//    (void)out_builder; \
    let state: RuleState = RuleState("cap", rule_desc, TKLEXERROR)

    let id_set: Array[Id] = [as Id: TKISO, TKTRN, TKREF, TKVAL, TKBOX, TKTAG, TKNONE]

    (let r: Ast, let found: Bool) = parser.parse_token_set(state, 
                                                          "capability", 
                                                          None, 
                                                          id_set, 
                                                          true)
    match r
    | PARSEOK => PARSEOK
    else
      return r
    end

    // DONE()
    parser.rule_complete(state)

