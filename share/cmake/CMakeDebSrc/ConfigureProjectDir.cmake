function(ConfigureProjectDir)
  # Copy debian directory into source tree
  file(COPY ${SRC_DIR}/ DESTINATION ${DEST_DIR})
  # Remove .git directory
  file(REMOVE_RECURSE ${DEST_DIR}/.git)
endfunction()

ConfigureProjectDir()
