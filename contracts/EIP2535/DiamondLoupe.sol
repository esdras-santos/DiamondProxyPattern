pragma solidity ^0.6.0;

import './interfaces/IDiamondLoupe.sol';

contract DiamondLoupe is IDiamondLoupe{
     struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    function facets() external override view returns (Facet[] memory facets_){
        Storage.DiamondStorage storage ds = Storage.diamondStorage();
        uint256 selectorCount = ds.selectors.length;

        facets_ = new Facet[](selectorCount);
        uint8[] memory numFacetSelectors = new uint8[](selectorCount);
        uint256 numFacets;

        for(uint256 selectorIndex;selectorIndex < selectorCount;selectorIndex++){
            bytes4 selector = ds.selectors[selectorIndex];
            address facetAddress_ = ds.facetAddressAndSelectorPosition[selector].facetAddress;
            bool continueLoop = false;
            for(uint256 facetIndex;facetIndex < numFacets;facetIndex++){
                if(facets_[facetIndex].facetAddress == facetAddress_){
                    facets_[facetIndex].functionSelectors[numFacetSelectors[facetIndex]] = selector;
                    require(numFacetSelectors[facetIndex] < 255);
                    numFacetSelectors[facetIndex]++;
                    continueLoop = true;
                    break;
                }
            }

            if (continueLoop){
                continueLoop = false;
                continue;
            }

            facets_[numFacets].facetAddress = facetAddress_;
            facets_[numFacets].functionSelectors = new bytes4[](selectorCount);
            facets_[numFacets].functionSelectors[0] = selector;
            numFacetSelectors[numFacets] = 1;
            numFacets++;
        }
        for (uint256 facetIndex; facetIndex < numFacets; facetIndex++){
            uint256 numSelectors = numFacetSelectors[facetIndex];
            bytes4[] memory selectors = facets_[facetIndex].functionSelectors;

            assembly{
                mstore(selectors, numSelectors)
            }
        }
        assembly{
            mstore(facets_,numFacets)
        }
    }

    function facetFunctionSelectors(address _facet) external override view returns (bytes4[] memory _facetFunctionSelectors){
        Storage.DiamondStorage storage ds = Storage.diamondStorage();
        uint256 selectorCount = ds.selectors.length;
        uint256 numSelectors;
        _facetFunctionSelectors = new bytes4[](selectorCount);

        for (uint256 selectorIndex; selectorIndex < selectorCount; selectorIndex++){
            bytes4 selector = ds.selectors[selectorIndex];
            address facetAddress_ = ds.facetAddressAndSelectorPosition[selector].facetAddress;
            if(_facet == facetAddress_){
                _facetFunctionSelectors[numSelectors] = selector;
                numSelectors++;
            }
        }
        assembly{
            mstore(_facetFunctionSelectors, numSelectors)
        }
    }
    
    function facetAddresses() external override view returns (address[] memory facetAddresses_){
        Storage.DiamondStorage storage ds = Storage.diamondStorage();
        uint256 selectorCount = ds.selectors.length;

        facetAddresses_ = new address[](selectorCount);
        uint256 numFacets;

        for (uint256 selectorIndex; selectorIndex < selectorCount; selectorIndex++){
            bytes4 selector = ds.selectors[selectorIndex];
            address facetAddress_ = ds.facetAddressAndSelectorPosition[selector].facetAddress;
            bool continueLoop = false;
            for(uint256 facetIndex; facetIndex < numFacets;facetIndex++){
                if(facetAddress_ == facetAddresses_[facetindex]){
                    continueLoop = true;
                    break;
                }
            }

            if (continueLoop){
                continueLoop = false;
                continue;
            }

            facetAddresses_[numFacets] = facetAddress_;
            numFacets++;
        }
        assembly{
            mstore(facetAddresses_, numFacets)
        }
    }
    
    function facetAddress(bytes4 _functionSelector) external override view returns (address facetAddress_){
        Storage.DiamondStorage storage ds = Storage.diamondStorage();
        facetAddress_ = ds.facetAddressAndSelectorPosition[_functionSelector].facetAddress;
    }
}