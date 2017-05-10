
//
//  TNNetServiceHelper.m
//  AplusEduPro
//
//  Created by neon on 15/7/16.
//  Copyright (c) 2015年 neon. All rights reserved.
//


#import "TNNetServiceHelper.h"
#import "NSDictionary+null.h"
#import "AFNetworking.h"
#import "SignInController.h"
#import "NSDictionary+null.h"

@interface TNNetServiceHelper()

@property (nonatomic, strong) NSNumber *recordedRequestId;
@property (nonatomic, strong) NSMutableDictionary *dispatchTable;

@end
@implementation TNNetServiceHelper

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static TNNetServiceHelper *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TNNetServiceHelper alloc] init];
    });
    return sharedInstance;
}

- (NSMutableDictionary *)dispatchTable
{
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

#pragma mark event
- (NSNumber *)generateRequestId
{
    if (_recordedRequestId == nil) {
        _recordedRequestId = @(1);
    } else {
        if ([_recordedRequestId integerValue] == NSIntegerMax) {
            _recordedRequestId = @(1);
        } else {
            _recordedRequestId = @([_recordedRequestId integerValue] + 1);
        }
    }
    return _recordedRequestId;
}

- (void)cancelRequestithRequestId:(NSInteger )requestID {
    
    NSURLSessionDataTask *task = self.dispatchTable[[NSNumber numberWithInteger:requestID]];
    [task cancel];
    [self.dispatchTable removeObjectForKey:[NSNumber numberWithInteger:requestID]];
}

- (void)showJsonStrWithData:(id)data {
    NSError *error = nil;
    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    NSLog(@"JSON数据--->%@", jsonString);
}

#pragma mark 批量请求
- (NSInteger)postBatchNetServiceWithUrl:(NSString *)URL withParams:(NSArray *)paramsList withCallbackDelegate:(id<TNNetServiceDelegate>)ownDelgate withProcess:(BOOL)showProcess{
    
    NSNumber *requestId = [self generateRequestId];
    
    [paramsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *item = obj;
        [item addEntriesFromDictionary:@{@"jsonrpc":@"2.0"}];
    }];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    if ([[SessionHelper sharedInstance] checkSession]) {
        [configuration setHTTPAdditionalHeaders:@{@"auth-token":[[SessionHelper sharedInstance] getAppSession].userToken}];
    }
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:configuration];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json-rpc,application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[[SessionHelper sharedInstance] getAppSession].userToken forHTTPHeaderField:@"auth-token"];
    
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0f;
    
    NSLog(@"发起请求的数据是---》%@",paramsList);
    
    NSURLSessionDataTask *task = [manager POST:URL parameters:paramsList progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (showProcess) {
            [TNPromptView dismissProcessView];
        }
        
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"调用成功，返回的数据是---》%@",responseDict);
        [ownDelgate doneBatchNetServiceWithResponseData:responseDict withTag:requestId.integerValue];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
        NSDictionary * responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"调用错误返回的信息是----》%@",responseDict);
        if (showProcess) {
            [TNPromptView dismissProcessView];
        }
        [TNPromptView showResultViewWithResult:NO withContent:@"网络原因造成的接口调用错误" withDoneBlock:^{
            [TNPromptView dismissAlertView];
        }];
        return ;
        
        
    }];
    
    self.dispatchTable[requestId] = task;
    return requestId.integerValue;
}

#pragma mark 单个请求
- (NSInteger)postNetServiceWithCompleteUrl:(NSString *)completeURL withMethodName:(NSString *)methodName withParams:(id)paramsData withCallbackDelegate:(id <TNNetServiceDelegate>)ownDelgate withProcess:(BOOL)showProcess withAlert:(BOOL)showAlert{
    
    NSNumber *requestId = [self generateRequestId];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]initWithDictionary:paramsData];
    
    [parameters addEntriesFromDictionary:@{@"id":requestId.stringValue}];
    [parameters addEntriesFromDictionary:@{@"jsonrpc":@"2.0"}];
    [parameters addEntriesFromDictionary:@{@"method":methodName}];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    if ([[SessionHelper sharedInstance]checkSession]) {
        [configuration setHTTPAdditionalHeaders:@{@"auth-token":[[SessionHelper sharedInstance]getAppSession].userToken}];
    }
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:configuration];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json-rpc,application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[[SessionHelper sharedInstance]getAppSession].userToken forHTTPHeaderField:@"auth-token"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.0f;
    
    NSLog(@"发起请求的数据是---》%@",parameters);
    NSURLSessionDataTask *task = [manager POST:completeURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSDictionary *allHeaders = response.allHeaderFields;
        NSLog(@"http头-->%@",allHeaders);
        if (showProcess) {
            [TNPromptView dismissProcessView];
        }
        
        NSDictionary* responseDict = [[NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil] dictionaryByReplacingNullsWithStrings];
        NSLog(@"调用成功，返回的数据是---》%@",responseDict);
        
        if (responseDict[@"error"]) {
            //可以在这个地方做统一的错误处理
            [ownDelgate doneNetServiceWithResponseData:responseDict[@"error"][@"message"]  withState:TNStateFail withTag:requestId.integerValue];
        }else {
            [ownDelgate doneNetServiceWithResponseData:responseDict[@"result"] withState:TNStateOK withTag:requestId.integerValue];
        }
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
        NSDictionary * responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"调用错误返回的信息是----》%@",responseDict);
        if (showProcess) {
            [TNPromptView dismissProcessView];
        }
        [TNPromptView showResultViewWithResult:NO withContent:@"网络原因造成的接口调用错误" withDoneBlock:^{
            [TNPromptView dismissAlertView];
        }];
        return ;
    }];
    
    
    self.dispatchTable[requestId] = task;
    return requestId.integerValue;
    
    
    
    
}
@end
