//
//  SLUserAuthenticator.h
//  SingleWide
//
//  Created by Bradley Griffith on 1/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessBlock)();
typedef void (^FailureBlock)(NSString *errorMessage);

@interface SLUserAuthenticator : NSObject

- (NSURLSessionDataTask *)loginWithNickname:(NSString *)nickname password:(NSString *)password success:(SuccessBlock)success failure:(FailureBlock)failure;

- (void)loginWithStoredCredentials:(SuccessBlock)success failure:(FailureBlock)failure;
- (void)refreshTokenAndRetryTask:(NSURLSessionDataTask *)task completion:(void (^)(NSURLResponse *response, id responseObject, NSError *error ) )completion authenticationFailure:(void (^)(NSURLSessionDataTask *task, NSString *errorMessage ) )authenticationFailure;

@end
