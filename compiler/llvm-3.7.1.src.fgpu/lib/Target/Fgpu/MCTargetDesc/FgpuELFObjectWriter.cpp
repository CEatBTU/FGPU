//===-- FgpuELFObjectWriter.cpp - Fgpu ELF Writer -------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/FgpuBaseInfo.h"
#include "MCTargetDesc/FgpuFixupKinds.h"
#include "MCTargetDesc/FgpuMCTargetDesc.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCSection.h"
#include "llvm/MC/MCValue.h"
#include "llvm/Support/ErrorHandling.h"
#include <list>

using namespace llvm;

namespace {
  class FgpuELFObjectWriter : public MCELFObjectTargetWriter {
  public:
    FgpuELFObjectWriter(uint8_t OSABI);

    unsigned GetRelocType(const MCValue &Target, const MCFixup &Fixup,
                          bool IsPCRel) const override {
      return Fixup.getKind();
    }

  };
}

FgpuELFObjectWriter::FgpuELFObjectWriter(uint8_t OSABI)
  : MCELFObjectTargetWriter(/*_is64Bit=false*/ false, OSABI, ELF::EM_FGPU,
                            /*HasRelocationAddend*/ false) {}


MCObjectWriter *llvm::createFgpuELFObjectWriter(raw_pwrite_stream &OS,
                                                uint8_t OSABI,
                                                bool IsLittleEndian) {
  MCELFObjectTargetWriter *MOTW = new FgpuELFObjectWriter(OSABI);
  return createELFObjectWriter(MOTW, OS, IsLittleEndian);
}

