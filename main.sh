#!/bin/bash

# Arguments : 1 = csv file with all variables, 2 = model for which to extract data, 
#             3 = csv file with future time periods, 4 = csv file with historical time periods

# Inform the log file
echo "Time: $(date). Begin script" >> dlclim.log

# Create directory for the model if it doesn't exist
if [ ! -d ${2} ]
  then mkdir ${2}
fi
if [ ! -d "${2}/data" ]
  then mkdir "${2}/data"
fi

# Loop on all variables to download data from model $2 (historical data)
while read timeperiodhist; do
    # Loop on all variables to download data from model $2 
    while read variables; do
        if [ ! -f $2/data/${variables}_$timeperiodhist.nc ]
          then bash bashscripts/dl_historical.sh $variables $2 $timeperiodhist &
        fi
    done < "$1"
    wait
    echo "Time: $(date). (model $2) - End download of $timeperiodhist" >> dlclim.log
done < "$4"

wait

echo "Time: $(date). (model $2) - End download of historical data" >> dlclim.log

# Loop on all time periods to download future data from model $2, ssp126
while read timeperiod; do
    # Loop on all variables to download data from model $2 
    while read var; do
        if [ ! -f $2/data/${var}_${timeperiod}_ssp126.nc ]
          then bash bashscripts/dl_climssptime.sh $var $2 ssp126 $timeperiod &
        fi
    done < "$1"
    wait
    echo "Time: $(date). (model $2) - End download of ssp126, $timeperiod" >> dlclim.log
done < "$3"

wait

# Loop on all time periods to download future data from model $2, ssp370
while read timeperiod; do
    # Loop on all variables to download data from model $2 
    while read var; do
        if [ ! -f $2/data/${var}_${timeperiod}_ssp370.nc ]
          then bash bashscripts/dl_climssptime.sh $var $2 ssp370 $timeperiod &
        fi
    done < "$1"
    wait
    echo "Time: $(date). (model $2) - End download of ssp370, $timeperiod" >> dlclim.log
done < "$3"

wait

# Loop on all time periods to download future data from model $2, ssp585
while read timeperiod; do
    # Loop on all variables to download data from model $2 
    while read var; do
        if [ ! -f $2/data/${var}_${timeperiod}_ssp585.nc ]
          then bash bashscripts/dl_climssptime.sh $var $2 ssp585 $timeperiod &
        fi
    done < "$1"
    wait
    echo "Time: $(date). (model $2) - End download of ssp585, $timeperiod" >> dlclim.log
done < "$3"

wait

# Download altitude data
if [ ! -f $2/data/elevation.nc ]
    then 
        wget https://files.isimip.org/ISIMIP3a/SecondaryInputData/climate/atmosphere/obsclim/global/daily/historical/W5E5v2.0/orog_W5E5v2.0.nc
        mv orog_W5E5v2.0.nc $2/data/elevation.nc
fi

# Calculate wai and pet for historical data 
# Loop on all time periods to calculate future sgdd and wai from model $2, ssp126
while read timeperiodhist; do
    # Identify the first year of the time period
    year1=$(echo "$timeperiodhist" | cut -d '_' -f 1)
    # If wai and sgdd already downloaded, don't do anything
    if [ ! -f $2/output/hist/wai_${year1}.nc ]
      then bash bashscripts/get_wai_sgdd.sh $timeperiodhist $2 ssp126 &
    fi
done < "$4"

wait
echo "Time: $(date). (model $2) - End calculation of historical sgdd and wai" >> dlclim.log

# Loop on all time periods to calculate future sgdd and wai from model $2, ssp126
while read timeperiod; do
    # Identify the first year of the time period
    year1=$(echo "$timeperiod" | cut -d '_' -f 1)
    # If wai and sgdd already downloaded, don't do anything
    if [ ! -f $2/output/ssp126/wai_${year1}.nc ]
      then bash bashscripts/get_wai_sgdd.sh $timeperiod $2 ssp126 &
    fi
done < "$3"

wait
echo "Time: $(date). (model $2) - End calculation of future sgdd and wai with ssp126" >> dlclim.log

# Loop on all time periods to calculate future sgdd and wai from model $2, ssp370
while read timeperiod; do
    # Identify the first year of the time period
    year1=$(echo "$timeperiod" | cut -d '_' -f 1)
    # If wai and sgdd already downloaded, don't do anything
    if [ ! -f $2/output/ssp370/wai_${year1}.nc ]
      then bash bashscripts/get_wai_sgdd.sh $timeperiod $2 ssp370 &
    fi
done < "$3"

wait
echo "Time: $(date). (model $2) - End calculation of future sgdd and wai with ssp370" >> dlclim.log


# Loop on all time periods to calculate future sgdd and wai from model $2, ssp585
while read timeperiod; do
    # Identify the first year of the time period
    year1=$(echo "$timeperiod" | cut -d '_' -f 1)
    # If wai and sgdd already downloaded, don't do anything
    if [ ! -f $2/output/ssp585/wai_${year1}.nc ]
      then bash bashscripts/get_wai_sgdd.sh $timeperiod $2 ssp585 &
    fi
done < "$3"

wait
echo "Time: $(date). (model $2) - End calculation of future sgdd and wai with ssp585" >> dlclim.log


echo "Time: $(date). End script" >> dlclim.log
