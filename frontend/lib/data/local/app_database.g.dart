// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
mixin _$FridgeDaoMixin on DatabaseAccessor<AppDatabase> {
  $FridgesTableTable get fridgesTable => attachedDatabase.fridgesTable;
  $FridgeMembersTable get fridgeMembers => attachedDatabase.fridgeMembers;
  FridgeDaoManager get managers => FridgeDaoManager(this);
}

class FridgeDaoManager {
  final _$FridgeDaoMixin _db;
  FridgeDaoManager(this._db);
  $$FridgesTableTableTableManager get fridgesTable =>
      $$FridgesTableTableTableManager(_db.attachedDatabase, _db.fridgesTable);
  $$FridgeMembersTableTableManager get fridgeMembers =>
      $$FridgeMembersTableTableManager(_db.attachedDatabase, _db.fridgeMembers);
}

mixin _$ItemDaoMixin on DatabaseAccessor<AppDatabase> {
  $ItemsTableTable get itemsTable => attachedDatabase.itemsTable;
  $ItemHistoryTable get itemHistory => attachedDatabase.itemHistory;
  ItemDaoManager get managers => ItemDaoManager(this);
}

class ItemDaoManager {
  final _$ItemDaoMixin _db;
  ItemDaoManager(this._db);
  $$ItemsTableTableTableManager get itemsTable =>
      $$ItemsTableTableTableManager(_db.attachedDatabase, _db.itemsTable);
  $$ItemHistoryTableTableManager get itemHistory =>
      $$ItemHistoryTableTableManager(_db.attachedDatabase, _db.itemHistory);
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _passwordHashMeta =
      const VerificationMeta('passwordHash');
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
      'password_hash', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _googleIdMeta =
      const VerificationMeta('googleId');
  @override
  late final GeneratedColumn<String> googleId = GeneratedColumn<String>(
      'google_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        username,
        email,
        passwordHash,
        googleId,
        avatarUrl,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
          _passwordHashMeta,
          passwordHash.isAcceptableOrUnknown(
              data['password_hash']!, _passwordHashMeta));
    }
    if (data.containsKey('google_id')) {
      context.handle(_googleIdMeta,
          googleId.isAcceptableOrUnknown(data['google_id']!, _googleIdMeta));
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      passwordHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password_hash']),
      googleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}google_id']),
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String username;
  final String email;
  final String? passwordHash;
  final String? googleId;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  const User(
      {required this.id,
      required this.username,
      required this.email,
      this.passwordHash,
      this.googleId,
      this.avatarUrl,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['username'] = Variable<String>(username);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || passwordHash != null) {
      map['password_hash'] = Variable<String>(passwordHash);
    }
    if (!nullToAbsent || googleId != null) {
      map['google_id'] = Variable<String>(googleId);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      email: Value(email),
      passwordHash: passwordHash == null && nullToAbsent
          ? const Value.absent()
          : Value(passwordHash),
      googleId: googleId == null && nullToAbsent
          ? const Value.absent()
          : Value(googleId),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      email: serializer.fromJson<String>(json['email']),
      passwordHash: serializer.fromJson<String?>(json['passwordHash']),
      googleId: serializer.fromJson<String?>(json['googleId']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'username': serializer.toJson<String>(username),
      'email': serializer.toJson<String>(email),
      'passwordHash': serializer.toJson<String?>(passwordHash),
      'googleId': serializer.toJson<String?>(googleId),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  User copyWith(
          {String? id,
          String? username,
          String? email,
          Value<String?> passwordHash = const Value.absent(),
          Value<String?> googleId = const Value.absent(),
          Value<String?> avatarUrl = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      User(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        passwordHash:
            passwordHash.present ? passwordHash.value : this.passwordHash,
        googleId: googleId.present ? googleId.value : this.googleId,
        avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      email: data.email.present ? data.email.value : this.email,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      googleId: data.googleId.present ? data.googleId.value : this.googleId,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('googleId: $googleId, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, username, email, passwordHash, googleId,
      avatarUrl, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.username == this.username &&
          other.email == this.email &&
          other.passwordHash == this.passwordHash &&
          other.googleId == this.googleId &&
          other.avatarUrl == this.avatarUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> username;
  final Value<String> email;
  final Value<String?> passwordHash;
  final Value<String?> googleId;
  final Value<String?> avatarUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.email = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.googleId = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String username,
    required String email,
    this.passwordHash = const Value.absent(),
    this.googleId = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        username = Value(username),
        email = Value(email);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? username,
    Expression<String>? email,
    Expression<String>? passwordHash,
    Expression<String>? googleId,
    Expression<String>? avatarUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (googleId != null) 'google_id': googleId,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? username,
      Value<String>? email,
      Value<String?>? passwordHash,
      Value<String?>? googleId,
      Value<String?>? avatarUrl,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      googleId: googleId ?? this.googleId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (googleId.present) {
      map['google_id'] = Variable<String>(googleId.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('googleId: $googleId, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FridgesTableTable extends FridgesTable
    with TableInfo<$FridgesTableTable, FridgeEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FridgesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, ownerId, isSynced, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fridges';
  @override
  VerificationContext validateIntegrity(Insertable<FridgeEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FridgeEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FridgeEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FridgesTableTable createAlias(String alias) {
    return $FridgesTableTable(attachedDatabase, alias);
  }
}

class FridgeEntry extends DataClass implements Insertable<FridgeEntry> {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FridgeEntry(
      {required this.id,
      required this.name,
      this.description,
      required this.ownerId,
      required this.isSynced,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['owner_id'] = Variable<String>(ownerId);
    map['is_synced'] = Variable<bool>(isSynced);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FridgesTableCompanion toCompanion(bool nullToAbsent) {
    return FridgesTableCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      ownerId: Value(ownerId),
      isSynced: Value(isSynced),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FridgeEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FridgeEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'ownerId': serializer.toJson<String>(ownerId),
      'isSynced': serializer.toJson<bool>(isSynced),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FridgeEntry copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? ownerId,
          bool? isSynced,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      FridgeEntry(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        ownerId: ownerId ?? this.ownerId,
        isSynced: isSynced ?? this.isSynced,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FridgeEntry copyWithCompanion(FridgesTableCompanion data) {
    return FridgeEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FridgeEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('ownerId: $ownerId, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, description, ownerId, isSynced, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FridgeEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.ownerId == this.ownerId &&
          other.isSynced == this.isSynced &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FridgesTableCompanion extends UpdateCompanion<FridgeEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> ownerId;
  final Value<bool> isSynced;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FridgesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FridgesTableCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String ownerId,
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        ownerId = Value(ownerId);
  static Insertable<FridgeEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? ownerId,
    Expression<bool>? isSynced,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (ownerId != null) 'owner_id': ownerId,
      if (isSynced != null) 'is_synced': isSynced,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FridgesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? ownerId,
      Value<bool>? isSynced,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return FridgesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FridgesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('ownerId: $ownerId, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FridgeMembersTable extends FridgeMembers
    with TableInfo<$FridgeMembersTable, FridgeMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FridgeMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fridgeIdMeta =
      const VerificationMeta('fridgeId');
  @override
  late final GeneratedColumn<String> fridgeId = GeneratedColumn<String>(
      'fridge_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('member'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [fridgeId, userId, role, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fridge_members';
  @override
  VerificationContext validateIntegrity(Insertable<FridgeMember> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('fridge_id')) {
      context.handle(_fridgeIdMeta,
          fridgeId.isAcceptableOrUnknown(data['fridge_id']!, _fridgeIdMeta));
    } else if (isInserting) {
      context.missing(_fridgeIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fridgeId, userId};
  @override
  FridgeMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FridgeMember(
      fridgeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fridge_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FridgeMembersTable createAlias(String alias) {
    return $FridgeMembersTable(attachedDatabase, alias);
  }
}

class FridgeMember extends DataClass implements Insertable<FridgeMember> {
  final String fridgeId;
  final String userId;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FridgeMember(
      {required this.fridgeId,
      required this.userId,
      required this.role,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['fridge_id'] = Variable<String>(fridgeId);
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<String>(role);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FridgeMembersCompanion toCompanion(bool nullToAbsent) {
    return FridgeMembersCompanion(
      fridgeId: Value(fridgeId),
      userId: Value(userId),
      role: Value(role),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FridgeMember.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FridgeMember(
      fridgeId: serializer.fromJson<String>(json['fridgeId']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fridgeId': serializer.toJson<String>(fridgeId),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>(role),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FridgeMember copyWith(
          {String? fridgeId,
          String? userId,
          String? role,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      FridgeMember(
        fridgeId: fridgeId ?? this.fridgeId,
        userId: userId ?? this.userId,
        role: role ?? this.role,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FridgeMember copyWithCompanion(FridgeMembersCompanion data) {
    return FridgeMember(
      fridgeId: data.fridgeId.present ? data.fridgeId.value : this.fridgeId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FridgeMember(')
          ..write('fridgeId: $fridgeId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(fridgeId, userId, role, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FridgeMember &&
          other.fridgeId == this.fridgeId &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FridgeMembersCompanion extends UpdateCompanion<FridgeMember> {
  final Value<String> fridgeId;
  final Value<String> userId;
  final Value<String> role;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FridgeMembersCompanion({
    this.fridgeId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FridgeMembersCompanion.insert({
    required String fridgeId,
    required String userId,
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : fridgeId = Value(fridgeId),
        userId = Value(userId);
  static Insertable<FridgeMember> custom({
    Expression<String>? fridgeId,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fridgeId != null) 'fridge_id': fridgeId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FridgeMembersCompanion copyWith(
      {Value<String>? fridgeId,
      Value<String>? userId,
      Value<String>? role,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return FridgeMembersCompanion(
      fridgeId: fridgeId ?? this.fridgeId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fridgeId.present) {
      map['fridge_id'] = Variable<String>(fridgeId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FridgeMembersCompanion(')
          ..write('fridgeId: $fridgeId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FridgeInvitesTable extends FridgeInvites
    with TableInfo<$FridgeInvitesTable, FridgeInvite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FridgeInvitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fridgeIdMeta =
      const VerificationMeta('fridgeId');
  @override
  late final GeneratedColumn<String> fridgeId = GeneratedColumn<String>(
      'fridge_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fromUserIdMeta =
      const VerificationMeta('fromUserId');
  @override
  late final GeneratedColumn<String> fromUserId = GeneratedColumn<String>(
      'from_user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _toUserIdMeta =
      const VerificationMeta('toUserId');
  @override
  late final GeneratedColumn<String> toUserId = GeneratedColumn<String>(
      'to_user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, fridgeId, fromUserId, toUserId, status, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fridge_invites';
  @override
  VerificationContext validateIntegrity(Insertable<FridgeInvite> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('fridge_id')) {
      context.handle(_fridgeIdMeta,
          fridgeId.isAcceptableOrUnknown(data['fridge_id']!, _fridgeIdMeta));
    } else if (isInserting) {
      context.missing(_fridgeIdMeta);
    }
    if (data.containsKey('from_user_id')) {
      context.handle(
          _fromUserIdMeta,
          fromUserId.isAcceptableOrUnknown(
              data['from_user_id']!, _fromUserIdMeta));
    } else if (isInserting) {
      context.missing(_fromUserIdMeta);
    }
    if (data.containsKey('to_user_id')) {
      context.handle(_toUserIdMeta,
          toUserId.isAcceptableOrUnknown(data['to_user_id']!, _toUserIdMeta));
    } else if (isInserting) {
      context.missing(_toUserIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FridgeInvite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FridgeInvite(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fridgeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fridge_id'])!,
      fromUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_user_id'])!,
      toUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_user_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FridgeInvitesTable createAlias(String alias) {
    return $FridgeInvitesTable(attachedDatabase, alias);
  }
}

class FridgeInvite extends DataClass implements Insertable<FridgeInvite> {
  final String id;
  final String fridgeId;
  final String fromUserId;
  final String toUserId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FridgeInvite(
      {required this.id,
      required this.fridgeId,
      required this.fromUserId,
      required this.toUserId,
      required this.status,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['fridge_id'] = Variable<String>(fridgeId);
    map['from_user_id'] = Variable<String>(fromUserId);
    map['to_user_id'] = Variable<String>(toUserId);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FridgeInvitesCompanion toCompanion(bool nullToAbsent) {
    return FridgeInvitesCompanion(
      id: Value(id),
      fridgeId: Value(fridgeId),
      fromUserId: Value(fromUserId),
      toUserId: Value(toUserId),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FridgeInvite.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FridgeInvite(
      id: serializer.fromJson<String>(json['id']),
      fridgeId: serializer.fromJson<String>(json['fridgeId']),
      fromUserId: serializer.fromJson<String>(json['fromUserId']),
      toUserId: serializer.fromJson<String>(json['toUserId']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fridgeId': serializer.toJson<String>(fridgeId),
      'fromUserId': serializer.toJson<String>(fromUserId),
      'toUserId': serializer.toJson<String>(toUserId),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FridgeInvite copyWith(
          {String? id,
          String? fridgeId,
          String? fromUserId,
          String? toUserId,
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      FridgeInvite(
        id: id ?? this.id,
        fridgeId: fridgeId ?? this.fridgeId,
        fromUserId: fromUserId ?? this.fromUserId,
        toUserId: toUserId ?? this.toUserId,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FridgeInvite copyWithCompanion(FridgeInvitesCompanion data) {
    return FridgeInvite(
      id: data.id.present ? data.id.value : this.id,
      fridgeId: data.fridgeId.present ? data.fridgeId.value : this.fridgeId,
      fromUserId:
          data.fromUserId.present ? data.fromUserId.value : this.fromUserId,
      toUserId: data.toUserId.present ? data.toUserId.value : this.toUserId,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FridgeInvite(')
          ..write('id: $id, ')
          ..write('fridgeId: $fridgeId, ')
          ..write('fromUserId: $fromUserId, ')
          ..write('toUserId: $toUserId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, fridgeId, fromUserId, toUserId, status, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FridgeInvite &&
          other.id == this.id &&
          other.fridgeId == this.fridgeId &&
          other.fromUserId == this.fromUserId &&
          other.toUserId == this.toUserId &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FridgeInvitesCompanion extends UpdateCompanion<FridgeInvite> {
  final Value<String> id;
  final Value<String> fridgeId;
  final Value<String> fromUserId;
  final Value<String> toUserId;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FridgeInvitesCompanion({
    this.id = const Value.absent(),
    this.fridgeId = const Value.absent(),
    this.fromUserId = const Value.absent(),
    this.toUserId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FridgeInvitesCompanion.insert({
    required String id,
    required String fridgeId,
    required String fromUserId,
    required String toUserId,
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fridgeId = Value(fridgeId),
        fromUserId = Value(fromUserId),
        toUserId = Value(toUserId);
  static Insertable<FridgeInvite> custom({
    Expression<String>? id,
    Expression<String>? fridgeId,
    Expression<String>? fromUserId,
    Expression<String>? toUserId,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fridgeId != null) 'fridge_id': fridgeId,
      if (fromUserId != null) 'from_user_id': fromUserId,
      if (toUserId != null) 'to_user_id': toUserId,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FridgeInvitesCompanion copyWith(
      {Value<String>? id,
      Value<String>? fridgeId,
      Value<String>? fromUserId,
      Value<String>? toUserId,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return FridgeInvitesCompanion(
      id: id ?? this.id,
      fridgeId: fridgeId ?? this.fridgeId,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fridgeId.present) {
      map['fridge_id'] = Variable<String>(fridgeId.value);
    }
    if (fromUserId.present) {
      map['from_user_id'] = Variable<String>(fromUserId.value);
    }
    if (toUserId.present) {
      map['to_user_id'] = Variable<String>(toUserId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FridgeInvitesCompanion(')
          ..write('id: $id, ')
          ..write('fridgeId: $fridgeId, ')
          ..write('fromUserId: $fromUserId, ')
          ..write('toUserId: $toUserId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemsTableTable extends ItemsTable
    with TableInfo<$ItemsTableTable, ItemEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fridgeIdMeta =
      const VerificationMeta('fridgeId');
  @override
  late final GeneratedColumn<String> fridgeId = GeneratedColumn<String>(
      'fridge_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _zoneMeta = const VerificationMeta('zone');
  @override
  late final GeneratedColumn<String> zone = GeneratedColumn<String>(
      'zone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pieces'));
  static const VerificationMeta _expiryDateMeta =
      const VerificationMeta('expiryDate');
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
      'expiry_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        fridgeId,
        name,
        category,
        zone,
        quantity,
        unit,
        expiryDate,
        imagePath,
        isSynced,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(Insertable<ItemEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('fridge_id')) {
      context.handle(_fridgeIdMeta,
          fridgeId.isAcceptableOrUnknown(data['fridge_id']!, _fridgeIdMeta));
    } else if (isInserting) {
      context.missing(_fridgeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('zone')) {
      context.handle(
          _zoneMeta, zone.isAcceptableOrUnknown(data['zone']!, _zoneMeta));
    } else if (isInserting) {
      context.missing(_zoneMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
          _expiryDateMeta,
          expiryDate.isAcceptableOrUnknown(
              data['expiry_date']!, _expiryDateMeta));
    } else if (isInserting) {
      context.missing(_expiryDateMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fridgeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fridge_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      zone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}zone'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      expiryDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expiry_date'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ItemsTableTable createAlias(String alias) {
    return $ItemsTableTable(attachedDatabase, alias);
  }
}

class ItemEntry extends DataClass implements Insertable<ItemEntry> {
  final String id;
  final String fridgeId;
  final String name;
  final String category;
  final String zone;
  final double quantity;
  final String unit;
  final DateTime expiryDate;
  final String? imagePath;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ItemEntry(
      {required this.id,
      required this.fridgeId,
      required this.name,
      required this.category,
      required this.zone,
      required this.quantity,
      required this.unit,
      required this.expiryDate,
      this.imagePath,
      required this.isSynced,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['fridge_id'] = Variable<String>(fridgeId);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['zone'] = Variable<String>(zone);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    map['expiry_date'] = Variable<DateTime>(expiryDate);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ItemsTableCompanion toCompanion(bool nullToAbsent) {
    return ItemsTableCompanion(
      id: Value(id),
      fridgeId: Value(fridgeId),
      name: Value(name),
      category: Value(category),
      zone: Value(zone),
      quantity: Value(quantity),
      unit: Value(unit),
      expiryDate: Value(expiryDate),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      isSynced: Value(isSynced),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ItemEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemEntry(
      id: serializer.fromJson<String>(json['id']),
      fridgeId: serializer.fromJson<String>(json['fridgeId']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      zone: serializer.fromJson<String>(json['zone']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      expiryDate: serializer.fromJson<DateTime>(json['expiryDate']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fridgeId': serializer.toJson<String>(fridgeId),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'zone': serializer.toJson<String>(zone),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'expiryDate': serializer.toJson<DateTime>(expiryDate),
      'imagePath': serializer.toJson<String?>(imagePath),
      'isSynced': serializer.toJson<bool>(isSynced),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ItemEntry copyWith(
          {String? id,
          String? fridgeId,
          String? name,
          String? category,
          String? zone,
          double? quantity,
          String? unit,
          DateTime? expiryDate,
          Value<String?> imagePath = const Value.absent(),
          bool? isSynced,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ItemEntry(
        id: id ?? this.id,
        fridgeId: fridgeId ?? this.fridgeId,
        name: name ?? this.name,
        category: category ?? this.category,
        zone: zone ?? this.zone,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        expiryDate: expiryDate ?? this.expiryDate,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        isSynced: isSynced ?? this.isSynced,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ItemEntry copyWithCompanion(ItemsTableCompanion data) {
    return ItemEntry(
      id: data.id.present ? data.id.value : this.id,
      fridgeId: data.fridgeId.present ? data.fridgeId.value : this.fridgeId,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      zone: data.zone.present ? data.zone.value : this.zone,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      expiryDate:
          data.expiryDate.present ? data.expiryDate.value : this.expiryDate,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemEntry(')
          ..write('id: $id, ')
          ..write('fridgeId: $fridgeId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('zone: $zone, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('imagePath: $imagePath, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fridgeId, name, category, zone, quantity,
      unit, expiryDate, imagePath, isSynced, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemEntry &&
          other.id == this.id &&
          other.fridgeId == this.fridgeId &&
          other.name == this.name &&
          other.category == this.category &&
          other.zone == this.zone &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.expiryDate == this.expiryDate &&
          other.imagePath == this.imagePath &&
          other.isSynced == this.isSynced &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ItemsTableCompanion extends UpdateCompanion<ItemEntry> {
  final Value<String> id;
  final Value<String> fridgeId;
  final Value<String> name;
  final Value<String> category;
  final Value<String> zone;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<DateTime> expiryDate;
  final Value<String?> imagePath;
  final Value<bool> isSynced;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ItemsTableCompanion({
    this.id = const Value.absent(),
    this.fridgeId = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.zone = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsTableCompanion.insert({
    required String id,
    required String fridgeId,
    required String name,
    required String category,
    required String zone,
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    required DateTime expiryDate,
    this.imagePath = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fridgeId = Value(fridgeId),
        name = Value(name),
        category = Value(category),
        zone = Value(zone),
        expiryDate = Value(expiryDate);
  static Insertable<ItemEntry> custom({
    Expression<String>? id,
    Expression<String>? fridgeId,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? zone,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<DateTime>? expiryDate,
    Expression<String>? imagePath,
    Expression<bool>? isSynced,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fridgeId != null) 'fridge_id': fridgeId,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (zone != null) 'zone': zone,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (imagePath != null) 'image_path': imagePath,
      if (isSynced != null) 'is_synced': isSynced,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? fridgeId,
      Value<String>? name,
      Value<String>? category,
      Value<String>? zone,
      Value<double>? quantity,
      Value<String>? unit,
      Value<DateTime>? expiryDate,
      Value<String?>? imagePath,
      Value<bool>? isSynced,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ItemsTableCompanion(
      id: id ?? this.id,
      fridgeId: fridgeId ?? this.fridgeId,
      name: name ?? this.name,
      category: category ?? this.category,
      zone: zone ?? this.zone,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      imagePath: imagePath ?? this.imagePath,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fridgeId.present) {
      map['fridge_id'] = Variable<String>(fridgeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (zone.present) {
      map['zone'] = Variable<String>(zone.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('fridgeId: $fridgeId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('zone: $zone, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('imagePath: $imagePath, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemHistoryTable extends ItemHistory
    with TableInfo<$ItemHistoryTable, ItemHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fridgeIdMeta =
      const VerificationMeta('fridgeId');
  @override
  late final GeneratedColumn<String> fridgeId = GeneratedColumn<String>(
      'fridge_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _itemNameMeta =
      const VerificationMeta('itemName');
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
      'item_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityChangedMeta =
      const VerificationMeta('quantityChanged');
  @override
  late final GeneratedColumn<double> quantityChanged = GeneratedColumn<double>(
      'quantity_changed', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _quantityLeftMeta =
      const VerificationMeta('quantityLeft');
  @override
  late final GeneratedColumn<double> quantityLeft = GeneratedColumn<double>(
      'quantity_left', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pieces'));
  static const VerificationMeta _byUserIdMeta =
      const VerificationMeta('byUserId');
  @override
  late final GeneratedColumn<String> byUserId = GeneratedColumn<String>(
      'by_user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        fridgeId,
        itemId,
        itemName,
        imagePath,
        kind,
        quantityChanged,
        quantityLeft,
        unit,
        byUserId,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_history';
  @override
  VerificationContext validateIntegrity(Insertable<ItemHistoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('fridge_id')) {
      context.handle(_fridgeIdMeta,
          fridgeId.isAcceptableOrUnknown(data['fridge_id']!, _fridgeIdMeta));
    } else if (isInserting) {
      context.missing(_fridgeIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    }
    if (data.containsKey('item_name')) {
      context.handle(_itemNameMeta,
          itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta));
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('quantity_changed')) {
      context.handle(
          _quantityChangedMeta,
          quantityChanged.isAcceptableOrUnknown(
              data['quantity_changed']!, _quantityChangedMeta));
    } else if (isInserting) {
      context.missing(_quantityChangedMeta);
    }
    if (data.containsKey('quantity_left')) {
      context.handle(
          _quantityLeftMeta,
          quantityLeft.isAcceptableOrUnknown(
              data['quantity_left']!, _quantityLeftMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('by_user_id')) {
      context.handle(_byUserIdMeta,
          byUserId.isAcceptableOrUnknown(data['by_user_id']!, _byUserIdMeta));
    } else if (isInserting) {
      context.missing(_byUserIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemHistoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fridgeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fridge_id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id']),
      itemName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_name'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      quantityChanged: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}quantity_changed'])!,
      quantityLeft: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity_left'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      byUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}by_user_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ItemHistoryTable createAlias(String alias) {
    return $ItemHistoryTable(attachedDatabase, alias);
  }
}

class ItemHistoryData extends DataClass implements Insertable<ItemHistoryData> {
  final String id;
  final String fridgeId;
  final String? itemId;
  final String itemName;
  final String? imagePath;
  final String kind;
  final double quantityChanged;
  final double quantityLeft;
  final String unit;
  final String byUserId;
  final DateTime createdAt;
  const ItemHistoryData(
      {required this.id,
      required this.fridgeId,
      this.itemId,
      required this.itemName,
      this.imagePath,
      required this.kind,
      required this.quantityChanged,
      required this.quantityLeft,
      required this.unit,
      required this.byUserId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['fridge_id'] = Variable<String>(fridgeId);
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<String>(itemId);
    }
    map['item_name'] = Variable<String>(itemName);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['kind'] = Variable<String>(kind);
    map['quantity_changed'] = Variable<double>(quantityChanged);
    map['quantity_left'] = Variable<double>(quantityLeft);
    map['unit'] = Variable<String>(unit);
    map['by_user_id'] = Variable<String>(byUserId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ItemHistoryCompanion toCompanion(bool nullToAbsent) {
    return ItemHistoryCompanion(
      id: Value(id),
      fridgeId: Value(fridgeId),
      itemId:
          itemId == null && nullToAbsent ? const Value.absent() : Value(itemId),
      itemName: Value(itemName),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      kind: Value(kind),
      quantityChanged: Value(quantityChanged),
      quantityLeft: Value(quantityLeft),
      unit: Value(unit),
      byUserId: Value(byUserId),
      createdAt: Value(createdAt),
    );
  }

  factory ItemHistoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemHistoryData(
      id: serializer.fromJson<String>(json['id']),
      fridgeId: serializer.fromJson<String>(json['fridgeId']),
      itemId: serializer.fromJson<String?>(json['itemId']),
      itemName: serializer.fromJson<String>(json['itemName']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      kind: serializer.fromJson<String>(json['kind']),
      quantityChanged: serializer.fromJson<double>(json['quantityChanged']),
      quantityLeft: serializer.fromJson<double>(json['quantityLeft']),
      unit: serializer.fromJson<String>(json['unit']),
      byUserId: serializer.fromJson<String>(json['byUserId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fridgeId': serializer.toJson<String>(fridgeId),
      'itemId': serializer.toJson<String?>(itemId),
      'itemName': serializer.toJson<String>(itemName),
      'imagePath': serializer.toJson<String?>(imagePath),
      'kind': serializer.toJson<String>(kind),
      'quantityChanged': serializer.toJson<double>(quantityChanged),
      'quantityLeft': serializer.toJson<double>(quantityLeft),
      'unit': serializer.toJson<String>(unit),
      'byUserId': serializer.toJson<String>(byUserId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ItemHistoryData copyWith(
          {String? id,
          String? fridgeId,
          Value<String?> itemId = const Value.absent(),
          String? itemName,
          Value<String?> imagePath = const Value.absent(),
          String? kind,
          double? quantityChanged,
          double? quantityLeft,
          String? unit,
          String? byUserId,
          DateTime? createdAt}) =>
      ItemHistoryData(
        id: id ?? this.id,
        fridgeId: fridgeId ?? this.fridgeId,
        itemId: itemId.present ? itemId.value : this.itemId,
        itemName: itemName ?? this.itemName,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        kind: kind ?? this.kind,
        quantityChanged: quantityChanged ?? this.quantityChanged,
        quantityLeft: quantityLeft ?? this.quantityLeft,
        unit: unit ?? this.unit,
        byUserId: byUserId ?? this.byUserId,
        createdAt: createdAt ?? this.createdAt,
      );
  ItemHistoryData copyWithCompanion(ItemHistoryCompanion data) {
    return ItemHistoryData(
      id: data.id.present ? data.id.value : this.id,
      fridgeId: data.fridgeId.present ? data.fridgeId.value : this.fridgeId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      kind: data.kind.present ? data.kind.value : this.kind,
      quantityChanged: data.quantityChanged.present
          ? data.quantityChanged.value
          : this.quantityChanged,
      quantityLeft: data.quantityLeft.present
          ? data.quantityLeft.value
          : this.quantityLeft,
      unit: data.unit.present ? data.unit.value : this.unit,
      byUserId: data.byUserId.present ? data.byUserId.value : this.byUserId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemHistoryData(')
          ..write('id: $id, ')
          ..write('fridgeId: $fridgeId, ')
          ..write('itemId: $itemId, ')
          ..write('itemName: $itemName, ')
          ..write('imagePath: $imagePath, ')
          ..write('kind: $kind, ')
          ..write('quantityChanged: $quantityChanged, ')
          ..write('quantityLeft: $quantityLeft, ')
          ..write('unit: $unit, ')
          ..write('byUserId: $byUserId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fridgeId, itemId, itemName, imagePath,
      kind, quantityChanged, quantityLeft, unit, byUserId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemHistoryData &&
          other.id == this.id &&
          other.fridgeId == this.fridgeId &&
          other.itemId == this.itemId &&
          other.itemName == this.itemName &&
          other.imagePath == this.imagePath &&
          other.kind == this.kind &&
          other.quantityChanged == this.quantityChanged &&
          other.quantityLeft == this.quantityLeft &&
          other.unit == this.unit &&
          other.byUserId == this.byUserId &&
          other.createdAt == this.createdAt);
}

class ItemHistoryCompanion extends UpdateCompanion<ItemHistoryData> {
  final Value<String> id;
  final Value<String> fridgeId;
  final Value<String?> itemId;
  final Value<String> itemName;
  final Value<String?> imagePath;
  final Value<String> kind;
  final Value<double> quantityChanged;
  final Value<double> quantityLeft;
  final Value<String> unit;
  final Value<String> byUserId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ItemHistoryCompanion({
    this.id = const Value.absent(),
    this.fridgeId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.itemName = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.kind = const Value.absent(),
    this.quantityChanged = const Value.absent(),
    this.quantityLeft = const Value.absent(),
    this.unit = const Value.absent(),
    this.byUserId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemHistoryCompanion.insert({
    required String id,
    required String fridgeId,
    this.itemId = const Value.absent(),
    required String itemName,
    this.imagePath = const Value.absent(),
    required String kind,
    required double quantityChanged,
    this.quantityLeft = const Value.absent(),
    this.unit = const Value.absent(),
    required String byUserId,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fridgeId = Value(fridgeId),
        itemName = Value(itemName),
        kind = Value(kind),
        quantityChanged = Value(quantityChanged),
        byUserId = Value(byUserId);
  static Insertable<ItemHistoryData> custom({
    Expression<String>? id,
    Expression<String>? fridgeId,
    Expression<String>? itemId,
    Expression<String>? itemName,
    Expression<String>? imagePath,
    Expression<String>? kind,
    Expression<double>? quantityChanged,
    Expression<double>? quantityLeft,
    Expression<String>? unit,
    Expression<String>? byUserId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fridgeId != null) 'fridge_id': fridgeId,
      if (itemId != null) 'item_id': itemId,
      if (itemName != null) 'item_name': itemName,
      if (imagePath != null) 'image_path': imagePath,
      if (kind != null) 'kind': kind,
      if (quantityChanged != null) 'quantity_changed': quantityChanged,
      if (quantityLeft != null) 'quantity_left': quantityLeft,
      if (unit != null) 'unit': unit,
      if (byUserId != null) 'by_user_id': byUserId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemHistoryCompanion copyWith(
      {Value<String>? id,
      Value<String>? fridgeId,
      Value<String?>? itemId,
      Value<String>? itemName,
      Value<String?>? imagePath,
      Value<String>? kind,
      Value<double>? quantityChanged,
      Value<double>? quantityLeft,
      Value<String>? unit,
      Value<String>? byUserId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ItemHistoryCompanion(
      id: id ?? this.id,
      fridgeId: fridgeId ?? this.fridgeId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      imagePath: imagePath ?? this.imagePath,
      kind: kind ?? this.kind,
      quantityChanged: quantityChanged ?? this.quantityChanged,
      quantityLeft: quantityLeft ?? this.quantityLeft,
      unit: unit ?? this.unit,
      byUserId: byUserId ?? this.byUserId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fridgeId.present) {
      map['fridge_id'] = Variable<String>(fridgeId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (quantityChanged.present) {
      map['quantity_changed'] = Variable<double>(quantityChanged.value);
    }
    if (quantityLeft.present) {
      map['quantity_left'] = Variable<double>(quantityLeft.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (byUserId.present) {
      map['by_user_id'] = Variable<String>(byUserId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemHistoryCompanion(')
          ..write('id: $id, ')
          ..write('fridgeId: $fridgeId, ')
          ..write('itemId: $itemId, ')
          ..write('itemName: $itemName, ')
          ..write('imagePath: $imagePath, ')
          ..write('kind: $kind, ')
          ..write('quantityChanged: $quantityChanged, ')
          ..write('quantityLeft: $quantityLeft, ')
          ..write('unit: $unit, ')
          ..write('byUserId: $byUserId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTable extends Notifications
    with TableInfo<$NotificationsTable, Notification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, type, payloadJson, isRead, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(Insertable<Notification> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Notification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notification(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json']),
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $NotificationsTable createAlias(String alias) {
    return $NotificationsTable(attachedDatabase, alias);
  }
}

class Notification extends DataClass implements Insertable<Notification> {
  final String id;
  final String userId;
  final String type;
  final String? payloadJson;
  final bool isRead;
  final DateTime createdAt;
  const Notification(
      {required this.id,
      required this.userId,
      required this.type,
      this.payloadJson,
      required this.isRead,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || payloadJson != null) {
      map['payload_json'] = Variable<String>(payloadJson);
    }
    map['is_read'] = Variable<bool>(isRead);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotificationsCompanion toCompanion(bool nullToAbsent) {
    return NotificationsCompanion(
      id: Value(id),
      userId: Value(userId),
      type: Value(type),
      payloadJson: payloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJson),
      isRead: Value(isRead),
      createdAt: Value(createdAt),
    );
  }

  factory Notification.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Notification(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      payloadJson: serializer.fromJson<String?>(json['payloadJson']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'type': serializer.toJson<String>(type),
      'payloadJson': serializer.toJson<String?>(payloadJson),
      'isRead': serializer.toJson<bool>(isRead),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Notification copyWith(
          {String? id,
          String? userId,
          String? type,
          Value<String?> payloadJson = const Value.absent(),
          bool? isRead,
          DateTime? createdAt}) =>
      Notification(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        type: type ?? this.type,
        payloadJson: payloadJson.present ? payloadJson.value : this.payloadJson,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt ?? this.createdAt,
      );
  Notification copyWithCompanion(NotificationsCompanion data) {
    return Notification(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notification(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('isRead: $isRead, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, type, payloadJson, isRead, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notification &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.payloadJson == this.payloadJson &&
          other.isRead == this.isRead &&
          other.createdAt == this.createdAt);
}

class NotificationsCompanion extends UpdateCompanion<Notification> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> type;
  final Value<String?> payloadJson;
  final Value<bool> isRead;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const NotificationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.isRead = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationsCompanion.insert({
    required String id,
    required String userId,
    required String type,
    this.payloadJson = const Value.absent(),
    this.isRead = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        type = Value(type);
  static Insertable<Notification> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? type,
    Expression<String>? payloadJson,
    Expression<bool>? isRead,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (isRead != null) 'is_read': isRead,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? type,
      Value<String?>? payloadJson,
      Value<bool>? isRead,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return NotificationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      payloadJson: payloadJson ?? this.payloadJson,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('isRead: $isRead, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $FridgesTableTable fridgesTable = $FridgesTableTable(this);
  late final $FridgeMembersTable fridgeMembers = $FridgeMembersTable(this);
  late final $FridgeInvitesTable fridgeInvites = $FridgeInvitesTable(this);
  late final $ItemsTableTable itemsTable = $ItemsTableTable(this);
  late final $ItemHistoryTable itemHistory = $ItemHistoryTable(this);
  late final $NotificationsTable notifications = $NotificationsTable(this);
  late final FridgeDao fridgeDao = FridgeDao(this as AppDatabase);
  late final ItemDao itemDao = ItemDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        users,
        fridgesTable,
        fridgeMembers,
        fridgeInvites,
        itemsTable,
        itemHistory,
        notifications
      ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String username,
  required String email,
  Value<String?> passwordHash,
  Value<String?> googleId,
  Value<String?> avatarUrl,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> username,
  Value<String> email,
  Value<String?> passwordHash,
  Value<String?> googleId,
  Value<String?> avatarUrl,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get googleId => $composableBuilder(
      column: $table.googleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get googleId => $composableBuilder(
      column: $table.googleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => column);

  GeneratedColumn<String> get googleId =>
      $composableBuilder(column: $table.googleId, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String?> passwordHash = const Value.absent(),
            Value<String?> googleId = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            username: username,
            email: email,
            passwordHash: passwordHash,
            googleId: googleId,
            avatarUrl: avatarUrl,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String username,
            required String email,
            Value<String?> passwordHash = const Value.absent(),
            Value<String?> googleId = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            username: username,
            email: email,
            passwordHash: passwordHash,
            googleId: googleId,
            avatarUrl: avatarUrl,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$UsersTable, User>(table),
                    BaseReferences<_$AppDatabase, $UsersTable, User>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()>;
typedef $$FridgesTableTableCreateCompanionBuilder = FridgesTableCompanion
    Function({
  required String id,
  required String name,
  Value<String?> description,
  required String ownerId,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$FridgesTableTableUpdateCompanionBuilder = FridgesTableCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String> ownerId,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$FridgesTableTableFilterComposer
    extends Composer<_$AppDatabase, $FridgesTableTable> {
  $$FridgesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$FridgesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FridgesTableTable> {
  $$FridgesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$FridgesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FridgesTableTable> {
  $$FridgesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FridgesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FridgesTableTable,
    FridgeEntry,
    $$FridgesTableTableFilterComposer,
    $$FridgesTableTableOrderingComposer,
    $$FridgesTableTableAnnotationComposer,
    $$FridgesTableTableCreateCompanionBuilder,
    $$FridgesTableTableUpdateCompanionBuilder,
    (
      FridgeEntry,
      BaseReferences<_$AppDatabase, $FridgesTableTable, FridgeEntry>
    ),
    FridgeEntry,
    PrefetchHooks Function()> {
  $$FridgesTableTableTableManager(_$AppDatabase db, $FridgesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FridgesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FridgesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FridgesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FridgesTableCompanion(
            id: id,
            name: name,
            description: description,
            ownerId: ownerId,
            isSynced: isSynced,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required String ownerId,
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FridgesTableCompanion.insert(
            id: id,
            name: name,
            description: description,
            ownerId: ownerId,
            isSynced: isSynced,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$FridgesTableTable, FridgeEntry>(table),
                    BaseReferences<_$AppDatabase, $FridgesTableTable,
                        FridgeEntry>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FridgesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FridgesTableTable,
    FridgeEntry,
    $$FridgesTableTableFilterComposer,
    $$FridgesTableTableOrderingComposer,
    $$FridgesTableTableAnnotationComposer,
    $$FridgesTableTableCreateCompanionBuilder,
    $$FridgesTableTableUpdateCompanionBuilder,
    (
      FridgeEntry,
      BaseReferences<_$AppDatabase, $FridgesTableTable, FridgeEntry>
    ),
    FridgeEntry,
    PrefetchHooks Function()>;
typedef $$FridgeMembersTableCreateCompanionBuilder = FridgeMembersCompanion
    Function({
  required String fridgeId,
  required String userId,
  Value<String> role,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$FridgeMembersTableUpdateCompanionBuilder = FridgeMembersCompanion
    Function({
  Value<String> fridgeId,
  Value<String> userId,
  Value<String> role,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$FridgeMembersTableFilterComposer
    extends Composer<_$AppDatabase, $FridgeMembersTable> {
  $$FridgeMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fridgeId => $composableBuilder(
      column: $table.fridgeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$FridgeMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $FridgeMembersTable> {
  $$FridgeMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fridgeId => $composableBuilder(
      column: $table.fridgeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$FridgeMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FridgeMembersTable> {
  $$FridgeMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fridgeId =>
      $composableBuilder(column: $table.fridgeId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FridgeMembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FridgeMembersTable,
    FridgeMember,
    $$FridgeMembersTableFilterComposer,
    $$FridgeMembersTableOrderingComposer,
    $$FridgeMembersTableAnnotationComposer,
    $$FridgeMembersTableCreateCompanionBuilder,
    $$FridgeMembersTableUpdateCompanionBuilder,
    (
      FridgeMember,
      BaseReferences<_$AppDatabase, $FridgeMembersTable, FridgeMember>
    ),
    FridgeMember,
    PrefetchHooks Function()> {
  $$FridgeMembersTableTableManager(_$AppDatabase db, $FridgeMembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FridgeMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FridgeMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FridgeMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> fridgeId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FridgeMembersCompanion(
            fridgeId: fridgeId,
            userId: userId,
            role: role,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String fridgeId,
            required String userId,
            Value<String> role = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FridgeMembersCompanion.insert(
            fridgeId: fridgeId,
            userId: userId,
            role: role,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$FridgeMembersTable, FridgeMember>(table),
                    BaseReferences<_$AppDatabase, $FridgeMembersTable,
                        FridgeMember>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FridgeMembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FridgeMembersTable,
    FridgeMember,
    $$FridgeMembersTableFilterComposer,
    $$FridgeMembersTableOrderingComposer,
    $$FridgeMembersTableAnnotationComposer,
    $$FridgeMembersTableCreateCompanionBuilder,
    $$FridgeMembersTableUpdateCompanionBuilder,
    (
      FridgeMember,
      BaseReferences<_$AppDatabase, $FridgeMembersTable, FridgeMember>
    ),
    FridgeMember,
    PrefetchHooks Function()>;
typedef $$FridgeInvitesTableCreateCompanionBuilder = FridgeInvitesCompanion
    Function({
  required String id,
  required String fridgeId,
  required String fromUserId,
  required String toUserId,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$FridgeInvitesTableUpdateCompanionBuilder = FridgeInvitesCompanion
    Function({
  Value<String> id,
  Value<String> fridgeId,
  Value<String> fromUserId,
  Value<String> toUserId,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$FridgeInvitesTableFilterComposer
    extends Composer<_$AppDatabase, $FridgeInvitesTable> {
  $$FridgeInvitesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fridgeId => $composableBuilder(
      column: $table.fridgeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fromUserId => $composableBuilder(
      column: $table.fromUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toUserId => $composableBuilder(
      column: $table.toUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$FridgeInvitesTableOrderingComposer
    extends Composer<_$AppDatabase, $FridgeInvitesTable> {
  $$FridgeInvitesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fridgeId => $composableBuilder(
      column: $table.fridgeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fromUserId => $composableBuilder(
      column: $table.fromUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toUserId => $composableBuilder(
      column: $table.toUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$FridgeInvitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FridgeInvitesTable> {
  $$FridgeInvitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fridgeId =>
      $composableBuilder(column: $table.fridgeId, builder: (column) => column);

  GeneratedColumn<String> get fromUserId => $composableBuilder(
      column: $table.fromUserId, builder: (column) => column);

  GeneratedColumn<String> get toUserId =>
      $composableBuilder(column: $table.toUserId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FridgeInvitesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FridgeInvitesTable,
    FridgeInvite,
    $$FridgeInvitesTableFilterComposer,
    $$FridgeInvitesTableOrderingComposer,
    $$FridgeInvitesTableAnnotationComposer,
    $$FridgeInvitesTableCreateCompanionBuilder,
    $$FridgeInvitesTableUpdateCompanionBuilder,
    (
      FridgeInvite,
      BaseReferences<_$AppDatabase, $FridgeInvitesTable, FridgeInvite>
    ),
    FridgeInvite,
    PrefetchHooks Function()> {
  $$FridgeInvitesTableTableManager(_$AppDatabase db, $FridgeInvitesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FridgeInvitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FridgeInvitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FridgeInvitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fridgeId = const Value.absent(),
            Value<String> fromUserId = const Value.absent(),
            Value<String> toUserId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FridgeInvitesCompanion(
            id: id,
            fridgeId: fridgeId,
            fromUserId: fromUserId,
            toUserId: toUserId,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fridgeId,
            required String fromUserId,
            required String toUserId,
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FridgeInvitesCompanion.insert(
            id: id,
            fridgeId: fridgeId,
            fromUserId: fromUserId,
            toUserId: toUserId,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$FridgeInvitesTable, FridgeInvite>(table),
                    BaseReferences<_$AppDatabase, $FridgeInvitesTable,
                        FridgeInvite>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FridgeInvitesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FridgeInvitesTable,
    FridgeInvite,
    $$FridgeInvitesTableFilterComposer,
    $$FridgeInvitesTableOrderingComposer,
    $$FridgeInvitesTableAnnotationComposer,
    $$FridgeInvitesTableCreateCompanionBuilder,
    $$FridgeInvitesTableUpdateCompanionBuilder,
    (
      FridgeInvite,
      BaseReferences<_$AppDatabase, $FridgeInvitesTable, FridgeInvite>
    ),
    FridgeInvite,
    PrefetchHooks Function()>;
typedef $$ItemsTableTableCreateCompanionBuilder = ItemsTableCompanion Function({
  required String id,
  required String fridgeId,
  required String name,
  required String category,
  required String zone,
  Value<double> quantity,
  Value<String> unit,
  required DateTime expiryDate,
  Value<String?> imagePath,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$ItemsTableTableUpdateCompanionBuilder = ItemsTableCompanion Function({
  Value<String> id,
  Value<String> fridgeId,
  Value<String> name,
  Value<String> category,
  Value<String> zone,
  Value<double> quantity,
  Value<String> unit,
  Value<DateTime> expiryDate,
  Value<String?> imagePath,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ItemsTableTable> {
  $$ItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fridgeId => $composableBuilder(
      column: $table.fridgeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get zone => $composableBuilder(
      column: $table.zone, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTableTable> {
  $$ItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fridgeId => $composableBuilder(
      column: $table.fridgeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get zone => $composableBuilder(
      column: $table.zone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTableTable> {
  $$ItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fridgeId =>
      $composableBuilder(column: $table.fridgeId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get zone =>
      $composableBuilder(column: $table.zone, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ItemsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemsTableTable,
    ItemEntry,
    $$ItemsTableTableFilterComposer,
    $$ItemsTableTableOrderingComposer,
    $$ItemsTableTableAnnotationComposer,
    $$ItemsTableTableCreateCompanionBuilder,
    $$ItemsTableTableUpdateCompanionBuilder,
    (ItemEntry, BaseReferences<_$AppDatabase, $ItemsTableTable, ItemEntry>),
    ItemEntry,
    PrefetchHooks Function()> {
  $$ItemsTableTableTableManager(_$AppDatabase db, $ItemsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fridgeId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> zone = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<DateTime> expiryDate = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemsTableCompanion(
            id: id,
            fridgeId: fridgeId,
            name: name,
            category: category,
            zone: zone,
            quantity: quantity,
            unit: unit,
            expiryDate: expiryDate,
            imagePath: imagePath,
            isSynced: isSynced,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fridgeId,
            required String name,
            required String category,
            required String zone,
            Value<double> quantity = const Value.absent(),
            Value<String> unit = const Value.absent(),
            required DateTime expiryDate,
            Value<String?> imagePath = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemsTableCompanion.insert(
            id: id,
            fridgeId: fridgeId,
            name: name,
            category: category,
            zone: zone,
            quantity: quantity,
            unit: unit,
            expiryDate: expiryDate,
            imagePath: imagePath,
            isSynced: isSynced,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ItemsTableTable, ItemEntry>(table),
                    BaseReferences<_$AppDatabase, $ItemsTableTable, ItemEntry>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ItemsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemsTableTable,
    ItemEntry,
    $$ItemsTableTableFilterComposer,
    $$ItemsTableTableOrderingComposer,
    $$ItemsTableTableAnnotationComposer,
    $$ItemsTableTableCreateCompanionBuilder,
    $$ItemsTableTableUpdateCompanionBuilder,
    (ItemEntry, BaseReferences<_$AppDatabase, $ItemsTableTable, ItemEntry>),
    ItemEntry,
    PrefetchHooks Function()>;
typedef $$ItemHistoryTableCreateCompanionBuilder = ItemHistoryCompanion
    Function({
  required String id,
  required String fridgeId,
  Value<String?> itemId,
  required String itemName,
  Value<String?> imagePath,
  required String kind,
  required double quantityChanged,
  Value<double> quantityLeft,
  Value<String> unit,
  required String byUserId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$ItemHistoryTableUpdateCompanionBuilder = ItemHistoryCompanion
    Function({
  Value<String> id,
  Value<String> fridgeId,
  Value<String?> itemId,
  Value<String> itemName,
  Value<String?> imagePath,
  Value<String> kind,
  Value<double> quantityChanged,
  Value<double> quantityLeft,
  Value<String> unit,
  Value<String> byUserId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ItemHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $ItemHistoryTable> {
  $$ItemHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fridgeId => $composableBuilder(
      column: $table.fridgeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantityChanged => $composableBuilder(
      column: $table.quantityChanged,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantityLeft => $composableBuilder(
      column: $table.quantityLeft, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get byUserId => $composableBuilder(
      column: $table.byUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ItemHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemHistoryTable> {
  $$ItemHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fridgeId => $composableBuilder(
      column: $table.fridgeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantityChanged => $composableBuilder(
      column: $table.quantityChanged,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantityLeft => $composableBuilder(
      column: $table.quantityLeft,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get byUserId => $composableBuilder(
      column: $table.byUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ItemHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemHistoryTable> {
  $$ItemHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fridgeId =>
      $composableBuilder(column: $table.fridgeId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get quantityChanged => $composableBuilder(
      column: $table.quantityChanged, builder: (column) => column);

  GeneratedColumn<double> get quantityLeft => $composableBuilder(
      column: $table.quantityLeft, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get byUserId =>
      $composableBuilder(column: $table.byUserId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ItemHistoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemHistoryTable,
    ItemHistoryData,
    $$ItemHistoryTableFilterComposer,
    $$ItemHistoryTableOrderingComposer,
    $$ItemHistoryTableAnnotationComposer,
    $$ItemHistoryTableCreateCompanionBuilder,
    $$ItemHistoryTableUpdateCompanionBuilder,
    (
      ItemHistoryData,
      BaseReferences<_$AppDatabase, $ItemHistoryTable, ItemHistoryData>
    ),
    ItemHistoryData,
    PrefetchHooks Function()> {
  $$ItemHistoryTableTableManager(_$AppDatabase db, $ItemHistoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fridgeId = const Value.absent(),
            Value<String?> itemId = const Value.absent(),
            Value<String> itemName = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<double> quantityChanged = const Value.absent(),
            Value<double> quantityLeft = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<String> byUserId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemHistoryCompanion(
            id: id,
            fridgeId: fridgeId,
            itemId: itemId,
            itemName: itemName,
            imagePath: imagePath,
            kind: kind,
            quantityChanged: quantityChanged,
            quantityLeft: quantityLeft,
            unit: unit,
            byUserId: byUserId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fridgeId,
            Value<String?> itemId = const Value.absent(),
            required String itemName,
            Value<String?> imagePath = const Value.absent(),
            required String kind,
            required double quantityChanged,
            Value<double> quantityLeft = const Value.absent(),
            Value<String> unit = const Value.absent(),
            required String byUserId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemHistoryCompanion.insert(
            id: id,
            fridgeId: fridgeId,
            itemId: itemId,
            itemName: itemName,
            imagePath: imagePath,
            kind: kind,
            quantityChanged: quantityChanged,
            quantityLeft: quantityLeft,
            unit: unit,
            byUserId: byUserId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ItemHistoryTable, ItemHistoryData>(table),
                    BaseReferences<_$AppDatabase, $ItemHistoryTable,
                        ItemHistoryData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ItemHistoryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemHistoryTable,
    ItemHistoryData,
    $$ItemHistoryTableFilterComposer,
    $$ItemHistoryTableOrderingComposer,
    $$ItemHistoryTableAnnotationComposer,
    $$ItemHistoryTableCreateCompanionBuilder,
    $$ItemHistoryTableUpdateCompanionBuilder,
    (
      ItemHistoryData,
      BaseReferences<_$AppDatabase, $ItemHistoryTable, ItemHistoryData>
    ),
    ItemHistoryData,
    PrefetchHooks Function()>;
typedef $$NotificationsTableCreateCompanionBuilder = NotificationsCompanion
    Function({
  required String id,
  required String userId,
  required String type,
  Value<String?> payloadJson,
  Value<bool> isRead,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$NotificationsTableUpdateCompanionBuilder = NotificationsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> type,
  Value<String?> payloadJson,
  Value<bool> isRead,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$NotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$NotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$NotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NotificationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotificationsTable,
    Notification,
    $$NotificationsTableFilterComposer,
    $$NotificationsTableOrderingComposer,
    $$NotificationsTableAnnotationComposer,
    $$NotificationsTableCreateCompanionBuilder,
    $$NotificationsTableUpdateCompanionBuilder,
    (
      Notification,
      BaseReferences<_$AppDatabase, $NotificationsTable, Notification>
    ),
    Notification,
    PrefetchHooks Function()> {
  $$NotificationsTableTableManager(_$AppDatabase db, $NotificationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> payloadJson = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotificationsCompanion(
            id: id,
            userId: userId,
            type: type,
            payloadJson: payloadJson,
            isRead: isRead,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String type,
            Value<String?> payloadJson = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotificationsCompanion.insert(
            id: id,
            userId: userId,
            type: type,
            payloadJson: payloadJson,
            isRead: isRead,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$NotificationsTable, Notification>(table),
                    BaseReferences<_$AppDatabase, $NotificationsTable,
                        Notification>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NotificationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotificationsTable,
    Notification,
    $$NotificationsTableFilterComposer,
    $$NotificationsTableOrderingComposer,
    $$NotificationsTableAnnotationComposer,
    $$NotificationsTableCreateCompanionBuilder,
    $$NotificationsTableUpdateCompanionBuilder,
    (
      Notification,
      BaseReferences<_$AppDatabase, $NotificationsTable, Notification>
    ),
    Notification,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$FridgesTableTableTableManager get fridgesTable =>
      $$FridgesTableTableTableManager(_db, _db.fridgesTable);
  $$FridgeMembersTableTableManager get fridgeMembers =>
      $$FridgeMembersTableTableManager(_db, _db.fridgeMembers);
  $$FridgeInvitesTableTableManager get fridgeInvites =>
      $$FridgeInvitesTableTableManager(_db, _db.fridgeInvites);
  $$ItemsTableTableTableManager get itemsTable =>
      $$ItemsTableTableTableManager(_db, _db.itemsTable);
  $$ItemHistoryTableTableManager get itemHistory =>
      $$ItemHistoryTableTableManager(_db, _db.itemHistory);
  $$NotificationsTableTableManager get notifications =>
      $$NotificationsTableTableManager(_db, _db.notifications);
}
