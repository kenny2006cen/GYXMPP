//
//  VihomeGateway.m
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMGateway.h"
#import "HomeMateSDK.h"


@implementation HMGateway
+(NSString *)tableName
{
    return @"gateway";
}

+ (NSArray*)columns
{
    return @[
             column("gatewayId","text"),
             column("familyId","text"),
             column("versionID","integer"),
             column("hardwareVersion","text"),
             column("softwareVersion","integer"),
             column("staticServerPort","integer"),
             column("staticServerIP","text"),
             column("domainServerPort","integer"),
             column("domainName","text"),
             column("localStaticIP","text"),
             column("localGateway","text"),
             column("localNetMask","text"),
             column("dhcpMode","integer"),
             column("model","text"),
             column("homeName","text"),
             column_constrains("uid","text","UNIQUE ON CONFLICT REPLACE"),
             column("mac","text default ''"),
             column("timeZone","text"),
             column("password","text"),
             column("dst","integer"),
             column("channel","integer"),
             column("panID","integer"),
             column("externalPanID","integer"),
             column("securityKey","text"),
             column("masterSlaveFlag","integer"),
             column("coordinatorVersion","text"),
             column("systemVersion","text"),
             column("netState","integer default 0"),
             column("country","text"),
             column("countryCode","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","Integer")
             ];
}

/**不改版本号的情况下，新增的一个column*/
+ (NSArray<NSDictionary *>*)newColumns {
    return @[column("mac","text default ''")
             ,column("netState","integer default 0")
             ,column("country","text")
             ,column("countryCode","text")];
}

- (void)prepareStatement
{
    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
    if (!self.timeZone) {
        self.timeZone = @"-1";
    }
    if (!self.coordinatorVersion) {
        self.coordinatorVersion = @"-1";
    }
    if (!self.systemVersion) {
        self.systemVersion = @"-1";
    }
    
    if (!self.createTime) {
        self.createTime = self.updateTime;
    }
    
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from gateway where gatewayId = '%@'",self.gatewayId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    return dic;
}

+(HMGateway *)objectWithUid:(NSString *)uid
{
    NSString *sql = [NSString stringWithFormat:@"select * from gateway where uid = '%@' and delFlag = 0 and familyId = '%@'",uid,userAccout().familyId];
    FMResultSet *rs = [self executeQuery:sql];
    HMGateway *gateway;
    if ([rs next]) {
        gateway = [HMGateway object:rs];
    }
    [rs close];
    
    // 网关表没有数据
    if (!gateway) {
        
        DLog(@"网关表没有数据:uid = %@",uid);
        
  //        NSParameterAssert(gateway);
    }
    return gateway;
}


+(HMGateway *)bluetoothLockGateWayWithbleMac:(NSString *)bleMac
{
    NSString *sql = [NSString stringWithFormat:@"select * from gateway where uid = '%@'and familyId = '%@' and delFlag = 0",bleMac,userAccout().familyId];
    FMResultSet *rs = [self executeQuery:sql];
    HMGateway *gateway;
    if ([rs next]) {
        gateway = [HMGateway object:rs];
    }
    [rs close];
    
    // 网关表没有数据
    if (!gateway) {
        DLog(@"网关表没有蓝牙门锁数据:bleMac = %@",bleMac);
    }
    return gateway;
}


+(NSArray *)gatewayArr
{
    NSMutableArray *gatewayArr;
    NSString *sql = [NSString stringWithFormat:@"select * from gateway where familyId = '%@'",userAccout().familyId];
    FMResultSet *rs = [self executeQuery:sql];
    while ([rs next]) {
        if (!gatewayArr) {
            gatewayArr = [[NSMutableArray alloc] initWithCapacity:1];
        }
        [gatewayArr addObject:[HMGateway object:rs]];
    }
    [rs close];
    return gatewayArr;
}


-(NSString *)model
{
    // 兼容 VIH004 是中性版本
    if ([_model isEqualToString:kNormalViHomeModel]) {
        return kNormalGatewayModelID;
    }
    return _model;
}

-(BOOL)isAlarmHub{
    
    // 非 WIFI设备
    if (!isWifiDeviceModel(self.model)) {
        
        KDeviceType type = HostType(self.model);
        
        return (KDeviceTypeAlarmHub == type);
    }
    return NO;
}

-(BOOL)isMiniHub{
    
    // 非 WIFI设备
    if (!isWifiDeviceModel(self.model)) {
        
        KDeviceType type = HostType(self.model);
        
        return (kDeviceTypeMiniHub == type);
    }
    return NO;
}

-(BOOL)isViCenterHub{
    
    // 非 WIFI设备
    if (!isWifiDeviceModel(self.model)) {
        
        KDeviceType type = HostType(self.model);
        
        return (kDeviceTypeViHCenter300 == type);
    }
    return NO;
}

@end
