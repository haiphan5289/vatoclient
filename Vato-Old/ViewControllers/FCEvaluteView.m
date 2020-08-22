//
//  FCEvaluteView.m
//  FaceCar
//
//  Created by facecar on 2/26/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCEvaluteView.h"

@implementation FCEvaluteView {
    void (^_actionHandler)(NSInteger index);
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet NSLayoutConstraint *bottomView;
    __weak IBOutlet NSLayoutConstraint *heightVIew;
    __weak IBOutlet NSLayoutConstraint *bottomBtCompleted;
    __weak IBOutlet NSLayoutConstraint *viewHeight;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    [self resetStars];
    [_btnDone setTitle:[localizedFor(@"Hoàn tất") uppercaseString] forState:UIControlStateNormal];
    [_btnCancel setTitle:localizedFor(@"Bỏ qua") forState:UIControlStateNormal];
    _tvComment.placeholder = localizedFor(@"Nhập đánh giá của bạn");
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.btnDone] ||
        [touch.view isDescendantOfView:self.btnCancel]) {
        return NO;
    }
    return YES;
}

- (void) reloadData {
    [[FirebaseHelper shareInstance] getDriver:self.booking.info.driverFirebaseId
                                      handler:^(FCDriver * driver) {
                                          [self.imgDriverAvatar setImageWithUrl:driver.user.avatarUrl];
                                          [self.lblTitle setText:[NSString stringWithFormat:@"%@ \n %@", localizedFor(@"Đánh giá của bạn về chuyến đi với tài xế"), driver.user.fullName]];
                                      }];
    
    self.btnDone.enabled = NO;
    RAC(self.btnDone, enabled) = [RACSignal combineLatest:@[RACObserve(self, starRating)]
                                                   reduce:^(NSNumber* rating) {
                                                       return @([rating intValue] > 0);
                                                   }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGRect sizeFrame = self.frame;
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height - 40, 0);
    _btnDone.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height - 5);
    if (keyboardSize.height == 0) {
        return;
    }
    CGRect rect = [_viewRating convertRect:_viewRating.frame toView:scrollView];
    rect.size.height = rect.size.height + 40;
    [scrollView scrollRectToVisible:rect animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    _btnDone.transform = CGAffineTransformIdentity;
    bottomBtCompleted.constant = 20;
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void) setActionCallback:(void (^)(NSInteger))handler {
    _actionHandler = handler;
}

- (IBAction)star1Clicked:(id)sender {
    [self onStarClicked:1];
}

- (IBAction)star2Clicked:(id)sender {
    [self onStarClicked:2];
}

- (IBAction)star3Clicked:(id)sender {
    [self onStarClicked:3];
}

- (IBAction)star4Clicked:(id)sender {
    [self onStarClicked:4];
}

- (IBAction)star5Clicked:(id)sender {
    [self onStarClicked:5];
}

- (IBAction)onCompleteClicked:(id)sender {
    [self sendRating];
}

- (IBAction)onCancelClicked:(id)sender {
    _actionHandler(0);
}

- (IBAction)backgroundClicked:(id)sender {
    [self.tvComment resignFirstResponder];
}
 
- (void) sendRating {
    FCEvalute* evalute = [[FCEvalute alloc] init];
    evalute.rating = _starRating;
    evalute.comment = _tvComment.text;
    evalute.bookingId = _booking.info.tripId;
    evalute.driverId = _booking.info.driverUserId;
    evalute.clientId = _booking.info.clientUserId;
    evalute.zoneId = _booking.info.zoneId;
    
    [[FirebaseHelper shareInstance] setEvalute:evalute];
     [[UserDataHelper shareInstance] removeLastestTripbook];
//    [[FCNotifyBannerView banner] show:nil
//                              forType:FCNotifyBannerTypeSuccess
//                             autoHide:YES
//                              message:@"Cảm ơn bạn đã quan tâm và sử dụng dịch vụ của VATO."
//                           closeClick:nil
//                          bannerClick:nil];
    

    @try {
        NSDictionary* body = @{@"driverId": @(evalute.driverId),
                               @"rating": @(_starRating),
                               @"referId": self.booking.info.tripId,
                               @"referCode": self.booking.info.tripCode,
                               @"detail":evalute.comment,
                               @"tripType":@(self.booking.info.tripType)};
        [[APIHelper shareInstance] post:API_ADD_RATING
                                   body:body
                               complete:nil];
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e)
    }
    _actionHandler(1);
}

- (void) resetStars {
    [self.imgStar1 setImage:[UIImage imageNamed:@"star-empty"]];
    [self.imgStar2 setImage:[UIImage imageNamed:@"star-empty"]];
    [self.imgStar3 setImage:[UIImage imageNamed:@"star-empty"]];
    [self.imgStar4 setImage:[UIImage imageNamed:@"star-empty"]];
    [self.imgStar5 setImage:[UIImage imageNamed:@"star-empty"]];
}

- (void) onStarClicked: (int) star {
    
    [self resetStars];
    self.starRating = star;
    
    switch (star) {
        case 1:
            [self.imgStar1 setImage:[UIImage imageNamed:@"star-fill"]];
            break;
            
        case 2:
            [self.imgStar1 setImage:[UIImage imageNamed:@"star-fill"]];
            [self.imgStar2 setImage:[UIImage imageNamed:@"star-fill"]];
            break;
            
        case 3:
            [self.imgStar1 setImage:[UIImage imageNamed:@"star-fill"]];
            [self.imgStar2 setImage:[UIImage imageNamed:@"star-fill"]];
            [self.imgStar3 setImage:[UIImage imageNamed:@"star-fill"]];
            break;
            
        case 4:
            [self.imgStar1 setImage:[UIImage imageNamed:@"star-fill"]];
            [self.imgStar2 setImage:[UIImage imageNamed:@"star-fill"]];
            [self.imgStar3 setImage:[UIImage imageNamed:@"star-fill"]];
            [self.imgStar4 setImage:[UIImage imageNamed:@"star-fill"]];
            break;
            
        case 5:
            [self.imgStar1 setImage:[UIImage imageNamed:@"star-fill"]];
            [self.imgStar2 setImage:[UIImage imageNamed:@"star-fill"]];
            [self.imgStar3 setImage:[UIImage imageNamed:@"star-fill"]];
            [self.imgStar4 setImage:[UIImage imageNamed:@"star-fill"]];
            [self.imgStar5 setImage:[UIImage imageNamed:@"star-fill"]];
            break;
            
        default:
            break;
    }
}

@end
