//
//  HMEnergyUploadMonth.h
//  HomeMate
//
//  Created by orvibo on 16/7/4.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMEnergyUploadBaseModel.h"

@interface HMEnergyUploadMonth : HMEnergyUploadBaseModel

@property (nonatomic, strong) NSString *energyUploadMonthId;        ///< 按月统计表id
@property (nonatomic, strong) NSString *energy;                     ///< 功耗
@property (nonatomic, assign) int workingTime;                      ///< 工作时长(分钟)
@property (nonatomic, strong) NSString *month;                      ///<
@property (nonatomic ,strong) NSString *tMonth;
@property (nonatomic, strong) NSString *deviceId;

/**
 *  本月用电
 */
+ (CGFloat)currMonEnergyUseWithDeviceId:(NSString *)deviceId;


/**
 是否有本月用电量数据

 @param deviceId <#deviceId description#>
 */
+ (BOOL)isHasCurrMonEnergyUseWithDeviceId:(NSString *)deviceId;

@end
