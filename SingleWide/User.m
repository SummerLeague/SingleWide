//
//  User.m
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "User.h"

@interface User () <NSCopying>

@end

@implementation User

- (id)initWithDoublewideId:(NSString *)doubleWideId nickname:(NSString *)nickname
{
	self = [super init];
	if (self) {
		self.doubleWideId = doubleWideId;
		self.nickname = nickname;
	}
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	User *user = [User allocWithZone:zone];
	if( user )
	{
		user.doubleWideId = self.doubleWideId;
		user.nickname = self.nickname;
	}
	
	return user;
}

@end
