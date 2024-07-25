<template>
  <Transition enter-active-class="transition" leave-active-class="transition" enter-from-class="opacity-0" leave-to-class="opacity-0">
    <div v-if="modal" class="flex-center fixed left-0 top-0 z-10 h-full w-full bg-gray-dark/90 p-3 backdrop-blur-sm">
      <div class="absolute h-full w-full" @click="closeModal(false)"></div>
      <div
        class="md:shadow-yellow-md relative h-full max-h-130 w-full max-w-130 rounded-md bg-gray px-2.5 py-6 shadow-yellow transition sm:rounded-lg sm:px-4 md:max-h-140 md:max-w-140 md:rounded-xl md:p-8 lg:max-h-150 lg:max-w-150 lg:rounded-2xl lg:p-10">
        <button
          class="flex-center absolute right-0 top-0 h-10 w-10 text-beige opacity-70 transition hover:opacity-100 md:right-2 md:top-2"
          @click="closeModal(true)">
          <CloseIcon class="w-3.5 stroke-2" />
        </button>

        <WalletConnector v-if="modal == 'WalletConnector'" @update="onWalletUpdate" />
        <PrivacyPolicy v-else />
      </div>
      <div v-if="lockScreen" class="fixed left-0 top-0 h-full w-full"></div>
    </div>
  </Transition>
</template>

<script lang="ts">
import WalletConnector from '@/components/WalletConnector.vue'
import PrivacyPolicy from '@/components/PrivacyPolicy.vue'
import CloseIcon from '@/components/icons/CloseIcon.vue'
import { ref } from 'vue'

type Modal = 'WalletConnector' | 'PrivacyPolicy'

const modal = ref<Modal | false>(false),
  lockScreen = ref(false)

let focusTime = 0

const onWindowFocus = () => {
  focusTime = Date.now()
}

const openModal = (type: Modal) => {
  focusTime = Date.now()
  modal.value = type
  window.addEventListener('focus', onWindowFocus)
}

export { openModal }
</script>

<script setup lang="ts">
const closeModal = (force: boolean) => {
  if (force || Date.now() - focusTime > 500) {
    modal.value = false
    window.removeEventListener('focus', onWindowFocus)
  }
}

const onWalletUpdate = (status: string) => {
  if (status == 'connecting') {
    lockScreen.value = true
  } else {
    lockScreen.value = false
    if (status == 'connected') {
      closeModal(true)
    }
  }
}
</script>
