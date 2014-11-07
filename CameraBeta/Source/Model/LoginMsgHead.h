//
//  LoginMsgHead.h
//  CameraBeta
//
//  Created by 康伟 on 14-8-22.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginMsgHead : NSObject
@property(nonatomic,assign) short protocolVersion;
@property(nonatomic,assign) Byte msgType;
@property(nonatomic,assign) short transactionNumber;
@property(nonatomic,assign) short length;

@end
