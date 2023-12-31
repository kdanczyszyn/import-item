from pydantic import BaseModel

class ApiCallModel(BaseModel):
    item_number : str
    ftgnr : str
    perssign : str
    server : str
    dbname : str
    processid : str