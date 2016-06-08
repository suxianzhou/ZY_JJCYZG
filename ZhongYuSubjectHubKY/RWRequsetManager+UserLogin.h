//
//  RWRequsetManager+UserLogin.h
//  ZhongYuSubjectHubKY
//
//  Created by zhongyu on 16/5/10.
//  Copyright © 2016年 RyeWhiskey. All rights reserved.
//

#import "RWRequsetManager.h"

@interface RWRequsetManager (UserLogin)

- (void)registerWithUsername:(NSString *)username AndPassword:(NSString *)password;

- (void)userinfoWithUsername:(NSString *)username AndPassword:(NSString *)password;

- (void)replacePasswordWithUsername:(NSString *)username AndPassword:(NSString *)password;

- (void)obtainVerificationCodeWithPhoneNumber:(NSString *)phoneNumber Complate:(void(^)(BOOL isSuccessed))complate;

- (void)verificationWithVerificationCode:(NSString *)verificationCode PhoneNumber:(NSString *)phoneNumber Complate:(void(^)(BOOL isSuccessed))complate;

- (BOOL)verificationPhoneNumber:(NSString *)phoneNumber;

- (BOOL)verificationPassword:(NSString *)password;

- (BOOL)verificationEmail:(NSString *)Email;

@end

