pragma solidity >=0.6.0;

import "./DappToken.sol";
import "./DaiToken.sol";

contract TokenFarm {
  string public name = "Dapp Token Farm";
  DappToken public dappToken;
  DaiToken public daiToken;
  address owner;

  address[] public stakers;
  mapping(address => uint) public stakingBalance; // like object in js
  mapping(address => bool) public hasStaked;
  mapping(address => bool) public isStaking;

  constructor(DappToken _dappToken, DaiToken _daiToken) public {
    dappToken = _dappToken;
    daiToken = _daiToken;
    owner = msg.sender; // assign owner upon deployment
  }

  // 1. Stakes Token (depoist)
  function stakeTokens(uint _amount) public {
    require(_amount > 0, "amount cannot be 0");

    // transfer Dai to this contract for staking
    // transferFrom is to delegate the transfer by someone else
    daiToken.transferFrom(msg.sender, address(this), _amount);

    // Update staking balance
    stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

    // add user to stakers array only if they haven't staked already
    if (!hasStaked[msg.sender]) {
      stakers.push(msg.sender);
    }

    hasStaked[msg.sender] = true;
    isStaking[msg.sender] = true;
  }

  // 2. Unstakes Token (withdraw)
  function unstakeTokens() public {
    // Fetch staking balance
    uint balance = stakingBalance[msg.sender];

    // Require amount greater than 0
    require(balance > 0, "staking balance cannot be 0");

    // Transfer Mock Dai tokens to this contract for staking
    daiToken.transfer(msg.sender, balance);

    // Reset staking balance
    stakingBalance[msg.sender] = 0;

    // Update staking status
    isStaking[msg.sender] = false; 
  }

  // 3. Issue Tokens (earn interests)
  function issueTokens() public {
    require(msg.sender == owner, 'caller must be the owner');

    for (uint i=0; i<stakers.length; i++) {
      address recipient = stakers[i];
      uint balance = stakingBalance[recipient];
      dappToken.transfer(recipient, balance);  
    }   
  }
  
}