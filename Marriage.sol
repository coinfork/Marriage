pragma solidity >=0.4.24 <0.7.0;

/// @title Ethereum marriage contract
/// @author Witek Radomski
/// @notice This smart contract allows for marriage and divorce on the Ethereum blockchain with a monetary incentive to
/// stay married for the full term, as well as a prisoner's dilemma to update the contract if a divorce were to happen.
contract Marriage {

    address public partner1;
    string public partner1Name;
    bool public partner1Signed = false;

    address public partner2;
    string public partner2Name;
    bool public partner2Signed = false;

    uint256 public blockchainWeddingDate;
    uint256 public yearsToLockFunds;
    address payable public divorceBurnAddress;
    uint256 public percentToBurnOnDivorce;
    bool public married = true;
    
    event Married(address indexed _partner1, address indexed _partner2);
    event Signed(address indexed _partner);
    event LifeEvent(address indexed _sender, uint256 _time, string _eventDescription);
    event Wishes(address indexed _sender, uint256 _time, string _note);
    event Divorced(address indexed _partner1, address indexed _partner2, address _initiatedBy);

    uint256 constant DAYS_IN_YEAR = 365;

    modifier onlyPartner() {
        require(msg.sender == partner1 || msg.sender == partner2, "Must be one of the partners");
        _;
    }

    /// @param _partner1 The address of the first partner
    /// @param _partner2 The address of the second partner
    /// @param _yearsToLockFunds How many years to lock funds for. Note: Years are 365 days, leap years are not
    /// considered here.
    /// @param _divorceBurnAddress If a divorce occurs, Ether will be sent here. I recommend supplying the public
    /// address of a charity that accepts Ether, such as SENS Research Foundation for the betterment of humankind.
    /// @param _percentToBurnOnDivorce The percentage out of 100 to burn if a divorce happens. Suggested: 90. The
    /// rest will be transferred to the user that initiates the divorce function as a prisoner's dilemma incentive
    /// to execute the function.
    constructor(
        address _partner1,
        address _partner2,
        uint256 _yearsToLockFunds,
        address payable _divorceBurnAddress,
        uint256 _percentToBurnOnDivorce
    ) public {
        partner1 = _partner1;
        partner2 = _partner2;
        yearsToLockFunds = _yearsToLockFunds;
        divorceBurnAddress = _divorceBurnAddress;
        percentToBurnOnDivorce = _percentToBurnOnDivorce;
        blockchainWeddingDate = now;
        
        emit Married(partner1, partner2);
    }

    /// @notice Each partner must sign the contract with this function. This will lock funds and also set their name.
    /// This function may also be called any time in the future by either partner to update their name if needed.
    /// @param _partnerName The full legal name or nickname of the current partner signing this contract
    function signPartner(string memory _partnerName) public onlyPartner {
        if(msg.sender == partner1) {
            partner1Name = _partnerName;
            partner1Signed = true;
        }
        else if(msg.sender == partner2) {
            partner2Name = _partnerName;
            partner2Signed = true;
        }
        
        emit Signed(msg.sender);
    }

    /// @notice Warning: Executing this function will send a percentage of the Ether balance to the divorceBurnAddress
    /// as a penalty for not staying married through the length of the marriage contract.
    /// The person who initiates the divorce function will receive the remainder of funds.
    /// Please talk things through with your partner and work on your marriage before considering this function!
    /// @param _confirm Safety measure. This must be integer 1 to confirm the divorce proceeds.
    function divorce(uint256 _confirm) public onlyPartner returns (bool) {
        require(_confirm == 1, "To proceed with divorce and burn funds, pass 1 to _confirm");
        require(married == true, "Already divorced, cannot divorce again!");
        
        uint256 burnAmount = address(this).balance * percentToBurnOnDivorce / 100;
        uint256 divorcerAmount = address(this).balance - burnAmount;
        
        divorceBurnAddress.transfer(burnAmount);
        msg.sender.transfer(divorcerAmount);
        
        married = false;
        emit Divorced(partner1, partner2, msg.sender);
    }
    
    /// @notice Funds may be withdrawn by either partner after the lock period has ended
    /// @param _amount Amount of Ether in wei to withdraw from this contract
    function withdrawFunds(uint256 _amount) public onlyPartner {
        require(partner1Signed == false || partner2Signed == false || now >= blockchainWeddingDate + (yearsToLockFunds * DAYS_IN_YEAR * 1 days), "Lock time has not passed yet");
        
        require(_amount <= address(this).balance, "Amount is larger than the available balance");
        msg.sender.transfer(_amount);
    }
    
    /// @notice This function may be called by the couple to log significant life events, such as the birth of a child.
    /// @param _eventDescription A human-readable description string
    function addLifeEvent(string memory _eventDescription) public onlyPartner {
        emit LifeEvent(msg.sender, now, _eventDescription);
    }
    
    /// @notice This function may be called by friends or public to wish a happy marriage, happy anniversary, etc.
    /// @param _note A human-readable note. Please include your name so the couple may know who the wishes are from.
    function addWishes(string memory _note) public {
        emit Wishes(msg.sender, now, _note);
    }
    
    /// @notice Payable fallback function, allows this contract to receive Ether.
    function() external payable {
    }

}