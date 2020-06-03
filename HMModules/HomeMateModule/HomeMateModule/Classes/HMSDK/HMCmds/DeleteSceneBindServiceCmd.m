//
//  DeleteSceneBindServiceCmd.m
//  HomeMateSDK
//
//  Created by orvibo on 2017/1/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "DeleteSceneBindServiceCmd.h"

@implementation DeleteSceneBindServiceCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SCENE_SERVICE_DELETE_BIND;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.userName forKey:@"userName"];
    [sendDic setObject:self.sceneNo forKey:@"sceneNo"];
    [sendDic setObject:self.sceneBindList forKey:@"sceneBindList"];
    return sendDic;
}
-(BOOL)sendToServer{
    
    return YES;
}
@end
