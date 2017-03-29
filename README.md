Code to pull Miami Open211 data and transform to HSDS format

1. Run miamiopen211-hsds.py - this connects to the Miami Open211 database to pull down their data.
   The data is storied in MiamiOpen211.db and transformed using the scripts in sql-scripts to HSDS format.
   The data is output to csv files in the miamiopen211 folder.
   Pre-requisites: Must have an SSH connection to Miami Open211 servers: ssh -N -L 1433:12.0.106.247:1433 coop@dev3.default.opendataservices.uk0.bigv.io
   
2. Run etl_hsds_ohana.py - this converts the HSDS files to Ohana format, resolving the key differences that prevent loading.
   Converted files are stored in the ohana folder in the miamiopen211 folder.
   These files are ready for loading into Ohana.

