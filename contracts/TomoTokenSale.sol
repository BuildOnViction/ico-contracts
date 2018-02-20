pragma solidity 0.4.19;

// ================= Ownable Contract start =============================
/*
 * Ownable
 *
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */
contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}
// ================= Ownable Contract end ===============================

// ================= Safemath Contract start ============================
/* taking ideas from FirstBlood token */
contract SafeMath {

  function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
    uint256 z = x + y;
    assert((z >= x) && (z >= y));
    return z;
  }

  function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
    assert(x >= y);
    uint256 z = x - y;
    return z;
  }

  function safeMult(uint256 x, uint256 y) internal returns(uint256) {
    uint256 z = x * y;
    assert((x == 0)||(z/x == y));
    return z;
  }
}
// ================= Safemath Contract end ==============================

// ================= ERC20 Token Contract start =========================
/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}
// ================= ERC20 Token Contract end ===========================

// ================= Standard Token Contract start ======================
contract StandardToken is ERC20, SafeMath {

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  function transfer(address _to, uint _value) returns (bool success){
    balances[msg.sender] = safeSubtract(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSubtract(balances[_from], _value);
    allowed[_from][msg.sender] = safeSubtract(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}
// ================= Standard Token Contract end ========================

// ================= Pausable Token Contract start ======================
/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
  * @dev modifier to allow actions only when the contract IS paused
  */
  modifier whenNotPaused() {
    require (!paused);
    _;
  }

  /**
  * @dev modifier to allow actions only when the contract IS NOT paused
  */
  modifier whenPaused {
    require (paused) ;
    _;
  }

  /**
  * @dev called by the owner to pause, triggers stopped state
  */
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
  * @dev called by the owner to unpause, returns to normal state
  */
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}
// ================= Pausable Token Contract end ========================

// ================= Tomocoin  start =======================
contract TomoCoin is SafeMath, StandardToken, Pausable {
  string public constant name = 'Tomocoin';
  string public constant symbol = 'TOMO';
  uint256 public constant decimals = 18;
  address public tokenSaleAddress;
  address public tomoDepositAddress; // multisig wallet

  uint256 public constant tomoDeposit = 100000000 * 10**decimals;

  function TomoCoin(address _tomoDepositAddress) { 
    tomoDepositAddress = _tomoDepositAddress;

    balances[tomoDepositAddress] = tomoDeposit;
    Transfer(0x0, tomoDepositAddress, tomoDeposit);
    totalSupply = tomoDeposit;
  }

  function transfer(address _to, uint _value) whenNotPaused returns (bool success) {
    return super.transfer(_to,_value);
  }

  function approve(address _spender, uint _value) whenNotPaused returns (bool success) {
    return super.approve(_spender,_value);
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return super.balanceOf(_owner);
  }

  // Setup Token Sale Smart Contract
  function setTokenSaleAddress(address _tokenSaleAddress) onlyOwner {
    if (_tokenSaleAddress != address(0)) {
      tokenSaleAddress = _tokenSaleAddress;
    }
  }

  function mint(address _recipient, uint _value) whenNotPaused returns (bool success) {
      assert(_value > 0);
      // This function is only called by Token Sale Smart Contract
      require(msg.sender == tokenSaleAddress);

      balances[tomoDepositAddress] = safeSubtract(balances[tomoDepositAddress], _value);
      balances[ _recipient ] = safeAdd(balances[_recipient], _value);

      Transfer(tomoDepositAddress, _recipient, _value);
      return true;
  }
}
// ================= Ico Token Contract end =======================


// ================= Whitelist start ====================
contract TomoContributorWhitelist is Ownable {
    mapping(address=>uint256) public whitelist;

    function TomoContributorWhitelist() {}

    event ListAddress( address _user, uint256 cap, uint _time );

    function listAddress( address _user, uint256 cap ) onlyOwner {
        whitelist[_user] = cap;
        ListAddress( _user, cap, now );
    }

    function listAddresses( address[] _users, uint256[] _caps ) onlyOwner {
        for( uint i = 0 ; i < _users.length ; i++ ) {
            listAddress( _users[i], _caps[i] );
        }
    }

    function getCap( address _user ) constant returns(uint) {
        return whitelist[_user];
    }
}
// ================= Whitelist end ====================

// ================= Actual Sale Contract Start ====================
contract TomoTokenSale is SafeMath, Pausable {
  TomoCoin public token;
  TomoContributorWhitelist whitelist;

  address public ethFundDepositAddress;
  address public tomoDepositAddress;

  uint256 public tokenCreationCap = 4000000 * 10**18;
  uint256 public totalSupply;
  uint256 public fundingStartTime = 1504051200; // 2017-08-30
  uint256 public fundingPoCEndTime = 1518480000; // 2018-02-13
  uint256 public fundingEndTime = 1518652800; // 2018-02-15
  uint256 public minContribution = 0.1 ether;
  uint256 public maxContribution = 10 ether;
  uint256 public tokenExchangeRate = 4000;

  bool public isFinalized;

  event MintTomo(address from, address to, uint256 val);
  event RefundTomo(address to, uint256 val);

  function TomoTokenSale(
    TomoCoin _tomoCoinAddress,
    TomoContributorWhitelist _tomoContributorWhitelistAddress,
    address _ethFundDepositAddress,
    address _tomoDepositAddress
  )
  {
    token = TomoCoin(_tomoCoinAddress);
    whitelist = TomoContributorWhitelist(_tomoContributorWhitelistAddress);
    ethFundDepositAddress = _ethFundDepositAddress;
    tomoDepositAddress = _tomoDepositAddress;

    isFinalized = false;
  }

  function buy(address to, uint256 val) internal returns (bool success) {
    MintTomo(tomoDepositAddress, to, val);
    return token.mint(to, val);
  }

  function () payable {    
    createTokens(msg.sender, msg.value);
  }

  function createTokens(address _beneficiary, uint256 _value) internal whenNotPaused {
    require (now >= fundingStartTime);
    require (now <= fundingEndTime);
    require (_value >= minContribution);
    require (_value <= maxContribution);
    require (!isFinalized);

    uint256 tokens = safeMult(_value, tokenExchangeRate);

    uint256 maxCap = safeMult(maxContribution, tokenExchangeRate);
    uint256 cap = whitelist.getCap(msg.sender);
    require (cap > 0);

    uint256 tokensToAllocate = 0;
    uint256 tokensToRefund = 0;
    uint256 etherToRefund = 0;

    // running while PoC Buying Time
    if (now <= fundingPoCEndTime) {
      tokensToAllocate = safeSubtract(cap, token.balanceOf(msg.sender));
    } else {
      tokensToAllocate = safeSubtract(maxCap, token.balanceOf(msg.sender));
    }

    // calculate refund if over max cap or individual cap
    if (tokens > tokensToAllocate) {
      tokensToRefund = safeSubtract(tokens, tokensToAllocate);
      etherToRefund = tokensToRefund / tokenExchangeRate;
    } else {
      // user can buy amount they want
      tokensToAllocate = tokens;
    }

    uint256 checkedSupply = safeAdd(totalSupply, tokensToAllocate);

    // if reaches hard cap
    if (tokenCreationCap < checkedSupply) {        
      tokensToAllocate = safeSubtract(tokenCreationCap, totalSupply);
      tokensToRefund   = safeSubtract(tokens, tokensToAllocate);
      etherToRefund = tokensToRefund / tokenExchangeRate;
      totalSupply = tokenCreationCap;
    } else {
      totalSupply = checkedSupply;
    }

    require(buy(_beneficiary, tokensToAllocate));
    if (etherToRefund > 0) {
      // refund in case user buy over hard cap, individual cap
      RefundTomo(msg.sender, etherToRefund);
      msg.sender.transfer(etherToRefund);
    }
    ethFundDepositAddress.transfer(this.balance);
    return;
  }

  /// @dev Ends the funding period and sends the ETH home
  function finalize() external onlyOwner {
    require (!isFinalized);
    // move to operational
    isFinalized = true;
    ethFundDepositAddress.transfer(this.balance);
  }
}
