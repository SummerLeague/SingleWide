//
//  Checkin.m
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "Checkin.h"

@implementation Checkin

- (id)initWithUser:(User *)user venue:(Venue *)venue
{
	self = [super init];
	if (self) {
		self.user = user;
		self.venue = venue;
	}
	
	return self;
}

@end
