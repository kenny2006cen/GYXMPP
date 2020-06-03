//
//  HMFirmwareModel.m
//  HomeMate
//
//  Created by Feng on 2017/12/25.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMFirmwareModel.h"

@implementation HMFirmwareModel
+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"NewVersion" : @"newVersion",
             @"desc" : @"description"};
}

#pragma mark - 为了存到UserDefaults要实现下面方法
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.type = [coder decodeObjectForKey:@"type"];
        self.isForce = [coder decodeIntForKey:@"isForce"];
        self.NewVersion = [coder decodeObjectForKey:@"NewVersion"];
        self.md5 = [coder decodeObjectForKey:@"md5"];
        self.downloadUrl = [coder decodeObjectForKey:@"downloadUrl"];
        self.desc = [coder decodeObjectForKey:@"desc"];
    }
    return self;
}
- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:_type forKey:@"type"];
    [coder encodeInt:_isForce forKey:@"isForce"];
    [coder encodeObject:_NewVersion forKey:@"NewVersion"];
    [coder encodeObject:_md5 forKey:@"md5"];
    [coder encodeObject:_downloadUrl forKey:@"downloadUrl"];
    [coder encodeObject:_desc forKey:@"desc"];
}

- (NSTimeInterval)updateLeftTime {
    
    NSTimeInterval interval = 0;
    
    if (_updateStartTime > 0) { //升级倒计时中的设备倒计时剩余时间
        interval = (HMFirmwareUpdateCountDownTime - ([[NSDate date] timeIntervalSince1970] - _updateStartTime));
        if (interval < 0) {
            interval = 0;
        }
    }
    
    return interval;
}

@end

