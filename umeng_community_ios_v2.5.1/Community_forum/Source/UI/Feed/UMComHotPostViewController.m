//
//  UMComPostListViewController.m
//  UMCommunity
//
//  Created by umeng on 12/2/15.
//  Copyright © 2015 Umeng. All rights reserved.
//

#import "UMComHotPostViewController.h"
#import "UMComPullRequest.h"
#import "UMComNavigationController.h"
#import "UMComPostTableViewController.h"
#import "UIViewController+UMComAddition.h"
#import "UMComTopic.h"
#import "UMComTopFeedTableViewHelper.h"
#import "UMComSegmentedControl.h"

@interface UMComHotPostViewController ()

@property (nonatomic, assign) NSInteger lastPage;

@property (nonatomic, assign) NSInteger currentPage;


@end

@implementation UMComHotPostViewController

- (instancetype)initWithTopic:(UMComTopic *)topic
{
    self = [super init];
    if (self) {
        _topic = topic;
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    if (!self.topic) {
        [self createHotFeedsSubViewControllers];
    }else{
        [self createTopicHotFeedsSubViewControllers];
    }
}

- (void)setPage:(NSInteger)page
{
    _lastPage = _currentPage;
    _currentPage = page;
    [self transitionFromViewControllers];
}

- (void)transitionFromViewControllers
{
    [self transitionFromViewControllerAtIndex:_lastPage toViewControllerAtIndex:_currentPage animations:nil completion:nil];
}

//全局热门Feed列表
- (void)createHotFeedsSubViewControllers
{
    CGRect commonFrame = self.view.bounds;
    for (int index = 0; index < 4; index ++) {
        UMComPostTableViewController *postTableViewC = [[UMComPostTableViewController alloc] init];
        postTableViewC.isLoadLoacalData = NO;
        postTableViewC.showEditButton = YES;
        UMComHotFeedRequest *hotFeedRequest = [[UMComHotFeedRequest alloc]initWithCount:BatchSize withinDays:1];
        if (index == 0) {
            hotFeedRequest.days = 30;
            postTableViewC.isAutoStartLoadData = YES;
            [self.view addSubview:postTableViewC.view];
        }else if (index == 1){
            hotFeedRequest.days = 3;
        }else if (index == 2){
            hotFeedRequest.days = 7;
        }else if (index == 3){
            hotFeedRequest.days = 1;
        }
        postTableViewC.fetchRequest = hotFeedRequest;
        postTableViewC.view.frame = commonFrame;
        [self addChildViewController:postTableViewC];
        
        //添加置顶类---begin
        UMComTopFeedTableViewHelper* tempTopFeedTableViewHelper =  [[UMComTopFeedTableViewHelper alloc] init];
        tempTopFeedTableViewHelper.topFeedRequest = [[UMComTopFeedRequest alloc] initwithTopFeedCountCount:BatchSize];
        postTableViewC.topFeedTableViewHelper = tempTopFeedTableViewHelper;
        postTableViewC.showTopMark = YES;
        //添加置顶类---end
    }
    [self transitionFromViewControllers];
}

//话题热门feed列表
- (void)createTopicHotFeedsSubViewControllers
{
    UMComSegmentedControl *segmentedControl = [[UMComSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"1天内",@"3天内",@"7天内",@"30天内", nil]];
    segmentedControl.frame = CGRectMake(40, 8, self.view.frame.size.width - 80, 27);
    [self.view addSubview:segmentedControl];
    [segmentedControl addTarget:self action:@selector(didSelectedHotFeedPage:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.tintColor = UMComColorWithColorValueString(@"#008BEA");
    [segmentedControl setfont:UMComFontNotoSansLightWithSafeSize(14) titleColor:UMComColorWithColorValueString(@"#008BEA") selectedColor:[UIColor whiteColor]];
    [self.view addSubview:segmentedControl];
    
    CGRect commonFrame = self.view.bounds;
    commonFrame.origin.y = segmentedControl.frame.size.height + segmentedControl.frame.origin.y*2;
    commonFrame.size.height = self.view.bounds.size.height - commonFrame.origin.y;
    for (int index = 0; index < 4; index ++) {
        UMComPostTableViewController *postTableViewC = [[UMComPostTableViewController alloc] init];
        postTableViewC.isLoadLoacalData = NO;
        UMComTopicHotFeedsRequest *hotFeedRequest = [[UMComTopicHotFeedsRequest alloc]initWithTopicId:self.topic.topicID count:BatchSize withinDays:1];
        if (index == 0) {
            postTableViewC.isAutoStartLoadData = YES;
            [self.view addSubview:postTableViewC.view];
        }else if (index == 1){
            hotFeedRequest.days = 3;
        }else if (index == 2){
            hotFeedRequest.days = 7;
        }else if (index == 3){
            hotFeedRequest.days = 30;
        }
        postTableViewC.cell_top_edge = UMCom_Forum_Post_Cell_Top_Edge;
        postTableViewC.fetchRequest = hotFeedRequest;
        postTableViewC.view.frame = commonFrame;
        [self addChildViewController:postTableViewC];
    }
    [self transitionFromViewControllers];
}

- (void)didSelectedHotFeedPage:(UISegmentedControl *)sender
{
    [self setPage:sender.selectedSegmentIndex];
}


#pragma mark - search delegate
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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


@end
