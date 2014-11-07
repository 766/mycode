//
//  MsgHead.m
//  CameraBeta
//
//  Created by 康伟 on 14-8-21.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import "MsgHead.h"
@implementation MsgHead
@synthesize verifyMsg;
@synthesize msgType;
@synthesize msgLength;
@synthesize count;
-(id)initWithType:(Byte)type andLength:(short)length{
    self = [super init];
    if(self){
        self.msgType = type;
        self.msgLength = length;
        self.verifyMsg = 0x100;
    }
    return self;
}
@end
