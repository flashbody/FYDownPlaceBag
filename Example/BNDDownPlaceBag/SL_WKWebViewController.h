 

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "SL_SDKRepositoryApi.h"
 
@class WebViewJavascriptBridge;

/**
 
 注: 本H5加载工具提供加载网页基础事例, 具体加载功能, 请各业务线继承该工具后, 扩展各自业务使用 或者参考自行实现
    各业务线如有扩展需求疑问或技术难点, 可联系QQ-2062906281 或者IM群 联系-吴生强
 
    本工具可直接加载H5资源包的路由格式:
    范例 (收货地址): #/myAddress?key1=value1&key2=value2 (根据前端同事确认的标准格式)
    如加载其他路由格式, 请自行扩展
 
 */
@interface SL_WKWebViewController : UIViewController

//网页加载工具
@property (nonatomic, strong)WKWebView* webview;
//H5包名
@property (nonatomic, strong)NSString* packageName;
//本地h5文件夹名
@property (nonatomic, strong)NSString* localPackageName;
//网页地址,外链
@property (nonatomic, strong)NSString* remoteString;
//加载项目本地h5(H5对应子页面路由, 各业务线自行定制)
@property (nonatomic, strong)NSString* localPageName;
//加载远程下载H5资源包(H5对应子页面路由, 各业务线自行定制)
@property (nonatomic, strong)NSString* remotePageName;
//交互桥梁
@property (nonatomic, strong)WebViewJavascriptBridge* webBridge;
//注册交互方法
@property (nonatomic, strong)SL_H5SDKManager* H5SDKManager;




//初始化
- (void)setUI;


- (void)dealloc;

//加载外链网页
- (void)lodeRemoteUrl;

//加载本地H5
- (void)lodeLocalPageName;

//加载下载的H5包
- (void)lodeRemotePageName;



@end

