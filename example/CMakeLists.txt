cmake_minimum_required (VERSION 3.5)

project (MyCoolProject)

find_package(CMakeDebSrc)

SET(PPA "ppa:kevin-demarco/cmake-project-template" CACHE STRING "Launchpad PPA for dput.")
SET(GPG_KEY_ID "3951DA01" CACHE STRING "GPG Key ID on local system.")
SET(DISTRIBUTION "xenial" CACHE STRING "Target Linux distribution.")
SET(ARCHITECTURES "amd64 i386 armhf arm64" CACHE STRING "Possible build architectures.")

BuildDebSrcFromRepo(
  NAME "pybind11"
  DISTRIBUTION ${DISTRIBUTION}
  ARCHITECTURES ${ARCHITECTURES_LIST}
  DEBIAN_DIR ${CMAKE_SOURCE_DIR}/packages/pybind11/debian
  GIT_REPOSITORY https://github.com/pybind/pybind11.git
  GIT_TAG 13d8cd2cc7566de34d724f428ea7a6b6448d6a0c
  SOURCE_VERSION 0.1
  PPA_VERSION_NUMBER 3
  PPA ${PPA}
  GPG_KEY_ID ${GPG_KEY_ID}
  UPDATE_COMMAND ""
  PATCH_COMMAND ""
  CONFIGURE_COMMAND ""
  )

#BuildDebSrcFromDir(
#  NAME "pybind11"
#  PROJECT_DIRECTORY /path/to/pybind11
#  DISTRIBUTION ${DISTRIBUTION}
#  ARCHITECTURES ${ARCHITECTURES_LIST}
#  DEBIAN_DIR ${CMAKE_SOURCE_DIR}/packages/pybind11/debian
#  SOURCE_VERSION 0.1
#  PPA_VERSION_NUMBER 3
#  PPA ${PPA}
#  GPG_KEY_ID ${GPG_KEY_ID}
#  UPDATE_COMMAND ""
#  PATCH_COMMAND ""
#  CONFIGURE_COMMAND ""
#  )

BuildDebSrcFromDir(
  NAME "scrimmage"
  PROJECT_DIRECTORY /home/syllogismrxs/scrimmage/scrimmage
  DISTRIBUTION ${DISTRIBUTION}
  ARCHITECTURES ${ARCHITECTURES_LIST}
  DEBIAN_DIR ${CMAKE_SOURCE_DIR}/packages/scrimmage/debian
  SOURCE_VERSION 0.1
  PPA_VERSION_NUMBER 0
  PPA ${PPA}
  GPG_KEY_ID ${GPG_KEY_ID}
  UPDATE_COMMAND ""
  PATCH_COMMAND ""
  CONFIGURE_COMMAND ""
  )
