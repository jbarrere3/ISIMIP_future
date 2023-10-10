#!/bin/bash

# Arguments : 1 = csv file with all variables, 2 = model for which to extract data, 3 = csv file with future time periods

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

# Loop on all variables to download future data from model $2, ssp126
while read timeperiod; do
    if [ ! -f $2/${variables}_2011_2014.nc ]
      then bash dl_historical.sh $variables $2 &
    fi
done < "$3"
