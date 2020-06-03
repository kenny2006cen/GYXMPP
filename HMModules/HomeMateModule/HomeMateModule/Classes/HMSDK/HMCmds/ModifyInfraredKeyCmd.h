//
//  ModifyInfraredKeyCMD.h
//  Vihome
//
//  Created by Ned on 5/8/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface ModifyInfraredKeyCmd : BaseCmd

@property (nonatomic, copy) NSString * deviceIrId;

@property (nonatomic, copy) NSString * deviceId;

@property (nonatomic, copy) NSString * keyName;

@property (nonatomic, copy) NSString * kkIrId;

@property (nonatomic, strong) NSArray * deviceIrArray;

@end
