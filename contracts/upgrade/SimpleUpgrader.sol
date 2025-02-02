pragma solidity ^0.5.4;

import "../modules/common/BaseModule.sol";

/**
 * @title SimpleUpgrader
 * @dev Temporary module used to add/remove other modules.
 * @author Olivier VDB - <olivier@argent.xyz>, Julien Niset - <julien@argent.im>
 */
contract SimpleUpgrader is BaseModule {

    bytes32 constant NAME = "SimpleUpgrader";
    address[] public toDisable;
    address[] public toEnable;

    // *************** Constructor ********************** //

    constructor(
        ModuleRegistry _registry,
        address[] memory _toDisable,
        address[] memory _toEnable
    )
        BaseModule(_registry, NAME)
        public
    {
        toDisable = _toDisable;
        toEnable = _toEnable;
    }

    // *************** External/Public Functions ********************* //

    /**
     * @dev Perform the upgrade for a wallet. This method gets called
     * when SimpleUpgrader is temporarily added as a module.
     * @param _wallet The target wallet.
     */
    function init(BaseWallet _wallet) external onlyWallet(_wallet) {
        uint256 i;
        //remove old modules
        for(; i < toDisable.length; i++) {
            BaseWallet(_wallet).authoriseModule(toDisable[i], false);
        }
        //add new modules
        for(i = 0; i < toEnable.length; i++) {
            BaseWallet(_wallet).authoriseModule(toEnable[i], true);
        }
        // SimpleUpgrader did its job, we no longer need it as a module
        BaseWallet(_wallet).authoriseModule(address(this), false);
    }
}