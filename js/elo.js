// Standard Elo update, K=32. ratingA/ratingB are the current scores;
// winnerIsA is true if cat A won the comparison.
function eloUpdate(ratingA, ratingB, winnerIsA) {
  const K = 32;
  const expectedA = 1 / (1 + Math.pow(10, (ratingB - ratingA) / 400));
  const expectedB = 1 - expectedA;
  const scoreA = winnerIsA ? 1 : 0;
  const scoreB = winnerIsA ? 0 : 1;
  const newA = Math.round(ratingA + K * (scoreA - expectedA));
  const newB = Math.round(ratingB + K * (scoreB - expectedB));
  return { newA, newB };
}
