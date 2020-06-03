//
//  VihomeRemoteBind.m
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMRemoteBind.h"
#import "HMDatabaseManager.h"

@interface HMRemoteBind ()
@property (nonatomic, strong)NSArray *           authList;   //与HMLinkageOutput HMSceneBind一致，定义协议属性 有权限的家庭成员，存储[HMFamilyUsers]对象
@end

@implementation HMRemoteBind

+(NSString *)tableName
{
    return @"remoteBind";
}

+ (NSArray*)columns
{
    return @[
             column("remoteBindId","text"),
             column("uid","text"),
             column("deviceId","text"),
             column("keyNo","integer"),
             column("keyAction","integer"),
             column("bindedDeviceId","text"),
             column("deviceIdType","integer"),
             column("bindOrder","text"),
             column("actionName","text"),
             column("value1","integer"),
             column("value2","integer"),
             column("value3","integer"),
             column("value4","integer"),
             column("delayTime","integer"),
             column("freq","integer"),
             column("pluseNum","integer"),
             column("pluseData","text"),
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
    return @"UNIQUE (remoteBindId) ON CONFLICT REPLACE";
}

- (void)prepareStatement
{
    if (!self.createTime) {
        self.createTime = self.updateTime;
    }
    if (!self.pluseData) {
        self.pluseData = @"";
    }
    if (!self.actionName) {
        self.actionName = @"";
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from remoteBind where remoteBindId = '%@'",self.remoteBindId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

-(KDeviceType)deviceType
{
    return self.bindDeviceType;
}

-(BOOL)isBindSecurity{
    
    if([self.bindOrder isEqualToString:@"outside security"]
       ||[self.bindOrder isEqualToString:@"inside security"]
       ||[self.bindOrder isEqualToString:@"cancel security"]
       ||[self.bindOrder isEqualToString:@"security card"]){
        return YES;
    }
    return NO;
}

-(BOOL)isBindService{
    
    if([self.bindOrder isEqualToString:@"song control"]
       ||[self.bindOrder isEqualToString:@"voice intercom"]
       ||[self.bindOrder isEqualToString:@"mixpad card"]){
        return YES;
    }
    return NO;
}

- (id)copyWithZone:(NSZone *)zone
{
    HMRemoteBind *object = [[HMRemoteBind alloc]init];
    
    object.remoteBindId = self.remoteBindId;
    object.uid = self.uid;
    object.keyNo = self.keyNo;
    object.deviceId = self.deviceId;
    object.bindOrder = self.bindOrder;
    object.value1 = self.value1;
    object.value2 = self.value2;
    object.value3 = self.value3;
    object.value4 = self.value4;
    object.keyAction = self.keyAction;
    object.bindedDeviceId = self.bindedDeviceId;
    object.delFlag = self.delFlag;
    object.deviceIdType = self.deviceIdType;
    object.pluseData = self.pluseData;
    object.freq = self.freq;
    object.pluseNum = self.pluseNum;
    object.themeId = self.themeId;
    object.actionName = self.actionName;
    return object;
}

- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:self.remoteBindId forKey:@"remoteBindId"];
    [dic setObject:self.uid forKey:@"uid"];
    [dic setObject:self.deviceId forKey:@"deviceId"];
    [dic setObject:[NSNumber numberWithInt:self.keyNo] forKey:@"keyNo"];
    [dic setObject:[NSNumber numberWithInt:self.keyAction] forKey:@"keyAction"];
    [dic setObject:self.bindedDeviceId forKey:@"bindedDeviceId"];
    [dic setObject:self.bindOrder forKey:@"order"];
    [dic setObject:[NSNumber numberWithInt:self.value1] forKey:@"value1"];
    [dic setObject:[NSNumber numberWithInt:self.value2] forKey:@"value2"];
    [dic setObject:[NSNumber numberWithInt:self.value3] forKey:@"value3"];
    [dic setObject:[NSNumber numberWithInt:self.value4] forKey:@"value4"];
    [dic setObject:self.updateTime forKey:@"updateTime"];
    [dic setObject:[NSNumber numberWithInt:self.delFlag] forKey:@"delFlag"];
    [dic setObject:[NSNumber numberWithInt:self.deviceIdType] forKey:@"deviceIdType"];
    
    if (self.themeId) {
        [dic setObject:self.themeId forKey:@"themeId"];
    }

    return dic;
}

+ (BOOL)deleteRemoteBindInfoWithSceneNo:(NSString *)sceneNo
{
    NSString *sql = [NSString stringWithFormat:@"delete from remoteBind where "
                     "bindOrder = 'scene control' and "
                     "bindedDeviceId = '%@'",sceneNo];

    BOOL result = [[HMDatabaseManager shareDatabase] executeUpdate:sql];
    return result;
}


@end
