ws-json-client-stream
==========================

A wrapper around the ws npm module that adds JSON-parsing stream interface.

### Example usage
Below is an example that subscribes to all the transactions happening on the Stellar network. [Stellar API endpoint documentation](https://www.stellar.org/api/#api-subscribe)
```javascript
var _ = require( 'highland' ),
    socket = require( 'ws-json-client-stream' ),
    stellarSocket = socket( 'ws://live.stellar.org:9001' );

_(stellarSocket).each(console.log);

stellarSocket.write({
  "command" : "subscribe",
  "streams" :  [ "transactions" ]
});
```
