//
//  HMEnergyUploadBaseModel.h
//  HomeMate
//
//  Created by orvibo on 16/8/22.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMBaseModel+Extension.h"



@interface HMEnergyUploadBaseModel : HMBaseModel

@property (nonatomic, strong) NSString *showTimeString;
@property (nonatomic, strong) NSString *workingTimeString;
@property (nonatomic, strong) NSString *totalEnergyString;
@property (nonatomic, strong) NSString *averageEnergyString;
@property (nonatomic, strong) NSString *yearString;

+ (NSString *)transformWorkingTime:(int)workingTime;

+ (NSString *)particularYearWithCurrentObj:(id)currentObj lastObj:(id)lastObject;

@end
