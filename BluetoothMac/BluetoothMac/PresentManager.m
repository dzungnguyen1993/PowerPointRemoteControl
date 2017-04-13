//
//  PresentManager.m
//  BluetoothMac
//
//  Created by Thanh-Dung Nguyen on 4/12/17.
//  Copyright © 2017 Dzung Nguyen. All rights reserved.
//

#import "PresentManager.h"

static int currentSlide;
//path of slide
static NSString *presentationPath = @"";//@"/Users/md761/Documents/luanvan/thesispresentation.pptx";

@implementation PresentManager

//open presentation
+ (void)openPresentation{
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"tell application \"Microsoft PowerPoint\"\n open \"%@\"\n active presentation \n activate \n run slide show slide show settings of active presentation \n end tell",presentationPath]];

    NSDictionary *errorDict;
    NSAppleEventDescriptor *returnDescriptor = NULL;
    
    returnDescriptor = [appleScript executeAndReturnError:&errorDict];
    
    if (returnDescriptor != NULL)
    {
        currentSlide = 1;
        // successful execution
        if (kAENullEvent != [returnDescriptor descriptorType])
        {
            // script returned an AppleScript result
            if (cAEList == [returnDescriptor descriptorType])
            {
                // result is a list of other descriptors
            }
            else
            {
                // coerce the result to the appropriate ObjC type
            }
        }
    }
    else
    {
        // no script result, handle error here
    }
}

//go to next slide
+ (void)gotoNextSlide {
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"tell application \"Microsoft PowerPoint\" \n activate \n go to next slide slide show view of slide show window 1 \n end tell"];
    
    NSDictionary *errorDict;
    NSAppleEventDescriptor *descriptor = [script executeAndReturnError:&errorDict];
    
    if (descriptor != NULL)
    {
        currentSlide++;
    }
}

//go to previous slide
+ (void)gotoPreviousSlide {
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"tell application \"Microsoft PowerPoint\" \n activate \n go to previous slide slide show view of slide show window 1 \n end tell"];
    
    NSDictionary *errorDict;
    NSAppleEventDescriptor *descriptor = [script executeAndReturnError:&errorDict];
    
    if (descriptor != NULL)
    {
        currentSlide--;
    }
}

//close presentation session
+ (void)closePresentation {
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"tell application \"Microsoft PowerPoint\" \n exit slide show slideshow view of slide show window 1 \n end tell"];
    
    [script executeAndReturnError:nil];
}

//go to specific slide
+ (void)gotoSlide:(int)index
{
    //    NSString *command = [NSString stringWithFormat:@"tell application \"Microsoft PowerPoint\" \n activate \n go to slide view of document window 1 number 5 \n end tell"];
    //
    //    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:command];
    //
    //    [script executeAndReturnError:nil];
    if (index < currentSlide)
    {
        for (int i=currentSlide;i>index;i--)
        {
            [PresentManager gotoPreviousSlide];
            NSLog(@"%d", i);
        }
    }
    else if (index > currentSlide)
    {
        for (int i=currentSlide;i<index;i++)
        {
            [PresentManager gotoNextSlide];
            NSLog(@"%d", i);
        }
    }
    currentSlide = index;
}

//jump to first line
+ (void)gotoFirstSlide
{
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"tell application \"Microsoft PowerPoint\" \n activate \n go to first slide slide show view of slide show window 1 \n end tell"];
    
    NSDictionary *errorDict;
    NSAppleEventDescriptor *descriptor = [script executeAndReturnError:&errorDict];
    
    if (descriptor != NULL)
    {
        currentSlide = 1;
    }
}

//jump to last slide
+ (void)gotoLastSlide
{
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"tell application \"Microsoft PowerPoint\" \n activate \n go to last slide slide show view of slide show window 1 \n end tell"];
    
    NSDictionary *errorDict;
    NSAppleEventDescriptor *descriptor = [script executeAndReturnError:&errorDict];
    
    if (descriptor != NULL)
    {
        currentSlide = 1;
    }
}

//return number of slides
+ (int)countSlides
{
    NSString *command = [NSString stringWithFormat:@"set numberSlide to missing value \n tell application \"Microsoft PowerPoint\"\n tell active presentation \n set numberSlide to count slides \n end tell \n end tell \n return numberSlide"];
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:command];
    
    NSDictionary *errorDict;
    NSAppleEventDescriptor *returnDescriptor = NULL;
    
    returnDescriptor = [appleScript executeAndReturnError:&errorDict];
    NSData *data = [returnDescriptor data];
    int numberSlide = 0;
    [data getBytes:&numberSlide length:[data length]];
    
    return numberSlide;
}

+ (void)setFilePath:(NSString*)path {
    presentationPath = path;
}
@end
