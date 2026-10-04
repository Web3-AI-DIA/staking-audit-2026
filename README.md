# Staking Contract Audit (2026)

This repository contains a full audit of a simplified staking contract. The contract allows users to stake an ERC20 token and earn rewards over time.

## Files
- COVER.md — audit summary  
- findings.md — issues and observations  
- threat-model.md — actors and risks  
- privilege-map.md — who can do what  
- architecture.md — how the contract works  
- recommendations.md — fixes and improvements  
- src/SimpleStaking.sol — audited contract  

## Summary
The staking contract is functional but contains several design risks typical of reward‑based staking systems. These include reentrancy surfaces, reward starvation, owner privilege concentration, and reliance on external token behavior.
