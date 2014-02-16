//
//  Checkin.h
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Venue.h"

@interface Checkin : NSObject

@property (nonatomic, copy) User *user;
@property (nonatomic, copy) Venue *venue;

- (id)initWithUser:(User *)user venue:(Venue *)venue;

@end
