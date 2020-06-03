//
//  HMDeviceSort.m
//  HomeMateSDK
//
//  Created by liuzhicai on 16/10/11.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMDeviceSort.h"

@implementation HMDeviceSort

+(NSString *)tableName
{
    return @"deviceSort";
}

+ (NSArray*)columns
{
    return @[column("roomId","text"),
             column("deviceId","text"),
             column("sortNum","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE(deviceId) ON CONFLICT REPLACE";
}

- (void)prepareStatement
{
    if (!self.roomId) {
        self.roomId = @"";
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


@end
