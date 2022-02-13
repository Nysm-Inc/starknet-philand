pragma solidity ^0.8.8;
import "@ensdomains/ens-contracts/contracts/registry/ENS.sol";

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
    IStarknetCore starknetCore;
    ENS internal ens; 

    mapping(uint256 => uint256) public userBalances;

    // The selector of the "create_philand" l1_handler.
    uint256 constant CREATE_GRID_SELECTOR =
        230744737155971716570284140634551213064188756564393274009046094202533668423;

    uint256 constant CLAIM_L1_OBJECT_SELECTOR =
        1426524085905910661260502794228018787518743932072178038305015687841949115798;

    event LogCreatePhiland(address indexed l1Sender, uint256 grid_x, uint256 grid_y, uint256 ensname);
    event LogClaimObject(uint256 ensname,uint256 contract_address,uint256 tokenid);
    /**
      Initializes the contract state.
    */
    constructor(IStarknetCore _starknetCore
    ) public {
        starknetCore = _starknetCore;
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
        // payload[2] = asciiToInteger(node);
        payload[2] = ensname;
        // Send the message to the StarkNet core contract.
        starknetCore.sendMessageToL2(l2ContractAddress, CREATE_GRID_SELECTOR, payload);
    }

    function claimObject(
        uint256 l2ContractAddress,
        uint256 ensname,
        address contract_address,
        uint256 tokenid
        ) external {

        emit LogClaimObject(ensname,uint256(uint160(contract_address)),tokenid);        
        uint256[] memory payload = new uint256[](3);
        payload[0] = ensname;
        payload[1] = uint256(uint160(contract_address));
        payload[2] = tokenid;

        // Send the message to the StarkNet core contract.
        starknetCore.sendMessageToL2(l2ContractAddress, CLAIM_L1_OBJECT_SELECTOR, payload);
    }

    function toSplitUint(uint256 value) internal pure returns (uint256, uint256) {
    uint256 low = value & ((1 << 128) - 1);
    uint256 high = value >> 128;
    return (low, high);
    }

    function asciiToInteger(bytes32 x) public pure returns (uint256) {
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