//===-- FgpuMCInstLower.cpp - Convert Fgpu MachineInstr to MCInst ---------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains code to lower Fgpu MachineInstrs to their corresponding
// MCInst records.
//
//===----------------------------------------------------------------------===//

#include "FgpuMCInstLower.h"

#include "FgpuAsmPrinter.h"
#include "FgpuInstrInfo.h"
#include "MCTargetDesc/FgpuBaseInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/IR/Mangler.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/Support/Debug.h"


#define DEBUG_TYPE "fgpu-mc-instlower"
using namespace llvm;

FgpuMCInstLower::FgpuMCInstLower(FgpuAsmPrinter &asmprinter)
  : AsmPrinter(asmprinter) {}

void FgpuMCInstLower::Initialize(MCContext* C) {
  Ctx = C;
}

MCOperand FgpuMCInstLower::LowerSymbolOperand(const MachineOperand &MO,
                                              MachineOperandType MOTy,
                                              unsigned Offset) const {
  MCSymbolRefExpr::VariantKind Kind;
  const MCSymbol *Symbol;

  switch(MO.getTargetFlags()) {
  default:                   llvm_unreachable("Invalid target flag!");
  case FgpuII::MO_NO_FLAG:   Kind = MCSymbolRefExpr::VK_None; break;
  }

  switch (MOTy) {
  case MachineOperand::MO_GlobalAddress:
    // DEBUG(dbgs() << "Global address symbol name : " << MO.getSymbolName() << " \n");
    Symbol = AsmPrinter.getSymbol(MO.getGlobal());
    DEBUG(dbgs() << "Global address symbol offset: " << MO.getOffset() << " \n");
    break;

  case MachineOperand::MO_MachineBasicBlock:
    Symbol = MO.getMBB()->getSymbol();
    break;

  case MachineOperand::MO_BlockAddress:
    Symbol = AsmPrinter.GetBlockAddressSymbol(MO.getBlockAddress());
    Offset += MO.getOffset();
    break;

  case MachineOperand::MO_ExternalSymbol:
    DEBUG(dbgs() << "External symbol name : " << MO.getSymbolName() << " \n");
    Symbol = AsmPrinter.GetExternalSymbolSymbol(MO.getSymbolName());
    Offset += MO.getOffset();
    DEBUG(dbgs() << "External symbol offset = " << Offset << "\n");
    break;

  case MachineOperand::MO_JumpTableIndex:
    Symbol = AsmPrinter.GetJTISymbol(MO.getIndex());
    break;

  default:
    llvm_unreachable("<unknown operand type>");
  }

  const MCSymbolRefExpr *MCSym = MCSymbolRefExpr::create(Symbol, Kind, *Ctx);
  DEBUG(dbgs() << "offset: " << Offset << " \n");

  if (!Offset)
    return MCOperand::createExpr(MCSym);

  // Assume offset is never negative.
  assert(Offset > 0);

  const MCConstantExpr *OffsetExpr =  MCConstantExpr::create(Offset, *Ctx);
  const MCBinaryExpr *AddExpr = MCBinaryExpr::createAdd(MCSym, OffsetExpr, *Ctx);
  DEBUG(AddExpr->dump());
  return MCOperand::createExpr(AddExpr);
}

//@LowerOperand {
MCOperand FgpuMCInstLower::LowerOperand(const MachineOperand& MO,
                                        unsigned offset) const {
  MachineOperandType MOTy = MO.getType();
  switch (MOTy) {
  //@2
  default: llvm_unreachable("unknown operand type");
  case MachineOperand::MO_Register:
    // Ignore all implicit register operands.
    if (MO.isImplicit()) break;
    return MCOperand::createReg(MO.getReg());
  case MachineOperand::MO_Immediate:
    return MCOperand::createImm(MO.getImm() + offset);
  case MachineOperand::MO_MachineBasicBlock:
  case MachineOperand::MO_ExternalSymbol:
  case MachineOperand::MO_JumpTableIndex:
  case MachineOperand::MO_BlockAddress:
  case MachineOperand::MO_GlobalAddress:
    return LowerSymbolOperand(MO, MOTy, offset);
  case MachineOperand::MO_RegisterMask:
    break;
 }

  return MCOperand();
}

void FgpuMCInstLower::Lower(const MachineInstr *MI, MCInst &OutMI) const {
  OutMI.setOpcode(MI->getOpcode());

  for (unsigned i = 0, e = MI->getNumOperands(); i != e; ++i) {
    const MachineOperand &MO = MI->getOperand(i);
    MCOperand MCOp = LowerOperand(MO);

    if (MCOp.isValid())
      OutMI.addOperand(MCOp);
  }
}

