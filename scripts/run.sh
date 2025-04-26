#!/usr/bin/bash

#########################
# Settings
#########################

# This program will be used to compress the output, and be given to
#  the program sort in order to compress intermediate files
#
# This program should support 
#   "$COMPRESS" -d
# for decompression.
#
# Alternative include `xz` and `bzip2`
#
# Note that `xz` will give better compression, but will result in
# a slowdown.
COMPRESS="gzip"

# This is the program that is used to prepend elements of the
#  generating set to a list of elements
GENERATE_NEXT="./prepend-generator-fg"

# where to put the output files
OUTDIR="$(pwd)/output"

# by default, sort will likely place its intermediate files in the directory
# /tmp which might have a quota placed on it. This causes an issue as if the
# program reaches this quota, then it will crash.
#
# This  is the where we should instead put the temperaries
SORT_TMPDIR="$OUTDIR/tmp"

# This is the amount of memory that sort will be allowed.
#
# The larger this amount, the faster the program
SORT_BUFFER_SIZE=8G

# This program will generate the statistics for elements of length
#  1 to SIZE
SIZE=35

#########################
# Initialise the code
#########################

# make sure C-c terminates the entire script
trap "echo; exit" INT
set -eo pipefail

# We need to process levels 0, 1 and 2 before we
# can get to the general case

#################
# length 0

mkdir -p "$OUTDIR"
mkdir -p "$SORT_TMPDIR"
printf "1:@:1" | "$COMPRESS" >"$OUTDIR/length0.data"

#################
# length 1

"$COMPRESS" -d --stdout "$OUTDIR/length0.data" \
  | "$GENERATE_NEXT"\
  | LC_ALL=C sort --compress-prog="$COMPRESS" \
  | ./make-unique \
  | ./subtract-elements \
      <("$COMPRESS" -d --stdout "$OUTDIR/length0.data") \
  | "$COMPRESS" >"$OUTDIR/length1.data"

#################
# length 2

"$COMPRESS" -d --stdout "$OUTDIR/length1.data" \
  | "$GENERATE_NEXT"\
  | LC_ALL=C sort --compress-prog="$COMPRESS" \
  | ./make-unique \
  | ./subtract-elements \
      <("$COMPRESS" -d --stdout "$OUTDIR/length1.data") \
      <("$COMPRESS" -d --stdout "$OUTDIR/length0.data") \
  | "$COMPRESS" >"$OUTDIR/length2.data"

#########################
# General case
#########################

generateNextlength() {
  i="$1"
  "$COMPRESS" -d --stdout "$OUTDIR/length$(expr "$i" - 1).data" \
    | "$GENERATE_NEXT"\
    | LC_ALL=C sort \
        --temporary-directory="$SORT_TMPDIR" \
        --compress-prog="$COMPRESS" \
        --buffer-size="$SORT_BUFFER_SIZE" \
    | ./make-unique \
    | ./subtract-elements \
        <("$COMPRESS" -d --stdout "$OUTDIR/length$(expr "$i" - 1).data") \
        <("$COMPRESS" -d --stdout "$OUTDIR/length$(expr "$i" - 2).data") \
        <("$COMPRESS" -d --stdout "$OUTDIR/length$(expr "$i" - 3).data") \
    | "$COMPRESS" >"$OUTDIR/length$i.data"
}

step() {
  i="$1"
  echo "processing length $i"
  (time generateNextlength "$i") 2>&1
  echo ""

  "$COMPRESS" -d --stdout "$OUTDIR/length$i.data" \
    | ./summary \
    | gawk "match(\$0, /size ([0-9]*) [(]([0-9]*)[)]/, m) { printf(\"sphere size: %'d (%'d)\", m[1], m[2]) }"
  echo ""

  COMPRESSED_SIZE="$( cat "$OUTDIR/length$i.data" | ./wcbytes )"
  REAL_SIZE="$( "$COMPRESS" -d --stdout "$OUTDIR/length$i.data" | ./wcbytes )"

  printf \
    "file size: %'d / %'d (%d%%)" \
      "$COMPRESSED_SIZE" \
      "$REAL_SIZE" \
      "$( expr "(" "$COMPRESSED_SIZE" "*" 100 ")" "/" "$REAL_SIZE" )"
}

for i in `seq 3 "$SIZE"`; do
  if [ ! -e "$OUTDIR/length$i.summary" ]; then
    # we need to generate this length
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo ""
    echo "started at $( date )"
    step "$i" | tee "$OUTDIR/length$i.inprogress"
    printf "\n\n"
    sync
    mv "$OUTDIR/length$i.inprogress" "$OUTDIR/length$i.summary"
    sync
  else
    # already generated
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo ""
    echo "NOTICE: skiping length $i as it's already generated"
    echo ""
    cat "$OUTDIR/length$i.summary" | gawk "{ print \" > \" \$0 }"
    echo ""
  fi
done

