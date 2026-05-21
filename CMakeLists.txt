cmake_minimum_required(VERSION 3.10)
project(RemoteQtApp VERSION 1.0 LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find Qt5 (CMake will figure out which architecture based on the environment)
find_package(Qt5 COMPONENTS Widgets REQUIRED)

add_executable(RemoteQtApp 
    main.cpp 
    mainwindow.cpp 
    mainwindow.h
)

target_link_libraries(RemoteQtApp Qt5::Widgets)

target_link_libraries(RemoteQtApp Qt5::Widgets)