//
//  VihomeScene.m
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMScene.h"
#import "HMConstant.h"

@implementation HMScene

+ (NSString *)tableName {
    
    return @"scene";
}

+ (NSArray *)columns {

    return @[column("sceneNo","text"),
             column("familyId","text"),
             column("sceneName","text"),
             column("roomId", "text"),
             column("onOffFlag","integer"),
             column("sceneId","integer"),
             column("groupId","integer"),
             column("pic","integer"),
             column("imgUrl","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer"),
             ];

}

+ (NSArray<NSDictionary *>*)newColumns {
    return  @[column("imgUrl","text default ''")];
}

+ (NSString *)constrains {

    return @"UNIQUE (sceneNo, familyId) ON CONFLICT REPLACE";
}

+ (BOOL)createTrigger {
    // 先删除旧的触发器，再创建新的触发器
    [self executeUpdate:@"DROP TRIGGER if exists delete_scene_sequence"];
    [self executeUpdate:@"DROP TRIGGER if exists delete_scene"];
    
    BOOL result = [self executeUpdate:@"CREATE TRIGGER if not exists delete_scene BEFORE DELETE ON scene for each row"
                   " BEGIN "
                   "DELETE FROM sceneBind where sceneNo = old.sceneNo;"
                   
                   "END"];

    return result;
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


- (void)prepareStatement {
    if (!self.createTime) {
        self.createTime = self.updateTime;
    }

    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
}

- (BOOL)deleteObject {

    // 先删除绑定
    NSString * delBindSql = [NSString stringWithFormat:@"delete from sceneBind where sceneNo = '%@'",self.sceneNo];
    updateInsertDatabase(delBindSql);
    
    // 删除情景本身
    NSString * sql = [NSString stringWithFormat:@"delete from scene where sceneNo = '%@'",self.sceneNo];
    // 删除常用情景排序
     NSString * commonScenesql = [NSString stringWithFormat:@"delete from commonScene where sceneNo = '%@'",self.sceneNo];
    updateInsertDatabase(commonScenesql);

    
   
    BOOL deleteTiming = YES;
#if defined (__Wistar__) || defined(__NVCLighting__)
    // 删除情景定时
    NSString * deleteSql = [NSString stringWithFormat:@"delete from timing where bindOrder = 'scene control' and value1 = %d",self.sceneId];
   deleteTiming = [self executeUpdate:deleteSql];
#endif
    
    BOOL result = [self executeUpdate:sql];
    return result && deleteTiming;
}

- (NSDictionary *)dictionaryFromObject {

    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.sceneNo forKey:@"sceneNo"];
    [dic setObject:self.sceneName forKey:@"sceneName"];
    [dic setObject:self.roomId forKey:@"roomId"];
    [dic setObject:userAccout().userId forKey:@"userId"];
    [dic setObject:[NSNumber numberWithInt:self.onOffFlag] forKey:@"onOffFlag"];
    [dic setObject:[NSNumber numberWithInt:self.sceneId] forKey:@"sceneId"];
    [dic setObject:[NSNumber numberWithInt:self.groupId] forKey:@"groupId"];
    [dic setObject:[NSNumber numberWithInt:self.pic] forKey:@"pic"];
    [dic setObject:self.updateTime forKey:@"updateTime"];
    [dic setObject:[NSNumber numberWithInt:self.delFlag] forKey:@"delFlag"];
    [dic setObject:userAccout().familyId forKey:@"familyId"];
    [dic setObject:self.imgUrl forKey:@"imageUrl"];
    return dic;
}

- (id)copyWithZone:(NSZone *)zone {

    HMScene *object = [[HMScene alloc]init];
    object.sceneNo = self.sceneNo;
    object.sceneName = self.sceneName;
    object.roomId = self.roomId;
    object.onOffFlag = self.onOffFlag;
    object.sceneId = self.sceneId;
    object.groupId = self.groupId;
    object.pic = self.pic;
    object.updateTime = self.updateTime;
    object.delFlag = self.delFlag;
    object.initialPic = self.pic;
    object.initialName = self.sceneName;
    object.userId = userAccout().userId;
    object.familyId = userAccout().familyId;
    object.imgUrl = self.imgUrl;
    return object;
}

- (BOOL)changed {

    if ((![self.initialName isEqualToString:self.sceneName])       // 名称发生变化
        || (self.initialPic != self.pic)) {             // 图标发生变化
        return YES;
    }
    return NO;
}

+ (NSArray *)allScenesArr {
    
    __block NSMutableArray *sceneArr;
    {//查询家庭下的全开全关情景

        NSString *allCloseOpenSql = [NSString stringWithFormat:@"select * from scene where delFlag = 0 and familyId = '%@' and onOffFlag in (1, 0) order by onOffFlag DESC",userAccout().familyId];

        queryDatabase(allCloseOpenSql, ^(FMResultSet *rs) {
            if (!sceneArr) {
                sceneArr = [[NSMutableArray alloc] init];
            }
            HMScene *scene = [HMScene object:rs];
            
            [sceneArr addObject:scene];
        });
    }
    
    NSString *sql = [NSString stringWithFormat:@"select * from scene where delFlag = 0 and familyId = '%@' and onOffFlag not in (1,0) order by createTime asc",userAccout().familyId];

    queryDatabase(sql, ^(FMResultSet *rs) {
        if (!sceneArr) {
            sceneArr = [[NSMutableArray alloc] init];
        }
        HMScene *scene = [HMScene object:rs];

        [sceneArr addObject:scene];
    });
    return sceneArr;
}


+ (HMScene *)readSceneWithSceneNo:(NSString *)sceneNo {

    NSString *sql = [NSString stringWithFormat:@"select * from scene where delFlag = 0 and familyId = '%@' and sceneNo = '%@'",userAccout().familyId, sceneNo];

    __block HMScene *scene;
    queryDatabase(sql, ^(FMResultSet *rs) {
        scene = [HMScene object:rs];
        
    });
    return scene;
}

- (NSString *)picName {
    int pic = self.pic;
    
    if (pic < 0 || pic > 11) {//美居同步过来的情景可能为-1
        pic = 11;
    }
    
    if(self.onOffFlag == 0){
        return @"scene_icon_10";
    }else if(self.onOffFlag == 1){
        return @"scene_icon_9";
    }
    return [NSString stringWithFormat:@"scene_icon_%d", pic];
}

+ (NSArray *)getSceneBindHostUIDsWithSceneNo:(NSString *)sceneNo {

    NSString *sql = [NSString stringWithFormat:@"select t.uid from (select DISTINCT uid from sceneBind where sceneNo = '%@' and delFlag = 0 and length(uid)) t left join gateway on t.uid = gateway.uid where (model like '%%%@%%' or model like '%%%@%%' or model in (%@))",sceneNo,kViHomeModel,kHubModel,HostModelIDs()];

    __block NSMutableArray *array = [NSMutableArray array];
    queryDatabase(sql, ^(FMResultSet *rs) {
        NSString *uid = [rs stringForColumn:@"uid"];
        if (uid) {
            [array addObject:uid];
        }
    });
    return array;
}


-(NSArray<NSString *> *)zigbeeHostUidArray
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    if (self.onOffFlag == 0 || self.onOffFlag == 1) { // 情景为全开或者全关, 则查询当前家庭下的所有主机
        
        NSArray *bindArray = [HMUserGatewayBind zigbeeHostBindArray];
        NSArray *uids = [bindArray valueForKey:@"uid"];
        NSSet *set = [NSSet setWithArray:uids];
        [array setArray:[set allObjects]];
        
        DLog(@"全开全关情景，familyId=%@ uid:%@",userAccout().familyId,uids);
        
    } else {    // 其他情景则查询情景绑定的设备所在的主机
        NSArray *uidArray = [HMScene getSceneBindHostUIDsWithSceneNo:self.sceneNo];
        [array setArray:uidArray];
        
        DLog(@"普通情景，familyId=%@ uid:%@",userAccout().familyId,uidArray);
    }
    
    return array;
}
@end
