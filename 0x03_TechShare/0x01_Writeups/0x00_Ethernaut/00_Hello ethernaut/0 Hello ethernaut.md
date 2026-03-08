


解题的时候 没有记录。。。。。。。。。
### 简单写一下流程：
#### 1. 访问网站"https://ethernaut.openzeppelin.com/"
![[Pasted image 20251108102304.png]]

#### 2. 点击"00"的小手图标后进入第一个题目(Hello Ethernaut):
![[Pasted image 20251108102641.png]]
#### 3. 随后按照教学步骤操作即可。


### 这里记录一下踩到的坑和解题步骤：
#### 1. 坑：水龙头提取不到i测试币

> [!NOTE]
> （发现目前几个水龙头都有点问题），要求钱包里至少有0.001ETH或者1Link之类的

![[Pasted image 20251108105610.png]]
目前这几个都没领到测试币：
> https://faucets.chain.link/
> https://cloud.google.com/application/web3/faucet/ethereum/sepolia

#### 解决方法：

> [!NOTE]
> 1、给钱包里放超过0.001ETH后，这个网站可以领到币（https://faucet.quicknode.com/ethereum/sepolia）。
> 
> 2、听说B站有博主，关注之后会定期放水，有空可以了解一下。

![[Pasted image 20251108114327.png]]

#### 解题步骤：
1. 按照新手指引，创建好钱包、账户并获取了测试币后，打开浏览器控制台
2. 在控制台输入指令顺序大致如下()：
Step_1：（按照提示获得的第一个method，）
```
await contract.info()
// Output: 'You will find what you need in info1().'
```
Step_2：（根据info的输出获得第二个method是info1）
```
await contract.info1()
// Output: 'Try info2(), but with "hello" as a parameter.'
```
Step_3：（根据info1的输出获得第三个method和parameter）
```
await contract.info2("hello")
// Output: 'The property infoNum holds the number of the next info method to call.'
```
Step_4：（在结尾处详细解释一下这里的命令）
```
await contract.infoNum().then(v => v.toString())
// Output: 42
```
Step_5：(获取下一个method)
```
await contract.info42()
// Output: 'theMethodName is the name of the next method.'
```
Step_6：（获取下一个method）
```
await contract.theMethodName()
// Output: 'The method name is method7123949.'
```
Step_7：（获得信息：将密码）
```
await contract.method7123949()
// Output: 'If you know the password, submit it to authenticate().'
```
Step_8 (查看合约内的内容，看看有没有线索，发现password函数)：
```
contract
// Output: { abi: ..., address: ..., ...., password: f () }
```
Step_9：（查看password的输出，获得密码）
```
await contract.password()
// Output: 'ethernaut0`
```
Step_10：（按照之前的提示，将密码作为parameter提交到authenticate）
```
await contract.authenticate('ethernaut0')
```

#### 解释一下Step_4的命令：
**Solidity 状态变量** → **RPC 报文** → **ethers.js 反序列化** → **BigNumber 内部表示** → **toString() 算法** → **最终打印 "42"**
```<solidity>
uint8 public infoNum = 42;     //这段代码表示42被编译成“32 字节大端”状态存储
```
##### 解释一下 `.then(v => v.toString())` : 
`v`  是得到的 `BigNumber` 实例，`.then(v => v.toString())` 的意思是把 `v` 传递给 `.toString()` 函数(回调调用)。


解题结束后可以看到源码：
```Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Instance {
    string public password;
    // 42被编译成 **32 字节大端** 状态存储
	uint8 public infoNum = 42;
    string public theMethodName = "The method name is method7123949.";
    bool private cleared = false;

    // constructor
    constructor(string memory _password) {
        password = _password;
    }

    function info() public pure returns (string memory) {
        return "You will find what you need in info1().";
    }

    function info1() public pure returns (string memory) {
        return 'Try info2(), but with "hello" as a parameter.';
    }

    function info2(string memory param) public pure returns (string memory) {
        if (keccak256(abi.encodePacked(param)) == keccak256(abi.encodePacked("hello"))) {
            return "The property infoNum holds the number of the next info method to call.";
        }
        return "Wrong parameter.";
    }

    function info42() public pure returns (string memory) {
        return "theMethodName is the name of the next method.";
    }

    function method7123949() public pure returns (string memory) {
        return "If you know the password, submit it to authenticate().";
    }

    function authenticate(string memory passkey) public {
        if (keccak256(abi.encodePacked(passkey)) == keccak256(abi.encodePacked(password))) {
            cleared = true;
        }
    }

    function getCleared() public view returns (bool) {
        return cleared;
    }
}
```

> 学习记录而已   #knowledge-management 

> [!NOTE]
> >  山高水长，路在脚下。
> >  
> > 心向远方者，魂无所牵，昂首即达。
