//
//  ViewController.m
//  Altimeter
//
//  Created by Cheng Yao on 25/3/15.
//  Copyright (c) 2015 Cheng Yao. All rights reserved.
//

@import CoreMotion;

#import "ViewController.h"

@interface AltitudeDataItem : NSObject
@property (strong, nonatomic) CMAltitudeData *altitudeData;
@property (strong, nonatomic) NSError *error;
+ (instancetype)dataItemWithAltitudeData:(CMAltitudeData *)altitudeData error:(NSError *)error;
@end
@implementation AltitudeDataItem
+ (instancetype)dataItemWithAltitudeData:(CMAltitudeData *)altitudeData error:(NSError *)error
{
    AltitudeDataItem *dataItem = [[self alloc] init];
    dataItem.altitudeData = altitudeData;
    dataItem.error = error;
    return dataItem;
}
@end

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) CMAltimeter *altimeter;

@end

@implementation ViewController

- (void)dealloc
{
    [self.altimeter stopRelativeAltitudeUpdates];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([CMAltimeter isRelativeAltitudeAvailable]) {
        
        self.title = @"CMAltitudeData Log";
        self.items = [NSMutableArray array];
        self.altimeter = [[CMAltimeter alloc] init];
        
        __weak typeof(self)weakSelf = self;
        
        [self.altimeter startRelativeAltitudeUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAltitudeData *altitudeData, NSError *error) {
            AltitudeDataItem *dataItem = [AltitudeDataItem dataItemWithAltitudeData:altitudeData error:error];
            typeof(weakSelf) strongSelf = weakSelf;
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [strongSelf.items addObject:dataItem];
                NSIndexPath *newRow = [NSIndexPath indexPathForRow:strongSelf.items.count-1 inSection:0];
                [strongSelf.tableView beginUpdates];
                [strongSelf.tableView insertRowsAtIndexPaths:@[newRow] withRowAnimation:UITableViewRowAnimationAutomatic];
                [strongSelf.tableView endUpdates];
                [strongSelf.tableView scrollToRowAtIndexPath:newRow atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            });

        }];
    } else {
        self.title = @"M8 isn't available.";
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AltimeterCell" forIndexPath:indexPath];
    
    AltitudeDataItem *dataItem = self.items[indexPath.row];
    if (dataItem.error) {
        cell.textLabel.text = @"Error";
        cell.detailTextLabel.text = dataItem.error.localizedDescription;
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%f", dataItem.altitudeData.timestamp];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", dataItem.altitudeData.relativeAltitude, dataItem.altitudeData.pressure];
    }

    
    return cell;
}

@end
