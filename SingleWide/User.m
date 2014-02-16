//
//  User.m
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "User.h"

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

@end
