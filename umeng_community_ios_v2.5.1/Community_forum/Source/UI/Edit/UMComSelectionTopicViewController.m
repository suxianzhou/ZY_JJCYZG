//
//  UMComSelectionTopicViewController.m
//  UMCommunity
//
//  Created by 张军华 on 16/3/28.
//  Copyright © 2016年 Umeng. All rights reserved.
//

#import "UMComSelectionTopicViewController.h"
#import "UIViewController+UMComAddition.h"
#import "UMComHorizonCollectionView.h"
#import "UMComTools.h"

#import "UMComSelectionAllTopicTableViewController.h"
#import "UMComSelectionFocusedTableViewController.h"

#import "UMComPullRequest.h"
#import "UMComSession.h"

#import "UMComSelectionTopicDelegate.h"

//创建的分页的CollectionCell---begin
/**
 *  创建横向的指示cell
 */
@interface CollectionCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *label;

@end

@implementation CollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        self.label = label;
        self.label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.label];
    }
    return self;
}
@end
//创建的分页的CollectionCell---end

@interface UMComSelectionTopicViewController ()<UICollectionViewDataSource,
                                                UICollectionViewDelegate,
                                                UMComSelectionTopicDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger currentIndex;//collectionView当前index
@property (nonatomic,strong)  UIView* scrollIndicatorView;//collectionView下划线指示器
@property (nonatomic, strong) UIView *bottomLine; //collectionView最下面的细线
@property (nonatomic,strong)  NSMutableArray* cellCenterXArray;//cell的中心点坐标Array

@property (nonatomic ,strong) UIViewController *currentVC;//当前显示的viewcontroller
@property (nonatomic ,strong) NSMutableArray *vcArray;//childviewController的Array

-(void)createCollectionView;
-(void)layoutCollectionCell:(CollectionCell*)cell indexPath:(NSIndexPath *)indexPath;
- (void)transitionToPageAtIndexPath:(NSIndexPath *)indexPath;
- (void)createSubControllers;
- (void)transitionController:(UIViewController *)oldController newController:(UIViewController *)newController newIndex:(NSInteger)newIndex;
@end

@implementation UMComSelectionTopicViewController

//颜色值
#define UMCom_Forum_TopicPost_TopMenu_NomalTextColor @"#999999"
#define UMCom_Forum_TopicPost_TopMenu_HighLightTextColor @"#008BEA"
#define UMCom_Forum_TopicPost_DropMenu_NomalTextColor @"#8F8F8F"
#define UMCom_Forum_TopicPost_DorpMenu_HighLightTextColor @"#F5F5F5"

#define UMCom_Forum_TopicPost_BottomLineColor @"#EEEFF3"

//文字大小
#define UMCom_Forum_TopicPost_TopMenu_TextFont 18
#define UMCom_Forum_TopicPost_DropMenu_TextFont 15
#define UMCom_Forum_TopicPost_MenuHeight 49

#define UMCom_Forum_TopicPost_ScrollIndicatorViewHeight 3

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    [self setForumUITitle:UMComLocalizedString(@"um_com_topic", @"话题")];
    
    self.cellCenterXArray = [NSMutableArray arrayWithCapacity:2];
    self.vcArray = [NSMutableArray arrayWithCapacity:2];
    
    [self createCollectionView];
    
    [self createSubControllers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 2;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifierCell = @"Cell";
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifierCell forIndexPath:indexPath];
    
    [self layoutCollectionCell:cell indexPath:indexPath];
    
    CGFloat cellCenterX =  cell.center.x;
    if (self.cellCenterXArray.count < 2) {
        self.cellCenterXArray[indexPath.row] = @(cellCenterX);
    }

    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self transitionToPageAtIndexPath:indexPath];
}


#pragma mark - private method
-(void) createCollectionView
{
    CGSize itemSize = CGSizeMake((self.view.bounds.size.width -2) / 2, UMCom_Forum_TopicPost_MenuHeight);
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = itemSize;
    layout.minimumInteritemSpacing = 2;

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, UMCom_Forum_TopicPost_MenuHeight)
                                                          collectionViewLayout:layout];
    
    collectionView.scrollEnabled = NO;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[CollectionCell class] forCellWithReuseIdentifier:@"Cell"];
    self.collectionView = collectionView;
    [self.view addSubview:self.collectionView];
    
    //创建固定的分割线
    self.bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, self.collectionView.frame.size.height-1, self.collectionView.frame.size.width, 1)];
    self.bottomLine.backgroundColor = UMComColorWithColorValueString(UMCom_Forum_TopicPost_BottomLineColor);
    [self.collectionView addSubview: self.bottomLine];
    
    //创建标示下划线
    CGFloat scrollIndicatorViewWidth = itemSize.width*2/3;
    CGFloat scrollIndicatorViewOrginX = (itemSize.width - scrollIndicatorViewWidth)/2;
    self.scrollIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(scrollIndicatorViewOrginX, self.collectionView.bounds.size.height -UMCom_Forum_TopicPost_ScrollIndicatorViewHeight, scrollIndicatorViewWidth, UMCom_Forum_TopicPost_ScrollIndicatorViewHeight)];
    
    self.scrollIndicatorView.backgroundColor = UMComColorWithColorValueString(UMCom_Forum_TopicPost_TopMenu_HighLightTextColor);
    [self.collectionView addSubview: self.scrollIndicatorView];
}

-(void)layoutCollectionCell:(CollectionCell*)cell indexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        cell.label.text = UMComLocalizedString(@"um_com_forum_alltopic", @"全部话题");
    }else if (indexPath.row == 1){
        cell.label.text = UMComLocalizedString(@"um_com_forum_focusedtopic", @"关注的话题");
    }
    if (indexPath.row == self.currentIndex) {
        cell.label.textColor = UMComColorWithColorValueString(UMCom_Forum_TopicPost_TopMenu_HighLightTextColor);
    }else{
        cell.label.textColor = UMComColorWithColorValueString(UMCom_Forum_TopicPost_TopMenu_NomalTextColor);
    }
    cell.label.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_TopicPost_TopMenu_TextFont);
}


- (void)transitionToPageAtIndex:(NSInteger)index
{
    //改变childviewcontroller
    UIViewController* newController = [self.vcArray objectAtIndex:index];
    if (self.currentVC == newController) {
        return;
    }
    
    [self transitionController:self.currentVC newController:newController newIndex:index];
}

- (void)transitionToPageAtIndexPath:(NSIndexPath *)indexPath
{
    [self transitionToPageAtIndex:indexPath.row];
}


- (void)createSubControllers
{
    CGRect commonFrame = self.view.bounds;
    commonFrame.origin.y = self.collectionView.frame.origin.y +  self.collectionView.frame.size.height;

    //全部话题
    UMComSelectionAllTopicTableViewController* allTopicTableViewController = [[UMComSelectionAllTopicTableViewController alloc] init];
    allTopicTableViewController.view.frame = commonFrame;
    allTopicTableViewController.selectionTopicDelegate = self;
    [self addChildViewController:allTopicTableViewController];
    
    //关注话题
    UMComSelectionFocusedTableViewController *focuedTopicsTableViewController = [[UMComSelectionFocusedTableViewController alloc] init];
    focuedTopicsTableViewController.view.frame = commonFrame;
    focuedTopicsTableViewController.selectionTopicDelegate = self;
    [self addChildViewController:focuedTopicsTableViewController];
    
    [self.vcArray addObject:allTopicTableViewController];
    [self.vcArray addObject:focuedTopicsTableViewController];
    
    self.currentVC = allTopicTableViewController;
    [self.view addSubview:allTopicTableViewController.view];
}

//  切换各个标签内容
- (void)transitionController:(UIViewController *)oldController newController:(UIViewController *)newController newIndex:(NSInteger)newIndex
{
     __weak typeof(self) weakSelf = self;
    [self transitionFromViewController:oldController toViewController:newController duration:0.3 options:UIViewAnimationOptionCurveLinear animations:nil completion:^(BOOL finished) {

        if (finished) {
            weakSelf.currentVC = newController;
            weakSelf.currentIndex = newIndex;
            [UIView animateWithDuration:0.25 animations:^{
                NSNumber* centerXNumber =  weakSelf.cellCenterXArray[weakSelf.currentIndex];
                CGFloat  centerX = centerXNumber.floatValue;
                CGFloat  centerY  = weakSelf.scrollIndicatorView.center.y;
                weakSelf.scrollIndicatorView.center = CGPointMake(centerX, centerY);
            }];
            [weakSelf.collectionView reloadData];
        }else{
            weakSelf.currentVC = oldController;
        }
    }];
}

#pragma mark - UMComSelectionTopicDelegate
-(void) didSeletionTopic:(UMComTopic*)topic error:(NSError*)error
{
    if (self.selectionTopicComplete) {
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong UMComSelectionTopicViewController* strongSelf = weakself;
            if (strongSelf) {
                strongSelf.selectionTopicComplete(topic,error);
            }
        });
    }
    [self.navigationController popViewControllerAnimated:YES];
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
                childViewControllerRC.size.height = viewFrame.size.height - self.collectionView.frame.size.height;
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
