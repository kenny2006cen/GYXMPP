//
//  EnableSceneServiceCmd.m
//  HomeMateSDK
//
//  Created by orvibo on 2017/1/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "EnableSceneServiceCmd.h"

@implementation EnableSceneServiceCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SCENE_SERVICE_EXECUTE;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.userName forKey:@"userName"];
    [sendDic setObject:self.sceneNo forKey:@"sceneNo"];
    return sendDic;
}
-(BOOL)sendToServer{
    
    return YES;
}

@end
