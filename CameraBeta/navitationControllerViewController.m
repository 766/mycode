//
//  navitationControllerViewController.m
//  CameraBeta
//
//  Created by 康伟 on 14-11-4.
//  Copyright (c) 2014年 wei. All rights reserved.
//

#import "navitationControllerViewController.h"

@interface navitationControllerViewController ()

@end

@implementation navitationControllerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
//    
//    if ([self.topViewController isKindOfClass:[DevicesListControllerViewController class]]) {
//        return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown );
//    }else if ([self.topViewController isKindOfClass:[PlayViewController class]]){
//        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown );
//    }
//    return NO;
//}
//-(NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskAllButUpsideDown;
//}
//-(BOOL)shouldAutorotate
//{
//    if ([self.topViewController isKindOfClass:[PlayViewController class]])
//    {
//        return YES;
//    }
//    else
//    {
//        return NO;
//    }
//    return NO;
//}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([self.topViewController isKindOfClass:[DevicesListControllerViewController class]]) {
        return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    }else if([self.topViewController isKindOfClass:[PlayViewController class]]){
        return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    }
    return UIInputViewStyleDefault;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
@end
