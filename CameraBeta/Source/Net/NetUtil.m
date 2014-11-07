
//  NetUtil.m
//  CameraBeta
//
//  Created by 康伟 on 14-8-21.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import "NetUtil.h"
#import "IPAdress.h"
#define SOCK_FD int
//bool isFinish = false;
bool isFirst = false;
static NetUtil *netUtil = nil;
@implementation NetUtil
{
    int uiNodeCount;
    BOOL isFinish;
    NSData *result;
}
// --------------单例模式------------------
+(NetUtil *)sharedManager
{
    
    @synchronized(self)
    {
        if (!netUtil) {
            netUtil = [[self alloc]init];
        }
    }
    
    
    return netUtil;
}

+(id)allocWithZone:(NSZone *)zone{
    
    @synchronized(self){
        
        if (!netUtil) {
            
            netUtil = [super allocWithZone:zone]; //确保使用同一块内存地址
            
            return netUtil;
        }
    }
    
    return nil;
    
}

- (id)copyWithZone:(NSZone *)zone;{
    
    return self; //确保copy对象也是唯一
}

-(NSString *)getCurrentNet
{
    
    Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    
    switch ([r currentReachabilityStatus]) {
            
        case NotReachable:
            
            return @"invalidNet" ;
            
        case ReachableViaWiFi:
            
            return @"wifi" ;
            
        case ReachableViaWWAN:
            
            return @"3g" ;
            
        default:
            break;
    }
}
+(BOOL)isEnableWIFI
{
    
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
    
}
+(BOOL)isEnable3G
{
    
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
    
}
+(NSString *)macAddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    if((mib[5] = if_nametoindex("en0")) == 0){
        printf("Error: if_nametoindex error/h");
        return nil;
    }
    if(sysctl(mib, 6, nil, &len, nil, 0) < 0){
        printf("Error sysctl,take 1/n");
        return nil;
    }
    if((buf = malloc(len)) == nil)
    {
        printf("Could not allocate memory. error!/n");
        return nil;
    }
    if (sysctl(mib, 6, buf, &len, nil, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return nil;
    }
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x",*ptr,*(ptr +1),*(ptr + 2),*(ptr + 3),*(ptr + 4),*(ptr + 5)];
    free(buf);
    return [outstring uppercaseString];
}

+(NSString *)localWiFiIPAddress
{
    BOOL success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    success = getifaddrs(&addrs) == 0;
    if(success)
    {
        cursor = addrs;
        while (cursor != nil) {
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0) {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if([name isEqualToString:@"en0"]){
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
}

+(NSString *)stringFromAddress:(const struct sockaddr *)address
{
    if(address && address->sa_family == AF_INET)
    {
        const struct sockaddr_in *sin = (struct sockaddr_in *)address;
        return [NSString stringWithFormat:@"%@:%d",[NSString stringWithUTF8String:inet_ntoa(sin->sin_addr)],ntohs(sin->sin_port)];
    }
    return nil;
}

+(BOOL)addressFromString:(NSString *)IPAddress address:(struct sockaddr_in *)address
{
    if (!IPAddress || ![IPAddress length]) {
        return NO;
    }
    memset((char *)address, sizeof(struct sockaddr_in), 0);
    address->sin_family = AF_INET;
    address->sin_len = sizeof(struct sockaddr_in);
    int conversionResult = inet_aton([IPAddress UTF8String], &address->sin_addr);
    if(conversionResult == 0)
    {
        NSAssert1(conversionResult != 1, @"Failed to convert the ip address string into a socket_in:%@", IPAddress);
        return NO;
    }
    return YES;
    
}

-(NSString *)hostname
{
    char baseHostName[256];
    int success = gethostname(baseHostName, 255);
    if(success != 0)return nil;
    baseHostName[255] = '\0';
#if TARGET_IPHONE_SIMULATOR
    return [NSString stringWithFormat:@"%s",baseHostName];
#else
    return [NSString stringWithFormat:@"%s.local",baseHostName];
#endif
    
}

-(NSString *)getIPAddressForHost:(NSString *)theHost
{
    struct hostent *host = gethostbyname([theHost UTF8String]);
    if (!host) {
        herror("resolv");
        return NULL;
    }
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
    NSString *addressString = [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
    return addressString;
}

-(NSString *)localIPAddress
{
    struct hostent *host = gethostbyname([[self hostname] UTF8String]);
    if (!host) {
        herror("resolv");
        return nil;
    }
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
    return [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
}

-(NSString *)deviceIPAddress
{
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    return [NSString stringWithFormat:@"%s",ip_names[1]];
}
-(void)freeAddress
{
    FreeAddresses();
}
/**
 *设置UDP服务器
 */
- (void)setupUdpSocket
{

//        if (![udpSocket isClosed])
//        {
//            [udpSocket close];
//            udpSocket = nil;
//        }
//        
//        udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
//        
//        NSError *error;
//        
//        NSInteger port = (arc4random() % 65535) + 1000;
//        
//        if (![udpSocket bindToPort:port error:&error]) {
//            NSLog(@"%@",FORMAT(@"Error binding: %@", error));
//            
//            [NSException raise:@"udpSock error" format:@"%@",error];
//        }
//        
//        [udpSocket enableBroadcast:YES error:&error];
//        
//        NSLog(@"Ready");
}
/**
 *
 *设置tcp
 */
-(void)setupTcpSocket:(NSString *) host :(NSInteger) port{
    
    if (!tcpSocket) {
        
        tcpSocket = [[AsyncSocket alloc]initWithDelegate:self];
        
        NSError *error;
        
        if (![tcpSocket connectToHost:host onPort:port error:&error]) {
            
            Log(@"Error:%@",error);
            
        }
    }
}
-(NSData *)sendMessage:(Message *)msg :(NSInteger)sendType :(NSString *)ip{
    isFinish = false;
    
    NSData *data = [msg getData:sendType];
    
    NSData *retData;
    
    UdpSocket *udpSocket;
    
    if (sendType != 6)
    {
        udpSocket = [[UdpSocket alloc] init];
        if (![udpSocket setup]) {
            return NULL;
        }
    }
//    NSTimeInterval timeout = 5;
    switch (sendType) {
        case 1:
        {
            isFinish =true;
            [udpSocket sendTo:ip port:SERVER_MONITOR_VSIP_PORT data:data withTimeOut:-1];
            
            char recvBuf[255];
            retData = [udpSocket recv:recvBuf len:255];
            
            break;
        }
        case 2:
        {
//            [udpSocket sendData:data toHost:ip port:SERVER_LOCAL_TRANSMIT_VIDEO_PORT withTimeout:timeout tag:1];
            
            isFinish =true;
            [udpSocket sendTo:ip port:SERVER_LOCAL_TRANSMIT_VIDEO_PORT data:data withTimeOut:-1];
            
            return nil;
        }
        case 3:
        {
//            [udpSocket sendData:data toHost:ip port:SERVER_LOCAL_LISTEN_MONITOR_EVENT_PORT withTimeout:timeout tag:1];
            isFinish = true;
            [udpSocket sendTo:ip port:SERVER_LOCAL_TRANSMIT_VIDEO_PORT data:data withTimeOut:-1];
            
            return nil;
        }
        case 4:
        {
//            [udpSocket sendData:data toHost:ip port:SERVER_LOCAL_TRANSMIN_AUDIO_PORT withTimeout:timeout tag:1];
            isFinish = true;
            [udpSocket sendTo:ip port:SERVER_LOCAL_TRANSMIT_VIDEO_PORT data:data withTimeOut:-1];
            
            return nil;
        }
            
        case 5:
        {
//            [udpSocket sendData:data toHost:ip port:SERVER_MONITOR_VSIP_PORT withTimeout:timeout tag:1];
            
            isFinish = true;
            [udpSocket sendTo:ip port:SERVER_LOCAL_TRANSMIT_VIDEO_PORT data:data withTimeOut:-1];
            
            return nil;
        }
        case 6:
        {
            [self setupTcpSocket:ip :SERVER_MONITOR_VSIP_PORT];
            [tcpSocket writeData:data withTimeout:-1 tag:0];
            [tcpSocket readDataToLength:74 withTimeout:-1 tag:0];
            
            break;
        }
        default:
            break;
    }
    if (sendType != 6) {
        [udpSocket close];
    }
    while (!isFinish) {
        [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    if (result != NULL) {
        retData = result;
    }
    return retData;
}


-(NSData *)sendMessage1:(int)localPort serverPort:(int)serverPort serverIp:(NSString *)serverIp data:(NSData *)data isReceive:(BOOL)isReceive{
    
//    @try {
//        [self setupUdpSocket];
//    }
//    @catch (NSException *exception) {
//        return NULL;
//    }
//    [udpSocket :data toHost:serverIp port:serverPort withTimeout:-1 tag:0];
//    [udpSocket receiveWithTimeout:5 tag:0];
//    if (isReceive) {
//        isFinish = false;
//    }else{
//        isFinish = true;
//    }
    //这里关闭的话在release下会崩溃 message sent to deallocated instance;
//    if (udpSocket) {
//        [udpSocket closeAfterSendingAndReceiving];
//    }
//    while (!isFinish) {
//        [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//    }
    
    UdpSocket *udpSocket = [[UdpSocket alloc] init];
    [udpSocket setup];
    [udpSocket sendTo:serverIp port:serverPort data:data withTimeOut:-1];
    if (isReceive)
    {
        char recvBuf[255];
        result = [udpSocket recv:recvBuf len:255];
    }
    else
    {
        result = NULL;
    }
    return result;
}
-(AsyncSocket *)getTcpConnection:(NSString *)host port:(NSInteger)port{
    [self setupTcpSocket:host :port];
    if (tcpSocket) {
        return tcpSocket;
    }
    return nil;
}
#pragma mark UDP callBack
-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port{
    result = data;
    Log(@"--------onReceive-------- %@   ",data) ;
    isFinish = YES;
    return YES;
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{
    Log(@"didNotReceiveDataWithTag err:%@",error);
    isFinish = NO;
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    Log(@"didNotSendDataWithTag err:%@",error);
}

-(void)udpSocket:(AsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
    Log(@"connect success.");
}

-(void)onUdpSocketDidClose:(AsyncUdpSocket *)sock{
    Log(@"udpSocket closed");
    isFinish = YES;
}

#pragma mark TCP callBack
-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err{
    Log(@"willDisconnectWithError:%@",err);
    result = nil;
}
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    Log(@"didConnectToHost");
    //    [tcpSocket readDataWithTimeout:-1 tag:0];
}
-(void)onSocket:(AsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    
}
-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
#pragma mark 第一次接受
    if (!isFirst) {
        Log(@"dataLength:%lu",(unsigned long)[data length]);
        Byte *tcpResult = (Byte *)[data bytes];
        MONITORID = (tcpResult[10] << 24 | tcpResult[9] << 16 | tcpResult[8] << 8| (tcpResult[7] & 0xff));
        uiNodeCount = (tcpResult[14] << 24 | tcpResult[13] << 16 | tcpResult[12] << 8 | (tcpResult[11] & 0xff));
        NODESCOUNT = uiNodeCount;
        USERID = (tcpResult[18] << 24 | tcpResult[17] << 16 | tcpResult[16] << 8 | (tcpResult[15] & 0xff));
        USERLEVEL = (tcpResult[22] << 24 | tcpResult[21] << 16 | tcpResult[20] << 8 | (tcpResult[19] & 0xff));
        
        Log(@"%ld",(long)NODESCOUNT);
        isFirst = YES;
    }
    [tcpSocket readDataToLength:uiNodeCount * 477 withTimeout:-1 tag:0];
    Log(@"dataLength:%lu",(unsigned long)[data length]);
    if ([data length] == uiNodeCount * 477) {
        result = data;
        isFinish = true;
    }else{
        isFinish = NO;
    }
    //    [tcpSocket disconnectAfterReadingAndWriting];
}
-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag{
    Log(@"didWriteDataWithTag%ld",tag);
}
-(void)onSocketDidDisconnect:(AsyncSocket *)sock{
    Log(@"SocketDidDisconnect");
}
-(void)dealloc
{
//    netUtil = nil;
}
@end
