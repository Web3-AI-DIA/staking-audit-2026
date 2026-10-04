# Findings

## 1. Reentrancy Risk in `stake`, `withdraw`, `getReward`
**Severity:** Medium  
External ERC20 calls occur after state updates. If the token is malicious, reentrancy is possible.

**Recommendation:** Add a reentrancy guard.

---

## 2. Reward Starvation When `totalStaked == 0`
**Severity:** Medium  
Rewards stop accumulating when no one is staked, causing reward distribution to freeze.

**Recommendation:** Consider accumulating rewards even when no one is staked.

---

## 3. Owner Can Drain Any Token Except Staking Token
**Severity:** Medium  
`rescueTokens()` allows the owner to withdraw any token except the staking token.

**Recommendation:** Add governance or multi‑sig.

---

## 4. Reward Rate Can Be Changed Arbitrarily
**Severity:** Medium  
Owner can change reward rate at any time, affecting user expectations.

**Recommendation:** Add timelock or governance.

---

## 5. No Validation of Reward Token Balance
**Severity:** Medium  
If rewardToken has insufficient balance, `getReward()` fails.

**Recommendation:** Add checks or auto‑funding logic.

---

## 6. Rounding Errors in Reward Math
**Severity:** Low  
`1e18` scaling introduces rounding loss.

**Recommendation:** Document rounding behavior.

---

## 7. No Emergency Withdraw
**Severity:** Low  
Users cannot withdraw without claiming rewards.

**Recommendation:** Add `emergencyWithdraw()` without rewards.
