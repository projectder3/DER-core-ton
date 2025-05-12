// tact.config.js
module.exports = {
  compilerOptions: {
    standard: 'TEP-74',
    contractName: 'IslamicEconomicShield',
    metadata: {
      name:        "Islamic Economic Shield",
      symbol:      "DER",
      decimals:    9,
      description: "DEFI HALAL ON TON",
      image:       "https://violet-negative-whale-504.mypinata.cloud/ipfs/bafybeidaqstetyks7sb2igwqstq6ad6zoghznbzcnta46t3ujmwxhhzxli"
    },
    treasuryAddress: '0:A1906487e4130684c7fb397d9af7d36b1eba366091d2a7e499352e1b73327809',
    constants: {
      GAS_FEE:             '0.15',  // TON ثابت رسوم الغاز
      GAS_REFUND_THRESHOLD:'0.05'
    }
  }
};
