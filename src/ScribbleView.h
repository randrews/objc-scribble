#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "DrawingCommand.h"

@interface ScribbleView : NSView {
  NSMutableArray* drawingCommands;
  NSColor* backgroundColor;
}

-(void) drawRect: (NSRect) rect;
-(void) addDrawingCommand: (DrawingCommand*) dc;
-(void) clearDrawingCommands;
-(void) setBackgroundColor: (NSColor*) color;

@end
