#!/usr/bin/sh
. /home/ubuntu/virtual_environments/venv_importItem/bin/activate
. /opt/sqlanywhere17/bin64/sa_config.sh
gunicorn --config gunicorn.py main:app
