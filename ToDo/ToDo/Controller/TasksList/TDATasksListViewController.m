//
//  TDATasksListViewController.m
//  ToDo
//
//  Created by Yuriy Berdnikov on 11/1/13.
//  Copyright (c) 2013 Yuriy Berdnikov. All rights reserved.
//

#import "TDATasksListViewController.h"
#import "TDATaskViewCell.h"
#import "TDATaskEntity.h"
#import "TDATaskEntity+CellElementsLayout.h"
#import "TDADataContextProxy.h"

static NSString *cellIdentifier = @"taskCell";

@interface TDATasksListViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UITextField *newTaskTextField;

@property (nonatomic, strong) UITableView *contentTableView;
@property (nonatomic, assign) BOOL ignoreUpdates;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultController;

@end

@implementation TDATasksListViewController

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
    
    self.title = NSLocalizedString(@"Tasks List", nil);
    
    self.managedObjectContext = [[TDADataContextProxy sharedInstance] createManagedObjectContext];
    
    [self.contentTableView registerClass:[TDATaskViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    NSError *error;
	if (![self.fetchedResultController performFetch:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        
        return;
	}
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.newTaskTextField = nil;
    self.contentTableView = nil;
    self.managedObjectContext = nil;
    self.fetchedResultController = nil;
}

#pragma mark - Properties

- (UITextField *)newTaskTextField
{
    if (!_newTaskTextField)
    {
        _newTaskTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentTableView.frame) - 20.0f, 40.0f)];
        _newTaskTextField.borderStyle = UITextBorderStyleRoundedRect;
        _newTaskTextField.returnKeyType = UIReturnKeyDone;
        _newTaskTextField.delegate = self;
        _newTaskTextField.placeholder = NSLocalizedString(@"Add new task...", nil);
    }
    
    return _newTaskTextField;
}

- (UIView *)contentTableHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentTableView.frame), 60.0f)];
    headerView.backgroundColor = [UIColor clearColor];

    [headerView addSubview:self.newTaskTextField];
    self.newTaskTextField.center = CGPointMake(CGRectGetMidX(headerView.bounds), CGRectGetMidY(headerView.bounds));
    
    return headerView;
}

- (UITableView *)contentTableView
{
    if (!_contentTableView)
    {
        _contentTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _contentTableView.tableHeaderView = [self contentTableHeaderView];
        _contentTableView.tableFooterView = [[UIView alloc] init];
        _contentTableView.delegate = self;
        _contentTableView.dataSource = self;
        
        [self.view addSubview:_contentTableView];
    }
    
    return _contentTableView;
}

- (NSFetchedResultsController *)fetchedResultController
{
    if (_fetchedResultController)
        return _fetchedResultController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"modifiedDate" ascending:NO];
    NSSortDescriptor *sortByOrdering = [[NSSortDescriptor alloc] initWithKey:@"ordering" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortByOrdering, sortByDate]];
    
    [fetchRequest setFetchBatchSize:20];
    
    _fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                   managedObjectContext:self.managedObjectContext
                                                                     sectionNameKeyPath:nil
                                                                              cacheName:nil];
    _fetchedResultController.delegate = self;
    
    return _fetchedResultController;
}

#pragma mark - UIBarButton selectors

- (void)editButtonPressed:(UIBarButtonItem *)sender
{
    if (self.contentTableView.editing)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed:)];
    else
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editButtonPressed:)];
    
    [self.contentTableView setEditing:!self.contentTableView.editing animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.fetchedResultController.fetchedObjects.count;
    self.navigationItem.rightBarButtonItem.enabled = (count > 0);

    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TDATaskEntity *taskEntity = [self.fetchedResultController objectAtIndexPath:indexPath];
    
    return [taskEntity cellOptimalHeightWithWidth:CGRectGetWidth(tableView.bounds)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TDATaskViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.taskEntity = [self.fetchedResultController objectAtIndexPath:indexPath];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSInteger sourceRow = sourceIndexPath.row;
    NSInteger destRow = destinationIndexPath.row;
    
    if (sourceRow == destRow)
		return;
    
    self.ignoreUpdates = YES;
    
    NSMutableArray *tasks = [self.fetchedResultController.fetchedObjects mutableCopy];
	TDATaskEntity *taskToMove = [tasks objectAtIndex:sourceRow];
	[tasks removeObject:taskToMove];
	[tasks insertObject:taskToMove atIndex:destRow];
	
    [tasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setOrdering:@(idx)];
    }];
    
	[self.managedObjectContext save:nil];
    [[TDADataContextProxy sharedInstance] saveMainContext];
    
    self.ignoreUpdates = NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete)
        return;
    
    TDATaskEntity *taskToDelete = [self.fetchedResultController objectAtIndexPath:indexPath];
    [self.managedObjectContext deleteObject:taskToDelete];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed to delete task", nil)
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (!textField.text.length)
        return YES;
    
    // create new entity object
    TDATaskEntity *task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    task.title = textField.text;
    task.createdDate = [NSDate date];
    task.modifiedDate = task.createdDate;
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed to create task", nil)
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
        [[TDADataContextProxy sharedInstance] saveMainContext];
    
    textField.text = nil;
    
    return YES;
}

#pragma mark - NSFetchedResultsController delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (self.ignoreUpdates)
        return;
    
    [self.contentTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (self.ignoreUpdates)
        return;
    
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
            [self.contentTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.contentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.contentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.contentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.contentTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.ignoreUpdates)
        return;
    
    [self.contentTableView endUpdates];
}

@end
