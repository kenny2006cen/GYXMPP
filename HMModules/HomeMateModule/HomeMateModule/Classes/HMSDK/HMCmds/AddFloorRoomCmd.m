//
//  AddFloorRoomCmd.m
//  Vihome
//
//  Created by Air on 15-3-6.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "AddFloorRoomCmd.h"

#import "HMRoom.h"

@implementation AddFloorRoomCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_AFR;
}

-(NSDictionary *)payload
{
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (NSDictionary *dic in self.floorArray) {
        
        NSMutableArray *array = [NSMutableArray array];
        NSArray *roomNameList = [dic objectForKey:@"roomNameList"];
        for (HMRoom *room in roomNameList) {
    
            [array addObject:@{@"roomName": room.roomName,@"roomType":@(room.roomType)}];
        }
        NSMutableDictionary * tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [tempDic setObject:array forKey:@"roomNameList"];
        
        [tempArray addObject:tempDic];
    }

    [sendDic setObject:tempArray forKey:@"floorList"];
    
    return sendDic;
}

@end
