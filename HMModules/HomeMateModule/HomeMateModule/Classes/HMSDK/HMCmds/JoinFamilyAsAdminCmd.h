//
//  JoinFamilyAsAdminCmd.h
//  HomeMateSDK
//
//  Created by peanut on 2017/6/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

/**
 请求加入家庭(成为管理员)
 */
@interface JoinFamilyAsAdminCmd : BaseCmd
/** 选填 */
@property (nonatomic, copy) NSString *userId;
/** 必填 */
@property (nonatomic, copy) NSString *familyId;
@end
