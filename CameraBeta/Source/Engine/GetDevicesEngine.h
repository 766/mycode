//
//  GetDevicesEngine.h
//  CameraBeta
//
//  Created by 康伟 on 14-8-28.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import "BaseEngine.h"
#import "Device.h"
#import "ArrayUtil.h"
#import "Global.h"
@interface GetDevicesEngine : BaseEngine
-(NSMutableArray *)getDevices:(Message *)msg :(NSInteger)sendType :(NSString *)host;
@end
