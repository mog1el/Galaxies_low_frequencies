#!/usr/bin/env bash

###
SHOW=True
OUTPUTFILE='Figure.png'
YLIMLOW=0
YLIMHIGH=0.02e38
###

###
TOTAL_TIME=3e1
DT=1e-3
NBINMIN=10
NBINMAX=1000
R=40
NCHUNKS=1
STEP=10
###

python3 setup.py build_ext --inplace
mkdir outputs
python3 -c "import main; main.letsgo(total_time=$TOTAL_TIME, dt=$DT, Nbinmin = $NBINMIN, Nbinmax = $NBINMAX, R = $R, Nchunks = $NCHUNKS, step=$STEP)"
python3 -c "import noise_csv; noise_csv.plotting(show=$SHOW, outputfile='$OUTPUTFILE', total_time=$TOTAL_TIME, dt=$DT, Nbinmin = $NBINMIN, Nbinmax = $NBINMAX, ylimlow=$YLIMLOW, ylimhigh=$YLIMHIGH, step=$STEP)"