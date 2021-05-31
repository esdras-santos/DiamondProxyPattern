pragma solidity ^0.6.0;

import './interfaces/IDiamondCut.sol';

contract DiamondCut is IDiamondCut{
    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);

    enum FacetCutAction {Add, Replace, Remove}
    mapping (bytes4=>address) private _selectorToAddress;

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {
        for (uint i = 0; i < _diamondCut.length; i++){
            if (_diamondCut[i].action == FacetCutAction.Add){
                for(uint j = 0; j < _diamondCut[i].functionSelectors[j].length; j++){
                    require(_selectorToAddress[_diamondCut[i].functionSelectors[j]] == address(0), "function already exists");
                    
                }
            }
            
        }
    }
}