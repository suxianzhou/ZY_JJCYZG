//
//  UMComTopicPostTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/12/30.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComTopicPostTableViewController.h"
#import "UMComPullRequest.h"
#import "UMComTopic.h"
#import "UMComFeed.h"
#import "UMComLoginManager.h"
#import "UMComPostingViewController.h"
#import "UMComNavigationController.h"

@interface UMComTopicPostTableViewController ()


@end

@implementation UMComTopicPostTableViewController

- (instancetype)initWithTopic:(UMComTopic *)topic
{
    self = [super init];
    if (self) {
        self.topic = topic;
        self.showEditButton = YES;
    }
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - override From UMComPostTableViewController

- (void)showPostEditViewController:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    [UMComLoginManager performLogin:self completion:^(id responseObject, NSError *error) {
        if (!error) {
            UMComPostingViewController *editViewController = [[UMComPostingViewController alloc]initWithTopic:self.topic];
            editViewController.postCreatedFinish = ^(UMComFeed *feed){
                //已经通过通知来代替block
//                UIViewController* parentViewController = weakSelf.parentViewController;
//                if (parentViewController && parentViewController.childViewControllers.count > 0) {
//                   UMComTopicPostTableViewController*  lasteFeedTableViewController =  parentViewController.childViewControllers[0];
//                    if (lasteFeedTableViewController) {
//                        [lasteFeedTableViewController inserNewFeedInTabelView:feed];
//                    }
//                }
            };
            UMComNavigationController *navigationController = [[UMComNavigationController alloc]initWithRootViewController:editViewController];
            [weakSelf presentViewController:navigationController animated:YES completion:nil];
        }
    }];
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


@interface UMComTopicPostLatestFeedTableViewController ()

-(void)handleNewFeed:(NSNotification*)notification;

@end

@implementation UMComTopicPostLatestFeedTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewFeed:) name:kNotificationPostFeedResultNotification object:nil];
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:kNotificationPostFeedResultNotification];
}

#pragma mark - override From UMComPostTableViewController

- (void)inserNewFeedInTabelView:(UMComFeed *)feed
{
    if (!feed) {
        return;
    }
    //判断当前话题是否属于当前话题
    UMComTopic* tempTopic =   feed.topics.firstObject;
    if (tempTopic && [self.topic.topicID isEqualToString:tempTopic.topicID]) {
        [super inserNewFeedInTabelView:feed];
    }
}

#pragma mark - kNotificationPostFeedResultNotification
-(void)handleNewFeed:(NSNotification*)notification;
{
    id target =  notification.object;
    if (target && [target isKindOfClass:[UMComFeed class]]) {
        
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself inserNewFeedInTabelView:target];
        });
    }
}


@end
