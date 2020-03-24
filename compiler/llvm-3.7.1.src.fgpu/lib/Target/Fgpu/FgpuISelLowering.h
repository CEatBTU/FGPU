//===-- FgpuISelLowering.h - Fgpu DAG Lowering Interface --------*- C++ -*-===//
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

#ifndef FGPUISELLOWERING_H
#define FGPUISELLOWERING_H


// #include "MCTargetDesc/FgpuBaseInfo.h"
#include "MCTargetDesc/FgpuABIInfo.h"
#include "Fgpu.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/IR/Function.h"
#include "llvm/Target/TargetLowering.h"
#include <deque>

namespace llvm {

  
  namespace FgpuISD {
    enum NodeType {
      // Start the numbering from where ISD NodeType finishes.
      FIRST_NUMBER = ISD::BUILTIN_OP_END,

      // Jump and link (call)
      JmpLink,

      // Tail call
      TailCall,

      // Get the Higher 16 bits from a 32-bit immediate
      // No relation with Fgpu Hi register
      LUi,
      // Get the Lower 16 bits from a 32-bit immediate
      // No relation with Fgpu Lo register
      Li,

      // Handle gp_rel (small data/bss sections) relocation.
      GPRel,

      // Thread Pointer
      ThreadPointer,

      // FGPU special instructions
      RET,
      LP,
      WGOFF,
      WGID,
      LID,
      WGSIZE,
      SIZE,
      AADD,
      AMAX,


      Wrapper,
      DynAlloc,

      Sync
    };
  }

  //===--------------------------------------------------------------------===//
  // TargetLowering Implementation
  //===--------------------------------------------------------------------===//
  class FgpuFunctionInfo;
  class FgpuSubtarget;
  bool isKernelFunction(const Function &F);

  //@class FgpuTargetLowering
  class FgpuTargetLowering : public TargetLowering  {
  public:
    explicit FgpuTargetLowering(const FgpuTargetMachine &TM,
                                const FgpuSubtarget &STI);

    static const FgpuTargetLowering *create(const FgpuTargetMachine &TM,
                                            const FgpuSubtarget &STI);

    /// LowerOperation - Provide custom lowering hooks for some operations.
    SDValue LowerOperation(SDValue Op, SelectionDAG &DAG) const override;

    /// getTargetNodeName - This method returns the name of a target specific
    //  DAG node.
    const char *getTargetNodeName(unsigned Opcode) const override;

    SDValue PerformDAGCombine(SDNode *N, DAGCombinerInfo &DCI) const override;


  protected:

    /// This function fills Ops, which is the list of operands that will later
    /// be used when a function call node is created. It also generates
    /// copyToReg nodes to set up argument registers.
    virtual void
    getOpndList(SmallVectorImpl<SDValue> &Ops,
                std::deque< std::pair<unsigned, SDValue> > &RegsToPass,
                bool IsPICCall, bool GlobalOrExternal, bool InternalLinkage,
                CallLoweringInfo &CLI, SDValue Callee, SDValue Chain) const;

    /// FgpuCC - This class provides methods used to analyze formal and call
    /// arguments and inquire about calling convention information.
    class FgpuCC {
    public:

      FgpuCC(CallingConv::ID CallConv, CCState &Info);

      void analyzeCallOperands(const SmallVectorImpl<ISD::OutputArg> &Outs,
                               const SDNode *CallNode);
      void analyzeFormalArguments(const SmallVectorImpl<ISD::InputArg> &Ins,
                                  Function::const_arg_iterator FuncArg);

      void analyzeCallResult(const SmallVectorImpl<ISD::InputArg> &Ins,
                             const SDNode *CallNode,
                             const Type *RetTy) const;

      void analyzeReturn(const SmallVectorImpl<ISD::OutputArg> &Outs,
                         const Type *RetTy) const;

      const CCState &getCCInfo() const { return CCInfo; }

      /// regSize - Size (in number of bits) of integer registers.
      unsigned regSize() const { return 4; }
      /// numIntArgRegs - Number of integer registers available for calls.
      unsigned numIntArgRegs() const;

      /// reservedArgArea - The size of the area the caller reserves for
      /// register arguments. This is 16-byte if ABI is CC_Fgpu.
      unsigned reservedArgArea() const;

      /// Return pointer to array of integer argument registers.
      const ArrayRef<MCPhysReg> intArgRegs() const;

    private:

      /// useRegsForByval - Returns true if the calling convention allows the
      /// use of registers to pass byval arguments.
      bool useRegsForByval() const { return CallConv != CallingConv::Fast; }

      template<typename Ty>
      void analyzeReturn(const SmallVectorImpl<Ty> &RetVals,
                         const SDNode *CallNode, const Type *RetTy) const;

      CCState &CCInfo;
      CallingConv::ID CallConv;
    };

  protected:
    // Subtarget Info
    const FgpuSubtarget &Subtarget;
    // Cache the ABI from the TargetMachine, we use it everywhere.
    const FgpuABIInfo &ABI;

  private:
    // Create a TargetExternalSymbol node.
    SDValue getTargetNode(ExternalSymbolSDNode *N, EVT Ty, SelectionDAG &DAG,
                          unsigned Flag) const;

    // Create a TargetBlockAddress node.
    SDValue getTargetNode(BlockAddressSDNode *N, EVT Ty, SelectionDAG &DAG,
                          unsigned Flag) const;

    // Lower Operand helpers
    SDValue LowerCallResult(SDValue Chain,
                            SDValue InFlag,
                            CallingConv::ID CallConv,
                            const SmallVectorImpl<ISD::InputArg> &Ins,
                            SDLoc dl, SelectionDAG &DAG,
                            SmallVectorImpl<SDValue> &InVals,
                            const SDNode *CallNode, const Type *RetTy) const;

    /// ReplaceNodeResults - Replace the results of node with an illegal result
    /// type with new values built out of custom code.
    ///
    void ReplaceNodeResults(SDNode *N, SmallVectorImpl<SDValue>&Results,
                            SelectionDAG &DAG) const override;

    SDValue lowerGlobalAddress(SDValue Op, SelectionDAG &DAG) const;
    SDValue lowerConstantPool(SDValue Op, SelectionDAG &DAG) const;
    SDValue lowerLoad(SDValue Op, SelectionDAG &DAG) const;
    SDValue lowerStore(SDValue Op, SelectionDAG &DAG) const;
    // SDValue lowerBRCOND(SDValue Op, SelectionDAG &DAG) const;
    SDValue lowerTargetGlobalAddress(SDValue Op, SelectionDAG &DAG) const;
    SDValue lowerGlobalTLSAddress(SDValue Op, SelectionDAG &DAG) const;
    SDValue lowerSINT_TO_FP(SDValue Op, SelectionDAG &DAG) const;
    SDValue lowerFP_TO_SINT(SDValue Op, SelectionDAG &DAG) const;
    SDValue lowerSETCC(SDValue Op, SelectionDAG &DAG) const;
    SDValue LowerFrameIndex(SDValue Op, SelectionDAG &DAG) const;

    SDValue LowerFormalArguments(SDValue Chain,
                           CallingConv::ID CallConv, bool IsVarArg,
                           const SmallVectorImpl<ISD::InputArg> &Ins,
                           SDLoc dl, SelectionDAG &DAG,
                           SmallVectorImpl<SDValue> &InVals) const override;
    SDValue LowerFormalArgumentsUsingCallStack(SDValue Chain,
                           CallingConv::ID CallConv,
                           const SmallVectorImpl<ISD::InputArg> &Ins,
                           SDLoc dl, SelectionDAG &DAG,
                           SmallVectorImpl<SDValue> &InVals) const;
    SDValue LowerFormalArgumentsUsingLP(SDValue Chain,
                           CallingConv::ID CallConv,
                           const SmallVectorImpl<ISD::InputArg> &Ins,
                           SDLoc dl, SelectionDAG &DAG,
                           SmallVectorImpl<SDValue> &InVals) const;

    SDValue passArgOnStack(SDValue StackPtr, unsigned Offset, SDValue Chain,
                           SDValue Arg, SDLoc DL, bool IsTailCall,
                           SelectionDAG &DAG) const;

    SDValue LowerCall(TargetLowering::CallLoweringInfo &CLI,
                      SmallVectorImpl<SDValue> &InVals) const override;

    SDValue LowerReturn(SDValue Chain,
                        CallingConv::ID CallConv, bool IsVarArg,
                        const SmallVectorImpl<ISD::OutputArg> &Outs,
                        const SmallVectorImpl<SDValue> &OutVals,
                        SDLoc dl, SelectionDAG &DAG) const override;

    // Inline asm support
    ConstraintType getConstraintType(StringRef Constraint) const override;

    /// Examine constraint string and operand type and determine a weight value.
    /// The operand object must already have been set up with the operand type.
    ConstraintWeight getSingleConstraintMatchWeight(
      AsmOperandInfo &info, const char *constraint) const override;

    /// This function parses registers that appear in inline-asm constraints.
    /// It returns pair (0, 0) on failure.
    std::pair<unsigned, const TargetRegisterClass *>
    parseRegForInlineAsmConstraint(const StringRef &C, MVT VT) const;

    std::pair<unsigned, const TargetRegisterClass *>
    getRegForInlineAsmConstraint(const TargetRegisterInfo *TRI,
                                 StringRef Constraint, MVT VT) const override;

    /// LowerAsmOperandForConstraint - Lower the specified operand into the Ops
    /// vector.  If it is invalid, don't add anything to Ops. If hasMemory is
    /// true it means one of the asm constraint of the inline asm instruction
    /// being processed is 'm'.
    void LowerAsmOperandForConstraint(SDValue Op,
                                      std::string &Constraint,
                                      std::vector<SDValue> &Ops,
                                      SelectionDAG &DAG) const override;

    bool isLegalAddressingMode(const DataLayout &DL, const AddrMode &AM,
                               Type *Ty, unsigned AS) const override;

    bool isOffsetFoldingLegal(const GlobalAddressSDNode *GA) const override;

  };
  const FgpuTargetLowering *
  createFgpuSETargetLowering(const FgpuTargetMachine &TM, const FgpuSubtarget &STI);
}

#endif
