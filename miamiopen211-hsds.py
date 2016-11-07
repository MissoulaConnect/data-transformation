import os
import sys
import pandas as pd
from time import strftime
from sqlalchemy import create_engine # database connection
from sqlalchemy import text
from sqlalchemy.orm import sessionmaker 

def main():
    os.system('clear')
    print('*************************')
    print('Miami Open211 ETL to HSDS')
    print('*************************')
    print('')
    print(strftime('%X'), 'Connecting to Miami Open211 SQL Server')
    
    # Connect to Maimi DB
    try:
        #engine = create_engine('mssql+pyodbc:///cr:communityresource2016!@localhost:1433?driver=SQL+Server+Native+Client+11.0/community_resource', echo=False) 
        engine = create_engine('mssql+pymssql://cr:communityresource2016!@localhost:1433/community_resource', echo=False)
        Session = sessionmaker(bind=engine)
        Session.configure(bind=engine)
        session = Session()   
        print(strftime('%X'), 'Connected to database')        
    except:
        print(strftime('%X'), 'Error opening database:', sys.exc_info()[0])    
        return

    # Get tables: provider, provider_target_population, provider_taxonomy
    sqlQuery = text("""
        select * from dbo.provider;
    """)        
    dfProvider = pd.read_sql_query(sqlQuery, engine)    
    print(strftime('%X'), 'Provider:   ', "{:,}".format(dfProvider.shape[0]))
    
    sqlQuery = text("""
        select * from dbo.provider_target_population;
    """)        
    dfTargetPopulation = pd.read_sql_query(sqlQuery, engine)    
    print(strftime('%X'), 'Target Population:   ', "{:,}".format(dfTargetPopulation.shape[0]))
        
    sqlQuery = text("""
        select * from dbo.provider_taxonomy;
    """)        
    dfTaxonomy = pd.read_sql_query(sqlQuery, engine)    
    print(strftime('%X'), 'Taxonomy:   ', "{:,}".format(dfTaxonomy.shape[0]))
        
    print(strftime('%X'), 'Complete')    
if __name__ == "__main__":
    main()
