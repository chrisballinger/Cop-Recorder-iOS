//
//  LecturePlayerViewController.h
//  LectureLeaks
//
//  Created by Christopher Ballinger on 6/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Recording.h"


@interface LecturePlayerViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate> {
    Recording* recording;
    int duration;
    BOOL isPlaying;
    AVAudioPlayer* player;

    UILabel *durationLabel;
    UILabel *currentTimeLabel;
    NSTimer *playerUpdateTimer;
    UISlider *playerSlider;
    UIBarButtonItem *playButton;
    UIBarButtonItem *stopButton;
    UIBarButtonItem *submitButton;

    UITextField *nameTextField;
    UITextField *publicDescriptionTextField;
    UITextField *privateDescriptionTextField;
    UIProgressView *progressView;
    UILabel *submitLabel;
    UISwitch *locationSwitch;
}
@property (nonatomic, retain) IBOutlet UISwitch *locationSwitch;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) IBOutlet UITextField *privateDescriptionTextField;
@property (nonatomic, retain) IBOutlet UITextField *publicDescriptionTextField;
@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) Recording* recording;
@property (nonatomic, retain) IBOutlet UILabel *durationLabel;
@property (nonatomic, retain) IBOutlet UILabel *currentTimeLabel;
@property (nonatomic, retain)     NSTimer *playerUpdateTimer;
@property (nonatomic, retain) IBOutlet UISlider *playerSlider;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *playButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *stopButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *submitButton;
@property (nonatomic, retain)     AVAudioPlayer* player;

- (IBAction)submitPressed:(id)sender;
- (IBAction)playPressed:(id)sender;
- (IBAction)stopPressed:(id)sender;
- (void) updateElapsedTime:(NSTimer *) timer;
- (void) updateLabel:(UILabel*)label withTime:(NSTimeInterval)time;
- (IBAction)seek:(id)sender;
@property (nonatomic, retain) IBOutlet UILabel *submitLabel;

@end
