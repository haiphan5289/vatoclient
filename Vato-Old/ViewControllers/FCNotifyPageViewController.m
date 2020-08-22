//
//  FCNotifyPageViewController.m
//  FaceCar
//
//  Created by facecar on 8/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCNotifyPageViewController.h"
#import "FCNotifyViewController.h"
#import "FCGiftViewController.h"
#import "UIImageView+Helper.h"

#define NUM_OF_PAGE 2
#define BAR_HEIGHT 100
#define TAB_NOTI 0
#define TAB_GIFT 1
#define ACTIVE_COLOR [UIColor orangeColor]
#define INACTIVE_COLOR [UIColor lightGrayColor]

@interface FCNotifyPageViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *imgNoti;
@property (weak, nonatomic) IBOutlet UILabel *lblNoti;
@property (weak, nonatomic) IBOutlet UIImageView *imgGift;
@property (weak, nonatomic) IBOutlet UILabel *lblGift;

@property (strong, nonatomic) UIPageViewController* pageViewController;

@end

@implementation FCNotifyPageViewController

- (instancetype) initView {
    
    self = [self initWithNibName:@"FCNotifyPageViewController" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initPageView];
}

- (IBAction)closeClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)notifyTabClicked:(id)sender {
    UIViewController *vc = [self viewControllerAtIndex:TAB_NOTI];
    [self.pageViewController setViewControllers:@[vc]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:YES
                                     completion:nil];
}

- (IBAction)giftTabClicked:(id)sender {
    UIViewController *vc = [self viewControllerAtIndex:TAB_GIFT];
    [self.pageViewController setViewControllers:@[vc]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
}

- (void) initPageView {
    self.navigationController.navigationBar.hidden = YES;
    
    // Create page view controller
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
    self.pageViewController.dataSource = self;
    
    FCNotifyViewController *startingViewController = (FCNotifyViewController*) [self viewControllerAtIndex:TAB_NOTI];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - BAR_HEIGHT);
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

}

#pragma mark - Page View Datasource Methods
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[FCNotifyViewController class]]) {
        [self activeTab:TAB_NOTI];
        return nil;
    }
    return [self viewControllerAtIndex:TAB_NOTI];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[FCGiftViewController class]]) {
        [self activeTab:TAB_GIFT];
        return nil;
    }
    
    return [self viewControllerAtIndex:TAB_GIFT];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return NUM_OF_PAGE;
}


#pragma mark - Other Methods
- (UIViewController*) viewControllerAtIndex:(NSUInteger)index
{
    [self activeTab:index];
    
    if (index == 0) {
        FCNotifyViewController* vc = [[FCNotifyViewController alloc] initView];
        vc.homeViewModel = self.homeViewModel;
        [vc setPageVC:self];
        return vc;
    }

    UIViewController* vc = [[FCGiftViewController alloc] initView];
    [(FCGiftViewController*) vc setPageVC:self];
    [(FCGiftViewController*) vc setHomeViewModel:self.homeViewModel];
    return vc;
}

- (void) activeTab: (NSInteger) index {
    [self.imgNoti setImageColor:index == 0 ? ACTIVE_COLOR : INACTIVE_COLOR];
    [self.lblNoti setTextColor:index == 0 ? ACTIVE_COLOR : INACTIVE_COLOR];
    
    [self.imgGift setImageColor:index == 1 ? ACTIVE_COLOR : INACTIVE_COLOR];
    [self.lblGift setTextColor:index == 1 ? ACTIVE_COLOR : INACTIVE_COLOR];
}

@end
