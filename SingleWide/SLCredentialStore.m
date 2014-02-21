//
//  SLCredentialStore.m
//  SingleWide
//
//  Created by Bradley Griffith on 1/14/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "SLCredentialStore.h"
#import "SSKeychain.h"

static NSString *ServiceName = @"SingleWide";
static NSString *AuthTokenKey = @"auth_token";
static NSString *NicknameKey = @"nickname";
static NSString *IdKey = @"userId";
static NSString *PasswordKey = @"password";

@implementation SLCredentialStore

- (BOOL)isLoggedIn
{
	return [self authToken] != nil;
}

- (void)clearSavedCredentials
{
	[self setAuthToken:nil];
	[self setNickname:nil];
	[self setPassword:nil];
	[self setUserId:nil];
}

- (NSString *)authToken
{
	NSLog(@"authToken: %@", [self secureValueForKey:AuthTokenKey]);
	return [self secureValueForKey:AuthTokenKey];
}

- (NSString *)nickname
{
	return [self secureValueForKey:NicknameKey];
}

- (NSString *)password
{
	return [self secureValueForKey:PasswordKey];
}

- (NSString *)userId
{
	return [self secureValueForKey:IdKey];
}

- (void)setAuthToken:(NSString *)authToken
{
	[self setSecureValue:authToken forKey:AuthTokenKey];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"token-changed" object:self];
}

- (void)setNickname:(NSString *)nickname
{
	[self setSecureValue:nickname forKey:NicknameKey];
}

- (void)setPassword:(NSString *)password
{
	[self setSecureValue:password forKey:PasswordKey];
}

- (void)setUserId:(NSString *)userId
{
	[self setSecureValue:userId forKey:IdKey];
}

- (void)setSecureValue:(NSString *)value forKey:(NSString *)key
{
	// In the keychain, there are passwords for various services.
	// We utilize these key/values to store sensitive key/value pairs.
	if (value) {
		[SSKeychain setPassword:value forService:ServiceName account:key];
	}
	else {
		[SSKeychain deletePasswordForService:ServiceName account:key];
	}
}

- (NSString *)secureValueForKey:(NSString *)key
{
	return [SSKeychain passwordForService:ServiceName account:key];
}

@end
