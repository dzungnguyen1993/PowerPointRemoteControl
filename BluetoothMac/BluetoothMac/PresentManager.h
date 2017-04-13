//
//  PresentManager.h
//  BluetoothMac
//
//  Created by Thanh-Dung Nguyen on 4/12/17.
//  Copyright © 2017 Dzung Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PresentManager : NSObject

+ (void)openPresentation;
+ (void)gotoNextSlide ;
+ (void)gotoPreviousSlide;
+ (void)closePresentation;
+ (void)gotoSlide:(int)index;
+ (void)gotoFirstSlide;
+ (void)gotoLastSlide;
+ (int)countSlides;
+ (void)setFilePath:(NSString*)path;
@end
