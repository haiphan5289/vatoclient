//
//  FCPopupListView.h
//  FaceCar
//
//  Created by facecar on 12/17/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCView.h"
#import "FCHomeViewModel.h"

@interface FCPopupListView : FCView
@property (strong, nonatomic) FCHomeViewModel* homeViewModel;
@property (strong, nonatomic) FCPartner* partnerSelected;
@property (assign, nonatomic) CGPoint originPoint; // position for start view
@end
