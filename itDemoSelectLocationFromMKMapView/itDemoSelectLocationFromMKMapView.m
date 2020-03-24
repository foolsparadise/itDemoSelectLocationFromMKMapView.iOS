//
//  itDemoSelectLocationFromMKMapView
//  NULL
//
//  Created by foolsparadise on 4/12/2019.
//  Copyright © 2019 github.com/foolsparadise All rights reserved.
//

#import "itDemoSelectLocationFromMKMapView.h"
#define NSLog(FORMAT, ...) {\
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
[dateFormatter setDateStyle:NSDateFormatterMediumStyle];\
[dateFormatter setTimeStyle:NSDateFormatterShortStyle];\
[dateFormatter setDateFormat:@"HH:mm:ss:SSSSSS"]; \
NSString *str = [dateFormatter stringFromDate:[NSDate date]];\
fprintf(stderr, "\n%s function:%s line:%d content:%s\n", [str UTF8String], __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);\
}
#import "Masonry.h"
#import <MapKit/MapKit.h>
#import <MapKit/MKPinAnnotationView.h>
#import <CoreLocation/CoreLocation.h>

@interface itDemoSelectLocationFromMKMapView ()<MKMapViewDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic)MKMapView * xMapView;

@property (strong, nonatomic)CLLocationManager *locationmanager;//定位服务

@property (strong, nonatomic)CLLocation *yourLocation; //当前的位置

@property (strong, nonatomic)CLLocation *selectedLocation; //选择的位置
@property (strong, nonatomic)CLPlacemark *selectedPlaceMark; //选择的地理 //当前城市..等等

@end

@implementation itDemoSelectLocationFromMKMapView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //返回上一级
    UIBarButtonItem *backFromMapButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(doButtonBack)];
    self.navigationItem.leftBarButtonItem = backFromMapButtonItem;
    
    //确定这个地点
    UIBarButtonItem *confirmButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(confirmButton)];
    self.navigationItem.rightBarButtonItem = confirmButtonItem;
    
    //地图view
    self.xMapView = [MKMapView new];
    self.xMapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.xMapView.delegate = self;
    self.xMapView.showsUserLocation = YES;
    self.xMapView.showsCompass = YES;
    self.xMapView.mapType =  MKMapTypeStandard;
    [self.view addSubview:self.xMapView];
    [self.xMapView mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.mas_equalTo(self.view.mas_left).offset(0);
       make.right.mas_equalTo(self.view.mas_right).offset(0);
       make.top.mas_equalTo(self.view.mas_top).offset(0);
       make.bottom.mas_equalTo(self.view.mas_bottom).offset(0);
    }];
    
    //点击选择地点
    UITapGestureRecognizer *mTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
    [self.xMapView addGestureRecognizer:mTap];
    
    
    //判断定位功能是否打开
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog( @"Starting CLLocationManager" );
        self.locationmanager = [[CLLocationManager alloc]init];
        self.locationmanager.delegate = self;
        [self.locationmanager requestAlwaysAuthorization];
        [self.locationmanager requestWhenInUseAuthorization];

        //设置寻址精度
        self.locationmanager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        self.locationmanager.distanceFilter = 5.0;
        [self.locationmanager startUpdatingLocation];
    }
    else
    {
        NSLog( @"Cannot CLLocationManager" );
    }
 
}
- (void)tapPress:(UIGestureRecognizer*)gestureRecognizer {
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.xMapView];//这里touchPoint是点击的某点在地图控件中的位置
    NSLog(@"%@",NSStringFromCGPoint(touchPoint));
    
    // 获取长按点的坐标
    CGPoint pos = [gestureRecognizer locationInView:self.xMapView];
    // 将长按点的坐标转换为经度值、纬度值
    CLLocationCoordinate2D coord = [self.xMapView convertPoint:pos toCoordinateFromView:self.xMapView];
    self.selectedLocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
  //锚点和覆盖层

   #if 1//锚点
    // 将经度值、纬度值包装为CLLocation对象
    CLLocation *location = [[CLLocation alloc]initWithLatitude:coord.latitude longitude:coord.longitude];
    // 根据经度、纬度反向解析地址
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    //反地理编码
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
       
        if (placemarks != nil && placemarks.count >0 && error==nil) {
             // 获取解析得到的第一个地址信息
            CLPlacemark *placemark = placemarks[0];
            // 获取地址信息中的FormattedAddressLines对应的详细地址
            NSArray* addrArray = placemark
            .addressDictionary[@"FormattedAddressLines"];
            // 将详细地址拼接成一个字符串
            NSMutableString* address = [[NSMutableString alloc] init];
            for(int i = 0; i < addrArray.count; i ++){
                [address appendString:addrArray[i]];
            }
            // 创建MKPointAnnotation对象——代表一个锚点
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
            annotation.title = placemark.name;
            annotation.subtitle = address;
            annotation.coordinate = coord;
            //添加到地图
            [self.xMapView removeAnnotations:self.xMapView.annotations];
            [self.xMapView addAnnotation:annotation];
            [self.xMapView setCenterCoordinate:location.coordinate animated:YES];
            self.selectedPlaceMark = placemark.copy;
            NSLog(@"%@", self.selectedPlaceMark);
            self.title = self.selectedPlaceMark.name;
        }
        
    }];
#elif 0 //覆盖层

#endif
    
    
}
-(void)doButtonBack
{
    NSLog(@"");
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)confirmButton
{
    NSLog(@"");
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate itDemoSelectLocationFromMKMapViewDelegate:self.selectedLocation.copy placeMark:self.selectedPlaceMark.copy];
    NSLog(@"%@ 当前的纬度与经度:%f,%f", self.selectedLocation, self.selectedLocation.coordinate.latitude, self.selectedLocation.coordinate.longitude);
}
#pragma mark CoreLocation delegate (定位失败)
//定位失败后调用此代理方法
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //设置提示提醒用户打开定位服务
    NSLog(@"error");
}

#pragma mark 定位成功后则执行此代理方法
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    //旧址
    CLLocation *currentLocation = [locations lastObject];
    //打印当前的经度与纬度
    NSLog(@"%@ current:%f,%f", locations, currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    self.yourLocation = [[CLLocation alloc] initWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];

    MKCoordinateSpan theSpan; // 设置地图显示的范围，地图显示范围越小，细节越清楚
    theSpan.latitudeDelta = 0.005;
    theSpan.longitudeDelta = 0.005;
    MKCoordinateRegion theRegion;
    theRegion.center = self.locationmanager.location.coordinate;
    theRegion.span = theSpan;
    [self.xMapView setRegion:theRegion];
    [self.xMapView setCenterCoordinate:currentLocation.coordinate animated:YES];
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    //反地理编码
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks && placemarks.count > 0) {
            CLPlacemark *placemark = [placemarks firstObject];
            //self.currentCity = placemark.locality;
            NSLog(@"current:%@，%f，%f",placemark.name, placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
            self.selectedPlaceMark = placemark.copy;
            CLPlacemark *mark = [placemarks firstObject];
            // 地标名称
            NSLog(@"name %@", mark.name);
            // 街道名称
            NSLog(@"thoroughfare %@", mark.thoroughfare);
            // 街道附加信息，例如门牌号
            NSLog(@"subThoroughfare %@", mark.subThoroughfare);
            // 地级市/直辖市
            NSLog(@"locality %@", mark.locality);
            // 区/县
            NSLog(@"subLocality %@", mark.subLocality);
            // 省
            NSLog(@"administrativeArea %@", mark.administrativeArea);
            // 行政区附加信息
            NSLog(@"subAdministrativeArea %@", mark.subAdministrativeArea);
            // 邮编
            NSLog(@"postalCode %@", mark.postalCode);
            // 国家编码，中国CN
            NSLog(@"ISOcountryCode %@", mark.ISOcountryCode);
            // 国家名称
            NSLog(@"country %@", mark.country);
            // 水源/湖泊
            NSLog(@"inlandWater %@", mark.inlandWater);
            // 海洋
            NSLog(@"ocean %@", mark.ocean);
            // 景点
            NSLog(@"areasOfInterest %@", mark.areasOfInterest);
            //再重置一下界面中间位置,显示当前位置
            [self.xMapView setCenterCoordinate:placemark.location.coordinate animated:YES];
            
            NSString* startAddressString = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@",
                                            placemark.subThoroughfare, placemark.thoroughfare,
                                            placemark.postalCode, placemark.locality,
                                            placemark.administrativeArea,
                                            placemark.country];
            NSLog(@"location:%@", startAddressString);
            self.selectedPlaceMark = placemark.copy;
            NSLog(@"%@", self.selectedPlaceMark);
            self.title = self.selectedPlaceMark.name;
        }
        if(error) { }
        else
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 根据需要，获取位置成功后是否要停止定位
                [self.locationmanager stopUpdatingLocation];
                
            });
        }
    }];
    
 
}
// 画当前位置的大头针标注
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;
{
    NSLog(@"");
    MKPinAnnotationView* annotationView = (MKPinAnnotationView*)[self.xMapView dequeueReusableAnnotationViewWithIdentifier:@"annotationView"];
    if(annotationView == nil)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotationView"];
    }
    annotationView.canShowCallout = YES;
    //annotationView.pinColor = MKPinAnnotationColorRed;
    annotationView.animatesDrop = YES;
    return annotationView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
