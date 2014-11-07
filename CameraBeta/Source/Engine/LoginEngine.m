//
//  LoginEngine.m
//  CameraBeta
//
//  Created by 康伟 on 14-8-22.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import "LoginEngine.h"
@implementation LoginEngine
@synthesize loginMsg;
-(enum LoginState)login{
    NSInteger sendType = 1;
    NSData *result = [super request:loginMsg :sendType :loginMsg.ip];
    if (result == nil) {
        return LOGIN_SERVER_ERROR;
    }
    return [self processData:result];
}
-(enum LoginState)processData:(NSData *)result{
    Byte *datas = (Byte *)[result bytes];
    int transcationNumber = (int)datas[2];
    if(transcationNumber == 113)
    {
        int loginInfo = (int)datas[7];
        if(loginInfo == 0)
        {
            short nameLen = (short)(datas[8] << 8 | datas[9]);
            Byte nameData[nameLen];
            
            NSStringEncoding gbk = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            [ArrayUtil arrayCopy:datas srcPos:10 dst:nameData dstPos:0 length:nameLen];
            NSData *nameTemp = [[NSData alloc]initWithBytes:nameData length:nameLen];
            SERVERNAME = [[NSString alloc]initWithData:nameTemp encoding:gbk];
            Log(@"name:%@",SERVERNAME);
            return LOGIN_SUCCESS;
        }
        else if(loginInfo == 1)
        {
            return LOGIN_USERNAME_ERROR;
        }
        else if (loginInfo == 2)
        {
            return LOGIN_PASSWORD_ERROR;
        }
    }
    return LOGIN_SERVER_ERROR;
}
@end
