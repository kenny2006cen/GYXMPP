//
//  ModifyFloorCmd.h
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface ModifyFloorCmd : BaseCmd

@property (nonatomic, retain)NSString * floorId;

@property (nonatomic, retain)NSString * FloorName;

@end
