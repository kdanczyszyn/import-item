import json
import pyodbc

class Database:
    def __init__(self, server, dbname):
        with open("config/database.json") as data_file:
            self.config = json.load(data_file)
            self.server = server
            self.dbname = dbname

    def __connect(self):
        try:
            user = self.config[self.server]['user']
            pwd = self.config[self.server]['password']

            cnxn = pyodbc.connect(       
                driver='{ODBC Driver 17 for SQL Server}',       
                server=self.server,
                database=self.dbname,
                uid=user,
                pwd=pwd
            )
            return cnxn
        except Exception as e:
            # print (e)
            raise Exception("Error when connecting to SQL Database") 

    def update_log(self, artnr, message, processid, EI):
        cnxn = self.__connect()
        cursor = cnxn.cursor()

        message = str(message).replace('\'', '"')
                     
        query = """
        UPDATE [dbo].[ImportItemLog]
        SET [msg] = '{message}',
        [EI] = '{EI}',
        [ExternalNr] = '{artnr}'
        WHERE [processID] = '{processid}'
        """.format(message = message, processid = processid, artnr = artnr, EI=EI)
        cursor.execute(query)
        cursor.commit()
        cursor.close()
        cnxn.close()
