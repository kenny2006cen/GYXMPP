//
//  HMHubOnlineModel.h
//  HomeMateSDK
//
//  Created by liqiang on 2018/2/24.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMBaseModel.h"

@interface HMHubOnlineModel : HMBaseModel
@property (nonatomic, assign) int online;


/**
 根据uid查询网关是否在线（每一个心跳周期从服务器查询一次） 默认是YES

 @return YES 在线  NO 不在线
 */
+ (BOOL)hubOnline:(NSString *)uid;

+ (HMHubOnlineModel *)hubOnlineModel:(NSString *)uid;
+ (NSArray <HMHubOnlineModel *> *)hubOnlineModelWithUids:(NSArray *)uids;
@end
