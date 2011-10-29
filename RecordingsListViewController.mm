//
//  RecordingsListViewController.m
//  LectureLeaks
//
//  Created by Christopher Ballinger on 6/6/11.
//  Copyright 2011. All rights reserved.
//

#import "RecordingsListViewController.h"
#import "LecturePlayerViewController.h"
#import "Recording.h"

@implementation RecordingsListViewController

@synthesize listContent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSFileManager *manager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:documentsDirectory];
        NSMutableArray *lectureList = [[NSMutableArray alloc] init];
        Recording *newRecording;

        NSString *filename;

        while ((filename = [direnum nextObject] ))
        {
            if ([filename hasSuffix:@".audio.plist"])
            {
                newRecording = [Recording recordingWithFile:filename];
                [lectureList addObject:newRecording];
            }
        }
        listContent = lectureList;
    }
    return self;
}

#pragma mark -
#pragma mark UITableView data source and delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listContent count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"cellID";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellID] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

	/*
	 If the requesting table view is the search display controller's table view, configure the cell using the filtered content, otherwise use the main list.
	 */
	Recording *recording = nil;

    recording = [self.listContent objectAtIndex:indexPath.row];

    if([recording.name isEqualToString:@""])
        cell.textLabel.text = [recording.date description];
    else
        cell.textLabel.text = recording.name;

    if(!recording.isSubmitted)
    {
        cell.textLabel.textColor = [UIColor redColor];
        cell.detailTextLabel.text = @"Not submitted!";
    }
    else
    {
        cell.detailTextLabel.text = @"Submitted";
    }
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LecturePlayerViewController *lecturePlayerController = [[LecturePlayerViewController alloc] init];


	Recording *recording = nil;
    recording = [self.listContent objectAtIndex:indexPath.row];

	lecturePlayerController.title = [recording.date description];
    lecturePlayerController.recording = recording;

    [[self navigationController] pushViewController:lecturePlayerController animated:YES];
    [lecturePlayerController release];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[listContent objectAtIndex:indexPath.row] deleteFiles];

        [listContent removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }
}

- (void)dealloc
{
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
    // Do any additional setup after loading the view from its nib.

    self.editButtonItem.target = self;
    [self.navigationItem setRightBarButtonItem:self.editButtonItem animated:YES];
    self.title = @"My Recordings";

}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidUnload
{
    self.tableView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
