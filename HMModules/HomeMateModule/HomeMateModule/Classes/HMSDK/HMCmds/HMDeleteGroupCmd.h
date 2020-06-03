//
//  HMDeleteGroupCmd.h
//  HomeMateSDK
//
//  Created by liqiang on 2019/9/20.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import <HomeMateSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMDeleteGroupCmd : BaseCmd
@property (nonatomic, copy) NSString * userId;
@property (nonatomic, copy) NSString * groupId;
@end

NS_ASSUME_NONNULL_END
