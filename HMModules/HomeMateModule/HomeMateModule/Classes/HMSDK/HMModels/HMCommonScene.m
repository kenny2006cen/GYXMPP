//
//  HMCommonScene.m
//  HomeMateSDK
//
//  Created by liuzhicai on 16/9/29.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMCommonScene.h"
#import "HMConstant.h"


@implementation HMCommonScene

+(NSString *)tableName
{
    return @"commonScene";
}
+ (NSArray*)columns
{
    return @[column("roomId","text"),
             column("sceneNo","text"),
             column("userId","text"),
             column("sortNum","integer")
             ];
    
}

+ (NSString*)constrains
{
    return @"UNIQUE(roomId, sceneNo) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from commonScene where sceneNo = '%@' and roomId = '%@' and userId = '%@'",self.sceneNo,self.roomId,self.userId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (NSArray *)commonSceneWithRoomId:(NSString *)roomId {
    if (!roomId) {
        roomId = @"";
    }
    NSString *userId = userAccout().userId;
    NSString *sql = [NSString stringWithFormat:@"select s.*,c.sortNum from scene s, commonScene c where s.familyId = '%@' and s.delFlag = 0 and s.sceneNo = c.sceneNo and c.roomId = '%@' and c.userId = '%@' order by sortNum asc",userAccout().familyId,roomId,userId];
    
    __block NSMutableArray *sceneArr;
    queryDatabase(sql,^(FMResultSet *rs){
        if (!sceneArr) {
            sceneArr = [NSMutableArray array];
        }
        HMScene *scene = [HMScene object:rs];
        [sceneArr addObject:scene];
    });
    
    NSArray *allScene = [HMSceneExtModel readAllSceneArray];
    NSArray *sceneNoArr = [allScene valueForKey:@"sceneNo"];
    
//    DLog(@"sceneNoArr : %@",sceneNoArr);
    [sceneArr filterUsingPredicate:[NSPredicate predicateWithFormat:@"self.sceneNo in %@",sceneNoArr]];
    return sceneArr;
}

+ (BOOL)deleteCommonSceneWithRoomId:(NSString *)roomId {
    if (!roomId) {
        roomId = @"";
    }
    NSString *sql = [NSString stringWithFormat:@"delete from commonScene where roomId = '%@'",roomId];
    BOOL result = [self executeUpdate:sql];
    return result;
}
@end
