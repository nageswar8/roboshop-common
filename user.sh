#!/bin/bash

app_name="user"

source ./common.sh
CHECK_ROOT

CREATE_USER

APP_SETUP

NODE_SETUP

system_setup

PROCESS_TIME