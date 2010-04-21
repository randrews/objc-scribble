#import <Foundation/Foundation.h>
#include "sexp.h"
#import "ScribbleView.h"

@interface CommandController : NSObject {
  NSMutableDictionary* paths;
  ScribbleView* scribbleView;
}

-(id) initWithScribbleView: (ScribbleView*) scribbleView;
-(void) handleSexpr: (sexp_t*) sexpr;
-(NSBezierPath*) pathForName: (NSString*) name;

@end
