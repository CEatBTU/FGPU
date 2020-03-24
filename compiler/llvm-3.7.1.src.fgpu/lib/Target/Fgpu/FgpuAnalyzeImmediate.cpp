//===-- FgpuAnalyzeImmediate.cpp - Analyze Immediates ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
#include "FgpuAnalyzeImmediate.h"
#include "Fgpu.h"

#include "llvm/Support/MathExtras.h"

using namespace llvm;

FgpuAnalyzeImmediate::Inst::Inst(unsigned O, unsigned I) : Opc(O), ImmOpnd(I) {}

// Add I to the instruction sequences.
void FgpuAnalyzeImmediate::AddInstr(InstSeqLs &SeqLs, const Inst &I) {
  // Add an instruction seqeunce consisting of just I.
  if (SeqLs.empty()) {
    SeqLs.push_back(InstSeq(1, I));
    return;
  }

  for (InstSeqLs::iterator Iter = SeqLs.begin(); Iter != SeqLs.end(); ++Iter)
    Iter->push_back(I);
}


void FgpuAnalyzeImmediate::GetInstSeqLs(uint64_t Imm, unsigned RemSize, InstSeqLs &SeqLs) {
  uint64_t MaskedImm = Imm & (0xffffffffffffffffULL >> (64 - Size));

  // Do nothing if Imm is 0.
  if (!MaskedImm)
    return;

  // A single ADDi will do if RemSize <= 16.
  AddInstr(SeqLs, Inst(Li, MaskedImm));
  AddInstr(SeqLs, Inst(LUi, MaskedImm));
}


const FgpuAnalyzeImmediate::InstSeq
&FgpuAnalyzeImmediate::Analyze(uint64_t Imm, unsigned Size) {
  this->Size = Size;

  Li = Fgpu::Li;
  LUi = Fgpu::LUi;

  InstSeqLs SeqLs;
  
  // Get the list of instruction sequences.
  GetInstSeqLs(Imm, Size, SeqLs);

  return Insts;
}

