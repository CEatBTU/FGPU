set(LLVM_TARGET_DEFINITIONS FgpuAsm.td)
tablegen(LLVM FgpuGenAsmMatcher.inc -gen-asm-matcher)

set(LLVM_TARGET_DEFINITIONS Fgpu.td)

tablegen(LLVM FgpuGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM FgpuGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM FgpuGenDisassemblerTables.inc -gen-disassembler)
tablegen(LLVM FgpuGenCodeEmitter.inc -gen-emitter)
tablegen(LLVM FgpuGenMCCodeEmitter.inc -gen-emitter)
tablegen(LLVM FgpuGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM FgpuGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM FgpuGenMCPseudoLowering.inc -gen-pseudo-lowering)
tablegen(LLVM FgpuGenDAGISel.inc -gen-dag-isel)
tablegen(LLVM FgpuGenCallingConv.inc -gen-callingconv)

# FgpuCommonTableGen must be defined
add_public_tablegen_target(FgpuCommonTableGen)

# FgpuCodeGen should match with LLVMBuild.txt FgpuCodeGen
add_llvm_target(FgpuCodeGen
  FgpuTargetMachine.cpp
  FgpuFrameLowering.cpp
  FgpuInstrInfo.cpp
  FgpuISelLowering.cpp
  FgpuMachineFunction.cpp
  FgpuRegisterInfo.cpp
  FgpuSEFrameLowering.cpp
  FgpuSEISelLowering.cpp
  FgpuSERegisterInfo.cpp
  FgpuSubtarget.cpp
  FgpuTargetObjectFile.cpp
  FgpuSEInstrInfo.cpp
  FgpuAsmPrinter.cpp
  FgpuMCInstLower.cpp
  FgpuISelDAGToDAG.cpp
  FgpuSEISelDAGToDAG.cpp
  FgpuAnalyzeImmediate.cpp
  FgpuDelUselessBranch.cpp
  )


# Should match with "subdirectories =  MCTargetDesc TargetInfo" in LLVMBuild.txt
add_subdirectory(InstPrinter)
add_subdirectory(Disassembler)
add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)
add_subdirectory(AsmParser)
