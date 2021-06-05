pragma solidity ^0.6.0;

import './interfaces/IDiamondLoupe.sol';

contract DiamondLoupe is IDiamondLoupe{
     struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    function facets() external override view returns (Facet[] memory facets_){

    }

    function facetFunctionSelectors(address _facet) external override view returns (bytes4[] memory facetFunctionSelectors_){

    }
    
    function facetAddresses() external override view returns (address[] memory facetAddresses_){

    }
    
    function facetAddress(bytes4 _functionSelector) external override view returns (address facetAddress_){
        
    }
}