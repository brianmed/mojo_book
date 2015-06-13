#TEXINPUTS=/usr/share/texmf/tex//:./latex-beamer-3.05//:.
#          Beamer                   Linux                  Apple                     pgf/tikz          texlive
#TEXINPUTS=./latex-beamer-current//:/usr/share/texmf/tex//:/sw/share/texmf-dist/tex//:./pgf-current//:.

#           Beamer                   pgf/tikz        Linux                  Apple fink               apple TexLive                        Current directory
#TEXINPUTS=./latex-beamer-current//:./pgf-current//:/usr/share/texmf/tex//:/sw/share/texmf-dist/tex//:/usr/local/texlive/2011/texmf-dist//:.
TEXINPUTS=.:/usr/local/texlive/2014/texmf-dist//:/usr/local/texlive/2011/texmf-dist//:/usr/local/texlive/2013/texmf-dist//:custom_themes//
#texlive: :/usr/local/texlive//
export TEXINPUTS

PDFLATEX=/usr/local/texlive/2014//bin/x86_64-darwin/pdflatex
DOC=mojo

# ZoffixWork
# bpmedley, RE: http://bmedley.org/mojo.pdf  The immediate concern is all the
# hyphens in shell commands in the book are actually UTF8 minus signs, so it
# makes it impossible to copy-paste them (I'm assuming the book *will* be
# available in digital format) and copy/pasting code examples leaves spaces
# after nearly every character. You also keep using full paths to morbo, et.
# al. and I don't think that's necessary and should be avoided f
# 12:15		or clarity. <html>, <head>, and <body> are all optional tags.
#    Perhaps, it will be clearer if they are omitted in the code examples (at
#    least in Hello World example) to simplify overall snippet. In fact, I
#    think the "Getting Started" section on homepage of http://mojolicio.us/ is
#    the perfect example to use: it's just 3 lines. To the uninitiated, it'll
#    likely be confusing why you first use Lite and the full apps. I think
#    there shoul
# 12:15		d be a section explaining the purpose of Lite apps. There should be
#    a section (say, section 0.7.0) explaining the MVC concept. People
#    unfamiliar with it with get confused right when you start talking about
#    Controllers. The code example after section 0.7.2 looks really messy. I
#    think it should be written with 70-col, or so, max line width so there
#    would be no wraps. I also don't think this form for dereference is the
#    common one: $$
# 12:15		site_config{hypnotoad_ip}
# 12:16		Sorry for the noise... Anyway, that's my two cents.

all: clean doc

clean: 
	rm -rf $(DOC).{ps,pdf}
	rm -rf $(DOC).{log,aux,dvi,bbl,blg,log,out,nav,snm,toc,vrb}
	rm -f bibliography-processed.bib
	rm -rf *.vrb
	rm -f texput.log

test:
	$(PDFLATEX) $(DOC).tex

doc:      
	$(PDFLATEX) $(DOC).tex
	$(PDFLATEX) $(DOC).tex
	$(PDFLATEX) $(DOC).tex
	open mojo.pdf
