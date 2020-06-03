//
//  HMLanCommunicationKeyModel.m
//  HomeMateSDK
//
//  Created by 2049lzc on 2018/8/28.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMLanCommunicationKeyModel.h"
#import "NSData+AES.h"
#import "HMBaseModel+Extension.h"
#import "HMDatabaseManager.h"


@implementation HMLanCommunicationKeyModel

@synthesize  lanCommunicationKey = _lanCommunicationKey;


+(NSString *)tableName
{
    return @"lanCommunicationKey";
}

+ (NSArray*)columns
{
    return @[
             column("familyId", "text"),
             column("lanCommunicationKey", "text"),
             ];
}


+ (NSString*)constrains
{
    return @"UNIQUE (familyId) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

+ (NSString *)lanCommunicationKeyOfFamilyId:(NSString *)familyId
{
    __block HMLanCommunicationKeyModel *lanCommunicationKeyModel = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from lanCommunicationKey where familyId = '%@'",familyId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        lanCommunicationKeyModel = [HMLanCommunicationKeyModel object:rs];
    });
    return lanCommunicationKeyModel.lanCommunicationKey;
}

-(void)setLanCommunicationKey:(NSString *)lanCommunicationKey {
//    NSData *orignalData = [lanCommunicationKey dataUsingEncoding:NSUTF8StringEncoding];
//    NSData * encryptedData = [orignalData hm_AES128EncryptWithKey:@"Zhijia365 2049abc" iv:nil];
//    NSString * encryptedKey = [[NSString alloc] initWithData:encryptedData encoding:NSUTF8StringEncoding];
//    DLog(@"加密前的局域网密钥： %@ 加密后： %@",lanCommunicationKey,encryptedKey);
    _lanCommunicationKey = lanCommunicationKey;
}

- (NSString *)lanCommunicationKey {
//    NSData *encryptedData = [_lanCommunicationKey dataUsingEncoding:NSUTF8StringEncoding];
//    NSData * decryptData = [encryptedData hm_AES128DecryptWithKey:@"Zhijia365 2049abc" iv:nil];
//    NSString *originalKey = [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
//    DLog(@"解密前局域网通信密钥： %@ 解密后： %@",_lanCommunicationKey,originalKey);
    return _lanCommunicationKey;
}

@end
