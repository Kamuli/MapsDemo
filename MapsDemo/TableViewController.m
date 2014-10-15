//
//  TableViewController.m
//  MapsDemo
//
//  Created by Juha Näppi on 14.10.2014.
//  Copyright (c) 2014 Kamuli Software. All rights reserved.
//

#import "TableViewController.h"
#import "AppDelegate.h"

@interface TableViewController ()

@property(strong, nonatomic) NSURLSession *markerSession;
@property(copy,nonatomic) NSSet *markers;
@property(strong, nonatomic) NSMutableArray *monitoredVehicle;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // URL session
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.URLCache = [[NSURLCache alloc] initWithMemoryCapacity:10*1024*1+24 diskCapacity:20*1024*1024 diskPath:@"MaekerData"];
    self.markerSession = [NSURLSession sessionWithConfiguration:config];
    
    [self downloadMarkerData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 7;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

-(void)downloadMarkerData
{
    NSURL *vehicleURL = [NSURL URLWithString:@"http://data.itsfactory.fi/journeys/api/1/vehicle-activity"];
    NSURLSessionDataTask *task = [self.markerSession dataTaskWithURL:vehicleURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"json: %@",json);
        if (!error){
        [self createMarkerObjectsWithJson:json];
        }
    }];
    
    [task resume];
}

-(void)createMarkerObjectsWithJson:(NSDictionary *)json
{
    NSMutableSet *mutableSet = [[NSMutableSet alloc] initWithSet:self.markers];
        for (NSDictionary *vehicleData in json[@"body"])
        {
            GMSMarker *newMarker = [[GMSMarker alloc] init];
            newMarker.title = vehicleData [@"vehicleRef"];
            
            newMarker.snippet = vehicleData[@"destinationShortName"]; // tähän origin => destination !!!
            NSString *latitude = [NSString stringWithFormat:@"%@", vehicleData[@"vehicleLocation"][@"latitude"]];
            NSString *longitude = [NSString stringWithFormat:@"%@", vehicleData[@"vehicleLocation"][@"longitude"]];
            newMarker.position = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
            
            NSLog(@"%@",newMarker);
        };
    self.markers = [mutableSet copy];
    //näkyviin jonnekin
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(MMDrawerController *)drawControllerFromAppDelegate
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.drawerController;
}


@end
