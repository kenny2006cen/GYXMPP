//
//  HMSceneBusiness.m
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMSceneBusiness.h"
#import "HMNetworkMonitor.h"

@implementation HMSceneBusiness

+ (void)createScene:(NSString *)sceneName pic:(int)pic completion:(commonBlockWithObject)completion
{
    NSAssert(sceneName, @"情景名称不能为空");
    
    if (!sceneName || [sceneName isEqualToString:@""]) {
        
        if (completion) {
            DLog(@"情景名称不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    
    AddSceneServiceCmd * cmd = [AddSceneServiceCmd object];
    cmd.userName = userAccout().userName;
    cmd.sceneName = sceneName;
    cmd.pic = pic;
    cmd.familyId = userAccout().familyId;
    
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            
            NSDictionary *sceneDic = returnDic[@"scene"];
            NSAssert(sceneDic, @"服务器返回的情景Dictionary不能为空");
            
            if (sceneDic) {
                
                HMScene * scene = [HMScene objectFromDictionary:sceneDic];
                [scene insertObject];
                
                if (completion) {
                    completion(returnValue, scene);
                }
                return; // 成功时尽早return
            }
        }
        
        // 所有的失败情况，都走这里
        if (completion) {
            completion(returnValue, returnDic);
        }
    });
}


+ (void)modifySceneWithNo:(NSString *)sceneNo sceneName:(NSString *)sceneName pic:(int)pic imageURL:(NSString *)imageURL completion:(commonBlockWithObject)completion {

    NSAssert(sceneNo, @"情景No不能为空");
    NSAssert(sceneName, @"情景名称不能为空");

    if (!sceneNo || [sceneNo isEqualToString:@""]) {
        if (completion) {
            DLog(@"情景 No 不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }

    if (!sceneName || [sceneName isEqualToString:@""]) {
        if (completion) {
            DLog(@"情景名称不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }

    ModifySceneServiceCmd * cmd = [ModifySceneServiceCmd object];
    cmd.userName = userAccout().userName;
    cmd.sceneName = sceneName;
    cmd.sceneNo = sceneNo;
    cmd.pic = pic;
    cmd.imgUrl = imageURL ? imageURL : @"";
    cmd.isTransparent = YES;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {

        if (returnValue == KReturnValueSuccess) {
            HMScene *scene =  [HMScene readSceneWithSceneNo:sceneNo];
            scene.sceneName = sceneName;
            scene.pic = pic;
            scene.imgUrl = imageURL;
            [scene updateObject];
            if (completion) {
                completion(returnValue, scene);
            }
            return;
        } else {
            if (completion) {
                completion(returnValue, returnDic);
            }
        }
    });
}


+ (void)deleteSceneBinds:(NSArray *)sceneBindArray sceneNo:(NSString *)sceneNo completion:(commonBlockWithObject)completion {

    if (!sceneBindArray || !sceneBindArray.count) {
        if (completion) {
            DLog(@"删除情景绑定列表不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }

    if (!sceneNo || [sceneNo isEqualToString:@""]) {
        if (completion) {
            DLog(@"情景 No 不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }

    DeleteSceneBindServiceCmd *deleteSceneBindCmd = [DeleteSceneBindServiceCmd object];
    deleteSceneBindCmd.userName = userAccout().userName;
    deleteSceneBindCmd.sceneBindList = sceneBindArray;
    deleteSceneBindCmd.onlySendOnce = YES;
    deleteSceneBindCmd.sceneNo = sceneNo;
    sendCmd(deleteSceneBindCmd, (^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        // 命令有部分失败的可能(71)，所以不需要判断返回是否成功，直接判断对应字段中是否有数据
        NSArray *successList = [returnDic objectForKey:@"successList"];
        
        if (successList.count) {    // 更新数据库
            
            NSMutableArray *bindIDArray = [NSMutableArray array];
            for(NSDictionary * dic in successList){
                
                NSString *bindId = dic[@"sceneBindId"];
                [bindIDArray addObject:[NSString stringWithFormat:@"'%@'",bindId]];
            }
            NSString *bindIDs = [bindIDArray componentsJoinedByString:@","];
            NSString *sql = [NSString stringWithFormat:@"delete from sceneBind where sceneBindId in (%@)", bindIDs];
            updateInsertDatabase(sql);
        }
        
        if (completion) {
            completion(returnValue, returnDic);
        }
    }));
}

+ (void)addSceneBinds:(NSArray *)sceneBindArray sceneNo:(NSString *)sceneNo completion:(commonBlockWithObject)completion {

    if (!sceneBindArray || !sceneBindArray.count) {
        if (completion) {
            DLog(@"添加情景绑定列表不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }

    if (!sceneNo || [sceneNo isEqualToString:@""]) {
        if (completion) {
            DLog(@"情景 No 不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }

    AddSceneBindServiceCmd *addBindCmd = [AddSceneBindServiceCmd object];
    addBindCmd.userName = userAccout().userName;
    addBindCmd.onlySendOnce = YES;
    addBindCmd.sceneNo = sceneNo;
    addBindCmd.sceneBindList = sceneBindArray;

    sendCmd(addBindCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        NSArray *successList = [returnDic objectForKey:@"successList"];

        if (successList.count) {
            for (NSDictionary *bindDic in successList) {

                NSMutableDictionary *realDic = [NSMutableDictionary dictionaryWithDictionary:bindDic];

                HMSceneBind *bind = [HMSceneBind objectFromDictionary:realDic];
                [bind insertObject];
            }
        }

        if (completion) {
            completion(returnValue, returnDic);
        }
    });
}


+ (void)modifySceneBinds:(NSArray *)sceneBindArray sceneNo:(NSString *)sceneNo completion:(commonBlockWithObject)completion {

    if (!sceneBindArray || !sceneBindArray.count) {
        if (completion) {
            DLog(@"修改情景绑定列表不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }

    if (!sceneNo || [sceneNo isEqualToString:@""]) {
        if (completion) {
            DLog(@"情景 No 不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }

    ModifySceneBindServiceCmd *modifyBindCmd = [ModifySceneBindServiceCmd object];
    modifyBindCmd.userName = userAccout().userName;
    modifyBindCmd.onlySendOnce = YES;
    modifyBindCmd.sceneNo = sceneNo;
    modifyBindCmd.sceneBindList = sceneBindArray;

    sendCmd(modifyBindCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {

        NSArray *successList = [returnDic objectForKey:@"successList"];

        if (successList.count) {

            for (NSDictionary *bindDic in successList) {

                NSMutableDictionary *realDic = [NSMutableDictionary dictionaryWithDictionary:bindDic];
                HMSceneBind *bind = [HMSceneBind objectFromDictionary:realDic];
                if (!bind.updateTime.length) {
                    bind.updateTime = [returnDic objectForKey:@"updateTime"];
                }
                [bind updateObject];
            }
        }

        if (completion) {
            completion(returnValue, returnDic);
        }
    });
}

+ (void)deleteScene:(HMScene *)scene completion:(commonBlockWithObject)completion {

    DeleteSceneServiceCmd * cmd = [DeleteSceneServiceCmd object];
    cmd.userName = userAccout().userName;
    cmd.sceneNo = scene.sceneNo;

    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {

            // 删除手动情景后，删除相应遥控器绑定表
            [HMRemoteBind deleteRemoteBindInfoWithSceneNo:scene.sceneNo];

            // 删除排序
            HMSceneExtModel *sceneExtModel = [[HMSceneExtModel alloc] init];
            [sceneExtModel deleteObjectWithSceneNo:scene.sceneNo];

            // 删除情景
            [scene deleteObject];

        } else if (returnValue == KReturnValueDataNotExist){
            [scene deleteObject];

            [HMRemoteBind deleteRemoteBindInfoWithSceneNo:scene.sceneNo];

        }

        if (completion) {
            completion(returnValue, returnDic);
        }
    });
}

+ (void)triggleSceneWithScene:(HMScene *)scene completion:(commonBlockWithObject)completion {

    [self sceneControlWithSceneNo:scene.sceneNo
                                sceneId:scene.sceneId
                               uidArray:scene.zigbeeHostUidArray
                             completion:completion];
}



+ (void)sceneControlWithSceneNo:(NSString *)sceneNo sceneId:(int)sceneId uidArray:(NSArray *)uidArray completion:(commonBlockWithObject)block
{
    EnableSceneServiceCmd *cmd = [EnableSceneServiceCmd object];
    cmd.userName = userAccout().userName;
    cmd.sceneNo = sceneNo;
    cmd.sendToServer = YES;
    commonBlockWithObject completion = ^(KReturnValue returnValue, NSDictionary *returnDic) {
        // 如果首次返回控制失败，则再尝试一次远程控制，仍然失败则返回
        if (returnValue == KReturnValueFail) {
            sendCmd([cmd copy], ^(KReturnValue returnValue, NSDictionary *returnDic) {
                if (block) {
                    block(returnValue, returnDic);
                }
            });
        }else{
            if (block) {
                block(returnValue, returnDic);
            }
        }
    };
    
    if ([RemoteGateway shareInstance].isSocketConnected) {     // 网络可用，则发到服务器

        sendCmd([cmd copy], ^(KReturnValue returnValue, NSDictionary *returnDic) {
            
            if (returnValue == KReturnValueSuccess) { // 远程控制成功，直接返回
                
                if (completion) {
                    completion(returnValue, returnDic);
                }
                
            }else{ // 远程控制失败，则尝试本地控制
                
                [self localSceneControlWithSceneNo:sceneNo
                                           sceneId:sceneId
                                          uidArray:uidArray
                                        completion:completion];
            }
        });
        
    }else {    // 远程失败则尝试本地控制
        
        [self localSceneControlWithSceneNo:sceneNo
                                   sceneId:sceneId
                                  uidArray:uidArray
                                completion:completion];
    }

}

+ (void)localSceneControlWithSceneNo:(NSString *)sceneNo sceneId:(int)sceneId uidArray:(NSArray *)uidArray completion:(commonBlockWithObject)completion {
    
    // WiFi环境 && 有主机uid信息，才允许本地控制，否则直接返回失败
    if (isEnableWIFI() && uidArray.count) {
        
        NSMutableArray *gateways = [NSMutableArray array];
        for (NSString *uid in uidArray) {
            [gateways addObject:getGateway(uid)];
        }

        // 如果有一个uid在本地，则先尝试本地控制
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"self.isLocalNetwork = %d",YES];
        NSArray *filter = [gateways filteredArrayUsingPredicate:pred];
        
        // 有至少一台主机在本地
        if (filter.count) {
            
            DLog(@"本地主机数量：%d uid:%@",filter.count,filter);
            [self didLocalSceneControlWithSceneNo:sceneNo sceneId:sceneId uidArray:[filter valueForKey:@"uid"] completion:completion];
            
        }else{
            // 如果所有的uid都不在本地，则先mdns搜索一次，再本地控制
            searchGatewaysWtihCompletion(^(BOOL success, NSArray *gateways) {
                
                if (success) {
                    
                    // 本地搜索到主机，则判断是否有传入的uid，如果有，则对本地的uid进行控制
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self in (%@)",[gateways valueForKey:@"uid"]];
                    NSArray *localGateways = [uidArray filteredArrayUsingPredicate:predicate];
                    
                    if (localGateways.count) {
                        
                        DLog(@"本地主机数量：%d uid:%@",localGateways.count,localGateways);
                        [self didLocalSceneControlWithSceneNo:sceneNo sceneId:sceneId uidArray:localGateways completion:completion];
                        
                    }else{
                        
                        // 本地搜索到的主机不包含在传入的数组
                        if (completion) {
                            completion(KReturnValueFail, nil);
                        }
                    }
                    
                }else{
                    
                    // 本地未搜索到主机，直接返回失败
                    if (completion) {
                        completion(KReturnValueFail, nil);
                    }
                }
            });
        }
        
        
    }else {   // 如果没有WiFi或者没有uid，则直接返回失败
        
        if (completion) {
            completion(KReturnValueFail, nil);
        }
    }
}

+ (void)didLocalSceneControlWithSceneNo:(NSString *)sceneNo sceneId:(int)sceneId uidArray:(NSArray *)uidArray completion:(commonBlockWithObject)completion
{
    
    __block BOOL didReceiveSuccess = NO;
    __block int returnFailCount = 0;
    
    for (NSString *uid in uidArray) {
        
        ControlDeviceCmd *cmd = [ControlDeviceCmd object];
        cmd.uid = uid;
        cmd.userName = userAccout().userName;
        cmd.deviceId = sceneNo;
        cmd.order = @"scene control";
        cmd.value1 = sceneId;
        cmd.delayTime = 0;
        cmd.sendToGateway = YES;
        sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
            if (returnValue == KReturnValueSuccess) {
                
                if (completion && didReceiveSuccess == NO) {    // 如果收到成功，就马上返回成功（切只返回一次）
                    DLog(@"收到了成功了，准备返回！");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(returnValue, returnDic);
                    });
                } else {
                    
                    DLog(@"收到了成功，但是已经返回了一次了！！！！");
                    
                }
                didReceiveSuccess = YES;
            } else {
                returnFailCount ++;
                if (completion && returnFailCount == uidArray.count) {     // 如果返回失败的次数为发送的次数，则返回最后一次失败的原因
                    DLog(@"失败次数跟发送次数一样！，要返回失败洛！！！");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(returnValue, nil);
                    });
                }
            }
        });
    }
}

+ (void)querySceneAuthorityOfUserId:(NSString *)userId familyId:(NSString *)familyId completion:(commonBlockWithObject)completion
{
    NSAssert(userId, @"userId is nil");
    NSAssert(familyId, @"familyId is nil");
    QuerySceneAuthorityCmd *cmd = [QuerySceneAuthorityCmd object];
    cmd.userId = userId;
    cmd.familyId = familyId;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
       
        if (completion) {
            completion(returnValue,returnDic);
        }
        
    });
}

+ (void)modifyMemberAuthorityOfUserId:(NSString *)userId
                             familyId:(NSString *)familyId
                        authorityType:(int)authorityType
                             dataList:(NSArray *)dataList
                           completion:(commonBlockWithObject)completion
{
    NSAssert(userId, @"userId is nil");
    NSAssert(familyId, @"familyId is nil");
    NSAssert(dataList, @"dataList is nil");
    
    ModifySceneAuthorityCmd *cmd = [ModifySceneAuthorityCmd object];
    cmd.userId = userId;
    cmd.familyId = familyId;
    cmd.authorityType = authorityType;
    cmd.dataList = dataList;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (completion) {
            completion(returnValue,returnDic);
        }
        
    });
}

+ (void)queryNotificationAuthorityOfObjId:(NSString *)objId authorityType:(int)authorityType familyId:(NSString *)familyId completion:(commonBlockWithObject)completion;
{
    HMQueryNotificationAuthorityCmd *cmd = [HMQueryNotificationAuthorityCmd object];
    cmd.familyId = familyId;
    cmd.authorityType = authorityType;
    cmd.objId = objId;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (returnValue == KReturnValueSuccess) {
            
            NSArray *data = returnDic[@"data"];
            if ([data isKindOfClass:[NSArray class]]) {
                
                NSMutableSet *userSet = [[NSMutableSet alloc]initWithCapacity:5];
                // 插入新的权限信息
                [HMDatabaseManager insertInTransactionWithHandler:^(NSMutableArray *objectArray) {
                    
                    for (NSDictionary *dic in data) {
                        
                        NSString *sceneBindId = dic[@"itemId"];
                        // 删除旧的权限信息
                        [HMAuthority deleteAuthorityWithObjectId:sceneBindId authorityType:authorityType familyId:familyId];
                        
                        NSArray *authArray = dic[@"authArray"];
                        
                        if ([authArray isKindOfClass:[NSArray class]]) {
                            
                            for (NSDictionary *authDic in authArray) {
                                
                                if ([authDic[@"isAuthorized"]intValue] == 1) {
                                    
                                    NSString *userId = authDic[@"userId"];
                                    
                                    HMAuthority *authority = [[HMAuthority alloc]init];
                                    authority.userId = userId;
                                    authority.familyId = familyId;
                                    authority.objId = sceneBindId;
                                    authority.authorityType = authorityType;
                                    [objectArray addObject:authority];
                                    
                                    [userSet addObject:userId];
                                }
                            }
                        }
                    }
                    
                }completion:^{
                    [self checkUsers:userSet data:returnDic completion:completion];
                }];
                return;
            }
        }
    
        if (completion) {
            completion(returnValue,returnDic);
        }
        
    });
}


+(void)checkUsers:(NSSet *)serverUserSet data:(NSDictionary *)returnDic completion:(commonBlockWithObject)completion{

    // 检查有权限的成员，在本地是否有数据，如果没有，则再查一次成员表
    if (serverUserSet.count) {
        
        NSString *familyId = returnDic[@"familyId"];
        
        NSString *userString = stringWithObjectArray([serverUserSet allObjects]);
        NSArray *localUserArray = [self localUserArrayWithUserString:userString familyId:familyId];
        
        // 本地数据库查出来的用户数量，和服务器权限接口返回的user数量一致，则返回组装后的数据
        if (localUserArray.count == serverUserSet.count) {
            if (completion) {
                NSDictionary *dic = [self transformServerData:returnDic localUserArray:localUserArray];
                completion(KReturnValueSuccess,dic);
            }
            
        }else{
             // 本地数据库查出来的用户数量，和服务器权限接口返回的user数量不同，则需要再从服务器查询一次家庭成员数据
            [HMFaimilyAPI queryFamilyUsersList:familyId completion:^(KReturnValue returnValue, id object) {
                
                NSArray *newLocalUserArray = localUserArray;
                if (returnValue == KReturnValueSuccess) {
                    //服务器返回成功，则重新查一次本地数据库
                    newLocalUserArray = [self localUserArrayWithUserString:userString familyId:familyId];
                }else{
                    //服务器返回失败，则用上一次的数据
                }
                
                if (completion) {
                    NSDictionary *dic = [self transformServerData:returnDic localUserArray:newLocalUserArray];
                    completion(returnValue,dic);
                }
            }];
        }
    }else{
        //当前情景下面，所有的自定义通知类型的情景绑定，都没有成员权限
        if (completion) {
            NSDictionary *dic = [self transformServerData:returnDic localUserArray:nil];
            completion(KReturnValueSuccess,dic);
        }
    }
}

+(NSMutableArray *)localUserArrayWithUserString:(NSString *)userString familyId:(NSString *)familyId
{
    NSMutableArray *localUserArray = [@[] mutableCopy];
    
    NSString *sql = [NSString stringWithFormat:@"select * from familyUsers where familyId = '%@' and delFlag = 0 and userId in (%@)",familyId,userString];
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMFamilyUsers *user = [HMFamilyUsers object:rs];
        [localUserArray addObject:user];
    });
    return localUserArray;
}

+(NSDictionary *)transformServerData:(NSDictionary *)returnDic localUserArray:(NSArray *)localUserArray
{
    NSMutableDictionary *transformDic = [@{} mutableCopy];
    
    // 数据转换，由userId字符串转为[HMFamilyUsers]对象
    for (NSDictionary *dic in returnDic[@"data"]) {
        
        NSString *sceneBindId = dic[@"itemId"];
        if (sceneBindId) {
            NSArray *authArray = dic[@"authArray"];
            if (authArray.count) {
                NSArray *sbindAuthUsers = [authArray valueForKey:@"userId"];
                NSPredicate *prd = [NSPredicate predicateWithFormat:@"userId in %@",sbindAuthUsers];
                NSArray *authList = [localUserArray filteredArrayUsingPredicate:prd];
                transformDic[sceneBindId] = authList;
            }else{
                transformDic[sceneBindId] = @[];
            }
        }
    }
    
    return transformDic;
}

+(NSArray *)authListWithSceneBind:(HMSceneBind *)bind isModify:(BOOL)modify
{
    bind.authList = bind.authList ?: @[];
    NSMutableArray *authList = [@[] mutableCopy];
    
    if (modify) { //修改绑定时，把有权限和无权限的成员都带下去
        NSArray *allMembers = [HMFamilyUsers selectAllFamilyUsersByFamilyId:userAccout().familyId];
        NSArray *ownAuthMembers = [bind.authList valueForKey:@"userId"];
        for (HMFamilyUsers *user in allMembers) {
            NSString *memberUserId = user.userId;
            int isAuthorized = [ownAuthMembers containsObject:memberUserId] ? 1:0;
            NSMutableDictionary *dic = [@{} mutableCopy];
            dic[@"userId"] = memberUserId;
            dic[@"isAuthorized"] = @(isAuthorized);
            [authList addObject:dic];
        }
        return authList;
    }
    
    // 添加绑定时，只带有权限的成员数据即可
    for (HMFamilyUsers *user in bind.authList) {
        NSMutableDictionary *dic = [@{} mutableCopy];
        dic[@"userId"] = user.userId;
        dic[@"isAuthorized"] = @(1);
        [authList addObject:dic];
    }
    return authList;
}


@end
