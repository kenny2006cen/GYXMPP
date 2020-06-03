//
//  HMUdpBusiness.m
//  HomeMateSDK
//
//  Created by 2049lzc on 2018/8/28.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMUdpBusiness.h"

@implementation HMUdpBusiness

+ (void)lanCommunicationKeyWithFamilyId:(NSString *)familyId callBlock:(void(^)(NSString *lanCommunicationKey))block {
    
    NSAssert(familyId, @"HMUdpBusiness -- familyId is null");
    
    NSString *localLanCommunicationKey = [HMLanCommunicationKeyModel lanCommunicationKeyOfFamilyId:familyId];
    if (localLanCommunicationKey) {
        DLog(@"本地有此家庭Id的局域网通信密钥，直接使用，不去查询");
        if (block) {
            block(localLanCommunicationKey);
        }
        return;
    }
    DLog(@"登录成功查询家庭 ： %@ 局域网通信密钥",familyId);
    
    [self queryNewestLanCommunicationKeyFromServerWithFamilyId:familyId callBlock:block];
}

+ (void)queryNewestLanCommunicationKeyFromServerWithFamilyId:(NSString *)familyId callBlock:(void(^)(NSString *lanCommunicationKey))block {
    
    QueryLanCommunicationKey *cmd = [QueryLanCommunicationKey object];
    cmd.familyId = familyId;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        NSString *key = nil;
        if (returnValue == KReturnValueSuccess) {
            
            NSString *returnFamilyId = returnDic[@"familyId"];
            
            if ([returnFamilyId isKindOfClass:[NSString class]] && [returnFamilyId isEqualToString:familyId]) {
                key = returnDic[@"cryptKey"];
                HMLanCommunicationKeyModel *lanKeyModel = [[HMLanCommunicationKeyModel alloc] init];
                lanKeyModel.lanCommunicationKey = key;
                lanKeyModel.familyId = familyId;
                [lanKeyModel insertObject];
            }
        }
        if (block) {
            block(key);
        }
    });
}

@end
