//
//  UMComForumUserCenterViewController.h
//  UMCommunity
//
//  Created by umeng on 15/11/27.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComViewController.h"

@class UMComUser;
@protocol UMComUserOperationFinishDelegate;
@interface UMComForumUserCenterViewController : UMComViewController

@property (nonatomic, weak) id<UMComUserOperationFinishDelegate> userOperationFinishDelegate;

- (instancetype)initWithUser:(UMComUser *)user;

@end