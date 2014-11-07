//
//  NumberUtil.h
//  CameraBeta
//
//  Created by 康伟 on 14-8-22.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NumberUtil : NSObject
+(Byte *)sToLH :(short) n;
+(Byte *)sToHL :(short) n;
+(Byte *)iToHL :(int) n;
+(Byte *)itoLH :(int) n;
@end
