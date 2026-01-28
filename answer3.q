\p 5050 / make sure port set for pykx connection
\l pykx.q / for future plotting

// Step 1. Load table data into memory
  / a. Weather data from day 1
.pq:use`kx.pq;
weather:select from .pq.pq`:weather.parquet;
  / b. Vitals data from day 3
vitals:("PIE";enlist ",") 0: `:vitals.csv;

// Step 2. Join weather data at time of vital 
vitalsWeather:aj[`time;vitals;weather];

// Step 3. Add plot tool inside q session (just to keep it one script - would be better in python session)
.pykx.pyexec"import matplotlib.pyplot as plt";
.pykx.pyexec"import numpy as np";
.pykx.set[`heartRate;exec heartRate from vitalsWeather];
.pykx.set[`temperatureF;exec temperatureF from vitalsWeather];
genPlot:{
  .pykx.pyexec"plt.scatter(heartRate, temperatureF)";
  .pykx.pyexec"plt.xlabel('Heart Rate (bpm)')";
  .pykx.pyexec"plt.ylabel('Temperature (F)')";
  .pykx.pyexec"plt.title('Heart Rate vs Temperature')";
  }`;
.pykx.pyexec"plt.show()";

// Step 4. Add additional lines to visualize cut off
genPlot`; / re generate plot details
.pykx.pyexec"plt.axvline(x=100, color='red', linestyle='--', linewidth=2, label='Heart Rate = 100')";
.pykx.pyexec"plt.axhline(y=100, color='red', linestyle='--', linewidth=2, label='Temperature = 77')";
.pykx.pyexec"plt.show()";

select from vitalsWeather where heartRate>100,temperatureF>77; / would also return answer
`x xdesc select count i by sensorId from vitalsWeather;
count select from vitalsWeather where heartRate>100,temperatureF>77;
select count i by 60 xbar time.minute from vitalsWeather where heartRate>100,temperatureF>77;
