#TEXINPUTS=/usr/share/texmf/tex//:./latex-beamer-3.05//:.
#          Beamer                   Linux                  Apple                     pgf/tikz          texlive
#TEXINPUTS=./latex-beamer-current//:/usr/share/texmf/tex//:/sw/share/texmf-dist/tex//:./pgf-current//:.

#           Beamer                   pgf/tikz        Linux                  Apple fink               apple TexLive                        Current directory
#TEXINPUTS=./latex-beamer-current//:./pgf-current//:/usr/share/texmf/tex//:/sw/share/texmf-dist/tex//:/usr/local/texlive/2011/texmf-dist//:.
TEXINPUTS=.:/usr/local/texlive/2015/texmf-dist//:/usr/local/texlive/2011/texmf-dist//:/usr/local/texlive/2013/texmf-dist//:custom_themes//
#texlive: :/usr/local/texlive//
export TEXINPUTS

PDFLATEX=/usr/local/texlive/2015//bin/x86_64-darwin/pdflatex
DOC=mojo

all: clean doc

clean: 
	rm -f $(DOC).{ps,pdf}
	rm -f mojo_book.pdf
	rm -f $(DOC).{log,aux,dvi,bbl,blg,log,out,nav,snm,toc,vrb,lol}
	rm -f bibliography-processed.bib
	rm -f *.vrb
	rm -f texput.log

test:
	$(PDFLATEX) $(DOC).tex

doc:      
	$(PDFLATEX) $(DOC).tex
	$(PDFLATEX) $(DOC).tex
	$(PDFLATEX) $(DOC).tex
	/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py -o mojo_book.pdf mojo_title.pdf mojo.pdf
	open mojo_book.pdf
