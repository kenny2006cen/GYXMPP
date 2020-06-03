//
//  SetNicknameCmd.h
//  CloudPlatform
//
//  Created by orvibo on 15/6/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface SetNicknameCmd : BaseCmd

@property (nonatomic, copy) NSString *nickname;

@end
