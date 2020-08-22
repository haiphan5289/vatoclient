//
//  GoogleAutoCompleteViewController.h
//  FaceCar
//
//  Created by facecar on 5/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleViewModel.h"
#import "FCSwipeView.h"

@import GooglePlaces;

@interface GoogleAutoCompleteViewController : FCSwipeView

@property (strong, nonatomic) GoogleViewModel* googleViewModel;
@property (strong, nonatomic) UITextField* searchView;
@property (weak, nonatomic) FCGGMapView* mapview;
@property (weak, nonatomic) IBOutlet FCProgressView *progressView;

@end
