pragma solidity ^0.6.0;

import './interfaces/IDiamondCut.sol';

contract DiamondCut is IDiamondCut{
    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);

    enum FacetCutAction {Add, Replace, Remove}
    mapping (bytes4=>address) private _facets;

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
                    require(_facets[_diamondCut[i].functionSelectors[j]] == address(0), "function already exists");
                    _facets[_diamondCut[i].functionSelectors[j]] = _diamondCut[i].facetAddress;
                }
            }
            else if (_diamondCut[i].action == FacetCutAction.Remove){
                for(uint j = 0; j < _diamondCut[i].functionSelectors[j].length; j++){
                    require(_facets[_diamondCut[i].functionSelectors[j]] != address(this));
                    require(_facets[_diamondCut[i].functionSelectors[j]] != address(0), "function does not exists");
                    _facets[_diamondCut[i].functionSelectors[j]] = address(0);
                }
            }
            else if (_diamondCut[i].action == FacetCutAction.Replace){
                for(uint j = 0; j < _diamondCut[i].functionSelectors[j].length; j++){
                    require(_facets[_diamondCut[i].functionSelectors[j]] != address(this));
                    require(_facets[_diamondCut[i].functionSelectors[j]] != _diamondCut[i].facetAddress;);
                    require(_facets[_diamondCut[i].functionSelectors[j]] != address(0), "function does not exists");
                    _facets[_diamondCut[i].functionSelectors[j]] = _diamondCut[i].facetAddress;;
                }
            }
        }
        if(_init == address(0) && _calldata != 0x00){
            revert();
        }
        if(_init != address(0) && _calldata == 0x00){
            revert();
        }
        if(_init != address(0) && _calldata != 0x00){
            _init.delegatecall(_calldata);
        }
        
        emit DiamondCut(_diamondCut,_init,_calldata);
    }
}