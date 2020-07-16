//
//  SL_QZH5Manage.h
//  SL_H5ComponentLibrary
//
//  Created by until on 2020/1/10.
//

#import <Foundation/Foundation.h>
//#import "SL_QZWKWebViewController.h"
typedef enum : NSUInteger {
    //下载失败
    SL_QZH5LoadFail             = 0,
    //下载中
    SL_QZH5LoadProcess          = 1,
    //下载成功
    SL_QZH5LoadSuccess          = 2
    
} SL_QZH5LoadState;  //下载状态


typedef void(^SL_QZH5ManageDownloadH5Block)(BOOL loadResult);

typedef void(^SL_QZH5ManageH5Block)(BOOL result);

typedef void(^SL_QZH5ManageCheckLoadingH5Block)(SL_QZH5LoadState state, CGFloat progress);

typedef void(^SL_QZH5ManageH5TicketBlock)(BOOL result, NSString* ticket);


@interface SL_QZH5Manage : NSObject

@property (nonatomic, copy)SL_QZH5ManageCheckLoadingH5Block resultBlock;

@property (nonatomic, strong)NSString* loadPageName;

+ (instancetype)manage;

/// 下载H5资源包 Zip包
/// @param url 下载地址
/// @param packageName 包名(自定义, 方便存取)
/// @param loadResult 下载结果 YES / NO
- (void)sl_QZDownloadWebZipDataWithUrl:(NSString* )url andPackageName:(NSString* )packageName andCompetetion:(SL_QZH5ManageDownloadH5Block)loadResult;


/// 请求H5信息
/// @param url 接口
/// @param header 请求头
/// @param parameters 请求体
/// @param method 请求方式 GET / POST (目前服务端GET)
/// @param packageName H5的包名
/// @param result 返回值 YES成功, NO失败
- (void)sl_QZLoadH5PackageWithUrl:(NSString* )url header:(NSDictionary* )header parameters:(id)parameters method:(NSString *)method andPackageName:(NSString* )packageName andCompetetion:(SL_QZH5ManageH5Block)result;


/// 获取指定包名的H5下载状态, 下载中, 下载失败显示本地包
/// @param packageName 包名
- (SL_QZH5LoadState)loadingState:(NSString* )packageName;



/// 监测H5下载状态回调 , 实时监测, 有结果回调, 进度显示
/// @param packageName 包名
/// @param resultBlock 回调
- (void)slCheckLoadingState:(NSString* )packageName andBlock:(SL_QZH5ManageCheckLoadingH5Block)resultBlock;



/// 获取ticket
/// @param url 接口
/// @param header 请求头
/// @param parameters 请求体
/// @param method 请求方式 GET / POST
/// @param ticketBlock 返回值
//- (void)slGetTicketWithUrl:(NSString* )url header:(NSDictionary* )header parameters:(id)parameters method:(NSString *)method andCompetetion:(SL_QZH5ManageH5TicketBlock)ticketBlock;





@end

