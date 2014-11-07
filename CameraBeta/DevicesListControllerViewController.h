//
//  DevicesListControllerViewController.h
//  CameraBeta
//
//  Created by 康伟 on 14-8-28.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetDevicesEngine.h"
#import "LoginMessage.h"
#import "Global.h"
#import "CustomTableViewCell.h"
#import "NSStringWrapper.h"
#include "PlayViewController.h"
//#import "MBHUDView.h"
#import "AppDelegate.h"
#define kCustomRowCount     7
//extern NSString *USERNAME;
//extern NSString *PASSWORD;
//extern NSString *SERVERIP;
@interface DevicesListControllerViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
