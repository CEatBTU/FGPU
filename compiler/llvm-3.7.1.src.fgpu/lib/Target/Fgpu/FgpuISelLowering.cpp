//===-- FgpuISelLowering.cpp - Fgpu DAG Lowering Implementation -----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the interfaces that Fgpu uses to lower LLVM code into a
// selection DAG.
//
//===----------------------------------------------------------------------===//
#include "FgpuISelLowering.h"

#include "MCTargetDesc/FgpuBaseInfo.h"
#include "FgpuMachineFunction.h"
#include "FgpuTargetMachine.h"
#include "FgpuTargetObjectFile.h"
#include "FgpuSubtarget.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "fgpu-lower"
static unsigned
addLiveIn(MachineFunction &MF, unsigned PReg, const TargetRegisterClass *RC)
{
  unsigned VReg = MF.getRegInfo().createVirtualRegister(RC);
  MF.getRegInfo().addLiveIn(PReg, VReg);
  return VReg;
}

SDValue 
FgpuTargetLowering::getTargetNode(BlockAddressSDNode *N, EVT Ty,
                                  SelectionDAG &DAG, unsigned Flag) const {
  DEBUG(dbgs() << "getTargetNode for BlockAddress Node entered\n");
  return DAG.getTargetBlockAddress(N->getBlockAddress(), Ty, 0, Flag);
}

const char *FgpuTargetLowering::getTargetNodeName(unsigned Opcode) const {
  switch (Opcode) {
  case FgpuISD::JmpLink:          return "FgpuISD::JmpLink";
  case FgpuISD::TailCall:         return "FgpuISD::TailCall";
  case FgpuISD::LUi:              return "FgpuISD::LUi";
  case FgpuISD::Li:               return "FgpuISD::Li";
  case FgpuISD::GPRel:            return "FgpuISD::GPRel";
  case FgpuISD::RET:              return "FgpuISD::RET";
  case FgpuISD::LP:               return "FgpuISD::LP";
  case FgpuISD::WGOFF:            return "FgpuISD::WGOFF";
  case FgpuISD::AADD:             return "FgpuISD::AADD";
  case FgpuISD::WGID:             return "FgpuISD::WGID";
  case FgpuISD::WGSIZE:           return "FgpuISD::WGSIZE";
  case FgpuISD::SIZE:             return "FgpuISD::SIZE";
  case FgpuISD::LID:              return "FgpuISD:LID";
  case FgpuISD::Wrapper:          return "FgpuISD::Wrapper";
  default:                        return NULL;
  }
}

FgpuTargetLowering::FgpuTargetLowering(const FgpuTargetMachine &TM,
                                       const FgpuSubtarget &STI)
    : TargetLowering(TM), Subtarget(STI), ABI(TM.getABI()) {

  // Set up the register classes
  addRegisterClass(MVT::i32, &Fgpu::ALURegsRegClass);

  // Fgpu does not have i1 type, so use i32 for
  // setcc operations results (slt, sgt, ...).
  setBooleanContents(ZeroOrOneBooleanContent);
  // setBooleanVectorContents(ZeroOrNegativeOneBooleanContent);

  setOperationAction(ISD::VSELECT, MVT::v2i32, Expand);
  setLoadExtAction(ISD::SEXTLOAD, MVT::i32, MVT::i16,  Custom);
  setLoadExtAction(ISD::ZEXTLOAD, MVT::i32, MVT::i16,  Custom);
  setLoadExtAction(ISD::EXTLOAD, MVT::i32, MVT::i16,  Custom);
  setLoadExtAction(ISD::SEXTLOAD, MVT::i32, MVT::i8,  Custom);
  setLoadExtAction(ISD::ZEXTLOAD, MVT::i32, MVT::i8,  Custom);
  setLoadExtAction(ISD::EXTLOAD, MVT::i32, MVT::i8,  Custom);
  setOperationAction(ISD::BR_JT,              MVT::Other, Custom);
  setOperationAction(ISD::GlobalAddress,      MVT::i32,   Custom);
  setOperationAction(ISD::BlockAddress,       MVT::i32,   Custom);
  setOperationAction(ISD::GlobalTLSAddress,   MVT::i32,   Custom);
  setOperationAction(ISD::JumpTable,          MVT::i32,   Custom);
  setOperationAction(ISD::ConstantPool,       MVT::i32,   Custom);
  // setOperationAction(ISD::STORE,          MVT::i32,   Custom);



  if(!Subtarget.hasHardFloatUnits()) {
    // to remove the hardware support for any instruction, 
    // move the corresponding Expand command to outside
    // this if block
    setOperationAction(ISD::UINT_TO_FP, MVT::f32,   Expand);
    setOperationAction(ISD::FADD, MVT::f32,   Expand);
    setOperationAction(ISD::FMUL, MVT::f32,   Expand);
    setOperationAction(ISD::FDIV, MVT::f32,   Expand);
    setOperationAction(ISD::FSUB, MVT::f32,   Expand);
  }
  // setOperationAction(ISD::FP_TO_SINT, MVT::f32,   Custom);

  // setOperationAction(ISD::SETCC, MVT::f32, Custom);
  
  setOperationAction(ISD::FP_TO_SINT, MVT::i32,   Custom);
  setOperationAction(ISD::FP_TO_UINT, MVT::i32,   Custom);
  setOperationAction(ISD::SINT_TO_FP, MVT::i32,   Custom);
  // setOperationAction(ISD::UINT_TO_FP, MVT::i32,   Custom);
  setOperationAction(ISD::ConstantFP, MVT::f32, Legal);
  // setOperationAction(ISD::SETOLT, MVT::f32, Legal);
  
  // setOperationAction(ISD::FrameIndex, MVT::i32, Custom);
  
  // setOperationAction(ISD::FSQRT, MVT::f32, Legal);
  // setOperationAction(ISD::SETCC, MVT::f32, Expand);

  // Used by legalize types to correctly generate the setcc result.
  // Without this, every float setcc comes with a AND/OR with the result,
  // we don't want this, since the fpcmp result goes to a flag register,
  // which is used implicitly by brcond and select operations.

  // setLibcallName(RTLIB::ADD_F32, "_addsf3");
  // setLibcallName(RTLIB::OGE_F32, "_gesf3");
  // setLibcallName(RTLIB::UO_F32,  "_unordsf2");
  AddPromotedToType(ISD::SETCC, MVT::i1, MVT::i32);
  // setOperationAction(ISD::SETCC, MVT::i32, Legal);
  setOperationAction(ISD::SETCC, MVT::v2i32, Expand);
  setOperationAction(ISD::SETCC, MVT::v2i1, Expand);
  setOperationAction(ISD::SETCC, MVT::v4i1, Expand);
  // Operations not directly supported by Fgpu.
//   setOperationAction(ISD::BR_JT,             MVT::Other, Expand);
  setOperationAction(ISD::BR_CC, MVT::i32, Expand);
  setOperationAction(ISD::BR_CC, MVT::f32, Expand);
  setOperationAction(ISD::SELECT_CC, MVT::i32, Expand);
  setOperationAction(ISD::SELECT_CC, MVT::f32, Expand);
  // setOperationAction(ISD::SELECT, MVT::f32, Expand);
  setOperationAction(ISD::SELECT_CC, MVT::Other, Expand);
  setOperationAction(ISD::SDIV,         MVT::i32, Expand);
  setOperationAction(ISD::UDIV,         MVT::i32, Expand);
  setOperationAction(ISD::SDIVREM,         MVT::i32, Expand);
  setOperationAction(ISD::UDIVREM,     MVT::i32, Expand);
  setOperationAction(ISD::MULHS,     MVT::i32, Expand);
  setOperationAction(ISD::MULHU,     MVT::i32, Expand);
  setOperationAction(ISD::SMUL_LOHI,     MVT::i32, Expand);
  setOperationAction(ISD::UMUL_LOHI,     MVT::i32, Expand);

  setOperationAction(ISD::FSIN   , MVT::f64, Expand);
  setOperationAction(ISD::FCOS   , MVT::f64, Expand);
  setOperationAction(ISD::FSINCOS, MVT::f64, Expand);
  setOperationAction(ISD::FSIN   , MVT::f32, Expand);
  setOperationAction(ISD::FCOS   , MVT::f32, Expand);
  setOperationAction(ISD::FSINCOS, MVT::f32, Expand);
  
  setOperationAction(ISD::CTLZ, MVT::i32, Expand);
  setOperationAction(ISD::CTTZ, MVT::i32, Expand);
  setOperationAction(ISD::CTPOP,             MVT::i32,   Expand);
  // setOperationAction(ISD::CTTZ,              MVT::i32,   Expand);
  // setOperationAction(ISD::CTTZ_ZERO_UNDEF,   MVT::i32,   Expand);
  // setOperationAction(ISD::CTLZ_ZERO_UNDEF,   MVT::i32,   Expand);
  // Fgpu doesn't have sext_inreg, replace them with shl/sra.
  setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i1 , Expand);
  setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i8 , Expand);
  setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i16 , Expand);
  setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i32 , Expand);
  // setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::Other , Expand);


  // setCondCodeAction(ISD::SETOEQ, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETOGT, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETOGE, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETOLT, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETOLE, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETONE, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETO, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETUO, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETUEQ, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETUGT, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETUGE, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETULT, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETULE, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETUNE, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETTRUE, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETFALSE2, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETFALSE, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETEQ, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETGT, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETGE, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETLT, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETLE, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETNE, MVT::f32, Expand);
  // setCondCodeAction(ISD::SETTRUE2, MVT::f32, Expand);



  //- Set .align 2
  // It will emit .align 2 later
  setMinFunctionAlignment(2);
  setStackPointerRegisterToSaveRestore(Fgpu::SP);
}

SDValue FgpuTargetLowering::PerformDAGCombine(SDNode *N, DAGCombinerInfo &DCI)
  const {
  unsigned Opc = N->getOpcode();
  DEBUG(dbgs() << "Soubhi: Perform DAG Combine entered" << "\n");

  switch (Opc) {
  default: break;
  case ISD::LOAD:
  case ISD::SHL:
    DEBUG(dbgs() << "Soubhi: it is a load" << "\n");
  }

  return SDValue();
}
const FgpuTargetLowering *FgpuTargetLowering::create(const FgpuTargetMachine &TM,
                                                     const FgpuSubtarget &STI) {
  return llvm::createFgpuSETargetLowering(TM, STI);
}

void FgpuTargetLowering::ReplaceNodeResults(SDNode *N,
                                       SmallVectorImpl<SDValue> &Results,
                                       SelectionDAG &DAG) const {
  DEBUG(dbgs() << "Soubhi: ReplaceNodeResults entered " << "\n");
  SDValue Res = LowerOperation(SDValue(N, 0), DAG);

  if(Res.getNode() != nullptr)
    for (unsigned I = 0, E = Res->getNumValues(); I != E; ++I)
      Results.push_back(Res.getValue(I));
}

SDValue FgpuTargetLowering::LowerOperation(SDValue Op, SelectionDAG &DAG) const
{
  DEBUG(dbgs() << "Soubhi: LowerOperation entered " << "\n");
  // DEBUG(dbgs() << "Soubhi: LowerOperantin entered " << Op.getOpcode() << "\n");
  switch (Op.getOpcode())
  {
    case ISD::ConstantPool:         return lowerConstantPool(Op, DAG);
    case ISD::GlobalAddress:        return lowerGlobalAddress(Op, DAG);
    case ISD::BlockAddress:   
    case ISD::GlobalTLSAddress: 
    case ISD::JumpTable:          
    case ISD::BR_JT:
      assert(0);
    case ISD::LOAD:                 return lowerLoad(Op, DAG);
    case ISD::STORE:                return lowerStore(Op, DAG);
    // case ISD::TargetGlobalAddress:  return lowerTargetGlobalAddress(Op, DAG);
    case ISD::UINT_TO_FP:           
    case ISD::SINT_TO_FP:           return lowerSINT_TO_FP(Op, DAG);
    case ISD::FP_TO_SINT:           return lowerFP_TO_SINT(Op, DAG);
    case ISD::SETCC:                return lowerSETCC(Op, DAG);
    // case ISD::FrameIndex:           return LowerFrameIndex(Op, DAG);
    // case ISD::SINT_TO_FP:
    // case ISD::UINT_TO_FP:           return lowerINT_TO_FP
  }
  return SDValue();
}


SDValue FgpuTargetLowering::lowerGlobalAddress(SDValue Op, SelectionDAG &DAG) const {
  //@lowerGlobalAddress }
  DEBUG(dbgs() << "soubhi: lowerGlobalAdress entered\n");
  // const Cpu0TargetObjectFile *TLOF =  static_cast<const Cpu0TargetObjectFile *>(
                                  // getTargetMachine().getObjFileLowering());
  EVT Ty = Op.getValueType();
  GlobalAddressSDNode *N = cast<GlobalAddressSDNode>(Op);
  // const GlobalValue *GV = N->getGlobal();
  SDLoc DL(N);
  SDValue Hi = DAG.getTargetGlobalAddress(N->getGlobal(), SDLoc(N), Ty, 0, FgpuII::MO_NO_FLAG);
  SDValue Lo = DAG.getTargetGlobalAddress(N->getGlobal(), SDLoc(N), Ty, 0, FgpuII::MO_NO_FLAG);
  // SDValue Hi = getTargetNode(N, Ty, DAG, FgpuII::MO_ABS_HI);
  // SDValue Lo = getTargetNode(N, Ty, DAG, FgpuII::MO_ABS_LO);
  return DAG.getNode(ISD::ADD, DL, Ty,
                      // DAG.getTargetGlobalAddress(N->getGlobal(), SDLoc(N), Ty, 0, FgpuII::MO_NO_FLAG));
                       DAG.getNode(FgpuISD::LUi, DL, Ty, Hi),
                       DAG.getNode(FgpuISD::Li, DL, Ty, Lo));
}

SDValue FgpuTargetLowering::lowerSETCC(SDValue Op, SelectionDAG &DAG) const {

  assert(!Op.getValueType().isVector());
  SDValue LHS = Op.getOperand(0);
  SDValue RHS = Op.getOperand(1);
  ISD::CondCode CC = cast<CondCodeSDNode>(Op.getOperand(2))->get();
  SDLoc dl(Op);

  assert(LHS.getValueType() == MVT::f32);
  softenSetCCOperands(DAG, MVT::f32, LHS, RHS, CC, dl);
  // assert(!RHS.getNode());
  // If softenSetCCOperands returned a scalar, use it.
  assert(LHS.getValueType() == Op.getValueType() &&
         "Unexpected setcc expansion!");
  return LHS;

}
SDValue FgpuTargetLowering::lowerFP_TO_SINT(SDValue Op,
                                               SelectionDAG &DAG) const {
  DEBUG(dbgs() << "soubhi: lowerFP_TO_INT entered!\n");
  assert(!Op.getOperand(0).getValueType().isVector());

  // f16 conversions are promoted to f32.
  assert (Op.getOperand(0).getValueType() == MVT::f32);
  assert (Op.getOpcode() == ISD::FP_TO_SINT || Op.getOpcode() == ISD::FP_TO_UINT);

  RTLIB::Libcall LC;
  if (Op.getOpcode() == ISD::FP_TO_SINT)
    LC = RTLIB::getFPTOSINT(Op.getOperand(0).getValueType(), Op.getValueType());
  else
    LC = RTLIB::getFPTOUINT(Op.getOperand(0).getValueType(), Op.getValueType());

  SmallVector<SDValue, 2> Ops(Op->op_begin(), Op->op_end());
  return makeLibCall(DAG, LC, Op.getValueType(), &Ops[0], Ops.size(), false,
                     SDLoc(Op)).first;
}
SDValue FgpuTargetLowering::lowerSINT_TO_FP(SDValue Op,
                                               SelectionDAG &DAG) const {
  DEBUG(dbgs() << "soubhi: lowerSINT_TO_FP entered!\n");
  assert(!Op.getOperand(0).getValueType().isVector());

  // f16 conversions are promoted to i32.
  assert (Op.getOperand(0).getValueType() == MVT::i32);

  // SoftenFloatResult(Op, 0);

  RTLIB::Libcall LC;

  if (Op.getOpcode() == ISD::SINT_TO_FP)
    LC = RTLIB::getSINTTOFP(Op.getOperand(0).getValueType(), Op.getValueType());
  else
    LC = RTLIB::getUINTTOFP(Op.getOperand(0).getValueType(), Op.getValueType());


  SmallVector<SDValue, 2> Ops(Op->op_begin(), Op->op_end());
  return makeLibCall(DAG, LC, Op.getValueType(), &Ops[0], Ops.size(), false,
                     SDLoc(Op)).first;
}

SDValue
FgpuTargetLowering::lowerConstantPool(SDValue Op, SelectionDAG &DAG) const {
  EVT ValTy = Op.getValueType();
  Op->dump();
  SDLoc dl(Op);
  ConstantPoolSDNode *CP = cast<ConstantPoolSDNode>(Op);
  SDValue Res;
  if (CP->isMachineConstantPoolEntry()){
    assert(0);
    Res = DAG.getTargetConstantPool(CP->getMachineCPVal(), ValTy,
                                    CP->getAlignment());
  }
  else{
    Res = DAG.getTargetConstantPool(CP->getConstVal(), ValTy,
                                    CP->getAlignment());
  }
  Res->dump();
  // return DAG.getConstant(Op.getValue(0), dl, MVT::i32);
  return DAG.getNode(Fgpu::Li, dl, ValTy, Res);
}

SDValue FgpuTargetLowering::lowerTargetGlobalAddress(SDValue Op,
                                               SelectionDAG &DAG) const {
  DEBUG(dbgs() << "soubhi: lowerTargetGlobalAddress entered\n");
  assert(0);
  SDLoc DL(Op);
  GlobalAddressSDNode *N = cast<GlobalAddressSDNode>(Op);
  const GlobalValue *GV = N->getGlobal();

  if (getTargetMachine().getRelocationModel() != Reloc::PIC_) {
    DEBUG(dbgs() << "getAddrNonPIC is entered\n");
    //@ %gp_rel relocation
    // if (TLOF->IsGlobalInSmallSection(GV, getTargetMachine())) {
    //   assert(0);
    // }

    //@ %hi/%lo relocation
    // return getAddrNonPIC(N, Ty, DAG);
  }

  if (GV->hasInternalLinkage() || (GV->hasLocalLinkage() && !isa<Function>(GV)))
  {
    assert(0);
    // return getAddrLocal(N, Ty, DAG);
  }

  //@large section
  // if (!TLOF->IsGlobalInSmallSection(GV, getTargetMachine())){
  //   assert(0);
  //   return getAddrGlobalLargeGOT(N, Ty, DAG, FgpuII::MO_GOT_HI16,
  //                                FgpuII::MO_GOT_LO16, DAG.getEntryNode(), 
  //                                MachinePointerInfo::getGOT());
  // }
  return Op;
  // return getAddrGlobal(N, Ty, DAG, FgpuII::MO_GOT16, DAG.getEntryNode(), 
  //                      MachinePointerInfo::getGOT());
}
// //===----------------------------------------------------------------------===//
// //  Misc Lower Operation implementation
// //===----------------------------------------------------------------------===//
//
SDValue FgpuTargetLowering::lowerStore(SDValue Op, SelectionDAG &DAG) const{
  StoreSDNode *N = cast<StoreSDNode>(Op);
  EVT MemVT = N->getMemoryVT();

  DEBUG(dbgs() << "Soubhi: getAlignment = " << N->getAlignment() << "\n");
  DEBUG(dbgs() << "Soubhi: getSizeInBits = " << MemVT.getSizeInBits() << "\n");
  
  SDValue Ch = N->getChain(), Ptr = N->getBasePtr();
  SDLoc dl(N);

  // SDValue Val = GetPromotedInteger(N->getValue());  // Get promoted value.
  SDValue ExtValue = DAG.getNode(ISD::ANY_EXTEND, dl, MVT::i32,
                                  N->getValue());

  // Truncate the value and store the result.
  return DAG.getTruncStore(Ch, dl, ExtValue, Ptr,
                           N->getMemoryVT(), N->getMemOperand());
  // return Op;
}

SDValue FgpuTargetLowering::lowerLoad(SDValue Op, SelectionDAG &DAG) const
{
  DEBUG(dbgs() << "Soubhi: lowerLoad entered " << "\n");
  LoadSDNode *LD = cast<LoadSDNode>(Op);
  EVT MemVT = LD->getMemoryVT();
  assert(MemVT == MVT::i8 || MemVT == MVT::i16);
  unsigned alignment = LD->getAlignment();
  DEBUG(dbgs() << "Soubhi: getAlignment = " << LD->getAlignment() << "\n");
  DEBUG(dbgs() << "Soubhi: getSizeInBits = " << MemVT.getSizeInBits() << "\n");
  SDLoc DL(LD);
  ISD::LoadExtType ExtType = LD->getExtensionType();
  SDValue Chain = LD->getChain();

  //search for vecor load v4i8
  DEBUG(dbgs() << "soubhi: LD->getNumOperands() = " << LD->getNumOperands() << "\n");
  assert(LD->getNumOperands() == 3 && "soubhi: a load has to have 3 operands");
  SDValue undef_node = LD->getOperand(2);
  assert(undef_node.getOpcode() == ISD::UNDEF);
  SDValue addr = LD->getBasePtr();
  unsigned offset;
  SDValue base;
  bool addr_may_be_vector_offset = false;
  // the load should be either load(vec_addr) or load(vec_add+constant)
  if(alignment % 4 != 0){
    if(addr.getOpcode() == ISD::ADD){
      if(addr.getOperand(0).getOpcode() == ISD::Constant){
        base = addr.getOperand(1);
        offset = cast<ConstantSDNode>(addr.getOperand(0))->getZExtValue();
        addr_may_be_vector_offset = true;
      }
      else if(addr.getOperand(1).getOpcode() == ISD::Constant){
        base = addr.getOperand(0);
        offset = cast<ConstantSDNode>(addr.getOperand(1))->getZExtValue();
        addr_may_be_vector_offset = true;
      }
    }
  }
  bool load_base_found = false;
  SDValue vec_base_addr;
  if(addr_may_be_vector_offset)
  {
    DEBUG(dbgs() << "addr is ptr+offset:\n");
    DEBUG(base->dump());
    DEBUG(dbgs() << "offste = " << offset << "\n");
    //search for load operations that are connected to the same undef (operand 2)
    SDNode *from = undef_node.getNode();
    for (SDNode::use_iterator UI = from->use_begin(), E = from->use_end(); UI != E; ++UI) {
      if(LoadSDNode *n = dyn_cast<LoadSDNode>(*UI)){
        //the load should be aligned at 4
        if(n->getAlignment() % 4 == 0){
          DEBUG(dbgs() << "load with alignment%4=0 is found\n");
          DEBUG(n->dump());
          SDValue n_addr = n->getBasePtr();
          if(n_addr == base){
            load_base_found = true;
            if(offset < 4)
              vec_base_addr = n_addr;
            else
            {
              vec_base_addr = DAG.getNode(ISD::ADD, DL, MVT::i32, n_addr,  DAG.getConstant(4*(offset/4), DL, MVT::i32));
              DEBUG(dbgs() << "offset is beyond 4; another address node is created\n");
            }
            break;
          }
        }
      }
    }
  }
  if(load_base_found)
  {
    DEBUG(dbgs() << "load_base found, vec_base_addr is " << "\n");
    DEBUG(vec_base_addr.dump());
  }
  SDValue LW_addr = load_base_found? vec_base_addr:LD->getBasePtr();

  SDValue LW = DAG.getLoad(MVT::i32, DL, Chain,
                            LW_addr,
                            // LD->getBasePtr(),
                            MachinePointerInfo(), 
                            LD->isVolatile(), 
                            LD->isNonTemporal(),
                            LD->isInvariant(), 
                            4, //Alignemnt
                            LD->getAAInfo(),
                            LD->getRanges());
  SDValue shift3, shift1;
  if(alignment%4 == 0)
  {
    DEBUG(dbgs() << "alignemnt is 4; max. of 2 shifts will be used\n");
    if(MemVT == MVT::i16){
      shift1 = DAG.getNode(ISD::SHL, DL, MVT::i32, LW, DAG.getConstant(16, DL, MVT::i32));
      switch(ExtType){
        default:
          assert(false);
        case ISD::SEXTLOAD:
          shift3 = DAG.getNode(ISD::SRA, DL, MVT::i32, shift1,  DAG.getConstant(16, DL, MVT::i32));
          break;
        case ISD::EXTLOAD:
        case ISD::ZEXTLOAD:
          shift3 = DAG.getNode(ISD::SRL, DL, MVT::i32, shift1,  DAG.getConstant(16, DL, MVT::i32));
          break;
      }
    }
    else if(MemVT == MVT::i8){
      switch(ExtType){
        default:
          assert(false);
        case ISD::SEXTLOAD:
          shift1 = DAG.getNode(ISD::SHL, DL, MVT::i32, LW, DAG.getConstant(24, DL, MVT::i32));
          shift3 = DAG.getNode(ISD::SRA, DL, MVT::i32, shift1,  DAG.getConstant(24, DL, MVT::i32));
          break;
        case ISD::EXTLOAD:
        case ISD::ZEXTLOAD:
          shift3 = DAG.getNode(ISD::AND, DL, MVT::i32, LW,  DAG.getConstant(255, DL, MVT::i32));
          break;
      }
    }
  }
  else if(load_base_found)
  {
    DEBUG(dbgs() << "load of vector element is detected\n");
    offset = offset%4;
    assert(offset != 0);
    if(MemVT == MVT::i16){
      assert(offset == 2);
      DEBUG(dbgs() << "type is i16 with offset=1; only 1 shift will be used\n");
      switch(ExtType){
        default:
          assert(false);
        case ISD::SEXTLOAD:
          shift3 = DAG.getNode(ISD::SRA, DL, MVT::i32, LW,  DAG.getConstant(16, DL, MVT::i32));
          break;
        case ISD::EXTLOAD:
        case ISD::ZEXTLOAD:
          shift3 = DAG.getNode(ISD::SRL, DL, MVT::i32, LW,  DAG.getConstant(16, DL, MVT::i32));
          break;
      }
    }
    else if(MemVT == MVT::i8){
      DEBUG(dbgs() << "type is i8 with offset=1; only 2 shifts will be used\n");
      shift1 = DAG.getNode(ISD::SHL, DL, MVT::i32, LW, DAG.getConstant(8*(3-offset), DL, MVT::i32));
      switch(ExtType){
        default:
          assert(false);
        case ISD::SEXTLOAD:
          shift3 = DAG.getNode(ISD::SRA, DL, MVT::i32, shift1,  DAG.getConstant(24, DL, MVT::i32));
          break;
        case ISD::EXTLOAD:
        case ISD::ZEXTLOAD:
          shift3 = DAG.getNode(ISD::SRL, DL, MVT::i32, shift1,  DAG.getConstant(24, DL, MVT::i32));
          break;
      }
    }
  }
  else
  {
    // xori r1, addr, 31      (30)
    // slli r1, r1, 3         
    // sll  r2, data, r1
    // srli/srai  r2, r2, 24  (16)
    SDValue xori ;
    if(MemVT == MVT::i16){
      xori = DAG.getNode(ISD::XOR, DL, MVT::i32, LD->getBasePtr(), DAG.getConstant(30, DL, MVT::i32));
    }
    else if(MemVT == MVT::i8){
      xori = DAG.getNode(ISD::XOR, DL, MVT::i32, LD->getBasePtr(), DAG.getConstant(31, DL, MVT::i32));
    }
    shift1 = DAG.getNode(ISD::SHL, DL, MVT::i32, xori, DAG.getConstant(3, DL, MVT::i32));
    SDValue shift2 = DAG.getNode(ISD::SHL, DL, MVT::i32, LW, shift1);;
    switch(ExtType){
      default:
        assert(false);
      case ISD::SEXTLOAD:
        DEBUG(dbgs() << "Soubhi: i16(i8) load, sign extended to i32" << "\n");
        if(MemVT == MVT::i16){
          shift3 = DAG.getNode(ISD::SRA, DL, MVT::i32, shift2,  DAG.getConstant(16, DL, MVT::i32));
        }
        else if(MemVT == MVT::i8){
          shift3 = DAG.getNode(ISD::SRA, DL, MVT::i32, shift2,  DAG.getConstant(24, DL, MVT::i32));
        }
        break;
      case ISD::EXTLOAD:
      case ISD::ZEXTLOAD:
        DEBUG(dbgs() << "Soubhi: i16(i8) load, zero extended to i32" << "\n");
        if(MemVT == MVT::i16){
          shift3 = DAG.getNode(ISD::SRL, DL, MVT::i32, shift2,  DAG.getConstant(16, DL, MVT::i32));
        }
        else if(MemVT == MVT::i8){
          shift3 = DAG.getNode(ISD::SRL, DL, MVT::i32, shift2,  DAG.getConstant(24, DL, MVT::i32));
        }
        break;
    }
  }

  SDValue Ops[] = {
    shift3,
    LD->getChain()
  };
  SDNode *tmp = cast<SDNode>(LW);
  // Legalized the chain result - switch anything that used the old chain to
  // use the new one.
  DAG.ReplaceAllUsesOfValueWith(SDValue(LD,1), SDValue(tmp, 1));
  return DAG.getMergeValues(Ops, DL);

}

//===----------------------------------------------------------------------===//
// TODO: Implement a generic logic using tblgen that can support this.
// Fgpu 32 ABI rules:
// ---
//===----------------------------------------------------------------------===//

static bool CC_Fgpu(unsigned ValNo, MVT ValVT, MVT LocVT,
                       CCValAssign::LocInfo LocInfo, ISD::ArgFlagsTy ArgFlags,
                       CCState &State) {
  static const MCPhysReg IntRegs[] = { Fgpu::R1, Fgpu::R2, Fgpu::R3, Fgpu::R4, Fgpu::R5, Fgpu::R6, Fgpu::R7, Fgpu::R8};
  DEBUG(dbgs() << "Soubhi: CC_Fgpu entered\n");

  // Do not process byval args here.
  assert(!ArgFlags.isByVal());
  
  if (LocVT == MVT::i8 || LocVT == MVT::i16) {
    LocVT = MVT::i32;
    if (ArgFlags.isSExt())
      LocInfo = CCValAssign::SExt;
    else if (ArgFlags.isZExt())
      LocInfo = CCValAssign::ZExt;
    else
      LocInfo = CCValAssign::AExt;
  }

  unsigned Reg;

  // f32 and f64 are allocated in R1, R2 when either of the following
  // is true: function is vararg, argument is 3rd or higher, there is previous
  // argument which is not f32 or f64.
  unsigned OrigAlign = ArgFlags.getOrigAlign();

  LocVT = MVT::i32;
  if (ValVT == MVT::i32 || (ValVT == MVT::f32)) {
    DEBUG(dbgs() << "Soubhi: CC_Fgpu : ValVT is i32 \n");
    Reg = State.AllocateReg(IntRegs);
    // If this is the first part of an i64 arg,
    // the allocated register must be R1.
  } else if (ValVT == MVT::f64) {
    assert(0);
  } else
    llvm_unreachable("Cannot handle this ValVT.");

  if (!Reg) {
    DEBUG(dbgs() << "Soubhi: CC_Fgpu : is not Reg \n");
    unsigned Offset = State.AllocateStack(ValVT.getSizeInBits() >> 3,
                                          OrigAlign);
    State.addLoc(CCValAssign::getMem(ValNo, ValVT, Offset, LocVT, LocInfo));
  } else {
    DEBUG(dbgs() << "Soubhi: CC_Fgpu : is Reg \n");
    State.addLoc(CCValAssign::getReg(ValNo, ValVT, Reg, LocVT, LocInfo));
  }

  return false;
}

#include "FgpuGenCallingConv.inc"

//===----------------------------------------------------------------------===//
//                  Call Calling Convention Implementation
//===----------------------------------------------------------------------===//
void FgpuTargetLowering::FgpuCC::
analyzeCallOperands(const SmallVectorImpl<ISD::OutputArg> &Args,
                    const SDNode *CallNode) {
  unsigned NumOpnds = Args.size();

  for (unsigned I = 0; I != NumOpnds; ++I) {
    MVT ArgVT = Args[I].VT;
    ISD::ArgFlagsTy ArgFlags = Args[I].Flags;

    if (ArgFlags.isByVal()) {
      assert(false);
    }

    bool R = CC_Fgpu(I, ArgVT, ArgVT, CCValAssign::Full, ArgFlags, this->CCInfo);

    if (R) {
#ifndef NDEBUG
      DEBUG(dbgs() << "Call operand #" << I << " has unhandled type "
             << EVT(ArgVT).getEVTString());
#endif
      llvm_unreachable(nullptr);
    }
  }
}
SDValue FgpuTargetLowering::LowerFrameIndex(SDValue Op,
                                              SelectionDAG &DAG) const {

  DEBUG(dbgs() << "LowerFrameIndex entered\n");
  SDLoc DL(Op);
  return
      DAG.getCopyFromReg(DAG.getEntryNode(), DL, Fgpu::SP,
                         getPointerTy(DAG.getDataLayout()));
}

SDValue
FgpuTargetLowering::passArgOnStack(SDValue StackPtr, unsigned Offset,
                                   SDValue Chain, SDValue Arg, SDLoc DL,
                                   bool IsTailCall, SelectionDAG &DAG) const {
  assert(!IsTailCall);
  if (!IsTailCall) {
    SDValue PtrOff =
        DAG.getNode(ISD::ADD, DL, getPointerTy(DAG.getDataLayout()), StackPtr,
                    DAG.getIntPtrConstant(Offset, DL));
    return DAG.getStore(Chain, DL, Arg, PtrOff, MachinePointerInfo(), false,
                        false, 0);
  }

  MachineFrameInfo *MFI = DAG.getMachineFunction().getFrameInfo();
  int FI = MFI->CreateFixedObject(Arg.getValueSizeInBits() / 8, Offset, false);
  SDValue FIN = DAG.getFrameIndex(FI, getPointerTy(DAG.getDataLayout()));
  return DAG.getStore(Chain, DL, Arg, FIN, MachinePointerInfo(),
                      /*isVolatile=*/ true, false, 0);
}
void FgpuTargetLowering::getOpndList(SmallVectorImpl<SDValue> &Ops,
            std::deque< std::pair<unsigned, SDValue> > &RegsToPass,
            bool IsPICCall, bool GlobalOrExternal, bool InternalLinkage,
            CallLoweringInfo &CLI, SDValue Callee, SDValue Chain) const {

  assert (!IsPICCall && GlobalOrExternal);
  Ops.push_back(Callee);

  // Build a sequence of copy-to-reg nodes chained together with token
  // chain and flag operands which copy the outgoing args into registers.
  // The InFlag in necessary since all emitted instructions must be
  // stuck together.
  SDValue InFlag;

  for (unsigned i = 0, e = RegsToPass.size(); i != e; ++i) {
    Chain = CLI.DAG.getCopyToReg(Chain, CLI.DL, RegsToPass[i].first,
                                 RegsToPass[i].second, InFlag);
    InFlag = Chain.getValue(1);
  }

  // Add argument registers to the end of the list so that they are
  // known live into the call.
  for (unsigned i = 0, e = RegsToPass.size(); i != e; ++i)
    Ops.push_back(CLI.DAG.getRegister(RegsToPass[i].first,
                                      RegsToPass[i].second.getValueType()));

  // Add a register mask operand representing the call-preserved registers.
  const TargetRegisterInfo *TRI = Subtarget.getRegisterInfo();
  const uint32_t *Mask = 
      TRI->getCallPreservedMask(CLI.DAG.getMachineFunction(), CLI.CallConv);
  assert(Mask && "Missing call preserved mask for calling convention");
  Ops.push_back(CLI.DAG.getRegisterMask(Mask));

  if (InFlag.getNode())
    Ops.push_back(InFlag);
}
//@LowerCall {
/// LowerCall - functions arguments are copied from virtual regs to
/// (physical regs)/(stack frame), CALLSEQ_START and CALLSEQ_END are emitted.
SDValue
FgpuTargetLowering::LowerCall(TargetLowering::CallLoweringInfo &CLI,
                              SmallVectorImpl<SDValue> &InVals) const {
  DEBUG(dbgs() << "Soubhi: LowerCall entered\n");
  // assert(false);
  SelectionDAG &DAG                     = CLI.DAG;
  SDLoc DL                              = CLI.DL;
  SmallVectorImpl<ISD::OutputArg> &Outs = CLI.Outs;
  SmallVectorImpl<SDValue> &OutVals     = CLI.OutVals;
  SmallVectorImpl<ISD::InputArg> &Ins   = CLI.Ins;
  SDValue Chain                         = CLI.Chain;
  SDValue Callee                        = CLI.Callee;
  bool &IsTailCall                      = CLI.IsTailCall;
  CallingConv::ID CallConv              = CLI.CallConv;
  bool IsVarArg                         = CLI.IsVarArg;
  assert(!IsVarArg);
  assert(!IsTailCall);
  assert(getTargetMachine().getRelocationModel() != Reloc::PIC_);
  bool IsPIC = getTargetMachine().getRelocationModel() == Reloc::PIC_;

  MachineFunction &MF = DAG.getMachineFunction();
  const TargetFrameLowering *TFL = MF.getSubtarget().getFrameLowering();


  // Analyze operands of the call, assigning locations to each operand.
  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(),
                 ArgLocs, *DAG.getContext());
  FgpuCC FgpuCCInfo(CallConv, CCInfo);

  FgpuCCInfo.analyzeCallOperands(Outs, Callee.getNode());

  // Get a count of how many bytes are to be pushed on the stack.
  unsigned NextStackOffset = CCInfo.getNextStackOffset();
  DEBUG(dbgs()<< "NextStackOffset = " << NextStackOffset << "\n");
  
  // Check if it's really possible to do a tail call.

  if (CLI.CS && CLI.CS->isMustTailCall())
    report_fatal_error("failed to perform tail call elimination on a call "
                       "site marked musttail");

  // Chain is the output chain of the last Load/Store or CopyToReg node.
  // ByValChain is the output chain of the last Memcpy node created for copying
  // byval arguments to the stack.
  unsigned StackAlignment = TFL->getStackAlignment();
  NextStackOffset = RoundUpToAlignment(NextStackOffset, StackAlignment);
  SDValue NextStackOffsetVal = DAG.getIntPtrConstant(NextStackOffset, DL, true);

  Chain = DAG.getCALLSEQ_START(Chain, NextStackOffsetVal, DL);

  SDValue StackPtr =
      DAG.getCopyFromReg(Chain, DL, Fgpu::SP,
                         getPointerTy(DAG.getDataLayout()));


  // With EABI is it possible to have 16 args on registers.
  std::deque< std::pair<unsigned, SDValue> > RegsToPass;
  SmallVector<SDValue, 16> MemOpChains;

  // Walk the register/memloc assignments, inserting copies/loads.
  for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i) {
    SDValue Arg = OutVals[i];
    CCValAssign &VA = ArgLocs[i];
    MVT LocVT = VA.getLocVT();
    // ISD::ArgFlagsTy Flags = Outs[i].Flags;

    DEBUG(dbgs() << "soubhi: Arg Nr. " << i << "\n");
    assert (!Outs[i].Flags.isByVal());
    // Promote the value if needed.
    switch (VA.getLocInfo()) {
    default: llvm_unreachable("Unknown loc info!");
    case CCValAssign::Full:
      break;
    case CCValAssign::SExt:
      Arg = DAG.getNode(ISD::SIGN_EXTEND, DL, LocVT, Arg);
      break;
    case CCValAssign::ZExt:
      Arg = DAG.getNode(ISD::ZERO_EXTEND, DL, LocVT, Arg);
      break;
    case CCValAssign::AExt:
      Arg = DAG.getNode(ISD::ANY_EXTEND, DL, LocVT, Arg);
      break;
    }
    
    // Arguments that can be passed on register must be kept at
    // RegsToPass vector
    if (VA.isRegLoc()) {
      RegsToPass.push_back(std::make_pair(VA.getLocReg(), Arg));
      continue;
    }

    // Register can't get to this point...
    assert(VA.isMemLoc());

    // emit ISD::STORE whichs stores the
    // parameter value to a stack Location
    MemOpChains.push_back(passArgOnStack(StackPtr, VA.getLocMemOffset(),
                                         Chain, Arg, DL, IsTailCall, DAG));
  }

  // Transform all store nodes into one single node because all store
  // nodes are independent of each other.
  if (!MemOpChains.empty())
    Chain = DAG.getNode(ISD::TokenFactor, DL, MVT::Other, MemOpChains);

  assert(!IsPIC); // IsPIC true if calls are translated to
  bool IsPICCall = IsPIC; // true if calls are translated to
  bool GlobalOrExternal = false, InternalLinkage = false;
  // EVT Ty = Callee.getValueType();
  if (GlobalAddressSDNode *G = dyn_cast<GlobalAddressSDNode>(Callee)) {
      DEBUG(dbgs() << "soubhi: GlobalAddressSDNode\n");
    if (IsPICCall) {
      const GlobalValue *Val = G->getGlobal();
      InternalLinkage = Val->hasInternalLinkage();
      DEBUG(dbgs() << "soubhi: IsPICCall\n");

      // if (InternalLinkage)
      //   Callee = getAddrLocal(G, Ty, DAG);
      // else
      //   Callee = getAddrGlobal(G, Ty, DAG, FgpuII::MO_GOT_CALL, Chain,
      //                          FuncInfo->callPtrInfo(Val));
    } else
      Callee = DAG.getTargetGlobalAddress(G->getGlobal(), DL,
                                          getPointerTy(DAG.getDataLayout()), 0,
                                          FgpuII::MO_NO_FLAG);
      // Callee = DAG.getGlobalAddress(G->getGlobal(), DL,
      //                                     getPointerTy(DAG.getDataLayout()), 0, false,
      //                                     FgpuII::MO_NO_FLAG);
    GlobalOrExternal = true;
  }
  else if (ExternalSymbolSDNode *S = dyn_cast<ExternalSymbolSDNode>(Callee)) {
    const char *Sym = S->getSymbol();

    DEBUG(dbgs() << "soubhi: ExternalSymbolSDNode\n");
    DEBUG(Callee.dump());
    if (!IsPIC) // static
      Callee = DAG.getTargetExternalSymbol(Sym,
                                           getPointerTy(DAG.getDataLayout()),
                                           FgpuII::MO_NO_FLAG);
    DEBUG(Callee.dump());
    // else // PIC
    //   Callee = getAddrGlobal(S, Ty, DAG, FgpuII::MO_GOT_CALL, Chain,
    //                          FuncInfo->callPtrInfo(Sym));

    GlobalOrExternal = true;
  }

  SmallVector<SDValue, 8> Ops(1, Chain);
  SDVTList NodeTys = DAG.getVTList(MVT::Other, MVT::Glue);

  getOpndList(Ops, RegsToPass, IsPICCall, GlobalOrExternal, InternalLinkage,
              CLI, Callee, Chain);

  Chain = DAG.getNode(FgpuISD::JmpLink, DL, NodeTys, Ops);
  SDValue InFlag = Chain.getValue(1);

  // Create the CALLSEQ_END node.
  Chain = DAG.getCALLSEQ_END(Chain, NextStackOffsetVal,
                             DAG.getIntPtrConstant(0, DL, true), InFlag, DL);
  InFlag = Chain.getValue(1);

  // Handle result values, copying them out of physregs into vregs that we
  // return.
  return LowerCallResult(Chain, InFlag, CallConv,
                         Ins, DL, DAG, InVals, CLI.Callee.getNode(), CLI.RetTy);
}
//@LowerCall }

/// LowerCallResult - Lower the result values of a call into the
/// appropriate copies out of appropriate physical registers.
SDValue
FgpuTargetLowering::LowerCallResult(SDValue Chain, SDValue InFlag,
                                    CallingConv::ID CallConv,
                                    const SmallVectorImpl<ISD::InputArg> &Ins,
                                    SDLoc DL, SelectionDAG &DAG,
                                    SmallVectorImpl<SDValue> &InVals,
                                    const SDNode *CallNode,
                                    const Type *RetTy) const {
  // Assign locations to each value returned by this call.
  DEBUG(dbgs() << "Soubhi: LowerCallResult entered\n");
  SmallVector<CCValAssign, 16> RVLocs;
  CCState CCInfo(CallConv, false, DAG.getMachineFunction(),
     RVLocs, *DAG.getContext());

  FgpuCC FgpuCCInfo(CallConv, CCInfo);

  FgpuCCInfo.analyzeCallResult(Ins, CallNode, RetTy);

  DEBUG(dbgs() << "soubhi: LowerCallResult: RVLocs.size() =  " <<  RVLocs.size() << "\n");
  
  // Copy all of the result registers out of their specified physreg.
  for (unsigned i = 0; i != RVLocs.size(); ++i) {
    DEBUG(dbgs() << "soubhi: LowerCallResult: loop index " <<  i << ": " << RVLocs[i].getValNo() << "\n");
    SDValue Val = DAG.getCopyFromReg(Chain, DL, RVLocs[i].getLocReg(),
                                     RVLocs[i].getLocVT(), InFlag);
    Chain = Val.getValue(1);
    InFlag = Val.getValue(2);

    assert(RVLocs[i].getValVT() == MVT::i32 || RVLocs[i].getValVT() == MVT::f32);
    assert(RVLocs[i].getLocVT() == MVT::i32 || RVLocs[i].getLocVT() == MVT::f32);
    if (RVLocs[i].getValVT() != RVLocs[i].getLocVT()){
      DEBUG(dbgs() << "Soubhi: \n");
      Val = DAG.getNode(ISD::BITCAST, DL, RVLocs[i].getValVT(), Val);
    }

    InVals.push_back(Val);
    DEBUG(dbgs() << "soubhi: LowerCallResult: end of loop " <<  i << ": " << RVLocs[i].getValNo() << "\n");
  }

  return Chain;
}

// //===----------------------------------------------------------------------===//
// //@            Formal Arguments Calling Convention Implementation
// //===----------------------------------------------------------------------===//
SDValue FgpuTargetLowering::LowerFormalArgumentsUsingCallStack(SDValue Chain, 
                                CallingConv::ID CallConv,
                                const SmallVectorImpl<ISD::InputArg> &Ins,
                                SDLoc DL, SelectionDAG &DAG,
                                SmallVectorImpl<SDValue> &InVals) const {
  DEBUG(dbgs() << "soubhi: Lowering formal arguments using Call Stack entered\n");
  DEBUG(dbgs() << "soubhi: IsSoftFloat = " << Subtarget.useSoftFloat() << " \n");
  MachineFunction &MF = DAG.getMachineFunction();
  MachineFrameInfo *MFI = MF.getFrameInfo();
  FgpuFunctionInfo *FgpuFI = MF.getInfo<FgpuFunctionInfo>();

  FgpuFI->setVarArgsFrameIndex(0);
  bool IsVarArg = 0;

  // Assign locations to all of the incoming arguments.
  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(),
                 ArgLocs, *DAG.getContext());
  FgpuCC FgpuCCInfo(CallConv, CCInfo);
  FgpuFI->setFormalArgInfo(CCInfo.getNextStackOffset());

  Function::const_arg_iterator FuncArg =
    DAG.getMachineFunction().getFunction()->arg_begin();

  DEBUG(dbgs() << "soubhi: ArgLocs.size()= " << ArgLocs.size() << "\n");
  FgpuCCInfo.analyzeFormalArguments(Ins, FuncArg);
  DEBUG(dbgs() << "soubhi: ArgLocs.size()= " << ArgLocs.size() << "\n");

  // Used with vargs to acumulate store chains.
  std::vector<SDValue> OutChains;

  unsigned CurArgIdx = 0;

  for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i) {
    CCValAssign &VA = ArgLocs[i];
    if (Ins[i].isOrigArg()) {
      DEBUG(dbgs()<< "Soubhi: is Original Argument!\n");
    }

    std::advance(FuncArg, Ins[i].OrigArgIndex - CurArgIdx);
    CurArgIdx = Ins[i].OrigArgIndex;
    DEBUG(dbgs() << "soubhi: Arg Nr. " << i << ", CurArgIdx= " << CurArgIdx << ", Ins[i].OrigArgIndex= " << Ins[i].OrigArgIndex << "\n");
    EVT ValVT = VA.getValVT();
    bool IsRegLoc = VA.isRegLoc();
    DEBUG(dbgs() << "soubhi: ArgLocs[" << i << "].isRegLoc= " << IsRegLoc << "\n");

    // Arguments stored on registers
    if (IsRegLoc) {
      MVT RegVT = VA.getLocVT();
      unsigned ArgReg = VA.getLocReg();
      const TargetRegisterClass *RC = getRegClassFor(RegVT);

      // Transform the arguments stored on
      // physical registers into virtual ones
      unsigned Reg = addLiveIn(DAG.getMachineFunction(), ArgReg, RC);
      SDValue ArgValue = DAG.getCopyFromReg(Chain, DL, Reg, RegVT);

      // If this is an 8 or 16-bit value, it has been passed promoted
      // to 32 bits.  Insert an assert[sz]ext to capture this, then
      // truncate to the right size.
      if (VA.getLocInfo() != CCValAssign::Full) {
        DEBUG(dbgs() << "soubhi: VA.getLocInfo() != CCValAssign::Full\n");
        unsigned Opcode = 0;
        if (VA.getLocInfo() == CCValAssign::SExt)
          Opcode = ISD::AssertSext;
        else if (VA.getLocInfo() == CCValAssign::ZExt)
          Opcode = ISD::AssertZext;
        if (Opcode)
          ArgValue = DAG.getNode(Opcode, DL, RegVT, ArgValue,
                                 DAG.getValueType(ValVT));
        ArgValue = DAG.getNode(ISD::TRUNCATE, DL, ValVT, ArgValue);
      }

      // Handle floating point arguments passed in integer registers.
      assert(RegVT == MVT::i32);
      DEBUG(dbgs()<< "soubhi: ValVT == MVT::i64 is " << (ValVT == MVT::i64) << "\n");
      if ((RegVT == MVT::i32 && ValVT == MVT::f32) ||
          (RegVT == MVT::i64 && ValVT == MVT::f64))
        ArgValue = DAG.getNode(ISD::BITCAST, DL, ValVT, ArgValue);
      else if ( RegVT == MVT::i32 && ValVT == MVT::i64) {
        assert(0);
        // unsigned Reg2 = addLiveIn(DAG.getMachineFunction(),
        //                           getNextIntArgReg(ArgReg), RC);
        // SDValue ArgValue2 = DAG.getCopyFromReg(Chain, DL, Reg2, RegVT);
        // if (!Subtarget.isLittle())
        //   std::swap(ArgValue, ArgValue2);
        // ArgValue = DAG.getNode(MipsISD::BuildPairF64, DL, MVT::f64,
        //                        ArgValue, ArgValue2);
      }
      InVals.push_back(ArgValue);
    } else { // VA.isRegLoc()

      // sanity check
      assert(VA.isMemLoc());

      // The stack pointer offset is relative to the caller stack frame.
      int FI = MFI->CreateFixedObject(ValVT.getSizeInBits()/8,
                                      VA.getLocMemOffset(), true);

      // Create load nodes to retrieve arguments from the stack
      SDValue FIN = DAG.getFrameIndex(FI, getPointerTy(DAG.getDataLayout()));
      SDValue Load = DAG.getLoad(ValVT, DL, Chain, FIN,
                                 MachinePointerInfo::getFixedStack(FI),
                                 false, false, false, 0);
      InVals.push_back(Load);
      OutChains.push_back(Load.getValue(1));
    }
  }

//@Ordinary struct type: 1 {
  for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i) {
    // The ABIs for returning structs by value requires that we copy
    // the sret argument into $v0 for the return. Save the argument into
    // a virtual register so that we can access it from the return points.
    if (Ins[i].Flags.isSRet()) {
      unsigned Reg = FgpuFI->getSRetReturnReg();
      if (!Reg) {
        Reg = MF.getRegInfo().createVirtualRegister(
            getRegClassFor(MVT::i32));
        FgpuFI->setSRetReturnReg(Reg);
      }
      SDValue Copy = DAG.getCopyToReg(DAG.getEntryNode(), DL, Reg, InVals[i]);
      Chain = DAG.getNode(ISD::TokenFactor, DL, MVT::Other, Copy, Chain);
      break;
    }
  }
//@Ordinary struct type: 1 }

  // All stores are grouped in one node to allow the matching between
  // the size of Ins and InVals. This only happens when on varg functions
  if (!OutChains.empty()) {
    OutChains.push_back(Chain);
    Chain = DAG.getNode(ISD::TokenFactor, DL, MVT::Other, OutChains);
  }

  return Chain;
}
SDValue FgpuTargetLowering::LowerFormalArgumentsUsingLP(SDValue Chain, 
                                CallingConv::ID CallConv,
                                const SmallVectorImpl<ISD::InputArg> &Ins,
                                SDLoc DL, SelectionDAG &DAG,
                                SmallVectorImpl<SDValue> &InVals) const {

  DEBUG(dbgs() << "soubhi: Lowering formal arguments using LP entered\n");
  DEBUG(dbgs() << "soubhi: IsSoftFloat = " << Subtarget.useSoftFloat() << " \n");
  MachineFunction &MF = DAG.getMachineFunction();
  DEBUG(dbgs() << MF.getName() << "\n");

  // Assign locations to all of the incoming arguments.
  SmallVector<CCValAssign, 16> ArgLocs;
  bool IsVarArg = false;
  CCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(),
                 ArgLocs, *DAG.getContext());
  FgpuCC FgpuCCInfo(CallConv, CCInfo);

  Function::const_arg_iterator FuncArg =
    DAG.getMachineFunction().getFunction()->arg_begin();

  DEBUG(dbgs() << "soubhi: ArgLocs.size()= " << ArgLocs.size() << "\n");
  FgpuCCInfo.analyzeFormalArguments(Ins, FuncArg);
  DEBUG(dbgs() << "soubhi: ArgLocs.size()= " << ArgLocs.size() << "\n");

  unsigned CurArgIdx = 0;
  std::vector<SDValue> OutChains;

  for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i) {
    CCValAssign &VA = ArgLocs[i];
    std::advance(FuncArg, Ins[i].OrigArgIndex - CurArgIdx);
    CurArgIdx = Ins[i].OrigArgIndex;
    DEBUG(dbgs() << "soubhi: Arg Nr. " << i << ", CurArgIdx= " << CurArgIdx << 
        ", Ins[i].OrigArgIndex= " << Ins[i].OrigArgIndex << "\n");
    EVT ValVT = VA.getValVT();
    bool IsRegLoc = VA.isRegLoc();
    DEBUG(dbgs() << "soubhi: ArgLocs[" << i << "].isRegLoc= " << IsRegLoc << "\n");
    assert (VA.getLocInfo() == CCValAssign::Full);


    MVT RegVT = VA.getLocVT();
    SDVTList VTs = DAG.getVTList(RegVT, MVT::Other);
    SDValue Ops[] = {Chain, DAG.getConstant(i, DL, MVT::i32) };
    SDValue ArgValue = DAG.getNode(FgpuISD::LP, DL, VTs, Ops);
    OutChains.push_back(ArgValue.getValue(1));
    ArgValue = DAG.getNode(ISD::BITCAST, DL, ValVT, ArgValue);
    InVals.push_back(ArgValue);
      
  }
  if (!OutChains.empty()) {
    OutChains.push_back(Chain);
    Chain = DAG.getNode(ISD::TokenFactor, DL, MVT::Other, OutChains);
  }

  return Chain;
}
//
//@LowerFormalArguments {
/// LowerFormalArguments - transform physical registers into virtual registers
/// and generate load operations for arguments places on the stack.
SDValue FgpuTargetLowering::LowerFormalArguments(SDValue Chain, 
                                CallingConv::ID CallConv, bool IsVarArg,
                                const SmallVectorImpl<ISD::InputArg> &Ins,
                                SDLoc DL, SelectionDAG &DAG,
                                SmallVectorImpl<SDValue> &InVals) const {

  DEBUG(dbgs() << "soubhi: LowerFormalArguments entered\n");
  MachineFunction &MF = DAG.getMachineFunction();
  DEBUG(dbgs() << MF.getName() << "\n");
  // FgpuFunctionInfo *MFI = MF.getInfo<FgpuFunctionInfo>();
  const Function *F = MF.getFunction();
  bool isKernel = isKernelFunction(*F);
  assert(!IsVarArg && "Fgpu does not accept functions with variable number of variables");
  if(isKernel) {
    Chain = LowerFormalArgumentsUsingLP(Chain, CallConv, Ins, DL, DAG, InVals);
  }
  else {
    Chain = LowerFormalArgumentsUsingCallStack(Chain, CallConv, Ins, DL, DAG, InVals);
  }
  return Chain;
}
// // @LowerFormalArguments }
//===----------------------------------------------------------------------===//
//@              Return Value Calling Convention Implementation
//===----------------------------------------------------------------------===//
SDValue FgpuTargetLowering::LowerReturn(SDValue Chain,
                                CallingConv::ID CallConv, bool IsVarArg,
                                const SmallVectorImpl<ISD::OutputArg> &Outs,
                                const SmallVectorImpl<SDValue> &OutVals,
                                SDLoc DL, SelectionDAG &DAG) const {
  DEBUG(dbgs() << "soubhi: LowerReturn enetered\n");

  MachineFunction &MF = DAG.getMachineFunction();
  DEBUG(dbgs() << MF.getName() << "\n");
  const Function *F = MF.getFunction();
  bool isKernel = isKernelFunction(*F);
  if(isKernel) {
    return DAG.getNode(FgpuISD::RET, DL, MVT::Other, Chain);
  }
  else {
    // CCValAssign - represent the assignment of
    // the return value to a location
    SmallVector<CCValAssign, 16> RVLocs;
    MachineFunction &MF = DAG.getMachineFunction();

    // CCState - Info about the registers and stack slot.
    CCState CCInfo(CallConv, IsVarArg, MF, RVLocs,
                   *DAG.getContext());
    FgpuCC FgpuCCInfo(CallConv, CCInfo);

    // Analyze return values.
    FgpuCCInfo.analyzeReturn(Outs, MF.getFunction()->getReturnType());

    SDValue Flag;
    SmallVector<SDValue, 4> RetOps(1, Chain);

    // Copy the result values into the output registers.
    for (unsigned i = 0; i != RVLocs.size(); ++i) {
      SDValue Val = OutVals[i];
      CCValAssign &VA = RVLocs[i];
      assert(VA.isRegLoc() && "Can only return in registers!");

      if (RVLocs[i].getValVT() != RVLocs[i].getLocVT())
        Val = DAG.getNode(ISD::BITCAST, DL, RVLocs[i].getLocVT(), Val);

      Chain = DAG.getCopyToReg(Chain, DL, VA.getLocReg(), Val, Flag);

      // Guarantee that all emitted copies are stuck together with flags.
      Flag = Chain.getValue(1);
      RetOps.push_back(DAG.getRegister(VA.getLocReg(), VA.getLocVT()));
    }

    assert(MF.getFunction()->hasStructRetAttr() == 0);

    RetOps[0] = Chain;  // Update chain.

    // Add the flag if we have it.
    if (Flag.getNode())
      RetOps.push_back(Flag);

    // Return on Fgpu is always a "ret $lr"
    return DAG.getNode(FgpuISD::RET, DL, MVT::Other, RetOps);

  }
}
//===----------------------------------------------------------------------===//
//                           Fgpu Inline Assembly Support
//===----------------------------------------------------------------------===//

/// getConstraintType - Given a constraint letter, return the type of
/// constraint it is for this target.
FgpuTargetLowering::ConstraintType 
FgpuTargetLowering::getConstraintType(StringRef Constraint) const
{
  // Fgpu specific constraints
  // GCC config/mips/constraints.md
  // 'c' : A register suitable for use in an indirect
  //       jump. This will always be $t9 for -mabicalls.
  DEBUG(dbgs() << "soubhi: getConstraintType entered\n");
  if (Constraint.size() == 1) {
    switch (Constraint[0]) {
      default : break;
      case 'c':
        return C_RegisterClass;
      case 'R':
        return C_Memory;
    }
  }
  return TargetLowering::getConstraintType(Constraint);
}

/// Examine constraint type and operand type and determine a weight value.
/// This object must already have been set up with the operand type
/// and the current alternative constraint selected.
TargetLowering::ConstraintWeight
FgpuTargetLowering::getSingleConstraintMatchWeight(
    AsmOperandInfo &info, const char *constraint) const {
  ConstraintWeight weight = CW_Invalid;
  Value *CallOperandVal = info.CallOperandVal;
    // If we don't have a value, we can't do a match,
    // but allow it at the lowest weight.
  DEBUG(dbgs() << "soubhi: getSingleConstraintMatchWeight entered\n");
  if (!CallOperandVal)
    return CW_Default;
  Type *type = CallOperandVal->getType();
  // Look at the constraint type.
  switch (*constraint) {
  default:
    weight = TargetLowering::getSingleConstraintMatchWeight(info, constraint);
    break;
  case 'c': // $t9 for indirect jumps
    if (type->isIntegerTy())
      weight = CW_SpecificReg;
    break;
  case 'I': // signed 16 bit immediate
  case 'J': // integer zero
  case 'K': // unsigned 16 bit immediate
  case 'L': // signed 32 bit immediate where lower 16 bits are 0
  case 'N': // immediate in the range of -65535 to -1 (inclusive)
  case 'O': // signed 15 bit immediate (+- 16383)
  case 'P': // immediate in the range of 65535 to 1 (inclusive)
    if (isa<ConstantInt>(CallOperandVal))
      weight = CW_Constant;
    break;
  case 'R':
    weight = CW_Memory;
    break;
  }
  return weight;
}

/// This is a helper function to parse a physical register string and split it
/// into non-numeric and numeric parts (Prefix and Reg). The first boolean flag
/// that is returned indicates whether parsing was successful. The second flag
/// is true if the numeric part exists.
static std::pair<bool, bool>
parsePhysicalReg(const StringRef &C, std::string &Prefix,
                 unsigned long long &Reg) {
  if (C.front() != '{' || C.back() != '}')
    return std::make_pair(false, false);

  // Search for the first numeric character.
  StringRef::const_iterator I, B = C.begin() + 1, E = C.end() - 1;
  I = std::find_if(B, E, std::ptr_fun(isdigit));

  Prefix.assign(B, I - B);

  // The second flag is set to false if no numeric characters were found.
  if (I == E)
    return std::make_pair(true, false);

  // Parse the numeric characters.
  return std::make_pair(!getAsUnsignedInteger(StringRef(I, E - I), 10, Reg),
                        true);
}

std::pair<unsigned, const TargetRegisterClass *> FgpuTargetLowering::
parseRegForInlineAsmConstraint(const StringRef &C, MVT VT) const {
  DEBUG(dbgs() << "parseRegForInlineAsmConstraint entered, C = " << C.str() << "\n");
  const TargetRegisterClass *RC;
  std::string Prefix;
  unsigned long long Reg;

  std::pair<bool, bool> R = parsePhysicalReg(C, Prefix, Reg);

  if (!R.first)
    return std::make_pair(0U, nullptr);
  if (!R.second)
    return std::make_pair(0U, nullptr);

  assert(Prefix == "$");
  RC = getRegClassFor((VT == MVT::Other) ? MVT::i32 : VT);

  assert(Reg < RC->getNumRegs());
  return std::make_pair(*(RC->begin() + Reg), RC);
}

/// Given a register class constraint, like 'r', if this corresponds directly
/// to an LLVM register class, return a register of 0 and the register class
/// pointer.
std::pair<unsigned, const TargetRegisterClass *>
FgpuTargetLowering::getRegForInlineAsmConstraint(const TargetRegisterInfo *TRI,
                                                 StringRef Constraint,
                                                 MVT VT) const
{
  DEBUG(dbgs() << "soubhi: getRegForInlineAsmConstraint entered, Constraint[0] = " << Constraint << "\n");
  if (Constraint.size() == 1) {
    DEBUG(dbgs() << "Constraint.size() = 1 \n");
    switch (Constraint[0]) {
    // case 'I':
    case 'r':
      DEBUG(dbgs()<< "It is r\n");
      if (VT == MVT::i32 || VT == MVT::i16 || VT == MVT::i8) {
        return std::make_pair(0U, &Fgpu::ALURegsRegClass);
      }
      if (VT == MVT::i64)
        return std::make_pair(0U, &Fgpu::ALURegsRegClass);
      // This will generate an error message
      return std::make_pair(0u, static_cast<const TargetRegisterClass*>(0));
    case 'c': // register suitable for indirect jump
      if (VT == MVT::i32)
        return std::make_pair((unsigned)Fgpu::R25, &Fgpu::ALURegsRegClass);
      assert("Unexpected type.");
    }
  }
  std::pair<unsigned, const TargetRegisterClass *> R;
  R = parseRegForInlineAsmConstraint(Constraint, VT);

  if (R.second)
    return R;

  return TargetLowering::getRegForInlineAsmConstraint(TRI, Constraint, VT);
}

/// LowerAsmOperandForConstraint - Lower the specified operand into the Ops
/// vector.  If it is invalid, don't add anything to Ops.
void FgpuTargetLowering::LowerAsmOperandForConstraint(SDValue Op,
                                                     std::string &Constraint,
                                                     std::vector<SDValue>&Ops,
                                                     SelectionDAG &DAG) const {
  SDLoc DL(Op);
  SDValue Result;
  DEBUG(dbgs() << "soubhi: LowerAsmOperandForConstraint entered\n");
  // Only support length 1 constraints for now.
  if (Constraint.length() > 1) return;

  char ConstraintLetter = Constraint[0];
  switch (ConstraintLetter) {
  default: break; // This will fall through to the generic implementation
  case 'I': // Signed 16 bit constant
    // If this fails, the parent routine will give an error
    if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(Op)) {
      EVT Type = Op.getValueType();
      int64_t Val = C->getSExtValue();
      if (isInt<16>(Val)) {
        Result = DAG.getTargetConstant(Val, DL, Type);
        break;
      }
    }
    return;
  case 'J': // integer zero
    if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(Op)) {
      EVT Type = Op.getValueType();
      int64_t Val = C->getZExtValue();
      if (Val == 0) {
        Result = DAG.getTargetConstant(0, DL, Type);
        break;
      }
    }
    return;
  case 'K': // unsigned 16 bit immediate
    if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(Op)) {
      EVT Type = Op.getValueType();
      uint64_t Val = (uint64_t)C->getZExtValue();
      if (isUInt<16>(Val)) {
        Result = DAG.getTargetConstant(Val, DL, Type);
        break;
      }
    }
    return;
  case 'L': // signed 32 bit immediate where lower 16 bits are 0
    if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(Op)) {
      EVT Type = Op.getValueType();
      int64_t Val = C->getSExtValue();
      if ((isInt<32>(Val)) && ((Val & 0xffff) == 0)){
        Result = DAG.getTargetConstant(Val, DL, Type);
        break;
      }
    }
    return;
  case 'N': // immediate in the range of -65535 to -1 (inclusive)
    if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(Op)) {
      EVT Type = Op.getValueType();
      int64_t Val = C->getSExtValue();
      if ((Val >= -65535) && (Val <= -1)) {
        Result = DAG.getTargetConstant(Val, DL, Type);
        break;
      }
    }
    return;
  case 'O': // signed 15 bit immediate
    if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(Op)) {
      EVT Type = Op.getValueType();
      int64_t Val = C->getSExtValue();
      if ((isInt<15>(Val))) {
        Result = DAG.getTargetConstant(Val, DL, Type);
        break;
      }
    }
    return;
  case 'P': // immediate in the range of 1 to 65535 (inclusive)
    if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(Op)) {
      EVT Type = Op.getValueType();
      int64_t Val = C->getSExtValue();
      if ((Val <= 65535) && (Val >= 1)) {
        Result = DAG.getTargetConstant(Val, DL, Type);
        break;
      }
    }
    return;
  }

  if (Result.getNode()) {
    Ops.push_back(Result);
    return;
  }

  TargetLowering::LowerAsmOperandForConstraint(Op, Constraint, Ops, DAG);
}

bool FgpuTargetLowering::isLegalAddressingMode(const DataLayout &DL,
                                               const AddrMode &AM, Type *Ty,
                                               unsigned AS) const {
  // No global is ever allowed as a base.
  if (AM.BaseGV)
    return false;

  switch (AM.Scale) {
  case 0: // "r+i" or just "i", depending on HasBaseReg.
    break;
  case 1:
    if (!AM.HasBaseReg) // allow "r+i".
      break;
    return false; // disallow "r+r" or "r+r+i".
  default:
    return false;
  }

  return true;
}

bool
FgpuTargetLowering::isOffsetFoldingLegal(const GlobalAddressSDNode *GA) const {
  // The Fgpu target isn't yet aware of offsets.
  return false;
}

FgpuTargetLowering::FgpuCC::FgpuCC(
  CallingConv::ID CC, CCState &Info)
  : CCInfo(Info), CallConv(CC) {
  // Pre-allocate reserved argument area.
  CCInfo.AllocateStack(reservedArgArea(), 1);
}

void FgpuTargetLowering::FgpuCC::
analyzeFormalArguments(const SmallVectorImpl<ISD::InputArg> &Args,
                       Function::const_arg_iterator FuncArg) {
  unsigned NumArgs = Args.size();
  DEBUG(dbgs() << "soubhi: analyzeFormalArguments: NumArgs = " << NumArgs << "\n");
  unsigned CurArgIdx = 0;

  for (unsigned I = 0; I != NumArgs; ++I) {
    // DEBUG(dbgs() << "soubhi: analyzeFormalArguments: I = " << I << "\n");
    MVT ArgVT = Args[I].VT;
    ISD::ArgFlagsTy ArgFlags = Args[I].Flags;
    DEBUG(dbgs() << "soubhi: analyzeFormalArguments: Args[" << I<< "].OrigArgIndex = " << Args[I].OrigArgIndex << "\n");
    std::advance(FuncArg, Args[I].OrigArgIndex - CurArgIdx);
    CurArgIdx = Args[I].OrigArgIndex;

    if (ArgFlags.isByVal()) {
      assert(false);
    }

    if (!CC_Fgpu(I, ArgVT, ArgVT, CCValAssign::Full, ArgFlags, this->CCInfo))
      continue;

#ifndef NDEBUG
    DEBUG(dbgs() << "Formal Arg #" << I << " has unhandled type "
           << EVT(ArgVT).getEVTString());
#endif
    llvm_unreachable(nullptr);
  }
}

template<typename Ty> void FgpuTargetLowering::FgpuCC::analyzeReturn(
        const SmallVectorImpl<Ty> &RetVals,
              const SDNode *CallNode, const Type *RetTy) const {
  for (unsigned I = 0, E = RetVals.size(); I < E; ++I) {
    MVT VT = RetVals[I].VT;
    ISD::ArgFlagsTy Flags = RetVals[I].Flags;

    // it will retrun true always!
    if (RetCC_Fgpu(I, VT, VT, CCValAssign::Full, Flags, this->CCInfo)) {
#ifndef NDEBUG
      DEBUG(dbgs() << "Call result #" << I << " has unhandled type "
             << EVT(VT).getEVTString() << '\n');
#endif
      llvm_unreachable(nullptr);
    }
  }
}

void FgpuTargetLowering::FgpuCC::analyzeCallResult(
                                  const SmallVectorImpl<ISD::InputArg> &Ins,
                                  const SDNode *CallNode,
                                  const Type *RetTy) const {
  analyzeReturn(Ins, CallNode, RetTy);
}

void FgpuTargetLowering::FgpuCC::analyzeReturn(
              const SmallVectorImpl<ISD::OutputArg> &Outs,
              const Type *RetTy) const {
  analyzeReturn(Outs, nullptr, RetTy);
}

unsigned FgpuTargetLowering::FgpuCC::reservedArgArea() const {
  return (CallConv != CallingConv::Fast) ? 8 : 0;
}


bool llvm::isKernelFunction(const Function &F) {
  // F.print(dbgs());
  // F.viewCFG();
  // F.viewCFGOnly();
  DEBUG(dbgs() << "Function Name = " << F.getName() << "\n");
  // bool retval = findNamedMetadata(&F, "opencl.kernels");
  const Module *m = F.getParent();
  DEBUG(dbgs() << "Soubhi: Module : " << m->getModuleIdentifier() << "\n");
  NamedMDNode *NMD = m->getNamedMetadata("opencl.kernels");
  if (!NMD)
  {
    DEBUG(dbgs() << "No opencl.kernels found!\n");
    return false;
  }
  else{
    DEBUG(dbgs() << "opencl.kernels found!\n");
  }
  DEBUG(dbgs() << "opencl.kernels->getNumOperands() = " << NMD->getNumOperands() << "\n");
  for (unsigned i = 0, e = NMD->getNumOperands(); i != e; ++i) {
    const MDNode *elem = NMD->getOperand(i);
    DEBUG(dbgs() << "Operand Nr. " << i << " of opencl.kernels is: ");
    DEBUG(elem->print(dbgs()));
    DEBUG(dbgs() << "\n");
    // GlobalValue *entity =
    //     mdconst::dyn_extract_or_null<GlobalValue>(elem->getOperand(0));
    const Function *entity =
        mdconst::dyn_extract_or_null<Function>(elem->getOperand(0));
    DEBUG(dbgs() << "first operand is: ");
    DEBUG(elem->getOperand(0).get()->print(dbgs()));
    DEBUG(dbgs() << "\n");
    if (!entity)
    {
      DEBUG(dbgs() << "operand is not a function!\n");
    }
    if (entity == &F)
    {
      DEBUG(dbgs() << "The function is a kernel!\n");
      return true;
    }
  }
  DEBUG(dbgs() << "The function is not a kernel!\n");
  return false;
}

SDValue FgpuTargetLowering::getTargetNode(ExternalSymbolSDNode *N, EVT Ty,
                                          SelectionDAG &DAG,
                                          unsigned Flag) const {
  DEBUG(dbgs() << "getTargetNode for ExternalSymbolSDNode entered\n");
  return DAG.getTargetExternalSymbol(N->getSymbol(), Ty, Flag);
}
