//
//  GetDevicesEngine.m
//  CameraBeta
//
//  Created by 康伟 on 14-8-28.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import "GetDevicesEngine.h"

@implementation GetDevicesEngine
{
@private NSMutableArray *list;
}
-(NSMutableArray *)getDevices:(Message *)msg :(NSInteger)sendType :(NSString *)host
{
    NSData *result = [super request:msg :sendType :host];
    
    Device *device;
    
    if (sendType == 6) {
        
        list = [[NSMutableArray alloc]init];
        
        for (int num = 0; num < NODESCOUNT/**TODO*/; num ++) {
            
            device = [[Device alloc]init];
            
            if (result != nil)
            {
                
                [self processData:num *477 :result :device];
                
                [list addObject:device];
            }
        }
        
        return list;
    }
    
    return nil;
}
-(void)processData :(NSInteger)num :(NSData *)data :(Device *)device
{
    Byte *retData = (Byte *)[data bytes];
//    retData += 74;   数据头已经处理，不用再次处理
//    [self showData:retData];
    Byte dst4[4];
    [ArrayUtil arrayCopy:retData srcPos:num dst:dst4 dstPos:0 length:4];
    device.cobject = dst4;
    
    device.uiViewID = (retData[num +7] << 24 | retData[num + 6] << 16 | retData[num + 5] << 8 | (retData[num + 4] &255));
    device.uiParentID = (retData[num + 11] << 24 | retData[num + 10] <<16 | retData[num + 9] <<8 | (retData[num + 8] & 255));
    
    // 考慮到建立的对象占据内存，可使用下列方法直接操作数据
    device.guidServer_Data1 = (retData[num + 15] << 24 | retData[num + 14] << 16
                               | retData[num + 13] << 8 | retData[num + 12]);
    device.guidServer_Data2 = (retData[num + 17] << 8 | retData[num + 16]);
    device.guidServer_Data3 = (retData[num + 19] << 8 | retData[num + 18]);
    Byte dst8[8];
    [ArrayUtil arrayCopy:retData srcPos:num + 20 dst:dst8 dstPos:0 length:8];
    device.guidServer_Data4 = dst8;
    
    device.guidNode_Data1 = (retData[num + 31] << 24 | retData[num + 30] << 16
                             | retData[num + 29] << 8 | retData[num + 28]);
    device.guidNode_Data2 = (retData[num + 33] << 8 | retData[num + 32]);
    
    device.guidNode_Data3 = (retData[num + 35] << 8 | retData[num + 34]);
    
    memset(dst8, 0, 8);
    [ArrayUtil arrayCopy:retData srcPos:num + 36 dst:dst8 dstPos:0 length:8];
    device.guidNode_Data4 = dst8;
    
    memset(dst4, 0, 4);
    [ArrayUtil arrayCopy:retData srcPos:num + 44 dst:dst4 dstPos:0 length:4];
    device.uiUnitPbuIP = dst4;
    
    memset(dst4, 0, 4);
    [ArrayUtil arrayCopy:retData srcPos:num + 48 dst:dst4 dstPos:0 length:4];
    device.uiUnitPbuIP = dst4;
    
    device.uiUnitID = (retData[num + 55] << 24 | retData[num + 54] << 16
                       | retData[num + 53] << 8 | retData[num + 52]);
    // System.arraycopy(buffer,i+52,uiUnitIP,0,4);
    memset(dst4, 0, 4);
    [ArrayUtil arrayCopy:retData srcPos:num + 56 dst:dst4 dstPos:0 length:4];
    device.uiServerIP = dst4;
    
    // uiUnitLocalIP=(buffer[i+51]<<24|buffer[i+50]<<16|buffer[i+49]<<8|buffer[i+48]);
    // uiServerIP=(buffer[i+59]<<24|buffer[i+58]<<16|buffer[i+57]<<8|buffer[i+56]);
    device.uiNodeID = (retData[num + 63] << 24 | retData[num + 62] << 16
                       | retData[num + 61] << 8 | retData[num + 60]);
    device.uiNodeType = (short) (retData[num + 65] << 8 | (retData[num + 64] & 0xff));
    device.uiNodeStatus = (short) (retData[num + 67] << 8 | retData[num + 66]);
    device.uiUserData1 = (retData[num + 71] << 24 | retData[num + 70] << 16
                          | retData[num + 69] << 8 | retData[num + 68]);
    device.uiUserData2 = (retData[num + 75] << 24 | retData[num + 74] << 16
                          | retData[num + 73] << 8 | retData[num + 72]);
    Byte dst200[200];
    memset(dst200, 0, 200);
    [ArrayUtil arrayCopy:retData srcPos:num + 76 dst:dst200 dstPos:0 length:200];
    device.chNodeInfo = dst200;
    
    // 获取镜头名称
    int nameLen = 0;
    while (dst200[nameLen] != 0) {
        nameLen++;
    }
    
    // System.out.print("第"+i+"镜头名称共占:"+index+"位");
    Byte NodeNameBuffer[nameLen];
    
    [ArrayUtil arrayCopy:dst200 srcPos:0 dst:NodeNameBuffer dstPos:0 length:nameLen];
    
    NSStringEncoding gbk = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    NSData *nameTemp = [[NSData alloc]initWithBytes:NodeNameBuffer length:nameLen];
    
    NSString *name = [[NSString alloc]initWithData:nameTemp encoding:gbk];

    device.nodeName = name;
    // System.out.println("第" + i + "镜头名称为:" + device.nodeName);
    memset(dst200, 0, 200);
    [ArrayUtil arrayCopy:retData srcPos:num + 276 dst:device.chNodeInfo dstPos:0 length:200];
    device.chNodeInfo = dst200;
    
    device.chRecordState = retData[num + 476];
    // i += 477;
    // return i;
}
-(void)showData:(Byte *) data{
    while(1){
        Log(@"%Xd",*data);
        data ++;
    }
}
-(void)dealloc{
}
@end
