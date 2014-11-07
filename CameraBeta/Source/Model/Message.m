//
//  Message.m
//  CameraBeta
//
//  Created by 康伟 on 14-8-21.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import "Message.h"
@implementation Message
@synthesize dataLength;
@synthesize head;
-(id)initWithType:(Byte)type andLength:(short)length{
    self = [super init];
    if(self){
        dataLength = length;
        head = [[MsgHead alloc]initWithType:type andLength:length];
    }
    return self;
}
-(NSData *)getData:(int)sendType{
    return nil;
}
-(NSData *)getMsgData:(int *)point params:(NSDictionary *)params ponitCount:(int)pointCount{
    int length = 0;
    Byte *byteData = malloc(sizeof(Byte) * 12);
    Byte *temp = [NumberUtil sToHL:[head verifyMsg]];
    [ArrayUtil arrayCopy:temp srcPos:0 dst:byteData dstPos:0 length:2];
    byteData[2] = [head msgType];
    temp = [NumberUtil sToHL:[head count]];
    [ArrayUtil arrayCopy:temp srcPos:0 dst:byteData dstPos:3 length:2];
    temp = [NumberUtil sToHL:[head msgLength]];
    [ArrayUtil arrayCopy:temp srcPos:0 dst:byteData dstPos:5 length:2];
    int i = 0;
    for (NSString *key in params) {
        while (i < pointCount) {
            id value = [params valueForKey:key];
            const char *pObject = [((NSNumber *)value) objCType];
            if (strcmp(pObject, @encode(int)) == 0) {
                length = 4;
                temp = [NumberUtil iToHL:[value intValue]];
                [ArrayUtil arrayCopy:temp srcPos:0 dst:byteData dstPos:point[i] length:length];
            }
            if (strcmp(pObject, @encode(short)) == 0) {
                length = 2;
                temp = [NumberUtil iToHL:[value shortValue]];
                [ArrayUtil arrayCopy:temp srcPos:0 dst:byteData dstPos:point[i] length:length];
            }
            if (strcmp(pObject, @encode(Byte)) == 0) {
                byteData[point[i]] = [value charValue];
            }
            i ++;
            point ++;
        }
    }
    NSData *data = [[NSData alloc]initWithBytes:byteData length:dataLength];
    return data;
}
@end
