//
//  UMComPostViewController.h
//  UMCommunity
//
//  Created by umeng on 15/11/17.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComRequestTableViewController.h"

#define UMCom_Forum_Post_Cell_Top_Edge 8

static NSString * UMComPostTableViewCellIdentifier = @"UMComPostTableViewCellIdentifier";

@class UMComFeed;
@class UMComTopFeedTableViewHelper;

/**
 *  论坛的所有feed列表的基类
 */
@interface UMComPostTableViewController : UMComRequestTableViewController

@property (nonatomic, assign) BOOL showTopMark;

@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, assign) BOOL showEditButton;


@property (nonatomic, assign) CGFloat cell_top_edge;

- (void)inserNewFeedInTabelView:(UMComFeed *)feed;

- (void)deleteNewFeedInTabelView:(UMComFeed *)feed;

//置顶feed的帮助类
@property(nonatomic,readwrite,strong,nullable)UMComTopFeedTableViewHelper* topFeedTableViewHelper;

#pragma mark - 判断当前Feed是否置顶(2.4新方法)
/**
 * 检查feed是否需要置顶标示(通过UMComFeed的is_topType字段)
 *
 *  @param feed 当前要显示的feed
 *
 *  @return YES 需要置顶 NO 不需要置顶
 */
-(BOOL) checkTopFeedWithFeed:(UMComFeed*)feed;

@end
