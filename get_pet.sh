#!/bin/bash

# Arguments : 1 = time period, 2 = model, 3 = ssp scenario

# Identify the boundary years of the time period
year1=$(echo "$1" | cut -d '_' -f 1)
year2=$(echo "$1" | cut -d '_' -f 2)

# Set the input NetCDF file and the output files
input_file_elevation="$2/elevation.nc"
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

# Start of all files produced
st="${2}_${1}_${3}_"

# Convert from Kelvin to Celsius
cdo subc,273.15 $input_file_tasmax "${st}tasmax.nc"
cdo subc,273.15 $input_file_tasmin "${st}tasmin.nc"
cdo subc,273.15 $input_file_tas "${st}tas.nc"

# Calculate vapor pressure deficit
cdo expr,'esTmax = (0.6108*exp((17.27*tasmax)/(tasmax+237.3)))' "${st}tasmax.nc" "${st}esTmax.nc"
cdo expr,'esTmin = (0.6108*exp((17.27*tasmin)/(tasmin+237.3)))' "${st}tasmin.nc" "${st}esTmin.nc"
cdo -divc,2 -add "${st}esTmax.nc" "${st}esTmin.nc" "${st}es.nc"
cdo -divc,100 -mul "${st}es.nc" $input_file_hurs "${st}ea.nc"
cdo sub "${st}es.nc" "${st}ea.nc" "${st}vpd.nc"
rm "${st}esTmax.nc"
rm "${st}esTmin.nc"
rm "${st}es.nc"

# Calculate net radiation
# - net shortwave
cdo mulc,0.0864 $input_file_rsds "${st}rs.nc"
cdo mulc,0.77 "${st}rs.nc" "${st}rns.nc"
# - clear-sky radiation rso (extraterrestrial radiation ra assumed constant at 188)
cdo -mulc,118 -addc,0.75 -mulc,0.00002 $input_file_elevation "${st}rso.nc"
# - Calculate in several terms (rnla, rnlb and rnlc) net longwave
cdo -mulc,0.0000000024515 -add -powc,4 $input_file_tasmax -powc,4 $input_file_tasmin "${st}rnla.nc"
cdo -addc,0.34 -mulc,-0.14 -powc,0.5 "${st}ea.nc" "${st}rnlb.nc"
cdo -subc,0.35 -mulc,1.35 -div "${st}rs.nc" "${st}rso.nc" "${st}rnlc.nc"
cdo mul "${st}rnla.nc" "${st}rnlb.nc" "${st}rnlc.nc" "${st}rnl.nc"
# - net radiation
cdo sub "${st}rns.nc" "${st}rnl.nc" "${st}rn.nc"
# - Remove temporary files
rm "${st}rns.nc"
rm "${st}rso.nc"
rm "${st}ea.nc"
rm "${st}rnla.nc"
rm "${st}rnlb.nc"
rm "${st}rnlc.nc"
rm "${st}rnl.nc"

#cdo expr,'es = (esTmax + esTmin)/2' -selvar,esTmax "${st}esTmax.nc" -selvar,esTmin "${st}esTmin.nc" "${st}es.nc"
#cdo -selvar,es "${st}es.nc" -selvar,hurs $input_file_hurs expr,'vpd = es*(1 - hurs/100)' "${st}vpd.nc"
# cdo expr,'Delta = (4098*0.6108*exp((17.27*(tas-273.15))/((tas-273.15)+237.3)))/(((tas-273.15)+237.3)^2)' $input_file_tas $2_$1_Delta.nc
# cdo expr,'Pr = (4098*0.6108*exp((17.27*(tas-273.15))/((tas-273.15)+237.3)))/(((tas-273.15)+237.3)^2)' $input_file_tas $2_$1_Delta.nc

# Loop through the years 
for ((year = year1; year <= year2; year++)); do

    # Set the output filename for the current year
    # output_file_sgdd="sgdd_$year.nc"
    # output_file_wai="wai_$year.nc"
    output_file_rnmean="rnmean_${year}.nc"

    # Use CDO to calculate sgdd and wai for the current year
    cdo yearmean -selyear,${year} "${st}rn.nc" $output_file_rnmean

    echo "Generated $output_file_rnmean"
done

echo "All annual files generated in the current directory"

# remove temporary directory
rm "${st}tas.nc"
rm "${st}tasmin.nc"
rm "${st}tasmax.nc"
rm "${st}rn.nc"
rm "${st}vpd.nc"