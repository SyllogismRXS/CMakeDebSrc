include(CMakeParseArguments)

function(BuildDebSrcFromRepo)
  set(options "")
  set(oneValueArgs NAME DEBIAN_DIR GIT_REPOSITORY GIT_TAG SOURCE_VERSION PPA PPA_VERSION_NUMBER PPA_VERSION_NUMBER_SUFFIX GPG_KEY_ID DISTRIBUTION ARCHITECTURES)
  set(multiValueArgs CONFIGURE_COMMAND PATCH_COMMAND UPDATE_COMMAND)
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

  if("${ARG_PPA_VERSION_NUMBER_SUFFIX}" STREQUAL "")
    set(ARG_PPA_VERSION_NUMBER_SUFFIX "0")
  endif()

  set(DEB_SRC_DIR ${ARG_NAME}-deb-src)

  # Use ExternalProject_Add to clone the source repository, checkout, and any
  # update or patch
  ExternalProject_Add(
    ${DEB_SRC_DIR}
    GIT_REPOSITORY ${ARG_GIT_REPOSITORY}
    GIT_TAG        ${ARG_GIT_TAG}
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}
    BUILD_IN_SOURCE 1
    UPDATE_COMMAND "${ARG_UPDATE_COMMAND}"
    PATCH_COMMAND "${ARG_PATCH_COMMAND}"
    CONFIGURE_COMMAND "${ARG_CONFIGURE_COMMAND}"
    CMAKE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    )

  # Run a custom cmake script that copies the debian directory into the
  # respective source tree and configure the changelog file.
  add_custom_command(
    DEPENDS ${DEB_SRC_DIR} ${ARG_DEBIAN_DIR}
    COMMAND ${CMAKE_COMMAND}
    -DARG_SOURCE_VERSION=${ARG_SOURCE_VERSION}
    -DARG_PPA_VERSION_NUMBER=${ARG_PPA_VERSION_NUMBER}
    -DARG_PPA_VERSION_NUMBER_SUFFIX=${ARG_PPA_VERSION_NUMBER_SUFFIX}
    -DSRC_DIR=${CMAKE_SOURCE_DIR}/packages/${ARG_NAME}
    -DDEST_DIR=${CMAKE_BINARY_DIR}/src/${DEB_SRC_DIR}
    -P ${CMAKEDEBSRC_SHARE_INSTALL_DIR}/cmake/CMakeDebSrc/ConfigureDebianDir.cmake
    OUTPUT ${CMAKE_BINARY_DIR}/src/${DEB_SRC_DIR}/debian
    )

  # Generate the debian source package
  add_custom_target(
    ${ARG_NAME}-debuild
    DEPENDS ${CMAKE_BINARY_DIR}/src/${DEB_SRC_DIR}/debian
    COMMAND cd ${CMAKE_BINARY_DIR}/src && ${TAR} -acf ${ARG_NAME}_${ARG_SOURCE_VERSION}.${ARG_PPA_VERSION_NUMBER}.orig.tar.gz ${DEB_SRC_DIR} --exclude-vcs
    COMMAND cd ${CMAKE_BINARY_DIR}/src/${DEB_SRC_DIR} && ${DEBUILD} -i -S -sa -k${ARG_GPG_KEY_ID}
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
      COMMAND cd ${CMAKE_BINARY_DIR}/src && sudo DIST=${ARG_DISTRIBUTION} ARCH=${ARCHITECTURE} ${PBUILDER} --build --distribution ${ARG_DISTRIBUTION} --architecture ${ARCHITECTURE} --basetgz /var/cache/pbuilder/${ARG_DISTRIBUTION}-${ARCHITECTURE}-base.tgz --buildresult ${CMAKE_BINARY_DIR}/${ARG_DISTRIBUTION}/${ARCHITECTURE} ${ARG_NAME}_${ARG_SOURCE_VERSION}.${ARG_PPA_VERSION_NUMBER}-${ARG_PPA_VERSION_NUMBER}ppa${ARG_PPA_VERSION_NUMBER_SUFFIX}.dsc
      )
  endforeach()
endfunction()

function(BuildDebSrcFromDir)
  set(options "")
  set(oneValueArgs NAME DIRECTORY SOURCE_VERSION PPA PPA_VERSION_NUMBER PPA_VERSION_NUMBER_SUFFIX GPG_KEY_ID DISTRIBUTION ARCHITECTURES)
  set(multiValueArgs)
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

  if("${ARG_PPA_VERSION_NUMBER_SUFFIX}" STREQUAL "")
    set(ARG_PPA_VERSION_NUMBER_SUFFIX "0")
  endif()

  set(DEB_SRC_DIR ${ARG_NAME}-deb-src)

  # Run a custom cmake script that copies the debian directory into the
  # respective source tree and configure the changelog file.
  add_custom_command(
    DEPENDS ${ARG_DIRECTORY}/debian
    COMMAND ${CMAKE_COMMAND}
    -DARG_SOURCE_VERSION=${ARG_SOURCE_VERSION}
    -DARG_PPA_VERSION_NUMBER=${ARG_PPA_VERSION_NUMBER}
    -DSRC_DIR=${CMAKE_SOURCE_DIR}/packages/${ARG_NAME}
    -DDEST_DIR=${CMAKE_BINARY_DIR}/src/${DEB_SRC_DIR}
    -P ${CMAKE_SOURCE_DIR}/cmake/Modules/ConfigureDebianDir.cmake
    OUTPUT ${CMAKE_BINARY_DIR}/src/${DEB_SRC_DIR}/debian
    )

  # Generate the debian source package
  add_custom_target(
    ${ARG_NAME}-debuild
    DEPENDS ${CMAKE_BINARY_DIR}/src/${DEB_SRC_DIR}/debian
    COMMAND cd ${CMAKE_BINARY_DIR}/src && ${TAR} -acf ${ARG_NAME}_${ARG_SOURCE_VERSION}.${ARG_PPA_VERSION_NUMBER}.orig.tar.gz ${DEB_SRC_DIR} --exclude-vcs
    COMMAND cd ${CMAKE_BINARY_DIR}/src/${DEB_SRC_DIR} && ${DEBUILD} -i -S -sa -k${ARG_GPG_KEY_ID}
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
      COMMAND cd ${CMAKE_BINARY_DIR}/src && sudo DIST=${ARG_DISTRIBUTION} ARCH=${ARCHITECTURE} ${PBUILDER} --build --distribution ${ARG_DISTRIBUTION} --architecture ${ARCHITECTURE} --basetgz /var/cache/pbuilder/${ARG_DISTRIBUTION}-${ARCHITECTURE}-base.tgz --buildresult ${CMAKE_BINARY_DIR}/${ARG_DISTRIBUTION}/${ARCHITECTURE} ${ARG_NAME}_${ARG_SOURCE_VERSION}.${ARG_PPA_VERSION_NUMBER}-${ARG_PPA_VERSION_NUMBER}ppa${ARG_PPA_VERSION_NUMBER_SUFFIX}.dsc
      )
  endforeach()
endfunction()
