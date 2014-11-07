//
//  PlayViewController.h
//  CameraBeta
//
//  Created by 康伟 on 14-9-3.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
#import "NSStringWrapper.h"
#import "IsH264Message.h"
#import "RequestDataTypeMsg.h"
#import "NetUtil.h"
#import "MONActivityIndicatorView.h"
//#import "VideoDecoder.h"
//#import "colorconvert.h"
#import "H264/h264.h"
@interface PlayViewController : UIViewController<AsyncSocketDelegate>
@property Device *device;
@property (weak, nonatomic) IBOutlet UIImageView *VideoView;
@end
