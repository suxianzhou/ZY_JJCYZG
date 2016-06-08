//
//  RWTabBarViewController.m
//  ZhongYuSubjectHubKY
//
//  Created by zhongyu on 16/5/5.
//  Copyright © 2016年 RyeWhiskey. All rights reserved.
//

#import "RWTabBarViewController.h"
#import "RWMainViewController.h"
#import "RWInformationViewController.h"
#import "RWMoreViewController.h"
#import "RWSubjectCatalogueController.h"

@interface RWTabBarViewController ()

@property (nonatomic,strong)UIView *coverLayer;

@property (nonatomic,strong)NSArray *names;

@property (nonatomic,strong)NSArray *images;

@property (nonatomic,strong)NSArray *selectImages;

@end

@implementation RWTabBarViewController

@synthesize coverLayer;;

- (void)addHiddenBarObserver
{
    [[NSNotificationCenter defaultCenter] addObserverForName:HIDDEN_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note)
     {
         self.tabBar.translucent = YES;
         self.tabBar.hidden = YES;
     }];
}

- (void)addUnhiddenBarObserver
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UNHIDDEN_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note)
     {
         self.tabBar.translucent = NO;
         self.tabBar.hidden = NO;
     }];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initResource];
    
    [self compositonViewControllers];
    
    [self compositionCoverLayer];
    
    [self compositionButton];
    
    [self addHiddenBarObserver];
    
    [self addUnhiddenBarObserver];
}

- (void)initResource
{
    _names = @[@"题目练习",@"直播课",@"",@"错题复习",@"更多"];
    
    _images = @[[UIImage imageNamed:@"main"],
                [UIImage imageNamed:@"noti"],
                [UIImage imageNamed:@"noti"],
                [UIImage imageNamed:@"error"],
                [UIImage imageNamed:@"set"]];
    
    _selectImages = @[[UIImage imageNamed:@"mian_s"],
                      [UIImage imageNamed:@"noti_s"],
                      [UIImage imageNamed:@"noti"],
                      [UIImage imageNamed:@"error_s"],
                      [UIImage imageNamed:@"set_s"]];
}

- (void)compositionCoverLayer
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    coverLayer = [[UIView alloc] initWithFrame:
                                    CGRectMake(0, 0, self.tabBar.frame.size.width,
                                                     self.tabBar.frame.size.height)];
    
    [self.tabBar addSubview:coverLayer];
    
    coverLayer.backgroundColor = [UIColor whiteColor];
}

- (void)compositonViewControllers
{
    
    RWMainViewController *main = [[RWMainViewController alloc]init];
    
    UINavigationController *mainNav = [[UINavigationController alloc]initWithRootViewController:main];
    
    RWSubjectCatalogueController *catalogue =
                                        [[RWSubjectCatalogueController alloc]init];
    
    UINavigationController *catalogueNav = [[UINavigationController alloc]initWithRootViewController:catalogue];
    
    RWInformationViewController *information = [[RWInformationViewController alloc]init];
    
    UINavigationController *notiNav = [[UINavigationController alloc]initWithRootViewController:information];
    
    RWMoreViewController *more = [[RWMoreViewController alloc]init];
    
    UINavigationController *moreNav = [[UINavigationController alloc]initWithRootViewController:more];
    
    
    self.viewControllers = @[mainNav,catalogueNav,notiNav,moreNav];
    
}

- (void)compositionButton
{
    CGFloat w = self.tabBar.frame.size.width / 5;
    
    CGFloat h = self.tabBar.frame.size.height;
    
    for (int i = 0; i < 5; i++)
    {
        if (i == 2)
        {
            continue;
        }
        
        [self tabBarButtonWithFrame:CGRectMake(w * i, 0, w, h) AndTag:i+1];
    }
    
    [self selectWithTag:1];
}

- (void)toRootViewController
{
    for (int i = 1; i <= 4; i++)
    {
        UIButton *btnX = (UIButton *)[self.view viewWithTag:i+10];
        
        btnX.selected = NO;
        
        UILabel *nameX = (UILabel *)[self.view viewWithTag:i+100];
        
        nameX.textColor = [UIColor grayColor];
    }
    
    [self selectWithTag:1];
    
    self.selectedIndex = 0;
}

- (UIView *)tabBarButtonWithFrame:(CGRect)frame AndTag:(NSInteger)tag
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    view.tag = tag;
    
    [coverLayer addSubview:view];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    
    imageView.tag = tag * 10;
    
    imageView.image = _images[tag-1];
    
    [view addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(view.mas_top).offset(2);
        make.width.equalTo(@(30));
        make.height.equalTo(@(30));
        make.centerX.equalTo(view.mas_centerX).offset(0);
    }];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    
    nameLabel.text = _names[tag-1];
    
    nameLabel.tag = tag * 100;
    
    nameLabel.textAlignment = NSTextAlignmentCenter;
    
    nameLabel.font = [UIFont systemFontOfSize:10];
    
    nameLabel.textColor = [UIColor grayColor];
    
    [view addSubview:nameLabel];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(imageView.mas_bottom).offset(0);
        make.left.equalTo(view.mas_left).offset(0);
        make.right.equalTo(view.mas_right).offset(0);
        make.bottom.equalTo(view.mas_bottom).offset(-3);
    }];
    
    [self addGestureRecognizerToView:view];
    
    return view;
}

- (void)addGestureRecognizerToView:(UIView *)view
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cutViewControllerWithGesture:)];
    
    tap.numberOfTapsRequired = 1;
    
    [view addGestureRecognizer:tap];
}

- (void)cutViewControllerWithGesture:(UITapGestureRecognizer *)tapGesture
{
    for (int i = 0; i < 5; i++)
    {
        if (i == 2)
        {
            continue;
        }
        
        UIImageView *imageItem = (UIImageView *)[self.view viewWithTag:(i + 1)*10];
        
        imageItem.image = _images[i];
        
        UILabel *nameX = (UILabel *)[self.view viewWithTag:(i + 1)*100];
        
        nameX.textColor = [UIColor grayColor];
    }
    
    [self selectWithTag:tapGesture.view.tag];
}

- (void)selectWithTag:(NSInteger)tag
{
    UIImageView *imageItem =
                    (UIImageView *)[self.view viewWithTag:tag * 10];
    
    imageItem.image = _selectImages[tag - 1];
    
    UILabel *nameLabel = [self.view viewWithTag:tag * 100];
    
    nameLabel.textColor = MAIN_COLOR;
    
    if (tag < 3)
    {
        self.selectedIndex = tag - 1;
    }
    else if (tag > 3)
    {
        self.selectedIndex = tag - 2;
    }
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
