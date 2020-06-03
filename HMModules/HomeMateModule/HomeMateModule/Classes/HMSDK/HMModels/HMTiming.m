//
//  VihomeTiming.m
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMTiming.h"
#import "HMDatabaseManager.h"

@implementation HMTiming
+(NSString *)tableName
{
    return @"timing";
}

+ (NSArray*)columns
{
    return @[
             column("timingId","text"),
             column("uid","text"),
             column("timingGroupId","text"),
             column("showIndex","integer"),
             column("name","text"),
             column("deviceId","text"),
             column("bindOrder","text"),
             column("pluseData","text"),
             column("freq","integer"),
             column("pluseNum","integer"),
             column("value1","integer"),
             column("value2"," integer"),
             column("value3","integer"),
             column("value4","integer"),
             column("hour","integer"),
             column("minute","integer"),
             column("second","integer"),
             column("week","integer"),
             column("isPause","integer"),
             column("timingType","integer"),
             column("resourceId","integer"),
             column("typeId","integer"),
             column("isHD","integer"),
             column("themeId","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSArray<NSDictionary *>*)newColumns {
    return  @[column("themeId","text default ''")];
}

+ (NSString*)constrains
{
    return @"UNIQUE (timingId, uid) ON CONFLICT REPLACE";
}

- (void)prepareStatement
{
    if (!self.createTime) {
        self.createTime = self.updateTime;
    }
    if (!self.pluseData) {
        self.pluseData = @"";
    }
    
    if (!self.timingGroupId) {
        self.timingGroupId = @"";
    }
    
    if (!self.name) {
        self.name = @"";
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from timing where timingId = '%@' and uid = '%@'",self.timingId,self.uid];
    BOOL result = [self executeUpdate:sql];
    return result;
}



- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:self.timingId forKey:@"timingId"];
    [dic setObject:self.uid forKey:@"uid"];
    [dic setObject:self.name forKey:@"name"];
    [dic setObject:self.deviceId forKey:@"deviceId"];
    [dic setObject:self.bindOrder forKey:@"order"];
    [dic setObject:[NSNumber numberWithInt:self.value1] forKey:@"value1"];
    [dic setObject:[NSNumber numberWithInt:self.value2] forKey:@"value2"];
    [dic setObject:[NSNumber numberWithInt:self.value3] forKey:@"value3"];
    [dic setObject:[NSNumber numberWithInt:self.value4] forKey:@"value4"];
    [dic setObject:[NSNumber numberWithInt:self.hour] forKey:@"hour"];
    [dic setObject:[NSNumber numberWithInt:self.minute] forKey:@"minute"];
    [dic setObject:[NSNumber numberWithInt:self.second] forKey:@"second"];
    [dic setObject:[NSNumber numberWithInt:self.week] forKey:@"week"];
    [dic setObject:[NSNumber numberWithInt:self.isPause] forKey:@"isPause"];
    [dic setObject:self.updateTime forKey:@"updateTime"];
    [dic setObject:[NSNumber numberWithInt:self.delFlag] forKey:@"delFlag"];
    
    
    if (self.pluseData.length) {
        [dic setObject:self.pluseData forKey:@"pluseData"];

    }
    if (self.name.length) {
        [dic setObject:self.name forKey:@"name"];
    }
    [dic setObject:[NSNumber numberWithInt:self.pluseNum] forKey:@"pluseNum"];
    [dic setObject:[NSNumber numberWithInt:self.freq] forKey:@"freq"];

    
    return dic;
}

- (BOOL)isEqualtoTimer:(HMTiming *)timer
{
    if (self.value1 != timer.value1) {
        return NO;
    }
    
    if (self.value2 != timer.value2) {
        return NO;
    }
    
    if (self.value3 != timer.value3) {
        return NO;
    }
    
    if (self.value4 != timer.value4) {
        return NO;
    }
    
    if (self.hour != timer.hour) {
        return NO;
    }
    
    if (self.minute != timer.minute) {
        return NO;
    }
    
    if (self.second != timer.second) {
        return NO;
    }
    
    if (self.pluseNum != timer.pluseNum) {
        return NO;
    }
    
    if (self.freq != timer.freq) {
        return NO;
    }
    if(self.pluseData.length){
        if (![self.pluseData isEqualToString:timer.pluseData]) {
            return NO;
        }
    }
    if (self.name.length) {
        if (![self.name isEqualToString:timer.name]) {
            return NO;
        }
    }
    if (![self.bindOrder isEqualToString:timer.bindOrder]) {
        return NO;
    }
    return YES;
}

- (id)copyWithZone:(NSZone *)zone
{
    HMTiming * copy = [[HMTiming alloc]init];
    copy.timingId = self.timingId;
    copy.name = self.name;
    copy.deviceId = self.deviceId;
    copy.bindOrder = self.bindOrder;
    copy.uid = self.uid;
    copy.value1 = self.value1;
    copy.value2 = self.value2;
    copy.value3 = self.value3;
    copy.value4 = self.value4;
    copy.hour = self.hour;
    copy.minute = self.minute;
    copy.second = self.second;
    copy.week = self.week;
    copy.isPause = self.isPause;
    
    copy.freq = self.freq;
    copy.pluseData = self.pluseData;
    copy.pluseNum = self.pluseNum;
    return copy;
}

+(NSArray *)timingArrWithDeviceId:(NSString *)deviceId
{
    NSMutableArray *timerArr;
    
    NSString *selectSql = nil;
    if([self columnExists:@"timingType"]){
        selectSql = [NSString stringWithFormat:@"select * from timing where deviceId = '%@' and delFlag = 0 and timingType = 0 and (showIndex == 0 or showIndex == -1) order by hour asc, minute asc",deviceId];
    }else{
        selectSql = [NSString stringWithFormat:@"select * from timing where deviceId = '%@' and delFlag = 0 order by hour asc, minute asc",deviceId];
    }
    
    FMResultSet *resultSet = [self executeQuery:selectSql];
    while ([resultSet next]) {
        if (!timerArr) {
            timerArr = [[NSMutableArray alloc] initWithCapacity:0];
        }
        HMTiming *timerObj = [HMTiming object:resultSet];
        [timerArr addObject:timerObj];
    }
    
    [resultSet close];
    return timerArr;
}

+ (HMTiming *)objectWithTimingId:(NSString *)timingId
{
    __block HMTiming *timingObj = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from timing where timingId = '%@'",timingId];
    queryDatabase(sql, ^(FMResultSet *rs) {
       
        timingObj = [HMTiming object:rs];
        
    });
    
    return timingObj;
}

+(NSArray *)availabilityTimingArrWithDeviceId:(NSString *)deviceId
{
    NSMutableArray *timerArr;
    NSString *selectSql = [NSString stringWithFormat:@"select * from timing where deviceId = '%@' and isPause = 1 and delFlag = 0 and timingType = 0 and (showIndex == 0 or showIndex == -1)",deviceId];
    FMResultSet *resultSet = [self executeQuery:selectSql];
    while ([resultSet next]) {
        if (!timerArr) {
            timerArr = [[NSMutableArray alloc] initWithCapacity:0];
        }
        HMTiming *timerObj = [HMTiming object:resultSet];
        [timerArr addObject:timerObj];
    }
    
    [resultSet close];
    return timerArr;
}

+(BOOL)updatePause:(int)isPause timingId:(NSString *)timingId
{
    NSString *updateSql = [NSString stringWithFormat:@"update timing set isPause = %d where timingId = '%@'",isPause, timingId];
    BOOL result = [self executeUpdate:updateSql];
    return result;
}

+(BOOL)deleteTimerWithTimingId:(NSString *)timingId
{
    NSString *deleteSql = [NSString stringWithFormat:@"delete from timing where timingId = '%@'", timingId];
    BOOL result = [self executeUpdate:deleteSql];
    return result;
}


+(BOOL)sameHour:(int)hour minute:(int)minute newTimerWeek:(int)newWeek deviceId:(NSString *)deviceId
{
    return [HMTiming sameHour:hour minute:minute newTimerWeek:newWeek deviceId:deviceId ignoreTimingId:nil];
}


+(BOOL)sameHour:(int)hour minute:(int)minute newTimerWeek:(int)newWeek deviceId:(NSString *)deviceId ignoreTimingId:(NSString *)timingId
{
    NSString *sql;
    if (!timingId) {
        
        // 定时冲突时要将模式定时一起算进去
        
//        sql = [NSString stringWithFormat:@"select * from timing where hour = %d and minute = %d and deviceId = '%@' and isPause = 1 and delFlag = 0 and timingType = 0 and (showIndex == 0 or showIndex == -1)",
//                      hour,minute,deviceId];
        
        sql = [NSString stringWithFormat:@"select * from timing where hour = %d and minute = %d and deviceId = '%@' and isPause = 1 and delFlag = 0",
               hour,minute,deviceId];
    }else{
//        sql = [NSString stringWithFormat:@"select * from timing where hour = %d and minute = %d and deviceId = '%@' and isPause = 1 and delFlag = 0 and timingId != '%@' and timingType = 0 and (showIndex == 0 or showIndex == -1)",hour,minute,deviceId,timingId];
        
        sql = [NSString stringWithFormat:@"select * from timing where hour = %d and minute = %d and deviceId = '%@' and isPause = 1 and delFlag = 0 and timingId != '%@'",hour,minute,deviceId,timingId];
    }
    FMResultSet *resultSet = [self executeQuery:sql];
    NSMutableArray *arr;
    while([resultSet next]) {
        if (!arr) {
            arr = [[NSMutableArray alloc] initWithCapacity:1];
        }
        [arr addObject:[resultSet objectForColumn:@"week"]];
    }
    
    [resultSet close];
    if (arr == nil) {
        return NO;
    }
    int newIsOnce = !(newWeek >> 7 & 0x00000001);
    int newSunday = newWeek >>6 & 0x00000001;
    int newMonday = newWeek & 0x00000001;
    int newTuesDay = newWeek >>1 & 0x00000001;
    int newWednesDay = newWeek >>2 & 0x00000001;
    int newThursday = newWeek >>3 & 0x00000001;
    int newFriday = newWeek >>4 & 0x00000001;
    int newSaturday = newWeek >>5 & 0x00000001;
    
    for (id weekObj in arr) {
        int week = [weekObj intValue];
        if (week == newWeek) {
            return YES;
        }
        int oldIsOnce = !(week >> 7 & 0x00000001);
        int oldSunday = week >>6 & 0x00000001;
        int oldMonday = week & 0x00000001;
        int oldTuesDay = week >>1 & 0x00000001;
        int oldWednesDay = week >>2 & 0x00000001;
        int oldThursday = week >>3 & 0x00000001;
        int oldFriday = week >>4 & 0x00000001;
        int oldSaturday = week >>5 & 0x00000001;
        
        //旧的和新的都是多次
        if (oldIsOnce == 0 && newIsOnce == 0){
            if ((oldSunday == 1 && newSunday == 1)       || (oldMonday == 1 && newMonday == 1) || (oldTuesDay == 1 && newTuesDay == 1) ||
                (oldWednesDay == 1 && newWednesDay == 1) || (oldThursday == 1 && newThursday == 1) ||
                (oldFriday == 1 && newFriday == 1)       || (oldSaturday == 1 && newSaturday == 1)) {
                return YES;
            }
        }else if (oldIsOnce == 1 && newIsOnce == 1){//旧的和新的都是单次
            return YES;
        }
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *timerComp = [calendar components:NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[NSDate date]];
        NSInteger currentWeekday = [timerComp weekday];//1:星期日、2:星期一、3:星期二 ...
        NSInteger currentHour = [timerComp hour];
        NSInteger currentMinute = [timerComp minute];
        currentWeekday -= 1;
        if (currentWeekday == 0) {
            currentWeekday = 7;
        }
        //7:星期日、1:星期一、2:星期二 ...
        if (newIsOnce && !oldIsOnce) {//要新增的定时是单次,已存在相同时分的定时是多次
            //如果新增的定时时间比当前时间小，那么将在明天执行，所以新设置的定时周要加1后才能与已存在的定时的周比较
            if (hour*60+minute < currentHour*60+currentMinute) {
                currentWeekday++;
                if (currentWeekday == 8) {
                    currentWeekday = 1;
                }
            }
            switch (currentWeekday) {
                case 1:
                    if (oldMonday) {
                        return YES;
                    }
                    break;
                case 2:
                    if (oldTuesDay) {
                        return YES;
                    }
                    break;
                case 3:
                    if (oldWednesDay) {
                        return YES;
                    }
                    break;
                case 4:
                    if (oldThursday) {
                        return YES;
                    }
                    break;
                case 5:
                    if (oldFriday) {
                        return YES;
                    }
                    break;
                case 6:
                    if (oldSaturday) {
                        return YES;
                    }
                    break;
                case 7:
                    if (oldSunday) {
                        return YES;
                    }
                    break;
                    
                default:
                    break;
            }
        }
        if (!newIsOnce && oldIsOnce) {//要新增的定时是多次，已存在旧的定时是单次
            //如果旧的定时时间小于当前的时间，那么该已存在的定时将明天执行，所以该条单次的定时的week（currentWeekday）要加1
            if (hour*60+minute < currentHour*60+currentMinute) {
                currentWeekday++;
                if (currentWeekday == 8) {
                    currentWeekday = 1;
                }
            }
            switch (currentWeekday) {
                case 1:
                    if (newMonday) {
                        return YES;
                    }
                    break;
                case 2:
                    if (newTuesDay) {
                        return YES;
                    }
                    break;
                case 3:
                    if (newWednesDay) {
                        return YES;
                    }
                    break;
                case 4:
                    if (newThursday) {
                        return YES;
                    }
                    break;
                case 5:
                    if (newFriday) {
                        return YES;
                    }
                    break;
                case 6:
                    if (newSaturday) {
                        return YES;
                    }
                    break;
                case 7:
                    if (newSunday) {
                        return YES;
                    }
                    break;
                    
                default:
                    break;
            }
            
        }
    }
    return NO;
}

+ (NSArray *)appointmentProgramsWithDeviceId:(NSString *)deviceId
{
    NSMutableArray *array = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from timing where deviceId = '%@' and isPause = 1 and timingType = 2 and delFlag = 0",deviceId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMTiming *timingModel = [HMTiming object:rs];
        [array addObject:timingModel];
    });
    return array;
}

+ (BOOL)isHasOrderProgramInHour:(int)hour minute:(int)minute week:(int)week isHd:(BOOL)isHd deviceId:(NSString *)deviceId name:(NSString *)name
{
    __block BOOL isHas = NO;
    NSString *sql = [NSString stringWithFormat:@"select * from timing where isPause = 1 and timingType = 2 and delFlag = 0 and hour = %d and minute = %d and week = %d and isHD = %d and deviceId = '%@' and name = '%@'",hour,minute,week,isHd,deviceId,name];
    queryDatabase(sql, ^(FMResultSet *rs) {
        isHas = YES;
    });
    return isHas;
}

+ (HMTiming *)orderProgramInHour:(int)hour minute:(int)minute week:(int)week isHd:(BOOL)isHd deviceId:(NSString *)deviceId name:(NSString *)name
{
    __block HMTiming *timingModel = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from timing where isPause = 1 and timingType = 2 and delFlag = 0 and hour = %d and minute = %d and week = %d and isHD = %d and deviceId = '%@' and name = '%@'",hour,minute,week,isHd,deviceId,name];
    queryDatabase(sql, ^(FMResultSet *rs) {
        timingModel = [HMTiming object:rs];
    });
    return timingModel;
}

@end
