//===-- FgpuMachineFunctionInfo.h - Private data used for Fgpu ----*- C++ -*-=//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the Fgpu specific subclass of MachineFunctionInfo.
//
//===----------------------------------------------------------------------===//

#ifndef FGPU_MACHINE_FUNCTION_INFO_H
#define FGPU_MACHINE_FUNCTION_INFO_H

#include "llvm/ADT/StringMap.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineMemOperand.h"
#include "llvm/CodeGen/PseudoSourceValue.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/ValueMap.h"
#include "llvm/Target/TargetFrameLowering.h"
#include "llvm/Target/TargetMachine.h"
#include <map>
#include <string>
#include <utility>

namespace llvm {

/// \brief A class derived from PseudoSourceValue that represents a GOT entry
/// resolved by lazy-binding.
class FgpuCallEntry : public PseudoSourceValue {
public:
  explicit FgpuCallEntry(const StringRef &N);
  explicit FgpuCallEntry(const GlobalValue *V);
  bool isConstant(const MachineFrameInfo *) const override;
  bool isAliased(const MachineFrameInfo *) const override;
  bool mayAlias(const MachineFrameInfo *) const override;

private:
  void printCustom(raw_ostream &O) const override;
#ifndef NDEBUG
  std::string Name;
  const GlobalValue *Val;
#endif
};

//@1 {
/// FgpuFunctionInfo - This class is derived from MachineFunction private
/// Fgpu target-specific information for each MachineFunction.
class FgpuFunctionInfo : public MachineFunctionInfo {
public:
  FgpuFunctionInfo(MachineFunction& MF)
  : MF(MF), 
    SRetReturnReg(0),
    VarArgsFrameIndex(0), 
    CallsEhReturn(false),
    MaxCallFrameSize(0)
    {}

  ~FgpuFunctionInfo();

  unsigned getSRetReturnReg() const { return SRetReturnReg; }
  void setSRetReturnReg(unsigned Reg) { SRetReturnReg = Reg; }

  int getVarArgsFrameIndex() const { return VarArgsFrameIndex; }
  void setVarArgsFrameIndex(int Index) { VarArgsFrameIndex = Index; }

  void setFormalArgInfo(unsigned Size) {
    IncomingArgSize = Size;
  }

  unsigned getIncomingArgSize() const { return IncomingArgSize; }

  bool callsEhReturn() const { return CallsEhReturn; }

  void createEhDataRegsFI();

  unsigned getMaxCallFrameSize() const { return MaxCallFrameSize; }
  void setMaxCallFrameSize(unsigned S) { MaxCallFrameSize = S; }

private:
  virtual void anchor();

  MachineFunction& MF;

  /// SRetReturnReg - Some subtargets require that sret lowering includes
  /// returning the value of the returned struct in a register. This field
  /// holds the virtual register into which the sret argument is passed.
  unsigned SRetReturnReg;


  // VarArgsFrameIndex - FrameIndex for start of varargs area.
  int VarArgsFrameIndex;


  /// Size of incoming argument area.
  unsigned IncomingArgSize;

  /// CallsEhReturn - Whether the function calls llvm.eh.return.
  bool CallsEhReturn;

  /// Frame objects for spilling eh data registers.
  int EhDataRegFI[4];

  // mutable int DynAllocFI; // Frame index of dynamically allocated stack area.
  unsigned MaxCallFrameSize;

  /// FgpuCallEntry maps.
  StringMap<std::unique_ptr<const FgpuCallEntry>> ExternalCallEntries;
  ValueMap<const GlobalValue *, std::unique_ptr<const FgpuCallEntry>>
      GlobalCallEntries;
};
//@1 }

} // end of namespace llvm


#endif
