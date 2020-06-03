//
//  QrCodeModel.m
//  HomeMate
//
//  Created by liuzhicai on 16/1/13.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMQrCodeModel.h"
#import "HMConstant.h"
#import "NSObject+MJKeyValue.h"
@implementation HMQrCodeModel
+(NSString *)tableName
{
    return @"qrCode";
}

+ (NSArray*)columns
{
    return @[
             column_constrains("qrCodeId","text","UNIQUE ON CONFLICT REPLACE"),
             column("qrCodeNo","integer"),
             column("type","text"),
             column("picUrl","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from qrCode where qrCodeId = '%@'",self.qrCodeId];
    BOOL result =  [self executeUpdate:sql];
    return result;
}

+ (instancetype)objectwithQrCode:(NSString *)qrCodeNo
{
    NSString *sql = [NSString stringWithFormat:@"select * from qrCode where qrCodeNo = '%@' and delFlag = 0",qrCodeNo];
    HMQrCodeModel *qrCodeModel = nil;
    FMResultSet *set = [self executeQuery:sql];
    if ([set next]) {
        qrCodeModel = [[self class] mj_objectWithKeyValues:[set resultDictionary]];
    }
    return qrCodeModel;
}

+ (instancetype)objectFromDictionary:(NSDictionary *)dict
{
    HMQrCodeModel *obj = [[self class] mj_objectWithKeyValues:dict];
    return obj;
}

@end
