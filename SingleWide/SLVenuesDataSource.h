//
//  SLVenuesDataSource.h
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SLVenuesDataSourceDelegate;

@interface SLVenuesDataSource : NSObject

@property (nonatomic, copy) NSString *reusableCellIdentifier;
@property (nonatomic, weak) id<SLVenuesDataSourceDelegate> delegate;
@property (nonatomic, strong) NSArray *nearbyVenues;

- (id)initWithTableView:(UITableView *)tableView;

@end

@protocol SLVenuesDataSourceDelegate <NSObject>
@required
- (void)configureCell:(id)cell withObject:(id)object;
@end
