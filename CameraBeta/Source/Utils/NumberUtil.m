
//  NumberUtil.m
//  CameraBeta
//
//  Created by 康伟 on 14-8-22.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import "NumberUtil.h"
Byte b[2];
Byte b1[4];
@implementation NumberUtil
+(Byte *)sToHL:(short)n{
    memset(b, 0, 2);
    b[1] = (Byte)(n & 0xff);
    b[0] = (Byte)(n >> 8 & 0xff);
    return b;
}
+(Byte *)sToLH:(short)n{
    memset(b, 0, 2);
    *b = (Byte)(n & 0xff);
    *(b + 1) = (Byte)(n >> 8 & 0xff);
    return b;
}
+(Byte *)iToHL:(int)n{
    memset(b1, 0, 4);
    b1[3] = (Byte)(n & 0xff);
    b1[2] = (Byte)(n >> 8 & 0xff);
    b1[1] = (Byte)(n >> 16 & 0xff);
    b1[0] = (Byte)(n >> 24 & 0xff);
    return b1;
}
+(Byte *)itoLH:(int)n{
    memset(b1, 0, 4);
    b1[0] = (Byte)(n & 0xff);
    b1[1] = (Byte)(n >> 8 & 0xff);
    b1[2] = (Byte)(n >> 16 & 0xff);
    b1[3] = (Byte)(n >> 24 & 0xff);
    return b1;
}
@end
