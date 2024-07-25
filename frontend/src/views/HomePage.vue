<template>
  <div class="mb-6 flex flex-col justify-around gap-3 text-sm sm:mb-10 sm:flex-row md:mb-15 md:text-base lg:mb-20">
    <div class="flex items-center justify-between rounded-md border-gray sm:h-15 sm:w-52 sm:flex-col sm:justify-around sm:border-2">
      <b class="text-yellow">Total Supply</b>
      <i class="mx-1 mb-1 flex-1 self-stretch bg-gradient-to-r from-beige from-35% to-transparent to-0% bg-dotted bg-left-bottom bg-repeat-x sm:hidden"></i>
      <b>
        {{ fTotalSupply.groupInteger }}<span class="text-smaller font-normal text-beige">{{ fTotalSupply.decimal }}{{ fTotalSupply.fraction }}</span>
        tHOLD
      </b>
    </div>
    <div class="flex items-center justify-between rounded-md border-gray sm:h-15 sm:w-52 sm:flex-col sm:justify-around sm:border-2">
      <b class="text-yellow">HOLD Price</b>
      <i class="mx-1 mb-1 flex-1 self-stretch bg-gradient-to-r from-beige from-35% to-transparent to-0% bg-dotted bg-left-bottom bg-repeat-x sm:hidden"></i>
      <b>
        {{ fHoldPrice.groupInteger }}<span class="text-smaller font-normal text-beige">{{ fHoldPrice.decimal }}{{ fHoldPrice.fraction }}</span>
        tADA
      </b>
    </div>
    <div class="flex items-center justify-between rounded-md border-gray sm:h-15 sm:w-52 sm:flex-col sm:justify-around sm:border-2">
      <b class="text-yellow">Total Value Locked</b>
      <i class="mx-1 mb-1 flex-1 self-stretch bg-gradient-to-r from-beige from-35% to-transparent to-0% bg-dotted bg-left-bottom bg-repeat-x sm:hidden"></i>
      <b>
        {{ fTotalValueLocked.groupInteger
        }}<span class="text-smaller font-normal text-beige">{{ fTotalValueLocked.decimal }}{{ fTotalValueLocked.fraction }}</span>
        tADA
      </b>
    </div>
  </div>

  <div class="flex h-12 font-bold sm:text-lg md:h-15 md:text-xl xl:text-2xl">
    <button
      class="flex-center relative mr-5 flex-1 rounded-tl-md pl-5 sm:rounded-tl-lg md:mr-7 md:rounded-tl-xl lg:rounded-tl-2xl xl:rounded-tl-3xl"
      :class="currentTab == 'mint' ? 'bg-gray fill-gray text-yellow transition' : 'fill-transparent text-beige hover:text-yellow'"
      @click="currentTab = 'mint'">
      Mint HOLD
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 60 60" class="absolute left-full h-full">
        <path d="m43 50c4 7 10 10 17 10H0V0c7 0 13 3 17 10"></path>
      </svg>
    </button>
    <button
      class="flex-center relative ml-5 flex-1 rounded-tr-md pr-5 sm:rounded-tr-lg md:ml-7 md:rounded-tr-xl lg:rounded-tr-2xl xl:rounded-tr-3xl"
      :class="currentTab == 'burn' ? 'bg-gray fill-gray text-yellow transition' : 'fill-transparent text-beige hover:text-yellow'"
      @click="currentTab = 'burn'">
      Burn HOLD
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 60 60" class="absolute right-full h-full">
        <path d="m43 10C47 3 53 0 60 0V60H0c7 0 13-3 17-10"></path>
      </svg>
    </button>
  </div>
  <main
    class="mb-6 rounded-md bg-gray px-2 pb-8 pt-5 sm:mb-10 sm:rounded-lg sm:px-4 sm:pb-10 sm:pt-7 md:mb-15 md:rounded-xl md:px-8 md:pb-14 md:pt-11 lg:mb-20 lg:rounded-2xl lg:px-10 lg:pb-16 lg:pt-13 xl:rounded-3xl"
    :class="
      currentTab == 'mint'
        ? 'rounded-tl-none sm:rounded-tl-none md:rounded-tl-none lg:rounded-tl-none xl:rounded-tl-none'
        : 'rounded-tr-none sm:rounded-tr-none md:rounded-tr-none lg:rounded-tr-none xl:rounded-tr-none'
    ">
    <Transition enter-active-class="transition duration-700" enter-from-class="opacity-0" mode="out-in">
      <MintTab v-if="currentTab == 'mint'" />
      <BurnTab v-else />
    </Transition>
  </main>

  <FAQ />
</template>

<script lang="ts">
import state from '@/state'

const updateTreasuryInfo = async () => {
  const fetchRes = await fetch('/api/rest/v0/treasury', {
    method: 'GET',
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json',
    },
  })

  const data = await fetchRes.json()

  if (data.statusCode == 200) {
    state.totalSupply = BigInt(data.data.total_supply)
    state.totalValueLocked = BigInt(data.data.tvl)
  }
}

export default {
  async beforeRouteEnter() {
    await updateTreasuryInfo()
  },
}
</script>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { formatAdaHold } from '@/utils'
import FAQ from '@/components/FAQ.vue'
import MintTab from '@/components/MintTab.vue'
import BurnTab from '@/components/BurnTab.vue'

const currentTab = ref('mint'),
  holdPrice = computed(() => (state.totalValueLocked * 1_000_000n) / state.totalSupply),
  fTotalSupply = computed(() => formatAdaHold(state.totalSupply)),
  fTotalValueLocked = computed(() => formatAdaHold(state.totalValueLocked)),
  fHoldPrice = computed(() => formatAdaHold(holdPrice.value))

setInterval(updateTreasuryInfo, 60000)
</script>
