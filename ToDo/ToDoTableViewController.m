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

NSString *const NSUSERDEFAULTS_TODOLIST_INDEX = @"todoListIndex";

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
    // Load the saved todo list from NSUserDefaults;
    // alloc a new one if there is no saved list.
    self.todoList = [self loadFromUserDefaults];
    if (!self.todoList) {
        self.todoList = [[NSMutableArray alloc] init];
    }
    [self logTodoList];
}

//==============================================================================
#pragma mark - UIViewController
//==============================================================================

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

//==============================================================================
#pragma mark - UITableViewDataSource
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
    cell.textView.text = [self.todoList objectAtIndex:index];
    cell.textView.delegate = self;
    cell.textView.tag = index;
    
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
        
        [self saveToUserDefaults];
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
    [self saveToUserDefaults];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

//==============================================================================
#pragma mark - UITableViewDelegate
//==============================================================================

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // NSLog(@"heightForRowAtIndexPath %d : %@", indexPath.row, [self.todoList objectAtIndex:indexPath.row]);
    
    int index = indexPath.row;
    NSString *item = [self.todoList objectAtIndex:index];
    
    CGFloat width = self.tableView.frame.size.width - 30;
    CGSize size = CGSizeMake(width, MAXFLOAT);
    UIFont *font = [UIFont systemFontOfSize:14];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    CGRect boundingRect = [item boundingRectWithSize:size
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:attributes
                                             context:nil];
    
    // NSLog(@"boundingRect = (%f, %f", boundingRect.size.width, ceil(boundingRect.size.height));
    
    return ceil(boundingRect.size.height) + 30;
}

//==============================================================================
#pragma mark - UITextViewDelegate
//==============================================================================

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"textViewDidEndEditing");
    
    // Decide which text field based on it's tag and save data to the model.
    int index = textView.tag;
    NSString *item = textView.text;
    [self.todoList replaceObjectAtIndex:index withObject:item];
    
    [self saveToUserDefaults];
    
    // Reload this row to properly size the cell.
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // NSLog(@"shouldChangeTextInRange");
    
    // Check if new text added is the Done key...
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO; // Return false so last "\n" doesn't get added
    }
    
    return YES;
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
    [cell.textView becomeFirstResponder];
    
    [self saveToUserDefaults];
}

//==============================================================================
#pragma mark - Private Methods
//==============================================================================

- (EditableCell *)cellAtIndex:(NSInteger)index
{
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    EditableCell *cell = (EditableCell *)[self.tableView cellForRowAtIndexPath:newIndexPath];
    
    return cell;
}

- (void)updateTagsFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    for (int i = fromIndex; i <= toIndex; i++) {
        [self cellAtIndex:i].tag = i;
    }
}

- (void)saveToUserDefaults
{
    NSLog(@"*** saveToUserDefaults ***");
    [self logTodoList];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.todoList forKey:NSUSERDEFAULTS_TODOLIST_INDEX];
    [defaults synchronize];
}

- (NSMutableArray *)loadFromUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:NSUSERDEFAULTS_TODOLIST_INDEX];
}

- (void)logTodoList
{
    for (NSString *string in self.todoList) {
        NSLog(@"%@", string);
    }
}

@end
