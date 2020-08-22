//
//  FCPromotionCollectionViewCell.h
//  FaceCar
//
//  Created by facecar on 10/2/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHomeViewModel.h"
#import "FCFareManifest.h"

@interface FCPromotionCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgCover;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblHeadLine;
@property (weak, nonatomic) IBOutlet UIButton *btnUsing;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@property (strong, nonatomic) void (^usingCallback)(FCFareManifest*);

@property (strong, nonatomic) FCFareManifest* gift;
@property (strong, nonatomic) FCHomeViewModel* homeViewModel;

- (void) loadView: (FCFareManifest*) gift atIndex: (NSInteger) index total: (NSInteger) total;

@end
