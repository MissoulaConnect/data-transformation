'''
    ETL Script to transform Miami Open211 data to HSDS format    
'''

import os
import sys
import ast
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
        # A1. Extract
        # If Extract Flag is True (default), download these tables from Miami's db
        #    1. Provider
        #    2. Provider Target Population
        #    3. Provider Taxonomy
        print(strftime('%X'), 'A1. Extract')
        print(strftime('%X'), 'Connecting to Miami Open211 SQL Server')

        # Connect to SQL server (ensure SSH tunnel is open if remote)
        try:
            engine = create_engine('mssql+pymssql://cr:communityresource2016!@localhost:1433/community_resource', echo=False)
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
            
    # A2. Transform
    # Add timestamp column to each table: indicates date and time downloaded in UTC
    # Index tables
    if extract:
        print(strftime('%X'), 'A2. Transform')
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
        
    # A3. Load    
    # Add tables to db
    #     Create the table if it doesn't exist
    #     Use src_ schema
    if extract:
        print(strftime('%X'), 'A3. Load')
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
    """
    Skipping this section for now        
    # B1. Merge
    # Create src_metadata if it doesn't exist
    # Save changes between versions [excluding timestamp]
    # Update m211_ tables    
    if extract:   
        print(strftime('%X'), 'B1. Merge')
        baseTableNames = ['provider', 'provider_taxonomy', 'provider_target_population']
        m211 = 'm211_'
        src = 'src_'
        
        # Create m211_ tables if they don't exist
        try:
            for baseTable in baseTableNames:
                if not engine.dialect.has_table(engine, m211+baseTable):  # If table don't exist, Create.
                    tableName = src+baseTable
                    sqlQuery = "select sql from sqlite_master where tbl_name = '"+tableName+"'"                
                    dfResult, returnCode = getTable(sqlQuery, tableName, engine)
                    dfResult['sql'] = dfResult['sql'].str.replace(src, m211)
                    for row in dfResult.iterrows():
                        result = engine.execute(row[1][0])
            session.commit()                 
            print(strftime('%X'), 'm211 tables created')                                        
        except:
            session.rollback()
            print(strftime('%X'), 'Error creating m211 tables:', sys.exc_info()[0])  
            print(sys.exc_info()[2])        
            return        

        # Fetch m211_ tables
        tableName = 'm211_provider'    
        sqlQuery = 'select * from ' + tableName + ';'   
        dfProviderM211 = pd.DataFrame()           
        dfProviderM211, returnCode = getTable(sqlQuery, tableName, engine)
        if returnCode is not None:
            return

        tableName = 'm211_provider_target_population'    
        sqlQuery = 'select * from ' + tableName + ';'   
        dfTargetPopulationM211 = pd.DataFrame()           
        dfTargetPopulationM211, returnCode = getTable(sqlQuery, tableName, engine)
        if returnCode is not None:
            return
            

        tableName = 'm211_provider_taxonomy'    
        sqlQuery = 'select * from ' + tableName + ';'   
        dfTaxonomyM211 = pd.DataFrame()           
        dfTaxonomyM211, returnCode = getTable(sqlQuery, tableName, engine)
        if returnCode is not None:
            return

        # Set the index and change the column order to match the src tables
        try:
            dfProviderM211.set_index(['provider_id'], inplace=True)
            dfProviderM211 = dfProviderM211[dfProvider.columns.values]
            dfTargetPopulationM211.set_index(['provider_service_code_id', 'target_population_code'], inplace=True)
            dfTaxonomyM211.set_index(['provider_service_code_id'], inplace=True)
            print(strftime('%X'), 'Added index(es) to m211 tables')
        except:
            print(strftime('%X'), 'Error adding index(es) to m211 tables:', sys.exc_info()[0])  
            print(sys.exc_info()[2])
            return

        ne_stacked = (dfProvider != dfProviderM211).stack()
        changed = ne_stacked[ne_stacked]
        changed.index.names = ['provider_id', 'col']
            
        differences = np.where(dfProvider != dfProviderM211)
        changed_from = dfProvider.values[differences]
        changed_to = dfProviderM211.values[differences]
        dfDiff = pd.DataFrame({'from': changed_from, 'to': changed_to}, index=changed.index)
   
        print(dfDiff.head())
        
        print(dfProvider.columns.values)
        print(dfProviderM211.columns.values)
        print(dfProvider.index)
        print(dfProviderM211.index)
    """
        
    # C1. Extract
    # Get subset of HSDS from existing data
    print(strftime('%X'), 'C1. Extract')
    
    # C2. Transform 
    # Apply necessary changes to make it hsds
    print(strftime('%X'), 'C2. Transform ')
    
    # C3. Load
    # Add data to table in hsds_ schema
    # Update hsds_metadata
    print(strftime('%X'), 'C3. Load')
    
    # D1. Export
    # Save data to csv files
    # Create json package file
    print(strftime('%X'), 'D1. Export')

    # Close connection
    try:
        session.close()
        engine.dispose()
        print(strftime('%X'), 'Disconnected from sqlite database')        
    except:
        print(strftime('%X'), 'Error closing sqlite database:', sys.exc_info()[0])    
        print(sys.exc_info()[2])
        
    print(strftime('%X'), 'Complete')    
if __name__ == "__main__":
    main()
