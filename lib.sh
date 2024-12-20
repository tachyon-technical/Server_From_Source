#!/usr/bin/env bash

###
### Logging
###

LOG_FILE="/tmp/cloudinit.log"
ERR_FILE="/tmp/cloudinit_err.log"

###
### Compilation
###

NGINX="https://nginx.org/"
OPENSSL="https://www.openssl.org/"

PREFIX_DIR="/opt/usr/local"
INCLUDE_DIR="$PREFIX_DIR/include"
LIB_DIR="$PREFIX_DIR/lib"
OPTIMIZATION='-O3 -march=native -funroll-loops'
DEPENDENCIES="https://raw.githubusercontent.com/tachyon-technical/Server_From_Source/refs/heads/main/dependencies.tar.xz"
DEPENDENCIES_SHA256SUM="https://raw.githubusercontent.com/tachyon-technical/Server_From_Source/refs/heads/main/dependencies.tar.xz.sha256sum"

PROCS=$(nproc)
if [ "$PROCS" -le "3" ];
  then echo "1" && export GCC_PROCS=1;
elif [ "$PROCS" -ge "4" ] && [ "$PROCS" -le "7" ];
  then echo "2" && export GCC_PROCS=2;
elif [ "$PROCS" -ge "8" ] && [ "$PROCS" -le "13" ];
  then export GCC_PROCS=4;
else
  export GCC_PROCS=6; fi
echo "$GCC_PROCS"


###
###  Functions
###

function execute_and_log {
        if
                SCRIPT=$2
		CMD_LINE=$3
                eval "$1" >/dev/null 2>>$ERR_FILE
        then
                echo -e "\tSuccess. [$SCRIPT - $CMD_LINE]" >>$LOG_FILE
        else
                echo -e "\tError. [$SCRIPT - $CMD_LINE]" >>$LOG_FILE
        fi
}

