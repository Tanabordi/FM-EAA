-- ========================================================
-- FM-EAA Database Initialization Migration (Oracle SQL)
-- Version: 001_init.sql
-- ========================================================

-- 1. Users Table
CREATE TABLE users (
    id VARCHAR2(36) PRIMARY KEY,
    username VARCHAR2(50) NOT NULL UNIQUE,
    email VARCHAR2(255) NOT NULL UNIQUE,
    password_hash VARCHAR2(255),
    google_id VARCHAR2(255) UNIQUE,
    avatar_url VARCHAR2(1000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Fridges Table (Multiple Fridges per User)
CREATE TABLE fridges (
    id VARCHAR2(36) PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    description VARCHAR2(500),
    owner_id VARCHAR2(36) NOT NULL,
    is_synced NUMBER(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fridges_owner FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. Fridge Members Table (Shared Fridge Roles: owner | member)
CREATE TABLE fridge_members (
    fridge_id VARCHAR2(36) NOT NULL,
    user_id VARCHAR2(36) NOT NULL,
    role VARCHAR2(20) DEFAULT 'member' CHECK (role IN ('owner', 'member')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (fridge_id, user_id),
    CONSTRAINT fk_members_fridge FOREIGN KEY (fridge_id) REFERENCES fridges(id) ON DELETE CASCADE,
    CONSTRAINT fk_members_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 4. Fridge Invitations Table (status: pending | accepted | declined)
CREATE TABLE fridge_invites (
    id VARCHAR2(36) PRIMARY KEY,
    fridge_id VARCHAR2(36) NOT NULL,
    from_user_id VARCHAR2(36) NOT NULL,
    to_user_id VARCHAR2(36) NOT NULL,
    status VARCHAR2(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_invites_fridge FOREIGN KEY (fridge_id) REFERENCES fridges(id) ON DELETE CASCADE,
    CONSTRAINT fk_invites_from_user FOREIGN KEY (from_user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_invites_to_user FOREIGN KEY (to_user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 5. Items Table (Inventory Items bound to a specific fridge)
-- Categories: proteins | veggies | beverages | meals | sauces
-- Zones: fridge | freezer
CREATE TABLE items (
    id VARCHAR2(36) PRIMARY KEY,
    fridge_id VARCHAR2(36) NOT NULL,
    name VARCHAR2(200) NOT NULL,
    category VARCHAR2(50) NOT NULL CHECK (category IN ('proteins', 'veggies', 'beverages', 'meals', 'sauces')),
    zone VARCHAR2(20) NOT NULL CHECK (zone IN ('fridge', 'freezer')),
    quantity NUMBER(10, 2) DEFAULT 1 NOT NULL,
    unit VARCHAR2(50) DEFAULT 'pieces' NOT NULL,
    expiry_date DATE NOT NULL,
    image_path VARCHAR2(1000),
    is_synced NUMBER(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_items_fridge FOREIGN KEY (fridge_id) REFERENCES fridges(id) ON DELETE CASCADE
);

-- 6. Item History Table (Audit Log for Consumed & Expired items)
-- Kind: consumed | expired
-- TODO(history cleanup): Setup automated cron/job to delete records with kind = 'consumed' older than 30 days
CREATE TABLE item_history (
    id VARCHAR2(36) PRIMARY KEY,
    fridge_id VARCHAR2(36) NOT NULL,
    item_id VARCHAR2(36),
    item_name VARCHAR2(200) NOT NULL,
    image_path VARCHAR2(1000),
    kind VARCHAR2(20) NOT NULL CHECK (kind IN ('consumed', 'expired')),
    quantity_changed NUMBER(10, 2) NOT NULL,
    quantity_left NUMBER(10, 2) DEFAULT 0 NOT NULL,
    unit VARCHAR2(50) DEFAULT 'pieces' NOT NULL,
    by_user_id VARCHAR2(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_history_fridge FOREIGN KEY (fridge_id) REFERENCES fridges(id) ON DELETE CASCADE,
    CONSTRAINT fk_history_user FOREIGN KEY (by_user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 7. Notifications Table (In-app notifications)
-- Type: invite | expiry
CREATE TABLE notifications (
    id VARCHAR2(36) PRIMARY KEY,
    user_id VARCHAR2(36) NOT NULL,
    type VARCHAR2(30) NOT NULL CHECK (type IN ('invite', 'expiry')),
    payload_json CLOB,
    is_read NUMBER(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Indexes for performance & query optimization
CREATE INDEX idx_items_fridge_expiry ON items(fridge_id, expiry_date);
CREATE INDEX idx_items_fridge_sync ON items(fridge_id, is_synced);
CREATE INDEX idx_history_fridge_created ON item_history(fridge_id, created_at);
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read);

