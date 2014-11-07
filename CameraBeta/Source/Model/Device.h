//
//  Device.h
//  CameraBeta
//
//  Created by 康伟 on 14-8-28.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject
@property(nonatomic) Byte * cobject;
@property(assign,nonatomic) NSInteger uiViewID;
@property(assign,nonatomic) NSInteger uiParentID;
@property(assign,nonatomic) NSInteger guidServer_Data1;
@property(assign,nonatomic) NSInteger guidServer_Data2;
@property(assign,nonatomic) NSInteger guidServer_Data3;
@property(assign,nonatomic) Byte * guidServer_Data4;
@property(assign,nonatomic) NSInteger guidNode_Data1;
@property(assign,nonatomic) NSInteger guidNode_Data2;
@property(assign,nonatomic) NSInteger guidNode_Data3;
@property(assign,nonatomic) Byte * guidNode_Data4;
@property(assign,nonatomic) Byte *  uiUnitPbuIP;
@property(assign,nonatomic) Byte *  uiUnitLocalIP;
@property(assign,nonatomic) NSInteger uiUnitID;
@property(assign,nonatomic) Byte *  uiServerIP;
@property(assign,nonatomic) NSInteger uiNodeID;
@property(assign,nonatomic) short uiNodeStatus;
@property(assign,nonatomic) NSInteger uiUserData1;
@property(assign,nonatomic) NSInteger uiUserData2;
@property(assign,nonatomic) Byte *  chNodeName;
@property(assign,nonatomic) Byte *  chNodeInfo;
@property(assign,nonatomic) NSInteger chRecordState;
@property(assign,nonatomic) short uiNodeType;
@property(copy,nonatomic) NSString *  nodeName;
@end
