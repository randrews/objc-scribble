#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "Reader.h"
#import "ScribbleView.h"

int main(int argc, const char* argv[]){
  objc_startCollectorThread();
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [NSApplication sharedApplication];

  int width = 800;
  int height = 600;
  NSString *title = @"";

  if(argc >= 3){ // Providing width/height
    width = [[[NSString alloc] initWithUTF8String: argv[1]] intValue];
    height = [[[NSString alloc] initWithUTF8String: argv[2]] intValue];
  }

  if(argc >= 4){ // Providing title
    title = [[NSString alloc] initWithUTF8String: argv[3]];
  }

  // Create the window
  NSRect frame = NSMakeRect(0, 0, width, height);

  int style = NSTitledWindowMask |
    NSClosableWindowMask |
    NSResizableWindowMask |
    NSMiniaturizableWindowMask;

  NSWindow* window  = [[NSWindow alloc] initWithContentRect:frame
                                        styleMask:style
                                        backing:NSBackingStoreBuffered
                                        defer:NO];

  ScribbleView* scribbleView = [[ScribbleView alloc] init];
  [window setContentView: scribbleView];

  [window setTitle: title];
  [window makeKeyAndOrderFront:NSApp];

  // Create the thread that listens for input
  Reader* reader = [[Reader alloc] init];
  [NSThread detachNewThreadSelector: @selector(startListening:)
	    toTarget: reader
	    withObject: nil];

  // Run the app
  [NSApp run];
  [pool drain];
  return 0;
}
