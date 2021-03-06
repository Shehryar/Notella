//
//  MasterViewController.m
//  ControlTest
//
//  Created by Shehryar Hussain on 3/13/13.
//  Copyright (c) 2013 Shehryar Hussain. All rights reserved.
//

#import "MasterViewController.h"
#import "MCSwipeTableViewCell.h"
#import "DetailViewController.h"
#import "TehdaItem.h"
#import "TehdaLabel.h"

@interface MasterViewController () <MCSwipeTableViewCellDelegate> {
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MasterViewController {
    TehdaLabel *_itemLabel;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    
    NSDictionary *navBarAppearance = @{UITextAttributeTextColor: [UIColor colorWithRed:(85.0/255.0) green:(85.0/255.0) blue:(85.0/255.0) alpha:1.0],
                                       UITextAttributeFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0]
                                       };
    
    
    self.navigationController.navigationBar.titleTextAttributes = navBarAppearance;
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:(243.0/255.0) green:(243.0/255.0) blue:(243.0/255.0) alpha:1.0];
    NSDictionary *buttonAp = @{UITextAttributeFont: [UIFont fontWithName:@"HelveticaNeue" size:13.0]};
    //self.helpButton.title = @"Help!";
    [self.helpButton setTitleTextAttributes:buttonAp forState:UIControlStateNormal];
    self.navigationController.navigationItem.backBarButtonItem.tintColor = [UIColor colorWithRed:(93.0/255.0) green:(93.0/255.0) blue:(93.0/255.0) alpha:1.0];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.    
    
    TehdaItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"TehdaItem" inManagedObjectContext:context];
    
    // Uses the the cell's reuse identifier to bring the textfield into edit mode right when the cell is added
    MCSwipeTableViewCell *editCell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if ([item.itemTitle isEqual: @""]) {
        [editCell.itemLabel becomeFirstResponder];
    }
    
    [_itemLabel becomeFirstResponder];
    
    [item setValue:[NSDate date] forKey:@"itemDate"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Whoops! Something went wrong" message:@"Could have sworn I flipped the right switch" delegate:self cancelButtonTitle:@"Try restarting the app" otherButtonTitles:nil, nil];
        [alert show];
        //abort();
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (MCSwipeTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];

    if (!cell)
    {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    // For the delegate callback
    [cell setDelegate:self];
    
    [cell setFirstStateIconName:@"okay_light.png"
                     firstColor:[UIColor colorWithRed:85.0/255.0 green:213.0/255.0 blue:80.0/255.0 alpha:1.0]
            secondStateIconName:nil
                    secondColor:nil
                  thirdIconName:@"remove_light.png"
                     thirdColor:[UIColor colorWithRed:232.0/255.0 green:61.0/255.0 blue:14.0/255.0 alpha:1.0]
                 fourthIconName:nil
                    fourthColor:nil];

    
    //See if you can make it so swiping right is green and swiping left is red
    
    // We need to set a background to the content view of the cell
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
   
    // Setting the type of the cell
    [cell setMode:MCSwipeTableViewCellModeExit];
    
    cell.itemLabel.delegate = self;

    
    return cell;
}

#pragma mark - delete function
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode
{
    NSLog(@"IndexPath : %@ - MCSwipeTableViewCellState : %d - MCSwipeTableViewCellMode : %d", [self.tableView indexPathForCell:cell], state, mode);
    
    if (mode == MCSwipeTableViewCellModeExit) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Whoops! Something went wrong" message:@"Could have sworn I flipped the right switch" delegate:self cancelButtonTitle:@"Try restarting the app" otherButtonTitles:nil, nil];
            [alert show];
            //abort();
        }

    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TehdaItem *item = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        DetailViewController *dvc = (DetailViewController *)[segue destinationViewController];
        [dvc setTehdaItem:item];
        
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TehdaItem" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemDate" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Whoops! Something went wrong" message:@"Could have sworn I flipped the right switch" delegate:self cancelButtonTitle:@"Try restarting the app" otherButtonTitles:nil, nil];
        [alert show];
        //abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 /*
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
*/

- (void)configureCell:(MCSwipeTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    TehdaItem *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.itemLabel.text = object.itemTitle;
    
    if (cell.itemLabel.text == nil) {
        [cell.itemLabel becomeFirstResponder];
        
        [_addButton setEnabled:NO];

    }
    
    
}


#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    // Put some code here so that the textfield doesn't start editing if you push on the side of the cell on a button or something
    // need to segue to the detail view controller
    
    //[_addButton setEnabled:NO];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    MCSwipeTableViewCell *cell = (MCSwipeTableViewCell *) textField.superview.superview;
    
    // If app breaks look at the Evernote note and revert the changes
    // MCSwipeTableViewCell *cell = (MCSwipeTableViewCell *) textField.superview;
    TehdaItem *item = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    
    
    item.itemTitle = cell.itemLabel.text;
    [_addButton setEnabled:YES];
    
    if ([cell.itemLabel.text isEqual: @""]) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]]];
    }
    
    
    NSError *error;
    [item.managedObjectContext save:&error];
    
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Whoops! Something went wrong" message:@"Could have sworn I flipped the right switch" delegate:self cancelButtonTitle:@"Try restarting the app" otherButtonTitles:nil, nil];
        [alert show];
        //abort();
	}
     
}











@end
