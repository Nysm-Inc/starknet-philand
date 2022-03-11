
import "@openzeppelin/contracts/utils/Context.sol";
/**
* @dev Contracts to manage multiple owners.
*/
abstract contract MultiOwner is Context {
    error InvalidOwner();

    // address[] private _owners;
    mapping (address => bool) private _owners;

    event OwnershipGranted(address indexed operator, address indexed target);
    event OwnershipRemoved(address indexed operator, address indexed target);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owners[_msgSender()] = true;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner(address targetAddress) public virtual returns (bool) {
        return _owners[targetAddress];
    }

    /**
     * @dev Set the address of the owner.
     */
    function setOwner(address newOwner) public virtual onlyOwner {
        _owners[newOwner] = true;
        emit OwnershipGranted(msg.sender, newOwner);
    }

    /**
     * @dev Remove the address of the owner list.
     */
    function removeOwner(address oldOwner) public virtual onlyOwner {
        _owners[oldOwner] = false;
        emit OwnershipRemoved(msg.sender, oldOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        if (!_owners[msg.sender]) revert InvalidOwner();
        _;
    }

}