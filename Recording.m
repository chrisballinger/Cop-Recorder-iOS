//
//  Recording.m
//  CopRecorder
//
//  Created by Christopher Ballinger on 6/9/11.
//  Copyright 2011. All rights reserved.
//

#import "Recording.h"
#import "ASIFormDataRequest.h"
#import "LecturePlayerViewController.h"

@implementation Recording

@synthesize name;
@synthesize publicDescription;
@synthesize privateDescription;
@synthesize location;
@synthesize date;
@synthesize isSubmitted;
@synthesize url;

+ (id)recordingWithName:(NSString*)name publicDescription:(NSString*)publicDescription privateDescription:(NSString*)privateDescription location:(NSString*)location date:(NSDate*)date url:(NSURL*)url
{
    Recording *newRecording = [[[self alloc] init] autorelease];

    newRecording.name = name;
    newRecording.publicDescription = publicDescription;
    newRecording.privateDescription = privateDescription;
    newRecording.location = location;
    newRecording.date = date;
    newRecording.url = url;
    newRecording.isSubmitted = NO;

    return newRecording;
}

+ (id)recordingWithFile:(NSString*)fileName;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSString* cafPath = [path stringByReplacingOccurrencesOfString:@".audio.plist" withString:@".caf"];
    NSURL *url = [NSURL fileURLWithPath:cafPath];

    NSDictionary *metadata = [[[NSDictionary alloc] initWithContentsOfFile:path] autorelease];
    Recording *newRecording = [[[self alloc] init] autorelease];
    NSString *prefix = [[fileName componentsSeparatedByString:@"."] objectAtIndex:0];


    newRecording.name = [metadata objectForKey:@"name"];
    newRecording.publicDescription = [metadata objectForKey:@"publicDescription"];
    newRecording.privateDescription = [metadata objectForKey:@"privateDescription"];
    newRecording.location = [metadata objectForKey:@"location"];
    newRecording.date = [[NSDate alloc] initWithTimeIntervalSince1970:[prefix doubleValue]];
    newRecording.isSubmitted = [[metadata valueForKey:@"isSubmitted"] boolValue];
    newRecording.url = url;

    return newRecording;
}

-(void)saveMetadata
{
    NSString *fileName = [NSString stringWithFormat:@"%d.audio.plist", (int)[date timeIntervalSince1970]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *metadataPath = [documentsDirectory stringByAppendingPathComponent:fileName];


    NSMutableDictionary *metadata = [[[NSMutableDictionary alloc] init] autorelease];
    [metadata setObject:name forKey:@"name"];
    [metadata setObject:publicDescription forKey:@"publicDescription"];
    [metadata setObject:privateDescription forKey:@"privateDescription"];
    if(isSubmitted)
        [metadata setObject:[NSNumber numberWithBool:YES] forKey:@"isSubmitted"];
    else
        [metadata setObject:[NSNumber numberWithBool:NO] forKey:@"isSubmitted"];
    [metadata writeToFile:metadataPath atomically:YES];
}

-(void)deleteFiles
{
    NSString *fileName = [NSString stringWithFormat:@"%d.caf", (int)[date timeIntervalSince1970]];
    NSString *metadataFileName = [fileName stringByReplacingOccurrencesOfString:@".caf" withString:@".audio.plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *cafPath = [documentsDirectoryPath stringByAppendingPathComponent: fileName];
    NSString *plistPath = [documentsDirectoryPath stringByAppendingPathComponent: metadataFileName];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:cafPath error:nil];
    [fileManager removeItemAtPath:plistPath error:nil];
}

- (void)submitRecordingWithDelegate:(id)delegate;
{

     if([name isEqualToString:@""] || [publicDescription isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"More Info Please!" message:@"It appears you are trying to submit a recording without a title or public description.\n\nPlease fill in this information and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    else
    {
        //POST the file to the server using ASIFormDataRequset
        NSData *recording = [NSData dataWithContentsOfURL:url];
        NSString *urlString = @"http://openwatch.net/uploadnocaptcha/";
        time_t unixTime = (time_t) [date timeIntervalSince1970];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];

        [request setPostValue:name forKey:@"name"];
        [request setPostValue:publicDescription forKey:@"public_description"];
        [request setPostValue:privateDescription forKey:@"private_description"];
        [request setPostValue:location forKey:@"location"];

        //[request setTimeOutSeconds:20];

        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 3.13) {
            [request setShouldContinueWhenAppEntersBackground:YES];
        }

        LecturePlayerViewController* lecturePlayer = (LecturePlayerViewController*)delegate;
        [request setData:recording withFileName:[NSString stringWithFormat:@"%d.caf",unixTime] andContentType:@"audio/x-caf" forKey:@"rec_file"];
        lecturePlayer.progressView.progress = 0.0;
        lecturePlayer.progressView.hidden = FALSE;
        [request setShowAccurateProgress:YES];
        [request setUploadProgressDelegate:lecturePlayer.progressView];
        [request setDelegate:lecturePlayer];
        [request startAsynchronous];
    }
}

-(void)dealloc
{
    [name release];
    [publicDescription release];
    [privateDescription release];
    [location release];
    [date release];
    [url release];
    [super dealloc];
}


@end
