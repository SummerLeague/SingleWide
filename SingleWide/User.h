//
//  User.h
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreData;

@interface User : NSManagedObject

@property (nonatomic, copy) NSString *doubleWideId;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSSet *checkIns;

+ (id)userWithDoubleWideId:(NSString *)doubleWideId inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSString *)entityName;

@end
