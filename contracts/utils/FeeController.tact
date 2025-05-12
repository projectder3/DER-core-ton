// contracts/utils/FeeController.tact
// مكتبة FeeController: دالة ثابتة لاقتطاع 1% بحد أقصى 1000 DER

// تجلب عنوان التوكن الرئيسي من الإعداد
const TOKEN: MsgAddress = compiler.config().contractAddress;
const MAX_FEE:    UInt128 = 1000u128 * 10u128^9;  // 1000 DER
const FEE_RATE:  UInt128 = 1u128;                 // 1%

/// تقتطع 1% من `amount` (أقصى 1000 DER) من `from`، وتحولها لخزينة العقد الرئيسي
pub fn chargeFee(from: MsgAddress, amount: UInt128) -> UInt128 {
  let fee = min((amount * FEE_RATE) / 100u128, MAX_FEE);
  // استدعاء تحويل داخلي: TOKEN.transfer(TREASURY, fee)
  // ولكن لا يمكننا عمل call هنا، لذا نرجع القيمة ليطبقها العقد المستدعي
  fee
}
