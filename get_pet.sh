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
    input_file_pr="$2/pr_$1.nc"
    en = "_$2"
else
    input_file_tas="$2/tas_$1_$3.nc"
    input_file_tasmax="$2/tasmax_$1_$3.nc"
    input_file_tasmin="$2/tasmin_$1_$3.nc"
    input_file_hurs="$2/hurs_$1_$3.nc"
    input_file_rsds="$2/rsds_$1_$3.nc"
    input_file_sfcwind="$2/sfcwind_$1_$3.nc"
    input_file_pr="$2/pr_$1_$3.nc"
    en = "_$2_$3"
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
cdo -mulc,0.0000000024515 -add -pow,4 $input_file_tasmax -pow,4 $input_file_tasmin "${st}rnla.nc"
cdo -addc,0.34 -mulc,-0.14 -pow,0.5 "${st}ea.nc" "${st}rnlb.nc"
cdo -subc,0.35 -mulc,1.35 -div "${st}rs.nc" "${st}rso.nc" "${st}rnlc.nc"
cdo mul "${st}rnla.nc" "${st}rnlb.nc" "${st}rnlab.nc"
cdo mul "${st}rnlab.nc" "${st}rnlc.nc" "${st}rnl.nc"
# - net radiation
cdo sub "${st}rns.nc" "${st}rnl.nc" "${st}rn.nc"
# - Remove temporary files
rm "${st}rns.nc"
rm "${st}rs.nc"
rm "${st}rso.nc"
rm "${st}ea.nc"
rm "${st}rnla.nc"
rm "${st}rnlb.nc"
rm "${st}rnlc.nc"
rm "${st}rnlab.nc"
rm "${st}rnl.nc"

# Calculate slope of saturation vapor pressure (Delta)
cdo expr,'Delta = (4098*0.6108*exp((17.27*tas)/(tas+237.3)))/((tas+237.3)^2)' "${st}tas.nc" "${st}Delta.nc"

# Calculate psychometric constant
cdo expr,'Pr = 101.3*((293 - 0.0065*orog)/293)^5.26' $input_file_elevation "${st}Pr.nc"
cdo expr,'Gamma = (0.001013*Pr)/(0.622*2.45)' "${st}Pr.nc" "${st}Gamma.nc"

# Calculate windspeed at 2m high
cdo mulc,0.747132 $input_file_sfcwind "${st}u2.nc" 

# Final calculations for pet
cdo -mulc,0.408 -mul "${st}Delta.nc" "${st}rn.nc" "${st}pet1.nc"
cdo -mulc,900 -div "${st}Gamma.nc" $input_file_tas "${st}pet2.nc"
cdo -mul "${st}u2.nc" "${st}vpd.nc" "${st}pet3.nc"
cdo -add "${st}pet1.nc" -mul "${st}pet3.nc" "${st}pet2.nc" "${st}pet4.nc"
cdo -add "${st}Delta.nc" -mul "${st}Gamma.nc" -addc,1 -mulc,0.34 "${st}u2.nc" "${st}pet5.nc" 
cdo div "${st}pet4.nc" "${st}pet5.nc" "${st}pet.nc"

# Remove the last temporary files
rm "${st}pet1.nc"
rm "${st}pet2.nc"
rm "${st}pet3.nc"
rm "${st}pet4.nc"
rm "${st}pet5.nc"
rm "${st}u2.nc"
rm "${st}Pr.nc"
rm "${st}Gamma.nc"
rm "${st}Delta.nc"

# calculate degree days above 5.5
cdo -expr,'sgdd = ((tas < 0)) ? tas : 0' -subc,5.5 "${st}tas.nc" "${st}gdd.nc"

# Loop through the years 
for ((year = year1; year <= year2; year++)); do

    # Use CDO to sum pet and precipitation over each year
    cdo yearsum -selyear,${year} "${st}pet.nc" "pet_${year}${en}.nc"
    cdo yearsum -selyear,${year} $input_file_pr "pr_${year}${en}.nc"
    cdo yearsum -selyear,${year} "${st}gdd.nc" "sgdd_${year}${en}.nc"
    cdo -div -sub -mulc,86400 "pr_${year}${en}.nc" "pet_${year}${en}.nc" "pet_${year}${en}.nc" "wai_${year}${en}.nc" 

    # Remove temporary files
    rm "pet_${year}${en}.nc"
    rm "pr_${year}${en}.nc"

done

echo "All annual files generated in the current directory"

# remove temporary directory
rm "${st}tas.nc"
rm "${st}tasmin.nc"
rm "${st}tasmax.nc"
rm "${st}rn.nc"
rm "${st}vpd.nc"
rm "${st}pet.nc"
rm "${st}gdd.nc"