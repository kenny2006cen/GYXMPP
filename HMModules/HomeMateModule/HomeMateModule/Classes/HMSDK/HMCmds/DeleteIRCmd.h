//
//  DeleteIRCmd.h
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface DeleteIRCmd : BaseCmd

@property (nonatomic, assign)int deviceIrId;

@property (nonatomic, assign)int deviceId;

@end
