//
//  RecordingsListViewController.h
//  LectureLeaks
//
//  Created by Christopher Ballinger on 6/6/11.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RecordingsListViewController : UITableViewController
{
    NSMutableArray* listContent;
}

@property (nonatomic, retain) NSMutableArray* listContent;


@end
