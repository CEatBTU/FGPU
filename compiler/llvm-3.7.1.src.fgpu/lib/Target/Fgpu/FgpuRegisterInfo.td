//===-- FgpuRegisterInfo.td - Fgpu Register defs -----------*- tablegen -*-===//
//
// The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//===----------------------------------------------------------------------===//
// Declarations that describe the Fgpu register file
//===----------------------------------------------------------------------===//

// We have 32 registers each.
class FgpuReg<string n> : Register<n> {
  field bits<5> Num;
  let Namespace = "Fgpu";
}
// General Purpose Registers
class FgpuGPRReg<bits<16> num, string n> : FgpuReg<n> {
  let Num = num{4-0};
  let HWEncoding = num;
}
//===----------------------------------------------------------------------===//
//@Registers
//===----------------------------------------------------------------------===//
// The register string, such as "9" or "gp" will show on "llvm-objdump -d"
//@ All registers definition
let Namespace = "Fgpu" in {
  //@ General Purpose Registers
  def R0   : FgpuGPRReg<0,  "0">,    DwarfRegNum<[0]>;
  def R1   : FgpuGPRReg<1,  "1">,    DwarfRegNum<[1]>;
  def R2   : FgpuGPRReg<2,  "2">,    DwarfRegNum<[2]>;
  def R3   : FgpuGPRReg<3,  "3">,    DwarfRegNum<[3]>;
  def R4   : FgpuGPRReg<4,  "4">,    DwarfRegNum<[4]>;
  def R5   : FgpuGPRReg<5,  "5">,    DwarfRegNum<[5]>;
  def R6   : FgpuGPRReg<6,  "6">,    DwarfRegNum<[6]>;
  def R7   : FgpuGPRReg<7,  "7">,    DwarfRegNum<[7]>;
  def R8   : FgpuGPRReg<8,  "8">,    DwarfRegNum<[8]>;
  def R9   : FgpuGPRReg<9,  "9">,    DwarfRegNum<[9]>;
  def R10  : FgpuGPRReg<10, "10">,   DwarfRegNum<[10]>;
  def R11  : FgpuGPRReg<11, "11">,   DwarfRegNum<[11]>;
  def R12  : FgpuGPRReg<12, "12">,   DwarfRegNum<[12]>;
  def R13  : FgpuGPRReg<13, "13">,   DwarfRegNum<[13]>;
  def R14  : FgpuGPRReg<14, "14">,   DwarfRegNum<[14]>;
  def R15  : FgpuGPRReg<15, "15">,   DwarfRegNum<[15]>;
  def R16  : FgpuGPRReg<16, "16">,   DwarfRegNum<[16]>;
  def R17  : FgpuGPRReg<17, "17">,   DwarfRegNum<[17]>;
  def R18  : FgpuGPRReg<18, "18">,   DwarfRegNum<[18]>;
  def R19  : FgpuGPRReg<19, "19">,   DwarfRegNum<[19]>;
  def R20  : FgpuGPRReg<20, "20">,   DwarfRegNum<[20]>;
  def R21  : FgpuGPRReg<21, "21">,   DwarfRegNum<[21]>;
  def R22  : FgpuGPRReg<22, "22">,   DwarfRegNum<[22]>;
  def R23  : FgpuGPRReg<23, "23">,   DwarfRegNum<[23]>;
  def R24  : FgpuGPRReg<24, "24">,   DwarfRegNum<[24]>;
  def R25  : FgpuGPRReg<25, "25">,   DwarfRegNum<[25]>;
  def R26  : FgpuGPRReg<26, "26">,   DwarfRegNum<[26]>;
  def R27  : FgpuGPRReg<27, "27">,   DwarfRegNum<[27]>;
  def R28  : FgpuGPRReg<28, "28">,   DwarfRegNum<[28]>;
  def R29  : FgpuGPRReg<29, "29">,   DwarfRegNum<[29]>;
  def LR  : FgpuGPRReg<30, "lr">,   DwarfRegNum<[30]>;
  def SP  : FgpuGPRReg<31, "sp">,   DwarfRegNum<[31]>;

}

//===----------------------------------------------------------------------===//
//@Register Classes
//===----------------------------------------------------------------------===//

  def ALURegs : RegisterClass<"Fgpu", [i32], 32, (add R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19, R20, R21, R22, R23, R24, R25, R26, R27, R28, R29, LR, SP)>;

  //control registers
  def GPROut : RegisterClass<"Fgpu", [i32, f32], 32, (add ALURegs)>;
  def FloatRegs : RegisterClass<"Fgpu", [f32], 32, (add R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19, R20, R21, R22, R23, R24, R25, R26, R27, R28, R29)>;
