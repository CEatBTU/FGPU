//===-- FgpuMCTargetDesc.cpp - Fgpu Target Descriptions -------------------===//
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

#include "FgpuMCTargetDesc.h"
#include "InstPrinter/FgpuInstPrinter.h"
#include "FgpuMCAsmInfo.h"
#include "FgpuTargetStreamer.h"
#include "llvm/MC/MachineLocation.h"
#include "llvm/MC/MCCodeGenInfo.h"
#include "llvm/MC/MCELFStreamer.h"
#include "llvm/MC/MCInstPrinter.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FormattedStream.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "fgpu-mctarget"
using namespace llvm;

#define GET_INSTRINFO_MC_DESC
#include "FgpuGenInstrInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "FgpuGenSubtargetInfo.inc"

#define GET_REGINFO_MC_DESC
#include "FgpuGenRegisterInfo.inc"

// Select the Fgpu Architecture Feature for the given triple and cpu name.
// The function will be called at command 'llvm-objdump -d' for Fgpu elf input.
static StringRef selectFgpuArchFeature(const Triple &TT, StringRef CPU) {
  std::string FgpuArchFeature;
  if (CPU.empty() || CPU == "generic") {
    if (TT.getArch() == Triple::fgpu) {
       // if (CPU == "fgpu32") {
          // FgpuArchFeature = "+fgpu32";
        // }
    }
  }
  return FgpuArchFeature;
}

static MCInstrInfo *createFgpuMCInstrInfo() {
  MCInstrInfo *X = new MCInstrInfo();
  InitFgpuMCInstrInfo(X); // defined in FgpuGenInstrInfo.inc
  return X;
}

static MCRegisterInfo *createFgpuMCRegisterInfo(const Triple &TT) {
  MCRegisterInfo *X = new MCRegisterInfo();
  InitFgpuMCRegisterInfo(X, Fgpu::LR); // defined in FgpuGenRegisterInfo.inc
  return X;
}

static MCSubtargetInfo *createFgpuMCSubtargetInfo(const Triple &TT,
                                                  StringRef CPU, StringRef FS) {
  std::string ArchFS = selectFgpuArchFeature(TT,CPU);
  if (!FS.empty()) {
    if (!ArchFS.empty())
      ArchFS = ArchFS + "," + FS.str();
    else
      ArchFS = FS;
  }
  // DEBUG(dbgs() << "soubhi: ArchFS=" << ArchFS << "\n");
  // DEBUG(dbgs() << "soubhi: CPU=" << CPU.str() << "\n");
  // DEBUG(dbgs() << "soubhi: FS=" << FS.str() << "\n");
  // DEBUG(dbgs() << "soubhi: TT=" << TT.str() << "\n");
  return createFgpuMCSubtargetInfoImpl(TT, CPU, ArchFS);
// createFgpuMCSubtargetInfoImpl defined in FgpuGenSubtargetInfo.inc
}

static MCAsmInfo *createFgpuMCAsmInfo(const MCRegisterInfo &MRI,
                                      const Triple &TT) {
  MCAsmInfo *MAI = new FgpuMCAsmInfo(TT);

  unsigned SP = MRI.getDwarfRegNum(Fgpu::SP, true);
  MCCFIInstruction Inst = MCCFIInstruction::createDefCfa(0, SP, 0);
  MAI->addInitialFrameState(Inst);

  return MAI;
}

static MCCodeGenInfo *createFgpuMCCodeGenInfo(const Triple &TT, Reloc::Model RM,
                                              CodeModel::Model CM,
                                              CodeGenOpt::Level OL) {
  MCCodeGenInfo *X = new MCCodeGenInfo();
  // if (CM == CodeModel::JITDefault)
    RM = Reloc::Static;
  // else if (RM == Reloc::Default)
    // RM = Reloc::PIC_;
  X->initMCCodeGenInfo(RM, CM, OL); // defined in lib/MC/MCCodeGenInfo.cpp
  return X;
}

static MCInstPrinter *createFgpuMCInstPrinter(const Triple &T,
                                              unsigned SyntaxVariant,
                                              const MCAsmInfo &MAI,
                                              const MCInstrInfo &MII,
                                              const MCRegisterInfo &MRI) {
  return new FgpuInstPrinter(MAI, MII, MRI);
}

static MCStreamer *createMCStreamer(const Triple &TT, MCContext &Context, 
                                    MCAsmBackend &MAB, raw_pwrite_stream &OS, 
                                    MCCodeEmitter *Emitter, bool RelaxAll) {
  return createELFStreamer(Context, MAB, OS, Emitter, RelaxAll);
}

static MCTargetStreamer *createFgpuAsmTargetStreamer(MCStreamer &S,
                                                     formatted_raw_ostream &OS,
                                                     MCInstPrinter *InstPrint,
                                                     bool isVerboseAsm) {
  return new FgpuTargetAsmStreamer(S, OS);
}

extern "C" void LLVMInitializeFgpuTargetMC() {
  for (Target *T : {&TheFgpuTarget}) {
  // Register the MC asm info.
  RegisterMCAsmInfoFn X(*T, createFgpuMCAsmInfo);
  
  // Register the MC codegen info.
  TargetRegistry::RegisterMCCodeGenInfo(*T,
                                     createFgpuMCCodeGenInfo);
  
  // Register the MC instruction info.
  TargetRegistry::RegisterMCInstrInfo(*T, createFgpuMCInstrInfo);
  
  // Register the MC register info.
  TargetRegistry::RegisterMCRegInfo(*T, createFgpuMCRegisterInfo);
 
  // Register the elf streamer.
  TargetRegistry::RegisterELFStreamer(*T, createMCStreamer);
  
  // Register the asm target streamer.
  TargetRegistry::RegisterAsmTargetStreamer(*T, createFgpuAsmTargetStreamer);
  
  // Register the MC subtarget info.
  TargetRegistry::RegisterMCSubtargetInfo(*T,
                                        createFgpuMCSubtargetInfo);
  // Register the MCInstPrinter.
  TargetRegistry::RegisterMCInstPrinter(*T,
                                       createFgpuMCInstPrinter);
  }

  // Register the MC Code Emitter
  TargetRegistry::RegisterMCCodeEmitter(TheFgpuTarget,
                                        createFgpuMCCodeEmitter);

  // Register the asm backend.
  TargetRegistry::RegisterMCAsmBackend(TheFgpuTarget,
                                       createFgpuAsmBackend);
}
