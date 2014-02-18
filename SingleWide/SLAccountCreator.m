//
//  SLAccountCreator.m
//  SingleWide
//
//  Created by Bradley Griffith on 1/14/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "SLAccountCreator.h"
#import "SLDoubleWideAPIClient.h"
#import "SLCredentialStore.h"

@interface SLAccountCreator ()

@property (nonatomic, strong) SLCredentialStore *credentialStore;

@end

@implementation SLAccountCreator

- (id)init
{
	self = [super init];
	if (self) {
		_credentialStore = [[SLCredentialStore alloc] init];
	}
	
	return self;
}

- (NSURLSessionDataTask *)createUserWithNickname:(NSString *)nickname password:(NSString *)password success:(SuccessBlock)success failure:(FailureBlock)failure
{
	id params = @{
		@"nickname": nickname ?: @"",
		@"password": password ?: @""
	};
	
	NSURLSessionDataTask *task = [[SLDoubleWideAPIClient sharedClient] POST:@"/api/users" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
		NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
		if (response.statusCode == 200) {
			[_credentialStore setAuthToken:responseObject[@"token"]];
			[_credentialStore setNickname:nickname];
			[_credentialStore setPassword:password];
			[_credentialStore setUserId:[responseObject[@"_id"] stringValue]];
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
		failure(error.localizedDescription);
	}];
	
	return task;
}

@end
