//
//  TextUtil.m
//  CameraBeta
//
//  Created by 康伟 on 14-8-20.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import "TextUtil.h"

@implementation TextUtil
+(BOOL)isEmpty:(NSString *)string{
    NSString *str = string;
    if(str == nil || [str isEqualToString:@""""]){
        return YES;
    }
    if([str isKindOfClass:[NSNull class]]){
        return YES;
    }
    return NO;
}
+(BOOL)isValidIp:(NSString *)ipStr{
    NSString *ip = ipStr;
    NSString *ipRegex = @"^(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])$";
    NSPredicate *ipText = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",ipRegex];
    if ([ipText evaluateWithObject:ip]) {
        return YES;
    }
    return NO;
}
+(NSData *)typeConversion:(id)parame{
    if([parame isKindOfClass:[NSString class]]){
        NSString * string = (NSString *)parame;
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        return data;
    }
    return nil;
}
@end
