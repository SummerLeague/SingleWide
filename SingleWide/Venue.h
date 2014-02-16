//
//  Venue.h
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Venue : NSObject

@property (nonatomic, copy) NSString *venueId;
@property (nonatomic, copy) NSString *foursquareId;

- (id)initWithVenueId:(NSString *)venueId foursquareId:foursquareId;

@end
