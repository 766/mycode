//
//  UdpSocket.m
//  CameraBeta
//
//  Created by 康伟 on 14-10-28.
//  Copyright (c) 2014年 wei. All rights reserved.
//

#import "UdpSocket.h"
#define RECV_LOOP_COUNT 2
@implementation UdpSocket
{
    SOCK_FD sockfd;
    
    struct sockaddr_in their_addr;

}

-(SOCK_FD)setup
{
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    return sockfd;
}
-(int)sendTo:(NSString *)ip port:(int)port data:(NSData *)data withTimeOut:(uint)time
{
    their_addr.sin_family = AF_INET;
    Log(@"ip:%@",ip);
    their_addr.sin_addr.s_addr = inet_addr([ip UTF8String]);
    their_addr.sin_port = htons(port);
    bzero(&(their_addr.sin_zero), 8);
    int sendLen = 0;
    
//    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
//    NSTimeInterval startTime = [dat timeIntervalSince1970];
//    NSTimeInterval currentTime = 0;
//    while (currentTime - startTime < 5000) {
        sendLen = sendto(sockfd,[data bytes] , [data length], 0, (struct sockaddr *)&their_addr, sizeof(their_addr));
//        if (sendLen > 0) {
//            break;
//        }
//        currentTime = [dat
//                       timeIntervalSince1970];
//    }
    return sendLen;
}
-(NSData *)recv:(char *)recvBuf len:(int)recvBuf_n
{
    int len = sizeof(their_addr);
    struct timeval tv;
    fd_set readfds;
    int i = 0;
    
    unsigned int n = 0;
    for (i = 0; i < RECV_LOOP_COUNT; i++) {
        FD_ZERO(&readfds);
        FD_SET(sockfd, &readfds);
        tv.tv_sec = 3;
        tv.tv_usec = 0;
        select(sockfd + 1, &readfds, NULL, NULL, &tv);
        if (FD_ISSET(sockfd, &readfds)) {
            if ((n = recvfrom(sockfd, recvBuf, recvBuf_n, 0, (struct sockaddr *)&their_addr, &len)) > 0) {
                return [NSData dataWithBytes:recvBuf length:n];
            }
        }
    }
    return nil;
}
-(int)close
{
    return close(sockfd);
}
@end
