//
//  UdpSocket.h
//  CameraBeta
//
//  Created by 康伟 on 14-10-28.
//  Copyright (c) 2014年 wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <time.h>
#define SOCK_FD int
@interface UdpSocket : NSObject
-(SOCK_FD)setup;
-(int)sendTo:(NSString *)ip port:(int)port data:(NSData *)data withTimeOut:(uint)time;
-(NSData *)recv:(char *)recvBuf len:(int)recvBuf_n;
-(int)close;
@end
