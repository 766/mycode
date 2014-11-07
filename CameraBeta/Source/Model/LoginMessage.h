//
//  LoginMessage.h
//  CameraBeta
//
//  Created by 康伟 on 14-8-22.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import "Message.h"
#import "NumberUtil.h"
#import "ArrayUtil.h"
#import "NetUtil.h"
#import "Global.h"
#import <stdio.h>
@interface LoginMessage : Message
typedef struct{
    short protocolVerion;
    Byte msgType;
    short transactionNumber;
    short length;
    short m_versionSize;
    Byte pchVersion;
}LoginMsgHead;

//typedef struct{
//    char *ip;
//    short port;
//    char *password;
//    short usernameLength;
//    short passwordLength;
//    char *MAC;
//    
//}LoginMsgBody;
@property(strong) NSString *ip;
@property(assign) short port;
@property(strong) NSString *username;
@property(strong) NSString *password;
@property(assign) short usernameLength;
@property(assign) short passwordLength;
@property(strong) NSString *MAC;
@end
