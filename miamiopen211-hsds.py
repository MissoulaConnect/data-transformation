'''
    ETL Script to transform Miami Open211 data to HSDS format    
'''

import os
import sys
import ast
import glob
import sqlite3
import pymssql
import argparse
import datetime
import pandas as pd
from time import strftime
from sqlalchemy import create_engine # database connection
from sqlalchemy import text
from sqlalchemy.orm import sessionmaker 

def getTable(sqlQuery, tableName, engine):
    '''
        Returns a query or table from the provided database
    '''
    df = pd.DataFrame()
    returnCode = None
    try:
        df = pd.read_sql_query(sqlQuery, engine)    
        print(strftime('%X'), 'Fetching '+tableName+':', '{:,}'.format(df.shape[0]))    
    except:
        returnCode = sys.exc_info()[0]    
        print(strftime('%X'), 'Error fetching', tableName, ':', returnCode)
        print(sys.exc_info()[2])    
    return df, returnCode
    
def main():
    os.system('clear')
    print('*************************')
    print('Miami Open211 ETL to HSDS')
    print('*************************')
    print('')

    # Initialise
    parser = argparse.ArgumentParser()
    parser.add_argument('-p1', '--extract', help='Flag to extract data from Miami')
    args = parser.parse_args()

    databaseName = 'MiamiOpen211.db'
    outputFolder = 'miamiopen211'
    mssqlConnection = 'mssql+pymssql://cr:communityresource2016!@localhost:1433/community_resource'
    
    print('Parameters Provided')    
    print('-------------------')
    print('Extract Flag:',args.extract)
    print('Database Path:',databaseName)
    print('')
    
    # Check Params    
    if args.extract is not None and args.extract not in ["True","False"]:
        print(strftime('%X'), 'Error: Provide the extract flag as True/False/Leave blank')
        return
    
    if args.extract is None:
        args.extract = "True"        
    extract = ast.literal_eval(args.extract)
    
    # Start ETL
    print(strftime('%X'), 'Start')    
    if extract:
        # Extract
        # If Extract Flag is True (default), download these tables from Miami's db
        #    1. Provider
        #    2. Provider Target Population
        #    3. Provider Taxonomy
        print(strftime('%X'), 'Extract')
        print(strftime('%X'), 'Connecting to Miami Open211 SQL Server')

        # Connect to SQL server (ensure SSH tunnel is open if remote)
        try:
            engine = create_engine(mssqlConnection, echo=False)
            Session = sessionmaker(bind=engine)
            Session.configure(bind=engine)
            session = Session()   
            print(strftime('%X'), 'Connected to SQL Server database')        
        except:
            print(strftime('%X'), 'Error opening SQL Server database:', sys.exc_info()[0])    
            return
        
        # Fetch tables        
        tableName = 'dbo.provider'    
        sqlQuery = 'select * from ' + tableName + ';'   
        dfProvider = pd.DataFrame()           
        dfProvider, returnCode = getTable(sqlQuery, tableName, engine)
        if returnCode is not None:
            return

        tableName = 'dbo.provider_target_population'    
        sqlQuery = 'select * from ' + tableName + ';'   
        dfTargetPopulation = pd.DataFrame()           
        dfTargetPopulation, returnCode = getTable(sqlQuery, tableName, engine)
        if returnCode is not None:
            return
            

        tableName = 'dbo.provider_taxonomy'    
        sqlQuery = 'select * from ' + tableName + ';'   
        dfTaxonomy = pd.DataFrame()           
        dfTaxonomy, returnCode = getTable(sqlQuery, tableName, engine)
        if returnCode is not None:
            return

        # Close connection
        try:
            session.close()
            engine.dispose()
            print(strftime('%X'), 'Disconnected from SQL Server database')        
        except:
            print(strftime('%X'), 'Error closing database:', sys.exc_info()[0])    
            print(sys.exc_info()[2])
            
    # Transform
    # Add timestamp column to each table: indicates date and time downloaded in UTC
    # Index tables
    if extract:
        print(strftime('%X'), 'Transform')
        try:
            etl_timestamp = datetime.datetime.utcnow()    
            dfProvider['etl_timestamp'] = etl_timestamp
            dfTargetPopulation['etl_timestamp'] = etl_timestamp
            dfTaxonomy['etl_timestamp'] = etl_timestamp
            print(strftime('%X'), 'Added etl_timestamp: ',etl_timestamp)
        except:
            print(strftime('%X'), 'Error adding etl_timestamp:', sys.exc_info()[0])  
            print(sys.exc_info()[2])
            return
        
        try:
            dfProvider.set_index(['provider_id'], inplace=True)
            dfTargetPopulation.set_index(['provider_service_code_id', 'target_population_code'], inplace=True)
            dfTaxonomy.set_index(['provider_service_code_id'], inplace=True)
            print(strftime('%X'), 'Added index(es)')
        except:
            print(strftime('%X'), 'Error adding index(es):', sys.exc_info()[0])  
            print(sys.exc_info()[2])
            return

    # Connect to sqlite db   
    try:
        # Create DB if it doesn't exist
        conn = sqlite3.connect(databaseName)  
        conn.close()          
        
        # Connect with SQLAlchemy
        engine = create_engine('sqlite:///'+databaseName, echo=False)
        Session = sessionmaker(bind=engine)
        Session.configure(bind=engine)
        session = Session()   
        print(strftime('%X'), 'Connected to sqlite database')                                
    except:
        print(strftime('%X'), 'Error opening sqlite database:', sys.exc_info()[0])  
        print(sys.exc_info()[2])
        return
        
    # Load    
    # Add tables to db
    #     Create the table if it doesn't exist
    #     Use src_ schema
    if extract:
        print(strftime('%X'), 'Load')
        try:
            dfProvider.to_sql('src_provider', engine, if_exists='replace', index=True)
            dfTargetPopulation.to_sql('src_provider_target_population', engine, if_exists='replace', index=True)       
            dfTaxonomy.to_sql('src_provider_taxonomy', engine, if_exists='replace', index=True)         
            session.commit()                 
            print(strftime('%X'), 'Incoming tables saved')                                        
        except:
            session.rollback()
            print(strftime('%X'), 'Error saving incoming tables:', sys.exc_info()[0])  
            print(sys.exc_info()[2])        
            return        
            
        # Close connection
        try:
            session.close()
            engine.dispose()
            print(strftime('%X'), 'Disconnected from sqlite database')        
        except:
            print(strftime('%X'), 'Error closing sqlite database:', sys.exc_info()[0])    
            print(sys.exc_info()[2])
          
    # Extract & Transform
    # Get subset of HSDS from existing data
    #   Drop existing HSDS tables
    print(strftime('%X'), 'Extract')
    try:
        sqlScripts = sorted(glob.glob(os.path.join('sql-scripts', '*.sql')))
        print(strftime('%X'), len(sqlScripts),'SQL scripts to run')           
    except:
        session.rollback()
        print(strftime('%X'), 'Error retreiving SQL scripts:', sys.exc_info()[0])  
        print(sys.exc_info()[2])        
        return       

    print(strftime('%X'), 'Transform & Load')    
    try:
        for sqlScript in sqlScripts:
            sqlQuery = open(sqlScript, 'r').read()
            conn = sqlite3.connect(databaseName)
            c = conn.cursor()
            c.executescript(sqlQuery)
            conn.commit()
            c.close()
            conn.close() 
            print(strftime('%X'), 'Script:', os.path.split(sqlScript)[1])           
    except:
        session.rollback()
        print(strftime('%X'), 'Error running sql script', sqlScript, sys.exc_info()[0])  
        print(sys.exc_info()[2])        
        return        

    
    # D1. Export
    # Save data to csv files
    # Create json package file
    print(strftime('%X'), 'Export')
    
    # Fetch hsds tables        
    tableName = 'sqlite_master'    
    sqlQuery = "select name from " + tableName + " where name like 'hsds%' and type ='table';"
    dfHSDS = pd.DataFrame()           
    dfHSDS, returnCode = getTable(sqlQuery, tableName, engine)
    if returnCode is not None:
        return
    
    for index, row in dfHSDS.iterrows():
        tableName = row['name']
        sqlQuery = 'select * from ' + tableName + ';'
        df = pd.DataFrame()
        df, returnCode = getTable(sqlQuery, tableName, engine)
        if returnCode is not None:
            return
        
        try:
            csvName = tableName.replace('hsds_','')+'.csv'
            df.to_csv(os.path.join(outputFolder,csvName), index=False, float_format='%.f')    
            print(strftime('%X'), 'Create csv:', csvName)  
        except:
            print(strftime('%X'), 'Error creating csv', csvName, sys.exc_info()[0])  
            print(sys.exc_info()[2])        
            return        
              
    print(strftime('%X'), 'Complete')    
if __name__ == "__main__":
    main()
