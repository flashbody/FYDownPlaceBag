//
//  BNDDPBViewController.m
//  BNDDownPlaceBag
//
//  Created by yfs on 07/11/2020.
//  Copyright (c) 2020 yfs. All rights reserved.
//

#import "BNDDPBViewController.h"
#import "BNDDownPlaceBag.h"
#import "SL_QZTestViewController.h"

@interface BNDDPBViewController ()

@end

@implementation BNDDPBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	//下载资源包Zip, app启动时调用
    [[BNDDPBH5Manage manage] BNDDPBLoadH5PackageWithUrl:@"https://beta.shanglike.com/bnd-admin/v1/version/h5" header:nil parameters:@{@"packageName" :@"com.bonade.h5.mall"} method:@"GET" andPackageName:@"com.bonade.h5.mall" andCompetetion:^(BOOL result) {
        if (result) {
            //下载解压成功
            NSLog(@"=======");
        }else
        {
            //失败
        }
        
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self presentVC];
    return;
    [[BNDDPBH5Manage manage] slCheckLoadingState:@"com.bonade.h5.mall" andBlock:^(BNDDPBH5LoadState state, CGFloat progress) {
        if (state == BNDDPBH5LoadSuccess) {
            //下载成功, 加载最新页面
            //            NSLog(@"//#");
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self presentVC];
                        });
//            [self presentVC];
        }else if(state == BNDDPBH5LoadProcess){
            //下载中, 显示进度条
            NSLog(@"(com.bonade.h5.mall)===%.2f",progress);
        }else{
            // 下载失败
            
        }
    }];
     
}

- (void)presentVC
{
    SL_QZTestViewController* vc = [SL_QZTestViewController new];
    
    [self presentViewController:vc animated:YES completion:nil];
    
    vc.packageName = @"com.bonade.h5.mall";
    vc.remotePageName = @"#/timeLimit?channel=xsc";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
