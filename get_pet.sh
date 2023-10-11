#!/bin/bash

# Arguments : 1 = time period, 2 = model, 3 = ssp scenario

# Identify the boundary years of the time period
year1=$(echo "$1" | cut -d '_' -f 1)
year2=$(echo "$1" | cut -d '_' -f 2)

# Set the input NetCDF file and the output files
input_file_elevation = "$2/elevation.nc"
if [ "$year2" -lt 2015 ]; then
    input_file_tas="$2/tas_$1.nc"
    input_file_tasmax="$2/tasmax_$1.nc"
    input_file_tasmin="$2/tasmin_$1.nc"
    input_file_hurs="$2/hurs_$1.nc"
    input_file_rsds="$2/rsds_$1.nc"
    input_file_sfcwind="$2/sfcwind_$1.nc"
else
    input_file_tas="$2/tas_$1_$3.nc"
    input_file_tasmax="$2/tasmax_$1_$3.nc"
    input_file_tasmin="$2/tasmin_$1_$3.nc"
    input_file_hurs="$2/hurs_$1_$3.nc"
    input_file_rsds="$2/rsds_$1_$3.nc"
    input_file_sfcwind="$2/sfcwind_$1_$3.nc"
fi

# Create temporary folder for calculations
tempdir = "${2}_${1}_${3}"
mkdir tempdir

# Convert from Kelvin to Celsius
cdo subc,273.15 $input_file_tasmax $tempdir/tasmax_$year.nc
cdo subc,273.15 $input_file_tasmin $tempdir/tasmin_$year.nc
cdo subc,273.15 $input_file_tas $tempdir/tas_$year.nc

# cdo expr,'Delta = (4098*0.6108*exp((17.27*(tas-273.15))/((tas-273.15)+237.3)))/(((tas-273.15)+237.3)^2)' $input_file_tas $2_$1_Delta.nc
# cdo expr,'Pr = (4098*0.6108*exp((17.27*(tas-273.15))/((tas-273.15)+237.3)))/(((tas-273.15)+237.3)^2)' $input_file_tas $2_$1_Delta.nc

# Loop through the years 
for ((year = year1; year <= year2; year++)); do

    # Set the output filename for the current year
    # output_file_sgdd="sgdd_$year.nc"
    # output_file_wai="wai_$year.nc"
    output_file_tmean="tmean_$year.nc"

    # Use CDO to calculate sgdd and wai for the current year
    cdo yearmean -selyear,$year $tempdir/tasmin_$year.nc $output_file_tmean

    echo "Generated $output_file_sgdd and $output_file_wai"
done

echo "All annual files generated in the current directory"

# remove temporary directory
rm -d tempdir