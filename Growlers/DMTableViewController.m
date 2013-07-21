//
//  DMTableViewController.m
//  Growlers
//
//  Created by Daniel Miedema on 7/17/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMTableViewController.h"
#import "DMGrowlerTableViewCell.h"
#import "DMAboutViewController.h"

@interface DMTableViewController ()
@property (nonatomic, strong) NSArray *beers;
@property (nonatomic, strong) NSDate *lastUpdated;
- (void)loadBeers;
- (void)newBeerListing:(DMGrowlerTableViewCell *)cell;
- (void)about:(id)sender;
@end

@implementation DMTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DMGrowlerTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"growlerCell"];
    //    [[self tableView] registerNib:[UINib nibWithNibName:@"RepositoryTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Repository Cell"];

    [self loadBeers];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *info = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStyleBordered target:self action:@selector(about:)];
    self.navigationItem.leftBarButtonItem = info;
    
    // TODO: add text of last updated time
    [self.refreshControl addTarget:self action:@selector(loadBeers) forControlEvents:UIControlEventValueChanged];
    
    // This helps subliment removing the back text from a pushed view controller.
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadBeers {
    // if we're spinnin' and refreshin'
    // ... stop it.
    if (self.refreshControl.refreshing) {
        [self.refreshControl endRefreshing];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http:/76.115.252.132:8000"]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"JSON: %@", JSON);
        _beers = JSON;
        [self.tableView reloadData];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error: %@", error);
    }];
    [operation start];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _beers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"growlerCell";
    DMGrowlerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSDictionary *beer = _beers[indexPath.row];
    // Configure the cell...
    
    cell.beerName.text = beer[@"name"];
    cell.brewery.text  = beer[@"brewer"];
    cell.beerInfo.text = [NSString stringWithFormat:@"IBU: %@  ABV: %@  Growler: $%@  Growlette: $%@",
                                 beer[@"ibu"], beer[@"abv"], beer[@"growler"], beer[@"growlette"]];
//    if (indexPath.row == 1)
//        [self newBeerListing:cell];
    
    return cell;
}

- (void)newBeerListing:(DMGrowlerTableViewCell *)cell {
    // Create my base yellow color
    UIColor *yellowColor = [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:0.8];
    // Setup a width to use throughout.
    float borderWidth = 1.0f;
    
    // Set a border on the cell itself
    cell.layer.borderColor = [yellowColor CGColor];
    cell.layer.borderWidth = borderWidth;
    
    // Create another border, but inset from original
    CALayer *blurLayer = [CALayer layer];
    // maths. Set created border inside cells border
    blurLayer.frame = CGRectMake(borderWidth, borderWidth, cell.layer.frame.size.width-(borderWidth*2), cell.layer.frame.size.height-(borderWidth*2));
    blurLayer.opacity = .60f;
    blurLayer.borderWidth = borderWidth;
    blurLayer.borderColor = [yellowColor CGColor];
    // Add this one in above the cells layer (just adding works too)
    [cell.layer insertSublayer:blurLayer above:cell.layer];
    
    // Same thing, again. Make *another* border.
    CALayer *clearLayer = [CALayer layer];
    // set border inside, again.
    clearLayer.frame = CGRectMake((borderWidth*2), (borderWidth*2), cell.layer.frame.size.width-(borderWidth*2)*2, cell.layer.frame.size.height-(borderWidth*2)*2);
    clearLayer.opacity = .30f;
    clearLayer.borderWidth = borderWidth;
    clearLayer.borderColor = [yellowColor CGColor];
    // add this one too.
    [cell.layer insertSublayer:clearLayer above:cell.layer];
    
    //// Text glow, if wanted.
//    cell.beerName.layer.shadowColor = [yellowColor CGColor];
//    cell.beerName.layer.shadowRadius = 6.0f;
//    cell.beerName.layer.shadowOpacity = 1.0f;
//    cell.beerName.layer.shadowOffset = CGSizeZero;
//    cell.beerName.layer.masksToBounds = NO;
//    
//    cell.brewery.layer.shadowColor = [yellowColor CGColor];
//    cell.brewery.layer.shadowRadius = 2.0f;
//    cell.brewery.layer.shadowOpacity = 0.75f;
//    cell.brewery.layer.shadowOffset = CGSizeZero;
//    cell.brewery.layer.masksToBounds = NO;
//    
//    cell.beerInfo.layer.shadowColor = [yellowColor CGColor];
//    cell.beerInfo.layer.shadowRadius = 2.0f;
//    cell.beerInfo.layer.shadowOpacity = 0.75f;
//    cell.beerInfo.layer.shadowOffset = CGSizeZero;
//    cell.beerInfo.layer.masksToBounds = NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (void)about:(id)sender {
    DMAboutViewController *aboutView = [self.storyboard instantiateViewControllerWithIdentifier:@"DMAboutViewController"];
    [self.navigationController pushViewController:aboutView animated:YES];
}

@end
