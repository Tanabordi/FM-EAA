# DESIGN SPEC (สรุปจาก Figma FM-EAA)

> หมายเหตุเรื่องขนาด ตัวเลขขนาดในเอกสารนี้ (เช่น เฟรมมือถือ 412x892 หรือไดอะล็อก 328x184) เป็นขนาด artboard ใน Figma เพื่อให้เห็นสัดส่วนและระยะห่างเท่านั้น
> ตัวแอปพลิเคชันจริงต้องออกแบบให้ Responsive ยืดหยุ่นตามขนาดหน้าจอของมือถือแต่ละเครื่อง โดยไม่ล็อกความกว้างและความสูงตายตัว

เอกสารนี้สรุปดีไซน์จาก Figma เพื่อให้ทีมพัฒนานำไปใช้อ้างอิงในการออกแบบและพัฒนาได้โดยตรง
Figma [FM-EAA on Figma](https://www.figma.com/design/MB6XUkZz1GZqJpDqvfkHYc/FM-EAA?node-id=0-1&t=dJwjYD0ae67KEzdu-1)
หากเอกสารอื่นมีข้อความขัดแย้งกับไฟล์นี้ ให้ยึดรายละเอียดในไฟล์นี้เป็นหลัก

## Design tokens (Material 3 ธีมสีเขียว)
- Primary #2E6A44 (ปุ่มหลัก ปุ่มลอย FAB และแท็บที่เลือก) และ On Primary #FFFFFF
- Surface (พื้นหลังหน้าจอ) #F6FBF3 และ Surface Container (การ์ด ช่องค้นหา) #EAEFE8
- On Surface #181D18, On Surface Variant #414942 และ Outline #717971
- สถานะความสดใหม่ **Fresh** #34C759 (สีเขียว ไอคอนดาว), **Use soon** #FF8D28 (สีส้ม ไอคอนนาฬิกา), **Expired** #FF383C (สีแดง ไอคอนเตือน)
- ปุ่มการทำงานสำคัญ (Delete, Log out, Clear All, Decline) ใช้สีแดงเข้มประมาณ #B91C1C
- รูปทรงปุ่มหลักเป็นแบบแคปซูลกว้างเต็มพื้นที่ ปุ่มย้อนกลับเป็นกรอบมน ปุ่มลอย FAB สีเขียวมุมขวาล่าง ช่องค้นหาทรงรีมีมิติเงา และแผ่น Bottom Sheet มุมบนโค้งมน
- แอปพลิเคชันรองรับการสลับภาษา TH/EN และสลับธีม Light/Dark ในหน้า Settings

## หลักการจัดวางหน้าจอ (Responsive Layout)
- ออกแบบ Layout ให้ยืดหยุ่นตามขนาดหน้าจอโดยใช้ Flutter `Column`, `Row`, `Expanded`, `Flexible`, `SafeArea` และ `SingleChildScrollView` สำหรับเนื้อหาที่มีความยาว
- ไม่กำหนดความกว้างและความสูงของหน้าจอเป็นตัวเลขคงที่ โดยปุ่มหลัก ช่องกรอกข้อมูล และการ์ด จะใช้ความกว้างเต็มพื้นที่ตามระยะ Padding ที่กำหนด
- ใช้ระยะห่างและ Padding มาตรฐานประมาณ 16 ถึง 24 dp ร่วมกับความโค้งมนและขนาดไอคอนที่สม่ำเสมอ
- การ์ดตู้เย็นในหน้า My Fridges จัดวางในรูปแบบ Grid 2 คอลัมน์ โดยคำนวณความกว้างตามความกว้างของหน้าจอ
- รองรับการปรับขนาดฟอนต์ของระบบและการแสดงผลภาษาไทยที่มีความยาวมากกว่าภาษาอังกฤษ

## รายละเอียดหน้าจอทั้งหมด (ลำดับ ชื่อหน้าจอ รหัส Figma Node และรายละเอียด)

### Auth และ Onboarding
1. Onboarding & Permission (Node 11:26) ภาพตู้เย็น หัวข้อ "Reduce Food Waste" ข้อความ "Get smart alerts before your groceries expire." ปุ่ม "Enable Notifications" เพื่อขอสิทธิ์แจ้งเตือน และลิงก์ "Skip"
2. Sign In (Node 8:39) โลโก้แอป ข้อความ "Welcome To Fridge Management & Expiry Alert App" ช่องกรอก Username or Email, Password (กดดู/ซ่อนได้) ลิงก์ Forgot password? ปุ่ม Sign In ข้อความ "Or" ปุ่ม Sign in with Google และลิงก์ "Don't have an account? Sign up"
3. Create an Account (Node 52:113, 362:18) ช่องกรอก Username, Email, Password (คำแนะนำ "Use at least 8 characters.") Confirm Password ปุ่ม Sign Up ปุ่ม Sign up with Google และลิงก์ Sign In
4. Reset Password (Node 64:3) ข้อความ "Enter your email" ช่องกรอก Email และปุ่ม "Send Link"

### ตู้เย็น (ผู้ใช้สามารถสร้างได้หลายตู้)
5. My Fridges (Node 223:69, 88:62) หัวข้อ "My Fridges" ไอคอนแจ้งเตือนและตั้งค่า ข้อความ "A fresh look at what's inside." แบนเนอร์สรุป "A little check, a lot less waste N items need your attention today" หัวข้อ "Your fridges" พร้อมจำนวนตู้ การ์ดตู้เย็น 2 คอลัมน์ (แสดงไอคอน เมนูสามจุด ชื่อตู้ คำอธิบาย จำนวนของ ป้าย Personal หรือจำนวนสมาชิก) และปุ่มลอยเพิ่มตู้
6. Add New Fridge (Node 88:225) ช่องกรอก Fridge Name, Description และปุ่ม Create Fridge
7. Edit Fridge (Bottom Sheet Node 120:30) หัวข้อ "Edit Fridge" ช่องกรอก Fridge Name, Description (ไม่บังคับ) ปุ่ม Save และปุ่ม Delete Fridge (สีแดง)
8. Delete Fridge Alert (Dialog Node 124:30) ไดอะล็อกยืนยันการลบตู้เย็น

### ภายในตู้เย็น (หน้ารายการวัตถุดิบ)
9. Fridge Detail (Node 11:178, 275:17) แถบด้านบนแสดงปุ่มย้อนกลับ ชื่อตู้เย็น ไอคอน Family, History, Notifications, Settings ช่องค้นหา "Search for items" ชิปวงกลมเลือกหมวดหมู่ All, Proteins, Veggies, Beverages, Meals, Sauces แท็บสลับช่องธรรมดา Fridge และช่องแช่แข็ง Freezer การ์ดรายการอาหาร (รูป ชื่อ ปริมาณพร้อมหน่วย ป้ายสถานะ และจำนวนวันที่เหลือ) พร้อมปุ่มลอยเพิ่มของ
10. Search (Node 376:543, 383:77, 415:2102) ช่องค้นหาพร้อมปุ่มกากบาทล้างคำค้น ข้อความ "Results for..." และการ์ดแสดงผลลัพธ์การค้นหา

### วัตถุดิบ
11. Add Items (Node 20:52) การ์ด "Scan Label with AI" พร้อมปุ่มวิเคราะห์ด้วย Gemini และฟอร์มกรอก Food Name, Category, Quantity พร้อมหน่วย, Storage Location (Fridge/Freezer), Expiration Date และปุ่ม Save
12. Item details (Node 230:68, 230:110) ปุ่มแก้ไขไอคอนดินสอมุมขวาบน ภาพวัตถุดิบขนาดใหญ่ ชื่อ ปริมาณพร้อมหน่วย ป้ายสถานะความสด แท็กหมวดหมู่และโซนจัดเก็บ ปุ่ม "Mark as Consumed" และปุ่ม "Delete Item" สีแดง
13. Edit Item details (Node 376:1134, 376:1348) ภาพพร้อมปุ่มเปลี่ยนรูป ชื่อ หมวดหมู่ จำนวนพร้อมหน่วย โซนจัดเก็บ วันหมดอายุ และปุ่ม Save
14. Mark as Consumed (Bottom Sheet Node 407:30, 376:1616) คำถาม "How much did you consume?" แสดงชื่อและจำนวนคงเหลือในตู้ ตัวนับลบ/บวก ปุ่ม Confirm และปุ่ม "Finished all"
15. Finish All (State Node 401:154, 409:255, 409:401) กลับสู่หน้ารายการโดยนำของชิ้นนั้นออกจากรายการ พร้อมแสดง Snackbar "<ชื่อ> marked as consumed" และปุ่ม Undo เพื่อย้อนกลับ
16. Delete Item Alert (Dialog Node 376:1737) ไดอะล็อกยืนยันการลบวัตถุดิบ

### ประวัติการใช้งาน
17. History (Node 394:294, 394:369) แท็บสลับ Consumed และ Expired ข้อความชี้แจง "Consumed is auto-deleted after 30 days" ปุ่ม Clear All สีแดง รายการจัดกลุ่มตามวัน แสดงรูป ชื่อ จำนวนที่กินหรือเหลือ ผู้ทำรายการ วันเวลา ป้ายสถานะ และปุ่มลบรายชิ้น

### สมาชิกครอบครัว
18. Family Share (Node 11:49) การ์ดชื่อตู้เย็น จำนวนสมาชิก รายชื่อสมาชิก (รูป ชื่อ บทบาท Owner หรือ Member ปุ่มลบสมาชิกยกเว้นเจ้าของตู้) ข้อความอธิบาย และปุ่ม "Invite Member"
19. Invite to Family (Node 170:5, 174:6, 172:81) ช่องค้นหา "Search Username" พร้อมแสดงผลการค้นหาและปุ่มเชิญสมาชิก
20. Remove Member Alert (Dialog Node 172:142) ไดอะล็อกยืนยันการนำสมาชิกออกจากตู้เย็น

### การตั้งค่าและการแจ้งเตือน
21. Notifications (Node 141:22) การ์ดคำเชิญเข้าร่วมตู้เย็นพร้อมปุ่มกดยอมรับ Accept และปฏิเสธ Decline และการ์ดแจ้งเตือนวันหมดอายุของอาหาร
22. Settings (Node 134:187) ส่วนข้อมูลโปรไฟล์ (แสดงตัวอักษรย่อ ชื่อ อีเมล และปุ่มแก้ไข) ส่วนการตั้งค่าเลือกภาษา TH หรือ EN เลือกธีม Light หรือ Dark และปุ่ม Log out สีแดง
23. Edit Profile (Node 138:183) ภาพอวตารพร้อมปุ่มถ่ายรูป ช่องกรอก Name, Email ส่วนเปลี่ยนรหัสผ่าน Current Password, New Password และปุ่ม Save Changes
24. Log Out Alert (Dialog Node 133:438) ไดอะล็อกยืนยันการออกจากระบบ

## พฤติกรรมสำคัญตามการออกแบบ
- ผู้ใช้งานสามารถสร้างตู้เย็นได้หลายตู้ โดยแต่ละตู้มีชื่อและคำอธิบาย ตู้ส่วนตัวจะแสดงสถานะ Personal ส่วนตู้ที่แชร์จะแสดงจำนวนสมาชิก พร้อมกำหนดบทบาทเป็น Owner หรือ Member
- การกินของสามารถระบุจำนวนที่บริโภค หรือเลือก Finished all เมื่อกินหมด พร้อมบันทึกลงประวัติ History โดยระบุชื่อผู้ทำรายการและเวลา มีปุ่ม Undo สำหรับย้อนคืนสถานะ และประวัติในแท็บ Consumed จะถูกลบอัตโนมัติเมื่อครบ 30 วัน
- การเชิญสมาชิกเข้าตู้เย็นทำได้โดยค้นหา Username และส่งคำเชิญไปยังระบบแจ้งเตือนของอีกฝ่ายเพื่อกดยอมรับหรือปฏิเสธ
- สถานะความสดใหม่แบ่งออกเป็น 3 ระดับ คำนวณจากวันหมดอายุจริง
- ระบบเข้าสู่ระบบรองรับทั้ง Username/Email ร่วมกับรหัสผ่าน และ Google Sign-In พร้อมระบบส่งลิงก์ตั้งรหัสผ่านใหม่ทางอีเมล
- ระบบสแกนฉลากด้วย Gemini AI จะช่วยวิเคราะห์รูปถ่ายแล้วนำข้อมูลมากรอกลงในแบบฟอร์มเพิ่มของให้อัตโนมัติ

## ประเด็นที่รอการสรุปเพิ่มเติม (Open Questions)
- ข้อมูลและฟิลด์ที่ต้องบันทึกในแท็บ Expired ของหน้าประวัติ
- เกณฑ์จำนวนวันที่แน่นอนในการเปลี่ยนสถานะเป็น Use soon
- ข้อความระบุคำถามและคำเตือนในไดอะล็อกยืนยันแต่ละประเภท
- ชุดสี ColorScheme ทางการสำหรับธีม Dark Mode
