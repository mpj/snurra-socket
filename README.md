ws-json-client-stream
==========================

A wrapper around the ws npm module that adds JSON-parsing stream interface.

### Example usage

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
