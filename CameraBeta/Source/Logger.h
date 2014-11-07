//
//  Logger.h
//  CameraBeta
//
//  Created by 康伟 on 14-10-30.
//  Copyright (c) 2014年 wei. All rights reserved.
//
#define Debug 1
#ifndef CameraBeta_Logger_h
#define CameraBeta_Logger_h
#if Debug
#define Log(...) NSLog(__VA_ARGS__)
#else
#define Log(...)
#endif
#endif
