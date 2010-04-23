#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface DrawingCommand : NSObject {
  NSBezierPath* shape;
  NSColor* color;
  BOOL fill;
}

@property(retain) NSBezierPath* shape;
@property(retain) NSColor* color;
@property BOOL fill;

@end
