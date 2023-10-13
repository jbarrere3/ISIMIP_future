#!/bin/bash

# Download historical global file
wget https://files.isimip.org/ISIMIP3b/InputData/climate/atmosphere/bias-adjusted/global/daily/historical/${2^^}/$2_r1i1p1f1_w5e5_historical_$1_global_daily_2011_2014.nc

# Crop the file to European boundaries 
cdo -f nc4c -z zip_5 -masklonlatbox,-12,42,34,73 $2_r1i1p1f1_w5e5_historical_$1_global_daily_2011_2014.nc $2/data/$1_2011_2014.nc

# Remove the global file
rm mpi-esm1-2-hr_r1i1p1f1_w5e5_historical_$1_global_daily_2011_2014.nc