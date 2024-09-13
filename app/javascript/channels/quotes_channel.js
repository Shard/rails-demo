import consumer from "./consumer"

consumer.subscriptions.create("StockChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    document.getElementById('current-price').innerHTML = `<h2>Current Price: $${data.price.toFixed(2)}</h2>`;
    // Update the chart with new data
  }
});
