//
//  ViewController.m
//  BluetoothMac
//
//  Created by Thanh-Dung Nguyen on 4/12/17.
//  Copyright © 2017 Dzung Nguyen. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //initialize peripheral
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    
    [_peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
}

#pragma mark - Bluetooth Handling
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    //if bluetooth is not powered on -> return
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        //initialize characteristic
        self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
        
        //initialize service
        CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID] primary:YES];
        
        //set characteristic for this service
        transferService.characteristics = @[_transferCharacteristic];
        
        //add service to peripheral
        [_peripheralManager addService:transferService];
        
        //advertise service with defined characteristic
        [_peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
//    NSLog(@"Central subscribed to characteristic %@", characteristic);
}

- (void)sendData {
    //save for future use
//    static BOOL sendingEOM = NO;
//    
//    // end of message?
//    if (sendingEOM) {
//        BOOL didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
//        
//        if (didSend) {
//            // It did, so mark it as sent
//            sendingEOM = NO;
//        }
//        // didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
//        return;
//    }
//    
//    // We're sending data
//    // Is there any left to send?
//    if (self.sendDataIndex >= self.dataToSend.length) {
//        // No data left.  Do nothing
//        return;
//    }
//    
//    // There's data left, so send until the callback fails, or we're done.
//    BOOL didSend = YES;
//    
//    while (didSend) {
//        // Work out how big it should be
//        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
//        
//        // Can't be longer than 20 bytes
//        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
//        
//        // Copy out the data we want
//        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
//        
//        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
//        
//        // If it didn't work, drop out and wait for the callback
//        if (!didSend) {
//            return;
//        }
//        
//        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
//        NSLog(@"Sent: %@", stringFromData);
//        
//        // It did send, so update our index
//        self.sendDataIndex += amountToSend;
//        
//        // Was it the last one?
//        if (self.sendDataIndex >= self.dataToSend.length) {
//            
//            // Set this so if the send fails, we'll send it next time
//            sendingEOM = YES;
//            
//            BOOL eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
//            
//            if (eomSent) {
//                // It sent, we're all done
//                sendingEOM = NO;
//                NSLog(@"Sent: EOM");
//            }
//            
//            return;
//        }
//    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    //save for broadcast data periodically
    //    [self sendData];
}

#pragma mark - Execute commands
- (void)executeCommands:(int)command
{
    switch (command) {
        case 1:
        {
            //open presentation
            [PresentManager openPresentation];
            break;
        }
        case 2:
        {
            //navigate to next slide
            [PresentManager gotoNextSlide];
            break;
        }
        case 3:
        {
            //navigate to previous slide
            [PresentManager gotoPreviousSlide];
            break;
        }
        case 4:
        {
            //close presentation
            [PresentManager closePresentation];
            break;
        }
        case 5:
        {
            //go to first slide
            [PresentManager gotoFirstSlide];
            break;
        }
        case 6:
        {
            //go to last slide
            [PresentManager gotoLastSlide];
            break;
        }
        default:
        {
            //go to specific slide
            [PresentManager gotoSlide:(command-7)];
            break;
        }
    }
}

#pragma mark - Receive request from Central
- (void)peripheralManager:(nonnull CBPeripheralManager *)peripheral didReceiveWriteRequests:(nonnull NSArray<CBATTRequest *> *)requests
{
    //receive requests from central
    CBATTRequest *request = [requests objectAtIndex:0];

    NSString *commandString = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];

    [self executeCommands:commandString.intValue];
    
    [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    NSLog(@"Received data");
    
    
    
    //just test converting nsdata to bytes and vice versa
    //convert data to bytes
    NSUInteger len = [request.value length];
    Byte *bytes = (Byte*)malloc(len);
    memcpy(bytes, [_dataToSend bytes], len);
    
    bytes[0]=6;
    
    NSData *convertData = [NSData dataWithBytes:bytes length:len];
    Byte *bytes2 = (Byte*)malloc(len);
    memcpy(bytes2, [convertData bytes], len);
    
    if (bytes2[0] == 6)
    {
        NSLog(@"Converted successfully!");
    }
}

- (IBAction)sendMessageToCentral:(id)sender {
    [PresentManager setFilePath:[_pathTextField stringValue]];
    
    NSString *command = @"4";
    _dataToSend = [command dataUsingEncoding:NSUTF8StringEncoding];
    
    self.sendDataIndex = 0;
    [self sendData];
}

@end
