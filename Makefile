VERSION = 1.3

UTILS = boolify \
		cumsum \
		diffs \
		div \
		exp \
		exp10 \
		exp2 \
		hist \
		histbin \
		inrange \
		len \
		line \
		log \
		log10 \
		log2 \
		lwhich \
		max \
		mean \
		median \
		min \
		mult \
		ncol \
		range \
		round \
		showcol \
		stripfilt \
		sum \
		table

LINKSCRIPT = linkscript.sh
COPYSCRIPT = copyscript.sh
SCRIPTDIR = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

TESTDIR = tests
TESTINPUT = tinyutils.dat
TESTEXPECT = tinyutils.expected
TESTOUTPUT = tinyutils.output
TESTDIFF = tinyutils.testdiff

linkscript: $(UTILS)
	@echo "#!/bin/sh" > $(LINKSCRIPT)
	@echo "SCRIPTDIR=$(SCRIPTDIR)" >> $(LINKSCRIPT)
	@echo "for util in $(UTILS) ; do" >> $(LINKSCRIPT)
	@echo "    if [ ! -e \$$util -o -L \$$util ] ; then" >> $(LINKSCRIPT)
	@echo "        ln -sf $(SCRIPTDIR)/\$$util \$$util" >> $(LINKSCRIPT)
	@echo "    else" >> $(LINKSCRIPT)
	@echo "        echo Not linking \$$util: file exists and is not a symbolic link" >> $(LINKSCRIPT)
	@echo "    fi" >> $(LINKSCRIPT)
	@echo "done" >> $(LINKSCRIPT)
	@chmod +x $(LINKSCRIPT)
	@echo "$(LINKSCRIPT) created, run it to create symbolic links to tinyutils in current directory"

copyscript: $(UTILS)
	@echo "#!/bin/sh" > $(COPYSCRIPT)
	@echo "SCRIPTDIR=$(SCRIPTDIR)" >> $(COPYSCRIPT)
	@echo "for util in $(UTILS) ; do" >> $(COPYSCRIPT)
	@echo "    if [ ! -e \$$util ] ; then" >> $(COPYSCRIPT)
	@echo "        cp -pv $(SCRIPTDIR)/\$$util \$$util" >> $(COPYSCRIPT)
	@echo "    else" >> $(COPYSCRIPT)
	@echo "        echo Not copying \$$util: file exists" >> $(COPYSCRIPT)
	@echo "    fi" >> $(COPYSCRIPT)
	@echo "done" >> $(COPYSCRIPT)
	@chmod +x $(COPYSCRIPT)
	@echo "$(COPYSCRIPT) created, run it to copy tinyutils to current directory"

all: test $(ZIPFILE) $(TARBALL)

zipfile: $(UTILS) $(TESTDIR) Makefile README.md
	@if [ -e $(TESTDIR)/$(TESTDIFF) -o -e $(TESTDIR)/$(TESTOUTPUT) ] ; then \
		echo "$(TESTDIR)/ still contains $(TESTDIFF) and/or $(TESTOUTPUT)" ; \
		exit 1; \
	fi ;
	@(  echo "Creating zipfile for version $(VERSION)" ; \
	    ZIPFILE=tinyutils-$(VERSION).zip ; \
		rm -f $$ZIPFILE ; \
		chmod 755 $(UTILS) $(TESTDIR); \
		chmod 644 $(TESTDIR)/* Makefile README.md; \
		zip -r $$ZIPFILE $^ && echo "Created $$ZIPFILE" ; \
	)

tarball: $(UTILS) $(TESTDIR) Makefile README.md
	@if [ -e $(TESTDIR)/$(TESTDIFF) -o -e $(TESTDIR)/$(TESTOUTPUT) ] ; then \
		echo "$(TESTDIR)/ still contains $(TESTDIFF) and/or $(TESTOUTPUT)" ; \
		exit 1; \
	fi ;
	@(  echo "Creating tarball for version $(VERSION)" ; \
	    TARBALL=tinyutils-$(VERSION).tar.gz ; \
		rm -f $$TARBALL ; \
		chmod 755 $(UTILS) $(TESTDIR); \
		chmod 644 $(TESTDIR)/* Makefile README.md; \
		tar cvzf $$TARBALL $^ && echo "Created $$TARBALL" ; \
	)

test: $(TESTDIR)/$(TESTOUTPUT)
	@(  cd $(TESTDIR); \
		if diff $(TESTOUTPUT) $(TESTEXPECT) > $(TESTDIFF) ; then \
			echo "PASSED tinyutils test" ; \
			rm -f $(TESTOUTPUT) $(TESTDIFF) ; \
		else \
			echo "FAILED** tinyutils test, diff file in $(TESTDIR)/$(TESTDIFF)" ; \
		fi ; \
	)

# Sort table output for comparison because keys come out in various orders

$(TESTDIR)/$(TESTOUTPUT): $(UTILS)
	@(  cd $(TESTDIR); rm -f $(TESTDIFF) ; \
		cat /dev/null > $(TESTOUTPUT) ; \
		for U in boolify cumsum diffs exp exp10 exp2 hist histbin log log10 log2 max mean median min range stripfilt sum ncol len showcol; do \
			echo $$U >> $(TESTOUTPUT) ;\
	    	../$$U $(TESTINPUT) >> $(TESTOUTPUT) ; \
		done ; \
		echo 'mult mult=2' >> $(TESTOUTPUT); ../mult mult=2 $(TESTINPUT) >> $(TESTOUTPUT) ; \
		echo 'div div=2' >> $(TESTOUTPUT); ../div div=2 $(TESTINPUT) >> $(TESTOUTPUT) ; \
		echo 'round digits=0' >> $(TESTOUTPUT); ../round digits=0 $(TESTINPUT) >> $(TESTOUTPUT) ; \
		echo 'table | sort -k1,1 -n' >> $(TESTOUTPUT); ../table $(TESTINPUT) | sort -k1,1 -n >> $(TESTOUTPUT) ; \
		echo 'stripfilt inverse=1' >> $(TESTOUTPUT); ../stripfilt inverse=1 $(TESTINPUT) >> $(TESTOUTPUT) ; \
		echo 'stripfilt header=0 inverse=1' >> $(TESTOUTPUT); ../stripfilt header=0 inverse=1 $(TESTINPUT) >> $(TESTOUTPUT) ; \
		echo 'stripfilt inverse=1 inverse_early=0 header=0' >> $(TESTOUTPUT); ../stripfilt inverse=1 inverse_early=0 header=0 $(TESTINPUT) >> $(TESTOUTPUT) ; \
		echo 'inrange min=1 max=8' >> $(TESTOUTPUT); ../inrange min=1 max=8 $(TESTINPUT) >> $(TESTOUTPUT) ; \
		echo 'inrange abs=4' >> $(TESTOUTPUT); ../inrange abs=4 $(TESTINPUT) >> $(TESTOUTPUT) ; \
		echo 'line line=2' >> $(TESTOUTPUT); ../line line=2 $(TESTINPUT) >> $(TESTOUTPUT) ; \
		echo 'line min=7' >> $(TESTOUTPUT); ../line min=7 $(TESTINPUT) >> $(TESTOUTPUT) ; \
		echo 'line max=2' >> $(TESTOUTPUT); ../line max=2 $(TESTINPUT) >> $(TESTOUTPUT) ; \
		echo 'line min=3 max=4' >> $(TESTOUTPUT); ../line min=3 max=4 $(TESTINPUT) >> $(TESTOUTPUT) ; \
		echo 'lwhich val=0' >> $(TESTOUTPUT); ../lwhich val=0 $(TESTINPUT) >> $(TESTOUTPUT) ; \
		echo 'lwhich val=4' >> $(TESTOUTPUT); ../lwhich val=4 $(TESTINPUT) >> $(TESTOUTPUT) ; \
	)

clean:
	rm -f $(ZIPFILE) ; ( cd $(TESTDIR) ; rm -f $(TESTDIFF) $(TESTOUTPUT) )

.PHONY: $(UTILS)
