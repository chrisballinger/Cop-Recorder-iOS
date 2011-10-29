/*

 File: SpeakHereController.h
 Abstract: Class for handling user interaction and file record/playback
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "AQPlayer.h"
#import "AQRecorder.h"
#import "CoreLocationController.h"
#import "Recording.h"

@interface SpeakHereController : NSObject <CoreLocationControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate> {

	IBOutlet UIBarButtonItem*	btn_record;
	IBOutlet UIBarButtonItem*	btn_play;
    IBOutlet UIBarButtonItem*   btn_send;

	IBOutlet UILabel*			fileDescription;

	AQPlayer*					player;
	AQRecorder*					recorder;
    CoreLocationController*     CLController;

    NSString*                   str_location;

	BOOL						playbackWasInterrupted;
    UITextField *txtName;
    UITextField *txtPrivate;
    UITextField *txtPublic;
    UISwitch *useLocation;
    UILabel *lblName;
    UILabel *lblPriv;
    UILabel *lblPub;
    UILabel *lblLoc;
	BOOL						playbackWasPaused;

	CFStringRef					recordFilePath;
    BOOL                        backgroundSupported;
    UIProgressView *progressView;
    UISwitch *useStealth;
    UIImageView *img_black;
    UIToolbar *toolbar;
    UIButton *btn_info;

    NSString* currentFileName;
    UILabel *recordButtonLabel;

    Recording *recording;
}


@property (nonatomic, retain) IBOutlet UILabel *recordButtonLabel;

@property (nonatomic, retain)     NSString* currentFileName;
@property (nonatomic, retain)	UIBarButtonItem		*btn_record;
@property (nonatomic, retain)	UIBarButtonItem		*btn_play;
@property (nonatomic, retain)   UIBarButtonItem     *btn_send;
@property (nonatomic, retain)	UILabel				*fileDescription;
@property (nonatomic, retain) IBOutlet UILabel *lblName;
@property (nonatomic, retain) IBOutlet UILabel *lblPriv;
@property (nonatomic, retain) IBOutlet UILabel *lblPub;
@property (nonatomic, retain) IBOutlet UILabel *lblLoc;

//@property (nonatomic, retain) NSString*             str_location;

@property (readonly)			AQPlayer			*player;
@property (readonly)			AQRecorder			*recorder;
@property (nonatomic, retain) CoreLocationController *CLController;

@property						BOOL				playbackWasInterrupted;
@property (nonatomic, retain) IBOutlet UITextField *txtName;
@property (nonatomic, retain) IBOutlet UITextField *txtPrivate;
@property (nonatomic, retain) IBOutlet UITextField *txtPublic;
@property (nonatomic, retain) IBOutlet UISwitch *useLocation;
@property                       BOOL                backgroundSupported;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) IBOutlet UISwitch *useStealth;
@property (nonatomic, retain) IBOutlet UIImageView *img_black;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIButton *btn_info;


- (IBAction)record: (id) sender;
- (IBAction)play: (id) sender;
- (IBAction)send:(id)sender;
- (IBAction)locationToggle:(id)sender;
- (IBAction)info:(id)sender;

- (void) drawBlack;
- (void) showTutorial;

@end
