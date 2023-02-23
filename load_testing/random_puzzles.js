// k6 run load_testing/websockets.js

import { check, sleep } from 'k6'
import http from 'k6/http'

// const BASE = 'http://localhost:3000'
const BASE = 'https://api.lisudoku.xyz'
const API_URL = `${BASE}/api/puzzles/random?variant=classic&difficulty=easy9x9`
const USERS = 50

// See https://k6.io/docs/using-k6/options
export const options = {
  stages: [
    { duration: '1m', target: USERS },
    { duration: '3m', target: USERS },
    { duration: '1m', target: 0 },
  ],
  thresholds: {
    http_req_failed: ['rate<0.02'], // http errors should be less than 2%
    http_req_duration: ['p(95)<2000'], // 95% requests should be below 2s
  },
}

export default function main() {
  let res = http.post(
    API_URL,
    JSON.stringify({ id_blacklist: [ 'dummy_id' ] }),
    { headers: { 'Content-Type': 'application/json' } },
  )
  check(res, {
    'status is 200': r => r.status === 200,
    'puzzle data is present': r => r.body && r.body.includes('constraints'),
  })
  sleep(1)
}
