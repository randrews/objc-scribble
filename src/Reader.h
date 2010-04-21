#import <Foundation/Foundation.h>
#include "CommandController.h"
#include "sexp.h"

@interface Reader : NSObject {
  sexp_iowrap_t* sexp_io;
  CommandController* commandController;
}

-(id) initWithCommandController: (CommandController*) commandController_p;
-(void) startListening: (id) arg;

@end
