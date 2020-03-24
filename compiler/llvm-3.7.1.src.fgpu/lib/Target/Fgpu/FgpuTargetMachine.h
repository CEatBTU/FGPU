//===-- FgpuTargetMachine.h - Define TargetMachine for Fgpu -----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the Fgpu specific subclass of TargetMachine.
//
//===----------------------------------------------------------------------===//

#ifndef FGPUTARGETMACHINE_H
#define FGPUTARGETMACHINE_H


#include "MCTargetDesc/FgpuABIInfo.h"
#include "FgpuSubtarget.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/Target/TargetFrameLowering.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
// class formatted_raw_ostream;
class FgpuRegisterInfo;

class FgpuTargetMachine : public LLVMTargetMachine {
  bool isLittle;
  virtual void anchor();
  std::unique_ptr<TargetLoweringObjectFile> TLOF;
  
  FgpuABIInfo ABI;
  FgpuSubtarget *Subtarget;
  FgpuSubtarget DefaultSubtarget;

  mutable StringMap<std::unique_ptr<FgpuSubtarget>> SubtargetMap;
public:
  FgpuTargetMachine(const Target &T, const Triple &TT, StringRef CPU, 
                    StringRef FS, const TargetOptions &Options, 
                    Reloc::Model RM, CodeModel::Model CM, 
                    CodeGenOpt::Level OL);
  ~FgpuTargetMachine() override;

  const FgpuSubtarget *getSubtargetImpl() const {
    if (Subtarget)
      return Subtarget;
    return &DefaultSubtarget;
  }

  const FgpuSubtarget *getSubtargetImpl(const Function &F) const override;

  // Pass Pipeline Configuration
  TargetPassConfig *createPassConfig(PassManagerBase &PM) override;

  TargetLoweringObjectFile *getObjFileLowering() const override {
    return TLOF.get();
  }
  bool isLittleEndian() const { return isLittle; }
  const FgpuABIInfo &getABI() const { return ABI; }
};

} 

#endif
