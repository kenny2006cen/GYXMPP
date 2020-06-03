//
//  HMAvgConcentrationHour.h
//  HomeMate
//
//  Created by JQ on 16/8/8.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMAvgConcentrationBaseModel.h"

//浓度统计小时表(虚拟表，数据从sensorAverageData表获取)
@interface HMAvgConcentrationHour : HMAvgConcentrationBaseModel

@property (nonatomic, copy) NSString *avgConcentrationHourId;

/**
 *  时
 */
@property (nonatomic, copy) NSString *hour;


@end
