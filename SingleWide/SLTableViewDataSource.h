//
//  SLTableViewDataSource.h
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SLTableViewDataSourceDelegate;

@interface SLTableViewDataSource : NSObject

@property (nonatomic, copy) NSString *reusableCellIdentifier;
@property (nonatomic, weak) id<SLTableViewDataSourceDelegate> delegate;
@property (nonatomic, strong) NSArray *objects;

- (id)initWithTableView:(UITableView *)tableView;

@end

@protocol SLTableViewDataSourceDelegate <NSObject>
@required
- (void)configureCell:(id)cell withObject:(id)object;
@end
