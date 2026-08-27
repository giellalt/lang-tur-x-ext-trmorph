#!/bin/bash

# For debugging, uncomment this command:
# set -x

srcdir=$1

trmorphdir="$srcdir/src/fst/morphology/ext-TRmorph"

# analyzer.lexc composes the whole lexicon via cpp #include (see its own
# Makefile), and uses #if (OPTION == 1) blocks controlled by options.h, so we
# preprocess it the same way the real build does, to get the exact set of
# lexc entries that end up in the compiled analyzer. If options.h hasn't
# been generated yet (it's gitignored, only options.h-default is checked
# in), point cpp at a copy of the default instead, without touching the
# subtree's working directory.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
if [ ! -e "$trmorphdir/options.h" ]; then
    cp "$trmorphdir/options.h-default" "$tmpdir/options.h"
fi

preprocessed=$(cd "$trmorphdir" && gcc -E -traditional -P -w -x c -I "$tmpdir" analyzer.lexc)

# Count only genuine lexical entries (real words/stems/symbols), excluding
# everything else lexc syntax allows on a ";"-terminated line:
#   - comments (!), flag-diacritic/rule-sigil prefixed lines (@...), raw
#     xfst regexes (<...>), and lines starting with +
#   - TRmorph's own escaped morphological tags, %<TAG...%>, e.g. %<N%>,
#     %<Adj%:mredup%> -- these mark grammar/suffix machinery, not lemmas.
#     A bare escaped "<" used as a literal symbol lemma (%<  Sym;) is kept,
#     since %< is only excluded when immediately followed by more content.
#   - epsilon/null-morph entries, whose upper side is the literal "0"
#     (lexc's empty-string symbol), e.g. 0:@APOS@MB  NcompAposCont;
#   - LEXICON and Multichar_Symbols declaration headers
#   - bare continuation-lexicon references with no entry of their own
#     (just "SomeCont;", possibly with a trailing "! comment")
lemmacount=$(echo "$preprocessed" | \
    grep ";" | \
    sed -E 's/[[:space:]]!.*$//' | \
    grep -E -v "^[[:space:]]*(!|@|<|\+)" | \
    grep -E -v "^[[:space:]]*%<[^[:space:]]" | \
    grep -E -v "^[[:space:]]*0[:[:space:]]" | \
    grep -E -v "^[[:space:]]*(LEXICON|Multichar_Symbols)\b" | \
    grep -E -v "^[[:space:]]*[[:alnum:]_-]+[[:space:]]*;[[:space:]]*$" | \
    grep -E -v "^[[:space:]]*$" | \
    wc -l | tr -d '[:space:]')

echo $lemmacount
