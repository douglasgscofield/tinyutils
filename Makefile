UTILS = boolify \
		cumsum \
		diffs \
		hist \
		log \
		log10 \
		max \
		mean \
		median \
		min \
		sum \
		table

TESTDIR = tests

ZIPFILE = tinyutils.zip

all: test $(ZIPFILE)

$(ZIPFILE): $(UTILS) $(TESTDIR) Makefile README.md
	rm -f $@ ; zip -r $@ $^

test: tinyutils.output
	(cd $(TESTDIR); if diff $< tinyutils.expected > tinyutils.testdiff ; then \
		echo "tinyutils test PASSED" ; \
		rm -f $< tinyutils.testdiff ; \
	else \
		echo "tinyutils test FAILED, diff file in tests/" ; \
	fi )

tinyutils.output: $(UTILS)
	(cd $(TESTDIR); rm -f tinyutils.testdiff ; \
	cat /dev/null > $@ ; \
	for U in $^ ; do \
		echo $$U >> $@ ;\
	    ../$$U tinyutils.dat >> $@ ; \
	done )

clean:
	rm -f $(ZIPFILE) ; ( cd $(TESTDIR) ; rm -f tinyutils.testdiff tinyutils.output)
