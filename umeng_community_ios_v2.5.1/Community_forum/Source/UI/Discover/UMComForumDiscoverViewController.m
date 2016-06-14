//
//  UMComForumFindViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/17.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumDiscoverViewController.h"
#import "UMComSession.h"
#import "UMComPostTableViewController.h"
#import "UMComPullRequest.h"
#import "UMComPostNearbyTableViewController.h"
#import "UMComPhotoAlbumViewController.h"

#import "UMComForumInformCenterTableViewController.h"
#import "UMComForumUserCenterViewController.h"
#import "UMComForumTopicTableViewController.h"
#import "UMComUserNearbyViewController.h"



@interface UMComForumDiscoverViewController ()

@end

@implementation UMComForumDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)tranToCircleFriends
{
    UMComPostTableViewController *friendViewController = [[UMComPostTableViewController alloc]init];
    friendViewController.fetchRequest = [[UMComFriendFeedsRequest alloc]initWithCount:BatchSize];
    friendViewController.isAutoStartLoadData = YES;
    friendViewController.cell_top_edge = UMCom_Forum_Post_Cell_Top_Edge;
    friendViewController.isLoadLoacalData = NO;
    friendViewController.title = UMComLocalizedString(@"um_com_friend", @"好友圈");
    [self.navigationController pushViewController:friendViewController animated:YES];
}

- (void)tranToFollowedTopic
{
    UMComForumTopicTableViewController *topicViewController = [[UMComForumTopicTableViewController alloc]init];
    topicViewController.isAutoStartLoadData = YES;
    topicViewController.fetchRequest = [[UMComUserTopicsRequest alloc]initWithUid:[UMComSession sharedInstance].loginUser.uid count:BatchSize];
    [self.navigationController pushViewController:topicViewController animated:YES];
}

- (void)tranToAlbum
{
    UMComPhotoAlbumViewController *photoAlbumVc = [[UMComPhotoAlbumViewController alloc]init];
    photoAlbumVc.user = [UMComSession sharedInstance].loginUser;
    [self.navigationController pushViewController:photoAlbumVc animated:YES];
}

- (void)tranToNearby
{
    UMComPostNearbyTableViewController *nearbyFeedController = [[UMComPostNearbyTableViewController alloc]init];
    nearbyFeedController.cell_top_edge = UMCom_Forum_Post_Cell_Top_Edge;
    nearbyFeedController.title = UMComLocalizedString(@"um_com_nearbyRecommend", @"附近内容");
    [self.navigationController pushViewController:nearbyFeedController animated:YES];
}

- (void)tranToNearbyUsers
{
    UMComUserNearbyViewController *userViewController = [[UMComUserNearbyViewController alloc] init];
    userViewController.isAutoStartLoadData = YES;
    userViewController.callbackBlock = ^(UMComUserTableViewController *controller, UMComUserTableViewCallBackEvent event, UMComUser *user) {
        UMComForumUserCenterViewController *vc = [[UMComForumUserCenterViewController alloc] initWithUser:user];
        vc.userOperationFinishDelegate = controller.userOperationFinishDelegate;
        [controller.navigationController pushViewController:vc animated:YES];
    };
    userViewController.title = UMComLocalizedString(@"user_recommend", @"附近用户");
    [self.navigationController  pushViewController:userViewController animated:YES];
}

- (void)tranToRealTimeFeeds
{
    UMComPostTableViewController *realTimeFeedsViewController = [[UMComPostTableViewController alloc] initWithFetchRequest:[[UMComAllNewFeedsRequest alloc]initWithCount:BatchSize]];
    realTimeFeedsViewController.isAutoStartLoadData = YES;
    realTimeFeedsViewController.cell_top_edge = UMCom_Forum_Post_Cell_Top_Edge;
    realTimeFeedsViewController.isLoadLoacalData = NO;
    realTimeFeedsViewController.title = UMComLocalizedString(@"um_com_newcontent", @"实时内容");
    [self.navigationController  pushViewController:realTimeFeedsViewController animated:YES];
}

- (void)tranToRecommendUsers
{
    UMComUserTableViewController *userViewController = [[UMComUserTableViewController alloc] init];
    userViewController.fetchRequest = [[UMComRecommendUsersRequest alloc]initWithCount:BatchSize];
    userViewController.isAutoStartLoadData = YES;
    userViewController.callbackBlock = ^(UMComUserTableViewController *controller, UMComUserTableViewCallBackEvent event, UMComUser *user) {
        UMComForumUserCenterViewController *vc = [[UMComForumUserCenterViewController alloc] initWithUser:user];
        vc.userOperationFinishDelegate = controller.userOperationFinishDelegate;
        [controller.navigationController pushViewController:vc animated:YES];
    };
    userViewController.title = UMComLocalizedString(@"user_recommend", @"用户推荐");
    [self.navigationController  pushViewController:userViewController animated:YES];
}

- (void)tranToRecommendTopics
{
    UMComForumTopicTableViewController *topicsRecommendViewController = [[UMComForumTopicTableViewController alloc] init];
    topicsRecommendViewController.title = UMComLocalizedString(@"um_com_user_topic_recommend", @"推荐话题");
    topicsRecommendViewController.fetchRequest = [[UMComRecommendTopicsRequest alloc]initWithCount:BatchSize];
    topicsRecommendViewController.isAutoStartLoadData = YES;
    [self.navigationController  pushViewController:topicsRecommendViewController animated:YES];
}

- (void)tranToUsersFavourites
{
    UMComPostTableViewController *favouratesViewController = [[UMComPostTableViewController alloc] init];
    favouratesViewController.cell_top_edge = UMCom_Forum_Post_Cell_Top_Edge;
    favouratesViewController.fetchRequest = [[UMComUserFavouritesRequest alloc] init];
    favouratesViewController.title = UMComLocalizedString(@"um_com_user_collection", @"我的收藏");
    favouratesViewController.isAutoStartLoadData = YES;
    [self.navigationController  pushViewController:favouratesViewController animated:YES];
}

- (void)tranToUsersNotice
{
    UMComForumInformCenterTableViewController *userNewaNoticeViewController = [[UMComForumInformCenterTableViewController alloc] init];
    [self.navigationController  pushViewController:userNewaNoticeViewController animated:YES];
}

- (void)tranToUserCenter
{
    UMComForumUserCenterViewController *userCenterViewController = [[UMComForumUserCenterViewController alloc] initWithUser:[UMComSession sharedInstance].loginUser];
    [self.navigationController pushViewController:userCenterViewController animated:YES];
}


@end
