snurra-socket
==========================

A wrapper around the ws npm module that adds JSON-parsing stream interface.

### Example usage
Below is an example that subscribes to all the transactions happening on the Stellar network. [Stellar API endpoint documentation](https://www.stellar.org/api/#api-subscribe)
```coffeescript
_ = require 'highland'
socket = require('./index')()

_(socket('message')).each console.log

socket('connect').write 'ws://live.stellar.org:9001'

socket('send').write
  "command" : "subscribe"
  "streams" :  [ "transactions" ]

```
