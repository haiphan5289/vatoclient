//
//  FCTutorialStartupPageViewController.m
//  FaceCar
//
//  Created by facecar on 11/3/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCTutorialStartupPageViewController.h"
#import "FCTutorialStartUpViewController.h"
#import "UIView+Border.h"
#import "UserDataHelper.h"

#define NO_PAGE 5

@interface FCTutorialStartupPageViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (assign, nonatomic) NSInteger index;

@end

@implementation FCTutorialStartupPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.btnContinue borderViewWithColor:[UIColor whiteColor] width:1.0f andRadius:10];
    
    FCTutorialStartUpViewController *startingViewController = [self viewControllerAtIndex:0];
    self.pageViewController = (UIPageViewController*) [[NavigatorHelper shareInstance] getViewControllerById:@"PageViewController" inStoryboard:STORYBOARD_TUTORIAL];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 60);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) finished {
    [[UserDataHelper shareInstance] cacheFinishedTutorialStartup];
    
    UIViewController *viewController = [[NavigatorHelper shareInstance] getViewControllerById:@"SplashViewController" inStoryboard:STORYBOARD_LOGIN];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)nextClicked:(id)sender {
    if (self.index >= NO_PAGE - 1) {
        [self finished];
        return;
    }
    self.index += 1;
    FCTutorialStartUpViewController *startingViewController = [self viewControllerAtIndex:self.index];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
}

- (FCTutorialStartUpViewController*)viewControllerAtIndex:(NSUInteger) index {
    
    FCTutorialStartUpViewController *childViewController = (FCTutorialStartUpViewController*)[[NavigatorHelper shareInstance] getViewControllerById:@"FCTutorialStartUpViewController" inStoryboard:STORYBOARD_TUTORIAL];
    childViewController.currentPage = index;
    return childViewController;
}

- (NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return NO_PAGE;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(FCTutorialStartUpViewController*)viewController currentPage];
    
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    [self.btnContinue setTitle:@"Tiếp tục" forState:UIControlStateNormal];
    index--;
    self.index = index;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(FCTutorialStartUpViewController*)viewController currentPage];
    index++;
    
    self.index = index;
    if (index == NO_PAGE) {
        [self.btnContinue setTitle:@"Bắt đầu" forState:UIControlStateNormal];
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

@end
