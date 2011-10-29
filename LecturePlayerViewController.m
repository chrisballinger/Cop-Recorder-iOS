//
//  LecturePlayerViewController.m
//  LectureLeaks
//
//  Created by Christopher Ballinger on 6/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LecturePlayerViewController.h"
#import "ASIFormDataRequest.h"

@implementation LecturePlayerViewController
@synthesize submitLabel;
@synthesize durationLabel;
@synthesize currentTimeLabel;
@synthesize locationSwitch;
@synthesize progressView;
@synthesize privateDescriptionTextField;
@synthesize publicDescriptionTextField;
@synthesize nameTextField;
@synthesize recording;
@synthesize playerUpdateTimer;
@synthesize playerSlider;
@synthesize playButton;
@synthesize stopButton;
@synthesize submitButton;
@synthesize player;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [player release];
    [recording release];
    [durationLabel release];
    [currentTimeLabel release];
    [playerUpdateTimer release];
    [playerSlider release];
    [playButton release];
    [stopButton release];
    [submitButton release];
    [nameTextField release];
    [publicDescriptionTextField release];
    [privateDescriptionTextField release];
    [progressView release];
    [submitLabel release];
    [locationSwitch release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    nameTextField.text = recording.name;
    privateDescriptionTextField.text = recording.privateDescription;
    publicDescriptionTextField.text = recording.publicDescription;

    NSURL *url = recording.url;

    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];


    submitButton.enabled = YES;

    isPlaying = NO;


    playerUpdateTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                                        selector:@selector(updateElapsedTime:) userInfo:nil repeats:YES] retain];


    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.title = [recording.date description];


    if(recording.isSubmitted)
    {
        submitLabel.text = @"Previously Submitted";
        submitLabel.textColor = [UIColor greenColor];
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self stopPressed:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [player pause];
    [playerUpdateTimer invalidate];
}

- (void)viewDidUnload
{
    [self setDurationLabel:nil];
    [self setCurrentTimeLabel:nil];
    [self setPlayerSlider:nil];
    [self setPlayButton:nil];
    [self setStopButton:nil];
    [self setSubmitButton:nil];
    [self setNameTextField:nil];
    [self setPublicDescriptionTextField:nil];
    [self setPrivateDescriptionTextField:nil];
    [self setProgressView:nil];
    [self setSubmitLabel:nil];
    [self setLocationSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// Update the call timer once a second.
- (void) updateElapsedTime:(NSTimer *) timer
{
    int currentTime = player.currentTime;

    duration = player.duration;


    [self updateLabel:currentTimeLabel withTime:currentTime];
    [self updateLabel:durationLabel withTime:duration];

    if(duration != 0)
    {
        self.playerSlider.value = currentTime / ((float)duration);
    }
    if(!isPlaying)
    {
        playButton.title = @"Play";
        playButton.enabled = YES;
    }
}

-(void) updateLabel:(UILabel*)label withTime:(NSTimeInterval)time
{
    int hour, minute, second;
	hour = time / 3600;
	minute = (time - hour * 3600) / 60;
	second = (time - hour * 3600 - minute * 60);
	label.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
}

- (IBAction)seek:(id)sender
{

    float currentTime = self.playerSlider.value * duration;
    [player setCurrentTime:currentTime];

    [self updateElapsedTime:nil];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1)
    {
        if(!locationSwitch.on)
            recording.location = @"";
        [recording submitRecordingWithDelegate:self];
        submitLabel.text = @"Submitting...";
        submitLabel.textColor = [UIColor whiteColor];
    }
}

- (IBAction)submitPressed:(id)sender
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Submit to OpenWatch" message:@"Would you like to submit your recording to www.openwatch.net?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:nil] autorelease];
    [alert addButtonWithTitle:@"Yes"];
    [alert show];
}

- (IBAction)playPressed:(id)sender
{
    if(!isPlaying)
    {
        [player play];
        playButton.title = @"Pause";
        stopButton.enabled = YES;
        isPlaying = YES;

    }
    else
    {
        [player pause];
        playButton.title = @"Play";
        isPlaying = NO;
    }
}

- (IBAction)stopPressed:(id)sender
{

    [player pause];
    [player setCurrentTime:0];

    [self updateElapsedTime:nil];
    stopButton.enabled = NO;
    playButton.title = @"Play";
    isPlaying = NO;

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    recording.name = nameTextField.text;
    recording.privateDescription = privateDescriptionTextField.text;
    recording.publicDescription = publicDescriptionTextField.text;
    [recording saveMetadata];
    return YES;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Complete" message:@"The recording was uploaded successfully to www.openwatch.net" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];

    // Set TRUE if file was sent properly
    recording.isSubmitted = YES;
    [recording saveMetadata];

    submitLabel.text = @"Submission successful!";
    submitLabel.textColor = [UIColor greenColor];
    progressView.hidden = TRUE;
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Error" message:@"Upload failed, please check your internet connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];

    submitLabel.text = @"Submission failed!";
    submitLabel.textColor = [UIColor redColor];
    progressView.hidden = TRUE;
}

@end
