//***************************************************************************//
//***************************************************************************//
//  Copyright (c) 2018 zhanxn87
//  All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a 
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//  and/or sell copies of the Software, and to permit persons to whom the 
//  Software is furnished to do so, subject to the following conditions:
//
//  -The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
//  DEALINGS IN THE SOFTWARE.
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//
//    Author: zhanxn, zhanxn@gmail.com
//    Date  : 2018/08/18
//
//***************************************************************************//
//***************************************************************************//

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <inttypes.h>

#include "mex.h"

int taus_URNG(uint32_t seed0, uint32_t seed1, uint32_t seed2, uint32_t len, uint32_t *u0)
{
  uint32_t b0,b1,b2,s0_next,s1_next,s2_next,s0,s1,s2;
  uint32_t i;

  printf("Taus_URNG, seeds are %u %u %u\n", seed0, seed1, seed2);
  /*printf("size: %d, %d, %d\n",sizeof(uint64_t), sizeof(unsigned long), sizeof(uint32_t));*/

  s0 = seed0;
  s1 = seed1;
  s2 = seed2;

  for(i=0; i<len; i++)
  {
    b0 = (((s0 << 13) ^ s0) >> 19);
    s0_next = (((s0 & 0xFFFFFFFE) << 12) ^ b0);
    
    b1 = (((s1 << 2) ^ s1) >> 25);
    s1_next = (((s1 & 0xFFFFFFF8) << 4) ^ b1);
    
    b2 = (((s2 << 3) ^ s2) >> 11);
    s2_next = (((s2 & 0xFFFFFFF0) << 17) ^ b2);

    u0[i] = s0 ^ s1 ^ s2;

    s0 = s0_next;
    s1 = s1_next;
    s2 = s2_next;
  }

  return 0;
}

void mexFunction(int nlhs,mxArray *plhs[],int nrhs, const mxArray *prhs[])
/****************************************************************************************/
/*[LdpcOut,suc]=ldpc_dec_cmmb(inf_L, code_len, code_rate, IterMax);
inf_L:input soft information;
code_len:O -> 2688
code_len:1 -> 5376
IterMax:the maximum iteration
*/
/****************************************************************************************/
{
  unsigned int seed0, seed1, seed2, seq_len;
  unsigned int *u_out;

  seed0 =(unsigned int)mxGetScalar(prhs[0]); 
  seed1 =(unsigned int)mxGetScalar(prhs[1]); 
  seed2 =(unsigned int)mxGetScalar(prhs[2]); 
  seq_len =(unsigned int)mxGetScalar(prhs[3]); 
  
  mwSize ndim = 2;
  mwSize dims[2];
  dims[0]=1;
  dims[1]=seq_len;

  plhs[0]=mxCreateNumericArray(ndim, dims, mxUINT32_CLASS, mxREAL);

  if (plhs[0] == NULL)
    mexErrMsgTxt("\n Out Signal Matrix Could Not be Created!!--Exiting\n");

  u_out = (uint32_t *)mxGetData(plhs[0]);

  taus_URNG(seed0, seed1, seed2, seq_len, u_out);
}
