//
//  ViewController.m
//  BluetoothIOS
//
//  Created by Thanh-Dung Nguyen on 4/12/17.
//  Copyright © 2017 Dzung Nguyen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //initialize CBCentralManager
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _data = [[NSMutableData alloc] init];
}

#pragma mark - Bluetooth Handling

//update state
- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central
{
    //test all state
    if (central.state != CBCentralManagerStatePoweredOn)
    {
        return;
    }
    
    //if state == poweredOn
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        //scan for devices with specific UUID
        [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
        
        NSLog(@"Scanning started");
    }
}

- (void)centralManager:(nonnull CBCentralManager *)central didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral advertisementData:(nonnull NSDictionary<NSString *,id> *)advertisementData RSSI:(nonnull NSNumber *)RSSI
{
    //if first discovered peripheral
    if (_discoveredPeripheral != peripheral)
    {
        _discoveredPeripheral = peripheral;
        
        //connect to peripheral
        [_centralManager connectPeripheral:peripheral options:nil];
        NSLog(@"Connected");
    }
}

- (void)centralManager:(nonnull CBCentralManager *)central didFailToConnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error
{
    //fail to connect
    [self cleanup];
}

- (void)cleanup {
    
    // See if we are subscribed to a characteristic on the peripheral
    if (_discoveredPeripheral.services != nil) {
        for (CBService *service in _discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            [_discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            return;
                        }
                    }
                }
            }
        }
    }
    
    [_centralManager cancelPeripheralConnection:_discoveredPeripheral];
}

//peripheral connected
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //stop scanning
    [_centralManager stopScan];
    
    //reset data
    [_data setLength:0];
    
    peripheral.delegate = self;
    
    //discover for specific services
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        [self cleanup];
        return;
    }
    
    //discover characteristics of services
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
    }
    // Discover other characteristics
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        [self cleanup];
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            self.characteristic = characteristic;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error");
        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    // Have we got everything we need?
    if ([stringFromData isEqualToString:@"EOM"]) {
        
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        
        [_centralManager cancelPeripheralConnection:peripheral];
        
//        [self executeCommands:[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding]];
    }
    
    [_data appendData:characteristic.value];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
        return;
    }
    
    if (characteristic.isNotifying) {

    } else {
        // Notification has stopped
        [_centralManager cancelPeripheralConnection:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    _discoveredPeripheral = nil;
    
    [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_centralManager stopScan];
}

#pragma mark - Send data to client
- (void)sendMessageToPeripheral:(NSString*)command
{
    NSData *data2Send = [command dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.discoveredPeripheral writeValue:data2Send forCharacteristic:_characteristic type:CBCharacteristicWriteWithResponse];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    NSLog(@"Hello");
}

#pragma mark - Execute Commands
- (IBAction)openPresentation:(id)sender {
    NSString *command = @"1";
    [self sendMessageToPeripheral:command];
}

- (IBAction)gotoNextSlide:(id)sender {
    NSString *command = @"2";
    [self sendMessageToPeripheral:command];
}

- (IBAction)gotoPreviousSlide:(id)sender {
    NSString *command = @"3";
    [self sendMessageToPeripheral:command];
}

- (IBAction)closePresentation:(id)sender {
    NSString *command = @"4";
    [self sendMessageToPeripheral:command];
}

- (IBAction)gotoSlide:(id)sender {
    int index = [self.slideTextField.text intValue];
    index+=7;
    
    NSString *command = [NSString stringWithFormat:@"%d",index];
    
    [self sendMessageToPeripheral:command];
}

- (IBAction)gotoFirstSlide:(id)sender {
    NSString *command = @"5";
    [self sendMessageToPeripheral:command];
}

- (IBAction)gotoLastSlide:(id)sender {
    NSString *command = @"6";
    [self sendMessageToPeripheral:command];
}

#pragma mark - Keyboard Handling
//hide keyboard when tap return button
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
