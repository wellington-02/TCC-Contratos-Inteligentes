// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.0;

library Arbitrum {

    /******************************************************************************************************************/
    /*** Token Addresses                                                                                            ***/
    /******************************************************************************************************************/

    address internal constant SUSDC = 0x940098b108fB7D0a7E374f6eDED7760787464609;
    address internal constant SUSDS = 0xdDb46999F8891663a8F2828d25298f70416d7610;
    address internal constant USDC  = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address internal constant USDS  = 0x6491c05A82219b8D1479057361ff1654749b876b;

    /******************************************************************************************************************/
    /*** Bridging Addresses                                                                                         ***/
    /******************************************************************************************************************/

    address internal constant CCTP_TOKEN_MESSENGER = 0x19330d10D9Cc8751218eaf51E8885D058642E08A;

    address internal constant SKY_GOV_RELAY = 0x10E6593CDda8c58a1d0f14C5164B376352a55f2F;
    address internal constant TOKEN_BRIDGE  = 0x13F7F24CA959359a4D710D32c715D4bce273C793;

    /******************************************************************************************************************/
    /*** PSM Addresses                                                                                              ***/
    /******************************************************************************************************************/

    address internal constant PSM3 = 0x2B05F8e1cACC6974fD79A673a341Fe1f58d27266;

    /******************************************************************************************************************/
    /*** Spark Liquidity Layer Addresses                                                                            ***/
    /******************************************************************************************************************/

    address internal constant ALM_CONTROLLER  = 0x98f567464e91e9B4831d3509024b7868f9F79ee1;
    address internal constant ALM_PROXY       = 0x92afd6F2385a90e44da3a8B60fe36f6cBe1D8709;
    address internal constant ALM_RATE_LIMITS = 0x19D08879851FB54C2dCc4bb32b5a1EA5E9Ad6838;

    address internal constant ALM_FREEZER  = 0x90D8c80C028B4C09C0d8dcAab9bbB057F0513431;
    address internal constant ALM_RELAYER  = 0x8a25A24EDE9482C4Fc0738F99611BE58F1c839AB;
    address internal constant ALM_RELAYER2 = 0x8Cc0Cb0cfB6B7e548cfd395B833c05C346534795;

    /******************************************************************************************************************/
    /*** Aave Addresses                                                                                             ***/
    /******************************************************************************************************************/

    address internal constant ATOKEN_USDC = 0x724dc807b04555b71ed48a6896b6F41593b8C637;

    /******************************************************************************************************************/
    /*** Fluid Addresses                                                                                            ***/
    /******************************************************************************************************************/

    address internal constant FLUID_SUSDS = 0x3459fcc94390C3372c0F7B4cD3F8795F0E5aFE96;

    /******************************************************************************************************************/
    /*** Governance Relay Addresses                                                                                 ***/
    /******************************************************************************************************************/

    address internal constant SPARK_EXECUTOR = 0x65d946e533748A998B1f0E430803e39A6388f7a1;
    address internal constant SPARK_RECEIVER = 0x212871A1C235892F86cAB30E937e18c94AEd8474;

    /******************************************************************************************************************/
    /*** SSR Oracle Addresses                                                                                       ***/
    /******************************************************************************************************************/

    address internal constant SSR_AUTH_ORACLE             = 0xEE2816c1E1eed14d444552654Ed3027abC033A36;
    address internal constant SSR_BALANCER_RATE_PROVIDER  = 0xc0737f29b964e6fC8025F16B30f2eA4C2e2d6f22;
    address internal constant SSR_CHAINLINK_RATE_PROVIDER = 0x84AB0c8C158A1cD0d215BE2746cCa668B79cc287;
    address internal constant SSR_RECEIVER                = 0x567214Dc57a2385Abc4a756f523ddF0275305Cbc;

    /******************************************************************************************************************/
    /*** DSR Oracle Addresses                                                                                       ***/
    /******************************************************************************************************************/

    address internal constant DSR_AUTH_ORACLE            = 0xE206AEbca7B28e3E8d6787df00B010D4a77c32F3;
    address internal constant DSR_RECEIVER               = 0xcA61540eC2AC74E6954FA558B4aF836d95eCb91b;
    address internal constant DSR_BALANCER_RATE_PROVIDER = 0x73750DbD85753074e452B2C27fB9e3B0E75Ff3B8;

    /******************************************************************************************************************/
    /*** Multisigs                                                                                                  ***/
    /******************************************************************************************************************/

    address internal constant SPARK_REWARDS_MULTISIG = 0xF649956f43825d4d7295a50EDdBe1EDC814A3a83;

}
