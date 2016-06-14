//
//  UMComTopicPostViewController.m
//  UMCommunity
//
//  Created by umeng on 12/2/15.
//  Copyright © 2015 Umeng. All rights reserved.
//

#import "UMComTopicPostViewController.h"
#import "UMComHorizonCollectionView.h"
#import "UMComTools.h"
#import "UMComTopic.h"
#import "UMComBarButtonItem.h"
#import "UMComPushRequest.h"
#import "UMComPostingViewController.h"
#import "UMComNavigationController.h"
#import "UMComLoginManager.h"
#import "UMComPullRequest.h"
#import "UIViewController+UMComAddition.h"
#import "UMComTopicPostTableViewController.h"
#import "UMComHotPostViewController.h"
#import "UMComTopFeedTableViewHelper.h"

//颜色值
#define UMCom_Forum_TopicPost_TopMenu_NomalTextColor @"#999999"
#define UMCom_Forum_TopicPost_TopMenu_HighLightTextColor @"#008BEA"
#define UMCom_Forum_TopicPost_DropMenu_NomalTextColor @"#8F8F8F"
#define UMCom_Forum_TopicPost_DorpMenu_HighLightTextColor @"#F5F5F5"

//文字大小
#define UMCom_Forum_TopicPost_TopMenu_TextFont 18
#define UMCom_Forum_TopicPost_DropMenu_TextFont 15

#define UMCom_Forum_TopicPost_MenuHeight 49

@interface UMComTopicPostViewController ()
<UMComHorizonCollectionViewDelegate>

@property (nonatomic, strong) UMComTopic *topic;

@property (nonatomic, strong) UMComHorizonCollectionView *menuView;

@property (nonatomic, strong) UIViewController *currentController;

@property (nonatomic, assign) CGRect originFrame;

@end

@implementation UMComTopicPostViewController

- (instancetype)initWithTopic:(UMComTopic *)topic
{
     // TODO:check topic 
    if (self = [super init]) {
        self.topic = topic;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.originFrame = self.view.bounds;
    [self setForumUITitle:_topic.name];
    
    [self setForumUIBackButton];
    
    [self createSubControllers];
    
    [self transitionChildViewControllers];
    
    [self creatNavigationItemList];
    
    self.view.backgroundColor = UMComTableViewSeparatorColor;

}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    // in viewDidLoad UICollectionViewCell 不会创建
    if (!_menuView) {
        UMComHorizonCollectionView *collectionMenuView = [[UMComHorizonCollectionView alloc]initWithFrame:CGRectMake(0, 1, self.view.frame.size.width, UMCom_Forum_TopicPost_MenuHeight) itemCount:4];
        collectionMenuView.indicatorLineHeight = 2;
        collectionMenuView.itemSpace = 1;
        collectionMenuView.bottomLineHeight = 1;
        collectionMenuView.bottomLine.backgroundColor = UMComTableViewSeparatorColor;
        collectionMenuView.indicatorLineWidth = UMComWidthScaleBetweenCurentScreenAndiPhone6Screen(70.f);
        collectionMenuView.indicatorLineLeftEdge = UMComWidthScaleBetweenCurentScreenAndiPhone6Screen(12);
        collectionMenuView.backgroundColor = UMComTableViewSeparatorColor;
        collectionMenuView.cellDelegate = self;
        collectionMenuView.scrollIndicatorView.backgroundColor = UMComColorWithColorValueString(UMCom_Forum_TopicPost_TopMenu_HighLightTextColor);;
        self.menuView = collectionMenuView;
    }
    
    if (![_menuView superview]) {
        [self.view addSubview:_menuView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)createSubControllers
{
    CGRect frame = self.originFrame;
    frame.origin.y = UMCom_Forum_TopicPost_MenuHeight + 1;
    frame.size.height = self.originFrame.size.height - frame.origin.y;
    frame.origin.x = 0;
    for (int index = 0; index < 3; index ++) {
        UMComTopicPostTableViewController *topicTableViewController = nil;
        if (index == 0) {
            topicTableViewController = [[UMComTopicPostLatestFeedTableViewController alloc]initWithTopic:self.topic];
        }
        else{
            topicTableViewController = [[UMComTopicPostTableViewController alloc]initWithTopic:self.topic];
        }
        
        if (index == 0) {
            topicTableViewController.isAutoStartLoadData = YES;
            topicTableViewController.showTopMark = YES;
            UMComTopicFeedsRequest *topicFeedsRequest = [[UMComTopicFeedsRequest alloc]initWithTopicId:self.topic.topicID count:BatchSize order:UMComFeedSortTypeDefault isReverse:YES];
            topicTableViewController.fetchRequest = topicFeedsRequest;
            topicFeedsRequest.isShowGlobalTopItems = NO;//不显示全局置顶
            
            //添加置顶类---begin
            UMComTopFeedTableViewHelper* tempTopFeedTableViewHelper =  [[UMComTopFeedTableViewHelper alloc] init];
            tempTopFeedTableViewHelper.topFeedRequest = [[UMComTopicTopFeedRequest alloc] initwithTopFeedCount:BatchSize topFeedTopicID:self.topic.topicID];
            topicTableViewController.topFeedTableViewHelper = tempTopFeedTableViewHelper;
            topicTableViewController.showTopMark = YES;
            tempTopFeedTableViewHelper.isTopicFeed = YES;
            //添加置顶类---end
            
            [self.view addSubview:topicTableViewController.view];
        }else if(index == 1){
            UMComTopicFeedsRequest *topicFeedsRequest = [[UMComTopicFeedsRequest alloc]initWithTopicId:self.topic.topicID count:BatchSize order:UMComFeedSortTypeComment isReverse:YES];
            topicFeedsRequest.isShowGlobalTopItems = NO;//不显示全局置顶
            //topicTableViewController.showTopMark = YES;
            topicTableViewController.fetchRequest = topicFeedsRequest;
        }else if(index == 2){
            topicTableViewController.fetchRequest = [[UMComTopicRecommendFeedsRequest alloc]initWithTopicId:self.topic.topicID count:BatchSize];            
        }
        topicTableViewController.cell_top_edge = UMCom_Forum_Post_Cell_Top_Edge;
        topicTableViewController.view.frame = frame;
        [self addChildViewController:topicTableViewController];
    }
    
    UMComHotPostViewController *hostViewController = [[UMComHotPostViewController alloc]initWithTopic:self.topic];
    hostViewController.view.frame = frame;
    [self addChildViewController:hostViewController];
}


- (void)creatNavigationItemList
{
//    UMComBarButtonItem *editButton = [[UMComBarButtonItem alloc] initWithNormalImageName:@"um_forum_post_edit_highlight" target:self action:@selector(showPostEditViewController:)];
//    editButton.customButtonView.frame = CGRectMake(0, 0, 20, 20);
//    editButton.customButtonView.titleLabel.font = UMComFontNotoSansLightWithSafeSize(17);
    UMComBarButtonItem *topicFocusedButton = nil;
    if ([[self.topic is_focused] boolValue]) {
        topicFocusedButton = [[UMComBarButtonItem alloc] initWithNormalImageName:@"um_forum_topic_focused" target:self action:@selector(followTopic:)];;
    }else{
       topicFocusedButton = [[UMComBarButtonItem alloc] initWithNormalImageName:@"um_forum_topic_nofocused" target:self action:@selector(followTopic:)];
    }
    topicFocusedButton.customButtonView.frame = CGRectMake(0, 0, 20, 20);
    topicFocusedButton.customButtonView.titleLabel.font = UMComFontNotoSansLightWithSafeSize(17);
    [self.navigationItem setRightBarButtonItem:topicFocusedButton];
//    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]init];
//    UIView *spaceView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 20)];
//    spaceView.backgroundColor = [UIColor clearColor];
//    [spaceItem setCustomView:spaceView];
//    
//    UMComBarButtonItem *rightSpaceItem = [[UMComBarButtonItem alloc] init];
//    rightSpaceItem.customButtonView.frame = CGRectMake(0, 12, 20, 4);
//    rightSpaceItem.customButtonView.titleLabel.font = UMComFontNotoSansLightWithSafeSize(17);
//    [self.navigationItem setRightBarButtonItems:@[rightSpaceItem,topicFocusedButton,spaceItem,]];
}

- (void)showPostEditViewController:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    [UMComLoginManager performLogin:self completion:^(id responseObject, NSError *error) {
        if (!error) {
            UMComPostingViewController *editViewController = [[UMComPostingViewController alloc]initWithTopic:weakSelf.topic];
            editViewController.postCreatedFinish = ^(UMComFeed *feed){
            };
            UMComNavigationController *navigationController = [[UMComNavigationController alloc]initWithRootViewController:editViewController];
            [weakSelf presentViewController:navigationController animated:YES completion:nil];
        }
    }];
}

- (void)followTopic:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    [UMComLoginManager performLogin:self completion:^(id responseObject, NSError *error) {
        if (!error) {
            [UMComPushRequest followerWithTopic:weakSelf.topic isFollower:![weakSelf.topic.is_focused boolValue] completion:^(NSError *error) {
                if ([weakSelf.topic.is_focused boolValue]) {
                    [sender setBackgroundImage:UMComImageWithImageName(@"um_forum_topic_focused") forState:UIControlStateNormal];
                }else{
                    [sender setBackgroundImage:UMComImageWithImageName(@"um_forum_topic_nofocused") forState:UIControlStateNormal];
                }
            }];
        }
    }];
}


#pragma mark - HorizionMenuViewDelegate
- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView reloadCell:(UMComHorizonCollectionCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.label.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height-self.menuView.indicatorLineHeight);
    if (indexPath.row == 0) {
        cell.label.text = UMComLocalizedString(@"um_com_topic_latest_post", @"最新发布");
    }else if (indexPath.row == 1){
        cell.label.text = UMComLocalizedString(@"um_com_topic_latest_reply", @"最后回复");
    }else if (indexPath.row == 2){
        cell.label.text = UMComLocalizedString(@"um_com_recommend", @"推荐");
    }else if (indexPath.row == 3){
        cell.label.text = UMComLocalizedString(@"um_com_topic_hot", @"最热");
    }
    if (indexPath.row == collectionView.currentIndex) {
        cell.label.textColor = UMComColorWithColorValueString(UMCom_Forum_TopicPost_TopMenu_HighLightTextColor);
    }else{
        cell.label.textColor = UMComColorWithColorValueString(UMCom_Forum_TopicPost_TopMenu_NomalTextColor);
    }
    cell.label.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_TopicPost_TopMenu_TextFont);

}


- (NSInteger)numberOfRowInHorizonCollectionView:(UMComHorizonCollectionView *)collectionView
{
    return 4;
}



- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView didSelectedColumn:(NSInteger)column
{

    [self transitionChildViewControllers];
}


- (void)transitionChildViewControllers
{
    [self transitionFromViewControllerAtIndex:self.menuView.lastIndex toViewControllerAtIndex:self.menuView.currentIndex animations:^{
    } completion:^(BOOL finished) {
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 重置childViewController的Rect

-(void) resetFrameForChildViewControllers
{
    NSArray *childViewControllers = self.childViewControllers;
    if (childViewControllers && childViewControllers.count > 0) {
        CGRect viewFrame =  self.view.frame;
        for (int i = 0; i < childViewControllers.count > 0; i++) {
            UIViewController*  childViewController = self.childViewControllers[i];
            if (childViewController) {
                CGRect childViewControllerRC =  childViewController.view.frame;
                childViewControllerRC.size.height = viewFrame.size.height - self.menuView.frame.size.height;
                childViewController.view.frame = childViewControllerRC;
            }
        }
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self resetFrameForChildViewControllers];
}

@end
