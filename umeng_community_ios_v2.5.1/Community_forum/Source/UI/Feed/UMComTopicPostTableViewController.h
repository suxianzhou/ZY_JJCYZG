//
//  UMComTopicPostTableViewController.h
//  UMCommunity
//
//  Created by umeng on 15/12/30.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComPostTableViewController.h"

@class UMComTopic;

/**
 * 从单个话题进入feed列表(比如：最新发布，最后回复，推荐)
 */
@interface UMComTopicPostTableViewController : UMComPostTableViewController

- (instancetype)initWithTopic:(UMComTopic *)topic;

@property (nonatomic, strong) UMComTopic *topic;

@end

/**
 *  单个话题界面，最新发布的列表(此处做子类为了获得编辑界面的发送feed的通知kNotificationPostFeedResultNotification，能够及时更新)
 */
@interface UMComTopicPostLatestFeedTableViewController : UMComTopicPostTableViewController

@end
