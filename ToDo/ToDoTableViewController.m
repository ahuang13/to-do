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
    NSLog(@"BEFORE: self.todoList.count = %d", self.todoList.count);

    int index = indexPath.row;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.todoList removeObjectAtIndex:index];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        [self.todoList insertObject:@"Insert Test" atIndex:index];
        NSLog(@"commitEditingStyle:insert");
        NSLog(@"AFTER: self.todoList.count = %d", self.todoList.count);
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSInteger fromIndex = fromIndexPath.row;
    NSInteger toIndex = toIndexPath.row;
    [self.todoList exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

//==============================================================================
#pragma mark - IBActions
//==============================================================================

- (IBAction)onAddItemClick:(UIBarButtonItem *)sender {
    NSLog(@"onAddItemClick");
}
@end
