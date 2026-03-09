
**踩坑记录**：版本管理的重要性。

**核心漏洞**：未检查余额扣减时的整数下溢

```solidity
// 漏洞合约（版本 ^0.6.0）
contract Token {
    mapping(address => uint) balances;
    uint256 public totalSupply;
    
    constructor(uint256 _initialSupply) public {
        balances[msg.sender] = totalSupply = _initialSupply;
    }
    
    function transfer(address _to, uint256 _value) public returns (bool) {
        // 这里使用了 unchecked！
        unchecked {
            balances[msg.sender] -= _value; // 若余额不足，会下溢到 2^256-1
            balances[_to] += _value;
        }
        return true;
    }
}
```

**攻击流程**（来源：OpenZeppelin 安全博文）：
如果你的余额是 20，你要转账 21：
- `balances[msg.sender] -= 21` → 下溢 → 余额 = 2^256 - 1
- 瞬间获得无限代币

**攻击步骤**：
1. 获取初始代币（比如 20 个）
2. 调用 `transfer(受害地址, 21)`
3. 你的余额变为极大值

**个人感悟**：版本管理！版本管理！版本管理！版本管理！版本管理！版本管理！版本管理！版本管理！