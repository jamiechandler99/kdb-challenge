
.pq:use`kx.pq;

/ assumes linux and src in $HOME for directory obfuscation - can overwrite with any DB path
HDB_ROOT:"src/kdb-challenge/data";
HDB_ROOT:sv["/";] (getenv`HOME;HDB_ROOT);

// Step 1. Save weather data from day in partitioned database
  / a. Load in weather data and prep for save down
weather:select from .pq.pq`:weather.parquet;
weather:`time xasc select date:`date$time,time,sensorId,temperatureF,humidity from weather;
  / b. Save data to date partition database 
writeP:{[hdbroot;tn;pcol;data;dt]
  @[`.;tn;:;delete date from select from data where date=dt];
  .Q.dpft[hdbroot;dt;pcol;tn]; 
  };
writeP[hsym `$HDB_ROOT;`weather;`sensorId;weather] each distinct exec date from weather;

// Step 2. Load in database
delete weather from `.; / clear context to test load in database weather (rather then start new instance)
system"l ",HDB_ROOT;
  / a. Load in dbmaint and add derived colum temperatureC
    / dbmaint available : https://github.com/KxSystems/kdb/tree/master/utils
system"l ../dbmaint.q";
copycol[`:.;`weather;`temperatureF;`temperatureC]; / copy temperatureF to init temperatureC
fncol[`:.;`weather;`temperatureC;{(x-32)*5%9}]; / run conversion over temperatureC
reordercols[`:.;`weather;`sensorId`time`temperatureF`temperatureC`humidity];
system"l ",HDB_ROOT; / reload to pick up changes
  / b. Rename sensorID -> sensorTemp
renamecol[`:.;`weather;`sensorId;`sensorTemp];
system"l ",HDB_ROOT;




