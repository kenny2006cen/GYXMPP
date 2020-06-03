//
//  HMQueryNotificationAuthorityCmd.h
//  HomeMateSDK
//
//  Created by orvibo on 2018/9/5.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface HMQueryNotificationAuthorityCmd : BaseCmd

@property (nonatomic, strong) NSString *familyId;

/**
 3：情景自定义消息通知权限
 4：自动化自定义消息通知权限
 */
@property (nonatomic, assign) int authorityType;

/**

 authorityType = 3：sceneBindId
 authorityType = 4：linkageOutputId
 
 可选参数
 如果带了对象Id，服务器返回单个情景/自动化的通知
 如果没带对象Id，服务器返回家庭下的多个情景/自动化的通知
 */
@property (nonatomic, strong) NSString *objId;

@end
