=begin
Converts grammar rules in the format used by ponyc's parser.c into Pony functions
that parse the grammar.

Of course really the parsing here should be done by an instance of rdparser itself,
but it's not quite there yet. This is for bootstrapping...
=end

DEF = """
  fun RULE_NAME(parser: Parser[Id], 
                rule_desc: String): Ast =>
    let state: RuleState[Id] = RuleState[Id](\"RULE_NAME\", rule_desc, parser.lexerror)
"""

def def_macro(rule_name)
	puts DEF.gsub(/RULE_NAME/, rule_name)
end

def done_macro()
	puts """
    parser.rule_complete(state)
"""
end

TOKEN = """
    let id_setINDEX: Array[Id] = [as Id: TOKENS]

    (let rINDEX: Ast, let foundINDEX: Bool) = 
        parser.parse_token_set(state, 
                               \"RULE_DESC\",
                               \"TOKEN\",
                               None, 
                               id_setINDEX, 
                               true)
    if (not (rINDEX is PARSEOK)) then return rINDEX end
"""

def token_macro(index, desc, tokens)
	tokens = tokens.strip.split(/\s*,\s*/)
	tokens = tokens.map do |tok|
		tokbits = tok.split(/_/).map(&:capitalize).join("")
	end.join(", ")
	puts TOKEN.gsub(/TOKENS/, tokens)
	          .gsub(/RULE_DESC/, desc)
	          .gsub(/INDEX/, index.to_s)
end


fname = ARGV[0]
puts fname

lines = File.readlines(fname)

index = 0  # used to uniquify var names in a single Pony function
lines.each do |line|

	index += 1

	case line
	#when %r{^\w*//}  # comment, ignore
	when %r{^ \s* DEF \( (.*?) \) }x
		index = 0
		rule_name = Regexp::last_match[1]
		def_macro(rule_name)
	when %r{^ \s* TOKEN \( " (.*?) " , (.*?) \) }x
		desc = Regexp::last_match[1]
		tokens = Regexp::last_match[2]
		token_macro(index, desc, tokens)
	when %r{^ \s* DONE }x
		done_macro()
	end
end