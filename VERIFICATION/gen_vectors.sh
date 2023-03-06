#!/bin/bash

for (( WIDTH=128+17; WIDTH<4096; WIDTH=WIDTH+17 ))
do
	python3 /home/louis/FPL/VERIFICATION/gen_test_vectors.sage.py -w $WIDTH -n 100
done
