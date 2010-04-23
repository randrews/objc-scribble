#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface DrawingCommand : NSObject {
  NSBezierPath* shape;
  NSColor* color;
  BOOL shouldFill;
}

@property(retain) NSBezierPath* shape;
@property(retain) NSColor* color;
@property BOOL shouldFill;

@end
