# ISIMIP_future

Bash script to download historical (2010-2014) and future (2015-2100) climatic data from the [ISIMIP](https://data.isimip.org/search/tree/ISIMIP3b/InputData/climate/) repository. 
Several climatic models are available in ISIMIP ([gdfl-esm4](https://www.gfdl.noaa.gov/earth-system-esm4/), [ipsl-cm6a-lr](https://cmc.ipsl.fr/ipsl-climate-models/ipsl-cm6/), 
[mpi-esm1-2-hr](https://gmd.copernicus.org/articles/12/3241/2019/), [mri-esm2-0](https://www.jstage.jst.go.jp/article/jmsj/advpub/0/advpub_2019-051/_article/-char/en) and 
[ukesm1-0-ll](https://ukesm.ac.uk/wp-content/uploads/2022/06/UKESM1-0-LL.html)). To download historical and future (scenario ssp127, ssp370 and ssp585) for a given model (e.g., mpi-esm1-2-hr), 
just run the following command from the terminal : 

```bash main.sh var.csv mpi-esm1-2-hr time_future.csv```

The script will create a folder named after the model and place all data cropped at European level in this folder. 

Note that the script is written to run on Linux operating system. Prior to lauch the script, make sure that [climate data operator (cdo)](https://code.mpimet.mpg.de/projects/cdo/wiki) is installed. 

