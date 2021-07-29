pragma solidity ^0.6.0;


library Storage{
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct FacetAddressAndSelectorPosition{
        address facetAddress;
        //selector position in selectors array
        uint16 selectorPosition;
    }

    struct DiamondStorage{
        mapping (bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
        bytes4[] selectors;
        //mapping (bytes4=>bool) suportedInterfaces;
        address owner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds){
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly{
            ds.slot := position
        }
    }

    function setContractOwner(address _newOwner) internal{
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.owner;
        ds.owner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns(address contractOwner_){
        contractOwner_ = diamondStorage().owner;
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == diamondStorage().owner,"Must be contract owner");
    }
}