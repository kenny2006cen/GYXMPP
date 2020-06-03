
//
//  VihomeDevice.m
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMDevice.h"
#import "HMConstant.h"

@interface HMDevice ()
@property (nonatomic,strong)NSNumber *isWifiType; // 记录当前设备是否是WiFi类型
@property (nonatomic,strong)NSNumber *isWifiVirtualType;// 记录当前设备是否是WiFi的虚拟设备类型
@end

@implementation HMDevice

+ (NSString *)tableName
{
    return @"device";
}

+ (NSArray*)columns
{
    return @[column("deviceId","text"),
            column("uid","text"),
            column("extAddr","text"),
            column("endpoint","integer"),
            column("profileID","integer"),
            column("deviceName","text"),
            column("appDeviceId","integer"),
            column("deviceType","integer"),
            column("subDeviceType","integer"),
            column("zoneId","integer"),
            column("roomId","text"),
            column("irDeviceId","text"),
            column("company","text"),
            column("model","text"),
            column("version","text"),
            column("createTime","text"),
            column("updateTime","text"),
            column("delFlag","integer"),
            column("blueExtAddr","text"),
            column("isPreset","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (deviceId) ON CONFLICT REPLACE";
}


+ (BOOL)createTrigger
{
    // 先删除旧的触发器，再创建新的触发器
    [self executeUpdate:@"DROP TRIGGER if exists delete_device"];
    
    BOOL result = [self executeUpdate:@"CREATE TRIGGER if not exists delete_device BEFORE DELETE ON device for each row"
                   " BEGIN "
                   
                   // 摄像头表 KDeviceTypeCamera
                   // "DELETE FROM camerainfo where deviceId = old.deviceId and old.deviceType == 14 and type = 0;"
                   // 入网信息表 , 非摄像头，非coco排插，非虚拟红外设备才删除 deviceJoinIn 表
                   // "DELETE FROM deviceJoinIn where extAddr = old.extAddr and uid = old.uid and (old.deviceType != 14 and old.deviceType != 43 and old.appDeviceId != 65535);"
                   // 遥控器绑定表,情景面板 , 遥控器 KDeviceTypeRemote,KDeviceTypeSceneBorad
                   // "DELETE FROM remoteBind where deviceId = old.deviceId and (old.deviceType == 16 or old.deviceType == 15);"
                   // 遥控器绑定表,按键绑定的设备 非摄像头,非红外转发器，非遥控器，非情景面板
                   // "DELETE FROM remoteBind where bindedDeviceId = old.deviceId and (old.deviceType != 14 and old.deviceType != 11 and old.deviceType != 15 and old.deviceType != 16);"
                   // 红外码表,虚拟红外设备 KDeviceIDVirtualDevice
                   "DELETE FROM deviceIr where deviceId = old.deviceId and old.appDeviceId == 65535;"
                   // 红外码表,红外转发器 KDeviceTypeInfraredRelay
                   "DELETE FROM deviceIr where deviceAddress = old.extAddr and old.deviceType == 11;"
                   // 设备状态表 非摄像头,非虚拟红外设备才删除 deviceStatus 表
                   "DELETE FROM deviceStatus where deviceId = old.deviceId and (old.deviceType != 14 and old.appDeviceId != 65535);"
                   // 定时表 非摄像头,非红外转发器，非遥控器，非情景面板
                   "DELETE FROM timing where deviceId = old.deviceId and (old.deviceType != 14 and old.deviceType != 11 and old.deviceType != 15 and old.deviceType != 16);"
                   // 情景绑定表 非摄像头,非红外转发器，非遥控器，非情景面板
                   "DELETE FROM sceneBind where deviceId = old.deviceId and (old.deviceType != 14 and old.deviceType != 11 and old.deviceType != 15 and old.deviceType != 16);"
                   // 普通设备被删除，删除联动输出表
//                   "DELETE FROM linkageOutput where deviceId = old.deviceId and uid = old.uid;"
                   // 传感器设备被删除，删除联动表，联动输出表，联动条件表
//                   "DELETE from linkage where linkageId in (select DISTINCT linkageId from linkageCondition where deviceId = old.deviceId);"
                   //"DELETE from linkageCondition where linkageId in (select DISTINCT linkageId from linkageCondition where deviceId = old.deviceId);"
//                   "DELETE from linkageOutput where linkageId in (select DISTINCT linkageId from linkageCondition where deviceId = old.deviceId);"
                   
                   //删除百分比窗帘的常用模式
                   "DELETE FROM frequentlyMode where deviceId = old.deviceId;"
                   
                   //删除常用设备信息
                   //"DELETE FROM deviceCommon where deviceId = old.deviceId;"
                   
                   //删除常用模式表
                   "DELETE FROM frequentlyMode where deviceId = old.deviceId;"
                   
                   //删除本地设备排序表
                   //"DELETE FROM deviceSort where deviceId = old.deviceId;"
                   
                   //删除模式定时表
                   "DELETE FROM timingGroup where deviceId = old.deviceId;"
                   
                   //删除新门锁用户表
//                   "DELETE FROM doorUserBind where extAddr = old.extAddr;"，这里先去掉，因为如果添加到主机之后，再删除主机，会先删除这个门锁，如果这里删了就读不回来了
                   
                   // 删除messagePush
                   "DELETE FROM messagePush where taskId = old.deviceId;"
                   
                   //删除状态记录表
                   "DELETE FROM statusRecord where deviceId = old.deviceId;"
                   //删除新门锁本地临时用户
                   "DELETE FROM T1RecentVisitRecord where deviceId = old.deviceId;"
                   //删除t1门锁本地忽略的消息
                   "DELETE FROM ignoreAlertRecord where deviceId = old.deviceId;"
                   //删除常用频道
                   "DELETE FROM customChannel where deviceId = old.deviceId;"
                   
                   "END"];
    
    [self executeUpdate:@"DROP TRIGGER if exists delete_old_device_when_search"];
    
    return result;
}

- (void)prepareStatement
{
    if (!self.createTime) {
        self.createTime = self.updateTime;
    }

    if (!self.version) {
        self.version = @"";
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


/**
 *  搜索设备时先删除当前设备的旧数据，再插入新数据
 *
 *  @return
 */
- (BOOL)deleteObjectOnSearchDevice
{
    DLog(@"deleteObjectOnSearchDevice:%@",self);
    // 设备信息表，只删除自己，不删除相关联的设备
    NSString *sql = [NSString stringWithFormat:@"delete from device where uid = '%@' and extAddr = '%@' and endpoint = %d",self.uid,self.extAddr,self.endpoint];
    BOOL result = [self executeUpdate:sql];
    
    return result;
}

- (BOOL)deleteObject
{
    DLog(@"deleteObject:%@",self);
    // coco删除
    if (self.isWifiDevice || [self.extAddr isEqualToString:@"(null)"]) {
        cleanDeviceData(self.uid);
        return YES;
    }

    // 设备信息表，只删除自己，不删除相关联的设备
    NSString *sql = [NSString stringWithFormat:@"delete from device where deviceId = '%@' and uid = '%@'",self.deviceId,self.uid];
    BOOL result = [self executeUpdate:sql];
    
    return result;
}

-(BOOL)deleteObjectAndRelatedObject
{
    DLog(@"deleteObjectAndRelatedObject:%@",self);
    NSMutableString *sql = [NSMutableString string];
    
    if (self.deviceType == KDeviceTypeOrdinaryLight
        || self.deviceType == KDeviceTypeSingleFireSwitch// 普通灯，二，三路灯
        || (self.deviceType == KDeviceTypeSwitchedElectricRelay)    // 三路继电器
        || (self.deviceType == KDeviceTypeInfraredRelay)            // 红外转发器
        || isVRVAirConditionController(self)                        // VRV主控制器
        || (self.deviceType == KDeviceTypeSensorAccessModuleType)) {
        
        [sql appendFormat:@"delete from device where extAddr = '%@' and uid = '%@'",self.extAddr,self.uid];
        
    }else {
        
        [sql appendFormat:@"delete from device where deviceId = '%@' and uid = '%@' ",self.deviceId,self.uid];
        
    }
    if (self.deviceType == KDeviceTypeLock||
        self.deviceType == KDeviceTypeInfraredSensor||
        self.deviceType == KDeviceTypeLuminanceSensor||
        self.deviceType == KDeviceTypeMagneticDoor ||
        self.deviceType == KDeviceTypeMagneticWindow||
        self.deviceType == KDeviceTypeMagneticDrawer||
        self.deviceType == KDeviceTypeTemperatureSensor||
        self.deviceType == KDeviceTypeHumiditySensor||
        self.deviceType == KDeviceTypeMagneticOther) {
        [HMLinkage deleteLinkageWithDeviceId:self.deviceId];
    }else if (self.deviceType == kDeviceTypeWaterDetector
              ||  self.deviceType == KDeviceTypeCarbonMonoxideAlarm
              || self.deviceType == KDeviceTypeSmokeTransducer
              || self.deviceType == KDeviceTypeMagnet) {
        [HMLinkage deleteSecurityWithDeviceId:self.deviceId];
        
    }
    else if (Allone2ModelId(self.model)){
        
        if (self.deviceType == KDeviceTypeAllone) {
            [self deleteObject];
        }else{
            //[[self class] deleteAlloneRemoteRelatedObjectWithDevice:self];
        }
        
    }else if (self.deviceType == kDeviceTypeCODetector ||
              self.deviceType == kDeviceTypeHCHODetector) {
        [HMSensorData deleteWithDeviceId:self.deviceId];
        [HMSensorEvent deleteWithDeviceId:self.deviceId];
        [HMStatusRecordModel deleteWithDeviceId:self.deviceId];
        [self deleteObject];
    }

    BOOL result = [self executeUpdate:sql];
    return result;
}



- (id)copyWithZone:(NSZone *)zone
{
    HMDevice *copySelf = [[HMDevice alloc]init];
    copySelf.deviceId = self.deviceId;
    copySelf.uid = self.uid;
    copySelf.extAddr = self.extAddr;
    copySelf.endpoint = self.endpoint;
    copySelf.profileID = self.profileID;
    copySelf.deviceName = self.deviceName;
    copySelf.appDeviceId = self.appDeviceId;
    copySelf.deviceType = self.deviceType;
    copySelf.subDeviceType = self.subDeviceType;
    copySelf.zoneId = self.zoneId;
    copySelf.roomId = self.roomId;
    copySelf.floorId = self.floorId;
    copySelf.irDeviceId = self.irDeviceId;
    copySelf.company = self.company;
    copySelf.model = self.model;
    copySelf.version = self.version;
    copySelf.updateTime = self.updateTime;
    copySelf.delFlag = self.delFlag;
    return copySelf;
}

-(BOOL)isWifiVirtualDevice
{
    if (!self.isWifiVirtualType) {
        self.isWifiVirtualType = @(NO); // 默认
        if (self.isWifiDevice) {
            // 可以创建虚拟设备的WiFi设备包括：小方，RF主机
            if (AlloneProModelId(self.model) || Allone2ModelId(self.model)) {
                // 小方本身类型：30 RF主机本身类型 67
                if (self.deviceType == KDeviceTypeAllone || self.deviceType == kDeviceTypeRF) {
                    //return NO;
                }else {
                    self.isWifiVirtualType = @(YES);// 虚拟的WiFi设备
                }
            }
        }
    }
    return [self.isWifiVirtualType boolValue];
}
-(BOOL)isWifiDevice
{
    if (!self.isWifiType) {
        if (self.deviceType == kDeviceTypeCoco
            || self.deviceType == KDeviceTypeS20
            || [self.model hasPrefix:@"E10"]) {
            //旧版coco(汉枫, E10＊)model为E10开头，做一下兼容，理论上用deviceType已足够
            self.isWifiType = @(YES);
        }
        else {
            self.isWifiType = @(isWifiDeviceModel(self.model));
        }
    }
    return [self.isWifiType boolValue];
}

- (BOOL)isSecurityDevice {
    if (self.deviceType == KDeviceTypeCamera ||
        self.deviceType == KDeviceTypeLock ||
        self.deviceType == KDeviceTypeInfraredSensor ||
        self.deviceType == KDeviceTypeMagneticDoor ||
        self.deviceType == KDeviceTypeMagneticWindow ||
        self.deviceType == KDeviceTypeMagneticDrawer ||
        self.deviceType == KDeviceTypeMagneticOther ||
        self.deviceType == KDeviceTypeSmokeTransducer ||
        self.deviceType == KDeviceTypeMagnet ||
        self.deviceType == KDeviceTypeCarbonMonoxideAlarm ||
        self.deviceType == kDeviceTypeWaterDetector ||
        self.deviceType == KDeviceTypeEmergencyButton ||
        (self.deviceType == KDeviceTypeSensorAccessModuleType &&
         (self.subDeviceType == KDeviceTypeInfraredSensor ||
          self.subDeviceType == KDeviceTypeDoubleInfrared ||
          self.subDeviceType == KDeviceTypeMagneticDoor ||
          self.subDeviceType == KDeviceTypeMagneticWindow ||
          self.subDeviceType == KDeviceTypeMagneticDrawer ||
          self.subDeviceType == KDeviceTypeMagneticOther ||
          self.subDeviceType == KDeviceTypeSmokeTransducer ||
          self.subDeviceType == KDeviceTypeMagnet ||
          self.subDeviceType == kDeviceTypeWaterDetector ||
          self.subDeviceType == KDeviceTypeEmergencyButton))) {
             
        return YES;
    }
    
    return NO;
    
}

// 是否支持修改类型
- (BOOL)isCurtainSupportTypeVariable {
    
    if ([self.model isEqualToString:KZigebeeCurtainMotorModelID]
        || [self.model isEqualToString:KWiFiEleMachineRollerModelID]
        || [self.model isEqualToString:KWiFiRollerCurtainModelID]) {
        
        return YES;
    }
    return NO;
}

// 仅支持转向
- (BOOL)isCurtainSupportOverTurn {
    
    if ([self.model isEqualToString:@"4b8344b2291d4fb8a335c80887a31974"]
        || [self.model isEqualToString:@"ab14dd765de54f199d40221d3d4a1dcd"]
        || [self.model isEqualToString:@"a9241f3104c1422b82c7ad2cbd5d6fe0"]
        || [self.model isEqualToString:@"e04b8c08ed8942ec9949a2b67a0da1ef"]
        || [self.model isEqualToString:kAoKeCurtainModel]
        
        // v3.7需求，下面两个modelID 电机转向移动到隐藏页面(10次点击设备信息才出现隐藏的设置页)
        || [self.model isEqualToString:KWiFiEleMachineCurtainModelID]
        || [self.model isEqualToString:KWiFiEleMachineCurtainModelID2]
        || [self.model isEqualToString:KWiFiEleMachineCurtainModelID3]
        || [self.model isEqualToString:@"e168652579dd4a5786dad1ce3928ccdf"]
        
        // 4.0 巧克力点击仅支持转向
        || [self.model isEqualToString:KZigebeeCurtainBatteryMotorModelID]) {// V3.7 新款奥科窗帘电机
        
        return YES;
    }
    return NO;
}

// 同时支持支持限位及转向的百分比窗帘
- (BOOL)isCurtainSupportPositionSettingAndOverTurn {

    if ([self.model isEqualToString:KZigebeeCurtainMotorModelID]
        || [self.model isEqualToString:KWiFiEleMachineRollerModelID]
        || [self.model isEqualToString:KWiFiRollerCurtainModelID]
        || [self.model isEqualToString:kRuixiangBlindsModel]
        || [self.model isEqualToString:@"c3671040423c4cc18b9360b5ee50e633"]
        
        // V3.7 新款奥科窗帘电机
        || [self.model isEqualToString:@"6d9f186f274f4c6194c1d9a325c8b1e4"]
        || [self.model isEqualToString:@"2a103244da0b406fa51410c692f79ead"]
        ) {
        

        
        return YES;
    }
    return NO;
}

// 窗帘是否支持百分比控制
- (BOOL)isCurtainSupportPercentageControl
{
    // 多功能控制盒（窗帘模式），RF主机（窗帘类型），这两种不支持百分比控制
    // 其他都是单个的窗帘电机，都支持百分比控制
    
    // 确定支持百分比的model
    
//    NSArray *array = {
//
//        @[KZigebeeCurtainMotorModelID,
//          KZigebeeCurtainBatteryMotorModelID,
//          KWiFiEleMachineRollerModelID,
//          KWiFiRollerCurtainModelID,
//          kAoKeCurtainModel,
//          kRuixiangBlindsModel,
//          @"c3671040423c4cc18b9360b5ee50e633",
//          @"4b8344b2291d4fb8a335c80887a31974",
//          @"ab14dd765de54f199d40221d3d4a1dcd",
//          @"a9241f3104c1422b82c7ad2cbd5d6fe0",
//          @"e04b8c08ed8942ec9949a2b67a0da1ef",
//          ]
//    };
//
//    if ([array containsObject:self.model]) {
//        return YES;
//    }
    
    // 模式表没有数据，则认为不支持百分比控制
    NSArray *modelArr = [HMFrequentlyModeModel allFrequentlyModeForDevice:self];
    if (!modelArr.count){
        return NO;
    }
    
    if (AlloneProModelId(self.model)) {
        return NO;
    }
    
    HMDeviceDesc *desc = [HMDeviceDesc objectWithModel:self.model];
  
    if (!desc
        || !desc.endpointSet
        || [desc.endpointSet isEqualToString:@""]
        || stringContainString(desc.endpointSet.lowercaseString, @"null")
        || stringContainString(desc.endpointSet.lowercaseString, @",8@")) { // 窗帘控制盒，入网类型为 8（设备描述表信息）
        return NO;
    }

    return YES;
}

+ (instancetype)objectWithDeviceId:(NSString *)deviceId uid:(NSString *)uid
{
    
    // 因为现在支持多主机，所以查询设备不再判断uid信息，只根据 deviceId 来查
    NSString *sql = [NSString stringWithFormat:@"select * from device where deviceId = '%@' and delFlag = 0",deviceId];

    FMResultSet * rs = [self executeQuery:sql];
    
    if([rs next])
    {
        HMDevice *object = [HMDevice object:rs];
        
        [rs close];
        
        return object;
    }
    [rs close];
    //如果没找到，再找一次组
    HMDevice * groupDevice = [HMGroup deviceFromGroupId:deviceId];
    if(groupDevice) {
        return groupDevice;
    }
    
    return nil;
}


+ (instancetype)objectWithIrDeviceId:(NSString *)irDeviceId {

    NSString *sql = [NSString stringWithFormat:@"select * from device where irDeviceId = '%@' and delFlag = 0",irDeviceId];

    FMResultSet * rs = [self executeQuery:sql];

    if([rs next])
    {
        HMDevice *object = [HMDevice object:rs];

        [rs close];

        return object;
    }
    [rs close];

    return nil;

}

+ (instancetype)wifiObjectWithUid:(NSString *)uid {
    
    if (uid) {
        
        NSString *sql = [NSString stringWithFormat:@"select * from device where uid = '%@' and delFlag = 0",uid];
        
        FMResultSet * rs = [self executeQuery:sql];
        
        if([rs next])
        {
            HMDevice *object = [HMDevice object:rs];
            
            [rs close];
            
            DLog(@"找到设备：%@",object);
            return object;
        }
        [rs close];
    }
    
    DLog(@"未查找到当前设备 uid：%@",uid);
    
    return nil;
}

+ (instancetype)objectWithUid:(NSString *)uid {
    NSString *sql = [NSString stringWithFormat:@"select * from device where uid = '%@' and delFlag = 0 order by updateTime desc",uid];
    
    FMResultSet * rs = [self executeQuery:sql];
    
    if([rs next])
    {
        HMDevice *object = [HMDevice object:rs];
        
        [rs close];
        
        return object;
    }
    [rs close];
    
    return nil;
}
- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    return dic;
}

+ (instancetype)objectWithUid:(NSString *)uid deviceType:(KDeviceType)deviceType
{
    NSArray *array = [self objectsWithUid:uid deviceType:deviceType];
    return array.lastObject;
}

+ (NSArray *)objectsWithUid:(NSString *)uid deviceType:(KDeviceType)deviceType
{
    NSMutableArray *array = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from device where uid = '%@' and deviceType = %d and delFlag = 0",uid,deviceType];
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMDevice *device = [HMDevice object:rs];
        [array addObject:device];
    });
    return array.count ? array : nil;
}

+ (NSArray *)deviceArrWithUid:(NSString *)uid
{
    NSString *sql = [NSString stringWithFormat:@"select * from device where uid = '%@' and delFlag = 0",uid];
    __block NSMutableArray *deviceArray;
    queryDatabase(sql, ^(FMResultSet *rs) {
        if (!deviceArray) {
            deviceArray = [[NSMutableArray alloc] init];
        }
        [deviceArray addObject:[HMDevice object:rs]];
    });
    return deviceArray;
}

+ (NSArray *)deviceWithSameExtAddress:(HMDevice *)device
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    
    NSString *sql = [NSString stringWithFormat:@"select * from device where uid = \"%@\" and extAddr = \"%@\" and endpoint != %d and delFlag = 0",device.uid,device.extAddr,device.endpoint];
    
    FMResultSet * rs = [self executeQuery:sql];
    
    while([rs next])
    {
        HMDevice *object = [HMDevice object:rs];
        
        [array addObject:object];
        
    }
    [rs close];
    
    return array;
}

+ (NSArray *)deviceArrWithSameAppDeviceId:(int)appDeviceId
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSString *sql = [NSString stringWithFormat:@"select * from device where uid in %@ and appDeviceId = %d and delFlag = 0",[HMUserGatewayBind uidStatement],appDeviceId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMDevice *device = [HMDevice object:rs];
        [array addObject:device];
    });
    return array;
}


+ (NSArray *)wifiDeviceArray
{
    NSMutableArray *arr;
    NSString *sql = [NSString stringWithFormat:@"select * from device where uid in %@ and delFlag = 0 and (model like '%%%@%%' or model like '%%%@%%' or "
                     "model like '%%%@%%' or model like '%%%@%%' or model like '%%%@%%' or model like '%%%@%%' or deviceType = 29 or deviceType = 52 or model in (%@)) order by rowid asc",[HMUserGatewayBind uidStatement],kCocoModel,kYSCameraModel,kS20cModel,kCLHModel,kS20Model,kHudingStripModel,wifiDeviceModelIDs()];

    FMResultSet *rs = [self executeQuery:sql];
    while ([rs next]) {
        HMDevice *obj = [HMDevice object:rs];
        if (!arr) {
            arr = [[NSMutableArray alloc] initWithCapacity:1];
        }
        [arr addObject:obj];
    }
    [rs close];
    
    return arr;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@ deviceId:%@ type:%d extAddr:%@ port:%d",floorAndRoom(self),self.deviceName,self.deviceId,self.deviceType,self.extAddr,self.endpoint];
}

+(BOOL)updateWithDeviceName:(NSString *)name sql:(NSString *)sql
{
    sqlite3_stmt *statement;
    sqlite3*sqliteHandle = [[HMDatabaseManager shareDatabase]sqliteHandle];
    
    if (sqlite3_prepare_v2(sqliteHandle, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK)
    {
        DLog(@"Error: failed to insert:url");
        return NO;
    }
    
    sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);

    
    if (sqlite3_step(statement) != SQLITE_DONE) {
        DLog(@"Error: failed to insert into the database with message.");
        return NO;
    }
    sqlite3_finalize(statement);

    return YES;
}

+(BOOL)updateDeviceName:(NSString *)name deviceId:(NSString *)deviceId
{
    NSString *updateSql = [NSString stringWithFormat:@"update device set deviceName = ? where deviceId = '%@'",deviceId];
    return [[self class]updateWithDeviceName:name sql:updateSql];
}

+(BOOL)updateDeviceName:(NSString *)name extAddr:(NSString *)extAddr
{
    NSString *updateSql = [NSString stringWithFormat:@"update device set deviceName = ? where extAddr = '%@'",extAddr];
    return [[self class]updateWithDeviceName:name sql:updateSql];
}

+(BOOL)updateRoomId:(NSString *)roomId extAddr:(NSString *)extAddr
{
    NSString *updateSql = [NSString stringWithFormat:@"update device set roomId = '%@' where extAddr = '%@'", roomId, extAddr];
    BOOL result = [self executeUpdate:updateSql];
    return result;
}

+(KDeviceType)deviceTypeWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [NSString stringWithFormat:@"select deviceType from device where deviceId = '%@' and delFlag = 0",deviceId];
    FMResultSet *resultSet = [self executeQuery:sql];
    KDeviceType type = KDeviceTypeNotUsed;
    if ([resultSet next]) {
        type = [[resultSet stringForColumn:@"deviceType"] intValue];
    }
    [resultSet close];
    return type;
}

+(NSString *)deviceNameWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [NSString stringWithFormat:@"select deviceName from device where deviceId = '%@' and delFlag = 0",deviceId];
    FMResultSet *resultSet = [self executeQuery:sql];
    NSString * name = nil;
    if ([resultSet next]) {
        name = [resultSet stringForColumn:@"deviceName"];
    }
    [resultSet close];
    return name;
}


+ (NSString *)deviceNameWithExtAddr:(NSString *)extAddr differentDeviceId:(NSString *)deviceId
{
    NSString *sql = [NSString stringWithFormat:@"select deviceName from device where deviceId != '%@' and extAddr = '%@' and delFlag = 0 and uid in %@",deviceId,extAddr,[HMUserGatewayBind uidStatement]];
    __block NSString *name = @"";
    queryDatabase(sql, ^(FMResultSet *rs) {
        name = [rs stringForColumn:@"deviceName"];
    });
    return name;
}

+ (NSString *)versionWithDeviceId:(NSString *)deviceId {
    NSString *sql = [NSString stringWithFormat:@"select version from device where deviceId = '%@' and delFlag = 0",deviceId];
    FMResultSet *resultSet = [self executeQuery:sql];
    NSString * version = @"";
    if ([resultSet next]) {
        version = [resultSet stringForColumn:@"version"];
    }
    [resultSet close];
    return version;
}

-(NSUInteger)weightedValue
{
    NSUInteger weightedValue = [orderOfDeviceType() indexOfObject:@(self.deviceType)];
    return weightedValue;
}

+ (NSArray *)commonUseDevices
{
    NSString *sql = [NSString stringWithFormat:@"select * from device where uid in %@ and deviceType not in (%@) and delFlag = 0 and deviceId in (select deviceId from deviceCommon where commonFlag = 1)",[HMUserGatewayBind uidStatement],kFilterCommonDeviceType];
    NSMutableArray *array = [NSMutableArray array];
    queryDatabase(sql, ^(FMResultSet *rs) {
        
        HMDevice *device = [HMDevice object:rs];
        
        if (device.deviceType == KDeviceTypeOldDistBox
            && (device.endpoint != kOldDistBoxMainPoint)) {
        }else {
            [array addObject:device];
        }
    });
    return array;
}

+ (NSArray *)devicesToChooseForCommonUse
{
    return [self devicesToChooseForCommonUseWithRoomId:nil];
}

+ (NSArray *)devicesToChooseForCommonUseWithRoomId:(NSString *)roomId
{
    NSString *sql = nil;
    
    // 所有房间   roomId = nil
    if (!roomId) {
        sql = [NSString stringWithFormat:@"select * from device where uid in %@ and deviceType not in (%@) and delFlag = 0",[HMUserGatewayBind uidStatement],kFilterCommonDeviceType];
        
        // 具体房间  roomId != nil
    }else {
        sql = [NSString stringWithFormat:@"select * from device where uid in %@ and deviceType not in (%@) and delFlag = 0 and roomId = '%@'",[HMUserGatewayBind uidStatement],kFilterCommonDeviceType,roomId];
    }
    NSMutableArray *array = [NSMutableArray array];
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMDevice *device = [HMDevice object:rs];
        if (device.deviceType == KDeviceTypeOldDistBox
            && (device.endpoint != kOldDistBoxMainPoint)) {
        }else {
           [array addObject:device];
        }
    });
    return array;
}



+ (BOOL)isComonUseDeviceWithDeviceId:(NSString *)deviceId
{
   __block BOOL isCommon = NO;
    NSString *sql = [NSString stringWithFormat:@"select * from deviceCommon where deviceId = '%@' and commonFlag = 1",deviceId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        isCommon = YES;
    });
    return isCommon;
}

+(NSString *)roomIdByUid:(NSString *)uid deviceId:(NSString *)deviceId
{
    NSString *sql = [NSString stringWithFormat:@"select roomId from device where uid = '%@' and deviceId = '%@' and delFlag = 0",uid,deviceId];
    __block NSString *roomIdStr;
    queryDatabase(sql, ^(FMResultSet *rs) {
        roomIdStr = [rs stringForColumn:@"roomId"];
    });
    return roomIdStr;
}

-(void)setCommonFlag:(int)commonFlag
{
    NSString *sql = (commonFlag == 1)
    ?[NSString stringWithFormat:@"insert into deviceCommon (deviceId,commonFlag) values('%@',1)",self.deviceId]
    :[NSString stringWithFormat:@"delete from deviceCommon where deviceId = '%@'",self.deviceId];
    [self executeUpdate:sql];
}

-(void)setEnergySaveFlag:(int)energySaveFlag
{
    NSString *sql = (energySaveFlag == 1)
    ?[NSString stringWithFormat:@"insert into deviceEnergySave (deviceId,energySaveFlag) values('%@',1)",self.deviceId]
    :[NSString stringWithFormat:@"delete from deviceEnergySave where deviceId = '%@'",self.deviceId];
    [self executeUpdate:sql];
}

+ (NSArray *)devicesNeedToEnergyTipV2 {
    // 某个设备的节能提醒设置需要推送才提醒
    NSString *sql = [NSString stringWithFormat:@"select * from device d where d.uid in %@ and d.deviceType in (%@) and d.delFlag = 0 and d.deviceId in (select distinct deviceId from deviceStatus where value1 = 0) and d.deviceId in (select taskId from messagePush where familyId = '%@' and delFlag = 0 and isPush = 0 and type = 12)",[HMUserGatewayBind uidStatement],kEnergyDeviceType,userAccout().familyId];
    
     NSMutableArray *array = [NSMutableArray array];
    
    queryDatabase(sql, ^(FMResultSet *rs) {
 
        HMDevice *device = [HMDevice object:rs];
        // 创维rgb灯的调光灯那路过滤掉
        if ([device.model isEqualToString:kChuangWeiRGBWModel] && device.deviceType == KDeviceTypeDimmerLight) {
            
            // 如果rgb那路为关，则加入,并且以RGB那路的身份加入 （即始终只算一个设备）
            if (![HMDeviceStatus rgbwRGBEndPointIsOnWithExtAddr:device]) {
                HMDevice *rgbEndPointDevice = [self chuangweiRgbEndPointDeviceWithExtAddr:device.extAddr];
                if (rgbEndPointDevice) {
                    [array addObject:rgbEndPointDevice];
                }
            }
            
        }else {
            [array addObject:device];
        }
    });
    
    NSArray *onLightDevicesWithNotPushData = [self onLightDevicesNotInMessagePush];
    if ([onLightDevicesWithNotPushData count]) {
        [array addObjectsFromArray:onLightDevicesWithNotPushData];
    }
    return array;
}

+ (NSArray *)onLightDevicesNotInMessagePush
{
    NSString *sql = [NSString stringWithFormat:@"select * from device where uid in %@ and deviceType in (%@) and delFlag = 0 and deviceId in (select distinct deviceId from deviceStatus where value1 = 0) and deviceId not in (select taskId from messagePush where familyId = '%@' and delFlag = 0 and type = 12)",[HMUserGatewayBind uidStatement],kEnergyDeviceType,userAccout().familyId];
    NSMutableArray *array = [NSMutableArray array];
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMDevice *device = [HMDevice object:rs];
        // 创维rgb灯的调光灯那路过滤掉
        if ([device.model isEqualToString:kChuangWeiRGBWModel] && device.deviceType == KDeviceTypeDimmerLight) {
            
            // 如果rgb那路为关，则加入,并且以RGB那路的身份加入 （即始终只算一个设备）
            if (![HMDeviceStatus rgbwRGBEndPointIsOnWithExtAddr:device]) {
                HMDevice *rgbEndPointDevice = [self chuangweiRgbEndPointDeviceWithExtAddr:device.extAddr];
                if (rgbEndPointDevice) {
                    [array addObject:rgbEndPointDevice];
                }
            }
            
        }else {
            [array addObject:device];
        }
    });
    return array;
}


+ (NSArray *)lightDevices
{
    NSString *sql = [NSString stringWithFormat:@"select * from device where uid in %@ and deviceType in (%@) and delFlag = 0 order by deviceType desc, createTime desc",[HMUserGatewayBind uidStatement],kEnergyDeviceType];
    NSMutableArray *array = [NSMutableArray array];
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMDevice *device = [HMDevice object:rs];
        // 创维rgb灯的调光灯那路过滤掉
        if ([device.model isEqualToString:kChuangWeiRGBWModel] && device.deviceType == KDeviceTypeDimmerLight) {
            
            
        }else {
            [array addObject:device];
        }
    });
    return array;
}

+ (HMDevice *)chuangweiWDeviceWithExtAddr:(NSString *)extAddr
{
    NSString *sql = [NSString stringWithFormat:@"select * from device where extAddr = '%@' and model = '%@' and uid in %@ and deviceType = 0",extAddr,kChuangWeiRGBWModel,[HMUserGatewayBind uidStatement]];
   __block HMDevice *device = nil;
    queryDatabase(sql, ^(FMResultSet *rs) {
        device = [HMDevice object:rs];
    });
    return device;
}

+ (HMDevice *)chuangweiRgbEndPointDeviceWithExtAddr:(NSString *)extAddr
{
    NSString *sql = [NSString stringWithFormat:@"select * from device where extAddr = '%@' and model = '%@' and uid in %@ and deviceType = 19",extAddr,kChuangWeiRGBWModel,[HMUserGatewayBind uidStatement]];

    __block HMDevice *device = nil;
    queryDatabase(sql, ^(FMResultSet *rs) {
        device = [HMDevice object:rs];
    });
    return device;
}

+ (int)lightDeviceCount
{
    NSString *sql = [NSString stringWithFormat:@"select count() as count from device where uid in %@ and deviceType in (%@) and (model != '%@' or (model = '%@' and deviceType != 0)) and delFlag = 0",[HMUserGatewayBind uidStatement],kEnergyDeviceType,kChuangWeiRGBWModel,kChuangWeiRGBWModel];
    __block int lightCount = 0;
    queryDatabase(sql, ^(FMResultSet *rs) {
        lightCount = [rs intForColumn:@"count"];
    });
    return lightCount;
}

+ (int)zigbeeLightDeviceCount {

    NSString *sql = [NSString stringWithFormat:@"select count() as count from device where uid in %@ and deviceType in (%@) and delFlag = 0",[HMUserGatewayBind uidStatement],kEnergyDeviceType];
    __block int lightCount = 0;
    queryDatabase(sql, ^(FMResultSet *rs) {
        lightCount = [rs intForColumn:@"count"];
    });
    return lightCount;

}

+ (BOOL)isNeedEnergySaveTip:(NSString *)deviceId
{
    __block BOOL isNeedTip = YES;
    NSString *sql = [NSString stringWithFormat:@"select * from deviceEnergySave where deviceId = '%@' and energySaveFlag = 1",deviceId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        isNeedTip = NO;
    });
    return isNeedTip;
}

+ (NSArray *)allTheTVCanBeBoundArrayWithUid:(NSString *)uid
{
    __block NSMutableArray *devicesArray;
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:Allone2ModelIDArray()];
    [array addObjectsFromArray:AlloneProModelIDArray()];
    NSString *modelIds = stringWithObjectArray(array);
    
    NSString *sql = [NSString stringWithFormat:@"select * from device where deviceType = %d and model in (%@) and delFlag = 0 and uid = '%@'",KDeviceTypeTV, modelIds, uid];
    queryDatabase(sql, ^(FMResultSet *rs) {
        if (!devicesArray) {
            devicesArray = [[NSMutableArray alloc] init];
        }
        [devicesArray addObject:[HMDevice object:rs]];
    });
    return devicesArray;
}

+ (NSInteger)numberOfDeviceType:(KDeviceType)deviceType model:(NSString *)model
{
    NSString *sql = [NSString stringWithFormat:@"select count() as count from device where deviceType = %d and model = '%@' and uid in %@ and delFlag = 0",deviceType, model, [HMUserGatewayBind uidStatement]];
    __block NSInteger count = 0;
    queryDatabase(sql, ^(FMResultSet *rs) {
        count = [rs intForColumn:@"count"];
    });
    return count;
}

+ (HMDevice *)mainDistBoxWithExtAddr:(NSString *)extAddr
{
    NSString *sql = [NSString stringWithFormat:@"select * from device where extAddr = '%@' and endPoint = 1",extAddr];
    __block HMDevice *device = nil;
    queryDatabase(sql, ^(FMResultSet *rs) {
        device = [HMDevice object:rs];
    });
    return device;
}

+ (BOOL )thereIsDeviceInDeafaultRoom{
    __block BOOL inDefaultRoom = NO;

// TODO: 需要测试

    // 家庭中是否有设备在默认房间
    NSString *sql1 = [NSString stringWithFormat:@"select count() as count from device where uid in %@ and delFlag = 0 and length(roomId) < 2",[HMUserGatewayBind uidStatement]];
    queryDatabase(sql1, ^(FMResultSet *rs) {
        if ([rs intForColumn:@"count"] > 0) {
            inDefaultRoom = YES;
        }
    });
    
    if (inDefaultRoom) {
        return inDefaultRoom;
    }else{
        // 如果默认房间没设备，家庭中是否有设备
        NSString *sql = [NSString stringWithFormat:@"select count() as count from device where uid in %@ and delFlag = 0",[HMUserGatewayBind uidStatement]];
        queryDatabase(sql, ^(FMResultSet *rs) {
            if ([rs intForColumn:@"count"] == 0) {
                
                // 如果也没有设备，家庭中是否有房间
                //NSString *sql = [NSString stringWithFormat:@"select count() as count from room where uid = '%@' and delFlag = 0",UID()];
                NSString *sql = [NSString stringWithFormat:@"select count() as count from room where familyId = '%@' and delFlag = 0",userAccout().familyId];
                queryDatabase(sql, ^(FMResultSet *rs) {
                    if ([rs intForColumn:@"count"] == 0) {
                        inDefaultRoom = YES;
                        
                    }
                });
            }
            
        });
        
        return inDefaultRoom;

    }
}

#pragma mark -小方
/**
 *  删除小方所有虚拟设备存储在数据库中的数据
 */
+ (void)deleteAllRelatedObjectDBDataWithUid:(NSString *)uid
{
    DLog(@"deleteAllRelatedObjectDBDataWithUid:%@",uid);
    NSArray *deviceArr = [HMDevice deviceArrWithUid:uid];
    [deviceArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self deleteTheRelatedObjectDBData:obj];
    }];
}

/**
 *  删除小方的一个虚拟设备存储在数据库中的数据
 */
+ (void)deleteTheRelatedObjectDBData:(HMDevice *)device
{
    DLog(@"deleteTheRelatedObjectDBData:%@",device);
    //删除定时倒计时
    if (device.deviceType == KDeviceTypeAirconditioner || device.deviceType == KDeviceTypeFan || device.deviceType == KDeviceTypeCustomerInfrared || device.deviceType == KDeviceTypeSound || device.deviceType == KDeviceTypeRemoteLight) {
        
        for (NSString *tableName in @[@"timing",@"countdown"]) {
            NSString *sql = [NSString stringWithFormat:@"delete from %@ where deviceId = '%@'",tableName, device.deviceId];
            updateInsertDatabase(sql);
        }
    }
    
    NSString *sql = [NSString stringWithFormat:@"delete from device where deviceId = '%@' and uid = '%@'",device.deviceId,device.uid];
    [self executeUpdate:sql];
}

/**
 *  获取国家id，用于小方虚拟遥控器,获取码库需要用到countryId
 *
 *  @param company 小方下面创建的红外设备数据格式为：spType,spId,areaId,brandId,countryId
 */
- (NSString *)getCurrentDeviceCountryId
{
    NSArray *companyArray = [self.company componentsSeparatedByString:@","];
    NSString *countryId = nil;
    if (companyArray.count > 4) {
        countryId = [companyArray objectAtIndex:4];
    }
    return countryId;
}

+ (NSString *)getLightSensorDeviceIdWithExtAddr:(NSString *)extAddr {

    NSString *sql = [NSString stringWithFormat:@"select deviceId from device where extAddr = '%@' and deviceType = 18 and delFlag = 0", extAddr];

    __block NSString *deviceId;
    queryDatabase(sql, ^(FMResultSet *rs) {
        deviceId = [rs stringForColumn:@"deviceId"];
    });
    return deviceId;
}


+ (NSString *)getHumanSensorDeviceIdWithExtAddr:(NSString *)extAddr {
    NSString *sql = [NSString stringWithFormat:@"select deviceId from device where extAddr = '%@' and deviceType = 26 and delFlag = 0", extAddr];

    __block NSString *deviceId;
    queryDatabase(sql, ^(FMResultSet *rs) {
        deviceId = [rs stringForColumn:@"deviceId"];
    });
    return deviceId;

}



- (int)distBoxSortNum {
    if (self.deviceType == KDeviceTypeOldDistBox) {
      return [HMDeviceSettingModel sortNumOfDeviceId:self.deviceId];
    }
    return 10000;
}

- (BOOL)isForbidEnergySavePush {
    BOOL isForbid = NO;
    HMMessagePush * model = [HMMessagePush selectModelWithTaskId:self.deviceId AndType:12];
    if (model && model.isPush) {
        isForbid = YES;
    }
    return isForbid;
}



+ (NSArray *)leakageProtectSwitchsOfExtAddr:(NSString *)extAddr {
    NSString *sql = [NSString stringWithFormat:@"select * from device where extAddr = '%@' and endPoint != 0 and subDeviceType = 1 and delFlag = 0 and uid in %@ order by endPoint asc",extAddr,[HMUserGatewayBind uidStatement]];
    NSMutableArray *leakageSwitchs = [NSMutableArray array];
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMDevice *device = [HMDevice object:rs];
        [leakageSwitchs addObject:device];
    });
    return leakageSwitchs;
}

+ (HMDevice *)lockWithBlueMacId:(NSString *)bleMac
{
    
    // 因为现在支持多主机，所以查询设备不再判断uid信息，只根据 deviceId 来查
    NSString *sql = [NSString stringWithFormat:@"select * from device where blueExtAddr = '%@' and delFlag = 0",bleMac];
    
    FMResultSet * rs = [self executeQuery:sql];
    
    if([rs next])
    {
        HMDevice *object = [HMDevice object:rs];
        
        [rs close];
        
        return object;
    }
    [rs close];
    
    return nil;
}

+ (HMDevice *)lockWithExtAddr:(NSString *)extAddr {
    NSString *sql = [NSString stringWithFormat:@"select * from device where extAddr = '%@' and delFlag = 0",extAddr];
    
    FMResultSet * rs = [self executeQuery:sql];
    
    if([rs next])
    {
        HMDevice *object = [HMDevice object:rs];
        
        [rs close];
        
        return object;
    }
    [rs close];
    
    return nil;
}

//家庭中的mixpad
+ (NSArray <HMDevice *>*)allMixPadInFamily {
    NSString *sql = [NSString stringWithFormat:@"select * from device where uid in %@ and delFlag = 0 and deviceType = %d order by createTime asc",[HMUserGatewayBind uidStatement], KDeviceTypeMixPad];
    
    __block NSMutableArray *devicesArr = [NSMutableArray array];
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMDevice *device = [HMDevice object:rs];
        [devicesArr addObject:device];
    });

    return devicesArr;
}

-(BOOL)isEqual:(HMDevice *)object
{
    if ([object isKindOfClass:[self class]]) {
        return [self.deviceId isEqualToString:object.deviceId];
    }
    return [super isEqual:object];
}

-(NSUInteger)hash
{
    return self.deviceId.hash;
}


- (BOOL)isC1Lock {

    HMDeviceDesc * desc = [HMDeviceDesc objectWithModel:self.model];
    KDeviceType deviceType = [HMDeviceDesc descTableDeviceTypeWithModel:self.model];
    if (deviceType == KDeviceTypeOrviboLock && desc.deviceFlag == HMLockDeviceFlagC1) {
        return YES;
    }else {
        return NO;
    }
}

- (BOOL)online {
    return statusOfDevice(self).online;
}

/// 家庭下面智慧光源的数据
+ (int)countForDownLight {
    NSString * sql = [NSString stringWithFormat:@"select count() as count from device inner join deviceDesc on device.model = deviceDesc.model where device.deviceType = 38 and device.delFlag = 0 and deviceDesc.deviceFlag = 2 and device.uid in %@",[HMUserGatewayBind uidStatement]];
    __block int count = 0;
    queryDatabase(sql, ^(FMResultSet *rs) {
        count = [rs intForColumn:@"count"];
    });
    return count;
}
@end





