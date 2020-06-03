//
//  ResetPasswordCmd.m
//  CloudPlatform
//
//  Created by orvibo on 15/7/8.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ResetPasswordCmd.h"

@implementation ResetPasswordCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_RESETPASSWORD;
}


-(NSDictionary *)payload
{
    [sendDic setObject:self.password forKey:@"password"];
    
    // 联想app：  重置密码的时候需要把 username (手机号或邮箱)传上去

#if defined(__Lenovo__)
    
    [sendDic setObject:self.userName forKey:@"userName"];
    
#endif
    return sendDic;
}

@end
