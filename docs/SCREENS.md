# FM-EAA Screen Mapping & Specifications

เอกสารสรุปความเชื่อมโยงระหว่างหน้าจอในดีไซน์ Figma (24 หน้าจอ/คอมโพเนนต์ตาม [DESIGN_SPEC.md](DESIGN_SPEC.md)) กับโครงสร้างไฟล์และ Route ใน Flutter Application

Figma File: [FM-EAA on Figma](https://www.figma.com/design/MB6XUkZz1GZqJpDqvfkHYc/FM-EAA?node-id=0-1&t=dJwjYD0ae67KEzdu-1)

---

## 📱 ตารางหน้าจอทั้งหมด (Screen Mapping)

| ลำดับ | ชื่อหน้าจอ / คอมโพเนนต์ | ไฟล์ที่เกี่ยวข้อง (frontend/lib/...) | Route Path | Figma Node ID | รายละเอียดและฟังก์ชันหลัก |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **1** | Onboarding & Permission | `features/auth/presentation/pages/onboarding_page.dart` | `/onboarding` | `11:26` | รูปตู้เย็น, หัวข้อ "Reduce Food Waste", "Get smart alerts before your groceries expire.", ปุ่ม "Enable Notifications" ขอสิทธิ์แจ้งเตือน, ลิงก์ "Skip" |
| **2** | Sign In | `features/auth/presentation/pages/sign_in_page.dart` | `/sign-in` | `8:39` | โลโก้แอป, "Welcome To Fridge Management & Expiry Alert App", Username/Email, Password (toggle show/hide), Forgot password?, ปุ่ม Sign In, ปุ่ม Sign in with Google, Sign up link |
| **3** | Create an Account | `features/auth/presentation/pages/create_account_page.dart` | `/create-account` | `52:113`, `362:18` | Username, Email, Password ("Use at least 8 characters."), Confirm Password, ปุ่ม Sign Up, ปุ่ม Sign up with Google, Sign In link |
| **4** | Reset Password | `features/auth/presentation/pages/reset_password_page.dart` | `/reset-password` | `64:3` | "Enter your email", ช่อง Email, ปุ่ม "Send Link" |
| **5** | My Fridges | `features/fridges/presentation/pages/my_fridges_page.dart` | `/fridges` | `223:69`, `88:62` | หัวข้อ "My Fridges", ไอคอนแจ้งเตือน+ตั้งค่า, แบนเนอร์สรุปของต้องจัดการ, การ์ดตู้ 2 คอลัมน์ (ไอคอน, ชื่อ, คำอธิบาย, จำนวนของ, ป้าย Personal หรือ N members), FAB เพิ่มตู้ |
| **6** | Add New Fridge | `features/fridges/presentation/pages/add_fridge_page.dart` | `/fridges/add` | `88:225` | ช่อง Fridge Name, Description, ปุ่ม Create Fridge |
| **7** | Edit Fridge (Bottom Sheet) | `features/fridges/presentation/widgets/edit_fridge_sheet.dart` | *(Bottom Sheet)* | `120:30` | "Edit Fridge", ช่อง Fridge Name, Description (optional), ปุ่ม Save, ปุ่ม Delete Fridge (แดง) |
| **8** | Delete Fridge Alert (Dialog) | `features/fridges/presentation/widgets/delete_fridge_dialog.dart` | *(Dialog)* | `124:30` | ไดอะล็อกยืนยันการลบตู้เย็น |
| **9** | Fridge Detail | `features/fridge_detail/presentation/pages/fridge_detail_page.dart` | `/fridges/:id` | `11:178`, `275:17` | ย้อนกลับ, ชื่อตู้, ไอคอน Family, History, Notifications, Settings; ช่องค้นหา; Chips หมวด (All, Proteins, Veggies, Beverages, Meals, Sauces); แท็บ Fridge/Freezer; การ์ดของ (รูป, ชื่อ, ปริมาณ, ป้ายสถานะ); FAB เพิ่มของ |
| **10** | Search | `features/search/presentation/pages/search_page.dart` | `/fridges/:id/search` | `376:543`, `383:77`, `415:2102` | ช่องค้นหามีปุ่มล้าง (✕), "Results for...", การ์ดผลลัพธ์ (ชื่อ, หมวด, ป้ายสถานะ, วันที่เหลือ) |
| **11** | Add Items | `features/item/presentation/pages/add_item_page.dart` | `/fridges/:id/items/add` | `20:52` | การ์ด "Scan Label with AI" พร้อมปุ่มวิเคราะห์ด้วย Gemini, ฟอร์ม: Food Name, Category, Quantity+Unit, Storage Location (Fridge/Freezer), Expiration Date, ปุ่ม Save |
| **12** | Item Details | `features/item/presentation/pages/item_details_page.dart` | `/fridges/:id/items/:itemId` | `230:68`, `230:110` | ปุ่มแก้ไข (ดินสอ), รูปใหญ่, ชื่อ, ปริมาณ+หน่วย, ป้ายสถานะ, tags (หมวด, โซน), ปุ่ม "Mark as Consumed", ปุ่ม "Delete Item" (แดง) |
| **13** | Edit Item Details | `features/item/presentation/pages/edit_item_page.dart` | `/fridges/:id/items/:itemId/edit` | `376:1134`, `376:1348` | รูป + ปุ่มเปลี่ยนรูป, ชื่อ, Category, จำนวน+หน่วย, Storage Location, Expiration date, ปุ่ม Save |
| **14** | Mark as Consumed (Bottom Sheet) | `features/item/presentation/widgets/mark_consumed_sheet.dart` | *(Bottom Sheet)* | `407:30`, `376:1616` | "How much did you consume?", จำนวนที่มีในตู้, ตัวนับ − / + (เริ่ม 1 of N), ปุ่ม Confirm, ปุ่ม "Finished all" |
| **15** | Finish All (State / Snackbar) | `features/item/presentation/widgets/finish_all_snackbar.dart` | *(Snackbar/State)* | `401:154`, `409:255`, `409:401` | กลับหน้ารายการ ของหายไป มี Snackbar "<ชื่อ> marked as consumed" + ปุ่ม Undo |
| **16** | Delete Item Alert (Dialog) | `features/item/presentation/widgets/delete_item_dialog.dart` | *(Dialog)* | `376:1737` | ไดอะล็อกยืนยันการลบวัตถุดิบ |
| **17** | History | `features/history/presentation/pages/history_page.dart` | `/fridges/:id/history` | `394:294`, `394:369` | แท็บ Consumed / Expired, ข้อความ "Consumed is auto-deleted after 30 days", ปุ่ม Clear All (แดง), แถวประวัติ (รูป, ชื่อ, จำนวนที่กิน/เหลือ, @username, วันเวลา, ปุ่มลบรายชิ้น) |
| **18** | Family Share | `features/family/presentation/pages/family_share_page.dart` | `/fridges/:id/family` | `11:49` | ชื่อตู้, จำนวนสมาชิก, รายชื่อสมาชิก (รูป, ชื่อ, role Owner/Member, ปุ่มลบสมาชิกยกเว้น owner), ปุ่ม "Invite Member" |
| **19** | Invite to Family | `features/family/presentation/pages/invite_member_page.dart` | `/fridges/:id/family/invite` | `170:5`, `174:6`, `172:81` | ช่องค้นหา "Search Username", แสดงผลการค้นหาและปุ่มเชิญสมาชิก |
| **20** | Remove Member Alert (Dialog) | `features/family/presentation/widgets/remove_member_dialog.dart` | *(Dialog)* | `172:142` | ไดอะล็อกยืนยันการนำสมาชิกออกจากตู้เย็น |
| **21** | Notifications | `features/notifications/presentation/pages/notifications_page.dart` | `/notifications` | `141:22` | การ์ดคำเชิญเข้าตู้ ("... invited you to join '...'" + ปุ่ม Accept / Decline), การ์ดแจ้งเตือนวันหมดอายุ ("... expires tomorrow") |
| **22** | Settings | `features/settings/presentation/pages/settings_page.dart` | `/settings` | `134:187` | Profile card (ตัวอักษรย่อ, ชื่อ, อีเมล, ปุ่มแก้ไข), Preferences: Language (TH / EN), Theme (Light / Dark), ปุ่ม "Log out" (แดง) |
| **23** | Edit Profile | `features/settings/presentation/pages/edit_profile_page.dart` | `/settings/profile` | `138:183` | อวตาร + ปุ่มกล้อง, ช่อง Name, Email, "Change password" (Current Password, New Password), ปุ่ม Save Changes |
| **24** | Log Out Alert (Dialog) | `features/settings/presentation/widgets/logout_dialog.dart` | *(Dialog)* | `133:438` | ไดอะล็อกยืนยันการออกจากระบบ |

---

## ❓ Open Questions (ประเด็นที่ยังไม่ระบุชัดใน Spec)

ประเด็นเหล่านี้เป็นข้อสังเกตจากไฟล์ `DESIGN_SPEC.md` ที่ต้องรอการสรุปเพิ่มเติมจากทีมดีไซน์หรือ Product Owner:

1. **เนื้อหาและฟิลด์ข้อมูลในแท็บ Expired (History):**  
   ใน Figma แสดงโครงสร้างแท็บ Expired คล้ายกับ Consumed แต่ยังไม่ได้ระบุชัดเจนว่าของที่หมดอายุมีฟิลด์เหตุผลของการทิ้ง (Reason for discard) หรือบันทึกเฉพาะวันที่หมดอายุและปริมาณ
2. **เกณฑ์จำนวนวันของสถานะ "Use soon":**  
   ในตัวอย่าง Figma พบว่า 2 วันเหลือ = Use soon และ 5 วันเหลือ = Fresh แต่ยังไม่มีการกำหนด Business Rule ที่ชัดเจน (เช่น หมดอายุภายใน $\le 3$ วันถือเป็น Use soon หรือขึ้นกับหมวดหมู่อาหาร)
3. **ข้อความและคำเตือนในไดอะล็อกยืนยันทั้งหมด (Confirmation Dialogs):**  
   ข้อความคำถาม Title/Body ของไดอะล็อกยืนยันการลบตู้เย็น, การลบวัตถุดิบ, การลบสมาชิก และการ Log out ยังเป็นข้อความทั่วไปใน Mockup
4. **ค่าสีของธีม Dark Mode:**  
   ดีไซน์ใน Figma ระบุสวิตช์ Light / Dark Mode แต่ค่าสี Token ที่ระบุมีเฉพาะฝั่ง Light Mode (`Primary #2E6A44`, `Surface #F6FBF3`, `Surface Container #EAEFE8`, `On Surface #181D18`) ฝั่ง Dark Mode ต้องรอการกำหนดค่าสี ColorScheme อย่างเป็นทางการ

