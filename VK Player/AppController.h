//
//  AppController.h
//  VK Player
//
//  Created by mihael on 03.10.12.
//  Copyright (c) 2012 Mihael Isaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "EntitySongs.h"
#import "CommonHelper.h"
#import "SPMediaKeyTap.h"

@interface MediaKeyExampleApp : NSApplication
@end

@interface AppController : NSObject <AVAudioPlayerDelegate, NSApplicationDelegate, NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate>
{
    NSWindow *window;
	SPMediaKeyTap *keyTap;
    AVAudioPlayer *theAudio;
    NSTimer *playbackTimer;
    NSMutableArray *_list;
}

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSSlider *volumeSlider;
@property (weak) IBOutlet NSSlider *progressSlider;
@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSSearchField *searchBar;
@property (weak) IBOutlet NSSearchFieldCell *searchFieldCell;
@property (weak) IBOutlet NSTextField *currentSongTitle;
@property (weak) IBOutlet NSProgressIndicator *loadingBar;
@property (weak) IBOutlet NSTextField *loadingTitle;

-(IBAction)playSelector:(id)sender;
- (IBAction)volumeSelector:(id)sender;
- (IBAction)progressSelector:(id)sender;
- (IBAction)backwardSelector:(id)sender;
- (IBAction)forwardSelector:(id)sender;
- (IBAction)searchSelector:(id)sender;


@end
