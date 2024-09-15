// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the `bin/rails generate channel` command.

import { createConsumer } from "@rails/actioncable"

function getConsumerEndpoint() {
  if (window.location.protocol === 'http:') {
    // Fix for http only deployment
    return 'ws://' + window.location.host + '/cable'
  } else {
    // Use default endpoint
    return undefined;
  }
}



export default createConsumer()
