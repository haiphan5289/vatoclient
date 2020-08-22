//
//  FCPromotionDialogView.h
//  FaceCar
//
//  Created by facecar on 9/4/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHomeViewModel.h"
#import "FCFareManifest.h"

@interface FCPromotionDialogView : FCView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (assign, nonatomic) CGPoint originPoint; // position for start view
@property (strong, nonatomic) NSArray* listGifts;
@property (strong, nonatomic) FCHomeViewModel* homeViewModel;

- (void) setSelectDetail:(void(^)(FCFareManifest*))callbackDetail
             selectUsing:(void(^)(FCFareManifest*))callbackUsing;

@end
