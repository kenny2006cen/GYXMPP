//
//  HMFloorBusiness.m
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMFloorBusiness.h"

@implementation HMFloorBusiness
+ (void)createFloor:(NSString *)floorName familyId:(NSString *)familyId completion:(commonBlockWithObject)completion {
    [self createFloor:floorName familyId:familyId loading:YES completion:completion];
}
+ (void)createFloor:(NSString *)floorName familyId:(NSString *)familyId loading:(BOOL)loading completion:(commonBlockWithObject)completion {
    if (!familyId.length || !floorName.length) {
        if (completion) {
            DLog(@"familyId 和 floorName 不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    HMFloor * newFloor = [[HMFloor alloc] init];
    newFloor.floorName = floorName;
    NSMutableArray *newFloorArray = [NSMutableArray array];
    NSDictionary *dic = @{@"floorName": newFloor.floorName,@"familyId": familyId};
    [newFloorArray addObject:dic];
    
    AddFloorRoomCmd *arCmd = [AddFloorRoomCmd object];
    arCmd.uid = @"";
    arCmd.userName = userAccout().userName;
    arCmd.floorArray = newFloorArray;
    arCmd.sendToServer = YES;
    sendLCmd(arCmd, loading, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            
            [HMFloor saveFloorAndRoom:returnDic];
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

+ (void)modifyFloorName:(NSString *)floorName floorId:(NSString *)floorId completion:(commonBlockWithObject)completion {
    [self modifyFloorName:floorName floorId:floorId loading:YES completion:completion];
}
+ (void)modifyFloorName:(NSString *)floorName floorId:(NSString *)floorId loading:(BOOL)loading completion:(commonBlockWithObject)completion {
    if (!floorId.length) {
        if (completion) {
            DLog(@"floorId 不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    ModifyFloorCmd * mFloor = [ModifyFloorCmd object];
    mFloor.uid = @"";
    mFloor.sendToServer = YES;
    mFloor.userName = userAccout().userName;
    mFloor.FloorName = floorName;
    mFloor.floorId = floorId;
    
    sendLCmd(mFloor, loading, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (returnValue == KReturnValueSuccess) {
            
            HMFloor *newFloor = [HMFloor objectFromDictionary:returnDic];
            [newFloor insertObject]; // 修改楼层
            
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

+ (void)deleteFloor:(NSString *)floorId completion:(commonBlockWithObject)completion {
    [self deleteFloor:floorId loading:YES completion:completion];
}

+ (void)deleteFloor:(NSString *)floorId loading:(BOOL)loading completion:(commonBlockWithObject)completion {
    if (!floorId.length) {
        if (completion) {
            DLog(@"floorId 不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    HMFloor *floor = [HMFloor selectFloorByFloorId:floorId];
    DeleteFloorCmd *afCmd = [DeleteFloorCmd object];
    afCmd.uid = @"";
    afCmd.sendToServer = YES;
    afCmd.userName = userAccout().userName;
    afCmd.floorId = floorId;
    
    sendLCmd(afCmd, loading, (^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess|| returnValue == KReturnValueDataNotExist) {
            
            [floor deleteObject]; // 删除本地楼层和房间
            
            // 发出更新设备-widget数据的通知
            [HMBaseAPI postNotification:kNOTIFICATION_NEED_UPDATE_DEVICE_WIDGET_INFO object:nil];
            
            if (completion) {
                completion(returnValue, returnDic);
            }
            return; // 成功时尽早return
        }// 所有的失败情况，都走这里
        if (completion) {
            completion(returnValue,nil);
        }
    }));
}

+ (NSArray<HMFloor *> *)queryFloorsWithFamilyId:(NSString *)familyId {
    return [HMFloor selectAllFloorWithFamilyId:familyId];
}

+ (NSArray<HMRoom *> *)queryRoomsWithFloorId:(NSString *)floorId {
    return [HMRoom selectAllRoomWithFloorId:floorId];
}

+ (void)createRoom:(NSString *)roomName floorId:(NSString *)floorId completion:(commonBlockWithObject)completion {
    [self createRoom:roomName floorId:floorId loading:YES completion:completion];
}
+ (void)createRoom:(NSString *)roomName floorId:(NSString *)floorId loading:(BOOL)loading completion:(commonBlockWithObject)completion {
    if (!floorId.length) {
        if (completion) {
            DLog(@"floorId 不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    AddRoomCmd * addRoom = [AddRoomCmd object];
    addRoom.uid = @"";
    addRoom.sendToServer = YES;
    addRoom.userName = userAccout().userName;
    addRoom.roomName = roomName;
    addRoom.floorId = floorId;
    addRoom.roomType = 1;
    
    sendLCmd(addRoom, loading, (^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (returnValue == KReturnValueSuccess) {
            
            HMRoom *newRoom = [HMRoom objectFromDictionary:returnDic];
            [newRoom insertObject]; // 添加房间
            
            if (completion) {
                completion(returnValue, returnDic);
            }
            return; // 成功时尽早return
        }// 所有的失败情况，都走这里
        if (completion) {
            completion(returnValue,nil);
        }
    }));
}

+ (void)modifyRoom:(NSString *)roomName roomId:(NSString *)roomId completion:(commonBlockWithObject)completion {
    [self modifyRoom:roomName roomId:roomId loading:YES completion:completion];
}

+ (void)modifyRoom:(NSString *)roomName roomId:(NSString *)roomId loading:(BOOL)loading completion:(commonBlockWithObject)completion {
    if (!roomId.length) {
        if (completion) {
            DLog(@"roomId 不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    HMRoom *room = [HMRoom objectWithRecordId:roomId];
    
    ModifyRoomCmd * mRoom = [ModifyRoomCmd object];
    mRoom.uid = @"";
    mRoom.sendToServer = YES;
    mRoom.userName = userAccout().userName;
    mRoom.roomName = roomName;
    mRoom.roomId = roomId;
    mRoom.floorId = room.floorId;
    mRoom.roomType = room.roomType;
    sendLCmd(mRoom, loading, (^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (returnValue == KReturnValueSuccess) {

            NSString * sql = [NSString stringWithFormat:@"update room set roomName = '%@' , updateTime = '%@' where roomId = '%@'",roomName,returnDic[@"updateTime"],roomId];
            executeUpdate(sql);
            
            if (completion) {
                completion(returnValue, returnDic);
            }
            return; // 成功时尽早return
        }else if (returnValue == KReturnValueDataNotExist){ // 数据已被删除
            [room deleteObject];
        }
        
        // 所有的失败情况，都走这里
        if (completion) {
            completion(returnValue,nil);
        }
    }));

}

+ (void)deleteRoom:(NSString *)roomId completion:(commonBlockWithObject)completion {
    [self deleteRoom:roomId loading:YES completion:completion];
}

+ (void)deleteRoom:(NSString *)roomId loading:(BOOL)loading completion:(commonBlockWithObject)completion {
    if (!roomId.length) {
        if (completion) {
            DLog(@"roomId 不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    DeleteRoomCmd *afCmd = [DeleteRoomCmd object];
    afCmd.uid = @"";
    afCmd.sendToServer = YES;
    afCmd.userName = userAccout().userName;
    afCmd.roomId = roomId;
    
    HMRoom *room = [HMRoom objectWithRecordId:roomId];
    
    sendLCmd(afCmd, loading, (^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (returnValue == KReturnValueSuccess|| returnValue == KReturnValueDataNotExist) {
            
            [room deleteObject];
            // 发出更新设备-widget数据的通知
            [HMBaseAPI postNotification:kNOTIFICATION_NEED_UPDATE_DEVICE_WIDGET_INFO object:nil];
            
            if (completion) {
                completion(returnValue, returnDic);
            }
            return; // 成功时尽早return
        }// 所有的失败情况，都走这里
        if (completion) {
            completion(returnValue,nil);
        }
    }));
}

+ (void)addRooms:(NSArray *)rooms floorId:(NSString *)floorId loading:(BOOL)loading completion:(commonBlockWithObject)completion
{
    if (!rooms.count) {
        DLog(@"异常数据：房间数量为0，直接返回");
        return;
    }
    MassAddRoomCmd *cmd = [MassAddRoomCmd object];
    cmd.userName = userAccout().userName;
    cmd.floorId = floorId;
    cmd.rooms = rooms;
    sendLCmd(cmd,loading, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (returnValue == KReturnValueSuccess) {
            
            [HMDatabaseManager insertInTransactionWithHandler:^(NSMutableArray *objectArray) {
                
                NSArray *rooms = returnDic[@"rooms"];
                if ([rooms isKindOfClass:[NSArray class]]) {
                    
                    for (NSDictionary * roomDic in rooms) {
                        HMRoom *room = [HMRoom objectFromDictionary:roomDic];
                        [objectArray addObject:room];
                    }
                }
            } completion:^{
                if (completion) {
                    completion(returnValue,returnDic);
                }
            }];
        }else{
            if (completion) {
                completion(returnValue, returnDic);
            }
        }
    });
}
@end
