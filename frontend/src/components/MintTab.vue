<template>
  <div class="ml-11">
    <template v-if="step == 1">
      <div class="-ml-11 mb-6 flex items-center font-medium">
        <ForwardIcon class="-ml-0.5 mr-0.5 w-5 stroke-2" />
        <div class="mr-2 w-4 text-right">1.</div>
        <div>Enter HOLD amount to mint</div>
      </div>
      <div class="mb-6 flex flex-wrap gap-3">
        <div class="relative">
          <input
            type="text"
            inputmode="decimal"
            placeholder="1234.567890"
            v-model="inputValue"
            @keyup.enter="setInputValue()"
            class="h-9 w-50 rounded border bg-gray pl-3 pr-9 text-sm outline-none"
            :class="inputValue === '' || isInputValid ? 'border-yellow' : 'border-red shadow-red'"
            ref="input" />
          <button v-if="inputValue !== ''" class="flex-center absolute right-0 top-0 h-9 w-9 text-beige/70 hover:text-beige" @click="clearInputValue">
            <CloseIcon class="w-3 stroke-2"></CloseIcon>
          </button>
        </div>
      </div>
      <Transition enter-active-class="transition duration-700" enter-from-class="opacity-0" mode="out-in">
        <div v-if="isInputValid">
          <div class="mb-6 text-xs">
            It will lock
            <b
              >{{ fLockedAmount.groupInteger
              }}<span class="font-normal"
                ><span class="text-smaller text-beige">{{ fLockedAmount.decimal }}{{ fLockedAmount.fraction }}</span></span
              >
              ₳
            </b>
          </div>
          <button class="h-9 rounded bg-yellow/70 px-6 text-sm font-bold text-black hover:bg-yellow" @click="setInputValue()">Confirm</button>
        </div>
        <div v-else>
          <div class="mb-6 text-xs">or select one of the preset options</div>
          <div class="flex flex-wrap gap-3">
            <button
              class="h-9 rounded bg-yellow/70 px-3 text-black transition hover:bg-yellow sm:px-6"
              :key="v"
              v-for="v of [1, 5, 25, 100]"
              @click="setInputValue(v * 1_000)">
              <b class="hidden sm:block">{{ formatAdaHold(BigInt(v) * 1_000_000_000n).groupInteger }}</b>
              <b class="sm:hidden">{{ v }}K</b>
            </button>
          </div>
        </div>
      </Transition>
    </template>
    <div v-else class="-ml-11 mb-9 flex flex-wrap items-center">
      <CheckMarkIcon class="w-5 stroke-2 text-green" />
      <div class="relative mr-2 w-4 text-right">1.</div>
      <div>Amount to mint:</div>
      <div v-if="step < 4 && !waitingTx" @click="initStep()" class="cursor-pointer [&_svg]:hover:text-yellow">
        <b class="ml-5 border-b border-dashed border-beige"
          >{{ fInputValue.groupInteger
          }}<span class="font-normal"
            ><span class="text-smaller text-beige">{{ fInputValue.decimal }}{{ fInputValue.fraction }}</span></span
          >
        </b>
        <span class="ml-1 text-lg leading-6">Ⓗ</span>
        <ChangeIcon class="-mt-0.5 ml-3 inline-block w-4 stroke-2 text-yellow/70" />
      </div>
      <div v-else>
        <b class="ml-5"
          >{{ fInputValue.groupInteger
          }}<span class="font-normal"
            ><span class="text-smaller text-beige">{{ fInputValue.decimal }}{{ fInputValue.fraction }}</span></span
          >
        </b>
        <span class="ml-1 text-lg leading-6">Ⓗ</span>
      </div>
    </div>

    <div v-if="step < 2" class="-ml-6 mt-9 flex items-center opacity-40">
      <div class="mr-2 w-4 text-right">2.</div>
      <div>Select preferred Treasury tax</div>
    </div>
    <template v-else-if="step == 2">
      <div class="-ml-11 mb-6 mt-9 flex items-center font-medium">
        <ForwardIcon class="-ml-0.5 mr-0.5 w-5 stroke-2" />
        <div class="mr-2 w-4 text-right">2.</div>
        <div>Select preferred Treasury tax</div>
      </div>
      <div class="mb-6 flex flex-wrap gap-3">
        <button
          class="flex-center flex h-9 w-28 rounded bg-yellow/70 px-6 font-bold text-black transition hover:bg-yellow"
          :key="v"
          v-for="v of [0, 3]"
          @click="setTreasuryTax(v)">
          {{ v }}%
        </button>
      </div>
      <div class="text-xs">
        <div>Treasury tax will be paid when Burning your HOLD.</div>
        <div>Select 0% to pay no Treasury tax and get no staking rewards for locked ADA.</div>
        <div>Select 3% to pay 3% Treasury tax and get staking rewards for locked ADA.</div>
      </div>
    </template>
    <div v-else class="-ml-11 mb-9 flex flex-wrap items-center">
      <CheckMarkIcon class="w-5 stroke-2 text-green" />
      <div class="relative mr-2 w-4 text-right">2.</div>
      <div>Treasury tax:</div>
      <div v-if="step < 4 && !waitingTx" @click="setInputValue()" class="cursor-pointer [&_svg]:hover:text-yellow">
        <b class="ml-5 border-b border-dashed border-beige">{{ treasuryTax }}% </b>
        <ChangeIcon class="-mt-0.5 ml-3 inline-block w-4 stroke-2 text-yellow/70" />
      </div>
      <b v-else class="ml-5">{{ treasuryTax }}% </b>
    </div>

    <div v-if="step < 3" class="-ml-6 mt-9 flex items-center opacity-40">
      <div class="mr-2 w-4 text-right">3.</div>
      <div>Make minting transaction</div>
    </div>
    <template v-else-if="waitingTx">
      <div class="-ml-11 mb-6 mt-9 flex items-center font-medium">
        <LoadingIcon class="w-5 animate-spin text-yellow" />
        <div class="mr-2 w-4 text-right">3.</div>
        <div>Minting transaction</div>
      </div>
      <div class="flex-center pr-11 text-sm">
        <div class="max-w-160">
          <p class="mb-6 text-center">Well, it's almost done! Your HOLDs are rushing to you!</p>
          <p class="mb-6">
            Please be patient, it may take a while. If you don't want to wait, you can
            <a class="cursor-pointer text-beige" @click="initStep()">refresh the page</a>, or just close it. No worries, it is completely safe for your assets.
          </p>
          <p>
            After the transaction settlement, your balance will be updated automatically. You can also track the transaction in your favorite explorer by its
            hash
            <a class="cursor-pointer text-nowrap text-beige underline decoration-dashed underline-offset-2" @click="copyTxHash"
              >{{ waitingTx.slice(0, 8) + '…' + waitingTx.slice(-8)
              }}<Transition enter-active-class="transition duration-700" enter-from-class="opacity-0" mode="out-in">
                <CheckMarkIcon v-if="txHashCopied" class="-mt-0.5 ml-1 inline-block w-4 stroke-2" />
                <CopyIcon v-else class="-mt-0.5 ml-1 inline-block w-4 cursor-pointer" />
              </Transition>
            </a>
          </p>
        </div>
      </div>
    </template>
    <template v-else-if="step == 4">
      <div class="-ml-11 mb-6 mt-9 flex items-center font-medium">
        <CheckMarkIcon class="w-5 stroke-2 text-green" />
        <div class="mr-2 w-4 text-right">3.</div>
        <div>Minting transaction</div>
      </div>
      <div class="flex-center pr-11 text-sm">
        <div class="max-w-160">
          <p class="mb-6 text-center">Woohoo! Your HOLDs are in your wallet! What's next?</p>
          <p>
            Now you can <a class="cursor-pointer text-beige" @click="initStep()">refresh the page</a> in case you want to mint another batch of HOLDs, or simply
            close it. And remember, HOLD is the best strategy! Have a good one!
          </p>
        </div>
      </div>
    </template>
    <template v-else>
      <div class="-ml-11 mb-6 mt-9 flex items-center font-medium">
        <ForwardIcon class="-ml-0.5 mr-0.5 w-5 stroke-2" />
        <div class="mr-2 w-4 text-right">3.</div>
        <div>Make minting transaction</div>
      </div>
      <div class="flex-center max-w-80 pr-11 xl:max-w-88" v-if="calculatingTx">
        <LoadingIcon class="w-8 animate-spin" />
      </div>
      <div v-else-if="txFee > 0" class="max-w-80 pr-11 xl:max-w-88">
        <div class="mb-6 flex justify-between text-xs">
          <div>Locked amount:</div>
          <i class="mx-1 mb-1 flex-1 self-stretch bg-gradient-to-r from-beige from-35% to-transparent to-0% bg-dotted bg-left-bottom bg-repeat-x"></i>
          <b>
            {{ fLockedAmount.groupInteger }}<span class="text-smaller font-normal text-beige">{{ fLockedAmount.decimal }}{{ fLockedAmount.fraction }}</span>
            ₳
          </b>
        </div>
        <div class="mb-6 flex justify-between text-xs">
          <div>Transaction fee:</div>
          <i class="mx-1 mb-1 flex-1 self-stretch bg-gradient-to-r from-beige from-35% to-transparent to-0% bg-dotted bg-left-bottom bg-repeat-x"></i>
          <b class="relative">
            {{ fTxFee.groupInteger }}<span class="text-smaller font-normal text-beige">{{ fTxFee.decimal }}{{ fTxFee.fraction }}</span> ₳
            <span v-if="!connectedWallet" class="absolute -top-1 left-full font-normal">*</span>
          </b>
        </div>
        <div class="mb-8 text-right text-sm">
          <span class="mr-3">You pay:</span>
          <b class="relative">
            {{ fTotalAmount.groupInteger }}<span class="text-smaller font-normal text-beige">{{ fTotalAmount.decimal }}{{ fTotalAmount.fraction }}</span> ₳
            <span v-if="!connectedWallet" class="absolute -top-1 left-full font-normal">*</span>
          </b>
        </div>
        <div class="flex-center text-sm font-bold text-black md:text-base">
          <button
            v-if="connectedWallet"
            @click="mint"
            class="flex-center flex h-10 w-20 rounded bg-yellow/70 transition hover:bg-yellow md:h-13 md:w-32 md:rounded-lg">
            <LoadingIcon v-if="lockScreen" class="h-6 animate-spin" />
            <template v-else>Mint</template>
          </button>
          <button v-else @click="openModal('WalletConnector')" class="h-10 w-38 rounded bg-yellow/70 transition hover:bg-yellow md:h-13 md:w-50 md:rounded-lg">
            Connect Wallet
          </button>
        </div>
        <div v-if="connectedWallet" class="mt-6 text-xs">
          <div>Your HOLD tokens will be sent to you in the minting transaction</div>
        </div>
        <div v-else class="mt-6 flex text-xs">
          <div class="-ml-2 min-w-2">*</div>
          <div>These values are estimated. Please connect your wallet to see the accurate numbers.</div>
        </div>
      </div>
      <div v-else class="-ml-10 max-w-88 pr-1 text-xs text-red xl:max-w-96">
        An error has occured during the transaction building. This can be caused by various reasons. We are going to show the error reason, but it has not been
        implemented yet. So, for now please try to connect another one wallet, change HOLD amount, or refresh page and try again.
      </div>
    </template>

    <div v-if="lockScreen" class="fixed left-0 top-0 z-10 h-full w-full"></div>
    <ConfettiAnimation v-if="step == 4" />
  </div>
</template>

<script lang="ts">
import { ref, computed, watch, onMounted, nextTick } from 'vue'
import state from '@/state'
import { openModal } from '@/components/ModalWindow.vue'
import ConfettiAnimation, { start as startConfetti } from '@/components/ConfettiAnimation.vue'
import CloseIcon from '@/components/icons/CloseIcon.vue'
import ChangeIcon from '@/components/icons/ChangeIcon.vue'
import ForwardIcon from '@/components/icons/ForwardIcon.vue'
import CheckMarkIcon from '@/components/icons/CheckMarkIcon.vue'
import LoadingIcon from '@/components/icons/LoadingIcon.vue'
import CopyIcon from '@/components/icons/CopyIcon.vue'
import { formatAdaHold, cborStrToBuffer, cborBufferToStr } from '@/utils'
import { connectedWallet } from '@/components/WalletConnector.vue'
import { decode as cborDecode, encode as cborEncode } from 'cborg'
import { bigIntDecoder as cborBigIntDecoder, bigIntEncoder as cborBigIntEncoder } from 'cborg/taglib'
import type { TagDecoder } from 'cborg/interface'

let tx: any,
  confettiDone = false

class Tag {
  tag
  value

  constructor(tag: any, value: any) {
    this.tag = tag
    this.value = value
  }
}

const step = ref(1),
  inputValue = ref(''),
  // holdAmount = ref(0n),
  // lockedAmount = ref(0n),
  treasuryTax = ref(-1),
  txFee = ref(0n),
  calculatingTx = ref(true),
  waitingTx = ref(''),
  tags: TagDecoder[] = new Proxy([], {
    get: function (target: any[], name: any) {
      return target[name] || ((value: any) => new Tag(name, value))
    },
  }),
  lockScreen = ref(false),
  txHashCopied = ref(false)

tags[2] = cborBigIntDecoder

const fInputValue = computed(() => formatAdaHold(holdAmount.value))

const fLockedAmount = computed(() => formatAdaHold(lockedAmount.value))

const fTxFee = computed(() => formatAdaHold(txFee.value))

const fTotalAmount = computed(() => formatAdaHold(txFee.value + lockedAmount.value))

const isInputValid = computed(() => inputValue.value && /^(\d+(?:[.,]\d{0,6})?)$/.test(inputValue.value))

const holdAmount = computed(() => (isInputValid.value ? BigInt((inputValue.value.replace(',', '.') as unknown as number) * 1_000_000) : 0n))

const lockedAmount = computed(() => (isInputValid.value ? (holdAmount.value * state.totalValueLocked) / state.totalSupply : 0n))

const setInputValue = (amount?: number) => {
  if (amount) {
    inputValue.value = '' + amount
  }
  if (isInputValid.value) {
    // holdAmount.value = BigInt((inputValue.value.replace(',', '.') as unknown as number) * 1_000_000)
    // lockedAmount.value = (holdAmount.value * 121932543212n) / 98765432100n
    treasuryTax.value = -1
    step.value = 2
  }
}

const initStep = () => {
  waitingTx.value = ''
  inputValue.value = ''
  // holdAmount.value = 0n
  step.value = 1
  confettiDone = false
}

const createTx = async () => {
  try {
    const connectedWalletObject = connectedWallet.value!,
      walletApi = connectedWalletObject.api

    const spendAdaAmount = lockedAmount.value,
      requiredAdaAmount = spendAdaAmount + 8_000_000n, // reserve 8 ada for min UTXO change value, fee, collateral, etc
      cborUtxos = await walletApi.getUtxos(/* cborBufferToStr(cborEncode(requiredAdaAmount)) */), // we'd rather to send required amount, but unfortunately not all wallets return the correct set of UTXOs in this case, so we need to request all UTXOs and choose the ones that meet the conditions ourselves
      utxosTokens = [],
      utxosNoTokens = [],
      utxos = []

    for (const cborString of cborUtxos) {
      const utxoData = cborDecode(cborStrToBuffer(cborString), { useMaps: true, tags })

      for (let i = 0; i < utxoData.length; i++) {
        // some wallets have Map instead Array
        if (utxoData[1] instanceof Map) {
          utxoData[1] = [utxoData[1].get(0), utxoData[1].get(1)]
        }
      }

      if (Array.isArray(utxoData[1][1])) {
        const utxoAmount = BigInt(utxoData[1][1][0])
        utxoData[1][1][0] = utxoAmount
        utxosTokens.push(utxoData)
      } else {
        const utxoAmount = BigInt(utxoData[1][1])
        utxoData[1][1] = utxoAmount
        utxosNoTokens.push(utxoData)

        if (utxoAmount >= requiredAdaAmount) {
          if (!utxos.length || utxos[0][1][1] > utxoAmount) {
            utxos[0] = utxoData
          }
        }
      }
    }

    let amount = 0n
    if (utxos.length) {
      // we've already found the UTXO that covers the required amount
      amount = utxos[0][1][1]
    } else {
      utxosNoTokens.sort((a, b) => {
        let ret = 0
        if (a[1][1] < b[1][1]) {
          ret = 1
        } else if (a[1][1] > b[1][1]) {
          ret = -1
        }
        return ret
      })
      for (let utxoData of utxosNoTokens) {
        utxos.push(utxoData)
        amount += utxoData[1][1]

        if (amount >= requiredAdaAmount) {
          break
        }
      }

      if (amount < requiredAdaAmount) {
        utxosTokens.sort((a, b) => {
          let ret = 0
          if (a[1][1][0] < b[1][1][0]) {
            ret = 1
          } else if (a[1][1][0] > b[1][1][0]) {
            ret = -1
          }
          return ret
        })
        for (let utxoData of utxosTokens) {
          utxos.push(utxoData)
          amount += utxoData[1][1][0]

          if (amount >= requiredAdaAmount) {
            break
          }
        }
      }
    }

    if (amount >= requiredAdaAmount) {
      // all is good
      const changeAddress = await walletApi.getChangeAddress(),
        witnesses: Set<string> = new Set(),
        inputs: any[] = [],
        // outputs: any[] = [
        //   [cborStrToBuffer('60e601300163c9e1e5e12408741700a211b3aeb48996a822ca1c948d1d'), spendAdaAmount], // for testing, we send the required amount to addr_test1vrnqzvqpv0y7re0pysy8g9cq5ggm8t453xt2sgk2rj2g68gx8xuhw
        //   [cborStrToBuffer(changeAddress), amount - spendAdaAmount - 100000n],
        // ], // assume the inputs don't have any tokens
        tokens: Map<string, Map<string, bigint>> = new Map()
      // payload: Map<number, any> = new Map()

      // console.log(utxos)
      const tx_inputs = []

      let collateralInput: any = [],
        collateralTokens: any = {},
        collateralAmount = 0n

      const collateralCBORArr = await walletApi.getCollateral()
      if (collateralCBORArr && collateralCBORArr.length) {
        for (const collateralCBOR of collateralCBORArr) {
          const collateralData = cborDecode(cborStrToBuffer(collateralCBOR), { useMaps: true, tags })

          if (collateralData && collateralData.length == 2 && !Array.isArray(collateralData[1][1]) && collateralData[1][1] >= 5_000_000) {
            collateralInput = [cborBufferToStr(collateralData[0][0]), collateralData[0][1]]
            collateralAmount = BigInt(collateralData[1][1])
            break
          }
        }
      }

      for (let utxoData of utxos) {
        tx_inputs.push([cborBufferToStr(utxoData[0][0]), utxoData[0][1]])
        inputs.push(utxoData[0])

        witnesses.add(cborBufferToStr(utxoData[1][0]))

        if (Array.isArray(utxoData[1][1])) {
          for (const [policyBuf, tokensData] of utxoData[1][1][1]) {
            const policy = cborBufferToStr(policyBuf),
              policyMap = tokens.get(policy) || new Map<string, bigint>()

            if (!collateralInput.length) {
              if (!collateralTokens[policy]) {
                collateralTokens[policy] = {}
              }
            }

            if (!policyMap.size) {
              tokens.set(policy, policyMap)
            }

            for (const [nameRaw, qty] of tokensData) {
              const name = cborBufferToStr(nameRaw),
                bigIntQty = BigInt(qty)

              if (!collateralInput.length) {
                collateralTokens[policy][name] = bigIntQty
              }

              policyMap.set(name, (policyMap.get(name) || 0n) + bigIntQty)
            }
          }
          if (!collateralInput.length) {
            collateralAmount = utxoData[1][1][0]
          }
        } else {
          if (!collateralInput.length) {
            collateralAmount = utxoData[1][1]
          }
        }

        if (!collateralInput.length) {
          collateralInput = tx_inputs[tx_inputs.length - 1]
        }
      }

      let token_name = ''
      if (treasuryTax.value) {
        const rewardAddress = await walletApi.getRewardAddresses()
        if (rewardAddress && rewardAddress.length) {
          token_name = (rewardAddress[0].slice(0, 1).toLowerCase() == 'e' ? '0014df10' : '001bc280') + rewardAddress[0].slice(2)
        }
      }

      const body_obj = {
        inputs: tx_inputs,
        input_tokens: tokens,
        input_amount: amount,
        collateral_input: collateralInput,
        collateral_tokens: collateralTokens,
        collateral_amount: collateralAmount,
        change_address: changeAddress,
        hold_qty: holdAmount.value,
        token_name: token_name,
      }

      const fetchRes = await fetch('/api/rest/v0/tx', {
        method: 'POST',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body_obj),
      })
      const data = await fetchRes.json()

      if (data.statusCode == 200) {
        state.totalSupply = BigInt(data.data.total_supply)
        state.totalValueLocked = BigInt(data.data.tvl)

        const txDecode = cborDecode(cborStrToBuffer(data.data.tx), { useMaps: true, tags })

        txFee.value = BigInt(txDecode[0].get(2))

        tx = data.data.tx
      }

      // if (tokens.size) {
      //   const tokensBuffer = new Map()
      //   for (const [policy, policyMap] of tokens) {
      //     const policyMapBuffer = new Map()

      //     for (const [name, qty] of policyMap) {
      //       policyMapBuffer.set(cborStrToBuffer(name), qty)
      //     }

      //     tokensBuffer.set(cborStrToBuffer(policy), policyMapBuffer)
      //   }

      //   outputs[1][1] = [outputs[1][1], tokensBuffer]
      // }

      // payload.set(0, inputs)
      // payload.set(1, outputs)
      // payload.set(2, 100000n) // fake tx fee for calculating tx size

      // const signaturesMap = new Map(),
      //   fakeSignatures = []

      // tx = [payload, signaturesMap, true, null]

      // for (let i = 0; i < witnesses.size; i++) {
      //   fakeSignatures.push([new Uint8Array(32), new Uint8Array(64)])
      // }

      // signaturesMap.set(0, fakeSignatures)

      // const cborDraft = cborEncode(tx, { typeEncoders: { bigint: cborBigIntEncoder } })

      // const fee = BigInt(155381 + (cborDraft.byteLength - 1) * 44),
      //   changeAmount = amount - spendAdaAmount - fee

      // if (Array.isArray(outputs[1][1])) {
      //   outputs[1][1][0] = changeAmount
      // } else {
      //   outputs[1][1] = changeAmount
      // }
      // payload.set(2, fee)

      // signaturesMap.delete(0)

      // txFee.value = fee
    } else {
      // insufficient funds
    }
  } catch (e) {
    console.error(e)
  }
}

const mint = async () => {
  lockScreen.value = true
  try {
    const connectedWalletObject = connectedWallet.value!,
      walletApi = connectedWalletObject.api

    if (tx) {
      // const cbor = cborBufferToStr(cborEncode(tx, { typeEncoders: { bigint: cborBigIntEncoder } }))

      const signatures = cborDecode(cborStrToBuffer(await walletApi.signTx(tx, true)), { useMaps: true, tags })

      const witnesses = []

      for (const [, signaturesData] of signatures) {
        for (const signatureData of signaturesData) {
          witnesses.push(cborBufferToStr(cborEncode(signatureData, { typeEncoders: { bigint: cborBigIntEncoder } })))
        }
      }

      const body_obj = {
        tx: tx,
        witnesses: witnesses,
      }

      const fetchRes = await fetch('/api/rest/v0/send', {
        method: 'POST',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body_obj),
      })
      const data = await fetchRes.json()

      if (data.statusCode == 200) {
        state.totalSupply = BigInt(data.data.total_supply)
        state.totalValueLocked = BigInt(data.data.tvl)

        waitingTx.value = data.data.tx_hash
      }

      // for (const [key, signatureData] of signatures) {
      //   tx[1].set(key, signatureData)
      // }

      // const cborSigned = cborBufferToStr(cborEncode(tx, { typeEncoders: { bigint: cborBigIntEncoder } }))

      // console.log('cborSigned', cborSigned)

      // try {
      //   const txHash = await walletApi.submitTx(cborSigned)

      //   if (txHash && txHash.length == 64) {
      //     waitingTx.value = txHash
      //   }
      // } catch (e) {
      //   console.error(e)
      //   alert('An unexpected wallet error, please try again later.')
      // }
    }
  } catch (e) {
    console.error(e)
    // waitingTx.value = '045a0b46a385044cdcfdbbedbc9762a84a96cfe29ef73068bbd9d237e7c72d60'
    // setTimeout(() => {
    //   waitingTx.value = ''
    //   step.value = 4
    //   setTimeout(() => {
    //     DeactivateConfetti()
    //   }, 3000)
    // }, 20000)
  }
  lockScreen.value = false
}

const calculateTxFee = async () => {
  txFee.value = connectedWallet.value ? 0n : 166777n
  if (!txFee.value) {
    calculatingTx.value = true
    // await new Promise((r) => setTimeout(r, 3000))
    await createTx()
  }
  calculatingTx.value = false
}

const setTreasuryTax = (tax: number) => {
  treasuryTax.value = tax
  calculateTxFee()
  step.value = 3
}

const copyTxHash = async () => {
  try {
    await navigator.clipboard.writeText(waitingTx.value)
    txHashCopied.value = true
    setTimeout(() => {
      txHashCopied.value = false
    }, 1500)
  } catch (e) {
    //
  }
}

// const walletID = computed(() => connectedWallet.value?.id)

// watch(walletID, () => {
//   initStep()
// })

const adaAmount = computed(() => connectedWallet.value?.ada)

watch(adaAmount, async () => {
  console.log('MintTab adaAmount')
  if (step.value == 3) {
    if (waitingTx.value) {
      const walletApi = connectedWallet.value?.api
      if (walletApi) {
        try {
          const cborUtxos = await walletApi.getUtxos()

          for (const cborString of cborUtxos) {
            const utxoData = cborDecode(cborStrToBuffer(cborString), { useMaps: true, tags })

            if (cborBufferToStr(utxoData[0][0]) == waitingTx.value) {
              waitingTx.value = ''
              step.value = 4

              break
            }
          }
        } catch (e) {
          console.error(e)
        }
      } else {
        initStep()
      }
    } else {
      calculateTxFee()
    }
  }
})
</script>

<script setup lang="ts">
const input = ref<HTMLInputElement>()

const clearInputValue = () => {
  inputValue.value = ''
  input.value?.focus()
}

const confetti = () => {
  if (step.value == 4 && !confettiDone) {
    confettiDone = true
    startConfetti(4000)
  }
}

watch(step, () => {
  nextTick(confetti)
})

onMounted(() => {
  confetti()
})
</script>
