// contracts/IslamicEconomicShield.tact

// 1) جلب ثوابت الغاز من الإعداد
const GAS_FEE: Ton             = compiler.constant("GAS_FEE");
const GAS_REFUND_THRESHOLD: Ton = compiler.constant("GAS_REFUND_THRESHOLD");

// 2) الميتاداتا (من tact.config.js)
metadata(
  compiler.config().metadata.name,
  compiler.config().metadata.symbol,
  compiler.config().metadata.decimals,
  100_100_000 * 10u128^9,              // totalSupply
  compiler.config().metadata.description,
  compiler.config().metadata.image
);

// 3) تعريف المتغيرات الأساسية
let mut balances:   Map<MsgAddress, UInt128>               = Map::empty();
let mut allowances: Map<(MsgAddress, MsgAddress), UInt128> = Map::empty();
let mut locked:     Map<MsgAddress, (UInt128, UInt32)>    = Map::empty();

// 4) عناوين ثابتة
const OWNER:      MsgAddress = '0:28b8a98a1cbe6b9acfc0dc9ff6e739c9e128bf7c87b046cadfbc28c10d06fb58';
const AIRDROP:    MsgAddress = '0:C949a9f187f370a45c781bf7420a89d1e4cc54acf3d72e7e526bfd4c9ebe0b06';
const ICO_WALLET: MsgAddress = '0:F224876bd49a630aa240dd078e53af8342c2efb5114c63642f8906fd34992253';
const STRAT_RES:  MsgAddress = '0:28bb65478e517f71102b1a487ad618c74e130a94c5ba2d7eb4648fac2cf2fe32';
const TREASURY:   MsgAddress = '0:A1906487e4130684c7fb397d9af7d36b1eba366091d2a7e499352e1b73327809';
