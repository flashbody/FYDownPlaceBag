//
//  SL_QZTestViewController.m
//  SL_H5ComponentLibrary_Example
//
//  Created by until on 2020/1/13.
//  Copyright © 2020 QJwsq. All rights reserved.
//

#import "SL_TestViewController.h"
#import "BNDDownPlaceBag.h"
#import "SL_SDKRepositoryApi.h"

@interface SL_TestViewController ()

@end

@implementation SL_TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    

}

- (void)setUI
{
    [super setUI];

    [self.H5SDKManager.webBridge registerHandler:@"slGetUserInfoAction" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(@{@"success":@(NO),@"status":@(NO),@"msg":@"失败",@"data":@{}});
    }];
    
}



@end
