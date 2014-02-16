//
//  User.h
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, copy) NSString *doubleWideId;
@property (nonatomic, copy) NSString *nickname;

- (id)initWithDoublewideId:(NSString *)doubleWideId nickname:(NSString *)nickname;

@end
