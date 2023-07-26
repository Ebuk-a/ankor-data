import requests
import pandas as pd
import sqlalchemy
from sqlalchemy import text

postgres_engine = sqlalchemy.create_engine('postgresql://airflow:airflow@localhost:5432/postgres', connect_args={'connect_timeout': 10}, echo=False)

def getAPIData():
    url= 'http://127.0.0.1:8000/myendpoint'
    response = requests.get(url)
    data = response.json()
    list_data = data['products']
    

    page_counter=1 #Initilize page number
    print(f" page {str(page_counter)} read") 
    
    #Read and merge all the list output from the json response, before converting to a dataframe
    while data['has_more']== 'yes':
            page_counter+=1
            response = requests.get(f"{url}?page={page_counter}")
            data = response.json()
            print(f" page {str(page_counter)} read")  
            list_data.extend(data['products'])

    df_data= pd.DataFrame(list_data)

    #Write dim_products to datalake. We could have writen the data directly to the database, trying to follow the task requirement.
    df_data.to_csv('./sql_test/datalake/dim_products.csv', header=True, index=False)

def testDWConnection(engine=postgres_engine):
    """Tests Connection to Database"""
    try:
        with engine.connect() as con:
            con.execute(text("SELECT 1"))
        print('engine is valid and running')
    except Exception as e:
        print(f'Engine invalid: {str(e)}')

def readCSV() -> pd.DataFrame:
    """ Read data from datalake"""
    dim_products= pd.read_csv('./sql_test/datalake/dim_products.csv')
    return dim_products

def writeToDW(dim_products:pd.DataFrame = readCSV()) -> pd.DataFrame:
    """Write data to database"""
    print("Testing SQL Server Connection...")
    testDWConnection()

    convert_dict = {'id': int,
                    'name': str, 
                    'price': int,
                    }
    dim_products = dim_products.astype(convert_dict)
    dim_products.to_sql('dim_products', con= postgres_engine, schema='public', if_exists='replace', method='multi', chunksize= 500, index= False,)
    return (dim_products.head)

def runETLProcess():
    print("Calling API data...")
    getAPIData()

    print('reading CSV and writing to database...')
    dim_products_head= writeToDW()
    return dim_products_head

if __name__=='__main__':
    print(runETLProcess())


    