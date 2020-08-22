//
//  FCMainFooterView.m
//  FaceCar
//
//  Created by facecar on 12/6/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCMainFooterView.h"
#import "FCBookViewModel.h"

@implementation FCMainFooterView {
    NSInteger _currentIndex;
}

- (id) init {
    self = [super init];
    
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    if (self.isShadow) {
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(-2, -2);
    }
}

- (void) setHomeViewModel:(FCHomeViewModel *)homeViewModel {
    _homeViewModel = homeViewModel;
    
    [self initCartypeView];
}

- (void) initCartypeView {
    self.cartypeScrollView = [[PWParallaxScrollView alloc] initWithFrame:CGRectMake(0, 10, [UIScreen mainScreen].bounds.size.width, self.bounds.size.height - 145)];
    self.cartypeScrollView.backgroundColor = [UIColor clearColor];
    [self insertSubview:self.cartypeScrollView atIndex:0];
    
    [[RACObserve(self.homeViewModel, listProduct) takeUntilBlock:^BOOL(NSMutableArray* list) {
        if (list.count > 0) {
            self.listService = list;
            
            [self reloadCartypeData];
            [self moveToCurrentService];
        }
        return list.count > 0;
    }] subscribeNext:^(NSMutableArray* list) {
        
    }];
}

- (void) reloadCartypeData {
    self.cartypeScrollView.delegate = self;
    self.cartypeScrollView.dataSource = self;
}

- (void) reloadNextPrevButton: (NSInteger) currentPage {
    if (currentPage == 0) {
        self.btnNext.hidden = NO;
        self.btnPrev.hidden = YES;
    }
    else if (currentPage == self.listService.count-1) {
        self.btnNext.hidden = YES;
        self.btnPrev.hidden = NO;
    }
    else {
        self.btnNext.hidden = NO;
        self.btnPrev.hidden = NO;
    }
}

- (IBAction)onNextClicked:(id)sender {
    if (_currentIndex >= self.listService.count-1) {
        return;
    }
    
    [self.cartypeScrollView moveToIndex:_currentIndex+1];
}

- (IBAction)onPrevClicked:(id)sender {
    if (_currentIndex <= 0) {
        return;
    }
    
    [self.cartypeScrollView moveToIndex:_currentIndex-1];
}

- (void) moveToCurrentService {
    FCMCarType* currService = self.homeViewModel.bookViewModel.serviceSelected;
    int _prodIndex = 0;
    for (FCService* prod in self.listService) {
        for (FCMCarType* ser in prod.cartypes) {
            if (ser.id == currService.id) {
                _currentIndex = _prodIndex;
                [self reloadNextPrevButton:_prodIndex];
                
                [self.cartypeScrollView moveToIndex:_prodIndex];
                return;
            }
        }
        _prodIndex++;
    }
}

- (NSInteger)numberOfItemsInScrollView:(PWParallaxScrollView *)scrollView {
    return self.listService.count;
}

- (UIView*) backgroundViewAtIndex:(NSInteger)index scrollView:(PWParallaxScrollView*) scrollView
{
    ServiceCollectionViewCell* view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ServiceCollectionViewCell class])
                                                                     owner:self
                                                                   options:nil] firstObject];
    view.homeViewModel = self.homeViewModel;
    
    if (self.listService.count > index) {
        FCService* service = [self.listService objectAtIndex:index];
        [view loadService:service];
    }

    return view;
}

- (UIView*) foregroundViewAtIndex:(NSInteger)index scrollView:(PWParallaxScrollView *)scrollView {
    FCService* service = [self.listService objectAtIndex:index];
    UIView* view = [[UIView alloc] init];
    
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width/3), 0, ([UIScreen mainScreen].bounds.size.width/3), 15)];
        [label setTextColor:[UIColor blackColor]];
        [label setFont:[UIFont systemFontOfSize:16.0f]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setText:service.name];
        [view addSubview:label];
    }
    
    return view;
}

- (void) parallaxScrollView:(PWParallaxScrollView *)scrollView didChangeIndex:(NSInteger)index {
    _currentIndex = index;
    [self reloadNextPrevButton:index];
    ServiceCollectionViewCell* view = (ServiceCollectionViewCell*) [scrollView getViewAtIndex:index];
    [view setCurrentSerivceSelected];
}

@end
