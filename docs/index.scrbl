#lang scribble/manual

@; DOCS ARE COMPILED LIKE THIS:
@; DOCSFOR=TARUEN make docs
@;                      or
@; DOCSFOR=APERTIUM make docs
@;
@; TOOD this has to be done by Github actions automatically, depending on
@; whether it is a fork or upstream.
@; Alternative: provide base url on the command line.

@require[scribble/core
         scribble/html-properties
         scriblib/footnote]

@(define strikethrough
  (make-style "strikethrough"
    (list (make-css-addition "strikethrough.css"))))

@(define (sout . words)
   (elem #:style strikethrough words))

@title[#:version "0.1.0"]{@tt{Apertium-kaz}: a Morphological Transducer and
Disambiguator for Kazakh}

What follows is the documentation for @(when (equal? (getenv "DOCSFOR") "TARUEN")
@hyperlink["https://github.com/taruen/apertium-kaz"]{Taruen's fork of})
@hyperlink["https://github.com/apertium/apertium-kaz"]{@tt{apertium-kaz}} -- a
morphological transducer and disambiguator for Kazakh. First draft of this
documentation was written, or, rather, assembled from various writings on
@hyperlink["https://wiki.apertium.org"]{Apertium's wiki} and then extended with
more details by @hyperlink["http://github.com/IlnarSelimcan"]{IFS} on
September-October 2018 for members of the `Deep Learning for Sequential Models
in Natural Language Processing with Applications to Kazakh'
(@italic{dlsmnlpak}) research group at Nazarbayev University and
elsewhere. That being said, I hope that it will be useful for anyone who uses
@code{apertium-kaz} and maybe wants or needs to extend it with more stems or
other features. Most of the things said in this guide should be applicable to
Apertium's transducers/disambiguators for other Turkic languages as well.

@tt{Apertium-kaz} is a morphological transducer and disambiguator for Kazakh,
currently under development. It is intended to be compatible with transducers
for other Turkic languages so that they can be translated between. It's used in
the following translators (at various stages of development):

@itemize[

@item{@hyperlink["https://github.com/apertium/apertium-kaz-tat"]{Kazakh and
Tatar}}

@item{@hyperlink["https://github.com/apertium/apertium-eng-kaz"]{English and
  Kazakh}}

@item{@hyperlink["https://github.com/apertium/apertium-kaz-rus"]{Kazakh and
  Russian}}

@item{@hyperlink["https://github.com/apertium/apertium-kaz-kir"]{Kazakh and
Kyrgyz}}

@item{@hyperlink["https://github.com/apertium/apertium-kaz-kaa"]{Kazakh and
  Karakalpak}}

@item{@hyperlink["https://github.com/apertium/apertium-khk-kaz"]{Khalkha and
  Kazakh}}

@item{@hyperlink["https://github.com/apertium/apertium-kaz-kum"]{Kazakh and
Kumyk}}

@item{@hyperlink["https://github.com/apertium/apertium-kaz-tur"]{Kazakh and
Turkish}}

@item{@hyperlink["https://github.com/apertium/apertium-kaz-tyv"]{Kazakh and
Tuvan}}

@item{@hyperlink["https://github.com/apertium/apertium-nog-kaz"]{Nogai and
Kazakh}}

@item{@hyperlink["https://github.com/apertium/apertium-kaz-sah"]{Kazakh and
Sakha}}

@item{@hyperlink["https://github.com/apertium/apertium-fin-kaz"]{Finnish and
  Kazakh}}

@item{@hyperlink["https://github.com/apertium/apertium-kaz-uig"]{Kazakh and
Uyghur}}

]

Its source code is available on
@hyperlink[(if (equal? (getenv "DOCSFOR") "TARUEN")
               "https://github.com/taruen/apertium-kaz/"
               "https://github.com/apertium/apertium-kaz/")]{Github}.
The code is
published under @hyperlink["https://www.gnu.org/licenses/gpl-3.0.html"]{GNU
General Public License} (version 3). Some of the annotated data such as the
Universal Dependencies treebank is made available under the
@hyperlink["https://creativecommons.org/licenses/by-sa/4.0/"]{Creative Commons
Attribution-Share Alike 4.0 International} license.

@section{Installation}

For detailed instructions on installing Apertium Core (language-independent
engine) and language data for it, see the
@hyperlink["https://wiki.apertium.org/wiki/Installation"]{Installation} page on
Apertium's wiki.

To give you an example, assuming that you are using a Debian-based GNU/Linux
distribution (note that you can use any other distro and still get pre-compiled
binary packages), you should run the following:

@verbatim{
wget https://apertium.projectjj.com/apt/install-nightly.sh -O - | sudo bash
sudo apt-get -f install apertium-all-dev
}

See the aforementioned page for details.

Once @tt{Apertium Core} is installed, you should clone @tt{apertium-kaz} running

@verbatim{git clone @(if (equal? (getenv "DOCSFOR") "TARUEN")
"https://github.com/taruen/apertium-kaz.git"
"https://github.com/apertium/apertium-kaz.git")}

and then compile it running

@verbatim{
cd apertium-kaz
./autogen.sh
make}

Some of the experiments described in this documentation require you to catch an
extended lexicon for @tt{apertium-kaz} and an accompanying makefile from
@hyperlink["https://taruen.com/apertiumpp/apertiumpp-kaz/"]{@tt{apertium@bold{pp}-kaz}}. Concretely,
you need to fetch @tt{apertium-kaz.kaz.lexc} and @tt{Makefile.am} files from
@tt{apertium@bold{pp}-kaz}, overwrite @tt{apertium-kaz}'s
@tt{apertium-kaz.kaz.lexc} and @tt{Makefile.am} with them, and then recompile
it by running

@verbatim{
./autogen.sh
make}


@section{Usage. Modes}

Assuming that you are in the directory @tt{apertium-kaz}, this is how it's
used:

@verbatim{
echo "Сәлем! Бұл бір мысал." | apertium -n -d . <mode>
}

or

@verbatim{
cat your-text-file.txt | apertium -n -d . <mode>
}

where @tt{mode} is one of the following: @tt{kaz-morph}, @tt{kaz-tagger} or
@tt{kaz-disam}.

Mode is nothing else than a shorthand name for a relatively long chain of
commands (a ``pipeline''), which is defined in the @tt{modes.xml} file (or in
the @tt{modes} directory, which appears once you compile @tt{apertium-kaz}). In
other words, you can see which commands with which options are run when you
pass a particular mode to the @tt{-d} opiton of @tt{apertium}. If you need
that, you can create your own pipelines, using the already defined modes as an
example.

If you're interesed in part-of-speech tagged text, then the @tt{kaz-tagger}
mode is probably what you need.

By default, @tt{apertium} adds a sentence terminator aka period to the end of
each line. The @tt{-n} option prevents that.

@tt{apertium} itself and the underlying commands that it makes use of (like
@tt{lt-proc}, @tt{lt-comp}, @tt{apertium-destxt} etc.) come with manual pages,
which you can read with the usual @tt{man} (or @tt{info}) command on the
terminal:

@verbatim{man apertium}

If you don't like providing the @tt{-d} option all the time, you can install
the compiled @tt{apertium-kaz} by running @tt{sudo make install}. Then you
should be able to simply run

@verbatim{
echo "Сәлем! Бұл бір мысал." | apertium -n <mode>
}

in any directory.

@section{Annotated data}

Note that the directory @hyperlink[(if (equal? (getenv "DOCSFOR") "TARUEN")
"https://github.com/taruen/apertium-kaz/tree/master/texts"
"https://github.com/apertium/apertium-kaz/tree/master/texts")]{@tt{apertium-kaz/texts/}}
contains morphologically disambiguated texts, some of which are syntactically
annotated in the @hyperlink["https://universaldependencies.org/"]{Universal
Dependencies} framework.

Annotation is done in the files ending in @tt{tagged.txt} or simply @tt{.txt}.

In those text files, dependency labels are the tags starting with @"@" symbol,
e.g.:

@verbatim{"абонемент" n nom @"@"nmod:poss #1->2}

@tt{#1->2} means that the token number 2 is the head of the token number 1.

When annotating, working on text files directly is one option, but it makes
more sense to use a special tool such as
@hyperlink["http://wiki.apertium.org/wiki/UD_Annotatrix"]{UD Annotatrix}, where
you get to see the parse trees you're building/correcting.

@margin-note{`Puupankki' is Finnish for `treebank'.}

@(define puupankki-kaz-conllu
@hyperlink[(if (equal? (getenv "DOCSFOR") "TARUEN")
"https://github.com/taruen/apertium-kaz/blob/master/texts/puupankki/puupankki.kaz.conllu"
"https://github.com/apertium/apertium-kaz/blob/master/texts/puupankki/puupankki.kaz.conllu")]{@tt{apertium-kaz/texts/puupankki/puupankki.kaz.conllu}})

The file @puupankki-kaz-conllu initially was the result of automatic conversion
of the aforementioned @tt{*.tagged.txt} files (the ones which were
syntactically annotated, that is) into Universal Dependencies' CoNNL-U format.

However, since then
@hyperlink["https://github.com/apertium/apertium-kaz/pull/17"]{we have worked}
on the @tt{puupankki.kaz.conllu} file directly, so that the @tt{*.tagged.txt}
files and the @tt{.conllu} file have gone somewhat out of sync.

@bold{If you are interested in training a dependency parser for Kazakh,
@puupankki-kaz-conllu is what you should be looking for}. See a note in Section
4.1 for an example of how you can train a dependency parser on it.

@margin-note{It should be noted that
@hyperlink["https://github.com/apertium/apertium-kaz/pull/17"]{this
pull-request} is an ongoing effort to make sure that the treebank is fully
compatible with version 2 of the UD standard. The @tt{master} branch of
@url["https://github.com/taruen/apertium-kaz"] already contains the changes
``pullrequested''.}

``Currently the treebank is partially compatible with UD v2.0 standard, with
the choice of head direction in some constructions being one of the major
discrepancies. The standard requires coordination and some compounds
(e.g. names) to be left-headed, while the treebank developers believe that in
Kazakh (and other Turkic languages) such constructions should be right-headed
due to the placement of morphological locus, which is exclusive to the last
(rightmost) element of such constructions. So far this issue has been resolved
by an intermediate conversion step, where initially the annotation is performed
in a right-headed fashion, and at the time of release a special script flips
the heads of the constructions in question.'' (Tyers et al. 2017)

Thus, in @tt{.txt} files coordination and compounds might be right-headed,
whereas in the
@hyperlink["https://github.com/apertium/apertium-kaz/blob/master/texts/puupankki/puupankki.kaz.conllu"]{@tt{puupankki.kaz.conllu}}
they are left-headed.

More information about the Kazakh UD treebank and about the UD Annotatrix you
can find in the following papers.

  article{tyers2017assessment,
  title={An assessment of Universal Dependency annotation guidelines for Turkic languages},
  author={Tyers, Francis and Washington, Jonathan and {\c{C}}{\"o}ltekin, {\c{C}}a{\u{g}}r{\i} and Makazhanov, Aibek},
  year={2017},
  publisher={Tatarstan Academy of Sciences}
}

  inproceedings{tyers_tl2015,
  author = {Tyers, Francis M. and Washington, Jonathan N.},
  title = {Towards a Free/Open-source Universal-dependency Treebank for Kazakh},
  booktitle = {3rd International Conference on Turkic Languages Processing,
  (TurkLang 2015)},
  pages = {276--289},
  year = {2015},
}

  inproceedings{makazhan_tl2015,
  author = {Makazhanov, Aibek and
  Sultangazina, Aitolkyn and
  Makhambetov, Olzhas and
  Yessenbayev, Zhandos},
  title = {Syntactic Annotation of Kazakh: Following the Universal Dependencies Guidelines. A report},
  booktitle = {3rd International Conference on Turkic Languages Processing,
  (TurkLang 2015)},
  pages = {338--350},
  year = {2015},
}

  inproceedings{tyers2017ud,
  title={UD Annotatrix: An annotation tool for universal dependencies},
  author={Tyers, Francis and Sheyanova, Mariya and Washington, Jonathan},
  booktitle={Proceedings of the 16th International Workshop on Treebanks and Linguistic Theories},
  pages={10--17},
  year={2017}
}

@section{(In)frequently Asked Questions}

@subsection{How can I train a Universal Dependencies parser using the data
available in apertium-kaz/texts/puupankki/ ?}

The are several free/libre statistical dependency parsers available, exact
instructions naturally will depend on which one you decide to use.

If you use @hyperlink["https://ufal.mff.cuni.cz/udpipe"]{UDPipe}, training a
Kazakh tokenizer-tagger-parser with a default model can be achieved with the
following commands:

@verbatim{cat texts/puupankki/puupankki.kaz.conllu | udpipe --train kaz.udpipe}

which you then can use like this:

@verbatim{
echo "бұл бір мысал" | udpipe --tokenize --tag --parse kaz.udpipe
Loading UDPipe model: done.
# newdoc
# newpar
# sent_id = 1
# text = бұл бір місал
1       бұл     бұл     DET     det     PronType=Dem    3       det     _       _
2       бір     бір     NUM     num     NumType=Card    3       nummod  _       _
3       місал   місал   NOUN    n       Case=Nom        0       root    _       SpacesAfter=\n
}

If you are interesed in only parsing with @tt{udpipe} (i.e. input text is
already tokenised and tagged), you can do the following:

@verbatim{

cat <tagged.txt> | python3 ../ud-scripts/vislcg3-to-conllu-nodeps.py "<source>"
2> /dev/null | python3 ../ud-scripts/conllu-feats.py apertium-kaz.kaz.udx 2>
/dev/null | udpipe --parse kaz.udpipe > /tmp/out

}


More information on training UDPipe models can be found in
@hyperlink["https://wiki.apertium.org/wiki/UDPipe"]{this} article on Apertium's
wiki.

A minor question is whether features being in connlu format or not plays any
role (assuming that they are in the same format when training udpipe and when
using it, of course).

@section{A Constraint Grammar-based Universal Dependencies parser for Kazakh
(experimental)}

@subsection{How can I convert @tt{apertium-kaz}'s output into the
@hyperlink["https://universaldependencies.org/format.html"]{CoNLL-U} format of
the @hyperlink["https://universaldependencies.org/"]{Universal Dependencies}
project?}

@margin-note{TODO: this should be a apertium-kaz mode...}

While you are in the directory @tt{apertium-kaz}, run the following command:

@verbatim{
echo "Біздің елде сізге ерекше құрметпен қарайды." | apertium-destxt -n | \
apertium -f none -d . kaz-tagger | cg-conv -la | apertium-retxt | \
vislcg3 -g apertium-kaz.kaz.rlx | \
python3 ../ud-scripts/vislcg3-to-conllu.py "" 2> /dev/null | \
python3 ../ud-scripts/conllu-feats.py apertium-kaz.kaz.udx 2> /dev/null | \
python3 ../ud-scripts/conllu-nospaceafter.py 2> /dev/null
}

@bold{where @tt{vislcg3-to-conllu.py}, @tt{conllu-feats.py} and
@tt{conllu-nospaceafter.py} are scripts you can find
@hyperlink["https://github.com/taruen/ud-scripts"]{here}.}

And this is the output you should expect for the above command:

@verbatim{
# sent_id = :1:0
# text = Біздің елде сізге ерекше құрметпен қарайды.
1       Біздің  біз     PRON    prn     Case=Gen|Number=Plur|Person=1|PronType=Prs      2       nmod:poss       _       _
2       елде    ел      NOUN    n       Case=Loc        6       obl     _       _
3       сізге   сіз     PRON    prn     Case=Dat|Number=Sing|Person=2|Polite=Form|PronType=Prs  6       obl     _       _
4       ерекше  ерекше  ADJ     adj     _       5       amod    _       _
5       құрметпен       құрмет  NOUN    n       Case=Ins        6       obl     _       _
6       қарайды қара    VERB    v       Mood=Ind|Number=Plur|Person=3|Tense=Aor|VerbForm=Fin    0       root    _       SpaceAfter=No
7       .       .       PUNCT   sent    _       6       punct   _       _
}

Now that we have a way of converting @tt{apertium-kaz}'s output into CoNLL-U
format, we can take sentences from the UD Kazakh treebank, i.e. the gold
standard, pass them through @tt{apertium-kaz}, convert them and compare
@tt{apertium-kaz}'s output against the gold standard. The mismatches we see
will serve us as a guide for Constrait Grammar rules in
@tt{apertium-kaz.kaz.rlx}.

For evaluating the output of the CG-based dependency parser you can use
@hyperlink["https://gist.github.com/IlnarSelimcan/aacde626a02efa243b819d56957576a8"]{this
script}, which we will call @tt{conll18_ud_eval_lax.py}. It is a ``relaxed''
version of the original CoNLL 2018
@hyperlink["https://universaldependencies.org/conll18/evaluation.html"]{evaluation
script} -- relaxed in the sense that for the time being we commented out
otherwise useful checks for cycles in dependency trees and tokenization
mismatches (Constraint Grammar-based parser we're currently working on, being
incomplete, makes such errors sometimes).

No guarantees are given at this point as regards the scores obtained in such a
way. The only thing we can tell is that if we take only the first handful
sentences from the treebank and evaluate CG parser's output on them, we get
100% LAS score, as we should, since we know that they were covered by CG rules
and are perfectly parsed.

Parsing the first 2 sentences (lines 0-26 in the @tt{puupankki.kaz.conllu}
file) with CG parser and evaluating its output:

@verbatim{
python3 ~/conll18_ud_eval_lax.py --verbose \
<(head -n 26 texts/puupankki/puupankki.kaz.conllu) \
<(head -n 26 texts/puupankki/puupankki.kaz.conllu | grep "# text = " | \
sed 's/# text = //g' | apertium-destxt -n | apertium -f none -d . kaz-tagger | \
cg-conv -la | apertium-retxt | vislcg3 -g apertium-kaz.kaz.rlx | \
python3 ../ud-scripts/vislcg3-to-conllu.py "" 2> /dev/null | \
python3 ../ud-scripts/conllu-feats.py apertium-kaz.kaz.udx 2> /dev/null | \
python3 ../ud-scripts/conllu-nospaceafter.py 2> /dev/null )

Metric     | Precision |    Recall |  F1 Score | AligndAcc
-----------+-----------+-----------+-----------+-----------
Tokens     |    100.00 |    100.00 |    100.00 |
Sentences  |    100.00 |    100.00 |    100.00 |
Words      |    100.00 |    100.00 |    100.00 |
UPOS       |    100.00 |    100.00 |    100.00 |    100.00
XPOS       |    100.00 |    100.00 |    100.00 |    100.00
UFeats     |     94.44 |     94.44 |     94.44 |     94.44
AllTags    |     94.44 |     94.44 |     94.44 |     94.44
Lemmas     |     94.44 |     94.44 |     94.44 |     94.44
UAS        |    100.00 |    100.00 |    100.00 |    100.00
LAS        |    100.00 |    100.00 |    100.00 |    100.00
CLAS       |    100.00 |    100.00 |    100.00 |    100.00
MLAS       |     92.31 |     92.31 |     92.31 |     92.31
BLEX       |     92.31 |     92.31 |     92.31 |     92.31
}

To evaluate the CG parser on entire treebank we'd of course pass entire
treebank through it:

@verbatim{
python3 ~/conll18_ud_eval_lax.py --verbose \
<(cat texts/puupankki/puupankki.kaz.conllu) \
<(cat texts/puupankki/puupankki.kaz.conllu | grep "# text = " | \
sed 's/# text = //g' | apertium-destxt -n | apertium -f none -d . kaz-tagger | \
cg-conv -la | apertium-retxt | vislcg3 -g apertium-kaz.kaz.rlx | \
python3 ../ud-scripts/vislcg3-to-conllu.py "" 2> /dev/null | \
python3 ../ud-scripts/conllu-feats.py apertium-kaz.kaz.udx 2> /dev/null | \
python3 ../ud-scripts/conllu-nospaceafter.py 2> /dev/null )

Metric     | Precision |    Recall |  F1 Score | AligndAcc
-----------+-----------+-----------+-----------+-----------
Tokens     |     97.08 |     95.32 |     96.19 |
Sentences  |     93.22 |     95.80 |     94.49 |
Words      |     94.19 |     94.90 |     94.54 |
UPOS       |     86.43 |     87.08 |     86.75 |     91.76
XPOS       |     86.87 |     87.53 |     87.20 |     92.23
UFeats     |     81.37 |     81.98 |     81.67 |     86.39
AllTags    |     79.16 |     79.76 |     79.46 |     84.04
Lemmas     |     87.79 |     88.46 |     88.12 |     93.21
UAS        |     34.98 |     35.25 |     35.11 |     37.14
LAS        |     28.38 |     28.59 |     28.48 |     30.13
CLAS       |     35.30 |     29.88 |     32.36 |     31.81
MLAS       |     30.49 |     25.81 |     27.96 |     27.48
BLEX       |     32.65 |     27.64 |     29.94 |     29.43
}

Adding the statistical
@hyperlink["https://sourceforge.net/p/apertium/svn/HEAD/tree/branches/kaz-tagger/"]{kaz-tagger}
into the pipeline improves results, so this should be your default pipeline:

@verbatim{
python3 ~/conll18_ud_eval_lax.py --verbose <(cat texts/puupankki/puupankki.kaz.conllu) <(cat texts/puupankki/puupankki.kaz.conllu | grep "# text = " | \
sed 's/# text = //g' | apertium-destxt -n | apertium -f none -d . kaz-morph | \
cg-conv -la | apertium-retxt | python3 ~/src/sourceforge-apertium/branches/kaz-tagger/kaz_tagger.py | vislcg3 -g apertium-kaz.kaz.rlx | \
python3 ../ud-scripts/vislcg3-to-conllu.py "" 2> /dev/null | \
python3 ../ud-scripts/conllu-feats.py apertium-kaz.kaz.udx 2> /dev/null | \
python3 ../ud-scripts/conllu-nospaceafter.py 2> /dev/null )

Metric     | Precision |    Recall |  F1 Score | AligndAcc
-----------+-----------+-----------+-----------+-----------
Tokens     |     97.08 |     95.32 |     96.19 |
Sentences  |     93.22 |     95.80 |     94.49 |
Words      |     96.28 |     95.11 |     95.69 |
UPOS       |     86.96 |     85.90 |     86.43 |     90.32
XPOS       |     87.25 |     86.18 |     86.71 |     90.61
UFeats     |     83.83 |     82.81 |     83.32 |     87.07
AllTags    |     81.27 |     80.28 |     80.77 |     84.40
Lemmas     |     91.87 |     90.75 |     91.31 |     95.42
UAS        |     37.36 |     36.90 |     37.13 |     38.80
LAS        |     29.93 |     29.57 |     29.75 |     31.09
CLAS       |     36.85 |     31.61 |     34.03 |     33.55
MLAS       |     33.46 |     28.71 |     30.90 |     30.47
BLEX       |     35.82 |     30.73 |     33.08 |     32.62
}

@margin-note{A note for maintainers: switching to @tt{hfst-proc -w
kaz.automorf.hfst} from @tt{lt-proc -w kaz.automorf.bin} in the @tt{kaz-tagger}
mode drops the numbers dramatically, and I'm not yet sure why that is.}

If we overwrite @tt{apertium-kaz.kaz.lexc} and @tt{Makefile.am} of
@tt{apertium-kaz} with the eponymous, work-in-progress files from
@hyperlink["https://taruen.com/apertiumpp/apertiumpp-kaz/"]{apertium@bold{pp}-kaz}
and then recompile @tt{apertium-kaz} by running @tt{make}, for the above
command we get the following results:

@verbatim{
Metric     | Precision |    Recall |  F1 Score | AligndAcc
-----------+-----------+-----------+-----------+-----------
Tokens     |     97.67 |     96.00 |     96.83 |
Sentences  |     93.06 |     95.90 |     94.45 |
Words      |     96.89 |     95.73 |     96.31 |
UPOS       |     83.19 |     82.19 |     82.69 |     85.86
XPOS       |     83.40 |     82.40 |     82.90 |     86.08
UFeats     |     80.67 |     79.71 |     80.19 |     83.26
AllTags    |     77.64 |     76.71 |     77.17 |     80.13
Lemmas     |     92.15 |     91.05 |     91.60 |     95.11
UAS        |     37.47 |     37.02 |     37.24 |     38.67
LAS        |     29.63 |     29.28 |     29.46 |     30.59
CLAS       |     35.51 |     31.41 |     33.34 |     33.12
MLAS       |     31.56 |     27.91 |     29.62 |     29.43
BLEX       |     34.42 |     30.45 |     32.31 |     32.11
}

@section{Extending @tt{apertium-kaz}}

First of all, note that there is an ongoing effort described
@hyperlink["https://taruen.com/apertiumpp/apertiumpp-kaz/"]{here} to extend
@tt{apertium-kaz} with stems from the 15-volume Explanatory Dictionary of
Kazakh and to proof-read the resulting lexicion (and maybe expand with
additional markup). After proof-reading is done, it's likely that the resulting
stem-list will replace the lexicon currently available in
@tt{apertium-kaz/apertium-kaz.kaz.lexc} (since the former is a superset of the
latter). If you want to help out with proof-reading the lexicon agaist the
aforementioned paper dictionary, read
@hyperlink["https://taruen.com/apertiumpp/apertiumpp-kaz/"]{the documentation}
and contact Ilnar Salimzianov.

@subsection{Stems and categories}

To extend @tt{apertium-kaz} with new words, we need to know their lemmas and
their categories. Below we list the possible categories of words (we ignore the
so-called closed-class words here, as their likelihood to appear among
unrecognized words at this stage is negligible, and simplify some of the
categories of open-class words intentionally).

@tabular[#:style 'block
         #:column-properties '(left)
	 #:row-properties '(border)
(list (list @bold{Category} @bold{Comment} @bold{Examples (from @tt{apertium-kaz.kaz.lexc} file)})
      (list @bold{Nouns} 'cont 'cont)
      (list "N1" "common nouns" "алма:алма N1 ; ! “apple” \n жылқы:жылқы N1 ; ! “horse”")
      (list "N5" "nouns which are loanwords from Russian (and therefore potentially with exceptions in phonology)" "артист:артист N5 ; ! \"\" \n баррель:баррель N5 ; ! \"\"")
      (list "N6" "Linking nouns like акт, субъект, эффект to N6 forces apertium-kaz to analyse both акт and акті as noun, nominative; both актты and актіні as noun, accusative etc. The latter forms are the default — that is, акті and актіні are  generated for акт<n><nom> and акт<n><acc>, respectively, if apertium-kaz is used as a morphological generator." "")
      (list "N1-ABBR" "Abbreviated nouns. %{а%} indicates that the word ends in a vowel and takes back vowel endings; %{э%} indicates that word ends in a vowel and takes front vowel endings; %{а%}%{с%} shows that the word ends in unvoiced consonant and takes back-vowel endings and so on." "ДНҚ:ДНҚ%{а%} N1-ABBR ; ! \"DNA\"")
      (list "" "" "млн:млн%{а%}%{з%} N1-ABBR ; ! \"million\"")
      (list "" "" "млрд:млрд%{а%}%{с%} N1-ABBR ; ! \"billion\"")
      (list "" "" "км:км%{э%}%{з%} N1-ABBR ; ! \"km\"")
      (list @bold{Verbs} 'cont 'cont)
      (list "V-TV" "transitive verbs" "")
      (list "V-IV" "intransitve verbs. If the verb can take a direct object with -НЫ, then it's not IV; otherwise it is TV. FIXME?" "")
      (list @bold{Proper nouns} "" "")
      (list "NP-ANT-F" "feminine anthroponyms" @italic{Сәмиға})
      (list "NP-ANT-M" "masculine anthroponyms" @italic{Чыңғыз})
      (list "NP-COG-OB" "family names ending with -ов or -ев" @italic{Мусаев})
      (list "NP-COG-IN" "family names ending with -ин" @italic{Нуруллин})
      (list "NP-COG-M" "family names not ending with -ов, -ев or -in; masculine" @italic{Галицкий})
      (list "NP-COG-F" "family names not ending with -ов, -ев or -in; feminine" @italic{Толстая})
      (list "NP-COG-MF" "family names not ending with -ов, -ев or -in which can be both masculine and feminine" @italic{Гайдар})
      (list "NP-PAT-VICH" "patronymes ending with -вич (and thus which can also take the -вна ending)" @italic{Васильевич:Василье NP-PAT-VICH ; ! \"\"})
      (list "NP-TOP" "toponyms (river names should go here too)" @italic{Берлин})
      (list "NP-ORG" "organization names" @italic{Қазпошта})
      (list "NP-ORG-LAT" "organization names written in Latin characters" @italic{Microsoft})
      (list "NP-AL" "proper names not belonging to one of the above NP-* classes" @italic{Протон-М})
      (list @bold{Adjectives and adverbs} 'cont 'cont)
      (list "A1" "adjectives which can modify both nouns (жақсы адам) and verbs (жақсы оқиды)" "")
      (list "A2" "all other adjectives" @italic{көктемгі})
      (list "ADV" "adverbs. \n If you want to add an adverb, first think whether the word is really an adjective that can be used like an adverb. If this is the case, then add it as an A1 adjective." @italic{әбден}))]

Figuring the lemma of an unrecognized word should be straightforward. Except
for verbs, where the lemmas in @tt{apertium-kaz} are 2nd person singular
imperative forms such as @tt{бар}, @tt{кел}, @tt{ал} etc (i.e. not @tt{бару},
@tt{келу}, @tt{алу} as in some of the print dictionaries), the lemmas are what
you would expect to see in print dictionaries of Kazakh.

Still, there are some things to keep in mind (we use the word ``stem'' and
``lemma'' interchangeably below):

@itemize[

@item{Many stems exhibit a voicing alternation like п/б, к/г, қ/ғ. This is
processed automatically by @tt{apertium-kaz.kaz.twol}, and such stems must be
added with the voiceless consonant (п, к, қ) to @tt{apertium-kaz.kaz.lexc}, e.g
@tt{тақ:тақ V-TV ;}}

@item{Stems from Russian that end with one of the voiced consonants (б, г),
such as геолог should be entered as spelled, but should be put in the right
category for foreign words (e.g., if a noun, then N5).}

@item{Words that have an inserted ‹ы› or ‹і› in some forms should get %{y%} in
that spot on the right side, e.g. орын:ор%{y%}н N1 ;}

@item{There should be no infinitival final -у or -ю. It is best to take the
part of the verb before -GAн or -DI in those forms.}

@item{Infinitives ending in -ю should end in ‹й› instead, e.g ‹сүю› should be
entered as сүй}

@item{Some verbs have a "hidden" ‹ы› or ‹і› under the ‹у›, for example ері,
аршы, аңды, etc. These verb stems should be added with the ‹ы› or ‹і›.}

@item{Of course, verbs with ‹у› in the stem should keep the ‹у›, like жу, қу,
жау, etc.}

@item{Do not add passive or cooperative forms of verb stems (e.g., ‹тартыл› is
passive of ‹тарт›, and ‹тартыс› is cooperative).}]

@subsection{Lexicons}

@margin-note{This division of the lexicon will slightly
@hyperlink["https://github.com/apertium/apertium-kaz/issues/15"]{change}.}

At the end of @code{apertium-kaz.kaz.lexc}, there are five lexicons:

@itemize[

@item{Common}
@item{Hardcoded}
@item{Abbreviations}
@item{Punctuation}
@item{Proper}]

In each lexicon, entries are sorted alphabetically with the
@code{LC_ALL=kk_KZ.utf8 sort} command.

These five lexicons are where you have to put new words, after you have figured
out their stems and categories following the guidelines above.

@code{Abbreviations} and @code{Punctuation} lexicons should be self-explanatory.

Any stem linked to lexicon starting with NP should be placed into @code{LEXICON
Proper}.

Any (temporary) entry which involves tags, e.g.

@verbatim{қыл%<v%>%<tv%>%<gna_perf%>:ғып # ; ! "same as қып"}

belongs to the @code{Hardcoded} section.

The rest of stems goes to @code{LEXICON Common}.

@section{Open questions}

@itemize[

@item{Abbreviated toponyms like @italic{АҚШ} or @italic{БҰҰ} should they be <abbr> or
<np><top> or something else? In puupankki АҚШ is tagged as np top, but that
might be only because it's NP-TOP in kaz.lexc.}

@item{Maybe a better solution would be to make abbr into a secondary tag? For
one this will make it less confusing, АКШ will become np top abbr, БҰҰ will
become np org abbr, and млрд will become num abbr. The latter is currently
tagged as simply abbr, which is not very helpful for dep. parsing I guess.}

@item{On a related not, мың, миллион and миллиард are added both as noun and as
a numeral. That's ok imo, just to confirm.}

@item{диалогты gets the err_orth tag, that shouldn't happen imo}

@item{әрі --- post or adv}

@item{do stems of қору высыхать and қору строить differ in kazakh? In tatar they do.}

@item{what to do with -liq-nat forms? in pp-kaz, I analyse them as both noun and adjective.}

@item{freaking frequent қамтамасыз ет and other phrasal verbs like that? To
split or not to split, that is the question. Also, қол қой. Well, anything
labeled as `dep', in general.}

@item{is де transitive?}

@item{айтуынша cnjadv vs v.tv.ger.px3sp.equ} 

@item{suggestion to work strictly through pull requests}

@item{әрі қарай}

@item{өткен in атап өткен жөн.}

@item{ал in сатып алу vaux?}

@item{қатысты post or just adj?}

@item{does мен бен пен post make sense?}

]

@subsection{Open questions about Kazakh UD}

obl vs iobj

sometimes бол<cop> is root, sometimes it isn't

@verbatim{
- numeral compounds right headed (as currently) or left-headed?
  - I mean phrases like ``2 миллион доллар''
  - all occurences of such are tagged conssistently, which is good
  - that is, for our example: (доллар >nummod миллион; миллион >сompound 2)
  - query: [pos = "NUM"] > [pos = "NUM"]
  - where: https://weblicht.sfs.uni-tuebingen.de/Tundra/UD_Kazakh-KTB_v2.4/
  - probably best to keep as it is
}

diff between acl vs acl:relcl?

@itemlist[

@item{One seems to be used for clauses where the subject is
different from the main clause while the other for cases where the subject is
shared, but not in a consistent way. There is also acl:poss.}

@item{``This relation may be tagged with acl:relcl in the future, as it is the
way in which Turkic languages do relative clauses.''
(https://universaldependencies.org/kk/dep/acl.html)}

@item{Side-note: ``қандай түрде болса да'' example on the above page looks
wrong.}

]

хабараласушылар nmod vs clause

да <conj> vs postadv

Таяу күндерде аталған қаражат өңірлік қорларға аударылып, әрі қарай ол адамдардың есепшоттарына түседі. <= advcl vs coordination

Еуровидение 2010 ән конкурсы

20 есе өсті

@sout{NB that `бас' in Бас прокуратураның is `compound' dependent of
`прокуратураның', whereas in nominal constructions with possessives it would be
`nmod:poss', e.g. `бас -> (nmod:poss) ауыруы'}

No, that's not always the case (i.e. the mechanical test for a possessive affix
does not always work): жұсыс in жұмыс сапарының is also tagged as compound,
although the head word in this case does have a possessive suffix.

Тұрғын үй кешені 487 пәтерден тұрады. тұрады root no?

In reported speech, we seem to label the speech verb as root to which the
clause is attached as ccomp @bold{even if the speech verb clause is a the the
end of the sentence}, which is at odds with the ud2 annotation guidelines.
See akorda-random.tagged.txt:41:711 and guidelines on `parataxis' label.

TODO make sure that деп is treated the way it is said to be treated in
guidelines/papers.

сондықтан at the beginning of a sentence -- cc or mark?

Verbal nouns/gers (in my opinioun unnecessarily) lexicalised as nouns, should
they be kept as they are. Labeling verbs as nsubj would be against the rules
either.

akorda-random.tagged.txt:115:2056

Орталық Азия once is compound, once amod

akorda-random.tagged.txt:131:2334 why acl and not just amod?

өтеп бара жатқан -- өтеп main, бара and жатқан aux of it?

auxiliaries : advcl vs dep (атап өтілді in particular)

akorda-random.tagged.txt:167:3000 dubious

akorda-random.tagged.txt:205:3681 direction of flat:name seems odd

check akorda-random.tagged.txt:214:3835

head of да <advmod> might be inconsistent

өтуде as noun in akorda-random.tagged.txt:216:3868 :(

parataxis vs conj

да postadv sometimes dependent of the main verb, sometimes of the preceding noun

ranges like `2008-2009 жылдардагы'

something's wrong with this one:  УЕФА 1996 жылдан бергі футзал тарихында медаль алған алғашқы дебютант ел.

with sentences with a бар at the end (`there exists') should noun modifiers be labeled as nmod or obl?

to paratax to the left or to the right, that is the question. e.g. in kdt.tagged.txt:19:298

the last clause of kdt.tagged.txt:38:647 looks wrong somehow

Саған ешкім тимейді. <- why obj? Just because it tranlates to an acc noun in
English?

Ендеше, discourse vs advmod

Қорқақ аңдар, тілсіз жаулар! <- this one is inherently ambiguous, need a text
of Akbilek to see it in context.

parataxis right headed or left headed?

parataxis vs conj

should clf be used at all?

the end of kdt.tagged.txt:35:570 is messy

TODO discuss The right vs left headedness of conjunctions again: @italic{1
Қазақстанның 2 табыстары 3 мен 4 жетістіктерін ...} What should be the head of
Қазақстанның -- табыстары or жетістіктерін? If the latter, then we get a
non-projective tree. That is probably undesirable.

The exact command for converting .txt files in CG3 format ton CoNLL-U format is
as follows: TODO

TODO add a note on validation.py

5	қандай	қандай	PRON	prn	PronType=Int	8	csubj	_	_
2	қандай	қандай	ADJ	adj	PronType=Int	0	root	_	_

определиться надо?

also, noun-дай is obl if dependent of a predicate (correct), but amod if dependent of a subject
(nmod would be more appropriate, probably)

kdt.tagged.txt:200:3187 жауып отыра алмайды -- отыра could've been aux I guess?..

make sure that қайда and қайдан are labeled consistently

көн-көріс in kdt.tagged.txt:249:4052 is probably not conj

kdt.tagged.txt:282:4618

wikitravel.tagged.txt:31:318 here dep. claus of бола ма is labeled as csubj, although
in other sents iirc such clauses were ccomp ?

Сізде бірдеме тазалау бар ма? it is unlikely that тазалау is adj.comp here I think (IFS)

punctuation in Жиырма_Бесінші_Сөз.tagged.txt:3:70 (attached to orphan vs subsequent conj ?)

онан соң obl vs advmod ?

is түгіл really and conj in kazakh? or adv?

`Себебі' at the beginning of a sentences -- sconj vs nsubj

Жиырма_Бесінші_Сөз.tagged.txt:25:614 looks wrong, re-consider

nmod:poss vs compound (Иран Ислам республикасы, Иран.tagged.txt:9:238, Иран.tagged.txt:17:440)

Abbr:Yes feature while converting apertium <abbr>s into UD

help needed with Иран.tagged.txt:18:467, Иран.tagged.txt:19:546,
Иран.tagged.txt:27:704, Иран.tagged.txt:60:1747 (all should probably involve the orphan label)

-- punct preceding predicate sometimes right-headed, sometmes left-headed. What's the principle?

bah, punctuatin in  Иран.tagged.txt:20:583

Иран.tagged.txt:51:1426 -- too "advcl"s vs conj

year ranges like 1919-1921 (sometimes labeled as compound, sometimes
as conj; sometime left-headed, sometimes right-headed :/). Определиться надо!

hyphen dash between head and appoos -- where to attach it ? Moreover, the use
of appos seems to contradict v2 guidelines -- in particular, honorifics titles
are said to be labeled flat, but in kk they are appos ?

sents with orphans in them seem to have been handled wrong. I've corrected
(imho) the first few, but then, not being entirely sure on that, stopped doing
what I did.

I don't quite understand why dative nominals should be labeled as obj of
қарау...

wikipedia.tagged.txt:46:739 болды as cop ?

сонымен қатар

wikipedia.tagged.txt:71:1163 suspicious: атанды as cop porque ?

merge 954 and 955 into one sentences

I'd meant да <postadv> to have only ``уступительное'' значение (i.e. not
``too''), but in the treebank the latter meaning is also tagged as ADV

Шымкент.tagged.txt:8:216 has to be corrected to use the freaking `orphan' label, but
how exactly?

түйелері болыпты and other sents with болыпты in the same text --
болыпты root or preceding NP ? why ?

auxixilliary nouns like ішінде -- nouns (obl) or adp (case) ?

кемпірі екеуінің is a very peculiar, very peculiar construction. This is an
allusion (an allusion, not illusion) that the way it is annotated currently
might be wrong.

Guidelines v2 uses `flat' for dates and compound numerals, whereas in kazakh
treebank we use `compound'. Years in constructions like `1995 жылғы x' are
labeled as amod, which might be in contradiction with the guidelines,
dependenging on what is meant by dates.
