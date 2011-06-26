//
//  Recording.m
//  CopRecorder
//
//  Created by Christopher Ballinger on 6/9/11.
//  Copyright 2011. All rights reserved.
//

#import "Recording.h"


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
        [metadata setValue:YES forKey:@"isSubmitted"];
    else
        [metadata setValue:NO forKey:@"isSubmitted"];
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
