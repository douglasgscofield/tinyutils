UTILS = boolify \
		cumsum \
		diffs \
		hist \
		inrange \
		log \
		log10 \
		max \
		mean \
		median \
		min \
		stripfilt \
		sum \
		table

ZIPFILE = tinyutils.zip

TESTDIR = tests
TESTINPUT = tinyutils.dat
TESTEXPECT = tinyutils.expected
TESTOUTPUT = tinyutils.output
TESTDIFF = tinyutils.testdiff

all: test $(ZIPFILE)

$(ZIPFILE): $(UTILS) $(TESTDIR) Makefile README.md
	@if [ -e $(TESTDIR)/$(TESTDIFF) -o -e $(TESTDIR)/$(TESTOUTPUT) ] ; then \
		echo "$(TESTDIR)/ still contains $(TESTDIFF) and/or $(TESTOUTPUT)" ; \
		exit 1; \
	fi ;
	@(  rm -f $@ ; \
		chmod 755 $(UTILS) $(TESTDIR); \
		chmod 644 $(TESTDIR)/* Makefile README.md; \
		zip -r $@ $^ && echo "Created $@" ; \
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

$(TESTDIR)/$(TESTOUTPUT): $(UTILS)
	@(  cd $(TESTDIR); rm -f $(TESTDIFF) ; \
		cat /dev/null > $(TESTOUTPUT) ; \
		for U in boolify cumsum diffs hist log log10 max mean median min stripfilt sum table; do \
			echo $$U >> $(TESTOUTPUT) ;\
	    	../$$U $(TESTINPUT) >> $(TESTOUTPUT) ; \
		done ; \
		echo stripfilt inverse=1 >> $(TESTOUTPUT); ../stripfilt inverse=1 $(TESTINPUT) >> $(TESTOUTPUT) ; \
		echo stripfilt header=0 inverse=1 >> $(TESTOUTPUT); ../stripfilt header=0 inverse=1 $(TESTINPUT) >> $(TESTOUTPUT) ; \
		echo inrange min=1 max=8 >> $(TESTOUTPUT); ../inrange min=1 max=8 $(TESTINPUT) >> $(TESTOUTPUT) ; \
		echo inrange abs=4 >> $(TESTOUTPUT); ../inrange abs=4 $(TESTINPUT) >> $(TESTOUTPUT) ; \
	)

clean:
	rm -f $(ZIPFILE) ; ( cd $(TESTDIR) ; rm -f $(TESTDIFF) $(TESTOUTPUT) )
