//
//  UMComSelectionTopicViewController.h
//  UMCommunity
//
//  Created by 张军华 on 16/3/28.
//  Copyright © 2016年 Umeng. All rights reserved.
//

#import "UMComViewController.h"

@class UMComTopic;
//选择话题成功的回调
typedef void(^SelectionTopicComplete)(UMComTopic* topic,NSError* error);
/**
 *  论坛版本编辑界面选择话题的ViewController
 */
@interface UMComSelectionTopicViewController : UMComViewController

@property(nonatomic,copy)SelectionTopicComplete selectionTopicComplete;

@end
