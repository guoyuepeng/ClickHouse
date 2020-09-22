if(NOT ARCH_ARM AND NOT OS_FREEBSD AND NOT APPLE AND USE_PROTOBUF)
    option(ENABLE_HDFS "Enable HDFS" ${ENABLE_LIBRARIES})
elseif(ENABLE_HDFS OR USE_INTERNAL_HDFS3_LIBRARY)
    message (${RECONFIGURE_MESSAGE_LEVEL} "Cannot use HDFS3 with current configuration")
endif()

if(NOT ENABLE_HDFS)
    if(USE_INTERNAL_HDFS3_LIBRARY)
        message (${RECONFIGURE_MESSAGE_LEVEL} "Cannot use internal HDFS3 library with ENABLE_HDFS3=OFF")
    endif()
    return()
endif()

option(USE_INTERNAL_HDFS3_LIBRARY "Set to FALSE to use system HDFS3 instead of bundled (experimental - set to OFF on your own risk)"
       ON) # We don't know any linux distribution with package for it

if(NOT EXISTS "${ClickHouse_SOURCE_DIR}/contrib/libhdfs3/include/hdfs/hdfs.h")
    if(USE_INTERNAL_HDFS3_LIBRARY)
        message(WARNING "submodule contrib/libhdfs3 is missing. to fix try run: \n git submodule update --init --recursive")
        message (${RECONFIGURE_MESSAGE_LEVEL} "Cannot use internal HDFS3 library")
        set(USE_INTERNAL_HDFS3_LIBRARY 0)
    endif()
    set(MISSING_INTERNAL_HDFS3_LIBRARY 1)
endif()

if(NOT USE_INTERNAL_HDFS3_LIBRARY)
    find_library(HDFS3_LIBRARY hdfs3)
    find_path(HDFS3_INCLUDE_DIR NAMES hdfs/hdfs.h PATHS ${HDFS3_INCLUDE_PATHS})
    if(NOT HDFS3_LIBRARY OR NOT HDFS3_INCLUDE_DIR)
        message (${RECONFIGURE_MESSAGE_LEVEL} "Cannot find system HDFS3 library")
    endif()
endif()

if(HDFS3_LIBRARY AND HDFS3_INCLUDE_DIR)
    set(USE_HDFS 1)
elseif(NOT MISSING_INTERNAL_HDFS3_LIBRARY AND LIBGSASL_LIBRARY AND LIBXML2_LIBRARIES)
    set(HDFS3_INCLUDE_DIR "${ClickHouse_SOURCE_DIR}/contrib/libhdfs3/include")
    set(HDFS3_LIBRARY hdfs3)
    set(USE_INTERNAL_HDFS3_LIBRARY 1)
    set(USE_HDFS 1)
else()
    message (${RECONFIGURE_MESSAGE_LEVEL} "Cannout enable HDFS3")
endif()

message(STATUS "Using hdfs3=${USE_HDFS}: ${HDFS3_INCLUDE_DIR} : ${HDFS3_LIBRARY}")
