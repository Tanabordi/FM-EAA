const { GoogleGenAI } = require('@google/genai');

const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

const PROMPT = `อ่านฉลากอาหารในรูปนี้ แล้วตอบเป็น JSON เท่านั้นตามรูปแบบนี้:
{"foodName": string|null, "expiryDate": "YYYY-MM-DD"|null}
- foodName คือชื่อสินค้าหรือชนิดวัตถุดิบ
- expiryDate คือวันหมดอายุ (EXP, BBD, ควรบริโภคก่อน) ถ้าเป็นปี พ.ศ. ให้แปลงเป็น ค.ศ.
- ถ้าอ่านไม่เจอให้ใส่ null อย่าเดา`;

async function scanLabel(buffer, mimeType) {
  const res = await ai.models.generateContent({
    model: process.env.GEMINI_MODEL,
    contents: [
      { inlineData: { mimeType, data: buffer.toString('base64') } },
      { text: PROMPT },
    ],
    config: { responseMimeType: 'application/json' },
  });
  return JSON.parse(res.text);
}

module.exports = { scanLabel };