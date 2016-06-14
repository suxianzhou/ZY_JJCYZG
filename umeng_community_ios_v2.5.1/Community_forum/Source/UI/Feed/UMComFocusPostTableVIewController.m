//
//  UMComForumFeedTableVIewController.m
//  UMCommunity
//
//  Created by 张军华 on 16/2/24.
//  Copyright © 2016年 Umeng. All rights reserved.
//

#import "UMComFocusPostTableVIewController.h"
#import "UMComSession.h"
#import "UMComLoginManager.h"
#import "UMComFeed.h"
#import "UMComTopic.h"

#define UMCom_ForumFeed_LoginTextFont 18
#define UMCom_ForumFeed_LoginTextColor @"#FFFFFF"
#define UMCom_ForumFeed_LoginBgColor @"#008BEA"
#define UMCom_ForumFeed_NoticeTextColor @"#A5A5A5"
#define UMCom_ForumFeed_NoticeTextFont 15

@interface UMComFocusPostTableVIewController ()

@property (nonatomic, strong) UIView *loginView;

//登陆相关
- (void)login:(UIButton *)sender;
- (UIView *)createNoLoginView;

//获得newFeed的通知
-(void)handleNewFeed:(NSNotification*)notification;

//设置需要登陆的时候，是否显示编辑界面入口
-(void)setEditButtonWhenNeedLogin;

@end

@implementation UMComFocusPostTableVIewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([UMComLoginManager isLogin] == NO) {
        self.isAutoStartLoadData = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewFeed:) name:kNotificationPostFeedResultNotification object:nil];
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:kNotificationPostFeedResultNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setEditButtonWhenNeedLogin];
    [super viewWillAppear:animated];
    [self resetSubViews];
}

#pragma mark -  限制登陆的方法
- (void)resetSubViews
{
    if (![UMComSession sharedInstance].isLogin) {
        if (!self.loginView) {
            self.loginView = [self createNoLoginView];
            [self.view addSubview:self.loginView];
        }else{
            if (self.loginView.superview != self.view) {
                [self.view addSubview:self.loginView];
            }
        }
        [self.view bringSubviewToFront:self.loginView];
    }else{
        [self.loginView removeFromSuperview];
    }
}

- (UIView *)createNoLoginView
{
    UIView *nologinView = [[UIView alloc]initWithFrame:self.view.bounds];
    nologinView.backgroundColor = [UIColor whiteColor];
    
    UILabel *noticellabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, nologinView.frame.size.width, 40)];
    noticellabel.text = UMComLocalizedString(@"um_com_focusAferLoginIn", @"您登陆后，服务器君才知道您关注的话题哦~");
    noticellabel.center = CGPointMake(nologinView.frame.size.width/2, nologinView.frame.size.height/2 - 45);
    noticellabel.textAlignment = NSTextAlignmentCenter;
    noticellabel.font = UMComFontNotoSansLightWithSafeSize(UMCom_ForumFeed_NoticeTextFont);
    noticellabel.textColor = UMComColorWithColorValueString(UMCom_ForumFeed_NoticeTextColor);
    [nologinView addSubview:noticellabel];
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(0, 0, 150, 45);
    loginButton.layer.cornerRadius = 5;
    loginButton.clipsToBounds = YES;
    loginButton.center = CGPointMake(nologinView.frame.size.width/2, nologinView.frame.size.height/2);
    [loginButton setTitle:UMComLocalizedString(@"um_com_login", @"立即登录") forState:UIControlStateNormal];
    [loginButton setTitleColor:UMComColorWithColorValueString(UMCom_ForumFeed_LoginTextColor) forState:UIControlStateNormal];
    [loginButton setBackgroundColor:UMComColorWithColorValueString(UMCom_ForumFeed_LoginBgColor)];
    loginButton.titleLabel.font = UMComFontNotoSansLightWithSafeSize(UMCom_ForumFeed_LoginTextFont);
    [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [nologinView addSubview:loginButton];
    return nologinView;
}

- (void)login:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    [UMComLoginManager performLogin:self completion:^(id responseObject, NSError *error) {
        if (!error) {
            //[weakSelf loadAllData:nil fromServer:nil];
            [weakSelf.loginView removeFromSuperview];
        }
    }];
}
#pragma mark - UMComRefreshTableViewDelegate
- (void)refreshData
{
    if ([UMComSession sharedInstance].isLogin)
    {
        [super refreshData];
    }
    else
    {
        [self.refreshControl endRefreshing];
    }
}

- (void)loadMoreData
{
    if ([UMComSession sharedInstance].isLogin)
    {
        [self loadNextPageDataFromServer:nil];
    }
    else
    {
        [self.refreshControl endRefreshing];
    }
    
}

#pragma mark - override from UMComPostTableViewController
- (void)inserNewFeedInTabelView:(UMComFeed *)feed
{
    if (!feed) {
        return;
    }

    //判断当前话题是否属于当前话题
    //UMComTopic* tempTopic =   feed.topics.firstObject;
    //if (tempTopic && tempTopic.is_focused.integerValue == 1)
    {
        [super inserNewFeedInTabelView:feed];
    }
    
}

#pragma mark - kNotificationPostFeedResultNotification
-(void)handleNewFeed:(NSNotification*)notification;
{
    if (![UMComSession sharedInstance].isLogin)
        return;//没有登陆就返回,不处理通知
        
    id target =  notification.object;
    if (target && [target isKindOfClass:[UMComFeed class]]) {
        
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself inserNewFeedInTabelView:target];
        });
    }
}

#pragma mark -设置是否显示编辑界面入口
-(void)setEditButtonWhenNeedLogin
{
    if (![UMComSession sharedInstance].isLogin)
    {
        self.showEditButton = NO;
    }
    else
    {
        self.showEditButton = YES;
    }
}


@end
