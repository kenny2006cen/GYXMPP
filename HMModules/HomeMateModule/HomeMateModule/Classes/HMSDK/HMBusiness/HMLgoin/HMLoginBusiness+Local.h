//
//  HMLoginBusiness+Local.h
//  HomeMateSDK
//
//  Created by Air on 2017/6/21.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMLoginBusiness.h"

@interface HMLoginBusiness (Local)

/**
 *  局域网登录主机，有任意一台主机登录成功则立即返回
 *
 *  @param userName   用户名
 *  @param password   明文密码的MD5值 [传入参数为: md5WithStr(明文密码)]
 *  @param completion 回调结果
 *
 */
+(void)localLoginWithUserName:(NSString *)userName password:(NSString *)password completion:(SocketCompletionBlock)completion;


/**
 *  登录接口，只发送登录指令到主机做登录校验，限制使用场景为局域网登录主机
 *
 *  @param userName   用户名
 *  @param password   明文密码的MD5值 [传入参数为: md5WithStr(明文密码)]
 *  @param uid        主机的uid信息
 *  @param completion 回调结果
 */
+(void)loginWithUserName:(NSString *)userName
                password:(NSString *)password
                     uid:(NSString *)uid
              completion:(SocketCompletionBlock)completion;
@end
