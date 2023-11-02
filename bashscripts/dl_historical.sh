#!/bin/bash

# Arguments : 1 = name of the variable to dl, 2 = model for which to extract data, 
#             3 = time period for which to extract data

# Download historical global file
wget https://files.isimip.org/ISIMIP3b/InputData/climate/atmosphere/bias-adjusted/global/daily/historical/${2^^}/${2}_r1i1p1f1_w5e5_historical_${1}_global_daily_${3}.nc

# Crop the file to European boundaries 
cdo -f nc4c -z zip_5 -masklonlatbox,-12,42,34,73 ${2}_r1i1p1f1_w5e5_historical_${1}_global_daily_${3}.nc ${2}/data/${1}_${3}.nc

# Remove the global file
rm ${2}_r1i1p1f1_w5e5_historical_${1}_global_daily_${3}.nc