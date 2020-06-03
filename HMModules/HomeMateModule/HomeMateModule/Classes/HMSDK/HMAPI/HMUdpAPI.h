//
//  HMUdpAPI.h
//  HomeMateSDK
//
//  Created by 2049lzc on 2018/8/28.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import <HomeMateSDK.h>

@interface HMUdpAPI : HMBaseAPI

+ (instancetype)shareInstance;

- (void)sendData:(NSData *)data
          toHost:(NSString *)host
            port:(uint16_t)port
     withTimeout:(NSTimeInterval)timeout
             tag:(long)tag;

/**
 某家庭的局域网通信密钥，本地数据库有则返回本地的，没有则去服务器查

 @param familyId familyId
 */
+ (void)lanCommunicationKeyWithFamilyId:(NSString *)familyId callBlock:(void(^)(NSString *lanCommunicationKey))block;


/**
 查询最新的局域网通信密钥，不管本地有没有都去查，此方法在登录成功，和切换家庭成功需要调用，以防通信密钥发生改变

 @param familyId familyId
 */
+ (void)queryNewestLanCommunicationKeyFromServerWithFamilyId:(NSString *)familyId callBlock:(void(^)(NSString *lanCommunicationKey))block;


@end
