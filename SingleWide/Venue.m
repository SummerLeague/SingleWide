//
//  Venue.m
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "Venue.h"

@interface Venue () <NSCopying>

@end

@implementation Venue

- (id)initWithVenueId:(NSString *)venueId foursquareId:foursquareId
{
	self = [super init];
	if (self) {
		self.venueId = venueId;
		self.foursquareId = foursquareId;
	}
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	Venue *venue = [Venue allocWithZone:zone];
	if( venue )
	{
		venue.venueId = self.venueId;
		venue.foursquareId = self.foursquareId;
		venue.name = self.name;
	}
	
	return venue;
}

@end
