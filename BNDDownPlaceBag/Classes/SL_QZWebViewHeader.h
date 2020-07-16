//
//  SL_QZWebViewHeader.h
//  SL_H5ComponentLibrary
//
//  Created by until on 2020/1/13.
//

#ifndef SL_QZWebViewHeader_h
#define SL_QZWebViewHeader_h

// Pods - target - SL_H5ComponentLibrary - buildSetting---Allow Non-modular Includes In Framework Modules 这个值  改为YES.

//#import "WebViewJavascriptBridge.h"
//#import "SL_H5SDKManager.h"
//#import "SL_ApplicationWillEnterForeground.h"
//#import "SL_H5ParametersValidation.h"
#import "Masonry.h"
#import "SVProgressHUD.h"

//H5资源解压文件存放路径
#define SL_QZH5ZipFileBasePath   @"Documents/appPage"
//H5资源下载存放的路径
#define SL_QZH5ZipFileCachePath   @"Documents/cache/appPage"

#define SL_QZAcceptTypes [NSSet setWithObjects:@"application/json", @"application/x-www-form-urlencoded",@"text/json", @"text/javascript",@"text/html",@"text/plain", nil]







#endif
