//
//  ModifyRoomAuthorityCmd.h
//  HomeMateSDK
//
//  Created by peanut on 2017/6/21.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface ModifyRoomAuthorityCmd : BaseCmd
@property (nonatomic, copy) NSString *familyId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *roomId;
/**
 权限类型 isAuthorized int 0：有权限；1：没有权限，默认0
*/
@property (nonatomic, assign) int isAuthorized;

@end
