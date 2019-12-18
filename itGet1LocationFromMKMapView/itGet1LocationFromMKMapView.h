//
//  itGet1LocationFromMKMapView
//  NULL
//
//  Created by foolsparadise on 4/12/2019.
//  Copyright © 2019 github.com/foolsparadise All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CLPlacemark.h>

/**
### itGet1LocationFromMKMapView
在原生地图 MKMapView delegate方式 点选一个地点 Demo for MKMapView
### Usage
import
CoreLocation.framework MapKit.framework
add
Privacy - Location Always and When In Use Usage Description
Privacy - Location When In Use Usage Description
into your Info.plist
```
#import "itGet1LocationFromMKMapView.h"
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CLPlacemark.h>
add <itGet1LocationFromMKMapViewDelegate>
code..
itGet1LocationFromMKMapView * oneLocation = [[itGet1LocationFromMKMapView alloc] init];
oneLocation.delegate = self;
[self.navigationController pushViewController:oneLocation animated:YES];
-(void)itGet1LocationFromMKMapViewDelegate:(CLLocation *)location placeMark:(CLPlacemark *)placeMark
{
 NSLog(@"%@ Current:%f,%f", location, location.coordinate.latitude, location.coordinate.longitude);
 NSLog(@"%@", placeMark);
 NSLog(@"%@", [NSString stringWithFormat:@"%@\n%@", placeMark.name, placeMark.thoroughfare]);
}
```
### MIT
 */
NS_ASSUME_NONNULL_BEGIN

@protocol itGet1LocationFromMKMapViewDelegate <NSObject>

@optional
-(void)itGet1LocationFromMKMapViewDelegate:(CLLocation *)location placeMark:(CLPlacemark *)placeMark;

@end

@interface itGet1LocationFromMKMapView : UIViewController

@property (nonatomic, weak) id<itGet1LocationFromMKMapViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
