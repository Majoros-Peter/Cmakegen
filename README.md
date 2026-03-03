# CMakegen

Cmakegen is a bash script that generates files to help run OpenGL3 + SDL3 + Dear ImGUI on Linux.

## Dependencies

- cmake
- sdl3, sdl3_image
- glew
- a copy of [dear imgui](https://github.com/ocornut/imgui) (preferably with its path being **~/imgui**)
- [clangd](https://github.com/clangd/clangd) (optional)

## Usage

```
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
```

## Tip

You can make a symlink to use it everywhere for convenience:

```bash
sudo ln -s cmake-gen.sh /usr/sbin/
```
