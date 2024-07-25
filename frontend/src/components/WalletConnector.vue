<template>
  <Transition enter-active-class="transition duration-700" enter-from-class="opacity-0" mode="out-in">
    <TOS v-if="tos" @close="tos = false" />
    <div v-else class="flex h-full flex-col">
      <div class="text-center text-lg font-bold text-yellow md:text-xl">Wallet Dashboard</div>
      <hr class="my-3 h-px border-none bg-gradient-to-r from-transparent from-10% via-yellow/70 via-50% to-transparent to-90% sm:my-4 md:my-5" />
      <div v-if="connectedWallet" class="mb-6 mt-1 flex items-center justify-between text-white">
        <div class="flex items-center p-4 font-medium lg:px-5">
          <img :src="connectedWallet.icon" :alt="connectedWallet.name" class="mr-3 h-6 w-6" />
          {{ connectedWallet.name }}
          <ConnectIcon class="ml-2 h-4 text-yellow" />
        </div>
        <button
          class="rounded border border-gray-dark bg-gray-dark p-4 text-sm transition hover:border-yellow md:rounded-md lg:rounded-lg lg:px-5"
          @click="disconnect">
          Disconnect
        </button>
      </div>
      <div v-else-if="!installedWalletsCount" class="mb-4 text-sm md:mb-6 lg:mb-8">
        Supported wallets were not found. Please install and activate any one that supports CIP-30
      </div>
      <div v-else class="relative mb-4 flex cursor-pointer text-sm md:mb-6 lg:mb-8" @click="(readTos = !readTos), (tosWarn = false)">
        <CheckMarkIcon
          class="mr-2 mt-0.5 h-4 w-4 rounded border border-beige stroke-2 transition-all"
          :class="[readTos ? 'text-yellow' : 'text-transparent', { 'shadow-red': tosWarn }]" />
        <div class="flex-1 select-none">
          I have read, understood, and agreed to the
          <a class="text-beige" @click.stop="tos = true">Terms of Service</a>
        </div>
        <svg
          v-if="tosWarn"
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 50 50"
          fill="none"
          stroke="currentcolor"
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-dasharray="300"
          stroke-dashoffset="300"
          class="drop-shadow-arrow absolute -left-1.5 bottom-full mb-1 w-12 stroke-3 text-red filter">
          <path d="M46 4C30 4 2 18 14 45" class="animate-arrow" />
          <path d="M14 46 4 38" class="animate-arrow" style="animation-delay: 0.2s" />
          <path d="M14 46 19 35" class="animate-arrow" style="animation-delay: 0.3s" />
        </svg>
      </div>
      <div class="scrollbar -mx-2 flex-1 sm:-mx-3 md:-mx-4">
        <div class="mx-1 flex flex-col gap-4 text-beige sm:mx-2 md:mx-3">
          <template :key="wallet.name" v-for="wallet in installedWallets">
            <button
              v-if="wallet.id != connectedWallet?.id"
              class="flex items-center justify-between rounded border border-gray-dark bg-gray-dark p-4 transition hover:border-yellow md:rounded-md lg:rounded-lg lg:px-5 [&_svg]:hover:text-yellow"
              @click="connect(wallet.id)">
              <div class="flex items-center font-medium">
                <img :src="wallet.icon" :alt="wallet.name" class="mr-3 h-6 w-6" />
                {{ wallet.name }}
              </div>
              <LoadingIcon v-if="connecting == wallet.id" class="ml-1 h-4 animate-spin text-yellow" />
              <div v-else class="flex-center text-sm">
                Connect
                <ConnectIcon class="ml-1 h-4" />
              </div>
            </button>
          </template>
          <a
            :href="wallet.url"
            target="_blank"
            :key="key"
            v-for="(wallet, key) in knownWallets"
            class="flex items-center justify-between rounded border border-gray-dark bg-gray-dark p-4 text-beige transition hover:border-yellow md:rounded-md lg:rounded-lg lg:px-5"
            :class="{ 'opacity-50 hover:opacity-100': installedWalletsCount }">
            <div class="flex items-center font-medium">
              <img :src="walletImage(key)" :alt="wallet.name" class="mr-3 h-6 w-6" />
              {{ wallet.name }}
            </div>
            <div class="flex text-sm">
              Install
              <LinkIcon class="ml-1 mt-px h-4" />
            </div>
          </a>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script lang="ts">
import { nextTick, ref } from 'vue'

import { cborStrToBuffer } from '@/utils'

import { decode as cborDecode } from 'cborg'
import { bigIntDecoder as cborBigIntDecoder } from 'cborg/taglib'
import type { TagDecoder } from 'cborg/interface'

type WalletApi = {
  getBalance: () => Promise<string>
  getNetworkId: () => Promise<number>
  getUtxos: (amount?: string) => Promise<string[]>
  getChangeAddress: () => Promise<string>
  getRewardAddresses: () => Promise<string[]>
  getCollateral: () => Promise<string[]>
  signTx: (cbor: string, partial: boolean) => Promise<string>
  submitTx: (cbor: string) => Promise<string>
}

const connectedWallet = ref<null | {
  id: string
  name: string
  icon: string
  ada: bigint | null
  hold: bigint
  tokens: Map<string, bigint>
  api: WalletApi
}>(null)

const walletImage = (key: any) => {
  return new URL(`/src/assets/images/wallets/${key}.png`, import.meta.url).href
}

let balanceInterval: number, balanceEndTime: number

const getBalance = async () => {
  console.log('getBalance start')
  if (Date.now() - 15000 < balanceEndTime) {
    return
  }

  const connectedWalletObject = connectedWallet.value,
    tags: TagDecoder[] = []

  if (connectedWalletObject) {
    tags[2] = cborBigIntDecoder

    try {
      const cborString = await connectedWalletObject.api.getBalance()

      const cborObj = cborDecode(cborStrToBuffer(cborString), { useMaps: true, tags })

      connectedWalletObject.hold = 0n
      connectedWalletObject.tokens = new Map()
      if (Array.isArray(cborObj)) {
        connectedWalletObject.ada = BigInt(cborObj[0])
        for (const [policy, tokens] of cborObj[1]) {
          const policyId = policy.reduce((s: string, n: number) => s + n.toString(16).padStart(2, '0'), '')
          if (policyId == 'c6a4349e2357e50a9d8b6637b04df97b5d494265e9943a3d68b6b2c0') {
            for (const [tName, tQty] of tokens) {
              const tokenQty = BigInt(tQty)
              connectedWalletObject.hold += tokenQty
              connectedWalletObject.tokens.set(
                tName.reduce((s: string, n: number) => s + n.toString(16).padStart(2, '0'), ''),
                tokenQty
              )
            }
          }
        }
      } else {
        connectedWalletObject.ada = BigInt(cborObj)
      }
    } catch (e: any) {
      if (e?.code == -4) {
        tryToConnect(connectedWalletObject.id)
          .then((r) => {
            if (r) {
              getBalance()
            }
          })
          .catch((err) => {
            console.error(err)
          })
        return
      } else {
        console.error(e)
      }
    }

    balanceEndTime = Date.now()
  }
  console.log('getBalance end')
}

const balancePollingStop = () => {
  clearInterval(balanceInterval)
  balanceEndTime = 0
}

const balancePollingStart = () => {
  balancePollingStop()
  balanceInterval = setInterval(getBalance, 15000) // we use setInterval instead setTimeout since it allows us to ignore all external (wallet extension) unhandled errors with no pain
  getBalance()
}

const tryToConnect = async (walletId: string, init?: boolean): Promise<boolean> => {
  try {
    const wallet: {
      name: string
      icon: string
      enable: () => Promise<WalletApi>
      isEnabled: () => Promise<boolean>
    } = (window as any).cardano[walletId]

    if (init) {
      const enabled = await wallet.isEnabled()
      if (!enabled) {
        return false
      }
    }

    connectedWallet.value = {
      id: walletId,
      name: wallet.name,
      icon: wallet.icon,
      ada: null,
      hold: 0n,
      tokens: new Map(),
      api: await wallet.enable(),
    }

    if (!('getCollateral' in connectedWallet.value.api)) {
      try {
        ;(connectedWallet.value.api as any).getCollateral = (connectedWallet.value.api as any).experimental.getCollateral
      } catch (e) {
        ;(connectedWallet.value.api as any).getCollateral = async () => {
          return []
        }
      }
    }

    return true
  } catch (e) {
    console.error(e)
    return false
  }
}

const storedWalletId = window.localStorage.getItem('wallet')

if (import.meta.hot) {
  import.meta.hot.accept()
  import.meta.hot.dispose(() => {
    balancePollingStop()
  })
}

if (storedWalletId) {
  tryToConnect(storedWalletId, true)
    .then((r) => {
      if (r) {
        balancePollingStart()
      }
    })
    .catch((e) => {
      console.error(e)
    })
}

export { connectedWallet }
</script>

<script setup lang="ts">
import ConnectIcon from '@/components/icons/ConnectIcon.vue'
import LinkIcon from '@/components/icons/LinkIcon.vue'
import LoadingIcon from '@/components/icons/LoadingIcon.vue'
import CheckMarkIcon from '@/components/icons/CheckMarkIcon.vue'
import TOS from '@/components/TOS.vue'

const emit = defineEmits<{
  (e: 'update', value: string): void
}>()

const readTos = ref(false),
  tos = ref(false),
  tosWarn = ref(false),
  connecting = ref<string | boolean>(false)

const knownWallets: {
  [key: string]: {
    name: string
    url: string
  }
} = {
  eternl: {
    name: 'Eternl',
    url: 'https://eternl.io/',
  },
  typhoncip30: {
    name: 'Typhon',
    url: 'https://typhonwallet.io/',
  },
  nami: {
    name: 'Nami',
    url: 'https://namiwallet.io/',
  },
  lace: {
    name: 'Lace',
    url: 'https://lace.io/',
  },
  yoroi: {
    name: 'Yoroi',
    url: 'https://yoroi-wallet.com/',
  },
  nufi: {
    name: 'Nufi',
    url: 'https://nu.fi/',
  },
  flint: {
    name: 'Flint',
    url: 'https://flint-wallet.com/',
  },
  vespr: {
    name: 'Vespr',
    url: 'https://vespr.xyz/',
  },
  gerowallet: {
    name: 'Gero',
    url: 'https://gerowallet.io/',
  },
  begin: {
    name: 'Begin',
    url: 'https://begin.is/',
  },
}
const installedWallets: {
  [name: string]: {
    id: string
    name: string
    icon: string
  }
} = {}

let installedWalletsCount = 0

const cardano = (window as any).cardano

if (cardano && typeof cardano == 'object') {
  for (const id of Object.keys(cardano)) {
    // check if object is wallet
    if (
      typeof cardano[id]?.enable == 'function' &&
      typeof cardano[id]?.isEnabled == 'function' &&
      cardano[id]?.name &&
      cardano[id]?.icon &&
      cardano[id]?.apiVersion
    ) {
      const knownWalletName = knownWallets[id]?.name
      if (knownWalletName || !installedWallets[cardano[id].name]) {
        delete knownWallets[id as keyof typeof knownWallets]

        // since some wallets provide more than 1 api object we group them by name instead id
        installedWallets[cardano[id].name] = {
          id,
          name: knownWalletName || cardano[id].name,
          icon: cardano[id].icon,
        }

        installedWalletsCount++
      }
    }
  }
}

const connect = async (walletId: string) => {
  tosWarn.value = false

  await nextTick()

  if (!readTos.value && !connectedWallet.value) {
    tosWarn.value = true
    return
  }

  connecting.value = walletId
  emit('update', 'connecting')

  const res = await tryToConnect(walletId)

  connecting.value = false

  if (res) {
    balancePollingStart()
    window.localStorage.setItem('wallet', walletId)
    emit('update', 'connected')
  } else {
    emit('update', 'error')
  }
}

const disconnect = () => {
  balancePollingStop()
  connectedWallet.value = null
  window.localStorage.removeItem('wallet')
  emit('update', 'disconnected')
}
</script>
