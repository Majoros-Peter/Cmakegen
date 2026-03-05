#!/bin/bash

red='\e[38;5;196m'
green='\e[38;5;46m'
yellow='\e[38;5;226m'
reset='\e[0;97m'
clearln='\033[1K\r'

help=''
project_name=${PWD##*/}
imgui_path=~/imgui
cmake_version=$(cmake --version | head -n1 | awk '{print $3}')
clangd_conf=''

includes_dir=./includes
imgui_dir=./imgui


while [[ "$#" -gt 0 ]]; do
    case $1 in
		--imgui-dir*) imgui_dir="${1#*=}";;
		--includes-dir*) includes_dir="${1#*=}";;
		-h|--help) help="${1#}";;
		-n*|--name*) project_name="${1#*=}";;
		-i*|--imgui-path*) imgui_path="${1#*=}";;
		-c*|--cmake-version*) cmake_version="${1#*=}";;
		--clangd) clangd_conf="${1#}";;
        *) echo "Unknown parameter passed: $1";;
    esac
    shift
done




#	Help
#
if [[ ! -z $help ]]; then
cat << EOF
Usage:
  cmake-gen.sh [options]

Options:
  -c=<ver>                Use <ver> version of cmake        (default: current cmake version)
  -h, --help              Print this help message
  -i=<dir>                Local path to imgui directory     (default: '~/imgui')
  -n=<name>               Name for the project              (default: cwd)

  --clangd                Generate a .clangd config file    (default: nope)
  --cmake-version=<ver>   Same as -c, but the looong way
  --imgui-dir=<dir>       Directory to put dear imgui files (default: './imgui')
  --imgui-path=<dir>      Exactly the same as -i
  --includes-dir=<dir>    Directory containing build files  (default: './includes')
  --name=<name>           Exactly the same as -n
EOF
exit 0
fi



#	Dear ImGUI
#
if [[ ! -d $imgui_dir ]]; then
	mkdir $imgui_dir
fi

if [[ -z $(ls -A $imgui_dir) ]]; then
	echo -ne "${red}linking imgui files...${reset}"

	for file in imconfig.h imgui.cpp imgui.h imgui_demo.cpp imgui_draw.cpp imgui_internal.h imgui_tables.cpp imgui_widgets.cpp imstb_rectpack.h imstb_textedit.h imstb_truetype.h; do 
		ln -s "$imgui_path/$file" $imgui_dir; 
	done

	for file in imgui_impl_opengl3.cpp imgui_impl_opengl3.h imgui_impl_opengl3_loader.h imgui_impl_sdl3.cpp imgui_impl_sdl3.h; do 
		ln -s "$imgui_path/backends/$file" $imgui_dir; 
	done

	echo -e "${clearln}${green}✓ imgui files linked${reset}"
fi



#	CMakeLists.txt
#
echo -ne "${red}CMakeLists.txt...${reset}"
cat > CMakeLists.txt << EOF
cmake_minimum_required(VERSION ${cmake_version})

project(${project_name})

# Find packages
find_package(SDL3 REQUIRED)
find_package(SDL3_image REQUIRED)

# Include directories
include_directories(
$( [[ -d $includes_dir ]] && echo -e "\t$includes_dir" )
$( [[ -d $imgui_dir ]] && echo -e "\t$imgui_dir" )
)

#Executable
add_executable(
	\${PROJECT_NAME}
$(printf "\t./%s\n" $(ls *.cpp 2>/dev/null))
$( [[ -d $includes_dir ]] && printf "\t%s\n" $(ls $includes_dir/*.cpp 2>/dev/null))
$( [[ -d $imgui_dir ]] && printf "\t%s\n" $(ls $imgui_dir/*.cpp 2>/dev/null))
)

# Include directories
target_include_directories(
	\${PROJECT_NAME}
	PRIVATE
	\${SDL3_INCLUDE_DIRS}
	\${SDL3_image_INCLUDE_DIRS}
)

# Link libraries
target_link_libraries(
	\${PROJECT_NAME}
	SDL3::SDL3
	SDL3_image::SDL3_image
	GLEW GL GLU X11
)

# Copy assets and shaders
$([[ -d Assets ]] && echo -e "file(CREATE_LINK\n\t\${CMAKE_SOURCE_DIR}/Assets\n\t\${CMAKE_BINARY_DIR}/Assets\n\tSYMBOLIC\n)")
$([[ -d Shaders ]] && echo -e "file(CREATE_LINK\n\t\${CMAKE_SOURCE_DIR}/Shaders\n\t\${CMAKE_BINARY_DIR}/Shaders\n\tSYMBOLIC\n)")
EOF
echo -e "${clearln}${green}✓ CMakeLists.txt${reset}"



#	.clangd
#
if [[ ! -z $clangd_conf ]]; then
echo -ne "${red}.clangd...${reset}"
cat > .clangd << EOF
CompileFlags:
  Add: [
$( [[ -d $includes_dir ]] && echo -e "    -I$includes_dir" ),
$( [[ -d $imgui_dir ]] && echo -e "    -I$imgui_dir" )
  ]
EOF
echo -e "${clearln}${green}✓ .clangd${reset}"
fi



mkdir build 2> /dev/null

cat << EOF

cmake -S . build

cmake --build build -j5

./build/$project_name
EOF



# https://github.com/nigels-com/glew/issues/172
# glewInit()	->	glewContextInit()
# ^	Wayland miatt le kell cserélni
