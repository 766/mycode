//
//  TextUtil.h
//  CameraBeta
//
//  Created by 康伟 on 14-8-20.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextUtil : NSObject
+(BOOL)isEmpty:(NSString *)string;
+(BOOL)isValidIp:(NSString *)ipStr;
+(NSData *)typeConversion:(id<NSObject>)parame;
@end
