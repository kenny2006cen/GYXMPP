//
//  DeleteSceneServiceCmd.m
//  HomeMateSDK
//
//  Created by orvibo on 2017/1/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "DeleteSceneServiceCmd.h"

@implementation DeleteSceneServiceCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SCENE_SERVICE_DELETE;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.sceneNo forKey:@"sceneNo"];
    
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
