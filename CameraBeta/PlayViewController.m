//
//  PlayViewController.m
//  CameraBeta
//
//  Created by 康伟 on 14-9-3.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import "PlayViewController.h"

@interface PlayViewController () <MONActivityIndicatorViewDelegate>

@end
extern NSString *NOTIFICATIONNAME;
static NSArray *supportSream;
@implementation PlayViewController
{
@private NSInteger address;
@private int intArrs[50];
@private BOOL havePtz;
@private Byte *msgResult;
@private NetUtil *netUtil;
@private AsyncSocket *tcpSocket;
@private bool isFinish;
@private NSData *buffer;
@private volatile NSData *socketData;
@private volatile bool receivered;
@private volatile bool processed;
@private int nWidth;
@private int nHeight;
@private u_int8_t *mPixel;
@private BOOL unknowSize;
@private NSFileHandle *fileHandle;
@private NSFileManager *fileManager;
@private NSArray *directoryPaths;
@private NSString *documentDirectory;
@private BOOL isLopper;
@private MONActivityIndicatorView *indicatorView;
    //------解码数据------------
    // 初始化视频缓冲区
    AVCodecContext *c;
	AVFrame *picture;
    
    uint8_t *inbuf_ptr;
    char *m_yuvBuf;
    char *m_rgbBuf;
    
}
//char mPixel[1280 * 1080] = {0};
@synthesize device = _device;
@synthesize VideoView;
int sockfd;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    supportSream = [NSArray arrayWithObjects:@"1",@"12",@"16",@"19",@"24",@"26",@"30",@"32",@"34",@"36",@"36",@"37",@"38",@"42",@"43",@"46",@"47",@"48",@"50",@"102", nil];
    
    nWidth =  640;
    nHeight = 480;
    mPixel = (Byte *)malloc(nWidth * nHeight *3);
    unknowSize = YES;
    isLopper = YES;
    
    [NSThread detachNewThreadSelector:@selector(getVideoStream) toTarget:self withObject:nil];
    
    fileManager = [NSFileManager defaultManager];
    directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    documentDirectory = [directoryPaths objectAtIndex:0];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reachabilityChanged:) name:NOTIFICATIONNAME object:nil];
    
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"设备列表" style:UIBarButtonItemStylePlain target:self action:@selector(GoBack:)];
    /*========点击隐藏导航======*/
//    self.navigationController.hidesBarsOnTap = YES;
    /*========隐藏导航======*/
    self.navigationController.navigationBarHidden = YES;
    
    /*======初始化解码器=======*/
    [self InitDecoder];
    m_rgbBuf  = (char*)malloc(1024*1024*3);
    m_yuvBuf  = (char*)malloc(1024*1024*2);
    
    /*======屏幕常亮======*/
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    /*-----------Indicator----------------*/
    indicatorView = [[MONActivityIndicatorView alloc] init];
    indicatorView.delegate = self;
    indicatorView.numberOfCircles = 5;
    indicatorView.radius = 15;
    indicatorView.internalSpacing = 3;
    indicatorView.center = self.view.center;
    [indicatorView startAnimating];
    [self.view addSubview:indicatorView];
//    [NSTimer scheduledTimerWithTimeInterval:7 target:indicatorView selector:@selector(stopAnimating) userInfo:nil repeats:NO];
//    [NSTimer scheduledTimerWithTimeInterval:9 target:indicatorView selector:@selector(startAnimating) userInfo:nil repeats:NO];
    /*-----------Indicator----------------*/
 
//    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//    
//    CGRect frame = [UIScreen mainScreen].applicationFrame;
//    
//    CGPoint center =  CGPointMake(frame.origin.x + ceil(frame.size.width /2), frame.origin.y + ceil(frame.size.height/2));
//    
//    [[UIApplication sharedApplication]setStatusBarOrientation:UIDeviceOrientationLandscapeRight animated:YES];
//    
//    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
//    
//    [UIView beginAnimations:nil context:nil];
//    
//    [UIView setAnimationDuration:duration];
//    
//    self.navigationController.navigationBar.frame = CGRectMake(-204, 224, 480, 32);
//    self.navigationController.navigationBar.transform = CGAffineTransformMakeRotation(M_PI * 1.5);
//    self.view.bounds = CGRectMake(0, -54, self.view.frame.size.width, self.view.frame.size.height);
//    self.view.transform = CGAffineTransformMakeRotation(M_PI * 1.5);
//    
//    [UIView commitAnimations];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showTitleBar:)];
    [self.view addGestureRecognizer:tapGesture];
}

-(void)showTitleBar:(id)sender
{
    if ([self.navigationController isNavigationBarHidden]) {
        self.navigationController.navigationBarHidden = NO;
    }else{
        self.navigationController.navigationBarHidden = YES;
    }
}

-(void)reachabilityChanged:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark - MONActivityIndicatorViewDelegate Methods

- (UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView
      circleBackgroundColorAtIndex:(NSUInteger)index {
    CGFloat red   = (arc4random() % 256)/255.0;
    CGFloat green = (arc4random() % 256)/255.0;
    CGFloat blue  = (arc4random() % 256)/255.0;
    CGFloat alpha = 1.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

-(void)hideIndicatorView:(id)sender
{
    [indicatorView stopAnimating];
}


-(void)GoBack:(id)sender
{
    //    isLopper = false;
    //    [self.navigationController popViewControllerAnimated:YES];
}
-(void)getVideoStream{
    msgResult = malloc(sizeof(Byte) * 211);
    NSString *nodeName = [self.device nodeName];
    if ([nodeName contains:@"HAVEPTZ"]) {
        NSArray *strs = [nodeName split:@"HAVEPTZ"];
        //        nodeName = strs[1];
        NSInteger protocal = [[strs[0] substringFromIndex:0 toIndex:2] intValue];
        address = [[strs[0] substringFromIndex:2 toIndex:[strs[0]length]]intValue];
        protocal = protocal >= 50 ? protocal -50 : protocal;
        address = address >= 500 ? address -500 : address;
        havePtz = true;
    }else{
        havePtz = false;
    }
    Log(@"%xd ///",msgResult[2]);
    bzero(msgResult, 211);
    netUtil = [NetUtil sharedManager];
    
    while (msgResult != nil && msgResult[2] != 0x6f) {
        IsH264Message *is264Msg = [[IsH264Message alloc] initWithType:(Byte)0x6e andLength:(short)11];
        int point[] = {7};
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:[self.device uiViewID]],@"key1",
                                nil];
        NSData *retData = [netUtil sendMessage1:0 serverPort:30000 serverIp:SERVERIP data:[is264Msg getMsgData:point params:params ponitCount:1] isReceive:true];
        msgResult = (Byte *)[retData bytes];
    }
    Byte intData[4];
    int pos = 11;
    for (int i = 0; i < 50; i++) {
        [ArrayUtil arrayCopy:msgResult srcPos:pos dst:intData dstPos:0 length:4];
        pos += 4;
        intArrs[i] = ((intData[0] << 24 & 0xff) | (intData[1] << 16 & 0xff) | (intData[2] << 8 & 0xff) | (intData[3] & 0xff));
    }
    if (![supportSream containsObject:[NSString stringWithFormat:@"%d",intArrs[9]]]) {
        //不支持码流
        
        return;
    }
    
    RequestDataTypeMsg *dataTypeMsg = [[RequestDataTypeMsg alloc]initWithType:(Byte)0x5c andLength:(short)0x0b];
    
    int point[] = {7};
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[self.device uiViewID]],@"key1",
                            nil];
    msgResult = malloc(sizeof(Byte) * 11);
    
    //    while (msgResult == nil || 0x5d != msgResult[2]) {
    //        NSData *retData = [netUtil sendMessage1:0 serverPort:30000 serverIp:SERVERIP data:[dataTypeMsg getMsgData:point params:params ponitCount:1] isReceive:YES];
    //        msgResult = (Byte *)[retData bytes];
    //    }
    
    do{
        
        NSData *retData = [netUtil sendMessage1:0 serverPort:30000 serverIp:SERVERIP data:[dataTypeMsg getMsgData:point params:params ponitCount:1] isReceive:YES];
        
        msgResult = (Byte *)[retData bytes];
        
    }while (0x5d != msgResult[2]);
    
    int cameraId = (msgResult[7] << 24 | msgResult[8] << 16 | msgResult[9] << 8 | (msgResult[10] & 0xff));
    Log(@"cameraId:%d",cameraId);
    Byte data[35];
    Byte head[7];
    memset(data, 0, 35);
    memset(head, 0, 7);
    [ArrayUtil arrayCopy:head srcPos:0 dst:data dstPos:0 length:6];
    Byte *temp = [NumberUtil iToHL:MONITORID];
    [ArrayUtil arrayCopy:temp srcPos:0 dst:data dstPos:7 length:4];
    
    // if 2stream
    if (IS_OPEN_2_STREAM) {
        if (cameraId == 0) {
            return;
        }
        temp = [NumberUtil iToHL:cameraId];
    }else{
        if (cameraId != 0) {
            temp = [NumberUtil iToHL:cameraId];
        }else{
            temp = [NumberUtil iToHL:[self.device uiViewID]];
        }
    }
    [ArrayUtil arrayCopy:temp srcPos:0 dst:data dstPos:11 length:4];
    
    /*-----------tcp socket--------------*/
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd == -1) {
        Log(@"Failed to create socket.");
        return;
    }
    struct sockaddr_in their_addr;
    their_addr.sin_family = AF_INET;
    Log(@"ip:%s",[SERVERIP UTF8String]);
    their_addr.sin_addr.s_addr = inet_addr([SERVERIP UTF8String]);
    their_addr.sin_port = htons(SERVER_LOCAL_VIDO_STRAM_PORT);
    bzero(&(their_addr.sin_zero), 8);
    int ret = connect(sockfd, (struct sockaddr *) &their_addr, sizeof(their_addr));
    if (ret == -1) {
        close(sockfd);
        return;
    }
    size_t datalen = write(sockfd, data, 35);
    if (datalen == -1) {
        Log(@"send error.");
        return;
    }
    /*-----------tcp socket--------------*/
#pragma makr todo
    //    mPixel = malloc(sizeof(Byte) * 1280 * 1080 * 3);
    [self decode:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated{
    isFinish = true;
    isLopper = false;
}
-(void)viewDidAppear:(BOOL)animated{
}
-(void)dealloc{
//    free(msgResult);
//    msgResult = nil;
//    [[UIApplication sharedApplication]setStatusBarOrientation:UIDeviceOrientationPortrait animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark -Tcp
-(void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket{
    
}
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    Log(@"didConnectToHost///");
}
-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag{
    Log(@"didWriteDataWithTag%ld///",tag);
}
-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    Log(@"dataLength:%d",[data length]);
    //    [self decode:data];
    while (!processed) {
        continue;
    }
    socketData = data;
    receivered = true;
    processed = false;
    [NSThread detachNewThreadSelector:@selector(decode:) toTarget:self withObject:nil];
}
-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err{
    Log(@"willDisconnectWithError////:%@",err);
    isFinish = true;
    [tcpSocket disconnect];
}
-(void)onSocketDidDisconnect:(AsyncSocket *)sock{
    Log(@"SocketDidDisconnect////");
}

#pragma mark processStream
int mTrans=0x0F0F0F0F;
int i = 0;
-(void)decodeAndShow : (char*) pFrameRGB length:(int)len nWidth:(int)nWidth nHeight:(int)nHeight
{
    
    
    //NSLog(@"decode ret = %d readLen = %d\n", ret, nFrameLen);
    if(len > 0)
    {
        /*--------------------------分割线---------------------------*/
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
        CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, pFrameRGB, nWidth*nHeight*3,kCFAllocatorNull);
        CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        CGImageRef cgImage = CGImageCreate(nWidth,
                                           nHeight,
                                           8,
                                           24,
                                           nWidth*3,
                                           colorSpace,
                                           bitmapInfo,
                                           provider,
                                           NULL,
                                           YES,
                                           kCGRenderingIntentDefault);
        CGColorSpaceRelease(colorSpace);
        //UIImage *image = [UIImage imageWithCGImage:cgImage];
        UIImage* image = [[UIImage alloc]initWithCGImage:cgImage];   //crespo modify 20111020
        CGImageRelease(cgImage);
        CGDataProviderRelease(provider);
        CFRelease(data);
        [self performSelectorOnMainThread:@selector(updateView:) withObject:image waitUntilDone:YES];
        //        [image release];
        //        NSData *nalBuf1 = [[NSData alloc]initWithBytes:pFrameRGB length:len];
        /*--------------------------分割线---------------------------*/
        //        CGContextRef ctx = UIGraphicsGetCurrentContext();
        //        char* buffer= pFrameRGB;
        //        CGRect sourceRect =CGRectMake(0, 0,nWidth, nHeight);
        //
        //        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,
        //                                                                  buffer,
        //                                                                  sourceRect.size.width*sourceRect.size.height*3,
        //                                                                  NULL);
        //        CGImageRef iref = CGImageCreate(sourceRect.size.width,
        //                                        sourceRect.size.height,
        //                                        8,
        //                                        24,
        //                                        sourceRect.size.width*3,
        //                                        CGColorSpaceCreateDeviceRGB(),
        //                                        kCGBitmapByteOrderDefault,
        //                                        provider,
        //                                        NULL,
        //                                        NO,
        //                                        kCGRenderingIntentDefault);
        ////        [NSThread sleepForTimeInterval:2    ];
        //        UIImage *myImage = [[UIImage  alloc]initWithCGImage:iref];
        //        /*----------------file------------------*/
        ////        NSString *str1 = [[NSString alloc] initWithFormat:@"%d",i];
        ////        NSString *str2 = [str1 stringByAppendingString:@".png"];
        ////        NSString *filePath = [documentDirectory stringByAppendingString:str2];
        ////        DDLogCDebug(@"filePath:%@",filePath);
        ////        if (![fileManager fileExistsAtPath:filePath]) {
        ////            [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        ////        }
        ////        fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        ////        if (fileHandle == nil) {
        ////            return;
        ////        }
        ////        NSData *imgData = UIImagePNGRepresentation(myImage);
        ////        [fileHandle seekToEndOfFile];
        ////        [fileHandle writeData:imgData];
        ////        i ++;
        //        /*----------------file------------------*/
        //        [VideoView performSelectorOnMainThread:@selector(setImage:) withObject:myImage waitUntilDone:FALSE];
        //        [VideoView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:FALSE];
        //
        //        CGImageRelease(iref);
        //        CGDataProviderRelease(provider);
    }
    
    //    return;
}

-(void)updateView:(UIImage*)newImage
{
    NSLog(@"显示新画面");
    [VideoView setImage:newImage];
    [VideoView setNeedsDisplay];
    newImage = nil;
    
}
- (void)decode:(id)sender
{
    Log(@"------start decode.....-----");
//    X264_H handle = VideoDecoder_Init(nWidth,nHeight);
    int got_picture, lenav;
    int     iTemp=0;
    int     nalLen = 0;
    int     bytesRead = 0;
    int     NalBufUsed=0;
    int     SockBufUsed=0;
    
    bool    bFirst=true;
    bool    bFindPPS=true;
    
    char    SockBuf[2048];
    char    NalBuf[40980]; // 40k
    //    char    NalBuf[65535];
    char    buffOut[115200];
    char    rgbBuffer[230400];
    int outSize;
    outSize = 115200;
    memset(SockBuf,0,2048);
    memset(buffOut,0,115200);
//    InitConvtTbl();
    while (isLopper) {
        bytesRead = recv(sockfd, SockBuf, 2048, 0);
        NSLog(@"bytesRead = %d",bytesRead);
        if (bytesRead<=0) {
            break;
        }
        //        NSData *videoData = [[NSData alloc]initWithBytes:SockBuf length:bytesRead];
        
        SockBufUsed = 0;
        while (bytesRead - SockBufUsed > 0) {
            nalLen = MergeBuffer(NalBuf, NalBufUsed, SockBuf, SockBufUsed, bytesRead-SockBufUsed);
            NalBufUsed += nalLen;
            SockBufUsed += nalLen;
            
            while(mTrans == 1)
            {
                mTrans = 0xFFFFFFFF;
                
                if(bFirst==true) // the first start flag
                {
                    bFirst = false;
                }
                else  // a complete NAL data, include 0x00000001 trail.
                {
                    if(bFindPPS==true) // true
                    {
                        if( (NalBuf[4]&0x1F) == 7 )
                        {
                            bFindPPS = false;
                        }
                        else
                        {
                            NalBuf[0]=0;
                            NalBuf[1]=0;
                            NalBuf[2]=0;
                            NalBuf[3]=1;
                            
                            NalBufUsed=4;
                            
                            break;
                        }
                    }
    				
                    //	decode nal
                    //mPixel 是 * &mPixel表示取 char *的地址 表示char **
                    //                    NSData *nalBuf = [[NSData alloc]initWithBytes:NalBuf length:NalBufUsed - 4];
//                    iTemp = VideoDecoder_Decode(handle/**上下文*/, NalBuf, NalBufUsed - 4, buffOut,outSize, &nWidth,&nHeight);
                    
//                    iTemp = VideoDecoder_Decode(handle/**上下文*/, NalBuf, NalBufUsed - 4, mPixel,&nWidth,&nHeight);
                    lenav = avcodec_decode_video(c, picture, &got_picture,
                                                 NalBuf,NalBufUsed - 4);
                    if (lenav < 0) {
                        break;
                    }
                    if (got_picture) {
                            pgm_save2(picture->data[0],picture->linesize[0],c->width,c->height,m_yuvBuf);
                            pgm_save2(picture->data[1],picture->linesize[1],c->width/2,c->height/2,m_yuvBuf + c->width * c->height);
                            pgm_save2(picture->data[2],picture->linesize[2],c->width/2,c->height/2,m_yuvBuf + c->width * c->height*5/4);
                       
                    }
                    YUV420toRGB888(m_rgbBuf,(unsigned char *)m_yuvBuf, c->width, c->height);
                    [self RGBtoIMage:(char*)m_rgbBuf imgwide:c->width  imghigh:c->height];
                    if (!indicatorView.hidden) {
                        [self performSelectorOnMainThread:@selector(hideIndicatorView:) withObject:self waitUntilDone:YES];
                    }
                    NalBufUsed -= lenav;
                    inbuf_ptr += lenav;
                    
//                    if(iTemp == 0)
//                    {
//                        i420_to_rgb24(buffOut, rgbBuffer, nWidth, nHeight);
//                        flip(rgbBuffer, nWidth, nHeight);
//                        [self decodeAndShow:rgbBuffer length:nWidth*nHeight*3 nWidth:nWidth nHeight:nHeight];
//                    }
                }
                NalBuf[0]=0;
                NalBuf[1]=0;
                NalBuf[2]=0;
                NalBuf[3]=1;
                
                NalBufUsed=4;
            }
        }
        Log(@"nDecodeRet = %d  nWidth = %d  nHeight = %d", iTemp, c->width, c->height);
    }
    close(sockfd);
//    VideoDecoder_UnInit(handle);
    [self UnitDecoder];
}

int MergeBuffer(char* NalBuf, int NalBufUsed, char* SockBuf, int SockBufUsed, int SockRemain)
{//把读取的数剧分割成NAL块
    int  i=0;
    char Temp;
    
    for(i=0; i<SockRemain; i++)
    {
        Temp  =SockBuf[i+SockBufUsed];
        NalBuf[i+NalBufUsed]=Temp;
        
        mTrans <<= 8;
        mTrans  |= Temp;
        
        if(mTrans == 1) // 找到一个开始字
        {
            i++;
            break;
        }
    }
    
    return i;
}
void flip(char *pRGBBuffer, int nWidth, int nHeight)
{
    char temp[nWidth*3];
    for (int i = 0; i<nHeight/2; i++) {
        memcpy(temp, pRGBBuffer + i*nWidth*3, nWidth*3);
        memcpy(pRGBBuffer + i*nWidth*3, pRGBBuffer + (nHeight - i - 1)*nWidth*3, nWidth*3);
        memcpy(pRGBBuffer + (nHeight - i - 1)*nWidth*3, temp, nWidth*3);
    }
}
#pragma mark decodeAndShow
// 初始化解码器方法
-(void)InitDecoder
{
	//初始化解码器
	extern AVCodec h264_decoder;
	AVCodec *codec = &h264_decoder;
	avcodec_init();
	c= avcodec_alloc_context();
	picture= avcodec_alloc_frame();
	if(codec->capabilities&CODEC_CAP_TRUNCATED)
		c->flags|= CODEC_FLAG_TRUNCATED;
	if (avcodec_open(c, codec) < 0) {
		//[NSThread exit];
		return;
	}
	H264Context *h = c->priv_data;
	MpegEncContext *s = &h->s;
	s->dsp.idct_permutation_type =1;
	dsputil_init(&s->dsp, c);
	//解码器初始化完毕
}

// 释放内存
-(void)UnitDecoder
{
	avcodec_close(c);
	av_free(c);
	av_free(picture);
}
// 释放数据内存
- (void)freeData{
	avcodec_close(c);
	av_free(c);
	av_free(picture);
    
    bzero(m_rgbBuf, 1024*1024*3);
    bzero(m_yuvBuf, 1024*1024*2);
}
void pgm_save2(unsigned char *buf,int wrap, int xsize,int ysize,uint8_t *pDataOut)
{
    int i;
    for(i=0;i<ysize;i++)
    {
        memcpy(pDataOut+i*xsize, buf + /*(ysize-i)*/i * wrap, xsize);
    }
    
}
#define MRNG(m, a, n) { if ((a) < (m)) { (a) = (m); } else if ((a) > (n)) { (a) = (n); } }
//将转换为rgb的数据转换为image，用uiimageview显示
-(void)RGBtoIMage:(char*)buf imgwide:(NSInteger)mwide imghigh:(NSInteger)mhigh
{
	char* buffer = buf;
	CGRect sourceRect =CGRectMake(0, 0,mwide, mhigh);
	
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,
															  buffer,
															  sourceRect.size.width*sourceRect.size.height*3,
															  NULL);
	CGImageRef iref = CGImageCreate(sourceRect.size.width,
									sourceRect.size.height,
									8,
									24,
									sourceRect.size.width*3,
									CGColorSpaceCreateDeviceRGB(),
									kCGBitmapByteOrderDefault,
									provider,
									NULL,
									NO,
									kCGRenderingIntentDefault);
	UIImage *myImage = [[UIImage  alloc]initWithCGImage:iref];
	[VideoView performSelectorOnMainThread:@selector(setImage:) withObject:myImage waitUntilDone:FALSE];
	[VideoView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:FALSE];
	CGImageRelease(iref);
	CGDataProviderRelease(provider);
}
//将解码后的yuv420 转换成rgb888 用于iphone显示
void YUV420toRGB888( char *rgb888, unsigned char *yuv420, int width, int height)
{
	int x, y;
	int  Y, U, V;
	int  R, G, B;
	int pos;
	int y_pos, u_pos, v_pos;
	char  *rgb;
	unsigned char *y_ptr, *u_ptr, *v_ptr;
	
	pos = width * height;
	
	rgb = rgb888;
	
	y_ptr = yuv420;
	v_ptr = yuv420 + pos + (pos >> 2);
	u_ptr = yuv420 + pos;
	
	for (y = 0; y < height; y += 2)
	{
		for (x = 0; x < width; x += 2)
		{
			y_pos = y * width + x;
			u_pos = (y * width >> 2) + (x >> 1);
			v_pos = u_pos;
			
			Y = y_ptr[y_pos];
			U = ((u_ptr[u_pos] - 127) * 1865970) >> 20;
			V = ((v_ptr[v_pos] - 127) * 1477914) >> 20;
			
			R = V + Y;
			B = U + Y;
			G = (Y * 1788871 - R * 533725 - B * 203424) >> 20;
			
			MRNG(0, R, 255);
			MRNG(0, G, 255);
			MRNG(0, B, 255);
			
			pos = y_pos * 3;
			
			rgb[pos + 0] = (unsigned char)R;
			rgb[pos + 1] = (unsigned char)G;
			rgb[pos + 2] = (unsigned char)B;
			
			
			y_pos++;
			
			Y = y_ptr[y_pos];
			
			R = V + Y;
			B = U + Y;
			G = (Y * 1788871 - R * 533725 - B * 203424) >> 20;
			
			MRNG(0, R, 255);
			MRNG(0, G, 255);
			MRNG(0, B, 255);
			
			pos = y_pos * 3;
			
			rgb[pos + 0] = (unsigned char)R;
			rgb[pos + 1] = (unsigned char)G;
			rgb[pos + 2] = (unsigned char)B;
			
			
			y_pos += (width - 1);
			
			Y = y_ptr[y_pos];
			
			R = V + Y;
			B = U + Y;
			G = (Y * 1788871 - R * 533725 - B * 203424) >> 20; //G = 1.706 * Y - 0.509 * R - 0.194 * B
			
			MRNG(0, R, 255);
			MRNG(0, G, 255);
			MRNG(0, B, 255);
			
			pos = y_pos * 3;
			
			rgb[pos + 0] = (unsigned char)R;
			rgb[pos + 1] = (unsigned char)G;
			rgb[pos + 2] = (unsigned char)B;
			
			
			
			y_pos++;
			
			Y = y_ptr[y_pos];
			
			R = V + Y;
			B = U + Y;
			G = (Y * 1788871 - R * 533725 - B * 203424) >> 20; //G = 1.706 * Y - 0.509 * R - 0.194 * B
			
			MRNG(0, R, 255);
			MRNG(0, G, 255);
			MRNG(0, B, 255);
			
			pos = y_pos * 3;
			
			rgb[pos + 0] = (unsigned char)R;
			rgb[pos + 1] = (unsigned char)G;
			rgb[pos + 2] = (unsigned char)B;
			
		}
	}
}
@end
