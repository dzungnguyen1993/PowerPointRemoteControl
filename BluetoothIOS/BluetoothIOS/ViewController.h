//
//  ViewController.h
//  BluetoothIOS
//
//  Created by Thanh-Dung Nguyen on 4/12/17.
//  Copyright © 2017 Dzung Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SERVICES.h"

@interface ViewController : UIViewController <UITextFieldDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>

@property (weak, nonatomic) IBOutlet UITextField *slideTextField;

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData *data;
@property (strong, nonatomic) CBCharacteristic *characteristic;

@end

