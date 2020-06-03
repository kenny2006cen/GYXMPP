//
//  ModifyFamilyAuthorityCmd.h
//  HomeMateSDK
//
//  Created by peanut on 2017/6/16.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"


/**
 已废弃！！！！
 */
@interface ModifyFamilyAuthorityCmd : BaseCmd
@property (nonatomic, copy) NSString *familyId;

/**
 roomList:
 房间编号 roomId String 必填
 权限类型 type int 0：有权限；1：没有权限， 默认0
 */
@property (nonatomic, copy) NSArray *roomList;

/**
 deviceList:
 设备编号 deviceId String 必填
 权限类型 type int 0：有权限；1：没有权限，默认0
 */
@property (nonatomic, copy) NSArray *deviceList;
@end
