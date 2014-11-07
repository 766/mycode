//
//  LoginEngine.h
//  CameraBeta
//
//  Created by 康伟 on 14-8-22.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseEngine.h"
#import "LoginMessage.h"
#import "ArrayUtil.h"
#import "LoginMessage.h"
#import "Global.h"
enum LoginState{
    LOGIN_SUCCESS,
    LOGIN_USERNAME_ERROR,
    LOGIN_PASSWORD_ERROR,
    LOGIN_SERVER_ERROR,
};
//NSInteger LOGIN_SUCCESS;
//NSInteger LOGIN_USERNAME_ERROR;
//NSInteger LOGIN_PASSWORD_ERROR;
//NSInteger LOGIN_SERVER_ERROR;
@interface LoginEngine : BaseEngine
@property(strong,setter = setLoginMessage:) LoginMessage *loginMsg;
-(enum LoginState)login;
@end
