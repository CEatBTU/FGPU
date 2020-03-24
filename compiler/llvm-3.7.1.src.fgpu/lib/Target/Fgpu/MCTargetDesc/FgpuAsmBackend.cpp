//===-- FgpuASMBackend.cpp - Fgpu Asm Backend  ----------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the FgpuAsmBackend and FgpuELFObjectWriter classes.
//
//===----------------------------------------------------------------------===//
//

#include "MCTargetDesc/FgpuFixupKinds.h"
#include "MCTargetDesc/FgpuAsmBackend.h"

#include "MCTargetDesc/FgpuMCTargetDesc.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCDirectives.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCFixupKindInfo.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/Debug.h"

#include "llvm/ADT/StringExtras.h"

using namespace llvm;


#define DEBUG_TYPE "fgpu-asmbackend"
// Prepare value for the target space for it
static unsigned adjustFixupValue(const MCFixup &Fixup, uint64_t Value, MCContext *Ctx = nullptr)
{
  unsigned Kind = Fixup.getKind();
  // Add/subtract and shift
  switch (Kind) {
  default:
    return 0;
  case Fgpu::fixup_Fgpu_PC14:
    // For branches we start 1 instruction after the branch
    // so the displacement will be one instruction size less.
    Value -= 4;
    break;
  case Fgpu::fixup_Fgpu_JSUB:
    break;
  }
  return Value;
}

MCObjectWriter *FgpuAsmBackend::createObjectWriter(raw_pwrite_stream &OS) const {
  return createFgpuELFObjectWriter(OS,
    MCELFObjectTargetWriter::getOSABI(OSType), IsLittle);
}

void FgpuAsmBackend::applyFixup(const MCFixup &Fixup, char *Data, unsigned DataSize, uint64_t Value, bool IsPCRel) const {
  // ApplyFixup - Apply the \arg Value for given \arg Fixup into the provided
  // data fragment, at the offset specified by the fixup and following the
  // fixup kind as appropriate.
  // Data: a pointer to the beginning of the code and the code size if DataSize
  // Value: the offset between the branch instruction and the target

  MCFixupKind Kind = Fixup.getKind();
  Value = adjustFixupValue(Fixup, Value);
  unsigned Offset = Fixup.getOffset();
  if (!Value)
    return; // Doesn't change encoding.
  DEBUG(dbgs() << "soubhi: applyFixup entered\n");
  DEBUG(dbgs() << "soubhi: Value = " << (int)Value << "\n");
  DEBUG(dbgs() << "soubhi: applyFixup Offset = " << Offset << "\n");
  // Where do we start in the object

  // for(unsigned i = 0; i < 8; i++)
  //   DEBUG(dbgs() << "soubhi: applyFixup Data[" << i << "] = " << StringRef(utohexstr(Data[i])) << "\n");

  uint64_t Mask = ((uint64_t)(-1) >> (64 - getFixupKindInfo(Kind).TargetSize));
  DEBUG(dbgs() << "soubhi: applyFixup TargetSize = " << getFixupKindInfo(Kind).TargetSize  << "\n");
  DEBUG(dbgs() << " applyFixup Mask = 0x" << StringRef(utohexstr(Mask)) << "\n");
  assert(IsLittle);
  uint32_t *Dst32 = (uint32_t*)(Data + Offset);
  DEBUG(dbgs() << " old Dst32 = 0x" << StringRef(utohexstr(*Dst32)) << "\n");
  *Dst32 |= ((Value/4) & Mask) << 10; // old branch offset is captured
  DEBUG(dbgs() << " new Dst32 = 0x" << StringRef(utohexstr(*Dst32)) << "\n");

}

const MCFixupKindInfo &FgpuAsmBackend::getFixupKindInfo(MCFixupKind Kind) const {
  const static MCFixupKindInfo Infos[Fgpu::NumTargetFixupKinds] = {
    // This table *must* be in same the order of fixup_* kinds in
    // FgpuFixupKinds.h.
    //
    // name                        offset  bits  flags
    { "fixup_Fgpu_PC14",           0,     14,  MCFixupKindInfo::FKF_IsPCRel },
    { "fixup_Fgpu_JSUB",           0,     14,  MCFixupKindInfo::FKF_IsPCRel }
  };

  if (Kind < FirstTargetFixupKind)
    return MCAsmBackend::getFixupKindInfo(Kind);

  assert(unsigned(Kind - FirstTargetFixupKind) < getNumFixupKinds() &&
         "Invalid kind!");
  return Infos[Kind - FirstTargetFixupKind];
}

/// WriteNopData - Write an (optimal) nop sequence of Count bytes
/// to the given output. If the target cannot generate such a sequence,
/// it should return an error.
///
/// \return - True on success.
bool FgpuAsmBackend::writeNopData(uint64_t Count, MCObjectWriter *OW) const {
  return true;
}

// MCAsmBackend
MCAsmBackend *llvm::createFgpuAsmBackend(const Target &T, const MCRegisterInfo &MRI, const Triple &TT, StringRef CPU) {
  return new FgpuAsmBackend(T, TT.getOS(), /*IsLittle*/true);
}


