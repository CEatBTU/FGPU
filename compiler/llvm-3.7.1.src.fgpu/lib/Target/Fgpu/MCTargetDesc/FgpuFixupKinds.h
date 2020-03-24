//===-- FgpuFixupKinds.h - Fgpu Specific Fixup Entries ----------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_FGPU_FGPUFIXUPKINDS_H
#define LLVM_FGPU_FGPUFIXUPKINDS_H

#include "llvm/MC/MCFixup.h"

namespace llvm {
namespace Fgpu {
  // Although most of the current fixup types reflect a unique relocation
  // one can have multiple fixup types for a given relocation and thus need
  // to be uniquely named.
  //
  // This table *must* be in the save order of
  // MCFixupKindInfo Infos[Fgpu::NumTargetFixupKinds]
  // in FgpuAsmBackend.cpp.
  //@Fixups {
  enum Fixups {
    // PC relative branch fixup resulting in - R_FGPU_PC14.
    // fgpu PC14, e.g. beq
    fixup_Fgpu_PC14 = FirstTargetFixupKind,
    fixup_Fgpu_JSUB,

    // Marker
    LastTargetFixupKind,
    NumTargetFixupKinds = LastTargetFixupKind - FirstTargetFixupKind
  };
  //@Fixups }
} // namespace Fgpu
} // namespace llvm


#endif // LLVM_FGPU_FGPUFIXUPKINDS_H
