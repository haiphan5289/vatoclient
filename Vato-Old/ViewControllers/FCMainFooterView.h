//
//  FCMainFooterView.h
//  FaceCar
//
//  Created by facecar on 12/6/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWParallaxScrollView.h"
#import "ServiceCollectionViewCell.h"
#import "FCHomeViewModel.h"

@interface FCMainFooterView : FCView <PWParallaxScrollViewDataSource, PWParallaxScrollViewDelegate>


@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnPrev;


@property(nonatomic, strong) PWParallaxScrollView *cartypeScrollView;
@property(nonatomic, strong) FCHomeViewModel* homeViewModel;
@property(strong, nonatomic) NSMutableArray* listService;

//- (void) initCartypeView;

@end
