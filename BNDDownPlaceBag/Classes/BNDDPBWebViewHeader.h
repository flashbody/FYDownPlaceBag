

#ifndef BNDDPBWebViewHeader_h
#define BNDDPBWebViewHeader_h

// Pods - target - SL_H5ComponentLibrary - buildSetting---Allow Non-modular Includes In Framework Modules 这个值  改为YES.

//#import "WebViewJavascriptBridge.h"
//#import "SL_H5SDKManager.h"
//#import "SL_ApplicationWillEnterForeground.h"
//#import "SL_H5ParametersValidation.h"
#import "Masonry.h"
#import "SVProgressHUD.h"

//H5资源解压文件存放路径
#define BNDDPBH5ZipFileBasePath   @"Documents/appPage"
//H5资源下载存放的路径
#define BNDDPBH5ZipFileCachePath   @"Documents/cache/appPage"

#define BNDDPBAcceptTypes [NSSet setWithObjects:@"application/json", @"application/x-www-form-urlencoded",@"text/json", @"text/javascript",@"text/html",@"text/plain", nil]







#endif
