

#import "BNDDPBH5Manage.h"
#import "AFNetworking.h"
#import "SSZipArchive/SSZipArchive.h"

@implementation BNDDPBH5Manage

+ (instancetype)shareManager
{
    static BNDDPBH5Manage* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BNDDPBH5Manage alloc] init];
    });
    return instance;
}

- (void)YFSKingBNDDPBLoadH5PackageWithUrl:(NSString *)url header:(NSDictionary *)header parameters:(id)parameters method:(NSString *)method andPackageName:(NSString *)packageName andVersionCompetetion:(BNDDPBH5ManageH5VersionBlock)result{
    AFHTTPSessionManager* manager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = BNDDPBAcceptTypes;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    if (header) {
        NSArray* keyArray = header.allKeys;
        for (NSString* key in keyArray) {
            [manager.requestSerializer setValue:[self BNDDPBStringWith:header[key]] forHTTPHeaderField:[self BNDDPBStringWith:key]];
        }
    }
    
    NSString* requestUrl = [[self BNDDPBStringWith:url] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    if ([method isEqualToString:@"POST"]) {
        [manager POST:requestUrl parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *resdict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if (resdict && resdict[@"data"] && [resdict[@"data"] isKindOfClass:[NSArray class]]) {
                NSArray * inforArray = resdict[@"data"];
                if (inforArray.count >0) {
                    NSDictionary* infoDict = inforArray.lastObject;
                    // 支持的APP版本号 appVersion
                    NSString * appVersion = [NSString stringWithFormat:@"%@", infoDict[@"appVersion"]];
                    //服务器H5版本号
                    NSString* h5Version = [self BNDDPBStringWith:infoDict[@"h5Version"]];
                    //服务器Zip下载链接
                    NSString* h5Link = [self BNDDPBStringWith:infoDict[@"h5Link"]];
                    //本地H5版本号
                    NSArray* localArr = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
//                    if (self.isLog) {
//                        NSLog(@"服务器H5版本号==%@,,,下载地址===%@", h5Version,h5Link);
//                    }
                    NSMutableArray* remoteArray = [NSMutableArray arrayWithArray:[h5Version componentsSeparatedByString:@"."]];
//                    NSString* remoteIndex = @"";
//                    for (NSInteger i = 0; i < h5Version.length; i ++) {
//                        remoteIndex = [h5Version substringWithRange:NSMakeRange(i, 1)];
//                        if ([self stringIsNumber:remoteIndex]) {
//                            [remoteArray addObject:remoteIndex];
//                        }
//                    }
                    // 判断APP版本，空值通用，小于和等于才能进行下载。
                    BOOL isload = false;
                    NSArray * appArray = [appVersion componentsSeparatedByString:@"."];
                    // 获取当前App的基本信息字典
                    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

                    //app名称
//                        NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];

                    // app版本
                    NSString *sysVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
                    
                    if ([sysVersion isEqualToString:appVersion] || ![sysVersion isEqualToString:appVersion]) {
                        if ([appVersion isEqualToString:@""]) {
                            isload = true;
                        }else{
                            
                            
                            if ([sysVersion isEqualToString:appVersion]) {
                                isload = true;
                            }else{
                                isload = false;
                            }
    //                        NSArray * sysArray = [sysVersion componentsSeparatedByString:@"."];
    //
    //                        for (NSInteger  i= 0; i < sysArray.count; i++) {
    //                            if (appArray.count > i) {
    //                                if ([appArray[i] integerValue] > [sysArray[i] integerValue]) {
    //                                    isload = false;
    //                                    break;
    //                                }else{
    //                                    isload = true;
    //
    //                                }
    //                            }else{
    //                                isload = true;
    //                            }
    //
    //                        }
                        }
                        if (localArr == nil && isload) {
                            #pragma mark 需要下载
                            //下载中
                            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                            [self BNDDPBDownloadWebZipDataWithUrl:h5Link andPackageName:packageName andCompetetion:^(BOOL loadResult) {
                                if (loadResult) {
                                    //下载成功
                                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                    [[NSUserDefaults standardUserDefaults] setObject:remoteArray forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                    if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                        self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                                    }
                                }else
                                {
                                    //下载失败
                                    [[NSUserDefaults standardUserDefaults] setObject:@"-1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                    [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                    if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                        self.resultBlock(BNDDPBH5LoadFail, 0.0);
                                    }
                                }
                                
                                result(loadResult,h5Version);
                            }];
                            
                            
                        }else
                        {
                            NSMutableArray* localArray = [[NSMutableArray alloc] initWithArray:localArr];
                            
                            //判断远程h5是否需要下载
                            if (remoteArray.count < localArray.count) {
                                for (NSInteger i = remoteArray.count; i < localArray.count; i ++) {
                                    [remoteArray addObject:@"0"];
                                }
                            }else if (remoteArray.count > localArray.count)
                            {
                                for (NSInteger i = localArray.count; i < remoteArray.count; i ++) {
                                    [localArray addObject:@"0"];
                                }
                            }
                            
                            for (NSInteger i = 0; i < remoteArray.count; i ++) {
                                NSString* remoteNum = remoteArray[i];
                                NSString* localNum = localArray[i];
                                
                                if ([remoteNum integerValue] > [localNum integerValue]) {
                                    #pragma mark 需要下载
                                    //下载中
                                    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                    [self BNDDPBDownloadWebZipDataWithUrl:h5Link andPackageName:packageName andCompetetion:^(BOOL loadResult) {
                                        if (loadResult) {
                                            //下载成功
                                            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                            [[NSUserDefaults standardUserDefaults] setObject:remoteArray forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                            if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                                self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                                            }
                                        }else
                                        {
                                            //下载失败
                                            [[NSUserDefaults standardUserDefaults] setObject:@"-1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                            [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                            if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                                self.resultBlock(BNDDPBH5LoadFail, 0.0);
                                            }
                                        }
                                        
                                        result(loadResult,h5Version);
                                    }];
                                    
                                    return ;
                                }else if ([remoteNum integerValue] < [localNum integerValue])
                                {
                                    //无需下载, 停止判断
                                    if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                        self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                                    }
                                    result(YES,h5Version);
                                    return ;
                                }
                            }
                            if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                            }
                            result(YES,h5Version);
                            
                        }
                    
                    }else
                    {
                        if (result) {
                            result(false,@"");
                        }
                    }
                    
                }else
                {
                    if (result) {
                        result(false,@"");
                    }
                }
 
                
                
            }else
            {
                if (result) {
                    result(false,@"");
                }
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           if (result) {
               result(false,@"");
           }
        }];
 
    }else
    {
       
        [manager GET:requestUrl parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *resdict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                if (resdict && resdict[@"data"] && [resdict[@"data"] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary* infoDict = resdict[@"data"];
                    // 支持的APP版本号 appVersion
                    NSString * appVersion = [NSString stringWithFormat:@"%@", infoDict[@"appVersion"]];
                    //服务器H5版本号
                    NSString* h5Version = [self BNDDPBStringWith:infoDict[@"h5Version"]];
                    //服务器Zip下载链接
                    NSString* h5Link = [self BNDDPBStringWith:infoDict[@"h5Link"]];
                    //本地H5版本号
                    NSArray* localArr = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
//                    if (self.isLog) {
//                        NSLog(@"服务器H5版本号==%@,,,下载地址===%@", h5Version,h5Link);
//                    }
                    NSMutableArray* remoteArray = [NSMutableArray arrayWithArray:[h5Version componentsSeparatedByString:@"."]];
//                    NSString* remoteIndex = @"";
//                    for (NSInteger i = 0; i < h5Version.length; i ++) {
//                        remoteIndex = [h5Version substringWithRange:NSMakeRange(i, 1)];
//                        if ([self stringIsNumber:remoteIndex]) {
//                            [remoteArray addObject:remoteIndex];
//                        }
//                    }
                    // 判断APP版本，空值通用，小于和等于才能进行下载。
                    BOOL isload = false;
                    if ([appVersion isEqualToString:@""]) {
                        isload = true;
                    }else{
                        NSArray * appArray = [appVersion componentsSeparatedByString:@"."];
                        // 获取当前App的基本信息字典
                        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

                        //app名称
//                        NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];

                        // app版本
                        NSString *sysVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];

                        if ([sysVersion isEqualToString:appVersion]) {
                            isload = true;
                        }else{
                            isload = false;
                        }
//                        NSArray * sysArray = [sysVersion componentsSeparatedByString:@"."];
//
//                        for (NSInteger  i= 0; i < sysArray.count; i++) {
//                            if (appArray.count > i) {
//                                if ([appArray[i] integerValue] > [sysArray[i] integerValue]) {
//                                    isload = false;
//                                    break;
//                                }else{
//                                    isload = true;
//
//                                }
//                            }else{
//                                isload = true;
//                            }
//
//                        }
                    }
                    if (localArr == nil && isload) {
                        #pragma mark 需要下载
                        //下载中
                        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                        [self BNDDPBDownloadWebZipDataWithUrl:h5Link andPackageName:packageName andCompetetion:^(BOOL loadResult) {
                            if (loadResult) {
                                //下载成功
                                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                [[NSUserDefaults standardUserDefaults] setObject:remoteArray forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                    self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                                }
                            }else
                            {
                                //下载失败
                                [[NSUserDefaults standardUserDefaults] setObject:@"-1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                    self.resultBlock(BNDDPBH5LoadFail, 0.0);
                                }
                            }
                            
                            result(loadResult,h5Version);
                        }];
                        
                        
                    }else
                    {
                        NSMutableArray* localArray = [[NSMutableArray alloc] initWithArray:localArr];
                        
                        //判断远程h5是否需要下载
                        if (remoteArray.count < localArray.count) {
                            for (NSInteger i = remoteArray.count; i < localArray.count; i ++) {
                                [remoteArray addObject:@"0"];
                            }
                        }else if (remoteArray.count > localArray.count)
                        {
                            for (NSInteger i = localArray.count; i < remoteArray.count; i ++) {
                                [localArray addObject:@"0"];
                            }
                        }
                        
                        for (NSInteger i = 0; i < remoteArray.count; i ++) {
                            NSString* remoteNum = remoteArray[i];
                            NSString* localNum = localArray[i];
                            
                            if ([remoteNum integerValue] > [localNum integerValue]) {
                                #pragma mark 需要下载
                                //下载中
                                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                [self BNDDPBDownloadWebZipDataWithUrl:h5Link andPackageName:packageName andCompetetion:^(BOOL loadResult) {
                                    if (loadResult) {
                                        //下载成功
                                        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                        [[NSUserDefaults standardUserDefaults] setObject:remoteArray forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                        if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                            self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                                        }
                                    }else
                                    {
                                        //下载失败
                                        [[NSUserDefaults standardUserDefaults] setObject:@"-1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                        [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                        if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                            self.resultBlock(BNDDPBH5LoadFail, 0.0);
                                        }
                                    }
                                    
                                    result(loadResult,h5Version);
                                }];
                                
                                return ;
                            }else if ([remoteNum integerValue] < [localNum integerValue])
                            {
                                //无需下载, 停止判断
                                if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                    self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                                }
                                result(YES,h5Version);
                                return ;
                            }
                        }
                        if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                            self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                        }
                        result(YES,h5Version);
                        
                    }
                }else
                {
                    if (result) {
                        result(NO,@"");
                    }
                    if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                        self.resultBlock(BNDDPBH5LoadFail, 0.0);
                    }
                }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (result) {
                result(NO,@"");
            }
            if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                self.resultBlock(BNDDPBH5LoadFail, 0.0);
            }
        }];
    }
}

- (void)BNDDPBLoadH5PackageWithUrl:(NSString* )url header:(NSDictionary* )header parameters:(id)parameters method:(NSString *)method andPackageName:(NSString* )packageName andVersionCompetetion:(BNDDPBH5ManageH5VersionBlock)result{
    AFHTTPSessionManager* manager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = BNDDPBAcceptTypes;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    if (header) {
        NSArray* keyArray = header.allKeys;
        for (NSString* key in keyArray) {
            [manager.requestSerializer setValue:[self BNDDPBStringWith:header[key]] forHTTPHeaderField:[self BNDDPBStringWith:key]];
        }
    }
    
    NSString* requestUrl = [[self BNDDPBStringWith:url] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    if ([method isEqualToString:@"POST"]) {
        [manager POST:requestUrl parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *resdict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                if (resdict && resdict[@"data"] && [resdict[@"data"] isKindOfClass:[NSArray class]]) {
                    
                    NSArray * inforArray = resdict[@"data"];
                    if (inforArray.count >0) {
                        NSDictionary* infoDict = inforArray.lastObject;
                    
//                    NSDictionary* infoDict = resdict[@"data"];
                        // 支持的APP版本号 appVersion
                        NSString * appVersion = [NSString stringWithFormat:@"%@", infoDict[@"appVersion"]];
                        //服务器H5版本号
                        NSString* h5Version = [self BNDDPBStringWith:infoDict[@"h5Version"]];
                        //服务器Zip下载链接
                        NSString* h5Link = [self BNDDPBStringWith:infoDict[@"h5Link"]];
                        //本地H5版本号
                        NSArray* localArr = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
     
                        NSMutableArray* remoteArray = [NSMutableArray arrayWithArray:[h5Version componentsSeparatedByString:@"."]];
     
                        // 判断APP版本，空值通用，小于和等于才能进行下载。
                        BOOL isload = false;
                        if ([appVersion isEqualToString:@""]) {
                            isload = true;
                        }else{
                            NSArray * appArray = [appVersion componentsSeparatedByString:@"."];
                            // 获取当前App的基本信息字典
                            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
 
                            // app版本
                            NSString *sysVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];

                             
                            NSArray * sysArray = [sysVersion componentsSeparatedByString:@"."];
                            
                            for (NSInteger  i= 0; i < sysArray.count; i++) {
                                if (appArray.count > i) {
                                    if ([appArray[i] integerValue] > [sysArray[i] integerValue]) {
                                        isload = false;
                                        break;
                                    }else{
                                        isload = true;
                                        
                                    }
                                }else{
                                    isload = true;
                                }
                                
                            }
                        }
                        if (localArr == nil && isload) {
                            #pragma mark 需要下载
                            //下载中
                            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                            [self BNDDPBDownloadWebZipDataWithUrl:h5Link andPackageName:packageName andCompetetion:^(BOOL loadResult) {
                                if (loadResult) {
                                    //下载成功
                                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                    [[NSUserDefaults standardUserDefaults] setObject:remoteArray forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                    if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                        self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                                    }
                                }else
                                {
                                    //下载失败
                                    [[NSUserDefaults standardUserDefaults] setObject:@"-1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                    [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                    if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                        self.resultBlock(BNDDPBH5LoadFail, 0.0);
                                    }
                                }
                                
                                result(loadResult,h5Version);
                            }];
                            
                            
                        }else
                        {
                            NSMutableArray* localArray = [[NSMutableArray alloc] initWithArray:localArr];
                            
                            //判断远程h5是否需要下载
                            if (remoteArray.count < localArray.count) {
                                for (NSInteger i = remoteArray.count; i < localArray.count; i ++) {
                                    [remoteArray addObject:@"0"];
                                }
                            }else if (remoteArray.count > localArray.count)
                            {
                                for (NSInteger i = localArray.count; i < remoteArray.count; i ++) {
                                    [localArray addObject:@"0"];
                                }
                            }
                            
                            for (NSInteger i = 0; i < remoteArray.count; i ++) {
                                NSString* remoteNum = remoteArray[i];
                                NSString* localNum = localArray[i];
                                
                                if ([remoteNum integerValue] > [localNum integerValue]) {
                                    #pragma mark 需要下载
                                    //下载中
                                    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                    [self BNDDPBDownloadWebZipDataWithUrl:h5Link andPackageName:packageName andCompetetion:^(BOOL loadResult) {
                                        if (loadResult) {
                                            //下载成功
                                            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                            [[NSUserDefaults standardUserDefaults] setObject:remoteArray forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                            if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                                self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                                            }
                                        }else
                                        {
                                            //下载失败
                                            [[NSUserDefaults standardUserDefaults] setObject:@"-1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                            [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                            if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                                self.resultBlock(BNDDPBH5LoadFail, 0.0);
                                            }
                                        }
                                        
                                        result(loadResult,h5Version);
                                    }];
                                    
                                    return ;
                                }else if ([remoteNum integerValue] < [localNum integerValue])
                                {
                                    //无需下载, 停止判断
                                    if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                        self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                                    }
                                    result(YES,h5Version);
                                    return ;
                                }
                            }
                            if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                            }
                            result(YES,h5Version);
                            
                        }
                    }else{
                        result(NO,@"");
                    }
                }else
                {
                    if (result) {
                        result(NO,@"");
                    }
                    if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                        self.resultBlock(BNDDPBH5LoadFail, 0.0);
                    }
                }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           if (result) {
               result(false,@"");
           }
        }];
 
    }else
    {
       
        [manager GET:requestUrl parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *resdict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                if (resdict && resdict[@"data"] && [resdict[@"data"] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary* infoDict = resdict[@"data"];
                    // 支持的APP版本号 appVersion
                    NSString * appVersion = [NSString stringWithFormat:@"%@", infoDict[@"appVersion"]];
                    //服务器H5版本号
                    NSString* h5Version = [self BNDDPBStringWith:infoDict[@"h5Version"]];
                    //服务器Zip下载链接
                    NSString* h5Link = [self BNDDPBStringWith:infoDict[@"h5Link"]];
                    //本地H5版本号
                    NSArray* localArr = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
//                    if (self.isLog) {
//                        NSLog(@"服务器H5版本号==%@,,,下载地址===%@", h5Version,h5Link);
//                    }
                    NSMutableArray* remoteArray = [NSMutableArray arrayWithArray:[h5Version componentsSeparatedByString:@"."]];
//                    NSString* remoteIndex = @"";
//                    for (NSInteger i = 0; i < h5Version.length; i ++) {
//                        remoteIndex = [h5Version substringWithRange:NSMakeRange(i, 1)];
//                        if ([self stringIsNumber:remoteIndex]) {
//                            [remoteArray addObject:remoteIndex];
//                        }
//                    }
                    // 判断APP版本，空值通用，小于和等于才能进行下载。
                    BOOL isload = false;
                    if ([appVersion isEqualToString:@""]) {
                        isload = true;
                    }else{
                        NSArray * appArray = [appVersion componentsSeparatedByString:@"."];
                        // 获取当前App的基本信息字典
                        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

                        //app名称
//                        NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];

                        // app版本
                        NSString *sysVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];

                         
                        NSArray * sysArray = [sysVersion componentsSeparatedByString:@"."];
                        
                        for (NSInteger  i= 0; i < sysArray.count; i++) {
                            if (appArray.count > i) {
                                if ([appArray[i] integerValue] > [sysArray[i] integerValue]) {
                                    isload = false;
                                    break;
                                }else{
                                    isload = true;
                                    
                                }
                            }else{
                                isload = true;
                            }
                            
                        }
                    }
                    if (localArr == nil && isload) {
                        #pragma mark 需要下载
                        //下载中
                        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                        [self BNDDPBDownloadWebZipDataWithUrl:h5Link andPackageName:packageName andCompetetion:^(BOOL loadResult) {
                            if (loadResult) {
                                //下载成功
                                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                [[NSUserDefaults standardUserDefaults] setObject:remoteArray forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                    self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                                }
                            }else
                            {
                                //下载失败
                                [[NSUserDefaults standardUserDefaults] setObject:@"-1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                    self.resultBlock(BNDDPBH5LoadFail, 0.0);
                                }
                            }
                            
                            result(loadResult,h5Version);
                        }];
                        
                        
                    }else
                    {
                        NSMutableArray* localArray = [[NSMutableArray alloc] initWithArray:localArr];
                        
                        //判断远程h5是否需要下载
                        if (remoteArray.count < localArray.count) {
                            for (NSInteger i = remoteArray.count; i < localArray.count; i ++) {
                                [remoteArray addObject:@"0"];
                            }
                        }else if (remoteArray.count > localArray.count)
                        {
                            for (NSInteger i = localArray.count; i < remoteArray.count; i ++) {
                                [localArray addObject:@"0"];
                            }
                        }
                        
                        for (NSInteger i = 0; i < remoteArray.count; i ++) {
                            NSString* remoteNum = remoteArray[i];
                            NSString* localNum = localArray[i];
                            
                            if ([remoteNum integerValue] > [localNum integerValue]) {
                                #pragma mark 需要下载
                                //下载中
                                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                [self BNDDPBDownloadWebZipDataWithUrl:h5Link andPackageName:packageName andCompetetion:^(BOOL loadResult) {
                                    if (loadResult) {
                                        //下载成功
                                        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                        [[NSUserDefaults standardUserDefaults] setObject:remoteArray forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                        if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                            self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                                        }
                                    }else
                                    {
                                        //下载失败
                                        [[NSUserDefaults standardUserDefaults] setObject:@"-1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                        [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                        if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                            self.resultBlock(BNDDPBH5LoadFail, 0.0);
                                        }
                                    }
                                    
                                    result(loadResult,h5Version);
                                }];
                                
                                return ;
                            }else if ([remoteNum integerValue] < [localNum integerValue])
                            {
                                //无需下载, 停止判断
                                if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                    self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                                }
                                result(YES,h5Version);
                                return ;
                            }
                        }
                        if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                            self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                        }
                        result(YES,h5Version);
                        
                    }
                }else
                {
                    if (result) {
                        result(NO,@"");
                    }
                    if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                        self.resultBlock(BNDDPBH5LoadFail, 0.0);
                    }
                }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (result) {
                result(NO,@"");
            }
            if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                self.resultBlock(BNDDPBH5LoadFail, 0.0);
            }
        }];
    }
}

- (void)BNDDPBLoadH5PackageWithUrl:(NSString* )url header:(NSDictionary* )header parameters:(id)parameters method:(NSString *)method andPackageName:(NSString* )packageName andCompetetion:(BNDDPBH5ManageH5Block)result
{
    AFHTTPSessionManager* manager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = BNDDPBAcceptTypes;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    if (header) {
        NSArray* keyArray = header.allKeys;
        for (NSString* key in keyArray) {
            [manager.requestSerializer setValue:[self BNDDPBStringWith:header[key]] forHTTPHeaderField:[self BNDDPBStringWith:key]];
        }
    }
    
    NSString* requestUrl = [[self BNDDPBStringWith:url] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    if ([method isEqualToString:@"POST"]) {
        [manager POST:requestUrl parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *resdict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if (resdict && resdict[@"data"]) {
//                NSDictionary* infoDict = resdict[@"data"];
                
                
            }else
            {
                if (result) {
                    result(NO);
                }
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           if (result) {
               result(NO);
           }
        }];
 
    }else
    {
       
        [manager GET:requestUrl parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *resdict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                if (resdict && resdict[@"data"] && [resdict[@"data"] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary* infoDict = resdict[@"data"];
                    // 支持的APP版本号 appVersion
                    NSString * appVersion = [NSString stringWithFormat:@"%@", infoDict[@"appVersion"]];
                    //服务器H5版本号
                    NSString* h5Version = [self BNDDPBStringWith:infoDict[@"h5Version"]];
                    //服务器Zip下载链接
                    NSString* h5Link = [self BNDDPBStringWith:infoDict[@"h5Link"]];
                    //本地H5版本号
                    NSArray* localArr = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
//                    if (self.isLog) {
//                        NSLog(@"服务器H5版本号==%@,,,下载地址===%@", h5Version,h5Link);
//                    }
                    NSMutableArray* remoteArray = [NSMutableArray arrayWithArray:[h5Version componentsSeparatedByString:@"."]];
//                    NSString* remoteIndex = @"";
//                    for (NSInteger i = 0; i < h5Version.length; i ++) {
//                        remoteIndex = [h5Version substringWithRange:NSMakeRange(i, 1)];
//                        if ([self stringIsNumber:remoteIndex]) {
//                            [remoteArray addObject:remoteIndex];
//                        }
//                    }
                    // 判断APP版本，空值通用，小于和等于才能进行下载。
                    BOOL isload = false;
                    if ([appVersion isEqualToString:@""]) {
                        isload = true;
                    }else{
                        NSArray * appArray = [appVersion componentsSeparatedByString:@"."];
                        // 获取当前App的基本信息字典
                        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

                        //app名称
//                        NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];

                        // app版本
                        NSString *sysVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];

                         
                        NSArray * sysArray = [sysVersion componentsSeparatedByString:@"."];
                        
                        for (NSInteger  i= 0; i < sysArray.count; i++) {
                            if (appArray.count > i) {
                                if ([appArray[i] integerValue] > [sysArray[i] integerValue]) {
                                    isload = false;
                                    break;
                                }else{
                                    isload = true;
                                    
                                }
                            }else{
                                isload = true;
                            }
                            
                        }
                    }
                    if (localArr == nil && isload) {
                        #pragma mark 需要下载
                        //下载中
                        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                        [self BNDDPBDownloadWebZipDataWithUrl:h5Link andPackageName:packageName andCompetetion:^(BOOL loadResult) {
                            if (loadResult) {
                                //下载成功
                                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                [[NSUserDefaults standardUserDefaults] setObject:remoteArray forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                    self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                                }
                            }else
                            {
                                //下载失败
                                [[NSUserDefaults standardUserDefaults] setObject:@"-1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                    self.resultBlock(BNDDPBH5LoadFail, 0.0);
                                }
                            }
                            
                            result(loadResult);
                        }];
                        
                        
                    }else
                    {
                        NSMutableArray* localArray = [[NSMutableArray alloc] initWithArray:localArr];
                        
                        //判断远程h5是否需要下载
                        if (remoteArray.count < localArray.count) {
                            for (NSInteger i = remoteArray.count; i < localArray.count; i ++) {
                                [remoteArray addObject:@"0"];
                            }
                        }else if (remoteArray.count > localArray.count)
                        {
                            for (NSInteger i = localArray.count; i < remoteArray.count; i ++) {
                                [localArray addObject:@"0"];
                            }
                        }
                        
                        for (NSInteger i = 0; i < remoteArray.count; i ++) {
                            NSString* remoteNum = remoteArray[i];
                            NSString* localNum = localArray[i];
                            
                            if ([remoteNum integerValue] > [localNum integerValue]) {
                                #pragma mark 需要下载
                                //下载中
                                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                [self BNDDPBDownloadWebZipDataWithUrl:h5Link andPackageName:packageName andCompetetion:^(BOOL loadResult) {
                                    if (loadResult) {
                                        //下载成功
                                        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                        [[NSUserDefaults standardUserDefaults] setObject:remoteArray forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                        if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                            self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                                        }
                                    }else
                                    {
                                        //下载失败
                                        [[NSUserDefaults standardUserDefaults] setObject:@"-1" forKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
                                        [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:[NSString stringWithFormat:@"BNDDPBH5Zip%@",packageName]];
                                        if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                            self.resultBlock(BNDDPBH5LoadFail, 0.0);
                                        }
                                    }
                                    
                                    result(loadResult);
                                }];
                                
                                return ;
                            }else if ([remoteNum integerValue] < [localNum integerValue])
                            {
                                //无需下载, 停止判断
                                if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                                    self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                                }
                                result(YES);
                                return ;
                            }
                        }
                        if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                            self.resultBlock(BNDDPBH5LoadSuccess, 1.0);
                        }
                        result(YES);
                        
                    }
                }else
                {
                    if (result) {
                        result(NO);
                    }
                    if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                        self.resultBlock(BNDDPBH5LoadFail, 0.0);
                    }
                }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (result) {
                result(NO);
            }
            if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
                self.resultBlock(BNDDPBH5LoadFail, 0.0);
            }
        }];
    }
    
}

- (void)slCheckLoadingState:(NSString *)packageName andBlock:(BNDDPBH5ManageCheckLoadingH5Block)resultBlock
{
    if ([self loadingState:packageName] == BNDDPBH5LoadSuccess) {
        
        resultBlock(BNDDPBH5LoadSuccess, 1.0);
    }else if([self loadingState:packageName] == BNDDPBH5LoadFail)
    {
        resultBlock(BNDDPBH5LoadFail, 0.0);
    }else
    {
        self.loadPageName = packageName;
        self.resultBlock = resultBlock;
    }
    
}

- (BNDDPBH5LoadState)loadingState:(NSString* )packageName
{
    NSString* pageState = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"BNDDPBLoading%@",packageName]];
    if ([[self BNDDPBStringWith:pageState] integerValue] == 1) {
        return BNDDPBH5LoadSuccess;
        
    }else if ([[self BNDDPBStringWith:pageState] integerValue] == -1)
    {
        return BNDDPBH5LoadFail;
    }else
    {
        return BNDDPBH5LoadProcess;
    }
    
}

- (void)BNDDPBDownloadWebZipDataWithUrl:(NSString* )url andPackageName:(NSString* )packageName andCompetetion:(BNDDPBH5ManageDownloadH5Block)loadResult
{
    NSURL *requestUrl = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];
    
    //异步线程下载
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]init];
    __block NSString *path = [NSString stringWithFormat:@"%@/%@/",NSHomeDirectory(),BNDDPBH5ZipFileCachePath];
    [self createFolder:path];
    NSURLSessionDownloadTask *_downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        double curr=(double)downloadProgress.completedUnitCount;
        double total=(double)downloadProgress.totalUnitCount;
        if (self.isLog) {
            NSLog(@"(BNDDPBH5Manage/%@)-H5下载进度==%.2f",packageName,curr/total);
        }
        
        if (self.resultBlock && [self.loadPageName isEqualToString:packageName]) {
            CGFloat progress = curr/total;
            self.resultBlock(BNDDPBH5LoadProcess, progress);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        path = [path stringByAppendingPathComponent:response.suggestedFilename];
        
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            //下载失败
            if (self.isLog) {
                NSLog(@"(%@)-下载失败",packageName);
            }
            
            NSString * tempPath = [NSString stringWithFormat:@"%@/%@/%@",NSHomeDirectory(),BNDDPBH5ZipFileBasePath,packageName];
            @try {
                [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            } @catch (NSException *exception) {
                
            } 
            
            if (loadResult) {
                loadResult(NO);
            }
            
        }else
        {
            //下载成功
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self startUnzipH5FileZip:path FileName:packageName finishBlock:^(BOOL sucess) {
                    if (sucess) {
                        //解压成功
                        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                        if (self.isLog) {
                            NSLog(@"(%@)-解压成功",packageName);
                        }
                        
                        if (loadResult) {
                            loadResult(YES);
                        }
                        
                        
                    }else
                    {
                        //解压失败
                        NSString* tempPath = [NSString stringWithFormat:@"%@/%@/%@",NSHomeDirectory(),BNDDPBH5ZipFileBasePath,packageName];
                        @try {
                            [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
                            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                
                        } @catch (NSException *exception) {
                            
                        }
                        if (self.isLog) {
                            NSLog(@"(%@)-解压失败",packageName);
                        }
                        
                        if (loadResult) {
                            loadResult(NO);
                        }
                    }
                    
                }];
                
            });
            
        }
      
    }];
    
    //开始下载任务
    [_downloadTask resume];

}




- (BOOL)stringIsNumber:(NSString *)string
{
    if (string.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:string]) {
        return YES;
    }
    return NO;
    
}

//字符串判空处理
- (NSString* )BNDDPBStringWith:(NSString* )string
{
    NSString* str = [NSString stringWithFormat:@"%@",string];
    if ([str isKindOfClass:[NSNull class]] || str == nil || str.length == 0 || [str isEqualToString:@"(null)"]) {
        return @"";
    }
    
    return str;
    
}

- (void)createFolder:(NSString *)createDir{
    BOOL isDirectory = NO;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:createDir isDirectory:&isDirectory];
    if ( !(isDirectory == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:createDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}


- (void)startUnzipH5FileZip:(NSString*)localZipFile FileName:(NSString *)FileName finishBlock:(void(^)(BOOL sucess))finishBlock{
    if([[NSFileManager defaultManager] fileExistsAtPath:localZipFile] && [localZipFile hasSuffix:@"zip"]){
        NSString * newPath = [NSString stringWithFormat:@"%@/%@/%@",NSHomeDirectory(),BNDDPBH5ZipFileBasePath,FileName];
        BOOL isDirectory = YES;
        if ([[NSFileManager defaultManager] fileExistsAtPath:newPath isDirectory:&isDirectory]) {
            
            [[NSFileManager defaultManager] removeItemAtPath:newPath error:nil];
        }
        
        [self OpenZip:localZipFile unzipto:newPath finishBlock:finishBlock];
    }else{
        finishBlock(false);
    }
}

- (BOOL)OpenZip:(NSString* )zipPath unzipto:(NSString* )unzipto finishBlock:(void(^)(BOOL sucess))finishBlock{
    @synchronized(self) {
        [SSZipArchive unzipFileAtPath:zipPath toDestination:unzipto
                      progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {}
                    completionHandler:^(NSString *path, BOOL succeeded, NSError *error) {
                        if (finishBlock) {
                            finishBlock(succeeded);
                        }
                    }];
        return YES;
    }
}


@end
