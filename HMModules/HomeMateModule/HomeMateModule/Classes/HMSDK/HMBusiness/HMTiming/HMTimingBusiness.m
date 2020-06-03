//
//  HMTimingBusiness.m
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMTimingBusiness.h"

@implementation HMTimingBusiness

+ (NSArray <HMTiming *>*)querySceneTimingsWithSceneNo:(NSString *)sceneNo {
    NSMutableArray <HMTiming*>*timings = [NSMutableArray array];
    NSString *selectSql = [NSString stringWithFormat:@"select * from Timing where uid = '%@' and bindOrder = '%@' and delFlag = 0 and deviceId = '%@' order by hour asc, minute asc", userAccout().familyId,@"scene control",sceneNo];
    FMResultSet *resultSet = [[HMDatabaseManager shareDatabase] executeQuery:selectSql];
    while ([resultSet next]) {
        HMTiming *timerObj = [HMTiming object:resultSet];
        [timings addObject:timerObj];
    }
    [resultSet close];
    return [timings copy];
}

+ (void)activate:(BOOL)activate sceneTiming:(HMTiming *)sceneTiming completion:(commonBlockWithObject)completion {
    if (!sceneTiming) {
        if (completion) {
            DLog(@"sceneTiming 不能为空");
            completion(KReturnValueParameterError, nil);
        }
        return;
    }
    NewActiveTimerCmd * cmd = [NewActiveTimerCmd object];
    cmd.userName = userAccout().userName;
    cmd.uid = userAccout().familyId;
    cmd.timingId = sceneTiming.timingId;
    if (activate) {
        cmd.isPause = 1;
    }else{
        cmd.isPause = 0;
    }
    cmd.sendToServer = YES;
    
    sendLCmd(cmd, YES, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            if (!sceneTiming) {
                DLog(@"");
            }
            sceneTiming.isPause = cmd.isPause;
            // 命令成功后，更新数据库的数据
            [sceneTiming insertObject];

        }
        if (completion) {
            completion(returnValue, returnDic);
        }
    });
}

+ (void)addSceneTiming:(HMTiming *)sceneTiming scene:(HMScene *)scene completion:(commonBlockWithObject)completion {
    if (!sceneTiming || !scene.sceneNo.length) {
        if (completion) {
            DLog(@"sceneTiming和scene.sceneNo 不能为空");
            completion(KReturnValueParameterError, nil);
        }
        return;
    }
    NewAddTimerCmd * cmd = [NewAddTimerCmd object];
    
    cmd.userName     = userAccout().userName;
    cmd.uid          = userAccout().familyId;
    cmd.name         = @"";
    cmd.deviceId     = scene.sceneNo;
    cmd.order        = @"scene control";
    cmd.value1       = sceneTiming.value1;
    cmd.value2       = sceneTiming.value2;
    cmd.value3       = sceneTiming.value3;
    cmd.value4       = sceneTiming.value4;
    cmd.hour         = sceneTiming.hour;
    cmd.minute       = sceneTiming.minute;
    cmd.second       = sceneTiming.second;
    cmd.week         = sceneTiming.week;
    cmd.timingType   = new_timer_type_scene;
    cmd.sendToServer = YES;
    
    sendLCmd(cmd, YES, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            HMTiming * timer = [HMTiming objectFromDictionary:returnDic];
            timer.isPause = 1;
            [timer insertObject];
        }
        if (completion) {
            completion(returnValue, returnDic);
        }
    });
}

+ (void)modifySceneTiming:(HMTiming *)sceneTiming completion:(commonBlockWithObject)completion {
    if (!sceneTiming) {
        if (completion) {
            DLog(@"sceneTiming 不能为空");
            completion(KReturnValueParameterError, nil);
        }
        return;
    }
    NewModifyTimerCmd * cmd = [NewModifyTimerCmd object];
    cmd.timingId = sceneTiming.timingId;
    cmd.userName = userAccout().userName;
    cmd.uid = userAccout().familyId; // 情景定时uid填familyId
    cmd.name = @"";
    cmd.order = @"scene control";
    cmd.value1 = sceneTiming.value1;
    cmd.value2 = sceneTiming.value2;
    cmd.value3 = sceneTiming.value3;
    cmd.value4 = sceneTiming.value4;
    cmd.hour = sceneTiming.hour;
    cmd.minute = sceneTiming.minute;
    cmd.second = sceneTiming.second;
    cmd.week = sceneTiming.week;
    cmd.sendToServer = YES;
    
    if (cmd.value1 == -1) {
        cmd.value1 = 0;
    }
    
    if (cmd.value2 == -1) {
        cmd.value2 = 0;
    }
    
    if (cmd.value3 == -1) {
        cmd.value3 = 0;
    }
    
    if (cmd.value4 == -1) {
        cmd.value4 = 0;
    }
    sendLCmd(cmd, YES, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            sceneTiming.isPause = 1;
            [sceneTiming insertObject];
        }else if(returnValue == KReturnValueDataNotExist) {
            [sceneTiming deleteObject];
        }
        if (completion) {
            completion(returnValue, returnDic);
        }
    });
}

+ (void)deleteSceneTiming:(NSString *)timingId completion:(commonBlockWithObject)completion {
    if (!timingId.length) {
        if (completion) {
            DLog(@"timingId 不能为空");
            completion(KReturnValueParameterError, nil);
        }
        return;
    }
    NewDeleteTimerCmd * cmd = [NewDeleteTimerCmd object];
    cmd.userName = userAccout().userName;
    cmd.uid = userAccout().familyId;
    cmd.timingId = timingId;
    cmd.sendToServer = YES;
    
    sendLCmd(cmd, YES, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess || returnValue == KReturnValueDataNotExist) {
            HMTiming *timing = [HMTiming objectWithTimingId:timingId];
            [timing deleteObject];
        }
        if (completion) {
            completion(returnValue, returnDic);
        }
    });
}

+ (HMTiming *)querySceneTimingWhichIsActiveAndCanExecuteTodayWithSceneNo:(NSString *)sceneNo {
    HMTiming *timing = nil;
    NSString *selectSql = [NSString stringWithFormat:@"select * from Timing where uid = '%@' and bindOrder = '%@' and delFlag = 0 and deviceId = '%@' and isPause = 1 order by hour asc, minute asc", userAccout().familyId,@"scene control",sceneNo];
    FMResultSet *resultSet = [[HMDatabaseManager shareDatabase] executeQuery:selectSql];
    while ([resultSet next]) {
        HMTiming *timerObj = [HMTiming object:resultSet];
        if ([[self class] canExecuteToday:timerObj]) {
            timing = timerObj;
            break;
        }
    }
    [resultSet close];
    return timing;
}

+ (NSArray <HMTiming *>*)querySecurityTimingsWithFamilyId:(NSString *)familyId {
    NSMutableArray <HMTiming*>*timings = [NSMutableArray array];
    NSString *selectSql = [NSString stringWithFormat:@"select * from Timing where uid = '%@'  and delFlag = 0 and bindOrder in ('outside security','inside security','cancel security') order by hour,minute", userAccout().familyId];
    FMResultSet *resultSet = [[HMDatabaseManager shareDatabase] executeQuery:selectSql];
    while ([resultSet next]) {
        HMTiming *timerObj = [HMTiming object:resultSet];
        [timings addObject:timerObj];
    }
    [resultSet close];
    return [timings copy];
}

+ (HMTiming *)querySecurityTimingWhichIsActiveAndCanExecuteTodayWithFamilyId:(NSString *)familyId {
    HMTiming *timing = nil;
    NSString *selectSql = [NSString stringWithFormat:@"select * from Timing where uid = '%@'  and delFlag = 0 and bindOrder in ('outside security','inside security','cancel security') and isPause = 1 order by hour,minute", userAccout().familyId];
    FMResultSet *resultSet = [[HMDatabaseManager shareDatabase] executeQuery:selectSql];
    while ([resultSet next]) {
        HMTiming *timerObj = [HMTiming object:resultSet];
        if ([[self class] canExecuteToday:timerObj]) {
            timing = timerObj;
            break;
        }
    }
    [resultSet close];
    return timing;
}


+ (BOOL)canExecuteToday:(HMTiming *)timer {
    
    int Monday = timer.week & 0x00000001;
    int TuesDay = timer.week >>1 & 0x00000001;
    int WednesDay = timer.week >>2 & 0x00000001;
    int Thursday = timer.week >>3 & 0x00000001;
    int Friday = timer.week >>4 & 0x00000001;
    int Saturday = timer.week >>5 & 0x00000001;
    int Sunday = timer.week >>6 & 0x00000001;
    
    BOOL isWeekdayToday = NO;
    BOOL isExecuteTimeLaterThanNow = NO;
    
    //判断星期是否是今天
    NSString *todayWeekStr = [[self class] weekdayStringFromDate:[NSDate date]];
    if (timer.week == 0) {
        isWeekdayToday = YES;
    }else if (Monday == 1 && TuesDay == 1 && WednesDay == 1 && Thursday == 1 && Friday == 1 && Saturday == 1 && Sunday == 1) {
        isWeekdayToday = YES;
    }else if ([todayWeekStr isEqualToString:@"周一"] && Monday == 1) {
        isWeekdayToday = YES;
    }else if ([todayWeekStr isEqualToString:@"周二"] && TuesDay == 1) {
        isWeekdayToday = YES;
    }else if ([todayWeekStr isEqualToString:@"周三"] && WednesDay == 1) {
        isWeekdayToday = YES;
    }else if ([todayWeekStr isEqualToString:@"周四"] && Thursday == 1) {
        isWeekdayToday = YES;
    }else if ([todayWeekStr isEqualToString:@"周五"] && Friday == 1) {
        isWeekdayToday = YES;
    }else if ([todayWeekStr isEqualToString:@"周六"] && Saturday == 1) {
        isWeekdayToday = YES;
    }else if ([todayWeekStr isEqualToString:@"周日"] && Sunday == 1) {
        isWeekdayToday = YES;
    }
    
    //判断执行时间是否是当前时间之后
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"HH:mm:ss"];
    NSString *timerDateStr = [NSString stringWithFormat:@"%02d:%02d:00",timer.hour, timer.minute];
    NSDate *timerDate = [formatter dateFromString:timerDateStr];
    NSString *nowDateStr = [formatter stringFromDate:[NSDate date]];
    NSDate *nowDate = [formatter dateFromString:nowDateStr];
    NSComparisonResult result = [timerDate compare:nowDate];
    if (result == NSOrderedDescending) {
        isExecuteTimeLaterThanNow = YES;
    }
    return (isWeekdayToday && isExecuteTimeLaterThanNow);
}

+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate {
    
    NSArray *weekdays = @[@"", @"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六"];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    
    [calendar setTimeZone: timeZone];

    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;

    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];

    return [weekdays objectAtIndex:theComponents.weekday];
}
    
@end
