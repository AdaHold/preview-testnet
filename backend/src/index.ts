import { start } from './lib/app'

Object.defineProperty(BigInt.prototype, 'toJSON', {
  value: function () {
    return this.toString()
  },
})

Object.defineProperty(Map.prototype, 'toJSON', {
  value: function () {
    const obj: any = {}
    for (const [k, v] of this) {
      obj[k] = v
    }
    return obj
  },
})

start()
