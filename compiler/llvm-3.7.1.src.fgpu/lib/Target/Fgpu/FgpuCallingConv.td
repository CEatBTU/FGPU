//===-- FgpuCallingConv.td - Calling Conventions for Fgpu --*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// This describes the calling conventions for Fgpu architecture.
//===----------------------------------------------------------------------===//

def RetCC_FgpuEABI : CallingConv<[
  CCIfType<[i32,f32], CCAssignToReg<[R1, R2, R3, R4, R5, R6, R7, R8]>>
]>;

def RetCC_Fgpu : CallingConv<[
  CCDelegateTo<RetCC_FgpuEABI>
]>;

def CSR_CC_Fgpu : CalleeSavedRegs<(sequence "R%u", 9, 29)>;

