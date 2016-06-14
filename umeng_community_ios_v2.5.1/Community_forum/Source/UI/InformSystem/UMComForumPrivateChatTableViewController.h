//
//  UMComForumPrivateChatTableViewController.h
//  UMCommunity
//
//  Created by umeng on 15/12/1.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComRequestTableViewController.h"

@class UMComPrivateLetter, UMComImageView, UMComUser,UMComPrivateMessage,UMComMutiText,UMComMutiStyleTextView;

@interface UMComForumPrivateChatTableViewController : UMComRequestTableViewController

- (instancetype)initWithPrivateLetter:(UMComPrivateLetter *)privateLetter;
- (instancetype)initWithUser:(UMComUser *)user;

@end
