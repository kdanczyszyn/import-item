from config.companiesDict import companies
import json
import sqlanydb
import os
import importlib


class Acquisition:
    def __init__(self, ftgnr : str) -> None:

        self.company_name = companies.get(ftgnr)
        if self.company_name is None:
            raise ValueError(f"Company {ftgnr} not exists in this integration. Contact support.")

        self.company_data = self.__load_company_data(self.company_name)
               
    def __load_company_data(self, company_name: str) -> dict:
        try:
            module_path = os.path.join("config", f"{company_name}.py")
            module_name = f"{company_name}"
            spec = importlib.util.spec_from_file_location(module_name, module_path)
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)

            return module.main
        except FileNotFoundError:
            raise ValueError(f"Module for {company_name} does not exists.")

    def __connect(self):
        if self.company_data.get('driver') == "sqlanydb":
            try:
                database_name = self.company_data.get('dbname')
                server = self.company_data.get('server')
                user = self.company_data.get('user')
                pwd = self.company_data.get('password')
                ip = self.company_data.get('ip')

                cnxn = sqlanydb.connect(
                    host=ip,
                    server=server,
                    DatabaseName=database_name,
                    userid=user,
                    password=pwd
                )

                return cnxn
            except Exception as e:
                return f"Error when connecting to {self.company_name} Database - SQL Anywhere 17"
        else:
            # future drivers goes here
            return "Driver not exists."

    def _run_query(self, query):
        cnxn = self.__connect()
        if type(cnxn) == str:
            return cnxn

        cursor = cnxn.cursor()
        cursor.execute(query)
        desc = cursor.description

        columns = [column[0] for column in desc]

        rowset = cursor.fetchall()

        if len(rowset) == 0:
            raise ValueError('Item does not exists in this company.')

        result = [{col: value for (col, value) in zip(columns, item)} for item in rowset]

        return result[0]

    def get_item(self, item):
        query = self.company_data.get('selectItem').format(item)
        return self._run_query(query)


    def start_export_process(self, item):
        return self.get_item(item)
        