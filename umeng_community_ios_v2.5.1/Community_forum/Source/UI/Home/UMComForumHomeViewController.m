//
//  UMComForumHomeViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/16.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumHomeViewController.h"
#import "UMComHorizonMenuView.h"
#import "UMComTools.h"
#import "UIViewController+UMComAddition.h"
#import "UMComPullRequest.h"
#import "UMComTopic.h"
#import "UMComForumAllTopicTableViewController.h"
#import "UMComLoginManager.h"
#import "UMComForumDiscoverViewController.h"
#import "UMComHorizonCollectionView.h"
#import "UMComPostTableViewController.h"
#import "UMComPostingViewController.h"
#import "UMComSearchBar.h"
#import "UMComSearchPostViewController.h"
#import "UMComNavigationController.h"
#import "UMComForumSearchTopicTableViewController.h"
#import "UMComHotPostViewController.h"
#import "UMComSession.h"
#import "UMComTopFeedTableViewHelper.h"
#import "UMComFocusPostTableVIewController.h"
#import "UMComSegmentedControl.h"

//颜色值
#define UMCom_Forum_Home_TopMenu_NomalTextColor @"#999999"
#define UMCom_Forum_Home_TopMenu_HighLightTextColor @"#008BEA"
#define UMCom_Forum_Home_DropMenu_NomalTextColor @"#8F8F8F"
#define UMCom_Forum_Home_DorpMenu_HighLightTextColor @"#F5F5F5"

//文字大小
#define UMCom_Forum_Home_TopMenu_TextFont 18
#define UMCom_Forum_Home_DropMenu_TextFont 15


//#define  USING_SearchBarInTableviewHeader //searchbar是否在tableview的header中，还是和以前一样保持一个searchbar
@interface UMComForumHomeViewController ()
<UMComHorizonCollectionViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UIButton *findButton;

@property (nonatomic, strong) UIView *itemNoticeView;

@property (nonatomic, strong) UMComHorizonCollectionView *menuView;

@property (nonatomic, strong) UMComSearchBar *searchBar;

@property (nonatomic, assign) CGFloat searchBarOriginY;

@property (nonatomic, strong) NSArray *searViewControllers;

@property (nonatomic, strong) UISegmentedControl *hotFeedSegmentControl;

@property (nonatomic, strong) UISegmentedControl *topicSegmentControl;

-(UMComSearchBar*) createSearchBarWithPlaceholder:(NSString*)placeholder;

@end

@implementation UMComForumHomeViewController
{
    CGPoint originOffset; //全部话题搜索页面的起始位置
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.findButton.hidden = NO;
//    [self.navigationController.navigationBar addSubview:self.menuView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.findButton.hidden = YES;
//    [self.menuView removeFromSuperview];
}
- (void)initBar
{
    self.navigationItem.title = @"社区";
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.tabBarController.tabBar.translucent = NO;
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
   
    MAIN_NAV
    
    [self initBar];
    
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//    如果当前NavigationViewController是跟视图， 则不需要显示返回按钮
    if ((rootViewController == self.navigationController && rootViewController.childViewControllers.count == 1) || rootViewController == self) {
        self.navigationItem.leftBarButtonItem = nil;
    }else{
//        [self setForumUIBackButton];
        self.navigationItem.leftBarButtonItem = nil;
    }
    self.view.backgroundColor = UMComColorWithColorValueString(UMCom_Feed_BgColor);
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    if (![[UIApplication sharedApplication] isStatusBarHidden]) {
        CGPoint temp_originOffset = [[UIApplication sharedApplication] statusBarFrame].origin;
        temp_originOffset.y += [[UIApplication sharedApplication] statusBarFrame].size.height;
        originOffset = temp_originOffset;
    }
    [self xbjzy_loadLeftBarButtonItemWithImageName:@"disclosureIndicator"];
    [self createDiscoverView];
    
//    UMComHorizonCollectionView *collectionMenuView = [[UMComHorizonCollectionView alloc]initWithFrame:CGRectMake(40, 0, self.view.frame.size.width - 80, 44) itemCount:4];
//    collectionMenuView.cellDelegate = self;
//    collectionMenuView.indicatorLineHeight = 2;
//    collectionMenuView.indicatorLineWidth = UMComWidthScaleBetweenCurentScreenAndiPhone6Screen(35.f);
//    collectionMenuView.scrollIndicatorView.backgroundColor = UMComColorWithColorValueString(FontColorBlue);
//    collectionMenuView.backgroundColor = [UIColor clearColor];
//    [self.navigationController.navigationBar addSubview:collectionMenuView];
//    self.menuView = collectionMenuView;
    
    //创建serchBar
    //屏蔽2.3版本及之前版本,只创建一个searbar,2.4版本后主页每个tableview都挂着一个searchbar
    //用宏USING_SearchBarInTableviewHeader来控制
#ifndef USING_SearchBarInTableviewHeader
    UMComSearchBar *searchBar = [[UMComSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    searchBar.placeholder = UMComLocalizedString(@"um_com_searchUserAndContent", @"搜索用户和内容");
    searchBar.delegate = self;
    searchBar.backgroundColor = UMComColorWithColorValueString(@"#F5F6FA");
    searchBar.bgImage = nil;
    [self.view addSubview:searchBar];
    self.searchBar = searchBar;
#endif
    
    [self createSubControllers];
    [UMComHttpManager updateTemplateChoice:1 response:nil];

    self.searViewControllers = [NSArray arrayWithObjects:@"UMComSearchPostViewController",@"UMComSearchPostViewController",@"UMComSearchPostViewController",@"UMComForumSearchTopicTableViewController", nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshAllDataWhenLoginUserChange) name:kUserLoginSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshAllDataWhenLoginUserChange) name:kUserLogoutSucceedNotification object:nil];
}
-(void)xbjzy_loadLeftBarButtonItemWithImageName:(NSString *) barButtonItemImageName
{
    UIBarButtonItem *leftBBI=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:barButtonItemImageName]
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(xbjzy_leftBarButtonItemAction)];
    
    self.navigationItem.leftBarButtonItem=leftBBI;
}
-(void)xbjzy_leftBarButtonItemAction
{
    if (self.navigationController.viewControllers.count==1)
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshAllDataWhenLoginUserChange
{
    //登陆成功或者退出登陆的时候需要刷新的页面，关注页面和话题下我的话题
    UMComRequestTableViewController *requestTableViewController = self.childViewControllers[2];
    requestTableViewController.fetchRequest = [[UMComAllFeedsRequest alloc] initWithCount:BatchSize];
    [requestTableViewController refreshNewDataFromServer:nil];
    
    UIViewController* forumAllTopicTableViewController= self.childViewControllers[3];
    if (forumAllTopicTableViewController && forumAllTopicTableViewController.childViewControllers.count > 0) {
       UMComRequestTableViewController *forumTopicFocusedTableViewController = forumAllTopicTableViewController.childViewControllers[0];
        [forumTopicFocusedTableViewController refreshNewDataFromServer:nil];
        
    }
}


- (void)createSubControllers
{
    UMComSegmentedControl *segmentedControl = [[UMComSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"1天内",@"3天内",@"7天内",@"30天内", nil]];
    segmentedControl.frame = CGRectMake(40, 8, self.view.frame.size.width - 80, 27);
    [self.view addSubview:segmentedControl];
    [segmentedControl addTarget:self action:@selector(didSelectedHotFeedAtIndex:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.tintColor = UMComColorWithColorValueString(@"#008BEA");
    segmentedControl.hidden = YES;
    [segmentedControl setfont:UMComFontNotoSansLightWithSafeSize(14) titleColor:UMComColorWithColorValueString(@"#008BEA") selectedColor:[UIColor whiteColor]];
    self.hotFeedSegmentControl = segmentedControl;
    
    CGRect commonFrame = self.view.frame;
    //commonFrame.origin.y = self.searchBar.frame.size.height;
    commonFrame.size.height = commonFrame.size.height - commonFrame.origin.y;
    
    UMComHotPostViewController *hotPostListController = [[UMComHotPostViewController alloc]init];
    hotPostListController.view.frame = commonFrame;
    [self addChildViewController:hotPostListController];
    [self.view addSubview:hotPostListController.view];
    
#ifdef USING_SearchBarInTableviewHeader
    //添加热门界面的searchBar---begin
    for(int i = 0; i < hotPostListController.childViewControllers.count; i++)
    {
        //不管是feed和话题都用此类UMComRequestTableViewController
        UMComRequestTableViewController* tempTableViewController =  hotPostListController.childViewControllers[i];
        if (tempTableViewController) {
            
            NSString* placeholder = nil;
            if (hotPostListController.topic) {
                placeholder = UMComLocalizedString(@"um_com_searchTopic", @"搜索话题");
            }
            else{
                placeholder = UMComLocalizedString(@"um_com_searchUserAndContent", @"搜索用户和内容");
            }
            
            UMComSearchBar * searchBar = [self createSearchBarWithPlaceholder:placeholder];
            if (searchBar) {
                tempTableViewController.tableView.tableHeaderView = searchBar;
            }
        }
    }
    //添加热门界面的searchBar---end
#endif
    
    
    UMComPostTableViewController *recommendPostListController = [[UMComPostTableViewController alloc] initWithFetchRequest:[[UMComRecommendFeedsRequest alloc] initWithCount:BatchSize]];
    recommendPostListController.showEditButton = YES;
    recommendPostListController.isLoadLoacalData = YES;
    //添加置顶类---begin
    UMComTopFeedTableViewHelper* tempTopFeedTableViewHelper =  [[UMComTopFeedTableViewHelper alloc] init];
    tempTopFeedTableViewHelper.topFeedRequest = [[UMComTopFeedRequest alloc] initwithTopFeedCountCount:BatchSize];
    recommendPostListController.topFeedTableViewHelper = tempTopFeedTableViewHelper;
    recommendPostListController.showTopMark = YES;
    //添加置顶类---end
    recommendPostListController.view.frame = commonFrame;
    [self addChildViewController:recommendPostListController];

#ifdef USING_SearchBarInTableviewHeader
    //添加推荐界面的searchBar---begin
    UMComSearchBar * recommendSearchBar = [self createSearchBarWithPlaceholder:UMComLocalizedString(@"um_com_searchUserAndContent", @"搜索用户和内容")];
    recommendPostListController.tableView.tableHeaderView = recommendSearchBar;
    //添加推荐界面的searchBar---end
#endif
    
    UMComFocusPostTableVIewController *followingPostListController = [[UMComFocusPostTableVIewController alloc] initWithFetchRequest:[[UMComAllFeedsRequest alloc] initWithCount:BatchSize]];
    followingPostListController.showEditButton = YES;
    followingPostListController.isLoadLoacalData = NO;
    followingPostListController.view.frame = commonFrame;
    [self addChildViewController:followingPostListController];
    followingPostListController.showTopMark = NO;
    __weak typeof(self) ws = self;
    followingPostListController.loadSeverDataCompletionHandler = ^(NSArray *data, BOOL haveNextPage,NSError *error)
    {
        if (!error) {
            [ws showTipLableFromTopWithTitle:@"数据已更新"];
        }
    };
    
#ifdef USING_SearchBarInTableviewHeader
    //添加关注界面的searchBar---begin
    UMComSearchBar * focusedSearchBar = [self createSearchBarWithPlaceholder:UMComLocalizedString(@"um_com_searchUserAndContent", @"搜索用户和内容")];
    followingPostListController.tableView.tableHeaderView = focusedSearchBar;
    //添加关注界面的searchBar---end
#endif
    
    UISegmentedControl *topiSegmentedControl = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"我的话题",@"推荐话题",@"全部话题", nil]];
    topiSegmentedControl.frame = CGRectMake(40, 8, self.view.frame.size.width - 80, 27);
    [self.view addSubview:topiSegmentedControl];
    [topiSegmentedControl addTarget:self action:@selector(didSelectedTopicAtIndex:) forControlEvents:UIControlEventValueChanged];
    topiSegmentedControl.selectedSegmentIndex = 0;
    topiSegmentedControl.tintColor = UMComColorWithColorValueString(@"#008BEA");
    topiSegmentedControl.hidden = YES;
    self.topicSegmentControl = topiSegmentedControl;
    
    UMComForumAllTopicTableViewController *forumViewController = [[UMComForumAllTopicTableViewController alloc]init];
    forumViewController.view.frame = commonFrame;
    [self addChildViewController:forumViewController];
    
#ifdef USING_SearchBarInTableviewHeader
    //添加话界面的searchBar---begin
    for(int i = 0; i < forumViewController.childViewControllers.count; i++)
    {
        //不管是feed和话题都用此类UMComForumTopicTableViewController
        UMComRequestTableViewController* tempTableViewController =  forumViewController.childViewControllers[i];
        if (tempTableViewController) {
            UMComSearchBar * searchBar = [self createSearchBarWithPlaceholder:UMComLocalizedString(@"um_com_searchTopic", @"搜索话题")];
            if (searchBar) {
                UITableView* temp = tempTableViewController.tableView;
                tempTableViewController.tableView.tableHeaderView = searchBar;
            }
        }
    }
    //添加话题界面的searchBar---end
    
#endif
    
    [self.menuView startIndex:0];
}

- (void)didSelectedHotFeedAtIndex:(UISegmentedControl *)segmentedControl
{
    UMComHotPostViewController *hotPostListController = self.childViewControllers[0];
    [hotPostListController setPage:segmentedControl.selectedSegmentIndex];
}

- (void)didSelectedTopicAtIndex:(UISegmentedControl *)segmentedControl
{
    UMComForumAllTopicTableViewController *forumViewController = self.childViewControllers[3];
    [forumViewController setPage:segmentedControl.selectedSegmentIndex];
}

- (void)createDiscoverView
{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(self.view.frame.size.width-45, self.navigationController.navigationBar.frame.size.height/2-22, 44, 44);
    CGFloat delta = 9;
    rightButton.imageEdgeInsets =  UIEdgeInsetsMake(delta, delta, delta, delta);
    [rightButton setImage:UMComImageWithImageName(@"um_discover_forum") forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(onClickDiscover:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:rightButton];
    self.findButton = rightButton;
    self.itemNoticeView = [self creatNoticeViewWithOriginX:rightButton.frame.size.width-10];
    [self.findButton addSubview:self.itemNoticeView];
}

- (UIView *)creatNoticeViewWithOriginX:(CGFloat)originX
{
    CGFloat noticeViewWidth = 8;
    UIView *itemNoticeView = [[UIView alloc]initWithFrame:CGRectMake(originX,5, noticeViewWidth, noticeViewWidth)];
    itemNoticeView.backgroundColor = [UIColor redColor];
    itemNoticeView.layer.cornerRadius = noticeViewWidth/2;
    itemNoticeView.clipsToBounds = YES;
    itemNoticeView.hidden = YES;
    return itemNoticeView;
}

#pragma mark - HorizionMenuViewDelegate
- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView reloadCell:(UMComHorizonCollectionCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    CGRect labelFrame = cell.label.frame;
    cell.label.textAlignment = NSTextAlignmentLeft;
    if (indexPath.row == 0) {
        cell.label.text = UMComLocalizedString(@"um_com_hot",@"热门");
    }else if (indexPath.row == 1){
        cell.label.text = UMComLocalizedString(@"um_com_recommend",@"推荐");
    }else if (indexPath.row == 2){
        cell.label.text = UMComLocalizedString(@"um_com_following", @"关注");
    }else if (indexPath.row == 3){
        cell.label.text = UMComLocalizedString(@"um_com_topic",@"话题");
    }
    if (indexPath.row == collectionView.currentIndex) {
        cell.label.textColor = UMComColorWithColorValueString(UMCom_Forum_Home_TopMenu_HighLightTextColor);
    }else{
        cell.label.textColor = UMComColorWithColorValueString(UMCom_Forum_Home_DropMenu_NomalTextColor);
    }
    cell.label.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_Home_TopMenu_TextFont);
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.label.frame = labelFrame;
}


- (NSInteger)numberOfRowInHorizonCollectionView:(UMComHorizonCollectionView *)collectionView
{
    return 4;
}

- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView didSelectedColumn:(NSInteger)column
{
    [self transitionToPageAtIndex:column];
}

#pragma mark - 

- (void)transitionToPageAtIndex:(NSInteger)index
{
    if (index == 3) {
        self.searchBar.placeholder = UMComLocalizedString(@"um_com_searchTopic", @"搜索话题");
    }else{
        self.searchBar.placeholder = UMComLocalizedString(@"um_com_searchUserAndContent", @"搜索用户和内容");
    }
    UIViewController *currentViewController = self.childViewControllers[index];
    CGRect searchBarFrame = self.searchBar.frame;
    CGRect commonViewFrame = currentViewController.view.frame;
    if (index > 0) {
        self.hotFeedSegmentControl.hidden = YES;
        if (index < 3) {
            searchBarFrame.origin.y = 0;
            self.topicSegmentControl.hidden = YES;
        }else{
            searchBarFrame.origin.y = self.topicSegmentControl.frame.size.height + self.topicSegmentControl.frame.origin.y;
            self.topicSegmentControl.hidden = NO;
            UMComForumAllTopicTableViewController *topicMenuViewController = (UMComForumAllTopicTableViewController *)currentViewController;
            [topicMenuViewController setPage:topicMenuViewController.page];
        }
    }else{
        searchBarFrame.origin.y = self.hotFeedSegmentControl.frame.size.height + self.hotFeedSegmentControl.frame.origin.y;
        self.hotFeedSegmentControl.hidden = NO;
        self.topicSegmentControl.hidden = YES;
        
    }
    commonViewFrame.origin.y = searchBarFrame.size.height + searchBarFrame.origin.y;
    commonViewFrame.size.height = self.view.bounds.size.height - commonViewFrame.origin.y;
    self.searchBar.frame = searchBarFrame;
    currentViewController.view.frame = commonViewFrame;
    [self transitionFromViewControllerAtIndex:self.menuView.lastIndex toViewControllerAtIndex:self.menuView.currentIndex animations:nil completion:nil];
}

- (void)onClickDiscover:(UIButton *)sender
{
    UMComForumDiscoverViewController *findViewController = [[UMComForumDiscoverViewController alloc] init];
    [self.navigationController  pushViewController:findViewController animated:YES];
}

- (void)transitionToSearViewController
{
    CGRect _currentViewFrame = self.view.frame;
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    UIView *spaceView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    spaceView.backgroundColor = [UMComTools colorWithHexString:@"#f7f7f8"];
    [self.navigationController.view addSubview:spaceView];
    __weak typeof(self) weakSelf = self;
    self.searchBarOriginY = self.searchBar.frame.origin.y;
    Class viewControllerClass = NSClassFromString(self.searViewControllers[self.menuView.currentIndex]);
    UIViewController *searchViewController =[[viewControllerClass alloc]init];
    UMComNavigationController *navi = [[UMComNavigationController alloc]initWithRootViewController:searchViewController];
    navi.view.frame = CGRectMake(0, navigationBar.frame.size.height+originOffset.y,self.view.frame.size.width, self.view.frame.size.height);
    void (^dismissBlock)() = ^(){
        //[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            weakSelf.searchBar.alpha = 1;
            weakSelf.searchBar.frame = CGRectMake(0, weakSelf.searchBarOriginY, weakSelf.searchBar.frame.size.width, weakSelf.searchBar.frame.size.height);
            navigationBar.frame = CGRectMake(originOffset.x, originOffset.y, weakSelf.view.frame.size.width, navigationBar.frame.size.height);
            weakSelf.view.frame = _currentViewFrame;
            [navi.view removeFromSuperview];
        [navi removeFromParentViewController];
            [spaceView removeFromSuperview];
        //} completion:nil];
    };
    if (self.menuView.currentIndex == 3) {
        UMComForumSearchTopicTableViewController *searchPostViewController = (UMComForumSearchTopicTableViewController *)searchViewController;
        searchPostViewController.dismissBlock = dismissBlock;
        searchPostViewController.isAutoStartLoadData = NO;
    }else{
        UMComSearchPostViewController *searchPostViewController = (UMComSearchPostViewController *)searchViewController;
        searchPostViewController.dismissBlock = dismissBlock;
    }
    self.navigationController.view.backgroundColor = UMComTableViewSeparatorColor;
    [self.navigationController.view addSubview:navi.view];
    [self.navigationController addChildViewController:navi];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        weakSelf.searchBar.alpha = 0;
        weakSelf.searchBar.frame = CGRectMake(0, weakSelf.searchBarOriginY-44, weakSelf.searchBar.frame.size.width, weakSelf.searchBar.frame.size.height);
        navigationBar.frame = CGRectMake(0, -44, weakSelf.view.frame.size.width, navigationBar.frame.size.height);
        weakSelf.view.frame = CGRectMake(0,- navigationBar.frame.size.height-originOffset.y, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height+navigationBar.frame.size.height+originOffset.y);
        navi.view.frame = CGRectMake(0, originOffset.y,weakSelf.view.frame.size.width, weakSelf.view.frame.size.height+navigationBar.frame.size.height);
    } completion:nil];
}

#pragma mark - searchBarDelelagte
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if ([UMComSession sharedInstance].communityGuestMode == 1) {
        [self transitionToSearViewController];
    }else{
        __weak typeof(self) weakSelf = self;
        [UMComLoginManager performLogin:self completion:^(id responseObject, NSError *error) {
            if (!error) {
                [weakSelf transitionToSearViewController];
            }
        }];
    }
    return NO;
}

-(UMComSearchBar*) createSearchBarWithPlaceholder:(NSString*)placeholder
{
    UMComSearchBar *searchBar =
    [[UMComSearchBar alloc] initWithFrame:CGRectMake(0, 0 ,self.view.frame.size.width, 44)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if (placeholder) {
        searchBar.placeholder = placeholder;
    }
    searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
    searchBar.delegate = self;
    searchBar.backgroundColor = UMComColorWithColorValueString(@"#F5F6FA");
    return searchBar;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    CGRect parentRect = self.view.frame;
//    int childViewControllerY = self.searchBar.frame.size.height;;
//    
//    NSArray* childViewControllers = self.childViewControllers;
//    for(int i = 0; i < childViewControllers.count;i++)
//    {
//        UIViewController* childViewController = (UIViewController*)childViewControllers[i];
//        if (childViewController) {
//            
//            childViewController.view.frame = CGRectMake(0,childViewControllerY , parentRect.size.width, parentRect.size.height -childViewControllerY);
//        }
//    }
//}
@end
