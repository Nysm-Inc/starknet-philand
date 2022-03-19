// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.8;

import { IENS } from './interfaces/IENS.sol';
import { IStarkNetLike } from './interfaces/IStarkNetLike.sol';
import { MultiOwner } from './utils/MultiOwner.sol';
import './utils/Strings.sol';


contract MessageENS is MultiOwner{

    IStarkNetLike _starknetLike;
    IENS _ens;
    address private _adminSigner;
    address private _ensaddress;    
    address private _starknet;

    mapping (string => address) public owner_lists;
    mapping (string => uint256) public coupon_type;

    bytes32 private baseNode = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;
    bytes32 public label;
    
    uint256 private CREATE_PHILAND_SELECTOR =
        617099311689109934115201364618365113888900634692095419483864089403220532029;

    uint256 private CLAIM_L2_OBJECT_SELECTOR =
    725729645710710348624275617047258825327720453914706103365608274738200251740;

    error InvalidENS (address sender, string name,uint256 ensname_low,uint256 ensname_high ,bytes32 label,address owner, string node);
    error AllreadyClaimedPhiland (address sender, address owner,string name );

    event LogCreatePhiland(address indexed l1Sender, string name);
    event LogClaimL1NFT(string name,uint256 contract_address,uint256 tokenid);
    event LogClaimL2Object(string name,uint256 l2user_address, uint256 tokenid);
    
    struct Coupon {
    bytes32 r;
    bytes32 s;
    uint8 v;
    }

    /**
      Initializes the contract state.
    */
    constructor(address starknet,IENS ens,address adminSigner){
        _starknet = starknet;
        _ens = ens;
        _adminSigner = adminSigner;
        
    }


    function setCreatePhilandSelector(uint256 _createPhilandSelector) external onlyOwner {
        CREATE_PHILAND_SELECTOR = _createPhilandSelector;
    }

    function setClaimL2ObjectSelector(uint256 _claimL2ObjectSelector) external onlyOwner {
        CLAIM_L2_OBJECT_SELECTOR = _claimL2ObjectSelector;
    }

    function setEnsBaseNode(bytes32 _basenode) external onlyOwner {
        baseNode = _basenode;
    }

    function createPhiland(
        uint256 l2ContractAddress,
        string calldata name
        ) external {

        label = createENSLable(name);
        
        uint256 ensname = uint256(label);
        uint256 ensname_low;
        uint256 ensname_high;
        (ensname_low,ensname_high)=toSplitUint(ensname);
        

        if (msg.sender != _ens.owner(label)){
            revert InvalidENS({
                sender: msg.sender,
                name: name,
                ensname_low: ensname_low,
                ensname_high: ensname_high,
                label: label,
                owner: _ens.owner(label),
                node: string(abi.encodePacked(ensname))
            });
        }
        if (owner_lists[name]!= address(0)){
            revert  AllreadyClaimedPhiland({
                sender: msg.sender,
                owner: owner_lists[name],
                name: name
            });
        }

        owner_lists[name]=msg.sender;
        emit LogCreatePhiland(msg.sender, name);

        uint256[] memory payload = new uint256[](2);
        payload[0] = ensname_low;
        payload[1] = ensname_high;

        // Send the message to the StarkNet core contract.
        IStarkNetLike(_starknet).sendMessageToL2(l2ContractAddress, CREATE_PHILAND_SELECTOR, payload);
    }

    function claimL2Object(
        uint256 l2ContractAddress,
        string calldata name,
        uint256 l2UserAddress,
        uint256 tokenid,
        string calldata condition,
        Coupon memory coupon
        ) external {

        bytes32 digest = keccak256(
        abi.encode(coupon_type[condition], msg.sender)
        ); 
    
        require(
        _isVerifiedCoupon(digest, coupon), 
        'Invalid coupon'
        ); 
        emit LogClaimL2Object(name,l2UserAddress,tokenid);

        label = keccak256(abi.encodePacked(baseNode, keccak256(bytes(name))));
        uint256 ensname = uint256(label);
        uint256 ensname_low;
        uint256 ensname_high;
        (ensname_low,ensname_high)=toSplitUint(ensname);

        uint256[] memory payload = new uint256[](5);
        payload[0] = ensname_low;
        payload[1] = ensname_high;
        payload[2] = l2UserAddress;
        (payload[3], payload[4])=toSplitUint(tokenid);

        // Send the message to the StarkNet core contract.
        IStarkNetLike(_starknet).sendMessageToL2(l2ContractAddress, CLAIM_L2_OBJECT_SELECTOR, payload);
    }

    function OwnerOfPhiland(string memory name) external view returns (bool){
        if (owner_lists[name]!=address(0))
            return true;
        else
            return false;
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

    function getCouponType(string calldata condition) view public returns (uint256){
        return coupon_type[condition];
    }

    function setCouponType(string calldata condition,uint256 tokenid) public onlyOwner() {
        coupon_type[condition] = tokenid;
    }

    function createENSLable(string calldata name) private returns (bytes32) {
        strings.slice memory slicee = strings.toSlice(name);
        strings.slice memory delim = strings.toSlice(".");
        string[] memory parts = new string[](strings.count(slicee,delim) + 1);
        for (uint i = 0; i < parts.length; i++) {
            parts[i] = strings.toString(strings.split(slicee,delim));
        }
        if (parts.length==1){
            label = keccak256(abi.encodePacked(baseNode, keccak256(bytes(name))));
        }else{
        for (uint i = parts.length-1; i > 0; i--) {
            if (i==parts.length - 1){
                label = keccak256(abi.encodePacked(baseNode, keccak256(bytes(parts[i]))));
            }else {
                label = keccak256(abi.encodePacked(label, keccak256(bytes(parts[i]))));
            }
            if(i==1){
                label = keccak256(abi.encodePacked(label, keccak256(bytes(parts[0]))));
            }
            }
        }
        return label;
    }
}