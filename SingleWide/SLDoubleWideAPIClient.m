//
//  SLDoubleWideAPIClient.m
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "SLDoubleWideAPIClient.h"
#import "SLCredentialStore.h"

//static NSString *serverAddress = @"http://127.0.0.1:8888";
//static NSString *serverAddress = @"http://10.0.1.7:8888";
static NSString *serverAddress = @"http://doublewide.herokuapp.com";

@implementation SLDoubleWideAPIClient

+ (SLDoubleWideAPIClient *)sharedClient
{
	static SLDoubleWideAPIClient *sharedClient = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSURL *baseURL = [NSURL URLWithString:serverAddress];
		sharedClient = [[SLDoubleWideAPIClient alloc] initWithBaseURL:baseURL];
	});
	
	return sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
	self = [super initWithBaseURL:url];
	if (self) {
		self.responseSerializer = [AFJSONResponseSerializer serializer];
		[self setAuthTokenHeader];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenChanged:) name:@"token-changed" object:nil];
	}
	
	return self;
}

- (void)setAuthTokenHeader
{
	SLCredentialStore *store = [[SLCredentialStore alloc] init];
	NSString *authToken = [store authToken];
	[self.requestSerializer setValue:authToken forHTTPHeaderField:@"auth_token"];
}

- (void)tokenChanged:(NSNotification *)notification
{
	[self setAuthTokenHeader];
}
@end
