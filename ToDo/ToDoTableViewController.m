//
//  ToDoTableViewController.m
//  ToDo
//
//  Created by Angus Huang on 1/25/14.
//  Copyright (c) 2014 Angus Huang. All rights reserved.
//

#import "ToDoTableViewController.h"
#import "EditableCell.h"

@interface ToDoTableViewController ()
- (IBAction)onAddItemClick:(UIBarButtonItem *)sender;
@property NSMutableArray *todoList;
@end

@implementation ToDoTableViewController

//==============================================================================
#pragma mark - Initializers
//==============================================================================

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.todoList = [[NSMutableArray alloc] init];
    
#warning remove this later
    [self.todoList addObject:@"Test 1"];
    [self.todoList addObject:@"Test 2"];
    [self.todoList addObject:@"Test 3"];
    [self.todoList addObject:@"Test 4"];
    
    NSLog(@"todoList.count = %d", self.todoList.count);
}

//==============================================================================
#pragma mark - Controller Lifecycle
//==============================================================================

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
#warning Not getting called
    NSLog(@"touchesBegan:withEvent:");
    
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

//==============================================================================
#pragma mark - Table View Data Source
//==============================================================================

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.todoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    EditableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    int index = indexPath.row;
    cell.editableCellTextField.text = [self.todoList objectAtIndex:index];
    cell.editableCellTextField.delegate = self;
    cell.editableCellTextField.tag = index;
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        int index = indexPath.row;
        [self.todoList removeObjectAtIndex:index];
        [self updateTagsFromIndex:index toIndex:self.todoList.count - 1];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    int fromIndex = fromIndexPath.row;
    int toIndex = toIndexPath.row;
    NSLog(@"moveRowAtIndexPath %d to %d", fromIndex, toIndex);
    
    // Remove item from underlying array.
    NSString *itemToMove = [self.todoList objectAtIndex:fromIndex];
    [self.todoList removeObjectAtIndex:fromIndex];
    
    // Insert item into new position.
    [self.todoList insertObject:itemToMove atIndex:toIndex];
    
    // Update the tags for all items that have been shifted.
    int startIndex = (fromIndex < toIndex) ? fromIndex : toIndex;
    int endIndex = (fromIndex < toIndex) ? toIndex : fromIndex;
    [self updateTagsFromIndex:startIndex toIndex:endIndex];
    
    // Reload the table view.
    [self.tableView reloadData];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

//==============================================================================
#pragma mark - UITextFieldDelegate
//==============================================================================

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidEndEditing");
    
    for (NSString *string in self.todoList) {
        NSLog(@"%@", string);
    }
    
    // Decide which text field based on it's tag and save data to the model.
    int index = textField.tag;
    NSString *item = textField.text;
    [self.todoList replaceObjectAtIndex:index withObject:item];
    
    [self.tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn");

    // Remove focus and keyboard when "Return" button is clicked.
    [textField resignFirstResponder];
    
    return NO;
}

//==============================================================================
#pragma mark - IBActions
//==============================================================================

- (IBAction)onAddItemClick:(UIBarButtonItem *)sender {

    // Create item in backing array and reload the table to reflect.
    [self.todoList addObject:@""];
    [self.tableView reloadData];
    
    // Get reference to the new cell and set focus in its TextField.
    int index = self.todoList.count - 1;
    EditableCell *cell = [self cellAtIndex:index];
    [cell.editableCellTextField becomeFirstResponder];
}

//==============================================================================
#pragma mark - Private Methods
//==============================================================================

- (EditableCell *)cellAtIndex:(NSInteger)index {
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    EditableCell *cell = (EditableCell *)[self.tableView cellForRowAtIndexPath:newIndexPath];
    
    return cell;
}

- (void)updateTagsFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {

    for (int i = fromIndex; i <= toIndex; i++) {
        [self cellAtIndex:i].tag = i;
    }
}

@end
