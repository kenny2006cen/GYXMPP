//
//  HMFamilyBusiness.m
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMFamilyBusiness.h"

#define kStartNum 0
#define kLimitNum 20

@implementation HMFamilyBusiness

+ (void)deleteFamilyWithUserId:(NSString *)userId
{
    LogFuncName();
    // 删除指定用户的family数据
    executeUpdate([NSString stringWithFormat:@"delete from family where userId = '%@'",userId]);
    executeUpdate([NSString stringWithFormat:@"delete from familyExt where userId = '%@'",userId]);
}

+ (void)saveAndSortFamilyInfo:(NSDictionary *)returnDic
{
    LogFuncName();
    
    NSArray *familyList = returnDic[@"familyList"];
    
    if (familyList && [familyList isKindOfClass:[NSArray class]]) {
        
        // 当前用户
        NSString *userId = returnDic[@"userId"];
        
        // 删除user的family数据
        [self deleteFamilyWithUserId:userId];
        
        [HMDatabaseManager insertInTransactionWithHandler:^(NSMutableArray *objectArray) {
            
            for (int i = 0; i < familyList.count; i ++) {
                
                // 插入最新family数据
                NSDictionary *dic = familyList[i];
                HMFamily *family = [HMFamily objectFromDictionary:dic];
                [objectArray addObject:family];
                
                // 插入获取到的family列表（按照列表顺序排序）
                HMFamilyExtModel *familyExt = [HMFamilyExtModel objectWithFamily:family sequence:i];
                [objectArray addObject:familyExt];
            }
            
        } completion:^{
            DLog(@"总共接收%d条family数据，从数据库读取到%d条family数据",(int)familyList.count,(int)[HMFamily readAllFamilys].count);
        }];
        
        
    }else{
        DLog(@"family数据有问题，不处理:%@",returnDic);
    }
}

+ (void)queryFamilyListWithCompletion:(SocketCompletionBlock)completion {
    QueryFamilyCmd *cmd = [QueryFamilyCmd object];
    cmd.limit = @(kLimitNum);
    cmd.start = @(kStartNum);
    cmd.userId = userAccout().userId;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (returnValue == KReturnValueSuccess) {
            [HMFamilyBusiness saveAndSortFamilyInfo:returnDic];
        }
        
        if (completion) {
            completion(returnValue, returnDic);
        }
    });
}
/*
 账号下已删除的有设备的未被绑定的家庭
 **/
+ (void)queryFamilyListCanBeRecoverWithCompletion:(SocketCompletionBlock)completion {
    QueryFamilyCmd *cmd = [QueryFamilyCmd object];
    cmd.limit = @(kLimitNum);
    cmd.start = @(kStartNum);
    cmd.userId = userAccout().userId;
    cmd.type = 1;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (completion) {
            completion(returnValue, returnDic);
        }
    });
}


+ (void)checkHostUpgradeStatus
{
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        
        LogFuncName();
        [self.delegate checkHostUpgradeStatus];
    }
}
+ (void)switchToFamily:(NSString *)familyId completion:(commonBlock)completion {
    
    DLog(@"switchToFamily familyId = %@",familyId);
    [self requestFamilyWithUserId:userAccout().userId lastFamilyId:familyId completion:^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (returnValue == KReturnValueSuccess) {
            
            // 注意不能直接受用familyId，因为有可能要切换的familyId已经失效，应该使用 userAccout().familyId
            DLog(@"开始读家庭下的所有数据 familyId = %@",userAccout().familyId);
            
            [HMLoginAPI readDataInFamily:userAccout().familyId completion:^(KReturnValue value,NSSet *tables) {
                
                if (value == KReturnValueSuccess) {
                    
                    DLog(@"切换家庭成功，查询最新局域网通信密钥");
                    [HMUdpAPI queryNewestLanCommunicationKeyFromServerWithFamilyId:userAccout().familyId callBlock:^(NSString *lanCommunicationKey) {
                    }];
 
                    DLog(@"同步家庭familyId = %@数据成功，发出通知，刷新数据",userAccout().familyId);
                    [HMBaseAPI postNotification:KNOTIFICATION_SYNC_TABLE_DATA_FINISH object:tables];
                    
                    DLog(@"同步家庭familyId = %@数据成功，检查主机升级状态",userAccout().familyId);
                    [self checkHostUpgradeStatus];
                    
                }
                
                if (completion) {
                    completion(returnValue);
                }
                
                if (value == KReturnValueSuccess) {
                    [HMBaseAPI postNotification:kNOTIFICATION_FAMILY_SWITCH_SUCCESS object:familyId];
                }
            }];
            
        }else{
            if (completion) {
                completion(returnValue);
            }
        }
        
    }];
}

+ (void)createFamilyWithName:(NSString *)familyName completion:(commonBlockWithObject)completion {
    [self createFamilyWithName:familyName loading:YES completion:completion];
}
+ (void)createFamilyWithName:(NSString *)familyName loading:(BOOL)loading completion:(commonBlockWithObject)completion {
    [self createFamilyWithName:familyName loading:loading insert:YES completion:completion];
}
+ (void)createFamilyWithName:(NSString *)familyName loading:(BOOL)loading insert:(BOOL)insert completion:(commonBlockWithObject)completion {
    AddFamilyCmd *cmd = [AddFamilyCmd object];
    cmd.userId =  userAccout().userId;
    cmd.familyName = familyName;
    cmd.sendToServer = YES;
    
    sendLCmd(cmd, loading, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            
            if (insert) {
                NSDictionary *familyDic = returnDic[@"family"];
                HMFamily *family = [HMFamily objectFromDictionary:familyDic];
                [family insertObject];
            }
            
            [HMFamilyBusiness queryFamilyListWithCompletion:nil];
            
            if (completion) {
                completion(returnValue, returnDic);
            }
            return; // 成功时尽早return
        }// 所有的失败情况，都走这里
        if (completion) {
            completion(returnValue,returnDic);
        }
    });
}

+ (void)modifyFamilyWithName:(NSString *)familyName familyId:(NSString *)familyId completion:(commonBlockWithObject)completion {
    if (!familyId.length) {
        if (completion) {
            DLog(@"familyId 不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    
    UpdateFamilyCmd *cmd = [UpdateFamilyCmd object];
    cmd.userId = userAccout().userId;
    cmd.familyId = familyId;
    cmd.familyName = familyName;
    sendLCmd(cmd, YES, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            NSDictionary *dic = returnDic[@"family"];
            [HMFamily updateFamilyName:dic[@"familyName"] byFamilyId:dic[@"familyId"]];
            if (completion) {
                completion(returnValue, returnDic);
            }
            return; // 成功时尽早return
        }// 所有的失败情况，都走这里
        if (completion) {
            completion(returnValue,nil);
        }
    });
}

/**
 修改家庭地理位置
 
 @param geofence 地理围栏
 @param position 家庭的位置
 @param latotide 经度
 @param latotide 纬度
 @param familyId 该家庭的id
 @param completion 回调方法使用服务器返回数据
 */
+ (void)modifyFamilyWithGeofence:(NSString *)geofence
                         positon:(NSString *)position
                       longitude:(NSString *)longitude
                        latotide:(NSString *)latotide
                        familyId:(NSString *)familyId
                      completion:(commonBlockWithObject)completion {
    
    if (!familyId.length) {
        if (completion) {
            DLog(@"familyId 不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    
    UpdateFamilyCmd *cmd = [UpdateFamilyCmd object];
    cmd.userId = userAccout().userId;
    cmd.familyId = familyId;
    cmd.geofence = geofence;
    cmd.position = position;
    cmd.latotide = latotide;
    cmd.longitude = longitude;
    sendLCmd(cmd, NO, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            NSDictionary *dic = returnDic[@"family"];
            HMFamily * family = [HMFamily objectFromDictionary:dic];
            [family insertObject];
            if (completion) {
                completion(returnValue, returnDic);
            }
            return; // 成功时尽早return
        }// 所有的失败情况，都走这里
        if (completion) {
            completion(returnValue,nil);
        }
    });
    
}


+ (void)queryFamilyUsersList:(NSString *)familyId completion:(commonBlockWithObject)completion {
    if (!familyId.length) {
        if (completion) {
            DLog(@"familyId 不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    QueryFamilyUsers *cmd = [QueryFamilyUsers object];
    cmd.userId = userAccout().userId;
    cmd.familyId = familyId;
    sendLCmd(cmd, NO, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            
            // 删除旧数据
            [HMFamilyUsers deleteFamilyUsersOfFamilyId:familyId];

            // 插入新数据
            NSArray *userArr = returnDic[@"fuList"];
            for (NSDictionary *dic in userArr) {
                HMFamilyUsers * user = [HMFamilyUsers objectFromDictionary:dic];
                [user insertObject];
            }
        }
        
        if (completion) {
            completion(returnValue,nil);
        }
    });
}

+ (void)inviteFamily:(NSString *)userName
            familyId:(NSString *)familyId
             isAdmin:(BOOL)isAdmin
 unAuthorizedRoomIds:(NSArray<NSString*>*)unAuthorizedRoomIds
unAuthorizedDevcedIds:(NSArray<NSString*>*)unAuthorizedDevcedIds
unAuthorizedGroupIds:(NSArray<NSString*>*)unAuthorizedGroupIds
unAuthorizedSceneNos:(NSArray<NSString*>*)unAuthorizedSceneNos
            userBind:(HMDoorUserBind *)user
          completion:(commonBlockWithObject)completion {
    
    if (!familyId.length || !userName.length) {
        if (completion) {
            DLog(@"familyId 和 userName 不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    InviteFamilyCmd *cmd = [InviteFamilyCmd object];
    cmd.userId = userAccout().userId;
    cmd.userName = userName;
    cmd.familyId = familyId;
    if (user) {//t1门锁关联帐号
        cmd.authorizedId = user.authorizedId;
        cmd.extAddr = user.extAddr;
    }
    if (isAdmin) {
        cmd.userType = 0;
    } else {
        cmd.userType = 1;
        NSMutableArray *roomList = [NSMutableArray array];
        [unAuthorizedRoomIds enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [roomList addObject:@{ @"roomId": obj, @"isAuthorized": @(0) }];
        }];
        NSMutableArray *deviceList = [NSMutableArray array];
        [unAuthorizedDevcedIds enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [deviceList addObject:@{ @"deviceId": obj, @"isAuthorized": @(0) }];
        }];

        NSMutableArray *groupList = [NSMutableArray array];
        [unAuthorizedGroupIds enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [groupList addObject:@{ @"groupId": obj, @"isAuthorized": @(0) }];
        }];
        
        cmd.authority = @{ @"roomList": roomList, @"deviceList": deviceList,@"groupList":groupList};

        // 情景是把有权限的数据发过去,传过来的是无权限的，所以要取反 （服务器上：情景默认没权限）
        NSArray *scenesArr = [HMSceneExtModel readAllSceneArray];
        NSArray * authorizedSceneNos = [scenesArr valueForKey:@"sceneNo"];
        if (unAuthorizedSceneNos) {
            authorizedSceneNos = [authorizedSceneNos filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (self in %@)",unAuthorizedSceneNos]];
        }
        if (authorizedSceneNos.count) {
            NSMutableArray *sceneList = [NSMutableArray array];
            [authorizedSceneNos enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [sceneList addObject:@{ @"sceneNo": obj, @"isAuthorized": @(1) }];
            }];
            cmd.authority = @{ @"roomList": roomList, @"deviceList": deviceList,@"groupList":groupList,@"sceneList":sceneList };
        }
    }
    cmd.sendToServer = YES;
    sendLCmd(cmd, YES, (^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (completion) {
            completion(returnValue, returnDic);
        }
    }));
    
    
}

+ (void)deleteFamilyUsers:(HMFamilyUsers *)familyUser completion:(commonBlockWithObject)completion {
    [self deleteFamilyUsers:familyUser deleteLocal:YES completion:completion];
}
+ (void)deleteFamilyUsers:(HMFamilyUsers *)familyUser deleteLocal:(BOOL)deleteLocal completion:(commonBlockWithObject)completion {

    if (!familyUser.familyUserId.length) {
        if (completion) {
            DLog(@"familyUser.familyUserId 不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    
    DeleteFamilyUserCmd *cmd = [DeleteFamilyUserCmd object];
    cmd.familyUserId = familyUser.familyUserId;
    cmd.sendToServer = YES;
    
    sendLCmd(cmd, YES, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            if (deleteLocal) {
                [familyUser deleteObject];
            }
            
            if (completion) {
                completion(returnValue, returnDic);
            }
            return; // 成功时尽早return
        }// 所有的失败情况，都走这里
        if (completion) {
            completion(returnValue,nil);
        }
    });

}

+ (void)deleteFamily:(NSString *)familyId completion:(commonBlockWithObject)completion {
    if (!familyId.length) {
        if (completion) {
            DLog(@"familyId 不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    HMFamily *family = [HMFamily familyWithId:familyId];
    
    DeleteFamilyCmd *cmd = [DeleteFamilyCmd object];
    cmd.userId = userAccout().userId;
    cmd.familyId = familyId;
    cmd.sendToServer = YES;
    sendLCmd(cmd, YES, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess || returnValue == KReturnValueDataNotExist) {
            [family deleteObject];
            
            // 删除家庭成员
            [HMFamilyUsers deleteFamilyUsersOfFamilyId:familyId];
            
            if (completion) {
                completion(returnValue, returnDic);
            }
            return; // 成功时尽早return
        }// 所有的失败情况，都走这里
        if (completion) {
            completion(returnValue,nil);
        }
    });
}

+ (void)exitFamily:(NSString *)familyId completion:(commonBlockWithObject)completion {
    if (!familyId.length) {
        if (completion) {
            DLog(@"familyId 不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    HMFamily *family = [HMFamily familyWithFamilyId:familyId userId:userAccout().userId];
    
    LeaveFamilyCmd *cmd = [LeaveFamilyCmd object];
    cmd.userId = userAccout().userId;
    cmd.familyId = familyId;
    cmd.sendToServer = YES;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess || returnValue == KReturnValueDataNotExist) {
            
           BOOL ret =  [family deleteObject];
            DLog(@"删除家庭 ret :%d",ret);
            
            if (completion) {
                completion(returnValue, returnDic);
            }
            return; // 成功时尽早return
        }// 所有的失败情况，都走这里
        if (completion) {
            completion(returnValue,nil);
        }
    });
}

+ (void)searchFamilyInLan:(NSArray<NSString *> *)uidList completion:(commonBlockWithObject)completion {
    SearchFamilyInLanCmd *cmd = [SearchFamilyInLanCmd object];
    if (uidList.count) {
        cmd.uidList = uidList;
    } else {
        cmd.uidList = @[];
    }
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (completion) {
            completion(returnValue, returnDic);
        }
    });
}

+ (void)searchFamilyInLanWithCompletion:(commonBlockWithObject)completion {
    searchGatewaysWtihCompletion(^(BOOL success, NSArray *gateways) {
        if (success) {
            NSArray *gatewayUids = [gateways valueForKey:@"uid"];
            [self searchFamilyInLan:gatewayUids completion:completion];
        } else {
            [self searchFamilyInLan:nil completion:completion];
        }
    });
}

+ (void)joinFamily:(NSString *)familyId completion:(commonBlockWithObject)completion {
    if (!familyId.length) {
        if (completion) {
            completion(KReturnValueParameterError, nil);
        }
    }
    JoinFamilyCmd *cmd = [JoinFamilyCmd object];
    cmd.userId = userAccout().userId;
    cmd.familyId = familyId;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (completion) {
            completion(returnValue, returnDic);
        }
    });
}

+ (void)responseJoinFamilyWithFamilyJoinId:(NSString *)familyJoinId accept:(BOOL)accept completion:(commonBlockWithObject)completion {
    if (!familyJoinId.length) {
        if (completion) {
            completion(KReturnValueParameterError, nil);
        }
    }
    JoinFamilyResponseCmd *cmd = [JoinFamilyResponseCmd object];
    cmd.familyJoinId = familyJoinId;
    cmd.type = accept ? 1 : 2;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (completion) {
            completion(returnValue, returnDic);
        }
    });
}

+ (void)joinFamilyAsAdmin:(NSString *)familyId completion:(commonBlockWithObject)completion {
    if (!familyId.length) {
        if (completion) {
            completion(KReturnValueParameterError, nil);
        }
    }
    JoinFamilyAsAdminCmd *cmd = [JoinFamilyAsAdminCmd object];
    cmd.userId = userAccout().userId;
    cmd.familyId = familyId;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (completion) {
            completion(returnValue, returnDic);
        }
    });
}


+(void)requestFamilyWithUserId:(NSString *)userId completion:(SocketCompletionBlock)completion
{
    NSString *lastUserFmlyKey =  [NSString stringWithFormat:@"CurrentFamilyIDKey_%@",userId];
    NSString *lastFamilyId = [HMUserDefaults valueForKey:lastUserFmlyKey];
    [HMFamilyBusiness requestFamilyWithUserId:userId lastFamilyId:lastFamilyId completion:completion];
}


+(void)requestFamilyWithUserId:(NSString *)userId lastFamilyId:(NSString *)lastFamilyId completion:(SocketCompletionBlock)completion
{
    NSParameterAssert(userId);
    DLog(@"requestFamilyWithUserId:%@ lastFamilyId:%@",userId,lastFamilyId);
    
    //查询family信息
    QueryFamilyCmd *queryFamily = [QueryFamilyCmd object];
    queryFamily.userId = userId;
    queryFamily.limit = @(kLimitNum);
    queryFamily.start = @(kStartNum);
    sendCmd(queryFamily, ^(KReturnValue returnValue , NSDictionary *returnDic) {
        
        if (returnValue == KReturnValueSuccess) {
            
            NSString *userId = returnDic[@"userId"];
            
            NSArray *familyList = returnDic[@"familyList"];
            
            // 家庭信息有效
            if (familyList && [familyList isKindOfClass:[NSArray class]] && [familyList count]) {
                
                // 家庭未失效，仍然可以查到当前家庭
                NSString * validFamilyId = nil;
                
                NSArray *familyIds = [familyList valueForKey:@"familyId"];
                if (lastFamilyId && [familyIds containsObject:lastFamilyId]) {
                    
                    DLog(@"选择的家庭有效，则读取当前家庭下面的所有设备数据信息");
                    validFamilyId = lastFamilyId;
                    
                }else{
                    
                    validFamilyId = familyIds.firstObject;
                    
                    DLog(@"用户：%@选择的家庭：%@已失效，自动切换到默认家庭：%@",userId,lastFamilyId,validFamilyId);
                    NSParameterAssert(validFamilyId);
                }
                
                userAccout().familyId = validFamilyId;
                
                // 更新家庭信息
                [HMFamilyBusiness saveAndSortFamilyInfo:returnDic];
                
            }else{
                
                DLog(@"远程返回无家庭：%@",returnDic);
                returnValue = KReturnValueFamilyEmpty;
                
                // 如果服务器返回无家庭，则应该把此值置为nil
                userAccout().familyId = nil;
                
                [HMFamilyBusiness deleteFamilyWithUserId:userId];
            }
        }
        
        if (completion) {
            completion(returnValue,returnDic);
        }
        
    });
}

+ (void)queryRoomAuthorityWithFamilyId:(NSString *)familyId userId:(NSString *)userId completion:(commonBlockWithObject)completion {
    if (!familyId.length || !userId.length) {
        if (completion) {
            completion(KReturnValueParameterError, nil);
        }
    }
    QueryRoomAuthorityCmd *cmd = [QueryRoomAuthorityCmd object];
    cmd.familyId = familyId;
    cmd.userId = userId;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (completion) {
            completion(returnValue,returnDic);
        }
    });
}

+ (void)queryDeviceAuthorityWithFamilyId:(NSString *)familyId userId:(NSString *)userId completion:(commonBlockWithObject)completion {
    if (!familyId.length || !userId.length) {
        if (completion) {
            completion(KReturnValueParameterError, nil);
        }
    }
    
    NewQueryAuthorityCmd *cmd = [NewQueryAuthorityCmd object];
    cmd.familyId = familyId;
    cmd.userId = userId;
    cmd.start = @(0);
    cmd.limit = @(20);
    cmd.authorityTypes = @"1,6";
    cmd.type = 1;
    
    [self queryAuthorityWithCmd:cmd completion:completion];
}

+ (void)queryAuthorityWithCmd:(NewQueryAuthorityCmd *)cmd completion:(commonBlockWithObject)completion
{
    if ([cmd.authorityTypes containsString:@","]) {
        NSMutableArray *authorityTypes = [[cmd.authorityTypes componentsSeparatedByString:@","]mutableCopy];
        [self queryAuthorityWithCmd:cmd authorityTypes:authorityTypes dataList:[@[] mutableCopy] completion:completion];
    }else{
        sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
            if (completion) {
                completion(returnValue,returnDic);
            }
        });
    }
}
+ (void)queryAuthorityWithCmd:(NewQueryAuthorityCmd *)cmd authorityTypes:(NSMutableArray *)authorityTypes dataList:(NSMutableArray *)dataList completion:(commonBlockWithObject)completion{
    
    NSString *authorityType = authorityTypes.firstObject;
    NewQueryAuthorityCmd * newCmd = [cmd copy];
    newCmd.authorityTypes = authorityType;
    
    sendCmd(newCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        // 成功，再查询下一个权限
        if (returnValue == KReturnValueSuccess) {
            
            NSArray *data = returnDic[@"data"];
            if (data && [data isKindOfClass:[NSArray class]]) {
                [dataList addObjectsFromArray:data];
            }
            [authorityTypes removeObject:authorityType];
            if (!authorityTypes.count) { // 所有类型都读取完毕
                
                NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dataList];
                NSArray *array = [orderedSet array];
                
                NSMutableDictionary *dict = [returnDic mutableCopy];
                dict[@"data"] = array;
                if (completion) {
                    completion(returnValue,dict);
                }
                
            }else{
                // 递归读取其他类型的权限
                [self queryAuthorityWithCmd:cmd authorityTypes:authorityTypes dataList:dataList completion:completion];
            }
            
        }else{ // 失败直接返回结果
            if (completion) {
                completion(returnValue,returnDic);
            }
        }
        
    });
}

+ (void)modifyRoomAuthorityWithFamilyId:(NSString *)familyId userId:(NSString *)userId roomId:(NSString *)roomId authorized:(BOOL)authorized completion:(commonBlockWithObject)completion {
    if (!familyId.length || !userId.length || !roomId.length) {
        if (completion) {
            completion(KReturnValueParameterError, nil);
        }
    }
    ModifyRoomAuthorityCmd *cmd = [ModifyRoomAuthorityCmd object];
    cmd.familyId = familyId;
    cmd.userId = userId;
    cmd.isAuthorized = authorized;
    cmd.roomId = roomId;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (completion) {
            completion(returnValue,returnDic);
        }
    });
    
}

+ (void)modifyDeviceAuthorityWithFamilyId:(NSString *)familyId userId:(NSString *)userId authorizedList:(NSArray <HMDevice *>*)authorizedList unauthorizedList:(NSArray <HMDevice *>*)unauthorizedList completion:(commonBlockWithObject)completion {
    if (!familyId.length || !userId.length) {
        if (completion) {
            completion(KReturnValueParameterError, nil);
        }
    }
    
    NSMutableArray *deviceList = [NSMutableArray array];
    [authorizedList enumerateObjectsUsingBlock:^(HMDevice * device, NSUInteger idx, BOOL * _Nonnull stop) {
        if (device.deviceType == KDeviceTypeDeviceGroup) {
            [deviceList addObject:@{@"objId":device.deviceId, @"isAuthorized":@(1),@"authorityType":@(6)}];
        }else {
            [deviceList addObject:@{@"objId":device.deviceId, @"isAuthorized":@(1),@"authorityType":@(1)}];
        }
    }];
    [unauthorizedList enumerateObjectsUsingBlock:^(HMDevice * device, NSUInteger idx, BOOL * _Nonnull stop) {
        if (device.deviceType == KDeviceTypeDeviceGroup) {
            [deviceList addObject:@{@"objId":device.deviceId, @"isAuthorized":@(0),@"authorityType":@(6)}];
        }else {
            [deviceList addObject:@{@"objId":device.deviceId, @"isAuthorized":@(0),@"authorityType":@(1)}];
        }
    }];
    
    ModifySceneAuthorityCmd *cmd = [[ModifySceneAuthorityCmd alloc] init];
    cmd.familyId = familyId;
    cmd.authorityType = -1;
    cmd.userId = userId;
    cmd.dataList = deviceList;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (completion) {
            completion(returnValue,returnDic);
        }
    });
}

+ (void)modifyFamilyAdminAuthorityWithFamilyId:(NSString *)familyId userId:(NSString *)userId toBeAdmin:(BOOL)toBeAdmin completion:(commonBlockWithObject)completion {
    if (!familyId.length || !userId.length) {
        if (completion) {
            completion(KReturnValueParameterError, nil);
        }
    }
    ModifyFamilyAdminAuthorityCmd *cmd = [ModifyFamilyAdminAuthorityCmd object];
    cmd.familyId = familyId;
    cmd.userId = userId;
    if (toBeAdmin) {
        cmd.isAdmin = 1;
    } else {
        cmd.isAdmin = 0;
    }
    
    cmd.sendToServer = YES;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (completion) {
            completion(returnValue, returnDic);
        }
    });
}

+ (void)queryAdminFamilyWithUserName:(NSString *)userName completion:(commonBlockWithObject)completion {
    if (!userName.length) {
        if (completion) {
            completion(KReturnValueParameterError, nil);
        }
    }
    QueryAdminFamilyCmd *cmd = [QueryAdminFamilyCmd object];
    cmd.userName = userName;

    cmd.sendToServer = YES;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (completion) {
            completion(returnValue, returnDic);
        }
    });
}

+ (void)queryFamilyByFamilyId:(NSString *)familyId completion:(commonBlockWithObject)completion {
    if (!familyId.length) {
        if (completion) {
            completion(KReturnValueParameterError, nil);
        }
    }
    QueryFamilyByFamilyIdCmd *cmd = [QueryFamilyByFamilyIdCmd object];
    cmd.familyId = familyId;
    cmd.sendToServer = YES;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (completion) {
            completion(returnValue, returnDic);
        }
    });
}

+ (void)recoverFamily:(NSString *)familyId completion:(commonBlockWithObject)completion {
    RecoverFamilyCmd *cmd = [RecoverFamilyCmd object];
    cmd.familyId = familyId;
    cmd.userId = userAccout().userId;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (completion) {
            completion(returnValue, returnDic);
        }
    });
}
/**
 查询指定用户的所有终端设备信息，返回设备的标识信息和名称列表，按上报时间倒序排序，最近使用过的终端排在最上面
 
 @param userId 用户Id
 @param completion 回调方法使用服务器返回数据
 */
+ (void)queryUserTerminalDeviceByUserId:(NSString *)userId completion:(commonBlockWithObject)completion {
    HMQueryUserTerminalDevice *cmd = [HMQueryUserTerminalDevice object];
    cmd.userId = userId;
    cmd.familyId = userAccout().familyId;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (completion) {
            completion(returnValue, returnDic);
        }
    });
}

@end
