<template>
  <div class="flex h-full flex-col">
    <div class="flex-center flex text-lg font-bold text-yellow md:text-xl">
      <button class="text-beige opacity-70 transition hover:opacity-100" @click="closeTos">
        <BackIcon class="w-6 stroke-1.4" />
      </button>
      <div class="mr-6 flex-1 text-center">Terms of Service</div>
    </div>
    <hr class="my-5 h-px border-none bg-gradient-to-r from-transparent from-10% via-yellow/70 via-50% to-transparent to-90%" />
    <div class="scrollbar -mx-2 flex-1 sm:-mx-3 md:-mx-4">
      <div class="mx-1 flex flex-col gap-4 text-sm sm:mx-2 md:mx-3">
        <strong class="text-base">Introduction</strong>
        <p>
          Please read these terms and conditions (hereby referred to as "Terms and Conditions") carefully before accessing, interacting with, or using the
          AdaHold protocol software, consisting of the AdaHold protocol technology stack (in particular its smart contracts) as well as any other AdaHold
          technology available (hereby referred to as "AdaHold Protocol"), and/or the website https://adahold.com/ including any accompanying documentation
          (hereby referred to as "Website"). By accessing, interacting with, or using the AdaHold Protocol and/or the Website, the user (hereby referred to as
          "User") agrees to all terms laid out in these Terms and Conditions.
        </p>
        <p>
          These Terms and Conditions relate to the use of the AdaHold Protocol and the Website that were created by AdaStat Team (hereby referred to as "Service
          Provider") as an Open Source service. The AdaHold Protocol is a decentralized peer-to-peer protocol that enables Users to mint and/or burn
          cryptographic tokens, and to potentially make use of further features in the future. The AdaHold Protocol consists of a set of smart contracts
          deployed to the Cardano blockchain. Any and all functionalities of the AdaHold Protocol are of a purely technical nature, and there is no claim
          towards any private individual or legal entity in this regard.
        </p>
        <p>
          The content of the Website is purely informational. In particular, none of the content of the Website shall be understood as any kind of financial or
          other advice provided by Service Provider or any other third party, nor does the Service Provider or any other third party warrant the actuality and
          accuracy of the information on the Website.
        </p>
        <br /><strong class="text-base">No Relationship to the Service Provider</strong>
        <p>
          The AdaHold Protocol runs in a decentralized and autonomous manner on the Cardano network. The Service Provider is neither directly involved nor in
          any way responsible for the operation, running, or functioning of the AdaHold Protocol and/or any of the interactions, collaborations, or factual
          relationships between Users and the smart contracts of the AdaHold Protocol. The Service Provider does not control and/or influence any corresponding
          transactions, deposits, and/or allocations made by the Users and the involved smart contracts using the AdaHold Protocol. In particular, the Service
          Provider has not and will not enter into any legal or factual relationship with any User of the AdaHold Protocol.
        </p>
        <br /><strong class="text-base">Exclusion of liability and warranty</strong>
        <p>
          The Service Provider is not liable to any User for damages, including any general, special, incidental, or consequential damages arising out of the
          use, in connection with the use or inability to use the AdaHold protocol software (including but not limited to loss of the HOLD token or any other
          token, allocation or non-allocation of fees, loss of data, business interruption, data being rendered inaccurate or other losses sustained by a User
          or third parties related to the AdaHold protocol and/or any activity of a possible third-party frontend operator or a failure of the AdaHold protocol
          to operate with any other software). The User agrees and understands that all trades and other actions you submitted through the AdaHold Protocol are
          unsolicited, which means that the User did not receive any investment advice neither from the Association in connection with any trades, and no
          suitability review or similar of any submitted trades is conducted.
        </p>
        <p>
          As the AdaHold Protocol is of experimental nature, it may contain bugs, defects, or errors (including any bug, defect, or error relating to or
          resulting from the display, manipulation, processing, storage, transmission, or use of data) that may materially and adversely affect the use,
          functionality, or performance of the AdaHold Protocol or any product or system containing or used in conjunction with the AdaHold Protocol.
        </p>
        <p>
          THE ADAHOLD PROTOCOL HAS BEEN PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
          MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.
        </p>
        <p>
          THE ADAHOLD PROTOCOL SOFTWARE IS EXPERIMENTAL AND ANY HOLD OR OTHER TOKEN SENT, STAKED, DEPOSITED OR SIMILAR TO THE ADAHOLD PROTOCOL IS AT RISK OF
          BEING LOST INDEFINITELY, WITHOUT ANY KIND OF CONSIDERATION.
        </p>
        <p>
          Further, as the AdaHold Protocol is built on the Cardano network, its proper functioning depends on the Cardano network, and any transaction incurs
          transaction fees.
        </p>
        <br /><strong class="text-base">Usage of the AdaHold Protocol / Restricted countries </strong>
        <p>
          Any usage of the front end made available through the Website lies in the User’s sole responsibility. The User understands and agrees that the front
          end is made available solely to simplify accessing the AdaHold Protocol but is not technically required to access the AdaHold Protocol. The Service
          Provider may, at some point in the future, make infrastructure available allowing third parties to build and operate a front end for the Protocol. In
          such a case, the Service Provider will not enter into any form of cooperation with third party front end providers. Any possible information about
          third party front-end providers on the Website is for purely informational purposes only, does not constitute any kind of endorsement, and the Service
          Provider does not make any statement regarding the technical functionality and/or trustworthiness of any mentioned third party front end provider. The
          use of any front end lies in the User’s sole responsibility and must be made carefully.
        </p>
        <p>
          Users located, incorporated, or otherwise established in, or a citizen of, the following jurisdictions are prohibited from using the AdaHold Protocol:
          BELARUS, THE CENTRAL AFRICAN REPUBLIC, THE DEMOCRATIC REPUBLIC OF CONGO, THE DEMOCRATIC PEOPLE’S REPUBLIC OF KOREA, THE CRIMEA REGION OF UKRAINE,
          CUBA, IRAN, LIBYA, SOMALIA, SUDAN, SOUTH SUDAN, SYRIA, THE USA, YEMEN, AND ZIMBABWE or any other jurisdiction in which accessing or using the AdaHold
          Protocol is prohibited (hereby referred to as "Prohibited Jurisdictions"). By accessing any part of the AdaHold Protocol, the User confirms that (1)
          they are not the subject of economic or trade sanctions administered or enforced by any governmental authority or otherwise designated on any list of
          prohibited or restricted parties; (2) they are not a citizen of, resident of, or organized in Prohibited Jurisdiction. Finally, the User represent
          that their access and use of the AdaHold Protocol will fully comply with all applicable laws and regulations, that the User is of legal age to enter
          into and accept these Terms and Conditions, and that the User will not access or use the AdaHold Protocol to conduct, promote, or otherwise facilitate
          any illegal activity, including but not limited to intellectual property infringement, cyberattacks, fraud and misrepresentation of any kind, market
          manipulation, securities and derivates violations or any other unlawful conduct.
        </p>
        <br /><strong class="text-base">Assumption of Risks of Cryptographic Token, Currencies, and Systems</strong>
        <p>
          There are general risks associated with purchasing, owning, and using a cryptographic token (hereby referred to as "Token"). In order to access and
          make use of certain features of the AdaHold Protocol, a User may need a Token, in particular the HOLD token (hereby referred to as "HOLD") or the
          Cardano native ADA token (hereby referred to as "ADA").
        </p>
        <p>
          Tokens such ADA can be highly volatile due to many factors, including but not limited to adoption, speculation, technology, and security risks. The
          cost of transacting on the Cardano network or related blockchain technologies is variable. It may increase at any time, causing impact on any
          activities taking place on the Cardano network.
        </p>
        <p>
          The User is solely responsible for transacting and holding Tokens while accessing and/or interacting with the AdaHold Protocol. Before using the
          AdaHold Protocol, the User should review the relevant documentation and ensure that he/she/it understands the functioning of the AdaHold Protocol.
        </p>
        <p>
          The User is responsible for implementing reasonable measures for securing the wallet, vault, or other storage mechanism used to receive and hold
          Tokens, including any requisite private key(s) or other credentials necessary to access such storage mechanism(s). If the User’s private key(s) or
          other access credentials are lost, the User may lose access to its Token. These Terms and Conditions are not intended to, and do not, create or impose
          any fiduciary duties on the Service Provider or any other third-party.
        </p>
        <br /><strong class="text-base">No Ownership rights or similar</strong>
        <p>
          HOLD does not represent or constitute any ownership rights or stake, shares or security or equivalent rights nor any rights to receive future revenues
          or shares or any other form of participation or governance rights in or relating to any private individual or legal entity. In particular, HOLD does
          not represent or confer any ownership right or stake, share, security, or equivalent rights, or any right to receive future revenue shares,
          intellectual property rights or any other form of participation in or relating to any private individual or legal entity.
        </p>
        <br /><strong class="text-base">Risk of Regulatory Actions and Compliance with Laws</strong>
        <p>
          The AdaHold Protocol could be impacted by one or more regulatory inquiries or regulatory actions, which could impede or limit the User’s ability to
          access or use the AdaHold Protocol. The User is solely responsible for complying with applicable law when interacting with the AdaHold Protocol or
          HOLD.
        </p>
        <br /><strong class="text-base">Dispute Resolution</strong>
        <p>
          Any dispute between a User and the Service Provider shall be submitted to the exclusive jurisdiction of the competent at the seat of the Service
          Provider, with the exclusion of any other jurisdiction or arbitration. These Terms and Conditions shall be governed by and construed and interpreted
          in accordance with the substantive laws of jurisdiction at the seat of the Service Provider, excluding the conflict of law rules. The United Nations
          Convention for the International Sales of Goods is excluded.
        </p>
        <br /><strong class="text-base">Changes</strong>
        <p>
          These Terms and Conditions may be modified from time to time and as indicated by the version and date at the top of these Terms and Conditions. All
          modifications will be effective when posted, and the continued access or use of the AdaHold Protocol and/or the Website will serve as confirmation of
          acceptance of those modifications. Any User not agreeing to any modifications to these Terms and Conditions must immediately stop accessing and using
          the AdaHold Protocol and/or the Website.
        </p>
        <p>These Terms and Conditions are effective as of 30.04.2024</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import BackIcon from '@/components/icons/BackIcon.vue'

const emit = defineEmits(['close'])

const closeTos = () => {
  emit('close')
}
</script>
