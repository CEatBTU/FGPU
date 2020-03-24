//===-- FgpuTargetStreamer.h - Fgpu Target Streamer ------------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_FGPU_FGPUTARGETSTREAMER_H
#define LLVM_LIB_TARGET_FGPU_FGPUTARGETSTREAMER_H

#include "llvm/MC/MCELFStreamer.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCStreamer.h"

namespace llvm {

class FgpuTargetStreamer : public MCTargetStreamer {
public:
  FgpuTargetStreamer(MCStreamer &S);
};

// This part is for ascii assembly output
class FgpuTargetAsmStreamer : public FgpuTargetStreamer {
  formatted_raw_ostream &OS;

public:
  FgpuTargetAsmStreamer(MCStreamer &S, formatted_raw_ostream &OS);
};

}

#endif
