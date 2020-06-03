//
//  JoinFamilyCmd.h
//  HomeMateSDK
//
//  Created by peanut on 2017/6/14.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

/** 
 * 请求加入家庭(子帐号-服务器 1/4)
 */
@interface JoinFamilyCmd : BaseCmd
/** 选填 */
@property (nonatomic, copy) NSString *userId;
/** 必填 */
@property (nonatomic, copy) NSString *familyId;
@end
