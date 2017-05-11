/*Look at zepplin for inspiration. Please see github repo.*/

pragma solidity ^0.4.8;

/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}

/*
 * ERC20Basic
 * Simpler version of ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Basic {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function transfer(address to, uint value);
  event Transfer(address indexed from, address indexed to, uint value);
}

/*
 * Basic token
 * Basic version of StandardToken, with no allowances
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint;

  mapping(address => uint) balances;

  /*
   * Fix for the ERC20 short address attack
   */
  modifier onlyPayloadSize(uint size) {
     if(msg.data.length < size + 4) {
       throw;
     }
     _;
  }

  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

}

/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint);
  function transferFrom(address from, address to, uint value);
  function approve(address spender, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

/**
 * Standard ERC20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is BasicToken, ERC20 {

  mapping (address => mapping (address => uint)) allowed;

  function transferFrom(address _from, address _to, uint _value) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // if (_value > _allowance) throw;

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
  }

  function approve(address _spender, uint _value) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}

/*
 * SimpleToken
 *
 * Very simple ERC20 Token example, where all tokens are pre-assigned
 * to the creator. Note they can later distribute these tokens
 * as they wish using `transfer` and other `StandardToken` functions.
 */
contract SimpleToken is StandardToken {

  string public name = "SimpleToken";
  string public symbol = "SIM";
  uint public decimals = 18;
  uint public INITIAL_SUPPLY = 10000;

  function SimpleToken() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }

}

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
    if (msg.sender != owner) {
      throw;
    }
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint value);
  event MintFinished();

  bool public mintingFinished = false;
  uint public totalSupply = 0;

  modifier canMint() {
    if(mintingFinished) throw;
    _;
  }

  function mint(address _to, uint _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

contract InvestecCoin is MintableToken {
  string public name = "InvestecCoin";
  string public symbol = "IC";
  uint public decimals = 2;
  uint public INITIAL_SUPPLY = 0;

  struct Transaction {
     bytes32 message;
     uint amount;
     address from;
     address to;
   }
   mapping (address => Transaction[]) transactionIn;
   mapping (address => Transaction[]) transactionOut;
   mapping (address => Transaction[]) paymentRequests;
   uint paymentReqInd = 0;

  function InvestecCoin() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }

  // add check if coin amount is really less
  function redeemCoins(uint amount) returns (bool) {
    if (amount > balances[msg.sender]) {
      return false;
    } else {
      balances[msg.sender] = balances[msg.sender] - amount;
      return true;
    }
  }

  function requestPayment(address _from, uint _amount, bytes32 _message) {
    Transaction memory newPayReq;    // have a boolean check here... only add transaction if enough funds...
    /*Transfer(msg.sender, msg.sender, _amount);*/
    newPayReq.message = _message;
    newPayReq.amount = _amount;
    newPayReq.from = _from;
    newPayReq.to = msg.sender;
    paymentRequests[_from].push(newPayReq);
    /*transactionIn[_to].push(newPayReq);
    transactionIn[msg.sender].push(newPayReq);*/
  }

  function viewPayRequests() constant returns (bytes32[],address[],uint[]) {
    uint length = paymentRequests[msg.sender].length - paymentReqInd;

    bytes32[] memory messages = new bytes32[](length);
    uint[] memory amounts = new uint[](length);
    address[] memory addresses = new address[](length);

    // This for loop isn't too expensive because this function is 'constart'
    for (uint i = paymentReqInd; i < length; i++) {
      Transaction memory nextReq;

      nextReq = paymentRequests[msg.sender][i];

      messages[i] = nextReq.message;
      addresses[i] = nextReq.to;
      amounts[i] = nextReq.amount;
    }
    return (messages, addresses, amounts);

  }

 /*bytes32[] memory firstNames = new bytes32[](length);
 bytes32[] memory lastNames = new bytes32[](length);
 uint[] memory ages = new uint[](length);*/

 /*
 function sendMoney(bytes32 _message, address _to, uint _amount) returns (bool success) {
   Transaction memory newPerson;    // have a boolean check here... only add transaction if enough funds...
   Transfer(msg.sender, _to, _amount);    newPerson.message = _message;
   newPerson.amount = _amount;
   newPerson.from = msg.sender;
   newPerson.to = _to;    transactionIn[_to].push(newPerson);
   transactionIn[msg.sender].push(newPerson);
   return true;
 }*/

 /*function investInBank(bytes32 _message, address _to, uint _amount)*/
}
