//===-- FgpuInstPrinter.cpp - Convert Fgpu MCInst to assembly syntax ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This class prints an Fgpu MCInst to a .s file.
//
//===----------------------------------------------------------------------===//

#include "FgpuInstPrinter.h"

#include "FgpuInstrInfo.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/Debug.h"
using namespace llvm;

#define DEBUG_TYPE "asm-printer"

#define PRINT_ALIAS_INSTR
#include "FgpuGenAsmWriter.inc"

void FgpuInstPrinter::printRegName(raw_ostream &OS, unsigned RegNo) const {
//- getRegisterName(RegNo) defined in FgpuGenAsmWriter.inc which came from 
//   Fgpu.td indicate.
  if(StringRef(getRegisterName(RegNo)).lower() == "sp" ||
    StringRef(getRegisterName(RegNo)).lower() == "lr")
    OS << StringRef(getRegisterName(RegNo)).lower();
  else
    OS << 'r' << StringRef(getRegisterName(RegNo)).lower();
}

//@1 {
void FgpuInstPrinter::printInst(const MCInst *MI, raw_ostream &O,
                                StringRef Annot, const MCSubtargetInfo &STI) {
  // Try to print any aliases first.
  if (!printAliasInstr(MI, O))
//@1 }
    //- printInstruction(MI, O) defined in FgpuGenAsmWriter.inc which came from 
    //   Fgpu.td indicate.
    printInstruction(MI, O);
  printAnnotation(O, Annot);
}

//@printExpr {
static void printExpr(const MCExpr *Expr, raw_ostream &OS) {
//@printExpr body {
  int Offset = 0;
  const MCSymbolRefExpr *SRE;

  if (const MCBinaryExpr *BE = dyn_cast<MCBinaryExpr>(Expr)) {
    SRE = dyn_cast<MCSymbolRefExpr>(BE->getLHS());
    const MCConstantExpr *CE = dyn_cast<MCConstantExpr>(BE->getRHS());
    assert(SRE && CE && "Binary expression must be sym+const.");
    Offset = CE->getValue();
  }
  else if (!(SRE = dyn_cast<MCSymbolRefExpr>(Expr)))
    assert(false && "Unexpected MCExpr type.");

  MCSymbolRefExpr::VariantKind Kind = SRE->getKind();

  switch (Kind) {
  default:                                 llvm_unreachable("Invalid kind!");
  case MCSymbolRefExpr::VK_None:           break;
  }

  OS << SRE->getSymbol();

  if (Offset) {
    if (Offset > 0)
      OS << '+';
    OS << Offset;
  }

  if (Kind != MCSymbolRefExpr::VK_None)
    OS << ')';
}

void FgpuInstPrinter::printOperand(const MCInst *MI, unsigned OpNo, raw_ostream &O) {
  // errs() << "\nprintOperand entered: Imm= " << OpNo << "\n";
  const MCOperand &Op = MI->getOperand(OpNo);
  if (Op.isReg()) {
    printRegName(O, Op.getReg());
    return;
  }

  if (Op.isImm()) {
    O << Op.getImm();
    return;
  }

  assert(Op.isExpr() && "unknown operand kind in printOperand");
  printExpr(Op.getExpr(), O);
}

void FgpuInstPrinter::printUnsignedShortImm(const MCInst *MI, int opNum, raw_ostream &O) {
  // errs() << "printUnsignedShortImm entered: Imm= " << opNum << "\n";
  const MCOperand &MO = MI->getOperand(opNum);
  if (MO.isImm())
    O << (unsigned short int)MO.getImm();
  else
    printOperand(MI, opNum, O);
}
void FgpuInstPrinter::printUnsignedImm(const MCInst *MI, int opNum, raw_ostream &O) {
  // errs() << "printUnsignedImm entered: Imm= " << opNum << "\n";
  const MCOperand &MO = MI->getOperand(opNum);
  if (MO.isImm())
    O << (unsigned int)MO.getImm();
  else
    printOperand(MI, opNum, O);
}

void FgpuInstPrinter::
printMemOperandEA(const MCInst *MI, int opNum, raw_ostream &O) {
  DEBUG(dbgs() << "soubhi: printMemOperand entered\n");
  printOperand(MI, opNum, O);
  O << ", ";
  printOperand(MI, opNum+1, O);
}

void FgpuInstPrinter::
printMemOperand(const MCInst *MI, int opNum, raw_ostream &O) {
  DEBUG(dbgs() << "soubhi: printMemOperand entered\n");
  printOperand(MI, opNum, O);
  O << "[";
  printOperand(MI, opNum+1, O);
  O << "]";
}
