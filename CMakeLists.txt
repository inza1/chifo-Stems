cmake_minimum_required(VERSION 3.22)
if(APPLE)
  set(CMAKE_OSX_DEPLOYMENT_TARGET "10.13" CACHE STRING "")
  set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64" CACHE STRING "")
endif()
project(GeneralOsirisStems VERSION 1.0.0)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FetchContent)
FetchContent_Declare(JUCE
  GIT_REPOSITORY https://github.com/juce-framework/JUCE.git
  GIT_TAG 8.0.14
  GIT_SHALLOW ON
  PATCH_COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/patch_juce.cmake)
FetchContent_MakeAvailable(JUCE)

set(COPY_AFTER FALSE)
if(APPLE)
  set(COPY_AFTER TRUE)   # copie auto dans ~/Library/Audio/Plug-Ins
endif()

juce_add_plugin(OsirisStems
  COMPANY_NAME "General Osiris"
  PLUGIN_MANUFACTURER_CODE Gosi
  PLUGIN_CODE Osst
  FORMATS AU VST3 Standalone
  PRODUCT_NAME "General-Osiris Stems"
  BUNDLE_ID com.generalosiris.stems
  COPY_PLUGIN_AFTER_BUILD ${COPY_AFTER}
  IS_SYNTH FALSE
  NEEDS_MIDI_INPUT FALSE
  NEEDS_MIDI_OUTPUT FALSE
  AU_MAIN_TYPE kAudioUnitType_Effect
  VST3_CATEGORIES Fx)

option(OSIRIS_ONNX "Separation IA via ONNX Runtime" ON)
if(OSIRIS_ONNX)
  set(ORT_VER 1.17.3)
  if(WIN32)
    set(ORT_URL https://github.com/microsoft/onnxruntime/releases/download/v${ORT_VER}/onnxruntime-win-x64-${ORT_VER}.zip)
    set(ORT_LIB_REL lib/onnxruntime.dll)
    set(ORT_LIB_DST onnxruntime.dll)
    set(OSIRIS_DATA "$ENV{APPDATA}/General Osiris")
  elseif(APPLE)
    set(ORT_URL https://github.com/microsoft/onnxruntime/releases/download/v${ORT_VER}/onnxruntime-osx-universal2-${ORT_VER}.tgz)
    set(ORT_LIB_REL lib/libonnxruntime.${ORT_VER}.dylib)
    set(ORT_LIB_DST libonnxruntime.dylib)
    set(OSIRIS_DATA "$ENV{HOME}/Library/Application Support/General Osiris")
  else()
    message(FATAL_ERROR "ONNX : plateforme non geree (utilisez -DOSIRIS_ONNX=OFF)")
  endif()
  file(MAKE_DIRECTORY "${OSIRIS_DATA}/models")
  if(NOT EXISTS "${OSIRIS_DATA}/models/drumsep.json")   # ne jamais ecraser la config de l'utilisateur
    file(COPY_FILE "${CMAKE_SOURCE_DIR}/Models/drumsep.json" "${OSIRIS_DATA}/models/drumsep.json")
  endif()
  FetchContent_Declare(onnxruntime URL ${ORT_URL})
  FetchContent_MakeAvailable(onnxruntime)
endif()

juce_generate_juce_header(OsirisStems)

target_sources(OsirisStems PRIVATE
  Source/PluginProcessor.cpp
  Source/PluginEditor.cpp)

target_compile_definitions(OsirisStems PUBLIC
  JUCE_WEB_BROWSER=0 JUCE_USE_CURL=0 JUCE_VST3_CAN_REPLACE_VST2=0
  JUCE_DISPLAY_SPLASH_SCREEN=0)

if(OSIRIS_ONNX)
  target_include_directories(OsirisStems PRIVATE ${onnxruntime_SOURCE_DIR}/include)
  target_compile_definitions(OsirisStems PUBLIC OSIRIS_ONNX=1)
  # copie du runtime + exemple de config dans le dossier de donnees, et dans artefacts/ONNX_Runtime (pour la CI)
  add_custom_command(TARGET OsirisStems POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory "${OSIRIS_DATA}/models"
    COMMAND ${CMAKE_COMMAND} -E copy "${onnxruntime_SOURCE_DIR}/${ORT_LIB_REL}" "${OSIRIS_DATA}/${ORT_LIB_DST}"
    COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_SOURCE_DIR}/Models/drumsep.waveform.json.example" "${OSIRIS_DATA}/models/drumsep.waveform.json.example"
    COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/OsirisStems_artefacts/ONNX_Runtime/models"
    COMMAND ${CMAKE_COMMAND} -E copy "${onnxruntime_SOURCE_DIR}/${ORT_LIB_REL}" "${CMAKE_BINARY_DIR}/OsirisStems_artefacts/ONNX_Runtime/${ORT_LIB_DST}"
    COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_SOURCE_DIR}/Models/drumsep.json" "${CMAKE_BINARY_DIR}/OsirisStems_artefacts/ONNX_Runtime/models/drumsep.json")
else()
  target_compile_definitions(OsirisStems PUBLIC OSIRIS_ONNX=0)
endif()

if(MSVC)
  target_compile_options(OsirisStems PRIVATE /utf-8)
endif()

target_link_libraries(OsirisStems
  PRIVATE juce::juce_audio_utils juce::juce_dsp
  PUBLIC juce::juce_recommended_config_flags)
