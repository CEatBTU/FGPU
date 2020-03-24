//===---- FgpuABIInfo.h - Information about FGPU ABI's --------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_FGPU_MCTARGETDESC_FGPUABIINFO_H
#define LLVM_LIB_TARGET_FGPU_MCTARGETDESC_FGPUABIINFO_H


#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/Triple.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/MC/MCRegisterInfo.h"

namespace llvm {

class MCTargetOptions;
class StringRef;
class TargetRegisterClass;

class FgpuABIInfo {
public:
  enum class ABI { Unknown, CC_Fgpu};

protected:
  ABI ThisABI;

public:
  FgpuABIInfo(ABI ThisABI) : ThisABI(ThisABI) {}

  static FgpuABIInfo Unknown() { return FgpuABIInfo(ABI::Unknown); }
  static FgpuABIInfo CC_Fgpu() { return FgpuABIInfo(ABI::CC_Fgpu); }
  static FgpuABIInfo computeTargetABI();

  bool IsKnown() const { return ThisABI != ABI::Unknown; }
  ABI GetEnumValue() const { return ThisABI; }

  /// Obtain the size of the area allocated by the callee for arguments.
  /// CallingConv::FastCall affects the value for CC_Fgpu.
  unsigned GetCalleeAllocdArgSizeInBytes(CallingConv::ID CC) const;

  /// Ordering of ABI's
  /// FgpuGenSubtargetInfo.inc will use this to resolve conflicts when given
  /// multiple ABI options.
  bool operator<(const FgpuABIInfo Other) const {
    return ThisABI < Other.GetEnumValue();
  }

  unsigned GetStackPtr() const;
  unsigned GetFramePtr() const;
  unsigned GetNullPtr() const;

  unsigned GetEhDataReg(unsigned I) const;
};
}
#endif
