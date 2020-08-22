//
//  ServiceCollectionViewCell.h
//  FaceCar
//
//  Created by vudang on 2/17/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CartypeCollectionViewCell.h"
#import "FCHomeViewModel.h"

@interface ServiceCollectionViewCell : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (unsafe_unretained, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSIndexPath* currentIndexSelected;
@property (strong, nonatomic) NSArray* listCartype;
@property (strong, nonatomic) FCHomeViewModel* homeViewModel;

- (void) loadService:(FCService*) services;
- (void) setCurrentSerivceSelected;

@end
