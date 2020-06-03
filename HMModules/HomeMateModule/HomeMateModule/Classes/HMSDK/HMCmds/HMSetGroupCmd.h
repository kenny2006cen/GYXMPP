//
//  HMSetGroupCmd.h
//  HomeMateSDK
//
//  Created by liqiang on 2019/9/20.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import <HomeMateSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMSetGroupCmd : BaseCmd
@property (nonatomic, copy) NSString * userId;
@property (nonatomic, copy) NSString * groupId;
@property (nonatomic, copy) NSString * roomId;
@property (nonatomic, copy) NSString * groupName;
@property (nonatomic, copy) NSArray * groupMemberAddList;
@property (nonatomic, copy) NSArray * groupMemberDeleteList;
@end

NS_ASSUME_NONNULL_END
