//
//  FCEvaluteView.h
//  FaceCar
//
//  Created by facecar on 2/26/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCView.h"
#import "FCTextView.h"

@interface FCEvaluteView : FCView <UIGestureRecognizerDelegate>

@property (strong, nonatomic) FCBooking* booking;
@property (weak, nonatomic) IBOutlet FCImageView *imgDriverAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgStar1;
@property (weak, nonatomic) IBOutlet UIImageView *imgStar2;
@property (weak, nonatomic) IBOutlet UIImageView *imgStar3;
@property (weak, nonatomic) IBOutlet UIImageView *imgStar4;
@property (weak, nonatomic) IBOutlet UIImageView *imgStar5;
@property (weak, nonatomic) IBOutlet FCTextView *tfComment;
@property (weak, nonatomic) IBOutlet FCButton *btnDone;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet FCTextView *tvComment;
@property (weak, nonatomic) IBOutlet UIView *viewRating;

@property (assign, nonatomic) int starRating;

- (void) reloadData;
- (void) setActionCallback: (void (^)(NSInteger index)) handler;

@end
