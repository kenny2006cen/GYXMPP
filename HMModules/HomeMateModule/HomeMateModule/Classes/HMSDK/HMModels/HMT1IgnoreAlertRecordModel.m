//
//  HMT1IgnoreAlertRecordModel.m
//  HomeMateSDK
//
//  Created by peanut on 2018/3/28.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMT1IgnoreAlertRecordModel.h"
#import "HMBaseModel+Extension.h"

@implementation HMT1IgnoreAlertRecordModel

+(NSString *)tableName
{
    return @"ignoreAlertRecord";
}

+ (NSArray*)columns
{
    return @[
             column("familyId", "text"),
             column("deviceId", "text"),
             column("recordId", "text"),
             ];
}


+ (NSString*)constrains
{
    return @"UNIQUE (recordId) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}
@end
