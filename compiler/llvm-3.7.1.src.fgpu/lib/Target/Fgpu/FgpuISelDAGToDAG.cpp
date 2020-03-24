//===-- FgpuISelDAGToDAG.cpp - A Dag to Dag Inst Selector for Fgpu --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines an instruction selector for the FGPU target.
//
//===----------------------------------------------------------------------===//

#include "FgpuISelDAGToDAG.h"
#include "Fgpu.h"

#include "FgpuMachineFunction.h"
#include "FgpuRegisterInfo.h"
#include "FgpuSEISelDAGToDAG.h"
#include "FgpuSubtarget.h"
#include "FgpuTargetMachine.h"
#include "MCTargetDesc/FgpuBaseInfo.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/Type.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/CodeGen/SelectionDAGNodes.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

#define DEBUG_TYPE "fgpu-isel"

//===----------------------------------------------------------------------===//
// Instruction Selector Implementation
//===----------------------------------------------------------------------===//


bool FgpuDAGToDAGISel::runOnMachineFunction(MachineFunction &MF) {
  DEBUG(dbgs() << "soubhi: FgpuDAGToDAGISel pass entered \n");
  bool Ret = SelectionDAGISel::runOnMachineFunction(MF);

  processFunctionAfterISel(MF);
  DEBUG(dbgs() << "soubhi: FgpuDAGToDAGISel pass finished \n");
  return Ret;
}

/// ComplexPattern used on FgpuInstrInfo used on Fgpu Load/Store instructions
bool FgpuDAGToDAGISel::selectFrameAddr(SDNode *Parent, SDValue Addr, SDValue &Base, SDValue &Offset) {
  DEBUG(dbgs() << "soubhi: selectFrameAddr entered\n");
  EVT ValTy = Addr.getValueType();
  SDLoc DL(Addr);

  // If Parent is an unaligned f32 load or store, select a (base + index)
  // floating point load/store instruction (luxc1 or suxc1).
  const LSBaseSDNode* LS = 0;

  if (Parent && (LS = dyn_cast<LSBaseSDNode>(Parent))) {
    EVT VT = LS->getMemoryVT();

    if (VT.getSizeInBits() / 8 > LS->getAlignment()) {
      assert("Unaligned loads/stores not supported for this type.");
      assert(false);
      if (VT == MVT::f32)
        return false;
    }
  }
  // return false;
  // if Address is FI, get the TargetFrameIndex.
  if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    DEBUG(dbgs() << "soubhi: FrameIndexSDNode\n");
    Base   = CurDAG->getTargetFrameIndex(FIN->getIndex(), ValTy);
    Offset = CurDAG->getTargetConstant(0, DL, ValTy);
    return true;
  }
  // return false;

  // Addresses of the form FI+const or FI|const
  if (CurDAG->isBaseWithConstantOffset(Addr)) {
    DEBUG(dbgs() << "soubhi: isBaseWithConstantOffset\n");
    ConstantSDNode *CN = dyn_cast<ConstantSDNode>(Addr.getOperand(1));
    if (isInt<16>(CN->getSExtValue())) {
      DEBUG(dbgs() << "soubhi: is 16bit offset\n");

      // If the first operand is a FI, get the TargetFI Node
      if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode> (Addr.getOperand(0))) {
        DEBUG(dbgs() << "soubhi: operand 0 is a FrameIndex\n");
        Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), ValTy);
        Offset = CurDAG->getTargetConstant(CN->getZExtValue(), DL, ValTy);
        return true;
      }
      // else
      //   Base = Addr.getOperand(0);

    }
  }
  return false;

  Base   = Addr;
  Offset = CurDAG->getTargetConstant(0, DL, ValTy);
  return true;
}

//@Select {
/// Select instructions not customized! Used for
/// expanded, promoted and normal instructions
SDNode* FgpuDAGToDAGISel::Select(SDNode *Node) {
//@Select }
  // Dump information about the Node being selected
  DEBUG(errs() << "Selecting: "; Node->dump(CurDAG); errs() << "\n");

  // If we have a custom node, we already have selected!
  if (Node->isMachineOpcode()) {
    DEBUG(errs() << "== "; Node->dump(CurDAG); errs() << "\n");    Node->setNodeId(-1);
    DEBUG(errs() << "soubhi: isMachineOpCode\n");
    return nullptr;
  }

  unsigned Opcode = Node->getOpcode();

  switch(Opcode) {
    case ISD::Constant:
	  // const ConstantSDNode *CSDN = dyn_cast<ConstantSDNode>(Node);
      DEBUG(errs() << '<' << dyn_cast<ConstantSDNode>(Node)->getAPIntValue() << '>');
      DEBUG(errs() << "soubhi: constant node \n");

      break;
    default: break;


  }

  // Select the default instruction (from the FguGenDAGISel.inc) file
  SDNode *ResNode = SelectCode(Node);

  DEBUG(errs() << "=> ");
  if (ResNode == NULL || ResNode == Node)
    DEBUG(Node->dump(CurDAG));
  else
    DEBUG(ResNode->dump(CurDAG));
  DEBUG(errs() << "\n");
  return ResNode;
}

bool FgpuDAGToDAGISel::SelectInlineAsmMemoryOperand(const SDValue &Op, unsigned ConstraintID, std::vector<SDValue> &OutOps) {
  // All memory constraints can at least accept raw pointers.
  switch(ConstraintID) {
  default:
    llvm_unreachable("Unexpected asm memory constraint");
  case InlineAsm::Constraint_m:
    OutOps.push_back(Op);
    return false;
  }
  return true;
}

/// createFgpuISelDag - This pass converts a legalized DAG into a
/// FGPU-specific DAG, ready for instruction scheduling.
FunctionPass *llvm::createFgpuISelDag(FgpuTargetMachine &TM) {
  return llvm::createFgpuSEISelDag(TM);
}

