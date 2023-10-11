#!/bin/bash

# Arguments : 1 = time period, 2 = model, 3 = ssp scenario

# Identify the years
year1=$(echo "$1" | cut -d '_' -f 1)
year2=$(echo "$1" | cut -d '_' -f 2)

# Set the input NetCDF file and the output files
if [ "$year2" -lt 2015 ]; then
    input_file="$2/tas_$1.nc"
else
    input_file="$2/tas_$1_$3.nc"
fi

# Loop through the years 
for year in {$year1..$year2}; do

    # Set the output filename for the current year
    output_file="tmean_$year.nc"

    # Use CDO to calculate the annual mean temperature for the current year
    cdo yearmean -selyear,$year $input_file $output_file

    echo "Generated $output_file"
done

echo "All annual temperature files generated in $output_dir"