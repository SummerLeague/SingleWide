//
//  SLCredentialStore.h
//  SingleWide
//
//  Created by Bradley Griffith on 1/14/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLCredentialStore : NSObject

- (BOOL)isLoggedIn;
- (void)clearSavedCredentials;
- (NSString *)authToken;
- (NSString *)nickname;
- (NSString *)password;
- (NSString *)userId;
- (void)setAuthToken:(NSString *)authToken;
- (void)setNickname:(NSString *)nickname;
- (void)setPassword:(NSString *)password;
- (void)setUserId:(NSString *)userId;

@end
