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

DONE = """
    parser.rule_complete(state)

"""

TOKEN = """
    let id_setINDEX: Array[Id] = [as Id: TOKENS]

    (let rINDEX: Ast, let foundINDEX: Bool) = 
        parser.parse_token_set(state, 
                               RULE_DESC,
                               \"TOKEN\",
                               None, 
                               id_setINDEX, 
                               true)
    if (not (rINDEX is PARSEOK)) then return rINDEX end
"""

SKIP = """
    let id_setINDEX: Array[Id] = [as Id: TOKENS]

    (let rINDEX: Ast, let foundINDEX: Bool) = 
        parser.parse_token_set(state, 
                               RULE_DESC,
                               \"SKIP\",
                               None, 
                               id_setINDEX, 
                               false)
    if (not (rINDEX is PARSEOK)) then return rINDEX end
"""

RULE = """
    let rule_setINDEX = [as { (Parser[Id], String): Ast } box: RULES]

    (let rINDEX: Ast, let foundINDEX: Bool) = 
        parser.parse_rule_set(state,
                              RULE_DESC,
                              \"RULE\",
                              rule_setINDEX)

    if (not (rINDEX is PARSEOK)) then return rINDEX end
"""


def nullToNone(s)
	if s == "NULL"
		"None"
	else
		s
	end
end

def special_map_token_part(part)
	case part
	when "Lsquare"
		"LSquare"
	when "Rsquare"
		"RSquare"
	else
		part
	end
end

def convert_token_string(tokens)
	tokens = tokens.strip.split(/\s*,\s*/)
	tokens.map do |tok|
		tok.split(/_/)
		   .map(&:capitalize)
		   .map do |part| special_map_token_part(part) end
		   .join("")
	end.join(", ")
end

def convert_rule_string(rules)
	rules.strip
	     .split(/\s*,\s*/)
	     .map {|r| "this~#{r}()"}
	     .join(",")
end

def macro_convert(index, template, mappings = {})
	template = template.gsub(/INDEX/, index.to_s)
	mappings.each do |name, value|
		template = template.gsub(name.to_s, value)
	end
	template
end

def convert_line(index, line)
	print "\n    // #{line.strip}"

	case line
	#when %r{^\w*//}  # comment, ignore
	when %r{^ \s* DEF \( (.*?) \) }x
		index = 0
		puts macro_convert(index, DEF, 
			               :RULE_NAME => $~[1])
	when %r{^ \s* DONE }x
		puts macro_convert(index, DONE)
	when %r{^ \s* TOKEN \( (.*?) , (.*?) \) }x
		puts macro_convert(index, TOKEN,
			               :RULE_DESC => nullToNone($~[1]),
			               :TOKENS => convert_token_string($~[2]))
	when %r{^ \s* SKIP \( (.*?) , (.*?) \) }x
		puts macro_convert(index, SKIP,
			               :RULE_DESC => nullToNone($~[1]),
			               :TOKENS => convert_token_string($~[2]))
	when %r{^ \s* RULE \( (.*?) , (.*?) \) }x
		puts macro_convert(index, RULE,
			               :RULE_DESC => nullToNone($~[1]),
			               :RULES => convert_rule_string($~[2])
			              )
	end

	index
end




fname = ARGV[0]

lines = File.readlines(fname)

index = 0  # used to uniquify var names in a single Pony function
lines.each do |line|
	index += 1
	index = convert_line(index, line)
end




