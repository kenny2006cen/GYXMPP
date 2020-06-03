//
//  ModifySceneServiceCmd.m
//  HomeMateSDK
//
//  Created by orvibo on 2017/1/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ModifySceneServiceCmd.h"

@implementation ModifySceneServiceCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SCENE_SERVICE_MODIFY;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.sceneNo forKey:@"sceneNo"];
    [sendDic setObject:self.sceneName forKey:@"sceneName"];
    [sendDic setObject:[NSNumber numberWithInt:self.pic] forKey:@"pic"];
    [sendDic setObject:self.imgUrl forKey:@"imgUrl"];
    return sendDic;
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

@end
