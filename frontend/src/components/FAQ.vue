<template>
  <div id="faq" class="mb-8 text-center text-lg font-bold text-yellow md:mb-10 md:text-xl xl:text-2xl">Frequently Asked Questions</div>

  <div
    :key="i"
    v-for="(row, i) of faq"
    class="mb-5 rounded-md bg-gray transition sm:rounded-lg md:rounded-xl lg:rounded-2xl"
    :class="{ 'shadow md:shadow-md': row.open }">
    <button class="flex w-full items-center justify-between p-3 font-bold text-beige sm:p-4 md:p-8 lg:p-10" @click="row.open = !row.open">
      {{ row.title }}
      <ChevronIcon class="w-4 transform fill-none stroke-current stroke-2 transition-transform" :class="row.open ? 'rotate-180' : '-rotate-90'" />
    </button>
    <Transition enter-active-class="transition-transform" enter-from-class="transform scale-0">
      <div v-if="row.open" class="p-3 pt-0 text-sm sm:p-4 sm:pt-0 md:p-8 md:pt-0 lg:p-10 lg:pt-0" v-html="row.text"></div>
    </Transition>
  </div>
</template>

<script setup lang="ts">
import ChevronIcon from '@/components/icons/ChevronIcon.vue'
import { reactive } from 'vue'

const faq = reactive([
  {
    title: 'What is the HOLD token?',
    text: `Hold is a decenralized token on the Cardano blockchain, that allows the ADA holders to get more profit. The Hold minting and burning process as well as Hold price are controlled by Plutus smart contract.`,
    open: false,
  },
  {
    title: 'How do HOLD holders make a profit?',
    text: `Those HOLD holders who wait long enough will sell HOLD tokens at a higher price than they bought. The holder who HOLD the longest will take the whole treasury accumulated by all the time.`,
    open: false,
  },
  {
    title: 'What does Hold price depend on?',
    text: `The Hold token price is controlled by Plutus smart contract. The HOLD price is constantly growing, and never decreases. There are 3 factors increasing the HOLD token price:
    <ul>
      <li>- 3% Treasury tax paid by HOLD holders when burning their HOLD</li>
      <li>- staking/voting rewards for locked ADA paid for HOLD minting</li>
      <li>- staking/voting rewards for Treasury</li>
    <ul>`,
    open: false,
  },
  {
    title: 'Are there any restrictions on HOLD minting/burning?',
    text: `There are not any restrictions on HOLD minting/burning. Everyone can mint/burn any amount of HOLD they want/have at any time.`,
    open: false,
  },
  {
    title: 'Why is the Treasury tax different?',
    text: `Choosing the 0% Treasury tax option HOLD holders pay no Treasury tax when burning their HOLD. This option does not give HOLD holders an opportunity to receive voting/staking rewards for ADA they paid for minting HOLD. This option can be particularly interesting for those who don't want to pay tax or prefer short time holding.<br>Choosing the 3% Treasury tax option HOLD holders pay 3% Treasury tax when burning their HOLD. This option gives HOLD holders an opportunity to receive voting/staking rewards for ADA they paid for minting HOLD just as if this ADA is in their wallets. Redelegation is also available, it will be done automatically. This option can be particularly interesting for SPO whose stake is used as a pool pledge. They can hold HOLD tokens instead ADA and not break pledge!`,
    open: false,
  },
  {
    title: 'Does AdaHold smart contract have open source code?',
    text: `Yes, AdaHold is fully Open Source.`,
    open: false,
  },
  {
    title: "I haven't found the answer to my question. Where can I ask it?",
    text: `You can ask us any question in our TG group <a href="https://t.me/AdaHoldOfficial" target="_blank">https://t.me/AdaHoldOfficial</a>`,
    open: false,
  },
])
</script>
