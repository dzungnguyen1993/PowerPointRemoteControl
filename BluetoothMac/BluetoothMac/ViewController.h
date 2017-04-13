//
//  ViewController.h
//  BluetoothMac
//
//  Created by Thanh-Dung Nguyen on 4/12/17.
//  Copyright © 2017 Dzung Nguyen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SERVICES.h"
#import "PresentManager.h"

@interface ViewController : NSViewController <CBPeripheralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic *transferCharacteristic;
@property (strong, nonatomic) NSData *dataToSend;
@property (nonatomic, readwrite) NSInteger sendDataIndex;
@property (weak) IBOutlet NSTextField *pathTextField;

@end

