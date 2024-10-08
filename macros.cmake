## Copyright 2020 Intel Corporation
## SPDX-License-Identifier: Apache-2.0

macro(append_cmake_prefix_path)
  list(APPEND CMAKE_PREFIX_PATH ${ARGN})
  string(REPLACE ";" "|" CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
endmacro()

macro(setup_subproject_path_vars _NAME)
  set(SUBPROJECT_NAME ${_NAME})

  set(SUBPROJECT_INSTALL_PATH ${INSTALL_DIR_ABSOLUTE})

  set(SUBPROJECT_SOURCE_PATH ${SUBPROJECT_NAME}/source)
  set(SUBPROJECT_STAMP_PATH ${SUBPROJECT_NAME}/stamp)
  set(SUBPROJECT_BUILD_PATH ${SUBPROJECT_NAME}/build)
endmacro()

macro(build_subproject)
  # See cmake_parse_arguments docs to see how args get parsed here:
  #    https://cmake.org/cmake/help/latest/command/cmake_parse_arguments.html
  set(oneValueArgs NAME URL CUSTOM_SOURCE_PACKAGE_PATH)
  set(multiValueArgs BUILD_ARGS DEPENDS_ON PATCH_COMMAND)
  cmake_parse_arguments(BUILD_SUBPROJECT "" "${oneValueArgs}"
                        "${multiValueArgs}" ${ARGN})

  # Setup SUBPROJECT_* variables (containing paths) for this function
  setup_subproject_path_vars(${BUILD_SUBPROJECT_NAME})

  message("CMAKE_PREFIX_PATH = ${CMAKE_PREFIX_PATH}")

  # Build the actual subproject
  ExternalProject_Add(${SUBPROJECT_NAME}
    PREFIX ${SUBPROJECT_NAME}
    DOWNLOAD_DIR ${SUBPROJECT_NAME}
    STAMP_DIR ${SUBPROJECT_STAMP_PATH}
    SOURCE_DIR ${SUBPROJECT_SOURCE_PATH}
    BINARY_DIR ${SUBPROJECT_BUILD_PATH}
    URL ${BUILD_SUBPROJECT_URL}
    LIST_SEPARATOR | # Use the alternate list separator
    CMAKE_ARGS
      -DCMAKE_BUILD_TYPE=Release
      -DCMAKE_NINJA_CMCLDEPS_RC=OFF
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_INSTALL_PREFIX:PATH=${SUBPROJECT_INSTALL_PATH}
      -DCMAKE_INSTALL_INCLUDEDIR=${CMAKE_INSTALL_INCLUDEDIR}
      -DCMAKE_INSTALL_LIBDIR=${CMAKE_INSTALL_LIBDIR}
      -DCMAKE_INSTALL_DOCDIR=${CMAKE_INSTALL_DOCDIR}
      -DCMAKE_INSTALL_BINDIR=${CMAKE_INSTALL_BINDIR}
      -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
      -DPython3_ROOT_DIR=${Python3_ROOT_DIR}
      ${BUILD_SUBPROJECT_BUILD_ARGS}
    BUILD_COMMAND ${DEFAULT_BUILD_COMMAND}
    PATCH_COMMAND ${BUILD_SUBPROJECT_PATCH_COMMAND}
    BUILD_ALWAYS OFF
  )

  if(BUILD_SUBPROJECT_DEPENDS_ON)
    ExternalProject_Add_StepDependencies(${SUBPROJECT_NAME}
      configure ${BUILD_SUBPROJECT_DEPENDS_ON}
    )
  endif()

  # Place installed component on CMAKE_PREFIX_PATH for downstream consumption
  append_cmake_prefix_path(${SUBPROJECT_INSTALL_PATH})
endmacro()