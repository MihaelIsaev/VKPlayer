//
//  Player.h
//  VK Player
//
//  Created by mihael on 08.10.12.
//  Copyright (c) 2012 Mihael Isaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "EntitySongs.h"
#import "CommonHelper.h"
#import "SPMediaKeyTap.h"

@class AudioStreamer;

@interface Player : NSObject
{
	IBOutlet NSTextField *downloadSourceField;
	IBOutlet NSButton *button;
	IBOutlet NSTextField *positionLabel;
	IBOutlet NSSlider *progressSlider;
	AudioStreamer *streamer;
	NSTimer *progressUpdateTimer;
}

- (IBAction)buttonPressed:(id)sender;
- (void)spinButton;
- (void)updateProgress:(NSTimer *)aNotification;
- (IBAction)sliderMoved:(NSSlider *)aSlider;

@end

@interface MediaKeyExampleApp : NSApplication
@end
