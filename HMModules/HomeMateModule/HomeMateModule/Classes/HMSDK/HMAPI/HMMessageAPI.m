//
//  HMMessageAPI.m
//  HomeMateSDK
//
//  Created by liuzhicai on 2017/7/10.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMMessageAPI.h"
#import "HMMessageBusiness.h"

@implementation HMMessageAPI

+ (void)readNewestCommonMsgFromServerWithFamilyId:(NSString *)familyId messageType:(HMMessageType)messageType completion:(commonBlockWithObject)completion {
    [HMMessageBusiness readNewestCommonMsgFromServerWithFamilyId:familyId messageType:messageType completion:completion];
}


+ (void)readNewestSecurityMsgFromServerWithFamilyId:(NSString *)familyId completion:(commonBlockWithObject)completion {
    [HMMessageBusiness readNewestSecurityMsgFromServerWithFamilyId:familyId completion:completion];
}

+ (void)readNewStatusRecordWithSecurityDevice:(HMDevice *)device completion:(commonBlockWithObject)completion {
    [HMMessageBusiness readNewStatusRecordWithSecurityDevice:device completion:completion];
}


+ (void)readOldCommonMsgBeforeSequence:(int)sequence familyId:(NSString *)familyId messageType:(HMMessageType)messageType completion:(commonBlockWithObject)completion {
    [HMMessageBusiness readOldCommonMsgBeforeSequence:sequence familyId:familyId messageType:messageType  completion:completion];
}

@end
