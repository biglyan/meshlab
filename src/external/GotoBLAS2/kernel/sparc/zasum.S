/*********************************************************************/
/*                                                                   */
/*             Optimized BLAS libraries                              */
/*                     By Kazushige Goto <kgoto@tacc.utexas.edu>     */
/*                                                                   */
/* Copyright (c) The University of Texas, 2009. All rights reserved. */
/* UNIVERSITY EXPRESSLY DISCLAIMS ANY AND ALL WARRANTIES CONCERNING  */
/* THIS SOFTWARE AND DOCUMENTATION, INCLUDING ANY WARRANTIES OF      */
/* MERCHANTABILITY, FITNESS FOR ANY PARTICULAR PURPOSE,              */
/* NON-INFRINGEMENT AND WARRANTIES OF PERFORMANCE, AND ANY WARRANTY  */
/* THAT MIGHT OTHERWISE ARISE FROM COURSE OF DEALING OR USAGE OF     */
/* TRADE. NO WARRANTY IS EITHER EXPRESS OR IMPLIED WITH RESPECT TO   */
/* THE USE OF THE SOFTWARE OR DOCUMENTATION.                         */
/* Under no circumstances shall University be liable for incidental, */
/* special, indirect, direct or consequential damages or loss of     */
/* profits, interruption of business, or related expenses which may  */
/* arise from use of Software or Documentation, including but not    */
/* limited to those resulting from defects in Software and/or        */
/* Documentation, or loss or inaccuracy of data of any kind.         */
/*********************************************************************/

#define ASSEMBLER
#include "common.h"

#define N	%i0
#define X	%i1
#define INCX	%i2
#define I	%i3

#ifdef DOUBLE
#define c1	%f0
#define c2	%f2
#define t1	%f8
#define t2	%f10
#define t3	%f12
#define t4	%f14

#define a1	%f16
#define a2	%f18
#define a3	%f20
#define a4	%f22
#define a5	%f24
#define a6	%f26
#define a7	%f28
#define a8	%f30
#else
#define c1	%f0
#define c2	%f1
#define t1	%f4
#define t2	%f5
#define t3	%f6
#define t4	%f7

#define a1	%f8
#define a2	%f9
#define a3	%f10
#define a4	%f11
#define a5	%f12
#define a6	%f13
#define a7	%f14
#define a8	%f15
#endif

	PROLOGUE
	SAVESP

	FCLR(0)

	sll	INCX, ZBASE_SHIFT, INCX
	
	FMOV	c1, c2
	FMOV	c1, t1
	FMOV	c1, t2
	FMOV	c1, t3
	FMOV	c1, t4

	cmp	INCX, 0
	ble	.LL19
	nop

	cmp	INCX, 2 * SIZE
	bne	.LL50
	nop

	sra	N, 2, I
	cmp	I, 0
	ble,pn	%icc, .LL15
	nop

	LDF	[X +  0 * SIZE], a1
	add	I, -1, I
	LDF	[X +  1 * SIZE], a2
	cmp	I, 0
	LDF	[X +  2 * SIZE], a3
	LDF	[X +  3 * SIZE], a4
	LDF	[X +  4 * SIZE], a5
	LDF	[X +  5 * SIZE], a6
	LDF	[X +  6 * SIZE], a7
	LDF	[X +  7 * SIZE], a8

	ble,pt	%icc, .LL12
	add	X, 8 * SIZE, X

#define PREFETCHSIZE 32

.LL11:
	FADD	c1, t1, c1
	prefetch [X  + PREFETCHSIZE * SIZE], 0
	FABS	a1, t1
	LDF	[X +  0 * SIZE], a1

	FADD	c2, t2, c2
	add	I, -1, I
	FABS	a2, t2
	LDF	[X +  1 * SIZE], a2

	FADD	c1, t3, c1
	cmp	I, 0
	FABS	a3, t3
	LDF	[X +  2 * SIZE], a3

	FADD	c2, t4, c2
	nop
	FABS	a4, t4
	LDF	[X +  3 * SIZE], a4

	FADD	c1, t1, c1
	nop
	FABS	a5, t1
	LDF	[X +  4 * SIZE], a5

	FADD	c2, t2, c2
	nop
	FABS	a6, t2
	LDF	[X +  5 * SIZE], a6

	FADD	c1, t3, c1
	FABS	a7, t3
	LDF	[X +  6 * SIZE], a7
	add	X, 8 * SIZE, X

	FADD	c2, t4, c2
	FABS	a8, t4
	bg,pt	%icc, .LL11
	LDF	[X -  1 * SIZE], a8

.LL12:
	FADD	c1, t1, c1
	FABS	a1, t1
	FADD	c2, t2, c2
	FABS	a2, t2

	FADD	c1, t3, c1
	FABS	a3, t3
	FADD	c2, t4, c2
	FABS	a4, t4

	FADD	c1, t1, c1
	FABS	a5, t1
	FADD	c2, t2, c2
	FABS	a6, t2

	FADD	c1, t3, c1
	FABS	a7, t3
	FADD	c2, t4, c2
	FABS	a8, t4

.LL15:
	and	N, 3, I
	cmp	I,  0
	ble,a,pn %icc, .LL19
	nop

.LL16:
	LDF	[X +  0 * SIZE], a1
	LDF	[X +  1 * SIZE], a2
	add	I, -1, I
	cmp	I, 0
	FADD	c1, t1, c1
	FADD	c2, t2, c2
	FABS	a1, t1
	FABS	a2, t2
	bg,pt	%icc, .LL16
	add	X, 2 * SIZE, X

.LL19:
	FADD	c1, t1, c1
	FADD	c2, t2, c2
	FADD	c1, t3, c1
	FADD	c2, t4, c2

	FADD	c1, c2, c1
	return	%i7 + 8
	clr	%g0

.LL50:
	sra	N, 2, I
	cmp	I, 0
	ble,pn	%icc, .LL55
	nop

	LDF	[X +  0 * SIZE], a1
	LDF	[X +  1 * SIZE], a2
	add	X, INCX, X
	LDF	[X +  0 * SIZE], a3
	LDF	[X +  1 * SIZE], a4
	add	X, INCX, X
	LDF	[X +  0 * SIZE], a5
	LDF	[X +  1 * SIZE], a6
	add	X, INCX, X
	add	I, -1, I
	LDF	[X +  0 * SIZE], a7
	cmp	I, 0
	LDF	[X +  1 * SIZE], a8

	ble,pt	%icc, .LL52
	add	X, INCX, X

.LL51:
	FADD	c1, t1, c1
	add	I, -1, I
	FABS	a1, t1
	LDF	[X +  0 * SIZE], a1

	FADD	c2, t2, c2
	cmp	I, 0
	FABS	a2, t2
	LDF	[X +  1 * SIZE], a2
	add	X, INCX, X

	FADD	c1, t3, c1
	FABS	a3, t3
	LDF	[X +  0 * SIZE], a3

	FADD	c2, t4, c2
	FABS	a4, t4
	LDF	[X +  1 * SIZE], a4
	add	X, INCX, X

	FADD	c1, t1, c1
	FABS	a5, t1
	LDF	[X +  0 * SIZE], a5

	FADD	c2, t2, c2
	FABS	a6, t2
	LDF	[X +  1 * SIZE], a6
	add	X, INCX, X

	FADD	c1, t3, c1
	FABS	a7, t3
	LDF	[X +  0 * SIZE], a7

	FADD	c2, t4, c2
	FABS	a8, t4
	LDF	[X +  1 * SIZE], a8

	bg,pt	%icc, .LL51
	add	X, INCX, X

.LL52:
	FADD	c1, t1, c1
	FABS	a1, t1
	FADD	c2, t2, c2
	FABS	a2, t2

	FADD	c1, t3, c1
	FABS	a3, t3
	FADD	c2, t4, c2
	FABS	a4, t4

	FADD	c1, t1, c1
	FABS	a5, t1
	FADD	c2, t2, c2
	FABS	a6, t2

	FADD	c1, t3, c1
	FABS	a7, t3
	FADD	c2, t4, c2
	FABS	a8, t4

.LL55:
	and	N, 3, I
	cmp	I,  0
	ble,a,pn %icc, .LL59
	nop

.LL56:
	LDF	[X +  0 * SIZE], a1
	LDF	[X +  1 * SIZE], a2
	FADD	c1, t1, c1
	FADD	c2, t2, c2
	add	I, -1, I
	FABS	a1, t1
	FABS	a2, t2
	cmp	I, 0
	bg,pt	%icc, .LL56
	add	X, INCX, X

.LL59:
	FADD	c1, t1, c1
	FADD	c2, t2, c2
	FADD	c1, t3, c1
	FADD	c2, t4, c2

	FADD	c1, c2, c1

	return	%i7 + 8
	clr	%o0

	EPILOGUE
