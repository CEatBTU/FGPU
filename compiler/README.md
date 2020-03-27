# Instructions

Use the provided `Dockerfile` to build a Docker image containing the compilation environment.

In short, run `docker build -t fgpu_compiler .` inside this directory.

The compiler binaries will then be available inside the container in the `/llvm/llvm-3.7.1.build/bin` folder.

To compile the kernels, you have to bring the kernels directory into the Docker container. An example usage is provided below: 
- Do `docker run fgpu_compiler -v $(pwd):/llvm/kernels -it` from inside the kernels directory. This will create a directory `/llvm/kernels` inside the container and mount the current directory over there, and then run the container into interactive mode (i.e., you get a shell inside the container).
- Inside the container, `cd` into the kernels folder and run the `compile.sh` script, following its instructions accordingly.
