//
//  ScreenShotViewController.h
//  Notella
//
//  Created by Shehryar Hussain on 3/27/13.
//  Copyright (c) 2013 Shehryar Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScreenShotViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
- (IBAction)dimiss:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backBarButton;

@end
