//
//  InviteFamilyCmd.h
//  HomeMateSDK
//
//  Created by user on 17/1/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface InviteFamilyCmd : BaseCmd

@property (nonatomic, copy)NSString * userId;

@property (nonatomic, copy)NSString * familyId;
//@property (nonatomic, copy)NSString * userName;

//@property (nonatomic, copy)NSString * familyName; //不要的属性

/** 成员类型 0:管理员 1:普通成员(默认是普通成员，只有家庭创建者能设置管理员) */
@property (nonatomic, assign)int userType;

/** 
 roomList object房间列表
 roomList结构：
 roomId String 必填
 isAuthorized	isAuthorized	int 是否有权限 0：没有权限 1：有权限 (必填)
 
 deviceList object 设备列表
 deviceList结构：
 deviceId String 必填
 isAuthorized	isAuthorized	int 是否有权限 0：没有权限 1：有权限 (必填)
 */
@property (nonatomic, strong) NSDictionary *authority;

@property (nonatomic,copy) NSString * extAddr; //门锁zigbeeMac地址 （选填)
@property (nonatomic, assign)int authorizedId; //锁用户ID（选填）, 同意邀请后生成锁用户绑定doorUserBind
@end
