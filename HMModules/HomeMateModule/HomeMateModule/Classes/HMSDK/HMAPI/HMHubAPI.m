//
//  HMHubAPI.m
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMHubAPI.h"
#import "HMHubBusiness.h"
#import "Gateway.h"
#import "HMTypes.h"

@implementation HMHubAPI

+ (void)addGateway:(Gateway *)gateway result:(KReturnValueBlock)valueBlock
{
    [HMHubBusiness addGateway:gateway result:valueBlock];
}

+ (void)addGateway:(Gateway *)gateway completion:(commonBlockWithObject)completion
{
    [HMHubBusiness addGateway:gateway completion:completion];
}

+ (void)addGateway:(Gateway *)gateway reSend:(BOOL)reSend result:(KReturnValueBlock)valueBlock
{
    [HMHubBusiness addGateway:gateway reSend:reSend result:valueBlock];
}

+ (void)openSearchZigBeeDevice:(KReturnValueBlock)valueBlock
{
    [HMHubBusiness openSearchZigBeeDevice:valueBlock];
}

+ (void)openSearchZigBeeDeviceInGatewayUids:(NSArray *)uids completion:(commonBlockWithObject)completion
{
    [HMHubBusiness openSearchZigBeeDeviceInGatewayUids:uids completion:completion];
}

+ (void)closeSearchZigBeeDevice:(KReturnValueBlock)valueBlock
{
    [HMHubBusiness closeSearchZigBeeDevice:valueBlock];
}

+ (void)getGatewaysAdded:(void(^)(NSArray *gateways))gatewaysBlock
{
    [HMHubBusiness getGatewaysAdded:gatewaysBlock];
}

+ (void)searchCurrentWifiGateways:(void(^)(NSArray *gateways))gatewaysBlock
{
    [HMHubBusiness searchCurrentWifiGateways:gatewaysBlock];
}

+ (void)queryGateway:(Gateway *)gateway status:(void(^)(HMGatewayStatus status))resultBlock
{
    [HMHubBusiness queryGateway:gateway status:resultBlock];
}

+ (void)queryBindStatusWithUidList:(NSArray *)uidList completion:(commonBlockWithObject)completion
{
    [HMHubBusiness queryBindStatusWithUidList:uidList completion:completion];
}

+ (void)searchUnbindAlarmHostInLocalNetWorkRetBlock:(commonBlockWithObject)completion
{
    [HMHubBusiness searchUnbindAlarmHostInLocalNetWorkRetBlock:completion];
}

+ (NSString *)nameWithGateway:(Gateway *)gateway {
    return [HMHubBusiness nameWithGateway:gateway];
}

+ (void)queryMixPadQrcodeWithToken:(NSString *)token block:(commonBlockWithObject)completion {
    [HMHubBusiness queryMixPadQrcodeWithToken:token block:completion];
}

@end
