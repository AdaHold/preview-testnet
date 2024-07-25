<template>
  <header>
    <div
      class="scale-y-70 md:scale-y-80 pointer-events-none fixed -right-25 top-0 z-1 hidden w-full min-w-406 origin-top-right transform fill-yellow text-gray-dark/80 sm:flex md:-right-6 xl:right-0 xl:transform-none">
      <svg class="drop-shadow-header h-66 shrink-0 filter" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 264">
        <path
          d="m0 0h300v132h-48v-12h-12v24h-24v-12h12v-12h-12v12h-12v24h-12v-12h-12v12h-12v12h-12v-24h24v-12h-24v-24h-12v24h12v12h-12v24h-12v12h-12v-12h12v-12h-12v12h-12v24h-12v-36h12v-12h24v-12h-36v24h-12v-12h-24v12h12v12h12v36h-24v-12h12v-24h-12v-12h-12v-12h-12v-36h-12v12h-12v-12h-12v-24h12v12h12v-12h-12v-12h-12m0 60h24v12h-12v12h24v12h12v36h-12v-36h-12v12h-12v24h12v12h24v12h-12v12h-12v-24h-12v12h-12v-48h12v-24h-12m0 96h12v12h-12m60-156v24h12v-24m12-12v12h12v-12m12 12v12h12v-12m48-12v12h12v-12m12 12v12h12v-12m24-24v12h12v-12m24 24v12h12v-12" />
      </svg>
      <svg class="drop-shadow-header h-33 w-full shrink filter" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 818 132" preserveAspectRatio="none">
        <path d="m0 0h818v84c-251-7-596 0-818 48" />
      </svg>
      <svg class="drop-shadow-header h-33 shrink-0 filter" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 132">
        <path d="m0 0v84c165 5 294 19 387 48h413v-132" fill="url(#hg)" />
        <defs>
          <linearGradient id="hg" x1="270" y1="-112" x2="430" y2="120" gradientUnits="userSpaceOnUse">
            <stop stop-color="currentColor" class="text-yellow" />
            <stop stop-color="currentColor" class="text-gray-dark" offset="1" />
          </linearGradient>
        </defs>
      </svg>
    </div>
    <div class="left-0 top-0 z-1 w-full items-start justify-between p-3 pb-0 sm:fixed sm:flex sm:px-4 md:px-8 xl:px-10 xl:pt-5">
      <a href="/" class="fixed bottom-2 right-3 z-1 block sm:static">
        <img :src="logo" alt="AdaHold" class="h-9 md:h-11" />
      </a>
      <nav class="flex items-center justify-between text-sm font-bold text-black sm:gap-6 md:gap-10 md:text-base lg:gap-13 xl:gap-17">
        <a
          @click="scrollToTop()"
          class="after:content relative hidden cursor-pointer after:absolute after:bottom-0 after:left-1/2 after:h-0.5 after:w-0 after:bg-black after:transition-all hover:after:left-0 hover:after:w-full sm:block">
          Home
        </a>
        <a
          @click="scrollToFAQ()"
          class="after:content relative hidden cursor-pointer after:absolute after:bottom-0 after:left-1/2 after:h-0.5 after:w-0 after:bg-black after:transition-all hover:after:left-0 hover:after:w-full sm:block">
          FAQ
        </a>
        <NetworkSelector />
        <button
          v-if="connectedWallet"
          class="flex h-10 min-w-38 items-center justify-between rounded bg-gray/70 p-2 text-white transition hover:bg-gray md:h-13 md:min-w-50 md:rounded-lg md:px-5"
          @click="openModal('WalletConnector')">
          <img :src="connectedWallet.icon" :alt="connectedWallet.name" class="max-h-full max-w-6 md:max-w-9" />
          <LoadingIcon v-if="connectedWallet.ada === null" class="w-6 animate-spin" />
          <div v-else class="ml-2 flex flex-col items-end justify-between text-xs font-medium md:text-sm">
            <div class="flex items-start">
              <div>{{ fWalletAda.groupInteger }}</div>
              <div class="ml-0.5 w-4 font-normal">₳</div>
            </div>
            <div class="flex items-start">
              <div>{{ fWalletHold.groupInteger }}</div>
              <div class="ml-0.5 w-4 font-normal md:-mt-px">Ⓗ</div>
            </div>
          </div>
        </button>
        <button v-else class="h-10 w-38 rounded bg-yellow/70 transition hover:bg-yellow md:h-13 md:w-50 md:rounded-lg" @click="openModal('WalletConnector')">
          Connect Wallet
        </button>
      </nav>
    </div>
  </header>

  <div class="mx-3 mb-3 mt-6 sm:mx-4 sm:mb-16 sm:mt-28 md:mx-auto md:my-33 md:w-225 xl:my-40 xl:w-240">
    <RouterView />
  </div>

  <footer>
    <div
      class="sm:scale-70 md:scale-80 pointer-events-none fixed bottom-0 right-0 flex w-v2 origin-bottom-right transform items-end fill-yellow text-gray-dark/80 xl:transform-none">
      <div class="drop-shadow-footer h-13 flex-auto bg-gray-dark filter sm:h-16" aria-hidden="true"></div>
      <svg class="drop-shadow-footer h-33 shrink-0 filter sm:hidden" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 360 132">
        <path d="m0 80h65c8 0 21 2 32 6l8 2c153 25 215-16 255-88v132h-360" fill="url(#fgs)" />
        <path
          d="m25 132v-8h-8v-8h16v-16h8v-8h8v8h-8v16h-8v8h8v8h8v-8h16v-16h16v8h-8v8h-8v8h16v-16h8v8h8v8h8v-8h8v-16h8v16h-8v8h16v-8h8v-8h8v8h-8v8m-88-16v-8h8v8m16-16v-8h8v8m8 8v-16h16v-4l-8-2v30h8v-8m8-8v-8h8v8m8 8v-8h8v8m16 0v-8h8v8m151-32v-8h8v8m16-8v-8h8v8m0 16v-8h8v8m8-24h-8v-8h8v-16h-8v8h-8v-8h8v-8h8m-303 56v-4h8v4"
          class="fill-gray-dark" />
        <defs>
          <linearGradient id="fgs" x1="55" y1="152" x2="18" y2="112" gradientUnits="userSpaceOnUse">
            <stop stop-color="currentColor" class="text-yellow" />
            <stop stop-color="currentColor" class="text-gray-dark" offset="1" />
          </linearGradient>
        </defs>
      </svg>
      <svg class="drop-shadow-footer hidden h-60 shrink-0 filter sm:block" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 240">
        <path d="m0 176h241c134 23 414 34 590-68h33V96h24V72h24V48h12V36h12V24h12V0h12v240H0" fill="url(#fg)" />
        <path
          d="m888 84h12V72h12V60h24V36h12V24h12v24h-12v12h-12v12h12v24h-12v12h-12V72h-12v36h12v12h24V96h12v24h-12v12h-12v12h12v12h12v24h-12v12h12v12h-12v-12h-12v-12h12v-24h-12v12h-12v-36h-12v-12h-12v-12h-12v12h12v12h-12v12h-12v-24h-12v-12h24m-48 0h12v12h-12m12 12h12v12h-12m-24 0h12v12h-12m60 0h12v-12h12v24h-12v12h-12m-24-12h12v24h-12m-24-24h12v12h-12m48 12h12v12h-12m24-24h12v12h-12m0 24h12v12h-12m-84-24h12v12h-12"
          class="fill-gray-dark" />
        <defs>
          <linearGradient id="fg" x1="475" y1="225" x2="404" y2="90" gradientUnits="userSpaceOnUse">
            <stop stop-color="currentColor" class="text-yellow" />
            <stop stop-color="currentColor" class="text-gray-dark" offset="1" />
          </linearGradient>
        </defs>
      </svg>
    </div>
    <div class="bottom-0 mb-14 w-full md:fixed md:mb-3 xl:mb-4">
      <div class="mx-3 flex items-end justify-between text-sm sm:mx-4 sm:justify-start md:mx-auto md:w-225 xl:w-240">
        <div>
          <div>2024, brought by <a href="https://adastat.net/" target="_blank" class="text-beige">AdaStat</a> team</div>
          <div><a href="" @click.prevent="openModal('PrivacyPolicy')" class="text-beige">Privacy Policy</a></div>
        </div>
        <div class="bottom-0 -mb-2 flex items-end sm:ml-15">
          <a href="https://github.com/AdaHold/token-preview-testnet" target="_blank" class="-mb-1 p-2.5 sm:m-0 sm:mr-2">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="20" height="20">
              <path
                d="m10 0c-5.5 0-10 4.5-10 10 0 2.1.7 4.1 1.9 5.8 1.2 1.7 2.9 3 4.9 3.6.5.1.7-.2.7-.5 0-.2 0-1 0-1.8-2.5.5-3.2-.6-3.3-1.2-.2-.3-.7-1.1-1.1-1.4-.3-.2-.8-.6 0-.7.8 0 1.4.8 1.6 1.1.8 1.5 2.3 1 2.9.8.1-.6.3-1.1.6-1.3-2.2-.3-4.6-1.1-4.6-5 0-1 .4-1.9 1.1-2.6-.1-.3-.5-1.3.1-2.7 0 0 .8-.2 2.7 1 .8-.2 1.7-.3 2.5-.3.9 0 1.7.1 2.5.3 1.9-1.2 2.8-1 2.8-1 .5 1.4.2 2.4.1 2.7.6.7 1 1.5 1 2.6 0 3.9-2.3 4.7-4.6 5 .4.3.7.9.7 1.8 0 1.3 0 2.4 0 2.7 0 .3.2.6.7.5 2-.6 3.7-1.9 4.9-3.6 1.2-1.7 1.9-3.7 1.9-5.8 0-5.5-4.5-10-10-10"
                class="fill-beige" />
            </svg>
          </a>
          <a href="https://twitter.com/ada_stat" target="_blank" class="-mr-1 mb-5 p-2.5 sm:m-0 sm:mr-2">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="20" height="20">
              <path
                d="m3 1c-2 0-3 1-3 3v12c0 2 1 3 3 3h14c2 0 3-1 3-3v-12c0-2-1-3-3-3m-3 3.5h2.1l-4.6 4.6 5.4 6.3h-4.2l-3.4-3.8-3.8 3.8h-2.1l4.9-5-5.2-5.9h4.4l3 3.4m-3.7-2.4h-1.2l7.7 8.8h1.1"
                class="fill-beige" />
            </svg>
          </a>
          <a href="https://t.me/AdaHoldOfficial" target="_blank" class="-mr-3 mb-15 p-2.5 sm:m-0">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" width="20" height="20">
              <path
                d="m10 0c-5.5 0-10 4.5-10 10 0 5.5 4.5 10 10 10 5.5 0 10-4.5 10-10 0-5.5-4.5-10-10-10m4.6 6.9c-.1 1.6-.8 5.4-1.1 7.2-.1.7-.4 1-.7 1-.6.1-1-.4-1.6-.7-.8-.6-1.3-1-2.2-1.5-1-.7-.3-1 .2-1.6.2-.2 2.7-2.5 2.8-2.7 0 0 0-.1 0-.1 0 0 0 0-.1-.1 0 0-.1 0-.2 0-.1 0-1.5 1-4.2 2.8-.4.3-.7.4-1.1.4-.3 0-1-.2-1.5-.4-.6-.2-1.1-.3-1.1-.6 0-.2.3-.4.7-.6 3-1.3 4.9-2.1 5.9-2.5 2.8-1.1 3.3-1.3 3.7-1.3.1 0 .3 0 .4.1.1.1.1.2.1.2 0 .1 0 .3 0 .4"
                class="fill-beige" />
            </svg>
          </a>
        </div>
      </div>
    </div>
  </footer>

  <ModalWindow />
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { RouterView } from 'vue-router'

import { formatAdaHold } from '@/utils'

import logo from '@/assets/images/logo.svg'
import NetworkSelector from '@/components/NetworkSelector.vue'
import ModalWindow, { openModal } from '@/components/ModalWindow.vue'
import { connectedWallet } from '@/components/WalletConnector.vue'
import LoadingIcon from '@/components/icons/LoadingIcon.vue'

const fWalletAda = computed(() => formatAdaHold(connectedWallet.value?.ada || 0n)),
  fWalletHold = computed(() => formatAdaHold(connectedWallet.value?.hold || 0n))

const scrollToTop = () => {
  window.scroll({
    top: 0,
    behavior: 'smooth',
  })
}

const scrollToFAQ = () => {
  const y = document.getElementById('faq')?.getBoundingClientRect().top
  if (y) {
    window.scroll({
      top: y + window.scrollY - 100,
      behavior: 'smooth',
    })
  }
}
</script>
