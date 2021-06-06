pragma solidity ^0.6.0;


library Storage{

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
}