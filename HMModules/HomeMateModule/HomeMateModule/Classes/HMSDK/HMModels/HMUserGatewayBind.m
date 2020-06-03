//
//  VihomeUserGatewayBind.m
//  Vihome
//
//  Created by Air on 15/7/24.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMUserGatewayBind.h"

@implementation HMUserGatewayBind

+(NSString *)tableName
{
    return @"userGatewayBind";
}

+(NSString *)modelTable
{
    return @"(select userGatewayBind.*,gateway.model from (userGatewayBind left JOIN gateway on gateway.uid = userGatewayBind.uid) where userGatewayBind.delFlag = 0 and gateway.delFlag = 0)";
}

+(NSString *)modelStatement
{
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE familyId = '%@' and delFlag = 0",[self modelTable],userAccout().familyId];
}

+(NSString *)uidStatement
{
    return [NSString stringWithFormat:@"(SELECT DISTINCT uid FROM userGatewayBind WHERE familyId = '%@' and delFlag = 0)",userAccout().familyId];
}

+ (NSArray*)columns
{
    return @[
             column_constrains("bindId","text","UNIQUE ON CONFLICT REPLACE"),
             column("familyId","text"),
             column("uid","text"),
             column("userType","integer"),
             column("saveTime","text"),
             column("wifiFlag","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}


- (void)prepareStatement
{
    if (!self.createTime) {
        self.createTime = self.updateTime;
    }
    if (!self.saveTime) {
        self.saveTime = self.updateTime;
    }
    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from userGatewayBind where bindId = '%@' and uid = '%@'",self.bindId,self.uid];
    BOOL result = [self executeUpdate:sql];
    return result;
}

- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:self.bindId forKey:@"bindId"];
    [dic setObject:self.familyId forKey:@"familyId"];
    [dic setObject:self.uid forKey:@"uid"];
    [dic setObject:[NSNumber numberWithInt:self.userType] forKey:@"userType"];
    [dic setObject:self.updateTime forKey:@"updateTime"];
    [dic setObject:[NSNumber numberWithInt:self.delFlag] forKey:@"delFlag"];
    
    return dic;
}

-(NSString *)model
{
    if (!_model) {
        
        HMGateway *gateway = [HMGateway objectWithUid:self.uid];
        _model = gateway.model;
    }
    
    return _model;
}


-(BOOL)isVicenter{
    return isHostModel(self.model);
}

+(HMUserGatewayBind *)bindWithHmGateway:(HMGateway *)gateway
{
    return [self bindWithUid:gateway.uid model:gateway.model];
}
+(HMUserGatewayBind *)bindWithGateway:(Gateway *)gateway
{
    return [self bindWithUid:gateway.uid model:gateway.model];
}


+(HMUserGatewayBind *)bindWithUid:(NSString *)uid model:(NSString *)theModel
{
    DLog(@"bindWithUid:%@ model:%@",uid,theModel);
    
    NSMutableString *model = [NSMutableString stringWithString:kViHomeModel];// 默认model
    
    if (theModel) {
        
        [model setString:theModel];
        
    }else{
        NSString *sql = [NSString stringWithFormat:@"select model from gateway where uid = '%@'",uid];
        queryDatabase(sql, ^(FMResultSet *rs) {
            
            [model setString:[rs stringForColumn:@"model"]];
        });
    }
    
    HMUserGatewayBind *bind = [[HMUserGatewayBind alloc]init];
    bind.familyId = userAccout().familyId;
    bind.model = model;
    bind.uid = uid;
    
    return bind;
}

/**
 *  get 一个设备绑定信息
 *
 *  @param uid 指定设备的uid
 *
 *  @return
 */

+(HMUserGatewayBind *)bindWithUid:(NSString *)uid
{
    if (!isValidUID(uid)) {
        DLog(@"uid 有误:uid = %@",uid);
        return nil;
    }
    __block HMUserGatewayBind *bind = nil;
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where familyId = '%@' and uid = '%@'",[HMUserGatewayBind modelTable],userAccout().familyId,uid];
    queryDatabase(sql, ^(FMResultSet *rs) {
        bind = [HMUserGatewayBind object:rs];
    });
    return bind;
}

+ (BOOL)isHasBindUid:(NSString *)uid {
    
    if (!isValidUID(uid)) {
        DLog(@"uid 有误:uid = %@",uid);
        return NO;
    }
    __block BOOL hasUid = NO;
    NSString *sql = [NSString stringWithFormat:@"select * from userGatewayBind where familyId = '%@' and uid = '%@' and delFlag = 0",userAccout().familyId,uid];
    queryDatabase(sql, ^(FMResultSet *rs) {
        hasUid = YES;
    });
    return hasUid;
}



+(NSArray *)bindArrayWithFamilyId:(NSString *)familyId
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where familyId = '%@'",[HMUserGatewayBind modelTable],familyId];
    
    NSMutableArray *gatewayArray = [NSMutableArray array];
    queryDatabase(sql, ^(FMResultSet *rs) {
        [gatewayArray addObject:[HMUserGatewayBind object:rs]];
    });
    return gatewayArray;
}

+(BOOL)isWifiDeviceWithUid:(NSString *)uid
{
    NSString *model = [[self class]modelWithUid:uid];
    if (model) {
        return isWifiDeviceModel(model);
    }
    return NO;
}

+(BOOL)isHostWithUid:(NSString *)uid
{
    NSString *model = [[self class]modelWithUid:uid];
    if (model) {
        return isHostModel(model);
    }
    return NO;
}

+(NSString *)modelWithUid:(NSString *)uid
{
    NSString *model = nil;
    NSString *userGatewayBindSql = [NSString stringWithFormat:@"select model from %@ where familyId = '%@' and uid = '%@'",[HMUserGatewayBind modelTable],userAccout().familyId,uid];
    
    FMResultSet * userGatewayBindRs = executeQuery(userGatewayBindSql);
    
    if([userGatewayBindRs next]){
        
        model = [userGatewayBindRs stringForColumn:@"model"];
    }
    [userGatewayBindRs close];
    
    
    if (!model) {
        
        NSString *gatewaySql = [NSString stringWithFormat:@"select model from gateway where uid = '%@'",uid];
        
        FMResultSet * gatewayRs = executeQuery(gatewaySql);
        
        if([gatewayRs next]){
            
            model = [gatewayRs stringForColumn:@"model"];
        }
        [gatewayRs close];
        
    }
    
    return model;
}

-(NSNumber *)lastUpdateTime
{
    if (!self.uid) {
        return @(0);
    }
    
    NSString *uid = self.uid;
    NSString *lastTimeSecKey = lastUpdateTimeSecKey(uid);
    NSNumber *lastTimeSec = [HMUserDefaults objectForKey:lastTimeSecKey]; // 实际上如果存在应该是nsnumber类型
    
    if (lastTimeSec) {
        return lastTimeSec;
    }else{
        NSString *keyOfLastUpdateTimeKey = lastUpdateTimeKey(uid);
        
        NSString *lastUpdateTimeStr = [HMUserDefaults objectForKey:keyOfLastUpdateTimeKey];
        return @(secondWithString(lastUpdateTimeStr));
    }
}

-(NSDictionary *)widgetBindInfo
{
    
    NSDictionary *deviceBindInfo = @{@"uid":(self.uid ?:@"")
                                     ,@"lastUpdateTime":self.lastUpdateTime
                                     ,@"model":(self.model ?:@"")};
    return deviceBindInfo;
}

+(NSMutableArray *)deviceBindArrayWithCondition:(NSString *)condition
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@"
                            " where familyId = '%@'",[HMUserGatewayBind modelTable],userAccout().familyId];
    if (condition) {
        
        if (isHostModel(condition)) {
            [sql appendFormat:@" and (model like '%%%@%%' or model like '%%%@%%' or model in (%@))",condition,kHubModel,HostModelIDs()];
        }else{
            [sql appendFormat:@" and (model in (%@) or model like '%%%@%%' or model like '%%%@%%' or "
             "model like '%%%@%%' or model like '%%%@%%' or model like '%%%@%%' or model like '%%%@%%')"
             ,wifiDeviceModelIDs(),condition,kYSCameraModel,kS20cModel,kCLHModel,kS20Model,kHudingStripModel];
        }
        
    }
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    queryDatabase(sql, ^(FMResultSet *rs) {
        
        HMUserGatewayBind *bind = [HMUserGatewayBind object:rs];
        NSArray *uids = [array valueForKey:@"uid"];
        if ([uids containsObject:bind.uid]) {
            // 已经存在同一个uid的数据
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"uid = %@",bind.uid];
            HMUserGatewayBind *oldBind = [array filteredArrayUsingPredicate:pred].firstObject;
            if (isBlankString(oldBind.bindId)) {
                DLog(@"当前查出的uid绑定关系已存在，丢弃oldBind：%@",oldBind);
                [array removeObject:oldBind];
                [array addObject:bind];
            }else{
                DLog(@"当前查出的uid绑定关系已存在，丢弃newBind：%@",bind);
            }
        }else{
            [array addObject:bind];
        }
        
    });
    
    return array;
}
+(NSMutableArray *)allDeviceBindArray
{
    return [self deviceBindArrayWithCondition:nil];
}

+(NSMutableArray *)wifiDeviceBindArray
{
    return [self deviceBindArrayWithCondition:kCocoModel];
}
+(NSMutableArray *)zigbeeHostBindArray
{
    return [self deviceBindArrayWithCondition:kViHomeModel];
}
@end
