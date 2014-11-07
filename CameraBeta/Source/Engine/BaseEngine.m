//
//  BaseEngine.m
//  CameraBeta
//
//  Created by 康伟 on 14-8-22.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import "BaseEngine.h"

@implementation BaseEngine
{
    NetUtil *netUtil;
}

-(NSData *)request:(Message *)msg :(NSInteger)sendType :(NSString *)ip{
    if (netUtil == NULL) {
        netUtil = [NetUtil sharedManager];
    }
    return [netUtil sendMessage:msg :sendType :ip];
}

@end
