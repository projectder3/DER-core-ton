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
// 5) constructor: توزيع المبالغ الأساسية
constructor() {
  // خزينة + ICO tranche + Strategic Reserve
  let treasuryAmt = (15_000_000 + 50_000_000) * 10u128^9;
  balances.insert(TREASURY, treasuryAmt);
  balances.insert(STRAT_RES, 15_000_000 * 10u128^9);

  // رصيد المالك مع قفل 5 سنوات
  let ownerAmt = 10_100_000 * 10u128^9;
  balances.insert(OWNER, ownerAmt);
  locked.insert(OWNER, (ownerAmt, now() + 5 * 365 * 24 * 3600));

  // أيردروب: 5 مليون DER
  balances.insert(AIRDROP, 5_000_000 * 10u128^9);
}

// 6) دالة مساعدة لاقتطاع رسوم 1% (حد أقصى 1000 DER) وتحويلها للخزينة
fn _chargeFee(from: MsgAddress, amount: UInt128) -> UInt128 {
  let fee = min(amount / 100u128, 1000u128 * 10u128^9);
  let bal = balances.get(from).unwrap_or(0u128);
  require(bal >= fee, 100);    // رصيد غير كافٍ للرسوم
  balances.insert(from, bal - fee);
  let tbal = balances.get(TREASURY).unwrap_or(0u128);
  balances.insert(TREASURY, tbal + fee);
  fee
}

// 7) دوال التوكن الأساسية

// قراءة الرصيد
pub fn balance_of(owner: MsgAddress) -> UInt128 {
  balances.get(owner).unwrap_or(0u128)
}

// قراءة allowance
pub fn allowance(owner: MsgAddress, spender: MsgAddress) -> UInt128 {
  allowances.get((owner, spender)).unwrap_or(0u128)
}

// تفويض spender
pub fn approve(spender: MsgAddress, amount: UInt128) {
  allowances.insert((msg.sender(), spender), amount);
}

// تحويل DER (مع اقتطاع الرسوم)
pub fn transfer(to: MsgAddress, amount: UInt128) {
  let sender = msg.sender();
  let bal = balances.get(sender).unwrap_or(0u128);
  require(bal >= amount, 101); // رصيد غير كافٍ

  // اقتطاع الرسوم
  let fee = _chargeFee(sender, amount);
  let net = amount - fee;

  // إجراء التحويل
  balances.insert(sender, bal - amount);
  let rbal = balances.get(to).unwrap_or(0u128);
  balances.insert(to, rbal + net);
}

// تحويل باستخدام allowance (مع رسوم)
pub fn transfer_from(from: MsgAddress, to: MsgAddress, amount: UInt128) {
  let spender = msg.sender();
  let allowed = allowances.get((from, spender)).unwrap_or(0u128);
  require(allowed >= amount, 102);  // غير مصرح

  let fbal = balances.get(from).unwrap_or(0u128);
  require(fbal >= amount, 101);    // رصيد غير كافٍ

  // اقتطاع الرسوم من المرسل الأصلي
  let fee = _chargeFee(from, amount);
  let net = amount - fee;

  // تحديث الرصيد والallowance
  allowances.insert((from, spender), allowed - amount);
  balances.insert(from, fbal - amount);
  let rbal = balances.get(to).unwrap_or(0u128);
  balances.insert(to, rbal + net);
}
