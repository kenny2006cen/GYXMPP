//
//  GetSmsCmd.h
//  Vihome
//
//  Created by Air on 15-1-29.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface GetSmsCmd : BaseCmd

@property (nonatomic, retain)NSString * phoneNumber;
@property (nonatomic, retain)NSString * areaCode;

/**
 0 注册
 1 修改密码
 */
@property (nonatomic, assign)int type;
@end
