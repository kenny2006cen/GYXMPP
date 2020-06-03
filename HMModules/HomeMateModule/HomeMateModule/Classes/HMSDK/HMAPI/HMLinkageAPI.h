//
//  HMLinkageAPI.h
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseAPI.h"
#import "HMTypes.h"
#import "HMLinkage.h"
#import "HMLinkageOutput.h"


@interface HMLinkageAPI : HMBaseAPI



/**
 删除联动

 @param linkage 联动实例
 @param completion 服务器返回字典
 */
+ (void)deleteLinkage:(HMLinkage *)linkage completion:(commonBlockWithObject)completion;


/**
 保存联动

 @param linkageName 联动名称
 @param conditionList 联动启动条件
 @param outputList 联动输出
 */
+ (void)createLinkageWithName:(NSString *)linkageName
                conditionList:(NSArray *)conditionList
                   outputList:(NSArray *)outputList
                   completion:(commonBlockWithObject)completion;


/**
 修改联动

 以下参数，除了 linkageId ，修改了才需要带上

 */
+ (void)modifyLinkageWithName:(NSString *)linkageName
                    linkageId:(NSString *)linkageId
                         type:(int)type
      linkageConditionAddList:(NSArray *)linkageConditionAddList
   linkageConditionModifyList:(NSArray *)linkageConditionModifyList
   linkageConditionDeleteList:(NSArray *)linkageConditionDeleteList
         linkageOutputAddList:(NSArray *)linkageOutputAddList
      linkageOutputModifyList:(NSArray *)linkageOutputModifyList
      linkageOutputDeleteList:(NSArray *)linkageOutputDeleteList
                   completion:(commonBlockWithObject)completion;

/// 多条件联动，新增 conditionRelation  
+ (void)createLinkageWithName:(NSString *)linkageName
            conditionRelation:(NSString *)relation
                conditionList:(NSArray *)conditionList
                   outputList:(NSArray *)outputList
                   completion:(commonBlockWithObject)completion;


/// 多条件联动，新增 conditionRelation
+ (void)createLinkageWithName:(NSString *)linkageName
                         type:(HMLinakgeType)type
                         mode:(HMLinakgeVoiceMode)mode
                          uid:(NSString *)uid
            conditionRelation:(NSString *)relation
                conditionList:(NSArray *)conditionList
                   outputList:(NSArray *)outputList
                   completion:(commonBlockWithObject)completion;


+ (void)modifyLinkageWithName:(NSString *)linkageName
                    linkageId:(NSString *)linkageId
                         type:(int)type
            conditionRelation:(NSString *)relation
      linkageConditionAddList:(NSArray *)linkageConditionAddList
   linkageConditionModifyList:(NSArray *)linkageConditionModifyList
   linkageConditionDeleteList:(NSArray *)linkageConditionDeleteList
         linkageOutputAddList:(NSArray *)linkageOutputAddList
      linkageOutputModifyList:(NSArray *)linkageOutputModifyList
      linkageOutputDeleteList:(NSArray *)linkageOutputDeleteList
                   completion:(commonBlockWithObject)completion;


+ (void)modifyLinkageWithName:(NSString *)linkageName
                    linkageId:(NSString *)linkageId
                         type:(HMLinakgeType)type
                         mode:(HMLinakgeVoiceMode)mode
                          uid:(NSString *)uid
            conditionRelation:(NSString *)relation
      linkageConditionAddList:(NSArray *)linkageConditionAddList
   linkageConditionModifyList:(NSArray *)linkageConditionModifyList
   linkageConditionDeleteList:(NSArray *)linkageConditionDeleteList
         linkageOutputAddList:(NSArray *)linkageOutputAddList
      linkageOutputModifyList:(NSArray *)linkageOutputModifyList
      linkageOutputDeleteList:(NSArray *)linkageOutputDeleteList
                   completion:(commonBlockWithObject)completion;

/**
 查询自动化下面的所有自定义通知，各有哪些用户有权限可以查看
 
 @param linkageId 如果为nil，则查询家庭下所有的自定好输出的自定义通知的用户权限
 @param completion 服务器返回数据
 */
+ (void)queryNotificationAuthorityOfLinkageId:(NSString *)linkageId completion:(commonBlockWithObject)completion;

/** 对于自定义通知，把成员信息转化成协议中的标准json格式 */
+(NSArray *)authListWithLinkageOutput:(HMLinkageOutput *)output isModify:(BOOL)modify;

@end
