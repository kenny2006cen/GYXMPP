//
//  JoinFamilyResponseCmd.h
//  HomeMateSDK
//
//  Created by peanut on 2017/6/14.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

/** 
 * 请求加入家庭处理(主帐号-服务器 3/4)，
 * 主账号选择接受或拒绝子账号的加入家庭申请
 **/
@interface JoinFamilyResponseCmd : BaseCmd

/** 请求的id */
@property (nonatomic, copy) NSString *familyJoinId;
/** 1：接受；2：拒绝 */
@property (nonatomic, assign) int type;

@end
