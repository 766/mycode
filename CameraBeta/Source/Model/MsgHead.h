//
//  MsgHead.h
//  CameraBeta
//
//  Created by 康伟 on 14-8-21.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface MsgHead : NSObject
@property(nonatomic,assign) short verifyMsg;
@property(nonatomic,assign) Byte msgType;
@property(nonatomic,assign) short msgLength;
@property(nonatomic,assign) short count ;
-(id)initWithType:(Byte)msgType andLength:(short)msgLength;
@end
