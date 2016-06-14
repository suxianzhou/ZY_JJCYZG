//
//  UMComForumCommentTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/30.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumCommentTableViewController.h"
#import "UMComComment.h"
#import "UMComTools.h"
#import "UMComPullRequest.h"
#import "UMComClickActionDelegate.h"
#import "UMComUser.h"
#import "UMComSession.h"
#import "UMComCommentEditView.h"
#import "UMComPushRequest.h"
#import "UMComShowToast.h"
#import "UMComForumUserCenterViewController.h"
#import "UMComPostContentViewController.h"
#import "UMComUnReadNoticeModel.h"
#import "UIViewController+UMComAddition.h"
#import "UMComWebViewController.h"
#import "UMComTopicPostViewController.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComMutiStyleTextView.h"
#import "UMComImageView.h"
#import "UMComSysCommentCell.h"
#import "UMComFeed.h"
#import "UMComTopic.h"

#define kUMComCommentFinishNotification @"kUMComCommentFinishNotification"


@interface UMComForumCommentTableViewController ()<UMComClickActionDelegate>

@property (nonatomic, strong) UMComCommentEditView *commentEditView;

@property (nonatomic, strong) NSMutableArray *commentDics;


@end

@implementation UMComForumCommentTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self setForumUITitle:UMComLocalizedString(@"um_com_comment", @"评论")];
   
    self.commentDics = [NSMutableArray array];
    
    if ([self.fetchRequest isKindOfClass:[UMComUserCommentsSentRequest class]]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewCommentFromNotice:) name:kUMComCommentFinishNotification object:nil];
    }
}

- (void)addNewCommentFromNotice:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[UMComComment class]]) {
        [self commentModlesWithCommentData:@[notification.object]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITabelViewDeleagte

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commentDics.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    
    UMComSysCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UMComSysCommentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId cellSize:CGSizeMake(tableView.frame.size.width, tableView.rowHeight)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.delegate = self;
    if ([self.fetchRequest isKindOfClass:[UMComUserCommentsSentRequest class]]) {
        cell.replyButton.hidden = YES;
    }
    NSDictionary *commentDict = self.commentDics[indexPath.row];
    [cell reloadCellWithObj:[commentDict valueForKey:@"comment"]
                 timeString:[commentDict valueForKey:@"creat_time"]
                   mutiText:[commentDict valueForKey:@"commentMutiText"]
               feedMutiText:[commentDict valueForKey:@"feedMutiText"]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *commentModel = self.commentDics[indexPath.row];
    return [[commentModel valueForKey:@"totalHeight"] floatValue];
}

#pragma mark - data handel

- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if ([self.fetchRequest isKindOfClass:[UMComUserCommentsSentRequest class]]) {
        [UMComSession sharedInstance].unReadNoticeModel.notiByCommentCount = 0;
    }
    if ([data isKindOfClass:[NSArray class]] &&  data.count > 0) {
        [self.commentDics removeAllObjects];
        [self.tableView reloadData];
        self.dataArray = data;
        [self commentModlesWithCommentData:data];
    }
}

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        [self.commentDics removeAllObjects];
        [self.tableView reloadData];
        self.dataArray = data;
        [self commentModlesWithCommentData:data];
    }
}

- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        NSMutableArray *tempData = [NSMutableArray arrayWithArray:self.dataArray];
        [tempData addObject:data];
        self.dataArray = tempData;
        [self commentModlesWithCommentData:data];
    }
}

- (void)commentModlesWithCommentData:(NSArray *)dataArray
{
    for (UMComComment *comment in dataArray) {
        NSDictionary *commentDict = [self commentDictionaryWithComment:comment];
        [self.commentDics addObject:commentDict];
        NSInteger index = self.commentDics.count - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

/*
- (NSDictionary *)commentDictionaryWithComment:(UMComComment *)comment
{
    CGFloat subViewWidth = self.view.frame.size.width - UMCom_SysCommonCell_SubViews_LeftEdge - UMCom_SysCommonCell_SubViews_RightEdge;
    if ([self.fetchRequest isKindOfClass:[UMComUserCommentsSentRequest class]]) {
        subViewWidth -= 15;
    }
    CGFloat totalHeight = UMCom_SysCommonCell_NameLabel_Height + UMCom_SysCommonCell_Content_TopEdge*2;
    NSMutableDictionary *commentDict = [NSMutableDictionary dictionary];
    [commentDict setValue:comment forKey:@"comment"];
    if (comment.content) {
        NSMutableString * replayStr = [NSMutableString stringWithString:@""];
        NSMutableArray *checkWords = nil;
        if (comment.reply_user) {
            [replayStr appendString:UMComLocalizedString(@"um_com_replyComment", @"回复")];
            checkWords = [NSMutableArray arrayWithObject:[NSString stringWithFormat:UserNameString,comment.reply_user.name]];
            [replayStr appendFormat:UserNameString,comment.reply_user.name];
            [replayStr appendFormat:@"："];
        }
        if (comment.content) {
            [replayStr appendFormat:@"%@",comment.content];
        }
        UMComMutiText *mutiText = [UMComMutiText mutiTextWithSize:CGSizeMake(subViewWidth, MAXFLOAT) font:UMComFontNotoSansLightWithSafeSize(14) string:replayStr lineSpace:2 checkWords:checkWords];
        totalHeight += mutiText.textSize.height;
        [commentDict setValue:mutiText forKey:@"commentMutiText"];
    }
    NSMutableArray *feedCheckWords = nil;
    UMComFeed *feed = comment.feed;
    NSString *feedString = feed.title;
    if (![feedString isKindOfClass:[NSString class]] || feedString.length == 0) {
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
    }else{
        feedString = UMComLocalizedString(@"Delete Content", @"该内容已被删除");
    }
    UMComMutiText *feedMutiText = [UMComMutiText mutiTextWithSize:CGSizeMake(subViewWidth-UMCom_SysCommonCell_FeedText_HorizonEdge*2, MAXFLOAT) font:UMComFontNotoSansLightWithSafeSize(14) string:feedString lineSpace:3 checkWords:feedCheckWords];
    totalHeight += feedMutiText.textSize.height;
    totalHeight += UMCom_SysCommonCell_Cell_BottomEdge;
    NSString *timeString = createTimeString(comment.create_time);
    [commentDict setValue:timeString forKey:@"creat_time"];
    [commentDict setValue:feedMutiText forKey:@"feedMutiText"];
    [commentDict setValue:@(totalHeight) forKey:@"totalHeight"];
    return commentDict;
}
 */

- (NSDictionary *)commentDictionaryWithComment:(UMComComment *)comment
{
    NSMutableDictionary *commentDict = [NSMutableDictionary dictionary];
    CGFloat totalHeight = UMCom_SysCommonCell_Comment_UserNameTopMargin +
                          UMCom_SysCommonCell_Comment_UserNameHeight +
                          UMCom_SysCommonCell_Comment_SpaceBetweenUserNameAndComment;

    if (comment.content) {
        NSMutableString * replayStr = [NSMutableString stringWithString:@""];
        NSMutableArray *checkWords = nil;
        if (comment.reply_user) {
            [replayStr appendString:UMComLocalizedString(@"um_com_replyComment", @"回复")];
            checkWords = [NSMutableArray arrayWithObject:[NSString stringWithFormat:UserNameString,comment.reply_user.name]];
            [replayStr appendFormat:UserNameString,comment.reply_user.name];
            [replayStr appendFormat:@":"];
        }
        if (comment.content) {
            [replayStr appendFormat:@"%@",comment.content];
        }
        
        CGFloat subViewWidth = self.view.frame.size.width - UMCom_SysCommonCell_Comment_LeftMargin - UMCom_SysCommonCell_Comment_RightMargin - UMCom_SysCommonCell_Comment_UserImgWidth -UMCom_SysCommonCell_Comment_SpaceBetweenUserNameAndComment;
        if ([self.fetchRequest isKindOfClass:[UMComUserCommentsReceivedRequest class]]) {
            //如果是收到的评论，还需要减去快捷回复的按钮的宽度
            subViewWidth -= UMCom_SysCommonCell_Comment_replyBtnWidth;
        }
        
        UMComMutiText *mutiText = [UMComMutiText mutiTextWithSize:CGSizeMake(subViewWidth, MAXFLOAT) font:UMComFontNotoSansLightWithSafeSize(14) string:replayStr lineSpace:2 checkWords:checkWords textColor:        [UMComTools colorWithHexString:@"A5A5A5"]];
        totalHeight += mutiText.textSize.height;
        [commentDict setValue:mutiText forKey:@"commentMutiText"];
        //[commentDict setValue:@(subViewWidth) forKey:@"commentMutiTextWidth"];
    }
    else
    {
        //评论没有内容，加入默认的内容占位高度
        totalHeight += UMCom_SysCommonCell_Comment_CommentDefaultHeight;
    }
    
    //累加评论底部的边距
    totalHeight += UMCom_SysCommonCell_Comment_CommentBotoom;
    
    //获得feed相关的
    NSMutableArray *feedCheckWords = nil;
    UMComFeed *feed = comment.feed;
    
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
    //[commentDict setValue:@(feedMutiTextWidth) forKey:@"feedMutiTextWidth"];
    
    NSString *timeString = createTimeString(comment.create_time);
    [commentDict setValue:comment forKey:@"comment"];
    [commentDict setValue:@(totalHeight) forKey:@"totalHeight"];
    [commentDict setValue:timeString forKey:@"creat_time"];
    
    return commentDict;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UMComClickActionDelegate
- (void) customObj:(id)obj clickOnComment:(UMComComment *)comment feed:(UMComFeed *)feed
{
    if (!self.commentEditView) {
        self.commentEditView = [[UMComCommentEditView alloc]initWithSuperView:[UIApplication sharedApplication].keyWindow];
    }
    __weak typeof(self) weakSelf = self;
    self.commentEditView.SendCommentHandler = ^(NSString *commentText){
        [weakSelf postComment:commentText comment:comment feed:feed];
    };
    [self.commentEditView presentEditView];
    self.commentEditView.commentTextField.placeholder = [NSString stringWithFormat:@"回复%@",[[comment creator] name]];
}

- (void)postComment:(NSString *)content comment:(UMComComment *)comment feed:(UMComFeed *)feed
{
    [UMComPushRequest commentFeedWithFeed:feed
                           commentContent:content
                             replyComment:comment
                     commentCustomContent:nil
                                   images:nil
                               completion:^(id responseObject,NSError *error) {
                                   if (error) {
                                       [UMComShowToast showFetchResultTipWithError:error];
                                   }else{
                                        [[NSNotificationCenter defaultCenter] postNotificationName:kUMComCommentFinishNotification object:responseObject];
                                       [[NSNotificationCenter defaultCenter] postNotificationName:kUMComCommentOperationFinishNotification object:feed];
                                   }
                               }];
}


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

- (void)customObj:(id)obj clickOnTopic:(UMComTopic *)topic
{
    UMComTopicPostViewController *topicTableVc = [[UMComTopicPostViewController alloc] initWithTopic:topic];
    [self.navigationController pushViewController:topicTableVc animated:YES];
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




