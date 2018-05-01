pragma solidity ^0.4.19;

// Standard ERC20 contract with Burning capabilities.
// https://theethereum.wiki/w/index.php/ERC20_Token_Standard

import './SafeMath.sol'; 
import './ERC20Interface.sol';


// ----------------------------------------------------------------------------
// Receive approval and then execute function
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint tokens, address token, bytes data) public;
}


// ------------------------------------------------------------------------
// Standard ERC20 Token Contract.
// Fixed Supply with burn capabilities
// ------------------------------------------------------------------------
contract ERC20 is ERC20Interface{
    using SafeMath for uint; 

    // ------------------------------------------------------------------------
    /// Token supply, balances and allowance
    // ------------------------------------------------------------------------
    uint internal supply;
    mapping (address => uint) internal balances;
    mapping (address => mapping (address => uint)) public allowed;

    // ------------------------------------------------------------------------
    // Token Information
    // ------------------------------------------------------------------------
    string public name;                   //Full Token name: MyBit
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier:  MYB


    // ------------------------------------------------------------------------
    // Constructor
    // Param: (uint) 
    // ------------------------------------------------------------------------
    function ERC20(uint _initialAmount, string _tokenName, uint8 _decimalUnits, string _tokenSymbol) 
    public {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        supply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }


    // ------------------------------------------------------------------------
    // Transfer _amount tokens to address _to 
    // Sender must have enough tokens. Cannot send to 0x0.
    // ------------------------------------------------------------------------
    function transfer(address _to, uint _amount) 
    public 
    returns (bool success) {
        require(_to != address(0));         // Use burn() function instead
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    // ------------------------------------------------------------------------
    // Transfer _amount of tokens if _from has allowed msg.sender to do so
    //  _from must have enough tokens + must have approved msg.sender 
    // ------------------------------------------------------------------------
    function transferFrom(address _from, address _to, uint _amount) 
    public 
    returns (bool success) {
        require(_to != address(0)); 
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(_from, _to, _amount);
        return true;
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    // ------------------------------------------------------------------------
    function approve(address _spender, uint _amount) 
    public 
    returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token holder can notify a contract that it has been approved
    // to spend _amount of tokens
    // ------------------------------------------------------------------------
    function approveAndCall(address _spender, uint _amount, bytes _data) 
    public 
    returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        ApproveAndCallFallBack(_spender).receiveApproval(msg.sender, _amount, this, _data);
        return true;
    }

    // ------------------------------------------------------------------------
    // Removes senders tokens from supply.
    // Lowers user balance and totalSupply by _amount
    // ------------------------------------------------------------------------   
    function burn(uint _amount) 
    public 
    returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        supply = supply.sub(_amount);
        LogBurn(msg.sender, _amount);
        Transfer(msg.sender, address(0), _amount);
        return true;
    }

    // ------------------------------------------------------------------------
    // An approved sender can burn _amount tokens of user _from
    // Lowers user balance and supply by _amount 
    // ------------------------------------------------------------------------    
    function burnFrom(address _from, uint _amount) 
    public 
    returns (bool success) {
        balances[_from] = balances[_from].sub(_amount);                         // Subtract from the targeted balance
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);             // Subtract from the sender's allowance
        supply = supply.sub(_amount);                              // Update supply
        LogBurn(_from, _amount);
        Transfer(_from, address(0), _amount);
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the number of tokens in circulation
    // ------------------------------------------------------------------------
    function totalSupply()
    public 
    view 
    returns (uint tokenSupply) { 
        return supply; 
    }

    // ------------------------------------------------------------------------
    // Returns the token balance of user
    // ------------------------------------------------------------------------
    function balanceOf(address _tokenHolder) 
    public 
    view 
    returns (uint balance) {
        return balances[_tokenHolder];
    }

    // ------------------------------------------------------------------------
    // Returns amount of tokens _spender is allowed to transfer or burn
    // ------------------------------------------------------------------------
    function allowance(address _tokenHolder, address _spender) 
    public 
    view 
    returns (uint remaining) {
        return allowed[_tokenHolder][_spender];
    }


    // ------------------------------------------------------------------------
    // Fallback function
    // Won't accept ETH
    // ------------------------------------------------------------------------
    function () 
    public 
    payable {
        revert();
    }

    // ------------------------------------------------------------------------
    // Event: Logs the amount of tokens burned and the address of the burner
    // ------------------------------------------------------------------------
    event LogBurn(address indexed _burner, uint indexed _amountBurned); 
}

