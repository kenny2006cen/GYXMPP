//
//  DeviceDesc.m
//  HomeMate
//
//  Created by liuzhicai on 16/1/13.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMDeviceDesc.h"
#import "HMConstant.h"
#import "NSObject+MJKeyValue.h"
#import "HMStorage.h"

@implementation HMDeviceDesc
+(NSString *)tableName
{
    return @"deviceDesc";
}

+ (NSArray*)columns
{
    return @[
             column_constrains("deviceDescId","text","UNIQUE ON CONFLICT REPLACE"),
             column("source","text"),
             column("model","text"),
             column("productModel","text"),
             column("internalModel","text default ''"),
             column("endpointSet","text"),
             column("picUrl","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer"),
             column("valueAddedService","integer default 1"), // 默认有增值服务，1
             column("hostFlag","integer"),
             column("wifiFlag","integer"),
             column("deviceFlag","integer")
             ];
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

+ (NSArray<NSDictionary *>*)newColumns {
    return  @[column("internalModel","text default ''"),
              column("deviceFlag","integer default 0"),
              column("valueAddedService","integer default 1")]; // 默认有增值服务，1
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from deviceDesc where deviceDescId = '%@'",self.deviceDescId];
    BOOL result =  [self executeUpdate:sql];
    return result;
}


+ (instancetype)objectBySourceWithModel:(NSString *)model {
    
    NSString *descSource = [HMStorage shareInstance].descSource;
    NSString *sql = [NSString stringWithFormat:@"select * from deviceDesc where model = '%@' and delFlag = 0 and source = '%@'",model,descSource];
    FMResultSet *set = [self executeQuery:sql];
    HMDeviceDesc *descModel = nil;
    if ([set next]) {
        descModel = [[self class] mj_objectWithKeyValues:[set resultDictionary]];
    }
    [set close];
    
    // 如果HomeMate 查不到，则以zhijia365 去查
    if (!descModel) {
        sql = [NSString stringWithFormat:@"select * from deviceDesc where model = '%@' and delFlag = 0 and source = '%@'",model,[HMStorage shareInstance].appName];
        set = [self executeQuery:sql];
        if ([set next]) {
            descModel = [[self class] mj_objectWithKeyValues:[set resultDictionary]];
        }
        [set close];
        return descModel;
    }
    return descModel;
}



+ (instancetype)objectWithModel:(NSString *)model
{
    // 根据app的source能查到就返回，查不到就以source为空去查
    HMDeviceDesc *descModel = [self objectBySourceWithModel:model];
    if (descModel) {
        return descModel;
    }
    
    
    
    NSString *sql = [NSString stringWithFormat:@"select * from deviceDesc where model = '%@' and delFlag = 0 and source = '%@'",model,@""];
    FMResultSet *set = [self executeQuery:sql];
    if ([set next]) {
        descModel = [[self class] mj_objectWithKeyValues:[set resultDictionary]];
    }
    [set close];
    return descModel;
}

+ (instancetype)objectFromDictionary:(NSDictionary *)dict
{
    HMDeviceDesc *obj = [[self class] mj_objectWithKeyValues:dict];
    return obj;
}

// 根据 model 获取默认名称
+ (NSString *)defaultNameWithModel:(NSString *)model
{
    if (!model) {
        return nil;
    }
    HMDeviceDesc *desc = [HMDeviceDesc objectWithModel:model];
    if (!desc) {
        return nil;
    }
    HMDeviceLanguage *languageModel = [HMDeviceLanguage objectWithDataId:desc.deviceDescId];
    return languageModel.productName;;
}

+ (KDeviceType)descTableDeviceTypeWithModel:(NSString *)model {
    
    KDeviceType deviceType = -1000;
    if (isBlankString(model)) {
        return deviceType;
    }
    
    static NSMutableDictionary *modelTypeDict;
    if (!modelTypeDict) {
        modelTypeDict = [[NSMutableDictionary alloc]init];
    }else{
        NSNumber *deviceTypeNum = modelTypeDict[model];
        if (deviceTypeNum) {
            return [deviceTypeNum intValue];
        }
    }
    
    HMDeviceDesc *descModel = [self objectWithModel:model];
    if (descModel) {
        NSString *lastPartStr = [[descModel.endpointSet componentsSeparatedByString:@","] lastObject];
        NSString * deviceTypeStr = [[lastPartStr componentsSeparatedByString:@"@"] firstObject];
        if ([deviceTypeStr respondsToSelector:@selector(intValue)]) {
            deviceType = [deviceTypeStr intValue];
        }else {
            DLog(@"model=%@ 设备描述表查到的设备类型字符串为： %@",model,deviceTypeStr);
        }
    }
    modelTypeDict[model] = @(deviceType);
    
    return deviceType;
}

@end
