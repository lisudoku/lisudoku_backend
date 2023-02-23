// k6 run load_testing/websockets.js

import { check, sleep } from 'k6'
import ws from 'k6/ws'

// const WS_URL = 'ws://localhost:3000/cable'
// const ORIGIN = 'http://localhost:3001'
const WS_URL = 'wss://api.lisudoku.xyz/cable'
const ORIGIN = 'https://lisudoku.xyz'

const SECONDS = 7
const USERS = 50
// const SECONDS = 60
// const USERS = 10

// See https://k6.io/docs/using-k6/options
export const options = {
  stages: [
    { duration: '30s', target: USERS },
    { duration: '3m', target: USERS },
  ],
}

export default function main() {
  const params = {
    headers: { 'Origin': ORIGIN },
  }
  const res = ws.connect(WS_URL, params, socket => {
    socket.on('open', function open() {
      console.log('connected')
    })

    socket.on('message', function message(data) {
      console.log('Message received: ', data)
    })

    socket.on('close', () => console.log('disconnected'))

    socket.setTimeout(function () {
      console.log('closing the socket')
      socket.close()
    }, SECONDS * 1000)
  })

  check(res, { 'status is 101': (r) => r && r.status === 101 })

  sleep(1)
}
