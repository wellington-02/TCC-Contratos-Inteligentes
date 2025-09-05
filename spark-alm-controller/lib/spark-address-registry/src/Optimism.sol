// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.0;

library Optimism {

    /******************************************************************************************************************/
    /*** Token Addresses                                                                                            ***/
    /******************************************************************************************************************/

    address internal constant SUSDC = 0xCF9326e24EBfFBEF22ce1050007A43A3c0B6DB55;
    address internal constant SUSDS = 0xb5B2dc7fd34C249F4be7fB1fCea07950784229e0;
    address internal constant USDC  = 0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85;
    address internal constant USDS  = 0x4F13a96EC5C4Cf34e442b46Bbd98a0791F20edC3;

    /******************************************************************************************************************/
    /*** Bridging Addresses                                                                                         ***/
    /******************************************************************************************************************/

    address internal constant CCTP_TOKEN_MESSENGER = 0x2B4069517957735bE00ceE0fadAE88a26365528f;

    address internal constant SKY_GOV_RELAY = 0x10E6593CDda8c58a1d0f14C5164B376352a55f2F;
    address internal constant TOKEN_BRIDGE  = 0x8F41DBF6b8498561Ce1d73AF16CD9C0d8eE20ba6;

    /******************************************************************************************************************/
    /*** PSM Addresses                                                                                              ***/
    /******************************************************************************************************************/

    address internal constant PSM3 = 0xe0F9978b907853F354d79188A3dEfbD41978af62;

    /******************************************************************************************************************/
    /*** Spark Liquidity Layer Addresses                                                                            ***/
    /******************************************************************************************************************/

    address internal constant ALM_CONTROLLER  = 0x1d54A093b8FDdFcc6fBB411d9Af31D96e034B3D5;
    address internal constant ALM_PROXY       = 0x876664f0c9Ff24D1aa355Ce9f1680AE1A5bf36fB;
    address internal constant ALM_RATE_LIMITS = 0x6B34A6B84444dC3Fc692821D5d077a1e4927342d;

    address internal constant ALM_FREEZER  = 0x90D8c80C028B4C09C0d8dcAab9bbB057F0513431;
    address internal constant ALM_RELAYER  = 0x8a25A24EDE9482C4Fc0738F99611BE58F1c839AB;
    address internal constant ALM_RELAYER2 = 0x8Cc0Cb0cfB6B7e548cfd395B833c05C346534795;

    /******************************************************************************************************************/
    /*** Governance Relay Addresses                                                                                 ***/
    /******************************************************************************************************************/

    address internal constant SPARK_EXECUTOR = 0x205216D89a00FeB2a73273ceecD297BAf89d576d;
    address internal constant SPARK_RECEIVER = 0x61Baf0Ce69D23C8318c786e161D1cAc285AA4EA3;

    /******************************************************************************************************************/
    /*** SSR Oracle Addresses                                                                                       ***/
    /******************************************************************************************************************/

    address internal constant SSR_AUTH_ORACLE             = 0x6E53585449142A5E6D5fC918AE6BEa341dC81C68;
    address internal constant SSR_BALANCER_RATE_PROVIDER  = 0xe1e4953C93Da52b95eDD0ffd910565D3369aCd6b;
    address internal constant SSR_CHAINLINK_RATE_PROVIDER = 0x8e3b08e65cC59d293932F5e9aF3186970087a529;
    address internal constant SSR_RECEIVER                = 0xE2868095814c2714039b3A9eBEE035B9E2c411E5;

    /******************************************************************************************************************/
    /*** DSR Oracle Addresses                                                                                       ***/
    /******************************************************************************************************************/

    address internal constant DSR_AUTH_ORACLE            = 0x33a3aB524A43E69f30bFd9Ae97d1Ec679FF00B64;
    address internal constant DSR_RECEIVER               = 0xE206AEbca7B28e3E8d6787df00B010D4a77c32F3;
    address internal constant DSR_BALANCER_RATE_PROVIDER = 0x15ACEE5F73b36762Ab1a6b7C98787b8148447898;

    /******************************************************************************************************************/
    /*** Multisigs                                                                                                  ***/
    /******************************************************************************************************************/

    address internal constant SPARK_REWARDS_MULTISIG = 0xF649956f43825d4d7295a50EDdBe1EDC814A3a83;

    /******************************************************************************************************************/
    /*** Rewards Addresses                                                                                          ***/
    /******************************************************************************************************************/

    address internal constant SPARK_REWARDS = 0xf94473Bf6EF648638A7b1eEef354fE440721ef41;

}
