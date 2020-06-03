//
//  HMUdpBusiness.h
//  HomeMateSDK
//
//  Created by 2049lzc on 2018/8/28.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMBaseBusiness.h"

@interface HMUdpBusiness : HMBaseBusiness

+ (void)lanCommunicationKeyWithFamilyId:(NSString *)FamilyId callBlock:(void(^)(NSString *lanCommunicationKey))block;

+ (void)queryNewestLanCommunicationKeyFromServerWithFamilyId:(NSString *)familyId callBlock:(void(^)(NSString *lanCommunicationKey))block;

@end
