//
//  RWMainViewController.m
//  ZhongYuSubjectHubKY
//
//  Created by zhongyu on 16/4/26.
//  Copyright © 2016年 RyeWhiskey. All rights reserved.
//

#import "RWMainViewController.h"
#import "RWSubjectCarouselCell.h"
#import "RWSubjectHubListCell.h"
#import "RWDataBaseManager.h"
#import "RWChooseSubViewController.h"
#import <SVProgressHUD.h>
#import "RWAnswerViewController.h"
#import "RWWelcomeController.h"
#import "RWMainViewController+Drawer.h"
#import "RWMainViewController+CountDownView.h"

@interface RWMainViewController ()

<

    UITableViewDelegate,
    UITableViewDataSource,
    UIAlertViewDelegate,
    RWSubjectCarouselDelegate

>

@property (nonatomic,strong)NSArray *subjectClassSource;

@property (nonatomic,strong)NSMutableArray *subjectSource;

@property (nonatomic,strong)RWDataBaseManager *baseManager;

@property (nonatomic,strong)NSString *selectTitle;

@property (nonatomic,strong)NSArray *titles;

@property (nonatomic,strong)NSArray *images;

@property (nonatomic,strong)NSArray *bannersUrls;

@property (nonatomic,assign)BOOL isRequestBanners;

@end

static NSString *const carousel = @"caroisel";

static NSString *const hubList = @"hunList";

static NSString *const taste = @"taste";

@implementation RWMainViewController

@synthesize subjectHubList;
@synthesize baseManager;
@synthesize subjectClassSource;
@synthesize subjectSource;
@synthesize selectTitle;
@synthesize titles;
@synthesize images;
@synthesize bannersUrls;
@synthesize deployManager;
@synthesize isRequestBanners;

- (void)initBar
{
    self.navigationItem.title = @"基金从业资格";
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.tabBarController.tabBar.translucent = NO;
    self.navigationController.navigationBar.translucent = NO;
 
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *barButton =
                [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"admin_gg"]
                                                style:UIBarButtonItemStyleDone
                                               target:self
                                               action:@selector(drawerSwitch)];
    
    self.navigationItem.leftBarButtonItem = barButton;
}

- (void)toWelcomeView
{
    RWWelcomeController *welcomeView = [[RWWelcomeController alloc] init];
    
    [self presentViewController:welcomeView animated:NO completion:nil];
}

#pragma mark - Version > iOS 8_0

- (void)warningForNull
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"友情提示" message:@"客官，后台数据更新中，完成后第一时间推送给您。" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *registerAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [self carouseStart];
        });
    }];
    
    [alert addAction:registerAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)notRegister
{
    NSString *header, *message, *responcedTitle, *cancelTitle;
    
    header = @"登录";
    message=@"立即登录免费获取全部题库\n\n继续体验，请点击取消按钮";
    responcedTitle = @"立即注册";
    cancelTitle = @"取消";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:header message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *registerAction = [UIAlertAction actionWithTitle:responcedTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        
        [SVProgressHUD show];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           
                           RWDeployManager *deploy = [RWDeployManager defaultManager];
                           
                           [deploy setDeployValue:NOT_LOGIN forKey:LOGIN];
                       });
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [self carouseStart];
    }];
    
    [alert addAction:registerAction];
    
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)initManagersAndDatas
{
    _requestManager = [[RWRequsetManager alloc] init];
    
    baseManager = [RWDataBaseManager defaultManager];
    
    subjectSource = [[NSMutableArray alloc] init];
    
    deployManager = [RWDeployManager defaultManager];
    
    isRequestBanners = NO;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MAIN_NAV
    
    [self initManagersAndDatas];
    
    [self initBar];
    
    subjectHubList = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStyleGrouped];
    
    [self.view addSubview:subjectHubList];
    
    [subjectHubList mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.view.mas_top).offset(0);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        
    }];

    subjectHubList.showsHorizontalScrollIndicator = NO;
    subjectHubList.showsVerticalScrollIndicator   = NO;
    
    subjectHubList.delegate   = self;
    subjectHubList.dataSource = self;
    
    [subjectHubList registerClass:[RWSubjectCarouselCell class] forCellReuseIdentifier:carousel];
    
    [subjectHubList registerClass:[RWSubjectHubListCell class] forCellReuseIdentifier:hubList];
    
    [subjectHubList registerClass:[UITableViewCell class] forCellReuseIdentifier:taste];
    
    [self compositionDrawer];
    
    [self examineWhetherShowTestCountDownView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tabBarController.view.window insertSubview:_drawerView atIndex:0];
    
    _drawerCenter = _drawerView.center;
    
    if ([[deployManager deployValueForKey:FIRST_OPEN_APPILCATION] boolValue])
    {
        [self toWelcomeView];
        
        return;
    }
    
    if (!subjectClassSource) {
        
        subjectClassSource = [baseManager obtainHubClassNames];
        
        if (subjectClassSource.count == 0) {
            
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
            
            [SVProgressHUD setFont:[UIFont systemFontOfSize:14]];
            
            [SVProgressHUD showWithStatus:@"正在初始化请稍后..."];
            
            _requestManager.delegate = self;
            
            [_requestManager obtainServersInformation];

        }else {
            
            for (int i = 0;  i < subjectClassSource.count; i ++) {
                
                [subjectSource addObject:[baseManager obtainHubNamesWithTitle:[subjectClassSource[i] valueForKey:@"title"]]];
            }
        }
    }
    
    if (!images)
    {
        if (isRequestBanners)
        {
            NSArray *baseBanners = [baseManager obtainBanners];
            
            if (baseBanners.count != 0)
            {
                [self carouseStop];
                
                titles = baseBanners[RWBannersOfTitles];
                
                images = baseBanners[RWBannersOfImages];
                
                bannersUrls = baseBanners[RWBannersOfContentUrls];
            }
        }
        else
        {
            isRequestBanners = YES;
            
            _requestManager.delegate = self;
            
            [_requestManager obtainBanners:^(NSArray *banners) {
                
                if (self.isViewLoaded && self.view.window && banners.count != 0)
                {
                    [self carouseStop];
                    
                    titles = banners[RWBannersOfTitles];
                    
                    images = banners[RWBannersOfImages];
                    
                    bannersUrls = banners[RWBannersOfContentUrls];
                    
                    [subjectHubList reloadData];
                    
                    [self carouseStart];
                }
            }];
        }
    }
    
    [subjectHubList reloadData];
    
    [self carouseStart];
    
    if (_countDown)
    {
        [_countDown rollTestNameAndDays];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self carouseStop];
}

- (void)carouseStart
{
    RWSubjectCarouselCell *cell = [subjectHubList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (cell)
    {
        if (!cell.isStartCarouse)
        {
            [cell carouseStart];
        }
    }
}

- (void)carouseStop
{
    RWSubjectCarouselCell *cell = [subjectHubList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (cell)
    {
        if (cell.isStartCarouse)
        {
            [cell carouseStop];
        }
    }
}

#pragma mark - RWRequsetDelegate

- (void)requestError:(NSError *)error Task:(NSURLSessionDataTask *)task {
    
    [SVProgressHUD dismiss];
    
    if (_requestManager.reachabilityStatus == AFNetworkReachabilityStatusUnknown)
    {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        
        [SVProgressHUD setFont:[UIFont systemFontOfSize:14]];
        
        [SVProgressHUD setMinimumDismissTimeInterval:0.1];
    
        [SVProgressHUD showInfoWithStatus:@"当前无网络，请检查网络设置"];
                
    }
}

- (void)subjectHubDownLoadDidFinish:(NSArray *)subjectHubs {
    
    subjectClassSource = subjectHubs;
    
    for (int i = 0;  i < subjectClassSource.count; i ++) {
        
        [subjectSource addObject:[baseManager obtainHubNamesWithTitle:[subjectClassSource[i] valueForKey:@"title"]]];
    }
    
    [subjectHubList reloadData];
    
    [SVProgressHUD dismiss];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return subjectClassSource.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0)
    {
        return 1;
    }
    
    return [subjectSource[section - 1] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section != 0)
    {
        CGFloat w = self.view.frame.size.width;
        
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, w, 30)];
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        
        image.image = [UIImage imageNamed:@"mark"];
        
        [headerView addSubview:image];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 200, 30)];
        
        titleLabel.text = [subjectClassSource[section - 1] valueForKey:@"title"];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        
        [headerView addSubview:titleLabel];
        
        return headerView;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0)
    {
        RWSubjectCarouselCell *cell = [tableView dequeueReusableCellWithIdentifier:carousel forIndexPath:indexPath];
        
        cell.delegate = self;
        
        if (images.count > 0)
        {
            cell.images = images;
            
            cell.titles = titles;
            
            if (!cell.isStartCarouse)
            {
                [cell carouseStart];
            }

        }
        else
        {
            cell.images = @[[UIImage imageNamed:@"zhongyuEDU"],[UIImage imageNamed:@"zhongyuEDU"]];
            
            cell.titles = @[@"考研题库－考研成功助力神器",@"考研题库－考研成功助力神器"];
            
            [cell carouseStop];
        }
        
        
        
        return cell;
    }
#if 0
    else if (indexPath.section == 1)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:taste forIndexPath:indexPath];
        
        cell.textLabel.text = @"体验答题";
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
#endif
    else
    {
        RWSubjectHubListCell *cell = [tableView dequeueReusableCellWithIdentifier:hubList forIndexPath:indexPath];
        
        cell.title = [subjectSource[indexPath.section - 1][indexPath.row] valueForKey:@"title"];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;  
        
        if ([baseManager isExistHubWithHubName:[subjectSource[indexPath.section - 1][indexPath.row] valueForKey:@"title"]])
        {
            cell.downLoadState = @"已下载";
        }
        else
        {
            cell.downLoadState = @"未下载";
        }
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0)
    {
        return self.view.frame.size.width * 0.55;
    }
    
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section != 0)
    {
        return 30;
    }
    
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self carouseStop];
    
    selectTitle = [subjectSource[indexPath.section - 1][indexPath.row] valueForKey:@"title"];
    
    if (indexPath.section != 0)
    {
        _requestManager.delegate = self;
        
        if (![[deployManager deployValueForKey:LOGIN] isEqualToString:DID_LOGIN])
        {
            [self notRegister];
            
            return;
        }
        
        NSArray *classSource = [baseManager obtainIndexNameWithHub:selectTitle];
        
        if (classSource.count == 0)
        {
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
            
            [SVProgressHUD setFont:[UIFont systemFontOfSize:14]];
            
            [SVProgressHUD showWithStatus:@"正在下载..."];
            
            if ([[subjectSource[indexPath.section - 1][indexPath.row] valueForKey:@"formalDBURL"]
                 rangeOfString:@".db"].location == NSNotFound)
            {
                [SVProgressHUD dismiss];
                
                [self warningForNull];
                
                return;
            }
            
            [_requestManager obtainBaseWith:
                                [subjectSource[indexPath.section - 1][indexPath.row]
                                 valueForKey:@"formalDBURL"] AndHub:
             selectTitle DownLoadFinish:^(BOOL declassify) {
                 
            }];
        }
        else
        {
            RWChooseSubViewController *choose = [[RWChooseSubViewController alloc] init];
            
            choose.headerTitle = selectTitle;
            
            choose.classSource = [baseManager obtainIndexNameWithHub:selectTitle];
            
            [self.navigationController pushViewController:choose animated:YES];
            
            [SVProgressHUD dismiss];
        } 
    }
#if 0
    else if (indexPath.section == 1)
    {
        RWAnswerViewController *answerView = [[RWAnswerViewController alloc] init];
        
        answerView.headerTitle = @"体验答题";
        
        answerView.displayType = RWDisplayTypeNormal;
        
        NSMutableArray *subjects = [NSMutableArray arrayWithArray:[baseManager obtainTasteSubject]];
        
        if (subjects.count == 0)
        {
            [requestManager obtainTasteSubject];
            
            subjects = [NSMutableArray arrayWithArray:[baseManager obtainTasteSubject]];
        }
        answerView.subjectSource = subjects;
        answerView.beginIndexPath = [baseManager obtainBeginWithBeforeOfLastSubjectWithSubjectSource:subjects];
        [self.navigationController pushViewController:answerView animated:YES];
    }
#endif
}

#pragma mark - RWSubjectCarouselDelegate

- (void)carousel:(RWSubjectCarouselCell *)carousel DidSelectWithIndex:(NSInteger)index
{
    RWWebViewController *webViewController = [[RWWebViewController alloc]init];
    
    if (bannersUrls.count > 0)
    {
        webViewController.url = bannersUrls[index];
    }
    else
    {
        webViewController.url = @"http://kaoyan.zhongyuedu.com";
    }
    
    
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)subjectBaseDeployDidFinish:(NSArray *)subjectHubs
{
    RWChooseSubViewController *choose = [[RWChooseSubViewController alloc] init];
    
    choose.headerTitle = selectTitle;
    
    choose.classSource = subjectHubs;
    
    [SVProgressHUD dismiss];
    
    [self.navigationController pushViewController:choose animated:YES];
}

#pragma mark +CountDown

- (void)countDownView:(RWCountDownView *)countDown DidClickCloseButton:(UIImageView *)closeButton
{
    [self removeCountDownView];
}

@end
