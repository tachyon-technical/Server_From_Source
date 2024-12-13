#!/usr/bin/env bash

source dep_lib.sh

export CFLAGS="$OPTIMIZATION"
export CXXFLAGS="$OPTIMIZATION"
export INCLUDEDIR="$INCLUDE_DIR"
export LIBDIR="$LIB_DIR"
export PREFIX="$PREFIX_DIR"

echo "Running updates." >>$LOG_FILE
execute_and_log "apt-get update -y && apt upgrade -y" $0 $LINENO

echo "Installing dependencies." >>$LOG_FILE
execute_and_log "apt-get install -y git build-essential libpcre3 libpcre3-dev \
	zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev \
	uuid-dev ca-certificates cmake libtool" $0 $LINENO

echo "Moving to /tmp" >>$LOG_FILE
execute_and_log "cd /tmp" $0 $LINENO

echo "Downloading dependency bundle." >>$LOG_FILE
execute_and_log "wget -qN ${DEPENDENCIES} -O /tmp/dependencies.tar.xz" $0 $LINENO

echo "Downloading dependency bundle sha256 hash." >>$LOG_FILE
execute_and_log "wget -qN ${DEPENDENCIES_SHA256SUM} -O /tmp/dependencies.tar.xz.sha256" $0 $LINENO

echo "Verifying SHA256 checksum." >>$LOG_FILE
execute_and_log "sha256sum -c /tmp/dependencies.tar.xz.sha256" $0 $LINENO

echo "Extracting contents." >>$LOG_FILE
execute_and_log "tar xJf /tmp/dependencies.tar.xz" $0 $LINENO

echo "Entering brotli directory." >>$LOG_FILE
execute_and_log "cd $(ls -d /tmp/dependencies/brotli-*)" $0 $LINENO

echo "Compiling brotli" >>$LOG_FILE
execute_and_log "cmake \
	-DCMAKE_INSTALL_PREFIX=${PREFIX} \
	-DCMAKE_LIBRARY_PATH=${LIBDIR} \
	-DCMAKE_C_FLAGS=\"${OPTIMIZATION}\" \
	-DCMAKE_CXX_FLAGS=\"${OPTIMIZATION}\" && \
	make -j${GCC_PROCS} && \
	make install" $0 $LINENO

echo "Entering zlib directory."  >>$LOG_FILE
execute_and_log "cd $(ls -d /tmp/dependencies/zlib-*)" $0 $LINENO

echo "Compiling zlib."  >>$LOG_FILE
export INCLUDEDIR=$INCLUDE_DIR/zlib
execute_and_log "./configure --prefix=${PREFIX} \
	--includedir=${INCLUDEDIR} \
	--libdir=${LIBDIR} && \
	make -j${GCC_PROCS} && \
	make install" $0 $LINENO

echo "Entering zstd directory."  >>$LOG_FILE
execute_and_log "cd $(ls -d /tmp/dependencies/zstd-*)" $0 $LINENO

echo "Compiling zstd."  >>$LOG_FILE
export INCLUDEDIR=$INCLUDE_DIR/zstd
execute_and_log "make -j${GCC_PROCS} && \
        make install" $0 $LINENO

echo "Entering pcre2 directory."  >>$LOG_FILE
execute_and_log "cd $(ls -d /tmp/dependencies/pcre2-*)" $0 $LINENO

echo "Compiling pcre2."  >>$LOG_FILE
export INCLUDEDIR=$INCLUDE_DIR/pcre2
execute_and_log "./autogen.sh && \
        ./configure --prefix=${PREFIX} \
	--exec-prefix=${PREFIX} \
        --includedir=${INCLUDEDIR} \
        --libdir=${LIBDIR} \
	--enable-jit && \
        make -j${GCC_PROCS} && \
        make install" $0 $LINENO

echo "Entering libatomic directory."  >>$LOG_FILE
execute_and_log "cd $(ls -d /tmp/dependencies/libatomic_ops-*)" $0 $LINENO

echo "Compiling libatomic."  >>$LOG_FILE
export INCLUDEDIR=$INCLUDE_DIR/libatomic
execute_and_log "./autogen.sh && \
        ./configure --prefix=${PREFIX} \
        --exec-prefix=${PREFIX} \
        --includedir=${INCLUDEDIR} \
        --libdir=${LIBDIR} && \
        make -j${GCC_PROCS} && \
        make install" $0 $LINENO
