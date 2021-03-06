//
//  SL_QZWKWebViewController.m
//  SL_H5ComponentLibrary
//
//  Created by until on 2020/1/13.
//

#import "SL_WKWebViewController.h"
#import "WebViewJavascriptBridge.h"
#import "SL_SDKRepositoryApi.h"
#import "BNDDownPlaceBag.h"
@interface SL_WKWebViewController ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler,SL_H5SDKManagerDelegate>
 



@end

@implementation SL_WKWebViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    [self setUI];
    
}


- (void)setUI
{
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    config.preferences.javaScriptEnabled = YES;
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];

    config.userContentController = userContentController;

    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    config.preferences = preferences;
 
    [config.preferences setValue:@(YES) forKey:@"allowFileAccessFromFileURLs"];
    config.preferences.javaScriptEnabled = YES;
    if (@available(iOS 10.0, *)) {
        [config setValue:@YES forKey:@"allowUniversalAccessFromFileURLs"];
    }
    _webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) configuration:config];
    _webview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_webview];

    _webview.UIDelegate = self;
    _webview.navigationDelegate = self;
    _webview.allowsBackForwardNavigationGestures = YES;

    if(@available(iOS 11.0, *)) {
        _webview.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

    if (!_webBridge) {
        _webBridge = [WebViewJavascriptBridge bridgeForWebView:self.webview];
    }

    self.H5SDKManager.webBridge = _webBridge;
    [_webBridge setWebViewDelegate:self];
    [self.H5SDKManager h5BridgeWithWebView:self.webview];
    self.H5SDKManager.delegate = self;
    
    
}

//SL_SDKRepository????????????
- (void)dealloc{
    [self.H5SDKManager h5SDKClearData]; //??????????????????
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


//????????????,??????
- (void)setRemoteString:(NSString *)remoteString
{
    _remoteString = remoteString;
    
    if (remoteString) {
        [self lodeRemoteUrl];
    }
}

//????????????h5
- (void)setLocalPageName:(NSString *)localPageName
{
    _localPageName = localPageName;
    if (localPageName) {

        [self lodeLocalPageName];
    }
}

//????????????H5?????????
- (void)setRemotePageName:(NSString *)remotePageName
{
    _remotePageName = remotePageName;
    if (remotePageName) {

        [self lodeRemotePageName];
    }
}

- (void)lodeRemoteUrlTicket
{
    
//    [[AFNWorkingTool sharedTool] requestWithURL:QZThirdPartyTicketURL parameters:@{@"aUserId":[NSString qzStringWith:[XSCUserManager shareManager].currentUserId], @"clientIdSign":[NSString qzStringWith:channel],@"data":@{@"companyId":[NSString qzStringWith:[XSCUserManager shareManager].currentUser.organId],@"channel":@"xsc"}} method:@"POST" competetion:^(NSDictionary* resonseObject) {

//        NSLog(@"%@",resonseObject);
//        if (resonseObject && [resonseObject[@"status"] integerValue] == 200) {
//
//            NSString* ticket = resonseObject[@"data"][@"ticket"];
//            NSString* sendUrl = [NSString stringWithFormat:@"%@ticket=%@%@",url,ticket,lastParame];
//
//            SSM_QZWKWebViewController* webview = [SSM_QZWKWebViewController new];
//            webview.hidesBottomBarWhenPushed = YES;
//            webview.remoteUrl = [NSURL URLWithString:sendUrl];
//
//            [self.viewController.navigationController pushViewController:webview animated:YES];
//        }
//
//    }];
    
    
}

//??????????????????
- (void)lodeRemoteUrl
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.remoteString]];

    [self.webview loadRequest:request];
}


//????????????H5
- (void)lodeLocalPageName{

    //H5??????????????????????????????????????????LocalHtmlName (???????????????)
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:self.localPackageName];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    if (baseURL == nil) {
        //??????????????????????????????
        return;
    }

    baseURL = [NSURL URLWithString:self.localPageName relativeToURL:baseURL];

    [self.webview loadRequest:[NSURLRequest requestWithURL:baseURL]];


}

//???????????????H5???
- (void)lodeRemotePageName
{
     NSString* firstUrl = [NSString stringWithFormat:@"%@/%@/%@/index.html",NSHomeDirectory(),BNDDPBH5ZipFileBasePath,self.packageName];
    
     NSURL* secondUrl = [NSURL fileURLWithPath:firstUrl];

     NSURL* requestUrl = [NSURL URLWithString:self.remotePageName relativeToURL:secondUrl];

     NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:requestUrl];

     [self.webview loadFileURL:request.URL allowingReadAccessToURL:request.URL.URLByDeletingLastPathComponent];

}


//?????????
- (SL_H5SDKManager *)H5SDKManager{
    if (!_H5SDKManager) {
        _H5SDKManager = [[SL_H5SDKManager alloc] init];
    }
    return _H5SDKManager;
}




@end
