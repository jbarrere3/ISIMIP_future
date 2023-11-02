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
    input_file_sfcwind="$2/data/sfcwind_${1}.nc"
    outdir="${2}/output/hist"
else
    input_file_sfcwind="$2/data/sfcwind_${1}_${3}.nc"
    outdir="${2}/output/${3}"
fi

# Create directory for the outputs if it doesn't exist
if [ ! -d $outdir ]
  then mkdir $outdir
fi

# Start of all files produced
st="${2}_${1}_${3}_"


# Calculate windspeed at 2m high
cdo mulc,0.747132 $input_file_sfcwind "${st}U2.nc" 

# Loop through the years 
for ((year = year1; year <= year2; year++)); do

    # Subset windspeed for this year only
    cdo -selyear,${year} "${st}U2.nc" "${st}U2_${year}.nc"

    # Use CDO to calculate 95% quantile
    cdo yearpctl,95 "${st}U2_${year}.nc" -yearmin "${st}U2_${year}.nc" -yearmax "${st}U2_${year}.nc" "$outdir/u2max_${year}.nc"

    # Remove temporary file
    rm "${st}U2_${year}.nc"

done

# Remove temporary file
rm "${st}U2.nc"

echo "All annual files generated in the directory $outdir"
