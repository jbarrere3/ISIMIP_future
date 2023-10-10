#!/bin/bash

# Arguments : 1 = csv file with all variables, 2 = model for which to extract data, 3 = csv file with future time periods

# Inform the log file
echo "Time: $(date). Begin script" >> dlclim.log

# Create directory for the model if it doesn't exist
if [ ! -d ${2} ]
  then mkdir ${2}
fi

# Loop on all variables to download data from model $2 (historical data)
while read variables; do
    if [ ! -f $2/${variables}_2011_2014.nc ]
      then bash dl_historical.sh $variables $2 &
    fi
done < "$1"

wait

echo "Time: $(date). (model $2) - End download of historical data" >> dlclim.log

# Loop on all time periods to download future data from model $2, ssp126
while read timeperiod; do
    # Loop on all variables to download data from model $2 (historical data)
    while read var; do
        if [ ! -f $2/${var}_${timeperiod}_ssp126.nc ]
          then bash dl_climssptime.sh $var $2 ssp126 $timeperiod &
        fi
    done < "$1"
    wait
    echo "Time: $(date). (model $2) - End download of ssp126, $timeperiod" >> dlclim.log
done < "$3"

wait

echo "Time: $(date). End script" >> dlclim.log