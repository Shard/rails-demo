import consumer from "channels/consumer"

consumer.subscriptions.create({ channel: "PriceChannel"}, {
  connected() {
    console.log('channel connected')
    document.getElementById('bad-network').classList.remove('active');
  },

  disconnected() {
    console.log('channel disconnected')
    document.getElementById('bad-network').classList.add('active');
  },

  received(data) {
    window.updateChart([data.price, data.created]);
  }
});
