//===- FgpuDisassembler.cpp - Disassembler for Fgpu -------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file is part of the Fgpu Disassembler.
//
//===----------------------------------------------------------------------===//

#include "Fgpu.h"

#include "FgpuRegisterInfo.h"
#include "FgpuSubtarget.h"
#include "llvm/MC/MCDisassembler.h"
#include "llvm/MC/MCFixedLenDisassembler.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/MemoryObject.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/Debug.h"

using namespace llvm;

#define DEBUG_TYPE "fgpu-disassembler"

typedef MCDisassembler::DecodeStatus DecodeStatus;

namespace {

/// FgpuDisassemblerBase - a disasembler class for Fgpu.
class FgpuDisassemblerBase : public MCDisassembler {
public:
  /// Constructor     - Initializes the disassembler.
  ///
  FgpuDisassemblerBase(const MCSubtargetInfo &STI, MCContext &Ctx,
                       bool bigEndian) :
    MCDisassembler(STI, Ctx),
    IsBigEndian(bigEndian) {}

  virtual ~FgpuDisassemblerBase() {}

protected:
  bool IsBigEndian;
};

/// FgpuDisassembler - a disasembler class for Fgpu32.
class FgpuDisassembler : public FgpuDisassemblerBase {
public:
  /// Constructor     - Initializes the disassembler.
  ///
  FgpuDisassembler(const MCSubtargetInfo &STI, MCContext &Ctx, bool bigEndian)
      : FgpuDisassemblerBase(STI, Ctx, bigEndian) {
  }

  /// getInstruction - See MCDisassembler.
  DecodeStatus getInstruction(MCInst &Instr, uint64_t &Size,
                              ArrayRef<uint8_t> Bytes, uint64_t Address,
                              raw_ostream &VStream,
                              raw_ostream &CStream) const override;
};

} // end anonymous namespace
// Decoder tables for ALURegs registers
static const unsigned ALURegsTable[] = {
  Fgpu::R0, Fgpu::R1, Fgpu::R2, Fgpu::R3,
  Fgpu::R4, Fgpu::R5, Fgpu::R6, Fgpu::R7, 
  Fgpu::R8, Fgpu::R9, Fgpu::R10, Fgpu::R11, 
  Fgpu::R12, Fgpu::R13, Fgpu::R14, Fgpu::R15,
  Fgpu::R16, Fgpu::R17, Fgpu::R18, Fgpu::R19,
  Fgpu::R20, Fgpu::R21, Fgpu::R22, Fgpu::R23,
  Fgpu::R24, Fgpu::R25, Fgpu::R26, Fgpu::R27,
  Fgpu::R28, Fgpu::R29, Fgpu::LR, Fgpu::SP
};


static DecodeStatus DecodeFloatRegsRegisterClass(MCInst &Inst,
                                               unsigned RegNo,
                                               uint64_t Address,
                                               const void *Decoder);
static DecodeStatus DecodeALURegsRegisterClass(MCInst &Inst,
                                               unsigned RegNo,
                                               uint64_t Address,
                                               const void *Decoder);
static DecodeStatus DecodeGPROutRegisterClass(MCInst &Inst,
                                               unsigned RegNo,
                                               uint64_t Address,
                                               const void *Decoder);
static DecodeStatus DecodeMem(MCInst &Inst,
                              unsigned Insn,
                              uint64_t Address,
                              const void *Decoder);
static DecodeStatus DecodeSimm14(MCInst &Inst, unsigned Insn, uint64_t Address, const void *Decoder);
static DecodeStatus DecodeUimm14(MCInst &Inst, unsigned Insn, uint64_t Address, const void *Decoder);
static DecodeStatus DecodeUimm16(MCInst &Inst, unsigned Insn, uint64_t Address, const void *Decoder);

namespace llvm {
extern Target TheFgpuTarget;
}

static MCDisassembler *createFgpuDisassembler(
                       const Target &T,
                       const MCSubtargetInfo &STI,
                       MCContext &Ctx) {
  return new FgpuDisassembler(STI, Ctx, false);
}

extern "C" void LLVMInitializeFgpuDisassembler() {
  // Register the disassembler.
  TargetRegistry::RegisterMCDisassembler(TheFgpuTarget,
                                         createFgpuDisassembler);
}


#include "FgpuGenDisassemblerTables.inc"

/// Read four bytes from the ArrayRef and return 32 bit word sorted
/// according to the given endianess
static DecodeStatus readInstruction32(ArrayRef<uint8_t> Bytes, uint64_t Address,
                                      uint64_t &Size, uint32_t &Insn,
                                      bool IsBigEndian) {
  // We want to read exactly 4 Bytes of data.
  if (Bytes.size() < 4) {
    Size = 0;
    return MCDisassembler::Fail;
  }
  // DEBUG(dbgs() << "readInstruction entered, isBigEndian = " << IsBigEndian << "\n");

  if (IsBigEndian) {
    // Encoded as a big-endian 32-bit word in the stream.
    Insn = (Bytes[3] <<  0) |
           (Bytes[2] <<  8) |
           (Bytes[1] << 16) |
           (Bytes[0] << 24);
  }
  else {
    // Encoded as a small-endian 32-bit word in the stream.
    Insn = (Bytes[0] <<  0) |
           (Bytes[1] <<  8) |
           (Bytes[2] << 16) |
           (Bytes[3] << 24);
  }

  return MCDisassembler::Success;
}

DecodeStatus
FgpuDisassembler::getInstruction(MCInst &Instr, uint64_t &Size,
                                              ArrayRef<uint8_t> Bytes,
                                              uint64_t Address,
                                              raw_ostream &VStream,
                                              raw_ostream &CStream) const {
  uint32_t Insn;

  DecodeStatus Result;

  Result = readInstruction32(Bytes, Address, Size, Insn, IsBigEndian);

  if (Result == MCDisassembler::Fail)
    return MCDisassembler::Fail;

  // Calling the auto-generated decoder function.
  Result = decodeInstruction(DecoderTableFgpu32, Instr, Insn, Address,
                             this, STI);
  if (Result != MCDisassembler::Fail) {
    Size = 4;
    return Result;
  }

  return MCDisassembler::Fail;
}

static DecodeStatus DecodeFloatRegsRegisterClass(MCInst &Inst,
                                               unsigned RegNo,
                                               uint64_t Address,
                                               const void *Decoder) {
  if (RegNo > 30)
    return MCDisassembler::Fail;

  Inst.addOperand(MCOperand::createReg(ALURegsTable[RegNo]));
  return MCDisassembler::Success;
}
static DecodeStatus DecodeALURegsRegisterClass(MCInst &Inst,
                                               unsigned RegNo,
                                               uint64_t Address,
                                               const void *Decoder) {
  if (RegNo > 32)
    return MCDisassembler::Fail;

  Inst.addOperand(MCOperand::createReg(ALURegsTable[RegNo]));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeGPROutRegisterClass(MCInst &Inst,
                                               unsigned RegNo,
                                               uint64_t Address,
                                               const void *Decoder) {
  if (RegNo > 31)
    return MCDisassembler::Fail;
  return DecodeALURegsRegisterClass(Inst, RegNo, Address, Decoder);
}

static DecodeStatus DecodeMem(MCInst &Inst,  unsigned Insn,  uint64_t Address, const void *Decoder) {
  int Offset = SignExtend32<14>((Insn>>5) & 0x3fff);
  int Base = (int)fieldFromInstruction(Insn, 0, 5);

  Inst.addOperand(MCOperand::createReg(ALURegsTable[Base]));
  Inst.addOperand(MCOperand::createImm(Offset));

  return MCDisassembler::Success;
}

static DecodeStatus DecodeSimm14(MCInst &Inst, unsigned Insn, uint64_t Address, const void *Decoder) {
  Inst.addOperand(MCOperand::createImm(SignExtend32<14>(Insn)));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeUimm14(MCInst &Inst, unsigned Insn, uint64_t Address, const void *Decoder) {
  Inst.addOperand(MCOperand::createImm(Insn));
  return MCDisassembler::Success;
}
static DecodeStatus DecodeUimm16(MCInst &Inst, unsigned Insn, uint64_t Address, const void *Decoder) {
  DEBUG(dbgs() << "DecodeUimm16 entered, Insn  = " << Insn << "\n");
  Inst.addOperand(MCOperand::createImm(SignExtend32<16>(Insn)));
  return MCDisassembler::Success;
}
