//
//  HMCreateGroupCmd.h
//  HomeMateSDK
//
//  Created by liqiang on 2019/9/20.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import <HomeMateSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMCreateGroupCmd : BaseCmd
@property (nonatomic, copy) NSString * familyId;
@property (nonatomic, copy) NSString * userId;
@property (nonatomic, copy) NSString * roomId;
@property (nonatomic, copy) NSString * groupName;
@property (nonatomic, copy) NSString * pic;
@property (nonatomic, copy) NSArray * groupMemberList;
@property (nonatomic, assign) int groupType;
@end

NS_ASSUME_NONNULL_END
