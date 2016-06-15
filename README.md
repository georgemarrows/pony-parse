# Pony Parse

Tools for parsing Pony source code, all written in Pony. Only baby steps so far!

Possible uses:
* Syntax error highlighter for Pony editing
* Pony source formatter
* Feed into @jemc's ponycc Pony-in-Pony compiler
* Could potentially be wired into the standard `ponyc` compiler as first step in transmogrifying that from C to Pony.


##  Overview

* `rdparser` is a translation of the recursive-descent parser framework in parserapi.c in the Pony source tree. It is generic over the type of the tokens it can parse. When AST building is added, the aim is to be generic over the type of AST too. The input for rdparser is a text file that uses the parserapi.h macros. The canonical example of this is parser.c in the Pony source, but it's potentially reusable for other purposes. Because there's nothing like C macros in Pony, a Ruby script will convert the input file into Pony source that implements the parser.

* `ponyparser` is an application of `rdparser` to parsing the Pony language. The lexing portion has yet to be written; the parsing portion will be created from Pony's parser.c

* `ponyparser/test` is the only application of any of this so far.


## To run

* `cd ponyparser/test`
* `ponyc && test`

Use `test --sequential` to avoid tracing output from different tests getting mixed together.


## Short-term roadmap

* Ruby script to generate Pony source from parser.c; switch ponyparser to use it
* make AST and genericise over AST type
* rename Tk in rdparser
* Add support for more parsing macros from parserapi.h

