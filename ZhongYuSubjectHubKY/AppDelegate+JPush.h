//
//  AppDelegate+JPush.h
//  ZhongYuSubjectHubKY
//
//  Created by zhongyu on 16/5/21.
//  Copyright © 2016年 RyeWhiskey. All rights reserved.
//

#import "AppDelegate.h"
#import "JPUSHService.h"
#import "RWTabBarViewController.h"

#define JPUSH_KEY @"7416f870c8b3b834a9dddff1"

@interface AppDelegate (JPush)

- (void)initJPushWithLaunchOptions:(NSDictionary *) launchOptions;

- (void)examinePushInformation;

@end
