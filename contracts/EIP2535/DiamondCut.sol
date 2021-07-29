pragma solidity ^0.6.0;

import './interfaces/IDiamondCut.sol';
import './libraries/DiamondStorage.sol';

contract DiamondCut is IDiamondCut{
    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {
        Storage.enforceIsContractOwner();
        for (uint facetIndex; facetIndex < _diamondCut.length; facetIndex++){
            if (_diamondCut[facetIndex].action == IDiamondCut.FacetCutAction.Add){
                addFunction(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            }
            else if (_diamondCut[facetIndex].action == IDiamondCut.FacetCutAction.Replace){
                replaceFunction(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            }
            else if (_diamondCut[i].action == FacetCutAction.Remove){
                removeFunction(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            }
        }
        
        emit DiamondCut(_diamondCut,_init,_calldata);

        if(_init == address(0)){
            require(_calldata.length == 0,"_init is address(0) but call data is not empty");
        }else {
            require(_calldata.length > 0, "_calldata is empty but _init is not address(0)");
            if (_init != address(this)){
                require(isContract(_init),"_init is not a contract");
            }
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if(!success){
                if(error.length > 0){
                    revert(string(error));
                }else{
                    revert("_init fuction reverted");
                }
            }
        }      
        
    }

    function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal{
        require(_functionSelectors.length > 0, "No selectors to cut");
        require(_facetAddress != address(0), "Facet address can't be 0");
        require(isContract(_facetAddress),"Facet is not a contract");
        Storage.DiamondStorage storage ds = Storage.diamondStorage();
        uint16 selectorCount = uint16(ds.selectors.length);
        
        for(uint256 selectorIndex; selectorIndex < _functionSelectors.length; _functionSelectors++){
            bytes4 selctor = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.facetAddressAndSelectorPosition[selector].facetAddress;
            require(oldFacetAddress == address(0), "function already exists");
            ds.facetAddressAndSelectorPosition[selector] = Storage.FacetAddressAndSelectorPosition(_facetAddress,selectorCount);
            ds.selectors.push(selector);
            selectorCount++;
        }
    }

    function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal{
        require(_functionSelectors.length > 0, "No selectors");
        require(isContract(_facetAddress), "is not a contract");
        Storage.DiamondStorage storage ds = Storage.diamondStorage();
        uint16 selectorCount = uint16(ds.selectors.length);

        for(uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++){
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.facetAddressAndSelectorPosition[selector].facetAddress;
            require(oldFacetAddress != address(this), "immutable function");
            require(oldFacetAddress != _facetAddress," can't replace function with the same function");
            require(oldFacetAddress != address(0), "function does not exists");
            ds.facetAddressAndSelectorPosition[selector] = _facetAddress;
        }
    }

    function removeFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal{
        require(_functionSelectors.length > 0, "No selectors");
        require(_facetAddress == address(0), "facet address must be 0");
        uint256 selectorCount = ds.selectors.length;
        Storage.DiamondStorage storage ds = Storage.diamondStorage();

        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++){
            bytes4 selector = _functionSelectors[selectorIndex];
            Storage.FacetAddressAndSelectorPosition memory oldFacetAddressAndSelectorPosition = ds.facetAddressAndSelectorPosition[selector];
            require(oldFacetAddressAndSelectorPosition.facetAddress != address(0), "functions does not exists");
            require(oldFacetAddressAndSelectorPosition.facetAddress != address(this), "immutable function");
            selectorCount--;
            if(oldFacetAddressAndSelectorPosition.selectorPosition != selectorCount){
                bytes4 lastSelector = ds.selectors[selectorCount];
                ds.selectors[oldFacetAddressAndSelectorPosition.selectorPosition] = lastSelector;
                ds.facetAddressAndSelectorPosition[lastSelector].selectorPosition = oldFacetAddressAndSelectorPosition.selectorPosition;
            }
            ds.selectors.pop();
            delete ds.facetAddressAndSelectorPosition[selector];
        } 
    }

    function isContract(address _contract) internal view returns (bool){
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        return (contractSize > 0);
    }
}