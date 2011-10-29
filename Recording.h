//
//  Recording.h
//  CopRecorder
//
//  Created by Christopher Ballinger on 6/9/11.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Recording : NSObject
{
    NSString *name;
    NSString *publicDescription;
    NSString *privateDescription;
    NSString *location;
    NSDate *date;
    BOOL isSubmitted;
    NSURL *url;
}


@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *publicDescription;
@property (nonatomic, retain) NSString *privateDescription;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSURL *url;
@property BOOL isSubmitted;

+ (id)recordingWithName:(NSString*)name publicDescription:(NSString*)publicDescription privateDescription:(NSString*)privateDescription location:(NSString*)location date:(NSDate*)date url:(NSURL*)url;
+ (id)recordingWithFile:(NSString*)fileName;

- (void)saveMetadata;
- (void)deleteFiles;
- (void)submitRecordingWithDelegate:(id)delegate;

@end
