#import "ScribbleView.h"

@implementation ScribbleView

-(id) init: (ScribbleView*) scribbleView_p {
  self = [super init];

  if(self==nil){
    return nil;
  }

  drawingCommands = [NSMutableArray arrayWithCapacity: 10];

  return self;
}

- (void) drawRect: (NSRect) rect {
  [[NSColor colorWithCalibratedRed: 0 green: 0 blue: 0x60/256.0 alpha: 1.0] setFill];
  [[NSBezierPath bezierPathWithRect: rect] fill];
}

@synthesize drawingCommands;

@end
