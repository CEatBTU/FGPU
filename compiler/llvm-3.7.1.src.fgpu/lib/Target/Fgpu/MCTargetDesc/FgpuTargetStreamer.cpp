//===-- FgpuTargetStreamer.cpp - Fgpu Target Streamer Methods -------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file provides Fgpu specific target streamer methods.
//
//===----------------------------------------------------------------------===//

#include "InstPrinter/FgpuInstPrinter.h"
#include "FgpuMCTargetDesc.h"
#include "FgpuTargetObjectFile.h"
#include "FgpuTargetStreamer.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCSectionELF.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCSymbolELF.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ELF.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FormattedStream.h"

using namespace llvm;

FgpuTargetStreamer::FgpuTargetStreamer(MCStreamer &S)
    : MCTargetStreamer(S) {
}

FgpuTargetAsmStreamer::FgpuTargetAsmStreamer(MCStreamer &S,
                                             formatted_raw_ostream &OS)
    : FgpuTargetStreamer(S), OS(OS) {}

