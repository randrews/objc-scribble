#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "DrawingCommand.h"

@interface ScribbleView : NSView {
  NSMutableArray* drawingCommands;
}

-(void) drawRect: (NSRect) rect;
-(void) addDrawingCommand: (DrawingCommand*) dc;

@end
