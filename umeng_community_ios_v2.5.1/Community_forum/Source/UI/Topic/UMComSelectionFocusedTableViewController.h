//
//  UMComSelectionFocusedTableViewController.h
//  UMCommunity
//
//  Created by 张军华 on 16/3/29.
//  Copyright © 2016年 Umeng. All rights reserved.
//

#import "UMComRequestTableViewController.h"
#import "UMComSelectionTopicDelegate.h"

/**
 *  用户关注话题选择界面(为编辑界面选择关注话题用的)
 */
@interface UMComSelectionFocusedTableViewController : UMComRequestTableViewController

@property(nonatomic,weak)id<UMComSelectionTopicDelegate> selectionTopicDelegate;

@end
