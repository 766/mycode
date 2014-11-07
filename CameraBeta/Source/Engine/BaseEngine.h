//
//  BaseEngine.h
//  CameraBeta
//
//  Created by 康伟 on 14-8-22.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"
#import "NetUtil.h"
@interface BaseEngine : NSObject
-(NSData *)request:(Message *)msg :(NSInteger)sendType :(NSString *) ip;
@end
