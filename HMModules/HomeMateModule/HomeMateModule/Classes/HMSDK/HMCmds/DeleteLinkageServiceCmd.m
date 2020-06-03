//
//  DeleteLinkageServiceCmd.m
//  HomeMate
//
//  Created by Air on 15/10/13.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "DeleteLinkageServiceCmd.h"

@implementation DeleteLinkageServiceCmd

- (VIHOME_CMD)cmd {
    return VIHOME_CMD_LINKAGE_SERVICE_DELETE;
}

- (NSDictionary *)payload {
    [sendDic setObject:self.linkageId forKey:@"linkageId"];
    return sendDic;
}

- (BOOL)sendToServer {

    return YES;
}

- (NSString *)uid {
    return nil;
}

- (BOOL)onlySendOnce {

    return YES;
}
@end
