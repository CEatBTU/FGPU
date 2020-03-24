//===-- FgpuBaseInfo.h - Top level definitions for FGPU MC ------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains small standalone helper functions and enum definitions for
// the Fgpu target useful for the compiler back-end and the MC libraries.
//
//===----------------------------------------------------------------------===//
#ifndef FGPUBASEINFO_H
#define FGPUBASEINFO_H


#include "FgpuFixupKinds.h"
#include "FgpuMCTargetDesc.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/Support/DataTypes.h"
#include "llvm/Support/ErrorHandling.h"

namespace llvm {

/// FgpuII - This namespace holds all of the target specific flags that
/// instruction info tracks.
//@FgpuII
namespace FgpuII {
  /// Target Operand Flag enum.
  enum TOF {
    //===------------------------------------------------------------------===//
    // Fgpu Specific MachineOperand flags.

    MO_NO_FLAG,

    /// MO_GOT16 - Represents the offset into the global offset table at which
    /// the address the relocation entry symbol resides during execution.
    // MO_GOT16,
    // MO_GOT,

    /// MO_GOT_CALL - Represents the offset into the global offset table at
    /// which the address of a call site relocation entry symbol resides
    /// during execution. This is different from the above since this flag
    /// can only be present in call instructions.
    // MO_GOT_CALL,

    /// MO_GPREL - Represents the offset from the current gp value to be used
    /// for the relocatable object file being produced.
    // MO_GPREL,

    /// MO_ABS_HI/LO - Represents the hi or low part of an absolute symbol
    /// address.
    // MO_ABS_HI,
    // MO_ABS_LO,

    /// MO_TLSGD - Represents the offset into the global offset table at which
    // the module ID and TSL block offset reside during execution (General
    // Dynamic TLS).
    // MO_TLSGD,

    /// MO_TLSLDM - Represents the offset into the global offset table at which
    // the module ID and TSL block offset reside during execution (Local
    // Dynamic TLS).
    // MO_TLSLDM,
    // MO_DTP_HI,
    // MO_DTP_LO,

    /// MO_GOTTPREL - Represents the offset from the thread pointer (Initial
    // Exec TLS).
    // MO_GOTTPREL,

    /// MO_TPREL_HI/LO - Represents the hi and low part of the offset from
    // the thread pointer (Local Exec TLS).
    // MO_TP_HI,
    // MO_TP_LO,

    // MO_GOT_DISP,
    // MO_GOT_PAGE,
    // MO_GOT_OFST,
    //
    // // N32/64 Flags.
    // MO_GPOFF_HI,
    // MO_GPOFF_LO,
    //
    // /// MO_GOT_HI16/LO16 - Relocations used for large GOTs.
    // MO_GOT_HI16,
    // MO_GOT_LO16
  }; // enum TOF {

  enum {
    //===------------------------------------------------------------------===//
    // Instruction encodings.  These are the standard/most common forms for
    // Fgpu instructions.
    //

    // Pseudo - This represents an instruction that is a pseudo instruction
    // or one that has not been implemented yet.  It is illegal to code generate
    // it, but tolerated for intermediate implementation stages.
    FrmPseudo = 0,

    /// This form is for instructions of the format RRR.
    FrmRRR  = 1,
    /// This form is for instructions of the format RRI.
    FrmRRI  = 2,
    /// FrmOther - This form is for instructions that have no specific format.
    FrmRI = 3,
    // ret operation
    FrmCtrl = 4,
    FrmMask = 15
  };
}

//@get register number
/// getFgpuRegisterNumbering - Given the enum value for some register,
/// return the number that it corresponds to.
inline static unsigned getFgpuRegisterNumbering(unsigned RegEnum)
{
  switch (RegEnum) {
  //@1
  case Fgpu::R0:
    return 0;
  case Fgpu::R1:
    return 1;
  case Fgpu::R2:
    return 2;
  case Fgpu::R3:
    return 3;
  case Fgpu::R4:
    return 4;
  case Fgpu::R5:
    return 5;
  case Fgpu::R6:
    return 6;
  case Fgpu::R7:
    return 7;
  case Fgpu::R8:
    return 8;
  case Fgpu::R9:
    return 9;
  case Fgpu::R10:
    return 10;
  case Fgpu::R11:
    return 11;
  case Fgpu::R12:
    return 12;
  case Fgpu::R13:
    return 13;
  case Fgpu::R14:
    return 14;
  case Fgpu::R15:
    return 15;
  case Fgpu::R16:
    return 16;
  case Fgpu::R17:
    return 17;
  case Fgpu::R18:
    return 18;
  case Fgpu::R19:
    return 19;
  case Fgpu::R20:
    return 20;
  case Fgpu::R21:
    return 21;
  case Fgpu::R22:
    return 22;
  case Fgpu::R23:
    return 23;
  case Fgpu::R24:
    return 24;
  case Fgpu::R25:
    return 25;
  case Fgpu::R26:
    return 26;
  case Fgpu::R27:
    return 27;
  case Fgpu::R28:
    return 28;
  case Fgpu::R29:
    return 29;
  case Fgpu::LR:
    return 30;
  case Fgpu::SP:
    return 31;
  default: llvm_unreachable("Unknown register number!");
  }
}

}
#endif
