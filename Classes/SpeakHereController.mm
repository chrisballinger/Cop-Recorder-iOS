//
/*

 File: SpeakHereController.mm
 Abstract: n/a
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

#import "SpeakHereController.h"
#import "ASIFormDataRequest.h"
#import "Recording.h"

@implementation SpeakHereController

@synthesize player;
@synthesize recorder;
@synthesize CLController;

//@synthesize str_location;

@synthesize btn_record;
@synthesize btn_play;
@synthesize btn_send;

@synthesize fileDescription;
@synthesize playbackWasInterrupted;
@synthesize txtName;
@synthesize txtPrivate;
@synthesize txtPublic;
@synthesize useLocation;
@synthesize lblName;
@synthesize lblPriv;
@synthesize lblPub;
@synthesize lblLoc;
@synthesize backgroundSupported;
@synthesize progressView;
@synthesize useStealth;
@synthesize img_black;
@synthesize toolbar;
@synthesize btn_info;

@synthesize recordButtonLabel;
@synthesize currentFileName;

char *OSTypeToStr(char *buf, OSType t)
{
	char *p = buf;
	char str[4], *q = str;
	*(UInt32 *)str = CFSwapInt32(t);
	for (int i = 0; i < 4; ++i) {
		if (isprint(*q) && *q != '\\')
			*p++ = *q++;
		else {
			sprintf(p, "\\x%02x", *q++);
			p += 4;
		}
	}
	*p = '\0';
	return buf;
}

-(void)setFileDescriptionForFormat: (CAStreamBasicDescription)format withName:(NSString*)name
{
	char buf[5];
	const char *dataFormat = OSTypeToStr(buf, format.mFormatID);
	NSString* description = [[NSString alloc] initWithFormat:@"(%d ch. %s @ %g Hz)", format.NumberChannels(), dataFormat, format.mSampleRate, nil];
	fileDescription.text = description;
	[description release];
}

-(void)showTutorial
{

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)locationUpdate:(CLLocation *)location {
    recording.location = [NSString stringWithFormat:@"%f, %f",location.coordinate.latitude, location.coordinate.longitude];
    [recording saveMetadata];
    //[str_location retain];
    //NSLog(str_location);
    [CLController.locMgr stopUpdatingLocation];
}

- (void)locationError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Error!" message:@"Cannot retreive location. This may be because you have disabled the service." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
    [useLocation setOn:NO];
}

- (IBAction)locationToggle:(id)sender
{
    if(useLocation.on)
    {
        CLController = [[CoreLocationController alloc] init];
        CLController.delegate = self;
        [CLController.locMgr startUpdatingLocation];
    }
    else
        [CLController release];
}

- (IBAction)info:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"About Cop Recorder" message:@"Cop Recorder is a subproject of OpenWatch. OpenWatch is a participatory citizen media project aiming to provide documentary evidence of uses and abuses of power.\n\nUntil now, surveillance technology has only been in the hands of those who are already in power, which means it cannot be used to combat the largest problem facing modern society: abuse of power.\n\nSo the question remains: Who watches the watchers? \n\nThis is where OpenWatch comes in. Now, we are all opportunistic journalists. Whenever any of us come in contact with power being used or abused, we can capture it and make it become part of the public record. If we seek truth and justice, we will be able to appeal to documentary evidence, not just our word against theirs. Ideally, this will mean less corruption, more open government and a more transparent society.\n\nOpenWatch is not only intended to display abuse of power, but also to highlight appropriate use. As we are unbound by technological restrictions, we can aim to record every single time power is applied so that we may analyze global trends and provide a record for future historians.\n\nPolice, corporate executives, judges, lawyers, private security agents, lobbyists, bankers, principals and politicians: be mindful! We are watching! \n\n\nCop Recorder is Free and Open Source Software. More information is available at OpenWatch.net\n\nWarning: Use of this program is subject to local laws and regulations. The author is not responsible for any unauthorized use of this program." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

// Draw black rect in stealth mode
-(void)drawBlack
{
    /*StealthModeViewController *stealthController = [[StealthModeViewController alloc] init];
    [self.navigationController pushViewController:stealthController animated:YES];
    [stealthController release];*/

    img_black.hidden = NO;
}


#pragma mark Playback routines

-(void)stopPlayQueue
{
	player->StopQueue();
	btn_record.enabled = YES;
}

-(void)pausePlayQueue
{
	player->PauseQueue();
	playbackWasPaused = YES;
}




- (void)stopRecord
{
	recorder->StopRecord();

	// dispose the previous playback queue
	player->DisposeQueue(true);

	// now create a new queue for the recorded file
	player->CreateQueueForFile((CFStringRef)currentFileName);

	// Set the button's state back to "record"
	btn_record.title = @"Record";
    recordButtonLabel.text = @"Record Audio";
	btn_play.enabled = YES;
    btn_send.enabled = YES;
}

- (IBAction)play:(id)sender
{
	/*if (player->IsRunning())
     {
     if (playbackWasPaused) {
     OSStatus result = player->StartQueue(true);
     if (result == noErr)
     [[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:self];
     }
     else
     [self stopPlayQueue];
     }
     else
     {
     OSStatus result = player->StartQueue(false);
     if (result == noErr)
     [[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:self];
     }*/
    /*RecordingsListViewController *recordingsListController = [[RecordingsListViewController alloc] init];
    [self.navigationController pushViewController:recordingsListController animated:YES];
    [recordingsListController release];*/
}

- (IBAction)send:(id)sender
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Submit to OpenWatch" message:@"Would you like to submit your recording to www.openwatch.net?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:nil] autorelease];
    [alert setTag:2];
    [alert addButtonWithTitle:@"Yes"];
    [alert show];

}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"]; //3

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Complete" message:@"The recording was uploaded successfully to www.openwatch.net" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];

    // Set TRUE if file was sent properly
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    [data setObject:[NSNumber numberWithBool:TRUE] forKey:@"fileWasSent"];

    [data writeToFile: path atomically:YES];
    [data release];

    btn_send.title = @"Send";
    btn_send.enabled = TRUE;
    btn_record.enabled = TRUE;
    btn_play.enabled = TRUE;
    progressView.hidden = TRUE;
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Error" message:@"Upload failed, please check your internet connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];

    btn_send.title = @"Send";
    btn_send.enabled = TRUE;
    btn_record.enabled = TRUE;
    btn_play.enabled = TRUE;
    progressView.hidden = TRUE;
}

- (IBAction)record:(id)sender
{
	if (recorder->IsRunning()) // If we are currently recording, stop and save the file.
	{
		[self stopRecord];
        fileDescription.text = @"";
	}
	else // If we're not recording, start.
	{
		btn_play.enabled = NO;
        btn_send.enabled = NO;

		// Set the button's state to "stop"
		btn_record.title = @"Stop";
        recordButtonLabel.text = @"Stop Recording";


        NSDate* date = [NSDate date];
        time_t unixTime = (time_t) [date timeIntervalSince1970];
        currentFileName = [NSString stringWithFormat:@"%d.caf",unixTime];
        [currentFileName retain];

		// Start the recorder
		recorder->StartRecord((CFStringRef)currentFileName);




        [self setFileDescriptionForFormat:recorder->DataFormat() withName:@"Recorded File"];
        fileDescription.hidden = FALSE;

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
        NSString *documentsDirectory = [paths objectAtIndex:0]; //2
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"]; //3
        NSString* recordingPath = [documentsDirectory stringByAppendingPathComponent:currentFileName];
        NSURL *url = [NSURL fileURLWithPath:recordingPath];
        recording = [Recording recordingWithName:@"" publicDescription:@"" privateDescription:@"" location:@"" date:date url:url];
        [recording saveMetadata];


        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Stealth Mode" message:@"When finished recording in Stealth Mode simply close the program to stop." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
        [self drawBlack];
        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];

	}
}

#pragma mark AudioSession listeners
void interruptionListener(	void *	inClientData,
                          UInt32	inInterruptionState)
{
	SpeakHereController *THIS = (SpeakHereController*)inClientData;
	if (inInterruptionState == kAudioSessionBeginInterruption)
	{
		if (THIS->recorder->IsRunning()) {
			[THIS stopRecord];
		}
		else if (THIS->player->IsRunning()) {
			//the queue will stop itself on an interruption, we just need to update the UI
			[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:THIS];
			THIS->playbackWasInterrupted = YES;
		}
	}
	else if ((inInterruptionState == kAudioSessionEndInterruption) && THIS->playbackWasInterrupted)
	{
		// we were playing back when we were interrupted, so reset and resume now
		THIS->player->StartQueue(true);
		[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:THIS];
		THIS->playbackWasInterrupted = NO;
	}
}

void propListener(	void *                  inClientData,
                  AudioSessionPropertyID	inID,
                  UInt32                  inDataSize,
                  const void *            inData)
{
	SpeakHereController *THIS = (SpeakHereController*)inClientData;
	if (inID == kAudioSessionProperty_AudioRouteChange)
	{
		CFDictionaryRef routeDictionary = (CFDictionaryRef)inData;
		//CFShow(routeDictionary);
		CFNumberRef reason = (CFNumberRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
		SInt32 reasonVal;
		CFNumberGetValue(reason, kCFNumberSInt32Type, &reasonVal);
		if (reasonVal != kAudioSessionRouteChangeReason_CategoryChange)
		{
			if (reasonVal == kAudioSessionRouteChangeReason_OldDeviceUnavailable)
			{
				if (THIS->player->IsRunning()) {
					[THIS pausePlayQueue];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:THIS];
				}
			}

			// stop the queue if we had a non-policy route change
			if (THIS->recorder->IsRunning()) {
				[THIS stopRecord];
                THIS->fileDescription.text = @"";
			}
		}
	}
	else if (inID == kAudioSessionProperty_AudioInputAvailable)
	{
		if (inDataSize == sizeof(UInt32)) {
			UInt32 isAvailable = *(UInt32*)inData;
			// disable recording if input is not available
            if(isAvailable > 0)
            {
                THIS->btn_record.enabled =  YES;
                AudioSessionSetActive(true);
            }
            else
            {
                THIS->btn_record.enabled =  NO;

                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Microphone Error" message:@"If you are trying to record on an iPod Touch, headphones with a microphone must be plugged in before you can record." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
            }
		}
	}
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 1) {
        if (buttonIndex == 1) {
            // Enable play/send if an old file was found
            //player->CreateQueueForFile((CFStringRef)@"recordedFile.caf");
            btn_play.enabled = YES;
            btn_send.enabled = YES;
        }
        else
        {
            btn_play.enabled = YES;
            btn_send.enabled = NO;
        }
    }
    else if([alertView tag] == 2) // Submit to OpenWatch
    {
        if (buttonIndex == 1)
        {
            if([txtName.text isEqualToString:@""] || [txtPublic.text isEqualToString:@""])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"More Info Please!" message:@"It appears you are trying to submit a recording without a title or public description.\n\nPlease fill in this information and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
            }
            else
            {
                // For setting whether or not file was sent properly if application exits
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
                NSString *documentsDirectory = [paths objectAtIndex:0]; //2
                NSString *recordingPath = [documentsDirectory stringByAppendingPathComponent:currentFileName];

                //POST the file to the server using ASIFormDataRequset
                NSData *recording = [NSData dataWithContentsOfFile:recordingPath];
                NSString *urlString = @"http://openwatch.net/uploadnocaptcha/";
                time_t unixTime = (time_t) [[NSDate date] timeIntervalSince1970];
                ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];

                [request setPostValue:txtName.text forKey:@"name"];
                [request setPostValue:txtPublic.text forKey:@"public_description"];
                [request setPostValue:txtPrivate.text forKey:@"private_description"];
                if(useLocation.on)
                {
                    //NSLog(str_location);
                    [request setPostValue:str_location forKey:@"location"];
                }
                else
                    [request setPostValue:@"None" forKey:@"location"];



                //[request setTimeOutSeconds:20];

                if ([[[UIDevice currentDevice] systemVersion] floatValue] > 3.13) {
                    [request setShouldContinueWhenAppEntersBackground:YES];
                }

                [request setData:recording withFileName:[NSString stringWithFormat:@"%d.caf",unixTime] andContentType:@"audio/x-caf" forKey:@"rec_file"];
                progressView.progress = 0.0;
                progressView.hidden = FALSE;
                fileDescription.hidden = TRUE;
                [request setShowAccurateProgress:YES];
                [request setUploadProgressDelegate:progressView];
                [request setDelegate:self];
                [request startAsynchronous];
                btn_send.title = @"Sending...";
                btn_send.enabled = FALSE;
                btn_record.enabled = FALSE;
                btn_play.enabled = FALSE;
            }

        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    if (recorder->IsRunning()) // If we are currently recording, stop and save the file.
	{
		[self stopRecord];
        fileDescription.text = @"";
	}
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if(!recorder->IsRunning())
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
        img_black.hidden = YES;
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* foofile = [documentsPath stringByAppendingPathComponent:@"recordedFile.caf"];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];

        // http://ipgames.wordpress.com/tutorials/writeread-data-to-plist-file/
        NSError *err;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
        NSString *documentsDirectory = [paths objectAtIndex:0]; //2
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"]; //3

        NSFileManager *fileManager = [NSFileManager defaultManager];


        if (![fileManager fileExistsAtPath: path]) //4
        {
            NSString *bundle = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]; //5

            [fileManager copyItemAtPath:bundle toPath: path error:&err]; //6
        }

        NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];

        //load from savedStock example int value
        BOOL fileWasSent;
        fileWasSent = [[savedStock objectForKey:@"fileWasSent"] boolValue];

        [savedStock release];

        if(!fileWasSent && fileExists)
        {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Unsubmitted Recording" message:@"An unsubmitted recording has been found. Would you like to load it?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:nil] autorelease];
            [alert setTag:1];
            [alert addButtonWithTitle:@"Yes"];
            [alert show];
        }
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (recorder->IsRunning()) // If we are currently recording, stop and save the file.
	{
		[self stopRecord];
        fileDescription.text = @"";
	}
}

#pragma mark Initialization routines
- (void)awakeFromNib
{
	// Allocate our singleton instance for the recorder & player object
	recorder = new AQRecorder();
	player = new AQPlayer();

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"]; //3
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (![fileManager fileExistsAtPath: path]) //4
    {

    }

    CLController = [[CoreLocationController alloc] init];
	CLController.delegate = self;
	[CLController.locMgr startUpdatingLocation];

    UIDevice* device = [UIDevice currentDevice];
    backgroundSupported = NO;
    if ([device respondsToSelector:@selector(isMultitaskingSupported)])
        backgroundSupported = device.multitaskingSupported;

    //[self checkFile];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 3.13)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
    }


	OSStatus error = AudioSessionInitialize(NULL, NULL, interruptionListener, self);
	if (error) printf("ERROR INITIALIZING AUDIO SESSION! %d\n", error);
	else
	{
		UInt32 category = kAudioSessionCategory_PlayAndRecord;
		error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
		if (error) printf("couldn't set audio category!");

		error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, self);
		if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", error);
		UInt32 inputAvailable = 0;
		UInt32 size = sizeof(inputAvailable);

		// we do not want to allow recording if input is not available
		error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
		if (error) printf("ERROR GETTING INPUT AVAILABILITY! %d\n", error);
		btn_record.enabled = (inputAvailable) ? YES : NO;

		// we also need to listen to see if input availability changes
		error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, propListener, self);
		if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", error);

		error = AudioSessionSetActive(true);
		if (error)
        {
            printf("AudioSessionSetActive (true) failed");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Microphone Error" message:@"If you are trying to record on an iPod Touch, headphones with a microphone must be plugged in before you can record." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueResumed:) name:@"playbackQueueResumed" object:nil];


	btn_play.enabled = YES;
    btn_send.enabled = NO;

	playbackWasInterrupted = NO;
	playbackWasPaused = NO;


}

# pragma mark Notification routines
- (void)playbackQueueStopped:(NSNotification *)note
{
	btn_play.title = @"Play";
	btn_record.enabled = YES;
}

- (void)playbackQueueResumed:(NSNotification *)note
{
	btn_play.title = @"Stop";
	btn_record.enabled = NO;
}

#pragma mark Cleanup
- (void)dealloc
{
	[btn_record release];
	[btn_play release];
    [btn_send release];
	[fileDescription release];
    [CLController release];

	delete player;
	delete recorder;

    [txtName release];
    [txtPrivate release];
    [txtPublic release];
    [lblName release];
    [lblPriv release];
    [lblPub release];
    [lblLoc release];
    [useLocation release];
    [str_location release];
    [progressView release];
    [useStealth release];
    [img_black release];
    [toolbar release];
    [btn_info release];
    [recordButtonLabel release];
	[super dealloc];
}

@end
