# Geodesic Growth Series: Fabrykowski-Gupta group

This repo contains some code to generate the geodesic growth series for the Fabrykowski-Gupta group.

The design of this code is based on the Unix philosophy. In paricular, the software in this repo is separated into five executables, plus a bash script to connect everything.

The code in this repo uses the usual generating set with the recursively defined generator `b = (a,1,b)`.

This code is relased under the MIT license.

# Requirements

The code in this repo is written for a GNU/Linux based system.
In particular, this program has only been tested on Debian Trixie.

The code makes use of some common GNU coreutils such as `sort`, `gawk`, `tee`, `gzip`.

This program is written in Zig (v0.14.0), so you will need a copy of the Zig compiler.

# How to compile and run

Compile the program by running:

```bash
zig build -Doptimize=ReleaseSafe
```

> [!NOTE]
> You must use `ReleaseSafe` or `Debug` as its adds additional bounds checks on array accesses which the program does not explicitly check.
> (This should not cause any issues, you sould have to be generating out to well over length 1000 before this becomes an issue: it is simply not realistic to be able to reach this situation.)

After compiling, the programs should then be available under `./zig-out/bin`.

To start the code, run the program `run.sh`.

> [!NOTE]
> You should view and edit the contents of `run.sh` before running it.
> This script contains some settings at the top:
> 
> ```bash
> COMPRESS="gzip"
> GENERATE_NEXT="./prepend-generator-fg"
> OUTDIR="$(pwd)/output"
> SORT_TMPDIR="$OUTDIR/tmp"
> SORT_BUFFER_SIZE=8G
> SIZE=35
> ```
> 
> There is a description of each such variable in the file `run.sh`

# Output Files

The output of this program is given as:

 1. text files formatted as `length*.summary` which contain a basic summary of the level;
 2. a summary to standard output which is just a concatination of the `length*.summary` files; and
 3. compressed text files of the form `length*.data` contains the contents of the spheres.
    These files are compressed using the `$COMPRESS` variable in `run.sh`.
    The format of these files is described as follows.

## Summary Format

The files `length*.summary` have the following format

```text
processing length [length-of-elements-in-sphere]

[timing information]

sphere size: [number-of-elements] ([number-of-geodesics])
file size: [compressed-file-size] / [uncompressed-file-size] ([compression-ratio])
```

For example:

```text
processing length 34

real	240m27.913s
user	279m34.721s
sys	18m11.892s

sphere size: 2,751,740,432 (5,043,285,984)
file size: 15,448,128,041 / 205,633,326,389 (7%)
```

Indicates that

 - there are 2,751,740,432 elements of length 34;
 - there are 5,043,285,984 elements of length 34;
 - the compressed file size of length34.data is 15,448,128,041 bytes;
 - the uncompressed file size of length34.data is 205,633,326,389 bytes; and
 - generating length34.data from the previous lengths took around 279 minutes = 4.65 hours.

## Sphere Format

The uncompressed contexts of the files of the form `length*.data` contain one element per line.

### Overview

Each line has the form:

```text
[portrait]:[descend-set]:[count]
```

where

  * `[portrait]` is an encoding of a minimal size portrait of an element;
  * `[descend-set]` is an encoding of a subset of the generators which, if pre-composed with the element, will result in a shorter element; and
  * `[count]` is a count, in base 10, of the number of geodesics give this element.


### Example

Contents of `length3.data`:

```text
(<Ab(>A1B)):D:1
(<BA1):A:1
(<aB(<a1b)):H:1
(<ab(>a1b)):D:1
(<ba1):A:1
(=1BA):A:1
(=1ba):A:1
(=BA1):B:1
(=ba1):B:1
(>(<1BA)AB):H:1
(>(<1ba)aB):D:1
(>(>BA1)Ab):H:1
(>(>ba1)ab):D:1
(>1BA):B:1
(>1ba):B:1
```

Some lines from `length35.data`:

```text
(<(<(<(<1BA)(<1BA)(<A1B))(=(<A1B)AB)(>ab(>a1b)))(=aB(<AB(<A1B)))(=(<1BA)(<a1b)(>(>ba1)ab))):H:2
(<(<(<(<1BA)(<1BA)(<A1B))(=(<A1B)AB)(>ab(>a1b)))(=aB(<AB(<A1B)))(=(<1BA)(<a1b)(>A1B))):H:4
(<(<(<(<1BA)(<1BA)(<A1B))(=(<A1B)AB)(>ab(>a1b)))(=aB(<AB(<A1B)))(=(<1BA)(<a1b)(>BA1))):H:1
(<(<(<(<1BA)(<1BA)(<A1B))(=(<A1B)AB)(>ab(>a1b)))(=aB(<AB(<A1B)))(=(<1ba)(>A1B)(<1BA))):H:1
(<(<(<(<1BA)(<1BA)(<A1B))(=(<A1B)AB)(>ab(>a1b)))(=aB(<AB(<A1B)))(=(<1ba)(>A1B)(<A1B))):H:6
(<(<(<(<1BA)(<1BA)(<A1B))(=(<A1B)AB)(>ab(>a1b)))(=aB(<AB(<A1B)))(=(<1ba)(>A1B)(<ab(>a1b)))):H:4
(<(<(<(<1BA)(<1BA)(<A1B))(=(<A1B)AB)(>ab(>a1b)))(=aB(<AB(<A1B)))(=(<A1B)(<a1b)(>BA1))):A:1
(<(<(<(<1BA)(<1BA)(<A1B))(=(<A1B)AB)(>ab(>a1b)))(=aB(<AB(<A1B)))(=(>BA1)(<1BA)(<a1b))):L:2
(<(<(<(<1BA)(<1BA)(<A1B))(=(<A1B)AB)(>ab(>a1b)))(=aB(<AB(<A1B)))(=(>BA1)(<A1B)(<1ba))):H:1
(<(<(<(<1BA)(<1BA)(<A1B))(=(<A1B)AB)(>ab(>a1b)))(=aB(<AB(<A1B)))(=(>a1b)ab)):A:1
(<(<(<(<1BA)(<1BA)(<A1B))(=(<A1B)AB)(>ab(>a1b)))(=aB(<AB(<A1B)))(=(>ba1)(>(<1ba)aB)b)):D:1
(<(<(<(<1BA)(<1BA)(<A1B))(=(<A1B)AB)(>ab(>a1b)))(=aB(<AB(<A1B)))(=1(=BA1)A)):H:1
(<(<(<(<1BA)(<1BA)(<A1B))(=(<A1B)AB)(>ab(>a1b)))(=aB(<AB(<A1B)))(=a(=1ba)(>a1b))):H:2
```

### Format of portraits

Portraits can be defined recusively as follows

```text
# the action of the generator a
[portait] ~> 'a'

# the action of the generator a^{-1}
[portait] ~> 'A'

# the action of the generator b
[portait] ~> 'b'

# the action of the generator b^{-1}
[portait] ~> 'B'

# we need to expand out the action using wreath recursion
# Here
#   * [action] is how the subtrees are permuted
#   * the three sub-portraits are the actions on the subtrees 
[portrait] ~> '(' [action] [portrait] [portrait] [portrait] ')'

# do not permute the subtree
[action] ~> '='

# do not permute the subtree as like the generator a
[action] ~> '>'

# do not permute the subtree as like the generator a^{-1}
[action] ~> '<'
```

### Format of the descend set

A descend set is a subset of the generating set `X = \{ a, a^{-1}, b, b^{-1} \}`.

We encode the desend set as a single ASCII character.

In particular, we encode it as

```text
 0100 x4 x3 x2 x1
```

where

 * `x1` is `1` if and only if `a` is in the set;
 * `x2` is `1` if and only if `a^{-1}` is in the set;
 * `x3` is `1` if and only if `b` is in the set; and
 * `x4` is `1` if and only if `b^{-1}` is in the set.

We choose this encoding as it corresponds to letters in ASCII.
For example, in ASCII, the letter `H` is encoded as `01001000` which would correspond to a descend set containing only `b^{-1}`.

# Output of the program

## Summary

| length | spherical growth | spherical geodesic growth |
| -- | -- | -- |
| 3 | 16 | 16 |
| 4 | 32 | 32 |
| 5 | 64 | 64 |
| 6 | 128 | 128 |
| 7 | 256 | 256 |
| 8 | 512 | 512 |
| 9 | 1,024 | 1,024 |
| 10 | 1,968 | 2,048 |
| 11 | 3,608 | 3,664 |
| 12 | 6,816 | 7,104 |
| 13 | 12,704 | 13,424 |
| 14 | 23,696 | 25,664 |
| 15 | 43,720 | 48,432 |
| 16 | 80,224 | 91,136 |
| 17 | 146,432 | 170,304 |
| 18 | 266,688 | 318,944 |
| 19 | 484,464 | 591,984 |
| 20 | 878,800 | 1,104,032 |
| 21 | 1,589,376 | 2,049,584 |
| 22 | 2,862,976 | 3,797,952 |
| 23 | 5,145,456 | 7,004,976 |
| 24 | 9,226,328 | 12,928,032 |
| 25 | 16,495,488 | 23,712,040 |
| 26 | 29,422,368 | 43,491,840 |
| 27 | 52,346,136 | 79,512,504 |
| 28 | 92,872,704 | 144,997,904 |
| 29 | 164,374,672 | 263,539,944 |
| 30 | 290,176,048 | 478,231,104 |
| 31 | 511,135,408 | 864,602,376 |
| 32 | 897,966,344 | 1,560,704,000 |
| 33 | 1,573,794,776 | 2,808,866,784 |
| 34 | 2,751,740,432 | 5,043,285,984 |
| 35 | 4,802,049,192 | 9,030,311,920 |

## Ouptut content

**NOTE:** The output given in this section is for a slightly older version of the program. In particular, the file sizes will be different by around 1 byte. (The new version of the program ends the file with a `\n` character while the older version did not.)


Here is some example output of the program.

This code was run on a Lenovo ThinkPad E15 with 12th Gen Intel(R) Core(TM) i3-1215U CPU.

Note that I hibernated my computer partway through, so some of the timings are off (look at the `user` timing for more accurate information).

```text
processing length 3

real	0m0.008s
user	0m0.011s
sys	0m0.004s

sphere size: 16 (16)
file size: 114 / 215 (53%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 4

real	0m0.008s
user	0m0.012s
sys	0m0.006s

sphere size: 32 (32)
file size: 171 / 511 (33%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 5

real	0m0.006s
user	0m0.008s
sys	0m0.005s

sphere size: 64 (64)
file size: 340 / 1,223 (27%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 6

real	0m0.006s
user	0m0.009s
sys	0m0.005s

sphere size: 128 (128)
file size: 589 / 2,847 (20%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 7

real	0m0.006s
user	0m0.007s
sys	0m0.007s

sphere size: 256 (256)
file size: 1,145 / 6,175 (18%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 8

real	0m0.007s
user	0m0.013s
sys	0m0.004s

sphere size: 512 (512)
file size: 2,142 / 13,311 (16%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 9

real	0m0.007s
user	0m0.009s
sys	0m0.007s

sphere size: 1,024 (1,024)
file size: 4,207 / 28,183 (14%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 10

real	0m0.011s
user	0m0.012s
sys	0m0.010s

sphere size: 1,968 (2,048)
file size: 8,087 / 57,567 (14%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 11

real	0m0.015s
user	0m0.019s
sys	0m0.009s

sphere size: 3,608 (3,664)
file size: 14,909 / 113,887 (13%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 12

real	0m0.019s
user	0m0.029s
sys	0m0.004s

sphere size: 6,816 (7,104)
file size: 28,422 / 229,735 (12%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 13

real	0m0.030s
user	0m0.027s
sys	0m0.022s

sphere size: 12,704 (13,424)
file size: 53,646 / 457,183 (11%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 14

real	0m0.041s
user	0m0.055s
sys	0m0.009s

sphere size: 23,696 (25,664)
file size: 101,700 / 904,455 (11%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 15

real	0m0.070s
user	0m0.083s
sys	0m0.018s

sphere size: 43,720 (48,432)
file size: 191,719 / 1,760,999 (10%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 16

real	0m0.122s
user	0m0.153s
sys	0m0.021s

sphere size: 80,224 (91,136)
file size: 357,935 / 3,399,903 (10%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 17

real	0m0.201s
user	0m0.265s
sys	0m0.029s

sphere size: 146,432 (170,304)
file size: 664,415 / 6,504,671 (10%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 18

real	0m0.369s
user	0m0.501s
sys	0m0.062s

sphere size: 266,688 (318,944)
file size: 1,228,222 / 12,394,867 (9%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 19

real	0m0.671s
user	0m0.969s
sys	0m0.128s

sphere size: 484,464 (591,984)
file size: 2,260,638 / 23,476,403 (9%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 20

real	0m1.286s
user	0m2.011s
sys	0m0.131s

sphere size: 878,800 (1,104,032)
file size: 4,144,199 / 44,299,419 (9%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 21

real	0m2.276s
user	0m3.477s
sys	0m0.360s

sphere size: 1,589,376 (2,049,584)

file size: 7,604,821 / 83,100,139 (9%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 22

real	0m4.157s
user	0m6.590s
sys	0m0.667s

sphere size: 2,862,976 (3,797,952)
file size: 13,865,516 / 155,047,399 (8%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 23

real	0m7.573s
user	0m12.260s
sys	0m1.110s

sphere size: 5,145,456 (7,004,976)
file size: 25,308,064 / 288,058,559 (8%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 24

real	0m13.857s
user	0m22.880s
sys	0m1.989s

sphere size: 9,226,328 (12,928,032)
file size: 45,948,382 / 533,062,639 (8%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 25

real	0m25.472s
user	0m42.380s
sys	0m3.761s

sphere size: 16,495,488 (23,712,040)
file size: 83,313,572 / 982,381,315 (8%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 26

real	1m29.910s
user	2m1.034s
sys	0m9.608s

sphere size: 29,422,368 (43,491,840)
file size: 150,437,518 / 1,803,608,215 (8%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 27

real	2m41.481s
user	3m38.582s
sys	0m15.938s

sphere size: 52,346,136 (79,512,504)
file size: 271,562,082 / 3,299,144,847 (8%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 28

real	4m49.052s
user	6m34.905s
sys	0m26.641s

sphere size: 92,872,704 (144,997,904)
file size: 487,444,555 / 6,011,161,683 (8%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 29

real	8m44.622s
user	12m29.071s
sys	0m51.535s

sphere size: 164,374,672 (263,539,944)
file size: 874,053,652 / 10,917,112,943 (8%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 30

real	15m37.733s
user	22m20.214s
sys	1m32.771s

sphere size: 290,176,048 (478,231,104)
file size: 1,560,402,512 / 19,757,181,219 (7%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 31

real	79m37.222s
user	85m5.353s
sys	4m16.917s

sphere size: 511,135,408 (864,602,376)
file size: 2,781,590,004 / 35,655,330,151 (7%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 32

real	210m17.224s
user	146m14.148s
sys	8m6.128s

sphere size: 897,966,344 (1,560,704,000)
file size: 4,937,352,481 / 64,125,095,363 (7%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 33

real	278m23.807s
user	186m31.923s
sys	11m17.029s

sphere size: 1,573,794,776 (2,808,866,784)
file size: 8,749,389,142 / 115,003,901,189 (7%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 34

real	240m27.913s
user	279m34.721s
sys	18m11.892s

sphere size: 2,751,740,432 (5,043,285,984)
file size: 15,448,128,041 / 205,633,326,389 (7%)

~~~~~~~~~~~~~~~~~~~~~~~~~~

processing length 35

real	636m15.186s
user	672m44.035s
sys	41m58.897s

sphere size: 4,802,049,192 (9,030,311,920)
file size: 27,230,594,230 / 366,833,616,923 (7%)
```

