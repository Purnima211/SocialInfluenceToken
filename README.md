# 🪙 SocialInfluenceToken (SIT)

**Tokenized Social Influence** — a Solidity smart contract that rewards users for verified social engagement.

This minimal ERC-20–like implementation issues tokens based on **engagement scores** provided by trusted verifiers.  
It has **no imports**, **no constructor**, and can be deployed as-is on any EVM-compatible blockchain.

---

## 🌟 Overview

The **SocialInfluenceToken** (SIT) contract enables a tokenized incentive system for social media platforms or communities.  
Users earn SIT tokens proportional to their verified social engagement (likes, shares, comments, etc.), which are submitted on-chain by trusted verifiers.

### Key Features
- ✅ **No imports / no constructor** — fully standalone.
- 🧾 **Activation-based ownership** — deploy, then call `activate()` to set the owner.
- 🛡️ **Trusted Verifiers** — only approved verifiers can mint tokens.
- 📈 **Dynamic reward multiplier** — owner can adjust engagement-to-token ratio.
- 💰 **ERC20-compatible** — supports transfer, approve, and transferFrom.
- ⚙️ **Simple role management** — owner can add/remove verifiers.

---

## 🧱 Contract Summary

| Property | Description |
|-----------|--------------|
| **Name** | SocialInfluenceToken |
| **Symbol** | SIT |
| **Decimals** | 18 |
| **Standard** | Minimal ERC-20 |
| **Total Supply** | Increases as verifiers mint tokens |
| **Roles** | Owner, Verifier, User |

---

## 🚀 How It Works

1. **Deploy** the contract.  
2. **Activate** the contract by calling:
   ```solidity
   activate()
