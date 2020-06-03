//
//  RegisterCmd.h
//  Vihome
//
//  Created by Air on 15-1-24.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface RegisterCmd : BaseCmd

@property (nonatomic,strong)NSString *phone;
@property (nonatomic,strong)NSString *email;
@property (nonatomic,strong)NSString *password;
// 是否校验邮箱验证码  0  不校验   1校验
@property (nonatomic,assign)int checkEmail;

@property (nonatomic,strong)NSString * areaCode;

@end
