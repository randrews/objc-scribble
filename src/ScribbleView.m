#import "ScribbleView.h"

@implementation ScribbleView

- (void) drawRect: (NSRect) rect {
  [[NSColor colorWithCalibratedRed: 0 green: 0 blue: 0x60/256.0 alpha: 1.0] setFill];
  [[NSBezierPath bezierPathWithRect: rect] fill];
}

@end
