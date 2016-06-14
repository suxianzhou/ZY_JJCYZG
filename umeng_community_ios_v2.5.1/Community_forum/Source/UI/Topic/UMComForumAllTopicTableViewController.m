//
//  UMComForumAllViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/17.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumAllTopicTableViewController.h"
#import "UMComPullRequest.h"
#import "UMComSearchBar.h"
#import "UMComTopic.h"
#import "UMComForumTopicTableViewController.h"
#import "UMComForumSearchTopicTableViewController.h"
#import "UMComSession.h"
#import "UMComPushRequest.h"
#import "UMComShowToast.h"
#import "UMComForumTopicTypeTableViewController.h"
#import "UMComNavigationController.h"
#import "UMComScrollViewDelegate.h"
#import "UMComForumTopicFocusedTableViewController.h"
#import "UIViewController+UMComAddition.h"

@interface UMComForumAllTopicTableViewController ()<UISearchBarDelegate, UMComScrollViewDelegate>


@property (nonatomic, assign) NSInteger lastIndex;//上次显示的页面

@property (nonatomic, strong)  UIButton *loginBt;

@property (nonatomic, assign) CGFloat searchBarOriginY;

@end


@implementation UMComForumAllTopicTableViewController
{
    CGPoint originOffset; //全部话题搜索页面的起始位置
}

- (void)viewDidLoad {

    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    [self createTopicViewControllers];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resetSubViewControllers) name:kUserLoginSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resetSubViewControllers) name:kUserLogoutSucceedNotification object:nil];
}


- (void)resetSubViewControllers
{
    UMComForumTopicTableViewController *focusedVc = self.childViewControllers[0];
    focusedVc.dataArray = nil;
    focusedVc.isLoadFinish = YES;
    [focusedVc.tableView reloadData];
    if ([[UMComSession sharedInstance] isLogin]) {
        focusedVc.fetchRequest = [[UMComUserTopicsRequest alloc] initWithUid:[UMComSession sharedInstance].uid count:BatchSize];

    }else{
        focusedVc.fetchRequest = nil;
    }
    UMComForumTopicTableViewController *topicVc = self.childViewControllers[1];
    topicVc.dataArray = nil;
    topicVc.isLoadFinish = YES;
    [topicVc.tableView reloadData];
    [self transitionToPageAtIndex:self.page];
}

//创建各自话题ViewController
- (void)createTopicViewControllers
{
    CGRect commonFrame = self.view.bounds;
    UMComForumTopicFocusedTableViewController *focuedTopicsTableViewController = [[UMComForumTopicFocusedTableViewController alloc] initWithFetchRequest:[[UMComUserTopicsRequest alloc] initWithUid:[UMComSession sharedInstance].uid count:BatchSize]];
    focuedTopicsTableViewController.isLoadLoacalData = YES;
    focuedTopicsTableViewController.scrollViewDelegate = self;
    focuedTopicsTableViewController.view.frame = commonFrame;
    [self.view addSubview:focuedTopicsTableViewController.view];
    [self addChildViewController:focuedTopicsTableViewController];
    
    UMComForumTopicTableViewController *recommendTopicsTableViewController = [[UMComForumTopicTableViewController alloc] initWithFetchRequest:[[UMComRecommendTopicsRequest alloc] initWithCount:BatchSize]];
    recommendTopicsTableViewController.scrollViewDelegate = self;
    recommendTopicsTableViewController.view.frame = commonFrame;
    [self addChildViewController:recommendTopicsTableViewController];
    
    UMComForumTopicTypeTableViewController *topicTypesTableViewController = [[UMComForumTopicTypeTableViewController alloc] init];
    topicTypesTableViewController.view.frame = commonFrame;
    [self addChildViewController:topicTypesTableViewController];
}

//设置当前页面
- (void)setPage:(NSInteger)page
{
    _lastIndex = _page;
    _page = page;
    if (page < self.childViewControllers.count) {
        [self transitionToPageAtIndex:page];
    }
}

/**
 跳到指定的页面
 
 @param index 要显示第几页
 
 */
- (void)transitionToPageAtIndex:(NSInteger)index
{
    UMComRequestTableViewController *requestTableViewController = self.childViewControllers[index];
    if (index == 0) {
        [requestTableViewController performSelector:@selector(resetSubViews) withObject:nil afterDelay:0];
    }
    [requestTableViewController refreshData];
    [self transitionFromViewControllerAtIndex:_lastIndex toViewControllerAtIndex:index animations:nil completion:nil];
}

///**
// 当前ViewController的子ViewControllers之间的切换
// 
// @param fromViewController 当前ViewController
// 
// @param toViewController   将要显示的ViewController
// 
// */
//- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
//{
//    if (fromViewController == toViewController) {
//        return;
//    }
//    __weak typeof(self) weakSelf = self;
//    [self transitionFromViewController:fromViewController toViewController:toViewController duration:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//        toViewController.view.center = CGPointMake(weakSelf.view.frame.size.width/2, toViewController.view.center.y);
//        if (weakSelf.page > weakSelf.lastIndex) {
//            fromViewController.view.center = CGPointMake(-weakSelf.view.frame.size.width*3/2, fromViewController.view.center.y);
//        }else if(weakSelf.page < weakSelf.lastIndex){
//            fromViewController.view.center = CGPointMake(weakSelf.view.frame.size.width*3/2, fromViewController.view.center.y);
//        }else{
//            toViewController.view.center = fromViewController.view.center;
//        }
//    } completion:^(BOOL finished) {
//        weakSelf.lastViewController = toViewController;
//    }];
//}

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

//-(void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    CGRect parentRect = self.view.frame;
//    
//    NSArray* childViewControllers = self.childViewControllers;
//    for(int i = 0; i < childViewControllers.count;i++)
//    {
//        UIViewController* childViewController = (UIViewController*)childViewControllers[i];
//        if (childViewController) {
//            childViewController.view.frame = CGRectMake(0,0 , parentRect.size.width, parentRect.size.height);
//        }
//    }
//}

#pragma mark - 重置childViewController的高度

-(void) resetFrameForChildViewControllers
{
    NSArray *childViewControllers = self.childViewControllers;
    if (childViewControllers && childViewControllers.count > 0) {
        CGRect viewFrame =  self.view.frame;
        for (int i = 0; i < childViewControllers.count > 0; i++) {
            UIViewController*  childViewController = self.childViewControllers[i];
            if (childViewController) {
               CGRect childViewControllerRC =  childViewController.view.frame;
                childViewControllerRC.size.height = viewFrame.size.height;
                childViewController.view.frame = childViewControllerRC;
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self resetFrameForChildViewControllers];
}

@end
