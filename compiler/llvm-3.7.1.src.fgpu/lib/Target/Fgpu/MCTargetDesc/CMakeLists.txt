# MCTargetDesc/CMakeLists.txt
add_llvm_library(LLVMFgpuDesc
  FgpuMCTargetDesc.cpp
  FgpuABIInfo.cpp
  FgpuMCAsmInfo.cpp
  FgpuAsmBackend.cpp
  FgpuMCCodeEmitter.cpp
  FgpuELFObjectWriter.cpp
  FgpuTargetStreamer.cpp
  )




