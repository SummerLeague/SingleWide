//
//  Checkin.m
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "Checkin.h"

@interface Checkin () <NSCopying>

@end

@implementation Checkin

- (id)initWithId:(NSString *)checkinId user:(User *)user venue:(Venue *)venue creationDateString:(NSString *)creationDateString
{
	self = [super init];
	if (self) {
		self.doubleWideId = checkinId;
		self.creationDateString = creationDateString;
		self.user = user;
		self.venue = venue;
	}
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	Checkin *checkin = [Checkin allocWithZone:zone];
	if( checkin )
	{
		checkin.user = self.user;
		checkin.venue = self.venue;
	}
	
	return checkin;
}

@end
