//
//  RWRequsetManager.h
//  ZhongYuSubjectHubKY
//
//  Created by zhongyu on 16/4/26.
//  Copyright © 2016年 RyeWhiskey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "RWClassListModel.h"
#import "RWInformationModel.h"

@protocol RWRequsetDelegate <NSObject>

@optional

- (void)requestError:(NSError *)error Task:(NSURLSessionDataTask *)task;

- (void)subjectHubDownLoadDidFinish:(NSArray *)subjectHubs;

- (void)subjectBaseDeployDidFinish:(NSArray *)subjectHubs;

- (void)classListDownloadDidFinish:(NSMutableArray *)classListSource;

- (void)recommendListSourceDownloadFinish:(NSArray *)recommendListSource;

- (void)registerResponds:(BOOL)isSuccessed ErrorReason:(NSString *)reason;

- (void)userLoginResponds:(BOOL)isSuccessed ErrorReason:(NSString *)reason;

- (void)replacePasswordResponds:(BOOL)isSuccessed ErrorReason:(NSString *)reason;

- (void)latestInformationDownLoadFinish:(NSArray *)LatestInformations;

@end

@interface RWRequsetManager : NSObject

+ (instancetype)sharedRequestManager;

@property (nonatomic,assign)id <RWRequsetDelegate> delegate;

@property (nonatomic,strong)AFHTTPSessionManager *manager;

@property (nonatomic,assign,readonly)AFNetworkReachabilityStatus reachabilityStatus;

- (void)obtainServersInformation;

- (void)obtainTasteSubject;

- (void)obtainBaseWith:(NSString *)url AndHub:(NSString *)hub DownLoadFinish:(void(^)(BOOL declassify))finish;

- (void)obtainBanners:(void(^)(NSArray *banners))response;

- (void)obtainClassList;

- (void)obtainLatestInformation;

- (void)obtainRecommendListSource;

- (void)postUserName:(NSString *)userName Complete:(void(^)(BOOL isSucceed,NSString *reason,NSError *error))complete;

- (void)receivePushMessageOfHTML:(void(^)(NSString *html,NSError *error))complete;

+ (void)warningToViewController:(__kindof UIViewController *)viewController Title:(NSString *)title Click:(void(^)(void))click;

@end
