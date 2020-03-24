//===-- FgpuAsmPrinter.cpp - Fgpu LLVM Assembly Printer -------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains a printer that converts from our internal representation
// of machine-dependent LLVM code to GAS-format FGPU assembly language.
//
//===----------------------------------------------------------------------===//

#include "FgpuAsmPrinter.h"

#include "InstPrinter/FgpuInstPrinter.h"
#include "MCTargetDesc/FgpuBaseInfo.h"
#include "Fgpu.h"
#include "FgpuInstrInfo.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/ADT/Twine.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineMemOperand.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Mangler.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Target/TargetLoweringObjectFile.h"
#include "llvm/Target/TargetOptions.h"

using namespace llvm;

#define DEBUG_TYPE "fgpu-asm-printer"

bool FgpuAsmPrinter::runOnMachineFunction(MachineFunction &MF) {
  DEBUG(dbgs() << "soubhi: FgpuAsmPrinter pass entered\n");
  FgpuFI = MF.getInfo<FgpuFunctionInfo>();
  AsmPrinter::runOnMachineFunction(MF);
  return true;
}


//- EmitInstruction() must exists or will have run time error.
void FgpuAsmPrinter::EmitInstruction(const MachineInstr *MI) {
  if (MI->isDebugValue()) {
    SmallString<128> Str;
    raw_svector_ostream OS(Str);

    PrintDebugValueComment(MI, OS);
    return;
  }

  MachineBasicBlock::const_instr_iterator I = MI;
  MachineBasicBlock::const_instr_iterator E = MI->getParent()->instr_end();

  MCInst TmpInst0;
  do {
    MCInstLowering.Lower(I, TmpInst0);
    OutStreamer->EmitInstruction(TmpInst0, getSubtargetInfo());
  } while ((++I != E) && I->isInsideBundle()); // Delay slot check
}

//===----------------------------------------------------------------------===//
// Mask directives
//===----------------------------------------------------------------------===//
//	.frame	$sp,8,$lr
//->	.mask 	0x00000000,0
//	.set	noreorder
//	.set	nomacro

// Create a bitmask with all callee saved registers for CPU or Floating Point
// registers. For CPU registers consider LR, GP and FP for saving if necessary.
void FgpuAsmPrinter::printSavedRegsBitmask(raw_ostream &O) {
  // CPU and FPU Saved Registers Bitmasks
  unsigned CPUBitmask = 0;
  int CPUTopSavedRegOff;

  // Set the CPU and FPU Bitmasks
  const MachineFrameInfo *MFI = MF->getFrameInfo();
  const std::vector<CalleeSavedInfo> &CSI = MFI->getCalleeSavedInfo();
  // size of stack area to which FP callee-saved regs are saved.
  unsigned GPROutSize = Fgpu::GPROutRegClass.getSize();
  unsigned i = 0, e = CSI.size();

  // Set CPU Bitmask.
  for (; i != e; ++i) {
    unsigned Reg = CSI[i].getReg();
    unsigned RegNum = getFgpuRegisterNumbering(Reg);
    CPUBitmask |= (1 << RegNum);
  }

  CPUTopSavedRegOff = CPUBitmask ? -GPROutSize : 0;

  // Print CPUBitmask
  O << "\t.mask \t"; printHex32(CPUBitmask, O);
  O << ',' << CPUTopSavedRegOff << '\n';
}

// Print a 32 bit hex number with all numbers.
void FgpuAsmPrinter::printHex32(unsigned Value, raw_ostream &O) {
  O << "0x";
  for (int i = 7; i >= 0; i--)
    O.write_hex((Value & (0xF << (i*4))) >> (i*4));
}

//===----------------------------------------------------------------------===//
// Frame and Set directives
//===----------------------------------------------------------------------===//
//->	.frame	$sp,8,$lr
//	.mask 	0x00000000,0
//	.set	noreorder
//	.set	nomacro
/// Frame Directive
void FgpuAsmPrinter::emitFrameDirective() {
  const TargetRegisterInfo &RI = *MF->getSubtarget().getRegisterInfo();

  unsigned stackReg  = RI.getFrameRegister(*MF);
  unsigned returnReg = RI.getRARegister();
  unsigned stackSize = MF->getFrameInfo()->getStackSize();
  auto stackRegString =  StringRef(FgpuInstPrinter::getRegisterName((stackReg))).lower();
  auto returnRegString =  StringRef(FgpuInstPrinter::getRegisterName((returnReg))).lower();

  if (OutStreamer->hasRawTextSupport())
    OutStreamer->EmitRawText("\t.frame\t" + stackRegString +
           "," + Twine(stackSize) + "," + returnRegString);
}

/// Emit Set directives.
const char *FgpuAsmPrinter::getCurrentABIString() const {
  switch (static_cast<FgpuTargetMachine &>(TM).getABI().GetEnumValue()) {
  case FgpuABIInfo::ABI::CC_Fgpu:  return "cc_fgpu";
  default: llvm_unreachable("Unknown Fgpu ABI");
  }
}

//		.type	main,@function
//->		.ent	main                    # @main
//	main:
void FgpuAsmPrinter::EmitFunctionEntryLabel() {
  if (OutStreamer->hasRawTextSupport())
    OutStreamer->EmitRawText("\t.ent\t" + Twine(CurrentFnSym->getName()));
  OutStreamer->EmitLabel(CurrentFnSym);
}


//  .frame  $sp,8,$pc
//  .mask   0x00000000,0
//->  .set  noreorder
//@-> .set  nomacro
/// EmitFunctionBodyStart - Targets can override this to emit stuff before
/// the first basic block in the function.
void FgpuAsmPrinter::EmitFunctionBodyStart() {
  MCInstLowering.Initialize(&MF->getContext());

  emitFrameDirective();


  if (OutStreamer->hasRawTextSupport()) {
    SmallString<128> Str;
    raw_svector_ostream OS(Str);
    printSavedRegsBitmask(OS);
    OutStreamer->EmitRawText(OS.str());
    OutStreamer->EmitRawText(StringRef("\t.set\tnoreorder"));
    OutStreamer->EmitRawText(StringRef("\t.set\tnomacro"));
  }
}

//->	.set	macro
//->	.set	reorder
//->	.end	main
/// EmitFunctionBodyEnd - Targets can override this to emit stuff after
/// the last basic block in the function.
void FgpuAsmPrinter::EmitFunctionBodyEnd() {
  // There are instruction for this macros, but they must
  // always be at the function end, and we can't emit and
  // break with BB logic.
  if (OutStreamer->hasRawTextSupport()) {
    OutStreamer->EmitRawText(StringRef("\t.set\tmacro"));
    OutStreamer->EmitRawText(StringRef("\t.set\treorder"));
    OutStreamer->EmitRawText("\t.end\t" + Twine(CurrentFnSym->getName()));
  }
}

//	.section .mdebug.abi32
//	.previous
void FgpuAsmPrinter::EmitStartOfAsmFile(Module &M) {
  // FIXME: Use SwitchSection.

  // Tell the assembler which ABI we are using
  if (OutStreamer->hasRawTextSupport())
    OutStreamer->EmitRawText("\t.section .mdebug." +
                            Twine(getCurrentABIString()));

  // return to previous section
  if (OutStreamer->hasRawTextSupport())
    OutStreamer->EmitRawText(StringRef("\t.previous"));
}

// Print out an operand for an inline asm expression.
bool FgpuAsmPrinter::PrintAsmOperand(const MachineInstr *MI, unsigned OpNum, unsigned AsmVariant,const char *ExtraCode, raw_ostream &O) {
  // Does this asm operand have a single letter operand modifier?
  DEBUG(dbgs() << "PrintAsmOperand entered\n");
  if (ExtraCode && ExtraCode[0]) {
    if (ExtraCode[1] != 0) return true; // Unknown modifier.

    const MachineOperand &MO = MI->getOperand(OpNum);
    switch (ExtraCode[0]) {
    default:
      // See if this is a generic print operand
      return AsmPrinter::PrintAsmOperand(MI,OpNum,AsmVariant,ExtraCode,O);
    case 'X': // hex const int
      if ((MO.getType()) != MachineOperand::MO_Immediate)
        return true;
      O << "0x" << StringRef(utohexstr(MO.getImm())).lower();
      return false;
    case 'x': // hex const int (low 16 bits)
      if ((MO.getType()) != MachineOperand::MO_Immediate)
        return true;
      O << "0x" << StringRef(utohexstr(MO.getImm() & 0xffff)).lower();
      return false;
    case 'd': // decimal const int
      if ((MO.getType()) != MachineOperand::MO_Immediate)
        return true;
      O << MO.getImm();
      return false;
    case 'm': // decimal const int minus 1
      if ((MO.getType()) != MachineOperand::MO_Immediate)
        return true;
      O << MO.getImm() - 1;
      return false;
    case 'z': 
      // R0 if zero, regular printing otherwise
      if (MO.getType() != MachineOperand::MO_Immediate)
        return true;
      int64_t Val = MO.getImm();
      if (Val)
        O << Val;
      else
        O << "r0";
      return false;
    }
  }
  printOperand(MI, OpNum, O);
  return false;
}

bool FgpuAsmPrinter::PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNum, unsigned AsmVariant, const char *ExtraCode, raw_ostream &O) {
  int Offset = 0;
  // Currently we are expecting either no ExtraCode or 'D'
  if (ExtraCode) {
    return true; // Unknown modifier.
  }

  const MachineOperand &MO = MI->getOperand(OpNum);
  assert(MO.isReg() && "unexpected inline asm memory operand");
  O << Offset << "(R" << FgpuInstPrinter::getRegisterName(MO.getReg()) << ")";

  return false;
}

void FgpuAsmPrinter::printOperand(const MachineInstr *MI, int opNum, raw_ostream &O) {
  const MachineOperand &MO = MI->getOperand(opNum);
  bool closeP = false;

  if (MO.getTargetFlags())
    closeP = true;

  switch (MO.getType()) {
    case MachineOperand::MO_Register:
      O << 'r'
        << StringRef(FgpuInstPrinter::getRegisterName(MO.getReg())).lower();
      break;

    case MachineOperand::MO_Immediate:
      O << MO.getImm();
      break;

    case MachineOperand::MO_MachineBasicBlock:
      O << *MO.getMBB()->getSymbol();
      return;

    case MachineOperand::MO_GlobalAddress:
      O << *getSymbol(MO.getGlobal());
      break;

    case MachineOperand::MO_BlockAddress: {
      MCSymbol *BA = GetBlockAddressSymbol(MO.getBlockAddress());
      O << BA->getName();
      break;
    }

    case MachineOperand::MO_ExternalSymbol:
      O << *GetExternalSymbolSymbol(MO.getSymbolName());
      break;

    case MachineOperand::MO_JumpTableIndex:
      O << MAI->getPrivateGlobalPrefix() << "JTI" << getFunctionNumber()
        << '_' << MO.getIndex();
      break;


    default:
      llvm_unreachable("<unknown operand type>");
  }

  if (closeP) O << ")";
}

void FgpuAsmPrinter::PrintDebugValueComment(const MachineInstr *MI, raw_ostream &OS) {
  // TODO: implement
  OS << "PrintDebugValueComment()";
}

// Force static initialization.
extern "C" void LLVMInitializeFgpuAsmPrinter() {
  RegisterAsmPrinter<FgpuAsmPrinter> X(TheFgpuTarget);
  // RegisterAsmPrinter<FgpuAsmPrinter> Y(TheFgpuelTarget);
}
