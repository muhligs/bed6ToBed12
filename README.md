# bed6ToBed12
This program turns bed6 files into bed12 files based on the fourth name column. 
Entries on the same chromosome with the same name are converted into a bed12 entry. 
The program sorts the output file according to chromosome, name and position.

Input supports stdin and can be piped. 
The convention of parameter -i is adopted from bedtools
Output is stdout, so usage would be e.g.

bed6ToBed12 -i bed6file

bed6ToBed12 -i bed6file > bed12file

cat bed6file | bed6ToBed12 -i stdin > bed12file

cat bed6file | bed6ToBed12 -i stdin | something something > file

To use the program, download the bed6ToBed12 directory and make executable. 
Add e.g. a symbolic link to the bed6ToBed12.sh file in your /usr/local/bin directory.
The program runs partly in R and requires packages iRanges and parallel, so make sure this is available.

Then you shold be set to go.

Technically, the program first merges the bed6 files so that overlapping entries with the same name (and chromosome) are merged into a single bed6 entry. 
This is done with R, and is required to avoid partly overlapping blocks in the bed12 output. 
I had a previoius version where this was done with bedtools merge, but it turned out to be much slower even on single cores. 
Now it runs decently, especially with multiple cores. The subsequent step of bed12 assembly is written in awk.
Enjoy.
