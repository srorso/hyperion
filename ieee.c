
/* IEEE.C       (c) Copyright Roger Bowler and others, 2003-2012     */
/*              (c) Copyright Willem Konynenberg, 2001-2003          */
/*              (c) Copyright "Fish" (David B. Trout), 2011          */
/*              Hercules Binary (IEEE) Floating Point Instructions   */
/*              (c) Copyright Stephen R. Orso, 2016                  */
/*              Updated to use version 3a of the Softfloat library   */
/*                and implement instructions and instruction         */
/*                operands enabled by the Floating Point Extension   */
/*                Facility                                           */
/*                                                                   */
/*   Released under "The Q Public License Version 1"                 */
/*   (http://www.hercules-390.org/herclic.html) as modifications to  */
/*   Hercules.                                                       */

/*-------------------------------------------------------------------*/
/* This module implements ESA/390 Binary Floating-Point (IEEE 754)   */
/* instructions as described in SA22-7201-05 ESA/390 Principles of   */
/* Operation and SA22-7832-08 z/Architecture Principles of Operation.*/
/*-------------------------------------------------------------------*/

/*
 * Hercules System/370, ESA/390, z/Architecture emulator
 * ieee.c
 * Binary (IEEE) Floating Point Instructions
 * Copyright (c) 2001-2009 Willem Konynenberg <wfk@xos.nl>
 * TCEB, TCDB and TCXB contributed by Per Jessen, 20 September 2001.
 * THDER,THDR by Roger Bowler, 19 July 2003.
 * Additional instructions by Roger Bowler, November 2004:
 *  LXDBR,LXDB,LXEBR,LXEB,LDXBR,LEXBR,CXFBR,CXGBR,CFXBR,CGXBR,
 *  MXDBR,MXDB,MDEBR,MDEB,MADBR,MADB,MAEBR,MAEB,MSDBR,MSDB,
 *  MSEBR,MSEB,DIEBR,DIDBR,TBEDR,TBDR.
 * Based very loosely on float.c by Peter Kuschnerus, (c) 2000-2006.
 * All instructions (except convert to/from HFP/BFP format THDR, THDER,
 *  TBDR and TBEDR) completely updated by "Fish" (David B. Trout)
 *  Aug 2011 to use SoftFloat Floating-Point package by John R. Hauser
 *  (http://www.jhauser.us/arithmetic/SoftFloat.html).
 * June 2016: All instructions (except convert to/from HFP/BFP and 
 *  Load Positive/Negative/Complement) completely updated by Stephen 
 *  R. Orso to use the updated Softfloat 3a library by John R. Hauser 
 *  (link above).  Added interpretation of M3 and M4 operands for
 *  those instructions that support same, conditioned on 
 *  FEATURE_FLOATING_POINT_EXTENSION_FACILITY.  All changes are based 
 *  on the -10 edition of the z/Architecture Principles of Operation, 
 *  SA22-7832.  
 */


/* Modifications to the Softfloat interface enable use of a separately-     */
/* packaged Softfloat Library with minimal modifications.                   */

/* Modifications required to Softfloat:  (so far)                           */
/* - Change NaN propagation in the following routines to conform to IBM     */
/*   NaN propagation rules:                                                 */
/*      softfloat_propagateNaNF32UI()                                       */
/*      softfloat_propagateNaNF64UI()                                       */
/*      softfloat_propagateNaNF128UI()                                      */
/* - Change the default NaNs defined in softfloat-specialize.h from         */
/*   negative NaNs to positive NaNs.                                        */
/*   Change init_detectTininess from softfloat_tininess_afterRounding       */
/*   to softfloat_tininess_beforeRounding in softfloat-specialize.h, as     */
/*   required by SA22-7832-10 page 9-22.                                    */
/* - Change the following Softfloat global state variables in               */
/*   softfloat-state.c to include the __thread attribute to enable          */
/*   state separation when multiple CPU threads are running.  Make the      */
/*   same change for these variables in softfloat.h                         */
/*      softfloat_roundingMode                                              */
/*      softfloat_detectTininess                                            */
/*      softfloat_exceptionFlags                                            */
/* - Expose the "unbounded exponent results" during round and pack          */
/*   operations within Softfloat as part of the global state variables.     */
/*   This enables correct scaling of results on trappable overflow and      */
/*   underflow operations.  Affected routines:                              */
/*       softfloat_roundPackToF32()                                         */
/*       softfloat_roundPackToF64()                                         */
/*       softfloat_roundPackToF128()                                        */
/*                                                                          */
/*   These modifications, and the unmodified Softfloat 3a source, are       */
/*   maintained in a separate public repository                             */



#include "hstdinc.h"

#if !defined(_HENGINE_DLL_)
#define _HENGINE_DLL_
#endif

#if !defined(_IEEE_C_)
#define _IEEE_C_
#endif

#ifndef _GNU_SOURCE
#define _GNU_SOURCE 1
#endif

#include "hercules.h"
#include "opcode.h"
#include "inline.h"
#define FEATURE_FLOATING_POINT_EXTENSION_FACILITY            /* TEMP - */

#if defined(FEATURE_BINARY_FLOATING_POINT) && !defined(NO_IEEE_SUPPORT)


#if !defined(_IEEE_NONARCHDEP_)
/* Architecture independent code goes within this ifdef */

/*****************************************************************************/
/*                       ---  B E G I N  ---                                 */
/*                                                                           */
/*           'SoftFloat' IEEE Binary Floating Point package                  */
#define SOFTFLOAT_FAST_INT64
#include "softfloat.h"

#define FEATURE_FLOATING_POINT_EXTENSION_FACILITY            /* TEMP - */

/* Handy constants                           low    high                 */
static const float128_t  float128_zero   = { 0ULL, 0x0000000000000000ULL };
static const float64_t   float64_zero    = {       0x0000000000000000ULL };
static const float32_t   float32_zero    = {       0x00000000 };
/*                                           low    high                 */
#if 0
static const float128_t  float128_neg0   = { 0ULL, 0x8000000000000000ULL };
#endif
static const float64_t   float64_neg0    = {       0x8000000000000000ULL };
static const float32_t   float32_neg0    = {       0x80000000 };
/*                                           low       high                 */
#if 0
static const float128_t  float128_inf    = { 0ULL, 0x7FFF000000000000ULL };
#endif
static const float64_t   float64_inf     = {       0x7FF0000000000000ULL };
static const float32_t   float32_inf     = {       0x7F800000 };
/*                                           low       high                 */
#if 0
static const float128_t  float128_neginf = { 0ULL, 0xFFFF000000000000ULL };
#endif
static const float64_t   float64_neginf  = {       0xFFF0000000000000ULL };
static const float32_t   float32_neginf  = {       0xFF800000 };

/* Default QNaN per SA22-7832-10 page 9-3: plus sign, quiet, and payload of zero */
static const float64_t   float64_default_qnan = { 0x7FF8000000000000ULL  };
static const float32_t   float32_default_qnan = { 0x7FC00000 };

/* Map of IBM M3 rounding mode values to those used by Softfloat                                        */
static const BYTE map_m3_to_sf_rm[8] = { 0,                         /* M3 0: Use FPC BFP Rounding Mode  */
                                    softfloat_round_near_maxMag,    /* M3 1: RNTA                       */
                                    0,                              /* M3 2: invalid; detected in edits */ 
                                    softfloat_round_odd,            /* M3 3: RFS, substitute ties away  */
                                    softfloat_round_near_even,      /* M3 4: RNTE                       */
                                    softfloat_round_minMag,         /* M3 5: RZ                         */
                                    softfloat_round_max,            /* M3 6: RP                         */
                                    softfloat_round_min,            /* M3 7: RM                         */
                                  };


/* Map of IBM fpc BFP rounding mode values to those used by Softfloat                                   */
/* This table depends on FPS Support instructions to set the BFP rounding mode to only valid values     */
static const BYTE map_fpc_brm_to_sf_rm[8] = { 
                                    softfloat_round_near_even,      /* FPC BRM 0: RNTE                  */
                                    softfloat_round_minMag,         /* FPC BRM 5: RZ                    */
                                    softfloat_round_max,            /* FPC BRM 6: RP                    */
                                    softfloat_round_min,            /* FPC BRM 6: RM                    */
                                    0,                              /* FPC BRM 4: invalid               */
                                    0,                              /* FPC BRM 5: invalid               */
                                    0,                              /* FPC BRM 6: invalid               */
                                    softfloat_round_odd,            /* FPC BRM 7: RFS, subst. ties away */
                                       };

/* Table of valid M3 values and macro to generate program check if invalid BFP rounding method */
#if defined(FEATURE_FLOATING_POINT_EXTENSION_FACILITY)
/* Map of valid IBM M3 rounding mode values when the Floating Point Extension Facility is installed    */
static const BYTE map_valid_m3_values[8] = { 1,     /* M3 0: Use FPC BFP Rounding Mode  */
                                             1,     /* M3 1: RNTA                       */
                                             0,     /* M3 2: invalid                    */
                                             1,     /* M3 3: RFS, substitute ties away  */
                                             1,     /* M3 4: RNTE                       */
                                             1,     /* M3 5: RZ                         */
                                             1,     /* M3 6: RP                         */
                                             1,     /* M3 7: RM                         */
                                           };
#else
/* Map of valid IBM M3 rounding mode values when the Floating Point Extension Facility is NOT installed    */
static const BYTE map_valid_m3_values[8] = { 1,     /* M3 0: Use FPC BFP Rounding Mode  */
                                             1,     /* M3 1: RNTA                       */
                                             0,     /* M3 2: invalid                    */
                                             0,     /* M3 3: RFS, invalid without FPEF  */
                                             1,     /* M3 4: RNTE                       */
                                             1,     /* M3 5: RZ                         */
                                             1,     /* M3 6: RP                         */
                                             1,     /* M3 7: RM                         */
                                           };
#endif  /* if defined(FEATURE_FLOATING_POINT_EXTENSION_FACILITY)  */

#define BFPRM_CHECK(_x,_regs)                                                  \
        {if (_x > 7 || !map_valid_m3_values[(_x & 0x7)])                       \
            {regs->program_interrupt(_regs, PGM_SPECIFICATION_EXCEPTION);}}

#define SUPPRESS_INEXACT(_m4)  (_m4 & 0x04)


  /* Identify NaNs  */

#define FLOAT128_ISNAN( _op )   ( ((_op.v[1] & 0x7FFF000000000000ULL) == 0x7FFF000000000000ULL) &&     \
                                   (_op.v[1] & 0x0000FFFFFFFFFFFFULL || _op.v[0] ) )

#define FLOAT64_ISNAN( _op )    ( ((_op.v    & 0x7FF0000000000000ULL) == 0x7FF0000000000000ULL) &&     \
                                   (_op.v    & 0x000FFFFFFFFFFFFFULL) )

#define FLOAT32_ISNAN( _op )    ( ((_op.v & 0x7F800000 ) == 0x7F800000) &&                             \
                                   (_op.v & 0x007FFFFF) )

  /* Make SNaNs into QNaNs  */

#define FLOAT128_MAKE_QNAN( _op )  _op.v[1] |= 0x0000800000000000ULL
#define FLOAT64_MAKE_QNAN( _op )   _op.v    |= 0x0008000000000000ULL
#define FLOAT32_MAKE_QNAN( _op )   _op.v    |= 0x00400000

  /* Determine condition code based on value of result operand    */

#define FLOAT128_CC( _op1 ) /* Determine cc from float132 value */                         \
                            FLOAT128_ISNAN( _op1 ) ? 3 :                                       \
                            !( (_op1.v[1] & 0x7FFFFFFFFFFFFFFFULL) | _op1.v[0]) ? 0 :  \
                            _op1.v[1] & 0x8000000000000000ULL ? 1 : 2

#define FLOAT64_CC( _op1 )  /* Determine cc from float64 value */                          \
                            FLOAT64_ISNAN( _op1 ) ? 3 :                                        \
                            !(_op1.v & 0x7FFFFFFFFFFFFFFFULL) ? 0 :                    \
                            _op1.v & 0x8000000000000000ULL ? 1 : 2

#define FLOAT32_CC( _op1 )  /* Determine cc from float32 value */                          \
                            FLOAT32_ISNAN( _op1 )  ? 3 :                                   \
                            !(_op1.v & 0x7FFFFFFF) ? 0 :                                   \
                            _op1.v & 0x80000000    ? 1 : 2

static void ieee_trap( REGS *regs, BYTE dxc)
{
    regs->dxc = dxc;                   /*  Save DXC in PSA         */
    regs->fpc &= ~FPC_DXC;             /*  Clear any previous DXC  */
    regs->fpc |= ((U32)dxc << 8);      
    regs->program_interrupt(regs, PGM_DATA_EXCEPTION);
}

static void ieee_cond_trap( REGS *regs, U32 ieee_traps ) 
{
    /* ieee_cond_trap is called before instruction completion for Xi  */
    /* and Xz traps, resulting in instruction suppression.            */
    /* For other instructions, it is called after instruction results */
    /* have been stored.                                              */

    /* PROGRAMMING NOTE: for the underflow/overflow and inexact       */
    /* data exceptions, SoftFloat does not distinguish between        */
    /* exact, inexact and truncated, or inexact and incremented       */
    /* types, so neither can we. Thus for now we will always          */
    /* return the "truncated" variety.                                */

    switch (ieee_traps)
    {
    case FPC_MASK_IMI: ieee_trap(regs, DXC_IEEE_INVALID_OP);
    case FPC_MASK_IMZ: ieee_trap(regs, DXC_IEEE_DIV_ZERO);
    case FPC_MASK_IMO: ieee_trap(regs, DXC_IEEE_OF_INEX_TRUNC);
    case FPC_MASK_IMU: ieee_trap(regs, DXC_IEEE_UF_INEX_TRUNC);
    case FPC_MASK_IMX: ieee_trap(regs, DXC_IEEE_INEXACT_TRUNC);
    }
}

/*------------------------------------------------------------------------------*/
/* z/Architecture Floating-Point classes (for "Test Data Class" instruction)    */
/*                                                                              */
/* Values taken from SA22-7832-10, Table 19-21 on page 19-41                    */
/*------------------------------------------------------------------------------*/
enum {
    float_class_pos_zero            = 0x00000800,
    float_class_neg_zero            = 0x00000400,
    float_class_pos_normal          = 0x00000200,
    float_class_neg_normal          = 0x00000100,
    float_class_pos_subnormal       = 0x00000080,
    float_class_neg_subnormal       = 0x00000040,
    float_class_pos_infinity        = 0x00000020,
    float_class_neg_infinity        = 0x00000010,
    float_class_pos_quiet_nan       = 0x00000008,
    float_class_neg_quiet_nan       = 0x00000004,
    float_class_pos_signaling_nan   = 0x00000002,
    float_class_neg_signaling_nan   = 0x00000001
};

static INLINE U32 float128_class( float128_t op )
{
    int neg =
       (  op.v[1] & 0x8000000000000000ULL ) ? 1 : 0;
    if (f128_isSignalingNaN( op ))                          return float_class_pos_signaling_nan >> neg;
    if (FLOAT128_ISNAN( op ))                               return float_class_pos_quiet_nan     >> neg;
    if (!(op.v[1] & 0x7FFFFFFFFFFFFFFFULL ) && !op.v[0])    return float_class_pos_zero          >> neg;
    if ( (op.v[1] & 0x7FFFFFFFFFFFFFFFULL )
                 == 0x7FFF000000000000ULL   && !op.v[0])    return float_class_pos_infinity      >> neg;
    if (  op.v[1] & 0x7FFF000000000000ULL )                 return float_class_pos_normal        >> neg;
                                                            return float_class_pos_subnormal     >> neg;
}

static INLINE U32 float64_class( float64_t op )
{
    int neg =
       (  op.v & 0x8000000000000000ULL ) ? 1 : 0;
    if (f64_isSignalingNaN( op ))                           return float_class_pos_signaling_nan >> neg;
    if (FLOAT64_ISNAN( op ))                                return float_class_pos_quiet_nan     >> neg;
    if (!(op.v & 0x7FFFFFFFFFFFFFFFULL ))                   return float_class_pos_zero          >> neg;
    if ( (op.v & 0x7FFFFFFFFFFFFFFFULL )
              == 0x7FF0000000000000ULL )                    return float_class_pos_infinity      >> neg;
    if (  op.v & 0x7FF0000000000000ULL )                    return float_class_pos_normal        >> neg;
                                                            return float_class_pos_subnormal     >> neg;
}

static INLINE U32 float32_class( float32_t op )
{
    int neg =
       (  op.v & 0x80000000) ? 1 : 0;
    if (f32_isSignalingNaN( op ))     return float_class_pos_signaling_nan >> neg;
    if (FLOAT32_ISNAN( op ))              return float_class_pos_quiet_nan     >> neg;
    if (!(op.v & 0x7FFFFFFF))         return float_class_pos_zero          >> neg;
    if ( (op.v & 0x7FFFFFFF)
              == 0x7F800000)          return float_class_pos_infinity      >> neg;
    if (  op.v & 0x7F800000)          return float_class_pos_normal        >> neg;
                                      return float_class_pos_subnormal     >> neg;
}

/* ***************************************************************************************************** */
/*                 TAKE NOTE, TAKE NOTE!                                                                 */
/*                                                                                                       */
/* Softfloat architecture dependant: softfloat_exceptionFlags must use the same bit pattern as FPC Flags */
/*                                                                                                       */
/* ***************************************************************************************************** */

/* And here is another issue: flags are set only if the corresponding mask is set to non-trap.    */
/* need to do something with AND of current mask bits before or-ing in the flags, AND the test    */
/* for trap->data exception must be based on results from Softfloat, not the settings of the      */
/* flags.  Note: if a trap mask is 1, the corresponding flag is never set.                        */
#undef  SET_FPC_FLAGS_FROM_SF
#define SET_FPC_FLAGS_FROM_SF(regs) regs->fpc |= (softfloat_exceptionFlags << 19) & ~(regs->fpc >> 8) & 0x00F80000;

#undef  IEEE_EXCEPTION_TEST_TRAPS          /* Save detected exceptions that are trap-enabled          */
#define IEEE_EXCEPTION_TEST_TRAPS(_regs, _ieee_trap_conds, _exceptions)   \
      _ieee_trap_conds = (_regs->fpc & FPC_MASK) & (softfloat_exceptionFlags << 27) & (_exceptions)

/* ****           End of Softfloat architecture-dependent code                               **** */

#undef SET_SF_RM_FROM_FPC           /* Translate FPC rounding mode into matching Softfloat rounding mode  */
#define SET_SF_RM_FROM_FPC map_fpc_brm_to_sf_rm[ (regs->fpc & FPC_BRM_3BIT) ]

#undef SET_SF_RM_FROM_M3            /* Translate M3 rounding mode into matching Softfloat rounding mode, use FPC mode if M3 zero  */
#define SET_SF_RM_FROM_M3(_m3) softfloat_roundingMode = _m3 ? map_m3_to_sf_rm[_m3] : SET_SF_RM_FROM_FPC 


#undef  IEEE_EXCEPTION_TRAP_XI      /* fastpath test for Xi trap; many instructions only return Xi   */
#define IEEE_EXCEPTION_TRAP_XI(_regs)                                                                \
        if ( (softfloat_exceptionFlags & softfloat_flag_invalid) && (_regs->fpc & FPC_MASK_IMI) )    \
            ieee_trap(_regs, DXC_IEEE_INVALID_OP)                                                    \


#undef  IEEE_EXCEPTION_TRAP_XZ      /* fastpath test for Xz trap; only Divide returns Xz  */
#define IEEE_EXCEPTION_TRAP_XZ(_regs)                                                                \
        if ( (softfloat_exceptionFlags & softfloat_flag_infinite) && (_regs->fpc & FPC_MASK_IMZ) )   \
            ieee_trap(_regs, DXC_IEEE_DIV_ZERO )


#undef  IEEE_EXCEPTION_TRAP                /* trap if any provided exception has been previously detected   */
#define IEEE_EXCEPTION_TRAP(_regs, _ieee_trap_conds, _exceptions)                 \
        if ( _ieee_trap_conds & (_exceptions) )                                   \
            ieee_cond_trap(_regs, _ieee_trap_conds)


/* Test FPC against Softfloat execptions; return field whose bits identify those exceptions that */
/* a) were reported by Softfloat and b) are enabled for trapping by FPC byte zero                */
/* Only overflow, underflow, and inexact are tested; invalid and divide by zero are handled      */
/* separately.                                                                                   */

static INLINE U32 ieee_exception_test_oux(REGS *regs)
{
    U32 ieee_trap_conds = 0;

    if (regs->fpc & FPC_MASK)           /* some flags and some traps enabled.  Figure it out  */
    {
        IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);
        if (ieee_trap_conds & (FPC_MASK_IMO | FPC_MASK_IMU))
            softfloat_exceptionFlags &= ~softfloat_flag_inexact;  /* turn off Xx if Xo or Xo will trap      */
    };
    SET_FPC_FLAGS_FROM_SF(regs);        /*   Transfer any returned flags from Softfloat to FPC   */
    return ieee_trap_conds;
}

/*                          ---  E N D  ---                                  */
/*                                                                           */
/*           'SoftFloat' IEEE Binary Floating Point package                  */
/*****************************************************************************/

struct lbfp {
    int sign;
    int exp;
    U64 fract;
    double v;
};
struct sbfp {
    int sign;
    int exp;
    int fract;
    float v;
};

#endif  /* !defined(_IEEE_NONARCHDEP_) */

/*****************************************************************************/
/*                       ---  B E G I N  ---                                 */
/*                                                                           */
/*           'SoftFloat' IEEE Binary Floating Point package                  */

static INLINE void ARCH_DEP(get_float128)( float128_t *op, U32 *fpr )
{
                                                      /* high order bits in v[1], low order in v[0]  */
    op->v[1] = ((U64)fpr[0]     << 32) | fpr[1];               /* *****  Possible endian concern  ******* */
    op->v[0]  = ((U64)fpr[FPREX] << 32) | fpr[FPREX+1];
}

static INLINE void ARCH_DEP(put_float128)( float128_t *op, U32 *fpr )
{
    fpr[0]       = (U32) (op->v[1] >> 32);
    fpr[1]       = (U32) (op->v[1] & 0xFFFFFFFF);
    fpr[FPREX]   = (U32) (op->v[0]  >> 32);
    fpr[FPREX+1] = (U32) (op->v[0] & 0xFFFFFFFF);
}

static INLINE void ARCH_DEP(get_float64)( float64_t *op, U32 *fpr )
{
    op->v = ((U64)fpr[0] << 32) | fpr[1];
}

static INLINE void ARCH_DEP(put_float64)( float64_t *op, U32 *fpr )
{
    fpr[0] = (U32) (op->v >> 32);
    fpr[1] = (U32) (op->v & 0xFFFFFFFF);
}

static INLINE void ARCH_DEP(get_float32)( float32_t *op, U32 *fpr )
{
    op->v = *fpr;
}

static INLINE void ARCH_DEP(put_float32)( float32_t *op, U32 *fpr )
{
    *fpr = op->v;
}

#undef VFETCH_FLOAT64_OP
#undef VFETCH_FLOAT32_OP

#define VFETCH_FLOAT64_OP( op, effective_addr, arn, regs )  op.v = ARCH_DEP(vfetch8)( effective_addr, arn, regs )
#define VFETCH_FLOAT32_OP( op, effective_addr, arn, regs )  op.v = ARCH_DEP(vfetch4)( effective_addr, arn, regs )

#undef GET_FLOAT128_OP
#undef GET_FLOAT64_OP
#undef GET_FLOAT32_OP

#define GET_FLOAT128_OP( op, r, regs )  ARCH_DEP(get_float128)( &op, regs->fpr + FPR2I(r) )
#define GET_FLOAT64_OP( op, r, regs )   ARCH_DEP(get_float64)(  &op, regs->fpr + FPR2I(r) )
#define GET_FLOAT32_OP( op, r, regs )   ARCH_DEP(get_float32)(  &op, regs->fpr + FPR2I(r) )

#undef GET_FLOAT128_OPS
#undef GET_FLOAT64_OPS
#undef GET_FLOAT32_OPS

#define GET_FLOAT128_OPS( op1, r1, op2, r2, regs )  \
    do {                                            \
        GET_FLOAT128_OP( op1, r1, regs );           \
        GET_FLOAT128_OP( op2, r2, regs );           \
    } while (0)

#define GET_FLOAT64_OPS( op1, r1, op2, r2, regs )   \
    do {                                            \
        GET_FLOAT64_OP( op1, r1, regs );            \
        GET_FLOAT64_OP( op2, r2, regs );            \
    } while (0)

#define GET_FLOAT32_OPS( op1, r1, op2, r2, regs )   \
    do {                                            \
        GET_FLOAT32_OP( op1, r1, regs );            \
        GET_FLOAT32_OP( op2, r2, regs );            \
    } while (0)

static INLINE BYTE ARCH_DEP(float128_cc_quiet)( float128_t op1, float128_t op2 )
{
    return FLOAT128_ISNAN(    op1      ) ||
           FLOAT128_ISNAN(         op2 ) ? 3 :
           f128_eq(       op1, op2 ) ? 0 :
           f128_lt_quiet( op1, op2 ) ? 1 : 2;
}

static INLINE BYTE ARCH_DEP(float128_compare)( float128_t op1, float128_t op2 )
{
    if (f128_isSignalingNaN( op1 ) ||
        f128_isSignalingNaN( op2 ))
        softfloat_raiseFlags( softfloat_flag_invalid );
    return ARCH_DEP(float128_cc_quiet)( op1, op2 );
}

static INLINE BYTE ARCH_DEP(float128_signaling_compare)( float128_t op1, float128_t op2 )
{
    if (FLOAT128_ISNAN( op1 ) ||
        FLOAT128_ISNAN( op2 ))
        softfloat_raiseFlags(softfloat_flag_invalid);
    return ARCH_DEP(float128_cc_quiet)( op1, op2 );
}

static INLINE BYTE ARCH_DEP(float64_cc_quiet)( float64_t op1, float64_t op2 )
{
    return FLOAT64_ISNAN(   op1      ) ||
           FLOAT64_ISNAN(        op2 ) ? 3 :
           f64_eq(       op1, op2 ) ? 0 :
           f64_lt_quiet( op1, op2 ) ? 1 : 2;
}

static INLINE BYTE ARCH_DEP(float64_compare)( float64_t op1, float64_t op2 )
{
    if (f64_isSignalingNaN( op1 ) ||
        f64_isSignalingNaN( op2 ))
        softfloat_raiseFlags(softfloat_flag_invalid);
    return ARCH_DEP(float64_cc_quiet)( op1, op2 );
}

static INLINE BYTE ARCH_DEP(float64_signaling_compare)( float64_t op1, float64_t op2 )
{
    if (FLOAT64_ISNAN( op1 ) ||
        FLOAT64_ISNAN( op2 ))
        softfloat_raiseFlags(softfloat_flag_invalid);
    return ARCH_DEP(float64_cc_quiet)( op1, op2 );
}

static INLINE BYTE ARCH_DEP(float32_cc_quiet)( float32_t op1, float32_t op2 )
{
    return FLOAT32_ISNAN(    op1      ) ||
           FLOAT32_ISNAN(        op2 ) ? 3 :
           f32_eq(       op1, op2 ) ? 0 :
           f32_lt_quiet( op1, op2 ) ? 1 : 2;
}

static INLINE BYTE ARCH_DEP(float32_compare)( float32_t op1, float32_t op2 )
{
    if (f32_isSignalingNaN( op1 ) ||
        f32_isSignalingNaN( op2 ))
        softfloat_raiseFlags(softfloat_flag_invalid);
    return ARCH_DEP(float32_cc_quiet)( op1, op2 );
}

static INLINE BYTE ARCH_DEP(float32_signaling_compare)( float32_t op1, float32_t op2 )
{
    if (FLOAT32_ISNAN( op1 ) ||
        FLOAT32_ISNAN( op2 ))
        softfloat_raiseFlags(softfloat_flag_invalid);
    return ARCH_DEP(float32_cc_quiet)( op1, op2 );
}

#undef FLOAT128_COMPARE
#undef FLOAT64_COMPARE
#undef FLOAT32_COMPARE

#define FLOAT128_COMPARE( op1, op2 )  ARCH_DEP(float128_compare)( op1, op2 )
#define FLOAT64_COMPARE( op1, op2 )   ARCH_DEP(float64_compare)(  op1, op2 )
#define FLOAT32_COMPARE( op1, op2 )   ARCH_DEP(float32_compare)(  op1, op2 )

#undef FLOAT128_COMPARE_AND_SIGNAL
#undef FLOAT64_COMPARE_AND_SIGNAL
#undef FLOAT32_COMPARE_AND_SIGNAL

#define FLOAT128_COMPARE_AND_SIGNAL( op1, op2 )  ARCH_DEP(float128_signaling_compare)( op1, op2 )
#define FLOAT64_COMPARE_AND_SIGNAL( op1, op2 )   ARCH_DEP(float64_signaling_compare)(  op1, op2 )
#define FLOAT32_COMPARE_AND_SIGNAL( op1, op2 )   ARCH_DEP(float32_signaling_compare)(  op1, op2 )

#undef PUT_FLOAT128_NOCC
#undef PUT_FLOAT64_NOCC
#undef PUT_FLOAT32_NOCC

#define PUT_FLOAT128_NOCC( op1, r1, regs )  ARCH_DEP(put_float128)( &op1, regs->fpr + FPR2I(r1) )
#define PUT_FLOAT64_NOCC( op1, r1, regs )   ARCH_DEP(put_float64)( &op1, regs->fpr + FPR2I(r1) )
#define PUT_FLOAT32_NOCC( op1, r1, regs )   ARCH_DEP(put_float32)( &op1, regs->fpr + FPR2I(r1) )

#undef PUT_FLOAT128_CC
#undef PUT_FLOAT64_CC
#undef PUT_FLOAT32_CC

#define PUT_FLOAT128_CC( op1, r1, regs )                   \
    do {                                                        \
        ARCH_DEP(put_float128)( &op1, regs->fpr + FPR2I(r1) );  \
        regs->psw.cc = FLOAT128_CC(op1);                      \
    } while (0)

#define PUT_FLOAT64_CC( op1, r1, regs )                    \
    do {                                                        \
        ARCH_DEP(put_float64)( &op1, regs->fpr + FPR2I(r1) );   \
        regs->psw.cc = FLOAT64_CC(op1);                       \
    } while (0)

#define PUT_FLOAT32_CC( op1, r1, regs )                    \
    do {                                                        \
        ARCH_DEP(put_float32)( &op1, regs->fpr + FPR2I(r1) );   \
        regs->psw.cc = FLOAT32_CC(op1);                       \
    } while (0)


/*                          ---  E N D  ---                                  */
/*                                                                           */
/*           'SoftFloat' IEEE Binary Floating Point package                  */
/*****************************************************************************/

#if !defined(_IEEE_NONARCHDEP_)

#if !defined(HAVE_MATH_H) && (_MSC_VER < VS2015)
/* Avoid double definition for VS2015 (albeit with different values). */
/* All floating-point numbers can be put in one of these categories.  */
enum
{
    FP_NAN          =  0,
    FP_INFINITE     =  1,
    FP_ZERO         =  2,
    FP_SUBNORMAL    =  3,
    FP_NORMAL       =  4
};
#endif /*!defined(HAVE_MATH_H)*/

/*
 * Classify emulated fp values
 */
static int lbfpclassify(struct lbfp *op)
{
    if (op->exp == 0) {
        if (op->fract == 0)
            return FP_ZERO;
        else
            return FP_SUBNORMAL;
    } else if (op->exp == 0x7FF) {
        if (op->fract == 0)
            return FP_INFINITE;
        else
            return FP_NAN;
    } else {
        return FP_NORMAL;
    }
}
static int sbfpclassify(struct sbfp *op)
{
    if (op->exp == 0) {
        if (op->fract == 0)
            return FP_ZERO;
        else
            return FP_SUBNORMAL;
    } else if (op->exp == 0xFF) {
        if (op->fract == 0)
            return FP_INFINITE;
        else
            return FP_NAN;
    } else {
        return FP_NORMAL;
    }
}
/*
 * Get/fetch binary float from registers/memory
 */
static void get_lbfp(struct lbfp *op, U32 *fpr)
{
    op->sign = (fpr[0] & 0x80000000) != 0;
    op->exp = (fpr[0] & 0x7FF00000) >> 20;
    op->fract = (((U64)fpr[0] & 0x000FFFFF) << 32) | fpr[1];
    //logmsg("lget r=%8.8x%8.8x exp=%d fract=%"PRIx64"\n", fpr[0], fpr[1], op->exp, op->fract);
}

static void get_sbfp(struct sbfp *op, U32 *fpr)
{
    op->sign = (*fpr & 0x80000000) != 0;
    op->exp = (*fpr & 0x7F800000) >> 23;
    op->fract = *fpr & 0x007FFFFF;
    //logmsg("sget r=%8.8x exp=%d fract=%x\n", *fpr, op->exp, op->fract);
}

/*
 * Put binary float in registers
 */
static void put_lbfp(struct lbfp *op, U32 *fpr)
{
    fpr[0] = (op->sign ? 1<<31 : 0) | (op->exp<<20) | (op->fract>>32);
    fpr[1] = op->fract & 0xFFFFFFFF;
    //logmsg("lput exp=%d fract=%"PRIx64" r=%8.8x%8.8x\n", op->exp, op->fract, fpr[0], fpr[1]);
}

static void put_sbfp(struct sbfp *op, U32 *fpr)
{
    fpr[0] = (op->sign ? 1<<31 : 0) | (op->exp<<23) | op->fract;
    //logmsg("sput exp=%d fract=%x r=%8.8x\n", op->exp, op->fract, *fpr);
}

#endif  /* !defined(_IEEE_NONARCHDEP_) */

/*
 * Chapter 9. Floating-Point Overview and Support Instructions
 */

#if defined(FEATURE_FPS_EXTENSIONS)
#if !defined(_CBH_FUNC)
/*
 * Convert binary floating point to hexadecimal long floating point
 * save result into long register and return condition code
 * Roger Bowler, 19 July 2003
 */
static int cnvt_bfp_to_hfp (struct lbfp *op, int fpclass, U32 *fpr)
{
    int exp;
    U64 fract;
    U32 r0, r1;
    int cc;

    switch (fpclass) {
    default:
    case FP_NAN:
        r0 = 0x7FFFFFFF;
        r1 = 0xFFFFFFFF;
        cc = 3;
        break;
    case FP_INFINITE:
        r0 = op->sign ? 0xFFFFFFFF : 0x7FFFFFFF;
        r1 = 0xFFFFFFFF;
        cc = 3;
        break;
    case FP_ZERO:
        r0 = op->sign ? 0x80000000 : 0;
        r1 = 0;
        cc = 0;
        break;
    case FP_SUBNORMAL:
        r0 = op->sign ? 0x80000000 : 0;
        r1 = 0;
        cc = op->sign ? 1 : 2;
        break;
    case FP_NORMAL:
        //logmsg("ieee: exp=%d (X\'%3.3x\')\tfract=%16.16"PRIx64"\n",
        //        op->exp, op->exp, op->fract);
        /* Insert an implied 1. in front of the 52 bit binary
           fraction and lengthen the result to 56 bits */
        fract = (U64)(op->fract | 0x10000000000000ULL) << 3;

        /* The binary exponent is equal to the biased exponent - 1023
           adjusted by 1 to move the point before the 56 bit fraction */
        exp = op->exp - 1023 + 1;

        //logmsg("ieee: adjusted exp=%d\tfract=%16.16"PRIx64"\n", exp, fract);
        /* Shift the fraction right one bit at a time until
           the binary exponent becomes a multiple of 4 */
        while (exp & 3)
        {
            exp++;
            fract >>= 1;
        }
        //logmsg("ieee:  shifted exp=%d\tfract=%16.16"PRIx64"\n", exp, fract);

        /* Convert the binary exponent into a hexadecimal exponent
           by dropping the last two bits (which are now zero) */
        exp >>= 2;

        /* If the hexadecimal exponent is less than -64 then return
           a signed zero result with a non-zero condition code */
        if (exp < -64) {
            r0 = op->sign ? 0x80000000 : 0;
            r1 = 0;
            cc = op->sign ? 1 : 2;
            break;
        }

        /* If the hexadecimal exponent exceeds +63 then return
           a signed maximum result with condition code 3 */
        if (exp > 63) {
            r0 = op->sign ? 0xFFFFFFFF : 0x7FFFFFFF;
            r1 = 0xFFFFFFFF;
            cc = 3;
            break;
        }

        /* Convert the hexadecimal exponent to a characteristic
           by adding 64 */
        exp += 64;

        /* Pack the exponent and the fraction into the result */
        r0 = (op->sign ? 1<<31 : 0) | (exp << 24) | (fract >> 32);
        r1 = fract & 0xFFFFFFFF;
        cc = op->sign ? 1 : 2;
        break;
    }
    /* Store high and low halves of result into fp register array
       and return condition code */
    fpr[0] = r0;
    fpr[1] = r1;
    return cc;
} /* end function cnvt_bfp_to_hfp */

/*
 * Convert hexadecimal long floating point register to
 * binary floating point and return condition code
 * Roger Bowler, 28 Nov 2004
 */

/* Definitions of BFP rounding methods */
#define RM_DEFAULT_ROUNDING             0
#define RM_BIASED_ROUND_TO_NEAREST      1
#define RM_ROUND_TO_NEAREST             4
#define RM_ROUND_TOWARD_ZERO            5
#define RM_ROUND_TOWARD_POS_INF         6
#define RM_ROUND_TOWARD_NEG_INF         7

static int cnvt_hfp_to_bfp (U32 *fpr, int rounding,
        int bfp_fractbits, int bfp_emax, int bfp_ebias,
        int *result_sign, int *result_exp, U64 *result_fract)
{
    BYTE sign;
    short expo;
    U64 fract;
    int roundup = 0;
    int cc;
    U64 b;

    /* Break the source operand into sign, characteristic, fraction */
    sign = fpr[0] >> 31;
    expo = (fpr[0] >> 24) & 0x007F;
    fract = ((U64)(fpr[0] & 0x00FFFFFF) << 32) | fpr[1];

    /* Determine whether to round up or down */
    switch (rounding) {
    case RM_BIASED_ROUND_TO_NEAREST:
    case RM_ROUND_TO_NEAREST: roundup = 0; break;
    case RM_DEFAULT_ROUNDING:
    case RM_ROUND_TOWARD_ZERO: roundup = 0; break;
    case RM_ROUND_TOWARD_POS_INF: roundup = (sign ? 0 : 1); break;
    case RM_ROUND_TOWARD_NEG_INF: roundup = sign; break;
    } /* end switch(rounding) */

    /* Convert HFP zero to BFP zero and return cond code 0 */
    if (fract == 0) /* a = -0 or +0 */
    {
        *result_sign = sign;
        *result_exp = 0;
        *result_fract = 0;
        return 0;
    }

    /* Set the condition code */
    cc = sign ? 1 : 2;

    /* Convert the HFP characteristic to a true binary exponent */
    expo = (expo - 64) * 4;

    /* Convert true binary exponent to a biased exponent */
    expo += bfp_ebias;

    /* Shift the fraction left until leftmost 1 is in bit 8 */
    while ((fract & 0x0080000000000000ULL) == 0)
    {
        fract <<= 1;
        expo -= 1;
    }

    /* Convert 56-bit fraction to 55-bit with implied 1 */
    expo--;
    fract &= 0x007FFFFFFFFFFFFFULL;

    if (expo < -(bfp_fractbits-1)) /* |a| < Dmin */
    {
        if (expo == -(bfp_fractbits-1) - 1)
        {
            if (rounding == RM_BIASED_ROUND_TO_NEAREST
                || rounding == RM_ROUND_TO_NEAREST)
                roundup = 1;
        }
        if (roundup) { expo = 0; fract = 1; } /* Dmin */
        else { expo = 0; fract = 0; } /* Zero */
    }
    else if (expo < 1) /* Dmin <= |a| < Nmin */
    {
        /* Reinstate implied 1 in preparation for denormalization */
        fract |= 0x0080000000000000ULL;

        /* Denormalize to get exponent back in range */
        fract >>= (expo + (bfp_fractbits-1));
        expo = 0;
    }
    else if (expo > (bfp_emax+bfp_ebias)) /* |a| > Nmax */
    {
        cc = 3;
        if (roundup) { /* Inf */
            expo = (bfp_emax+bfp_ebias) + 1;
            fract = 0;
        } else { /* Nmax */
            expo = (bfp_emax+bfp_ebias);
            fract = 0x007FFFFFFFFFFFFFULL - (((U64)1<<(1+(55-bfp_fractbits)))-1);
        } /* Nmax */
    } /* end Nmax < |a| */

    /* Set the result sign and exponent */
    *result_sign = sign;
    *result_exp = expo;

    /* Apply rounding before truncating to final fraction length */
    b = ( (U64)1 ) << ( 55 - bfp_fractbits);
    if (roundup && (fract & b))
    {
        fract += b;
    }

    /* Convert 55-bit fraction to result fraction length */
    *result_fract = fract >> (55-bfp_fractbits);

    return cc;
} /* end function cnvt_hfp_to_bfp */

#define _CBH_FUNC
#endif /*!defined(_CBH_FUNC)*/

/*-------------------------------------------------------------------*/
/* B359 THDR  - CONVERT BFP TO HFP (long)                      [RRE] */
/* Roger Bowler, 19 July 2003                                        */
/*-------------------------------------------------------------------*/
DEF_INST(convert_bfp_long_to_float_long_reg)
{
    int r1, r2;
    struct lbfp op2;

    RRE(inst, regs, r1, r2);
    //logmsg("THDR r1=%d r2=%d\n", r1, r2);
    HFPREG2_CHECK(r1, r2, regs);

    /* Load lbfp operand from R2 register */
    get_lbfp(&op2, regs->fpr + FPR2I(r2));

    /* Convert to hfp register and set condition code */
    regs->psw.cc =
        cnvt_bfp_to_hfp (&op2,
                         lbfpclassify(&op2),
                         regs->fpr + FPR2I(r1));

} /* end DEF_INST(convert_bfp_long_to_float_long_reg) */

/*-------------------------------------------------------------------*/
/* B358 THDER - CONVERT BFP TO HFP (short to long)             [RRE] */
/* Roger Bowler, 19 July 2003                                        */
/*-------------------------------------------------------------------*/
DEF_INST(convert_bfp_short_to_float_long_reg)
{
    int r1, r2;
    struct sbfp op2;
    struct lbfp lbfp_op2;

    RRE(inst, regs, r1, r2);
    //logmsg("THDER r1=%d r2=%d\n", r1, r2);
    HFPREG2_CHECK(r1, r2, regs);

    /* Load sbfp operand from R2 register */
    get_sbfp(&op2, regs->fpr + FPR2I(r2));

    /* Lengthen sbfp operand to lbfp */
    lbfp_op2.sign = op2.sign;
    lbfp_op2.exp = op2.exp - 127 + 1023;
    lbfp_op2.fract = (U64)op2.fract << (52 - 23);

    /* Convert lbfp to hfp register and set condition code */
    regs->psw.cc =
        cnvt_bfp_to_hfp (&lbfp_op2,
                         sbfpclassify(&op2),
                         regs->fpr + FPR2I(r1));

} /* end DEF_INST(convert_bfp_short_to_float_long_reg) */

/*-------------------------------------------------------------------*/
/* B351 TBDR  - CONVERT HFP TO BFP (long)                      [RRF] */
/*-------------------------------------------------------------------*/
DEF_INST(convert_float_long_to_bfp_long_reg)
{
    int r1, r2, m3;
    struct lbfp op1;

    RRF_M(inst, regs, r1, r2, m3);
    //logmsg("TBDR r1=%d r2=%d\n", r1, r2);
    HFPREG2_CHECK(r1, r2, regs);
    BFPRM_CHECK(m3,regs);

    regs->psw.cc =
        cnvt_hfp_to_bfp (regs->fpr + FPR2I(r2), m3,
            /*fractbits*/52, /*emax*/1023, /*ebias*/1023,
            &(op1.sign), &(op1.exp), &(op1.fract));

    put_lbfp(&op1, regs->fpr + FPR2I(r1));

} /* end DEF_INST(convert_float_long_to_bfp_long_reg) */

/*-------------------------------------------------------------------*/
/* B350 TBEDR - CONVERT HFP TO BFP (long to short)             [RRF] */
/*-------------------------------------------------------------------*/
DEF_INST(convert_float_long_to_bfp_short_reg)
{
    int r1, r2, m3;
    struct sbfp op1;
    U64 fract;

    RRF_M(inst, regs, r1, r2, m3);
    //logmsg("TBEDR r1=%d r2=%d\n", r1, r2);
    HFPREG2_CHECK(r1, r2, regs);
    BFPRM_CHECK(m3,regs);

    regs->psw.cc =
        cnvt_hfp_to_bfp (regs->fpr + FPR2I(r2), m3,
            /*fractbits*/23, /*emax*/127, /*ebias*/127,
            &(op1.sign), &(op1.exp), &fract);
    op1.fract = (U32)fract;

    put_sbfp(&op1, regs->fpr + FPR2I(r1));

} /* end DEF_INST(convert_float_long_to_bfp_short_reg) */
#endif /*defined(FEATURE_FPS_EXTENSIONS)*/

/*-------------------------------------------------------------------*/
/* B34A AXBR  - ADD (extended BFP)                             [RRE] */
/*-------------------------------------------------------------------*/

DEF_INST(add_bfp_ext_reg)
{
    int r1, r2;
    float128_t op1, op2, ans;
    U32 ieee_trap_conds = 0;                                /* start out with no traps detected                     */

    RRE(inst, regs, r1, r2);                                /* decode operand registers from instruction            */
    BFPINST_CHECK(regs);                                    /* Ensure BPF instructions allowed by CPU State         */
    BFPREGPAIR2_CHECK(r1, r2, regs);                        /* Ensure valide FP register pair                       */
    GET_FLOAT128_OPS( op1, r1, op2, r2, regs );             /* Get operand values                                   */

    softfloat_exceptionFlags = 0;                           /* Clear all Softfloat IEEE flags                       */
    SET_SF_RM_FROM_FPC;                                     /* Set rounding mode for Add from FPC                   */
    ans = f128_add( op1, op2 );                             /* Add two float128_t values                            */

    if (softfloat_exceptionFlags)                           /* Any IEEE Exceptions?                                 */
    {
        IEEE_EXCEPTION_TRAP_XI(regs);                       /* if Xi trappable, suppresses result, no return        */
        ieee_trap_conds = ieee_exception_test_oux(regs);    /* test for overflow, underflow, inexact, set FPC flags */
    };

    PUT_FLOAT128_CC( ans, r1, regs );                       /* Store result from Add */
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO     /* Take trap for any trappable exception */
                                             | FPC_MASK_IMU 
                                             | FPC_MASK_IMX);
}

/*-------------------------------------------------------------------*/
/* B31A ADBR  - ADD (long BFP)                                 [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(add_bfp_long_reg)
{
    int r1, r2;
    float64_t op1, op2, ans;
    int ieee_trap_conds = 0;                /* start out with no traps detected   */

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    GET_FLOAT64_OPS( op1, r1, op2, r2, regs );

    softfloat_exceptionFlags = 0;
    SET_SF_RM_FROM_FPC;                                     /* Set rounding mode for Add from FPC                   */
    ans = f64_add( op1, op2 );

    /* following optimized around "normal" case: no ieee exceptions or no traps enabled  */
    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);   /* Xi is only trap that suppresses result, no return  */
        ieee_trap_conds = ieee_exception_test_oux(regs);  /* test for overflow, underflow, inexact  */
    };

    PUT_FLOAT64_CC(ans, r1, regs);       /* Store result from Add */
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */
}

/*-------------------------------------------------------------------*/
/* ED1A ADB   - ADD (long BFP)                                 [RXE] */
/*-------------------------------------------------------------------*/
DEF_INST(add_bfp_long)
{
    int r1, b2;
    VADR effective_addr2;
    float64_t op1, op2, ans;
    int ieee_trap_conds = 0;                /* start out with no traps detected   */

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);
    GET_FLOAT64_OP( op1, r1, regs );
    VFETCH_FLOAT64_OP( op2, effective_addr2, b2, regs );

    softfloat_exceptionFlags = 0;
    SET_SF_RM_FROM_FPC;                                     /* Set rounding mode for Add from FPC                   */
    ans = f64_add( op1, op2 );

    /* following optimized around "normal" case: no ieee exceptions or no traps enabled  */
    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);   /* Xi is only trap that suppresses result, no return  */
        ieee_trap_conds = ieee_exception_test_oux(regs);  /* test for overflow, underflow, inexact  */
    };

    PUT_FLOAT64_CC(ans, r1, regs);       /* Store result from Add */
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */

}

/*-------------------------------------------------------------------*/
/* B30A AEBR  - ADD (short BFP)                                [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(add_bfp_short_reg)
{
    int r1, r2;
    float32_t op1, op2, ans;
    int ieee_trap_conds = 0;                /* start out with no traps detected   */
    
    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    GET_FLOAT32_OPS( op1, r1, op2, r2, regs );

    softfloat_exceptionFlags = 0;
    SET_SF_RM_FROM_FPC;                                     /* Set rounding mode for Add from FPC                   */
    ans = f32_add( op1, op2 );

    /* following optimized around "normal" case: no ieee exceptions or no traps enabled  */
    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);   /* Xi is only trap that suppresses result, no return  */
        ieee_trap_conds = ieee_exception_test_oux(regs);  /* test for overflow, underflow, inexact  */
    };

    PUT_FLOAT32_CC(ans, r1, regs);       /* Store result from Add */
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */

}

/*-------------------------------------------------------------------*/
/* ED0A AEB   - ADD (short BFP)                                [RXE] */
/*-------------------------------------------------------------------*/
DEF_INST(add_bfp_short)
{
    int r1, b2;
    VADR effective_addr2;
    float32_t op1, op2, ans;
    int ieee_trap_conds = 0;                /* start out with no traps detected   */

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);
    GET_FLOAT32_OP( op1, r1, regs );
    VFETCH_FLOAT32_OP( op2, effective_addr2, b2, regs );

    softfloat_exceptionFlags = 0;
    SET_SF_RM_FROM_FPC;                                     /* Set rounding mode for Add from FPC                   */
    ans = f32_add( op1, op2 );

    /* following optimized around "normal" case: no ieee exceptions or no traps enabled  */
    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);   /* Xi is only trap that suppresses result, no return  */
        ieee_trap_conds = ieee_exception_test_oux(regs);  /* test for overflow, underflow, inexact  */
    };

    PUT_FLOAT32_CC(ans, r1, regs);       /* Store result from Add */
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */
}

/*-------------------------------------------------------------------*/
/* B349 CXBR  - COMPARE (extended BFP)                         [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(compare_bfp_ext_reg)
{
    int r1, r2;
    float128_t op1, op2;
    BYTE newcc;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    BFPREGPAIR2_CHECK(r1, r2, regs);
    GET_FLOAT128_OPS( op1, r1, op2, r2, regs );

    softfloat_exceptionFlags = 0;
    newcc = FLOAT128_COMPARE(op1, op2);

    IEEE_EXCEPTION_TRAP_XI(regs);   /* Xi is only trap that suppresses result, no return  */

    SET_FPC_FLAGS_FROM_SF(regs);        /*   Transfer any returned flags from Softfloat to FPC   */
    regs->psw.cc = newcc;
    /* Xi is only possible exception detected for Compare   */
}

/*-------------------------------------------------------------------*/
/* B319 CDBR  - COMPARE (long BFP)                             [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(compare_bfp_long_reg)
{
    int r1, r2;
    float64_t op1, op2;
    BYTE newcc;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    GET_FLOAT64_OPS( op1, r1, op2, r2, regs );

    softfloat_exceptionFlags = 0;
    newcc = FLOAT64_COMPARE(op1, op2);

    IEEE_EXCEPTION_TRAP_XI(regs);       /* Xi is only trap; suppress result, no return  */
    SET_FPC_FLAGS_FROM_SF(regs);        /*   Transfer any returned flags from Softfloat to FPC   */
    regs->psw.cc = newcc;

}

/*-------------------------------------------------------------------*/
/* ED19 CDB   - COMPARE (long BFP)                             [RXE] */
/*-------------------------------------------------------------------*/
DEF_INST(compare_bfp_long)
{
    int r1, b2;
    VADR effective_addr2;
    float64_t op1, op2;
    BYTE newcc;

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);
    GET_FLOAT64_OP( op1, r1, regs );
    VFETCH_FLOAT64_OP( op2, effective_addr2, b2, regs );

    softfloat_exceptionFlags = 0;
    newcc = FLOAT64_COMPARE(op1, op2);

    IEEE_EXCEPTION_TRAP_XI(regs);       /* Xi is only trap; suppress result, no return  */
    SET_FPC_FLAGS_FROM_SF(regs);        /*   Transfer any returned flags from Softfloat to FPC   */
    regs->psw.cc = newcc;
}

/*-------------------------------------------------------------------*/
/* B309 CEBR  - COMPARE (short BFP)                            [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(compare_bfp_short_reg)
{
    int r1, r2;
    float32_t op1, op2;
    BYTE newcc;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    GET_FLOAT32_OPS( op1, r1, op2, r2, regs );

    softfloat_exceptionFlags = 0;
    newcc = FLOAT32_COMPARE(op1, op2);

    IEEE_EXCEPTION_TRAP_XI(regs);       /* Xi is only trap; suppress result, no return  */
    SET_FPC_FLAGS_FROM_SF(regs);        /*   Transfer any returned flags from Softfloat to FPC   */
    regs->psw.cc = newcc;
}

/*-------------------------------------------------------------------*/
/* ED09 CEB   - COMPARE (short BFP)                            [RXE] */
/*-------------------------------------------------------------------*/
DEF_INST(compare_bfp_short)
{
    int r1, b2;
    VADR effective_addr2;
    float32_t op1, op2;
    BYTE newcc;

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);
    GET_FLOAT32_OP( op1, r1, regs );
    VFETCH_FLOAT32_OP( op2, effective_addr2, b2, regs );

    softfloat_exceptionFlags = 0;
    newcc = FLOAT32_COMPARE(op1, op2);

    IEEE_EXCEPTION_TRAP_XI(regs);       /* Xi is only trap; suppress result, no return  */
    SET_FPC_FLAGS_FROM_SF(regs);        /*   Transfer any returned flags from Softfloat to FPC   */
    regs->psw.cc = newcc;
}

/*-------------------------------------------------------------------*/
/* B348 KXBR  - COMPARE AND SIGNAL (extended BFP)              [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(compare_and_signal_bfp_ext_reg)
{
    int r1, r2;
    float128_t op1, op2;
    BYTE newcc;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    BFPREGPAIR2_CHECK(r1, r2, regs);
    GET_FLOAT128_OPS( op1, r1, op2, r2, regs );

    softfloat_exceptionFlags = 0;
    newcc = FLOAT128_COMPARE_AND_SIGNAL(op1, op2);

    IEEE_EXCEPTION_TRAP_XI(regs);       /* Xi is only trap; suppress result, no return  */
    SET_FPC_FLAGS_FROM_SF(regs);        /*   Transfer any returned flags from Softfloat to FPC   */
    regs->psw.cc = newcc;
}

/*-------------------------------------------------------------------*/
/* B318 KDBR  - COMPARE AND SIGNAL (long BFP)                  [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(compare_and_signal_bfp_long_reg)
{
    int r1, r2;
    float64_t op1, op2;
    BYTE newcc;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    GET_FLOAT64_OPS( op1, r1, op2, r2, regs );

    softfloat_exceptionFlags = 0;
    newcc = FLOAT64_COMPARE_AND_SIGNAL(op1, op2);

    IEEE_EXCEPTION_TRAP_XI(regs);       /* Xi is only trap; suppress result, no return  */
    SET_FPC_FLAGS_FROM_SF(regs);        /*   Transfer any returned flags from Softfloat to FPC   */
    regs->psw.cc = newcc;
}

/*-------------------------------------------------------------------*/
/* ED18 KDB   - COMPARE AND SIGNAL (long BFP)                  [RXE] */
/*-------------------------------------------------------------------*/
DEF_INST(compare_and_signal_bfp_long)
{
    int r1, b2;
    VADR effective_addr2;
    float64_t op1, op2;
    BYTE newcc;

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);
    GET_FLOAT64_OP( op1, r1, regs );
    VFETCH_FLOAT64_OP( op2, effective_addr2, b2, regs );

    softfloat_exceptionFlags = 0;
    newcc = FLOAT64_COMPARE_AND_SIGNAL(op1, op2);

    IEEE_EXCEPTION_TRAP_XI(regs);       /* Xi is only trap; suppress result, no return  */
    SET_FPC_FLAGS_FROM_SF(regs);        /*   Transfer any returned flags from Softfloat to FPC   */
    regs->psw.cc = newcc;
}

/*-------------------------------------------------------------------*/
/* B308 KEBR  - COMPARE AND SIGNAL (short BFP)                 [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(compare_and_signal_bfp_short_reg)
{
    int r1, r2;
    float32_t op1, op2;
    BYTE newcc;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    GET_FLOAT32_OPS( op1, r1, op2, r2, regs );

    softfloat_exceptionFlags = 0;
    newcc = FLOAT32_COMPARE_AND_SIGNAL(op1, op2);

    IEEE_EXCEPTION_TRAP_XI(regs);       /* Xi is only trap; suppress result, no return  */
    SET_FPC_FLAGS_FROM_SF(regs);        /*   Transfer any returned flags from Softfloat to FPC   */
    regs->psw.cc = newcc;
}

/*-------------------------------------------------------------------*/
/* ED08 KEB   - COMPARE AND SIGNAL (short BFP)                 [RXE] */
/*-------------------------------------------------------------------*/
DEF_INST(compare_and_signal_bfp_short)
{
    int r1, b2;
    VADR effective_addr2;
    float32_t op1, op2;
    BYTE newcc;

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);
    GET_FLOAT32_OP( op1, r1, regs );
    VFETCH_FLOAT32_OP( op2, effective_addr2, b2, regs );

    softfloat_exceptionFlags = 0;
    newcc = FLOAT32_COMPARE_AND_SIGNAL(op1, op2);

    IEEE_EXCEPTION_TRAP_XI(regs);       /* Xi is only trap; suppress result, no return  */
    SET_FPC_FLAGS_FROM_SF(regs);        /*   Transfer any returned flags from Softfloat to FPC   */
    regs->psw.cc = newcc;

}

/*--------------------------------------------------------------------------*/
/* CONVERT FROM FIXED                                                       */
/*                                                                          */
/* Input is a signed integer; Xo, Xu, and Xx are only exceptions possible   */
/*                                                                          */
/* If FEATURE_FLOATING_POINT_EXTENSION FACILITY installed (defined)         */
/*   M3 field controls rounding, 0=Use FPC BRM                              */
/*   M4 field bit 0x04 XxC (inexact) suppresses inexact exception: no       */
/*   inexact trap or FPC status flag.                                       */
/*                                                                          */
/* If Floating Point Extension Facility not installed                       */
/*   M3 & M4 must be zero else program check specification exception        */
/*   Rounding is controlled by the BFP Rounding Mode in the FPC             */
/*                                                                          */
/*--------------------------------------------------------------------------*/


/*----------------------------------------------------------------------*/
/* B396 CXFBR  - CONVERT FROM FIXED (32 to extended BFP)       [RRE]    */
/* B396 CXFBRA - CONVERT FROM FIXED (32 to extended BFP)       [RRF-e]  */
/*                                                                      */
/* Fixed 32-bit always fits in Extended BFP; no exceptions possible     */
/*                                                                      */
/*----------------------------------------------------------------------*/
DEF_INST(convert_fix32_to_bfp_ext_reg)
{
    int r1, r2;
    BYTE m3, m4;
    S32 op2;
    float128_t op1;

    RRF_MM(inst, regs, r1, r2, m3, m4);

    BFPINST_CHECK(regs);
    BFPREGPAIR_CHECK(r1, regs);

#if defined(FEATURE_FLOATING_POINT_EXTENSION_FACILITY)
    BFPRM_CHECK(m3, regs);            /* validate BFP Rounding mode in instruction         */
#else
    if (m3 | m4)                      /* ensure M3 and M4 are zero for pre-FPEF interpretation of instructions  */
        regs->program_interrupt(regs, PGM_SPECIFICATION_EXCEPTION);
#endif

    op2 = regs->GR_L(r2);
    SET_SF_RM_FROM_M3(m3);            /* Set Softfloat rounding mode from M3 or FPC if M3 = 0  */
    softfloat_exceptionFlags = 0;
    op1 = i32_to_f128(op2);
                                      /* No flags set by CONVERT FROM FIXED (32 to extended BFP); */

    PUT_FLOAT128_NOCC( op1, r1, regs );

}

/*----------------------------------------------------------------------*/
/* B395 CDFBR  - CONVERT FROM FIXED (32 to long BFP)           [RRE]    */
/* B395 CDFBRA - CONVERT FROM FIXED (32 to long BFP)           [RRF-e]  */
/*                                                                      */
/* Fixed 32-bit always fits in long BFP; no exceptions possible         */
/*----------------------------------------------------------------------*/
DEF_INST(convert_fix32_to_bfp_long_reg)
{
    int r1, r2;
    BYTE m3, m4;
    S32 op2;
    float64_t op1;

    RRF_MM(inst, regs, r1, r2, m3, m4);
    BFPINST_CHECK(regs);

#if defined(FEATURE_FLOATING_POINT_EXTENSION_FACILITY)
    BFPRM_CHECK(m3, regs);              /* validate BFP Rounding mode in instruction         */
#else
    if (m3 | m4)                        /* ensure M3 and M4 are zero for pre-FPEF interpretation of instructions  */
        regs->program_interrupt(regs, PGM_SPECIFICATION_EXCEPTION);  
#endif

    SET_SF_RM_FROM_M3(m3);              /* Set Softfloat rounding mode from M3 or FPC if M3 = 0  */
    op2 = regs->GR_L(r2);
    softfloat_exceptionFlags = 0;
    op1 = i32_to_f64( op2 );
                                        /* No flags set by CONVERT FROM FIXED (32 to long BFP); */
    PUT_FLOAT64_NOCC( op1, r1, regs );

}

/*--------------------------------------------------------------------------*/
/* B394 CEFBR  - CONVERT FROM FIXED (32 to short BFP)           [RRE]       */
/* B394 CEFBRA - CONVERT FROM FIXED (32 to short BFP)           [RRF-e]     */
/*                                                                          */
/* Fixed 32-bit may need to be rounded to fit in the 23+1 bits available    */
/* in a short BFP, IEEE Inexact may be raised.  If m4 Inexact suppression   */
/* (XxC) is on, then no inexact exception is recognized (no trap nor flag   */
/* set).                                                                    */
/*--------------------------------------------------------------------------*/
DEF_INST(convert_fix32_to_bfp_short_reg)
{
    int r1, r2;
    BYTE m3, m4;
    S32 op2;
    float32_t op1;
    U32 ieee_trap_conds = 0;

    RRF_MM(inst, regs, r1, r2, m3, m4);
    BFPINST_CHECK(regs);

#if defined(FEATURE_FLOATING_POINT_EXTENSION_FACILITY)
    BFPRM_CHECK(m3, regs);            /* validate BFP Rounding mode in instruction         */
#else
    if (m3 | m4)                      /* ensure M3 and M4 are zero for pre-FPEF interpretation of instructions  */
        regs->program_interrupt(regs, PGM_SPECIFICATION_EXCEPTION);
#endif

    SET_SF_RM_FROM_M3(m3);                          /* Set Softfloat rounding mode from M3 or FPC if M3 = 0  */
    op2 = regs->GR_L(r2);
    softfloat_exceptionFlags = 0;
    op1 = i32_to_f32( op2 );
    PUT_FLOAT32_NOCC( op1, r1, regs );              /* operation always stores result, inexact only possible exception  */

    if ( softfloat_exceptionFlags && !SUPPRESS_INEXACT(m4) )        /* inexact occurred and not masked by m4?  */
    {                                                               /* ..yes, set FPC flags and test for a trap   */
        ieee_trap_conds = ieee_exception_test_oux(regs);            /* test for overflow, underflow, inexact, save flags  */
        IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMX);   /* taxe Xx trap if inexact detected  */
    };

}

#if defined(FEATURE_ESAME)
/*----------------------------------------------------------------------*/
/* B3A6 CXGBR  - CONVERT FROM FIXED (64 to extended BFP)        [RRE]   */
/* B3A6 CXGBRA - CONVERT FROM FIXED (64 to extended BFP)        [RRF-e] */
/*                                                                      */
/* Fixed 64-bit always fits in extended BFP; no exceptions possible     */
/*----------------------------------------------------------------------*/
DEF_INST(convert_fix64_to_bfp_ext_reg)
{
    int r1, r2;
    BYTE m3, m4;
    S64 op2;
    float128_t op1;

    RRF_MM(inst, regs, r1, r2, m3, m4);
    BFPINST_CHECK(regs);
    BFPREGPAIR_CHECK(r1, regs);

#if defined(FEATURE_FLOATING_POINT_EXTENSION_FACILITY)
    BFPRM_CHECK(m3, regs);              /* validate BFP Rounding mode in instruction         */
#else
    if (m3 | m4)                        /* ensure M3 and M4 are zero for pre-FPEF interpretation of instructions  */
        regs->program_interrupt(regs, PGM_SPECIFICATION_EXCEPTION);
#endif

    SET_SF_RM_FROM_M3(m3);              /* Set Softfloat rounding mode from M3 or FPC if M3 = 0  */
    op2 = regs->GR_G(r2);               /* HERE'S THE ERROR    !!!!!!!  should be the whole register*/
    softfloat_exceptionFlags = 0;
    op1 = i64_to_f128(op2);
                                        /* No flags set by CONVERT FROM FIXED (64 to extended BFP); */
    PUT_FLOAT128_NOCC(op1, r1, regs);

}
#endif /*defined(FEATURE_ESAME)*/

#if defined(FEATURE_ESAME)
/*--------------------------------------------------------------------------*/
/* B3A5 CDGBR  - CONVERT FROM FIXED (64 to long BFP)            [RRE]       */
/* B3A5 CDGBRA - CONVERT FROM FIXED (64 to long BFP)            [RRF-e]     */
/*                                                                          */
/* Fixed 64-bit may not fit in the 52+1 bits available in a long BFP, IEEE  */
/* Inexact exceptions are possible.  If m4 Inexact suppression control      */
/* (XxC) is on, then no Inexact exceptions recognized (no trap nor flag     */
/* set).                                                                    */
/*--------------------------------------------------------------------------*/
DEF_INST(convert_fix64_to_bfp_long_reg)
{
    int r1, r2;
    BYTE m3, m4;
    S64 op2;
    float64_t op1;
    U32 ieee_trap_conds = 0;
    
    RRF_MM(inst, regs, r1, r2, m3, m4);
    BFPINST_CHECK(regs);

#if defined(FEATURE_FLOATING_POINT_EXTENSION_FACILITY)
    BFPRM_CHECK(m3, regs);            /* validate BFP Rounding mode in instruction         */
#else
    if (m3 | m4)                      /* ensure M3 and M4 are zero for pre-FPEF interpretation of instructions  */
        regs->program_interrupt(regs, PGM_SPECIFICATION_EXCEPTION);
#endif

    SET_SF_RM_FROM_M3(m3);            /* Set Softfloat rounding mode from M3 or FPC if M3 = 0  */
    op2 = regs->GR_G(r2);
    softfloat_exceptionFlags = 0;
    op1 = i64_to_f64( op2 );
    PUT_FLOAT64_NOCC( op1, r1, regs );              /* operation always stores result  */

    if (softfloat_exceptionFlags && !SUPPRESS_INEXACT(m4))          /* inexact occurred and not masked by m4?  */
    {                                                               /* ..yes, set FPC flags and test for a trap   */
        ieee_trap_conds = ieee_exception_test_oux(regs);            /* test for overflow, underflow, inexact; save flags  */
        IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMX);   /* taxe Xx trap if inexact detected  */
    };

}
#endif /*defined(FEATURE_ESAME)*/

#if defined(FEATURE_ESAME)
/*--------------------------------------------------------------------------*/
/* B3A4 CEGBR  - CONVERT FROM FIXED (64 to short BFP)           [RRE]       */
/* B3A4 CEGBRA - CONVERT FROM FIXED (64 to short BFP)           [RRF-e]     */
/*                                                                          */
/* Fixed 64-bit may need to be rounded to fit in the 23+1 bits available    */
/* in a short BFP, IEEE Inexact may be raised.  If m4 Inexact suppression   */
/* (XxC) is on, then no inexact exception is recognized (no trap nor flag   */
/* set).                                                                    */
/*--------------------------------------------------------------------------*/
DEF_INST(convert_fix64_to_bfp_short_reg)
{
    int r1, r2;
    BYTE m3, m4;
    S64 op2;
    float32_t op1;
    U32 ieee_trap_conds = 0;

    RRF_MM(inst, regs, r1, r2, m3, m4);
    BFPINST_CHECK(regs);

#if defined(FEATURE_FLOATING_POINT_EXTENSION_FACILITY)
    BFPRM_CHECK(m3, regs);            /* validate BFP Rounding mode in instruction         */
#else
    if (m3 | m4)                      /* ensure M3 and M4 are zero for pre-FPEF interpretation of instructions  */
        regs->program_interrupt(regs, PGM_SPECIFICATION_EXCEPTION);
#endif

    SET_SF_RM_FROM_M3(m3);            /* Set Softfloat rounding mode from M3 or FPC if M3 = 0  */
    op2 = regs->GR_G(r2);
    softfloat_exceptionFlags = 0;
    op1 = i64_to_f32( op2 );
    PUT_FLOAT32_NOCC( op1, r1, regs );       /* operation always stores result  */

    if (softfloat_exceptionFlags && !(SUPPRESS_INEXACT(m4)))        /* inexact occurred and not masked by m4?  */
    {                                                               /* ..yes, set FPC flags and test for a trap   */
        ieee_trap_conds = ieee_exception_test_oux(regs);            /* test for overflow, underflow, inexact; save flags  */
        IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMX);   /* taxe Xx trap if inexact detected  */
    };

}
#endif /*defined(FEATURE_ESAME)*/

/*--------------------------------------------------------------------------*/
/* CONVERT TO FIXED                                                         */
/*                                                                          */
/* Input is a floating point value; Xi and Xx are only exceptions possible  */
/* M3 field controls rounding, 0=Use FPC BRM                                */
/*                                                                          */
/* If the input value magnitude is too large to be represented in the       */
/* target format, an IEEE Invalid exception is raised.  If Invalid is not   */
/* trappable, the result is a maximum-magnitude integer of matching sign    */
/* and the IEEE Inexact exception is raised.                                */
/*                                                                          */
/* If FEATURE_FLOATING_POINT_EXTENSION FACILITY installed (defined)         */
/*   M4 field bit 0x40 XxC (inexact) suppresses inexact exception: no       */
/*   IEEE Inexact trap or FPC Inexact status flag set.                      */
/*                                                                          */
/* If Floating Point Extension Facility not installed                       */
/*   M4 must be zero else program check specification exception             */
/*                                                                          */
/* Softfloat does not do two things required by SA-22-7832-10 table 19-18   */
/* on page 19.23:                                                           */
/* ** If the input is a NaN, return the largest negative number (Softfloat  */
/*    returns the largest positive number).  We code around this issue.     */
/* ** If Invalid is returned by Softfloat or due to a NaN and is not        */
/*    trappable, Inexact must be returned if not masked by M4               */
/*                                                                          */
/* We also need some test cases to probe Softfloat behavior when the        */
/* rounded result fits in an integer but the input is larger than that.     */
/* PoP requires inexact and maximum magnitude integer result.               */
/*--------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------*/
/* B39A CFXBR  - CONVERT TO FIXED (extended BFP to 32)          [RRF]    */
/* B39A CFXBRA - CONVERT TO FIXED (extended BFP to 32)          [RRF-e]  */
/*-----------------------------------------------------------------------*/
DEF_INST(convert_bfp_ext_to_fix32_reg)
{
    int r1, r2;
    BYTE m3, m4, newcc;
    S32 op1;
    float128_t op2;
    U32 ieee_trap_conds = 0;

#if defined(FEATURE_FLOATING_POINT_EXTENSION_FACILITY)
    RRF_MM(inst, regs, r1, r2, m3, m4);
#else
    RRF_M(inst, regs, r1, r2, m3);
    m4 = 0;
#endif

    BFPINST_CHECK(regs);
    BFPREGPAIR_CHECK(r2, regs);
    BFPRM_CHECK(m3,regs);
    GET_FLOAT128_OP(op2, r2, regs);

    softfloat_exceptionFlags = 0;
    if (FLOAT128_ISNAN(op2))                    /* NaN input always returns maximum negative integer, cc3, and IEEE invalid exception */
    {
        op1 = -0x7FFFFFFF - 1;
        newcc = 3;
        softfloat_raiseFlags(softfloat_flag_invalid);   
    }
    else
    {
        SET_SF_RM_FROM_M3(m3);                  /* Set Softfloat rounding mode from M3 or FPC if M3 = 0  */
        op1 = f128_to_i32(op2, softfloat_roundingMode, !(SUPPRESS_INEXACT(m4)));
        newcc = op1 ? (op1 < 0 ? 1 : 2) : 0;    /* Set condition code from result value  */
    }

    IEEE_EXCEPTION_TRAP_XI(regs);

    IEEE_EXCEPTION_TRAP_XI(regs);
    if (softfloat_exceptionFlags & softfloat_flag_invalid)              /* Non-trappable Invalid exception?             */
    {
        newcc = 3;                                                      /* ..yes, set cc=3                              */
        if (!SUPPRESS_INEXACT(m4))                                       /* Inexact not suppressed?                      */
            softfloat_exceptionFlags |= softfloat_flag_inexact;         /* ..yes, add Inexact exception to FCPR flags   */
    }

    regs->GR_L(r1) = op1;                       /* results returned even if exception trapped*/
    regs->psw.cc = newcc;

    ieee_trap_conds = ieee_exception_test_oux(regs);                    /* test for Xo, Xu, Xx; save flags                      */
                      /* Test for Xx with trap enabled; Pgm Chk Data Exception and suppress result if any true   */
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMX);

}

/*-------------------------------------------------------------------*/
/* B399 CFDBR - CONVERT TO FIXED (long BFP to 32)              [RRF] */
/*-------------------------------------------------------------------*/
DEF_INST(convert_bfp_long_to_fix32_reg)
{
    int r1, r2;
    BYTE m3, m4, newcc;
    S32 op1;
    float64_t op2;
    U32 ieee_trap_conds = 0;

#if defined(FEATURE_FLOATING_POINT_EXTENSION_FACILITY)
    RRF_MM(inst, regs, r1, r2, m3, m4);
#else
    RRF_M(inst, regs, r1, r2, m3);
    m4 = 0;
#endif

    BFPINST_CHECK(regs);
    BFPRM_CHECK(m3, regs);
    GET_FLOAT64_OP(op2, r2, regs);

    softfloat_exceptionFlags = 0;
    if (FLOAT64_ISNAN(op2))
    {
        op1 = -0x7FFFFFFF - 1;
        newcc = 3;
        softfloat_raiseFlags(softfloat_flag_invalid);
    }
    else
    {
        SET_SF_RM_FROM_M3(m3);                  /* Set Softfloat rounding mode from M3 or FPC if M3 = 0  */
        op1 = f64_to_i32( op2, softfloat_roundingMode, !SUPPRESS_INEXACT(m4) );
        newcc = op1 ? (op1 < 0 ? 1 : 2) : 0;    /* Set condition code from result value  */
    }

    IEEE_EXCEPTION_TRAP_XI(regs);

    IEEE_EXCEPTION_TRAP_XI(regs);
    if (softfloat_exceptionFlags & softfloat_flag_invalid)              /* Non-trappable Invalid exception?             */
    {
        newcc = 3;                                                      /* ..yes, set cc=3                              */
        if (!SUPPRESS_INEXACT(m4))                                       /* Inexact not suppressed?                      */
            softfloat_exceptionFlags |= softfloat_flag_inexact;         /* ..yes, add Inexact exception to FCPR flags   */
    }

    regs->GR_L(r1) = op1;
    regs->psw.cc = newcc;

    ieee_trap_conds = ieee_exception_test_oux(regs);                    /* test for Xo, Xu, Xx; save flags                      */
    /* Test for Xx with trap enabled; Pgm Chk Data Exception and suppress result if any true   */
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMX);

}

/*-------------------------------------------------------------------*/
/* B398 CFEBR - CONVERT TO FIXED (short BFP to 32)             [RRF] */
/*-------------------------------------------------------------------*/
DEF_INST(convert_bfp_short_to_fix32_reg)
{
    int r1, r2;
    BYTE m3, m4, newcc;
    S32 op1;
    float32_t op2;
    U32 ieee_trap_conds = 0;

#if defined(FEATURE_FLOATING_POINT_EXTENSION_FACILITY)
    RRF_MM(inst, regs, r1, r2, m3, m4);
#else
    RRF_M(inst, regs, r1, r2, m3);
    m4 = 0;
#endif

    BFPINST_CHECK(regs);
    BFPRM_CHECK(m3,regs);
    GET_FLOAT32_OP( op2, r2, regs );

    softfloat_exceptionFlags = 0;
    if (FLOAT32_ISNAN(op2))
    {
        op1 = -0x7FFFFFFF - 1;
        newcc = 3;
        softfloat_raiseFlags(softfloat_flag_invalid);
    }
    else
    {
        SET_SF_RM_FROM_M3(m3);                  /* Set Softfloat rounding mode from M3 or FPC if M3 = 0  */
        op1 = f32_to_i32(op2, softfloat_roundingMode, !SUPPRESS_INEXACT(m4) );
        newcc = op1 ? (op1 < 0 ? 1 : 2) : 0;    /* Set condition code from result value  */
    }

    IEEE_EXCEPTION_TRAP_XI(regs);

    IEEE_EXCEPTION_TRAP_XI(regs);
    if (softfloat_exceptionFlags & softfloat_flag_invalid)              /* Non-trappable Invalid exception?             */
    {
        newcc = 3;                                                      /* ..yes, set cc=3                              */
        if (!SUPPRESS_INEXACT(m4))                                       /* Inexact not suppressed?                      */
            softfloat_exceptionFlags |= softfloat_flag_inexact;         /* ..yes, add Inexact exception to FCPR flags   */
    }

    regs->GR_L(r1) = op1;
    regs->psw.cc = newcc;

    ieee_trap_conds = ieee_exception_test_oux(regs);                    /* test for Xo, Xu, Xx; save flags                      */
    /* Test for Xx with trap enabled; Pgm Chk Data Exception and suppress result if any true   */
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMX);

}

#if defined(FEATURE_ESAME)
/*-------------------------------------------------------------------*/
/* B3AA CGXBR - CONVERT TO FIXED (extended BFP to 64)          [RRF] */
/*-------------------------------------------------------------------*/
DEF_INST(convert_bfp_ext_to_fix64_reg)
{
    int r1, r2;
    BYTE m3, m4, newcc;
    S64 op1;
    float128_t op2;
    U32 ieee_trap_conds = 0;

#if defined(FEATURE_FLOATING_POINT_EXTENSION_FACILITY)
    RRF_MM(inst, regs, r1, r2, m3, m4);
#else
    RRF_M(inst, regs, r1, r2, m3);
    m4 = 0;
#endif

    BFPINST_CHECK(regs);
    BFPREGPAIR_CHECK(r2, regs);
    BFPRM_CHECK(m3,regs);
    GET_FLOAT128_OP( op2, r2, regs );

    softfloat_exceptionFlags = 0;
    if (FLOAT128_ISNAN(op2))
    {
        op1 = -(0x7FFFFFFFFFFFFFFFULL) - 1;
        newcc = 3;
        softfloat_raiseFlags(softfloat_flag_invalid);
    }
    else
    {
        SET_SF_RM_FROM_M3(m3);                  /* Set Softfloat rounding mode from M3 or FPC if M3 = 0  */
        op1 = f128_to_i64(op2, softfloat_roundingMode, !SUPPRESS_INEXACT(m4) );
        newcc = op1 ? (op1 < 0 ? 1 : 2) : 0;    /* Set condition code from result value  */
    }

    IEEE_EXCEPTION_TRAP_XI(regs);
    if (softfloat_exceptionFlags & softfloat_flag_invalid)              /* Non-trappable Invalid exception?             */
    {
        newcc = 3;                                                      /* ..yes, set cc=3                              */
        if(!SUPPRESS_INEXACT(m4))                                       /* Inexact not suppressed?                      */
            softfloat_exceptionFlags |= softfloat_flag_inexact;         /* ..yes, add Inexact exception to FCPR flags   */
    }

    regs->GR_G(r1) = op1;
    regs->psw.cc = newcc;

    ieee_trap_conds = ieee_exception_test_oux(regs);                    /* test for Xo, Xu, Xx; save flags                      */
    /* Test for Xx with trap enabled; Pgm Chk Data Exception and suppress result if any true   */
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMX);

}
#endif /*defined(FEATURE_ESAME)*/

#if defined(FEATURE_ESAME)
/*-------------------------------------------------------------------*/
/* B3A9 CGDBR - CONVERT TO FIXED (long BFP to 64)              [RRF] */
/*-------------------------------------------------------------------*/
DEF_INST(convert_bfp_long_to_fix64_reg)
{
    int r1, r2;
    BYTE m3, m4, newcc;
    S64 op1;
    float64_t op2;
    U32 ieee_trap_conds = 0;

#if defined(FEATURE_FLOATING_POINT_EXTENSION_FACILITY)
    RRF_MM(inst, regs, r1, r2, m3, m4);
#else
    RRF_M(inst, regs, r1, r2, m3);
    m4 = 0;
#endif

    BFPINST_CHECK(regs);
    BFPRM_CHECK(m3,regs);
    GET_FLOAT64_OP(op2, r2, regs);

    softfloat_exceptionFlags = 0;
    if (FLOAT64_ISNAN(op2))
    {
        op1 = -(0x7FFFFFFFFFFFFFFFULL) - 1;
        newcc = 3;
        softfloat_raiseFlags(softfloat_flag_invalid);
    }
    else
    {
        SET_SF_RM_FROM_M3(m3);                  /* Set Softfloat rounding mode from M3 or FPC if M3 = 0  */
        op1 = f64_to_i64(op2, softfloat_roundingMode, !SUPPRESS_INEXACT(m4) );
        newcc = op1 ? (op1 < 0 ? 1 : 2) : 0;    /* Set condition code from result value  */
    }

    IEEE_EXCEPTION_TRAP_XI(regs);
    if (softfloat_exceptionFlags & softfloat_flag_invalid)          /* Non-trappable Invalid exception?             */
    {
        newcc = 3;                                                  /* ..yes, set cc=3                              */
        if (!SUPPRESS_INEXACT(m4))                                  /* Inexact not suppressed?                      */
            softfloat_exceptionFlags |= softfloat_flag_inexact;     /* ..yes, add Inexact exception to FCPR flags   */
    }

    regs->GR_G(r1) = op1;
    regs->psw.cc = newcc;

    ieee_trap_conds = ieee_exception_test_oux(regs);                    /* test for Xo, Xu, Xx; save flags                      */
    /* Test for Xx with trap enabled; Pgm Chk Data Exception and suppress result if any true   */
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMX);

}
#endif /*defined(FEATURE_ESAME)*/

#if defined(FEATURE_ESAME)
/*-------------------------------------------------------------------*/
/* B3A8 CGEBR - CONVERT TO FIXED (short BFP to 64)             [RRF] */
/*-------------------------------------------------------------------*/
DEF_INST(convert_bfp_short_to_fix64_reg)
{
    int r1, r2;
    BYTE m3, m4, newcc;
    S64 op1;
    float32_t op2;
    U32 ieee_trap_conds = 0;

#if defined(FEATURE_FLOATING_POINT_EXTENSION_FACILITY)
    RRF_MM(inst, regs, r1, r2, m3, m4);
#else
    RRF_M(inst, regs, r1, r2, m3);
    m4 = 0;
#endif

    BFPINST_CHECK(regs);
    BFPRM_CHECK(m3,regs);
    GET_FLOAT32_OP( op2, r2, regs );

    softfloat_exceptionFlags = 0;
    if (FLOAT32_ISNAN(op2))
    {
        op1 = -(0x7FFFFFFFFFFFFFFFULL) - 1;
        newcc = 3;
        softfloat_raiseFlags(softfloat_flag_invalid);
    }
    else
    {
        SET_SF_RM_FROM_M3(m3);                  /* Set Softfloat rounding mode from M3 or FPC if M3 = 0  */
        op1 = f32_to_i64(op2, softfloat_roundingMode, !SUPPRESS_INEXACT(m4) );
        newcc = op1 ? (op1 < 0 ? 1 : 2) : 0;    /* Set condition code from result value  */
    }

    IEEE_EXCEPTION_TRAP_XI(regs);
    if (softfloat_exceptionFlags & softfloat_flag_invalid)          /* Non-trappable Invalid exception?             */
    {
        newcc = 3;                                                  /* ..yes, set cc=3                              */
        if (!SUPPRESS_INEXACT(m4))                                  /* Inexact not suppressed?                      */
            softfloat_exceptionFlags |= softfloat_flag_inexact;     /* ..yes, add Inexact exception to FCPR flags   */
    }

    regs->GR_G(r1) = op1;
    regs->psw.cc = newcc;

    ieee_trap_conds = ieee_exception_test_oux(regs);                    /* test for Xo, Xu, Xx; save flags                      */
    /* Test for Xx with trap enabled; Pgm Chk Data Exception and suppress result if any true   */
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMX);

}
#endif /*defined(FEATURE_ESAME)*/

/*-------------------------------------------------------------------*/
/* B34D DXBR  - DIVIDE (extended BFP)                          [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(divide_bfp_ext_reg)
{
    int r1, r2;
    float128_t op1, op2, ans;
    U32 ieee_trap_conds = 0;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    BFPREGPAIR2_CHECK(r1, r2, regs);
    GET_FLOAT128_OPS( op1, r1, op2, r2, regs );

    softfloat_exceptionFlags = 0;               /* clear all Softfloat exceptions  */
    SET_SF_RM_FROM_FPC;                         /* set rounding mode from FPC      */
    ans = f128_div( op1, op2 );

    if (softfloat_exceptionFlags)           /* any IEEE exceptions from Softfloat?  */
    {
        IEEE_EXCEPTION_TRAP_XI(regs);       /* Xi trap suppresses result, no return  */
        IEEE_EXCEPTION_TRAP_XZ(regs);       /* Xz trap suppresses result, no return  */
        ieee_trap_conds = ieee_exception_test_oux(regs);  /* test for overflow, underflow, inexact, save result  */
    };

    PUT_FLOAT128_NOCC(ans, r1, regs);       /* Store result from Divide; condition code not set */

    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */

}

/*-------------------------------------------------------------------*/
/* B31D DDBR  - DIVIDE (long BFP)                              [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(divide_bfp_long_reg)
{
    int r1, r2;
    float64_t op1, op2, ans;
    U32 ieee_trap_conds = 0;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    GET_FLOAT64_OPS( op1, r1, op2, r2, regs );

    softfloat_exceptionFlags = 0;               /* clear all Softfloat exceptions  */
    SET_SF_RM_FROM_FPC;                         /* set rounding mode from FPC      */
    ans = f64_div( op1, op2 );

    if (softfloat_exceptionFlags)           /* any IEEE exceptions from Softfloat?  */
    {
        IEEE_EXCEPTION_TRAP_XI(regs);       /* Xi trap suppresses result, no return  */
        IEEE_EXCEPTION_TRAP_XZ(regs);       /* Xz trap suppresses result, no return  */
        ieee_trap_conds = ieee_exception_test_oux(regs);  /* test for overflow, underflow, inexact, save result  */
    };

    PUT_FLOAT64_NOCC(ans, r1, regs);        /* Store result from Divide; condition code not set */

    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */

}

/*-------------------------------------------------------------------*/
/* ED1D DDB   - DIVIDE (long BFP)                              [RXE] */
/*-------------------------------------------------------------------*/
DEF_INST(divide_bfp_long)
{
    int r1, b2;
    VADR effective_addr2;
    float64_t op1, op2, ans;
    U32 ieee_trap_conds = 0;

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);
    GET_FLOAT64_OP( op1, r1, regs );
    VFETCH_FLOAT64_OP( op2, effective_addr2, b2, regs );

    softfloat_exceptionFlags = 0;               /* clear all Softfloat exceptions  */
    SET_SF_RM_FROM_FPC;                         /* set rounding mode from FPC      */
    ans = f64_div(op1, op2);

    if (softfloat_exceptionFlags)           /* any IEEE exceptions from Softfloat?  */
    {
        IEEE_EXCEPTION_TRAP_XI(regs);       /* Xi trap suppresses result, no return  */
        IEEE_EXCEPTION_TRAP_XZ(regs);       /* Xz trap suppresses result, no return  */
        ieee_trap_conds = ieee_exception_test_oux(regs);  /* test for overflow, underflow, inexact, save result  */
    };

    PUT_FLOAT64_NOCC(ans, r1, regs);        /* Store result from Divide; condition code not set */

    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */
}

/*-------------------------------------------------------------------*/
/* B30D DEBR  - DIVIDE (short BFP)                             [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(divide_bfp_short_reg)
{
    int r1, r2;
    float32_t op1, op2, ans;
    U32 ieee_trap_conds = 0;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    GET_FLOAT32_OPS( op1, r1, op2, r2, regs );

    softfloat_exceptionFlags = 0;               /* clear all Softfloat exceptions  */
    SET_SF_RM_FROM_FPC;                         /* set rounding mode from FPC      */
    ans = f32_div( op1, op2 );

    if (softfloat_exceptionFlags)           /* any IEEE exceptions from Softfloat?  */
    {
        IEEE_EXCEPTION_TRAP_XI(regs);       /* Xi trap suppresses result, no return  */
        IEEE_EXCEPTION_TRAP_XZ(regs);       /* Xz trap suppresses result, no return  */
        ieee_trap_conds = ieee_exception_test_oux(regs);  /* test for overflow, underflow, inexact, save result  */
    };

    PUT_FLOAT32_NOCC(ans, r1, regs);        /* Store result from Divide; condition code not set */

    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */
}

/*-------------------------------------------------------------------*/
/* ED0D DEB   - DIVIDE (short BFP)                             [RXE] */
/*-------------------------------------------------------------------*/
DEF_INST(divide_bfp_short)
{
    int r1, b2;
    VADR effective_addr2;
    float32_t op1, op2, ans;
    U32 ieee_trap_conds = 0;

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);
    GET_FLOAT32_OP( op1, r1, regs );
    VFETCH_FLOAT32_OP( op2, effective_addr2, b2, regs );

    softfloat_exceptionFlags = 0;               /* clear all Softfloat exceptions  */
    SET_SF_RM_FROM_FPC;                         /* set rounding mode from FPC      */
    ans = f32_div(op1, op2);

    if (softfloat_exceptionFlags)           /* any IEEE exceptions from Softfloat?  */
    {
        IEEE_EXCEPTION_TRAP_XI(regs);       /* Xi trap suppresses result, no return  */
        IEEE_EXCEPTION_TRAP_XZ(regs);       /* Xz trap suppresses result, no return  */
        ieee_trap_conds = ieee_exception_test_oux(regs);  /* test for overflow, underflow, inexact, save result  */
    };

    PUT_FLOAT32_NOCC(ans, r1, regs);        /* Store result from Divide; condition code not set */

    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */
}


/*-------------------------------------------------------------------*/
/* B342 LTXBR - LOAD AND TEST (extended BFP)                   [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(load_and_test_bfp_ext_reg)
{
    int r1, r2;
    float128_t op;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    BFPREGPAIR2_CHECK(r1, r2, regs);
    GET_FLOAT128_OP( op, r2, regs );

    if (FLOAT128_ISNAN(op))                             /* Testing needed only if NaN is input      */
    {
        if (f128_isSignalingNaN(op))                    /* Signalling NaN?                          */
            if (regs->fpc & FPC_MASK_IMI)               /* ..yes, is trapping enabled?              */
                ieee_trap(regs, DXC_IEEE_INVALID_OP);   /* ..yes, raise DXC, no return              */
            else
            {                                           /* ..no, change SNaN to QNaN and set flag   */
                regs->fpc |= FPC_FLAG_SFI;
                FLOAT128_MAKE_QNAN(op);
            }
    }

    PUT_FLOAT128_CC( op, r1, regs );
}

/*-------------------------------------------------------------------*/
/* B312 LTDBR - LOAD AND TEST (long BFP)                       [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(load_and_test_bfp_long_reg)
{
    int r1, r2;
    float64_t op;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    GET_FLOAT64_OP( op, r2, regs );

    if (FLOAT64_ISNAN(op))                              /* Testing needed only if NaN is input      */
    {
        if (f64_isSignalingNaN(op))                     /* Signalling NaN?                          */
            if (regs->fpc & FPC_MASK_IMI)               /* ..yes, is trapping enabled?              */
                ieee_trap(regs, DXC_IEEE_INVALID_OP);   /* ..yes, raise DXC, no return              */
            else
            {                                           /* ..no, change SNaN to QNaN and set flag   */
                regs->fpc |= FPC_FLAG_SFI;
                FLOAT64_MAKE_QNAN(op);
            }
    }

    PUT_FLOAT64_CC(op, r1, regs);
}

/*-------------------------------------------------------------------*/
/* B302 LTEBR - LOAD AND TEST (short BFP)                      [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(load_and_test_bfp_short_reg)
{
    int r1, r2;
    float32_t op;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    GET_FLOAT32_OP( op, r2, regs );

    if (FLOAT32_ISNAN(op))                              /* Testing needed only if NaN is input      */
    {
        if (f32_isSignalingNaN(op))                     /* Signalling NaN?                          */
            if (regs->fpc & FPC_MASK_IMI)               /* ..yes, is trapping enabled?              */
                ieee_trap(regs, DXC_IEEE_INVALID_OP);   /* ..yes, raise DXC, no return              */
            else
            {                                           /* ..no, change SNaN to QNaN and set invalid flag   */
                regs->fpc |= FPC_FLAG_SFI;
                FLOAT32_MAKE_QNAN(op);
            }
    }

    PUT_FLOAT32_CC( op, r1, regs );
}

/*-------------------------------------------------------------------*/
/* B357 FIEBR - LOAD FP INTEGER (short BFP)                    [RRF] */
/*-------------------------------------------------------------------*/
DEF_INST(load_fp_int_bfp_short_reg)
{
    int r1, r2;
    BYTE m3, m4;
    float32_t op;
    U32 ieee_trap_conds = 0;

#if defined(FEATURE_FLOATING_POINT_EXTENSION_FACILITY)
    RRF_MM(inst, regs, r1, r2, m3, m4);
#else
    RRF_M(inst, regs, r1, r2, m3);
    m4 = 0;
#endif

    BFPINST_CHECK(regs);
    BFPRM_CHECK(m3,regs);

    GET_FLOAT32_OP( op, r2, regs );

    softfloat_exceptionFlags = 0;
    SET_SF_RM_FROM_M3(m3);            /* Set Softfloat rounding mode from M3 or FPC if M3 = 0  */
    op = f32_roundToInt(op, softfloat_roundingMode, !SUPPRESS_INEXACT(m4) );

    IEEE_EXCEPTION_TRAP_XI(regs);                       /* Softfloat returns Xi and QNaN   if operand is an SNaN  */
    PUT_FLOAT32_NOCC( op, r1, regs );

    if (softfloat_exceptionFlags)                   /* Inexact or non-trapped invalid exceptions?  */
    {                                               /* ..yes, set FPC flags and test for Xx trap   */
        ieee_trap_conds = ieee_exception_test_oux(regs);           /* test for overflow, underflow, inexact, save flags  */
        IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMX);   /* taxe Xx trap if inexact detected  */
    }
}

/*-------------------------------------------------------------------*/
/* B35F FIDBR - LOAD FP INTEGER (long BFP)                     [RRF] */
/*-------------------------------------------------------------------*/
DEF_INST(load_fp_int_bfp_long_reg)
{
    int r1, r2;
    BYTE m3, m4;
    float64_t op;
    U32 ieee_trap_conds = 0;

#if defined(FEATURE_FLOATING_POINT_EXTENSION_FACILITY)
    RRF_MM(inst, regs, r1, r2, m3, m4);
#else
    RRF_M(inst, regs, r1, r2, m3);
    m4 = 0;
#endif    BFPINST_CHECK(regs);

    BFPRM_CHECK(m3,regs);
    GET_FLOAT64_OP( op, r2, regs );

    softfloat_exceptionFlags = 0;
    SET_SF_RM_FROM_M3(m3);            /* Set Softfloat rounding mode from M3 or FPC if M3 = 0  */
    op = f64_roundToInt(op, softfloat_roundingMode, !SUPPRESS_INEXACT(m4) );

    IEEE_EXCEPTION_TRAP_XI(regs);                       /* Softfloat returns Xi and QNaN   if operand is an SNaN  */
    PUT_FLOAT64_NOCC(op, r1, regs);

    if (softfloat_exceptionFlags)                   /* Inexact or non-trapped invalid exceptions?  */
    {                                               /* ..yes, set FPC flags and test for Xx trap   */
        ieee_trap_conds = ieee_exception_test_oux(regs);            /* test for overflow, underflow, inexact, save flags  */
        IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMX);   /* taxe Xx trap if inexact detected  */
    }

}

/*-------------------------------------------------------------------*/
/* B347 FIXBR - LOAD FP INTEGER (extended BFP)                 [RRF] */
/*-------------------------------------------------------------------*/
DEF_INST(load_fp_int_bfp_ext_reg)
{
    int r1, r2; 
    BYTE m3, m4;
    float128_t op;
    U32 ieee_trap_conds = 0;

#if defined(FEATURE_FLOATING_POINT_EXTENSION_FACILITY)
    RRF_MM(inst, regs, r1, r2, m3, m4);
#else
    RRF_M(inst, regs, r1, r2, m3);
    m4 = 0;
#endif    BFPINST_CHECK(regs);

    BFPINST_CHECK(regs);
    BFPREGPAIR2_CHECK(r1, r2, regs);
    BFPRM_CHECK(m3,regs);
    GET_FLOAT128_OP( op, r2, regs );

    softfloat_exceptionFlags = 0;
    SET_SF_RM_FROM_M3(m3);            /* Set Softfloat rounding mode from M3 or FPC if M3 = 0  */
    op = f128_roundToInt(op, softfloat_roundingMode, !SUPPRESS_INEXACT(m4) );

    IEEE_EXCEPTION_TRAP_XI(regs);                       /* Softfloat returns Xi and QNaN   if operand is an SNaN  */
    PUT_FLOAT128_NOCC(op, r1, regs);

    if (softfloat_exceptionFlags)                   /* Inexact or non-trapped invalid exceptions?  */
    {                                               /* ..yes, set FPC flags and test for Xx trap   */
        ieee_trap_conds = ieee_exception_test_oux(regs);            /* test for overflow, underflow, inexact, save flags  */
        IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMX);   /* taxe Xx trap if inexact detected  */
    }
}


/*-------------------------------------------------------------------*/
/* Load Lengthened                                                   */
/*                                                                   */
/* IBM expects SNaNs to raise the IEEE Invalid exception, to         */
/* suppress the result if the exception is trapped, and to make the  */
/* SNaN a QNaN if the exception is not trapped.  (Table 19-17 on     */
/* page 19-21 of SA22-7832-10.)                                      */
/*                                                                   */
/* Softfloat 3a never raises invalid in the routines that increase   */
/* the width of floating point values, nor does it make QNaNs of     */
/* SNaNs.                                                            */
/*-------------------------------------------------------------------*/

/*-------------------------------------------------------------------*/
/* B304 LDEBR - LOAD LENGTHENED (short to long BFP)            [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(load_lengthened_bfp_short_to_long_reg)
{
    int r1, r2;
    float32_t op2;
    float64_t op1;
    
    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    GET_FLOAT32_OP( op2, r2, regs );

    if (f32_isSignalingNaN(op2))
    {
        softfloat_exceptionFlags = softfloat_flag_invalid;  /* indicate IEEE Invalid exception      */
        IEEE_EXCEPTION_TRAP_XI(regs);                       /* no return if exception is trappable  */
        FLOAT32_MAKE_QNAN(op2);                             /* make the SNaN input a QNaN           */
        SET_FPC_FLAGS_FROM_SF(regs);                        /* not trapped; set FPC flag            */
    }
    
    op1 = f32_to_f64(op2);
    PUT_FLOAT64_NOCC( op1, r1, regs );

}

/*-------------------------------------------------------------------*/
/* ED04 LDEB  - LOAD LENGTHENED (short to long BFP)            [RXE] */
/*-------------------------------------------------------------------*/
DEF_INST(load_lengthened_bfp_short_to_long)
{
    int r1, b2;
    VADR effective_addr2;
    float32_t op2;
    float64_t op1;

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);
    VFETCH_FLOAT32_OP( op2, effective_addr2, b2, regs );

    if (f32_isSignalingNaN(op2))
    {
        softfloat_exceptionFlags = softfloat_flag_invalid;  /* indicate IEEE Invalid exception      */
        IEEE_EXCEPTION_TRAP_XI(regs);                       /* no return if exception is trappable  */
        FLOAT32_MAKE_QNAN(op2);                             /* make the SNaN input a QNaN           */
        SET_FPC_FLAGS_FROM_SF(regs);                        /* not trapped; set FPC flag            */
    }

    op1 = f32_to_f64( op2 );
    PUT_FLOAT64_NOCC( op1, r1, regs );
}

/*-------------------------------------------------------------------*/
/* B305 LXDBR - LOAD LENGTHENED (long to extended BFP)         [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(load_lengthened_bfp_long_to_ext_reg)
{
    int r1, r2;
    float64_t op2;
    float128_t op1;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    BFPREGPAIR_CHECK(r1, regs);
    GET_FLOAT64_OP( op2, r2, regs );

    if (f64_isSignalingNaN(op2))
    {
        softfloat_exceptionFlags = softfloat_flag_invalid;  /* indicate IEEE Invalid exception      */
        IEEE_EXCEPTION_TRAP_XI(regs);                       /* no return if exception is trappable  */
        FLOAT64_MAKE_QNAN(op2);                             /* make the SNaN input a QNaN           */
        SET_FPC_FLAGS_FROM_SF(regs);                        /* not trapped; set FPC flag            */
    }

    op1 = f64_to_f128( op2 );
    PUT_FLOAT128_NOCC( op1, r1, regs );
}

/*-------------------------------------------------------------------*/
/* ED05 LXDB  - LOAD LENGTHENED (long to extended BFP)         [RXE] */
/*-------------------------------------------------------------------*/
DEF_INST(load_lengthened_bfp_long_to_ext)
{
    int r1, b2;
    VADR effective_addr2;
    float64_t op2;
    float128_t op1;

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);
    BFPREGPAIR_CHECK(r1, regs);
    VFETCH_FLOAT64_OP( op2, effective_addr2, b2, regs );

    if (f64_isSignalingNaN(op2))
    {
        softfloat_exceptionFlags = softfloat_flag_invalid;  /* indicate IEEE Invalid exception      */
        IEEE_EXCEPTION_TRAP_XI(regs);                       /* no return if exception is trappable  */
        FLOAT64_MAKE_QNAN(op2);                              /* make the SNaN input a QNaN           */
        SET_FPC_FLAGS_FROM_SF(regs);                        /* not trapped; set FPC flag            */
    }

    op1 = f64_to_f128( op2 );
    PUT_FLOAT128_NOCC( op1, r1, regs );
}

/*-------------------------------------------------------------------*/
/* B306 LXEBR - LOAD LENGTHENED (short to extended BFP)        [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(load_lengthened_bfp_short_to_ext_reg)
{
    int r1, r2;
    float32_t op2;
    float128_t op1;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    BFPREGPAIR_CHECK(r1, regs);
    GET_FLOAT32_OP( op2, r2, regs );

    if (f32_isSignalingNaN(op2))
    {
        softfloat_exceptionFlags = softfloat_flag_invalid;  /* indicate IEEE Invalid exception      */
        IEEE_EXCEPTION_TRAP_XI(regs);                       /* no return if exception is trappable  */
        FLOAT32_MAKE_QNAN(op2);                             /* make the SNaN input a QNaN           */
        SET_FPC_FLAGS_FROM_SF(regs);                        /* not trapped; set FPC flag            */
    }

    op1 = f32_to_f128( op2 );
    PUT_FLOAT128_NOCC( op1, r1, regs );
}

/*-------------------------------------------------------------------*/
/* ED06 LXEB  - LOAD LENGTHENED (short to extended BFP)        [RXE] */
/*-------------------------------------------------------------------*/
DEF_INST(load_lengthened_bfp_short_to_ext)
{
    int r1, b2;
    VADR effective_addr2;
    float32_t op2;
    float128_t op1;

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);
    BFPREGPAIR_CHECK(r1, regs);
    VFETCH_FLOAT32_OP( op2, effective_addr2, b2, regs );

    if (f32_isSignalingNaN(op2))
    {
        softfloat_exceptionFlags = softfloat_flag_invalid;  /* indicate IEEE Invalid exception      */
        IEEE_EXCEPTION_TRAP_XI(regs);                       /* no return if exception is trappable  */
        FLOAT32_MAKE_QNAN(op2);                             /* make the SNaN input a QNaN           */
        SET_FPC_FLAGS_FROM_SF(regs);                        /* not trapped; set FPC flag            */
    }

    op1 = f32_to_f128( op2 );
    PUT_FLOAT128_NOCC( op1, r1, regs );
}

/*-------------------------------------------------------------------*/
/* B341 LNXBR - LOAD NEGATIVE (extended BFP)                   [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(load_negative_bfp_ext_reg)
{
    int r1, r2;
    float128_t op;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    BFPREGPAIR2_CHECK(r1, r2, regs);

    GET_FLOAT128_OP( op, r2, regs );
    op.v[1] |= 0x8000000000000000ULL;
    PUT_FLOAT128_CC( op, r1, regs );
}

/*-------------------------------------------------------------------*/
/* B311 LNDBR - LOAD NEGATIVE (long BFP)                       [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(load_negative_bfp_long_reg)
{
    int r1, r2;
    float64_t op;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);

    GET_FLOAT64_OP( op, r2, regs );
    op.v |= 0x8000000000000000ULL;
    PUT_FLOAT64_CC( op, r1, regs );
}

/*-------------------------------------------------------------------*/
/* B301 LNEBR - LOAD NEGATIVE (short BFP)                      [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(load_negative_bfp_short_reg)
{
    int r1, r2;
    float32_t op;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);

    GET_FLOAT32_OP( op, r2, regs );
    op.v |= 0x80000000;
    PUT_FLOAT32_CC( op, r1, regs );
}

/*-------------------------------------------------------------------*/
/* B343 LCXBR - LOAD COMPLEMENT (extended BFP)                 [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(load_complement_bfp_ext_reg)
{
    int r1, r2;
    float128_t op;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    BFPREGPAIR2_CHECK(r1, r2, regs);

    GET_FLOAT128_OP( op, r2, regs );
    op.v[1] ^= 0x8000000000000000ULL;
    PUT_FLOAT128_CC( op, r1, regs );
}

/*-------------------------------------------------------------------*/
/* B313 LCDBR - LOAD COMPLEMENT (long BFP)                     [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(load_complement_bfp_long_reg)
{
    int r1, r2;
    float64_t op;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);

    GET_FLOAT64_OP( op, r2, regs );
    op.v ^= 0x8000000000000000ULL;
    PUT_FLOAT64_CC( op, r1, regs );
}

/*-------------------------------------------------------------------*/
/* B303 LCEBR - LOAD COMPLEMENT (short BFP)                    [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(load_complement_bfp_short_reg)
{
    int r1, r2;
    float32_t op;
    
    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);

    GET_FLOAT32_OP( op, r2, regs );
    op.v ^= 0x80000000;
    PUT_FLOAT32_CC( op, r1, regs );
}

/*-------------------------------------------------------------------*/
/* B340 LPXBR - LOAD POSITIVE (extended BFP)                   [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(load_positive_bfp_ext_reg)
{
    int r1, r2;
    float128_t op;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    BFPREGPAIR2_CHECK(r1, r2, regs);

    GET_FLOAT128_OP( op, r2, regs );
    op.v[1] &= ~0x8000000000000000ULL;
    PUT_FLOAT128_CC( op, r1, regs );
}

/*-------------------------------------------------------------------*/
/* B310 LPDBR - LOAD POSITIVE (long BFP)                       [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(load_positive_bfp_long_reg)
{
    int r1, r2;
    float64_t op;
    
    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);

    GET_FLOAT64_OP( op, r2, regs );
    op.v  &= ~0x8000000000000000ULL;
    PUT_FLOAT64_CC( op, r1, regs );
}

/*-------------------------------------------------------------------*/
/* B300 LPEBR - LOAD POSITIVE (short BFP)                      [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(load_positive_bfp_short_reg)
{
    int r1, r2;
    float32_t op;
    
    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);

    GET_FLOAT32_OP( op, r2, regs );
    op.v &= ~0x80000000;
    PUT_FLOAT32_CC( op, r1, regs );
}

/*----------------------------------------------------------------------*/
/* Load Rounded                                                         */
/*                                                                      */
/* IBM expects SNaNs to raise the IEEE Invalid exception, to            */
/* suppress the result if the exception is trapped, and to make the     */
/* SNaN a QNaN if the exception is not trapped.  (Table 19-17 on        */
/* page 19-21 of SA22-7832-10.)                                         */
/*                                                                      */
/* Softfloat 3a never raises invalid in the routines that decrease      */
/* the width of floating point values, nor does it make QNaNs of        */
/* SNaNs.                                                               */
/*                                                                      */
/* A bigger "gotcha" is the behavior IBM defines when overflow or       */
/* underflow exceptions occur and are trappable.  IBM expects the       */
/* input value, rounded to the target precision but maintained in       */
/* the input precision, to be placed in the result before taking        */
/* trap.  Softfloat does not support this; we must do it ourselves      */
/*                                                                      */
/*----------------------------------------------------------------------*/

/*----------------------------------------------------------------------*/
/* B344 LEDBR  - LOAD ROUNDED (long to short BFP)               [RRE]   */
/* B344 LEDBRA - LOAD ROUNDED (long to short BFP)               [RRF-e] */
/*----------------------------------------------------------------------*/
DEF_INST(load_rounded_bfp_long_to_short_reg)
{
    int r1, r2;
    BYTE m3, m4;
    float64_t op2;
    float32_t op1;
    U32 ieee_trap_conds = 0;

    RRF_MM(inst, regs, r1, r2, m3, m4);
    BFPINST_CHECK(regs);
    GET_FLOAT64_OP( op2, r2, regs );

#if defined(FEATURE_FPS_EXTENSIONS)
    SET_SF_RM_FROM_M3(m3);
#else
    if (m3 || m4)
        regs->program_interrupt(regs, PGM_SPECIFICATION_EXCEPTION);
    SET_SF_RM_FROM_FPC;
#endif

    softfloat_exceptionFlags = 0;
    op1 = f64_to_f32( op2 );
    
#if defined(FEATURE_FPS_EXTENSIONS)
    if (SUPPRESS_INEXACT(m4))
        softfloat_exceptionFlags &= ~softfloat_flag_inexact;    /* suppress inexact if required  */
#endif

    if (f32_isSignalingNaN(op1))
    {
        softfloat_raiseFlags(softfloat_flag_invalid);       /* indicate IEEE Invalid exception      */
        IEEE_EXCEPTION_TRAP_XI(regs);                       /* no return if exception is trappable  */
        FLOAT32_MAKE_QNAN(op1);                             /* make the SNaN input a QNaN           */
    }

    IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);
    PUT_FLOAT32_NOCC( op1, r1, regs );

    /* ********** NEED TO FIGURE OUT TRAPPABLE Xo & Xu PROCESSING HERE ********** */
    /* ********** must return input format rounded to target precision ********** */
    
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */

}

/*----------------------------------------------------------------------*/
/* B345 LDXBR  - LOAD ROUNDED (extended to long BFP)            [RRE]   */
/* B345 LDXBRA - LOAD ROUNDED (extended to long BFP)            [RRF-e] */
/*----------------------------------------------------------------------*/
DEF_INST(load_rounded_bfp_ext_to_long_reg)
{
    int r1, r2;
    BYTE m3, m4;
    float128_t op2;
    float64_t op1;
    U32 ieee_trap_conds = 0;

    RRF_MM(inst, regs, r1, r2, m3, m4);

    BFPINST_CHECK(regs);
    BFPREGPAIR2_CHECK(r1, r2, regs);
    GET_FLOAT128_OP( op2, r2, regs );

#if defined(FEATURE_FPS_EXTENSIONS)
    SET_SF_RM_FROM_M3(m3);
#else
    if (m3 || m4)
        regs->program_interrupt(regs, PGM_SPECIFICATION_EXCEPTION);
    SET_SF_RM_FROM_FPC;
#endif

    softfloat_exceptionFlags = 0;
    op1 = f128_to_f64( op2 );

#if defined(FEATURE_FPS_EXTENSIONS)
    if (SUPPRESS_INEXACT(m4))
        softfloat_exceptionFlags &= ~softfloat_flag_inexact;    /* suppress inexact if required  */
#endif

    if (f64_isSignalingNaN(op1))
    {
        softfloat_raiseFlags(softfloat_flag_invalid);       /* indicate IEEE Invalid exception      */
        IEEE_EXCEPTION_TRAP_XI(regs);                       /* no return if exception is trappable  */
        FLOAT64_MAKE_QNAN(op1);                             /* make the SNaN input a QNaN           */
    }

    IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);
    PUT_FLOAT64_NOCC(op1, r1, regs);

    /* ********** NEED TO FIGURE OUT TRAPPABLE Xo & Xu PROCESSING HERE ********** */
    /* ********** must return input format rounded to target precision ********** */

    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */

}

/*----------------------------------------------------------------------*/
/* B346 LEXBR  - LOAD ROUNDED (extended to short BFP)           [RRE]   */
/* B346 LEXBRA - LOAD ROUNDED (extended to short BFP)           [RRF-e] */
/*-----------------------------------------------------------------------*/
DEF_INST(load_rounded_bfp_ext_to_short_reg)
{
    int r1, r2;
    BYTE m3, m4;
    float128_t op2;
    float32_t op1;
    U32 ieee_trap_conds = 0;

    RRF_MM(inst, regs, r1, r2, m3, m4);

    BFPINST_CHECK(regs);
    BFPREGPAIR2_CHECK(r1, r2, regs);
    GET_FLOAT128_OP( op2, r2, regs );

#if defined(FEATURE_FPS_EXTENSIONS)
    SET_SF_RM_FROM_M3(m3);
#else
    if (m3 || m4)
        regs->program_interrupt(regs, PGM_SPECIFICATION_EXCEPTION);
    SET_SF_RM_FROM_FPC;
#endif

    softfloat_exceptionFlags = 0;
    op1 = f128_to_f32(op2);

#if defined(FEATURE_FPS_EXTENSIONS)
    if (SUPPRESS_INEXACT(m4))
        softfloat_exceptionFlags &= ~softfloat_flag_inexact;    /* suppress inexact if required  */
#endif

    if (f32_isSignalingNaN(op1))
    {
        softfloat_raiseFlags(softfloat_flag_invalid);       /* indicate IEEE Invalid exception      */
        IEEE_EXCEPTION_TRAP_XI(regs);                       /* no return if exception is trappable  */
        FLOAT32_MAKE_QNAN(op1);                             /* make the SNaN input a QNaN           */
    }

    IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);
    PUT_FLOAT32_NOCC(op1, r1, regs);

    /* ********** NEED TO FIGURE OUT TRAPPABLE Xo & Xu PROCESSING HERE ********** */
    /* ********** must return input format rounded to target precision ********** */

    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */


}

/*-------------------------------------------------------------------*/
/* B34C MXBR  - MULTIPLY (extended BFP)                        [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(multiply_bfp_ext_reg)
{
    int r1, r2;
    float128_t op1, op2, ans;
    U32 ieee_trap_conds = 0;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    BFPREGPAIR2_CHECK(r1, r2, regs);
    GET_FLOAT128_OPS( op1, r1, op2, r2, regs );
    
    softfloat_exceptionFlags = 0;
    ans = f128_mul( op1, op2 );

    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);
    }
    
    PUT_FLOAT128_NOCC( ans, r1, regs );
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */

}

/*--------------------------------------------------------------------------*/
/* B307 MXDBR - MULTIPLY (long to extended BFP)                [RRE]        */
/*                                                                          */
/* Because the operation result is in a longer format than the operands,    */
/* IEEE exceptions Overflow, Underflow, and Inexact cannot occur.  An SNaN  */
/* will still generate Invalid.                                             */
/*                                                                          */
/* This emulation depends on Softfloat f64_to_f128() passing SNaNs and      */
/* QNaNs without change and without exceptions.  3a works this way.         */
/*--------------------------------------------------------------------------*/
DEF_INST(multiply_bfp_long_to_ext_reg)
{
    int r1, r2;
    float64_t op1, op2;
    float128_t iop1, iop2, ans;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    BFPREGPAIR_CHECK(r1, regs);
    GET_FLOAT64_OPS( op1, r1, op2, r2, regs );

    iop1 = f64_to_f128( op1 );
    iop2 = f64_to_f128( op2 );
    softfloat_exceptionFlags = 0;
    ans = f128_mul( iop1, iop2 );
    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        SET_FPC_FLAGS_FROM_SF(regs);
    }

    PUT_FLOAT128_NOCC( ans, r1, regs );

}

/*--------------------------------------------------------------------------*/
/* ED07 MXDB  - MULTIPLY (long to extended BFP)                [RXE]        */
/*                                                                          */
/* Because the operation result is in a longer format than the operands,    */
/* IEEE exceptions Overflow, Underflow, and Inexact cannot occur.  An SNaN  */
/* will still generate Invalid.                                             */
/*                                                                          */
/* This emulation depends on Softfloat f64_to_f128() passing SNaNs and      */
/* QNaNs without change and without exceptions.  3a works this way.         */
/*--------------------------------------------------------------------------*/
DEF_INST(multiply_bfp_long_to_ext)
{
    int r1, b2;
    VADR effective_addr2;
    float64_t op1, op2;
    float128_t iop1, iop2, ans;

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);
    BFPREGPAIR_CHECK(r1, regs);
    GET_FLOAT64_OP( op1, r1, regs );
    VFETCH_FLOAT64_OP( op2, effective_addr2, b2, regs );

    iop1 = f64_to_f128( op1 );
    iop2 = f64_to_f128( op2 );
    softfloat_exceptionFlags = 0;
    ans = f128_mul( iop1, iop2 );

    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        SET_FPC_FLAGS_FROM_SF(regs);
    }
    PUT_FLOAT128_NOCC( ans, r1, regs );
}

/*-------------------------------------------------------------------*/
/* B31C MDBR  - MULTIPLY (long BFP)                            [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(multiply_bfp_long_reg)
{
    int r1, r2;
    float64_t op1, op2, ans;
    U32 ieee_trap_conds =0;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    GET_FLOAT64_OPS( op1, r1, op2, r2, regs );
    
    softfloat_exceptionFlags = 0;
    ans = f64_mul( op1, op2 );

    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);
    }

    PUT_FLOAT64_NOCC(ans, r1, regs);
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */

}

/*-------------------------------------------------------------------*/
/* ED1C MDB   - MULTIPLY (long BFP)                            [RXE] */
/*-------------------------------------------------------------------*/
DEF_INST(multiply_bfp_long)
{
    int r1, b2;
    VADR effective_addr2;
    float64_t op1, op2, ans;
    U32 ieee_trap_conds =0;

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);
    GET_FLOAT64_OP( op1, r1, regs );
    VFETCH_FLOAT64_OP( op2, effective_addr2, b2, regs );

    softfloat_exceptionFlags = 0;
    ans = f64_mul(op1, op2);

    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);
    }

    PUT_FLOAT64_NOCC(ans, r1, regs);
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */
}

/*--------------------------------------------------------------------------*/
/* B30C MDEBR - MULTIPLY (short to long BFP)                   [RRE]        */
/*                                                                          */
/* Because the operation result is in a longer format than the operands,    */
/* IEEE exceptions Overflow, Underflow, and Inexact cannot occur.  An SNaN  */
/* will still generate Invalid.                                             */
/*                                                                          */
/* This emulation depends on Softfloat f64_to_f128() passing SNaNs and      */
/* QNaNs without change and without exceptions.  3a works this way.         */
/*--------------------------------------------------------------------------*/
DEF_INST(multiply_bfp_short_to_long_reg)
{
    int r1, r2;
    float32_t op1, op2;
    float64_t iop1, iop2, ans;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    GET_FLOAT32_OPS( op1, r1, op2, r2, regs );

    iop1 = f32_to_f64( op1 );
    iop2 = f32_to_f64( op2 );
    softfloat_exceptionFlags = 0;
    ans = f64_mul( iop1, iop2 );
    
    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        SET_FPC_FLAGS_FROM_SF(regs);
    }
    PUT_FLOAT64_NOCC(ans, r1, regs);

}

/*--------------------------------------------------------------------------*/
/* ED0C MDEB  - MULTIPLY (short to long BFP)                   [RXE]        */
/*                                                                          */
/* Because the operation result is in a longer format than the operands,    */
/* IEEE exceptions Overflow, Underflow, and Inexact cannot occur.  An SNaN  */
/* will still generate Invalid.                                             */
/*                                                                          */
/* This emulation depends on Softfloat f64_to_f128() passing SNaNs and      */
/* QNaNs without change and without exceptions.  3a works this way.         */
/*--------------------------------------------------------------------------*/
DEF_INST(multiply_bfp_short_to_long)
{
    int r1, b2;
    VADR effective_addr2;
    float32_t op1, op2;
    float64_t iop1, iop2, ans;

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);
    GET_FLOAT32_OP( op1, r1, regs );
    VFETCH_FLOAT32_OP( op2, effective_addr2, b2, regs );

    iop1 = f32_to_f64(op1);
    iop2 = f32_to_f64(op2);
    softfloat_exceptionFlags = 0;
    ans = f64_mul(iop1, iop2);

    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        SET_FPC_FLAGS_FROM_SF(regs);
    }

    PUT_FLOAT64_NOCC( ans, r1, regs );

}

/*-------------------------------------------------------------------*/
/* B317 MEEBR - MULTIPLY (short BFP)                           [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(multiply_bfp_short_reg)
{
    int r1, r2;
    float32_t op1, op2, ans;
    U32 ieee_trap_conds =0;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    GET_FLOAT32_OPS( op1, r1, op2, r2, regs );

    softfloat_exceptionFlags = 0;
    ans = f32_mul( op1, op2 );

    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);
    }

    PUT_FLOAT32_NOCC(ans, r1, regs);
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */
}

/*-------------------------------------------------------------------*/
/* ED17 MEEB  - MULTIPLY (short BFP)                           [RXE] */
/*-------------------------------------------------------------------*/
DEF_INST(multiply_bfp_short)
{
    int r1, b2;
    VADR effective_addr2;
    float32_t op1, op2, ans;
    U32 ieee_trap_conds =0;

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);
    GET_FLOAT32_OP( op1, r1, regs );
    VFETCH_FLOAT32_OP( op2, effective_addr2, b2, regs );

    softfloat_exceptionFlags = 0;
    ans = f32_mul( op1, op2 );


    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);
    }

    PUT_FLOAT32_NOCC(ans, r1, regs);
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */
}

/*-------------------------------------------------------------------*/
/* B31E MADBR - MULTIPLY AND ADD (long BFP)                    [RRF] */
/*-------------------------------------------------------------------*/
DEF_INST(multiply_add_bfp_long_reg)
{
    int r1, r2, r3;
    float64_t op1, op2, op3, ans;
    U32 ieee_trap_conds =0; 

    RRF_R(inst, regs, r1, r2, r3);
    BFPINST_CHECK(regs);
    GET_FLOAT64_OPS( op1, r1, op3, r3, regs );
    GET_FLOAT64_OP( op2, r2, regs );

    softfloat_exceptionFlags = 0;
    ans = f64_mulAdd(op2, op3, op1);

    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);
    }

    PUT_FLOAT64_NOCC(ans, r1, regs);
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */
}

/*-------------------------------------------------------------------*/
/* ED1E MADB  - MULTIPLY AND ADD (long BFP)                    [RXF] */
/*-------------------------------------------------------------------*/
DEF_INST(multiply_add_bfp_long)
{
    int r1, r3, b2;
    VADR effective_addr2;
    float64_t op1, op2, op3, ans;
    U32 ieee_trap_conds =0;

    RXF(inst, regs, r1, r3, b2, effective_addr2);
    BFPINST_CHECK(regs);

    GET_FLOAT64_OPS( op1, r1, op3, r3, regs );
    VFETCH_FLOAT64_OP( op2, effective_addr2, b2, regs );

    softfloat_exceptionFlags = 0;
    ans = f64_mulAdd(op2, op3, op1);

    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);
    }

    PUT_FLOAT64_NOCC(ans, r1, regs);
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */
}

/*-------------------------------------------------------------------*/
/* B30E MAEBR - MULTIPLY AND ADD (short BFP)                   [RRF] */
/*-------------------------------------------------------------------*/
DEF_INST(multiply_add_bfp_short_reg)
{
    int r1, r2, r3;
    float32_t op1, op2, op3, ans;
    U32 ieee_trap_conds =0;

    RRF_R(inst, regs, r1, r2, r3);
    BFPINST_CHECK(regs);
    GET_FLOAT32_OPS( op1, r1, op3, r3, regs );
    GET_FLOAT32_OP( op2, r2, regs );

    softfloat_exceptionFlags = 0;
    ans = f32_mulAdd(op2, op3, op1);

    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);
    }

    PUT_FLOAT32_NOCC(ans, r1, regs);
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */
}

/*-------------------------------------------------------------------*/
/* ED0E MAEB  - MULTIPLY AND ADD (short BFP)                   [RXF] */
/*-------------------------------------------------------------------*/
DEF_INST(multiply_add_bfp_short)
{
    int r1, r3, b2;
    VADR effective_addr2;
    float32_t op1, op2, op3, ans;
    U32 ieee_trap_conds =0;

    RXF(inst, regs, r1, r3, b2, effective_addr2);
    BFPINST_CHECK(regs);
    GET_FLOAT32_OPS( op1, r1, op3, r3, regs );
    VFETCH_FLOAT32_OP( op2, effective_addr2, b2, regs );

    softfloat_exceptionFlags = 0;
    ans = f32_mulAdd(op2, op3, op1);

    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);
    }

    PUT_FLOAT32_NOCC(ans, r1, regs);
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */

}

/*-------------------------------------------------------------------*/
/* B31F MSDBR - MULTIPLY AND SUBTRACT (long BFP)               [RRF] */
/*-------------------------------------------------------------------*/
DEF_INST(multiply_subtract_bfp_long_reg)
{
    int r1, r2, r3;
    float64_t op1, op2, op3, ans;
    U32 ieee_trap_conds =0;

    RRF_R(inst, regs, r1, r2, r3);
    BFPINST_CHECK(regs);
    GET_FLOAT64_OPS( op1, r1, op3, r3, regs );
    GET_FLOAT64_OP( op2, r2, regs );
    op1.v ^= 0x8000000000000000ULL;         /* invert sign to enable use of f64_MulAdd      */

    softfloat_exceptionFlags = 0;
    ans = f64_mulAdd(op2, op3, op1 );  

    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);
    }

    PUT_FLOAT64_NOCC(ans, r1, regs);
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */
}

/*-------------------------------------------------------------------*/
/* ED1F MSDB  - MULTIPLY AND SUBTRACT (long BFP)               [RXF] */
/*-------------------------------------------------------------------*/
DEF_INST(multiply_subtract_bfp_long)
{
    int r1, r3, b2;
    VADR effective_addr2;
    float64_t op1, op2, op3, ans;
    U32 ieee_trap_conds =0;

    RXF(inst, regs, r1, r3, b2, effective_addr2);
    BFPINST_CHECK(regs);
    GET_FLOAT64_OPS( op1, r1, op3, r3, regs );
    VFETCH_FLOAT64_OP( op2, effective_addr2, b2, regs );
    op1.v ^= 0x8000000000000000ULL;         /* invert sign to enable use of f64_MulAdd      */

    softfloat_exceptionFlags = 0;
    ans = f64_mulAdd(op2, op3, op1);

    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);
    }

    PUT_FLOAT64_NOCC(ans, r1, regs);
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */

}

/*-------------------------------------------------------------------*/
/* B30F MSEBR - MULTIPLY AND SUBTRACT (short BFP)              [RRF] */
/*-------------------------------------------------------------------*/
DEF_INST(multiply_subtract_bfp_short_reg)
{
    int r1, r2, r3;
    float32_t op1, op2, op3, ans;
    U32 ieee_trap_conds =0;

    RRF_R(inst, regs, r1, r2, r3);
    BFPINST_CHECK(regs);
    GET_FLOAT32_OPS( op1, r1, op3, r3, regs );
    GET_FLOAT32_OP( op2, r2, regs );
    op1.v ^= 0x80000000;                    /* invert sign to enable use of f32_MulAdd      */

    softfloat_exceptionFlags = 0;
    ans = f32_mulAdd(op2, op3, op1);

    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);
    }

    PUT_FLOAT32_NOCC(ans, r1, regs);
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */

}

/*-------------------------------------------------------------------*/
/* ED0F MSEB  - MULTIPLY AND SUBTRACT (short BFP)              [RXF] */
/*-------------------------------------------------------------------*/
DEF_INST(multiply_subtract_bfp_short)
{
    int r1, r3, b2;
    VADR effective_addr2;
    float32_t op1, op2, op3, ans;
    U32 ieee_trap_conds = 0;

    RXF(inst, regs, r1, r3, b2, effective_addr2);
    BFPINST_CHECK(regs);
    GET_FLOAT32_OPS( op1, r1, op3, r3, regs );
    VFETCH_FLOAT32_OP( op2, effective_addr2, b2, regs );
    op1.v ^= 0x80000000;                    /* invert sign to enable use of f32_MulAdd      */

    softfloat_exceptionFlags = 0;
    ans = f32_mulAdd(op2, op3, op1);

    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);
    }

    PUT_FLOAT32_NOCC(ans, r1, regs);
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO | FPC_MASK_IMU | FPC_MASK_IMX);   /* take any trap detected  */
}

/*-------------------------------------------------------------------*/
/* B316 SQXBR - SQUARE ROOT (extended BFP)                     [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(squareroot_bfp_ext_reg)
{
    int r1, r2;
    float128_t op1, op2;
    U32 ieee_trap_conds = 0;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    BFPREGPAIR2_CHECK(r1, r2, regs);
    GET_FLOAT128_OP( op2, r2, regs );

    softfloat_exceptionFlags = 0;
    op1 = f128_sqrt( op2 );

    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMX);
    }

    PUT_FLOAT128_NOCC(op1, r1, regs);
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMX);   /* take any trap detected  */
}

/*-------------------------------------------------------------------*/
/* B315 SQDBR - SQUARE ROOT (long BFP)                         [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(squareroot_bfp_long_reg)
{
    int r1, r2;
    float64_t op1, op2;
    U32 ieee_trap_conds = 0;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    GET_FLOAT64_OP( op2, r2, regs );

    softfloat_exceptionFlags = 0;
    op1 = f64_sqrt( op2 );

    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMX);
    }

    PUT_FLOAT64_NOCC(op1, r1, regs);
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMX);   /* take any trap detected  */
}

/*-------------------------------------------------------------------*/
/* ED15 SQDB  - SQUARE ROOT (long BFP)                         [RXE] */
/*-------------------------------------------------------------------*/
DEF_INST(squareroot_bfp_long)
{
    int r1, b2;
    VADR effective_addr2;
    float64_t op1, op2;
    U32 ieee_trap_conds = 0;

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);
    VFETCH_FLOAT64_OP( op2, effective_addr2, b2, regs );

    softfloat_exceptionFlags = 0;
    op1 = f64_sqrt( op2 );

    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMX);
    }

    PUT_FLOAT64_NOCC(op1, r1, regs);
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMX);   /* take any trap detected  */
}

/*-------------------------------------------------------------------*/
/* B314 SQEBR - SQUARE ROOT (short BFP)                        [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(squareroot_bfp_short_reg)
{
    int r1, r2;
    float32_t op1, op2;
    U32 ieee_trap_conds = 0;

    RRE(inst, regs, r1, r2);
    BFPINST_CHECK(regs);
    GET_FLOAT32_OP( op2, r2, regs );

    softfloat_exceptionFlags = 0;
    op1 = f32_sqrt( op2 );

    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMX);
    }

    PUT_FLOAT32_NOCC(op1, r1, regs);
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMX);   /* take any trap detected  */
}

/*-------------------------------------------------------------------*/
/* ED14 SQEB  - SQUARE ROOT (short BFP)                        [RXE] */
/*-------------------------------------------------------------------*/
DEF_INST(squareroot_bfp_short)
{
    int r1, b2;
    VADR effective_addr2;
    float32_t op1, op2;
    U32 ieee_trap_conds = 0;

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);
    VFETCH_FLOAT32_OP( op2, effective_addr2, b2, regs );
    
    softfloat_exceptionFlags = 0;
    op1 = f32_sqrt( op2 );
    
    if (softfloat_exceptionFlags)
    {
        IEEE_EXCEPTION_TRAP_XI(regs);      /* test for trappable Xi, no return if true    */
        IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMX);
    }

    PUT_FLOAT32_NOCC(op1, r1, regs);
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMX);   /* take any trap detected  */

}


/*-------------------------------------------------------------------*/
/* B34B SXBR  - SUBTRACT (extended BFP)                        [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(subtract_bfp_ext_reg)
{
    int r1, r2;
    float128_t op1, op2, ans;
    U32 ieee_trap_conds = 0;                                /* start out with no traps detected                     */

    RRE(inst, regs, r1, r2);                                /* decode operand registers from instruction            */
    BFPINST_CHECK(regs);                                    /* Ensure BPF instructions allowed by CPU State         */
    BFPREGPAIR2_CHECK(r1, r2, regs);                        /* Ensure valide FP register pair for extended format   */
    GET_FLOAT128_OPS( op1, r1, op2, r2, regs );             /* Get operand values                                   */

    SET_SF_RM_FROM_FPC;                                     /* Set rounding mode for Subtract from FPC              */
    softfloat_exceptionFlags = 0;                           /* Clear all Softfloat IEEE flags                       */
    ans = f128_sub(op1, op2);                               /* Add two float128_t values                            */

    if (softfloat_exceptionFlags)                           /* Any IEEE Exceptions?                                 */
    {
        IEEE_EXCEPTION_TRAP_XI(regs);                       /* if Xi trappable, suppresses result, no return        */
        ieee_trap_conds = ieee_exception_test_oux(regs);    /* test for overflow, underflow, inexact, set FPC flags */
    };

    PUT_FLOAT128_CC(ans, r1, regs);                         /* Store result from Subtract                           */
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO     /* Take trap for any trappable exception            */
        | FPC_MASK_IMU
        | FPC_MASK_IMX);

}

/*-------------------------------------------------------------------*/
/* B31B SDBR  - SUBTRACT (long BFP)                            [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(subtract_bfp_long_reg)
{
    int r1, r2;
    float64_t op1, op2, ans;
    U32 ieee_trap_conds = 0;                                /* start out with no traps detected                     */

    RRE(inst, regs, r1, r2);                                /* decode operand registers from instruction            */
    BFPINST_CHECK(regs);                                    /* Ensure BPF instructions allowed by CPU State         */
    GET_FLOAT64_OPS(op1, r1, op2, r2, regs);                /* Get operand values                                   */

    softfloat_exceptionFlags = 0;                           /* Clear all Softfloat IEEE flags                       */
    SET_SF_RM_FROM_FPC;                                     /* Set rounding mode for Subtract from FPC              */
    ans = f64_sub(op1, op2);                                /* Add two float64_t values                             */

    if (softfloat_exceptionFlags)                           /* Any IEEE Exceptions?                                 */
    {
        IEEE_EXCEPTION_TRAP_XI(regs);                       /* if Xi trappable, suppresses result, no return        */
        ieee_trap_conds = ieee_exception_test_oux(regs);    /* test for overflow, underflow, inexact, set FPC flags */
    };

    PUT_FLOAT64_CC(ans, r1, regs);                          /* Store result from Subtract                           */
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO     /* Take trap for any trappable exception            */
        | FPC_MASK_IMU
        | FPC_MASK_IMX);
}

/*-------------------------------------------------------------------*/
/* ED1B SDB   - SUBTRACT (long BFP)                            [RXE] */
/*-------------------------------------------------------------------*/
DEF_INST(subtract_bfp_long)
{
    int r1, b2;
    VADR effective_addr2;
    float64_t op1, op2, ans;
    U32 ieee_trap_conds = 0;                                /* start out with no traps detected                     */

    RXE(inst, regs, r1, b2, effective_addr2);               /* decode operand register and address                  */
    BFPINST_CHECK(regs);                                    /* Ensure BPF instructions allowed by CPU State         */
    GET_FLOAT64_OP(op1, r1, regs);                          /* Get register operand value                           */
    VFETCH_FLOAT64_OP(op2, effective_addr2, b2, regs);

    softfloat_exceptionFlags = 0;                           /* Clear all Softfloat IEEE flags                       */
    SET_SF_RM_FROM_FPC;                                     /* Set rounding mode for Subtract from FPC              */
    ans = f64_sub(op1, op2);                                /* Add two float64_t values                             */

    if (softfloat_exceptionFlags)                           /* Any IEEE Exceptions?                                 */
    {
        IEEE_EXCEPTION_TRAP_XI(regs);                       /* if Xi trappable, suppresses result, no return        */
        ieee_trap_conds = ieee_exception_test_oux(regs);    /* test for overflow, underflow, inexact, set FPC flags */
    };

    PUT_FLOAT64_CC(ans, r1, regs);                          /* Store result from Subtract                           */
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO     /* Take trap for any trappable exception            */
        | FPC_MASK_IMU
        | FPC_MASK_IMX);

}

/*-------------------------------------------------------------------*/
/* B30B SEBR  - SUBTRACT (short BFP)                           [RRE] */
/*-------------------------------------------------------------------*/
DEF_INST(subtract_bfp_short_reg)
{
    int r1, r2;
    float32_t op1, op2, ans;
    U32 ieee_trap_conds = 0;                                /* start out with no traps detected                     */

    RRE(inst, regs, r1, r2);                                /* decode operand registers from instruction            */
    BFPINST_CHECK(regs);                                    /* Ensure BPF instructions allowed by CPU State         */
    GET_FLOAT32_OPS(op1, r1, op2, r2, regs);                /* Get operand values                                   */

    softfloat_exceptionFlags = 0;                           /* Clear all Softfloat IEEE flags                       */
    SET_SF_RM_FROM_FPC;                                     /* Set rounding mode for Subtract from FPC              */
    ans = f32_sub(op1, op2);                                /* Add two float64_t values                             */

    if (softfloat_exceptionFlags)                           /* Any IEEE Exceptions?                                 */
    {
        IEEE_EXCEPTION_TRAP_XI(regs);                       /* if Xi trappable, suppresses result, no return        */
        ieee_trap_conds = ieee_exception_test_oux(regs);    /* test for overflow, underflow, inexact, set FPC flags */
    };

    PUT_FLOAT32_CC(ans, r1, regs);                          /* Store result from Subtract                           */
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO     /* Take trap for any trappable exception            */
        | FPC_MASK_IMU
        | FPC_MASK_IMX);

}

/*-------------------------------------------------------------------*/
/* ED0B SEB   - SUBTRACT (short BFP)                           [RXE] */
/*-------------------------------------------------------------------*/
DEF_INST(subtract_bfp_short)
{
    int r1, b2;
    VADR effective_addr2;
    float32_t op1, op2, ans;
    U32 ieee_trap_conds = 0;                                /* start out with no traps detected                     */

    RXE(inst, regs, r1, b2, effective_addr2);               /* decode operand register and address                  */
    BFPINST_CHECK(regs);                                    /* Ensure BPF instructions allowed by CPU State         */
    GET_FLOAT32_OP(op1, r1, regs);                          /* Get register operand value                           */
    VFETCH_FLOAT32_OP(op2, effective_addr2, b2, regs);

    softfloat_exceptionFlags = 0;                           /* Clear all Softfloat IEEE flags                       */
    SET_SF_RM_FROM_FPC;                                     /* Set rounding mode for Subtract from FPC              */
    ans = f32_sub(op1, op2);                                /* Add two float64_t values                             */

    if (softfloat_exceptionFlags)                           /* Any IEEE Exceptions?                                 */
    {
        IEEE_EXCEPTION_TRAP_XI(regs);                       /* if Xi trappable, suppresses result, no return        */
        ieee_trap_conds = ieee_exception_test_oux(regs);    /* test for overflow, underflow, inexact, set FPC flags */
    };

    PUT_FLOAT32_CC(ans, r1, regs);                          /* Store result from Subtract                           */
    IEEE_EXCEPTION_TRAP(regs, ieee_trap_conds, FPC_MASK_IMO     /* Take trap for any trappable exception            */
        | FPC_MASK_IMU
        | FPC_MASK_IMX);


}

/*-------------------------------------------------------------------*/
/* ED10 TCEB  - TEST DATA CLASS (short BFP)                    [RXE] */
/* Per Jessen, Willem Konynenberg, 20 September 2001                 */
/*-------------------------------------------------------------------*/
DEF_INST(test_data_class_bfp_short)
{
    int r1, b2;
    VADR effective_addr2;
    float32_t op1;

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);

    GET_FLOAT32_OP( op1, r1, regs );
    regs->psw.cc = !!(((U32)effective_addr2) & float32_class( op1 ));
}

/*-------------------------------------------------------------------*/
/* ED11 TCDB  - TEST DATA CLASS (long BFP)                     [RXE] */
/* Per Jessen, Willem Konynenberg, 20 September 2001                 */
/*-------------------------------------------------------------------*/
DEF_INST(test_data_class_bfp_long)
{
    int r1, b2;
    VADR effective_addr2;
    float64_t op1;

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);

    GET_FLOAT64_OP( op1, r1, regs );
    regs->psw.cc = !!(((U32)effective_addr2) & float64_class( op1 ));
}

/*-------------------------------------------------------------------*/
/* ED12 TCXB  - TEST DATA CLASS (extended BFP)                 [RXE] */
/* Per Jessen, Willem Konynenberg, 20 September 2001                 */
/*-------------------------------------------------------------------*/
DEF_INST(test_data_class_bfp_ext)
{
    int r1, b2;
    VADR effective_addr2;
    float128_t op1;

    RXE(inst, regs, r1, b2, effective_addr2);
    BFPINST_CHECK(regs);
    BFPREGPAIR_CHECK(r1, regs);

    GET_FLOAT128_OP( op1, r1, regs );
    regs->psw.cc = !!(((U32)effective_addr2) & float128_class( op1 ));
}

/*----------------------------------------------------------------------*/
/* DIVIDE TO INTEGER (All formats)                                      */
/*                                                                      */
/* Softfloat 3a does not have a Divide to Integer equivalent.           */
/*                                                                      */
/* Of the 64 possible combinations of operand class (NaN, Inf, etc),    */
/* only four actually require calculation of a quotent and remainder.   */
/*                                                                      */
/* So we will focus on those four cases first, followed by tests of     */
/* of operand classes to sort out results for the remaining 60 cases.   */
/*----------------------------------------------------------------------*/

/*----------------------------------------------------------------------*/
/* B35B DIDBR - DIVIDE TO INTEGER (long BFP)                   [RRF]    */
/*                                                                      */
/* Softfloat 3a does not have a Divide to Integer equivalent.           */
/*                                                                      */
/*----------------------------------------------------------------------*/
DEF_INST(divide_integer_bfp_long_reg)
{
    int r1, r2, r3;
    BYTE m4, newcc;
    float64_t op1, op2;
    float64_t quo, rem;
    U32 ieee_trap_conds = 0;                                /* start out with no traps detected                     */
    U32 op1_data_class, op2_data_class;                     /* Saved class of operands in same form as tested by    */
                                                            /* Test Data Class instruction                          */

    RRF_RM(inst, regs, r1, r2, r3, m4);                     /* decode operand registers and rounding mask           */
    BFPINST_CHECK(regs);                                    /* Ensure BPF instructions allowed by CPU State         */
    if (r1 == r2 || r2 == r3 || r1 == r3)                   /* Ensure all three operands in different registers     */
        regs->program_interrupt(regs, PGM_SPECIFICATION_EXCEPTION);  
    BFPRM_CHECK(m4,regs);                                   /* Ensure valid rounding mask value                     */
    GET_FLOAT64_OPS(op1, r1, op2, r2, regs);                /* Get operand values                                   */
    op1_data_class = float64_class(op1);                    /* Determine and save op1 data class                    */
    op2_data_class = float64_class(op2);                    /* Determine and save op2 data class                    */
    softfloat_exceptionFlags = 0;                           /* Clear all Softfloat exception flags                  */

    /* ******************************************************************************** */
    /* Following if / else if / else implements a decision tree based on SA-22-7832-10  */
    /* Table 19-21 parts 1 and 2 on pages 19-29 and 19-30 respectively.                 */
    /*                                                                                  */
    /* ORDER OF TESTS IS IMPORTANT                                                      */
    /* 1. Tests for cases that include one or two NaNs as input values                  */
    /* 2. Tests for cases that always generate the default quiet NaN                    */
    /* 3. Tests for cases that generate non-NaN results.                                */
    /*                                                                                  */
    /* When viewed from the perspective of Table 19-21, this order                      */
    /* 1. Removes the bottom two rows and the right-hand two columns                    */
    /* 2. Removes the center two colums and the top and new bottom rows                 */
    /* 3. Leaves only those cases that involve calculating and/or returning a result.   */
    /* ******************************************************************************** */

    /* ******************************************************************************** */
    /* Group 1: tests for cases with NaNs for one or both operands                      */
    /* ******* NEXT FOUR TESTS MUST REMAIN IN SEQUENCE *******                          */
    /* The sequence is required to ensure that the generated results match the IBM NaN  */
    /* propagation rules shown in Table 19-21                                           */

    if      (op1_data_class & (float_class_neg_signaling_nan | float_class_pos_signaling_nan))   /* first case: op1 an SNaN?  */
    {
        quo = op1;
        FLOAT64_MAKE_QNAN(quo);
        rem = quo;
        softfloat_exceptionFlags |= softfloat_flag_invalid;
        newcc = 1;
    }
    else if (op2_data_class & (float_class_neg_signaling_nan | float_class_pos_signaling_nan))   /* second case: op2 an SNaN?  */
    {
        quo = op2;
        FLOAT64_MAKE_QNAN(quo);
        rem = quo;
        softfloat_exceptionFlags |= softfloat_flag_invalid;
        newcc = 1;
    }
    else if (op1_data_class & (float_class_neg_quiet_nan | float_class_pos_quiet_nan))          /* third case: op1 a QNaN?  */
    {
        rem = quo = op1;
        newcc = 1;
    }
    else if (op2_data_class & (float_class_neg_quiet_nan | float_class_pos_quiet_nan))          /* fourth case: op2 a QNaN?  */
    {
        quo = rem = op2;
        newcc = 1;
    }
    
    /* END OF FOUR TESTS THAT MUST REMAIN IN SEQUENCE                                   */
    /* ******************************************************************************** */
    /* NEXT TEST MUST FOLLOW ALL FOUR NAN TESTS                                         */
    /* Group 2: Test cases that generate the default NaN and IEEE exception Invalid     */
    /* If operand 1 is an infinity OR operand two is a zero, and none of the above      */
    /* conditions are met, i.e., neither operand is a NaN, return a default NaN         */

    else if ((op1_data_class & (float_class_neg_infinity | float_class_pos_infinity))  /* Operand 1 an infinity?  */
        || (op2_data_class & (float_class_neg_zero | float_class_pos_zero)))           /* ..or operand 2 a zero?  */
    {                                                                                   /* ..yes, return DNaN, raise invalid  */
        quo = rem = float64_default_qnan;
        softfloat_exceptionFlags |= softfloat_flag_invalid;
        newcc = 1;
    }
    /* ABOVE TEST MUST IMMEDIATELY FOLLOW ALL FOUR NAN TESTS                            */

    /* ******************************************************************************** */
    /* Group 3: Tests for cases that generate non-NaN results                           */
    /*                                                                                  */
    /* Only test: both operands are non-zero finite numbers.  We can do a division.     */

    else if (   (op1_data_class & (float_class_neg_normal | float_class_pos_normal))   /* Both operands finite numbers?*/
        && (op2_data_class & (float_class_neg_normal | float_class_pos_normal)) )
    {                                                                                   /* ..yes, we can do division    */
                                                                                        
        rem = f64_rem( op1, op2);                           /* Calculate IEEE remainder.  No NaNs nor zeros, so no exceptions */
          /* need to save SF exceptions from rem operation, specifically underflow and inexact.  These will drive the FPC   */
        softfloat_roundingMode = softfloat_round_min;       /* Round to zero for division                                     */
        quo = f64_div(op1, op2);                            /* Get partial quotient*/
        /* need to test for quotient overflow here - */
        SET_SF_RM_FROM_M3(m4);                              /* Set Softfloat rounding mode from M4 mask             */
        quo = f64_roundToInt( quo, softfloat_round_minMag, TRUE);
        newcc = (0);                                        /* TBD: Condition code, probably set in function        */
    }

    /* End of tests.  At this point, operand 1 is a finite number or zero, and operand  */
    /* two is not zero.  The result is the same for each of the remaining cases:        */
    /* Operand 1 is the remainder, and the quotient is zero with a signed determined    */
    /* by the signs of the operands.  Exclusive Or sets the sign correctly.             */

    else
    {
        rem = op1;
        quo.v = (op1.v ^ op2.v) & 0x8000000000000000ULL;   /* remainder sign is exclusive or of operand signs   */
        newcc = 0;
    }

    IEEE_EXCEPTION_TRAP_XI(regs);                           /* IEEE Invalid Exception raised and trappable?         */
    IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMU | FPC_MASK_IMX);
    regs->psw.cc = newcc;
    PUT_FLOAT64_NOCC(rem, r1, regs);
    PUT_FLOAT64_NOCC(quo, r3, regs);
    ieee_cond_trap(regs, ieee_trap_conds);
    return;

}

/*-------------------------------------------------------------------*/
/* B353 DIEBR - DIVIDE TO INTEGER (short BFP)                  [RRF] */
/*-------------------------------------------------------------------*/
DEF_INST(divide_integer_bfp_short_reg)
{
    int r1, r2, r3;
    BYTE m4, newcc;
    float32_t op1, op2;
    float32_t quo, rem;
    U32 ieee_trap_conds = 0;                                /* start out with no traps detected                     */
    U32 op1_data_class, op2_data_class;                     /* Saved class of operands in same form as tested by    */
                                                            /* Test Data Class instruction                          */

    RRF_RM(inst, regs, r1, r2, r3, m4);                     /* decode operand registers and rounding mask           */
    BFPINST_CHECK(regs);                                    /* Ensure BPF instructions allowed by CPU State         */
    if (r1 == r2 || r2 == r3 || r1 == r3)                   /* Ensure all three operands in different registers     */
        regs->program_interrupt(regs, PGM_SPECIFICATION_EXCEPTION);
    BFPRM_CHECK(m4, regs);                                  /* Ensure valid rounding mask value                     */
    GET_FLOAT32_OPS(op1, r1, op2, r2, regs);                /* Get operand values                                   */
    op1_data_class = float32_class(op1);                    /* Determine and save op1 data class                    */
    op2_data_class = float32_class(op2);                    /* Determine and save op2 data class                    */
    softfloat_exceptionFlags = 0;                           /* Clear all Softfloat exception flags                  */

    /* ******************************************************************************** */
    /* Following if / else if / else implements a decision tree based on SA-22-7832-10  */
    /* Table 19-21 parts 1 and 2 on pages 19-29 and 19-30 respectively.                 */
    /*                                                                                  */
    /* ORDER OF TESTS IS IMPORTANT                                                      */
    /* 1. Tests for cases that include one or two NaNs as input values                  */
    /* 2. Tests for cases that always generate the default quiet NaN                    */
    /* 3. Tests for cases that generate non-NaN results.                                */
    /*                                                                                  */
    /* When viewed from the perspective of Table 19-21, this order                      */
    /* 1. Removes the bottom two rows and the right-hand two columns                    */
    /* 2. Removes the center two colums and the top and new bottom rows                 */
    /* 3. Leaves only those cases that involve calculating and/or returning a result.   */
    /* ******************************************************************************** */

    /* ******************************************************************************** */
    /* Group 1: tests for cases with NaNs for one or both operands                      */
    /* ******* NEXT FOUR TESTS MUST REMAIN IN SEQUENCE *******                          */
    /* The sequence is required to ensure that the generated results match the IBM NaN  */
    /* propagation rules shown in Table 19-21                                           */

    if (op1_data_class & (float_class_neg_signaling_nan | float_class_pos_signaling_nan))   /* first case: op1 an SNaN?  */
    {
        quo = op1;
        FLOAT32_MAKE_QNAN(quo);
        rem = quo;
        softfloat_exceptionFlags |= softfloat_flag_invalid;
        newcc = 1;
    }
    else if (op2_data_class & (float_class_neg_signaling_nan | float_class_pos_signaling_nan))   /* second case: op2 an SNaN?  */
    {
        quo = op2;
        FLOAT32_MAKE_QNAN(quo);
        rem = quo;
        softfloat_exceptionFlags |= softfloat_flag_invalid;
        newcc = 1;
    }
    else if (op1_data_class & (float_class_neg_quiet_nan | float_class_pos_quiet_nan))          /* third case: op1 a QNaN?  */
    {
        rem = quo = op1;
        newcc = 1;
    }
    else if (op2_data_class & (float_class_neg_quiet_nan | float_class_pos_quiet_nan))          /* fourth case: op2 a QNaN?  */
    {
        quo = rem = op2;
        newcc = 1;
    }

    /* END OF FOUR TESTS THAT MUST REMAIN IN SEQUENCE                                   */
    /* ******************************************************************************** */
    /* NEXT TEST MUST FOLLOW ALL FOUR NAN TESTS                                         */
    /* Group 2: Test cases that generate the default NaN and IEEE exception Invalid     */
    /* If operand 1 is an infinity OR operand two is a zero, and none of the above      */
    /* conditions are met, i.e., neither operand is a NaN, return a default NaN         */

    else if ((op1_data_class & (float_class_neg_infinity || float_class_pos_infinity))  /* Operand 1 an infinity?  */
        || (op2_data_class & (float_class_neg_zero || float_class_pos_zero)))           /* ..or operand 2 a zero?  */
    {                                                                                   /* ..yes, return DNaN, raise invalid  */
        quo = rem = float32_default_qnan;
        softfloat_exceptionFlags |= softfloat_flag_invalid;
        newcc = 1;
    }
    /* ABOVE TEST MUST IMMEDIATELY FOLLOW ALL FOUR NAN TESTS                            */

    /* ******************************************************************************** */
    /* Group 3: Tests for cases that generate non-NaN results                           */
    /*                                                                                  */
    /* Only test: both operands are non-zero finite numbers.  We can do a division.     */

    else if ((op1_data_class & (float_class_neg_normal | float_class_pos_normal))   /* Both operands finite numbers?*/
        && (op2_data_class & (float_class_neg_normal | float_class_pos_normal)))
    {                                                                                   /* ..yes, we can do division    */

        rem = f32_rem(op1, op2);                           /* Calculate IEEE remainder.  No NaNs nor zeros, so no exceptions */
                                                           /* need to save SF exceptions from rem operation, specifically underflow and inexact.  These will drive the FPC   */
        softfloat_roundingMode = softfloat_round_min;       /* Round to zero for division                                     */
        quo = f32_div(op1, op2);                            /* Get partial quotient*/
                                                            /* need to test for quotient overflow here - */
        SET_SF_RM_FROM_M3(m4);                              /* Set Softfloat rounding mode from M4 mask             */
        quo = f32_roundToInt(quo, softfloat_round_minMag, TRUE);
        newcc = (0);                                        /* TBD: Condition code, probably set in function        */
    }

    /* End of tests.  At this point, operand 1 is a finite number or zero, and operand  */
    /* two is not zero.  The result is the same for each of the remaining cases:        */
    /* Operand 1 is the remainder, and the quotient is zero with a signed determined    */
    /* by the signs of the operands.  Exclusive Or sets the sign correctly.             */

    else
    {
        rem = op1;
        quo.v = (op1.v ^ op2.v) & 0x80000000;                /* remainder sign is exclusive or of operand signs   */
        newcc = 0;
    }

    IEEE_EXCEPTION_TRAP_XI(regs);                           /* IEEE Invalid Exception raised and trappable?         */
    IEEE_EXCEPTION_TEST_TRAPS(regs, ieee_trap_conds, FPC_MASK_IMU | FPC_MASK_IMX);
    regs->psw.cc = newcc;
    PUT_FLOAT32_NOCC(rem, r1, regs);
    PUT_FLOAT32_NOCC(quo, r3, regs);
    ieee_cond_trap(regs, ieee_trap_conds);
    return;

}

/* Some functions are 'generic' functions which are NOT dependent
   upon any specific build architecture and thus only need to be
   built once since they work identically for all architectures.
   Thus the below #define to prevent them from being built again.
   Also note that this #define must come BEFORE the #endif check
   for 'FEATURE_BINARY_FLOATING_POINT' or build errors occur.
*/
#define _IEEE_NONARCHDEP_  /* (prevent rebuilding some code) */
#endif  /* FEATURE_BINARY_FLOATING_POINT */
/*
   Other functions (e.g. the instruction functions themselves)
   ARE dependent on the build architecture and thus need to be
   built again for each of the remaining defined architectures.
*/
#if !defined(_GEN_ARCH)
  #if defined(_ARCHMODE2)
    #define  _GEN_ARCH _ARCHMODE2
    #include "ieee.c"
  #endif
  #if defined(_ARCHMODE3)
    #undef   _GEN_ARCH
    #define  _GEN_ARCH _ARCHMODE3
    #include "ieee.c"
  #endif
#endif  /*!defined(_GEN_ARCH) */

/* end of ieee.c */
