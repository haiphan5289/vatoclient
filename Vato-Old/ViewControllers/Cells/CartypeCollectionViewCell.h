//
//  CartypeCollectionViewCell.h
//  FaceCar
//
//  Created by vudang on 12/5/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHomeViewModel.h"

@interface CartypeCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) FCMCarType* cartype;
@property (strong, nonatomic) FCHomeViewModel* homeViewModel;

- (void) setSelectedCar: (BOOL) selected;
- (void) loadData;

@end

@interface Cartype : NSObject
@property (strong, nonatomic)  NSString *icon;
@property (strong, nonatomic)  NSString *name;
@property (assign, nonatomic)  NSInteger type;
@property (assign, nonatomic)  BOOL selected;

- (id) init:(NSString*) name iconName: (NSString*) icon type: (NSInteger) type select:( BOOL) select;

@end
