//
//  ArrayUtil.h
//  CameraBeta
//
//  Created by 康伟 on 14-8-22.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArrayUtil : NSObject
+(void)arrayCopy:(Byte *)src srcPos:(NSInteger)srcPos dst:(Byte *)dst dstPos:(NSInteger)dstPos length:(NSInteger)length;
@end
