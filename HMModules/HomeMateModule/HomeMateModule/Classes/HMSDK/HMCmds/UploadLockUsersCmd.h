//
//  UploadLockUsersCmd.h
//  HomeMateSDK
//
//  Created by liqiang on 2019/4/19.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import <HomeMateSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface UploadLockUsersCmd : BaseCmd
@property (nonatomic, strong) NSArray * userList;
@end

NS_ASSUME_NONNULL_END
