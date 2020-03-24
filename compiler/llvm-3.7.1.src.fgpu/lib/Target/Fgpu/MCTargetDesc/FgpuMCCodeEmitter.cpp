//===-- FgpuMCCodeEmitter.cpp - Convert Fgpu Code to Machine Code ---------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the FgpuMCCodeEmitter class.
//
//===----------------------------------------------------------------------===//
//

#include "FgpuMCCodeEmitter.h"

#include "MCTargetDesc/FgpuBaseInfo.h"
#include "MCTargetDesc/FgpuFixupKinds.h"
#include "MCTargetDesc/FgpuMCTargetDesc.h"
#include "llvm/ADT/APFloat.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/Debug.h"

using namespace llvm;

#define DEBUG_TYPE "mccodeemitter"

MCCodeEmitter *llvm::createFgpuMCCodeEmitter(const MCInstrInfo &MCII,
                                               const MCRegisterInfo &MRI,
                                               MCContext &Ctx)
{
  return new FgpuMCCodeEmitter(MCII, Ctx, true);
}

void FgpuMCCodeEmitter::EmitByte(unsigned char C, raw_ostream &OS) const {
  OS << (char)C;
}

void FgpuMCCodeEmitter::EmitInstruction(uint64_t Val, unsigned Size, raw_ostream &OS) const {
  // Output the instruction encoding in little endian byte order.
  for (unsigned i = 0; i < Size; ++i) {
    unsigned Shift = IsLittleEndian ? i * 8 : (Size - 1 - i) * 8;
    EmitByte((Val >> Shift) & 0xff, OS);
  }
}

/// encodeInstruction - Emit the instruction.
/// Size the instruction (currently only 4 bytes)
void FgpuMCCodeEmitter::
encodeInstruction(const MCInst &MI, raw_ostream &OS,
                  SmallVectorImpl<MCFixup> &Fixups,
                  const MCSubtargetInfo &STI) const
{
  uint32_t Binary = getBinaryCodeForInstr(MI, Fixups, STI);

  // For now all instructions are 4 bytes
  int Size = 4; // FIXME: Have Desc.getSize() return the correct value!

  EmitInstruction(Binary, Size, OS);
}

/// getBranch14TargetOpValue - Return binary encoding of the branch
/// target operand. If the machine operand requires relocation,
/// record the relocation and return zero.
unsigned FgpuMCCodeEmitter::getBranch14TargetOpValue(const MCInst &MI, unsigned OpNo, SmallVectorImpl<MCFixup> &Fixups, const MCSubtargetInfo &STI) const {
  const MCOperand &MO = MI.getOperand(OpNo);
  if (MO.isImm()) 
    DEBUG(dbgs() << "getBranch14TargetOpValue is immediate = " << MO.getImm() << "\n");

  // If the destination is an immediate, we have nothing to do.
  if (MO.isImm()) return MO.getImm();
  assert(MO.isExpr() && "getBranch14TargetOpValue expects only expressions");

  const MCExpr *Expr = MO.getExpr();
  DEBUG(dbgs() << "getBranch14TargetOpValue  = " << *Expr << "\n");
  Fixups.push_back(MCFixup::create(0, Expr,
                                   MCFixupKind(Fgpu::fixup_Fgpu_PC14)));
  return 0;
}

/// getJumpTargetOpValue - Return binary encoding of the jump
/// target operand, such as JSUB. 
/// If the machine operand requires relocation,
/// record the relocation and return zero.
//@getJumpTargetOpValue {
unsigned FgpuMCCodeEmitter::
getJumpTargetOpValue(const MCInst &MI, unsigned OpNo,
                     SmallVectorImpl<MCFixup> &Fixups,
                     const MCSubtargetInfo &STI) const {
  DEBUG(dbgs() << "soubhi: getJumpTargetOpValue entered!\n");
  unsigned Opcode = MI.getOpcode();
  const MCOperand &MO = MI.getOperand(OpNo);
  // dbgs() << "soubhi: MO.getImm()
  // If the destination is an immediate, we have nothing to do.
  if (MO.isImm()) return MO.getImm();
  assert(MO.isExpr() && "getJumpTargetOpValue expects only expressions");

  // const MCExpr *Expr = MO.getExpr();
  assert(Opcode == Fgpu::JSUB);
  const MCExpr *Expr = MO.getExpr();
  if (Opcode == Fgpu::JSUB)
    Fixups.push_back(MCFixup::create(0, Expr,
                                     MCFixupKind(Fgpu::fixup_Fgpu_JSUB)));
  else
    llvm_unreachable("unexpect opcode in getJumpAbsoluteTargetOpValue()");
  return 0;
}
//@CH8_1 }

unsigned FgpuMCCodeEmitter::
getExprOpValue(const MCExpr *Expr,SmallVectorImpl<MCFixup> &Fixups,
               const MCSubtargetInfo &STI) const {
  DEBUG(dbgs() << "soubhi: getExprOpValue entered\n");
  // Expr->dump();
  MCExpr::ExprKind Kind = Expr->getKind();

  if (Kind == MCExpr::Binary) {
    Expr = static_cast<const MCBinaryExpr*>(Expr)->getLHS();
    Kind = Expr->getKind();
  }

  assert (Kind == MCExpr::SymbolRef);

  return 0;
}

/// getMachineOpValue - Return binary encoding of operand. If the machine
/// operand requires relocation, record the relocation and return zero.
unsigned FgpuMCCodeEmitter::
getMachineOpValue(const MCInst &MI, const MCOperand &MO,
                  SmallVectorImpl<MCFixup> &Fixups,
                  const MCSubtargetInfo &STI) const {
  if (MO.isReg()) {
    unsigned Reg = MO.getReg();
    unsigned RegNo = getFgpuRegisterNumbering(Reg);
    // unsigned RegNo = Ctx.getRegisterInfo()->getEncodingValue(Reg);
    return RegNo;
  } else if (MO.isImm()) {
    return static_cast<unsigned>(MO.getImm());
  } else if (MO.isFPImm()) {
    return static_cast<unsigned>(APFloat(MO.getFPImm())
        .bitcastToAPInt().getHiBits(32).getLimitedValue());
  }
  // MO must be an Expr.
  assert(MO.isExpr());
  return getExprOpValue(MO.getExpr(),Fixups, STI);
}

/// getMemEncoding - Return binary encoding of memory related operand.
/// If the offset operand requires relocation, record the relocation.
unsigned
FgpuMCCodeEmitter::getMemEncoding(const MCInst &MI, unsigned OpNo,
                                  SmallVectorImpl<MCFixup> &Fixups,
                                  const MCSubtargetInfo &STI) const {
  // assert(MI.getOperand(OpNo).isReg());
  // Base register is encoded in bits 9-5, offset is encoded in bits 23-10.
  unsigned RegBits = getMachineOpValue(MI, MI.getOperand(OpNo), Fixups, STI);
  unsigned OffBits = getMachineOpValue(MI, MI.getOperand(OpNo+1), Fixups, STI)/4;
  DEBUG(dbgs() << "soubhi : RegBits = " << RegBits << "\n");
  DEBUG(dbgs() << "soubhi : OffBits = " << OffBits << "\n");
  DEBUG(dbgs() << "soubhi : res = " << (((OffBits & 0x3FFF)<<5) | (RegBits & 0x1F)) << "\n");

  return ((OffBits & 0x3FFF)<<5) | (RegBits & 0x1F);
}

#include "FgpuGenMCCodeEmitter.inc"

