//
//  ModifyDeviceAuthorityCmd.h
//  HomeMateSDK
//
//  Created by peanut on 2017/6/21.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface ModifyDeviceAuthorityCmd : BaseCmd
@property (nonatomic, copy) NSString *familyId;
@property (nonatomic, copy) NSString *userId;


/**
 deviceList:
 设备编号 deviceId String 必填
 权限类型 isAuthorized int 0：有权限；1：没有权限，默认0
 */
@property (nonatomic, copy) NSArray *deviceList;
@end
