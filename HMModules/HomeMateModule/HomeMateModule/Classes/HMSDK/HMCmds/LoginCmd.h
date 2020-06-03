//
//  LoginCmd.h
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface LoginCmd : BaseCmd

@property (nonatomic,strong)NSString *password;

/**
 *  0:登录界面登录
 *  1:管理员登录
 *  2:普通用户登录
 *  3:按照家庭登录
 *  4: 2.5版本新登录方式，登录接口只验证用户名和密码正确性
 */

@property (nonatomic,assign)NSInteger type;

/**
 *  当 type = 4 时，familyId不用填写
 */
@property (nonatomic,strong)NSString *familyId;

@end
