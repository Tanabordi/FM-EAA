// TODO(service item): Implement item CRUD, consumption logic (partial / finished all), undo, and history audit logging
class ItemService {
  async getItemsByFridge(fridgeId, filters = {}) {
    // TODO: Query items with zone and category filtering
    throw new Error('Not implemented');
  }

  async createItem(fridgeId, itemData) {
    // TODO: Insert item into items table
    throw new Error('Not implemented');
  }

  async updateItem(itemId, itemData) {
    // TODO: Update item details
    throw new Error('Not implemented');
  }

  async deleteItem(itemId) {
    // TODO: Delete item from items table
    throw new Error('Not implemented');
  }

  async consumeItem(itemId, userId, amount, finishedAll = false) {
    // TODO: Deduct quantity or delete item if finished all, create record in item_history with kind = 'consumed'
    throw new Error('Not implemented');
  }

  async undoConsume(historyId, userId) {
    // TODO: Reverse consumption from item_history, restore quantity or re-create item
    throw new Error('Not implemented');
  }

  async getHistory(fridgeId, kind) {
    // TODO: Query item_history by fridgeId and kind (consumed | expired), ordered by created_at DESC
    throw new Error('Not implemented');
  }

  async deleteHistoryItem(historyId) {
    // TODO: Delete single history record
    throw new Error('Not implemented');
  }

  async clearHistory(fridgeId, kind) {
    // TODO: Clear all history records for a fridge matching kind
    throw new Error('Not implemented');
  }
}

module.exports = new ItemService();

