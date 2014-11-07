//
//  CameraViewController.m
//  CameraBeta
//
//  Created by 康伟 on 14-8-20.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import "LoginViewController.h"
#import "UIButton+Bootstrap.h"
@interface LoginViewController ()
@end
@implementation LoginViewController{
@private NSUserDefaults *userDef;
    enum LoginState loginState;
    MBProgressHUD *HUD;
}
@synthesize tf_username;
@synthesize tf_password;
@synthesize tf_serverip;
@synthesize btn_login;
@synthesize iv_logo;
@synthesize switchButton;
@synthesize is_open2_stream;
@synthesize inputUsername;
@synthesize inputPassword;
@synthesize inputServerip;


- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyBoard)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    [self.btn_login primaryStyle];
    /*initial view      *******/
    [self initView];
}

-(void)initView
{
    tf_username = [[JYTextField alloc]initWithFrame:CGRectMake(30, 210, 260, 38)
                                        cornerRadio:5
                                        borderColor:RGB(166, 166, 166)
                                        borderWidth:2
                                         lightColor:RGB(55, 154, 255)
                                          lightSize:8
                                   lightBorderColor:RGB(235, 235, 235)];
    
    [tf_username setClearButtonMode:UITextFieldViewModeWhileEditing];
    tf_username.keyboardType = UIKeyboardTypeASCIICapable;
    [tf_username setPlaceholder:@"用户名"];
    //    [self.tf_username setText:@"admin"];
    
    [self.view addSubview:tf_username];
    tf_password = [[JYTextField alloc]initWithFrame:CGRectMake(30, 265, 260, 38)
                                   cornerRadio:5
                                   borderColor:RGB(166, 166, 166)
                                   borderWidth:2
                                    lightColor:RGB(243, 168, 51)
                                     lightSize:8
                              lightBorderColor:RGB(235, 235, 235)];
    [tf_password setClearButtonMode:UITextFieldViewModeWhileEditing];
    [tf_password setPlaceholder:@"密码"];
    [tf_password setSecureTextEntry:YES];
    [self.view addSubview:tf_password];
    //    UIImageView *leftImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tf_pwd_lefimg.png"]];
    //    tf_pwd.leftView = leftImg;
    //    tf_pwd.leftViewMode = UITextFieldViewModeAlways;
    
    tf_serverip = [[JYTextField alloc]initWithFrame:CGRectMake(30,280+38, 260, 38)
                                        cornerRadio:7
                                        borderColor:RGB(166, 166, 166)
                                        borderWidth:2
                                         lightColor:RGB(133, 203, 51)
                                          lightSize:8
                                   lightBorderColor:RGB(235, 235, 235)];
    [tf_serverip setClearButtonMode:UITextFieldViewModeWhileEditing];
    [tf_serverip setPlaceholder:@"服务器IP"];
    tf_serverip.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    //    [tf_serverip setText:@"192.168.1.76"];
    [self.view addSubview:tf_serverip];
    
    /*set logo*/
    [iv_logo setImage:[UIImage imageNamed:@"logo_img2.png"]];
    
    
    [switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    
    [self showData];
    
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
    HUD.labelText = @"登录中...";
 
}

-(void)switchAction:(id)sender
{
    is_open2_stream = switchButton.isOn;
}
/*保存用户输入的数据*/
-(void)saveData:(NSString *)username password:(NSString *)password serverip:(NSString *)ip isOpen2Stream:(BOOL)is_open_2_stream
{
    userDef = [NSUserDefaults standardUserDefaults];
    [userDef setObject:username forKey:@"username"];
    [userDef setObject:password forKey:@"password"];
    [userDef setObject:ip forKey:@"serverip"];
    [userDef setBool:is_open_2_stream forKey:@"isOpen2Stream"];
    [userDef synchronize];
    Log(@"save success!");
}

-(void)showData
{
    userDef = [NSUserDefaults standardUserDefaults];
    NSString    *username = [userDef stringForKey:@"username"];
    NSString    *password = [userDef stringForKey:@"password"];
    NSString    *serverip = [userDef stringForKey:@"serverip"];
    is_open2_stream = [userDef boolForKey:@"isOpen2Stream"];
    username == nil ? [tf_username setText:@""]:[tf_username setText:username];
    password == nil ? [tf_password setText:@""]:[tf_password setText:password];
    serverip == nil ? [tf_serverip setText:@""]:[tf_serverip setText:serverip];
    [switchButton setOn:is_open2_stream];
    
}

-(void)dismissKeyBoard
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)login:(id)sender
{
    Log(@"click_loginBtn");
    AppDelegate *appDlg = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (!appDlg.isReachable)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"网络异常，请检查网络"  delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    inputUsername = tf_username.text;
    inputPassword = tf_password.text;
    inputServerip = tf_serverip.text;
    
    if ([TextUtil isEmpty:inputUsername])
    {
        return;
    }
    
    if (![TextUtil isValidIp:inputServerip]) {
        return;
    }
//    [NSThread detachNewThreadSelector:@selector(doLogin) toTarget:self withObject:nil];
    
    [HUD showWhileExecuting:@selector(doLogin) onTarget:self withObject:nil animated:YES];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setShouldToolbarUsesTextFieldTintColor:NO];
}
//-(void)setData
//{
//    
//}

-(void)doLogin
{
//    @autoreleasepool {
    LoginEngine *loginEngine = [[LoginEngine alloc]init];
    LoginMessage *msg = [[LoginMessage alloc]init];
    Log(@"dologin:username: %@",tf_username.text);
    msg.username = tf_username.text;
    msg.password = tf_password.text;
    msg.ip = tf_serverip.text;
    msg.MAC = [NetUtil macAddress];
    [loginEngine setLoginMessage:msg];
    loginState = [loginEngine login];
    [self performSelectorOnMainThread:@selector(processResult) withObject:nil waitUntilDone:YES];
//    }
}

-(void)processResult
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    switch (loginState)
    {
        case LOGIN_SUCCESS:
            Log(@"登陆成功");
            USERNAME = tf_username.text;
            PASSWORD = tf_password.text;
            SERVERIP = tf_serverip.text;
            IS_OPEN_2_STREAM = is_open2_stream;
            [self saveData:tf_username.text password:tf_password.text serverip:tf_serverip.text isOpen2Stream:is_open2_stream];
            [self performSegueWithIdentifier:@"GoToListViewSegue" sender:self];
            return;
        case LOGIN_USERNAME_ERROR:
            Log(@"用户名错误");
            [alert setMessage:@"用户名错误了，喵～～"];
            break;
        case LOGIN_PASSWORD_ERROR:
            Log(@"密码错误");
            [alert setMessage:@"密码错误了，喵～～"];
            break;
        case LOGIN_SERVER_ERROR:
            Log(@"服务器错误");
            [alert setMessage:@"服务器错误，请稍后重试"];
            break;
        default:
            break;
    }
    [alert show];
    
}
//-(BOOL)checkUserInfo
//{
//    if ([TextUtil isEmpty:tf_username.text]) {
//        return false;
//    }
//    
//    if(![TextUtil isValidIp:tf_serverip.text]){
//        return false;
//    }
//    inputUsername = tf_username.text;
//    inputPassword = tf_pwd.text;
//    inputServerip = tf_serverip.text;
//    return true;
//}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationMaskPortrait;
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
-(BOOL)shouldAutorotate
{
    return NO;
}

-(void)dealloc
{
    
}
@end
