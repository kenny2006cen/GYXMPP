//
//  AccountSingleton+RT.h
//  HomeMate
//
//  Created by Air on 15/8/12.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "AccountSingleton.h"


@interface AccountSingleton (RT)

/**
 *  登录接口，读取WiFi和zigbee主机数据
 *
 *  @param userName   用户名
 *  @param password   密码的MD5值
 *  @param completion 回调结果
 */
-(void)loginToReadDataWithUserName:(NSString *)userName password:(NSString *)password completion:(commonBlock)completion;

/**
*
*  使用“一键登录”，“验证码登录”成功后，读取WiFi和zigbee主机数据
*/
-(void)loginToReadDataWithToken:(commonBlock)completion;
/**
 *  登录接口，只做登录操作
 *
 *  @param userName   用户名
 *  @param password   密码的MD5值
 *  @param completion 回调结果
 */
-(void)loginWithUserName:(NSString *)userName password:(NSString *)password completion:(SocketCompletionBlock)completion;


/**
 *
 *  读取当前账号信息和账号下所有数据
 */
-(void)readAllData:(commonBlockWithObject)completion;

@end
