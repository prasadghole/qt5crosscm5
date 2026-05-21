cmake_minimum_required(VERSION 3.10)
project(RemoteQtApp VERSION 1.0 LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 1. Force CMake to use the ARM64 Cross-Compilers
set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

# 2. TEACH CMAKE WHERE THE ARM64 QT5 LIBRARIES LIVE
# This points CMake to the exact folder containing the arm64 configuration files
set(CMAKE_PREFIX_PATH "/usr/lib/aarch64-linux-gnu/cmake/Qt5")
set(Qt5_DIR "/usr/lib/aarch64-linux-gnu/cmake/Qt5")

# Also tell CMake to look into the arm64 system roots for headers and libraries
set(CMAKE_FIND_ROOT_PATH /usr/lib/aarch64-linux-gnu)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# 3. Now find the package
find_package(Qt5 COMPONENTS Widgets REQUIRED)

add_executable(RemoteQtApp 
    main.cpp 
    mainwindow.cpp 
    mainwindow.h
)

target_link_libraries(RemoteQtApp Qt5::Widgets)