#!/bin/sh

# location of openvibe acquisiton server binary
OV_SERVER_BIN="ov-server-0.18"

# location of openvibe acquisiton server config file
OV_SERVER_CONF="./ov-acquisition-server_processing.conf"

# launch ov server
$OV_SERVER_BIN --config $OV_SERVER_CONF

