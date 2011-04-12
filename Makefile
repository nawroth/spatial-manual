# Makefile for the Neo4j documentation
#

BUILDDIR         = $(CURDIR)/target
SRCDIR           = $(BUILDDIR)/classes
SRCFILE          = $(SRCDIR)/neo4j-spatial-manual.txt
IMGDIR           = $(SRCDIR)/images
CSSDIR           = $(SRCDIR)/css
JSDIR            = $(SRCDIR)/js
CONFDIR          = $(SRCDIR)/conf
DOCBOOKFILE      = $(BUILDDIR)/neo4j-spatial-manual.xml
DOCBOOKSHORTINFOFILE = $(BUILDDIR)/neo4j-spatial-manual-shortinfo.xml
DOCBOOKFILEPDF   = $(BUILDDIR)/neo4j-spatial-manual-pdf.xml
FOPDIR           = $(BUILDDIR)/pdf
FOPFILE          = $(FOPDIR)/neo4j-spatial-manual.fo
FOPPDF           = $(FOPDIR)/neo4j-spatial-manual.pdf
TEXTWIDTH        = 80
TEXTDIR          = $(BUILDDIR)/text
TEXTFILE         = $(TEXTDIR)/neo4j-spatial-manual.txt
TEXTHTMLFILE     = $(TEXTFILE).html
SINGLEHTMLDIR    = $(BUILDDIR)/html
SINGLEHTMLFILE   = $(SINGLEHTMLDIR)/neo4j-spatial-manual.html
ANNOTATEDDIR     = $(BUILDDIR)/annotated
ANNOTATEDFILE    = $(HTMLDIR)/neo4j-spatial-manual.html
CHUNKEDHTMLDIR   = $(BUILDDIR)/chunked
CHUNKEDOFFLINEHTMLDIR = $(BUILDDIR)/chunked-offline
CHUNKEDTARGET     = $(BUILDDIR)/neo4j-spatial-manual.chunked
CHUNKEDSHORTINFOTARGET = $(BUILDDIR)/neo4j-spatial-manual-shortinfo.chunked
MANPAGES         = $(BUILDDIR)/manpages
UPGRADE          = $(BUILDDIR)/upgrade
FILTERSRC        = $(CURDIR)/src/bin/resources
FILTERDEST       = ~/.asciidoc/filters

ifdef VERBOSE
	V = -v
  VA = VERBOSE=1
endif

ifdef KEEP
	K = -k
	KA = KEEP=1
endif

ifdef VERSION
    VERS = --attribute revnumber=$(VERSION)
else
    VERS = --attribute revnumber=-neo4j-version
endif

ifdef IMPORTDIR
    IMPDIR = --attribute importdir=$(IMPORTDIR)
else
    IMPDIR = --attribute importdir=$(SRCDIR)
    IMPORTDIR = $(SRCDIR)
endif

GENERAL_FLAGS = $(V) $(K) $(VERS) $(IMPDIR)

.PHONY: all dist docbook help clean pdf html offline-html text cleanup annotated upgrade installfilter

help:
	@echo "Please use 'make <target>' where <target> is one of"
	@echo "  clean       to clean the build directory"
	@echo "  dist        to generate the common distribution formats"
	@echo "  pdf         to generate a PDF file using FOP"
	@echo "  html        to make standalone HTML files"
	@echo "  singlehtml  to make a single large HTML file"
	@echo "  text        to make text files"
	@echo "  annotated   to make a single annotated HTML file"
	@echo "  manpages    to make the manpages"
	@echo "For verbose output, use 'VERBOSE=1'".
	@echo "To keep temporary files, use 'KEEP=1'".
	@echo "To set the version, use 'VERSION=[the version]'".
	@echo "To set the importdir, use 'IMPORTDIR=[the importdir]'".

dist: installfilter pdf offline-html annotated text cleanup
# html has been removed for now

clean:
	-rm -rf $(BUILDDIR)/*

cleanup:
	#
	#
	# Cleaning up.
	#
	#
ifndef KEEP
	rm -f $(DOCBOOKFILE)
	rm -f $(DOCBOOKFILEPDF)
	rm -f $(DOCBOOKSHORTINFOFILE)
	rm -f $(BUILDDIR)/*.xml
	rm -f $(FOPDIR)/images
	rm -f $(UPGRADE)/*.xml
	rm -f $(UPGRADE)/*.html
endif

installfilter:
	#
	#
	# Installing asciidoc filters.
	#
	#
	mkdir -p $(FILTERDEST)
	cp -fr $(FILTERSRC)/* $(FILTERDEST)

copyimages:
	#
	#
	# Copying images from source projects.
	#
	#
	cp -fr $(IMPORTDIR)/*/*/images/* $(SRCDIR)/images/

docbook:  copyimages
	#
	#
	# Building docbook output.
	#
	#
	mkdir -p $(BUILDDIR)
	asciidoc $(V) $(VERS) $(IMPDIR) --backend docbook --attribute docinfo --doctype book --conf-file=$(CONFDIR)/asciidoc.conf --conf-file=$(CONFDIR)/docbook45.conf --out-file $(DOCBOOKFILE) $(SRCFILE)
	xmllint --nonet --noout --xinclude --postvalid $(DOCBOOKFILE)

docbook-shortinfo:  copyimages
	#
	#
	# Building docbook output with short info.
	#
	#
	mkdir -p $(BUILDDIR)
	asciidoc $(V) $(VERS) $(IMPDIR) --backend docbook --attribute docinfo1 --doctype book --conf-file=$(CONFDIR)/asciidoc.conf --conf-file=$(CONFDIR)/docbook45.conf --out-file $(DOCBOOKSHORTINFOFILE) $(SRCFILE)
	xmllint --nonet --noout --xinclude --postvalid $(DOCBOOKSHORTINFOFILE)

pdf:  docbook copyimages
	#
	#
	# Building PDF.
	#
	#
	sed 's/\&#8594;/\&#8211;\&gt;/g' <$(DOCBOOKFILE) >$(DOCBOOKFILEPDF)
	mkdir -p $(FOPDIR)
	cd $(FOPDIR)
	xsltproc --xinclude --output $(FOPFILE) $(CONFDIR)/fo.xsl $(DOCBOOKFILEPDF)
	ln -s $(SRCDIR)/images $(FOPDIR)/images
	fop -fo $(FOPFILE) -pdf $(FOPPDF)
ifndef KEEP
	rm -f $(FOPFILE)
endif

html: copyimages docbook-shortinfo
	#
	#
	# Building html output.
	#
	#
	a2x $(V) -L -f chunked -D $(BUILDDIR) --xsl-file=$(CONFDIR)/chunked.xsl -r $(IMGDIR) -r $(CSSDIR) --xsltproc-opts "--stringparam admon.graphics 1" --xsltproc-opts "--xinclude" --xsltproc-opts "--stringparam chunk.section.depth 1" --xsltproc-opts "--stringparam toc.section.depth 1" $(DOCBOOKSHORTINFOFILE)
	rm -rf $(CHUNKEDHTMLDIR)
	mv $(CHUNKEDSHORTINFOTARGET) $(CHUNKEDHTMLDIR)
	cp -fr $(JSDIR) $(CHUNKEDHTMLDIR)/js

offline-html: copyimages docbook-shortinfo
	#
	#
	# Building html output for offline use.
	#
	#
	a2x $(V) -L -f chunked -D $(BUILDDIR) --xsl-file=$(CONFDIR)/chunked-offline.xsl -r $(IMGDIR) -r $(CSSDIR) --xsltproc-opts "--stringparam admon.graphics 1" --xsltproc-opts "--xinclude" --xsltproc-opts "--stringparam chunk.section.depth 1" --xsltproc-opts "--stringparam toc.section.depth 1" $(DOCBOOKSHORTINFOFILE)
	rm -rf $(CHUNKEDOFFLINEHTMLDIR)
	mv $(CHUNKEDSHORTINFOTARGET) $(CHUNKEDOFFLINEHTMLDIR)
	cp -fr $(JSDIR) $(CHUNKEDOFFLINEHTMLDIR)/js

# currently builds docbook format first
annotated:  copyimages
	#
	#
	# Building annotated html output.
	#
	#
	mkdir -p $(ANNOTATEDDIR)
	a2x $(GENERAL_FLAGS) -L -a showcomments -f xhtml -D $(ANNOTATEDDIR) --conf-file=$(CONFDIR)/xhtml.conf --asciidoc-opts "--conf-file=$(CONFDIR)/asciidoc.conf" --asciidoc-opts "--conf-file=$(CONFDIR)/docbook45.conf" --xsl-file=$(CONFDIR)/xhtml.xsl --xsltproc-opts "--stringparam admon.graphics 1" $(SRCFILE)
	cp -fr $(SRCDIR)/js $(ANNOTATEDDIR)/js

text: docbook-shortinfo
	#
	#
	# Building text output.
	#
	#
	mkdir -p $(TEXTDIR)
	cd $(TEXTDIR)
	xsltproc --xinclude --stringparam callout.graphics 0 --stringparam navig.graphics 0 --stringparam admon.textlabel 1 --stringparam admon.graphics 0  --output $(TEXTHTMLFILE) $(CONFDIR)/text.xsl $(DOCBOOKSHORTINFOFILE)
	cd $(SRCDIR)
	w3m -cols $(TEXTWIDTH) -dump -T text/html -no-graph $(TEXTHTMLFILE) > $(TEXTFILE)
ifndef KEEP
	rm -f $(TEXTHTMLFILE)
	rm -f $(TEXTDIR)/*.html
endif

