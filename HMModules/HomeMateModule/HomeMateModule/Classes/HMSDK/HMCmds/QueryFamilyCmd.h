//
//  QueryFamilyCmd.h
//  HomeMateSDK
//
//  Created by user on 17/1/19.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface QueryFamilyCmd : BaseCmd


@property (nonatomic, copy)NSString * userId;
@property (nonatomic, assign)int type; // 0:默认 1:(账号下已删除的有设备的未被绑定的家庭)



@end
