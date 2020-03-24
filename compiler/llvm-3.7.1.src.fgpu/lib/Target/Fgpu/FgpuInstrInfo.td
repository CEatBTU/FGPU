//===- FgpuInstrInfo.td - Target Description for Fgpu Target -*- tablegen -*-=//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the Fgpu implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//
include "FgpuRegisterInfo.td"
// include "Fgpu.td"

// def FeatureHardFloat :  Predicate<"!Subtarget->useSoftFloat()">;

def HasDSP : AssemblerPredicate<"FeatureHardFloat">;
//===----------------------------------------------------------------------===//
// Fgpu profiles and nodes
//===----------------------------------------------------------------------===//

// Node immediate fits as 14-bit sign extended on target immediate.
// e.g. addi
def imm_eq_31  : PatLeaf<(imm), [{ return (N->getZExtValue() == 31) ; }]>;
def imm_eq_4   : PatLeaf<(imm), [{ return (N->getZExtValue() == 4) ; }]>;
def imm_eq_3   : PatLeaf<(imm), [{ return (N->getZExtValue() == 3) ; }]>;
def imm_eq_2   : PatLeaf<(imm), [{ return (N->getZExtValue() == 2) ; }]>;
def imm_eq_1   : PatLeaf<(imm), [{ return (N->getZExtValue() == 1) ; }]>;
def immSExt14  : PatLeaf<(imm), [{ return isInt<14>(N->getSExtValue()); }]>;
def immZExt14  : PatLeaf<(imm), [{ return isUInt<14>(N->getSExtValue()); }]>;
def imm0       : PatLeaf<(imm), [{ return (N->getZExtValue() == 0); }]>;
def uimm4       : PatLeaf<(imm), [{ return isUInt<4>(N->getZExtValue()); }]>;
def uuimm16      : PatLeaf<(imm), [{ return isUInt<16>(N->getZExtValue()); }]>;
def uimm5       : PatLeaf<(imm), [{ return isUInt<5>(N->getZExtValue()); }]>;
def simm5       : PatLeaf<(imm), [{ return isInt<5>(N->getSExtValue()); }]>;
// Return
def FgpuRET   : SDNode<"FgpuISD::RET", SDTNone, [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;
// Constant 1.0f
// def FloatConst1 : PatLeaf<(fpimm), [{
//     if (&(N->getValueAPF().getSemantics()) != &llvm::APFloat::IEEEsingle)
//       return false;
//     float f = (float)N->getValueAPF().convertToFloat();
//     return (f==1.0f);
// }]>;

//===----------------------------------------------------------------------===//
// Instruction format superclass
//===----------------------------------------------------------------------===//

include "FgpuInstrFormats.td"

//===----------------------------------------------------------------------===//
// Fgpu Operand, Complex Patterns and Transformations Definitions.
//===----------------------------------------------------------------------===//
// Instruction operand types

// BEQ, BNE
def brtarget14    : Operand<OtherVT> {
let EncoderMethod = "getBranch14TargetOpValue";
 let OperandType = "OPERAND_PCREL";
 let DecoderMethod = "DecodeSimm14";
}

def simm14      : Operand<i32> {
  let DecoderMethod= "DecodeSimm14";
}

def calltarget  : Operand<iPTR> {
  let EncoderMethod = "getJumpTargetOpValue";
 let DecoderMethod = "DecodeSimm14";
}

def uimm14      : Operand<i32> {
  let DecoderMethod= "DecodeUimm14";
}

// Unsigned Operand
def uimm16      : Operand<i32> {
  let PrintMethod = "printUnsignedShortImm";
  let DecoderMethod= "DecodeUimm16";
}

def imm32      : Operand<i32> {
  let PrintMethod = "printUnsignedImm";
}

def frameAddr: 
  ComplexPattern<iPTR, 2, "selectFrameAddr", [frameindex], [SDNPWantParent]>;

def frameAddr_LEA: 
  ComplexPattern<iPTR, 2, "selectFrameAddr_LEA", [frameindex], [SDNPWantParent]>;

def FgpuMemAsmOperand : AsmOperandClass {
  let Name = "Mem";
}

// Address operand
def mem : Operand<i32> {
  let PrintMethod = "printMemOperand";
  let MIOperandInfo = (ops ALURegs, immZExt14);
  let EncoderMethod = "getMemEncoding";
  let ParserMatchClass = FgpuMemAsmOperand;
  let DecoderMethod = "DecodeMem";
}


//===----------------------------------------------------------------------===//
// Pattern fragment for load/store
//===----------------------------------------------------------------------===//

class AlignedLoad<PatFrag Node> :
  PatFrag<(ops node:$ptr), (Node node:$ptr), [{
  LoadSDNode *LD = cast<LoadSDNode>(N);
  return LD->getMemoryVT().getSizeInBits()/8 <= LD->getAlignment();
}]>;


class AlignedStore<PatFrag Node> :
  PatFrag<(ops node:$val, node:$ptr), (Node node:$val, node:$ptr), [{
  StoreSDNode *SD = cast<StoreSDNode>(N);
  return SD->getMemoryVT().getSizeInBits()/8 <= SD->getAlignment();
}]>;

def load_a          : AlignedLoad<load>;
def loadi16_a       : AlignedLoad<extloadi16>;
def store_a         : AlignedStore<store>;

//===----------------------------------------------------------------------===//
// Instructions specific format
//===----------------------------------------------------------------------===//

class CondR<bits<8> op, string instr_asm, PatFrag cond_op, RegisterClass RC, bit isComm = 0>:
  FRRR<op, (outs ALURegs:$rd), (ins RC:$rs, RC:$rt),
     !strconcat(instr_asm, "\t$rd, $rs, $rt"),
     [(set ALURegs:$rd, (cond_op RC:$rs, RC:$rt))],
     IIAlu> {
  let isCommutable = isComm;	// e.g. add rb rc =  add rc rb
}

class CondI<bits<8> op, string instr_asm, PatFrag cond_op, Operand Od, PatLeaf imm_type>:
  FRRI<op, (outs ALURegs:$rd), (ins ALURegs:$rs, Od:$imm14),
     !strconcat(instr_asm, "\t$rd, $rs, $imm14"),
     [(set ALURegs:$rd, (cond_op ALURegs:$rs, imm_type:$imm14))],
     IIAlu>;
// Arithmetic and logical instructions with 3 register operands.
class ArithLogicR<bits<8> op, string instr_asm, SDNode OpNode,
                  InstrItinClass itin, RegisterClass RC, bit isComm = 0>:
  FRRR<op, (outs RC:$rd), (ins RC:$rs, RC:$rt),
     !strconcat(instr_asm, "\t$rd, $rs, $rt"),
     [(set RC:$rd, (OpNode RC:$rs, RC:$rt))], itin> {
  let isCommutable = isComm;	// e.g. add rb rc =  add rc rb
  let isReMaterializable = 1;
}
class LogicNOR<bits<8> op, string instr_asm,
                InstrItinClass itin, RegisterClass RC, bit isComm = 0>:
  FRRR<op, (outs RC:$rd), (ins RC:$rs, RC:$rt),
         !strconcat(instr_asm, "\t$rd, $rs, $rt"),
         [(set RC:$rd, (not (or RC:$rs, RC:$rt)))], itin> {
  let isCommutable = 1;
}
class ArithOneARGTwoClasses<bits<8> op, string instr_asm, SDNode OpNode,
                  InstrItinClass itin, RegisterClass RCin, RegisterClass RCout, bit isComm = 0>:
  FRRR<op, (outs RCout:$rd), (ins RCin:$rs),
     !strconcat(instr_asm, "\t$rd, $rs"),
     [(set RCout:$rd, (OpNode RCin:$rs))], itin> {
  let isCommutable = isComm;	// e.g. add rb rc =  add rc rb
  let isReMaterializable = 1;
}
// class FloatRSQRT<bits<8> op, string instr_asm,
//                   InstrItinClass itin, RegisterClass RC>:
//   FRRR<op, (outs RC:$rd), (ins RC:$rs),
//      !strconcat(instr_asm, "\t$rd, $rs"),
//      [(set RC:$rd, (fdiv FloatConst1, (fsqrt RC:$rs))], itin> {
//   let isCommutable = 0;	// e.g. add rb rc =  add rc rb
//   let isReMaterializable = 1;
// }
class ArithOneARG<bits<8> op, string instr_asm, SDNode OpNode,
                  InstrItinClass itin, RegisterClass RC, bit isComm = 0>:
  FRRR<op, (outs RC:$rd), (ins RC:$rs),
     !strconcat(instr_asm, "\t$rd, $rs"),
     [(set RC:$rd, (OpNode RC:$rs))], itin> {
  let isCommutable = isComm;	// e.g. add rb rc =  add rc rb
  let isReMaterializable = 1;
}
class ArithLogicI<bits<8> op, string instr_asm, SDNode OpNode,
                  Operand Od, PatLeaf imm_type> :
  FRRI<op, (outs ALURegs:$rd), (ins ALURegs:$rs, Od:$imm14),
     !strconcat(instr_asm, "\t$rd, $rs, $imm14"),
     [(set ALURegs:$rd, (OpNode ALURegs:$rs, imm_type:$imm14))], IIAlu> {
  let isReMaterializable = 1;
}
class Macc<bits<8> op, string instr_asm, InstrItinClass itin, RegisterClass RC, bit isComm = 0>:
  FRRR<op, (outs RC:$rd_out), (ins RC:$rd, RC:$rs, RC:$rt),
     !strconcat(instr_asm, "\t$rd, $rs, $rt"),
     [(set RC:$rd_out, (add RC:$rd, (mul RC:$rs, RC:$rt)))], itin> {
  let isCommutable = isComm;	
  let isReMaterializable = 1;
  let Constraints = "$rd_out = $rd";
}


//Runtime Memory instructions
class RTMInstr<bits<8> op, string instr_asm, SDNode OpNode, Operand Imm, PatLeaf imm_type>:
  FRI_RTM<op, (outs ALURegs:$rd), (ins Imm:$uimm4),
     !strconcat(instr_asm, "\t$rd, $uimm4"),
     [(set ALURegs:$rd, (OpNode imm_type:$uimm4))], IIAlu> {
  let isReMaterializable = 1;
}

class LoadUpper<bits<8> op, string instr_asm, SDNode OpNode, RegisterClass RC, Operand Imm>:
  FRI<op, (outs RC:$rd), (ins Imm:$imm16),
     !strconcat(instr_asm, "\t$rd, $imm16"), 
     [(set ALURegs:$rd, (OpNode uuimm16:$imm16))], IIAlu> {
  let isReMaterializable = 1;
  let AddedComplexity = 20;
}

class Control<bits<8> op, string instr_asm>:
  FCTRL<op, (outs), (ins),
     instr_asm, [], IIBranch> {
  let isTerminator=1;
  let isBarrier=1;
}
def mem_ea : Operand<iPTR> {
  let PrintMethod = "printMemOperandEA";
  let MIOperandInfo = (ops ALURegs, immZExt14);
  let EncoderMethod = "getMemEncoding";
}
class EffectiveAddress<string instr_asm, RegisterClass RC, Operand Mem> :
  FRRI_Stack<0x11, (outs RC:$rd), (ins Mem:$addr),
  instr_asm, [(set RC:$rd, frameAddr:$addr)], IIAlu>;

def LEA_ADDiu : EffectiveAddress<"addi\t$rd, $addr", ALURegs, mem_ea> {
let isCodeGenOnly = 1;
}

class Load_Frame<bits<8> op, string instr_asm, PatFrag OpNode, RegisterClass RC>
            : FRRI_Stack<op, (outs RC:$rd), (ins mem:$addr),
            !strconcat(instr_asm, "\t$rd, $addr"),
            [(set RC:$rd,(OpNode frameAddr:$addr))], IILoad>{
  let isPseudo = 0;
  let mayLoad = 1;
}
class Load_Byte<bits<8> op, string instr_asm, PatFrag OpNode, RegisterClass RC>
            : FRRR<op, (outs RC:$rd), (ins RC:$rs, RC:$rt),
            !strconcat(instr_asm, "\t$rd, $rt[$rs]"),
            [(set RC:$rd,(OpNode (add RC:$rt,  RC:$rs)))], IILoad>{
  let isPseudo = 0;
  let mayLoad = 1;
}
class Load_Half<bits<8> op, string instr_asm, PatFrag OpNode, RegisterClass RC>
            : FRRR<op, (outs RC:$rd), (ins RC:$rs, RC:$rt),
            !strconcat(instr_asm, "\t$rd, $rt[$rs]"),
            [(set RC:$rd, (OpNode (add RC:$rt, (shl RC:$rs, imm_eq_1))))], IILoad>{
  let isPseudo = 0;
  let mayLoad = 1;
}
class Load_Word<bits<8> op, string instr_asm, PatFrag OpNode, RegisterClass RC>
            : FRRR<op, (outs RC:$rd), (ins ALURegs:$rs, ALURegs:$rt),
            !strconcat(instr_asm, "\t$rd, $rt[$rs]"),
            [(set RC:$rd, (OpNode (add ALURegs:$rt, (shl ALURegs:$rs, imm_eq_2))))], IILoad>{
  let isPseudo = 0;
  let mayLoad = 1;
}

class Store_Frame<bits<8> op, string instr_asm, PatFrag OpNode, RegisterClass RC>
            : FRRI_Stack<op, (outs), (ins RC:$rd, mem:$addr),
            !strconcat(instr_asm, "\t$rd, $addr"),
            [(OpNode RC:$rd, frameAddr:$addr)], IIStore>{
  let isPseudo = 0;
  let mayStore = 1;
}
class Store_Byte<bits<8> op, string instr_asm, PatFrag OpNode, RegisterClass RC>
            : FRRR<op, (outs), (ins RC:$rd, RC:$rs, RC:$rt),
            !strconcat(instr_asm, "\t$rd, $rt[$rs]"),
            [(OpNode RC:$rd, (add RC:$rt,  RC:$rs))], IIStore>{
  let isPseudo = 0;
  let mayStore = 1;
}
class Store_Half<bits<8> op, string instr_asm, PatFrag OpNode, RegisterClass RC>
            : FRRR<op, (outs), (ins RC:$rd, RC:$rs, RC:$rt),
            !strconcat(instr_asm, "\t$rd, $rt[$rs]"),
            [(OpNode RC:$rd, (add RC:$rt, (shl RC:$rs, imm_eq_1)))], IIStore>{
  let isPseudo = 0;
  let mayStore = 1;
}
class Store_Word<bits<8> op, string instr_asm, PatFrag OpNode, RegisterClass RC>
            : FRRR<op, (outs), (ins RC:$rd, ALURegs:$rs, ALURegs:$rt),
            !strconcat(instr_asm, "\t$rd, $rt[$rs]"),
            [(OpNode RC:$rd, (add ALURegs:$rt, (shl ALURegs:$rs, imm_eq_2)))], IIStore>{
  let isPseudo = 0;
  let mayStore = 1;
}

class Branch<bits<8> op, string instr_asm, PatFrag cond_op,
                  Operand Od, RegisterClass RC> :
  FRRI<op, (outs), (ins RC:$rd, RC:$rs, Od:$imm14),
     !strconcat(instr_asm, "\t$rd, $rs, $imm14"),
     [(brcond (i32 (cond_op RC:$rd, RC:$rs)), bb:$imm14)], IIBranch>{
  let isBranch = 1;
  let isTerminator = 1;
  let isBarrier = 1;
}

def SDT_FgpuJmpLink      : SDTypeProfile<0, 1, [SDTCisVT<0, iPTR>]>;
def FgpuJmpLink : SDNode<"FgpuISD::JmpLink",SDT_FgpuJmpLink,
                         [SDNPHasChain, SDNPOutGlue, SDNPOptInGlue,
                          SDNPVariadic]>;
class JmpLink<bits<8> op, string instr_asm>:
  FI<op, (outs), (ins calltarget:$imm14, variable_ops),
     !strconcat(instr_asm, "\t$imm14"),
      [(FgpuJmpLink imm:$imm14)], IIBranch>{
  let isCall=1;
}

//===----------------------------------------------------------------------===//
// Pseudo Instruction definition
//===----------------------------------------------------------------------===//
def SDTRTMInst    : SDTypeProfile<1, 1, [ SDTCisInt<1>]>;
def SDTAto        : SDTypeProfile<1, 2, [SDTCisSameAs<0,2>, SDTCisInt<0>, SDTCisPtrTy<1>
]>;
// def LI32_Pseudo   : SDNode<"FgpuISD::LI32"      , SDTRTMInst, []>;
def LUi_Pseudo    : SDNode<"FgpuISD::LUi"      , SDTRTMInst, []>;
def Li_Pseudo     : SDNode<"FgpuISD::Li"      , SDTRTMInst, []>;
def LP_Pseudo     : SDNode<"FgpuISD::LP"      , SDTRTMInst, [SDNPHasChain]>;
def LID_Pseudo    : SDNode<"FgpuISD::LID"    , SDTRTMInst, [SDNPHasChain]>;
def WGOFF_Pseudo  : SDNode<"FgpuISD::WGOFF"    , SDTRTMInst, [SDNPHasChain]>;
def WGID_Pseudo   : SDNode<"FgpuISD::WGID"    , SDTRTMInst, [SDNPHasChain]>;
def WGSIZE_Pseudo : SDNode<"FgpuISD::WGSIZE"    , SDTRTMInst, [SDNPHasChain]>;
def SIZE_Pseudo   : SDNode<"FgpuISD::SIZE"    , SDTRTMInst, [SDNPHasChain]>;
def AADD_Pseudo   : SDNode<"FgpuISD::AADD"  , SDTAto, [SDNPHasChain, SDNPMayStore, SDNPMayLoad, SDNPMemOperand]>;
def AMAX_Pseudo   : SDNode<"FgpuISD::AMAX"  , SDTAto, [SDNPHasChain, SDNPMayStore, SDNPMayLoad, SDNPMemOperand]>;

def SDT_FgpuCallSeqStart : SDCallSeqStart<[SDTCisVT<0, i32>]>;
def SDT_FgpuCallSeqEnd   : SDCallSeqEnd<[SDTCisVT<0, i32>, SDTCisVT<1, i32>]>;
def callseq_start : SDNode<"ISD::CALLSEQ_START", SDT_FgpuCallSeqStart,
                           [SDNPHasChain, SDNPOutGlue]>;
def callseq_end   : SDNode<"ISD::CALLSEQ_END", SDT_FgpuCallSeqEnd,
                           [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;
def ADJCALLSTACKDOWN : FgpuPseudo<(outs), (ins uimm14:$amt),
                                  "!ADJCALLSTACKDOWN $amt",
                                  [(callseq_start timm:$amt)]>;
def ADJCALLSTACKUP   : FgpuPseudo<(outs), (ins uimm14:$amt1, uimm14:$amt2),
                                  "!ADJCALLSTACKUP $amt1",
                                  [(callseq_end timm:$amt1, timm:$amt2)]>;
//===----------------------------------------------------------------------===//
// Fgpu Instructions
//===----------------------------------------------------------------------===//

def LW : Load_Word<0x74, "lw", load_a, ALURegs>;
def LH : Load_Half<0x72, "lh", load_a, ALURegs>;
def LB : Load_Byte<0x71, "lb", load_a, ALURegs>;
def LLWI : Load_Frame<0xD4, "llwi", load_a, ALURegs>;
// map load without index, i.e. lw rd, rt[0]
def : Pat<(load_a ALURegs:$in), (LW R0,ALURegs:$in )>;
def : Pat<( f32 (load_a ALURegs:$in)), (COPY_TO_REGCLASS (LW R0,ALURegs:$in), FloatRegs)>;
def : Pat<( f32 (load_a  (add ALURegs:$rt, (shl ALURegs:$rs, imm_eq_2)))), 
          (COPY_TO_REGCLASS (LW $rs,$rt), FloatRegs)>;
def : Pat<(f32 (bitconvert (i32 ALURegs:$Xn))), (COPY_TO_REGCLASS ALURegs:$Xn, FloatRegs)>;
def : Pat<(i32 (bitconvert (f32 FloatRegs:$Xn))), (COPY_TO_REGCLASS FloatRegs:$Xn, ALURegs)>;
// def : Pat<(f32 (bitconvert (i32 ALURegs:$Xn))),
//           (COPY_TO_REGCLASS ALURegs:$Xn, FloatRegs)>;
// def : Pat<(extloadi16 GPROut:$in), (i32 (LH R0,GPROut:$in))>;
// def : Pat<(load_a GPROut:$in), (LB R0,GPROut:$in)>;
// def : Pat<(i8 (sextload GPROut:$in)),(i8 (LW R0,GPROut:$in ))>;
// def : Pat<(i8 (zextload GPROut:$in)),(i8 (LW R0,GPROut:$in ))>;

def SW : Store_Word<0x7C, "sw", store_a, ALURegs>;
def SH : Store_Half<0x7A, "sh", truncstorei16, ALURegs>;
def SB : Store_Byte<0x79, "sb", truncstorei8, ALURegs>;
def LSWI : Store_Frame<0xDC, "lswi", store_a, ALURegs>;
// map store without index, i.e. sw rd, rt[0]
def : Pat<(store_a ALURegs:$rd, ALURegs:$addr), (SW ALURegs:$rd, R0, ALURegs:$addr)>;
def : Pat<(store_a (f32 FloatRegs:$rd), (add ALURegs:$rt, (shl ALURegs:$rs, imm_eq_2))),
          (SW ( i32 (COPY_TO_REGCLASS $rd, ALURegs)), $rs, $rt)>;
def : Pat<(store_a (f32 FloatRegs:$rd), ALURegs:$in), 
          (SW ( i32 (COPY_TO_REGCLASS $rd, ALURegs)), R0, $in)>;
def : Pat<(truncstorei16 ALURegs:$rd, ALURegs:$addr), (SH ALURegs:$rd, R0, ALURegs:$addr)>;
def : Pat<(truncstorei8 ALURegs:$rd, ALURegs:$addr), (SB ALURegs:$rd, R0, ALURegs:$addr)>;


/// Arithmetic Instructions (ALU Immediate)
def ADDi    : ArithLogicI<0x11, "addi", add, simm14, immSExt14>;
def ADD     : ArithLogicR<0x10, "add", add, IIAlu, ALURegs, 1>;

// let Predicates = [FeatureHardFloat] in {
def FADD    : ArithLogicR<0xC0, "fadd", fadd, IIAlu, FloatRegs, 1>;
def FMUL    : ArithLogicR<0xC1, "fmul", fmul, IIAlu, FloatRegs, 1>;
def FDIV    : ArithLogicR<0xC2, "fdiv", fdiv, IIAlu, FloatRegs, 0>;
def FSUB    : ArithLogicR<0xC8, "fsub", fsub, IIAlu, FloatRegs, 0>;
def FSQRT   : ArithOneARG<0xC4, "fsqrt", fsqrt, IIAlu, FloatRegs, 0>;
// def FRSQRT  : FloatRSQRT<0xC5, "frsqrt", IIAlu, FloatRegs, 0>;
def UITOFP  : ArithOneARG<0xC3, "uitofp", uint_to_fp, IIAlu, GPROut, 0>;





// def FP_TO_SINT : ArithLogicR<0xC4, "fp_to_sint", fp_to_sint, IIAlu, FloatRegs, 1>;
// def SINT_TO_FP : ArithLogicR<0xC5, "sint_to_fp", sint_to_fp, IIAlu, FloatRegs, 1>;
// def UINT_TO_FP : ArithLogicR<0xC6, "uint_to_fp", uint_to_fp, IIAlu, FloatRegs, 1>;
def SUB     : ArithLogicR<0x12, "sub", sub, IIAlu, ALURegs, 0>;
def MUL     : ArithLogicR<0x51, "mul", mul, IIAlu, ALURegs, 1>;
def MACC    : Macc<0x58, "macc", IIAlu, ALURegs, 0>;
def LUi     : LoadUpper<0x1D, "lui", LUi_Pseudo, ALURegs, uimm16>;
def Li      : LoadUpper<0x19, "li", Li_Pseudo, ALURegs, uimm16>;
def : Pat<(LUi_Pseudo (i32 tglobaladdr:$dst)),
          (LUi tglobaladdr:$dst)>;
def : Pat<(Li_Pseudo (i32 tglobaladdr:$dst)),
          (Li tglobaladdr:$dst)>;
def SLL     : ArithLogicR<0x20, "sll", shl, IIAlu, ALURegs, 0>;
def SLLi    : ArithLogicI<0x21, "slli", shl, uimm14, uimm5>;
def SRL     : ArithLogicR<0x28, "srl", srl, IIAlu, ALURegs, 0>;
def SRLi    : ArithLogicI<0x29, "srli", srl, uimm14, immZExt14>;
def SRA     : ArithLogicR<0x2C, "sra", sra, IIAlu, ALURegs, 0>;
def SRAi    : ArithLogicI<0x2D, "srai", sra, uimm14, uimm5>;
def AND     : ArithLogicR<0x30, "and", and, IIAlu, ALURegs, 1>;
def ANDi    : ArithLogicI<0x31, "andi", and, uimm14, immZExt14>;
def OR      : ArithLogicR<0x32, "or", or, IIAlu, ALURegs, 1>;
def ORi     : ArithLogicI<0x33, "ori", or, uimm14, immZExt14>;
def XOR     : ArithLogicR<0x34, "xor", xor, IIAlu, ALURegs, 1>;
def XORi    : ArithLogicI<0x35, "xori", xor, uimm14, immZExt14>;
def NOR     : LogicNOR<0x38, "nor", IIAlu, ALURegs, 1>;
def LID     : RTMInstr<0xA0, "lid", LID_Pseudo, imm32, uimm4>;
def WGOFF   : RTMInstr<0xA1, "wgoff", WGOFF_Pseudo, imm32, uimm4>;
def AADD    : ArithLogicR<0x81, "aadd", AADD_Pseudo, IIAlu, ALURegs, 1>;
def AMAX    : ArithLogicR<0x82, "amax", AMAX_Pseudo, IIAlu, ALURegs, 1>;
def SIZE    : RTMInstr<0xA2, "size", SIZE_Pseudo, imm32, uimm4>;
def WGID    : RTMInstr<0xA3, "wgid", WGID_Pseudo, imm32, uimm4>;
def WGSIZE  : RTMInstr<0xA4, "wgsize", WGSIZE_Pseudo, imm32, uimm4>;
def LP      : RTMInstr<0xA8, "lp", LP_Pseudo, imm32, uimm4>;

def : Pat<(i32 immSExt14:$in), (ADDi R0, imm:$in)>;
def Li32    : FgpuPseudo<(outs ALURegs:$rd), (ins imm32:$src), "Li32",
              [(set ALURegs:$rd, (imm:$src))]>;


let isReturn=1, isTerminator=1, isBarrier=1, hasCtrlDep=1 in
  def RetLR : FgpuPseudo<(outs), (ins), "", [(FgpuRET)]>;

def RET     : Control<0x92, "ret">;

def BEQ   : Branch<0x62, "beq", seteq, brtarget14, ALURegs>;
def BNE   : Branch<0x63, "bne", setne, brtarget14, ALURegs>;
def JSUB  : JmpLink<0x64, "jsub">;
def : Pat<(br bb:$addr), (BEQ R0, R0, bb:$addr)>;

def : Pat<(shl (load_a (add ALURegs:$base, (shl ALURegs:$offset, imm_eq_1))), (shl (xor (add ALURegs:$base, (shl ALURegs:$offset, imm_eq_1)), imm_eq_31), imm_eq_4)),
            (SLL (LH ALURegs:$offset, ALURegs:$base), (SLLi (XORi ALURegs:$offset, 31), 4))>;
// def : Pat<(shl (load_a (add ALURegs:$base, ALURegs:$offset)), (shl (xor (add ALURegs:$base, ALURegs:$offset), imm_eq_31), imm_eq_3)),
//             (SLL (LB ALURegs:$offset, ALURegs:$base), (SLLi (XORi ALURegs:$offset, 31), 3))>;

// def : Pat<(sra (load_a (add ALURegs:$base, ALURegs:$offset)),
//            (shl (add ALURegs:$base, ALURegs:$offset), imm_eq_3)),
//           (SRA (LB ALURegs:$offset, ALURegs:$base), (SLLi ALURegs:$offset, 3))>;
// def : Pat<(srl (load_a (add ALURegs:$base, ALURegs:$offset)),
//            (shl (add ALURegs:$base, ALURegs:$offset), imm_eq_3)),
//           (SRL (LB ALURegs:$offset, ALURegs:$base), (SLLi ALURegs:$offset, 3))>;

def FSLT    : CondR<0xC7, "fslt", setolt, FloatRegs, 0>;
def SLT     : CondR<0xB2, "slt", setlt, ALURegs, 0>;
def SLTi    : CondI<0xB3, "slti", setlt, simm14, immSExt14>;
def SLTu    : CondR<0xB6, "sltu", setult, ALURegs, 0>;
def SLTiu   : CondI<0xB7, "sltiu", setult, uimm14, immSExt14>;

// a == b
def : Pat<(seteq ALURegs:$lhs, ALURegs:$rhs), (SLTiu (XOR ALURegs:$lhs, ALURegs:$rhs), 1)>;
def : Pat<(setoeq FloatRegs:$lhs, FloatRegs:$rhs), (NOR (FSLT FloatRegs:$lhs, FloatRegs:$rhs), (FSLT FloatRegs:$rhs, FloatRegs:$lhs))>;
// a != b
def : Pat<(setne ALURegs:$lhs, ALURegs:$rhs), (SLTu R0, (XOR ALURegs:$lhs, ALURegs:$rhs))>;
def : Pat<(setone FloatRegs:$lhs, FloatRegs:$rhs), (OR (FSLT FloatRegs:$lhs, FloatRegs:$rhs), (FSLT FloatRegs:$rhs, FloatRegs:$lhs))>;
def : Pat<(setune FloatRegs:$lhs, FloatRegs:$rhs), (OR (FSLT FloatRegs:$lhs, FloatRegs:$rhs), (FSLT FloatRegs:$rhs, FloatRegs:$lhs))>;
// a <= b
def : Pat<(setle ALURegs:$lhs, ALURegs:$rhs), (XORi (SLT ALURegs:$rhs, ALURegs:$lhs), 1)>;
def : Pat<(setole FloatRegs:$lhs, FloatRegs:$rhs), (XORi (FSLT FloatRegs:$rhs, FloatRegs:$lhs), 1)>;
// a <= b is equal to (XORi (b < a), 1)
def : Pat<(setule ALURegs:$lhs, ALURegs:$rhs), (XORi (SLTu ALURegs:$rhs, ALURegs:$lhs), 1)>;
// a > b
def : Pat<(setgt ALURegs:$lhs, ALURegs:$rhs), (SLT ALURegs:$rhs, ALURegs:$lhs)>;
def : Pat<(setogt FloatRegs:$lhs, FloatRegs:$rhs), (FSLT FloatRegs:$rhs, FloatRegs:$lhs)>;
// a > b is equal to b < a is equal to setlt(b, a)
def : Pat<(setugt ALURegs:$lhs, ALURegs:$rhs), (SLTu ALURegs:$rhs, ALURegs:$lhs)>;
// a >= b
def : Pat<(setge ALURegs:$lhs, ALURegs:$rhs), (XORi (SLT ALURegs:$lhs, ALURegs:$rhs), 1)>;
def : Pat<(setoge FloatRegs:$lhs, FloatRegs:$rhs), (XORi (FSLT FloatRegs:$lhs, FloatRegs:$rhs), 1)>;
def : Pat<(setuge FloatRegs:$lhs, FloatRegs:$rhs), (XORi (FSLT FloatRegs:$lhs, FloatRegs:$rhs), 1)>;
def : Pat<(setge ALURegs:$lhs, immSExt14:$rhs), (XORi (SLTi ALURegs:$lhs, immSExt14:$rhs), 1)>;
// a >= b is equal to b <= a
def : Pat<(setuge ALURegs:$lhs, ALURegs:$rhs), (XORi (SLTu ALURegs:$lhs, ALURegs:$rhs), 1)>;
def : Pat<(setuge ALURegs:$lhs, immSExt14:$rhs), (XORi (SLTiu ALURegs:$lhs, immSExt14:$rhs), 1)>;

// rt is the condition
class CondMov<bits<8> op, string instr_asm> :
  FRRR<op, (outs GPROut:$rd), (ins GPROut:$rs, ALURegs:$rt, GPROut:$F),
     !strconcat(instr_asm, "\t$rd, $rs, $rt"), [], IIAlu> {
  let Constraints = "$F = $rd";
}

// Instantiation of instructions.
def MOVN : CondMov<0x40, "movn">;
def MOVZ : CondMov<0x48, "movz">;


// select patterns


multiclass COND_MOV<RegisterClass RC> {
  def : Pat<(select (setge ALURegs:$lhs, ALURegs:$rhs), RC:$T, RC:$F),
              (MOVZ $T, (SLT $lhs, $rhs), $F)>;
  def : Pat<(select (setuge ALURegs:$lhs, ALURegs:$rhs), RC:$T, RC:$F),
              (MOVZ $T, (SLTu $lhs, $rhs), $F)>;
  def : Pat<(select (setge ALURegs:$lhs, immSExt14:$rhs), RC:$T, RC:$F),
            (MOVZ $T, (SLTi $lhs, immSExt14:$rhs), $F)>;
  def : Pat<(select (setuge ALURegs:$lh, immSExt14:$rh), RC:$T, RC:$F),
              (MOVZ $T, (SLTiu $lh, immSExt14:$rh), $F)>;
  def : Pat<(select (setle ALURegs:$lhs, ALURegs:$rhs), RC:$T, RC:$F),
              (MOVZ $T, (SLT $rhs, $lhs), $F)>;
  def : Pat<(select (setule ALURegs:$lhs, ALURegs:$rhs), RC:$T, RC:$F),
              (MOVZ $T, (SLTu $rhs, $lhs), $F)>;
  def : Pat<(select (seteq ALURegs:$lhs, ALURegs:$rhs), RC:$T, RC:$F),
              (MOVZ $T, (XOR $lhs, $rhs), $F)>;
  def : Pat<(select (seteq ALURegs:$lhs, 0), RC:$T, RC:$F),
              (MOVZ $T, $lhs, $F)>;
  def : Pat<(select (setne ALURegs:$lhs, ALURegs:$rhs), RC:$T, RC:$F),
              (MOVN $T, (XOR $lhs, $rhs), $F)>;
  def : Pat<(select ALURegs:$cond, RC:$T, RC:$F),
              (MOVN $T, $cond, $F)>;
  def : Pat<(select (setne ALURegs:$lhs, 0), RC:$T, RC:$F),
              (MOVN $T, $lhs, $F)>;
}

defm COND_MOV_ALURegs: COND_MOV<ALURegs>;
defm COND_MOV_FloatRegs: COND_MOV<FloatRegs>;


// brcond patterns

// brcond for slt instruction

def : Pat<(brcond (i32 (setne ALURegs:$lhs, 0)), bb:$dst),
              (BNE ALURegs:$lhs, R0, bb:$dst)>;
def : Pat<(brcond (i32 (seteq ALURegs:$lhs, 0)), bb:$dst),
              (BEQ ALURegs:$lhs, R0, bb:$dst)>;

def : Pat<(brcond (i32 (seteq ALURegs:$lhs, ALURegs:$rhs)), bb:$dst),
              (BEQ ALURegs:$lhs, ALURegs:$rhs, bb:$dst)>;
def : Pat<(brcond (i32 (setueq ALURegs:$lhs, ALURegs:$rhs)), bb:$dst),
              (BEQ ALURegs:$lhs, ALURegs:$rhs, bb:$dst)>;
def : Pat<(brcond (i32 (setne ALURegs:$lhs, ALURegs:$rhs)), bb:$dst),
              (BNE ALURegs:$lhs, ALURegs:$rhs, bb:$dst)>;
def : Pat<(brcond (i32 (setune ALURegs:$lhs, ALURegs:$rhs)), bb:$dst),
              (BNE ALURegs:$lhs, ALURegs:$rhs, bb:$dst)>;
def : Pat<(brcond (i32 (setlt ALURegs:$lhs, ALURegs:$rhs)), bb:$dst),
              (BNE (SLT ALURegs:$lhs, ALURegs:$rhs), R0, bb:$dst)>;
def : Pat<(brcond (i32 (setult ALURegs:$lhs, ALURegs:$rhs)), bb:$dst),
              (BNE (SLTu ALURegs:$lhs, ALURegs:$rhs), R0, bb:$dst)>;
def : Pat<(brcond (i32 (setgt ALURegs:$lhs, ALURegs:$rhs)), bb:$dst),
              (BNE (SLT ALURegs:$rhs, ALURegs:$lhs), R0, bb:$dst)>;
def : Pat<(brcond (i32 (setugt ALURegs:$lhs, ALURegs:$rhs)), bb:$dst),
              (BNE (SLTu ALURegs:$rhs, ALURegs:$lhs), R0, bb:$dst)>;
def : Pat<(brcond (i32 (setle ALURegs:$lhs, ALURegs:$rhs)), bb:$dst),
              (BEQ (SLT ALURegs:$rhs, ALURegs:$lhs), R0, bb:$dst)>;
def : Pat<(brcond (i32 (setule ALURegs:$lhs, ALURegs:$rhs)), bb:$dst),
              (BEQ (SLTu ALURegs:$rhs, ALURegs:$lhs), R0, bb:$dst)>;
def : Pat<(brcond (i32 (setge ALURegs:$lhs, ALURegs:$rhs)), bb:$dst),
              (BEQ (SLT ALURegs:$lhs, ALURegs:$rhs), R0, bb:$dst)>;
def : Pat<(brcond (i32 (setuge ALURegs:$lhs, ALURegs:$rhs)), bb:$dst),
              (BEQ (SLTu ALURegs:$lhs, ALURegs:$rhs), R0, bb:$dst)>;

def : Pat<(brcond ALURegs:$cond, bb:$dst),
              (BNE ALURegs:$cond, R0, bb:$dst)>;


def : Pat<(FgpuJmpLink (i32 globaladdr:$dst)),
          (JSUB tglobaladdr:$dst)>;
def : Pat<(FgpuJmpLink (i32 tglobaladdr:$dst)),
          (JSUB tglobaladdr:$dst)>;
def : Pat<(FgpuJmpLink (i32 texternalsym:$dst)),
          (JSUB texternalsym:$dst)>;

def bitcast_fpimm_to_i32 : SDNodeXForm<fpimm, [{
return CurDAG->getTargetConstant(
  N->getValueAPF().bitcastToAPInt().getZExtValue(), SDLoc(N), MVT::i32);
}]>;



def : Pat<(f32 fpimm:$in),
  (COPY_TO_REGCLASS (Li32 (bitcast_fpimm_to_i32 f32:$in)), FloatRegs)>;



