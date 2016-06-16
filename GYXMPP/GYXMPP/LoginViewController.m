//
//  LoginViewController.m
//  GYXMPP
//
//  Created by User on 16/6/16.
//  Copyright © 2016年 jianglincen. All rights reserved.
//

#import "LoginViewController.h"
#import "GYXMPP.h"

#import "MessageListViewController.h"

@interface LoginViewController ()<UITableViewDataSource,UITableViewDelegate,GYXMPPDelegate>{
    
}
/*
 消息列表
 */
@property (nonatomic, strong) UITableView *tableView;
/**
 *数据源数组
 */
@property(nonatomic, strong) NSMutableArray *messageArray;


@end

@implementation LoginViewController

- (NSMutableArray *)messageArray
{
    if (!_messageArray) {
        _messageArray = [NSMutableArray array];
    }
    return _messageArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
   
}




- (IBAction)loginAction:(id)sender {
    
//#define WS(weakSelf) __weak __typeof(self) weakSelf = self;

    __weak __typeof(self) weakSelf = self;
    
  
    MessageListViewController *ctrol =[[MessageListViewController alloc]init];
    
    [weakSelf.navigationController pushViewController:ctrol animated:YES];
   
    

}


@end
