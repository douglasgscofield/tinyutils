Tiny utilities
==============

Tiny, generally useful scripts that work on data streams.  All (so far) are in awk, and all have the common options `header=0` which specifies the number of header lines on input to skip, and `skip_comment=1` which specifies whether to skip comment lines on input that begin with `#`.

You can download them all in a [single zip file]().

`boolify`
turns a specified column into 0 or 1 based on its current value.

`hist`
creates a histogram from its numeric input, grouping values into integer bins of [i, i+1).  To protect against potential errors in input or a huge histogram, if only a fraction `sparse=0.01` of the input range is occupied a message is printed instead of the full histogram; use `override=1` to override this behavior.

`table` 
counts the occurrences of unique values in the input and prints a table of them.

`mean`
calculates the mean of a set of numbers.

`median`
calculates the median of a set of numbers.

`min`
calculates the minimum of a set of numbers.

`max`
calculates the maximum of a set of numbers.

