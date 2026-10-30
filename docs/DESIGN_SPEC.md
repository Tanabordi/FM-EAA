# DESIGN SPEC (สรุปจาก Figma FM-EAA)

> หมายเหตุเรื่องขนาด: ตัวเลขขนาดในเอกสารนี้ (เฟรมมือถือ 412x892, ไดอะล็อก 328x184 ฯลฯ) เป็นแค่ขนาด artboard ใน Figma ใช้ดูสัดส่วนและระยะห่างเท่านั้น
> แอปจริงต้อง responsive ตามขนาดหน้าจอของมือถือแต่ละเครื่อง ห้ามล็อกความกว้าง/ความสูงตายตัว

เอกสารนี้สรุปดีไซน์จาก Figma เพื่อให้ทีมพัฒนานำไปใช้อ้างอิงในการออกแบบและพัฒนาได้โดยตรง
Figma: https://www.figma.com/design/MB6XUkZz1GZqJpDqvfkHYc/FM-EAA?node-id=0-1&t=dJwjYD0ae67KEzdu-1
ถ้า README หรือเอกสารอื่นขัดกับไฟล์นี้ ให้ยึดไฟล์นี้

## Design tokens (Material 3 ธีมเขียว)
- Primary #2E6A44 (ปุ่มหลัก, FAB, แท็บที่เลือก) / On Primary #FFFFFF
- Surface (พื้นหลังหน้า) #F6FBF3 / Surface Container (การ์ด, ช่องค้นหา) #EAEFE8
- On Surface #181D18 / On Surface Variant #414942 / Outline #717971
- สถานะความสด: Fresh #34C759 (เขียว, ไอคอนดาว), Use soon #FF8D28 (ส้ม, ไอคอนนาฬิกา), Expired #FF383C (แดง, ไอคอนเตือน)
- ปุ่มอันตราย (Delete, Log out, Clear All, Decline) เป็นสีแดงเข้ม ประมาณ #B91C1C
- ฟอนต์น่าจะเป็น Roboto, ปุ่มหลักทรงแคปซูลเต็มความกว้าง, ปุ่มย้อนกลับกรอบมน, FAB เขียวมุมขวาล่าง, ช่องค้นหาทรง pill มีเงา, bottom sheet มุมบนมน
- แอปมีสลับภาษา TH/EN และธีม Light/Dark (อยู่ในหน้า Settings)

## หลักการ layout (responsive)
- ใช้ layout ที่ยืดหยุ่นตามหน้าจอ: Flutter `Column`/`Row`/`Expanded`/`Flexible`, `SafeArea`, `LayoutBuilder`/`MediaQuery` เมื่อจำเป็น, เนื้อหายาวให้เลื่อนได้ (`ListView`/`SingleChildScrollView`)
- ห้ามกำหนดความกว้าง/ความสูงหน้าจอเป็นตัวเลขตายตัว (เช่น 412 หรือ 892); ปุ่มหลัก ช่องกรอก การ์ด ใช้ความกว้างเต็มพื้นที่ลบ padding ด้านข้าง
- ค่าที่ใช้คงที่ได้: padding/ระยะห่างมาตรฐาน (ประมาณ 16-24 dp), ความโค้งมุม, ขนาดไอคอน
- การ์ดตู้เย็นในหน้า My Fridges เป็น grid 2 คอลัมน์ ให้ความกว้างแต่ละการ์ดคำนวณตามหน้าจอ
- รองรับการปรับขนาดตัวอักษรของระบบและข้อความภาษาไทยที่ยาวกว่าอังกฤษ (ห้ามตัดข้อความโดยไม่จำเป็น)

## หน้าจอทั้งหมด (ลำดับ. ชื่อหน้า | Figma node | เนื้อหา)

### Auth / Onboarding
1. Onboarding & Permission | 11:26 | รูปตู้เย็น, หัวข้อ "Reduce Food Waste", "Get smart alerts before your groceries expire.", ปุ่ม "Enable Notifications" (ขอสิทธิ์แจ้งเตือน), ลิงก์ "Skip"
2. Sign In | 8:39 | โลโก้แอป, "Welcome To Fridge Management & Expiry Alert App", ช่อง Username or Email, Password (ซ่อน/แสดงได้), ลิงก์ Forgot password?, ปุ่ม Sign In, "Or", ปุ่ม Sign in with Google, "Don't have an account? Sign up"
3. Create an Account | 52:113, 362:18 | ช่อง Username, Email, Password (คำแนะนำ "Use at least 8 characters."), Confirm Password, ปุ่ม Sign Up, ปุ่ม Sign up with Google, "Already have an account? Sign In" (เฟรมที่สองคือ state เช่น error/validation)
4. Reset Password | 64:3 | "Enter your email", ช่อง Email, ปุ่ม "Send Link"

### ตู้เย็น (ผู้ใช้มีได้หลายตู้)
5. My Fridges | 223:69 (ว่าง), 88:62 (dashboard) | หัวข้อ "My Fridges", ไอคอนแจ้งเตือน + ตั้งค่า, "A fresh look at what's inside.", แบนเนอร์สรุป ("A little check, a lot less waste: N items need your attention today"), "Your fridges" + จำนวนตู้, การ์ดตู้ 2 คอลัมน์: ไอคอนตู้, เมนู ⋮, ชื่อตู้ (เช่น Studio / Kitchen), คำอธิบาย (เช่น 2nd floor / 1st floor), จำนวนของ (Empty / 35 Items), ป้าย Personal หรือ "N members", FAB เพิ่มตู้
6. Add New Fridge | 88:225 | ช่อง Fridge Name, Description, ปุ่ม Create Fridge
7. Edit Fridge (bottom sheet) | 120:30 | "Edit Fridge", ช่อง Fridge Name, Description (optional), ปุ่ม Save, ปุ่ม Delete Fridge (แดง)
8. Delete fridge alert (dialog) | 124:30 | ยืนยันลบตู้

### ภายในตู้เย็น (หน้า "Kitchen" = ชื่อตู้)
9. Fridge Detail | 11:178 (Fridge), 275:17 (Freezer) | แถบหัว: ย้อนกลับ, ชื่อตู้, ไอคอน 4 ตัว = Family, History, Notifications, Settings; ช่องค้นหา "Search for items"; chips หมวดแบบวงกลม All / Proteins / Veggies / Beverages / Meals / Sauces; แท็บ Fridge | Freezer; หัวข้อ "Your food" + "N items"; การ์ดวัตถุดิบ: รูป, ชื่อ, ปริมาณ+หน่วย (เช่น "1 bag · 150 g", "2 pieces"), ป้ายสถานะ + ข้อความ (Yesterday / 2 days left / 5 days left); FAB เพิ่มของ. เฟรมของแต่ละหมวด x โซนอีก 10 เฟรม (Protein 201:93/193:330, Veggies 199:76/193:245, Beverages 195:56/193:77, Meals 210:131/204:418, Sauces 193:161/197:160) เป็นแค่ state กรองของหน้านี้ ไม่ใช่หน้าใหม่
10. Search | 376:543, 383:77, 415:2102 และอีกหลายเฟรมชื่อ Search | ช่องค้นหา (มีปุ่มล้าง ✕), "Results for "<คำค้น>"", การ์ดผลลัพธ์ (เช่น "Avocados (Veggies)", จำนวน, ป้ายสถานะ, จำนวนวันที่เหลือ). เฟรมซ้ำเป็นแค่ state (ค้นจากแท็บ Fridge / Freezer, ไม่พบ ฯลฯ)

### วัตถุดิบ
11. Add Items | 20:52 | การ์ด "Scan Label with AI" (ไอคอนกล้อง "Capture the label. We'll fill in the details."), ปุ่มวิเคราะห์ด้วย Gemini ("ให้ Gemini AI Vision Engine วิเคราะห์"), ฟอร์ม: Food Name, Category (dropdown), Quantity + Unit (dropdown), Storage Location (Fridge/Freezer), Expiration Date (date picker, "Use-by or best-before date"), ปุ่ม Save
12. Item details | 230:68, 230:110 | ปุ่มแก้ไข (ไอคอนดินสอ) มุมขวาบน, รูปใหญ่, ชื่อ, "1 punnet · 250 g", ป้ายสถานะ ("Use soon in 2 Days"), tags (หมวด เช่น Veggies, โซน เช่น Fridge), ปุ่ม "Mark as Consumed", ปุ่ม "Delete Item" (แดง)
13. Edit Item details | 376:1134, 376:1348 | รูป + ปุ่มกล้องเปลี่ยนรูป, ชื่อ, Category, จำนวน + หน่วย, Storage (Fridge/Freezer), Expiration date, ปุ่ม Save
14. Mark as Consumed (bottom sheet) | 407:30, 376:1616 | "How much did you consume?", "<ชื่อ> · N pieces in fridge", ตัวนับ − / + (ค่าเริ่ม 1 "of N pieces"), ปุ่ม Confirm, ปุ่ม "Finished all"
15. Finish All (state หลังกินหมด) | 401:154, 409:255, 409:401 | กลับหน้ารายการ ของชิ้นนั้นหายไป มี snackbar "<ชื่อ> marked as consumed" + ปุ่ม Undo
16. Delete Item alert (dialog หลายเฟรม) | 376:1737 ฯลฯ | ยืนยันลบของ (และใช้ pattern เดียวกันกับการลบรายการประวัติ)

### ประวัติ
17. History | 394:294 (Consumed), 394:369 (Expired) | แท็บ Consumed | Expired; ข้อความ "Consumed is auto-deleted after 30 days", ปุ่ม "Clear All" (แดง + ถังขยะ); จัดกลุ่มตามวัน ("Today · 29 Oct", "Yesterday · 28 Oct"); แถว: รูป, ชื่อ, "-1 bottle (1 left) • by @alex.lee • 29 Oct • 08:30 AM", ป้าย Consumed, ปุ่มลบรายการ. แท็บ Expired มีโครงเดียวกัน (ไม่ได้ตรวจเนื้อหาละเอียด)

### ครอบครัว
18. Family Share | 11:49 | การ์ดชื่อตู้ ("Kitchen fridge"), "Family members" + "N Member", แถวสมาชิก: รูปโปรไฟล์, ชื่อ ("Mimi (ME)"), role Owner/Member, ปุ่มลบสมาชิก (เฉพาะที่ไม่ใช่ owner), ข้อความอธิบาย, ปุ่ม "Invite Member"
19. Invite to Family | 170:5, 174:6, 172:81 | ช่องค้นหา "Search Username" ผลลัพธ์ผู้ใช้ตามชื่อ (3 เฟรม = state: ว่าง, พิมพ์คำค้น, ผลลัพธ์/เชิญแล้ว)
20. Remove Member alert (dialog) | 172:142 | ยืนยันลบสมาชิก

### ตั้งค่า / การแจ้งเตือน
21. Notifications | 141:22 | การ์ดคำเชิญ ("John invited you to join 'Home Fridge'" + ปุ่ม Accept เขียว / Decline แดง), การ์ดแจ้งเตือนวันหมดอายุ (ไอคอนนาฬิกา "Milk expires tomorrow")
22. Settings | 134:187 | หัวข้อ Profile: การ์ดโปรไฟล์ (ตัวอักษรย่อ "AL", ชื่อ, อีเมล, ปุ่มแก้ไข); หัวข้อ Preferences: Language (TH | EN), Theme (Light | Dark); ปุ่ม "Log out" (แดง)
23. Edit Profile | 138:183 | อวตาร + ปุ่มกล้อง, ช่อง Name, Email, หัวข้อ "Change password" ("Leave blank to keep your current password."), Current Password, New Password, ปุ่ม Save Changes
24. Log Out alert (dialog) | 133:438 | ยืนยันออกจากระบบ

## พฤติกรรมสำคัญที่อนุมานจากดีไซน์
- ผู้ใช้มีได้หลายตู้ แต่ละตู้มี name + description; "Personal" = มีสมาชิกคนเดียว, ตู้ที่แชร์แสดง "N members"; role มี Owner / Member
- การกินของนับเป็น "จำนวน" (consume ทีละเท่าไรก็ได้ หรือ Finished all) แล้วบันทึกลง History พร้อมผู้ทำ (@username) และเวลา; มี Undo; History ฝั่ง Consumed ลบอัตโนมัติหลัง 30 วัน
- คำเชิญเข้าตู้ส่งผ่านการแจ้งเตือนในแอป (Accept/Decline) ค้นหาผู้ใช้ด้วย username
- สถานะความสด 3 ระดับ คำนวณจากวันหมดอายุ (ตัวอย่างใน Figma: 2 วัน = Use soon, 5 วัน = Fresh, เมื่อวาน = Expired; เกณฑ์ตัวเลขจริงยังไม่ชัด)
- ล็อกอินได้ทั้งแบบ Username/Email + Password และ Google; ลืมรหัสผ่านส่งลิงก์ทางอีเมล
- สแกนฉลากด้วย Gemini แล้วเติมฟอร์ม Add Item

## ยังไม่ชัด (ห้ามเดา ให้จดเป็น Open questions)
- เนื้อหาแท็บ Expired ใน History
- เกณฑ์จำนวนวันของสถานะ Use soon
- ข้อความในไดอะล็อกยืนยันทุกอัน
- ค่าสีของธีม Dark

