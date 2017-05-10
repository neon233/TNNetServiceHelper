//
//  TNNetServiceHelper.h
//  AplusEduPro
//
//  Created by neon on 15/7/16.
//  Copyright (c) 2015年 neon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TNNetServiceDelegate <NSObject>
@optional
-(void)doneNetServiceWithResponseData:(id)responseData withState:(NSInteger)state withTag:(NSInteger)tag;
-(void)doneBatchNetServiceWithResponseData:(id)responseData withTag:(NSInteger)tag;
@end

@interface TNNetServiceHelper : NSObject
+ (instancetype)sharedInstance;

- (NSInteger)postBatchNetServiceWithUrl:(NSString *)URL withParams:(NSArray *)paramsList withCallbackDelegate:(id<TNNetServiceDelegate>)ownDelgate withProcess:(BOOL)showProcess;

- (NSInteger)postNetServiceWithCompleteUrl:(NSString *)completeURL withMethodName:(NSString *)methodName withParams:(id)paramsData withCallbackDelegate:(id <TNNetServiceDelegate>)ownDelgate withProcess:(BOOL)showProcess withAlert:(BOOL)showAlert;

- (void)cancelRequestithRequestId:(NSInteger )requestID;
@end

