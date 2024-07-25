
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

export const formatAdaHold = (num: bigint) => {
  const formatData = {
    groupInteger: '',
    decimal: '',
    fraction: '',
  }

  for (const part of Intl.NumberFormat(undefined, { minimumFractionDigits: 6, maximumFractionDigits: 6, numberingSystem: 'latn' } as Intl.NumberFormatOptions).formatToParts( // numberingSystem ES2020 feature is missing in TypeScript 5.4 due to a bug
    Number(num) / 1_000_000
  )) {
    switch (part.type) {
      case 'integer':
      case 'group':
        formatData.groupInteger += part.value
        break
      case 'decimal':
      case 'fraction':
        formatData[part.type] += part.value
        break
    }
  }

  return formatData
}

export const cborStrToBuffer = (cborString: string) => {
  return new Uint8Array(cborString.match(/../g)!.map((h) => parseInt(h, 16)))
}

export const cborBufferToStr = (cborBuffer: Uint8Array) => {
  return cborBuffer.reduce((s: string, n: number) => s + n.toString(16).padStart(2, '0'), '')
}
