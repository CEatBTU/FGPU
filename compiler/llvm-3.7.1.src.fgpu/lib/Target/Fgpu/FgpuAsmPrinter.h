//===-- FgpuAsmPrinter.h - Fgpu LLVM Assembly Printer ----------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Fgpu Assembly printer class.
//
//===----------------------------------------------------------------------===//

#ifndef FGPUASMPRINTER_H
#define FGPUASMPRINTER_H


#include "FgpuMachineFunction.h"
#include "FgpuMCInstLower.h"
#include "FgpuSubtarget.h"
#include "FgpuTargetMachine.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
class MCStreamer;
class MachineInstr;
class MachineBasicBlock;
class Module;
class raw_ostream;

class LLVM_LIBRARY_VISIBILITY FgpuAsmPrinter : public AsmPrinter {

  void EmitInstrWithMacroNoAT(const MachineInstr *MI);

private:

  // lowerOperand - Convert a MachineOperand into the equivalent MCOperand.
  bool lowerOperand(const MachineOperand &MO, MCOperand &MCOp);

public:

  const FgpuSubtarget *Subtarget;
  const FgpuFunctionInfo *FgpuFI;
  FgpuMCInstLower MCInstLowering;

  explicit FgpuAsmPrinter(TargetMachine &TM,
                          std::unique_ptr<MCStreamer> Streamer)
    : AsmPrinter(TM, std::move(Streamer)), 
      MCInstLowering(*this) {
    Subtarget = static_cast<FgpuTargetMachine &>(TM).getSubtargetImpl();
  }

  virtual const char *getPassName() const override {
    return "Fgpu Assembly Printer";
  }

  virtual bool runOnMachineFunction(MachineFunction &MF) override;

//- EmitInstruction() must exists or will have run time error.
  void EmitInstruction(const MachineInstr *MI) override;
  void printSavedRegsBitmask(raw_ostream &O);
  void printHex32(unsigned int Value, raw_ostream &O);
  void emitFrameDirective();
  const char *getCurrentABIString() const;
  void EmitFunctionEntryLabel() override;
  void EmitFunctionBodyStart() override;
  void EmitFunctionBodyEnd() override;
  bool PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                       unsigned AsmVariant, const char *ExtraCode,
                       raw_ostream &O) override;
  bool PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNum,
                             unsigned AsmVariant, const char *ExtraCode,
                             raw_ostream &O) override;
  void printOperand(const MachineInstr *MI, int opNum, raw_ostream &O);
  void EmitStartOfAsmFile(Module &M) override;
  void PrintDebugValueComment(const MachineInstr *MI, raw_ostream &OS);
};
}


#endif

