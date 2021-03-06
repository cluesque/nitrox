//
//  NitroxScriptDebugDelegate.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/10/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxScriptDebugDelegate.h"
@implementation NitroxScriptDebugSourceInfo 
@synthesize    sid, lineNumber, url, body;

- (NSString *) description {
    return [NSString stringWithFormat:@"[SID=%d source=%@ parseline=%d]",
            self.sid, self.url ? self.url : self.body, self.lineNumber];
}

- (NitroxScriptDebugSourceInfo*) initWithURL:(NSString *)newurl
                                        body:(NSString *)newbody
                                         sid:(NSInteger)newsid
                                  lineNumber:(NSInteger)newline
{
    self.url = newurl;
    self.body = newbody;
    self.sid = newsid;
    self.lineNumber = newline;
    return self;
}

- (void) dealloc {
    self.url = nil;
    self.body = nil;
    [super dealloc];
}

@end



@implementation NitroxScriptDebugDelegate

- (NitroxScriptDebugDelegate*)init {
    [super init];
    sources = [[NSMutableDictionary alloc] init];
    return self;
}

- (void) dealloc {
    [sources release];
    [super dealloc];
}

- (void) recordSourceInfo:(NitroxScriptDebugSourceInfo*)source
{
    [sources setObject:source forKey:[NSNumber numberWithInt:source.sid]];
}

- (NitroxScriptDebugSourceInfo *) getSourceInfo:(int)sid
{
    NitroxScriptDebugSourceInfo *res = [sources objectForKey:[NSNumber numberWithInt:sid]];
    
    return res;
}

/*
 WebScriptCallFrame methods:

 32f5add0 t -[WebResourcePrivate dealloc]
 32f80b30 t -[WebScriptCallFrame caller]
 32f80a60 t -[WebScriptCallFrame dealloc]
 32f80c00 t -[WebScriptCallFrame evaluateWebScript:]
 32f80bd0 t -[WebScriptCallFrame exception]
 32f80ba0 t -[WebScriptCallFrame functionName]
 32f80b70 t -[WebScriptCallFrame scopeChain]
 32f80ac0 t -[WebScriptCallFrame setUserInfo:]
 32f80b20 t -[WebScriptCallFrame userInfo]

 
 00017 - (void)dealloc;
 00018 - (void)setUserInfo:(id)fp8;
 00019 - (id)userInfo;
 00020 - (id)caller;
 00021 - (id)scopeChain;
 00022 - (id)functionName;
 00023 - (id)exception;
*/

// some source was parsed, establishing a "source ID" (>= 0) for future reference
// this delegate method is deprecated, please switch to the new version below
//- (void)webView:(WebView *)webView       didParseSource:(NSString *)source
//        fromURL:(NSString *)url
//       sourceId:(int)sid
//    forWebFrame:(WebFrame *)webFrame
//{
//    NSLog(@"NSDD: called didParseSource; sid=%d, url=%@", sid, url);
//}

- (NSString *) webFrameInfo:(WebFrame *)frame
{
    NSString *res =
        [NSString stringWithFormat:@"[webFrame=%@, name=%@]",
         frame, [frame name]];

    return res;
}

- (NSString *) webViewInfo:(WebView *)view
{
    NSString *res =
        [NSString stringWithFormat:@"[webView=%@, URL=%@, title=%@]",
         view, [view mainFrameURL], [view mainFrameTitle]];
    
    return res;
}

// some source was parsed, establishing a "source ID" (>= 0) for future reference
- (void)webView:(WebView *)webView       didParseSource:(NSString *)source
 baseLineNumber:(unsigned)lineNumber
        fromURL:(NSURL *)url
       sourceId:(int)sid
    forWebFrame:(WebFrame *)webFrame
{
    [self recordSourceInfo:[[NitroxScriptDebugSourceInfo alloc]
                            initWithURL:url body:source sid:sid lineNumber:lineNumber]];
    NSLog(@"NSDD: didParseSource: view=%@, sid=%d, line=%d, frame=%@, source=%@", 
          [self webViewInfo:webView], 
          sid, 
          lineNumber, 
          [self webFrameInfo:webFrame],
          url ? (id)url : (id)source
          );
}

// some source failed to parse
- (void)webView:(WebView *)webView  failedToParseSource:(NSString *)source
 baseLineNumber:(unsigned)lineNumber
        fromURL:(NSURL *)url
      withError:(NSError *)error
    forWebFrame:(WebFrame *)webFrame
{
    NSLog(@"NSDD: called failedToParseSource: window=%@ url=%@ line=%d frame=%@ error=%@\nsource=%@", 
          [self webViewInfo:webView], 
          url, 
          lineNumber, 
          [self webFrameInfo:webFrame], 
          error, 
          source);

}

// just entered a stack frame (i.e. called a function, or started global scope)
//- (void)webView:(WebView *)webView    didEnterCallFrame:(WebScriptCallFrame *)frame
//       sourceId:(int)sid
//           line:(int)lineno
//    forWebFrame:(WebFrame *)webFrame
//{
//    NSLog(@"NSDD: called didEnterCallFrame");
//}

// about to execute some code
//- (void)webView:(WebView *)webView willExecuteStatement:(WebScriptCallFrame *)frame
//       sourceId:(int)sid
//           line:(int)lineno
//    forWebFrame:(WebFrame *)webFrame
//{
//    NSLog(@"NSDD: called willEXecuteStatement");
//}

// about to leave a stack frame (i.e. return from a function)
//- (void)webView:(WebView *)webView   willLeaveCallFrame:(WebScriptCallFrame *)frame
//       sourceId:(int)sid
//           line:(int)lineno
//    forWebFrame:(WebFrame *)webFrame
//{
//    NSLog(@"NSDD: called willLeaveCallFrame");
//}

// exception is being thrown
- (void)webView:(WebView *)webView   exceptionWasRaised:(WebScriptCallFrame *)frame
       sourceId:(int)sid
           line:(int)lineno
    forWebFrame:(WebFrame *)webFrame
{
    NSLog(@"NSDD: exception: webView=%@, webFrame=%@, sid=%d line=%d function=%@, caller=%@, exception=%@, scopeChain=%@\nsource=%@", 
          [self webViewInfo:webView],
          [self webFrameInfo:webFrame],
          sid, 
          lineno, 
          [frame functionName], 
          [frame caller], 
          [[frame exception] stringRepresentation], 
          [frame scopeChain],
          [[self getSourceInfo:sid] description]
    );
}

@end
