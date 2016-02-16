Tiny utilities
==============

Tiny scripts that work on a single column of data.  Some of these transform a single column of their input while passing everything through, some produce summary tables, and some produce a single summary value.  All (so far) are in awk, and all have the common options `header=0` which specifies the number of header lines on input to skip, `skip_comment=1` which specifies whether to skip comment lines on input that begin with `#`, and `col=1`, which specifies which column of the input stream should be examined.  Since they are awk scripts, they also have the standard variables for specifying the input field separator `FS="\t"` and the output field separator `OFS="\t"`.  Default output column separator is `"\t"`.

Set any of these variables by using `key=value` on the command line.  For example to find the median of the third column of numbers, when the first 10 lines of input are header:

````bash
median col=3 header=10 your.dat
````

Stick these in a pipeline that ends with [spark](https://github.com/holman/spark) for quick visual summaries.  If `indels.vcf.gz` is a compressed [VCF][] file containing indel calls, then this will print a sparkline of indel sizes in the range of ±10bp:

````bash
$ zcat indels.vcf.gz \
| stripfilt \
| awk '{print length($5)-length($4)}' \
| inrange abs=10 \
| hist \
| cut -f2 \
| spark
▁▁▁▁▁▁▁▁▂█▁▇▂▁▁▁▁▁▁▁▁
````

We get the second column of **hist** output because that's the counts.  This clearly shows the overabundance of single-base indels, and a slight overrepresentation of single-base deletions over insertions.

[VCF]:  http://www.1000genomes.org/wiki/Analysis/Variant%20Call%20Format/vcf-variant-call-format-version-41


### Transformers: output same as input with single column transformed

**boolify** : transform a column into 0 or 1 based on its current value

**cumsum** : replace a column with its cumulative sum

**log** : transform a column into its natural logarithm

**log10** : transform a column into its base-10 logarithm

**mult** : multiply a column by a given factor

**div** : divide a column by a given factor

**round** : round values to a given number of `digits=` after the decimal point



### Filters: output same as input with a subset of lines selected

**inrange** : 
pass through lines for which the value of a column falls within a given range of values

````bash
inrange col=3 abs=10 your.dat | ... # column 3 is between -10 and 10 inclusive
inrange min=0 max=1000 your.dat | ...  # column 1 is between 0 and 1000 inclusive
inrange min=10000 your.dat | ... # column 1 is at least 10000 inclusive
````

**stripfilt** : strip header and comment lines beginning with `#`, or *only* pass headers and comment lines; can include empty/whitespace lines

````bash
stripfilt your.dat | ... # remove default 1-line header and comments
stripfilt inverse=1 skip_comment=0 your.dat | ... # pass through only the header
stripfilt inverse=1 header=0 your.dat | ... # pass through only comments
stripfilt skip_blank=1 your.dat | ... # also remove empty and whitespace-only lines
````


### Condensers: output condensed from and some function of the input

**len** : print the length in characters of each line, excluding newline characters

**ncol** : print the number of columns in each line

**showcol** : prefix the contents of each column of the first line (by default, skipping comments) by the column number

**diffs** : produce successive pairwise numeric differences: 2nd - 1st, 3rd - 2nd, etc.  Length of output is length of data in input column - 1.

### Tablifiers: count summaries of input

**hist** : create a count histogram from a numeric column, grouping values into integer bins of [ *i*, *i* + 1).  Bins within the input range not having values in the input are printed with a count of 0.  To protect against potential errors in input or huge output, there must be more than `sparse=0.01` fraction of the input range occupied otherwise a message is printed instead of the full histogram; use `override=1` to override this behavior.  Use `drop_zero=1` to drop zero-valued bins from the output; this option implies `override=1`.

**table** : count the occurrences of unique values in a column and print a table of the values and their counts


### Summarizers: calculate summary values

**mean** : ... of a column

**median** : ... of a column

**min** : ... of a column

**max** : ... of a column

**range** : min and max of a column, separated by a tab

**sum** : ... of a column


### More examples

```bash
$ cat tests/tinyutils.dat
7
9
3
12.2
0
12
9
4

$ boolify tests/tinyutils.dat
1
1
1
1
0
1
1
1

$ cumsum tests/tinyutils.dat
7
16
19
31.2
31.2
43.2
52.2
56.2

$ ncol tests/tinyutils.dat
1
1
1
1
1
1
1
1

$ len tests/tinyutils.dat
1
1
1
4
1
2
1
1

$ diffs tests/tinyutils.dat
2
-6
9.2
-12.2
12
-3
-5

$ hist tests/tinyutils.dat
0	1
1	0
2	0
3	1
4	1
5	0
6	0
7	1
8	0
9	2
10	0
11	0
12	2

$ inrange min=1 max=8 tests/tinyutils.dat
7
3
4

$ inrange abs=4 tests/tinyutils.dat
3
0
4

$ log tests/tinyutils.dat
1.94591
2.19722
1.09861
2.50144
-inf
2.48491
2.19722
1.38629

$ log10 tests/tinyutils.dat
0.845098
0.954243
0.477121
1.08636
-inf
1.07918
0.954243
0.60206

$ max tests/tinyutils.dat
12.2

$ mean tests/tinyutils.dat
7.025

$ median tests/tinyutils.dat
8

$ min tests/tinyutils.dat
0

$ mult mult=2 tests/tinyutils.dat
14
18
6
24.4
0
24
18
8

$ div div=2 tests/tinyutils.dat
3.5
4.5
1.5
6.1
0
6
4.5
2

$ range tests/tinyutils.dat
0	12.2

$ round digits=0 tests/tinyutils.dat
7
9
3
12
0
12
9
4

$ stripfilt tests/tinyutils.dat  # default is a single-line header
9
3
12.2
0
12
9
4

$ stripfilt inverse=1 tests/tinyutils.dat
7

$ sum tests/tinyutils.dat
56.2

$ table tests/tinyutils.dat
3	1
4	1
7	1
9	2
12	1
12.2	1
0	1
```

**showcol** can eliminate errors from column-counting.

```
$ cat /etc/passwd | tr ':' '\t' | tail -n 1 | showcol
1:_launchservicesd	2:*	3:239	4:239	5:_launchservicesd	6:/var/empty	7:/usr/bin/false
```

By default the number of lines shown is `lines=1`, and the separator used is
`sep=":"`.  Any skipped header or comment lines are not shown.


