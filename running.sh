#!/usr/bin/env bash

SHOW=TRUE
OUTPUTFILE="Figure.png"

###
TOTAL_TIME=1e3
DT=5e-3
NBINMIN=10
NBINMAX=1000
R=40
NCHUNKS=1
###

python3 setup.py build_ext --inplace
mkdir outputs
python3 -c "import main; main.letsgo(total_time=$TOTAL_TIME, dt=$DT, Nbinmin = $NBINMIN, Nbinmax = $NBINMAX, R = $R, Nchunks = $NCHUNKS)"
python3 -c "import noise_csv; noise_csv.plotting(show=$SHOW, outputfile=$OUTPUTFILE, total_time=$TOTAL_TIME, dt=$DT, Nbinmin = $NBINMIN, Nbinmax = $NBINMAX)