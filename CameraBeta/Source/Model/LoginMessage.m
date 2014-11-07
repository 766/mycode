//
//  LoginMessage.m
//  CameraBeta
//
//  Created by 康伟 on 14-8-22.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import "LoginMessage.h"
@implementation LoginMessage
{
//@private LoginMsgBody *body;
@private LoginMsgHead *head;
@private Byte chbuffer[100];
}
@synthesize ip = _ip;
@synthesize port = _port ;
@synthesize username = _username;
@synthesize password = _password;
@synthesize usernameLength = _usernameLength;
@synthesize passwordLength = _passwordLength;
@synthesize MAC = _MAC;

-(id)init{
    self = [super init];
    if(self){
//        head = (__bridge LoginMsgHead *)([[MsgHead alloc]init]);
        head = malloc(sizeof(LoginMsgHead));
    }
    return self;
}
-(NSData *)getData:(int)sendType{
    head->protocolVerion = (short)0x0100;
    switch (sendType) {
        case 0:
            head->msgType = (Byte)0xa7;
            head->transactionNumber = (short)0x0000;
            head->length = (short)0x000a;
            break;
        case 1:
            head->msgType = (Byte)0x70;
            head->transactionNumber = (short)0x0001;
            break;
        case 2:
            head->msgType = (Byte)0x20;
            head->transactionNumber = (short)0x0002;
            break;
        case 3:
            head->msgType = (Byte)0x2b;
            head->transactionNumber = (short)0x0003;
            head->length = (short)0x001e;
            break;
        case 4:
            head->msgType = (Byte)0x21;
            head->transactionNumber = (short)0x0004;
            head->length = (short)0x001e;
            break;
        case 5:
            head->msgType = (Byte)0x1f;
            head->transactionNumber = (short)0x0005;
            head->length = (short)0x001e;
            break;
        case 6:
            head->msgType = (Byte)0x16;
            head->transactionNumber = (short)0x0006;
            head->length = 0x002b;
            break;
        default:
            break;
    }
#pragma mark 加入头文件
    Byte *temp;
    if(sendType != 6){
//        chbuffer = malloc(sizeof(Byte) * 100);
        memset(chbuffer, 0, 100);
        temp = [NumberUtil sToHL:head->protocolVerion];
        [ArrayUtil arrayCopy:temp srcPos:0 dst:chbuffer dstPos:0 length:2];
//        [self showData:temp];
        chbuffer[2] = head->msgType;
//        [self showData:chbuffer];
        temp = [NumberUtil sToHL:head->transactionNumber];
        [ArrayUtil arrayCopy:temp srcPos:0 dst:chbuffer dstPos:3 length:2];
//        [self showData:chbuffer];
    }else{
//        chbuffer = malloc(sizeof(Byte) * 512);
        memset(chbuffer, 0, 100);
        temp = [NumberUtil sToHL:head->protocolVerion];
        [ArrayUtil arrayCopy:temp srcPos:0 dst:chbuffer dstPos:0 length:2];
        chbuffer[2] = head->msgType;
        temp = [NumberUtil sToLH:head->transactionNumber];
        [ArrayUtil arrayCopy:temp srcPos:0 dst:chbuffer dstPos:3 length:2];
        temp = [NumberUtil sToLH:head->length];
        [ArrayUtil arrayCopy:temp srcPos:0 dst:chbuffer dstPos:5 length:2];
    }
    if (sendType == 6) {
        NSData *nbytes = [self.username dataUsingEncoding:NSUTF8StringEncoding];
        Byte *nameBytes = (Byte *)[nbytes bytes];
        [ArrayUtil arrayCopy:nameBytes srcPos:0 dst:chbuffer dstPos:7 length:[nbytes length]];
        NSData *pData = [self.password dataUsingEncoding:NSUTF8StringEncoding];
        Byte *pwdBytes = (Byte *)[pData bytes];
        if ([pData length] != 0) {
            [ArrayUtil arrayCopy:pwdBytes srcPos:0 dst:chbuffer dstPos:7 + 16 length:[pData length]];
        }
        //        [ArrayUtil arrayCopy:pwdBytes :0 :chbuffer :7 + 16 :[pData length]];
        int iVsipPort = 42190;
        temp = [NumberUtil itoLH:iVsipPort];
        [ArrayUtil arrayCopy:temp srcPos:0 dst:chbuffer dstPos:7 + 16 + 16 length:4];
    }else{
        /*------------------------旧方式----------------------------*/
//        Byte ia[4];
//        NetUtil *netUtil = [NetUtil sharedManager];
//        NSString *IPAddress = [netUtil deviceIPAddress];
//        NSLog(@"ip:%@",IPAddress);
//        int i = 0;
//        NSArray *ipArray = [IPAddress componentsSeparatedByString:@"."];
//        [netUtil freeAddress];
//        for(NSString *ipStr in ipArray){
//            int a = [ipStr intValue];
//            ia[i] = (Byte)(0xff & a);
//            i ++;
//        }
        /*------------------------------------------------------------*/
        NetUtil *netUtil = [NetUtil sharedManager];

        if (LOCALIPADDRESS == nil || [LOCALIPADDRESS isEqualToString:@""""]) {
            
            LOCALIPADDRESS = [netUtil deviceIPAddress];
        }
        
        const char *str = [LOCALIPADDRESS cStringUsingEncoding:NSUTF8StringEncoding];
        
        unsigned char ia[4] = {0,0,0,0};
        
        if(inet_pton(AF_INET, str, ia) < 0)
        {
            return nil;
        }
        
        [netUtil freeAddress];
        
//        [self showData:ia];
        [ArrayUtil arrayCopy:ia srcPos:0 dst:chbuffer dstPos:7 length:4];
//        [self showData:chbuffer];
        Byte *portTemp;
        portTemp = [NumberUtil sToHL:(short)42190];
        [ArrayUtil arrayCopy:portTemp srcPos:0 dst:chbuffer dstPos:11 length:2];
//        [self showData:chbuffer];
        if (sendType > 1 && sendType < 6) {
            sendType = 2;
        }
        switch (sendType) {
            case 1:
            {
                NSData *bytes ;
                Byte *nameBytes ;
                if (self.username != nil && ![self.username isEqualToString:@""""])
                {
                    Log(@"username:%@",self.username);
                    bytes = [self.username dataUsingEncoding:NSUTF8StringEncoding];
                    nameBytes = (Byte *)[bytes bytes];
                    self.usernameLength = [bytes length];
                    [ArrayUtil arrayCopy:nameBytes srcPos:0 dst:chbuffer dstPos:17 length:[bytes length]];

                }
                else
                {
                    self.usernameLength = 0;
                }
                
                
                NSData *pbytes;
                Byte *pwdBytes;
                
                if (self.password != nil && ![self.password isEqualToString:@""""])
                {
                    pbytes = [self.password dataUsingEncoding:NSUTF8StringEncoding];
                    pwdBytes = (Byte *)[pbytes bytes];
                    self.passwordLength = [pbytes length];
                    [ArrayUtil arrayCopy:pwdBytes srcPos:0 dst:chbuffer dstPos:17 + [bytes length] length:[pbytes length]];

                }
                else
                {
                    self.passwordLength = 0;
                }
                
                [ArrayUtil arrayCopy:[NumberUtil sToHL:self.usernameLength] srcPos:0 dst:chbuffer dstPos:13 length:2];
                [ArrayUtil arrayCopy:[NumberUtil sToHL:self.passwordLength] srcPos:0 dst:chbuffer dstPos:15 length:2];
//                [self showData:chbuffer];
//                [self showData:chbuffer];
                Byte *tempMac;
                if (self.MAC != nil) {
                    NSData *macData = [self.MAC dataUsingEncoding:NSUTF8StringEncoding];
                    tempMac = (Byte *)[macData bytes];
                    tempMac[0] = 0;
//                    [self showData:tempMac];
                    /*------------------------*/
                    [ArrayUtil arrayCopy:tempMac srcPos:0 dst:chbuffer dstPos:17 + [bytes length] + [pbytes length] length:17];
                    head->length = (short)(34 + self.usernameLength + self.passwordLength);
                    temp = [NumberUtil sToHL:head->length];
                    [ArrayUtil arrayCopy:temp srcPos:0 dst:chbuffer dstPos:5 length:2];
                }
//                [self showData:chbuffer];
                break;
            }
            case 2:
            {
                Byte *tempMac1;
                if (self.MAC != nil) {
                    NSData *macData1 = [self.MAC dataUsingEncoding:NSUTF8StringEncoding];
                    tempMac1 = (Byte *)[macData1 bytes];
                    tempMac1[0] = 0;
                    [ArrayUtil arrayCopy:tempMac1 srcPos:0 dst:chbuffer dstPos:13 length:16];
                    head->length = (short)0x001e;
                    temp = [NumberUtil sToHL:head->length];
                    [ArrayUtil arrayCopy:temp srcPos:0 dst:chbuffer dstPos:5 length:2];
                }
                break;
            }
        }
    }
    NSData *data = [[NSData alloc]initWithBytes:chbuffer length:head->length];

    return data;
}
-(void)showData:(Byte *) data{
    while(1){
        Log(@"%Xd",*data);
        data ++;
    }
}
-(void)dealloc{
    free(head);
    head = NULL;
//    free(chbuffer);
}
@end
