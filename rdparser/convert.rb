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


def token_macro(index, desc, tokens)
	puts TOKEN.gsub(/TOKENS/, convert_token_string(tokens))
	          .gsub(/RULE_DESC/, nullToNone(desc))
	          .gsub(/INDEX/, index.to_s)
end


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

def nullToNone(s)
	if s == "NULL"
		"None"
	else
		s
	end
end


def skip_macro(index, desc, tokens)
	puts SKIP.gsub(/TOKENS/, convert_token_string(tokens))
	         .gsub(/RULE_DESC/, nullToNone(desc))
	         .gsub(/INDEX/, index.to_s)
end

RULE = """
     let rule_setINDEX = [as { (Parser[Id], String): Ast } box: RULES]

     (let rINDEX: Ast, let foundINDEX: Bool) = 
         parser.parse_rule_set(state,
                               RULE_DESC,
                               \"RULE\",
                               rule_setINDEX)

     if (not (rINDEX is PARSEOK)) then return rINDEX end
"""

def rule_macro(index, desc, rules)
	rules = rules.strip.split(/\s*,\s*/)

	puts RULE.gsub(/RULES/, rules.map {|r| "this~#{r}()"}.join(","))
	         .gsub(/RULE_DESC/, nullToNone(desc))
	         .gsub(/INDEX/, index.to_s)
end

def comment(line)
	print "\n    // #{line.strip}"
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
		comment(line)
		index = 0
		rule_name = Regexp::last_match[1]
		def_macro(rule_name)
	when %r{^ \s* DONE }x
		comment(line)
		done_macro()
	when %r{^ \s* TOKEN \( (.*?) , (.*?) \) }x
		comment(line)
		desc = Regexp::last_match[1]
		tokens = Regexp::last_match[2]
		token_macro(index, desc, tokens)
	when %r{^ \s* SKIP \( (.*?) , (.*?) \) }x
		comment(line)
		desc = Regexp::last_match[1]
		tokens = Regexp::last_match[2]
		skip_macro(index, desc, tokens)
	when %r{^ \s* RULE \( (.*?) , (.*?) \) }x
		comment(line)
		desc = Regexp::last_match[1]
		rules = Regexp::last_match[2]
		rule_macro(index, desc, rules)
	end
end