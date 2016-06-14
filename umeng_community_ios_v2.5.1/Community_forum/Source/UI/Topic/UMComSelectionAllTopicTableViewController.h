//
//  UMComSelectionAllTopicTableViewController.h
//  UMCommunity
//
//  Created by 张军华 on 16/3/29.
//  Copyright © 2016年 Umeng. All rights reserved.
//

#import "UMComRequestTableViewController.h"
#import "UMComSelectionTopicDelegate.h"

/**
 *  全部话题选择界面(为编辑界面选择全部话题用的)
 */
@interface UMComSelectionAllTopicTableViewController : UMComRequestTableViewController

@property(nonatomic,weak)id<UMComSelectionTopicDelegate> selectionTopicDelegate;

@end
