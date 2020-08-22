//
//  FCPromotionCollectionViewCell.m
//  FaceCar
//
//  Created by facecar on 10/2/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCPromotionCollectionViewCell.h"

@implementation FCPromotionCollectionViewCell {
    FCGift* _currentGiftApply;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void) setHomeViewModel:(FCHomeViewModel *)homeViewModel {
    _homeViewModel = homeViewModel;
}

- (void) loadView: (FCFareManifest*) gift atIndex: (NSInteger) index total: (NSInteger) total {
    [self.btnUsing setEnabled:NO];
    
    self.gift = gift;
    self.footerView.hidden = TRUE;
    
//    [self.imgCover setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[gift.banner stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]
//                         placeholderImage:[UIImage imageNamed:@"promo-cover"]
//                                  success:^(NSURLRequest * request, NSHTTPURLResponse * response, UIImage * image) {
//                                      self.imgCover.image = image;
//                                      
//                                  } failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error) {
//                                      
//                                  }];
    [self.lblTitle setText:gift.title];
    [self.lblHeadLine setText:gift.headline];
    [self layoutSubviews];
}

- (IBAction)usingClciked:(id)sender {
    self.usingCallback(self.gift);
}

@end
