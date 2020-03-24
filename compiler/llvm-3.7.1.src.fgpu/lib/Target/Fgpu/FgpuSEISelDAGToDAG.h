//===-- FgpuSEISelDAGToDAG.h - A Dag to Dag Inst Selector for FgpuSE -----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Subclass of FgpuDAGToDAGISel specialized for fgpu32.
//
//===----------------------------------------------------------------------===//

#ifndef FGPUSEISELDAGTODAG_H
#define FGPUSEISELDAGTODAG_H


#include "FgpuISelDAGToDAG.h"

namespace llvm {

class FgpuSEDAGToDAGISel : public FgpuDAGToDAGISel {

public:
  explicit FgpuSEDAGToDAGISel(FgpuTargetMachine &TM) : FgpuDAGToDAGISel(TM) {}

private:

  bool runOnMachineFunction(MachineFunction &MF) override;

  void processFunctionAfterISel(MachineFunction &MF) override;

  bool replaceUsesWithZeroReg(MachineRegisterInfo *MRI, const MachineInstr&);
  
};

FunctionPass *createFgpuSEISelDag(FgpuTargetMachine &TM);

}

#endif
