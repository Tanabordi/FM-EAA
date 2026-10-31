const { GoogleGenAI } = require('@google/genai');

const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

const PROMPT = `อ่านฉลากอาหารในรูปนี้ แล้วตอบเป็น JSON เท่านั้นตามรูปแบบนี้:
{"foodName": string|null, "expiryDate": "YYYY-MM-DD"|null}
- foodName คือชื่อสินค้าหรือชนิดวัตถุดิบ
- expiryDate ใช้เฉพาะวันหมดอายุ (EXP, BBD, Best Before, ควรบริโภคก่อน, หมดอายุ) ห้ามใช้วันผลิต (MFD, MFG, ผลิต)
- วันที่บนฉลากไทยมักเป็น วัน/เดือน/ปี (DD/MM/YY หรือ DD/MM/YYYY)
- ปีสองหลัก 60-99 ให้ตีความเป็น พ.ศ. 25xx ปีสองหลัก 00-59 เป็น ค.ศ. 20xx
- ปีสี่หลักที่มากกว่า 2400 เป็น พ.ศ. ให้แปลงเป็น ค.ศ. ในคำตอบ
- ถ้าไม่พบวันหมดอายุหรืออ่านไม่ออก ให้ใส่ null อย่าเดา`;

async function scanLabel(buffer, mimeType) {
  const model = process.env.GEMINI_MODEL;
  if (!model) {
    throw new Error('GEMINI_MODEL is not configured');
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