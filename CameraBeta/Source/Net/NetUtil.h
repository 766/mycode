//
//  NetUtil.h
//  CameraBeta
//
//  Created by 康伟 on 14-8-21.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "Message.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <ifaddrs.h>
//#include "DDLog.h"
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <dlfcn.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "UdpSocket.h"
#import "AsyncUdpSocket.h"
#import "AsyncSocket.h"
#import "Global.h"
//static const int ddLogLevel = LOG_FLAG_VERBOSE | LOG_FLAG_DEBUG | LOG_FLAG_ERROR;
#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
@interface NetUtil : NSObject<AsyncUdpSocketDelegate,AsyncSocketDelegate>
{
    //    long tag;
    //	GCDAsyncUdpSocket *udpSocket;
//    AsyncUdpSocket *udpSocket;
    AsyncSocket *tcpSocket;
    //	NSMutableString *log;
}
+(NetUtil *)sharedManager;
-(NSString *)getCurrentNet;
+(BOOL)isEnableWIFI;
+(BOOL)isEnable3G;
-(NSData *)sendMessage:(Message *)msg :(NSInteger)sendType :(NSString *)ip;
-(NSData *)sendMessage1:(int)localPort serverPort:(int)serverPort serverIp:(NSString *)serverIp data:(NSData *)data isReceive:(BOOL)isReceive;
+(NSString *)macAddress;
+(NSString *)localWiFiIPAddress;
+(NSString *)stringFromAddress:(const struct sockaddr*)address;
+(BOOL)addressFromString:(NSString *)IPAddress address:(struct sockaddr_in *)address;
-(NSString *)hostname;
-(NSString *)getIPAddressForHost:(NSString *)theHost;
/**获得IP地址*/
-(NSString *)localIPAddress;
-(AsyncSocket *)getTcpConnection:(NSString *)host port:(NSInteger)port;
-(NSString *)deviceIPAddress;
-(void)freeAddress;
@end
