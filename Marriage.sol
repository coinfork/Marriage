pragma solidity >=0.4.24 <0.7.0;

/// @title Ethereum marriage contract
/// @author Witek Radomski
/// @notice This smart contract allows for marriage and divorce on the Ethereum blockchain with a monetary incentive to
/// stay married for the full term, as well as a prisoner's dilemma to update the contract if a divorce were to happen.
contract Marriage {

    address public partner1;
    string public partner1Name;
    bool public partner1Signed = false;
    address private partner1UpdateAddress;

    address public partner2;
    string public partner2Name;
    bool public partner2Signed = false;
    address private partner2UpdateAddress;

    string  public marriageContractId;
    uint256 public blockchainWeddingDate;
    uint256 public yearsToLockFunds;
    address payable public divorceBurnAddress;
    uint256 public percentToBurnOnDivorce;
    bool public married = true;
    
    event Married(address indexed _partner1, address indexed _partner2);
    event Signed(uint256 indexed _partnerNumber, address indexed _partner, string _partnerName);
    event UpdatedAddress(uint256 indexed _partnerNumber, address indexed _oldAddress, address indexed _newAddress);
    event LifeEvent(address indexed _sender, string _eventDescription);
    event Wishes(address indexed _sender, string _note);
    event Divorced(address indexed _partner1, address indexed _partner2, address _initiatedBy);

    uint256 constant DAYS_IN_YEAR = 365;

    modifier onlyPartner() {
        require(msg.sender == partner1 || msg.sender == partner2, "Must be one of the partners");
        _;
    }

    /// @param _marriageContractId A human-readable identifier or name for this contract.
    /// @param _partner1 The address of the first partner.
    /// @param _partner2 The address of the second partner.
    /// @param _yearsToLockFunds How many years to lock funds for. Note: Years are 365 days, leap years are not
    /// considered here.
    /// @param _divorceBurnAddress If a divorce occurs, Ether will be sent here. I recommend supplying the public
    /// address of a charity that accepts Ether, such as SENS Research Foundation for the betterment of humankind.
    /// @param _percentToBurnOnDivorce The percentage out of 100 to burn if a divorce happens. Suggested: 90. The
    /// rest will be transferred to the user that initiates the divorce function as a prisoner's dilemma incentive
    /// to execute the function.
    constructor(
        string memory _marriageContractId,
        address _partner1,
        address _partner2,
        uint256 _yearsToLockFunds,
        address payable _divorceBurnAddress,
        uint256 _percentToBurnOnDivorce
    ) public {
        marriageContractId = _marriageContractId;
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
            emit Signed(1, msg.sender, _partnerName);
        }
        else if(msg.sender == partner2) {
            partner2Name = _partnerName;
            partner2Signed = true;
            emit Signed(2, msg.sender, _partnerName);
        }
    }
    
    /// @notice To update a partner's Ethereum account address, they must first call this function (Step 1).
    /// Next, they must call the acceptUpdatePartnerAddress function from the new account address, to finalize.
    /// @param _partnerNumber Which partner is updating their address (1 or 2)
    /// @param _newAddress The new address to be updated to
    function updatePartnerAddress(uint256 _partnerNumber, address _newAddress) public onlyPartner {
        if(_partnerNumber == 1) {
            require(msg.sender == partner1, "Must be partner 1");
            partner1UpdateAddress = _newAddress;
        }
        else if(_partnerNumber == 2) {
            require(msg.sender == partner2, "Must be partner 2");
            partner2UpdateAddress = _newAddress;
        }
        else {
            revert("_partnerNumber must be 1 or 2");
        }
    }
    
    /// @notice This will permanently change one partner's address their desired new address (Step 2).
    /// Run this function using the new account AFTER calling updatePartnerAddress from the original account.
    /// @param _partnerNumber Which partner is accepting their new address change (1 or 2)
    function acceptUpdatePartnerAddress(uint256 _partnerNumber) public {
        if(_partnerNumber == 1) {
            if(msg.sender == partner1UpdateAddress) {
                emit UpdatedAddress(_partnerNumber, partner1, partner1UpdateAddress);
                partner1 = partner1UpdateAddress;
                partner1UpdateAddress = address(0);
            }
            else {
                revert("Please accept from the new account you had provided in updatePartnerAddress");
            }
        }
        else if(_partnerNumber == 2) {
            if(msg.sender == partner2UpdateAddress) {
                emit UpdatedAddress(_partnerNumber, partner2, partner2UpdateAddress);
                partner2 = partner2UpdateAddress;
                partner2UpdateAddress = address(0);
            }
            else {
                revert("Please accept from the new account you had provided in updatePartnerAddress");
            }
        }
        else {
            revert("_partnerNumber must be 1 or 2");
        }
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
        emit LifeEvent(msg.sender, _eventDescription);
    }
    
    /// @notice This function may be called by friends or public to wish a happy marriage, happy anniversary, etc.
    /// @param _note A human-readable note. Please include your name so the couple may know who the wishes are from.
    function addWishes(string memory _note) public {
        emit Wishes(msg.sender, _note);
    }
    
    /// @notice Payable fallback function, allows this contract to receive Ether.
    function() external payable {
    }

}
