(function (global) {
  function canEditCat(currentUserId, ownerId) {
    return Boolean(currentUserId) && Boolean(ownerId) && String(currentUserId) === String(ownerId);
  }

  function buildCatPayload({ currentUserId, existingCat = null, values = {} } = {}) {
    const payload = { ...values };

    if (existingCat && existingCat.added_by) {
      payload.added_by = existingCat.added_by;
    } else if (currentUserId) {
      payload.added_by = currentUserId;
    }

    return payload;
  }

  const api = { canEditCat, buildCatPayload };

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = api;
  }

  global.canEditCat = canEditCat;
  global.buildCatPayload = buildCatPayload;
  global.catOwnership = api;
})(typeof window !== 'undefined' ? window : globalThis);
