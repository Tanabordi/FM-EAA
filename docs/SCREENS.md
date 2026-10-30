# FM-EAA Screen Mapping & Specifications

เอกสารสรุปความเชื่อมโยงระหว่างหน้าจอในดีไซน์ Figma (24 หน้าจอและคอมโพเนนต์ตาม [DESIGN_SPEC.md](DESIGN_SPEC.md)) กับโครงสร้างไฟล์และ Route ใน Flutter Application

Figma File [FM-EAA on Figma](https://www.figma.com/design/MB6XUkZz1GZqJpDqvfkHYc/FM-EAA?node-id=0-1&t=dJwjYD0ae67KEzdu-1)

---

## 📱 ตารางหน้าจอทั้งหมด (Screen Mapping)

| ลำดับ | ชื่อหน้าจอและคอมโพเนนต์ | ไฟล์ที่เกี่ยวข้อง (frontend/lib/...) | Route Path | Figma Node ID | รายละเอียดและฟังก์ชันหลัก |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **1** | Onboarding & Permission | `features/auth/presentation/pages/onboarding_page.dart` | `/onboarding` | `11:26` | ภาพตู้เย็น หัวข้อ "Reduce Food Waste" พร้อมข้อความ "Get smart alerts before your groceries expire." ปุ่ม "Enable Notifications" ขอสิทธิ์แจ้งเตือน และลิงก์ "Skip" |
| **2** | Sign In | `features/auth/presentation/pages/sign_in_page.dart` | `/sign-in` | `8:39` | โลโก้แอป ข้อความ "Welcome To Fridge Management & Expiry Alert App" ช่อง Username/Email, Password (กดดู/ซ่อนได้), ลิงก์ Forgot password? ปุ่ม Sign In, ปุ่ม Sign in with Google และ Sign up link |
| **3** | Create an Account | `features/auth/presentation/pages/create_account_page.dart` | `/create-account` | `52:113`, `362:18` | ช่องกรอก Username, Email, Password (คำแนะนำ "Use at least 8 characters."), Confirm Password, ปุ่ม Sign Up, ปุ่ม Sign up with Google และ Sign In link |
| **4** | Reset Password | `features/auth/presentation/pages/reset_password_page.dart` | `/reset-password` | `64:3` | ข้อความ "Enter your email" ช่องกรอก Email และปุ่ม "Send Link" |
| **5** | My Fridges | `features/fridges/presentation/pages/my_fridges_page.dart` | `/fridges` | `223:69`, `88:62` | หัวข้อ "My Fridges" ไอคอนแจ้งเตือนและตั้งค่า แบนเนอร์สรุปของที่ต้องรีบจัดการ การ์ดตู้แบบ 2 คอลัมน์ (แสดงไอคอน, ชื่อ, คำอธิบาย, จำนวนของ, ป้าย Personal หรือ N members) และปุ่มลอยเพิ่มตู้ |
| **6** | Add New Fridge | `features/fridges/presentation/pages/add_fridge_page.dart` | `/fridges/add` | `88:225` | ช่องกรอก Fridge Name, Description และปุ่ม Create Fridge |
| **7** | Edit Fridge (Bottom Sheet) | `features/fridges/presentation/widgets/edit_fridge_sheet.dart` | *(Bottom Sheet)* | `120:30` | หัวข้อ "Edit Fridge" ช่องกรอก Fridge Name, Description (ไม่บังคับ), ปุ่ม Save และปุ่ม Delete Fridge (สีแดง) |
| **8** | Delete Fridge Alert (Dialog) | `features/fridges/presentation/widgets/delete_fridge_dialog.dart` | *(Dialog)* | `124:30` | ไดอะล็อกยืนยันการลบตู้เย็น |
| **9** | Fridge Detail | `features/fridge_detail/presentation/pages/fridge_detail_page.dart` | `/fridges/:id` | `11:178`, `275:17` | ปุ่มย้อนกลับ ชื่อตู้ ไอคอน Family, History, Notifications, Settings ช่องค้นหา ชิปกรองหมวดหมู่วงกลม (All, Proteins, Veggies, Beverages, Meals, Sauces) แท็บ Fridge/Freezer การ์ดรายการอาหาร (รูป, ชื่อ, ปริมาณ, ป้ายสถานะ) และปุ่มลอยเพิ่มของ |
| **10** | Search | `features/search/presentation/pages/search_page.dart` | `/fridges/:id/search` | `376:543`, `383:77`, `415:2102` | ช่องค้นหาพร้อมปุ่มล้างคำค้นหา (✕) แสดงข้อความ "Results for..." และการ์ดผลลัพธ์ (ชื่อ, หมวดหมู่, ป้ายสถานะ, จำนวนวันที่เหลือ) |
| **11** | Add Items | `features/item/presentation/pages/add_item_page.dart` | `/fridges/:id/items/add` | `20:52` | การ์ด "Scan Label with AI" พร้อมปุ่มวิเคราะห์ด้วย Gemini และฟอร์มกรอก Food Name, Category, Quantity+Unit, Storage Location (Fridge/Freezer), Expiration Date และปุ่ม Save |
| **12** | Item Details | `features/item/presentation/pages/item_details_page.dart` | `/fridges/:id/items/:itemId` | `230:68`, `230:110` | ปุ่มแก้ไข (ไอคอนดินสอ) ภาพขนาดใหญ่ ชื่อ ปริมาณพร้อมหน่วย ป้ายสถานะ แท็กกำกับหมวดหมู่และโซน ปุ่ม "Mark as Consumed" และปุ่ม "Delete Item" (สีแดง) |
| **13** | Edit Item Details | `features/item/presentation/pages/edit_item_page.dart` | `/fridges/:id/items/:itemId/edit` | `376:1134`, `376:1348` | รูปภาพพร้อมปุ่มเปลี่ยนภาพ ชื่อ Category จำนวนพร้อมหน่วย Storage Location (Fridge/Freezer) Expiration date และปุ่ม Save |
| **14** | Mark as Consumed (Bottom Sheet) | `features/item/presentation/widgets/mark_consumed_sheet.dart` | *(Bottom Sheet)* | `407:30`, `376:1616` | คำถาม "How much did you consume?" แสดงจำนวนที่มีในตู้ ตัวนับลบ/บวก (− / + เริ่มต้น 1 of N) ปุ่ม Confirm และปุ่ม "Finished all" |
| **15** | Finish All (State / Snackbar) | `features/item/presentation/widgets/finish_all_snackbar.dart` | *(Snackbar/State)* | `401:154`, `409:255`, `409:401` | นำกลับมาหน้ารายการโดยรายการของชิ้นนั้นจะถูกลบออก พร้อมแสดง Snackbar แจ้ง "<ชื่อ> marked as consumed" และปุ่ม Undo |
| **16** | Delete Item Alert (Dialog) | `features/item/presentation/widgets/delete_item_dialog.dart` | *(Dialog)* | `376:1737` | ไดอะล็อกยืนยันการลบวัตถุดิบออกจากตู้ |
| **17** | History | `features/history/presentation/pages/history_page.dart` | `/fridges/:id/history` | `394:294`, `394:369` | แท็บ Consumed / Expired ข้อความชี้แจง "Consumed is auto-deleted after 30 days" ปุ่ม Clear All (สีแดง) แถวประวัติ (รูป, ชื่อ, จำนวนที่กิน/เหลือ, @username, วันเวลา และปุ่มลบรายชิ้น) |
| **18** | Family Share | `features/family/presentation/pages/family_share_page.dart` | `/fridges/:id/family` | `11:49` | ชื่อตู้เย็น จำนวนสมาชิกทั้งหมด รายชื่อสมาชิก (รูปโปรไฟล์, ชื่อ, บทบาท Owner/Member และปุ่มลบสมาชิกยกเว้นเจ้าของตู้) พร้อมปุ่ม "Invite Member" |
| **19** | Invite to Family | `features/family/presentation/pages/invite_member_page.dart` | `/fridges/:id/family/invite` | `170:5`, `174:6`, `172:81` | ช่องค้นหา "Search Username" แสดงผลการค้นหาผู้ใช้และปุ่มกดเชิญสมาชิกเข้าร่วมตู้ |
| **20** | Remove Member Alert (Dialog) | `features/family/presentation/widgets/remove_member_dialog.dart` | *(Dialog)* | `172:142` | ไดอะล็อกยืนยันการนำสมาชิกออกจากตู้เย็น |
| **21** | Notifications | `features/notifications/presentation/pages/notifications_page.dart` | `/notifications` | `141:22` | การ์ดคำเชิญเข้าตู้เย็น (แสดงผู้เชิญและชื่อตู้ พร้อมปุ่ม Accept / Decline) และการ์ดแจ้งเตือนวันหมดอายุ (เช่น "Milk expires tomorrow") |
| **22** | Settings | `features/settings/presentation/pages/settings_page.dart` | `/settings` | `134:187` | การ์ด Profile (แสดงตัวอักษรย่อ, ชื่อ, อีเมล และปุ่มแก้ไข) หัวข้อ Preferences เลือกภาษา TH / EN เลือกธีม Light / Dark และปุ่ม "Log out" (สีแดง) |
| **23** | Edit Profile | `features/settings/presentation/pages/edit_profile_page.dart` | `/settings/profile` | `138:183` | รูปอวตารพร้อมปุ่มกล้องถ่ายรูป ช่องแก้ไข Name, Email ส่วนเปลี่ยนรหัสผ่าน (Current Password, New Password) และปุ่ม Save Changes |
| **24** | Log Out Alert (Dialog) | `features/settings/presentation/widgets/logout_dialog.dart` | *(Dialog)* | `133:438` | ไดอะล็อกยืนยันการออกจากระบบ |

---

## ❓ Open Questions (ประเด็นที่ยังไม่ระบุชัดใน Spec)

ประเด็นเหล่านี้เป็นข้อสังเกตจากไฟล์ `DESIGN_SPEC.md` ที่ต้องรอการสรุปเพิ่มเติมจากทีมดีไซน์หรือ Product Owner

1. **เนื้อหาและฟิลด์ข้อมูลในแท็บ Expired (History)**  
   ใน Figma แสดงโครงสร้างแท็บ Expired คล้ายกับ Consumed แต่ยังไม่ได้ระบุชัดเจนว่าของที่หมดอายุมีฟิลด์เหตุผลของการทิ้ง (Reason for discard) หรือบันทึกเฉพาะวันที่หมดอายุและปริมาณ
2. **เกณฑ์จำนวนวันของสถานะ "Use soon"**  
   ในตัวอย่าง Figma พบว่า 2 วันเหลือ = Use soon และ 5 วันเหลือ = Fresh แต่ยังไม่มีการกำหนด Business Rule ที่ชัดเจน (เช่น หมดอายุภายใน $\le 3$ วันถือเป็น Use soon หรือขึ้นกับหมวดหมู่อาหาร)
3. **ข้อความและคำเตือนในไดอะล็อกยืนยันทั้งหมด (Confirmation Dialogs)**  
   ข้อความคำถาม Title/Body ของไดอะล็อกยืนยันการลบตู้เย็น การลบวัตถุดิบ การลบสมาชิก และการ Log out ยังเป็นข้อความทั่วไปใน Mockup
4. **ค่าสีของธีม Dark Mode**  
   ดีไซน์ใน Figma ระบุสวิตช์ Light / Dark Mode แต่ค่าสี Token ที่ระบุมีเฉพาะฝั่ง Light Mode (`Primary #2E6A44`, `Surface #F6FBF3`, `Surface Container #EAEFE8`, `On Surface #181D18`) ฝั่ง Dark Mode ต้องรอการกำหนดค่าสี ColorScheme อย่างเป็นทางการ
