//
//  AppDelegate.h
//  Camera
//
//  Created by 康伟 on 14-9-28.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    Reachability *hostReach;
}

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL isReachable;
//@property (setter = )
@end
