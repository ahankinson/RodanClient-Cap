@import <Foundation/CPURLConnection.j>

@implementation CPURLConnection (SendAsync)

/*
    A category that implements a Cocoa method that is not in 
    core Capp. This is here until the kinks get worked out of it
    before submitting upstream.
*/
+ (void)sendAsynchronousRequest:(CPURLRequest)aRequest
                          queue:(CPOperationQueue)aQueue
              completionHandler:(Function /*CPURLResponse response, CPData data, CPError connectionError*/)aBlock
{
    var req = new CFHTTPRequest();

    try
    {
        req.open([aRequest HTTPMethod], [[aRequest URL] absoluteString], YES);

        req.onreadystatechange = function (event)
        {
            if (req.readyState() === CFHTTPRequest.CompleteState)
            {
                var statusCode = req.status(),
                    response = [[CPHTTPURLResponse alloc] initWithURL:[aRequest URL]];

                [response _setStatusCode:statusCode];
                [response _setAllResponseHeaders:req.getAllResponseHeaders()];

                var data = req.responseText(),
                    connectionError = [[CPError alloc] init];

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
    catch (anException)
    {
        var response = nil,
            data = nil,
            connectionError = anException;

        aBlock(response, data, connectionError);

        if ([_delegate respondsToSelector:@selector(connection:didFailWithError:)])
            [_delegate connection:self didFailWithError:anException];
    }
}

@end