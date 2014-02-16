//
//  SLVenuesDataSource.m
//  SingleWide
//
//  Created by Mark Stultz on 2/15/14.
//  Copyright (c) 2014 Summer League. All rights reserved.
//

#import "SLVenuesDataSource.h"
#import "Venue.h"

@interface SLVenuesDataSource () <UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation SLVenuesDataSource

- (id)initWithCollectionView:(UICollectionView *)collectionView
{
	self = [super init];
	if (self) {
		self.collectionView = collectionView;
		self.collectionView.dataSource = self;
	}
	
	return self;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.nearbyVenues.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	Venue *venue = [self.nearbyVenues objectAtIndex:indexPath.row];
	id cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:self.reusableCellIdentifier forIndexPath:indexPath];
	[self.delegate configureCell:cell withObject:venue];
	return cell;
}


@end
