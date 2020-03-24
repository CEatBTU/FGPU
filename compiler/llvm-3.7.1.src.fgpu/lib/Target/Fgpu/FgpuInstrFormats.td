//===-- FgpuInstrFormats.td - Fgpu Instruction Formats -----*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

// Format specifies the encoding used by the instruction.  This is part of the
// ad-hoc solution used to emit machine instruction encodings by our machine
// code emitter.
class Format<bits<4> val> {
  bits<4> Value = val;
}
//
def FrmPseudo   : Format<0>;
def FrmRRR      : Format<1>;
def FrmRRI      : Format<2>;
def FrmRI       : Format<3>;
def FrmCtrl     : Format<4>;
def FrmRRI_Stack: Format<5>;

// Generic Fgpu Format
class FgpuInst<dag outs, dag ins, string asmstr, list<dag> pattern,
               InstrItinClass itin, Format f>: Instruction
{
  field bits<32> Inst;
  Format Form = f;

  let Namespace = "Fgpu";

  let Size = 4;

  bits<8> Opcode = 0;

  // Top 8 bits are the 'opcode' field
  let Inst{31-24} = Opcode;

  let OutOperandList = outs;
  let InOperandList  = ins;

  let AsmString   = asmstr;
  let Pattern     = pattern;
  let Itinerary   = itin;

  // Attributes specific to Fgpu instructions...
  bits<4> FormBits = Form.Value;

  // TSFlags layout should be kept in sync with FgpuInstrInfo.h.

  let DecoderNamespace = "Fgpu";

  field bits<32> SoftFail = 0;
}

// Fgpu Pseudo Instructions Format
class FgpuPseudo<dag outs, dag ins, string asmstr, list<dag> pattern>:
      FgpuInst<outs, ins, asmstr, pattern, IIPseudo, FrmPseudo> {
  let isCodeGenOnly = 1;
  let isPseudo = 1;
}


// Pseudo-instructions for alternate assembly syntax (never used by codegen).
// These are aliases that require C++ handling to convert to the target
// instruction, while InstAliases can be handled directly by tblgen.
class FgpuAsmPseudoInst<dag outs, dag ins, string asmstr>:
  FgpuInst<outs, ins, asmstr, [], IIPseudo, FrmPseudo> {
  let isPseudo = 1;
  let Pattern = [];
}

//===----------------------------------------------------------------------===//
// Format RRR instruction class in Fgpu : <|opcode|rd|rs|imm|>
//===----------------------------------------------------------------------===//

class FCTRL<bits<8> op, dag outs, dag ins, string asmstr, list<dag> pattern,
         InstrItinClass itin>: FgpuInst<outs, ins, asmstr, pattern, itin, FrmCtrl>
{
  let Opcode = op;
}
class FRRI_Stack<bits<8> op, dag outs, dag ins, string asmstr, list<dag> pattern,
         InstrItinClass itin>: FgpuInst<outs, ins, asmstr, pattern, itin, FrmRRI_Stack>
{
  bits<5>  rd;
  bits<19>  addr;

  let Opcode = op;

  let Inst{23-5} = addr;
  let Inst{4-0}  = rd;
}

class FI<bits<8> op, dag outs, dag ins, string asmstr, list<dag> pattern,
         InstrItinClass itin>: FgpuInst<outs, ins, asmstr, pattern, itin, FrmRRI>
{
  bits<14>  imm14;

  let Opcode = op;

  let Inst{23-10} = imm14;
}
class FRRI<bits<8> op, dag outs, dag ins, string asmstr, list<dag> pattern,
         InstrItinClass itin>: FgpuInst<outs, ins, asmstr, pattern, itin, FrmRRI>
{
  bits<5>  rs;
  bits<5>  rd;
  bits<14>  imm14;

  let Opcode = op;

  let Inst{23-10} = imm14;
  let Inst{9-5} = rs;
  let Inst{4-0}  = rd;
}

//===----------------------------------------------------------------------===//
// Format RI instruction class in Fgpu : <|opcode|rd|rs|rt|>
//===----------------------------------------------------------------------===//


class FRRR<bits<8> op, dag outs, dag ins, string asmstr, list<dag> pattern,
         InstrItinClass itin>: FgpuInst<outs, ins, asmstr, pattern, itin, FrmRRR>
{
  bits<5>  rs;
  bits<5>  rt;
  bits<5>  rd;

  let Opcode = op;

  let Inst{14-10} = rt;
  let Inst{9-5} = rs;
  let Inst{4-0}  = rd;
}

class FRI_RTM<bits<8> op, dag outs, dag ins, string asmstr, list<dag> pattern,
         InstrItinClass itin>: FgpuInst<outs, ins, asmstr, pattern, itin, FrmRI>
{
  bits<5>  rd;
  bits<4> uimm4;

  let Opcode = op;

  let Inst{8-5}  = uimm4;
  let Inst{4-0}  = rd;
}
class FRI<bits<8> op, dag outs, dag ins, string asmstr, list<dag> pattern,
         InstrItinClass itin>: FgpuInst<outs, ins, asmstr, pattern, itin, FrmRI>
{
  bits<5>  rd;
  bits<16> imm16;

  let Opcode = op;

  let Inst{6-5}  = imm16{15-14};
  let Inst{23-10} = imm16{13-0};
  let Inst{4-0}  = rd;
}




