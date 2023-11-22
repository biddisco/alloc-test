include(FetchContent)

# -------------------------------------------------------------
# get_external_project
# -------------------------------------------------------------
function(get_external_project)
  cmake_parse_arguments(
    ARGS
    "DO_NOT_BUILD" # options
    "PROJECT_NAME;GIT_REPO;GIT_TAG;FOLDER_NAME" # 1 value args
    "" # multivalued args
    ${ARGN}
  )

  string(TOUPPER ${ARGS_PROJECT_NAME} UPPER_PROJECT)
  string(TOLOWER ${ARGS_PROJECT_NAME} LOWER_PROJECT)
  find_package(${ARGS_PROJECT_NAME} QUIET)

  if(NOT ${ARGS_PROJECT_NAME}_FOUND)
    # look in the current source tree
    if(ARGS_FOLDER_NAME)
      set(LOCAL_DIR ${PROJECT_SOURCE_DIR}/extern/${ARGS_FOLDER_NAME})
    else()
      set(LOCAL_DIR ${PROJECT_SOURCE_DIR}/extern/${ARGS_PROJECT_NAME})
    endif()
    if(EXISTS ${LOCAL_DIR}/.git)
      message(STATUS "ext: " "Using ${ARGS_PROJECT_NAME} in (${LOCAL_DIR})")
      # use the source in this directory
      set(FETCHCONTENT_SOURCE_DIR_${UPPER_PROJECT} ${LOCAL_DIR})
      # don't change branches, or pull
      set(FETCHCONTENT_UPDATES_DISCONNECTED_${UPPER_PROJECT} ON)
    endif()

    fetchcontent_declare(
      ${ARGS_PROJECT_NAME}
      GIT_REPOSITORY ${ARGS_GIT_REPO}
      GIT_TAG ${ARGS_GIT_TAG}
      GIT_SHALLOW TRUE
    )
    fetchcontent_getproperties(${ARGS_PROJECT_NAME})
    if(NOT ${ARGS_PROJECT_NAME}_POPULATED)
      fetchcontent_populate(${ARGS_PROJECT_NAME})
      if(NOT ${ARGS_DO_NOT_BUILD})
        add_subdirectory(
          ${${LOWER_PROJECT}_SOURCE_DIR} ${${LOWER_PROJECT}_BINARY_DIR}
        )
      endif()
    endif()
    # make location of project visible outside function
    set(${LOWER_PROJECT}_SOURCE_DIR
        "${${LOWER_PROJECT}_SOURCE_DIR}"
        PARENT_SCOPE
    )
    set(${LOWER_PROJECT}_BINARY_DIR
        "${${LOWER_PROJECT}_BINARY_DIR}"
        PARENT_SCOPE
    )
  endif()

endfunction(get_external_project)
