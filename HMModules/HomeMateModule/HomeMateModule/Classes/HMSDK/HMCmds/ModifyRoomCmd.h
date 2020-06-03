//
//  ModifyRoomCmd.h
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface ModifyRoomCmd : BaseCmd

@property (nonatomic, retain)NSString * roomId;

@property (nonatomic, retain)NSString * roomName;

@property (nonatomic, retain)NSString * floorId;

@property (nonatomic, assign)int  roomType;

@end
