#import "ScribbleView.h"

@implementation ScribbleView

-(id) init {
  self = [super init];

  if(self==nil){
    return nil;
  }

  drawingCommands = [NSMutableArray arrayWithCapacity: 10];

  backgroundColor = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1.0];

  return self;
}

- (void) drawRect: (NSRect) rect {
  [backgroundColor setFill];
  [[NSBezierPath bezierPathWithRect: rect] fill];

  for(DrawingCommand* dc in drawingCommands){
    if([dc shouldFill]){
      [[dc color] setFill];
      [[dc shape] fill];
    } else {
      [[dc color] setStroke];
      [[dc shape] stroke];
    }
  }
}

-(void) addDrawingCommand: (DrawingCommand*) dc {
  [drawingCommands addObject: dc];
}

-(void) clearDrawingCommands {
  [drawingCommands removeAllObjects];
}

-(void) setBackgroundColor: (NSColor*) color {
  backgroundColor = color;

  if(!backgroundColor){
    backgroundColor = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1.0];
  }
}

@end
