#!/bin/bash

# Arguments : 1 = time period, 2 = model, 3 = ssp scenario


# Create directory for the outputs if it doesn't exist
if [ ! -d "${2}/output" ]
  then mkdir "${2}/output"
fi


# Identify the boundary years of the time period
year1=$(echo "$1" | cut -d '_' -f 1)
year2=$(echo "$1" | cut -d '_' -f 2)

# Set the input NetCDF file and the output files
input_file_elevation="$2/data/elevation.nc"
if [ "$year2" -lt 2015 ]; then
    input_file_tas="$2/data/tas_${1}.nc"
    input_file_pr="$2/data/pr_${1}.nc"
    outdir="${2}/output/hist"
else
    input_file_tas="$2/data/tas_${1}_${3}.nc"
    input_file_pr="$2/data/pr_${1}_${3}.nc"
    outdir="${2}/output/${3}"
fi

# Create directory for the outputs if it doesn't exist
if [ ! -d $outdir ]
  then mkdir $outdir
fi

# Start of all files produced
st="${2}_${1}_${3}_"

# Convert temperature in degree celsius
cdo subc,273.15 $input_file_tas "${st}tas.nc"

# Loop through the years 
for ((year = year1; year <= year2; year++)); do

    # Subset temperature a,d precipitation for this year only
    cdo yearmean -selyear,${year} "${st}tas.nc" "$outdir/tmean_${year}.nc"
    cdo yearsum -selyear,${year} $input_file_pr "$outdir/pr_${year}.nc"
done

echo "All annual files generated in the directory $outdir"
