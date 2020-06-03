//
//  SetFrequentlyModeCmd.m
//  
//
//  Created by Air on 15/12/4.
//
//

#import "SetFrequentlyModeCmd.h"

@implementation SetFrequentlyModeCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SFM;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.frequentlyModeId forKey:@"frequentlyModeId"];
    
    //if (self.name) {
        [sendDic setObject:self.name forKey:@"name"];
    //}
    //if (self.order) {
        [sendDic setObject:self.order forKey:@"order"];
        [sendDic setObject:@(self.value1) forKey:@"value1"];
        [sendDic setObject:@(self.value2) forKey:@"value2"];
        [sendDic setObject:@(self.value3) forKey:@"value3"];
        [sendDic setObject:@(self.value4) forKey:@"value4"];
        [sendDic setObject:@(self.pic) forKey:@"pic"];
        [sendDic setObject:@(self.type) forKey:@"type"];
    //}
    
    return sendDic;
}

@end
