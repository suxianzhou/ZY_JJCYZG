//
//  UMComForumCommentViewController.m
//  UMCommunity
//
//  Created by umeng on 15/12/22.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumCommentViewController.h"
#import "UMComHorizonCollectionView.h"
#import "UMComForumCommentTableViewController.h"
#import "UMComPullRequest.h"
#import "UMComSession.h"
#import "UMComUnReadNoticeModel.h"
#import "UIViewController+UMComAddition.h"

@interface UMComForumCommentViewController ()<UMComHorizonCollectionViewDelegate>

@property (nonatomic, strong) UMComHorizonCollectionView *menuView;

@end

@implementation UMComForumCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createSubControllers];

    [self setForumUITitle:UMComLocalizedString(@"um_com_comment", @"评论")];
    
    self.view.backgroundColor = UMComTableViewSeparatorColor;
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (!self.menuView) {
        UMComHorizonCollectionView *menuView = [[UMComHorizonCollectionView alloc]initWithFrame:CGRectMake(0, 2, self.view.frame.size.width, 49) itemCount:2];
        menuView.cellDelegate = self;
        menuView.itemSpace = 0;
        menuView.indicatorLineHeight = 3;
        menuView.scrollIndicatorView.backgroundColor = UMComColorWithColorValueString(@"#008BEA");
        menuView.indicatorLineWidth = UMComWidthScaleBetweenCurentScreenAndiPhone6Screen(74);
        menuView.indicatorLineLeftEdge = UMComWidthScaleBetweenCurentScreenAndiPhone6Screen(56);
        [self.view addSubview:menuView];
        self.menuView = menuView;
        [self.view bringSubviewToFront:self.menuView];
    }
}

#pragma mark - UMComHorizonCollectionViewDelegate
- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView reloadCell:(UMComHorizonCollectionCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        cell.label.text = UMComLocalizedString(@"um_com_receiveComment", @"收到的评论");
    }else{
        cell.label.text = UMComLocalizedString(@"um_com_sendComment", @"发出的评论");
    }
    if (indexPath.row == collectionView.currentIndex) {
        cell.label.textColor = UMComColorWithColorValueString(@"#008BEA");
    }else{
        cell.label.textColor = UMComColorWithColorValueString(@"#999999");
    }
}

- (void)horizonCollectionView:(UMComHorizonCollectionView *)collectionView didSelectedColumn:(NSInteger)column
{
    UMComRequestTableViewController *requestTableVc = self.childViewControllers[column];
    if (requestTableVc.dataArray.count == 0 && requestTableVc.isLoadFinish) {
        [requestTableVc loadAllData:nil fromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            if (column == 0) {
                [UMComSession sharedInstance].unReadNoticeModel.notiByCommentCount = 0;
            }
        }];
    }
//    [self.view bringSubviewToFront:self.menuView];
    [self transitionFromViewControllerAtIndex:collectionView.lastIndex toViewControllerAtIndex:collectionView.currentIndex animations:nil completion:nil];
}


- (void)createSubControllers
{
    CGRect commonFrame = self.view.frame;
    commonFrame.origin.y = 53;
    commonFrame.size.height = commonFrame.size.height - commonFrame.origin.y;
    CGFloat centerY = commonFrame.size.height/2+commonFrame.origin.y;
    UMComForumCommentTableViewController *hotPostListController = [[UMComForumCommentTableViewController alloc] initWithFetchRequest:[[UMComUserCommentsReceivedRequest alloc] initWithCount:BatchSize]];
    hotPostListController.isAutoStartLoadData = YES;
    [hotPostListController loadAllData:nil fromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        [UMComSession sharedInstance].unReadNoticeModel.notiByCommentCount = 0;
    }];
    [self addChildViewController:hotPostListController];
    [self.view addSubview:hotPostListController.view];
    hotPostListController.view.frame = commonFrame;
    
    UMComForumCommentTableViewController *recommendPostListController = [[UMComForumCommentTableViewController alloc] initWithFetchRequest:[[UMComUserCommentsSentRequest alloc]initWithCount:BatchSize]];
    [self addChildViewController:recommendPostListController];
    recommendPostListController.view.frame = commonFrame;
}

//- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
//{
//    if (fromViewController == toViewController) {
//        [self.view bringSubviewToFront:self.menuView];
//        return;
//    }
//    __weak typeof(self) weakSelf = self;
//    [self transitionFromViewController:fromViewController toViewController:toViewController duration:0.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
//        toViewController.view.center = CGPointMake(weakSelf.view.frame.size.width/2, toViewController.view.center.y);
//        if (weakSelf.menuView.currentIndex > weakSelf.menuView.lastIndex) {
//            fromViewController.view.center = CGPointMake(-weakSelf.view.frame.size.width*3/2, fromViewController.view.center.y);
//        }else if(weakSelf.menuView.currentIndex < weakSelf.menuView.lastIndex){
//            fromViewController.view.center = CGPointMake(weakSelf.view.frame.size.width*3/2, fromViewController.view.center.y);
//        }else{
//            toViewController.view.center = fromViewController.view.center;
//        }
//        [weakSelf.view bringSubviewToFront:weakSelf.menuView];
//    } completion:^(BOOL finished) {
//        weakSelf.lastViewController = toViewController;
//    }];
//}
//

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
