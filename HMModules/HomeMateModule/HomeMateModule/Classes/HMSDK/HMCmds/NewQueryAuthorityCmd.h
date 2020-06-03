//
//  NewQueryAuthorityCmd.h
//  HomeMateSDK
//
//  Created by liqiang on 2019/10/15.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "BaseCmd.h"

NS_ASSUME_NONNULL_BEGIN

@interface NewQueryAuthorityCmd : BaseCmd

@property (nonatomic,strong) NSNumber * authorityType; // 0 房间权限 1 设备权限 2 情景权限 3 mixpad语音对讲权限 4 组权限 5 mixpad语音对讲权限（app）
@property (nonatomic,assign) int type;// 1 用户相关的权限 2 查询mixpad相关权限
@property (nonatomic,strong) NSString * authorityTypes;// 组合权限。"1,2"
@property (nonatomic,strong) NSString * userId;
@property (nonatomic,strong) NSString * familyId;


@end

NS_ASSUME_NONNULL_END
