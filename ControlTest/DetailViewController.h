//
//  DetailViewController.h
//  ControlTest
//
//  Created by Shehryar Hussain on 3/13/13.
//  Copyright (c) 2013 Shehryar Hussain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TehdaItem.h"

@interface DetailViewController : UIViewController
- (IBAction)saveDetails:(id)sender;

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) TehdaItem *tehdaItem;

@property (weak,nonatomic) IBOutlet UITextView *detailDescriptionLabel;

@end
