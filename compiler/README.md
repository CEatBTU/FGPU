# Instructions

Use the provided `Dockerfile` to build a Docker image containing the compilation environment.

In short, run `docker build -t fgpu_compiler .` inside this directory.

The compiler binaries will then be available inside the container in the `/llvm/llvm-3.7.1.build/bin` folder.

E.g.: to run clang, do: `docker run fgpu_compiler /llvm/llvm-3.7.1.build/bin/clang <source files>`
