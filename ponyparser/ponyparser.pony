use "../rdparser"


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

