#import <Foundation/Foundation.h>
#include "sexp.h"
#import "ScribbleView.h"

@interface CommandController : NSObject {
  NSMutableDictionary* paths;
  ScribbleView* scribbleView;
}

+(NSString*) stringForSexp: (sexp_t*) sexp;
+(BOOL) sexpIsValid: (sexp_t*) sexp;

-(id) initWithScribbleView: (ScribbleView*) scribbleView;
-(void) handleSexp: (sexp_t*) sexpr;
-(NSBezierPath*) pathForName: (NSString*) name;
@end
