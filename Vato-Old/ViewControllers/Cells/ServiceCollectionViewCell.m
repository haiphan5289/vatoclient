//
//  ServiceCollectionViewCell.m
//  FaceCar
//
//  Created by vudang on 2/17/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "ServiceCollectionViewCell.h"
#import "FCBookViewModel.h"

@implementation ServiceCollectionViewCell {
    FCService* _service;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.allowsSelection = TRUE;
    self.collectionView.allowsMultipleSelection = NO;
    [self.collectionView registerNib:[UINib nibWithNibName:@"CartypeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CartypeCollectionViewCell"];
}

- (void) loadService:(FCService *)services {
    
    _service = services;
    _listCartype = services.cartypes;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

- (void) setCurrentSerivceSelected {
    @try {
        if (_currentIndexSelected) {
            FCMCarType* service = [_listCartype objectAtIndex:_currentIndexSelected.row];
            self.homeViewModel.bookViewModel.serviceSelected = service;
            [self.homeViewModel checkingServiceSelected:service];
        }
    }
    @catch (NSException* e) {}
}

- (NSInteger) getIndexServiceSelected {
    FCMCarType* currService = self.homeViewModel.bookViewModel.serviceSelected;
    int index = 0;
    for (FCMCarType* ser in self.listCartype) {
        if (ser.id == currService.id) {
            return index;
        }
        index++;
    }
    return 0;
}

#pragma mark - Cartype CollectionView

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionView.frame.size.width/_listCartype.count, self.collectionView.frame.size.height);
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _listCartype.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CartypeCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CartypeCollectionViewCell" forIndexPath:indexPath];
    FCMCarType* car = [_listCartype objectAtIndex:indexPath.row];
    cell.cartype = car;
    cell.homeViewModel = self.homeViewModel;
    [cell loadData];
    
    // select cell
    if (indexPath.row == [self getIndexServiceSelected]) {
        _currentIndexSelected = indexPath;
        [cell setSelectedCar:YES];
        [collectionView selectItemAtIndexPath:indexPath
                                     animated:NO
                               scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath == _currentIndexSelected) {
        return;
    }
    
    _currentIndexSelected = indexPath;
    CartypeCollectionViewCell* cell = (CartypeCollectionViewCell*) [self.collectionView cellForItemAtIndexPath:indexPath];
    [cell setSelectedCar:YES];
    
    // notify create bookind data
    FCMCarType* service = [_listCartype objectAtIndex:indexPath.row];
    self.homeViewModel.bookViewModel.serviceSelected = service;
    [self.homeViewModel checkingServiceSelected:service];
}

- (void) collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    _currentIndexSelected = nil;
    CartypeCollectionViewCell* cell = (CartypeCollectionViewCell*) [collectionView cellForItemAtIndexPath:indexPath];
    [cell setSelectedCar:NO];
}

@end
