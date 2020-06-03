//
//  MassAddRoomCmd.h
//  HomeMateSDK
//
//  Created by orvibo on 2018/6/14.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface MassAddRoomCmd : BaseCmd

@property (nonatomic, copy) NSString *floorId;
@property (nonatomic, strong) NSArray *rooms;

@end
