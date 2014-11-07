//
//  ArrayUtil.m
//  CameraBeta
//
//  Created by 康伟 on 14-8-22.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import "ArrayUtil.h"

@implementation ArrayUtil
+(void)arrayCopy:(Byte *)src srcPos:(NSInteger)srcPos dst:(Byte *)dst dstPos:(NSInteger)dstPos length:(NSInteger)length{
    int newSrcPos = srcPos;
    int newDstPos = dstPos;
    for (int i = 0; i < length; i++) {
        //        *(dst+(dstPos + i)) = src[srcPos + i];
        if (src == nil) {
            return;
        }else{
            *(dst+newDstPos) = *(src + newSrcPos);
        }
        newSrcPos += 1;
        newDstPos += 1;
    }
}
@end
