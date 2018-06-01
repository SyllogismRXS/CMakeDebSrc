include(CMakeParseArguments)

function(BuildDeb)
  set(options "")
  set(oneValueArgs NAME DEBIAN_DIR GIT_REPOSITORY GIT_TAG SOURCE_VERSION PPA PPA_VERSION_NUMBER PPA_VERSION_NUMBER_SUFFIX GPG_KEY_ID DISTRIBUTION ARCHITECTURES DEB_SRC_DIR)
  set(multiValueArgs)
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

  # Convert string to cmake list
  string(REPLACE " " ";" ARCHITECTURES ${ARCHITECTURES})

  if("${ARG_PPA_VERSION_NUMBER_SUFFIX}" STREQUAL "")
    set(ARG_PPA_VERSION_NUMBER_SUFFIX "0")
  endif()

  # Run a custom cmake script that copies the debian directory into the
  # respective source tree and configure the changelog file.
  add_custom_command(
    DEPENDS ${ARG_DEB_SRC_DIR} ${ARG_DEBIAN_DIR}
    COMMAND ${CMAKE_COMMAND}
    -DARG_SOURCE_VERSION=${ARG_SOURCE_VERSION}
    -DARG_PPA_VERSION_NUMBER=${ARG_PPA_VERSION_NUMBER}
    -DARG_PPA_VERSION_NUMBER_SUFFIX=${ARG_PPA_VERSION_NUMBER_SUFFIX}
    -DARG_DISTRIBUTION=${ARG_DISTRIBUTION}
    -DSRC_DIR=${ARG_DEBIAN_DIR}
    -DDEST_DIR=${CMAKE_BINARY_DIR}/src/${ARG_DEB_SRC_DIR}
    -P ${CMAKEDEBSRC_SHARE_INSTALL_DIR}/cmake/CMakeDebSrc/ConfigureDebianDir.cmake
    OUTPUT ${CMAKE_BINARY_DIR}/src/${ARG_DEB_SRC_DIR}/debian/changelog
    COMMENT "Configure Debian Directory"
    )

  # Generate the debian source package
  add_custom_target(
    ${ARG_NAME}-debuild
    DEPENDS ${CMAKE_BINARY_DIR}/src/${ARG_DEB_SRC_DIR}/debian/changelog
    COMMAND cd ${CMAKE_BINARY_DIR}/src && ${TAR} -acf ${ARG_NAME}_${ARG_SOURCE_VERSION}.${ARG_PPA_VERSION_NUMBER}.orig.tar.gz ${ARG_DEB_SRC_DIR} --exclude-vcs
    COMMAND cd ${CMAKE_BINARY_DIR}/src/${ARG_DEB_SRC_DIR} && ${DEBUILD} -i -S -sa -k${ARG_GPG_KEY_ID}
    COMMENT "Running debuild"
    OUTPUT ${CMAKE_BINARY_DIR}/src/${ARG_NAME}_${ARG_SOURCE_VERSION}.${ARG_PPA_VERSION_NUMBER}.orig.tar.gz
    )

  # Upload the debian source package to the Launchpad PPA
  add_custom_target(
    ${ARG_NAME}-upload-ppa
    DEPENDS ${ARG_NAME}-debuild
    COMMAND cd ${CMAKE_BINARY_DIR}/src && ${DPUT} ${ARG_PPA} ${ARG_NAME}_${ARG_SOURCE_VERSION}.${ARG_PPA_VERSION_NUMBER}-${ARG_PPA_VERSION_NUMBER}ppa${ARG_PPA_VERSION_NUMBER_SUFFIX}_source.changes
    )
  # Make all ppa projects not build by default
  set_target_properties(${ARG_NAME}-upload-ppa PROPERTIES EXCLUDE_FROM_ALL 1 EXCLUDE_FROM_DEFAULT_BUILD 1)

  # Create local test build targets for all possible architectures
  foreach (ARCHITECTURE ${ARCHITECTURES})
    add_custom_target(
      ${ARG_NAME}-${ARCHITECTURE}-local-test
      DEPENDS ${ARG_NAME}-debuild
      COMMAND cd ${CMAKE_BINARY_DIR}/src && sudo DIST=${ARG_DISTRIBUTION} ARCH=${ARCHITECTURE} ${PBUILDER} --build --buildresult ${CMAKE_BINARY_DIR}/${ARG_DISTRIBUTION}/${ARCHITECTURE} ${ARG_NAME}_${ARG_SOURCE_VERSION}.${ARG_PPA_VERSION_NUMBER}-${ARG_PPA_VERSION_NUMBER}ppa${ARG_PPA_VERSION_NUMBER_SUFFIX}.dsc
      )
  endforeach()
endfunction()

function(BuildDebSrcFromRepo)
  set(options "")
  set(oneValueArgs NAME DEBIAN_DIR GIT_REPOSITORY GIT_TAG SVN_REPOSITORY SVN_REVISION SVN_USERNAME SVN_PASSWORD SOURCE_VERSION PPA PPA_VERSION_NUMBER PPA_VERSION_NUMBER_SUFFIX GPG_KEY_ID DISTRIBUTION ARCHITECTURES)
  set(multiValueArgs CONFIGURE_COMMAND PATCH_COMMAND UPDATE_COMMAND)
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

  set(DEB_SRC_DIR ${ARG_NAME}-deb-src)

  # Use ExternalProject_Add to clone the source repository, checkout, and any
  # update or patch
  ExternalProject_Add(
    ${DEB_SRC_DIR}
    GIT_REPOSITORY ${ARG_GIT_REPOSITORY}
    GIT_TAG        ${ARG_GIT_TAG}
    SVN_REPOSITORY ${ARG_SVN_REPOSITORY}
    SVN_REVISION   ${ARG_SVN_REVISION}
    SVN_USERNAME   ${ARG_SVN_USERNAME}
    SVN_PASSWORD   ${ARG_SVN_PASSWORD}
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}
    BUILD_IN_SOURCE 1
    UPDATE_COMMAND "${ARG_UPDATE_COMMAND}"
    PATCH_COMMAND "${ARG_PATCH_COMMAND}"
    CONFIGURE_COMMAND "${ARG_CONFIGURE_COMMAND}"
    CMAKE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    )

  BuildDeb(
    NAME ${ARG_NAME}
    DEBIAN_DIR ${ARG_DEBIAN_DIR}
    SOURCE_VERSION ${ARG_SOURCE_VERSION}
    PPA ${ARG_PPA}
    PPA_VERSION_NUMBER ${ARG_PPA_VERSION_NUMBER}
    PPA_VERSION_NUMBER_SUFFIX ${ARG_PPA_VERSION_NUMBER_SUFFIX}
    GPG_KEY_ID ${ARG_GPG_KEY_ID}
    DISTRIBUTION ${ARG_DISTRIBUTION}
    ARCHITECTURES ${ARCHITECTURES}
    DEB_SRC_DIR ${DEB_SRC_DIR}
    )
endfunction()

function(BuildDebSrcFromDir)
  set(options "")
  set(oneValueArgs NAME PROJECT_DIRECTORY DEBIAN_DIR SOURCE_VERSION PPA PPA_VERSION_NUMBER PPA_VERSION_NUMBER_SUFFIX GPG_KEY_ID DISTRIBUTION ARCHITECTURES)
  set(multiValueArgs CONFIGURE_COMMAND PATCH_COMMAND UPDATE_COMMAND)
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

  set(DEB_SRC_DIR ${ARG_NAME}-deb-src)

  # Run a custom cmake script that copies the debian directory into the
  # respective source tree and configure the changelog file.
  add_custom_command(
    DEPENDS ${PROJECT_DIRECTORY}
    COMMAND ${CMAKE_COMMAND}
    -DSRC_DIR=${ARG_PROJECT_DIRECTORY}
    -DDEST_DIR=${CMAKE_BINARY_DIR}/src/${DEB_SRC_DIR}
    -P ${CMAKEDEBSRC_SHARE_INSTALL_DIR}/cmake/CMakeDebSrc/ConfigureProjectDir.cmake
    OUTPUT deb-dir-init
    COMMENT "Configure Project Directory"
    )

  add_custom_command(
    DEPENDS deb-dir-init
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/src/${DEB_SRC_DIR}
    COMMAND ${ARG_UPDATE_COMMAND}
    OUTPUT deb-dir-update
    COMMENT "Running update"
    )

  add_custom_command(
    DEPENDS deb-dir-update
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/src/${DEB_SRC_DIR}
    COMMAND ${ARG_PATCH_COMMAND}
    OUTPUT deb-dir-patch
    COMMENT "Running patch"
    )

  add_custom_command(
    DEPENDS deb-dir-patch
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/src/${DEB_SRC_DIR}
    COMMAND ${ARG_CONFIGURE_COMMAND}
    OUTPUT ${DEB_SRC_DIR}
    COMMENT "Running configure"
    )

  BuildDeb(
    NAME ${ARG_NAME}
    DEBIAN_DIR ${ARG_DEBIAN_DIR}
    SOURCE_VERSION ${ARG_SOURCE_VERSION}
    PPA ${ARG_PPA}
    PPA_VERSION_NUMBER ${ARG_PPA_VERSION_NUMBER}
    PPA_VERSION_NUMBER_SUFFIX ${ARG_PPA_VERSION_NUMBER_SUFFIX}
    GPG_KEY_ID ${ARG_GPG_KEY_ID}
    DISTRIBUTION ${ARG_DISTRIBUTION}
    ARCHITECTURES ${ARCHITECTURES}
    DEB_SRC_DIR ${DEB_SRC_DIR}
    )
endfunction()
