trait val Tk is Equatable[Tk]
  fun show(): String ?


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


actor Trace
  let _out: StdStream
  new create(out: StdStream) => _out = out
  be log(s: String) => _out.print(s)



class Parser[I: Tk val, T: Token[I] val]
  let _lexer: Lexer[I, T]
  let _eof: I
  let lexerror: I
  let _trace: Trace tag

  var _token: T
  var _last_token_line: U32 = 0
  var _last_matched: String = ""

  new create(lexer: Lexer[I, T], eof: I, lexerror': I
    , trace: Trace tag
    ) =>
    _lexer = lexer
    _eof = eof
    lexerror = lexerror'
    _trace = trace

    _token = lexer.next()


  fun ref next_lexer_token() =>
    let newt: T = _lexer.next() 
    let oldt: T = _token
    
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
                         rule_set: Array[ { (Parser[I, T], String): Ast } box ]): ParseResult => 
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

