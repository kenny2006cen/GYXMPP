//
//  HMLinkageBusiness.h
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseBusiness.h"

@interface HMLinkageBusiness : HMBaseBusiness

+ (void)deleteLinkage:(HMLinkage *)linkage completion:(commonBlockWithObject)completion;

+ (void)createLinkageWithName:(NSString *)linkageName
                conditionList:(NSArray *)conditionList
                   outputList:(NSArray *)outputList
                   completion:(commonBlockWithObject)completion;

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




// 联动支持多条件接口
+ (void)createLinkageWithName:(NSString *)linkageName
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



+ (void)createLinkageWithName:(NSString *)linkageName
                         type:(HMLinakgeType)type
                         mode:(HMLinakgeVoiceMode)mode
                          uid:(NSString *)uid
            conditionRelation:(NSString *)relation
                conditionList:(NSArray *)conditionList
                   outputList:(NSArray *)outputList
                   completion:(commonBlockWithObject)completion;

@end
