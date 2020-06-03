//
//  HMDistBoxAttributeModel.m
//  HomeMateSDK
//
//  Created by liuzhicai on 16/10/17.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMDistBoxAttributeModel.h"
#import "HomeMateSDK.h"


@implementation HMDistBoxAttributeModel

+(NSString *)tableName
{
    return @"distBoxAttribute";
}

+ (NSArray*)columns
{
    return @[column("deviceId","text"),
             column("attributeId","integer"),
             column("attrValue","integer"),
             column("updateTime","text")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE(deviceId,attributeId) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


+ (NSString *)queryAttrValueSqlWithAttributeId:(int)attributeId deviceId:(NSString *)deviceId
{
    NSString *sql = [NSString stringWithFormat:@"select attrValue from distBoxAttribute where attributeId = %d and deviceId = '%@'",attributeId,deviceId];
    return sql;
}

+ (HMDistBoxAttributeModel *)abnormalObjectWithDevice:(HMDevice *)device{
    NSString *sql = [NSString stringWithFormat:@"select * from distBoxAttribute where deviceId = '%@' and attributeId = %ld",device.deviceId,device.deviceType == KDeviceTypeNewDistBox ? (long)KAttributeTypeNewBoxAbnormalTag : (long)KAttributeTypeMainsAlarmMask];
    __block HMDistBoxAttributeModel *model = nil;
    queryDatabase(sql, ^(FMResultSet *rs) {
        model = [HMDistBoxAttributeModel object:rs];
    });
    return model;
}

+ (int)queryIntValueSql:(NSString *)sql
{
    int attrValue = kDistBoxAttributeDefaultValue;
    FMResultSet *set = [self executeQuery:sql];
    if ([set next]) {
        attrValue = [set intForColumn:@"attrValue"];
    }
    [set close];
    return attrValue;
}



+ (int)abnormalValueWithDevice:(HMDevice *)device
{
    int value2 = 0; // 默认处于正常
//    DLog(@"abnormalValueWithDevice : %@",device.deviceId);
    // 上报的异常属性存在 HMDistBoxAttributeModel
    HMDistBoxAttributeModel *dboxAttriModel = [self abnormalObjectWithDevice:device];
    
    // 为防止异常属性丢失，主机在deviceSetting表备份了一份异常属性的值
    HMDeviceSettingModel *abnormalObj = [HMDeviceSettingModel abnormalDistObjWithDeviceId:device.deviceId];
    
    if (dboxAttriModel && abnormalObj) {
        
        // 两个都有，用最新时间的
        NSComparisonResult res =   [dboxAttriModel.updateTime compare:abnormalObj.updateTime];
        if (res == NSOrderedAscending) {
            value2 = [abnormalObj.paramValue intValue];
        }else {
            value2 = dboxAttriModel.attrValue;
        }
        
        DLog(@"两张表都有异常属性 dboxAttriModel.updateTime : %@  abnormalObj.updateTime: %@",dboxAttriModel.updateTime,abnormalObj.updateTime);
        
    }else if (!dboxAttriModel && abnormalObj){
        value2 = [abnormalObj.paramValue intValue];
        
        DLog(@"abnormalObj.updateTime: %@",abnormalObj.updateTime);
        
    }else if (dboxAttriModel && !abnormalObj) {
        value2 = dboxAttriModel.attrValue;
        
        DLog(@"dboxAttriModel.updateTime: %@",dboxAttriModel.updateTime);
    }
    
    return value2;
}

+ (CGFloat)voltageWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [self queryAttrValueSqlWithAttributeId:KAttributeTypeMainsVoltage deviceId:deviceId];
    int value2 = [self queryIntValueSql:sql];
    return value2 >=0 ? (value2/10.0) : kDistBoxAttributeDefaultValue;
}

+ (CGFloat)currentWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [self queryAttrValueSqlWithAttributeId:KAttributeTypeMainsCurrent deviceId:deviceId];
    int value2 = [self queryIntValueSql:sql];
    return value2 >=0 ? (value2/1000.0) : kDistBoxAttributeDefaultValue;
}

+ (CGFloat)powerWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [self queryAttrValueSqlWithAttributeId:KAttributeTypePower deviceId:deviceId];
    int value2 = [self queryIntValueSql:sql];
    return value2 >=0 ? (value2/10.0) : kDistBoxAttributeDefaultValue;
}

+ (CGFloat)powerFactorWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [self queryAttrValueSqlWithAttributeId:KAttributeTypePowerFatcor deviceId:deviceId];
    int value2 = [self queryIntValueSql:sql];
    
    return value2 >=0 ? (value2 / 100.0) : kDistBoxAttributeDefaultValue;
}

+ (CGFloat)overVoltageWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [self queryAttrValueSqlWithAttributeId:KAttributeTypeVoltageOverLoad deviceId:deviceId];
    return [self queryIntValueSql:sql]/10.0;
}

+ (CGFloat)overCurrentWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [self queryAttrValueSqlWithAttributeId:KAttributeTypeCurrentOverLoad deviceId:deviceId];
    return [self queryIntValueSql:sql]/1000.0;
}

+ (void)updateAbnormalFlagWithDeviceId:(NSString *)deviceId
{
   NSString *sql = [NSString stringWithFormat:@"update distBoxAttribute set attrValue = 0 where attributeId = %ld and deviceId = '%@'",(long)KAttributeTypeMainsAlarmMask,deviceId];
   BOOL result = updateInsertDatabase(sql);
   DLog(@"重置配电箱分控deviceId：%@ 的异常标志位：%@",deviceId,result ? @"成功！" : @"失败！");
}

+ (void)deleteRealTimeDataWithExtAddr:(NSString *)extAddr {
    
    NSString *sql = [NSString stringWithFormat:@"delete from distBoxAttribute where attributeId in (%ld,%ld,%ld,%ld) and deviceId in (select deviceId from device where extAddr = '%@' and delFlag = 0)",(long)KAttributeTypeMainsVoltage,(long)KAttributeTypeMainsCurrent,(long)KAttributeTypePower,(long)KAttributeTypePowerFatcor,extAddr];
    BOOL result =  [[HMDatabaseManager shareDatabase] executeUpdate:sql];
    DLog(@"删除配电箱extAddr：%@ 实时数据  %@",extAddr,result ? @"成功" : @"失败");
}

+ (void)resetVoltageToZeroWithExtAddr:(NSString *)extAddr {
    
    NSString *sql = [NSString stringWithFormat:@"update distBoxAttribute set attrValue = 0 where attributeId = 0 and deviceId in (select deviceId from device where extAddr = '%@' and delFlag = 0 and endPoint > 1)",extAddr];
   BOOL result =  [[HMDatabaseManager shareDatabase] executeUpdate:sql];
   DLog(@"重置配电箱extAddr：%@ 电压 %@",extAddr,result ? @"成功" : @"失败");
}

+ (int)rateCurrentValueWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [self queryAttrValueSqlWithAttributeId:KAttributeTypeRatedCurrent deviceId:deviceId];
    return [self queryIntValueSql:sql];
}

//+ (BOOL)hasAbnormalInfoWithDevice:(HMDevice *)device
//{
//    int abnormalValue = [self abnormalValueWithDevice:device];
//    
//    if (device.deviceType == KDeviceTypeNewDistBox) {
//        
//        if (abnormalValue == 0) {
//            DLog(@"新配电箱无异常");
//            return NO; // 无异常
//        }
//        // (16位分别表示的报警含义如下：某一位为1 则报警，0 则正常)
//        // 15电流预警 14漏电预警 13过压预警 12欠压预警 11欠压报警 10打火报警 9  8漏电保护自检未完成 7漏电保护功能正常  6过压报警 5过流报警 4漏电报警 3温度报警 2过载报警 1浪涌报警 0短路报警
//        NSString *binaryStr = [BLUtility getSixteenBitBinaryByDecimal:(NSInteger)abnormalValue];
//        if (binaryStr.length < 16) {
//            return NO;
//        }
//        int underVoltageBitValue = [[binaryStr substringWithRange:NSMakeRange(4, 1)] intValue];// 欠压位的值
//        int overVoltageBitValue = [[binaryStr substringWithRange:NSMakeRange(9, 1)] intValue];  // 过压位的值
//        int overCurrentBitValue = [[binaryStr substringWithRange:NSMakeRange(10, 1)] intValue]; // 过流位的值
//        int leagkeEletriBitValue = [[binaryStr substringWithRange:NSMakeRange(11, 1)] intValue];// 漏电位的值
//    
//        DLog(@"新配电箱异常信息deviceId：%@ 欠压位:%d 过压位:%d 过流位:%d 漏电位:%d",device.deviceId,underVoltageBitValue,overVoltageBitValue,overCurrentBitValue,leagkeEletriBitValue);
//        BOOL ret  = (underVoltageBitValue || overVoltageBitValue || overCurrentBitValue || leagkeEletriBitValue);
////        DLog(@"新配电箱是否有异常：ret ：%d",ret);
//        return ret;
//    }
//    
//    // 旧配电箱走以下逻辑
//    if (abnormalValue == KDBoxAbnorTypeOverVoltage // 过压
////        || abnormalValue == KDBoxAbnorTypeOverCurrentAndVoltage // 过压过流
//        || abnormalValue == KDBoxAbnorTypeOverCurrent // 过流
//        || abnormalValue == KDBoxAbnorTypeUnderVoltage // 欠压
//
//        )
//    {
//        return YES;
//    }
//   
//    return NO;
//}


@end
