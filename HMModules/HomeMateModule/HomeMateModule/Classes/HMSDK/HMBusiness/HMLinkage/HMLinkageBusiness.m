//
//  HMLinkageBusiness.m
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMLinkageBusiness.h"

@implementation HMLinkageBusiness


+ (void)deleteLinkage:(HMLinkage *)linkage completion:(commonBlockWithObject)completion {

    if (!linkage) {
        if (completion) {
            DLog(@"删除联动，联动不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }

    DeleteLinkageServiceCmd *cmd = [DeleteLinkageServiceCmd object];
    cmd.userName = userAccout().userName;
    cmd.linkageId = linkage.linkageId;

    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess || returnValue == KReturnValueDataNotExist) {
            [linkage deleteObject];
            [HMLinkageExtModel deleteObjectWithLinkageId:linkage.linkageId];
        }

        if (completion) {
            completion(returnValue, returnDic);
        }
    });

}

+ (void)createLinkageWithName:(NSString *)linkageName
                conditionList:(NSArray *)conditionList
                   outputList:(NSArray *)outputList
                   completion:(commonBlockWithObject)completion {
    [self createLinkageWithName:linkageName
              conditionRelation:nil
                  conditionList:conditionList
                     outputList:outputList
                     completion:completion];
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
                   completion:(commonBlockWithObject)completion {

    [self modifyLinkageWithName:linkageName
                      linkageId:linkageId
                           type:type
              conditionRelation:nil
        linkageConditionAddList:linkageConditionAddList
     linkageConditionModifyList:linkageConditionModifyList
     linkageConditionDeleteList:linkageConditionDeleteList
           linkageOutputAddList:linkageOutputAddList
        linkageOutputModifyList:linkageOutputModifyList
        linkageOutputDeleteList:linkageOutputDeleteList
                     completion:completion];
}


+ (void)createLinkageWithName:(NSString *)linkageName
                         type:(HMLinakgeType)type
                         mode:(HMLinakgeVoiceMode)mode
                          uid:(NSString *)uid
            conditionRelation:(NSString *)relation
                conditionList:(NSArray *)conditionList
                   outputList:(NSArray *)outputList
                   completion:(commonBlockWithObject)completion {
    
    if (!conditionList.count || !outputList.count) {
        if (completion) {
            DLog(@"保存联动数据出错");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    
    AddLinkageServiceCmd * cmd = [AddLinkageServiceCmd object];
    if (uid.length) {
        cmd.uid = uid;
    }else {
        cmd.uid = @"";  // 2.3 需求不需要传递uid，填空值
    }
    cmd.type = type;
    cmd.mode = mode;
    cmd.userName = userAccout().userName;
    cmd.linkageName = linkageName;
    if (relation) {
        cmd.conditionRelation = relation;
    }
    cmd.linkageConditionList = conditionList;
    cmd.linkageOutputList = outputList;
    cmd.familyId = userAccout().familyId;
    
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        [self p_saveSuccessData:returnDic];
        if (completion) {
            completion(returnValue, returnDic);
        }
        
    });
    
    
}



+ (void)createLinkageWithName:(NSString *)linkageName
            conditionRelation:(NSString *)relation
                conditionList:(NSArray *)conditionList
                   outputList:(NSArray *)outputList
                   completion:(commonBlockWithObject)completion {
    
    [self createLinkageWithName:linkageName
                           type:HMLinakgeTypeCommon
                           mode:HMLinakgeVoiceModeCustom
                            uid:@""
              conditionRelation:relation
                  conditionList:conditionList
                     outputList:outputList
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
    
    
    if (!linkageId) {
        if (completion) {
            DLog(@"修改联动，联动id不能为空");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    
    SetLinkageServiceCmd * cmd = [SetLinkageServiceCmd object];
    
    cmd.userName = userAccout().userName;
    cmd.type = (int)type;
    cmd.linkageId = linkageId;
    cmd.uid = uid;
    cmd.linkageName = linkageName; // 修改了才填，未修改可以不用填写
    if (relation) {
        cmd.conditionRelation = relation;
    }
    cmd.linkageConditionAddList = linkageConditionAddList;
    cmd.linkageConditionModifyList = linkageConditionModifyList;
    cmd.linkageConditionDeleteList = linkageConditionDeleteList;
    
    cmd.linkageOutputAddList = linkageOutputAddList;
    cmd.linkageOutputModifyList = linkageOutputModifyList;
    cmd.linkageOutputDeleteList = linkageOutputDeleteList;
    
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        [self p_saveSuccessData:returnDic];
        if (completion) {
            completion(returnValue, returnDic);
        }
        
    });
    
    
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
                   completion:(commonBlockWithObject)completion {
    [self modifyLinkageWithName:linkageName
                      linkageId:linkageId
                           type:type
                           mode:HMLinakgeVoiceModeCustom
                            uid:nil
              conditionRelation:relation
        linkageConditionAddList:linkageConditionAddList
     linkageConditionModifyList:linkageConditionModifyList
     linkageConditionDeleteList:linkageConditionDeleteList
           linkageOutputAddList:linkageOutputAddList
        linkageOutputModifyList:linkageOutputModifyList
        linkageOutputDeleteList:linkageOutputDeleteList
                     completion:completion];
    
}


/**
 *  保存服务器返回的数据
 */
+ (void)p_saveSuccessData:(NSDictionary *)returnData {

    if (!returnData) {
        return;
    }

    NSDictionary *linkageDic = returnData[@"linkage"];
    NSArray *linkageConditionList = returnData[@"linkageConditionList"];
    NSArray *linkageOutputList = returnData[@"linkageOutputList"];

    NSArray *linkageOutputAddList = [returnData objectForKey:@"linkageOutputAddList"];
    NSArray *linkageOutputModifyList = [returnData objectForKey:@"linkageOutputModifyList"];
    NSArray *linkageOutputDeleteList = [returnData objectForKey:@"linkageOutputDeleteList"];

    NSArray *linkageConditionAddList = [returnData objectForKey:@"linkageConditionAddList"];
    NSArray *linkageConditionModifyList = [returnData objectForKey:@"linkageConditionModifyList"];
    NSArray *linkageConditionDeleteList = [returnData objectForKey:@"linkageConditionDeleteList"];

    NSString *linkageName = [returnData objectForKey:@"linkageName"];
    NSString *conditionRelation = [returnData objectForKey:@"conditionRelation"];
    NSString *linkageId = [returnData objectForKey:@"linkageId"];

    if (linkageDic && ![linkageDic isEqual:[NSNull null]]) {   // 联动
        HMLinkage *linkage = [HMLinkage objectFromDictionary:linkageDic];
        [linkage insertObject];

//        HMLinkageExtModel *linkageExt = [[HMLinkageExtModel alloc] init];
//        [linkageExt insertObjectWithLinkageId:linkage.linkageId isInsertTail:YES];  // 排序统一插到尾部
    }

    if (linkageName && linkageId) {
        HMLinkage *linkage = [HMLinkage objectWithLinkageId:linkageId];
        linkage.linkageName = linkageName;
        [linkage updateObject];
    }
    if (conditionRelation && linkageId) {
        HMLinkage *linkage = [HMLinkage objectWithLinkageId:linkageId];
        linkage.conditionRelation = conditionRelation;
        [linkage updateObject];
    }
    

    // ------

    for (NSDictionary *linkageConditionListDic in linkageConditionList) {    // 联动条件 成功列表
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:linkageConditionListDic];
        HMLinkageCondition *linkageCondition = [HMLinkageCondition objectFromDictionary:dic];
        [linkageCondition insertObject];
    }

    for (NSDictionary *linkageOutputListDic in linkageOutputList) {     // 联动输出 成功列表
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:linkageOutputListDic];
        HMLinkageOutput *linkageOutput = [HMLinkageOutput objectFromDictionary:dic];
        [linkageOutput insertObject];
    }

    // ------

    for (NSDictionary *linkageOutputAddListDic in linkageOutputAddList) {       // 添加联动输出 成功列表
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:linkageOutputAddListDic];
        HMLinkageOutput *linkageOutput = [HMLinkageOutput objectFromDictionary:dic];
        linkageOutput.linkageId = linkageId;
        [linkageOutput insertObject];
    }

    for (NSDictionary *linkageOutputModifyListDic in linkageOutputModifyList) {     // 修改联动输出 成功列表
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:linkageOutputModifyListDic];
        HMLinkageOutput *linkageOutput = [HMLinkageOutput objectFromDictionary:dic];
        linkageOutput.linkageId = linkageId;
        [linkageOutput updateObject];
    }

    for (NSDictionary *linkageOutputDeleteListDic in linkageOutputDeleteList) {     // 删除联动输出 成功列表
        NSString *linkageOutputId = linkageOutputDeleteListDic[@"linkageOutputId"];
        [HMLinkageOutput deleteObjectWithLinkageOutputId:linkageOutputId];
    }

    // ------

    for (NSDictionary *linkageConditionAddListDic in linkageConditionAddList) {     // 添加联动条件 成功列表
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:linkageConditionAddListDic];
        HMLinkageCondition *linkageCondition = [HMLinkageCondition objectFromDictionary:dic];
        linkageCondition.linkageId = linkageId;
        [linkageCondition insertObject];
    }

    for (NSDictionary *linkageConditionModifyListDic in linkageConditionModifyList) {   // 修改联动条件 成功列表
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:linkageConditionModifyListDic];
        HMLinkageCondition *linkageCondition = [HMLinkageCondition objectFromDictionary:dic];
        linkageCondition.linkageId = linkageId;
        [linkageCondition insertObject];
    }

    for (NSDictionary *linkageConditionDeleteListDic in linkageConditionDeleteList) {   // 删除联动条件 成功列表

        NSString *linkageConditionId = linkageConditionDeleteListDic[@"linkageConditionId"];
        [HMLinkageCondition deleteConditionWithConditionId:linkageConditionId];
    }
}

@end




