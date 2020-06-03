//
//  HMSceneExtModel.m
//  HomeMateSDK
//
//  Created by orvibo on 16/10/7.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMSceneExtModel.h"
#import "HMScene.h"
#import "HMLinkageOutput.h"
#import "HMConstant.h"


@implementation HMSceneExtModel

+ (NSString *)tableName {

    return @"sceneExt";
}

+ (NSArray*)columns
{
    return @[
             column("sceneNo","text"),
             column("sequence","integer"),
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (sceneNo) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


- (BOOL)deleteObject {

    NSString * sql = [NSString stringWithFormat:@"delete from sceneExt where sceneNo = '%@'", self.sceneNo];
    BOOL result = [self executeUpdate:sql];
    return result;
}

- (void)insertObjectWithSceneNo:(NSString *)sceneNo {

    NSString *sql = [NSString stringWithFormat:@"select max(sequence) as max from sceneExt"];

    __block int max;
    queryDatabase(sql, ^(FMResultSet *rs) {
        max = [rs intForColumn:@"max"];
    });
    self.sequence = max + 1;
    self.sceneNo = sceneNo;
    [self updateObject];
}

- (void)deleteObjectWithSceneNo:(NSString *)sceneNo {

    NSString *sql = [NSString stringWithFormat:@"delete from sceneExt where sceneNo = '%@'", sceneNo];
    [self executeUpdate:sql];
}

+ (NSArray <HMLinkageOutput *>*)mixPadRecommendSceneInSceneNames:(NSArray *)sceneNames {
    NSMutableArray * recommendOutPut = [NSMutableArray array];
    
    NSArray * allScene = [self readAllSceneArray];
    for (HMScene * scene in allScene) {
        if ([sceneNames containsObject:scene.sceneName] && scene.onOffFlag != 0) {//系统的全关放在最后
            HMLinkageOutput * output = [HMLinkageOutput objectWithScene:scene];
            [recommendOutPut addObject:output];
        }
    }
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"self.onOffFlag = 0"];
    NSArray * preArray = [allScene filteredArrayUsingPredicate:pre];
    if (preArray.count) {
        HMScene * allOffScene = preArray.firstObject;
        if([sceneNames containsObject:allOffScene.sceneName]){
            HMLinkageOutput * output = [HMLinkageOutput objectWithScene:allOffScene];
            [recommendOutPut addObject:output];
        }
        
    }
    return recommendOutPut;
}

+ (NSArray *)readAllSceneArray {
    
    NSString *sql = [NSString stringWithFormat:@"select s.* from scene s, sceneExt e where s.familyId = '%@' and s.sceneNo = e.sceneNo and s.delFlag == 0 order by e.sequence asc",userAccout().familyId];
    
    NSMutableArray *unionSceneArray = [NSMutableArray array];
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMScene *scene = [HMScene object:rs];
        [unionSceneArray addObject:scene];
    });
    
    if (!unionSceneArray.count) {    // 如果联合查询没有数据，说明，本次查询为首次查询，排序表没有数据，直接把情景返回
        return [HMScene allScenesArr];
    }
    
    NSArray *allSceneArray = [HMScene allScenesArr];     // 获取全部情景
    
    if (allSceneArray.count > unionSceneArray.count) {
        
        // 所有的有排序的 sceneNo
        NSArray *unionSceneArrayNos = [unionSceneArray valueForKey:@"sceneNo"];
        
        // 所有的没排序的情景
        NSPredicate *notSortedScenePred = [NSPredicate predicateWithFormat:@"NOT (self.sceneNo in %@)", unionSceneArrayNos];
        NSArray *notSortedScene = [allSceneArray filteredArrayUsingPredicate:notSortedScenePred];
        
        NSMutableArray *totalArray = [[NSMutableArray alloc] init];
        totalArray = [NSMutableArray arrayWithArray:unionSceneArray];
        [totalArray addObjectsFromArray:notSortedScene];
        return totalArray;
        
    }
    return unionSceneArray;
}

+ (int)sequenceWithSceneNo:(NSString *)sceneNo {
    NSString *sql = [NSString stringWithFormat:@"select sequence from sceneExt where sceneNo = '%@'",sceneNo];
    __block int sequence = 0;
    queryDatabase(sql, ^(FMResultSet *rs) {
        sequence = [rs intForColumn:@"sequence"];
    });
    return sequence;
}

@end
