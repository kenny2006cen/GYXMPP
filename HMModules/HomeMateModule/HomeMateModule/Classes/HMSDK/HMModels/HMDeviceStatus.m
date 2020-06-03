//
//  VihomeDeviceStatus.m
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMDeviceStatus.h"

#import "HMDevice.h"
#import "HMDoorLockRecordModel.h"
#import "HMConstant.h"

@implementation HMDeviceStatus

+(NSString *)tableName
{
    return @"deviceStatus";
}

+ (NSArray*)columns
{
    return @[column("statusId","text"),
             column("uid","text"),
             column("deviceId","text"),
             column("value1","integer"),
             column("value2","integer"),
             column("value3","integer"),
             column("value4","integer"),
             column("online","integer"),
             column("alarmType","integer"),
             column("updateTime","text"),
             column("updateTimeSec","integer default 0"),
             column("delFlag","integer default 0")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (deviceId, uid) ON CONFLICT REPLACE";
}

+ (NSArray<NSDictionary *>*)newColumns
{
    return @[column("updateTimeSec","integer default 0"),column("delFlag","integer default 0")];
}

- (void)prepareStatement
{
    self.statusId = self.statusId ?: @"";
    
    // WiFi设备的属性报告中没有updateTime字段，无法满足 newdata.updateTime > olddata.updateTime，导致最新的属性报告无法插入数据库
    // 此处赋空值，然后判断条件中增加添加：length(newdata.updateTime) < 1，如果updateTime长度小于1，则直接插入数据库
    self.updateTime = self.updateTime ?: @"";
}

- (NSString *)updateStatement
{
    /**
     1.本地没有当前插入的这条记录 则插入
     2.本地已有当前插入的这条记录 updateTimeSec0 > updateTimeSec1 则插入
     3.本地已有当前插入的这条记录 updateTimeSec0 <= updateTimeSec1 则不需要插入
     */
    [self prepareStatement];
    NSString * sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO deviceStatus "
                      "SELECT newdata.* FROM (SELECT '%@' AS statusId,'%@' as uid,'%@' AS deviceId,%d AS value1,%d AS value2,%d AS value3,%d AS value4,%d AS online,%d AS alarmType, '%@' AS updateTime,%d AS updateTimeSec,%d AS delFlag) AS newdata "
                      "LEFT JOIN deviceStatus AS olddata ON newdata.deviceId = olddata.deviceId "
                      "WHERE length(newdata.updateTime) < 1 OR newdata.updateTimeSec = 0 OR newdata.updateTimeSec >= olddata.updateTimeSec OR olddata.deviceId IS NULL"
                      ,self.statusId,self.uid,self.deviceId,self.value1,self.value2,self.value3,self.value4,self.online,self.alarmType,self.updateTime,self.updateTimeSec,self.delFlag];
    return sql;
}

-(void)setInsertWithDb:(FMDatabase *)db{
    [self insertModel:db];
}
-(BOOL)insertModel:(FMDatabase *)db{
    return [db executeUpdate:self.sql]; // self.sql == [self updateStatement]
}
- (BOOL)insertObject{
    return [self executeUpdate:self.sql]; // self.sql == [self updateStatement]
}



- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from deviceStatus where statusId = '%@' and uid = '%@'",self.statusId,self.uid];
    BOOL result = [self executeUpdate:sql];
    return result;
}


+ (instancetype)saveProperty:(NSDictionary *)dic
{
    @autoreleasepool {
        
        NSString *uid = dic[@"uid"];
        NSString * deviceId = dic[@"deviceId"];
        
        
        HMDevice *device = nil;
        
        // coco ，s20等wifi设备
        if ([deviceId isEqualToString:@"0"]) {
            
            device = [HMDevice objectWithUid:uid];
        }else{
            
            // Zigbee 设备
            device = [HMDevice objectWithDeviceId:deviceId uid:uid];
            
        }
        
        // 设备表里面有这个设备
        if (device) {
            
            DLog(@"设备名称:%@ 类型:%d deviceId:%@ mac地址:%@ 状态:value1 = %@,value2 = %@,value3 = %@,value4 = %@"
                 ,device.deviceName,device.deviceType,device.deviceId,device.extAddr,dic[@"value1"],dic[@"value2"]
                 ,dic[@"value3"],dic[@"value4"]);
            
            NSNumber *statusType = dic[@"statusType"];
            // 电量值状态，此时只有value3、value4的值有效。客户端接收到这个属性报告之后只把value3、value4的值替换掉。安防传感器填写设备类型）
            if (statusType.intValue == 3) {
                
                NSNumber *value3 = dic[@"value3"];
                NSNumber *value4 = dic[@"value4"];
                
                NSString *sql = [NSString stringWithFormat:@"update deviceStatus set online = 1,value3 = %d,value4 = %d"
                                 " where uid = '%@' and deviceId = '%@'",value3.intValue,value4.intValue,uid,device.deviceId];// 如果是wifi设备，deviceId 值为"0"
                updateInsertDatabase(sql);
                
                HMDeviceStatus *deviceStatus = [HMDeviceStatus objectWithDeviceId:deviceId uid:uid];
                deviceStatus.relatedDevice = (HMDevice *)device;
                return deviceStatus;
            }
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:dic];
            dict[@"deviceId"] = device.deviceId; // 如果是wifi设备，deviceId 值为"0"
            dict[@"online"] = @(1);
            dict[@"statusId"] = @"";
            HMDeviceStatus * status = [HMDeviceStatus objectFromDictionary:dict];
            status.relatedDevice = (HMDevice *)device;
            status.deviceId = device.deviceId;
            
            // 配电箱的属性报告有三种（开关、异常信息、电压电流等正常属性）：
            // 只插入开关属性报告（statusType = 0），statusType = 64 表示非开关属性
            if (statusType.intValue == KDeviceTypeOldDistBox
                || statusType.intValue == KDeviceTypeNewDistBox
                // 单火开关报警属性不插入
                || statusType.intValue == KDeviceTypeSingleFireSwitch) {
                return status;
            }
            
            
            // 旧门锁给提示
            [status postAlertWithLock:device];
            
            NSDictionary *payload = dic[@"payload"];
            if (payload) {
                // 智能门锁才会有这个payload,有这个payload说明是事件，不属于状态改变，这里就不保存
                
                NSMutableDictionary *payloadDic = [NSMutableDictionary dictionaryWithDictionary:payload];
                payloadDic[@"uid"] = uid;
                HMDoorLockRecordModel *doorLockRecord = [HMDoorLockRecordModel objectFromDictionary:payloadDic];
                [doorLockRecord insertObject];
                
                [HMBaseAPI postNotification:KNOTIFICATION_DOOR_OPNE object:dic];
                
                // 这里加一个T1门锁判断，因为其他门锁的逻辑不清楚 by lq
                // 对于T1门锁，有payload时是开门上报，此时上报的其他value值是不对的，所以不更新到数据库中
                if(device.deviceType == KDeviceTypeOrviboLock){
                    HMDeviceStatus *deviceStatus = [HMDeviceStatus objectWithDeviceId:deviceId uid:uid];
                    DLog(@"收到T1门锁事件性属性报告 %@，这里不保存 直接返回，status",dic);
                    return deviceStatus;
                }
            }
            
            BOOL result = [status insertObject];
            
            if (!result) {
                DLog(@"属性报告保存失败!!!!!!!!");
            }
            
            return status;
        }else {//如果是子账号有组的权限，但是没有设备的权限，这里是查不到device的，但是组的状态又是根据设备的状态来显示的，所以如果是子账号，也保存一下
            if(!userAccout().isAdministrator) {
                HMDeviceStatus * status = [HMDeviceStatus objectFromDictionary:dic];
                status.statusId = @"";
                status.online = 1;
                BOOL result = [status insertObject];
                if (!result) {
                    DLog(@"属性报告保存失败!!!!!!!!");
                }
                return status;
            }
            

        }
        return nil;
    }
}

-(void)postAlertWithLock:(HMDevice *)device
{
    if (device.deviceType == KDeviceTypeLock && [device.model isKindOfClass:[NSString class]]) {
        
        if ([device.model isEqualToString:kAierFuDeDoorModelId] // 爱而福度门锁,开锁时进行toast提示
            || (!isSmartDoorLock(device))){    // 非智能门锁，需要弹框提示
            
            HMDeviceStatus *deviceStatus = self;
            static int _statusSerialNumber = 0;
            
            DLog(@"旧门锁的属性报告流水号：%d",_statusSerialNumber);
            
            if (_statusSerialNumber != deviceStatus.serial) {
                _statusSerialNumber = deviceStatus.serial;
                
                // 爱而福度的门锁，只有开锁的时候，才进行toast提示。
                if ([device.model isEqualToString:kAierFuDeDoorModelId]) {
                    if (deviceStatus.value1 == 0) {
                        [HMBaseAPI postNotification:KNOTIFICATION_OLD_DOORLOCK_OPNE object:deviceStatus];
                    }
                    
                } else {
                    [HMBaseAPI postNotification:KNOTIFICATION_OLD_DOORLOCK_OPNE object:deviceStatus];
                }
                
            }
            
        }
    }
}

+ (BOOL)isHasStatusWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [NSString stringWithFormat:@"select * from deviceStatus where deviceId = '%@'",deviceId];
    FMResultSet * rs = [self executeQuery:sql];
    BOOL hasStatus = NO;
    if([rs next])
    {
        hasStatus = YES;
    }
    [rs close];
    return hasStatus;
}


+ (instancetype)objectWithDeviceId:(NSString *)deviceId uid:(NSString *)uid
{
    
    NSString *sql = uid
    ? [NSString stringWithFormat:@"select * from deviceStatus where deviceId = '%@' and uid = '%@'",deviceId,uid]
    : [NSString stringWithFormat:@"select * from deviceStatus where deviceId = '%@'",deviceId];
    
    FMResultSet * rs = [self executeQuery:sql];
    
    if([rs next])
    {
        HMDeviceStatus *object = [HMDeviceStatus object:rs];
        
        [rs close];
        
        return object;
    }
    [rs close];
    
    return nil;
}

- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:self.online] forKey:@"online"];
    [dic setObject:[NSNumber numberWithInt:self.value1] forKey:@"value1"];
    [dic setObject:[NSNumber numberWithInt:self.value2] forKey:@"value2"];
    [dic setObject:[NSNumber numberWithInt:self.value3] forKey:@"value3"];
    [dic setObject:[NSNumber numberWithInt:self.value4] forKey:@"value4"];
    [dic setObject:self.deviceId forKey:@"deviceId"];
    if (self.updateTime) {
        [dic setObject:self.updateTime forKey:@"updateTime"];
    }
    
    return dic;
}

+ (BOOL)updateOnlineStatus:(int)status deviceId:(NSString *)deviceId
{
    NSString *sql = [NSString stringWithFormat:@"update deviceStatus set online = %d where deviceId = '%@'",status,deviceId];
   BOOL ret = updateInsertDatabase(sql);
   return ret;
}


+ (BOOL)rgbwRGBEndPointIsOnWithExtAddr:(HMDevice *)device
{
    // rgbw 只要有一路为开则为开
    __block BOOL isOn = NO;
    NSString *sql = [NSString stringWithFormat:@"select value1 from deviceStatus where deviceId in (select deviceId from device where extAddr = '%@' and uid = '%@' and deviceType = %d)",device.extAddr,device.uid,KDeviceTypeRGBLight];
    queryDatabase(sql, ^(FMResultSet *rs) {
        int value = -1;
        value = [rs intForColumn:@"value1"];
        if (value == 0) {
            isOn = YES;
        }
    });
    return isOn;
}

+ (BOOL)rgbWIsOnWithExtAddr:(HMDevice *)device
{
    // rgbw 只要有一路为开则为开
   __block BOOL isOn = NO;
    NSString *sql = [NSString stringWithFormat:@"select value1 from deviceStatus where deviceId in (select deviceId from device where extAddr = '%@' and uid = '%@')",device.extAddr,device.uid];
    queryDatabase(sql, ^(FMResultSet *rs) {
        int value = -1;
        value = [rs intForColumn:@"value1"];
        if (value == 0) {
            isOn = YES;
        }
    });
    return isOn;
}

- (id)copyWithZone:(NSZone *)zone
{
    HMDeviceStatus *copySelf = [[HMDeviceStatus alloc]init];
    copySelf.statusId = self.statusId;
    copySelf.uid = self.uid;
    copySelf.deviceId = self.deviceId;
    copySelf.value1 = self.value1;
    copySelf.value2 = self.value2;
    copySelf.value3 = self.value3;
    copySelf.value4 = self.value4;
    copySelf.online = self.online;
    return copySelf;
}

@end
