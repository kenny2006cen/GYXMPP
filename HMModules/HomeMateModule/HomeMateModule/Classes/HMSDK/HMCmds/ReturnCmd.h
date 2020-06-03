//
//  ReturnCmd.h
//  Vihome
//
//  Created by Air on 15-2-13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface ReturnCmd : BaseCmd

@property (nonatomic,assign)int status;

@property (nonatomic,strong)NSString * messageId;

@end
