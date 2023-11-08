#!/bin/bash

# Arguments : 1 = variable, 2 = model, 3 = ssp scenario, 4 = time period

# Download global file
wget https://files.isimip.org/ISIMIP3b/InputData/climate/atmosphere/bias-adjusted/global/daily/$3/${2^^}/$2_r1i1p1f1_w5e5_$3_$1_global_daily_$4.nc

# Move the file extracted
mv ${2}_r1i1p1f1_w5e5_${3}_${1}_global_daily_$4.nc $2/data/$1_$4_$3.nc
