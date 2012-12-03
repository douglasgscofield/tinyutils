Tiny utilities
==============

Tiny scripts that work on a single column of data.  Some of these transform a single column of their input while passing everything through, some produce summary tables, and some produce a single summary value.  All (so far) are in awk, and all have the common options `header=0` which specifies the number of header lines on input to skip, `skip_comment=1` which specifies whether to skip comment lines on input that begin with `#`, and `col=1`, which specifies which column of the input stream should be examined.  Since they are awk scripts, they also have the standard variables for specifying the input column separator `FS="\t"` and the output column separator `OFS="\t"`.

Set any of these variables by using `key=value` on the command line.  For example to find the median of the third column of numbers, when the first 10 lines of input are header:

````bash
median col=3 header=10 your.dat
````

* * *
You can download all tiny utilities in a [single zip file](https://github.com/downloads/douglasgscofield/tinyutils/tinyutils.zip).  The zip file includes this README, a tests directory and a Makefile which can recreate the zip file and do a bit of testing.
* * *

### Transformers: output same as input with single column transformed

**boolify** : transform a column into 0 or 1 based on its current value

**log** : transform a column into its natural logarithm

**log10** : transform a column into its base-10 logarithm

**cumsum** : replace a column with its cumulative sum


### Filters: output shorter than input, output a single column

**diffs** : produce successive pairwise numeric differences: 2nd - 1st, 3rd - 2nd, etc.  Length of output is length of input column - 1.


### Tablifiers: count summaries of input

**hist** : create a count histogram from a numeric column, grouping values into integer bins of [*i*, *i* + 1).  Bins within the input range not having values in the input are printed with a count of 0.  To protect against potential errors in input or huge output, there must be more than `sparse=0.01` fraction of the input range occupied otherwise a message is printed instead of the full histogram; use `override=1` to override this behavior.

**table** : count the occurrences of unique values in a column and print a table


### Summarizers: calculate a single value

**mean** : ... of a column

**median** : ... of a column

**min** : ... of a column

**max** : ... of a column

**sum** : ... of a column

### Examples

````bash
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

$ diffs tests/tinyutils.dat
2
-6
9.2
-12.2
12
-3
-5

$ hist tests/tinyutils.dat
0 1
1 0
2 0
3 1
4 1
5 0
6 0
7 1
8 0
9 2
10 0
11 0
12 2

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

$ sum tests/tinyutils.dat
56.2

$ table tests/tinyutils.dat
3 1
4 1
7 1
9 2
12 1
12.2 1
0 1
````
