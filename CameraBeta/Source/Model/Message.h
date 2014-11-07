//
//  Message.h
//  CameraBeta
//
//  Created by 康伟 on 14-8-21.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MsgHead.h"
#import "NumberUtil.h"
#import "ArrayUtil.h"
#import "MsgHead.h"
@interface Message : NSObject
@property(nonatomic,assign)short dataLength;
@property(nonatomic,retain) MsgHead* head;
-(NSData *)getData:(int)sendType;
-(NSData *)getMsgData:(int *)point params:(NSDictionary*)params ponitCount:(int)pointCount;
-(id)initWithType:(Byte)type andLength:(short)length;
@end
