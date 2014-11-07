//
//  CameraViewController.h
//  CameraBeta
//
//  Created by 康伟 on 14-8-20.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JYTextField.h"
#import "TextUtil.h"
#import "MBProgressHUD.h"
#import "Message.h"
#import "LoginMessage.h"
#import "LoginEngine.h"
#import "ArrayUtil.h"
#import "loginEngine.h"
#import "Global.h"
#import "AppDelegate.h"
#import "IQKeyboardManager.h"
#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
@interface  LoginViewController: UIViewController<UIGestureRecognizerDelegate>
@property(nonatomic)BOOL is_open2_stream;
@property (strong,nonatomic)JYTextField *tf_username;
@property (strong,nonatomic)JYTextField *tf_password;
@property (strong,nonatomic)JYTextField *tf_serverip;
@property (copy,nonatomic)  NSString *inputUsername;
@property (copy,nonatomic) NSString *inputPassword;
@property (copy,nonatomic)  NSString *inputServerip;
@property (weak, nonatomic) IBOutlet UIImageView *iv_logo;
@property (weak, nonatomic) IBOutlet UIButton *btn_login;
- (IBAction)login:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;

@end
