//
//  FCPromotionDialogView.m
//  FaceCar
//
//  Created by facecar on 9/4/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCPromotionDialogView.h"
#import "FCPromotionCollectionViewCell.h"
#import "FCWarningNofifycationView.h"
#import "FCFarePredicate.h"

#define CELL @"FCPromotionCollectionViewCell"
#define kContentHeight 390.0f

@interface FCPromotionDialogView ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *lblIndex;
@end

@implementation FCPromotionDialogView {
    void (^_detailCallback)(FCFareManifest*);
    void (^_usingCallback)(FCFareManifest*);
    
    CGRect _fromFrame;
    CGRect _targetFrame;
}

- (void) setSelectDetail:(void (^)(FCFareManifest *))callbackDetail
             selectUsing:(void (^)(FCFareManifest *))callbackUsing {

    _detailCallback = callbackDetail;
    _usingCallback = callbackUsing;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);

    [self.collectionView registerNib:[UINib nibWithNibName:CELL bundle:nil] forCellWithReuseIdentifier:CELL];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView reloadData];
    
    self.alpha = 0.1f;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.alpha = 1.0f;
                     }];
}

- (void) setListGifts:(NSArray *)listGifts {
    _listGifts = listGifts;
    self.lblIndex.hidden = listGifts.count == 0;
    
    [self.indicator stopAnimating];
    
    if (_listGifts.count == 0) {
        FCWarningNofifycationView* view = [[FCWarningNofifycationView alloc] initView];
        view.lblTitle.text = @"";
        view.bgColor = [UIColor whiteColor];
        view.messColor = [UIColor blackColor];
        [view show:self
             image:[UIImage imageNamed:@"gift-large"]
             title:@"Thông báo"
           message:@"Hiện tại chưa có chương trình khuyến mãi nào dành cho bạn."
          buttonOK:@"Đóng"
      buttonCancel:nil
          callback:^(NSInteger buttonIndex) {
              [view removeFromSuperview];
              [self hide];
          }];
    }
    else {
        self.lblIndex.text = [NSString stringWithFormat:@"1 / %ld", _listGifts.count];
    }
}

- (void) show {
    self.bgView.alpha = 0.0f;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    NSInteger targetH = kContentHeight;
    _fromFrame = CGRectMake(self.originPoint.x, self.originPoint.y, 0, 0);
    _targetFrame = CGRectMake(0, (screenSize.height - targetH)/2, screenSize.width, targetH);
    self.collectionView.frame = _fromFrame;
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.bgView.alpha = 0.8f;
                         self.collectionView.frame = _targetFrame;
                     }
                     completion:^(BOOL finished) {
                         [self layoutSubviews];
                     }];
    
    // reload layout
    [self.collectionView reloadData];
}

- (void) hide {
    [UIView animateWithDuration:0.25f
                          delay:0.1f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.bgView.alpha = 0.01f;
                         self.collectionView.alpha = 0.01f;
                         self.collectionView.frame = _fromFrame;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (IBAction)closeClicked:(id)sender {
    [self hide];
}

- (IBAction)bgClicked:(id)sender {
    [self hide];
}

#pragma mark - Collection View

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = collectionView.frame.size;
    return size;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listGifts.count;
}

- (UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FCPromotionCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL forIndexPath:indexPath];
    cell.homeViewModel = self.homeViewModel;
    cell.usingCallback = _usingCallback;
    [cell loadView:[self.listGifts objectAtIndex:indexPath.row] atIndex:indexPath.row total:self.listGifts.count];
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FCFarePredicate* gift = [self.listGifts objectAtIndex:indexPath.row];
    _detailCallback(gift);
    
    [self removeFromSuperview];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    @try {
        UICollectionViewCell *cell = [[self.collectionView visibleCells] firstObject];
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        self.lblIndex.text = [NSString stringWithFormat:@"%ld / %ld", indexPath.row + 1 , _listGifts.count];
    }
    @catch (NSException* e){}
}

@end
