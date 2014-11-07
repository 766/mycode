//
//  DevicesListControllerViewController.m
//  CameraBeta
//
//  Created by 康伟 on 14-8-28.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import "DevicesListControllerViewController.h"

@interface DevicesListControllerViewController ()

@end
extern NSString *NOTIFICATIONNAME;
@implementation DevicesListControllerViewController
{
@private NSMutableArray *arrayTemp;
@private NSArray *list;
//@private MBHUDView *HUD;
}

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
    //    [self getDevices];
    [NSThread detachNewThreadSelector:@selector(doGet) toTarget:self withObject:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reachabilityChanged:) name:NOTIFICATIONNAME object:nil];
}

/**刷新数据**/
-(void)reflashData
{
    [self.tableView reloadData];
}

-(void)reachabilityChanged:(id)sender
{
    [self reflashData];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated{
    
}
-(void)getDevices{
    //    HUD = [MBHUDView hudWithBody:@"正在拼命获取列表。。。" type:MBAlertViewHUDTypeActivityIndicator hidesAfter:0.0 show:YES];
    
}
-(void)doGet
{
    GetDevicesEngine *engine = [[GetDevicesEngine alloc]init];
    LoginMessage *msg = [[LoginMessage alloc]init];
    for (int i = 2; i < 7; i ++) {
        msg.MAC = [NetUtil macAddress];
        if (i == 6) {
            [msg setMAC:nil];
            [msg setUsername:USERNAME];
            [msg setPassword:PASSWORD];
        }
        arrayTemp = [engine getDevices:msg :i :SERVERIP];
    }
    Log(@"list's count:%lu",(unsigned long)[list count]);
    //        DDLogDebug(@"name:%@",[dev nodeName]);
    //        DDLogDebug(@"statu:%d",[dev uiNodeStatus]);
    //        DDLogDebug(@"uiType:%d",[dev uiNodeType]);
    list = [NSArray arrayWithArray:arrayTemp];
    for (Device *dev in list)
    {
        if ([dev uiNodeType] != 2)
        {
            [arrayTemp removeObject:dev];
        }
    }
    list = [NSArray arrayWithArray:arrayTemp];
    
    Log(@"list's count:%lu",(unsigned long)[arrayTemp count]);
    
    if (list!= nil && [list count] > 0)
    {
        [self performSelectorOnMainThread:@selector(preparedData) withObject:nil waitUntilDone:NO];
    }
}

-(void)preparedData{
    //    [HUD dismiss];
    //    [[self tableView] reloadData];
    [self reflashData];
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
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PlayViewSegue"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        PlayViewController *playViewController = segue.destinationViewController;
        
        playViewController.device = [list objectAtIndex:indexPath.row];
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [list count];
    
    if (count == 0) {
        return kCustomRowCount;
    }
    return count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *devicesTableIdentifier = @"CustomCell";
    
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:devicesTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[CustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:devicesTableIdentifier];
    }
    
    AppDelegate *appDlg = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if (!appDlg.isReachable)
    {
        cell.userInteractionEnabled = NO;
    }
    else
    {
        cell.userInteractionEnabled = YES;
    }
    Log(@"UiNodeStatus:%d",[[list objectAtIndex:indexPath.row] uiNodeStatus]);
    
    [cell.camera_name_lable setTextColor:[UIColor blackColor]];
    
    cell.userInteractionEnabled = YES;
    NSString *nodeName = [[list objectAtIndex:indexPath.row] nodeName];
    
    if (list != nil && [[list objectAtIndex:indexPath.row]uiNodeType] == 2)
    {
        if ([[list objectAtIndex:indexPath.row]uiNodeStatus] == 0)
        {
            [cell.camera_name_lable setTextColor:[UIColor redColor]];
            cell.userInteractionEnabled = NO;
        }
        
        if ([nodeName contains:@"HAVEPTZ"])
        {
            nodeName = [nodeName split:@"HAVEPTZ"][1];
            Log(@"nodeName:%@",nodeName);
            cell.camera_icon_iv.image = [UIImage imageNamed:@"camera_ptz.png"];
        }
        else
        {
            cell.camera_icon_iv.image = [UIImage imageNamed:@"camera_icon.9.png"];
        }
    }
    cell.camera_name_lable.text = nodeName;
    return cell;
}
@end
