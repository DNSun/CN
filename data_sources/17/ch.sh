#!/bin/bash

i=0
for file in `ls *.wav`
do
f='17-'
#echo $f
b=${file:0-4}
let "i=i+1"
filename=$f$i$b
mv $file $filename
done

