import { promisify } from 'node:util'
import { exec as execNonPromise } from 'node:child_process'
import { writeFile, mkdtemp, rm } from 'node:fs/promises'
import { join } from 'node:path'
import { tmpdir } from 'node:os'
import { bech32 } from 'bech32'
import fastify from 'fastify'

const assetsDir = process.env.ASSETS_DIR || process.cwd() + '/assets'

const exec = promisify(execNonPromise)

const server = fastify()

// (100)
const nftLabel = '000643b0'

// (333)
const pubkeyLabel = '0014df10'

// (444)
const scriptLabel = '001bc280'

const scRefTxIn = 'c32b10d745f57f71421528e005755b4d21a1991493759d594c3b50b7713a0d8e#1'

const redeemerMint = assetsDir + '/redeemer.mint.json'
const redeemerBurn = assetsDir + '/redeemer.burn.json'
const redeemerWrapped = assetsDir + '/redeemer.wrapped.json'

const deregCert = assetsDir + '/dereg.cert'
const regCert = assetsDir + '/reg.cert'
const delegCert = assetsDir + '/deleg.cert'

const treasury: {
  address: string
  stake_address: string
  cred: string
  nft: string
  token: string
  utxo: string
  datum: Record<string, any>
  value: bigint
  hold: bigint
  total_hold: bigint
  tvl: bigint
  reward: bigint
} = {
  address: 'addr_test1xrr2gdy7ydt72z5a3dnr0vzdl9a46j2zvh5egw3adzmt9sxx5s6fug6hu59fmzmxx7cym7tmt4y5ye0fjsar669kktqqc36ra5',
  stake_address: 'stake_test17rr2gdy7ydt72z5a3dnr0vzdl9a46j2zvh5egw3adzmt9sqp9dudu',
  cred: 'c6a4349e2357e50a9d8b6637b04df97b5d494265e9943a3d68b6b2c0',
  nft: nftLabel,
  token: scriptLabel,
  utxo: '',
  datum: {},
  value: 0n,
  hold: 0n,
  total_hold: 0n,
  tvl: 0n,
  reward: 0n
}

treasury.nft += treasury.cred
treasury.token += treasury.cred

const findTreasury = async () => {
  if (treasury.utxo) {
    try {
      const { stdout } = await exec(`cardano-cli query utxo --tx-in ${treasury.utxo} --testnet-magic 2 --output-json`)

      const utxos = JSON.parse(stdout)

      if (!(treasury.utxo in utxos)) {
        treasury.utxo = ''
      }
    } catch (e) {
      treasury.utxo = ''
    }
  }

  if (!treasury.utxo) {
    try {
      const { stdout } = await exec(`cardano-cli query utxo --address ${treasury.address} --testnet-magic 2 --output-json`)

      const utxos = JSON.parse(stdout)

      for (const outRef of Object.keys(utxos)) {
        const utxo = utxos[outRef]

        if (utxo?.value?.[treasury.cred]?.[treasury.nft] == 1) {
          treasury.utxo = outRef
          treasury.datum = utxo.inlineDatum
          treasury.value = BigInt(utxo.value.lovelace)

          treasury.hold = BigInt(treasury.datum.fields[2].fields[0].int)
          treasury.total_hold = BigInt(treasury.datum.fields[2].fields[1].int)
          treasury.tvl = BigInt(treasury.datum.fields[2].fields[2].int)

          break
        }
      }
    } catch (e) {
      treasury.utxo = ''
    }
  }

  if (treasury.utxo) {
    try {
      const { stdout } = await exec(`cardano-cli query stake-address-info --address ${treasury.stake_address} --testnet-magic 2`)

      const stake_data = JSON.parse(stdout)

      if (stake_data.length) {
        treasury.reward = BigInt(stake_data[0].rewardAccountBalance)
      }
    } catch (e) {
      treasury.utxo = ''
    }
  }
}

const getTX = async (data: any): Promise<string> => {
  let txCBOR = ''

  await findTreasury()

  if (treasury.utxo) {
    try {
      const mintedHoldQty = BigInt(data.hold_qty)
      const collateralAmount = BigInt(data.collateral_amount)

      const changeAddress = bech32.encode('addr_test', bech32.toWords(Buffer.from(data.change_address, 'hex')), 128)

      const tmpDir = await mkdtemp(join(tmpdir(), 'adahold-'))

      let txReq = `cardano-cli transaction build`

      const mintedTokenName = /^[0-9A-Fa-f]{64}$/.test(data.token_name) ? data.token_name : treasury.token

      const tvl = treasury.tvl + treasury.reward,
        mint = [],
        treasuryDatum = JSON.stringify({
          constructor: 0,
          fields: [
            treasury.datum.fields[0],
            treasury.datum.fields[1],
            {
              constructor: 0,
              fields: [
                {
                  int: '_treasuryHold_'
                },
                {
                  int: '_treasuryTotalHold_'
                },
                {
                  int: '_treasuryTVL_'
                }
              ]
            }
          ]
        })

      if (mintedHoldQty > 0) { // minting
        const lockedAmount = mintedHoldQty * tvl / treasury.total_hold

        // inputs
        for (const utxoIn of data.inputs) {
          const utxoHash = utxoIn[0],
            utxoIdx = parseInt(utxoIn[1])
          if (/^[0-9A-Fa-f]{64}$/.test(utxoHash) && utxoIdx >= 0) {
            txReq += ` --tx-in ${utxoHash}#${utxoIdx}`
          }
        }
        txReq += ` --tx-in ${treasury.utxo}`
        txReq += ` --spending-tx-in-reference ${scRefTxIn}`
        txReq += ` --spending-plutus-script-v2`
        txReq += ` --spending-reference-tx-in-inline-datum-present`
        txReq += ` --spending-reference-tx-in-redeemer-file ${redeemerWrapped}`
        if (mintedTokenName == treasury.token) {
          // treasury output
          const treasuryHold = (treasury.hold + mintedHoldQty).toString(),
            treasuryTotalHold = (treasury.total_hold + mintedHoldQty).toString(),
            treasuryTVL = (tvl + lockedAmount).toString(),
            treasuryDatumFileName = join(tmpDir, `treasury_datum.json`),
            treasuryDatumJSON = treasuryDatum.replace('"_treasuryHold_"', treasuryHold).replace('"_treasuryTotalHold_"', treasuryTotalHold).replace('"_treasuryTVL_"', treasuryTVL)

          await writeFile(treasuryDatumFileName, treasuryDatumJSON)

          txReq += ` --tx-out ${treasury.address}+${treasury.value + treasury.reward + lockedAmount}+"1 ${treasury.cred}.${treasury.nft}"`
          txReq += ` --tx-out-inline-datum-file ${treasuryDatumFileName}`
        } else {
          // collateral output
          const collateralStakeHash = mintedTokenName.slice(8),
            collateralAddrHeader = mintedTokenName.slice(0, 8) == pubkeyLabel ? '10' : '30',
            collateralAddrHash = collateralAddrHeader + treasury.cred + collateralStakeHash,
            collateralAddr = bech32.encode('addr_test', bech32.toWords(Buffer.from(collateralAddrHash, 'hex')), 128),
            collateralNFT = nftLabel + collateralStakeHash

          const { stdout } = await exec(`cardano-cli query utxo --address ${collateralAddr} --testnet-magic 2 --output-json`)

          const utxos = JSON.parse(stdout)

          let collateralHold = 0n,
            collateralTVL = 0n

          for (const outRef of Object.keys(utxos)) {
            const utxo = utxos[outRef]

            if (utxo?.value?.[treasury.cred]?.[collateralNFT] == 1) {
              const collateralDatum = utxo.inlineDatum

              collateralHold = BigInt(collateralDatum.fields[2].fields[0].int)
              collateralTVL = BigInt(utxo.value.lovelace)

              txReq += ` --tx-in ${outRef}`
              txReq += ` --spending-tx-in-reference ${scRefTxIn}`
              txReq += ` --spending-plutus-script-v2`
              txReq += ` --spending-reference-tx-in-inline-datum-present`
              txReq += ` --spending-reference-tx-in-redeemer-file ${redeemerWrapped}`

              break
            }
          }

          // treasury output
          const treasuryHold = treasury.hold.toString(),
            treasuryTotalHold = (treasury.total_hold + mintedHoldQty).toString(),
            treasuryTVL = (tvl + lockedAmount).toString(),
            treasuryDatumFileName = join(tmpDir, `treasury_datum.json`),
            treasuryDatumJSON = treasuryDatum.replace('"_treasuryHold_"', treasuryHold).replace('"_treasuryTotalHold_"', treasuryTotalHold).replace('"_treasuryTVL_"', treasuryTVL)

          await writeFile(treasuryDatumFileName, treasuryDatumJSON)

          txReq += ` --tx-out ${treasury.address}+${treasury.value + treasury.reward}+"1 ${treasury.cred}.${treasury.nft}"`
          txReq += ` --tx-out-inline-datum-file ${treasuryDatumFileName}`

          // collateral output
          const collateralHoldQty = (collateralHold + mintedHoldQty).toString(),
            collateralDatumJSON = JSON.stringify({
              constructor: 0,
              fields: [
                treasury.datum.fields[0],
                treasury.datum.fields[1],
                {
                  constructor: 0,
                  fields: [{
                    int: '_collateralHold_'
                  }]
                }
              ]
            }).replace('"_collateralHold_"', collateralHoldQty),
            collateralDatumFileName = join(tmpDir, `collateral_datum.json`)

          await writeFile(collateralDatumFileName, collateralDatumJSON)

          txReq += ` --tx-out ${collateralAddr}+${collateralTVL + lockedAmount}+"1 ${treasury.cred}.${collateralNFT}"`
          txReq += ` --tx-out-inline-datum-file ${collateralDatumFileName}`

          // collateral nft
          if (!collateralTVL) {
            mint.push(`1 ${treasury.cred}.${collateralNFT}`)
          }
        }

        // withdrawal
        txReq += ` --withdrawal ${treasury.stake_address}+${treasury.reward}`
        txReq += ` --withdrawal-tx-in-reference ${scRefTxIn}`
        txReq += ` --withdrawal-plutus-script-v2`
        txReq += ` --withdrawal-reference-tx-in-redeemer-file ${redeemerMint}`

        // collateral input
        const collateralUtxoHash = data.collateral_input[0],
          collateralUtxoIdx = parseInt(data.collateral_input[1])
        if (/^[0-9A-Fa-f]{64}$/.test(collateralUtxoHash) && collateralUtxoIdx >= 0) {
          txReq += ` --tx-in-collateral ${collateralUtxoHash}#${collateralUtxoIdx}`
        }

        // collateral return
        const collateralTokenChange = []
        for (const policyId of Object.keys(data.collateral_tokens)) {
          if (/^[0-9A-Fa-f]{56}$/.test(policyId)) {
            for (const [tokenName, tokenQty] of Object.entries(data.collateral_tokens[policyId])) {
              if (/^[0-9A-Fa-f]{0,64}$/.test(tokenName)) {
                collateralTokenChange.push(`${BigInt(tokenQty as number)} ${policyId}.${tokenName}`)
              }
            }
          }
        }
        const totalCollateral = collateralAmount >= 7_000_000n || collateralTokenChange.length ? 5_000_000n : collateralAmount,
          collateralChange = collateralAmount - totalCollateral

        txReq += ` --tx-total-collateral ${totalCollateral}`
        if (collateralChange > 0) {
          txReq += ` --tx-out-return-collateral ${changeAddress}+${collateralChange}`
          if (collateralTokenChange.length) {
            txReq += `+"${collateralTokenChange.join('+')}"`
          }
        }

        // change address
        txReq += ` --change-address ${changeAddress}`

        // mint
        mint.push(`${mintedHoldQty} ${treasury.cred}.${mintedTokenName}`)
        txReq += ` --mint "${mint.join('+')}"`
        txReq += ` --mint-tx-in-reference ${scRefTxIn}`
        txReq += ` --mint-plutus-script-v2`
        txReq += ` --mint-reference-tx-in-redeemer-file ${redeemerMint}`
        txReq += ` --policy-id ${treasury.cred}`

        // certs
        txReq += ` --certificate-file ${deregCert}`
        txReq += ` --certificate-tx-in-reference ${scRefTxIn}`
        txReq += ` --certificate-plutus-script-v2`
        txReq += ` --certificate-reference-tx-in-redeemer-file ${redeemerMint}`
        txReq += ` --certificate-file ${regCert}`
        txReq += ` --certificate-file ${delegCert}`
        txReq += ` --certificate-tx-in-reference ${scRefTxIn}`
        txReq += ` --certificate-plutus-script-v2`
        txReq += ` --certificate-reference-tx-in-redeemer-file ${redeemerMint}`

        txReq += ` --testnet-magic 2`

        const txFileName = join(tmpDir, `tx.raw`)
        txReq += ` --out-file ${txFileName} > /dev/null`

        const { stdout } = await exec(txReq + ` && cat ${txFileName}`)

        const txJSON = JSON.parse(stdout)

        txCBOR = txJSON.cborHex
      } else { // burning
        // inputs
        for (const utxoIn of data.inputs) {
          const utxoHash = utxoIn[0],
            utxoIdx = parseInt(utxoIn[1])
          if (/^[0-9A-Fa-f]{64}$/.test(utxoHash) && utxoIdx >= 0) {
            txReq += ` --tx-in ${utxoHash}#${utxoIdx}`
          }
        }
        txReq += ` --tx-in ${treasury.utxo}`
        txReq += ` --spending-tx-in-reference ${scRefTxIn}`
        txReq += ` --spending-plutus-script-v2`
        txReq += ` --spending-reference-tx-in-inline-datum-present`
        txReq += ` --spending-reference-tx-in-redeemer-file ${redeemerWrapped}`
        if (mintedTokenName == treasury.token) {
          // treasury output
          const unlockedAmount = -mintedHoldQty * tvl / treasury.total_hold,
            treasuryHold = (treasury.hold + mintedHoldQty).toString(),
            treasuryTotalHold = (treasury.total_hold + mintedHoldQty).toString(),
            treasuryTVL = (tvl - unlockedAmount).toString(),
            treasuryDatumFileName = join(tmpDir, `treasury_datum.json`),
            treasuryDatumJSON = treasuryDatum.replace('"_treasuryHold_"', treasuryHold).replace('"_treasuryTotalHold_"', treasuryTotalHold).replace('"_treasuryTVL_"', treasuryTVL)

          await writeFile(treasuryDatumFileName, treasuryDatumJSON)

          txReq += ` --tx-out ${treasury.address}+${treasury.value + treasury.reward - unlockedAmount}+"1 ${treasury.cred}.${treasury.nft}"`
          txReq += ` --tx-out-inline-datum-file ${treasuryDatumFileName}`
        } else {
          // collateral output
          const collateralStakeHash = mintedTokenName.slice(8),
            collateralAddrHeader = mintedTokenName.slice(0, 8) == pubkeyLabel ? '10' : '30',
            collateralAddrHash = collateralAddrHeader + treasury.cred + collateralStakeHash,
            collateralAddr = bech32.encode('addr_test', bech32.toWords(Buffer.from(collateralAddrHash, 'hex')), 128),
            collateralNFT = nftLabel + collateralStakeHash

          const { stdout } = await exec(`cardano-cli query utxo --address ${collateralAddr} --testnet-magic 2 --output-json`)

          const utxos = JSON.parse(stdout)

          let collateralHold = 0n,
            collateralTVL = 0n

          for (const outRef of Object.keys(utxos)) {
            const utxo = utxos[outRef]

            if (utxo?.value?.[treasury.cred]?.[collateralNFT] == 1) {
              const collateralDatum = utxo.inlineDatum

              collateralHold = BigInt(collateralDatum.fields[2].fields[0].int)
              collateralTVL = BigInt(utxo.value.lovelace)

              txReq += ` --tx-in ${outRef}`
              txReq += ` --spending-tx-in-reference ${scRefTxIn}`
              txReq += ` --spending-plutus-script-v2`
              txReq += ` --spending-reference-tx-in-inline-datum-present`
              txReq += ` --spending-reference-tx-in-redeemer-file ${redeemerWrapped}`

              break
            }
          }

          const unlockedAmount = -mintedHoldQty * tvl * 97n / (treasury.total_hold * 100n),
            collateralHoldLeft = collateralHold + mintedHoldQty,
            collateralValueLeft = collateralHoldLeft > 0 ? collateralHoldLeft * collateralTVL / collateralHold : 0n,
            collateralValueUnlocked = collateralTVL - collateralValueLeft,
            treasuryValueUnlocked = unlockedAmount - collateralValueUnlocked


          // treasury output
          const treasuryHold = treasury.hold.toString(),
            treasuryTotalHold = (treasury.total_hold + mintedHoldQty).toString(),
            treasuryTVL = (tvl - unlockedAmount).toString(),
            treasuryDatumFileName = join(tmpDir, `treasury_datum.json`),
            treasuryDatumJSON = treasuryDatum.replace('"_treasuryHold_"', treasuryHold).replace('"_treasuryTotalHold_"', treasuryTotalHold).replace('"_treasuryTVL_"', treasuryTVL)

          await writeFile(treasuryDatumFileName, treasuryDatumJSON)

          txReq += ` --tx-out ${treasury.address}+${treasury.value + treasury.reward - treasuryValueUnlocked}+"1 ${treasury.cred}.${treasury.nft}"`
          txReq += ` --tx-out-inline-datum-file ${treasuryDatumFileName}`

          // collateral output
          if (collateralHoldLeft > 0) {
            const collateralHoldQty = collateralHoldLeft.toString(),
              collateralDatumJSON = JSON.stringify({
                constructor: 0,
                fields: [
                  treasury.datum.fields[0],
                  treasury.datum.fields[1],
                  {
                    constructor: 0,
                    fields: [{
                      int: '_collateralHold_'
                    }]
                  }
                ]
              }).replace('"_collateralHold_"', collateralHoldQty),
              collateralDatumFileName = join(tmpDir, `collateral_datum.json`)

            await writeFile(collateralDatumFileName, collateralDatumJSON)

            txReq += ` --tx-out ${collateralAddr}+${collateralValueLeft}+"1 ${treasury.cred}.${collateralNFT}"`
            txReq += ` --tx-out-inline-datum-file ${collateralDatumFileName}`
          } else {
            // collateral nft
            mint.push(`-1 ${treasury.cred}.${collateralNFT}`)
          }
        }

        // withdrawal
        txReq += ` --withdrawal ${treasury.stake_address}+${treasury.reward}`
        txReq += ` --withdrawal-tx-in-reference ${scRefTxIn}`
        txReq += ` --withdrawal-plutus-script-v2`
        txReq += ` --withdrawal-reference-tx-in-redeemer-file ${redeemerBurn}`

        // collateral input
        const collateralUtxoHash = data.collateral_input[0],
          collateralUtxoIdx = parseInt(data.collateral_input[1])
        if (/^[0-9A-Fa-f]{64}$/.test(collateralUtxoHash) && collateralUtxoIdx >= 0) {
          txReq += ` --tx-in-collateral ${collateralUtxoHash}#${collateralUtxoIdx}`
        }

        // collateral return
        const collateralTokenChange = []
        for (const policyId of Object.keys(data.collateral_tokens)) {
          if (/^[0-9A-Fa-f]{56}$/.test(policyId)) {
            for (const [tokenName, tokenQty] of Object.entries(data.collateral_tokens[policyId])) {
              if (/^[0-9A-Fa-f]{0,64}$/.test(tokenName)) {
                collateralTokenChange.push(`${BigInt(tokenQty as number)} ${policyId}.${tokenName}`)
              }
            }
          }
        }
        const totalCollateral = collateralAmount >= 7_000_000n || collateralTokenChange.length ? 5_000_000n : collateralAmount,
          collateralChange = collateralAmount - totalCollateral

        txReq += ` --tx-total-collateral ${totalCollateral}`
        if (collateralChange > 0) {
          txReq += ` --tx-out-return-collateral ${changeAddress}+${collateralChange}`
          if (collateralTokenChange.length) {
            txReq += `+"${collateralTokenChange.join('+')}"`
          }
        }

        // change address
        txReq += ` --change-address ${changeAddress}`

        // mint
        mint.push(`${mintedHoldQty} ${treasury.cred}.${mintedTokenName}`)
        txReq += ` --mint "${mint.join('+')}"`
        txReq += ` --mint-tx-in-reference ${scRefTxIn}`
        txReq += ` --mint-plutus-script-v2`
        txReq += ` --mint-reference-tx-in-redeemer-file ${redeemerBurn}`
        txReq += ` --policy-id ${treasury.cred}`

        // certs
        txReq += ` --certificate-file ${deregCert}`
        txReq += ` --certificate-tx-in-reference ${scRefTxIn}`
        txReq += ` --certificate-plutus-script-v2`
        txReq += ` --certificate-reference-tx-in-redeemer-file ${redeemerBurn}`
        txReq += ` --certificate-file ${regCert}`
        txReq += ` --certificate-file ${delegCert}`
        txReq += ` --certificate-tx-in-reference ${scRefTxIn}`
        txReq += ` --certificate-plutus-script-v2`
        txReq += ` --certificate-reference-tx-in-redeemer-file ${redeemerBurn}`

        txReq += ` --testnet-magic 2`

        const txFileName = join(tmpDir, `tx.raw`)
        txReq += ` --out-file ${txFileName} > /dev/null`

        const { stdout } = await exec(txReq + ` && cat ${txFileName}`)

        const txJSON = JSON.parse(stdout)

        txCBOR = txJSON.cborHex
      }

      rm(tmpDir, { recursive: true, force: true })
    } catch (e) {
      // do nothing
      console.log(e)
    }
  }

  return txCBOR
}

server.get('/treasury', async () => {
  await findTreasury()

  return treasury.utxo ? {
    statusCode: 200,
    data: {
      tvl: treasury.tvl + treasury.reward,
      total_supply: treasury.total_hold
    }
  } : {
    statusCode: 500
  }
})

server.post('/tx', {
  schema: {
    body: {
      type: 'object',
      properties: {
        inputs: {
          type: 'array',
          items: {
            type: 'array'
          },
        },
        input_tokens: {
          type: 'object'
        },
        input_amount: {
          type: 'string'
        },
        collateral_input: {
          type: 'array',
        },
        collateral_tokens: {
          type: 'object'
        },
        collateral_amount: {
          type: 'string'
        },
        hold_qty: {
          type: 'string'
        },
        change_address: {
          type: 'string'
        },
        token_name: {
          type: 'string'
        },
      },
      required: ['inputs', 'input_tokens', 'input_amount', 'hold_qty', 'collateral_input', 'collateral_tokens', 'collateral_amount', 'change_address', 'token_name'],
    }
  }
}, async (req: any) => {
  const res: {
    statusCode: number
    data?: Record<string, any>
  } = {
    statusCode: 500
  }

  try {
    const tx = await getTX(req.body)

    if (tx) {
      res.statusCode = 200
      res.data = {
        tx: tx,
        tvl: treasury.tvl + treasury.reward,
        total_supply: treasury.total_hold
      }
    }
  } catch (e) {
    // do nothing
  }

  return res
})

server.post('/send', {
  schema: {
    body: {
      type: 'object',
      properties: {
        tx: {
          type: 'string'
        },
        witnesses: {
          type: 'array',
          items: {
            type: 'string'
          },
        },
      },
      required: ['tx', 'witnesses'],
    }
  }
}, async (req: any) => {
  const res: {
    statusCode: number
    data?: Record<string, any>
  } = {
    statusCode: 500
  }

  try {
    const tmpDir = await mkdtemp(join(tmpdir(), 'adahold-'))

    const txCbor = req.body.tx,
      witnesses = req.body.witnesses,
      txFileName = join(tmpDir, `tx.raw`)

    let txReq = `cardano-cli transaction assemble`

    await writeFile(txFileName, JSON.stringify({
      type: 'Unwitnessed Tx BabbageEra',
      description: 'Ledger Cddl Format',
      cborHex: txCbor
    }))

    txReq += ` --tx-body-file ${txFileName}`

    for (let i = 0; i < witnesses.length; i++) {
      const witnessFileName = join(tmpDir, `witness.${i}`)

      await writeFile(witnessFileName, JSON.stringify({
        type: 'TxWitness BabbageEra',
        description: 'Key Witness ShelleyEra',
        cborHex: witnesses[i]
      }))

      txReq += ` --witness-file ${witnessFileName}`
    }

    txReq += ` --out-file ${txFileName}`

    const { stdout } = await exec(txReq + ` && cardano-cli transaction submit --tx-file ${txFileName} --testnet-magic 2 > /dev/null && cardano-cli transaction txid --tx-body-file ${txFileName}`)

    const txHash = stdout.trim()

    if (/^[0-9A-Fa-f]{64}$/.test(txHash)) {
      treasury.utxo = txHash + '#0'

      await findTreasury()

      res.statusCode = 200
      res.data = {
        tx_hash: txHash,
        tvl: treasury.tvl + treasury.reward,
        total_supply: treasury.total_hold
      }
    }

    rm(tmpDir, { recursive: true, force: true })
  } catch (e) {
    // do nothing
    console.log(e)
  }

  return res
})

const start = async (): Promise<void> => {
  await findTreasury()

  server.listen({ host: '0.0.0.0', port: parseInt(process.env.HTTP_PORT!) || 5273 }, (err: any, address: any) => {
    if (err) {
      console.error(err)
      process.exit(1)
    }
    console.log(`Server listening at ${address}`)
  })
}

export { start }
