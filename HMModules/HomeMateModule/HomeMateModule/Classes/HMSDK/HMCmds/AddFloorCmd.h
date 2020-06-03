//
//  AddFloorCmd.h
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface AddFloorCmd : BaseCmd

@property (nonatomic, copy)NSString * floorName;
@property (nonatomic, copy)NSString * familyId;

@end
