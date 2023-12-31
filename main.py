from lib.database import Database
from lib.acquisition import Acquisition
from fastapi import FastAPI
from models.models import ApiCallModel
import os

app = FastAPI()

@app.post("/importItem")
def importItem(api_data: ApiCallModel):
    try:
        # variables
        server = api_data.server
        dbname = api_data.dbname
        ftgnr = api_data.ftgnr
        artnr = api_data.item_number   
        processid = api_data.processid
        
        # create acquisition object
        acquisition = Acquisition(ftgnr)

        # get item
        item_data = acquisition.start_export_process(artnr)
        
        return item_data
    except Exception as e:
        # create jeeves object    
        database = Database(server, dbname)
        
        database.update_log(artnr, str(e), processid, 'E')
        return {'status' : 'error', 'info': str(e)}

if __name__ =='__main__':
    import uvicorn 
    dir_path = os.path.dirname(os.path.realpath(__file__))
    if dir_path == "/home/ubuntu/itemImport":
        port = 8903
    else:
        port = 8900

    log_config = uvicorn.config.LOGGING_CONFIG
    log_config["formatters"]["default"]["fmt"] = "%(asctime)s [%(name)s] %(levelprefix)s %(message)s"
    log_config["formatters"]["access"]["fmt"] = '%(asctime)s [%(name)s] %(levelprefix)s %(client_addr)s - "%(request_line)s" %(status_code)s'
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True, debug=True, log_config=log_config)
