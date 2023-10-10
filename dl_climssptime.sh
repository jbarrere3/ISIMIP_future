#!/bin/bash

# Arguments : 1 = variable, 2 = model, 3 = ssp scenario, 4 = time period

# Download global file
wget https://files.isimip.org/ISIMIP3b/InputData/climate/atmosphere/bias-adjusted/global/daily/$3/${2^^}/$2_r1i1p1f1_w5e5_$3_$1_global_daily_$4.nc

# Crop the file to European boundaries 
cdo -f nc4c -z zip_5 -masklonlatbox,-12,42,34,73 $2_r1i1p1f1_w5e5_$3_$1_global_daily_$4.nc $2/$1_$4_$3.nc

# Remove the global file
rm $2_r1i1p1f1_w5e5_$3_$1_global_daily_$4.nc