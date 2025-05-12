// contracts/token/DERtoken.tact

// 1) استيراد مكتبة الرسوم
import "../utils/FeeController.tact" as FeeCtrl;

// 2) جلب عنوان خزينة المشروع من الإعداد
const TREASURY: MsgAddress = compiler.config().treasuryAddress;

// 3) تعريف metadata باستخدام الإعداد
metadata(
  compiler.config().metadata.name,
  compiler.config().metadata.symbol,
  compiler.config().metadata.decimals,
  100_100_000 * 10u128^9,
  compiler.config().metadata.description,
  compiler.config().metadata.image
);

// 4) حالة العقد الأساسية
let mut balances:   Map<MsgAddress, UInt128>               = Map::empty();
let mut allowances: Map<(MsgAddress, MsgAddress), UInt128> = Map::empty();

// 5) constructor: توزيع أولي (خزينة فقط)
constructor() {
  // خزينة المشروع: 65,000,000 DER
  let initial = (15_000_000 + 50_000_000) * 10u128^9;
  balances.insert(TREASURY, initial);
}

// 6) دوال التوكن الأساسية

/// رصيد عنوان
pub fn balance_of(owner: MsgAddress) -> UInt128 {
  balances.get(owner).unwrap_or(0u128)
}

/// allowance بين owner و spender
pub fn allowance(owner: MsgAddress, spender: MsgAddress) -> UInt128 {
  allowances.get((owner, spender)).unwrap_or(0u128)
}

/// تفويض spender
pub fn approve(spender: MsgAddress, amount: UInt128) {
  allowances.insert((msg.sender(), spender), amount);
}

/// تحويل DER مع تطبيق رسوم 1%
pub fn transfer(to: MsgAddress, amount: UInt128) {
  let sender = msg.sender();
  let bal = balances.get(sender).unwrap_or(0u128);
  require(bal >= amount, 100); // رصيد غير كافٍ

  // حساب الرسوم
  let fee = FeeCtrl::chargeFee(sender, amount);
  let net = amount - fee;

  // تنفيذ التحويل
  balances.insert(sender, bal - amount);
  let rbal = balances.get(to).unwrap_or(0u128);
  balances.insert(to, rbal + net);

  // إضافة الرسوم للخزينة
  let tbal = balances.get(TREASURY).unwrap_or(0u128);
  balances.insert(TREASURY, tbal + fee);
}

/// transfer_from مع تطبيق رسوم
pub fn transfer_from(from: MsgAddress, to: MsgAddress, amount: UInt128) {
  let spender = msg.sender();
  let allowed = allowances.get((from, spender)).unwrap_or(0u128);
  require(allowed >= amount, 101);

  let fbal = balances.get(from).unwrap_or(0u128);
  require(fbal >= amount, 100);

  let fee = FeeCtrl::chargeFee(from, amount);
  let net = amount - fee;

  allowances.insert((from, spender), allowed - amount);
  balances.insert(from, fbal - amount);

  let rbal = balances.get(to).unwrap_or(0u128);
  balances.insert(to, rbal + net);

  let tbal = balances.get(TREASURY).unwrap_or(0u128);
  balances.insert(TREASURY, tbal + fee);
}
