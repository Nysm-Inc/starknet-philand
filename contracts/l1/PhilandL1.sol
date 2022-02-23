pragma solidity ^0.8.8;
import "@ensdomains/ens-contracts/contracts/registry/ENSRegistry.sol";

interface IStarknetCore {
    /**
      Sends a message to an L2 contract.
      Returns the hash of the message.
    */
    function sendMessageToL2(
        uint256 to_address,
        uint256 selector,
        uint256[] calldata payload
    ) external returns (bytes32);
}
 
contract PhilandL1 {
     // The StarkNet core contract.
    IStarknetCore _starknetCore;
    ENS internal ens; 

    address private _adminSigner;
    mapping(uint256 => uint256) public userBalances;

    // The selector of the "create_philand" l1_handler.
    uint256 constant CREATE_GRID_SELECTOR =
        230744737155971716570284140634551213064188756564393274009046094202533668423;

    uint256 constant CLAIM_L1_OBJECT_SELECTOR =
        1426524085905910661260502794228018787518743932072178038305015687841949115798;

    uint256 constant CLAIM_L2_OBJECT_SELECTOR =
    725729645710710348624275617047258825327720453914706103365608274738200251740;

    event LogCreatePhiland(address indexed l1Sender, uint256 grid_x, uint256 grid_y, uint256 ensname);
    event LogClaimL1NFT(uint256 ensname,uint256 contract_address,uint256 tokenid);
    event LogClaimL2Object(uint256 ensname,uint256 contract_address,uint256 tokenid);
    /**
      Initializes the contract state.
    */
    constructor(IStarknetCore starknetCore,address adminSigner
    ) public {
        _starknetCore = starknetCore;
        _adminSigner = adminSigner;
    }
        
    function createPhiland(
        uint256 l2ContractAddress,
        uint256 grid_x,
        uint256 grid_y,
        uint256 ensname
        ) external {
        
        emit LogCreatePhiland(msg.sender, grid_x, grid_y,ensname);        
        uint256[] memory payload = new uint256[](3);
        payload[0] = grid_x;
        payload[1] = grid_y;
        payload[2] = ensname;
        // Send the message to the StarkNet core contract.
        _starknetCore.sendMessageToL2(l2ContractAddress, CREATE_GRID_SELECTOR, payload);
    }

    function claimL1Object(
        uint256 l2ContractAddress,
        uint256 ensname,
        address contract_address,
        uint256 tokenid
        ) external {

        emit LogClaimL1NFT(ensname,uint256(uint160(contract_address)),tokenid);        
        uint256[] memory payload = new uint256[](3);
        payload[0] = ensname;
        payload[1] = uint256(uint160(contract_address));
        payload[2] = tokenid;

        // Send the message to the StarkNet core contract.
        _starknetCore.sendMessageToL2(l2ContractAddress, CLAIM_L1_OBJECT_SELECTOR, payload);
    }

    struct Coupon {
    bytes32 r;
    bytes32 s;
    uint8 v;
    }
    
    enum CouponType {
    Genesis,
    Author,
    Presale
    }


    function claimL2Object(
        uint256 l2ContractAddress,
        uint256 ensname,
        address contract_address,
        uint256 tokenid,
        Coupon memory coupon
        ) external {

        bytes32 digest = keccak256(
        abi.encode(CouponType.Presale, msg.sender)
        ); 
    
        require(
        _isVerifiedCoupon(digest, coupon), 
        'Invalid coupon'
        ); 
        emit LogClaimL2Object(ensname,uint256(uint160(contract_address)),tokenid);

        uint256[] memory payload = new uint256[](3);
        payload[0] = ensname;
        payload[1] = uint256(uint160(contract_address));
        payload[2] = tokenid;

        // Send the message to the StarkNet core contract.
        _starknetCore.sendMessageToL2(l2ContractAddress, CLAIM_L2_OBJECT_SELECTOR, payload);
    }

    /// @dev check that the coupon sent was signed by the admin signer
	function _isVerifiedCoupon(bytes32 digest, Coupon memory coupon)
		internal
		view
		returns (bool)
	{
		
		address signer = ecrecover(digest, coupon.v, coupon.r, coupon.s);
		require(signer != address(0), 'ECDSA: invalid signature'); // Added check for zero address
		return signer == _adminSigner;
	}

    

    function toSplitUint(uint256 value) internal pure returns (uint256, uint256) {
    uint256 low = value & ((1 << 128) - 1);
    uint256 high = value >> 128;
    return (low, high);
    }


    function asciiToInteger(bytes32 x) internal pure returns (uint256) {
        uint256 y;
        for (uint256 i = 0; i < 32; i++) {
            uint256 c = (uint256(x) >> (i * 8)) & 0xff;
            if (48 <= c && c <= 57)
                y += (c - 48) * 10 ** i;
            else if (65 <= c && c <= 90)
                y += (c - 65 + 10) * 10 ** i;
            else if (97 <= c && c <= 122)
                y += (c - 97 + 10) * 10 ** i;
            else
                break;
        }
        return y;
    }

}