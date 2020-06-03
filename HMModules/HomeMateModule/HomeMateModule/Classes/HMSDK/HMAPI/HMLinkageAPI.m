//
//  HMLinkageAPI.m
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMLinkageAPI.h"
#import "HMLinkageBusiness.h"
#import "HMSceneBusiness.h"

@implementation HMLinkageAPI


+ (void)deleteLinkage:(HMLinkage *)linkage completion:(commonBlockWithObject)completion {

    [HMLinkageBusiness deleteLinkage:linkage completion:completion];
}

+ (void)createLinkageWithName:(NSString *)linkageName conditionList:(NSArray *)conditionList outputList:(NSArray *)outputList completion:(commonBlockWithObject)completion {

    [HMLinkageBusiness createLinkageWithName:linkageName conditionList:conditionList outputList:outputList completion:completion];
}

+ (void)modifyLinkageWithName:(NSString *)linkageName
                    linkageId:(NSString *)linkageId
                         type:(int)type
      linkageConditionAddList:(NSArray *)linkageConditionAddList
   linkageConditionModifyList:(NSArray *)linkageConditionModifyList
   linkageConditionDeleteList:(NSArray *)linkageConditionDeleteList
         linkageOutputAddList:(NSArray *)linkageOutputAddList
      linkageOutputModifyList:(NSArray *)linkageOutputModifyList
      linkageOutputDeleteList:(NSArray *)linkageOutputDeleteList
                   completion:(commonBlockWithObject)completion
{

    [HMLinkageBusiness modifyLinkageWithName:linkageName
                                   linkageId:linkageId
                                        type:type
                     linkageConditionAddList:linkageConditionAddList
                  linkageConditionModifyList:linkageConditionModifyList
                  linkageConditionDeleteList:linkageConditionDeleteList
                        linkageOutputAddList:linkageOutputAddList
                     linkageOutputModifyList:linkageOutputModifyList
                     linkageOutputDeleteList:linkageOutputDeleteList
                                  completion:completion];
}

+ (void)createLinkageWithName:(NSString *)linkageName
            conditionRelation:(NSString *)relation
                conditionList:(NSArray *)conditionList
                   outputList:(NSArray *)outputList
                   completion:(commonBlockWithObject)completion
{
    [HMLinkageBusiness createLinkageWithName:linkageName
                           conditionRelation:relation
                               conditionList:conditionList
                                  outputList:outputList
                                  completion:completion];
}



+ (void)createLinkageWithName:(NSString *)linkageName
                         type:(HMLinakgeType)type
                         mode:(HMLinakgeVoiceMode)mode
                          uid:(NSString *)uid
            conditionRelation:(NSString *)relation
                conditionList:(NSArray *)conditionList
                   outputList:(NSArray *)outputList
                   completion:(commonBlockWithObject)completion
{
    [HMLinkageBusiness createLinkageWithName:linkageName
                                        type:type
                                        mode:mode
                                         uid:uid
                           conditionRelation:relation
                               conditionList:conditionList
                                  outputList:outputList
                                  completion:completion];
}

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
                   completion:(commonBlockWithObject)completion
{
    [HMLinkageBusiness modifyLinkageWithName:linkageName
                                   linkageId:linkageId
                                        type:type
                           conditionRelation:relation
                     linkageConditionAddList:linkageConditionAddList
                  linkageConditionModifyList:linkageConditionModifyList
                  linkageConditionDeleteList:linkageConditionDeleteList
                        linkageOutputAddList:linkageOutputAddList
                     linkageOutputModifyList:linkageOutputModifyList
                     linkageOutputDeleteList:linkageOutputDeleteList
                                  completion:completion];
}

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
                   completion:(commonBlockWithObject)completion {
    
    [HMLinkageBusiness modifyLinkageWithName:linkageName
                                   linkageId:linkageId
                                        type:type
                                        mode:mode
                                         uid:uid
                           conditionRelation:relation
                     linkageConditionAddList:linkageConditionAddList
                  linkageConditionModifyList:linkageConditionModifyList
                  linkageConditionDeleteList:linkageConditionDeleteList
                        linkageOutputAddList:linkageOutputAddList
                     linkageOutputModifyList:linkageOutputModifyList
                     linkageOutputDeleteList:linkageOutputDeleteList
                                  completion:completion];
}

+ (void)queryNotificationAuthorityOfLinkageId:(NSString *)linkageId completion:(commonBlockWithObject)completion
{
    [HMSceneBusiness queryNotificationAuthorityOfObjId:linkageId
                                         authorityType:4
                                              familyId:userAccout().familyId
                                            completion:completion];
}

+(NSArray *)authListWithLinkageOutput:(HMLinkageOutput *)output isModify:(BOOL)modify
{
    return [HMSceneBusiness authListWithSceneBind:(HMSceneBind*)output isModify:modify];
}
@end
