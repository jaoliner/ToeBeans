const test = require('node:test');
const assert = require('node:assert/strict');
const { canEditCat, buildCatPayload } = require('../js/catOwnership.js');

test('creator can edit their cat', () => {
  assert.equal(canEditCat('user-1', 'user-1'), true);
});

test('non-creator cannot edit someone else\'s cat', () => {
  assert.equal(canEditCat('user-2', 'user-1'), false);
});

test('existing cat keeps original owner on update', () => {
  const payload = buildCatPayload({
    currentUserId: 'user-2',
    existingCat: { added_by: 'user-1' },
    values: { name: 'Milo', color: 'Orange' }
  });

  assert.equal(payload.added_by, 'user-1');
  assert.equal(payload.name, 'Milo');
  assert.equal(payload.color, 'Orange');
});

test('new cat is assigned to the current creator', () => {
  const payload = buildCatPayload({
    currentUserId: 'user-9',
    values: { name: 'Luna' }
  });

  assert.equal(payload.added_by, 'user-9');
  assert.equal(payload.name, 'Luna');
});
