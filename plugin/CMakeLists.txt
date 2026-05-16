cmake_minimum_required(VERSION 3.16)
project(koretoggle-runner LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Qml)
qt_standard_project_setup()

qt_add_qml_module(koretogglerunner
    URI org.koretoggle.runner
    VERSION 1.0
    PLUGIN_TARGET koretogglerunner
    SOURCES
        commandrunner.cpp
        commandrunner.h
)

target_link_libraries(koretogglerunner PRIVATE Qt6::Core Qt6::Qml)

set(QML_INSTALL_DIR /usr/lib/qt6/qml/org/koretoggle/runner
    CACHE PATH "QML module install directory")

install(TARGETS koretogglerunner DESTINATION ${QML_INSTALL_DIR})
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/qmldir"
    "${CMAKE_CURRENT_BINARY_DIR}/koretogglerunner.qmltypes"
    DESTINATION ${QML_INSTALL_DIR}
)
