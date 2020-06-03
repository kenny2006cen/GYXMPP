//
//  ModifyFamilyAdminAuthorityCmd.h
//  HomeMateSDK
//
//  Created by peanut on 2017/6/16.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface ModifyFamilyAdminAuthorityCmd : BaseCmd
@property (nonatomic, copy) NSString *familyId;
@property (nonatomic, copy) NSString *userId;

/**
 0:设为普通用户 1:设为管理员 (必填)
 */
@property (nonatomic, assign) int isAdmin;
@end
