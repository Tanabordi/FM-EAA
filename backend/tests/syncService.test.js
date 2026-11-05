const syncService = require('../src/services/syncService');
const db = require('../src/config/db');

describe('SyncService Unit Tests (LWW & Batch Processing)', () => {
  let mockConn;

  beforeEach(() => {
    mockConn = {
      execute: jest.fn(),
      commit: jest.fn().mockResolvedValue(),
      rollback: jest.fn().mockResolvedValue(),
      close: jest.fn().mockResolvedValue(),
    };
    jest.spyOn(db, 'getDbConnection').mockResolvedValue(mockConn);
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('throws 400 if payload or fridge_id is missing', async () => {
    await expect(syncService.processBatchSync('user_1', null)).rejects.toMatchObject({
      statusCode: 400,
    });
    await expect(syncService.processBatchSync('user_1', {})).rejects.toMatchObject({
      statusCode: 400,
    });
  });

  it('throws 403 if user is not a member of the fridge', async () => {
    mockConn.execute.mockResolvedValueOnce({ rows: [] }); // checkUserAccess returns empty

    await expect(
      syncService.processBatchSync('user_stranger', {
        fridge_id: 'fridge_1',
        items: [],
      })
    ).rejects.toMatchObject({
      statusCode: 403,
      message: 'Fridge not found or access denied',
    });
    expect(mockConn.rollback).toHaveBeenCalled();
    expect(mockConn.close).toHaveBeenCalled();
  });

  it('successfully processes new item inserts', async () => {
    // 1. checkUserAccess -> member
    mockConn.execute.mockResolvedValueOnce({ rows: [['owner']] });
    // 2. check if item exists in DB -> not found
    mockConn.execute.mockResolvedValueOnce({ rows: [] });
    // 3. insert item
    mockConn.execute.mockResolvedValueOnce({ rowsAffected: 1 });
    // 4. fetch all server items
    mockConn.execute.mockResolvedValueOnce({
      rows: [
        [
          'item_1',
          'fridge_1',
          'Fresh Milk',
          'beverages',
          'fridge',
          1,
          'bottle',
          '2026-11-10',
          null,
          '2026-11-04T12:00:00.000Z',
          '2026-11-04T12:00:00.000Z',
        ],
      ],
    });

    const result = await syncService.processBatchSync('user_1', {
      fridge_id: 'fridge_1',
      items: [
        {
          id: 'item_1',
          name: 'Fresh Milk',
          category: 'beverages',
          zone: 'fridge',
          quantity: 1,
          unit: 'bottle',
          expiry_date: '2026-11-10',
          updated_at: '2026-11-04T12:00:00.000Z',
        },
      ],
    });

    expect(result.success).toBe(true);
    expect(result.stats.upserted).toBe(1);
    expect(result.stats.skipped_server_won).toBe(0);
    expect(result.server_items).toHaveLength(1);
    expect(result.server_items[0].name).toBe('Fresh Milk');
    expect(mockConn.commit).toHaveBeenCalled();
    expect(mockConn.close).toHaveBeenCalled();
  });

  it('applies Last-Write-Wins: updates record when client updated_at is newer', async () => {
    // 1. checkUserAccess
    mockConn.execute.mockResolvedValueOnce({ rows: [['member']] });
    // 2. check item exists -> server has older timestamp
    mockConn.execute.mockResolvedValueOnce({
      rows: [['item_1', '2026-11-04T10:00:00.000Z']],
    });
    // 3. update query
    mockConn.execute.mockResolvedValueOnce({ rowsAffected: 1 });
    // 4. fetch all items
    mockConn.execute.mockResolvedValueOnce({
      rows: [
        [
          'item_1',
          'fridge_1',
          'Updated Milk',
          'beverages',
          'fridge',
          2,
          'bottle',
          '2026-11-12',
          null,
          '2026-11-04T10:00:00.000Z',
          '2026-11-04T12:00:00.000Z',
        ],
      ],
    });

    const result = await syncService.processBatchSync('user_1', {
      fridge_id: 'fridge_1',
      items: [
        {
          id: 'item_1',
          name: 'Updated Milk',
          category: 'beverages',
          zone: 'fridge',
          quantity: 2,
          unit: 'bottle',
          expiry_date: '2026-11-12',
          updated_at: '2026-11-04T12:00:00.000Z', // newer than 10:00:00
        },
      ],
    });

    expect(result.success).toBe(true);
    expect(result.stats.upserted).toBe(1);
    expect(result.stats.skipped_server_won).toBe(0);
    expect(mockConn.commit).toHaveBeenCalled();
  });

  it('applies Last-Write-Wins: keeps server record when server updated_at is newer', async () => {
    // 1. checkUserAccess
    mockConn.execute.mockResolvedValueOnce({ rows: [['member']] });
    // 2. check item exists -> server has newer timestamp (14:00:00)
    mockConn.execute.mockResolvedValueOnce({
      rows: [['item_1', '2026-11-04T14:00:00.000Z']],
    });
    // (No update query should be executed because server won)
    // 3. fetch all items
    mockConn.execute.mockResolvedValueOnce({
      rows: [
        [
          'item_1',
          'fridge_1',
          'Server Newer Milk',
          'beverages',
          'fridge',
          3,
          'bottle',
          '2026-11-15',
          null,
          '2026-11-04T10:00:00.000Z',
          '2026-11-04T14:00:00.000Z',
        ],
      ],
    });

    const result = await syncService.processBatchSync('user_1', {
      fridge_id: 'fridge_1',
      items: [
        {
          id: 'item_1',
          name: 'Older Client Milk',
          quantity: 1,
          updated_at: '2026-11-04T11:00:00.000Z', // older than server's 14:00:00
        },
      ],
    });

    expect(result.success).toBe(true);
    expect(result.stats.upserted).toBe(0);
    expect(result.stats.skipped_server_won).toBe(1);
    expect(result.server_items[0].name).toBe('Server Newer Milk');
  });

  it('deletes item when is_deleted is true and client is newer', async () => {
    // 1. checkUserAccess
    mockConn.execute.mockResolvedValueOnce({ rows: [['owner']] });
    // 2. check item exists
    mockConn.execute.mockResolvedValueOnce({
      rows: [['item_1', '2026-11-04T08:00:00.000Z']],
    });
    // 3. delete execution
    mockConn.execute.mockResolvedValueOnce({ rowsAffected: 1 });
    // 4. fetch all items
    mockConn.execute.mockResolvedValueOnce({ rows: [] });

    const result = await syncService.processBatchSync('user_1', {
      fridge_id: 'fridge_1',
      items: [
        {
          id: 'item_1',
          is_deleted: true,
          updated_at: '2026-11-04T09:00:00.000Z',
        },
      ],
    });

    expect(result.success).toBe(true);
    expect(result.stats.deleted).toBe(1);
  });
});

