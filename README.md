<div align="center">

# 🧊 Fridge Management & Expiry Alert App (FM-EAA)

**แอปพลิเคชันจัดการสต็อกวัตถุดิบในตู้เย็นและแจ้งเตือนวันหมดอายุอัจฉริยะ**  
*พัฒนาขึ้นสำหรับโครงงานรายวิชา MDSD-2026*

<br/>

[![Flutter](https://img.shields.io/badge/Frontend-Flutter_3.x-02569B?logo=flutter&logoColor=white&style=for-the-badge)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod-2E8555?style=for-the-badge)](https://riverpod.dev)
[![Drift](https://img.shields.io/badge/Local_DB-Drift_(SQLite)-003B57?logo=sqlite&logoColor=white&style=for-the-badge)](https://drift.simonbinder.eu/)  
[![Node.js](https://img.shields.io/badge/Backend-Node.js_REST_API-339933?logo=nodedotjs&logoColor=white&style=for-the-badge)](https://nodejs.org)
[![Oracle Cloud](https://img.shields.io/badge/Cloud_DB-Oracle_Cloud_(OCI)-F80000?logo=oracle&logoColor=white&style=for-the-badge)](https://cloud.oracle.com)
[![Gemini AI](https://img.shields.io/badge/AI_Vision-Gemini_Vision_API-4285F4?logo=google&logoColor=white&style=for-the-badge)](https://ai.google.dev)

<br/>

<p>
  แอปพลิเคชันช่วยลดปัญหาขยะอาหาร (Food Waste) และลดค่าใช้จ่ายในบ้านด้วยระบบจัดการสต็อกแบบ Offline-First<br/>
  ใช้งานได้แม้ไม่มีเน็ต พร้อมระบบ Auto-Sync ขึ้น Oracle Cloud และระบบสแกนฉลากหาวันหมดอายุอัตโนมัติด้วย Gemini Vision API
</p>

---

</div>

## 📌 สารบัญ (Table of Contents)

- [💡 ที่มาและความสำคัญ (Problem & Solution)](#-ที่มาและความสำคัญ-problem--solution)
- [✨ ฟีเจอร์เด่นของระบบ (Key Features)](#-ฟีเจอร์เด่นของระบบ-key-features)
- [📐 สถาปัตยกรรมระบบ (System Architecture)](#-สถาปัตยกรรมระบบ-system-architecture)
  - [1. สถาปัตยกรรมแบบ 3-Tier (3-Tier Architecture)](#1-สถาปัตยกรรมแบบ-3-tier-3-tier-architecture)
  - [2. โครงสร้างตู้เย็นและ Family Share (Fridge & Family Domain Model)](#2-โครงสร้างตู้เย็นและ-family-share-fridge--family-domain-model)
- [🔄 ลอจิกการทำงานหลัก (Core Technical Flows)](#-ลอจิกการทำงานหลัก-core-technical-flows)
  - [1. ระบบจัดเก็บข้อมูลแบบ Offline-First (Local SQLite Storage)](#1-ระบบจัดเก็บข้อมูลแบบ-offline-first-local-sqlite-storage)
  - [2. กลไกการซิงค์ข้อมูลอัตโนมัติ (Auto-Synchronization Engine)](#2-กลไกการซิงค์ข้อมูลอัตโนมัติ-auto-synchronization-engine)
  - [3. การวิเคราะห์ภาพถ่ายด้วย AI (Gemini Vision Processing)](#3-การวิเคราะห์ภาพถ่ายด้วย-ai-gemini-vision-processing)
  - [4. ความปลอดภัยและการยืนยันตัวตน (Authentication & Security)](#4-ความปลอดภัยและการยืนยันตัวตน-authentication--security)
- [🛠 เทคโนโลยีที่ใช้ (Tech Stack)](#-เทคโนโลยีที่ใช้-tech-stack)
- [🧪 การทดสอบและระบบ CI/CD (Testing & Automation)](#-การทดสอบและระบบ-cicd-testing--automation)
- [👥 สมาชิกผู้จัดทำ (Contributors)](#-สมาชิกผู้จัดทำ-contributors)

---

## 💡 ที่มาและความสำคัญ (Problem & Solution)

### ปัญหาที่พบ (The Problem)

- **ปัญหาขยะอาหาร (Food Waste)** คนส่วนใหญ่มักลืมของสดที่แช่ไว้ลึกในตู้เย็นจนหมดอายุหรือเน่าเสีย ทำให้ต้องทิ้งอาหารไปโดยเปล่าประโยชน์
- **ซื้อของซ้ำซ้อน** การไม่รู้ว่ามีอะไรอยู่ในตู้เย็นบ้าง ทำให้เผลอซื้อของเดิมมาซ้ำ เสียเงินโดยใช่เหตุ
- **คนในบ้านไม่รู้สต็อกร่วมกัน** สมาชิกในบ้านหรือรูมเมทไม่รู้ว่ามีวัตถุดิบอะไรเหลืออยู่ ชิ้นไหนกินไปแล้ว หรือชิ้นไหนต้องรีบกินก่อนหมดอายุ

### แนวทางการแก้ไข (The Solution)

แอปพลิเคชัน **FM-EAA** ออกแบบมาเพื่อแก้ปัญหาเหล่านี้

1. **จัดการได้หลายตู้เย็น และแชร์กับครอบครัว (Family Share)** สร้างตู้เย็นได้หลายตู้ (เช่น ตู้เย็นส่วนตัว ตู้เย็นในครัว) และเชิญคนในบ้านเข้ามาดูสต็อกเดียวกัน ให้ทุกคนเห็นข้อมูลตรงกัน
2. **สแกนฉลากด้วย AI (Scan Label with AI)** ถ่ายรูปฉลากอาหาร แล้วใช้ Gemini Vision API อ่านชื่อและวันหมดอายุลงฟอร์มให้ทันที ไม่ต้องพิมพ์เอง
3. **ใช้งานแบบ Offline-First** ใช้งานและบันทึกข้อมูลได้ตลอดเวลาแม้ไม่มีเน็ต แล้วค่อยซิงค์ข้อมูลขึ้น Oracle Cloud เมื่อเชื่อมต่อได้
4. **บันทึกประวัติการใช้งาน (History)** แยกชัดเจนว่าของชิ้นไหนกินแล้ว (Consumed) หรือชิ้นไหนหมดอายุ (Expired) ช่วยให้เห็นพฤติกรรมและวางแผนซื้อของได้ดีขึ้น

---

## ✨ ฟีเจอร์เด่นของระบบ (Key Features)

### 1. 🥗 การแบ่งหมวดหมู่อาหารและโซนจัดเก็บ (Smart Categorization & Zoning)

- **แยกโซนจัดเก็บชัดเจน (Storage Zones)**
  - ❄️ **Fridge** สำหรับของสด ผัก ผลไม้ และเครื่องดื่ม
  - 🧊 **Freezer** สำหรับอาหารแช่แข็ง เนื้อสัตว์ และของที่เก็บได้นาน
- **หมวดหมู่อาหาร (Categories)**
  - 🌐 **All** แสดงรายการวัตถุดิบทั่วทั้งตู้เย็น
  - 🥩 **Proteins** เนื้อสัตว์ อาหารทะเล ไข่ เต้าหู้
  - 🥦 **Veggies** ผักสด ผลไม้ สมุนไพร
  - 🧃 **Beverages** นม น้ำผลไม้ เครื่องดื่มบรรจุขวด
  - 🍱 **Meals** อาหารปรุงสำเร็จ อาหารพร้อมทาน
  - 🥫 **Sauces** เครื่องปรุงรส ซอส แยม
- **แถบสีบอกสถานะความสดใหม่ (Freshness Visual Cues)**
  - 🟢 **Fresh** วัตถุดิบยังสดใหม่ ปลอดภัย
  - 🟡 **Use soon** ใกล้หมดอายุ ควรรีบนำมารับประทาน
  - 🔴 **Expired** หมดอายุแล้ว ไม่ควรนำมารับประทาน

### 2. 🔍 ระบบค้นหาวัตถุดิบ (Search)

- ค้นหาของในตู้เย็นได้ทันทีผ่านช่องค้นหาเดียว ไม่ว่าจะอยู่ใน Fridge หรือ Freezer
- กรองตามชื่อ หมวดหมู่ และโซนจัดเก็บได้รวดเร็วผ่าน Index ของฐานข้อมูลในเครื่อง

### 3. ✅ การบันทึกการบริโภคและประวัติการใช้งาน (Mark as Consumed & History)

- **Mark as Consumed** เลือกจำนวนที่บริโภคได้ ("How much did you consume?") หรือกด **Finished all** เมื่อกินหมด และกด **Undo** เพื่อย้อนกลับได้
- **ประวัติการใช้งาน (History)** แยกเป็น 2 แท็บ
  - 🍽️ **Consumed** ของที่นำไปทำอาหารหรือกินแล้ว
  - ⏰ **Expired** ของที่เลยวันหมดอายุ เพื่อใช้ดูสถิติลดขยะอาหาร
- ทุกรายการแสดงว่าใครเป็นผู้ทำรายการและเวลาเท่าไร (เช่น `by @sarah`)
- ประวัติ Consumed และ Expired จะถูกลบอัตโนมัติหลังผ่านไป **30 วัน** และสามารถกด **Clear All** เพื่อล้างเองได้

### 4. 👨‍👩‍👧‍👦 หลายตู้เย็นและ Family Share (My Fridges & Family Share)

- **My Fridges** สร้าง แก้ไข และลบตู้เย็นได้หลายตู้ โดยแต่ละตู้มีชื่อ คำอธิบาย และสมาชิกของตัวเอง
- **Family Share** แชร์ตู้เย็นให้คนในบ้าน โดยมีบทบาท **Owner** และ **Member** ให้ทุกคนช่วยกันอัปเดตสต็อกได้
- **Invite Member** เชิญสมาชิกด้วยการค้นหา Username และอีกฝ่ายต้องกดยอมรับคำเชิญก่อนจึงจะเข้าร่วมได้
- **Notifications**
  - แจ้งเตือนวันหมดอายุล่วงหน้าบนตัวเครื่อง (Offline Local Notifications) แม้ไม่ได้เชื่อมต่ออินเทอร์เน็ตก็แจ้งเตือนได้ตรงเวลา
  - หน้าแจ้งเตือนในแอปแสดงคำเชิญเข้าร่วมครอบครัว (Accept / Decline) และรายการที่ใกล้หมดอายุ

### 5. ⚙️ การตั้งค่า (Settings)

- แก้ไขโปรไฟล์ (Edit Profile) และเปลี่ยนรหัสผ่าน
- เลือกภาษา **TH / EN**
- เลือกธีม **Light / Dark**

---

## 📐 สถาปัตยกรรมระบบ (System Architecture)

### 1. สถาปัตยกรรมแบบ 3-Tier (3-Tier Architecture)

โครงสร้างระบบแบ่งการทำงานออกเป็น 3 ส่วน (3-Tier Architecture) เพื่อให้จัดการโค้ดง่าย ปลอดภัย และดูแลระบบได้สะดวก

```mermaid
flowchart TD
    subgraph ClientTier ["📱 1. Client Tier (Mobile Application)"]
        UI["Flutter UI (Material Design 3)"]
        Riverpod["Riverpod State Management"]
        Repo["Repository Layer"]
        LocalDB[("Local SQLite Database<br/>(Drift)")]

        UI <--> Riverpod
        Riverpod <--> Repo
        Repo <--> LocalDB
    end

    subgraph BackendTier ["⚙️ 2. Application Tier (Node.js REST API)"]
        API["Node.js / Express Server"]
        AuthModule["Auth (Email/Password & Google OAuth)<br/>& JWT Verification"]
        SyncEngine["Sync Engine & Conflict Handler<br/>(Last-Write-Wins: LWW)"]
        GeminiAdapter["Gemini Vision AI Adapter"]

        API --> AuthModule
        API --> SyncEngine
        API --> GeminiAdapter
    end

    subgraph CloudTier ["☁️ 3. Data Tier (Cloud Services)"]
        OracleDB[("Oracle Cloud Infrastructure<br/>(OCI Database)")]
        GeminiCloud["Google Gemini Vision API"]

        SyncEngine <-->|"Connection Pool / SQL"| OracleDB
        GeminiAdapter <-->|"REST HTTPS Request"| GeminiCloud
    end

    Repo ==>|"HTTPS REST API (Bearer JWT)"| API

    classDef clientStyle fill:#e0f2fe,stroke:#0284c7,stroke-width:2px,color:#0369a1;
    classDef backendStyle fill:#f0fdf4,stroke:#16a34a,stroke-width:2px,color:#15803d;
    classDef cloudStyle fill:#fef3c7,stroke:#d97706,stroke-width:2px,color:#b45309;

    class UI,Riverpod,Repo,LocalDB clientStyle;
    class API,AuthModule,SyncEngine,GeminiAdapter backendStyle;
    class OracleDB,GeminiCloud cloudStyle;
```

---

### 2. โครงสร้างตู้เย็นและ Family Share (Fridge & Family Domain Model)

ระบบออกแบบให้ผู้ใช้มีได้หลายตู้เย็น และรายการวัตถุดิบผูกเข้ากับตู้เย็นแต่ละตู้ เมื่อเชิญสมาชิกผ่าน Family Share สมาชิกทุกคนในตู้เย็นนั้นจะเข้าถึงและอัปเดตสต็อกร่วมกันได้

```mermaid
flowchart TD
    subgraph FamilyGroup ["👥 Family Share (Owner & Members)"]
        U1["Owner"]
        U2["Member 1"]
        U3["Member 2"]
    end

    Fridge["🧊 ตู้เย็น (Fridge) เช่น Kitchen fridge"]

    subgraph InventoryStock ["📦 สต็อกวัตถุดิบในตู้เย็น"]
        I1["🥩 เนื้อหมูสันใน (Freezer / Expiry: 15 วัน)"]
        I2["🥦 ผักกาดขาว (Fridge / Expiry: 4 วัน)"]
        I3["🧃 นมสดพาสเจอร์ไรส์ (Fridge / Expiry: 2 วัน)"]
    end

    U1 --> Fridge
    U2 --> Fridge
    U3 --> Fridge

    Fridge --> I1
    Fridge --> I2
    Fridge --> I3

    classDef user fill:#e0f2fe,stroke:#0284c7,stroke-width:2px,color:#0369a1;
    classDef fridge fill:#fef3c7,stroke:#d97706,stroke-width:3px,color:#92400e;
    classDef item fill:#f1f5f9,stroke:#64748b,stroke-width:2px,color:#334155;

    class U1,U2,U3 user;
    class Fridge fridge;
    class I1,I2,I3 item;
```

---

## 🔄 ลอจิกการทำงานหลัก (Core Technical Flows)

### 1. ระบบจัดเก็บข้อมูลแบบ Offline-First (Local SQLite Storage)

- ข้อมูลทั้งหมดจะถูกเขียนและอ่านจาก SQLite ในเครื่อง (ผ่าน Drift) เป็นหลัก
- **Optimistic UI** เมื่อผู้ใช้เพิ่ม ลบ หรือแก้ไขรายการอาหาร หน้าจอจะอัปเดตผลทันทีผ่าน Riverpod โดยไม่ต้องรอเซิร์ฟเวอร์ตอบกลับ
- ระบบจะกำหนดสถานะ `is_synced = false` พร้อมบันทึก Timestamp ล่าสุดไว้ในเครื่อง เพื่อเตรียมส่งข้อมูลเมื่อเชื่อมต่อเน็ตได้

---

### 2. กลไกการซิงค์ข้อมูลอัตโนมัติ (Auto-Synchronization Engine)

- มีตัวตรวจสอบสถานะอินเทอร์เน็ตทำงานอยู่เบื้องหลัง
- เมื่ออุปกรณ์กลับมาเชื่อมต่อเน็ตได้ (Offline ➔ Online)
  1. ดึงข้อมูลที่ยังไม่ได้ซิงค์ (`is_synced = false`) ทั้งหมดจาก Drift ในเครื่อง
  2. รวมข้อมูลแล้วส่งคำขอแบบชุด (Batched Sync) ไปยัง Node.js API
  3. เซิร์ฟเวอร์ตรวจสอบและบันทึกลง Oracle Cloud Database (OCI) โดยใช้หลัก Last-Write-Wins (LWW) เพื่อจัดการกรณีข้อมูลชนกัน
  4. เมื่อเซิร์ฟเวอร์บันทึกสำเร็จ แอปจะปรับสถานะเป็น `is_synced = true` และตั้งเวลาแจ้งเตือนวันหมดอายุรอบใหม่

```mermaid
sequenceDiagram
    autonumber
    actor User as ผู้ใช้งาน
    participant App as แอป Flutter (Riverpod)
    participant LocalDB as Local SQLite (Drift)
    participant NetWatcher as Network Connectivity Watcher
    participant API as Node.js REST API
    participant Oracle as Oracle Cloud Database (OCI)

    User->>App: เพิ่ม / อัปเดตรายการวัตถุดิบ
    App->>LocalDB: บันทึกข้อมูล (is_synced = false, updated_at)
    LocalDB-->>App: ยืนยันการเขียนลงฐานข้อมูลในเครื่อง
    App-->>User: แสดงผลบนหน้าจอทันที (Optimistic UI)

    Note over NetWatcher: อุปกรณ์ตรวจพบการเชื่อมต่ออินเทอร์เน็ต (Reconnection)
    NetWatcher->>App: แจ้งเตือนสถานะออนไลน์ (Online Event)
    App->>LocalDB: สืบหาแถวข้อมูลที่ is_synced = false
    LocalDB-->>App: คืนรายการที่รอการซิงค์
    App->>API: POST /api/inventory/sync (พร้อมแนบ Bearer JWT)
    API->>Oracle: อัปเดต/บันทึกข้อมูล (Last-Write-Wins Resolution)
    Oracle-->>API: ยืนยัน Transaction สำเร็จ
    API-->>App: ส่งผลตอบกลับ 200 OK (Sync Success)
    App->>LocalDB: อัปเดตสถานะเป็น is_synced = true
```

---

### 3. การวิเคราะห์ภาพถ่ายด้วย AI (Gemini Vision Processing)

- ผู้ใช้กด **Scan Label with AI** แล้วถ่ายภาพฉลากอาหาร
- แอปส่งรูปภาพผ่าน API ไปยัง **Google Gemini Vision API**
- ระบบ AI ช่วยอ่านข้อความสำคัญบนฉลาก
  - **ชื่ออาหาร (Food Name)** สกัดชื่อสินค้าหรือชนิดวัตถุดิบ
  - **วันหมดอายุ (Expiration Date)** อ่านวันที่จากข้อความบนฉลาก เช่น EXP, BBD หรือ ควรบริโภคก่อน
- **Auto-fill & Review** นำข้อมูลที่อ่านได้มากรอกลงแบบฟอร์มให้อัตโนมัติ เพื่อให้ผู้ใช้ตรวจทานและแก้ไขก่อนกด **Save**

---

### 4. ความปลอดภัยและการยืนยันตัวตน (Authentication & Security)

- **การเข้าสู่ระบบ 2 รูปแบบ**
  - **Username / Email + Password** สมัครสมาชิกด้วย Username, Email และรหัสผ่านอย่างน้อย 8 ตัวอักษร
  - **Google OAuth 2.0** เข้าสู่ระบบ (Sign in with Google) หรือสมัครสมาชิก (Sign up with Google) ผ่าน Google Sign-In SDK บนมือถือ
- **การรีเซ็ตรหัสผ่าน (Forgot password)** กรอกอีเมลเพื่อรับลิงก์สำหรับตั้งรหัสผ่านใหม่ทางอีเมล
- **การตรวจสอบฝั่งเซิร์ฟเวอร์** กรณีใช้ Google แอปส่ง Google ID Token ไปยัง Node.js API เพื่อตรวจสอบความถูกต้องและจับคู่บัญชีใน Oracle Cloud Database
- **การปกป้อง API ด้วย JWT** เซิร์ฟเวอร์ออก JSON Web Token (JWT) ให้แอปเก็บไว้ใน Secure Storage ของเครื่อง และแนบไปกับ Header `Authorization: Bearer <Token>` ทุกครั้งในการเรียกใช้งาน API

---

## 🛠 เทคโนโลยีที่ใช้ (Tech Stack)

| ส่วนของระบบ | เทคโนโลยีที่เลือกใช้ | บทบาทและหน้าที่การทำงาน |
| :--- | :--- | :--- |
| **Mobile Client** | [Flutter 3.x](https://flutter.dev) | พัฒนาแอปพลิเคชันสำหรับ iOS และ Android |
| **State Management** | [Riverpod](https://riverpod.dev) | จัดการสถานะแอปพลิเคชันแบบ Reactive และแยก Business Logic ออกจาก UI |
| **Local Database** | [Drift](https://drift.simonbinder.eu/) | ฐานข้อมูล SQLite ในเครื่อง รองรับการใช้งานแบบ Offline-First ทำงานร่วมกับ Riverpod แบบ Stream |
| **Backend Framework** | [Node.js](https://nodejs.org) (Express) | REST API สำหรับประมวลผลคำขอ จัดการข้อมูล และเชื่อมต่อฐานข้อมูล |
| **Cloud Database** | [Oracle Cloud Database (OCI)](https://cloud.oracle.com) | ฐานข้อมูล Cloud สำหรับเก็บข้อมูลผู้ใช้ ตู้เย็น สต็อก และข้อมูลการซิงค์ |
| **AI Vision Engine** | [Google Gemini Vision API](https://ai.google.dev) | โมเดล AI อ่านภาพถ่ายฉลาก สกัดชื่ออาหารและวันหมดอายุ |
| **Authentication** | Email/Password, Google OAuth 2.0 & JWT | ระบบยืนยันตัวตน (รองรับทั้งอีเมลและ Google) และรักษาความปลอดภัยในการเรียกใช้ API |

---

## 🧪 การทดสอบและระบบ CI/CD (Testing & Automation)

ทีมงานใช้ **GitHub Actions** ตรวจสอบคุณภาพโค้ดอัตโนมัติก่อนรวมเข้าสู่ Main Branch

```mermaid
flowchart TD
    Push["🚀 Git Push / Pull Request"] --> Runner["🤖 GitHub Actions Runner"]

    subgraph Pipeline ["กระบวนการตรวจสอบคุณภาพซอฟต์แวร์"]
        Step1["1. Static Code Analysis & Linter"]
        Step2["2. Automated Test Matrix<br/>(Unit / Widget / Integration Tests)"]
        Step3{"3. ประเมิน Code Coverage"}

        Step1 --> Step2 --> Step3
    end

    Runner --> Step1

    Step3 -- "Coverage ≥ 70%" --> Passed["✅ ผ่านการทดสอบ (Ready to Merge)"]
    Step3 -- "Coverage < 70%" --> Blocked["❌ ระงับการรวมโค้ด (Blocked)"]

    classDef pass fill:#dcfce7,stroke:#22c55e,stroke-width:2px,color:#166534;
    classDef fail fill:#fee2e2,stroke:#ef4444,stroke-width:2px,color:#991b1b;
    classDef normal fill:#f8fafc,stroke:#64748b,stroke-width:2px,color:#1e293b;

    class Passed pass;
    class Blocked fail;
    class Push,Runner,Step1,Step2 normal;
```

- **Unit Testing** ตรวจสอบ Business Logic การคำนวณวันหมดอายุ และระบบซิงค์ข้อมูล
- **Widget Testing** ทดสอบการแสดงผลของหน้าจอและ UI Component ต่างๆ
- **Integration Testing** ทดสอบการส่งต่อข้อมูลระหว่าง Drift ในมือถือ ผ่าน API ไปยัง Oracle Cloud
- **Quality Gate** กำหนดเกณฑ์ Code Coverage ไม่ต่ำกว่า **70%** จึงจะผ่านการทดสอบและ Merge โค้ดได้

---

## 👥 สมาชิกผู้จัดทำ (Contributors)

โครงงานนี้พัฒนาขึ้นเพื่อการศึกษา รายวิชา **MDSD-2026** โดยทีมนักศึกษา

- **นางสาวอาทิตยา ผิวขำ** (รหัสนักศึกษา 67030260)
- **นายชนินทร์ คำวงศ์ษา** (รหัสนักศึกษา 67030281)
- **นายธนบดี บุญภมร** (รหัสนักศึกษา 67030298)
- **นายธีธัช รัตนโสภา** (รหัสนักศึกษา 67030302)
