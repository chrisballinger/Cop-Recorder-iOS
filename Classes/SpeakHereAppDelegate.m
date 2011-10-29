/*

    File: SpeakHereAppDelegate.m
Abstract: Application delegate for SpeakHere
 Version: 2.4

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2009 Apple Inc. All Rights Reserved.


*/

#import "SpeakHereAppDelegate.h"
#import "SpeakHereViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Recording.h"

@implementation SpeakHereAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize navController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {

    navController = [[UINavigationController alloc] initWithRootViewController:viewController];

    navController.navigationBarHidden = YES;

    [window addSubview:navController.view];

    // Override point for customization after app launch
    [window makeKeyAndVisible];

    CLLocationManager *manager = [[CLLocationManager alloc] init];

    BOOL locationAccessAllowed = NO ;
    if( [CLLocationManager instancesRespondToSelector:@selector(locationServicesEnabled)] )
    {
        // iOS 3.x and earlier
        locationAccessAllowed = manager.locationServicesEnabled ;
    }
    else if( [CLLocationManager respondsToSelector:@selector(locationServicesEnabled)] )
    {
        // iOS 4.x
        locationAccessAllowed = [manager locationServicesEnabled] ;
    }

    if (locationAccessAllowed == NO) {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled. If you proceed, you will be asked to confirm whether location services should be reenabled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
        [servicesDisabledAlert release];
    }
    [manager release];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"]; //3

    NSFileManager *fileManager = [NSFileManager defaultManager];


    if (![fileManager fileExistsAtPath: path]) //4
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]; //5

        [fileManager copyItemAtPath:bundle toPath: path error:nil]; //6

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome, new Watcher!" message:@"Whenever you think you are about to interact with an authority figure or a person in a position of power, start Cop Recorder and press Record. \n\nThis app will allow you to submit a recording, description, and location to OpenWatch.net.\n\nIf you record audio in Stealth Mode, the screen will go black while recording. When the encounter is over, simply close the application and it will stop the recording. On the next launch it will ask you if you'd like to load your unsubmitted recording. After loading you can preview the recording and submit it to OpenWatch.\n\nFor best audio quality, put the phone in your front shirt pocket, or on a nearby table with the microphone facing upwards.\n\nWhen uploading, please describe the incident. It will be reviewed by the editors and quickly published to OpenWatch.net. If you request, we will remove all of the personally identifiable information we can. No logs are kept on the server.\n\nAll uploads are released under the Creative-Commons-Attribution license.\n\nCourage is contagious!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }

    NSString *legacyFilePath = [documentsDirectory stringByAppendingPathComponent:@"recordedFile.caf"];
    if([fileManager fileExistsAtPath:legacyFilePath])
    {
        NSError *error;
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:legacyFilePath error:&error];
        NSDate *creationDate = [attributes objectForKey:NSFileCreationDate];
        NSString *newName = [NSString stringWithFormat:@"%d.caf",(int)[creationDate timeIntervalSince1970]];
        NSString *newPath = [documentsDirectory stringByAppendingPathComponent:newName];
        NSURL *url = [NSURL URLWithString:newPath];


        [fileManager moveItemAtPath:legacyFilePath toPath:newPath error:&error];

        Recording *recording = [Recording recordingWithName:@"" publicDescription:@"" privateDescription:@"" location:@"" date:creationDate url:url];
        [recording saveMetadata];
    }

    NSDirectoryEnumerator *direnum = [fileManager enumeratorAtPath:documentsDirectory];
    Recording *newRecording;

    NSString *filename;
    BOOL foundUnsubmittedFile = NO;

    while ((filename = [direnum nextObject] ) && !foundUnsubmittedFile)
    {
        if ([filename hasSuffix:@".audio.plist"])
        {
            newRecording = [Recording recordingWithFile:filename];
            if(!newRecording.isSubmitted)
                foundUnsubmittedFile = YES;
            //[newRecording release];
        }
    }
    if(foundUnsubmittedFile)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unsubmitted Recording Found!" message:@"Would you like to view your unsubmitted recordings?" delegate:navController.topViewController cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
        [alert release];
    }

    [fileManager release];
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
