# Overview
### Description
This project is used to integrate "Software name" and Acquisition Companies.  
It use [FastAPI](https://fastapi.tiangolo.com/).
FASTAPI uses `/importItem` endpoint
Returned data from Acquisition are stored in ImportItemLog

### Process description
**Import of items**<br>
User presses button<br>
Selects company from dropdown list<br>
Inserts Item number.<br>
Procedure `ImportItem` is executed.<br>
This procedure calls endpoint and inserts data fetched from acquired company to log.<br>
Procedure `ImportItem_insert` collects data from log and run process of validation and inserts data to tables.

### Dependencies
SQL DB
```
procedures:
    ImportItem
    ImportItem_insert
```

# Structure
`main.py` --> Main file with API endpoints  <br>
`gunicorn.py` --> File used for running FastAPI using Gunicorn <br>
`config/` --> folder for configuration files <br>
`lib/` --> folder for classes used in API  <br>
`models/` --> folder for pydantic models  <br>

# Contributing

# Deployment

## New machine
1. Add new service to systemd
```bash
sudo nano /etc/systemd/system/itemImport.service
```
```bash
# gunicorn.service
# For running Gunicorn based application with a config file - TutLinks.com
#
# This file is referenced from official repo of TutLinks.com
# https://github.com/windson/fastapi/blob/fastapi-postgresql-caddy-ubuntu-deploy/gunicorn.service
#
[Unit]
Description=Item Import from Acquisition Uvicorn App
After=network.target

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=/opt/importItem
Environment="PATH=/home/ubuntu/virtual_environments/venv_importItem/bin"
ExecStart=/opt/importItem/run_importItem.sh

[Install]
WantedBy=multi-user.target

```
```bash
sudo systemctl daemon-reload
```
2. Install SqlAnywhere17 driver to `/opt/sqlanywhere17`
```bash
https://medium.com/@mikekenneth77/python-connect-to-sybase-sap-database-linux-based-os-only-17691c013661
```
3. Edit `/opt/sqlanywhere17/bin32/sa_config.sh`
```bash
add LD_LIBRARY_PATH="/lib/x86_64-linux-gnu/:${LD_LIBRARY_PATH:-}"
```

