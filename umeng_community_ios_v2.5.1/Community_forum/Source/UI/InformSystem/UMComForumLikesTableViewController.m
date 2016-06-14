//
//  UMComForumLikesTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/30.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumLikesTableViewController.h"
#import "UMComLike.h"
#import "UMComPullRequest.h"
#import "UMComForumUserCenterViewController.h"
#import "UMComPostContentViewController.h"
#import "UMComClickActionDelegate.h"
#import "UMComUnReadNoticeModel.h"
#import "UMComSession.h"
#import "UIViewController+UMComAddition.h"
#import "UMComWebViewController.h"
#import "UMComSysLikeTableViewCell.h"
#import "UMComFeed+UMComManagedObject.h"
#import "UMComUser.h"
#import "UMComTopic.h"
#import "UMComMutiStyleTextView.h"

@interface UMComForumLikesTableViewController ()<UITableViewDelegate, UMComClickActionDelegate>

@property (nonatomic, strong) NSMutableArray *likeDicts;

@end

@implementation UMComForumLikesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.likeDicts = [NSMutableArray array];
    [self setForumUITitle:UMComLocalizedString(@"um_com_receivedLike", @"收到的赞")];

    self.fetchRequest = [[UMComUserLikesReceivedRequest alloc]initWithCount:BatchSize];
    [self loadAllData:nil fromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [UMComSession sharedInstance].unReadNoticeModel.notiByLikeCount = 0;
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.likeDicts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UMComSysLikeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UMComSysLikeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID cellSize:CGSizeMake(tableView.frame.size.width, tableView.rowHeight)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.delegate = self;
    NSDictionary *likeDict = self.likeDicts[indexPath.row];
    [cell reloadCellWithObj:[likeDict valueForKey:@"like"]
                 timeString:[likeDict valueForKey:@"creat_time"]
                   mutiText:nil
               feedMutiText:[likeDict valueForKey:@"feedMutiText"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *likeDict = self.likeDicts[indexPath.row];
    return [[likeDict valueForKey:@"totalHeight"] floatValue];
}

#pragma mark - data handler

- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if ([data isKindOfClass:[NSArray class]] &&  data.count > 0) {
        [self.likeDicts removeAllObjects];
        [self.tableView reloadData];
        [self inserLikes:data];
    }
}

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        [self.likeDicts removeAllObjects];
        [self.tableView reloadData];
        [self inserLikes:data];
    }
}

- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataArray];
        [tempArray addObjectsFromArray:data];
        self.dataArray = tempArray;
        [self inserLikes:data];
    }
}

- (void)inserLikes:(NSArray *)dataArray
{
    for (UMComLike *like in dataArray) {
        NSDictionary *commentDict = [self likeDictDictionaryWithLike:like];
        [self.likeDicts addObject:commentDict];
        NSInteger index = self.likeDicts.count - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

//- (NSDictionary *)likeDictDictionaryWithLike:(UMComLike *)like
//{
//    CGFloat subViewWidth = self.view.frame.size.width - UMCom_SysCommonCell_SubViews_LeftEdge - UMCom_SysCommonCell_SubViews_RightEdge;
//    if ([self.fetchRequest isKindOfClass:[UMComUserCommentsSentRequest class]]) {
//        subViewWidth -= 15;
//    }
//    CGFloat totalHeight = UMCom_SysCommonCell_NameLabel_Height + UMCom_SysCommonCell_Content_TopEdge*2;
//    NSMutableDictionary *likeDict = [NSMutableDictionary dictionary];
//    [likeDict setValue:like forKey:@"like"];
//
//    NSMutableArray *feedCheckWords = nil;
//    UMComFeed *feed = like.feed;
//    NSString *feedString = feed.title;
//    if (![feedString isKindOfClass:[NSString class]] || feedString.length == 0) {
//        feedString = feed.text;
//    }
//    if ([feed.status integerValue] < FeedStatusDeleted) {
//        if (feedString.length > kFeedContentLength) {
//            feedString = [feedString substringWithRange:NSMakeRange(0, kFeedContentLength)];
//        }
//        feedCheckWords = [NSMutableArray array];
//        for (UMComTopic *topic in feed.topics) {
//            NSString *topicName = [NSString stringWithFormat:TopicString,topic.name];
//            [feedCheckWords addObject:topicName];
//        }
//        for (UMComUser *user in feed.related_user) {
//            NSString *userName = [NSString stringWithFormat:UserNameString,user.name];
//            [feedCheckWords addObject:userName];
//        }
//    }else{
//        feedString = UMComLocalizedString(@"Delete Content", @"该内容已被删除");
//    }
//    UMComMutiText *feedMutiText = [UMComMutiText mutiTextWithSize:CGSizeMake(subViewWidth-UMCom_SysCommonCell_FeedText_HorizonEdge*2, MAXFLOAT) font:UMComFontNotoSansLightWithSafeSize(14) string:feedString lineSpace:3 checkWords:feedCheckWords];
//    totalHeight += feedMutiText.textSize.height;
//    totalHeight += UMCom_SysCommonCell_Cell_BottomEdge;
//    NSString *timeString = createTimeString(like.create_time);
//    [likeDict setValue:timeString forKey:@"creat_time"];
//    [likeDict setValue:feedMutiText forKey:@"feedMutiText"];
//    [likeDict setValue:@(totalHeight) forKey:@"totalHeight"];
//    return likeDict;
//}

- (NSDictionary *)likeDictDictionaryWithLike:(UMComLike *)like
{
    NSMutableDictionary *commentDict = [NSMutableDictionary dictionary];
    CGFloat totalHeight = UMCom_SysCommonCell_Comment_UserNameTopMargin +
    UMCom_SysCommonCell_Comment_UserNameHeight +
    UMCom_SysCommonCell_Comment_SpaceBetweenUserNameAndComment;
    

    //加入默认的高度来填写文字：赞了这条评论
    totalHeight += UMCom_SysCommonCell_Comment_CommentDefaultHeight;
    
    //累加评论底部的边距
    totalHeight += UMCom_SysCommonCell_Comment_CommentBotoom;
    
    //获得feed相关的
    NSMutableArray *feedCheckWords = nil;
    UMComFeed *feed = like.feed;
    
    //获得feed的内容
    NSString *feedString = @"";
    if (feed.text) {
        feedString = feed.text;
    }
    
    if ([feed.status integerValue] < FeedStatusDeleted) {
        if (feedString.length > kFeedContentLength) {
            feedString = [feedString substringWithRange:NSMakeRange(0, kFeedContentLength)];
        }
        feedCheckWords = [NSMutableArray array];
        for (UMComTopic *topic in feed.topics) {
            NSString *topicName = [NSString stringWithFormat:TopicString,topic.name];
            [feedCheckWords addObject:topicName];
        }
        for (UMComUser *user in feed.related_user) {
            NSString *userName = [NSString stringWithFormat:UserNameString,user.name];
            [feedCheckWords addObject:userName];
        }
        //加入feed创建者自身
        if(feed.creator.name){
            NSString *userName = [NSString stringWithFormat:UserNameString,feed.creator.name];
            [feedCheckWords addObject:userName];
        }
        
    }else{
        feedString = UMComLocalizedString(@"um_com_deleteContent", @"该内容已被删除");
    }
    
    CGFloat feedMutiTextWidth = 0;
    if (feed.image_urls && [feed.image_urls count] > 0 ) {
        
        if ([feed.status integerValue] < FeedStatusDeleted)
        {
            //feed有图片并且不为删除状态
            //totalHeight的高度为有照片的默认高度,默认宽度也要减去UMCom_SysCommonCell_Feed_IMGWidth
            totalHeight += UMCom_SysCommonCell_FeedWithIMG_Height;
            feedMutiTextWidth = self.view.frame.size.width - UMCom_SysCommonCell_Comment_LeftMargin - UMCom_SysCommonCell_Comment_RightMargin - UMCom_SysCommonCell_Comment_UserImgWidth -UMCom_SysCommonCell_Comment_SpaceBetweenUserNameAndComment - UMCom_SysCommonCell_Feed_IMGMargin*2 - UMCom_SysCommonCell_Feed_IMGWidth;
        }
        else
        {
            
            //totalHeight的高度为无照片的默认高度
            //totalHeight的高度为有照片的默认高度,默认宽度不需要减去UMCom_SysCommonCell_Feed_IMGWidth
            totalHeight += UMCom_SysCommonCell_FeedWithoutIMG_Height;
            feedMutiTextWidth = self.view.frame.size.width - UMCom_SysCommonCell_Comment_LeftMargin - UMCom_SysCommonCell_Comment_RightMargin - UMCom_SysCommonCell_Comment_UserImgWidth -UMCom_SysCommonCell_Comment_SpaceBetweenUserNameAndComment - UMCom_SysCommonCell_Feed_IMGMargin*2;
        }
        
    }
    else
    {
        //feed没有图片 高度固定
        totalHeight += UMCom_SysCommonCell_FeedWithoutIMG_Height;
        feedMutiTextWidth = self.view.frame.size.width - UMCom_SysCommonCell_Comment_LeftMargin - UMCom_SysCommonCell_Comment_RightMargin - UMCom_SysCommonCell_Comment_UserImgWidth -UMCom_SysCommonCell_Comment_SpaceBetweenUserNameAndComment;
        
    }
    
    totalHeight += UMCom_SysCommonCell_BottomMargin;
    
    UMComMutiText *feedMutiText = [UMComMutiText mutiTextWithSize:CGSizeMake(feedMutiTextWidth, MAXFLOAT) font:UMComFontNotoSansLightWithSafeSize(12) string:feedString lineSpace:2 checkWords:feedCheckWords textColor:[UMComTools colorWithHexString:@"A5A5A5"]];
    
    [commentDict setValue:feedMutiText forKey:@"feedMutiText"];
    
    NSString *timeString = createTimeString(like.create_time);
    [commentDict setValue:like forKey:@"like"];
    [commentDict setValue:@(totalHeight) forKey:@"totalHeight"];
    [commentDict setValue:timeString forKey:@"creat_time"];
    
    return commentDict;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ClickActionDelegate
- (void)customObj:(id)obj clickOnFeedText:(UMComFeed *)feed
{
    UMComPostContentViewController *postContent = [[UMComPostContentViewController alloc]initWithFeed:feed];
    [self.navigationController pushViewController:postContent animated:YES];
}

- (void)customObj:(id)obj clickOnUser:(UMComUser *)user
{
    UMComForumUserCenterViewController *userCenter = [[UMComForumUserCenterViewController alloc]initWithUser:user];
    [self.navigationController pushViewController:userCenter animated:YES];
}

- (void)customObj:(id)obj clickOnURL:(NSString *)url
{
    UMComWebViewController * webViewController = [[UMComWebViewController alloc] initWithUrl:url];
    [self.navigationController pushViewController:webViewController animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
