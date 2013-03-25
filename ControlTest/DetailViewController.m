//
//  DetailViewController.m
//  ControlTest
//
//  Created by Shehryar Hussain on 3/13/13.
//  Copyright (c) 2013 Shehryar Hussain. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController
@synthesize tehdaItem = _tehdaItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize dateLabel = _dateLabel;
@synthesize titleLabel = _titleLabel;

#pragma mark - Managing the detail item


- (void)configureView
{
    // Update the user interface for the detail item.
    self.detailDescriptionLabel.text = _tehdaItem.itemDetails;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    //[dateFormatter stringFromDate:_tehdaItem.itemDate];
    NSString *dateString = [dateFormatter stringFromDate:_tehdaItem.itemDate];
    
    _dateLabel.text = dateString;
    
    _titleLabel.text = _tehdaItem.itemTitle;
    }

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





- (IBAction)saveDetails:(id)sender {
    [self.tehdaItem setItemDetails:[_detailDescriptionLabel text]];
    
    NSError *error = nil;
    if (![self.tehdaItem.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Whoops! Something went wrong" message:@"Could have sworn I flipped the right switch" delegate:self cancelButtonTitle:@"Try restarting the app" otherButtonTitles:nil, nil];
        [alert show];
        //abort();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
