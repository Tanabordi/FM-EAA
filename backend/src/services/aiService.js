const { GoogleGenAI } = require('@google/genai');

const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

const PROMPT = `อ่านฉลากอาหารในรูปนี้ แล้วตอบเป็น JSON เท่านั้นตามรูปแบบนี้:
{
  "foodName": string|null,
  "expiryDate": "YYYY-MM-DD"|null,
  "category": "Proteins"|"Veggies"|"Beverages"|"Meals"|"Sauces",
  "storage": "Fridge"|"Freezer",
  "unit": "pieces"|"bag"|"punnet"|"bottle"|"box"|"can"|"pack"|"g"|"kg"
}
- foodName: คือชื่อสินค้าหรือชนิดวัตถุดิบ (ภาษาไทยหรืออังกฤษตามฉลาก)
- expiryDate: วันหมดอายุเท่านั้น (EXP, BBD, Best Before, ควรบริโภคก่อน, หมดอายุ) ห้ามใช้วันผลิต (MFD, MFG). แปลงเป็น ค.ศ. รูปแบบ YYYY-MM-DD ถ้าไม่พบให้ใส่ null อย่าเดา
- category: วิเคราะห์จากประเภทอาหาร
  * "Proteins": เนื้อสัตว์, หมู, ไก่, ปลา, กุ้ง, ไข่, ไส้กรอก, แฮม, เบคอน, เต้าหู้, ลูกชิ้น
  * "Veggies": ผักสด, ผลไม้สด, เห็ด
  * "Beverages": นม, น้ำดื่ม, น้ำผลไม้, ชา, กาแฟ, โซดา, เครื่องดื่ม
  * "Meals": อาหารปรุงสำเร็จ, ข้าวกล่อง, ข้าว, ก๋วยเตี๋ยว, แกง, ต้ม, ผัด, พาสต้า, พิซซ่า, แซนด์วิช, เบอร์เกอร์
  * "Sauces": ซอส, เครื่องปรุงรส, น้ำจิ้ม, ซีอิ๊ว, น้ำปลา, น้ำมัน, มายองเนส, แยม
- storage: ส่วนใหญ่แช่ตู้เย็นปกติ "Fridge" ยกเว้นสินค้าแช่แข็งหรือไอศกรีมให้เป็น "Freezer"
- unit: หน่วยที่เหมาะสมของบรรจุภัณฑ์ เช่น "pack" สำหรับไส้กรอก/เนื้อสัตว์, "bottle" สำหรับเครื่องดื่ม, "box" สำหรับอาหารกล่อง, "bag" สำหรับผักถุง, หรือ "pieces"`;

async function scanLabel(buffer, mimeType) {
  let model = (process.env.GEMINI_MODEL || 'gemini-3.5-flash-lite').replace(/^["']|["']$/g, '');
  if (model.includes('2.5') || model.includes('1.5')) {
    model = 'gemini-3.5-flash-lite';
  }

  const res = await ai.models.generateContent({
    model,
    contents: [
      { inlineData: { mimeType, data: buffer.toString('base64') } },
      { text: PROMPT },
    ],
    config: { responseMimeType: 'application/json', temperature: 0.1 },
  });

  const candidate = res.candidates?.[0];
  if (candidate?.finishReason && !['STOP', 'MAX_TOKENS'].includes(candidate.finishReason)) {
    throw new Error(`AI generation stopped due to: ${candidate.finishReason}`);
  }
  if (!res.text) {
    throw new Error('AI returned an empty response');
  }

  try {
    return JSON.parse(res.text);
  } catch (err) {
    throw new Error('Failed to parse AI response into valid JSON');
  }
}

module.exports = { scanLabel };
