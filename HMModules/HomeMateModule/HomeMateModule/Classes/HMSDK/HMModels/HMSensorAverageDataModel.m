//
//  HMSensorAverageDataModel.m
//  HomeMateSDK
//
//  Created by PandaLZMing on 16/11/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HomeMateSDK.h"

static NSString *formatString = @"yyyy-MM-dd HH:mm:ss";

#import "HMSensorAverageDataModel.h"

@implementation HMSensorAverageDataModel


+ (NSString *)tableName {
    
    return @"sensorAverageData";
}

+ (NSArray*)columns
{
    return @[
             column("deviceId","text"),
             column("familyId","text"),
             column("average","text"),
             column("time","text"),
             column("uid","text"),
             column("max","text"),
             column("min","text"),
             column("dataType","integer"),
             ];
}

- (void)prepareStatement {

    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
    
    if (!self.max || [self.max isEqual:[NSNull null]]) {
        self.max = @"-1";
    }
    
    if (!self.min || [self.min isEqual:[NSNull null]]) {
        self.min = @"-1";
    }
}

-(NSString *)hour
{
    if (self.time.length >= formatString.length) {
        return [self.time substringWithRange:NSMakeRange(11, 5)];
    }
    return @"10:00";
}

-(NSNumber *)value
{
    /*
     if (self.device.deviceType == KDeviceTypeTemperatureSensor) {
     if (fahrenheit) {
     temp.value1 = (((temp.value1/100+(temp.value1%100>49?1:0))*1.8)+32)*100;
     }
     [valueArray addObject:@(temp.value1/100+(temp.value1%100>49?1:0))];
     }else if (self.device.deviceType == KDeviceTypeHumiditySensor){
     [valueArray addObject:@(temp.value2/100+(temp.value2%100>49?1:0))];
     }
     */
    return @((int)round(self.average.doubleValue/100.0));
}

-(NSNumber *)fahrenheit
{
    // 华氏度(℉)=32+摄氏度(℃)×1.8
    return @(32 + (int)round(self.average.doubleValue/100.0 * 1.8));
    
}

+ (HMSensorAverageDataModel *)objectWithDic:(NSDictionary *)dic deviceId:(NSString *)deviceId uid:(NSString *)uid dataType:(kQuerySensorDataType)dataType isNeedToTranformTime:(BOOL)isneedToTranformTime isNeedTranformAverage:(BOOL)isneedToTranformAverage {

    HMSensorAverageDataModel *model = [[HMSensorAverageDataModel alloc] init];
    model.deviceId = deviceId;
    model.uid = uid;
    model.dataType = dataType;
    model.max = dic[@"max"];
    model.min = dic[@"min"];

    if (isneedToTranformTime) {
        model.time = dic[@"time"];
        model.tranformTime = [self transformDateString:dic[@"time"]];
    } else {
        model.time = dic[@"time"];
    }

    if (isneedToTranformAverage) {
        NSString *average = dic[@"average"];
        if (!average || [average isEqual:[NSNull null]]) {      // 如果为空，默认给一个 -1
            model.average = @"-1";
        } else {
            model.average = average;
        }
    } else {
        model.average = dic[@"average"];
    }
    return model;
}

+ (NSString *)transformDateString:(NSString *)dateString {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
    NSDate *date = [dateFormatter dateFromString:dateString];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *compsMonthAndDay = [calendar components:NSCalendarUnitMonth| NSCalendarUnitDay fromDate:date];
    NSInteger month = [compsMonthAndDay month];
    NSInteger day = [compsMonthAndDay day];
    return [NSString stringWithFormat:@"%ld/%ld",(long)month, (long)day]; //返回格式：11/11
}

+ (NSArray *)readSensorDataArrayWithDeviceId:(NSString *)deviceId dataType:(kQuerySensorDataType)dataType {
    NSString *sql = [NSString stringWithFormat:@"select * from sensorAverageData where deviceId = '%@' and familyId = '%@' and dataType = %ld order by time asc",deviceId,userAccout().familyId ,(long)dataType];

    __block NSMutableArray *dataArray = [NSMutableArray array];

    queryDatabase(sql, ^(FMResultSet *rs) {
        HMSensorAverageDataModel *model = [HMSensorAverageDataModel object:rs];
        [dataArray addObject:model];
    });
    return dataArray;
}

+ (NSArray *)dataArrayWithDeviceId:(NSString *)deviceId dataType:(kQuerySensorDataType)dataType{

    NSString *sql = [NSString stringWithFormat:@"select * from sensorAverageData where deviceId = '%@' and familyId = '%@' and dataType = %ld order by time asc",deviceId,userAccout().familyId ,(long)dataType];

    __block NSString *nowDateString = @"";
    __block NSMutableArray *dataArray = [NSMutableArray new];
    __block NSMutableArray *valueArray = [NSMutableArray new];    // 数值数组，格式为：[[1,2,3...], [2,3,4...],...] 数组里面的一个数组对应一天
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMSensorAverageDataModel *model = [HMSensorAverageDataModel object:rs];
        model.tranformTime = [self transformDateString:model.time];
        if (valueArray.count == 0) {
            nowDateString = model.tranformTime;
        }
        if ([model.tranformTime isEqualToString:nowDateString]) {       // 相同代表为同一天

            [valueArray addObject:model.average];

        } else {

            NSDictionary *oneDayDic = @{@"date": nowDateString,
                                        @"values": valueArray.copy};

            [dataArray addObject:oneDayDic];    // 先把一天的数据存好

            nowDateString = model.tranformTime; // 更新当前天日期
            [valueArray removeAllObjects];  // 移除当天的数据
            [valueArray addObject:model.average];
        }
    });
    NSDictionary *oneDayDic = @{@"date": nowDateString,
                                @"values": valueArray};
    [dataArray addObject:oneDayDic];    // 把最后一天的数据存好
    return dataArray;

}

+ (NSArray *)modelWithDeviceId:(NSString *)deviceId dataType:(kQuerySensorDataType)dataType{
    
    NSString *sql = [NSString stringWithFormat:@"select * from sensorAverageData where deviceId = '%@' and familyId = '%@' and dataType = %ld order by time asc",deviceId,userAccout().familyId ,(long)dataType];
    
    __block NSString *nowDateString = @"";
    __block NSMutableArray *dataArray = [NSMutableArray new];
    __block NSMutableArray *valueArray = [NSMutableArray new];    // 数值数组，格式为：[[1,2,3...], [2,3,4...],...] 数组里面的一个数组对应一天
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMSensorAverageDataModel *model = [HMSensorAverageDataModel object:rs];
        model.tranformTime = [self transformDateString:model.time];
        if (valueArray.count == 0) {
            nowDateString = model.tranformTime;
        }
        if ([model.tranformTime isEqualToString:nowDateString]) {       // 相同代表为同一天
            
            [valueArray addObject:model];
            
        } else {
            
            NSDictionary *oneDayDic = @{@"date": nowDateString,
                                        @"values": valueArray.copy};
            
            [dataArray addObject:oneDayDic];    // 先把一天的数据存好
            
            nowDateString = model.tranformTime; // 更新当前天日期
            [valueArray removeAllObjects];  // 移除当天的数据
            [valueArray addObject:model];
        }
    });
    
    if (![nowDateString isEqualToString:@""]) { //如果nowDateString有值
        
        NSDictionary *oneDayDic = @{@"date": nowDateString,
                                    @"values": valueArray};
        [dataArray addObject:oneDayDic];    // 把最后一天的数据存好
    }
    
    return dataArray;
    
}


+ (void)deleteDataWithDeviceId:(NSString *)deviceId dataType:(kQuerySensorDataType)dataType {
    // 这里需要删除 dataType ＝ 0 的原因是，dataType 是后来加上的，如果旧版本没有 dataType，默认数值就为0，属于错误数据，所以需要删除；
    NSString *sql = [NSString stringWithFormat:@"delete from sensorAverageData where deviceId = '%@' and familyId = '%@' and dataType in (0, %ld)", deviceId,userAccout().familyId, (long)dataType];
    [self executeUpdate:sql];
}

@end
