
/*
 * Copyright (C) 2009 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
#include "VideoDecoder.h"
#include <string.h>
#include "common.h"
#include "avcodec.h"
#import <stdlib.h>
#import <stdio.h>
#import <math.h>
#import "dsputil.h"
#import "h264.h"
#include <fcntl.h>
#include "avcodec.h"
#include "define.h"
#include <wchar.h>


struct AVCodec *codec=NULL;			  // Codec
struct AVCodecContext *c=NULL;		  // Codec Context
struct AVFrame *picture=NULL;		  // Frame
int frame_count;

int iWidth=0;
int iHeight=0;

int *colortab=NULL;
int *u_b_tab=NULL;
int *u_g_tab=NULL;
int *v_g_tab=NULL;
int *v_r_tab=NULL;

unsigned int *rgb_2_pix=NULL;
unsigned int *r_2_pix=NULL;
unsigned int *g_2_pix=NULL;
unsigned int *b_2_pix=NULL;

void DeleteYUVTab()
{
	av_free(colortab);
	av_free(rgb_2_pix);
}

void CreateYUVTab_16()
{
	int i;
	int u, v;
    //	tmp_pic = (short*)av_malloc(iWidth*iHeight*2); // ª∫¥Ê iWidth * iHeight * 16bits
    
	colortab = (int *)av_malloc(4*256*sizeof(int));
	u_b_tab = &colortab[0*256];
	u_g_tab = &colortab[1*256];
	v_g_tab = &colortab[2*256];
	v_r_tab = &colortab[3*256];
    
	for (i=0; i<256; i++)
	{
		u = v = (i-128);
        
		u_b_tab[i] = (int) ( 1.772 * u);
		u_g_tab[i] = (int) ( 0.34414 * u);
		v_g_tab[i] = (int) ( 0.71414 * v);
		v_r_tab[i] = (int) ( 1.402 * v);
	}
    
	rgb_2_pix = (unsigned int *)av_malloc(3*768*sizeof(unsigned int));
    
	r_2_pix = &rgb_2_pix[0*768];
	g_2_pix = &rgb_2_pix[1*768];
	b_2_pix = &rgb_2_pix[2*768];
    
	for(i=0; i<256; i++)
	{
		r_2_pix[i] = 0;
		g_2_pix[i] = 0;
		b_2_pix[i] = 0;
	}
    
	for(i=0; i<256; i++)
	{
		r_2_pix[i+256] = (i & 0xF8) << 8;
		g_2_pix[i+256] = (i & 0xFC) << 3;
		b_2_pix[i+256] = (i ) >> 3;
	}
    
	for(i=0; i<256; i++)
	{
		r_2_pix[i+512] = 0xF8 << 8;
		g_2_pix[i+512] = 0xFC << 3;
		b_2_pix[i+512] = 0x1F;
	}
    
	r_2_pix += 256;
	g_2_pix += 256;
	b_2_pix += 256;
}

void DisplayYUV_16(unsigned int *pdst1, unsigned char *y, unsigned char *u, unsigned char *v, int width, int height, int src_ystride, int src_uvstride, int dst_ystride)
{
	int i, j;
	int r, g, b, rgb;
    
	int yy, ub, ug, vg, vr;
    
	unsigned char* yoff;
	unsigned char* uoff;
	unsigned char* voff;
	
	unsigned int* pdst=pdst1;
    
	int width2 = width/2;
	int height2 = height/2;
	
	if(width2>iWidth/2)
	{
		width2=iWidth/2;
        
		y+=(width-iWidth)/4*2;
		u+=(width-iWidth)/4;
		v+=(width-iWidth)/4;
	}
    
	if(height2>iHeight)
		height2=iHeight;
    
	for(j=0; j<height2; j++) // “ª¥Œ2x2π≤Àƒ∏ˆœÒÀÿ
	{
		yoff = y + j * 2 * src_ystride;
		uoff = u + j * src_uvstride;
		voff = v + j * src_uvstride;
        
		for(i=0; i<width2; i++)
		{
			yy  = *(yoff+(i<<1));
			ub = u_b_tab[*(uoff+i)];
			ug = u_g_tab[*(uoff+i)];
			vg = v_g_tab[*(voff+i)];
			vr = v_r_tab[*(voff+i)];
            
			b = yy + ub;
			g = yy - ug - vg;
			r = yy + vr;
            
			rgb = r_2_pix[r] + g_2_pix[g] + b_2_pix[b];
            
			yy = *(yoff+(i<<1)+1);
			b = yy + ub;
			g = yy - ug - vg;
			r = yy + vr;
            
			pdst[(j*dst_ystride+i)] = (rgb)+((r_2_pix[r] + g_2_pix[g] + b_2_pix[b])<<16);
            
			yy = *(yoff+(i<<1)+src_ystride);
			b = yy + ub;
			g = yy - ug - vg;
			r = yy + vr;
            
			rgb = r_2_pix[r] + g_2_pix[g] + b_2_pix[b];
            
			yy = *(yoff+(i<<1)+src_ystride+1);
			b = yy + ub;
			g = yy - ug - vg;
			r = yy + vr;
            
			pdst [((2*j+1)*dst_ystride+i*2)>>1] = (rgb)+((r_2_pix[r] + g_2_pix[g] + b_2_pix[b])<<16);
		}
	}
}

//====================================================


X264_H VideoDecoder_Init(int width,int height)
{
	iWidth = width;
	iHeight = height;
	CreateYUVTab_16();
	
    avcodec_register_all();
	extern AVCodec h264_decoder;
	codec = &h264_decoder;
	avcodec_init();
	c= avcodec_alloc_context();
	picture= avcodec_alloc_frame();
	if(codec->capabilities&CODEC_CAP_TRUNCATED)
		c->flags|= CODEC_FLAG_TRUNCATED;
	if (avcodec_open(c, codec) < 0) {
		return -1;
	}
	H264Context *h = c->priv_data;
	MpegEncContext *s = &h->s;
	s->dsp.idct_permutation_type =1;
	dsputil_init(&s->dsp, c);
	
	return 1;
	
}
void pgm_save2(unsigned char *buf,int wrap, int xsize,int ysize,uint8_t *pDataOut)
{
    int i;
    for(i=0;i<ysize;i++)
    {
        memcpy(pDataOut+i*xsize, buf + /*(ysize-i)*/i * wrap, xsize);
    }
    
}

void VideoDecoder_UnInit(X264_H dwHandle /** 上下文,已废弃*/)
{
	avcodec_close(c);
	av_free(c);
	av_free(picture);
	DeleteYUVTab();
    return;
}

int VideoDecoder_Decode(X264_H dwHandle, uint8_t *pDataIn, int nInSize, uint8_t *pDataOut, int nOutSize, int *iWidth, int *iHeight)
//int VideoDecoder_Decode(X264_H dwHandle, uint8_t *pDataIn, int nInSize, uint8_t *pDataOut,int *iWidth,int *iHeight)
{
	//int i =;
	int i = 0;
	int imod;
	int got_picture;
    int lenav;
    
	uint8_t * Buf = pDataIn;
	uint8_t * Pixel= pDataOut;
    uint8_t * inbuf_ptr = Buf;
	int	size=nInSize;
	while (size>0)
    {
        lenav = avcodec_decode_video(c, picture, &got_picture,
                                     inbuf_ptr, size);
        if (lenav < 0) {
            //break;
            continue;
        }
        if (got_picture) {
            fflush(stdout);
            
            *iWidth     = c->width;
            *iHeight   = c->height;
            if(nOutSize >= c->width*c->height*3/2)
            {
                pgm_save2(picture->data[0],picture->linesize[0],c->width,c->height,Pixel);
                pgm_save2(picture->data[1],picture->linesize[1],c->width/2,c->height/2,Pixel + c->width * c->height);
                pgm_save2(picture->data[2],picture->linesize[2],c->width/2,c->height/2,Pixel + c->width * c->height*5/4);
            }
            frame_count ++;
            //	    	DisplayYUV_16(Pixel, picture->data[0], picture->data[1], picture->data[2], c->width, c->height, picture->linesize[0], picture->linesize[1], iWidth);
        }
        size -= lenav;
        inbuf_ptr += lenav;
    }
    //    if(nOutSize < (c->width)*(c->height)*3/2)
    //    {
    //        return -1;
    //    }
    return 0;
    //	return lenav;	
}
