#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "DrawingCommand.h"

@interface ScribbleView : NSView {
  NSArray* drawingCommands;
}

@property(retain) NSArray* drawingCommands;

-(void) drawRect: (NSRect) rect;

@end
