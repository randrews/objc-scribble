#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

int main(int argc, const char* argv[]){

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [NSApplication sharedApplication];

  NSRect frame = NSMakeRect(0, 0, 200, 200);

  int style = NSTitledWindowMask |
    NSClosableWindowMask |
    NSResizableWindowMask |
    NSMiniaturizableWindowMask;

  NSWindow* window  = [[NSWindow alloc] initWithContentRect:frame
                                        styleMask:style
                                        backing:NSBackingStoreBuffered
                                        defer:NO];

  [window makeKeyAndOrderFront:NSApp];

  [NSApp run];
  [pool drain];
  return 0;
}
