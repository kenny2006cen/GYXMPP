//
//  HMMessageBusiness.m
//  HomeMateSDK
//
//  Created by liuzhicai on 2017/7/10.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMMessageBusiness.h"



@implementation HMMessageBusiness

+ (void)readNewestCommonMsgFromServerWithFamilyId:(NSString *)familyId messageType:(HMMessageType)messageType completion:(commonBlockWithObject)completion {
    // 获得本地数据库中当前家庭普通消息的最大序号
    int maxUserSequence = [HMMessageCommonModel getMaxSequenceNumWithFamilyId:familyId messageType:messageType];
    [self readCommonMsgBetweenMinSequence:maxUserSequence andMaxSequence:-1 familyId:familyId messageType:messageType completion:completion];
}


+ (void)readNewestSecurityMsgFromServerWithFamilyId:(NSString *)familyId completion:(commonBlockWithObject)completion {
    // 获得本地数据库中当前家庭安防消息的最大序号
    int maxUserSequence =  [HMMessageSecurityModel getMaxSequenceNumWithFamilyld:familyId];
    [self readSecurityMsgBetweenMinSequence:maxUserSequence andMaxSequence:-1 familyId:familyId completion:completion];
}

+ (void)readSecurityMsgBetweenMinSequence:(int)minSe andMaxSequence:(int)maxSe familyId:(NSString *)familyId completion:(commonBlockWithObject)completion {
    if (!isNetworkAvailable()) {
        if (completion) {
            completion(KReturnValueNetWorkProblem,nil);
        }
        return;
    }
    QueryUserMessage *cmd = [QueryUserMessage object];
    cmd.userId = userAccout().userId;
    cmd.familyId = familyId;
    cmd.tableName = @"messageSecurity";
    cmd.maxSequence = maxSe;
    cmd.minSequence = minSe;
    cmd.readCount = kHMMessageAPI_PerReadCount;
    cmd.sendToServer = YES;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            NSArray *statusRecordArr = returnDic[@"data"];
            for (NSDictionary *dic in statusRecordArr) {
                if (dic && [dic isKindOfClass:[NSDictionary class]]) {
                    HMMessageSecurityModel *model = [HMMessageSecurityModel objectFromDictionary:dic];
                    model.readType = 0;
                    [model insertObject];
                }
            }
            if (completion) {
                completion(returnValue,returnDic);
            }
        }
    });
    
}

+ (void)readNewStatusRecordWithSecurityDevice:(HMDevice *)device completion:(commonBlockWithObject)completion {
    if (![device isKindOfClass:[HMDevice class]]) {
        if (completion) {
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    if (!isNetworkAvailable()) {
        if (completion) {
            completion(KReturnValueNetWorkProblem,nil);
        }
        return;
    }
    int minSequence = (int)[HMStatusRecordModel getLastDeleteSequence:device recordType:StatusRecordTypeAll];
    QueryStatusRecordCmd *qsrCmd = [QueryStatusRecordCmd object];
    qsrCmd.deviceId = device.deviceId;
    qsrCmd.maxSequence = -1;
    qsrCmd.minSequence = minSequence;
    qsrCmd.readCount = kHMMessageAPI_PerReadCount;
    qsrCmd.userName = userAccout().userName;
    qsrCmd.uid = device.uid;
    qsrCmd.sendToServer = YES;
    sendCmd(qsrCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (returnValue == KReturnValueSuccess) {
            [HMDatabaseManager insertInTransactionWithHandler:^(NSMutableArray *objectArray) {
                NSArray *statusRecordArr = returnDic[@"statusRecordList"];
                if ([statusRecordArr isKindOfClass:[NSArray class]]) {
                    
                    for (NSDictionary *dic in statusRecordArr) {
                        HMStatusRecordModel *model = [HMStatusRecordModel objectFromDictionary:dic];
                        model.readType = 1;
//                        [model insertObject];
                        [objectArray addObject:model];
                    }
                    
                }
            } completion:^{
                if (completion) {
                    completion(returnValue,returnDic);
                }
            }];
        }
    });
}

+ (void)readOldCommonMsgBeforeSequence:(int)sequence familyId:(NSString *)familyId messageType:(HMMessageType)messageType completion:(commonBlockWithObject)completion {
    int maxDeleteSequence = [HMMessageCommonModel getMaxDeleteSequenceWithFamilyId:familyId messageType:messageType];
    if (sequence <= maxDeleteSequence) {
        DLog(@"打算请求序号：%d以前的数据  最大删除序号：%d 不再请求小于最大删除序号的数据",sequence,maxDeleteSequence);
    }
    [self readCommonMsgBetweenMinSequence:maxDeleteSequence andMaxSequence:sequence familyId:familyId messageType:messageType completion:completion];
}

+ (void)readCommonMsgBetweenMinSequence:(int)minSe andMaxSequence:(int)maxSe familyId:(NSString *)familyId messageType:(HMMessageType)messageType completion:(commonBlockWithObject)completion {
    if (!isNetworkAvailable()) {
        if (completion) {
            completion(KReturnValueNetWorkProblem,nil);
        }
        return;
    }
    QueryUserMessage *qurCmd = [QueryUserMessage object];
    qurCmd.userId = userAccout().userId;
    qurCmd.familyId = familyId;
    qurCmd.tableName = @"messageCommon";
    qurCmd.minSequence = minSe;
    qurCmd.maxSequence = maxSe;
    qurCmd.type = (int)messageType;
    qurCmd.readCount = kHMMessageAPI_PerReadCount;
    qurCmd.sendToServer = YES;
    sendCmd(qurCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        DLog(@"读messageCommon表返回数据：%@",returnDic);
        
        NSString *tableName = returnDic[@"tableName"];
        if ([tableName isKindOfClass:[NSString class]] && [tableName isEqualToString:@"messageCommon"]) {
            
            NSArray *commonMsgArr = returnDic[@"data"];
            
            if ([commonMsgArr isKindOfClass:[NSArray class]]) {
                
                if (commonMsgArr.count) {
                    
                    [[HMDatabaseManager shareDatabase]inSerialQueue:^{
                        
                        NSMutableArray *objectsArray = [NSMutableArray array];
                        
                        for (NSDictionary *msgDic in commonMsgArr) {
                            
                            //DLog(@"msgDic  : %@",msgDic);
                            HMMessageCommonModel *model = [HMMessageCommonModel objectFromDictionary:msgDic];
                            NSString *paramStr = [msgDic objectForKey:@"params"];
                            if (paramStr != nil && ![paramStr isEqual:[NSNull null]]) {
                                NSData *jsonData = [paramStr dataUsingEncoding:NSUTF8StringEncoding];
                                if (jsonData.length) {
                                    NSDictionary *paramStrDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
                                    if (paramStrDic) {
                                        id deviceNameObj = [paramStrDic objectForKey:@"deviceName"];
                                        id roomNameObj = [paramStrDic objectForKey:@"roomName"];
                                        
                                        if ([deviceNameObj isKindOfClass:[NSString class]]) {
                                            model.deviceName = deviceNameObj;
                                        }else {
                                            model.deviceName = @"";
                                        }
                                        if ([roomNameObj isKindOfClass:[NSString class]]) {
                                            model.roomName = roomNameObj;
                                        }else {
                                            model.roomName = @"";
                                        }
                                    }
                                }
                            }
                            [model sql];
                            [objectsArray addObject:model];
                        }
                        
                        [[HMDatabaseManager shareDatabase]inTransaction:^(FMDatabase *db, BOOL *rollback) {
                            
                            [objectsArray setValue:db forKey:@"insertWithDb"];
                            
                            if (completion) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completion(returnValue,returnDic);
                                });
                            }
                        }];
                        
                    }];
                    
                }
            }
        }
    });
    
}


@end
