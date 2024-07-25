<template>
  <div v-if="!connectedWallet" class="ml-1">
    <div class="max-w-80 pr-1 xl:max-w-88">
      <div class="mb-8 flex justify-center text-sm">To burn tHOLD please connect your wallet first</div>
      <div class="flex-center">
        <button
          @click="openModal('WalletConnector')"
          class="h-10 w-38 rounded bg-yellow/70 font-bold text-black transition hover:bg-yellow md:h-13 md:w-50 md:rounded-lg">
          Connect Wallet
        </button>
      </div>
    </div>
  </div>
  <div v-else-if="connectedWallet.hold > 0" class="ml-11">
    <template v-if="step == 1">
      <div class="-ml-11 mb-6 flex items-center font-medium">
        <ForwardIcon class="-ml-0.5 mr-0.5 w-5 stroke-2" />
        <div class="mr-2 w-4 text-right">1.</div>
        <div>Select HOLD tokens you have</div>
      </div>
      <div class="mb-6 flex flex-wrap gap-3">
        <div class="relative">
          <select v-model="token" class="h-9 w-50 rounded border border-yellow bg-gray pl-3 pr-9 text-sm text-beige outline-none" @change="step = 2">
            <option disabled :value="null">Not selected</option>
            <option :key="t.val" v-for="t in tokens" :value="t">{{ t.name }}: {{ t.groupInteger }}{{ t.decimal }}{{ t.fraction }} Ⓗ</option>
          </select>
        </div>
      </div>
    </template>
    <div v-else class="-ml-11 mb-9 flex flex-wrap items-center">
      <CheckMarkIcon class="w-5 stroke-2 text-green" />
      <div class="relative mr-2 w-4 text-right">1.</div>
      <div>{{ token!.name }} balance:</div>
      <div v-if="step < 4 && !waitingTx && connectedWallet.tokens.size != 1" @click="initStep()" class="cursor-pointer [&_svg]:hover:text-yellow">
        <b class="ml-5 border-b border-dashed border-beige"
          >{{ token!.groupInteger
          }}<span class="font-normal"
            ><span class="text-smaller text-beige">{{ token!.decimal }}{{ token!.fraction }}</span></span
          >
        </b>
        <span class="ml-1 text-lg leading-6">Ⓗ</span>
        <ChangeIcon class="-mt-0.5 ml-3 inline-block w-4 stroke-2 text-yellow/70" />
      </div>
      <div v-else>
        <b class="ml-5"
          >{{ token!.groupInteger
          }}<span class="font-normal"
            ><span class="text-smaller text-beige">{{ token!.decimal }}{{ token!.fraction }}</span></span
          >
        </b>
        <span class="ml-1 text-lg leading-6">Ⓗ</span>
      </div>
    </div>

    <div v-if="step < 2" class="-ml-6 mt-9 flex items-center opacity-40">
      <div class="mr-2 w-4 text-right">2.</div>
      <div>Enter HOLD amount to burn</div>
    </div>
    <template v-else-if="step == 2">
      <div class="-ml-11 mb-6 mt-9 flex items-center font-medium">
        <ForwardIcon class="-ml-0.5 mr-0.5 w-5 stroke-2" />
        <div class="mr-2 w-4 text-right">2.</div>
        <div>Enter HOLD amount to burn</div>
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
          <button v-else class="flex-center absolute right-0 top-0 h-9 w-9 text-xs text-beige/70 hover:text-beige" @click="setInputValue(token!.qty)">
            max
          </button>
        </div>
      </div>
      <Transition enter-active-class="transition duration-700" enter-from-class="opacity-0" mode="out-in">
        <div v-if="isInputValid">
          <div class="mb-6 text-xs">
            It will unlock
            <b
              >{{ fUnlockedAmount.groupInteger
              }}<span class="font-normal"
                ><span class="text-smaller text-beige">{{ fUnlockedAmount.decimal }}{{ fUnlockedAmount.fraction }}</span></span
              >
              ₳
            </b>
          </div>
          <button class="h-9 rounded bg-yellow/70 px-6 text-sm font-bold text-black hover:bg-yellow" @click="setInputValue()">Confirm</button>
        </div>
      </Transition>
    </template>
    <div v-else class="-ml-11 mb-9 flex flex-wrap items-center">
      <CheckMarkIcon class="w-5 stroke-2 text-green" />
      <div class="relative mr-2 w-4 text-right">2.</div>
      <div>Amount to burn:</div>
      <div v-if="step < 4 && !waitingTx" @click="(inputValue = ''), (step = 2)" class="cursor-pointer [&_svg]:hover:text-yellow">
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

    <div v-if="step < 3" class="-ml-6 mt-9 flex items-center opacity-40">
      <div class="mr-2 w-4 text-right">3.</div>
      <div>Make burning transaction</div>
    </div>
    <template v-else-if="waitingTx">
      <div class="-ml-11 mb-6 mt-9 flex items-center font-medium">
        <LoadingIcon class="w-5 animate-spin text-yellow" />
        <div class="mr-2 w-4 text-right">3.</div>
        <div>Burning transaction</div>
      </div>
      <div class="flex-center pr-11 text-sm">
        <div class="max-w-160">
          <p class="mb-6 text-center">Well, it's almost done! Your ADA is rushing to you!</p>
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
        <div>Burning transaction</div>
      </div>
      <div class="flex-center pr-11 text-sm">
        <div class="max-w-160">
          <p class="mb-6 text-center">Woohoo! Your ADA is in your wallet! What's next?</p>
          <p>
            Now you can <a class="cursor-pointer text-beige" @click="initStep()">refresh the page</a> in case you want to burn another batch of HOLDs, or simply
            close it. AdaHold hopes to see you again soon ;) Best of luck!
          </p>
        </div>
      </div>
    </template>
    <template v-else>
      <div class="-ml-11 mb-6 mt-9 flex items-center font-medium">
        <ForwardIcon class="-ml-0.5 mr-0.5 w-5 stroke-2" />
        <div class="mr-2 w-4 text-right">3.</div>
        <div>Make burning transaction</div>
      </div>
      <div class="flex-center max-w-80 pr-11 xl:max-w-88" v-if="calculatingTx">
        <LoadingIcon class="w-8 animate-spin" />
      </div>
      <div v-else-if="txFee > 0" class="max-w-80 pr-11 xl:max-w-88">
        <div class="mb-6 flex justify-between text-xs">
          <div>Unlocked amount:</div>
          <i class="mx-1 mb-1 flex-1 self-stretch bg-gradient-to-r from-beige from-35% to-transparent to-0% bg-dotted bg-left-bottom bg-repeat-x"></i>
          <b>
            {{ fUnlockedAmount.groupInteger
            }}<span class="text-smaller font-normal text-beige">{{ fUnlockedAmount.decimal }}{{ fUnlockedAmount.fraction }}</span>
            ₳
          </b>
        </div>
        <div class="mb-6 flex justify-between text-xs">
          <div>Treasury tax:</div>
          <i class="mx-1 mb-1 flex-1 self-stretch bg-gradient-to-r from-beige from-35% to-transparent to-0% bg-dotted bg-left-bottom bg-repeat-x"></i>
          <b class="relative">
            {{ fTreasuryTax.groupInteger }}<span class="text-smaller font-normal text-beige">{{ fTreasuryTax.decimal }}{{ fTreasuryTax.fraction }}</span> ₳
          </b>
        </div>
        <div class="mb-6 flex justify-between text-xs">
          <div>Transaction fee:</div>
          <i class="mx-1 mb-1 flex-1 self-stretch bg-gradient-to-r from-beige from-35% to-transparent to-0% bg-dotted bg-left-bottom bg-repeat-x"></i>
          <b class="relative">
            {{ fTxFee.groupInteger }}<span class="text-smaller font-normal text-beige">{{ fTxFee.decimal }}{{ fTxFee.fraction }}</span> ₳
          </b>
        </div>
        <div class="mb-8 text-right text-sm">
          <span class="mr-3">You get:</span>
          <b class="relative">
            {{ fTotalAmount.groupInteger }}<span class="text-smaller font-normal text-beige">{{ fTotalAmount.decimal }}{{ fTotalAmount.fraction }}</span> ₳
          </b>
        </div>
        <div class="flex-center text-sm font-bold text-black md:text-base">
          <button @click="burn" class="flex-center flex h-10 w-20 rounded bg-yellow/70 transition hover:bg-yellow md:h-13 md:w-32 md:rounded-lg">
            <LoadingIcon v-if="lockScreen" class="h-6 animate-spin" />
            <template v-else>Burn</template>
          </button>
        </div>
      </div>
      <div v-else class="-ml-10 max-w-88 pr-1 text-xs text-red xl:max-w-96">
        An error has occured during the transaction building. This can be caused by various reasons. We are going to show the error reason, but it has not been
        implemented yet. So, for now please try to connect another one wallet, change HOLD amount, or refresh page and try again.
      </div>
    </template>

    <div v-if="lockScreen" class="fixed left-0 top-0 z-10 h-full w-full"></div>
  </div>
  <div v-else class="flex max-w-88 justify-center px-1 text-sm xl:max-w-96">You do not have any tHOLD yet. Please mint some first</div>
</template>

<script lang="ts">
import { ref, computed, watch } from 'vue'
import state from '@/state'
import { connectedWallet } from '@/components/WalletConnector.vue'
import { openModal } from '@/components/ModalWindow.vue'
import CloseIcon from '@/components/icons/CloseIcon.vue'
import ForwardIcon from '@/components/icons/ForwardIcon.vue'
import CheckMarkIcon from '@/components/icons/CheckMarkIcon.vue'
import ChangeIcon from '@/components/icons/ChangeIcon.vue'
import LoadingIcon from '@/components/icons/LoadingIcon.vue'
import CopyIcon from '@/components/icons/CopyIcon.vue'
import { decode as cborDecode, encode as cborEncode } from 'cborg'
import { bigIntDecoder as cborBigIntDecoder, bigIntEncoder as cborBigIntEncoder } from 'cborg/taglib'
import type { TagDecoder } from 'cborg/interface'
import { formatAdaHold, cborStrToBuffer, cborBufferToStr } from '@/utils'

type Token = {
  name: string
  val: string
  qty: bigint
} & ReturnType<typeof formatAdaHold>

let tx: any

class Tag {
  tag
  value

  constructor(tag: any, value: any) {
    this.tag = tag
    this.value = value
  }
}

const mintingPolicy = 'c6a4349e2357e50a9d8b6637b04df97b5d494265e9943a3d68b6b2c0',
  treasuryTokenName = '001bc280' + mintingPolicy,
  step = ref(0),
  inputValue = ref(''),
  txFee = ref(0n),
  calculatingTx = ref(true),
  token = ref<null | Token>(null),
  tokens = computed(() => {
    const t: Token[] = []
    if (connectedWallet.value) {
      for (const [tName, tQty] of connectedWallet.value.tokens) {
        t.push({
          name: (tName == treasuryTokenName ? '0%' : '3%') + ' Tax',
          val: tName,
          qty: tQty,
          ...formatAdaHold(tQty),
        })
      }
    }
    return t
  }),
  waitingTx = ref(''),
  lockScreen = ref(false),
  txHashCopied = ref(false),
  tags: TagDecoder[] = new Proxy([], {
    get: function (target: any[], name: any) {
      return target[name] || ((value: any) => new Tag(name, value))
    },
  })

tags[2] = cborBigIntDecoder

const isInputValid = computed(() => inputValue.value && /^(\d+(?:[.,]\d{0,6})?)$/.test(inputValue.value))

const fInputValue = computed(() => formatAdaHold(holdAmount.value))

const fUnlockedAmount = computed(() => formatAdaHold(unlockedAmount.value))

const fTxFee = computed(() => formatAdaHold(txFee.value))

const fTreasuryTax = computed(() => formatAdaHold(treasuryTax.value))

const fTotalAmount = computed(() => formatAdaHold(unlockedAmount.value - txFee.value))

const holdAmount = computed(() => (isInputValid.value ? BigInt((inputValue.value.replace(token.value!.decimal, '.') as unknown as number) * 1_000_000) : 0n))

const unlockedAmountWithoutTax = computed(() => (isInputValid.value ? (holdAmount.value * state.totalValueLocked) / state.totalSupply : 0n))

const unlockedAmount = computed(() =>
  isInputValid.value
    ? token.value?.val == treasuryTokenName
      ? unlockedAmountWithoutTax.value
      : (holdAmount.value * state.totalValueLocked * 97n) / (state.totalSupply * 100n)
    : 0n
)

const treasuryTax = computed(() => unlockedAmountWithoutTax.value - unlockedAmount.value)

const initStep = () => {
  const connectedWalletObj = connectedWallet.value
  waitingTx.value = ''
  inputValue.value = ''

  if (connectedWalletObj && connectedWalletObj.tokens.size == 1) {
    let [[tName, tQty]] = connectedWalletObj.tokens
    token.value = {
      name: (tName == treasuryTokenName ? '0%' : '3%') + ' Tax',
      val: tName,
      qty: tQty,
      ...formatAdaHold(tQty),
    }
    step.value = 2
  } else {
    token.value = null
    step.value = 1
  }
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

const createTx = async () => {
  txFee.value = 0n
  calculatingTx.value = true

  try {
    const connectedWalletObject = connectedWallet.value!,
      walletApi = connectedWalletObject.api,
      cborUtxos = await walletApi.getUtxos(),
      tx_inputs: any[] = [],
      tokens: Map<string, Map<string, bigint>> = new Map(),
      changeAddress = await walletApi.getChangeAddress(),
      collateralCBORArr = await walletApi.getCollateral()

    let amount = 0n,
      collateralInput: any = [],
      collateralTokens: any = {},
      collateralAmount = 0n

    for (const cborString of [...cborUtxos, ...collateralCBORArr]) {
      const utxoData = cborDecode(cborStrToBuffer(cborString), { useMaps: true, tags })

      for (let i = 0; i < utxoData.length; i++) {
        // some wallets have Map instead Array
        if (utxoData[1] instanceof Map) {
          utxoData[1] = [utxoData[1].get(0), utxoData[1].get(1)]
        }
      }

      if (Array.isArray(utxoData[1][1])) {
        if (Array.isArray(utxoData[1][1])) {
          const utxoAmount = BigInt(utxoData[1][1][0])

          for (const [policyBuf, tokensData] of utxoData[1][1][1]) {
            const policy = cborBufferToStr(policyBuf)

            if (policy == mintingPolicy) {
              let findToken = false

              for (const [nameRaw] of tokensData) {
                if (cborBufferToStr(nameRaw) == token.value!.val) {
                  findToken = true
                  break
                }
              }

              if (findToken) {
                tx_inputs.push([cborBufferToStr(utxoData[0][0]), utxoData[0][1]])

                const policyMap = tokens.get(policy) || new Map<string, bigint>()

                if (!collateralInput.length && utxoAmount >= 8_000_000n) {
                  if (!collateralTokens[policy]) {
                    collateralTokens[policy] = {}
                  }
                }

                if (!policyMap.size) {
                  tokens.set(policy, policyMap)
                }

                amount += utxoAmount

                for (const [nameRaw, qty] of tokensData) {
                  const name = cborBufferToStr(nameRaw),
                    bigIntQty = BigInt(qty)

                  if (!collateralInput.length && utxoAmount >= 8_000_000n) {
                    collateralTokens[policy][name] = bigIntQty
                  }

                  policyMap.set(name, (policyMap.get(name) || 0n) + bigIntQty)
                }
              }
            }
          }

          if (!collateralInput.length && collateralTokens[mintingPolicy]) {
            collateralAmount = utxoAmount
            collateralInput = [cborBufferToStr(utxoData[0][0]), utxoData[0][1]]
          }
        }
      } else if (utxoData[1][1] >= 5_000_000) {
        collateralAmount = BigInt(utxoData[1][1])
        collateralInput = [cborBufferToStr(utxoData[0][0]), utxoData[0][1]]
        collateralTokens = {}
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
      hold_qty: -holdAmount.value,
      token_name: token.value!.val,
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
  } catch (e) {
    console.error(e)
  }

  calculatingTx.value = false
}

const setInputValue = (amount?: bigint) => {
  if (amount) {
    const amountStr = amount.toString().padStart(7, '0')
    inputValue.value = amountStr.slice(0, -6) + '.' + amountStr.slice(-6)
  }
  if (isInputValid.value) {
    step.value = 3
    createTx()
  }
}

const burn = async () => {
  lockScreen.value = true
  try {
    const connectedWalletObject = connectedWallet.value!,
      walletApi = connectedWalletObject.api

    if (tx) {
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
    }
  } catch (e) {
    console.error(e)
  }
  lockScreen.value = false
}

const walletID = computed(() => connectedWallet.value?.id)

const adaAmount = computed(() => connectedWallet.value?.ada)

watch(adaAmount, async () => {
  console.log('BurnTab adaAmount')
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
      createTx()
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

watch(walletID, () => {
  initStep()
})

if (step.value == 0) {
  initStep()
}
</script>
