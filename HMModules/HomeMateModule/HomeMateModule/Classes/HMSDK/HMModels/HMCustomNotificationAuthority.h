//
//  HMCustomNotificationAuthority.h
//  HomeMateSDK
//
//  Created by orvibo on 2018/9/5.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMBaseModel.h"

@interface HMAuthority : HMBaseModel

@property (copy,nonatomic) NSString * userId;

/**
 authorityType = 0：roomId
 authorityType = 1：deviceId
 authorityType = 2：sceneNo
 authorityType = 3：sceneBindId
 authorityType = 4：linkageOutputId
 */
@property (copy,nonatomic) NSString * objId;

/**
 0：房间权限
 1：设备权限
 2：情景权限
 3：情景自定义消息通知权限
 4：自动化自定义消息通知权限
 */
@property (assign,nonatomic) int authorityType;

@end
