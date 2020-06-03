//
//  AddSceneServiceCmd.m
//  HomeMateSDK
//
//  Created by orvibo on 2017/1/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "AddSceneServiceCmd.h"

@implementation AddSceneServiceCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SCENE_SERVICE_CREATE;
}

-(BOOL)sendToServer{

    return YES;
}

-(NSString *)uid{

    return nil;
}

-(BOOL)onlySendOnce{

    return YES;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.sceneName forKey:@"sceneName"];
    [sendDic setObject:[NSNumber numberWithInt:self.pic] forKey:@"pic"];
    [sendDic setObject:self.familyId forKey:@"familyId"];
    return sendDic;
}

@end
