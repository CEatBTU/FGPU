//===-- FgpuMCTargetDesc.h - Fgpu Target Descriptions -----------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file provides Fgpu specific target descriptions.
//
//===----------------------------------------------------------------------===//

#ifndef FGPUMCTARGETDESC_H
#define FGPUMCTARGETDESC_H

#include "llvm/Support/DataTypes.h"

namespace llvm {
class MCAsmBackend;
class MCCodeEmitter;
class MCContext;
class MCInstrInfo;
class MCObjectWriter;
class MCRegisterInfo;
class MCSubtargetInfo;
class StringRef;
class Target;
class Triple;
class raw_ostream;
class raw_pwrite_stream;

extern Target TheFgpuTarget;

MCCodeEmitter *createFgpuMCCodeEmitter(const MCInstrInfo &MCII,
                                         const MCRegisterInfo &MRI,
                                         MCContext &Ctx);

MCAsmBackend *createFgpuAsmBackend(const Target &T,
                                       const MCRegisterInfo &MRI,
                                       const Triple &TT, StringRef CPU);

MCObjectWriter *createFgpuELFObjectWriter(raw_pwrite_stream &OS,
                                          uint8_t OSABI,
                                          bool IsLittleEndian);
} // End llvm namespace

// Defines symbolic names for Fgpu registers.  This defines a mapping from
// register name to register number.
#define GET_REGINFO_ENUM
#include "FgpuGenRegisterInfo.inc"

// Defines symbolic names for the Fgpu instructions.
#define GET_INSTRINFO_ENUM
#include "FgpuGenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "FgpuGenSubtargetInfo.inc"

#endif
