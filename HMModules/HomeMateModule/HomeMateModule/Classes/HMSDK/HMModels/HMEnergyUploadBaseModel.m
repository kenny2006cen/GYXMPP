//
//  HMEnergyUploadBaseModel.m
//  HomeMate
//
//  Created by orvibo on 16/8/22.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMEnergyUploadBaseModel.h"
#import "HMConstant.h"

@implementation HMEnergyUploadBaseModel

+ (NSString *)transformWorkingTime:(int)workingTime {

    if (workingTime < 60) {
        return [NSString stringWithFormat:@"%dmin",workingTime];
    } else {
        int hours = workingTime / 60; // 小时
        int minutes = workingTime - hours * 60 ; // 分钟
        if (minutes == 0) {
            return [NSString stringWithFormat:@"%dh", hours];
        } else {
            return [NSString stringWithFormat:@"%dh%dmin", hours, minutes];
        }
    }
}

+ (NSString *)particularYearWithCurrentObj:(id)currentObj lastObj:(id)lastObject
{
    NSString *yearString = nil;
    if (!lastObject) {
        return yearString;
    }
    if ([currentObj isKindOfClass:[HMEnergyUploadDay class]]) {
        HMEnergyUploadDay *obj = currentObj;
        HMEnergyUploadDay *lastObj = lastObject;
        NSInteger year = obj.day.integerValue;
        NSInteger lastObjYear = lastObj.day.integerValue;
        if (year != lastObjYear) {
            yearString = @(year).stringValue;
        }

    }else if ([currentObj isKindOfClass:[HMEnergyUploadWeek class]]) {
        HMEnergyUploadWeek *obj = currentObj;
        HMEnergyUploadWeek *lastObj = lastObject;
        NSInteger year = obj.week.integerValue;
        NSInteger lastObjYear = lastObj.week.integerValue;
        if (year != lastObjYear) {
            yearString = @(year).stringValue;
        }

    }else if ([currentObj isKindOfClass:[HMEnergyUploadMonth class]]) {
        HMEnergyUploadMonth *obj = currentObj;
        HMEnergyUploadMonth *lastObj = lastObject;
        NSInteger year = obj.month.integerValue;
        NSInteger lastObjYear = lastObj.month.integerValue;
        if (year != lastObjYear) {
            yearString = @(year).stringValue;
        }
    }
    return yearString;
}



@end
