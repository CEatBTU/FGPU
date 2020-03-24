//===-- Fgpu.td - Describe the Fgpu Target Machine ---------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Calling Conv, Instruction Descriptions
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

def FeatureHardFloat   : SubtargetFeature<"fgpu-hard-float", "HardFloatUnits", "true",
                                "fadd, fmul, fdiv, fsub">;

include "FgpuSchedule.td"
include "FgpuInstrInfo.td"
include "FgpuCallingConv.td"

def FgpuInstrInfo : InstrInfo;

// Without this will have error: 'fgpu32' is not a recognized processor for 
//  this target (ignoring processor)
//===----------------------------------------------------------------------===//
// Fgpu Subtarget features                                                    //
//===----------------------------------------------------------------------===//

def FeatureSoftFloat   : SubtargetFeature<"soft-float", "IsSoftFloat", "true",
                                "Does not support floating point instructions">;


//===----------------------------------------------------------------------===//
// Fgpu processors supported.
//===----------------------------------------------------------------------===//

class Proc<string Name, list<SubtargetFeature> Features>
 : Processor<Name, FgpuGenericItineraries, Features>;

def : Proc<"fgpu32",  []>;

def FgpuAsmParser : AsmParser {
  let ShouldEmitMatchRegisterName = 0;
}

def FgpuAsmParserVariant : AsmParserVariant {
  int Variant = 0;

  // Recognize hard coded registers.
  string RegisterPrefix = "r";
}

// Will generate FgpuGenAsmWrite.inc included by FgpuInstPrinter.cpp, contents 
//  as follows,
// void FgpuInstPrinter::printInstruction(const MCInst *MI, raw_ostream &O) {...}
// const char *FgpuInstPrinter::getRegisterName(unsigned RegNo) {...}
def Fgpu : Target {
// def FgpuInstrInfo : InstrInfo as before.
  let InstructionSet = FgpuInstrInfo;
  let AssemblyParsers = [FgpuAsmParser];
  let AssemblyParserVariants = [FgpuAsmParserVariant];
}
