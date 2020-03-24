//===-- FgpuSEISelLowering.cpp - FgpuSE DAG Lowering Interface --*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Subclass of FgpuTargetLowering specialized for fgpu32.
//
//===----------------------------------------------------------------------===//
#include "FgpuMachineFunction.h"
#include "FgpuSEISelLowering.h"

#include "FgpuRegisterInfo.h"
#include "FgpuTargetMachine.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetInstrInfo.h"

using namespace llvm;

#define DEBUG_TYPE "fgpu-isel"


//@FgpuSETargetLowering {
FgpuSETargetLowering::FgpuSETargetLowering(const FgpuTargetMachine &TM,
                                           const FgpuSubtarget &STI)
    : FgpuTargetLowering(TM, STI) {
//@FgpuSETargetLowering body {
  // Set up the register classes
  addRegisterClass(MVT::i32, &Fgpu::ALURegsRegClass);
  if(Subtarget.hasHardFloatUnits()) {
    DEBUG(dbgs()<< "soubhi: FloatRegs added\n");
    addRegisterClass(MVT::f32, &Fgpu::FloatRegsRegClass);
  }

  // setOperationAction(ISD::ATOMIC_FENCE,       MVT::Other, Custom);

// must, computeRegisterProperties - Once all of the register classes are 
//  added, this allows us to compute derived properties we expose.
  computeRegisterProperties(Subtarget.getRegisterInfo());
}

SDValue FgpuSETargetLowering::LowerOperation(SDValue Op,
                                             SelectionDAG &DAG) const {

  return FgpuTargetLowering::LowerOperation(Op, DAG);
}

const FgpuTargetLowering *
llvm::createFgpuSETargetLowering(const FgpuTargetMachine &TM,
                                 const FgpuSubtarget &STI) {
  return new FgpuSETargetLowering(TM, STI);
}
