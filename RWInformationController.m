//
//  RWInformationController.m
//  ZhongYuSubjectHubKY
//
//  Created by zhongyu on 16/5/11.
//  Copyright © 2016年 RyeWhiskey. All rights reserved.
//

#import "RWInformationController.h"
#import <MJRefresh.h>
#import "RWRequsetManager+UserLogin.h"
#import "RWWebViewController.h"

@interface RWInformationController ()

<
    UITableViewDelegate,
    UITableViewDataSource,
    RWRequsetDelegate
>

@property (nonatomic ,strong)UITableView *informationList;

@property (nonatomic ,strong)NSArray *informationSource;

@property (nonatomic ,strong)RWRequsetManager *requsetManager;

@end

static NSString *const informationCell = @"informationCell";

@implementation RWInformationController

@synthesize informationList;
@synthesize informationSource;
@synthesize requsetManager;

- (void)addMJRefresh
{
    informationList.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [requsetManager obtainLatestInformation];
    }];
}

- (void)initClassList
{
    informationList = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
    
    [self.view addSubview:informationList];
    
    [informationList mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.top.equalTo(self.view.mas_top).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
    }];
    
    informationList.delegate = self;
    informationList.dataSource = self;
    
    informationList.showsHorizontalScrollIndicator = NO;
    
    [self addMJRefresh];
    
    [informationList registerClass:[UITableViewCell class] forCellReuseIdentifier:informationCell];
}

- (void)initBar
{
    self.navigationItem.title = @"最新资讯";
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.tabBarController.tabBar.translucent = NO;
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

#pragma mark - Life Cycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!requsetManager)
    {
        requsetManager = [[RWRequsetManager alloc] init];
        requsetManager.delegate = self;
        
        [requsetManager obtainLatestInformation];
    }
}

- (void)latestInformationDownLoadFinish:(NSArray *)LatestInformations
{
    informationSource = LatestInformations;
    
    [informationList reloadData];
    
    [informationList.mj_header endRefreshing];
}

- (void)requestError:(NSError *)error Task:(NSURLSessionDataTask *)task
{
    [informationList.mj_header endRefreshing];
    
    [RWRequsetManager warningToViewController:self
                                        Title:@"网络连接失败，请检查网络"
                                        Click:^{
                                        }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return informationSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                                informationCell forIndexPath:indexPath];
    
    cell.textLabel.text = [informationSource[indexPath.row] valueForKey:@"title"];
    
    cell.textLabel.numberOfLines = 0;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RWWebViewController *webViewController = [[RWWebViewController alloc] init];
    
    webViewController.url = [informationSource[indexPath.row] valueForKey:@"url"];
    
    webViewController.headerTitle = @"最新资讯";
    
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MAIN_NAV
    
    HIDDEN_TABBAR
    
    [self initBar];
    // Do any additional setup after loading the view.
    [self initClassList];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    SHOW_TABBAR
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

@end
