//
//  UMComPostViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/17.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComPostTableViewController.h"
#import "UMComFeed.h"
#import "UMComFeed+UMComManagedObject.h"

#import "UMComPostTableViewCell.h"
#import "UMComPostContentViewController.h"
#import "UMComTools.h"
#import "UMComShowToast.h"

#import "UMComFeed.h"
#import "UMComPullRequest.h"
#import "UMComTopFeedTableViewHelper.h"
#import "UMComPostingViewController.h"
#import "UMComNavigationController.h"

@interface UMComPostTableViewController ()
<UMComPostContentViewControllerDelegate>

@end

@implementation UMComPostTableViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = UMComRGBColor(245, 246, 250);
    [self.tableView registerClass:[UMComPostTableViewCell class] forCellReuseIdentifier:UMComPostTableViewCellIdentifier];
    self.tableView.rowHeight = [UMComPostTableViewCell cellHeightForPlainStyle];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.showEditButton) {
        if (!self.editButton) {
            [self createEditButton];
            [self.navigationController.view addSubview:self.editButton];
        }
        self.editButton.hidden = NO;
    }
    else{
        self.editButton.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.editButton removeFromSuperview];
    self.editButton = nil;
}

- (void)createEditButton
{
    self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editButton.frame = CGRectMake(0, 0, 50, 50);
    self.editButton.center = CGPointMake(self.view.window.frame.size.width-45, self.view.window.bounds.size.height-45);
    [self.editButton setImage:UMComImageWithImageName(@"um_edit_nomal") forState:UIControlStateNormal];
    [self.editButton setImage:UMComImageWithImageName(@"um_edit_highlight") forState:UIControlStateSelected];
    [self.editButton addTarget:self action:@selector(showPostEditViewController:) forControlEvents:UIControlEventTouchUpInside];
    self.editButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
}

- (void)showPostEditViewController:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    [UMComLoginManager performLogin:self completion:^(id responseObject, NSError *error) {
        if (responseObject) {
            UMComPostingViewController *editViewController = [[UMComPostingViewController alloc]initWithTopic:nil];
            editViewController.postCreatedFinish = ^(UMComFeed *feed){
            };
            UMComNavigationController *navigationController = [[UMComNavigationController alloc]initWithRootViewController:editViewController];
            [weakSelf presentViewController:navigationController animated:YES completion:nil];
        }
    }];
}

#pragma mark - UITableViewDeleagte
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataArray.count > 0)//有数据
    {
        self.noDataTipLabel.hidden = YES;
        if (self.haveNextPage)//有下一页数据
        {
            self.loadMoreStatusView.hidden = NO;

            //有下一页就显示上来加载更多
            [self.loadMoreStatusView setLoadStatus:UMComNoLoad];
            
            //最后判断是否为可访问下一页，如果不能访问就显示登陆后访问更多数据
            if (!self.fetchRequest.canReadNextPage)
            {
                [self.loadMoreStatusView setLoadStatus:UMComNeedLoginMode];
            }
        }
        else//没有下一页数据
        {
            self.loadMoreStatusView.hidden = NO;
            //没有下一页就显示最后一页
            [self.loadMoreStatusView setLoadStatus:UMComFinish];
        }
    }
    else//数据为空
    {
        self.loadMoreStatusView.hidden = YES;
        self.noDataTipLabel.hidden = NO;
    }
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //对indexPath的校验检查---begin
    NSUInteger count = self.dataArray.count;
    NSUInteger curIndex =  indexPath.row;
    if (curIndex >=  count) {
        NSIndexPath* newindexPath = [NSIndexPath indexPathForRow:count-1 inSection:indexPath.section];
        UMComPostTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:UMComPostTableViewCellIdentifier forIndexPath:newindexPath];
        return cell;
    }
    //对indexPath的校验检查---end
    
    UMComPostTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:UMComPostTableViewCellIdentifier forIndexPath:indexPath];
    cell.cell_top_edge = self.cell_top_edge;
    UMComFeed *feed = self.dataArray[indexPath.row];
    cell.postFeed = feed;
    
    //cell.showTopMark = (_showTopMark && [feed.is_top boolValue]);
    cell.showTopMark = (_showTopMark && [self checkTopFeedWithFeed:feed]);
    cell.touchOnImage = ^(UMComGridViewerController *viewerController, UIImageView *imageView) {
        [self presentViewController:(UIViewController *)viewerController animated:YES completion:nil];
    };
    [cell refreshLayout];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //对indexPath的校验检查---begin
    NSUInteger count = self.dataArray.count;
    NSUInteger curIndex =  indexPath.row;
    if (curIndex >=  count) {
        return 0.f;
    }
    //对indexPath的校验检查---end
    
    UMComFeed *feed = self.dataArray[indexPath.row];
    CGFloat cellHeight = 0;
    if (feed.image_urls.count > 0) {
        cellHeight = [UMComPostTableViewCell cellHeightForImageStyle];
    }else{
        cellHeight = [UMComPostTableViewCell cellHeightForPlainStyle];
    }
    return cellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UMComFeed *feed = self.dataArray[indexPath.row];
    UMComPostContentViewController *controller = [[UMComPostContentViewController alloc] initWithFeed:feed];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)inserNewFeedInTabelView:(UMComFeed *)newFeed
{
    if (![newFeed isKindOfClass:[UMComFeed class]]) {
        return;
    }
    
    if (self.dataArray.count > 0) {
       NSMutableArray *array = [NSMutableArray arrayWithArray:self.dataArray];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UMComFeed *feed = obj;
            if (![feed.is_top boolValue]) {
                *stop = YES;
                [array insertObject:newFeed atIndex:idx];
                self.dataArray = array;
                [self.tableView reloadData];
            }
        }];
    }else{
        self.dataArray = @[newFeed];
        [self.tableView reloadData];
    }
}

- (void)deleteNewFeedInTabelView:(UMComFeed *)deleteFeed
{
    if (![deleteFeed isKindOfClass:[UMComFeed class]] || self.dataArray.count == 0) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.dataArray];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UMComFeed *feed = obj;
        if ([feed.feedID isEqualToString:deleteFeed.feedID]) {
            *stop = YES;
            [array removeObject:feed];
            weakSelf.dataArray = array;
            [weakSelf.tableView reloadData];
        }
    }];
}


#pragma mark - delegate
- (void)viewController:(UMComPostContentViewController *)viewController action:(UMComPostContentViewActionType)type object:(id)object
{
    if (type == UMPostContentViewActionDelete) {
        UMComFeed *feed = [object isKindOfClass:[UMComFeed class]] ? object : nil;
        [self deleteNewFeedInTabelView:feed];
    } else if (type == UMPostContentViewActionUpdateCount) {
        [self.tableView reloadData];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - overide method

/**
 *  排序回调的数据
 *
 *  @param data 源数据
 *
 *  @return 排序的数据(置顶数据在前面)
 */
-(NSArray*) sortFeedWithSourceData:(NSArray*)sourceData
{
    if (!sourceData || sourceData.count <= 0) {
        return [NSArray array];
    }
    
    NSMutableArray* topFeedArray = [NSMutableArray arrayWithCapacity:2];
    NSMutableArray* normalFeedArray = [NSMutableArray arrayWithCapacity:2];
    
    for (int i = 0; i < sourceData.count; i++) {
        
        id tempSourceFeed = sourceData[i];
        if (tempSourceFeed && [tempSourceFeed isKindOfClass:[UMComFeed class]]) {
            UMComFeed* sourceFeed = tempSourceFeed;
            if (sourceFeed) {
                
                if (sourceFeed.is_topType.integerValue == EUMTopFeedType_None) {
                    [normalFeedArray addObject:sourceFeed];
                }
                else{
                    [topFeedArray addObject:sourceFeed];
                }
            }
        }
    }
    
    NSMutableArray* resultFeedArray = [NSMutableArray arrayWithCapacity:2];
    
    [resultFeedArray addObjectsFromArray:topFeedArray];
    [resultFeedArray addObjectsFromArray:normalFeedArray];
    
    return resultFeedArray;
}

- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        self.dataArray = [self sortFeedWithSourceData:data];
    }
    if (finishHandler) {
        finishHandler();
    }
}

- (void)handleServerDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (self.topFeedTableViewHelper) {
        [self.topFeedTableViewHelper handleServerDataWithData:data error:error dataHandleFinish:finishHandler];
     
    if (error && self.topFeedTableViewHelper.tablviewDataArray.count == 0) {
    
        //当前普通流的服务器有错误，并且置顶数据和普通数据为0的时候，就表示不需要刷新，用当前的数据
        return;
    }
    else{
        //赋值给tableview的模型
        self.dataArray = self.topFeedTableViewHelper.tablviewDataArray;
    }
    
    //是否提示用户没有数据
    if(self.dataArray.count > 0)
    {
        self.noDataTipLabel.hidden = YES;
    }
    else
    {
        self.noDataTipLabel.hidden = NO;
    }
        
    //确定是否可以刷新
    if (self.topFeedTableViewHelper.topFeedState == EUMTopFeedStateFinishServerData ||
        self.topFeedTableViewHelper.topFeedState == EUMTopFeedStateServerDataError  ||
        self.topFeedTableViewHelper.topFeedState == EUMTopFeedStateNone) {
        if (finishHandler) {
//            NSLog(@"handleServerDataWithData...[tableView reloadData]");
            finishHandler();
            
            }
        }
    }
    else
    {
        [super handleServerDataWithData:data error:error dataHandleFinish:finishHandler];
    }
}



- (void)refreshNewDataFromServer:(LoadSeverDataCompletionHandler)complection
{
    __weak typeof(self) weakSelf = self;
    if (self.topFeedTableViewHelper) {
        [self.topFeedTableViewHelper refreshNewDataFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            [UMComShowToast showFetchResultTipWithError:error];

                        if (weakSelf.isLoadFinish) {
//                            NSLog(@"refreshTopFeedFromServer...[tableView reloadData]");
                            
                            /*
                            //case 1 无论有无置顶数据都会刷新，会影响用户的体验
                            weakSelf.dataArray = weakSelf.topFeedTableViewHelper.tablviewDataArray;
                            //是否提示用户没有数据
                            if(weakSelf.dataArray.count > 0)
                            {
                                weakSelf.noDataTipLabel.hidden = YES;
                            }
                            else
                            {
                                weakSelf.noDataTipLabel.hidden = NO;
                            }
                            [weakSelf.tableView reloadData];
                             */

                            //如果有错误就直接走super的逻辑
                            if (!error) {
                                //case 2 如果有置顶数据才会先刷新置顶数据
                                NSArray* tempTopArray = weakSelf.topFeedTableViewHelper.tablviewDataArray;
                                if (tempTopArray.count > 0) {
                                    weakSelf.dataArray = tempTopArray;
                                    [weakSelf.tableView reloadData];
                                }
                                else{
                                    //当置顶数据为空，判断上次的数据是否有来决定是否提示用户
                                    if (weakSelf.dataArray.count > 0) {
                                        weakSelf.noDataTipLabel.hidden = YES;
                                    }
                                    else{
                                        weakSelf.noDataTipLabel.hidden = NO;
                                    }
                                }
                            }
                            
                            [super refreshNewDataFromServer:complection];
                        }
        }];
        
    }
    else
    {
        [super refreshNewDataFromServer:complection];
    }
    
}

- (void)handleLoadMoreDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
{
    if (!error && [data isKindOfClass:[NSArray class]]) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataArray];
        //置顶去重---begin
        if (self.topFeedTableViewHelper) {
           NSArray* realArray =  [self.topFeedTableViewHelper filterTopfeedFromCommonFeedArray:data];
            if (realArray) {
                [tempArray addObjectsFromArray:realArray];
            }
        }
        else{
            [tempArray addObjectsFromArray:data];
        }
        //置顶去重---end
        self.dataArray = tempArray;
    }
    if (finishHandler) {
        finishHandler();
    }
}

#pragma mark - 判断当前Feed是否置顶(2.4新方法)
-(BOOL) checkTopFeedWithFeed:(UMComFeed*)feed
{
    if (!feed && !self.fetchRequest) {
        return NO;
    }
    
    BOOL isok = [self.fetchRequest isKindOfClass:[UMComTopicFeedsRequest class]];
    if (isok) {
        //如果是话题页面下,只需要判断EUMTopFeedType_TopicTopFeed 或者EUMTopFeedType_GlobalAndTopicTopFeed
        NSInteger resultTopType =   feed.is_topType.integerValue | EUMTopFeedType_Mask;
        if (resultTopType == EUMTopFeedType_TopicTopFeed || resultTopType == EUMTopFeedType_GlobalAndTopicTopFeed) {
            return YES;
        }
    }
    else
    {
        //如果是其他页面下,只需要判断EUMTopFeedType_GlobalTopFeed 或者 EUMTopFeedType_GlobalAndTopicTopFeed
        NSInteger resultTopType =   feed.is_topType.integerValue | EUMTopFeedType_Mask;
        if (resultTopType == EUMTopFeedType_GlobalTopFeed || resultTopType == EUMTopFeedType_GlobalAndTopicTopFeed) {
            return YES;
        }
    }
    return NO;
}


/**
 *  重新加载tableviewde数据(与下面函数handleCoreDataDataWithData一起使用，目前暂时不用)
 *
 *  @param data          tableview的数据模型
 *  @param finishHandler 成功后的调用的block
 */
//- (void)reloadTableviewData:(NSArray *)data dataHandleFinish:(DataHandleFinish)finishHandler
//{
//    if (data && [data isKindOfClass:[NSArray class]]) {
//        self.dataArray = data;
//    }
//    if (finishHandler) {
//        finishHandler();
//    }
//}

/**
 *  获得本地置顶的回调（目前此函数不需要暂时不需要）
 *
 *  @param data          本地数据
 *  @param error         error错误对象
 *  @param finishHandler 成功的回调
 */
//- (void)handleCoreDataDataWithData:(NSArray *)data error:(NSError *)error dataHandleFinish:(DataHandleFinish)finishHandler
//{
//    if (self.topFeedTableViewHelper) {
//        
//        //如果需要置顶数据，就请求并加入tableview的顶部
//        NSArray* result = [self.topFeedTableViewHelper FetchTopFeedFromCoreData];
//        if (result && result.count > 0) {
//            NSMutableArray* tableviewData = [NSMutableArray arrayWithArray:result];
//            
//            if (!error && [data isKindOfClass:[NSArray class]]) {
//                [tableviewData addObjectsFromArray:data];
//            }
//            
//            [self reloadTableviewData:tableviewData dataHandleFinish:finishHandler];
//        }
//        else
//        {
//            [self reloadTableviewData:data dataHandleFinish:finishHandler];
//        }
//    }
//    else{
//        if (!error) {
//            [self reloadTableviewData:data dataHandleFinish:finishHandler];
//        }
//    }
//}

@end
