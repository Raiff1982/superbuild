## Copyright 2021 Intel Corporation
## SPDX-License-Identifier: Apache-2.0

set(SNAPPY_VERSION 1.1.9)

set(COMPONENT_NAME snappy)

if (INSTALL_IN_SEPARATE_DIRECTORIES)
  set(COMPONENT_PATH ${INSTALL_DIR_ABSOLUTE}/${COMPONENT_NAME})
else()
  set(COMPONENT_PATH ${INSTALL_DIR_ABSOLUTE})
endif()

ExternalProject_Add(${COMPONENT_NAME}
  URL "https://github.com/google/snappy/archive/refs/tags/${SNAPPY_VERSION}.zip"

  # # Skip updating on subsequent builds (faster)
  UPDATE_COMMAND ""

  CMAKE_ARGS
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
    -DCMAKE_INSTALL_PREFIX:PATH=${COMPONENT_PATH}
    -DBUILD_SHARED_LIBS:BOOL=OFF
    -DSNAPPY_BUILD_TESTS:BOOL=OFF
    -DSNAPPY_BUILD_BENCHMARKS:BOOL=OFF
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
    -DCMAKE_BUILD_TYPE=${DEPENDENCIES_BUILD_TYPE}
)

list(APPEND CMAKE_PREFIX_PATH ${COMPONENT_PATH})
string(REPLACE ";" "|" CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
