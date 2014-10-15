//
//  ViewController.m
//  MapsDemo
//
//  Created by Juha Näppi on 7.10.2014.
//  Copyright (c) 2014 Kamuli Software. All rights reserved.
//
// info.plist tiedostoon lisättävä NSLocationAlwaysUsageDescription tai NSLocationWhenInUseUsageDescription
// ja niille teksti tai muuten paikka on lat0.0 lon0.0
// Voi mikä bugi...

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"


@interface ViewController () <CLLocationManagerDelegate, GMSMapViewDelegate>

@property (strong, nonatomic) NSMutableArray *viewControllers;
@property (strong, nonatomic) UINavigationController *mapsNavigationController;
@property (strong, nonatomic) UINavigationController *tableNavigationController;
@property (strong, nonatomic) UINavigationController *panoramaNavigationController;


@property (nonatomic) CLLocation *lastLocation;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;

@property (strong,nonatomic) GMSMarker *myMarker;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mapView.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
    
    //   Veikkola (60.269781, 24.443061);
    
    GMSCameraPosition *camera =
    [GMSCameraPosition cameraWithLatitude:60.269781 longitude:24.443061 zoom:13];
    self.mapView.camera = camera;

    [self.view addSubview:self.mapView];
    
    if (!self.viewControllers) {
        self.viewControllers = [[NSMutableArray alloc] initWithCapacity:3];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    // Location
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    
    // IOS8 kysyttävä lupa:
    [locationManager requestAlwaysAuthorization];
    
    [locationManager startMonitoringSignificantLocationChanges];
    NSLog(@"startMonitoringSignificantLocationChanges");
    
    self.mapView.myLocationEnabled = YES;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.settings.compassButton = YES;
    self.mapView.mapType =kGMSTypeNormal;
    [self.mapView setMinZoom:5 maxZoom:18];
}

-(void)viewDidAppear:(BOOL)animated
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
        MMDrawerController *drawController = [self drawControllerFromAppDelegate];
        self.mapsNavigationController = (UINavigationController *)drawController.centerViewController;
        [self.viewControllers addObject:self.mapsNavigationController];
  
        self.tableNavigationController = (UINavigationController *)drawController.leftDrawerViewController;
        [self.viewControllers addObject:self.tableNavigationController];

        self.panoramaNavigationController = (UINavigationController *)drawController.rightDrawerViewController;
        [self.viewControllers addObject:self.panoramaNavigationController];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"didUpdateLocations");
    CLLocation *location = [locations lastObject];
    
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        self.lastLocation = location;
        [self makeGoogleMaps:location];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"LocationManager error: %@",error);
}

-(void)makeGoogleMaps:(CLLocation *)mapLocation
{
    // Create a GMSCameraPosition
    NSLog(@"Camera at latitude %+.6f, longitude %+.6f\n",
          mapLocation.coordinate.latitude,
          mapLocation.coordinate.longitude);
    GMSCameraPosition *camera =
    [GMSCameraPosition cameraWithLatitude:mapLocation.coordinate.latitude longitude:mapLocation.coordinate.longitude zoom:10];
    self.mapView = [GMSMapView mapWithFrame:self.mapView.frame camera:camera];
}

-(void)makeGoogleMapsMarker:(CLLocation *)markerLocation
{
    // Create a marker in current location
    NSLog(@"Marker at latitude %+.6f, longitude %+.6f\n",
          markerLocation.coordinate.latitude,
          markerLocation.coordinate.longitude);
    GMSMarker *marker =[[GMSMarker alloc]init];
    marker.position = CLLocationCoordinate2DMake(markerLocation.coordinate.latitude, markerLocation.coordinate.longitude);
    marker.title = @"This point marked!";
    marker.snippet = [NSString stringWithFormat:@"lat: %+.6f, lng: %+.6f",
                      markerLocation.coordinate.latitude,
                      markerLocation.coordinate.longitude];
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.icon = [UIImage imageNamed:@"map-marker"];
    marker.map = self.mapView;
}


-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"Tapped at latitude %+.6f, longitude %+.6f\n",
          coordinate.latitude,
          coordinate.longitude);
    GMSGeocoder *geocoder = [GMSGeocoder geocoder];
    [geocoder reverseGeocodeCoordinate:coordinate completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
        GMSMarker *marker =[[GMSMarker alloc]init];
        marker.position = coordinate;
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
        NSLog(@"%@ %@ %@ %@ %@ %@",response.firstResult.administrativeArea,response.firstResult.country,response.firstResult.locality,response.firstResult.subLocality,response.firstResult.postalCode,response.firstResult.thoroughfare);
        
        // taulukossa tulee kaikki tieto ja sen voisi parseroida käyttöön. Muuten tulee vain nuo kaksi tietoa:
        NSLog(@"%@",response.results);
        marker.title = response.firstResult.thoroughfare;
        marker.snippet = response.firstResult.country;
        marker.map = self.mapView;
    }];
}

-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    // Create a marker in current location
    NSLog(@"Marker at latitude %+.6f, longitude %+.6f\n",
          coordinate.latitude,
          coordinate.longitude);
    GMSMarker *marker =[[GMSMarker alloc]init];
    marker.position = coordinate;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
    marker.title = @"This point marked!";
    marker.snippet = [NSString stringWithFormat:@"lat: %+.6f, lng: %+.6f",coordinate.latitude,
                      coordinate.longitude];
    self.myMarker = marker;
    marker.map = self.mapView;
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:marker.title
                                                                   message:marker.snippet
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {}];
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete marker!"
                                                            style:UIAlertActionStyleDestructive
                                                           handler:^(UIAlertAction * action) {marker.map=nil;}];
    UIAlertAction* navigateAction = [UIAlertAction actionWithTitle:@"Navigate to marker!"
                                                           style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {[self navigateWithGoogleMaps:marker.position];}];
   
   
    [alert addAction:navigateAction];
    [alert addAction:deleteAction];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)navigateWithGoogleMaps:(CLLocationCoordinate2D)coordinate
{
    NSURL *testURL = [NSURL URLWithString:@"comgooglemaps-x-callback://"];
    if ([[UIApplication sharedApplication] canOpenURL:testURL]) {
        NSString *coordinateString = [NSString stringWithFormat:@"%f,%f",coordinate.latitude,coordinate.longitude];
        NSString *myLocationString = [NSString stringWithFormat:@"%f,%f",self.mapView.myLocation.coordinate.latitude,self.mapView.myLocation.coordinate.longitude];
        NSString *directionsRequest = [NSString stringWithFormat:@"comgooglemaps-x-callback://?saddr=%@&daddr=%@&x-success=mapsdemo://?resume=true&x-source=mapsdemo",myLocationString,coordinateString];
        NSURL *directionsURL = [NSURL URLWithString:directionsRequest];
        NSLog(@"URL request:@%@",directionsURL);
        [[UIApplication sharedApplication] openURL:directionsURL];
    } else {
        NSLog(@"Can't use comgooglemaps-x-callback:// on this device.");
    }
}


-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.mapView.padding = UIEdgeInsetsMake(10, 0, 10, 0);
}


-(bool)prefersStatusBarHidden {
    return NO;
}

-(MMDrawerController *)drawControllerFromAppDelegate
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.drawerController;
}


- (IBAction)leftBarButtonPressed:(UIBarButtonItem *)sender {
    [[self drawControllerFromAppDelegate] toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (IBAction)rightBarButtonPressed:(UIBarButtonItem *)sender {
    [[self drawControllerFromAppDelegate] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
@end

