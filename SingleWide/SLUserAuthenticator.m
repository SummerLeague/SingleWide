//
//  SLUserAuthenticator.m
//  SingleWide
//
//  Created by Bradley Griffith on 1/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "SLUserAuthenticator.h"
#import "SLDoubleWideAPIClient.h"
#import "SLCredentialStore.h"

@interface SLUserAuthenticator ()

@property (nonatomic, strong) SLCredentialStore *credentialStore;

@end

@implementation SLUserAuthenticator

- (id)init
{
	self = [super init];
	if (self) {
		_credentialStore = [[SLCredentialStore alloc] init];
	}
	
	return self;
}

- (NSURLSessionDataTask *)loginWithNickname:(NSString *)nickname password:(NSString *)password success:(SuccessBlock)success failure:(FailureBlock)failure
{
	id params = @{
		@"nickname": nickname ?: @"",
		@"password": password ?: @""
	};
	
	NSURLSessionDataTask *task = [[SLDoubleWideAPIClient sharedClient] POST:@"/api/login" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
		NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
		if (response.statusCode == 200) {
			NSDictionary *user = responseObject[ @"user" ];
			[_credentialStore setAuthToken:user[ @"token"]];
			[_credentialStore setNickname:nickname];
			[_credentialStore setPassword:password];
			[_credentialStore setUserId:user[@"_id"]];
			success();
		}
		else {
			failure(@"Something went wrong.");
			NSLog(@"Recieved %@", response);
			NSLog(@"Recieved HTTP %ld", (long)response.statusCode);
		}
	}
	failure:^(NSURLSessionDataTask *task, NSError *error) {
		// TODO: Extact actual error from response.

		failure([error localizedDescription]);
	}];
	
	return task;
}

- (void)loginWithStoredCredentials:(SuccessBlock)success failure:(FailureBlock)failure
{
	NSString *nickname = [_credentialStore nickname];
	NSString *password = [_credentialStore password];
	
	[self loginWithNickname:nickname password:password success:success failure:failure];
}

- (void)refreshTokenAndRetryTask:(NSURLSessionDataTask *)task completion:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completion authenticationFailure:(void (^)(NSURLSessionDataTask *task, NSString *errorMessage))authenticationFailure
{
	NSString *nickname = [_credentialStore nickname];
	NSString *password = [_credentialStore password];
	
	[self loginWithNickname:nickname password:password success:^{
		// Retry request.
		NSLog(@"Retrying Request");
		NSURLRequest *retryRequest = [self requestForOriginalTask:task];
		NSURLSessionDataTask *retryTask = [[SLDoubleWideAPIClient sharedClient] dataTaskWithRequest:retryRequest completionHandler:completion];
		// Resume task.
		[retryTask resume];
	}
	failure:^(NSString *errorMessage) {
		authenticationFailure(task, errorMessage);
	}];
}

- (NSMutableURLRequest *)requestForOriginalTask:(NSURLSessionDataTask *)task
{
	NSMutableURLRequest *request = [task.originalRequest mutableCopy];
	[request addValue:nil forHTTPHeaderField:@"auth_token"];
	[request addValue:[_credentialStore authToken] forHTTPHeaderField:@"auth_token"];
	
	return request;
}

@end
