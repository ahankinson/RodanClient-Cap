@import <Foundation/CPURLConnection.j>

@implementation CPURLConnection (SendAsync)

/*
    A category that implements a Cocoa method that is not in 
    core Capp. This is here until the kinks get worked out of it
    before submitting upstream.
*/

/*!
 *  Loads the data for a URL request and executes a handler block when the request completes
 *  or fails.
 *  
 *  @param aRequest A CPURLRequest object
 *  @param aQueue   A CPOperationQueue object (currently not implemented)
 *  @param completionHandler A function passed in that will receive the request once it has returned.
 *
 *  The completion handler will receive three arguments:
 *<pre>
 *  (CPURLResponse) aResponse
 *  (CPData) data
 *  (CPError) connectionError
 *</pre>
 *  
 *  In Cocoa, any error will cause aResponse to be nil; however, in Cappuccino we will always return
 *  the response from the server (except the case where no response was received from the server).
 *
 *  Error codes for the response can be found in the CPURLError.j file, and also in the CFNetworkErrors.j
 *  file.
 *
 */
+ (void)sendAsynchronousRequest:(CPURLRequest)aRequest
                          queue:(CPOperationQueue)aQueue
              completionHandler:(Function /*CPURLResponse response, CPData data, CPError connectionError*/)aBlock
{
    var req = new CFHTTPRequest();

    req.open([aRequest HTTPMethod], [[aRequest URL] absoluteString], YES);
    req.setWithCredentials([aRequest withCredentials]);

    req.onreadystatechange = function (event)
    {
        if (req.readyState() !== CFHTTPRequest.CompleteState)
            return;

        var statusCode = req.status();
        // a status code of 0 usually means the server could not be found.
        if (statusCode === 0)
        {
            var response = nil,
                data = nil,
                userInfo = @{
                    CPUnderlyingErrorKey: @"",
                    CPURLErrorFailingURLErrorKey: [[aRequest URL] absoluteString],
                    CPURLErrorFailingURLStringErrorKey: [[aRequest URL] absoluteString],
                    CPLocalizedDescriptionKey: @"A server with the specified hostname could not be found"
                };

            var connectionError = [CPError errorWithDomain:CPURLErrorDomain
                                                      code:CPURLErrorCannotFindHost
                                                  userInfo:userInfo];

            // return the response with nil, but with a nice error object.
            aBlock(response, data, connectionError);

            CPLog.debug(@"sendAsynchronousRequest:queue:completionHandler is returning with an error");

            // there is nothing more we can do here, so bail.
            return nil;
        }

        if (req.readyState() === CFHTTPRequest.CompleteState)
        {
            var statusCode = req.status(),
                response = [[CPHTTPURLResponse alloc] initWithURL:[aRequest URL]],
                userInfo = nil,
                code = nil,
                domain = nil;

            if (statusCode === 401)
            {
                domain = CPURLErrorDomain;

                // Cocoa returns CPURLErrorUserCancelledAuthentication, but this error code
                // seems more appropriate.
                code = CPURLErrorUserAuthenticationRequired;

                userInfo = @{
                    CPURLErrorFailingURLStringErrorKey: [[aRequest URL] absoluteString],
                    CPUnderlyingErrorKey: @"",
                    CPURLErrorFailingURLErrorKey: [[aRequest URL] absoluteString]
                };
            }

            [response _setStatusCode:statusCode];
            [response _setAllResponseHeaders:req.getAllResponseHeaders()];

            var data = req.responseText(),
                connectionError = [CPError errorWithDomain:domain
                                                      code:code
                                                  userInfo:userInfo];

            CPLog.debug("Returning " + statusCode);
            aBlock(response, data, connectionError);
        }
    };

    var fields = [aRequest allHTTPHeaderFields],
        key = nil,
        keys = [fields keyEnumerator];

    while ((key = [keys nextObject]) !== nil)
        req.setRequestHeader(key, [fields objectForKey:key]);

    req.send([aRequest HTTPBody]);
}

@end