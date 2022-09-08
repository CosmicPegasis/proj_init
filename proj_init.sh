#!/bin/bash

# TODO Add git repo

# --- Colors ---
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

FATAL="${Red}[FATAL]${Color_Off}: "
INFO="[INFO]: "
SUCCESS="${Green}[SUCCESS]${Color_Off}: "


# --- Script Start ---
which cmake &> /dev/null || echo -e "${FATAL}cmake executable not found. Please install cmake and check your PATH variable."
which vcpkg &> /dev/null || echo -e "${FATAL}vcpkg executable not found. Please install vcpkg and check your PATH variable."

[ -z $1 ] && echo "${INFO}Initialising project in current directory"  || 
[ -z $1 ] || mkdir 

if [ -z $1 ]; then
    echo "${INFO}Initialising project in current directory"
else
    echo "${INFO}Intialising project in $1 sub directory."
    mkdir $1 &> /dev/null
    cd $1
fi


echo -e "${INFO}Making sub-directories."
{
mkdir lib
mkdir src
mkdir test
mkdir include
} &> /dev/null

echo -e "${INFO}Writing default CMakeLists.txt files."
cat > CMakeLists.txt <<EOF  
cmake_minimum_required(VERSION 3.1)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_TOOLCHAIN_FILE $HOME/.local/share/vcpkg/scripts/buildsystems/vcpkg.cmake)
set(CMAKE_BUILD_TYPE Debug)


project($(basename $(pwd)))
add_subdirectory(src)
add_subdirectory(lib)
add_subdirectory(test)
add_subdirectory(include)
EOF

echo -e "${INFO}Writing default main.cpp file."
cat > src/main.cpp <<EOF
#include <iostream>

int main(){
    std::cout << "Hello World";    
}
EOF
cat > src/CMakeLists.txt <<EOF
add_executable(main main.cpp)
EOF

cat > test/tests.cpp <<EOF
#include <gtest/gtest.h>
EOF

cat > test/CMakeLists.txt <<EOF
add_executable(tests tests.cpp)
target_include_directories(tests PRIVATE \${PROJECT_SOURCE_DIR})

find_package(GTest CONFIG REQUIRED)
    target_link_libraries(tests PRIVATE GTest::gmock GTest::gtest GTest::gmock_main GTest::gtest_main)
EOF

cat > lib/CMakeLists.txt <<EOF
EOF
cat > include/CMakeLists.txt <<EOF
EOF

echo -e "${INFO}Writing .clang-format file with Microsoft default style."
cat > .clang-format <<EOF
BasedOnStyle: Microsoft
EOF

echo -e "${INFO}Installing gtest."
echo -e "${Green}\n --- vcpkg --- \n${Color_Off}"
vcpkg install gtest
echo -e "${INFO}Configuring cmake."
echo -e "${Green}\n --- cmake --- \n${Color_Off}"
cmake -S . -B build 
echo
echo -e "${INFO}Soft linking compile commands."
ln -s build/compile_commands.json compile_commands.json

echo -e "\n${SUCCESS}All done and dusted.\n\n"

[ -z "$1" ] || echo -e "\t${Green}cd $1 to start!${Color_Off}\n"
