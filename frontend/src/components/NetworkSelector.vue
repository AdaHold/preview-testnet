<template>
  <div
    class="relative cursor-pointer text-yellow/70"
    v-on="networkSelectorOpen ? { mouseleave: () => closeNetworkSelector() } : { mouseenter: () => openNetworkSelector(), click: () => openNetworkSelector() }">
    <div
      class="flex h-10 items-center gap-2 rounded border border-yellow px-6 md:h-13 md:rounded-lg md:px-10"
      :class="{
        'rounded-b-none border-b-gray bg-gray md:rounded-b-none': networkSelectorOpen,
      }"
      v-on="isHoverable ? { click: () => closeNetworkSelector() } : {}">
      Preview
      <ChevronIcon class="w-3.5 stroke-2 transition-transform" :class="{ 'rotate-180 transform': networkSelectorOpen }" />
    </div>
    <Transition enter-active-class="transition" enter-from-class="opacity-0">
      <div
        v-if="networkSelectorOpen"
        class="absolute -mt-px w-full rounded-b border border-t-0 border-yellow bg-gray md:rounded-b-lg"
        @click="closeNetworkSelector(true)">
        <hr class="h-px border-none bg-gradient-to-r from-transparent from-10% via-yellow/70 via-50% to-transparent to-90%" />
        <div class="flex h-10 items-center px-6 transition hover:bg-gray-dark/50 hover:text-yellow md:h-13 md:px-10">Preprod</div>
        <hr class="h-px border-none bg-gradient-to-r from-transparent from-10% via-yellow/70 via-50% to-transparent to-90%" />
        <div
          class="flex h-10 items-center rounded rounded-t-none px-6 transition hover:bg-gray-dark/50 hover:text-yellow md:h-13 md:rounded-lg md:rounded-t-none md:px-10">
          Mainnet
        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup lang="ts">
import ChevronIcon from '@/components/icons/ChevronIcon.vue'
import { ref } from 'vue'

const isHoverable = ref(false),
  networkSelectorOpen = ref(false)

const openNetworkSelector = () => {
  networkSelectorOpen.value = true
  if (!window.matchMedia('(hover: hover) and (pointer: fine)').matches) {
    setTimeout(() => {
      if (networkSelectorOpen.value) {
        isHoverable.value = true
      }
    }, 500)
  }
}

const closeNetworkSelector = (select?: boolean) => {
  networkSelectorOpen.value = false
  isHoverable.value = false
  if (select) {
    setTimeout(() => {
      window.alert('At the moment, only the Preview testnet is available. Follow us on our social media and stay up to date with our latest news')
    }, 100)
  }
}
</script>
