//===-- FgpuTargetMachine.cpp - Define TargetMachine for Fgpu -------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Implements the info about Fgpu target spec.
//
//===----------------------------------------------------------------------===//

#include "FgpuTargetMachine.h"
#include "Fgpu.h"
#include "FgpuISelDAGToDAG.h"
#include "FgpuSubtarget.h"
#include "FgpuTargetObjectFile.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/Support/TargetRegistry.h"
using namespace llvm;

#define DEBUG_TYPE "fgpu"

extern "C" void LLVMInitializeFgpuTarget() {
  // Register the target.
  //- Little endian Target Machine
  RegisterTargetMachine<FgpuTargetMachine> Y(TheFgpuTarget);
}

static std::string computeDataLayout(const Triple &TT, StringRef CPU, const TargetOptions &Options, bool isLittle) {
  std::string Ret = "";
  // There are both little and big endian fgpu.
  if (isLittle)
    Ret += "e";
  else
    Ret += "E";

  Ret += "-m:m";

  // Pointers are 32 bit on some ABIs.
  Ret += "-p:32:32";

  // 8 and 16 bit integers only need to have natural alignment, but try to
  // align them to 32 bits. 64 bit integers have natural alignment.
  Ret += "-i8:8:32-i16:16:32-i64:64";

  // 32 bit registers are always available and the stack is at least 64 bit
  // aligned.
  Ret += "-n32-S64";

  return Ret;
}

FgpuTargetMachine::FgpuTargetMachine(const Target &T, const Triple &TT,
                  StringRef CPU, StringRef FS, const TargetOptions &Options,
                  Reloc::Model RM, CodeModel::Model CM,
                  CodeGenOpt::Level OL /*,bool isLittle*/)
    : LLVMTargetMachine(T, computeDataLayout(TT, CPU, Options, /*isLittle*/true), TT,
                        CPU, FS, Options, RM, CM, OL),
      isLittle(/*isLittle*/true), TLOF(make_unique<FgpuTargetObjectFile>()),
      ABI(FgpuABIInfo::computeTargetABI()),
      Subtarget(nullptr), DefaultSubtarget(TT, CPU, FS, /*isLittle*/true, *this) {
  // On function prologue, the stack is created by decrementing
  // its pointer. Once decremented, all references are done with positive
  // offset from the stack/frame pointer, using StackGrowsUp enables
  // an easier handling.
  // Using CodeModel::Large enables different CALL behavior.
  Subtarget = &DefaultSubtarget;
  // initAsmInfo will display features by llc -march=fgpu -mcpu=help on 3.7 but
  // not on 3.6
  initAsmInfo();
}

FgpuTargetMachine::~FgpuTargetMachine() {}

void FgpuTargetMachine::anchor() { }



const FgpuSubtarget* FgpuTargetMachine::getSubtargetImpl(const Function &F) const {
  Attribute CPUAttr = F.getFnAttribute("target-cpu");
  Attribute FSAttr = F.getFnAttribute("target-features");

  std::string CPU = !CPUAttr.hasAttribute(Attribute::None)
                        ? CPUAttr.getValueAsString().str()
                        : TargetCPU;
  std::string FS = !FSAttr.hasAttribute(Attribute::None)
                       ? FSAttr.getValueAsString().str()
                       : TargetFS;

  DEBUG(dbgs() << "soubhi: CPU = " << CPU << "\n");
  DEBUG(dbgs() << "soubhi: FS = " << FS << "\n");
  // DEBUG(dbgs() << "soubhi: IsSoftFloat = " << IsSoftFloat << "\n");
  auto &I = SubtargetMap[CPU + FS];
  if (!I) {
    // This needs to be done before we create a new subtarget since any
    // creation will depend on the TM and the code generation flags on the
    // function that reside in TargetOptions.
    resetTargetOptions(F);
    I = llvm::make_unique<FgpuSubtarget>(TargetTriple, CPU, FS, isLittle,
                                         *this);
  }
  return I.get();
}

namespace {
//@FgpuPassConfig {
/// Fgpu Code Generator Pass Configuration Options.
class FgpuPassConfig : public TargetPassConfig {
public:
  FgpuPassConfig(FgpuTargetMachine *TM, PassManagerBase &PM)
    : TargetPassConfig(TM, PM) {}

  FgpuTargetMachine &getFgpuTargetMachine() const {
    return getTM<FgpuTargetMachine>();
  }

  const FgpuSubtarget &getFgpuSubtarget() const {
    return *getFgpuTargetMachine().getSubtargetImpl();
  }
  // void addIRPasses() override;
  bool addInstSelector() override;
// #ifdef ENABLE_GPRESTORE
  // void addPreRegAlloc() override;
// #endif
  void addPreEmitPass() override;
};
} // namespace

TargetPassConfig *FgpuTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new FgpuPassConfig(this, PM);
}

bool FgpuPassConfig::addInstSelector() {
  // Install an instruction selector pass using
  // the ISelDag to gen Fgpu code.
  addPass(createFgpuISelDag(getFgpuTargetMachine()));
  return false;
}


void FgpuPassConfig::addPreEmitPass() {
// Implemented by targets that want to run passes immediately before
// machine code is emitted. return true if -print-machineinstrs should
// print out the code after the passes.
  FgpuTargetMachine &TM = getFgpuTargetMachine();
  addPass(createFgpuDelBranchPass(TM));
  return;
}
