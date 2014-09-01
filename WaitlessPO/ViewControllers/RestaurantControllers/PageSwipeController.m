//
//  PageSwipeController.m
//  WaitlessPO
//
//  Created by SSASOFT on 1/6/14.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import "PageSwipeController.h"
#import "RestaurantDetailsViewController.h"
#import "RestaurantModel.h"
#import "MFSideMenu.h"

@interface PageSwipeController ()

-(RestaurantDetailsViewController*)viewControllerAtIndex:(int)index;

@end

@implementation PageSwipeController

@synthesize pageController;
@synthesize selectedIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    restaurantList = [NSMutableArray array];
    [restaurantList addObjectsFromArray:[AppInfo sharedInfo].restaurantsList];
    [restaurantList addObjectsFromArray:[AppInfo sharedInfo].yelpRestaurantsList];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.delegate = self;
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    RestaurantDetailsViewController *initialViewController = [self viewControllerAtIndex:selectedIndex];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    [self.view bringSubviewToFront:topbarView];
    topbarView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
}

-(void)reloadPromotions {
    
    for (UIViewController *vc in self.pageController.viewControllers) {
        RestaurantDetailsViewController *restaurantVC = (RestaurantDetailsViewController*)vc;
        [restaurantVC reloadPromotions];
    }
}

#pragma mark 
#pragma mark Private Methods

- (RestaurantDetailsViewController*)viewControllerAtIndex:(int)index {
    
    id restaurantObj = [restaurantList objectAtIndex:index];
    RestaurantDetailsViewController *restaurantVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"RestaurantDetailsViewController"];
    restaurantVC.pageController = self;
    restaurantVC.selectedIndex = index;
    if ([restaurantObj isKindOfClass:[RestaurantModel class]]) {
        restaurantVC.isYelpRestaurant = NO;
        [restaurantVC setRestaurantModel:restaurantObj];
    }
    else {
        restaurantVC.isYelpRestaurant = YES;
        [restaurantVC setRestaurantData:restaurantObj];
    }
    
    return restaurantVC;
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)backAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark
#pragma mark UIPageViewControllerDelegate Methods

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    
//    RestaurantDetailsViewController *restaurantVC = (RestaurantDetailsViewController*)[pendingViewControllers lastObject];
//    NSLog(@"%@", [restaurantVC getRestaurantTitle]);
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    title_lbl.text = [(RestaurantDetailsViewController*)viewController getRestaurantTitle];
    int index = [(RestaurantDetailsViewController*)viewController selectedIndex];
    if (index == 0) {
        return nil;
    }
    // Decrease the index by 1 to return
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    title_lbl.text = [(RestaurantDetailsViewController*)viewController getRestaurantTitle];
    int index = [(RestaurantDetailsViewController*)viewController selectedIndex];
    index++;
    if (index == [restaurantList count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

@end
