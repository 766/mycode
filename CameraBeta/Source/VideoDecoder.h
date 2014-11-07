#ifndef VIDEODECODER_H
#define VIDEODECODER_H

#define X264_H int

#ifdef __cplusplus
extern "C" {
#endif
	X264_H VideoDecoder_Init(int widht,int height);
	int    VideoDecoder_Decode(X264_H dwHandle,unsigned char *pDataIn, int nInSize, unsigned char *pDataOut, int outSize ,int *nWidth, int *nHeight);
    //    int    VideoDecoder_Decode(X264_H dwHandle,unsigned char *pDataIn, int nInSize, unsigned char *pDataOut,int *iWidht,int *iHeight);
    void   VideoDecoder_UnInit(X264_H dwHandle);
#ifdef __cplusplus
}
#endif
#endif
