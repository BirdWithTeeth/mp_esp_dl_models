include(${MICROPY_DIR}/py/py.cmake)

add_library(usermod_mp_esp_dl INTERFACE)

target_include_directories(usermod_mp_esp_dl INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}
)

target_sources(usermod_mp_esp_dl INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/mp_esp_dl_module.c
)

if (MP_DL_FACE_DETECTOR_ENABLED)
    message(STATUS "Adding face detector model binding")
    target_compile_definitions(usermod_mp_esp_dl INTERFACE MP_DL_FACE_DETECTOR_ENABLED=1)
    add_dependencies(usermod_mp_esp_dl human_face_detect)
    target_sources(usermod_mp_esp_dl INTERFACE 
        ${CMAKE_CURRENT_LIST_DIR}/esp_face_detector.cpp
    )
endif()

if (MP_DL_IMAGENET_CLS_ENABLED)
    message(STATUS "Adding imagenet_cls model binding")
    target_compile_definitions(usermod_mp_esp_dl INTERFACE MP_DL_IMAGENET_CLS_ENABLED=1)
    add_dependencies(usermod_mp_esp_dl imagenet_cls)
    target_sources(usermod_mp_esp_dl INTERFACE 
        ${CMAKE_CURRENT_LIST_DIR}/esp_imagenet_cls.cpp
    )
endif()

if (MP_DL_PEDESTRIAN_DETECTOR_ENABLED)
    message(STATUS "Adding pedestrian_detect model binding")
    target_compile_definitions(usermod_mp_esp_dl INTERFACE MP_DL_PEDESTRIAN_DETECTOR_ENABLED=1)
    add_dependencies(usermod_mp_esp_dl pedestrian_detect)
    target_sources(usermod_mp_esp_dl INTERFACE 
        ${CMAKE_CURRENT_LIST_DIR}/esp_human_detector.cpp
    )
endif()

if (MP_DL_FACE_RECOGNITION_ENABLED)
    message(STATUS "Adding face_recognition model binding")
    target_compile_definitions(usermod_mp_esp_dl INTERFACE MP_DL_FACE_RECOGNITION_ENABLED=1)
    add_dependencies(usermod_mp_esp_dl human_face_recognition)
    target_compile_options(usermod INTERFACE $<$<COMPILE_LANGUAGE:CXX>:-frtti>)
    target_sources(usermod_mp_esp_dl INTERFACE 
        ${CMAKE_CURRENT_LIST_DIR}/esp_face_recognition.cpp
        ${CMAKE_CURRENT_LIST_DIR}/lib/mp_esp_dl_recognition_database.cpp
        ${CMAKE_CURRENT_LIST_DIR}/lib/mp_esp_dl_human_face_recognition.cpp
        ${CMAKE_CURRENT_LIST_DIR}/lib/mpfile.c
    )
endif()

if (MP_DL_COCO_DETECTOR_ENABLED)
    message(STATUS "Adding coco_detect model binding")
    target_compile_definitions(usermod_mp_esp_dl INTERFACE MP_DL_COCO_DETECTOR_ENABLED=1)
    add_dependencies(usermod_mp_esp_dl coco_detect)
    target_sources(usermod_mp_esp_dl INTERFACE 
        ${CMAKE_CURRENT_LIST_DIR}/esp_coco_detector.cpp
    )
endif()

if (MP_DL_CAT_DETECTOR_ENABLED)
    message(STATUS "Adding cat_detect model binding")
    target_compile_definitions(usermod_mp_esp_dl INTERFACE MP_DL_CAT_DETECTOR_ENABLED=1)
    add_dependencies(usermod_mp_esp_dl cat_detect)
    target_sources(usermod_mp_esp_dl INTERFACE 
        ${CMAKE_CURRENT_LIST_DIR}/esp_cat_detector.cpp
    )
endif()

# --- Cloned external modules (camera + jpeg) ---
# The workflow clones these into <workspace>/../ext_modules. Each repo keeps
# its micropython.cmake at the repo root; "src/" is tried as a fallback.
set(EXT_MODULES_DIR "${CMAKE_CURRENT_LIST_DIR}/../../ext_modules")

set(CAMERA_FOUND FALSE)
foreach(_cand "micropython.cmake" "src/micropython.cmake")
    set(_p "${EXT_MODULES_DIR}/micropython-camera-API/${_cand}")
    if(EXISTS "${_p}")
        message(STATUS "Including micropython-camera-API from ${_p}")
        include("${_p}")
        set(CAMERA_FOUND TRUE)
        break()
    endif()
endforeach()
if(NOT CAMERA_FOUND)
    message(WARNING "micropython-camera-API cmake file not found under ${EXT_MODULES_DIR}/micropython-camera-API")
endif()

set(JPEG_FOUND FALSE)
foreach(_cand "micropython.cmake" "src/micropython.cmake")
    set(_p "${EXT_MODULES_DIR}/mp_jpeg/${_cand}")
    if(EXISTS "${_p}")
        message(STATUS "Including mp_jpeg from ${_p}")
        include("${_p}")
        set(JPEG_FOUND TRUE)
        break()
    endif()
endforeach()
if(NOT JPEG_FOUND)
    message(WARNING "mp_jpeg cmake file not found under ${EXT_MODULES_DIR}/mp_jpeg")
endif()

# Deactivate ROM text compression for module
target_compile_definitions(usermod_mp_esp_dl INTERFACE 
    MICROPY_ROM_TEXT_COMPRESSION=0
)

target_link_libraries(usermod INTERFACE usermod_mp_esp_dl)

micropy_gather_target_properties(usermod_mp_esp_dl)
